# *inux environment with bedtools installed required.
require(data.table)

file_list <- list.files(recursive = F, all.files = F, pattern = "*.bed")


for (i in 1:length(file_list)){
  
# Generate bed files from pooling peaks. Each of them lacks peaks from one cell-line.
lackone_dataset <- rbindlist(lapply( file_list[-i], fread )) 

lackone_name <- paste0("no_",file_list[i])

write.table(lackone_dataset,file = lackone_name,quote = F, sep = "\t",row.names = F,col.names = F)

system("mkdir unique_peaks")

unique_name <- paste0("./unique_peaks/",file_list[i])

command <- paste("bedtools subtract -A -a", file_list[i], "-b", lackone_name, ">", unique_name)

system(command)

commandRM <- paste("rm", lackone_name)

system(commandRM)

}

rm(lackone_dataset)









