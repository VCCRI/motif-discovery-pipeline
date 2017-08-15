#  Author: Xin Wang  flyboyleo@gmail.com
setwd("~/TCF7L2_motif_freq/120/") 

#sh automergeTable.sh
library(foreach)
library(doMC)
registerDoMC(6)  # Change 6 to your CPU cores number.
library(randomForest)
library(ROCR)
library("caret")

dd2<-read.table("120_tmp6.motif.bed.out")[-1,-1] # renamed from the "tmp6.out in ~/TCF7L2_motif_freq/120/" 

dd<-t(dd2)

labels<-as.factor(c(rep(1,500),rep(2,500),rep(3,500),rep(4,500),rep(5,500),rep(6,500)))

# OOB  --------------------------------------------------------------


pdf("OOB_120_TCF7L2.pdf",8,5)
par(mai=c(1.02,1,0.82,0.42))
#plot(RFmodel2$err.rate[,1], log="y",col=1, type = "l")
#plot(RFmodel2_500$err.rate[,1], log="y",col=1, type = "l")
set.seed(213)
randomForest(dd,ntree = 1000, y = as.factor(labels),
             importance = T, do.trace = 100, proximity = T,keep.inbag = TRUE) -> RFmodel_1000
save(RFmodel_1000, file = "RFmodel_120_tree1k_TCF.Rdata")

plot(RFmodel_1000$err.rate[,1], log="y",col=1, type = "l", xlab="Number of trees", ylab = "Error"
     ,main = "Out of Bag (OOB) evaluation of RF of TCF7L2 dataset")

#legend("topright",inset = 0.02, c("OOB"),col=1,cex=0.8,fill=1)
dev.off()



#Generate a cross-validation set

foreach (j = 1:10) %do% {
set.seed(j)

AUC <-vector("list",length = 10)  
  
folds <- createFolds(labels, k = 10, list = TRUE, returnTrain = FALSE)

#Initialise predictions and test labels
#all.predictions <-c()
#all.predictions.continuous <- c()
#all.test.labels <-c()

pred.test <- vector("list", length(folds)) 
test.labels <- vector("list", length(folds)) 
pred.cont <- vector("list", length(folds)) 

#Iterate through the training/test folds
  for (i in 1:10){
  test <- dd[folds[[i]], ]
  train <- dd[-folds[[i]], ]
  
  train.labels <- labels[-folds[[i]]]
  #rf.classifier <- randomForest(train, y=train.labels, ntree=2)
  rf.classifier <- foreach(ntree=rep(100, 5), .combine=combine,.multicombine = T, .packages='randomForest') %dopar%
      randomForest(train, train.labels, ntree=ntree)
  rf.classifier
  
  pred.test <- predict(rf.classifier, test)
  test.labels <- labels[folds[[i]]]
  
  pred.cont <- predict(rf.classifier, test, type='prob')
  


#all.predictions <- unlist(pred.test)
#all.predictions.continuous <- do.call(rbind, pred.cont)
#all.test.labels <- unlist(test.labels)
#save.image("~/Movies//forShanon/TCF7L2_only/20/tmp//save_from_loop.Rdata")
 
#cm <- confusionMatrix(data=all.predictions, reference=all.test.labels, positive='True')

roc.x.values <- c()
roc.y.values <- c()
auc.values <- c()
roc.class.labels <- c()



for (class in 1:6) {
  cluster.labels <- test.labels==class
  pred.cont.output <- prediction(pred.cont[,class], cluster.labels)
  perf_AUC <- performance(pred.cont.output,"auc")
  perf_ROC <- performance(pred.cont.output,"tpr","fpr")
  perf_F1 <- performance(pred.cont.output,"f")
  
  
  
  roc.x.values <- c(roc.x.values, unlist(perf_ROC@x.values))
  roc.y.values <- c(roc.y.values, unlist(perf_ROC@y.values))
  auc.values <- c(auc.values, perf_AUC@y.values[[1]])
  roc.class.labels <- c(roc.class.labels, rep(class, length(unlist(perf_ROC@x.values))))
 }

auc.values->AUC[[i]]
 }

fname <- paste0(j,"_AUC_TCF.Rdata")
save(AUC, file = fname)
}



  
list.files(pattern = "*_AUC_TCF.Rdata")->Rfiles

tmp<-vector("list", length(Rfiles)) 

for(i in 1:length(Rfiles)){
  
  load(Rfiles[i])
  do.call(rbind,AUC) -> tmp[[i]]
  
}

do.call(rbind,tmp) -> AUCMatrix


data<-as.data.frame(t(apply(AUCMatrix,2,function(x){
  c(mean(x),sd(x))
})))

colnames(data)<-c("AUROC","sd")


library(ggplot2)

pdf("AUC_TCF_100times_TCF7L2.pdf",width = 4,height = 2)

dodge <- position_dodge(width = 0.9)
limits <- aes(ymax = data$AUROC + data$sd,
              ymin = data$AUROC - data$sd)

data$Cells<-c("HCT-116","HEK293","HeLa-S3","HepG2","MCF-7","PANC-1")

p <- ggplot(data = data, aes(x = Cells, y = AUROC, fill = Cells))

p + geom_bar(stat = "identity", position = dodge) +
  geom_errorbar(limits, position = dodge, width = 0.25) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.x=element_blank())

dev.off()

