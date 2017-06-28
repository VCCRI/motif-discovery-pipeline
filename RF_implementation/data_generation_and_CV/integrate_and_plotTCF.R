#  Author: Xin Wang  flyboyleo@gmail.com
system("mkdir ~/Downloads/TCF7L2/; cd ~/TCF7L2_motif_freq/; cp --parents `find -name \*.Rdata` ~/Downloads/TCF7L2/")
library(gtools)
setwd("~/Downloads/TCF7L2/")

list.dirs(recursive = F)->dirs

 Acc_F1<-vector("list", length(dirs))

for(h in 1:length(dirs)){

folder<-paste0("~/Downloads/TCF7L2/",dirs[h])
setwd(folder)

list.files(pattern = "*.Rdata")->Rfiles

 tmp<-vector("list", length(Rfiles)) 

 for(i in 1:length(Rfiles)){
   
   load(Rfiles[i])
   do.call(rbind,test) -> tmp[[i]]
 }

 do.call(rbind,tmp) -> Acc_F1[[h]]
}

 
 
setwd("~/Downloads/TCF7L2/")
pdf(file = "TCF7L2_unique_peaks_flanking5-300_10CV10.pdf", width = 30, height = 8) 
 
mai = c(0.8,0.8,0.8,0.8)
par(mfrow = c(2,3), mai = c(0.8,0.8,0.8,0.8),oma = c(0, 0, 3, 0))


lapply(Acc_F1,function(c){c[,2]})[mixedorder(dirs)] -> F1_HCT
boxplot(F1_HCT, xaxt = "n",main = "HCT-116", 
        xlab= "Flanking boundary from peak centres (bp)", ylab= "F1 score")
axis(1, at=1:length(dirs), labels=c(c(5,10,seq(20,300,20))))
abline(v = 8,col="red", lty = 3)

lapply(Acc_F1,function(c){c[,3]})[mixedorder(dirs)] -> F1_HEK293
boxplot(F1_HEK293, xaxt = "n",main = "HEK293",
        xlab= "Flanking boundary from peak centres (bp)", ylab= "F1 score")
axis(1, at=1:length(dirs), labels=c(c(5,10,seq(20,300,20))))
abline(v = 8,col="red", lty = 3)

lapply(Acc_F1,function(c){c[,4]})[mixedorder(dirs)] -> F1_HeLaS3
boxplot(F1_HeLaS3, xaxt = "n",main = "HeLa-S3",
        xlab= "Flanking boundary from peak centres (bp)", ylab= "F1 score")
axis(1, at=1:length(dirs), labels=c(c(5,10,seq(20,300,20))))
abline(v = 8,col="red", lty = 3)

lapply(Acc_F1,function(c){c[,5]})[mixedorder(dirs)] -> F1_HepG2
boxplot(F1_HepG2, xaxt = "n",main = "HepG2",
        xlab= "Flanking boundary from peak centres (bp)", ylab= "F1 score")
axis(1, at=1:length(dirs), labels=c(c(5,10,seq(20,300,20))))
abline(v = 8,col="red", lty = 3)

lapply(Acc_F1,function(c){c[,6]})[mixedorder(dirs)] -> F1_MCF
boxplot(F1_MCF, xaxt = "n",main = "MCF-7",
        xlab= "Flanking boundary from peak centres (bp)", ylab= "F1 score")
axis(1, at=1:length(dirs), labels=c(c(5,10,seq(20,300,20))))
abline(v = 8,col="red", lty = 3)

lapply(Acc_F1,function(c){c[,7]})[mixedorder(dirs)] -> F1_PANC
boxplot(F1_PANC, xaxt = "n",main = "PANC-1",
        xlab= "Flanking boundary from peak centres (bp)", ylab= "F1 score")
axis(1, at=1:length(dirs), labels=c(c(5,10,seq(20,300,20))))
abline(v = 8,col="red", lty = 3)

mtext("10 times 10-folds Cross-Validation of the TCF7L2 dataset", outer = TRUE, cex = 1.5)

dev.off()

