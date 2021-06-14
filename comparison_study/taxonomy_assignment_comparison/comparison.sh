qiime taxa collapse \
    --i-table ../mock16/unoise_output/table.qza \
    --i-taxonomy taxonomy_$1.qza \
    --p-level 7 \ 
    --o-collapsed-table $1_table_collapsed.qza

qiime feature-table relative-frequency \
    --i-table $1_table_collapsed.qza \
    --o-relative-frequency-table $1_table_relative.qza

qiime quality-control evaluate-composition \
    --i-expected-features expected_taxonomy_silva_55_species_formated.qza 
    --i-observed-features $1_table_relative.qza \
    --o-visualization $1_evaluation.qzv

qiime tools export \
    --input-path $1_evaluation.qzv 
    --output-path ./$1_evaluation/

rm *qza
rm *qzv
