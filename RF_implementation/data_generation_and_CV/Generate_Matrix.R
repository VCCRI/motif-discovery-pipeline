# This script generate the Matrix from the motif pipeline for the RF training purpose.

#Author: Xin Wang, flyboyleo@gmail.com

# Run this script under RF_implementation/TCF7L2 orv other TF folder.

tail(strsplit(getwd(),split = "/")[[1]],n = 1)->TF

mkdircommand<-paste0("mkdir ~/",TF,"_motif_freq/")

system(mkdircommand)

library(foreach)
library(doMC)
library(parallel)
registerDoMC(detectCores()-1) #Automatically detecting the number of cores.

#this.dir <- dirname(parent.frame(2)$ofile) # setting working directory to this source file location, may not work in Rstudio, you could change it manually to your absolute path.
#setwd(this.dir)
#setwd("/Volumes/Ho_lab/Xin/narrowPeaks_Znf274/motif-discovery-pipeline-master/RF_implementation/MXI1");
getwd()->TFfolder

list.dirs(recursive = F)->dirs

foreach(h = 1:length(dirs)) %dopar% {
  
  setwd(TFfolder);
  setwd(dirs[h])
  
  list.dirs(recursive = F)->samplesFolder
  strsplit(samplesFolder,split = "/")->samplesFolderlist
  sapply(samplesFolderlist, function(c){c[2]})->samplesFolderName
  
  path<-NULL;
  
  for (i in 1:length(samplesFolderName)){
   path[i]<-paste0(dirs[h],"/", samplesFolderName[i],"/motif.bed")
  }

 foreach(k = 1:length(path)) %dopar%{

  setwd(TFfolder);
  es <- read.table(path[k],sep="\t")
  
  output_path<-paste0("~/",TF,"_motif_freq/")
  setwd(output_path)
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



