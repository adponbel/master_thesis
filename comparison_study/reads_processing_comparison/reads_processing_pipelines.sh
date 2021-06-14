#activation of qiime2 environment
conda activate qiime2-2021.2

# this pipelines are used with two different mock communities: mock16 and zymomock
# it is advised to create two different folders: mock16 folder, and zymomock folder, and select the name of this folder with $1
# three numbers must be also given to the terminal: $2 (position to truncate forward reads), $3 (position to truncate reverse reads) and $4 (position to truncate merged reads)
##QIIME2 PIPELINES
#move into mock16 or zymomock folder
cd $1
#import adapter_trimmed samples into qiime format (.qza)
qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path adapter_trimmed/ \
    --input-format CasavaOneEightSingleLanePerSampleDirFmt \
    --output-path demux.qza

#visualization of paired-end reads for choosing best quality filtering parameters for DADA2 (.qzv format)
qiime demux summarize \
    --i-data demux.qza \    
    --o-visualization demux.qzv
qiime tools export  \
    --input-path demux.qzv \
    --output-path ./demux/

#merge paired-end reads (for Deblur and VSEARCH pipelines)
qiime vsearch join-pairs \
    --i-demultiplexed-seqs demux.qza \
    --o-joined-sequences demux-joined.qza

#visualization of the quality of merged reads
qiime demux summarize \
    --i-data demux-joined.qza \
    --o-visualization demux-joined.qzv
qiime tools export \
    --input-path demux-joined.qzv \
    --output-path ./demux-joined/

#filter low quality reads for Deblur and VSEARCH pipelines
qiime quality-filter q-score \
    --i-demux demux-joined.qza \
    --o-filtered-sequences demux-filtered.qza \
    --o-filter-stats demux-filter-stats.qza

#visualization of quality of quality-filtered reads
qiime demux summarize \
    --i-data demux-filtered.qza \
    --o-visualization demux-filtered.qzv
qiime tools export \
    --input-path demux-filtered.qzv \
    --output-path ./demux-filtered/

#dereplication (only for VSEARCH pipeline)
time qiime vsearch dereplicate-sequences \
    --i-sequences demux-filtered.qza \
    --o-dereplicated-table table-otu.qza \
    --o-dereplicated-sequences rep-seqs-otu.qza


#DADA2 algorithm 
#Need to truncate forward and reverse reads separately at positions where they lose quality (as seen in quality plots created in qiime2)
#$1: position to truncate forward reads (270 for zymomock, 200 for mock16)
#$2: position to truncate reverse reads (250 for zymomock, 180 for mock16)
time qiime dada2 denoise-paired \
    --i-demultiplexed-seqs demux.qza \ 
    --p-trunc-len-f $2 \
    --p-trunc-len-r $3 \
    --output-dir dada2_output \
    --p-n-threads 10 \
    --verbose &> dada2.log


#DEBLUR algortihm
#Need to truncate merged reads at position where lose quality (as seen in quality plots created in qiime2)
#$3: position to truncate merged reads (401 for zymomock, 250 for mock16)
time qiime deblur denoise-16S \
    --i-demultiplexed-seqs demux-filtered.qza \   
    --p-trim-length $4 \
    --p-sample-stats \  
    --p-jobs-to-start 10 \
    --output-dir deblur_output \
    --verbose &> deblur.log



#VSEARCH pipeline
#clustering denovo at 98% identity
time qiime vsearch cluster-features-de-novo \
    --i-table table-otu.qza \
    --i-sequences rep-seqs-otu.qza \
    --p-threads 10 \
    --p-perc-identity 0.98 \
    --output-dir vsearch_output_pre_chimera \   
    --verbose &> vsearch_de_novo_98.log

#chimera filtering
time qiime vsearch uchime-denovo \
    --i-table vsearch_output_pre_chimera/clustered_table.qza \
    --i-sequences vsearch_output_pre_chimera/clustered_sequences.qza \
    --output-dir vsearch_output_98 \
    --verbose &> uquime_denovo.log

qiime feature-table filter-features \
    --i-table vsearch_output_pre_chimera/clustered_table.qza \
    --m-metadata-file vsearch_output_98/nonchimeras.qza \
    --o-filtered-table vsearch_output_98/table_nonchimeric.qza

#clustering denovo at 97% identity
time qiime vsearch cluster-features-de-novo \
    --i-sequences vsearch_output_98/nonchimeras.qza \
    --i-table vsearch_output_98/table_nonchimeric.qza \
    --p-perc-identity 0.97 \
    --p-threads 10 \
    --o-clustered-table vsearch_output/table_pre_filtered.qza \
    --o-clustered-sequences vsearch_output/representative_sequences_pre_filtered.qza \
    --verbose &> vsearch_de_novo_97.log

#filter out singletons (features with only one read)
qiime feature-table filter-features \
    --i-table vsearch_output/table_pre_filtered.qza \
    --p-min-frequency 2 \
    --o-filtered-table vsearch_output/table.qza

qiime feature-table filter-seqs \
    --i-data vsearch_output/representative_sequences_pre_filtered.qza \
    --i-table vsearch_output/table.qza --o-filtered-data vsearch_output/representative_sequences.qza



### USEARCH pipelines

#unzip the paired-end reads
gzip -d adapter_trimmed/*

#merge reads
$PATH_to_usearch11.0.667_i86linux32 -fastq_mergepairs adapter_trimmed/*R1*.fastq -fastqout usearch/merged.fq -relabel @ -fastq_maxdiffs 20

#compress again the input files
gzip adapter_trimmed/*

#visualize quality of merged reads
$PATH_to_usearch11.0.667_i86linux32 -fastq_eestats2 usearch/merged.fq -output usearch/qual.txt

#truncate merged reads
#$3: position to trucate merged reads (401 for zymomock, 250 for mock16)
$PATH_to_usearch11.0.667_i86linux32 -fastq_filter usearch/merged.fq -fastq_maxee 1.0 -fastq_trunclen $4 -fastaout usearch/filtered.fa -relabel Filt 

#get unique reads
$PATH_to_usearch11.0.667_i86linux32 -fastx_uniques usearch/filtered.fa -sizeout -relabel Uniq -fastaout usearch/uniques.fa

#unoise algorithm
$PATH_to_usearch11.0.667_i86linux32 -unoise3 usearch/uniques.fa -zotus usearch/ASVs.fa

#get ASVs table
$PATH_to_usearch11.0.667_i86linux32 -otutab usearch/merged.fq -zotus usearch/ASVs.fa -otutabout usearch/zotutab.txt -mapout usearch/zmap.txt

#uparse algortihm
$PATH_to_usearch11.0.667_i86linux32 -cluster_otus usearch/uniques.fa -otus usearch/otus.fa -relabel Otu

#get OTUs table
$PATH_to_usearch11.0.667_i86linux32 -otutab usearch/merged.fq -otus usearch/otus.fa -otutabout usearch/otutab.txt -mapout usearch/map.txt

#import into qiime2 format for an easire comparison with the other pipelines

qiime tools import \
   --input-path usearch/otus.fa \
   --type 'FeatureData[Sequence]' \
   --output-path usearch/otus.qza

qiime tools import \
   --input-path usearch/ASVs.fa \
   --type 'FeatureData[Sequence]' \
   --output-path usearch/asvs.qza

biom convert -i usearch/otutab.txt -o usearch/feature_table_otu.biom --table-type="OTU table" --to-hdf5

mkdir uparse_output

qiime tools import \
   --input-path usearch/feature_table_otu.biom \
   --type 'FeatureTable[Frequency]' \
   --input-format BIOMV210Format \
   --output-path uparse_output/table.qza

qiime feature-table filter-seqs \
   --i-data usearch/otus.qza \
   --i-table uparse_output/table.qza \
   --o-filtered-data uparse_output/representative_sequences.qza

biom convert -i usearch/zotutab.txt -o usearch/feature_table_asvs.biom --table-type="OTU table" --to-hdf5

mkdir unoise_output 

qiime tools import \
   --input-path usearch/feature_table_asvs.biom \
   --type 'FeatureTable[Frequency]' \
   --input-format BIOMV210Format \
   --output-path unoise_output/table.qza

qiime feature-table filter-seqs \
   --i-data usearch/asvs.qza \
   --i-table unoise_output/table.qza \
   --o-filtered-data unoise_output/representative_sequences.qza


