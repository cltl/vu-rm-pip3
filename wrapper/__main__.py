import sys
import io
import argparse
from wrapper import pipeline
import logging
logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(description='VU Reading Machine pipeline')
parser.add_argument('-c', '--cfg_file', dest='cfg_file', default='./example/pipeline.yml', type=str, help='config file')
parser.add_argument('-d', '--bin_dir', dest='bin_dir', default='./scripts/bin/', type=str, help='module scripts directory')
parser.add_argument('-i', '--in_layers', dest='in_layers_str', type=str, help='input layers (comma-separated list string)')
parser.add_argument('-o', '--out_layers', dest='out_layers_str', type=str, help='output layers (comma-separated list string)')
parser.add_argument('-m', '--goal_modules', dest='goal_modules_str', type=str, help='goal modules (comma-separated list string)')
parser.add_argument('-l', '--log_file', dest='log_file', type=str, help='log file')
parser.add_argument('-s', '--module_args', dest='module_args', type=str, help='module arguments string')

args = parser.parse_args()
logging.basicConfig(format='%(message)s',
                filename=args.log_file,
                filemode='w',
                level=logging.INFO)
cfg_file = args.cfg_file
bin_dir = args.bin_dir

input_layers = [] 
if args.in_layers_str is not None:
    input_layers = args.in_layers_str.split(',')

output_layers = [] 
if args.out_layers_str is not None:
    output_layers = args.out_layers_str.split(',')

goal_modules = [] 
if args.goal_modules_str is not None:
    goal_modules = args.goal_modules_str.split(',')

subargs = {}
if args.module_args is not None:
    for argv in args.module_args.split(';'):
        mod_name, opt_name, opt_val = argv.split(':')
        subargs[mod_name] = '{} {}'.format(opt_name, opt_val)

p = pipeline.create_pipeline(cfg_file, in_layers=input_layers, goal_layers=output_layers, goal_modules=goal_modules, bindir=bin_dir, subargs=subargs)

input_file = sys.stdin
p.execute(input_file)
