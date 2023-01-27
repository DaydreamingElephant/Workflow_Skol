# Workflow_Skol
This is a project that serves as an example of documenting your workflows during bioinformatical research. Personally, I made a little [GoogleDoc](https://docs.google.com/document/d/1mKVJ1d2aPQhtxiAgTj_5g1_zKyl3ABjVpl2NpOSCOjk/edit?usp=sharing) with the work notes from the four days of the course. The overall goal is to analyze the interplay of [T5 bacteriophage](https://en.wikipedia.org/wiki/Escherichia_virus_T5) and its host - how the virus circumvents the [restriction-modification system](https://www.ndsu.edu/pubweb/~mcclean/plsc731/dna/dna5.htm) employing [various approaches](https://viralzone.expasy.org/3966) and the bacteria tries to counter them using, for example, the [PARIS system](https://www.biorxiv.org/content/10.1101/2021.01.21.427644v1.full.pdf). To this end we study raw phage genome reads, pre-process them and perform variant calling using the industry-standart tools.
## Structure
This project has three branches:
- Main/master branch with the description, enviroment configuration and barren of anything else. Please use conda and enter `conda env create -f envs/environment.yml` - it has everything necessary for both approaches.
- Bash branch where automation is achieved using core bash script functionality. 
- Snakemake branch which employs [snakemake](https://doi.org/10.1093/bioinformatics/bts480) pipeline management package for the same processes.
## This branch
Compared to provided files, included samtools into BWA .env file, altered raw reads handling because I have them uncompressed, ran the pipeline and uploaded .vcf with obtained results that differ from those gained from Bash branch.
## Contacts
Hit the author up at my [twitter](https://twitter.com/Serge_Bus).
