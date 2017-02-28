#!/bin/bash

TIMEFORMAT='%3R'

# Set output dir, or set to results dir if not specified
outdir=${1:-'results/'}

echo $outdir

# Set output file name
outfile=${outdir}/$(date +"%Y-%m-%d_%H-%M-%S").results

# Directories for executables
ref_simple='tourtre-simple-baseline/examples/simple/simple'
improved_simple='../examples/simple/simple'

# Make reference
make -C tourtre-simple-baseline/

# Make improved
make -C ../

# Get list of input files
inputs=$(ls sampledata/)

mkdir -p ${outdir}

for input in $inputs;
do

# Get time/output for ref and improved
(time ${ref_simple} -i sampledata/${input} -o /tmp/ref_${input} > /dev/null 2> /dev/null) 2> /tmp/ref_${input}_time
(time $improved_simple -i sampledata/${input} -o /tmp/improved_${input} > /dev/null 2> /dev/null) 2> /tmp/improved_${input}_time

# Diff output
diff /tmp/ref_${input} /tmp/improved_${input}

# If outputs equal
if [ $? -eq 0 ];
then
    
    # Calculate speedup
    ref=$(</tmp/ref_${input}_time)
    improved=$(</tmp/improved_${input}_time)
    speedup=$(bc -l <<< $ref/$improved)
    
    # Echo results to stdout and to output file
    echo -e "${input}\t\tref\t$ref\timproved\t$improved\tspeedup\t$speedup"
    echo -e "${input}\t\tref\t$ref\timproved\t$improved\tspeedup\t$speedup" >> ${outfile}

# If ourputs differ	
else
    # Echo that information
    echo -e "${input}\tResults Differ"
    echo -e "${input}\tResults Differ" >> ${outfile}
fi

rm -rf /tmp/ref_${input} /tmp/improved_${input}
done
