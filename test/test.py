
import os
import itertools
import argparse
from time_process import *
from prettify import *
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("-o", "--outfile", type=str, default='results/{}'.format(time.strftime("%Y_%m_%d__%H_%M_%S")), help="Output file for results")
args = parser.parse_args()


# Make reference
try:
    make_ref = subprocess.check_call(['make', '-B', '-C', 'tourtre-simple-baseline/'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
except subprocess.CalledProcessError:
    print("make ref failed. Exiting...")
    exit(1)


# Output file
if args.outfile.startswith('results'):
    outdir = 'results'
    if not os.path.exists(outdir):
        os.makedirs(outdir)

# Get pre-processor flags
ppflags_perms = []
try:
    ppflags = [line.rstrip('\n') for line in open('ppflags.txt', 'r')]

    # Get every permutation of ppflags
    for j in range(len(ppflags)+1):
        perms = list(itertools.permutations(ppflags, j))
        for i in range(len(perms)):
            ppflags_perms.append(perms[i])
    ppflags_perms.reverse()
except FileNotFoundError:
    print('Could not find ppflags.txt. Running with no flags.')



# Directories for executables
ref_simple = 'tourtre-simple-baseline/examples/simple/simple'
improved_simple = '../examples/simple/simple'

# Get list of input files
input_files = os.listdir('./sampledata')


statsfile = open(args.outfile, 'w')  # Open outfile
ref_times = {}  # Store ref impl times

# Execute ref implementation
for file in input_files:
    execute_ref = subprocess.Popen([ref_simple, '-i', 'sampledata/' + file, '-o', '/tmp/ref_' + file], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    ref_time, ref_stdout, ref_stderr = time_process(execute_ref)

    ref_times[file] = ref_time


# Execute improved implementation for every permutation of ppflags
for perm in ppflags_perms:
    flags = " ".join(perm)
    results = []
    result = ''

    # Make improved
    try:
        make_cmd = ['make', '-B', '-C', '../', 'PPFLAGS='+flags]
        make_improved = subprocess.check_call(make_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError:
        print("make improved failed with flags " + flags)
        continue

    # Execute for every input
    for file in input_files:
        execute_improved = subprocess.Popen([improved_simple, '-i', 'sampledata/'+file, '-o', '/tmp/improved_'+file], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        improved_time, improved_stdout, improved_stderr = time_process(execute_improved)

        # Check if different
        try:
            diff = subprocess.check_call(['diff', '/tmp/ref_'+file, '/tmp/improved_'+file], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            # If not different
            speedup = ref_times[file] / improved_time
            result = [file, 'flags', flags, 'ref', str(ref_times[file]), 'improved', str(improved_time), 'speedup', str(speedup)]

        except subprocess.CalledProcessError:
            # If different
            result = [file, 'flags', flags, 'Outputs Differ']

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