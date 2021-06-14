#create new directory for reads processing compasion
mkdir reads_processing_comparison
cd reads_processing_comparison

#the following scripts must be included in this directory:
#alignment.sh
#feature.py
#abundance.py

#mock16

./alignment.sh mock16 dada2
./alignment.sh mock16 deblur
./alignment.sh mock16 vsearch
./alignment.sh mock16 unoise
./alignment.sh mock16 uparse

cat abundance_mock16_expected.tsv abundance_mock16_dada2.tsv abundance_mock16_deblur.tsv abundance_mock16_uparse.tsv abundance_mock16_unoise.tsv abundance_mock16_vsearch.tsv > abundance_mock16_all.tsv
cat << EOF > feature_mock16_all.tsv
Type	Counts	Pipeline
EOF
cat feature_mock16_dada2.tsv feature_mock16_deblur.tsv feature_mock16_uparse.tsv feature_mock16_unoise.tsv feature_mock16_vsearch.tsv >> feature_mock16_all.tsv

#zymomock

./alignment.sh zymomock dada2
./alignment.sh zymomock deblur
./alignment.sh zymomock vsearch
./alignment.sh zymomock unoise
./alignment.sh zymomock uparse

cat abundance_zymomock_expected.tsv abundance_zymomock_dada2.tsv abundance_zymomock_deblur.tsv abundance_zymomock_uparse.tsv abundance_zymomock_unoise.tsv abundance_zymomock_vsearch.tsv > abundance_zymomock_all.tsv
cat << EOF > feature_zymomock_all.tsv
Type	Counts	Pipeline
EOF
cat feature_zymomock_dada2.tsv feature_zymomock_deblur.tsv feature_zymomock_uparse.tsv feature_zymomock_unoise.tsv feature_zymomock_vsearch.tsv >> feature_zymomock_all.tsv

