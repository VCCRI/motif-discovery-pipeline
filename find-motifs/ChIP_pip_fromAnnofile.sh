#!/bin/bash
#  Author: Xin Wang  flyboyleo@gmail.com
#  Author: Joe Godbehere

#Input:
# a reference genome
# an annotation file

#Output:
# to stdout: sorted motifs, with peak information
# to stderr: progress/error messages
# the annotation file will be sorted in-place

#Requires:
# bedtools
# perl

#Usage:
USAGE="#Usage : path/ChIP_pip_fromAnnofile.sh <mm10/hg19/mm9/hg18/dm3> <anno file>"

#calculate path to this script
Ppath=$(dirname "$0")

#there should be exactly 2 arguments
if [ -z "$1" -o -z "$2" -o ! -z "$3" ]
then
echo "ERROR: Incorrect number of arguments" >&2
echo "${USAGE}" >&2
exit
fi

#the first argument must indicate one of the supported genomes
if [[ ($1 != "hg19") && ($1 != "hg18") && ($1 != "mm10") && ($1 != "mm9") && ($1 != "dm3")]]
then
echo "ERROR: Reference genome '$1' not supported" >&2
echo "${USAGE}" >&2
exit
fi
genome=$1

#second argument should be a file or directory
if [ ! -e $2 ]
then
echo "ERROR: Could not find file/dir '$2'" >&2
echo "${USAGE}" >&2
exit
fi
annotations=$2

if [ -d $annotations ]
then
	peakinfo="peakinfo.tmp"
	anno_files="${annotations}/*.anno"
	rm -f "${peakinfo}"
	for filename in ${anno_files}
	do
		if [ ! -e ${peakinfo} ]
		then
			cut -f 1-6 "${filename}" > "${peakinfo}"
		fi
	done
else
	peakinfo=$annotations
fi

function sortAnno {
	#sort the annonated peaks file, preserving the header row
	head -n 1 "$1" > "$1".tmp
	tail -n +2 "$1" | sort -V -k2,2 -k3,3 >> "$1".tmp
	rm "$1"
	mv "$1".tmp "$1"
}


if [ ! -d ${annotations} ]
then #the annotations are in a single file

	sortAnno "${annotations}"

	perl "${Ppath}"/anno2motif.pl "${annotations}" > motif.bed

else #the annotations are in a directory

	sortAnno "${peakinfo}"

	rm -f motif.bed
	for filename in ${anno_files}
	do
		perl "${Ppath}"/anno2motif.pl "${filename}" >> motif.bed
	done

fi

#according to bedtools documentation, unix sort is preferred over sortBed (performance)
#sortBed -i motif.bed > motif.sorted.bed
sort -V -k1,1 -k2,2 motif.bed > motif.sorted.bed
rm motif.bed
mv motif.sorted.bed motif.bed

#if the annotations were merged from multiple files, remove the temp file
if [ "${peakinfo}" != "${annotations}" ]
then
	rm "${peakinfo}"
fi

echo "Done." >&2
