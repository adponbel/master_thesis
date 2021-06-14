time qiime feature-classifier classify-sklearn \
    --i-reads ../1-denoising/unoise_output/representative_sequences.qza \
    --i-classifier PATH_to_nbayes_classifier_V3-V4.qza \
    --p-n-jobs 10 \
    --p-reads-per-batch 2000 \
    --o-classification taxonomy_nbayes.qza
