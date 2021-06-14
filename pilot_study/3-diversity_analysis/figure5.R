library(qiime2R)
library(tidyverse)
library(phyloseq)
library("vegan")
library(metagMisc)
library("cowplot")

setwd('.')

#create phyloseq object
ps<-qza_to_phyloseq(
  features="../1-denoising/unoise_output/table.qza",
  metadata = "PATH_to_metadata"
)


##ALPHA DIVERSITY

#plot alpha diversity on shannon and simpson metrices
alpha_plot<-plot_richness(ps, x="covid", measures=c( "Shannon",'Simpson'),color = 'covid',) +
  geom_boxplot()+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(),legend.position='none',aspect.ratio=1,text=element_text(size = 20),axis.title.y = element_text(size=15))
rich = estimate_richness(ps)

#test alpha group significance
pairwise.wilcox.test(rich$Shannon, sample_data(ps)$covid)
pairwise.wilcox.test(rich$Simpson, sample_data(ps)$covid)

##BETA DIVERSITY

#TSS normalization 
ps.standarized = phyloseq_standardize_otu_abundance(ps, method = "total")

#calculate bray curtis and jaccard distances
bray_dist = phyloseq::distance(ps.standarized, method='bray')
jaccard_dist = phyloseq::distance(ps.standarized, method='jaccard')

#plot the distances on PcoA
bray_ordination = ordinate(ps.standarized, method = "PCoA", distance=bray_dist)
jaccard_ordination = ordinate(ps.standarized, method="PCoA", distance=jaccard_dist)
bray_plot<-plot_ordination(ps.standarized, bray_ordination, color="covid") +  
  stat_ellipse(aes(group = covid))+
  ggtitle("Bray curtis")+
  theme(aspect.ratio=1,text = element_text(size = 15),plot.title = element_text(hjust = 0.5)) + 
  geom_point(size = 4.5,alpha=0.5)
jaccard_plot<-plot_ordination(ps.standarized, jaccard_ordination, color="covid") +
  stat_ellipse(aes(group = covid))+ggtitle("Jaccard")+ 
  theme(aspect.ratio=1,text = element_text(size = 15),plot.title = element_text(hjust = 0.5)) + 
  geom_point(size = 4.5,alpha=0.5)+
  labs(fill = "")


#draw beta dievrsity plot
beta_plot<-ggdraw() +
  draw_plot(bray_plot+theme(legend.position = 'none'), x = 0, y = 0, width = .5, height = 1.0) +
  draw_plot(jaccard_plot+theme(legend.position = 'none'), x = 0.5, y = 0.0, width = .5, height = 1.0)


legend <- get_legend(
  bray_plot +
    guides(color = guide_legend(nrow = 1,title = 'Samples'))+
    theme(legend.position = "bottom",legend.text = element_text(size = 20))
)

#draw final figure
plot<-ggdraw() +
  draw_plot(alpha_plot+theme(legend.position = 'none'), x = 0, y = 0.51, width = 1, height = 0.49) +
  draw_plot(beta_plot+theme(legend.position = 'none'), x = 0, y = 0.0, width = 1, height = 0.48)+
  draw_plot_label(label = c("A", "B"), size = 20, x = c(0, 0), y = c(1, 0.5))
#add legend
plot_legend<-plot_grid(plot,legend, ncol = 1, rel_heights = c(1, .1))
plot_legend
ggsave("diversity_controls_vs_cases.png", height=10, width=10, device="png")

#get group significance on beta diversity
adonis(bray_dist ~sample_data(ps.standarized)$covid)
adonis(jaccard_dist ~sample_data(ps.standarized)$covid)


