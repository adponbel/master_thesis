library(tidyverse)
library(qiime2R)
library(microbiomeSeq)
library(dplyr)
library(ggpubr)
library("cowplot")
library(phyloseq)
library(metagMisc)

setwd('.')
#get the input files; metadata, feature table and taxonomy
metadata<-readr::read_tsv("PATH_TO_METADATA")
metadata$SampleID<-as.character(metadata$SampleID)
SVs<-read_qza("../1-denoising/unosie_output/table.qza")$data
taxonomy<-read_qza("taxonomy_nbayes.qza")$data %>% parse_taxonomy()


#set the pallete of colors
q2r_palette<-c(
  "dodgerblue2", "#E31A1C", # red
  "green4",
  "#6A3D9A", # purple
  "#FF7F00", # orange
  "green4", "gold1",
  "skyblue2", "#FB9A99", # lt pink
  "palegreen2",
  "orange", # lt purple
  "#FDBF6F", # lt orange
  "red1", "khaki2",
  "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
  "darkturquoise", "green1", "yellow4", "yellow3",
  "darkorange4", "brown",
  "grey"
    )

#Get the % of annotated features at each taxonomic level
phylum_annotated<-1-((sum(is.na(taxonomy$Phylum))+length(grep("uncultured", taxonomy$Phylum))+length(grep("unidentified", taxonomy$Phylum)))/dim(taxonomy)[1])
class_annotated<-1-((sum(is.na(taxonomy$Class))+length(grep("uncultured", taxonomy$Class))+length(grep("unidentified", taxonomy$Class)))/dim(taxonomy)[1])
order_annotated<-1-((sum(is.na(taxonomy$Order))+length(grep("uncultured", taxonomy$Order))+length(grep("unidentified", taxonomy$Order)))/dim(taxonomy)[1])
family_annotated<-1-((sum(is.na(taxonomy$Family))+length(grep("uncultured", taxonomy$Family))+length(grep("unidentified", taxonomy$Family)))/dim(taxonomy)[1])
genus_annotated<-1-((sum(is.na(taxonomy$Genus))+length(grep("uncultured", taxonomy$Genus))+length(grep("unidentified", taxonomy$Genus)))/dim(taxonomy)[1])
species_annotated<-1-((sum(is.na(taxonomy$Species))+length(grep("uncultured", taxonomy$Species))+length(grep("unidentified", taxonomy$Species)))/dim(taxonomy)[1])

#collapse at genus level
taxasums<-summarize_taxa(SVs, taxonomy)$Genus

#extract the top 20 most abundant features on average
ntoplot=20
taxasums_all<-make_percent(taxasums)
plotfeats<-names(sort(rowMeans(taxasums_all), decreasing = TRUE)[1:20]) # extract the top N most abundant features on average
plotfeats_family<-rev(read.table(text = plotfeats, sep = ";", as.is = TRUE)$V5)
plotfeats_genus<-rev(read.table(text = plotfeats, sep = ";", as.is = TRUE)$V6)
plotfeats_reduced<-paste(plotfeats_family,plotfeats_genus,sep=';')

figure4a_data<-
  taxasums_all %>%
  as.data.frame() %>%
  rownames_to_column("Taxon") %>%
  gather(-Taxon, key="SampleID", value="Abundance") %>%
  mutate(Taxon=if_else(Taxon %in% plotfeats, Taxon, "Remainder")) %>%
  group_by(Taxon, SampleID) %>%
  summarize(Abundance=sum(Abundance)) %>%
  ungroup() %>%
  mutate(Taxon=factor(Taxon, levels=rev(c(plotfeats, "Remainder")))) %>%
  left_join(metadata)

figure4a<-
  ggplot(figure4a_data, aes(x=as.character(SampleID), y=Abundance, fill=Taxon)) +
  geom_bar(stat="identity") +
  theme_q2r() +
  theme(text = element_text(size = 20),axis.text.x = element_text(angle=90, hjust=0,size=10),axis.text.y = element_text(size=15),legend.text = element_text(size = 10),legend.position = 'right')+
  guides(fill =guide_legend(ncol=1))+
  coord_cartesian(expand=FALSE) +
  xlab("Sample") +
  ylab("Relative abundance (%)")+
  scale_fill_manual(values=rev(q2r_palette), name="",label_value( c("Remainder", plotfeats_reduced)),)+
  facet_grid(~get('covid'), scales="free_x")+ theme(panel.spacing = unit(1, "lines"))


# get the average features abundance cases VS controls

OTU = otu_table(taxasums, taxa_are_rows = TRUE)
metadata<-read.csv('PATH_to_metadata',sep = '\t',row.names = 1)
metadata_ps<-sample_data(metadata)
ps<-merge_phyloseq(OTU,metadata_ps)
ps.standarized = phyloseq_standardize_otu_abundance(ps, method = "total")
controls<-subset_samples(ps, covid == "Controls")
cases<-subset_samples(ps, covid == "Cases")
controls_counts<-as.data.frame(rowSums(as.data.frame(otu_table(controls))))
cases_counts<-as.data.frame(rowSums(as.data.frame(otu_table(cases))))
taxasums_average<-cbind(cases_counts,controls_counts)
    colnames(taxasums_average)<-c('Cases','Controls')
taxasums_average<-make_percent(taxasums_average)

figure4b_data<-
  taxasums_average %>%
  as.data.frame() %>%
  rownames_to_column("Taxon") %>%
  gather(-Taxon, key="SampleID", value="Abundance") %>%
  mutate(Taxon=if_else(Taxon %in% plotfeats, Taxon, "Remainder")) %>%
  group_by(Taxon, SampleID) %>%
  summarize(Abundance=sum(Abundance))%>%
  ungroup() %>%
  mutate(Taxon=factor(Taxon, levels=rev(c(plotfeats, "Remainder")))) 

figure4b<-
  ggplot(figure4b_data, aes(x=SampleID, y=Abundance, fill=Taxon)) +
  geom_bar(stat="identity",width = 0.01) +
  theme_q2r() +
  theme(text = element_text(size = 20),axis.text.x= element_blank(),legend.text = element_text(size = 15.5),legend.position = 'right')+
  guides(fill =guide_legend(ncol=1))+
  coord_cartesian(expand=FALSE) +
  xlab("") +
  ylab("Relative abundance (%)")+
  scale_fill_manual(values=rev(q2r_palette), name="",label_value( c("Remainder", plotfeats_reduced)))+
  facet_grid(~get('SampleID'), scales="free_x", space="free")+ theme(panel.spacing = unit(1, "lines"))


# put together figure 4A and 4B with the legend
ggdraw() +
  draw_plot(figure4a+theme(legend.position = 'none'), x = 0, y = 0, width = .55, height = 1) +
  draw_plot(figure4b, x = 0.58, y = 0.052, width = .41, height = 0.94) +
  draw_plot_label(label = c("A", "B"), size = 20,
                  x = c(0, 0.58), y = c(1, 1))

ggsave("figure4.png", height=7, width=20, device="png")


