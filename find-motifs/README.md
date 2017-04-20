## Installation:
1. Make sure `ChIP_pip_fromPeakfile.sh` and `ChIP_pip_fromAnnofile.sh` are executable. i.e. in *nix: `chmod 775 *.sh`
2. Install HOMER: http://homer.ucsd.edu/homer/introduction/install.html
3. Install the relevant genome to HOMER. e.g. if we wanted to use `hg19`, then we navigate to the directory where HOMER is installed, then run
  `perl configureHomer.pl -install hg19`

## Usage:

#### Inputs:
1. A narrowPeak file in .bed format
2. A file containing a set of motif definitions (PWM)

#### Execute:
1. Navigate to the directory where you wish the output to be generated
2. Call
```
path_to_scripts/ChIP_pip_fromPeakfile.sh <mm10/hg19/mm9/hg18/dm3> <input narrow/broad peak file> <motif file> <(optional) number of jobs> <(optional) min length of each motif>
  ```

  Caution: HOMER's annotation/motif finding component appears to have a limitation where searching for more than around 200 motifs at a time silently fails to return all the motifs. For this reason (and to reduce memory constraints) this script has an option to split the work into multiple chunks. You should  

#### Example
Suppose that:
1. The scripts are installed at `~/data-pipeline-scripts/find-motifs`
2. The genome is `hg19`
3. The narrowPeak file is: `~/data/seq/GSM782123only.narrowPeak`
4. The motif file is: `~/data/motifs/custom.motifs`
5. There are 1000 motifs, therefore we need the script to break it into at least `ceil(1000/200) = 5` jobs

Then, from the folder where the output should appear, run

```
~/data-pipeline-scripts/find-motifs/ChIP_pip_fromPeakfile.sh hg19 ~/data/seq/GSM782123only.narrowPeak ~/data/motifs/custom.motifs 5
```
This will output two things to the current directory:
1. `motif.bed` - a sorted list of motifs found at the peaks, annotated with basic information about the corresponding peak to each motif
2. A HOMER annofile (or a folder containing multiple anno files) containing some additional data about the motifs.)
