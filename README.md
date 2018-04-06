# QIIME2 Pipeline

This pipeline was conceived in order to study metagenomic data with taxonomic assignment and downstream statistical and functional analysis.
It is adapted for data that were already demultiplexed, assembled and cleaned.
We begin this pipeline with one *.fastq* file per sample as well as a manifest file and a metadata file.

- **The manifest file** (in csv):

  - The header is: sample-id,absolute-filepath,direction

  - Each row contains the sample id, the absolute path to the sample file and the direction of the reads.

In our case, the reads are already merged so the direction of each sample will be described as forward.

- **The metadata file** (in tsv):

  - The header contains: #SampleID + all the metadata you want to include in your study. Might be the location, the pH, etc..

  - Each row contains one sample and all its corresponding metadata.

In order to use this pipeline, you need to create a general directory containing:

- A folder called `Silva` : it contains the SILVA classifier.

For this study, we used the classifier generated by the QIIME2 staff with SILVA128 available at:
<https://www.dropbox.com/sh/1i9l8clquvwm4xa/AABSABE569P9iTkcK9QAXdnwa?dl=0>

- A folder called `Data` : it contains your *.fastq* files as well as the *manifest* and *metadata* files.

- Then you clone this repository in your terminal with the following code:

```{bash}
git clone https://github.com/AmeLaporte/q2-pipeline.git
 ```