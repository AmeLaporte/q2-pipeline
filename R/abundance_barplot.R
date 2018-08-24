install.packages('Rcpp', dependencies = TRUE)
install.packages("ggplot2", dependencies = T)
install.packages('data.table', dependencies = TRUE)
install.packages("plyr", dependencies = T)
install.packages("dplyr", dependencies = T)
install.packages("tidyr", dependencies = T)
install.packages("gridExtra", dependencies = T)
install.packages("RColorBrewer")
library(plyr)
library(dplyr)
library(tidyr)
library(Rcpp)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(RColorBrewer)

require(reshape2)
require(scales)
require(plyr)
require(tidyr)
require(ggplot2)
require(gridExtra)
setwd("/media/amelie/DATA/STAGE_Guadeloupe/Sampling_depth/Analysis-18000/Taxonomy/SILVA/97/table/")

#Open the taxonomic abundance table
df<-read.table("15abundant.tsv",header = TRUE, sep="\t", check.names = FALSE)
#Organize the table
df<-subset(df,select=c("Taxon","4S","4H","3S","3H","2S","2H","1S","1H","8B","8A"))

#Create a new table
df.long<- melt(df, id.vars="Taxon",
               measure.vars=names(df[2:11]),
               variable.name="Sample",
               value.name="Abundance")
#Calcule le taux d'abondance relative
df.long <- ddply(df.long, .(Sample), transform, Abundance=(Abundance/sum(Abundance))*100)

#Creation du bar plot
df.long <- subset(df.long, df.long$Abundance != 0)
df.long$Taxon<- reorder(df.long$Taxon, -df.long$Abundance)
info <- dcast(df.long, Taxon ~ Sample)
info[is.na(info)] <- 0
info$`8A` <- round(info$`8A`,2)
info$`8B` <- round(info$`8B`,2)
info$`1H` <- round(info$`1H`,2)
info$`1S` <- round(info$`1S`,2)
info$`2S` <- round(info$`2S`,2)
info$`2H` <- round(info$`2H`,2)
info$`3S` <- round(info$`3S`,2)
info$`3H` <- round(info$`3H`,2)
info$`4S` <- round(info$`4S`,2)
info$`4H` <- round(info$`4H`,2)
#test<-info
#test<-data.frame(Taxon=ifelse(info$`4S`<1&info$`4H`<1&info$`3S`<1&info$`3H`<1&info$`2S`<1&info$`2H`<1&info$`1S`<1&info$`1H`<1&info$`8A`<1&info$`8B`<1,"Other",info$Taxon))

#Palette de 24 couleurs
cl <- colors(distinct = TRUE)
set.seed(nrow(df))
palette <- sample(cl, nrow(df))
#Associe les couleurs aux valeurs de taxon
names(palette) <- levels(df.long$Taxon)
mycolors <- c("#A6CEE3","#1F78B4","#B2DF8A","#33A02C","#FB9A99","#E31A1C","#FDBF6F","#FF7F00","#CAB2D6","#6A3D9A","#FFFF99","#B15928","#1B9E77","#D95F02","#7570B3")
colScale <- scale_fill_manual(name = "Taxon",values = mycolors)

bar <-ggplot(df.long, aes(x=Sample, y=Abundance, fill=Taxon, group=Abundance)) + 
  geom_bar(stat="identity", width=0.8)+
  colScale +
  #scale_fill_brewer(palette='Paired') +
  scale_y_continuous(breaks=seq(0,100,10)) +
  guides(fill=guide_legend(nrow=nrow(df)/3,byrow=TRUE)) +
  xlab('Échantillons')+
  ylab("Abondance")+
  labs(title = "Abondance relative des 15 phylums les plus représentés", subtitle = "", caption = "")+
  theme_minimal() + coord_flip()

bar + theme(legend.position='bottom')
#+ theme(legend.position = 'none')

df<-subset(df,select=c("Taxon","8A","8B","1H","1S","2H","2S","3H","3S","4H","4S"))

df.long<- melt(df, id.vars="Taxon",
               measure.vars=names(df[2:11]),
               variable.name="Sample",
               value.name="Abundance")
#Calcule le taux d'abondance relative
df.long <- ddply(df.long, .(Sample), transform, Abundance=(Abundance/sum(Abundance))*100)

#Creation du bar plot
df.long <- subset(df.long, df.long$Abundance != 0)
df.long$Taxon<- reorder(df.long$Taxon, -df.long$Abundance)
info <- dcast(df.long, Taxon ~ Sample)
info[is.na(info)] <- 0
info$`8A` <- round(info$`8A`,2)
info$`8B` <- round(info$`8B`,2)
info$`1H` <- round(info$`1H`,2)
info$`1S` <- round(info$`1S`,2)
info$`2S` <- round(info$`2S`,2)
info$`2H` <- round(info$`2H`,2)
info$`3S` <- round(info$`3S`,2)
info$`3H` <- round(info$`3H`,2)
info$`4S` <- round(info$`4S`,2)
info$`4H` <- round(info$`4H`,2)

tt <- ttheme_default(colhead=list(fg_params = list(parse=TRUE)))

tbl <- tableGrob(info, rows=NULL, theme=tt)

grid.arrange( bar,tbl,
              nrow=2,
              as.table=TRUE)

#Extraire et imprimer que la légende
#install.packages('cowplot')
#library(cowplot)
legend <- get_legend(bar)
ggdraw(plot_grid(legend))


# Exporte le tableau en csv
write.csv(info, file = "gamma-table.csv")

