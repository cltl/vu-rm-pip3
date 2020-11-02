from wrapper import dag
import yaml
import shlex
import re
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper
from subprocess import Popen, PIPE
import tempfile
import os
import logging
logger = logging.getLogger(__name__)

ROOT = 'root'


def create_root():
    return Component({'name': ROOT, 'output': [], 'cmd': None})


def build_pipeline(components):
    graph = dag.create_graph(ROOT, create_root())
    for m in components:
        graph.add_vertex(m.id, m)
    # adds edges based on component precedence
    for m in components:
        if not m.ins:
            graph.add_edge(ROOT, m.id)
        for m2 in components:
            if m.id != m2.id and m2.depends_on(m):
                graph.add_edge(m.id, m2.id)
    return graph


def is_alpino_text(line):
    alpino1 = r"^\[.*\]"
    alpino2 = r"^Q#[0-9].*"
    return re.search(alpino1, line) or re.search(alpino2, line)


def has_error_keyword(line):
    return 'Exception' in line or 'Error' in line or ' error' in line or ' fault' in line


def find_error(stderr_iterator):
    found_error = False
    for line in stderr_iterator:
        line = line.decode().strip()
        if has_error_keyword(line) and not is_alpino_text(line):
            logger.error(line)
            found_error = True
        else:
            logger.info(line)
    return found_error


def test_silent_failure(out):
    out.seek(0, os.SEEK_END)
    if out.tell():
        out.seek(0)
        return False
    else:
        return True


def reschedule(completed, remaining):
    """
    determines which components in 'remaining' can be run based on the
    'completed' components
    """
    visited = [m.node.id for m in completed]
    available_layers = set()
    for v in completed:
        available_layers.update(set(v.node.out))
    to_run = []
    for m in remaining:
        flag = False
        if m.node.after:
            flag = all(p in visited for p in m.node.after)
        else:
            flag = all(x in available_layers for x in m.node.ins)
        if flag:
            visited.append(m.node.id)
            available_layers.update(m.node.out)
            to_run.append(m)
    return to_run


def run(scheduled, input_file, bindir):
    components = [m for m in scheduled]
    completed = []
    failed = []
    not_run = [m for m in components]

    infile = tempfile.TemporaryFile()
    infile.write(bytes(input_file.read(), 'UTF-8'))

    while components:
        m, *components = components
        logger.info('-- Running ' + m.node.id)
        not_run.remove(m)

        out = tempfile.TemporaryFile()
        infile.seek(0)
        margs = shlex.split(m.node.cmd)
        margs[0] = bindir + margs[0]
        p = Popen(margs, stdin=infile, stdout=out, stderr=PIPE)
        component_failure = find_error(iter(p.stderr.readline, b''))
        silent_failure = test_silent_failure(out)
        if component_failure or silent_failure:
            failed.append(m)
            logger.error("component " + m.node.id + " failed")
            logger.info('\n-- Rebuilding pipeline with remaining components...')
            components = reschedule(completed, components)
            logger.info('pipeline can continue running with these components: {}'.format(
                [m.node.id for m in components]))
        else:
            completed.append(m)
            infile.close()
            infile = out
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


def load_components(yml_cfg, subargs):
    logger.info('Loading components from config...')
    with open(yml_cfg, 'r') as f:
        component_dicts = yaml.full_load(f)
    components = [Component(m) for m in component_dicts]
    if subargs:
        logger.info('The following component scripts will be called with non-default options:')
        for m in components:
            if m.id in subargs.keys():
                logger.info('{}: {}'.format(m.cmd, subargs[m.id]))
                m.cmd = '{} {}'.format(m.cmd, subargs[m.id])
    return components


def create_components(component_dicts):
    components = [Component(m) for m in component_dicts]
    return components


def create_pipeline(yml_cfg, in_layers=[], goal_layers=[], excepted_components=[], bindir='./scripts/bin/', subargs={}):
    components = load_components(yml_cfg, subargs)
    components = [c for c in components if c.id not in excepted_components]
    return Pipeline(components, in_layers, goal_layers, bindir)


class Component:
    """ Defines a pipeline component. """

    def __init__(self, mdict):
        if 'input' in mdict and mdict['input']:
            self.ins = mdict['input']
        else:
            self.ins = []
        self.out = mdict['output']
        self.cmd = mdict['cmd']
        self.id = mdict['name']
        if 'after' in mdict:
            self.after = mdict['after']
        else:
            self.after = []

    def __str__(self):
        return self.id

    def depends_on(self, parent):
        """defines precedence relation for pipeline assembly and execution

        parent is either required by 'after' or it *outputs* an input layer to this component.
        In the latter case, one distinguishes between components that modify a layer or
        produce a new one: the first type are connected only to a parent that *produces* the
        layer; the second type is connected to any parent that *outputs* the layer.
        The motivation for this distinction is to avoid cycles for the first type, and to
        let all components acting on a layer have precedence on the components for following
        layers.
        """
        if self.after:
            return parent.id in self.after
        else:
            for x in parent.out:
                if x in self.ins and x in self.out:
                    return x not in parent.ins
                elif x in self.ins and x not in self.out:
                    return True
            return False

    def satisfies_dependencies(self, parents):
        """tests if config dependencies are all present in pipeline"""
        if self.after:
            available = [p.id for p in parents]
            return all(x in available for x in self.after)
        else:
            available = set()
            for p in parents:
                available.update(set(p.out))
            return all(x in available for x in self.ins)


class Pipeline:
    def __init__(self, components, in_layers=[], goal_layers=[], bindir='./scripts/bin/'):
        self.bindir = bindir
        self.graph = build_pipeline(components)
        self.test_completeness()
        if in_layers:
            self.keep_from(in_layers)
        if goal_layers:
            self.keep_until(goal_layers)

    def nb_components(self):
        return len(self.graph.items()) - 1

    def topological_sort(self):
        stack = self.graph.topological_sort()
        stack.pop(0)  # pops root
        return stack

    def keep_until(self, layers):
        """keeps vertices that output `layers` and their parent vertices"""
        goal_components = self.graph.find_keys(lambda k: any(x in k.node.out for x in layers))
        if goal_components:
            path_to = set()
            for g in goal_components:
                path_to.update(self.graph.on_path_to(g))

            not_on_path = [k for k in self.graph.keys() if k not in path_to]
            self.graph.detach(not_on_path)
        else:
            logger.info("Found no goal components for filtering up to the layers:\n{}".format(layers))

    def keep_from(self, layers):
        """keeps vertices that output 'layers' and their children"""
        start_components = self.graph.find_keys(lambda k: any(x in k.node.out for x in layers))
        if start_components:
            path_from = set()
            path_to = set()
            for g in start_components:
                path_from.update(self.graph.on_path_from(g))
                path_to.update(self.graph.on_path_to(g))

            # prunes out components that do not depend on, or lead to the production of 'layers'
            not_accounted_for = [x for x in self.graph.keys(
            ) if x not in path_from and x not in path_to]
            self.graph.prune(not_accounted_for)

            # detaches upstream components (that produce the layers required for running the pipeline from 'layers')
            upstream = [x for x in path_to if x not in start_components and x != ROOT]
            self.graph.detach(upstream)
            # and connects leading vertices to root
            for v in start_components:
                self.graph.add_edge(ROOT, v)
        else:
            logger.info("Found no goal components for filtering down from the layers:\n{}".format(layers))

    def test_completeness(self):
        """ensures that all required edges are present based on component definitions"""
        orphans = []
        for v in self.graph.vertices():
            if not v.node.satisfies_dependencies([p.node for p in v.parents]):
                orphans.append(v.node.id)
        if orphans:
            raise ValueError(
                "Some config dependencies are missing from the pipeline for the following components: {}\nRefusing to build pipeline.".format(orphans))
        else:
            logger.info("Pipeline is complete.")

    def execute(self, infile):
        try:
            scheduled = self.topological_sort()
            summary = run(self.topological_sort(), infile, self.bindir)
            return summary
        except ValueError as e:
            logger.error(e)
            logger.error("Pipeline cannot be executed. Exiting now.")
