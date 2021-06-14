qiime quality-control evaluate-seqs \
    --i-query-sequences ../$1/$2_output/representative_sequences.qza \
    --i-reference-sequences $1_expected_sequences_uniques.qza \
    --o-visualization $1_$2.qzv

qiime tools export \
    --input-path $1_$2.qzv \
    --output-path ./$1_$2/

qiime quality-control exclude-seqs \
    --i-query-sequences ../$1/$2_output/representative_sequences.qza \
    --i-reference-sequences $1_expected_sequences_uniques.qza \
    --p-perc-identity 1.0 \
    --o-sequence-hits $1_$2_exact_hits.qza \
    --p-perc-query-aligned 1.0 \
    --o-sequence-misses $1_$2_exact_misses.qza

qiime tools export \
    --input-path $1_$2_exact_misses.qza \
    --output-path ./$1_$2_exact_misses/

qiime quality-control exclude-seqs \
    --i-query-sequences $1_$2_exact_misses.qza \
    --p-perc-query-aligned 1.0 \
    --i-reference-sequences $1_expected_sequences_uniques.qza \
    --p-perc-identity 0.97 \
    --o-sequence-hits $1_$2_partial_hits.qza \
    --o-sequence-misses $1_$2_partial_misses.qza

qiime tools export \ 
    --input-path $1_$2_partial_misses.qza \
    --output-path ./$1_$2_partial_misses/

qiime quality-control evaluate-seqs \
    --i-query-sequences $1_$2_partial_misses.qza \
    --i-reference-sequences $PATH_to_silva_db_ref_seqs_v4_or_v3-v4
    --o-visualization $1_$2_database.qzv

qiime tools export \
    --input-path $1_$2_database.qzv \
    --output-path ./$1_$2_database/

qiime quality-control exclude-seqs \
    --i-query-sequences $1_$2_partial_misses.qza \
    --i-reference-sequences $PATH_to_silva_db_ref_seqs_v4_or_v3-v4 \
    --p-perc-identity 1.0 \
    --o-sequence-hits $1_$2_exact_hits_database.qza \
    --p-perc-query-aligned 1.0 \
    --o-sequence-misses $1_$2_exact_misses_database.qza


qiime quality-control exclude-seqs \
    --i-query-sequences $1_$2_exact_misses_database.qza \
    --p-perc-query-aligned 1.0 \
    --i-reference-sequences $PATH_to_silva_db_ref_seqs_v4_or_v3-v4 \
    --p-perc-identity 0.97 \
    --o-sequence-hits $1_$2_partial_hits_database.qza \
    --o-sequence-misses $1_$2_partial_misses_database.qza

qiime tools export \
    --input-path $1_$2_partial_misses_database.qza \
    --output-path ./$1_$2_partial_misses_database/
rm *.qzv
rm *.qza


python3 abundance.py $1_$2/results.tsv $1_$2_exact_misses/dna-sequences.fasta ../$1/$2_output/table/feature-frequency-detail.csv $1 $2
python3 feature.py $1_$2/results.tsv $1_$2_database/results.tsv $1_$2_partial_misses_database/dna-sequences.fasta $1 $2 




