import sys
import os
import itertools
import argparse
import time

parser = argparse.ArgumentParser()
op_sys = parser.add_mutually_exclusive_group()
op_sys.add_argument("-w", "--windows", action="store_true", help="Using windows")
op_sys.add_argument("-l", "--linux", action="store_true", help="Using Linux")
parser.add_argument("-m", "--makepath", type=str, default='', help="Path to make.exe if on Windows")
parser.add_argument("-o", "--outfile", type=str, default='results/{}'.format(time.strftime("%Y_%m_%d__%H_%M_%S")), help="Output file for results")
args = parser.parse_args()


# Directories for executables
ref_simple = 'tourtre-simple-baseline/examples/simple/simple'
improved_simple = '../examples/simple/simple'

# Get list of input files
inputs = os.listdir('./sampledata')

if args.outfile.startswith('results'):
    outdir = 'results'
    if not os.path.exists(outdir):
        os.makedirs(outdir)

lin_make = 'make -C tourtre-simple-baseline/ > /dev/null && make -C ../ > /dev/null'
win_make = args.makepath + '  -C tourtre-simple-baseline\ > /dev/null && make -C ../ > /dev/null'