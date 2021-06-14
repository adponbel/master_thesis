# master_thesis

The master thesis is written as a paper following the format required on bioinformatics journal. It is divided in two differentiated sections, a comparison study of different 16S marker gene pipelines using two mock communities and a pilot study using the pipeline that presents a better accuracy.


## Adapter removal

First the adapters are removed using adapter_removal.sh, which uses cutadapt to detect and remove the adapters. The scripts needs four arguments:\n
-First argument: input directory that contains the forward and reverse reads of the samples compressed in gz format.\n
-Second argument: output path were the output directory 'adapter_trimmed' will be created. It will contain the resulting files with the reads without the adapters.\n
-Third argument: forward adapter.\n
-Fourth argument: reverse adapter.\n

Two mock communities are used for the pipeline comparison study. One is ZYMOSearch mock community (from now on zymomock community), sequenced at ADM-biopolis. The other one, mock16, can be retrieved from mockoriobiota github page. 
Zymomock and the data from the pilot study were sequenced at region V3-V4 of 16S, while mock16 was sequenced at V4 region. Therefore, the adapters to trim are different for the three sets of data:

```
#zymomock community
mkdir comparison_study/zymomock/
./adapter_removal.sh PATH_TO_ZYMOMOCK_SAMPLES comparison_study/zymomock/ CCTACGGGNGGCWGCAG GACTACHVGGGTATCTAATCC

#mock16 community
mkdir comparison_study/mock16/
./adapter_removal.sh PATH_TO_MOCK16_SAMPLES comparison_study/mock16/ GTGCCAGCMGCCGCGGTAA GGACTACHVGGGTWTCTAAT

#real data for pilot study
./adapter_removal.sh PATH_TO_PILOT_STUDY_SAMPLES pilot_study/ CCTACGGGNGGCWGCAG GACTACHVGGGTATCTAATCC
```

## Comparison study 

Is done with the scripts present in comparison_study/ folder. 

### Clustering/denoising comparison

Scripts are inside reads_processing_comparison folder. Running reads_processing_pipelines.sh script executes the five pipelines with the selected dataset. It needs four arguments:
-First argument: folder that contains the input samples (mock16 or zymomock adapter-trimmed reads)
-Second argumument: position to truncate merged reads on  deblur, vsearch, uparse and unoise pipelines
-Third argument: position to truncate forward reads on dada2 pipeline
-Fourth argument: position to truncate reverse reads on dada2 pipeline

We run the script with each mock community

```
./processing_pipelines.sh zymomock 401 270 250
./processing_pipelines.sh mock16 250 200 180
```

Figures 2 and 3 show the results of the evaluation of the pipelines. The scripts to construct those figures are in figures_2_3 folder. When running reads_processing_comparison.sh, with no needed arguments, tsv files with the results of the pipelines evaluation are created. This scripts calls the alignment.sh script that needs the path to a 16S marker gene database (change it manually at the script). The database used here is SILVA v138, retrieved from https://docs.qiime2.org/2021.4/data-resources/. It is advised to run first database_preparation.sh script from taxonomy_assignment_comparison folder, to extract the specific sequences of the V3-V4 or V4 regions (depending on the mock community) on the SILVA database. It can also work with the path to silva-138-99-seqs.qza, but takes more time to compute.

R scripts figure2.R and figure3.R create the figures using those tsv files as input.

### Taxonomy classifiers comparison

Scripts are inside taxonomy_assignment_comparison folder. First the SILVA database must be prepared running database_preparation.sh, which also trains the NBAYES classifier. Then taxonomy_assignment.sh computes the three classifiers with the output of the UNOISE pipeline on the mock16 community. Resulting taxonomies are compared running classifier_comparison.sh script. The results are shown on table2 in the paper.

## Pilot study

### Denoising

Run unoise.sh script from 1-denoising folder. It uses UNOISE3 pipeline for processing the 16S reads, as it shows the best overall results on sensitivity and specificity taking account both mock communities (see results and discussion section).

### Taxonomy assignment

Run nbayes.sh script on 2-taxonomy_assignment folder. It needs the path (change it manually) to the trained classifier on the V3-V4 region, that has been trained on the database_preparation.sh script.
R script figure4.R creates the bar plot figure with the genus of the two groups of the study.

### Diversity analysis

Run R script figures.R for diversity analysis between cases and controls, and sup_figure1.R for diversity analysis between cases with and without GI sympstoms. Available in 3-diversity_analysis folder.


### Differential abundance

Run R script figure_6.R for differential abundance analysis between cases and controls, and run sup_table3.R for differential abundance analysis between cases with and without GI sympstoms. Scripts available at 4-differential abundance folder.
