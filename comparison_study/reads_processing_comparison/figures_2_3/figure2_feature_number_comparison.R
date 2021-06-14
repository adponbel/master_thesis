library('ggplot2')
library("cowplot")

setwd('PATH_to_directory')

col <- c("#FFFF00", "#1CE6FF", "#FF34FF", "#FFAA92", "#04F757", "#006FA6", "#A30059",
         "#7A4900", "#0000A6", "#63FFAC", "#B79762", "#004D43", "#8FB0FF", "#997D87",
         "#5A0007", "#809693", "#4FC601", "#3B5DFF", "#4A3B53", "#FF2F80",
         "#61615A", "#BA0900", "#6B7900", "#00C2A0", "#FF90C9", "#B903AA", "#D16100",
         "#DDEFFF", "#000035", "#7B4F4B", "#A1C299", "#300018", "#0AA6D8", "#013349", "#00846F",
         "#372101", "#FFB500", "#C2FFED", "#A079BF", "#CC0744", "#C0B9B2", "#C2FF99", "#001E09",
         "#00489C", "#6F0062", "#0CBD66", "#EEC3FF", "#456D75", "#B77B68", "#7A87A1", "#788D66",
         "#885578", "#FAD09F", "#FF8A9A", "#D157A0", "#BEC459", "#456648", "#0086ED", "#886F4C",
         "#34362D", "#B4A8BD", "#00A6AA", "#452C2C", "#636375", "#A3C8C9", "#FF913F", "#938A81",
         "#575329", "#00FECF", "#B05B6F", "#8CD0FF", "#3B9700", "#04F757", "#C8A1A1", "#1E6E00",
         "#7900D7", "#A77500", "#6367A9", "#A05837", "#6B002C", "#772600", "#D790FF", "#9B9700",
         "#549E79", "#FFF69F", "#201625", "#72418F", "#BC23FF", "#99ADC0", "#3A2465", "#922329",
         "#5B4534", "#FDE8DC", "#404E55", "#0089A3", "#CB7E98", "#A4E804", "#324E72", "#6A3A4C")

###zymomock

data_zymomock<-read.csv(file = 'feature_zymomock_all.tsv',sep = '\t')
data_zymomock$Pipeline <- factor(data_zymomock$Pipeline,                                  
                             levels = c("dada2", "deblur", "unoise", "uparse","vsearch"))

data_zymomock$Type <- factor(data_zymomock$Type,                                  
                         levels = c("Unmatched","Partial database","Exact database","Partial sequence","Exact sequence"))
data_zymomock_asv<-data_zymomock[data_zymomock$Pipeline=="dada2"|data_zymomock$Pipeline=="deblur"|data_zymomock$Pipeline=="unoise", ]

plot_zymomock_asv<-ggplot(data=data_zymomock_asv, aes(x=Pipeline,y=Counts, fill=Type)) +
  geom_bar(stat="identity")+
  scale_fill_brewer(palette="Paired")+
  theme_cowplot()+
  theme(axis.text = element_text(size=20),legend.text = element_text(size = 20),axis.title =element_text(size=20))+
  labs(y="ASV counts", x = '')+
  scale_fill_manual(values=c(col))+
  geom_hline(yintercept =10, linetype="dotted",size=1.2)+
  scale_y_continuous(limits=c(0, 15))

plot_zymomock_asv
data_zymomock_otu<-data_zymomock[data_zymomock$Pipeline=="uparse"|data_zymomock$Pipeline=="vsearch", ]
plot_zymomock_otu<-ggplot(data=data_zymomock_otu, aes(x=Pipeline,y=Counts, fill=Type)) +
  geom_bar(stat="identity")+
  scale_fill_brewer(palette="Paired")+
  theme_cowplot()+
  theme(axis.text = element_text(size=20),legend.text = element_text(size = 20),axis.title =element_text(size=20))+
  labs(y="OTU counts", x ='')+
  scale_fill_manual(values=c(col))+
  geom_hline(yintercept =8, linetype="dotted",size=1.2)

plot_zymomock_otu
plot_zymomock_all <- grid.arrange(arrangeGrob(plot_zymomock_asv+theme(legend.position="none"),plot_zymomock_otu, nrow=1),bottom="Pipeline")



######mock16

data_mock16<-read.csv(file = 'feature_mock16_all.tsv',sep = '\t')
data_mock16$Pipeline <- factor(data_mock16$Pipeline,                                  
                            levels = c("dada2", "deblur", "unoise", "uparse","vsearch"))

data_mock16$Type <- factor(data_mock16$Type,                                  
                             levels = c("Unmatched","Partial database","Exact database","Partial sequence","Exact sequence"))
data_mock16_asv<-data_mock16[data_mock16$Pipeline=="dada2"|data_mock16$Pipeline=="deblur"|data_mock16$Pipeline=="unoise", ]

plot_mock16_asv<-ggplot(data=data_mock16_asv, aes(x=Pipeline,y=Counts, fill=Type)) +
  geom_bar(stat="identity")+
  scale_fill_brewer(palette="Paired")+
  theme_cowplot()+
  theme(axis.text = element_text(size=20),legend.text = element_text(size = 20),axis.title =element_text(size=20))+
  labs(y="ASV counts",x='',fill='')+
  scale_fill_manual(values=c(col))+
  geom_hline(yintercept =65, linetype="dotted",size=1.2)+
  scale_y_continuous(limits=c(0, 100))

data_mock16_otu<-data_mock16[data_mock16$Pipeline=="uparse"|data_mock16$Pipeline=="vsearch", ]
plot_mock16_otu<-ggplot(data=data_mock16_otu, aes(x=Pipeline,y=Counts, fill=Type)) +
  geom_bar(stat="identity")+
  scale_fill_brewer(palette="Paired")+
  theme_cowplot()+
  theme(axis.text = element_text(size=20),legend.text = element_text(size = 20),axis.title =element_text(size=20))+
  labs(y="OTU counts", x ='')+
  scale_fill_manual(values=c(col))+
  geom_hline(yintercept =47, linetype="dotted",size=1.2)+
  scale_y_continuous(limits=c(0, 100))

plot_mock16_all <- grid.arrange(arrangeGrob(plot_mock16_asv+theme(legend.position="none"),plot_mock16_otu, nrow=1),bottom="Pipeline")
    


##join plots

legend <- get_legend(
  # create some space to the left of the legend
  plot_mock16_asv + theme(legend.box.margin = margin(0, 0, 0, 30),legend.position = "bottom")+ guides(color = guide_legend(nrow = 1,title = ''),fill = guide_legend(reverse = TRUE))
)

plot<-ggdraw() +
  draw_plot(plot_zymomock_asv+theme(legend.position = 'none'), x = 0.02, y = 0.5, width = .54, height = 0.5) +
  draw_plot(plot_zymomock_otu+theme(legend.position = 'none'), x = 0.61, y = 0.5, width = .40, height = 0.5) +
  draw_plot(plot_mock16_asv+theme(legend.position = 'none'), x = 0.02, y = 0, width = .54, height = 0.5) +
  draw_plot(plot_mock16_otu+theme(legend.position = 'none'), x = 0.61, y = 0, width = .40, height = 0.5) +
  draw_plot_label(label = c("A", "B"), size = 25,
                  x = c(0, 0), y = c(1, 0.5))

png(file  = 'feature_figure.png',width = 850,height = 850)
plot_legend<-plot_grid(plot,legend,ncol =1, rel_heights  = c(1, .10))
plot_legend
dev.off()

