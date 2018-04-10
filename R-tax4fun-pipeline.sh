#!/usr/bin/env Rscript

#Installer Tax4Fun (ask to do it on the server)
install.packages('qiimer', repos='http://cran.us.r-project.org', quiet = TRUE)
install.packages('RJSONIO', repos='http://cran.us.r-project.org', quiet = TRUE)
install.packages('https://cran.r-project.org/src/contrib/Archive/biom/biom_0.3.12.tar.gz', quiet = TRUE)
install.packages('http://tax4fun.gobics.de/Tax4Fun/Tax4Fun_0.3.1.tar.gz', quiet = TRUE)
download.file('http://tax4fun.gobics.de/Tax4Fun/ReferenceData/SILVA119.zip', destfile="classifiers/tax4fun/SILVA119.zip", quiet = TRUE)
unzip("classifiers/tax4fun/SILVA119.zip", exdir="classifiers/tax4fun/.")

#Installer Vegan
install.packages("vegan", dependencies=TRUE)
require(vegan)
library(vegan)

setwd("~/Bureau/extracted-feature-table/")
metadata <- read.csv("metadata.csv", header=TRUE, row.names = 1)
factors<-names(metadata)
#TODO: demander le choix à l'utilisateur en fonction de l'interieur des metadata
metadata$Site = as.factor(metadata$Site)
otutable = read.table("~/Bureau/extracted-feature-table/feature-table (biom-tsv)/data/feature-table.tsv", sep="\t", header=TRUE, row.names = 1, check.names = FALSE)
#TODO !: ordre des echantillons soit le même que dans les metadata
otutable <- subset(otutable,select=c("1H","1S","2H","2S","3H","3S","4H","4S","8A","8B"))
otus = t(otutable)
read_depth = rowSums(otus)
# A L P H A   D I V E R S I T Y
shannon = diversity(otus, index = "shannon")
simpson = diversity(otus, index = "simpson")
richness = specnumber(otus)
rrichness = rarefy(otus, sample=min(read_depth))
#TODO: output graph as img file
rarecurve(otus,step=500)
sac=specaccum(otus)
plot(sac, ci.type="polygon", ci.col="yellow")
#Output first analysis
alphadiv = data.frame(read_depth=read_depth,richness=richness,rarefied_richness=rrichness,shannon=shannon,simpson=simpson)
write.csv(alphadiv, "chao_observed.csv", quote=FALSE)
#Boxplots
#TODO: output img file + summary en fonction des choix de l'utilisateur
summary(aov(rrichness~metadata$Site))
boxplot(rrichness~metadata$Site)
summary(aov(rrichness~metadata$Season))
boxplot(rrichness~metadata$Season)
summary(lm(rrichness~metadata$Site))
summary(lm(rrichness~metadata$Season))
summary(lm(rrichness~Site+Season,data=metadata))
#Hierarchical clustering
otus.ra = decostand(otus, method = "total")
bcDist = vegdist(otus.ra)
hc = hclust(bcDist, method="average")
#TODO: plot as img file
plot(hc)
#Principal component analysis:
pcasp = prcomp(otus.ra)
summary(pcasp)
ordiplot(pcasp, display="sites", type="t")
ordiplot(pcasp, display="sites", type="t")
ef_pca = envfit(pcasp, metadata)
plot(ef_pca, p.max=0.05/22, cex=0.8)
nmds_bc = metaMDS(otus.ra)
ordiplot(nmds_bc, display="sites", type="t")
nmds_g = metaMDS(otus.ra, distance="gower")
ordiplot(nmds_g, display="sites", type="t")
#to change!!
colour = c(rep("red",8),rep("green",8))
symbol = c(rep(1,4),rep(2,4),rep(1,4),rep(2,4))

ordiplot(nmds_g, display="sites", type="none")
points(nmds_g, display="sites", lwd=2, col=colour, pch=symbol)
legend("bottomleft", title="Treatment", pch=c(1,2), legend=c("No P","P"))
legend("bottomright", title="Soil type", col=c("red","green"), legend=c("Siliceous","Calcareous"),pch=1)

ordiplot(nmds_g, display="sites", type="none")
points(nmds_g, display="sites", lwd=2, col=colour, pch=symbol)
ordiellipse(nmds_g, groups=metadata$Parent.material, display = "sites", kind="sd", draw="lines",
            col=c("green","red"), conf=.95)

ef_nmds = envfit(nmds_g,metadata)

ordiplot(nmds_g, display="sites", xlim=range(-.2,.3), type="none")
points(nmds_g, display="sites", lwd=2, col=colour, pch=symbol)
ordiellipse(nmds_g, groups=metadata$Parent.material, display = "sites", kind="sd", draw="lines",
            col=c("green","red"), conf=.95)
plot(ef_nmds, p.max=0.05/22, cex=0.8)

hist(metadata$Year, col="grey", main= "Observed distribution of year")
adonis(otus.ra ~ Site, data=metadata)
adonis(otus.ra ~ Season, data=metadata)
#tochange
boxplot(Season~Site+Parent.material, data=metadata, main="Effect of fertilization and soil type on P conc.")
adonis(otus.ra ~ Parent.material + P + pH + Longitude + Latitude, data=metadata)
bioenv(otus.ra, metadata[,c("Parent.material","Soil.C", "N","P","pH","Longitude","Latitude",
                            "Fertilizer", "Compaction", "Aluminium.saturation")], metric="gower")
adonis(otus.ra ~ Parent.material, data=metadata)
sf = simper(otus.ra, group=metadata$Site, permutations=1000, parallel=4)

#Use Tax4Fun
library(Tax4Fun)

files = c("useful/closed/feature-table-tax4fun.txt")
QIIMEData = importQIIMEData(files)

pathReferenceData = "../classifiers/tax4fun/SILVA119"

Tax4FunOutput <- Tax4Fun(QIIMEData,pathReferenceData, fctProfiling = TRUE, refProfile = "UProC", shortReadMode = TRUE, normCopyNo = TRUE)

Tax4FunProfile <- data.frame(t(Tax4FunOutput$Tax4FunProfile))

write.table(Tax4FunProfile,"useful/tax4fun/Tax4FunProfile_Export.csv",sep="\t")