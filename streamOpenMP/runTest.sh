#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0 compilerName"
  exit 1
fi

npt=`grep -c ^processor /proc/cpuinfo`
numaNodes=`lscpu | grep "NUMA node(s):" | awk '{}{print $3}{}'`
tpc=`lscpu | grep "Thread(s) per core:" | awk '{}{print $4}{}'`
np="$(($npt / $tpc))"
npps="$(($np / $numaNodes))"
npm1="$(($np - 1))"


seqArray=()
##########################################
for i in  `seq 0 $((npps-1))`; do
    for j in `seq 0 $((numaNodes-1))`; do
        seqArray[i*$numaNodes+j]=$((i+j*npps))
    done
done
##########################################

echo ${seqArray[*]}
sequence=''
for p in `seq 0 $((  npm1  ))`; do
    sequence+=${seqArray[p]}','
done
sequence=${sequence%?}

echo $sequence

export OMP_DISPLAY_ENV=true
if [ -n "$PGI" ]; then
    echo "Pgi Compiler"
    export MP_BLIST=$sequence
    export MP_BIND="yes"
    #export MP_BLIST="0-$npm1"
    echo $MP_BLIST
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
    #np=15
    #npps="$(($np / $numaNodes))"
    #npm1="$(($np - 1))"
    export OMP_PROC_BIND=spread
    export OMP_PLACES=cores
    #export KMP_AFFINITY=scatter
    # needed to use dissabled in Blue waters
    #export KMP_AFFINITY=disabled
else
    echo "Gnu Compiler"
    export OMP_PROC_BIND=spread
    export OMP_PLACES=sockets
fi


rm -f temp.txt
for i in 1 `seq 2 1 $np`; do
    echo number of threads: $i
    export OMP_NUM_THREADS=$i
    streamOpenMP >> temp.txt
done

exit

mkdir -p ../../plots/StreamResults/$(hostname)/$1

cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Copy.dat

cat temp.txt | grep "Scale:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Scale:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Scale.dat

cat temp.txt | grep "Add:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Add:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Add.dat

cat temp.txt | grep "Triad:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Triad:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Triad.dat

rm temp.txt
