# Part 2: RandomForest implementations in the paper 

### Environment: Linux (may not fully compatible with Apple mac OS X)

The two sub-folders contains the raw unique peaks of TCF7L2 and MAX dataset. This readme file takes TCF7L2 dataset as example:

## 1. 10 times 10-folds Cross-Validation to find the best flanking regions:

#### 1). Run FlankingRegion_Top_NarrowPeak_auto.sh in the TCF7L2 folder to generate different flanking region BED files of each cell-line.   e.g. 

```
cd TCF7L2; sh ../data_generation_and_CV/FlankingRegion_Top_NarrowPeak_auto.sh
```
#### 2). Run modified HOMER: 
This step would be paralleled and quite CPU and memory consuming, it's recommanded to run on clusters such as Amazon AWS, this step also required original HOMER installed successfully with HOMER in the PATH and hg19 reference genome setuped in HOMER. See details in part 1 readme of find-motifs or HOMER manual online.

```
sh ../data_generation_and_CV/whole_pipline_auto_for_flanking_CV.sh
```

#### 3.) Run G_Matrix_compare_auto2_only_bed.R to change modified HOMER pipeline output BED files to motif frequency matrix. 
It's recommanded to run this step on clusters such as Amazon AWS, change CPU numbers in the script header to fit your own configuration.
```
mkdir ~/TCF7L2_motif_freq/; Rscript ../data_generation_and_CV/G_Matrix_compare_auto2_only_bed.R
```
#### 4.) Copy and run AutoMergeTable_auto_5-300.sh to merge each cell-line's motif frequency count to a matrix for Random Forest step. 
Setp 3 output files are now at "~/TCF7L2_motif_freq/", copy AutoMergeTable_auto_5-300.sh to "~/TCF7L2_motif_freq/"
```
cd ~/TCF7L2_motif_freq/; sh AutoMergeTable_auto_5-300.sh
```

#### 5.) Run Random_forest_with_F1score_ENCODE_10CV10_auto.R

```
Rscript Random_forest_with_F1score_ENCODE_10CV10_auto.R
```
#### 6.) Run integrate_and_plotTCF.R, then you would get "TCF7L2_unique_peaks_flanking5-300_10CV10.pdf" in "~/Downloads/TCF7L2/". (Additional file 1)
```
Rscript integrate_and_plotTCF.R
```

## 2. Out of Bag (OOB) to find the best ntree value and 10 times 10-folds Cross-Validation to get AUROC values from the best flanking regions (+/-120 bp).
Run:

```
Rscript AUROC_TCF_100times.R
```
Then you would get "OOB_120_TCF7L2.pdf" and "AUC_TCF_100times_TCF7L2.pdf" in "~/TCF7L2_motif_freq/120/".

## 3. Apply Random Forest with feature selection and tuning RF, get mean decrease accuracy (MDA) for each motif and extract rules by inTree.
Run:

```
Rscript Random_forest_and_inTrees.R
```
You'll get "importance_curve_TCF.pdf", "topMDA_TCF.pdf", and "readableRules_120_tree500.xls" in "~/TCF7L2_motif_freq/120/".



