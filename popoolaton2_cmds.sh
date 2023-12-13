#!/bin/bash

cd /homes/pthorpe001/data/HS

conda activate popoolation2


#java \
#-Xmx40g \
#-Dsnappy.disable=true \
#-jar /cluster/gjb_lab/pthorpe001/conda/envs/picard/share/picard-3.1.0-0/picard.jar SortSam \
#I=WUR_H.scha_il_reads.bam \
#O=WUR.bam \
#SO=coordinate \
#VALIDATION_STRINGENCY=SILENT


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
OUTPUT=WURdedup_rg.bam \
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
> p1_p2.mpileup





java -ea -Xmx20g -jar ./popoolation2_1201/mpileup2sync.jar --input p1_p2.mpileup --output p1_p2_java.sync --fastq-type sanger --min-qual 20 --threads 8


 ln -s p1_p2_java.sync p1_p2.sync

perl ./popoolation2_1201//snp-frequency-diff.pl --input p1_p2.sync --output-prefix p1_p2 --min-count 6 --min-coverage 50 --max-coverage 200

# FST sliding window

perl ./popoolation2_1201/fst-sliding.pl --input p1_p2.sync --output p1_p2.fst \
--suppress-noninformative --min-count 6 --min-coverage 30 \
--max-coverage 200 --min-covered-fraction 1 --window-size 1 \
--step-size 1 --pool-size 500



# Fisher's Exact Test: estimate the significance of allele frequency differences

perl ./popoolation2_1201/fisher-test.pl --input p1_p2.sync \
--output p1_p2.fet --min-count 6 --min-coverage 50 --max-coverage 200 --suppress-noninformative


# Calculate Fst values using a sliding window approach

perl ./popoolation2_1201/fst-sliding.pl --input p1_p2.sync \
--output p1_p2_w500.fst --min-count 6 --min-coverage 50 \
--max-coverage 200 --min-covered-fraction 1 --window-size 500 --step-size 500 --pool-size 5000



#Calculate Fst for genes
#Download the annotated exons for the first 1mio bp of chromosome 2R http://popoolation2.googlecode.com/files/2R_exons.gtf

#Convert the synchronized file into a gene-based synchronized file

perl ./popoolation2_1201/create-genewise-sync.pl --input p1_p2.sync --gtf exons.gtf --output p1_p2_genes.sync

## Calculate the Fst for every gene:

perl ./popoolation2_1201/fst-sliding.pl --min-count 6 --min-coverage 50 --max-coverage 200 \
--pool-size 5000 --min-covered-fraction 0.0 \
--window-size 1000000 --step-size 1000000 --input p1_p2_genes.sync --output p1_p2_genewise.fst








/homes/pthorpe001/apps/grenedalf/grenedalf_v0.3.0_linux_x86_64 \
--pileup-path /homes/pthorpe001/data/HS/p1_p2.sync --pileup-min-base-qual 20 \
--reference-genome-fasta-file  /homes/pthorpe001/data/HS/genome_data/heterodera_schachtii.PRJNA722882.WBPS17.genomic.fa \
--reference-genome-fai-file     /homes/pthorpe001/data/HS/genome_data/heterodera_schachtii.PRJNA722882.WBPS17.genomic.fa    \
--filter-region-gff /homes/pthorpe001/data/HS/genome_data




Input VCF/BCF:
  --vcf-path