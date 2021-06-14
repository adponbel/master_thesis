gzip -d  adapter_trimmed/*
$PATH_to_usearch11.0.667_i86linux32 -fastq_mergepairs adapter_trimmed/*R1*.fastq -fastqout merged.fq -relabel @
gzip adapter_trimmed/*

#look at quality plot of merged reads to decide the truncation position
$PATH_to_usearch11.0.667_i86linux32 -fastq_eestats2 merged.fq -output qual.txt -length_cutoffs 400,410,1

$PATH_to_usearch11.0.667_i86linux32 -fastq_filter merged.fq -fastq_maxee 1.0 -fastq_trunclen 401 -fastaout filtered.fa -relabel Filt 

$PATH_to_usearch11.0.667_i86linux32 -fastx_uniques filtered.fa -sizeout -relabel Uniq -fastaout uniques.fa

$PATH_to_usearch11.0.667_i86linux32 -unoise3 uniques.fa -zotus ASVs.fa

$PATH_to_usearch11.0.667_i86linux32 -otutab merged.fq -zotus ASVs.fa -otutabout zotutab.txt -mapout zmap.txt

#import into qiime2 format

qiime tools import \
    --input-path ASVs.fa \
    --type 'FeatureData[Sequence]' \
    --output-path unoise_output/asvs.qza

biom convert -i zotutab.txt -o unoise_output/feature_table.biom --table-type="OTU table" --to-hdf5

qiime tools import \  
    --input-path unoise_output/feature_table.biom \
    --type 'FeatureTable[Frequency]' \
    --input-format BIOMV210Format \
    --output-path unoise_output/table.qza

qiime feature-table filter-seqs \
    --i-data unoise_output/asvs.qza \
    --i-table unoise_output/table.qza \
    --o-filtered-data unoise_output/representative_sequences.qza

