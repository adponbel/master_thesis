

#NBAYES
time qiime feature-classifier classify-sklearn \
    --i-reads ../mock16/unoise_output/representative_sequences.qza \
    --i-classifier V4_classifier.qza \
    --p-n-jobs 10 \
    --p-reads-per-batch 2000 \
    --o-classification taxonomy_nbayes.qza

qiime tools export \
    --input-path mock16/taxonomy_nbayes.qza \
    --output-path mock16/taxonomy_nbayes.qza/


#BLAST+ algorithm

time qiime feature-classifier classify-consensus-blast \
    --i-query ../mock16/unoise_output/representative_sequences.qza \
    --i-reference-reads silva-138-99-seqs-V4.qza \
    --i-reference-taxonomy silva-138-99-tax.qza \
    --p-query-cov 0.89 \
    --p-maxaccepts 1000 \
    --p-strand both \
    --o-classification mock16/taxonomy_blast.qza


#VSEARCH algorithm

time qiime feature-classifier classify-consensus-vsearch \
    --i-query ../mock16/unoise_output/representative_sequences.qza \
    --i-reference-reads silva-138-99-seqs-V4.qza \
    --i-reference-taxonomy silva-138-99-tax.qza \
    --p-query-cov 0.89 \
    --p-maxaccepts 1000 \
    --p-strand both \
    --o-classification mock16/taxonomy_vsearch.qza
