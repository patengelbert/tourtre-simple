
import os
import itertools
import argparse
from time_process import *
from prettify import *
import subprocess

dirname = os.path.dirname(os.path.realpath(__file__))
rootdir = os.path.join(dirname, '..')

parser = argparse.ArgumentParser()
parser.add_argument("-o", "--outfile", type=str, default=os.path.join(dirname, 'results', '{}'.format(time.strftime("%Y_%m_%d__%H_%M_%S"))), help="Output file for results")
args = parser.parse_args()


# Make reference
try:
    make_ref = subprocess.check_call(['make', '-B', '-C', os.path.join(dirname, 'tourtre-simple-baseline')], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
except subprocess.CalledProcessError as e:
    print(e)
    print("make ref failed. Exiting...")
    exit(1)


# Output file
if 'results' in args.outfile:
    outdir = os.path.join(dirname, 'results')
    if not os.path.exists(outdir):
        os.makedirs(outdir)

# Get pre-processor flags
ppflags_perms = []
try:
    ppflags = [line.rstrip('\n') for line in open(os.path.join(dirname, 'ppflags.txt'), 'r')]

    # Get every permutation of ppflags
    for j in range(len(ppflags)+1):
        perms = list(itertools.permutations(ppflags, j))
        for i in range(len(perms)):
            ppflags_perms.append(perms[i])
    ppflags_perms.reverse()
except FileNotFoundError:
    print('Could not find ppflags.txt. Running with no flags.')



# Directories for executables
ref_simple = os.path.join(dirname, 'tourtre-simple-baseline', 'examples', 'simple', 'simple')
improved_simple = os.path.join(rootdir, 'examples', 'simple', 'simple')

# Get list of input files
input_files = set([f for f in os.listdir(os.path.join(rootdir, 'sampledata')) if f.lower().endswith(('.uint8', '.uint16'))])


statsfile = open(args.outfile, 'w')  # Open outfile
ref_times = {}  # Store ref impl times

# Execute ref implementation
for filename in input_files:
    os.system("sudo sh -c 'free; sync; echo 3 > /proc/sys/vm/drop_caches; free;'")
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
        make_cmd = ['make', '-B', '-C', rootdir, 'PPFLAGS='+flags]
        make_improved = subprocess.check_call(make_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError:
        print("make improved failed with flags " + flags)
        continue

    # Execute for every input
    for filename in input_files:
        os.system("sudo sh -c 'free; sync; echo 3 > /proc/sys/vm/drop_caches; free;'")
        execute_improved = subprocess.Popen([improved_simple, '-i', os.path.join(rootdir, 'sampledata', filename), '-o', '/tmp/improved_'+filename], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        improved_time, improved_stdout, improved_stderr = time_process(execute_improved)

        # Check if different
        try:
            diff = subprocess.check_call(['diff', '/tmp/ref_'+filename, '/tmp/improved_'+filename], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            # If not different
            speedup = ref_times[filename] / improved_time
            result = [filename, 'flags', flags, 'ref', str(ref_times[filename]), 'improved', str(improved_time), 'speedup', str(speedup)]

        except subprocess.CalledProcessError:
            # If different
            result = [filename, 'flags', flags, 'Outputs Differ']

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