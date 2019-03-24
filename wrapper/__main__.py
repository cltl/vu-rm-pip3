import sys
import io
import argparse
from wrapper import pipeline
import logging
logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(description='VU Reading Machine pipeline')
parser.add_argument('-c', '--cfg_file', dest='cfg_file', default='./cfg/pipeline.yml', type=str, help='config file')
parser.add_argument('-d', '--bin_dir', dest='bin_dir', default='./scripts/bin/', type=str, help='component scripts directory')
parser.add_argument('-i', '--in_layers', dest='in_layers_str', type=str, help='input layers and their prerequisite components are filtered out (comma-separated list string)')
parser.add_argument('-o', '--out_layers', dest='out_layers_str', type=str, help='only runs the components needed to produce the given output layers (comma-separated list string)')
parser.add_argument('-e', '--exclude_components', dest='exclude_components_str', type=str, help='excludes components from the pipeline (comma-separated list string)')
parser.add_argument('-l', '--log_file', dest='log_file', type=str, help='log file')
parser.add_argument('-s', '--component_args', dest='component_args', type=str, help='component arguments string')

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

exclude_components = [] 
if args.exclude_components_str is not None:
    exclude_components = args.exclude_components_str.split(',')

subargs = {}
if args.component_args is not None:
    for argv in args.component_args.split(';'):
        mod_name, opt_name, opt_val = argv.split(':')
        subargs[mod_name] = '{} {}'.format(opt_name, opt_val)

try:
    p = pipeline.create_pipeline(cfg_file, in_layers=input_layers, goal_layers=output_layers, excepted_components=exclude_components, bindir=bin_dir, subargs=subargs)
    input_file = sys.stdin
    p.execute(input_file)
except ValueError as e:
    logger.error(e)

