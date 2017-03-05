import os
import itertools
import argparse
import time
from time_process import time_process
from prettify import prettify
from reset_caches import reset_caches
import subprocess
from statistics import median


# Set relative pathnames
dirname = os.path.dirname(os.path.realpath(__file__))
rootdir = os.path.join(dirname, '..')

parser = argparse.ArgumentParser()
parser.add_argument("-o", "--outfile", type=str, default=os.path.join(dirname, 'results', '{}.tsv'.format(time.strftime("%Y-%m-%d_%H-%M-%S"))), help="Output file for results")
parser.add_argument("-c", "--compiler", type=str, default="gcc", help="Compiler to use for testing purposes. specify 'gcc' or 'icc'")
parser.add_argument("-r", "--repetitions", type=int, default=3, help="Number of repetitions used to calculate average. Default 3")
parser.add_argument("-p", "--ppflags", type=str, default=os.path.join(dirname, 'ppflags.txt'), help="File containing set of pre-processor flags to permute")
args = parser.parse_args()


# Make reference
try:
    make_ref = subprocess.check_call(['make', '-B', '-C', os.path.join(dirname, 'tourtre-simple-baseline')], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
except subprocess.CalledProcessError as e:
    print("make ref failed with this exception:\n\n{}\n\n Exiting...".format(str(e)))
    exit(1)


# Output file
if 'results' in args.outfile:
    outdir = os.path.join(dirname, 'results')
    if not os.path.exists(outdir):
        os.makedirs(outdir)

# Get pre-processor flags
ppflags_perms = []
try:
    ppflags = [line.rstrip('\n') for line in open(os.path.join(dirname, args.ppflags), 'r')]

    # Get every permutation of ppflags
    for j in range(len(ppflags)+1):
        perms = list(itertools.permutations(ppflags, j))
        for i in range(len(perms)):
            ppflags_perms.append(perms[i])
    ppflags_perms.reverse()
except FileNotFoundError:
    print('Could not find {}. Running with no flags.'.format(args.ppflags))



# Directories for executables
ref_simple = os.path.join(dirname, 'tourtre-simple-baseline', 'examples', 'simple', 'simple')
improved_simple = os.path.join(rootdir, 'examples', 'simple', 'simple')

# Get list of input files
input_files = sorted(set([f for f in os.listdir(os.path.join(rootdir, 'sampledata')) if f.lower().endswith(('.uint8', '.uint16'))]))


statsfile = open(args.outfile, 'w')  # Open outfile
ref_times = {}  # Store ref impl times

# Execute ref implementation
for filename in input_files:

    reset_caches()

    execute_ref = subprocess.Popen([ref_simple, '-i', os.path.join(rootdir, 'sampledata', filename), '-o', '/tmp/ref_' + filename], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    ref_time, ref_stdout, ref_stderr = time_process(execute_ref)

    ref_times[filename] = ref_time


# Execute improved implementation for every permutation of ppflags
for perm in ppflags_perms:
    flags = " ".join(perm)
    results = []
    result = ''

    # Make improved
    try:
        make_cmd = ['make', '-B', '-C', rootdir, 'PPFLAGS='+flags, 'CC='+args.compiler]
        make_improved = subprocess.check_call(make_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print("make improved failed with these flags: {} \n\nwith this exception:\n\n{}".format(flags, str(e)))
        continue

    # Execute for every input
    for filename in input_files:
        times = [None for rep in range(args.repetitions)]

        # Repeat to get an average
        for rep in range(args.repetitions):
            reset_caches()

            execute_improved = subprocess.Popen([improved_simple, '-i', os.path.join(rootdir, 'sampledata', filename), '-o', '/tmp/improved_'+filename], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            improved_time, improved_stdout, improved_stderr = time_process(execute_improved)

            # Check if different
            try:
                diff = subprocess.check_call(['diff', '/tmp/ref_'+filename, '/tmp/improved_'+filename], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

                # If not different
                times[rep] = improved_time

            except subprocess.CalledProcessError:
                # If different
                result = [filename, 'flags', flags, 'Outputs Differ on rep {}'.format(rep)]
                continue

        median_improved_time = median(times)
        speedup = ref_times[filename] / median_improved_time
        result = [filename, 'flags', flags, 'ref', str(ref_times[filename]), 'improved', str(median_improved_time), 'speedup', str(speedup)]

        # Output result
        results.append(result)



    pretty_results = prettify(results)

    # Print result
    for line in pretty_results:
        print(line)
        statsfile.write(line + '\n')

    print('\n')
    statsfile.write('\n')
    statsfile.flush()