#!/bin/bash

parallel=$(dirname $(which $0))/parallel

wd=$1 && shift
datacard=$1 && shift
label=$1 && shift

[ -n $1 ] && expected=""
expected=$1 && shift

expectedMass=""
[ -n $1 ] && expectedMass=$1 && shift


cd $wd
mkdir $label 


if [[ -n $expected ]]; then
    cond="-t -1 --expectSignal=$expected"
fi

if [[ -n $expectedMass ]]; then
    toysFile="higgsCombine${label}.GenerateOnly.mH$expectedMass.123456.root"
    if [[ ! -f $label/$toysFile ]]; then 
	combine --verbose=2  -M GenerateOnly -n $label -t  -1 --saveToys  --expectSignal=$expected --expectSignalMass=$expectedMass -m $expectedMass $datacard 
	mv $toysFile $label
    fi
    cond="-t -1 --expectSignal=$expected --toysFile $label/$toysFile"
    
fi

### seq 110 0.5 150 | $parallel -j 8 "combine --verbose=2  -M ProfileLikelihood -n $label --signif --pvalue $cond -m {} -S 1 $datacard | tee pvalue_${label}_{}.log"
seq 120 0.5 130 | $parallel -j 8 "combine --verbose=2  -M ProfileLikelihood -n $label --signif --pvalue $cond -m {} -S 1 $datacard | tee pvalue_${label}_{}.log"

hadd -f $label/higgsCombine$label.ProfileLikelihood.root higgsCombine$label.ProfileLikelihood.mH*.root 

rm *$label*.root 

mv *$label*.log $label

## hadd 
