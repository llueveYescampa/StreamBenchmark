#!/bin/bash
if [ "$#" -le 1 ]
then
  echo "Usage: $0  computer testType -> [Copy | Add | Scale | Triad ]"
  exit 1
fi

cd $1/Gnu
paste streamMPI_sm_$2.dat  streamOpenMP_$2.dat > result.txt

cd ../Intel
paste streamMPI_sm_$2.dat  streamOpenMP_$2.dat > result.txt

cd ../Pgi
paste streamMPI_sm_$2.dat  streamOpenMP_$2.dat > result.txt


cd ../..

gnuplot -c plot.gnp $1 $2
gnuplot -c plotRatio.gnp $1 $2

rm `find . -name result*.txt`

