#!/bin/bash

cd /homes/pthorpe001/data/HS


mamba activate picard

java \
-Xmx20g \#
-Dsnappy.disable=true \
-jar /cluster/gjb_lab/pthorpe001/conda/envs/picard/share/picard-3.1.0-0/picard.jar SortSam \
I=WUR_H.scha_il_reads.bam \
O=WUR.bam \
SO=coordinate \
VALIDATION_STRINGENCY=SILENT


java \
-Xmx40g \
-Dsnappy.disable=true \
-jar /cluster/gjb_lab/pthorpe001/conda/envs/picard/share/picard-3.1.0-0/picard.jar \
MarkDuplicates \
REMOVE_DUPLICATES=true \
I=WIR.bam \
O=WIRdedup.bam \
M=library-dedup.txt \
VALIDATION_STRINGENCY=SILENT



java \
-Xmx40g \
-Dsnappy.disable=true \
-jar /cluster/gjb_lab/pthorpe001/conda/envs/picard/share/picard-3.1.0-0/picard.jar \
AddOrReplaceReadGroups \
INPUT=WIRdedup.bam \
OUTPUT=WIRdedup_rg.bam \
SORT_ORDER=coordinate \
RGID=WIR \
RGLB=WIR \
RGPL=illumina \
RGSM=WIR \
RGPU=WIR \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=SILENT



conda activate funannotate

samtools mpileup -B \
-f reference.fa \
-b BAMlist.txt \
-q 20 \
-Q 20 \
 > DrosEU.mpileup.gz


#####################################
# RUN THE poolsnp.sh to call the snps

conda activate python27

# detect indels
python DrosEU_pipeline/scripts/DetectIndels.py --mpileup p1_p2.mpileup --minimum-count 20 \
 --mask 5 \
 | gzip > InDel-positions_20.txt.gz


# remove the repetitive regions
python DrosEU_pipeline/scripts/FilterPosFromVCF.py \
 --indel InDel-positions_20.txt.gz \
  --te ./genome_data/Hetero_scha.transposable_elements.gff3 --vcf HS_SNPs_poly_only.vcf.gz | gzip > HS_SNPs_poly_only_clean.vcf.gz


python DrosEU_pipeline/scripts/FilterPosFromVCF.py \
 --indel InDel-positions_20.txt.gz \
 --te ./genome_data/Hetero_scha.transposable_elements.gff3 \
 --vcf HS_SNPs_all_sites.vcf.gz | gzip > HS_SNPs_all_sites_clean.vcf.gz

########################################
# run snpeff to quantify the SNPs effect

conda activate snpeff
# all sites
java -XX:-UsePerfData -Djava.io.tmpdir=/homes/pthorpe001/data/HS -Xmx30g \
-jar ~/apps/snpEff/snpEff.jar HSC \
-stats  SNPs_clean.html HS_SNPs_all_sites_clean.vcf.gz > HS_SNPs_all_sites_cleanclean_snpeff.vcf

# poly morphic sites only
java -XX:-UsePerfData -Djava.io.tmpdir=/homes/pthorpe001/data/HS -Xmx30g \
 -jar ~/apps/snpEff/snpEff.jar HSC \
-stats  SNPs_clean.html \
HS_SNPs_poly_only_clean.vcf.gz \
> HS_SNPs_poly_only_clean_snpeff.vcf


conda activate python27
# convert to sync file format
python ./DrosEU_pipeline/scripts/VCF2sync.py --vcf HS_SNPs_poly_only_clean_snpeff.vcf \
| gzip > HS_SNPs_poly_only_clean_snpeff.sync.gz


python ./DrosEU_pipeline/scripts/VCF2sync.py --vcf HS_SNPs_all_sites_cleanclean_snpeff.vcf \
| gzip > HS_SNPs_all_sites_clean_snpeff.sync.gz


# subsample to 60 X
# will not take sync.gz as input so decompress

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


# Tajima's D using Pool-Seq corrections following Kofler et al. (2011)
python ./DrosEU_pipeline/scripts/PoolGen_var.py \
--input HS_SNPs_all_sites_clean_snpeff_60x.sync.gz \
--pool-size 100000 100000
--min-count 2 \
--window 200000 \
--step 200000 \
--sitecount truewindows-200000-200000.txt \
--min-sites-frac 0.75 \
--output Popgen

