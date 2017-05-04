#  Author: Xin Wang  flyboyleo@gmail.com

library(foreach)
library(doMC)
registerDoMC(128)
library("caret")
require("randomForest")
setwd("~/TCF7L2_motif_freq/");

list.dirs(recursive = F)->dirs


foreach(n = 1:10) %dopar% {         

foreach(h = 1:length(dirs)) %dopar% {
  
  folder<-paste0("~/TCF7L2_motif_freq/",dirs[h])
  print(folder)
  setwd(folder)
  dd<-na.omit(read.table("tmp6.out"))[-1,-1]
motifName <- na.omit(read.table("tmp6.out")[-1,1])
#dd[,1:3000]->dd

nooOFolds <- as.numeric(10)

flds <- createFolds(c(1: ncol(dd)), k=nooOFolds, list=TRUE, returnTrain=FALSE)

label<-as.factor(c(rep(1,500),rep(2,500),rep(3,500),rep(4,500),rep(5,500),rep(6,500)) )


enumatc <- c(1:nooOFolds)

modelpredic <- function (z){
  dd.ff<-dd[,-flds[[z]]]
  dd.ts <- dd[,flds[[z]]]
  classifier<-randomForest(t(dd.ff),as.factor(label[-flds[[z]]]), ntree = 500);
  
  test.label<-predict(classifier, t(dd.ts))    #,  type='prob')
  
  table(label[flds[[z]]], test.label) -> results
  print(results)
  results[1,1]+results[2,2]+results[3,3]+results[4,4]+results[5,5]+results[6,6] ->correct
  correct/sum(results) -> Accuracy  #Overall Accuracy

  F1score<-function(k){               # must be inside.
    
    results[k,k]/sum(results[k,]) ->precision
    
    results[k,k]/sum(results[,k]) ->recall
    
    2*(precision*recall)/(precision+recall)->F1
    
    return(F1)
  }
  
  #sapply(1:6,F1score) -> F1scores
  F1scores<-NULL
  for(j in 1:6){F1score(j)->F1scores[j]}
  
  return(c(Accuracy, F1scores))
  
 }

 #test <- lapply(enumatc, modelpredic)
 test <-vector("list",length(nooOFolds))
 for(i in 1:nooOFolds){modelpredic(i)->test[[i]]}

 fname <-paste0(n,"_",h,"dirstest.Rdata")
  
 save(test, file = fname)
 }

}





