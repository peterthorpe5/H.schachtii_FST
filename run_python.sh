#!/bin/bash

cd /homes/pthorpe001/data/HS


pigz -d *snpeff.sync.gz

python ./DrosEU_pipeline/scripts/SubsampleSync.py \
--sync HS_SNPs_all_sites_clean_snpeff.sync \
--target-cov 60 \
--min-cov 10 \
| gzip > HS_SNPs_all_sites_clean_snpeff_60x.sync.gz



python ./DrosEU_pipeline/scripts/SubsampleSync.py \
--sync HS_SNPs_poly_only_clean_snpeff.sync \
--target-cov 60 \
--min-cov 10 \
| gzip > HS_SNPs_poly_only_clean_snpeff_60x.sync.gz


#########################################################
# calculate true window

python ./DrosEU_pipeline/scripts/TrueWindows.py \
--badcov HS_SNPs_all_sites_BS.txt.gz \
--indel InDel-positions_20.txt.gz \
--te ./genome_data/Hetero_scha.transposable_elements.gff3 \
--window 200000 \
--step 200000 \
--output truewindows



python ./DrosEU_pipeline/scripts/PoolGen_var.py \
--input HS_SNPs_all_sites_clean_snpeff_60x.sync.gz \
--pool-size 100000 100000
--min-count 2 \
--window 200000 \
--step 200000 \
--sitecount truewindows-200000-200000.txt \
--min-sites-frac 0.75 \
--output Popgen


