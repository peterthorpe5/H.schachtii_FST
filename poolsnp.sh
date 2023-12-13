#!/bin/bash
#


sleep  14400


cd /homes/pthorpe001/data/HS

conda activate poolsnp

bash /homes/pthorpe001/data/HS/PoolSNP/PoolSNP.sh \
mpileup=/homes/pthorpe001/data/HS/p1_p2.mpileup \
reference=/homes/pthorpe001/data/HS/reference.fa \
names=library,WIR \
max-cov=0.99 \
min-cov=8 \
min-count=8 \
min-freq=0.01 \
allsites=0 \
jobs=12 \
BS=1 \
output=/homes/pthorpe001/data/HS/HS_SNPs_poly_only

bash /homes/pthorpe001/data/HS/PoolSNP/PoolSNP.sh \
mpileup=/homes/pthorpe001/data/HS/p1_p2.mpileup \
reference=/homes/pthorpe001/data/HS/reference.fa \
names=library,WIR \
max-cov=0.99 \
min-cov=8 \
min-count=8 \
min-freq=0.01 \
allsites=1 \
jobs=12 \
BS=1 \
output=/homes/pthorpe001/data/HS/HS_SNPs_all_sites
