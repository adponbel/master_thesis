library('ggplot2')
library('cowplot')
setwd('PATH_to_directory')

col <- c("#FFFF00", "#1CE6FF", "#FF34FF", "#FF4A46", "#008941", "#006FA6", "#A30059",
         "#7A4900", "#0000A6", "#63FFAC", "#B79762", "#004D43", "#8FB0FF", "#997D87",
         "#5A0007", "#809693", "#4FC601", "#3B5DFF", "#4A3B53", "#FF2F80",
         "#61615A", "#BA0900", "#6B7900", "#00C2A0", "#FFAA92", "#FF90C9", "#B903AA", "#D16100",
         "#DDEFFF", "#000035", "#7B4F4B", "#A1C299", "#300018", "#0AA6D8", "#013349", "#00846F",
         "#372101", "#FFB500", "#C2FFED", "#A079BF", "#CC0744", "#C0B9B2", "#C2FF99", "#001E09",
         "#00489C", "#6F0062", "#0CBD66", "#EEC3FF", "#456D75", "#B77B68", "#7A87A1", "#788D66",
         "#885578", "#FAD09F", "#FF8A9A", "#D157A0", "#BEC459", "#456648", "#0086ED", "#886F4C",
         "#34362D", "#B4A8BD", "#00A6AA", "#452C2C", "#636375", "#A3C8C9", "#FF913F", "#938A81",
         "#575329", "#00FECF", "#B05B6F", "#8CD0FF", "#3B9700", "#04F757", "#C8A1A1", "#1E6E00",
         "#7900D7", "#A77500", "#6367A9", "#A05837", "#6B002C", "#772600", "#D790FF", "#9B9700",
         "#549E79", "#FFF69F", "#201625", "#72418F", "#BC23FF", "#99ADC0", "#3A2465", "#922329",
         "#5B4534", "#FDE8DC", "#404E55", "#0089A3", "#CB7E98", "#A4E804", "#324E72", "#6A3A4C")

data_zymomock<-read.csv(file = 'abundance_zymomock_all.tsv',sep = '\t')
data_zymomock$Pipeline <- factor(data_zymomock$Pipeline,                                  
                  levels = c("Expected", "DADA2", "Deblur", "UNOISE3", "UPARSE","VSEARCH"))
data_zymomock$Organism <- gsub("_", " ", data_zymomock$Organism)
target <- data_zymomock[data_zymomock$Organism != "non reference", 1]
target<-unique(target)
data_zymomock$Organism <- factor(data_zymomock$Organism, levels=c("non reference", target))
zymomock_plot<-ggplot(data=data_zymomock, aes(x=Pipeline,y=Rel_abundance, fill=Organism)) +
  geom_bar(stat="identity")+
  scale_fill_brewer(palette="Paired")+
  theme_minimal()+
  theme(axis.text = element_text(size=19,face = 'bold'),axis.text.x =element_text(vjust = 8),legend.text = element_text(size = 22),axis.title=element_text(size=20,face="bold"),axis.title.x=element_text(vjust = 6),legend.title = element_text(size=20))+
 
  
  labs(y="Relative abundance", x = "Pipeline",fill='zymomockmock expected features')+
  scale_fill_manual(values=c("#bdbdbd",col))


data_mock16<-read.csv(file = 'abundance_mock16_all.tsv',sep = '\t')
data_mock16$Pipeline <- factor(data_mock16$Pipeline,                                  
                              levels = c( "Expected","DADA2", "Deblur", "UNOISE3", "UPARSE","VSEARCH"))
data_mock16$Organism <- gsub("_", " ", data_mock16$Organism)
target <- data_mock16[data_mock16$Organism != "non reference", 1]
target<-unique(target)
data_mock16$Organism <- factor(data_mock16$Organism, levels=c("non reference", target))
mock16_plot<-ggplot(data=data_mock16, aes(x=Pipeline,y=Rel.abundance, fill=Organism)) +
  geom_bar(stat="identity")+
  scale_fill_brewer(palette="Paired")+
  theme_minimal()+
  theme(axis.text = element_text(size=19,face = 'bold'),axis.text.x=element_text(vjust = 8),legend.text = element_text(size = 22),axis.title=element_text(size=20,face="bold"),axis.title.x=element_text(vjust = 6),legend.title = element_text(size = 20))+
  labs(y="Relative abundance", x = "Pipeline",fill='Mock16 expected features')+
  scale_fill_manual(values=c("#bdbdbd",col))+
  
  guides(fill=guide_legend(ncol=2))

zymomock_legend<- get_legend(
  # create some space to the left of the legend
  zymomock_plot
)
mock16_legend<- get_legend(
  # create some space to the left of the legend
  mock16_plot
)

png(file  = 'abundance_figure.png',width = 1500,height = 1400)
ggdraw() +
  draw_plot(zymomock_plot+theme(legend.position = 'none'), x = 0.03, y = 0.5, width = .5, height = 0.5) +
  draw_plot(mock16_plot+theme(legend.position = 'none'), x = 0.03, y = 0, width = .5, height = 0.5) +
  draw_plot(zymomock_legend, x = 0.53, y = 0.5, width = .47, height = 0.5) +
  draw_plot(mock16_legend, x = 0.53, y = 0, width = .47, height = 0.5) +
  draw_plot_label(label = c("A", "B"), size = 30, x = c(0, 0), y = c(1, 0.5))
dev.off()
          

ggdraw() +
  draw_plot(zymomock_plot+theme(legend.position = 'none'), x = 0.01, y = 0, width = .25, height = 1) +
  draw_plot(zymomock_legend, x = 0.25, y = 0, width = .15, height = 1) +
  draw_plot(mock16_plot+theme(legend.position = 'none'), x = 0.39, y = 0, width = .25, height = 1) +
  draw_plot(mock16_legend, x = 0.62, y = 0, width = .40, height = 1) +
  draw_plot_label(label = c("A", "B"), size = 30, x = c(0, 0.37), y = c(1, 1))

ggsave("abundance_figure.png", height=11, width=37.5, device="png")
  
