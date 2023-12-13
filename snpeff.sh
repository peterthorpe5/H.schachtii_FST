#!/bin/bash

cd /homes/pthorpe001/data/HS


# all sites
java -XX:-UsePerfData -Djava.io.tmpdir=/homes/pthorpe001/data/HS -Xmx30g -jar ~/apps/snpEff/snpEff.jar HSC \
-stats  SNPs_clean.html HS_SNPs_all_sites_clean.vcf.gz > HS_SNPs_all_sites_cleanclean_snpeff.vcf

# poly morphic sites only
java -XX:-UsePerfData -Djava.io.tmpdir=/homes/pthorpe001/data/HS -Xmx30g -jar ~/apps/snpEff/snpEff.jar HSC \
-stats  SNPs_clean.html \
HS_SNPs_poly_only_clean.vcf.gz \
> HS_SNPs_poly_only_clean_snpeff.vcf


