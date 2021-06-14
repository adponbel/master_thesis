library(qiime2R)
library(phyloseq)
library(microbiomeSeq)
library(SIAMCAT)
setwd('.')

#create phyloseq object from feature table, taxonomy and metadata
physeq<-qza_to_phyloseq(
  features="../1-denoising/unoise_output/table.qza",
  taxonomy = "../2-taxonomy_assignment/taxonomy_nbayes.qza",
  metadata = "PATH_to_metadata"
)

#collapse at gebnus level
physeq_collapsed<-taxa_level(physeq,"Genus")

#get relative abundance data
physeq_rel_ab<-transform_sample_counts(physeq_collapsed, function(x) x / sum(x) )

#get metadata table from phyloseq object
meta_table<-sample_data(physeq_collapsed)

#set labels for metadata
label <- create.label(meta=meta_table, label="covid",
                      case = 'Cases', control='Controls')

#create siamcat object from phyloseq object
sc.obj<-siamcat(phyloseq = physeq_rel_ab, meta = metadata,label=label)

#filter features with lower abundance than 0.1%
sc.obj <- filter.features(sc.obj,
                          filter.method = 'abundance',
                          cutoff = 0.001)

#create figure
pdf('differential_silva.pdf',height = 12,width = 20)
sc.obj <- check.associations(
  sc.obj,
  sort.by = 'fc',
  alpha = 0.05,
  mult.corr  = "fdr",
  max.show = 30,
  detect.lim = 10 ^-5,
  plot.type = "quantile.box",
  panels = c("fc"))
dev.off()
  png('differential_silva.png',height = 900,width = 605)

  
##between cases with and without GI sympstoms
  
#get only cases samples
physeq_covid<- subset_samples(physeq, covid == "Cases")

#collapse taxonomy at genus level
physeq_collapsed<-taxa_level(physeq_covid,"Genus")

#get relative abundances of the features
physeq_rel_ab<-transform_sample_counts(physeq_collapsed, function(x) x / sum(x) )

#get metadata table
meta_table<-sample_data(physeq_collapsed)

#set labels for metadata
label <- create.label(meta=meta_table, label="GI_symptoms",
                      case = '1', control='0')

#create siamcat object from phyloseq object
sc.obj<-siamcat(phyloseq = physeq_rel_ab,meta = metadata,label=label)

#filter features with lower abundance than 0.1%
sc.obj <- filter.features(sc.obj,
                          filter.method = 'abundance',
                          cutoff = 0.001)

#create figure (is not created as no DA features are detected in this case)
pdf('differential_diarrea_silva',height = 15,width = 12)
sc.obj <- check.associations(
  sc.obj,
  sort.by = 'fc',
  alpha = 0.05,
  mult.corr = "fdr",
  detect.lim = 10 ^-6,
  plot.type = "quantile.box",
  panels = c("fc"))
dev.off()