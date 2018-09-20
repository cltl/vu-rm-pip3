import sys
import argparse
import yaml 
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper
import itertools 
import random
import logging
from subprocess import SubprocessError, Popen, PIPE

logger = logging.getLogger(__name__)
#logging.basicConfig(format='%(name)s - %(levelname)s - %(message)s',
logging.basicConfig(format='%(message)s',
                filename='pipeline.log',
                filemode='w',
                level=logging.INFO)

"""
finds a valid execution order for the pipeline
"""    
def pipe(modules, selector, completed=[]):
    in_pipeline = []
    available_outputs = []
    if completed:
        available_outputs = list(itertools.chain.from_iterable(m['output'] for m in completed))
    else:
        available_outputs = list(itertools.chain.from_iterable(m['output'] for m in modules if 'status' in m and m['status'] == 'completed'))
        modules = [m for m in modules if 'status' not in m or m['status'] != 'completed']
    
    candidates = []
    max_rank = len(modules)
    def valid_input(mod, avail, pipe):
        in_ok = not mod['input'] or all(i in avail for i in mod['input'])
        after_ok = 'after' not in mod or all(any(n == m['name'] for m in pipe) for n in mod['after'])
        return in_ok and after_ok        

    for rank in range(max_rank):
        if modules:
            new_candidates = list(filter(lambda m: valid_input(m, available_outputs, in_pipeline), modules))
            for c in new_candidates:
                modules.remove(c)
            candidates.extend(new_candidates)
                
        if candidates:
            selected = selector(candidates)
            candidates.remove(selected)
            in_pipeline.append(selected)
            available_outputs.extend(selected['output'])
    return in_pipeline

def repr_module(m):
    after = None
    if 'after' in m:
        after = m['after']
    return '{} -- in: {}; out: {}; after: {}'.format(m['name'], m['input'], m['output'], after) 

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


def run(scheduled, input_file, output_file, bindir):
    modules = [m for m in scheduled]
    completed = []
    failed = []
    not_run = [m for m in modules]
    with open(output_file, 'w') as fi:
        fi.write(input_file.read())
    while modules:
        m, *modules = modules
        logger.info('-- Running ' + m['name'])
        not_run.remove(m)
        fi = open(output_file, 'r') 
        p = Popen([bindir + m['cmd']], stdin=fi, stdout=PIPE, stderr=PIPE)
        if find_error(iter(p.stderr.readline, b'')):
            failed.append(m)
            logger.error("module " + m['name'] + " returned an error")
            logger.info('\n-- Rebuilding pipeline with remaining modules...')
            modules = pipe(modules, lambda x: x[0], completed)
            logger.info('pipeline can continue running with these modules: {}'.format([m['name'] for m in modules]))
        else:
            completed.append(m)
            fi.close()
            out, err = p.communicate()
            with open(output_file, 'w') as fo:
                fo.write(out.decode())
    
    update_status(scheduled, completed, failed, not_run)
    with open(output_file, 'r') as f: 
        out = f.read()
    return out

def update_status(scheduled, completed, failed, not_run):
    for m in completed:
        m['status'] = 'completed'
    for m in not_run:
        m['status'] = 'not_run'
    for m in failed:
        m['status'] = 'failed'
    logger.info('\n-- Finished running pipeline')
    logger.info('- scheduled: {}'.format([m['name'] for m in scheduled]))
    logger.info('- completed: {}'.format([m['name'] for m in completed]))
    logger.info('- failed: {}'.format([m['name'] for m in failed]))
    logger.info('- not run: {}'.format([m['name'] for m in not_run]))

class Pipeline():
    def __init__(self, yml_cfg, bindir='./scripts/bin/'):
        self.bindir = bindir
        with open(yml_cfg, 'r') as f:    
            self.modules = yaml.load(f)
        self.build_pipeline()

    @property
    def bindir(self):
        return self._bindir
 
    @property
    def modules(self):
        return self._modules
 
    @modules.setter
    def modules(self, val):
        self._modules = val

    @bindir.setter
    def bindir(self, val):
        self._bindir = val

    def build_pipeline(self):
        self.modules = pipe(self._modules, lambda xs: xs[0]) 

    def build_random_pipeline(self):
        self.modules = pipe(self._modules, lambda xs: random.choice(xs)) 

    def run(self, infile, outfile):
        out = run(self._modules, infile, outfile, self._bindir)
        with open('cfg_out.yml', 'w') as f:
            f.write(yaml.dump(self._modules))

        return out

    def completed(self):
        return [m for m in self._modules if m['status'] == 'completed']

    def failed(self):
        return [m for m in self._modules if m['status'] == 'failed']

    def not_run(self):
        return [m for m in self._modules if 'status' not in m or  m['status'] == 'not_run']
 

if __name__ == "__main__":
    import sys
    import io

    parser = argparse.ArgumentParser(description='Newsreader pipeline')
    parser.add_argument('-c', '--cfg_file', dest='cfg_file', type=str, help='config file')
    parser.add_argument('-d', '--bin_dir', dest='bin_dir', default='./scripts/bin/', type=str, help='module scripts directory')
    args = parser.parse_args()
    cfg_file = args.cfg_file
    bin_dir = args.bin_dir
    output_file = 'pipeline.out'

    pipeline = Pipeline(cfg_file, bin_dir)
    input_file = sys.stdin
    out = pipeline.run(input_file, output_file)
