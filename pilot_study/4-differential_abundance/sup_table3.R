library(ANCOMBC)
library("tidyverse")
library(qiime2R)
library(phyloseq)
library("microbiome")
library(microbiomeSeq)


setwd('.')

#create phyloseq object
physeq<-qza_to_phyloseq(
  features="../1-denoising/unoise_output/table.qza",
  taxonomy = "../2-taxonomy_assignment/taxonomy_nbayes.qza",
  metadata = "PATH_to_metadata"
)

#collpase taxonomy at genus level
physeq_collapsed<-taxa_level(physeq,"Genus")

#perform ancom-bc test
ancom_da = ancombc(phyloseq = physeq_collapsed, formula = "covid + age +sex",
                   p_adj_method = "holm", zero_cut = 0.90, lib_cut = 1000,
                   group = "covid", struc_zero = FALSE, neg_lb = TRUE, tol = 1e-5,
                   max_iter = 100, conserve = TRUE, alpha = 0.05)

#get results in a table
ancom_res_df <- data.frame(
  Genera = row.names(ancom_da$res$beta),
  beta = unlist(ancom_da$res$beta),
  se = unlist(ancom_da$res$se),
  W = unlist(ancom_da$res$W),
  p_val = unlist(ancom_da$res$p_val),
  q_val = unlist(ancom_da$res$q_val),
  diff_abn = unlist(ancom_da$res$diff_abn))

#get significant results
filtered_ancom <- ancom_res_df %>%
  dplyr::filter(q_val < 0.05)


write_tsv(filtered_ancom,'ancombc_output.tsv')


##between cases with and without GI symptoms

#get only cases samples
physeq_covid<- subset_samples(physeq, covid == "Cases")

#collapse taxonomy at genus level
physeq_covid_collapsed<-taxa_level(physeq_covid,"Genus")

#perform ancom-bc test
ancom_covid_da = ancombc(phyloseq = physeq_covid_collapsed, formula = "GI_symptoms",
                         p_adj_method = "holm", zero_cut = 0.90, lib_cut = 1000,
                         group = "GI_symptoms", struc_zero = FALSE, neg_lb = FALSE, tol = 1e-5,
                         max_iter = 100, conserve = TRUE, alpha = 0.05)

#get results in a table
ancom_res_covid_df <- data.frame(
  Genera = row.names(ancom_covid_da$res$beta),
  beta = unlist(ancom_covid_da$res$beta),
  se = unlist(ancom_covid_da$res$se),
  W = unlist(ancom_covid_da$res$W),
  p_val = unlist(ancom_covid_da$res$p_val),
  q_val = unlist(ancom_covid_da$res$q_val),
  diff_abn = unlist(ancom_covid_da$res$diff_abn))

#get significant results
fdr_ancom_covid <- ancom_res_covid_df %>%
  dplyr::filter(q_val < 0.05)