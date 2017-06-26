# This script generate the Matrix from the motif pipeline for the RF training purpose.

#Author: Xin Wang, flyboyleo@gmail.com

library(foreach)
library(doMC)
registerDoMC(127)   # For AWS 128 CPUs instance. Change here to fit your own configuration.

#this.dir <- dirname(parent.frame(2)$ofile) # setting working directory to this source file location, you could change it manually to your absolute path.
#setwd(this.dir)
setwd("../TCF7L2/");

list.dirs(recursive = F)->dirs

foreach(h = 1:length(dirs)) %dopar% {
  

  path<-c(paste0(dirs[h],"/HCT-116.only.bed.500.txt/motif.bed"),
          paste0(dirs[h],"/HepG2.only.bed.500.txt/motif.bed"),
          paste0(dirs[h],"/HeLa.only.bed.500.txt/motif.bed"),
          paste0(dirs[h],"/MCF-7.only.bed.500.txt/motif.bed"),
          paste0(dirs[h],"/PANC-1.only.bed.500.txt/motif.bed"),
          paste0(dirs[h],"/HEK293.only.bed.500.txt/motif.bed"))
  

foreach(k = 1:length(path)) %dopar%{
  setwd(this.dir)
  setwd("../TCF7L2/");
  es <- read.table(path[k],sep="\t")
  
  setwd("~/TCF7L2_motif_freq/")
  dir.create(dirs[h])
  setwd(dirs[h])
  
  motifs1 <- unique(es[,6])

  motifs <- sort(motifs1)   
  
  peaks<-sort(na.omit(unique(es[,8])))

  
  counts <- matrix(NA, nrow=length(peaks), ncol=length(motifs))
  
  for(i in 1:length(peaks)){
    ind <- which(es[,8]==peaks[i])
    es_peak <- es[ind,]
    
    for(j in 1:length(motifs)){
      
      ind <- which(es_peak[,6]==motifs[j])
      counts[i,j] <- dim(es_peak[ind,])[1]	
    }	
  }
  colnames(counts) <- motifs
  rownames(counts) <- peaks

  write.table(t(counts),file=strsplit(dirname(file.path(path[k])),split = "/")[[1]][3],sep="\t",col.names = NA)
  }
}


