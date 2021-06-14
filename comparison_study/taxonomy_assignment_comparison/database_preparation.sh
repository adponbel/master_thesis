
#SILVA 138 database retrieved from https://docs.qiime2.org/2021.4/data-resources/#marker-gene-reference-databases
#region V4 reads extraction

qiime feature-classifier extract-reads \
  --i-sequences silva-138-99-seqs.qza \
  --p-f-primer GTGCCAGCMGCCGCGGTAA \
  --p-r-primer GGACTACHVGGGTWTCTAAT \
  --o-reads silva-138-99-seqs-V4.qza


#region V3-V4 reads extraction

qiime feature-classifier extract-reads \
  --i-sequences silva-138-99-seqs.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GACTACHVGGGTATCTAATCC \
  --o-reads silva-138-99-seqs-V3-V4.qza


#NBAYES classifier training with V4 sequences from the SILVA database

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva-138-99-seqs-V4.qza \
  --i-reference-taxonomy silva-138-99-tax.qza \
  --o-classifier V4_classifier.qza

#NBAYES classifier training with V3-V4 sequences from the SILVA database

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva-138-99-seqs-V3-V4.qza \
  --i-reference-taxonomy silva-138-99-tax.qza \
  --o-classifier V3-V4_classifier.qza
