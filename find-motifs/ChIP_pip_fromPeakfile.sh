#!/bin/bash
#  Author: Xin Wang  flyboyleo@gmail.com
#  Author: Joe Godbehere

#Input:
# a reference genome
# a narrow/broad peak file
# a motif file
# path to Homer

#Output:
# file containing sorted motifs, with peak information
# annotation file
# to stderr: progress/error messages

#Requires:
# Homer
# bedtools
# perl

#Usage:
USAGE="#Usage : path/ChIP_pip_fromPeakfile.sh <mm10/hg19/mm9/hg18/dm3> <input narrow/broad peak file> <motif file> <(optional) number of jobs> <(optional) min length of each motif>"
#Example:
# ChIP_pip_fromPeakfile.sh hg19 GSM782123only.narrowPeak custom.motifs

#calculate path to this script
Ppath=$(dirname "$0")

#the first argument must indicate one of the supported genomes
if [[ ($1 != "hg19") && ($1 != "hg18") && ($1 != "mm10") && ($1 != "mm9") && ($1 != "dm3")]]
then
	echo "ERROR: Reference genome '$1' not supported" >&2
	echo "${USAGE}" >&2
	exit
fi
genome=$1

#second argument must be the peakfile
if [ ! -e $2 ]
then
	echo "ERROR: Peak file '$2' not found" >&2
	echo "${USAGE}" >&2
	exit
fi
peak_file=$2

#third argument must be the motif file
if [ ! -e $3 ]
then
	echo "ERROR: Motif file '$3' not found" >&2
	echo "${USAGE}" >&2
	exit
fi
motif_file=$3

split=1
if [ ! -z $4 ]
then
	if [ "$4" -gt "1" ]
	then
		split=$4
	fi
else
	echo "WARNING: At time of writing, Homer's motif annotation tools do not properly handle motif files containing more than ~200 motifs at a time. If your motif file contains more than 200 motifs, you should provide a 4th command line argument to specify the number of chunks we should split the motif file into (i.e. number of motifs / 200)">&2
	exit
fi

minlen=0
if [ ! -z $5 ]
then
	if [ "$5" -gt "1" ]
	then
		minlen=$5
	fi
fi

Input=$(basename "${peak_file}")
xpref=${Input%.*}

InputM=$(basename "${motif_file}")
Mpref=${InputM%.*}

#define some file names/paths
anno_file="${xpref}_${Mpref}_motif.anno"
peak_file_temp="${xpref}.Pvalue.narrowPeak"

#extract information from the peak file into a format accepted by Homer
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$8"\t"$6"\t"$7}' "${peak_file}" > "${peak_file_temp}"

function annotate {
	motifs=$1
	output=$2
	# -noann flag excludeds detailed annotation data.
	# This halves memory use and improves runtime
	# This extra annotation data would not be featured in the output data anyway,
	# and could be reproduced later
	annotatePeaks.pl "${peak_file_temp}" "${genome}" -m "${motifs}" -noann > "${output}"
}

if [ $split -lt 2 ]
then
	#attempt to annotate without splitting the work into chunks
	annotate "${motif_file}" "${anno_file}"
	rm "${peak_file_temp}"
	"${Ppath}"/ChIP_pip_fromAnnofile.sh "${genome}" "${anno_file}"
	#rm "${anno_file}"
else
	#attempt to split the work into chunks by splitting the motif file

	#make sure temp directory for motifs exists and is empty
	split_motif_dir="./${Mpref}_split.tmp"
	mkdir -p "${split_motif_dir}"
	rm -f "${split_motif_dir}/*"

	#split motif file into chunks
	perl "${Ppath}"/split_motif_file.pl -m "${motif_file}" -n "${split}" -d "${split_motif_dir}" -min "${minlen}"

	#make sure temp directory for annotations exists and is empty
	#anno_prefix="${xpref}_${Mpref}_motif"
	anno_postfix=".anno"
	anno_dir="./${xpref}_${Mpref}_anno.tmp"
	mkdir -p "${anno_dir}"
	rm "${anno_dir}/*"

	#for each (split) motif file, generate a corresponding anno file
	split_motif_files=${split_motif_dir}/*
	for filename in ${split_motif_files}
	do
		basename=$(basename "${filename}")
		annotate "${filename}" "${anno_dir}/${basename}${anno_postfix}"
	done
	rm "${peak_file_temp}"
	"${Ppath}"/ChIP_pip_fromAnnofile.sh "${genome}" "${anno_dir}"
	rm -R "${split_motif_dir}"
	#rm -R "${anno_dir}"
fi

echo "Done." >&2
