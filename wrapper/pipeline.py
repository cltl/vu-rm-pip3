from wrapper import dag
#import wrapper.dag.Graph
import yaml 
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper
from subprocess import SubprocessError, Popen, PIPE
import tempfile
import logging
logger = logging.getLogger(__name__)
#logging.basicConfig(format='%(message)s',
#                filename='pipeline.log',
#                filemode='w',
#                level=logging.INFO)


def build_pipeline(modules):
    graph = dag.Graph()
    graph.add_vertex('root', createRoot())
    for m in modules:
        graph.add_vertex(m.id, m)

    for m in modules:
        if not m.ins:
            graph.add_edge('root', m.id)
        for m2 in modules:
            if m.id != m2.id and m2.follows(m):
                graph.add_edge(m.id, m2.id)
    return graph

def find_error(stderr_iterator):
    found_error = False
    for line in stderr_iterator:
        line = line.decode().strip()
        if 'Exception' in line or 'Error' in line or 'error' in line or ' fault' in line:
            logger.error(line)
            found_error = True
        else:
            logger.info(line)
    return found_error

"""
filters remaining modules (in executable order) that can be executed 
after a list of completed modules
"""
def reschedule(completed, remaining): 
    visited = [m.node.id for m in completed]
    to_run = []
    for m in remaining:
        if all(x.node.id in visited for x in m.parents):
            visited.append(m.node.id)
            to_run.append(m)
    return to_run    

"""
runs a pipeline from an ordered list of module vertices 
"""
def run(scheduled, input_file, bindir):
    modules = [m for m in scheduled]
    completed = []
    failed = []
    not_run = [m for m in modules]

    infile = tempfile.TemporaryFile()
    infile.write(bytes(input_file.read(), 'UTF-8'))

    while modules:
        m, *modules = modules
        logger.info('-- Running ' + m.node.id)
        not_run.remove(m)

        out = tempfile.TemporaryFile()
        infile.seek(0) 
        p = Popen([bindir + m.node.cmd], stdin=infile, stdout=out, stderr=PIPE)
        module_failure = find_error(iter(p.stderr.readline, b''))
        if module_failure:
            failed.append(m)
            logger.error("module " + m.node.id + " returned an error")
            logger.info('\n-- Rebuilding pipeline with remaining modules...')
            modules = reschedule(completed, modules)
            logger.info('pipeline can continue running with these modules: {}'.format([m.node.id for m in modules]))
        else:
            completed.append(m)
            infile.close()   
            infile =  out
    infile.seek(0) 
    print(infile.read().decode(), end="")
    infile.close()
    return update_status(scheduled, completed, failed, not_run)
    
def update_status(scheduled, completed, failed, not_run):
    status = {}
    for m in completed:
        status[m.node.id] = 'completed'
    for m in not_run:
        status[m.node.id] = 'not_run'
    for m in failed:
        status[m.node.id] = 'failed'
    logger.info('\n-- Finished running pipeline')
    logger.info('- scheduled: {}'.format([m.node.id for m in scheduled]))
    logger.info('- completed: {}'.format([m.node.id for m in completed]))
    logger.info('- failed: {}'.format([m.node.id for m in failed]))
    logger.info('- not run: {}'.format([m.node.id for m in not_run]))
    return status

def create_pipeline(yml_cfg, in_layers=[], goal_layers=[], goal_modules=[], bindir='./scripts/bin/'):
    with open(yml_cfg, 'r') as f:
        modules = yaml.load(f)
    return Pipeline(modules, in_layers, goal_layers, goal_modules, bindir)

def createRoot():
    return Module({'name': 'root', 'output': 'raw', 'cmd': 'none'})

"""
Defines a module with input and output layers, and a name pointing to a shell script for running that module
"""
class Module:
    def __init__(self, mdict):
        if 'input' in mdict and mdict['input']:
            self._ins = mdict['input']
        else:
            self._ins = []
        self._out = mdict['output']
        self._cmd = mdict['cmd']
        self._id = mdict['name']
        if 'after' in mdict:
            self._after = mdict['after']
        else:
            self._after = []
    
    def __str__(self):
        return self._id

    @property
    def ins(self):
        return self._ins

    @ins.setter
    def ins(self, val):
        self._ins = val

    @property
    def out(self):
        return self._out

    @out.setter
    def out(self, val):
        self._out = val

    @property
    def after(self):
        return self._after

    @after.setter
    def after(self, val):
        self._after = val

    @property
    def id(self):
        return self._id

    @id.setter
    def id(self, val):
        self._id = val

    @property
    def cmd(self):
        return self._cmd

    @cmd.setter
    def cmd(self, val):
        self._cmd = val

    """
    parent is either required by 'after' or it *produces* an input layer to this module;
    a module either produces a layer (if it is *not in its input*) or modifies it.
    """
    def follows(self, parent):
        return parent.id in self._after or any(x in self._ins and x not in parent.ins for x in parent.out)


class Pipeline:
    def __init__(self, module_dicts, in_layers=[], goal_layers=[], goal_modules=[], bindir='./scripts/bin/'):
        self.bindir = bindir
        modules = [Module(m) for m in module_dicts]
        self.graph = build_pipeline(modules)
        if goal_layers:
            self.filter_layers(goal_layers)
        if goal_modules:
            try:
                self.filter_goals(goal_modules)
            except KeyError:
                logger.error('Error while filtering modules; verify that they are within your goal layers')
                raise KeyError
        if in_layers:
            self.filter_input_layers(in_layers, goal_modules)

    def nb_modules(self):
        return len(self.graph.items()) - 1

    def topological_sort(self):
        stack = self.graph.topological_sort()
        stack.pop(0) # pops root
        return stack

    def filter_goals(self, goals):
        path = set()
        for g in goals:
            path.update(self.graph.on_path_to(g)) 
        to_filter = [k for k in self.graph.get_keys() if k not in path]
        for k in to_filter:
            self.graph.remove_key(k)
        for v in self.graph.get_vertices():
            v.children = [c for c in v.children if c.node.id not in to_filter] 

    def filter_layers(self, layers):
        goals = set(self.graph.find_keys(lambda v: any(x in v.node.out for x in layers))) 
        self.filter_goals(goals) 
 
    def filter_input_layers(self, layers, goal_modules):
        # filter modules producing 'layers'
        to_filter = set(self.graph.find_keys(lambda v: any(x in v.node.out for x in layers))) 
        # ... excepted modules in 'with_modules'
        for m in goal_modules:
            if m in to_filter:
                to_filter.remove(m)

        # remove input layers and reconnect their direct children to root
        for k in to_filter:
            self.graph.remove_key(k)
        # remove edges from filtered parents 
        for v in self.graph.get_vertices():    
            v.parents = [p for p in v.parents if p.node.id not in to_filter]
        self.graph.get_vertex('root').children = [] 
        for k in self.graph.get_keys():
            if k != 'root' and not self.graph.get_vertex(k).parents:
                self.graph.add_edge('root', k)


    def execute(self, infile):
        summary = run(self.topological_sort(), infile, self.bindir)
        return summary

