# QIIME2 Pipeline

This pipeline was conceived in order to study metagenomic data with taxonomic assignment and downstream statistical and functional analysis.
It is adapted for data that were already demultiplexed, assembled and cleaned.

## What do you need

[1] `qiime2-2018.2`

[2] `biom-format` (Python package)

[3] `Tax4fun`

[4] `R`

## How to use this pipeline
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

The first step of this analysis is to launch the `q2-pipeline.sh` on your server where `qiime2-2018.2` is installed.
This script allows you to choose if you also want the diversity analysis by QIIME2 or not.
It will launch the taxonomic classification of your data in a background task because this step can take a long time.

Once you the taxonomic classification is done, you can launch the `R-tax4fun-pipeline.sh` to do the statistical analysis with `R` followed by a functional analysis using `Tax4fun`.

### References

[1] <https://qiime2.org/>

[2] <http://biom-format.org/>

[3] Aßhauer, K. P., Wemheuer, B., Daniel, R., & Meinicke, P. (2015). Tax4Fun: predicting functional profiles from metagenomic 16S rRNA data. Bioinformatics, 31(17), 2882–2884. <http://doi.org/10.1093/bioinformatics/btv287>

<http://tax4fun.gobics.de/>

[4]  R Development Core Team (2008). R: A language and environment for
  statistical computing. R Foundation for Statistical Computing,
  Vienna, Austria. ISBN 3-900051-07-0, URL <http://www.R-project.org.>


