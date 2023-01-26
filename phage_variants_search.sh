#!/bin/bash

#alias "java -jar /home/nvaulin/Documents/Trimmomatic-0.39/trimmomatic-0.39.jar" trimmomatic

# define samples and other necessary parameters
declare -a SAMPLES=("AI-69_S60" "AI-70_S61" "AI-71_S62" "AI-72_S63" "AI-73_S64")
REF_GENOME="T5"
THREADS="8"

# define directories
QUALITY_DIR=Data/quality_reports
TRIMMING_DIR=Data/trimmed_reads
MAPPED_DIR=Data/mapped
MAPPED_SORTED_DIR=Data/mapped_sorted
MAPPED_STAT_DIR=Data/mapped_statistics
CALLING_DIR=Data/calling_files

# create directories
mkdir ${QUALITY_DIR} ${TRIMMING_DIR}
mkdir ${MAPPED_DIR} ${MAPPED_SORTED_DIR} ${MAPPED_STAT_DIR}
mkdir ${CALLING_DIR}

# index reference
REFERENCE=Data/reference/${REF_GENOME}_sequence.fasta
bwa index ${REFERENCE}

#iterate over samples
for SAMPLE in ${SAMPLES[@]}; do
    # Obtain files we examine during this cycle
    RAW_READ_FOR=Data/raw_files/${SAMPLE}_R1_001.fastq
    RAW_READ_REV=Data/raw_files/${SAMPLE}_R2_001.fastq
    
    # variables that we create
    TRIMMED_READ_FOR=${TRIMMING_DIR}/trimmed_${SAMPLE}_R1_paired.fq
    TRIMMED_READ_REV=${TRIMMING_DIR}/trimmed_${SAMPLE}_R2_paired.fq
    TRIMMED_READ_UNPAIRED_FOR=${TRIMMING_DIR}/trimmed_${SAMPLE}_R1_unpaired.fq
    TRIMMED_READ_UNPAIRED_REV=${TRIMMING_DIR}/trimmed_${SAMPLE}_R2_inpaired.fq
    
    ALIGNMENT_STAT=${MAPPED_STAT_DIR}/${REF_GENOME}_${SAMPLE}.txt
    ALIGNMENT_BAM=${MAPPED_DIR}/${REF_GENOME}_${SAMPLE}.bam
    ALIGNMENT_SORTED_BAM=${MAPPED_SORTED_DIR}/${REF_GENOME}_${SAMPLE}_sorted.bam
    VARIANTS_VCF=${CALLING_DIR}/variants_ref_${REF_GENOME}_sample_${SAMPLE}_filtered.vcf
    
    # quality check
    fastqc -q -t ${THREADS} --outdir ${QUALITY_DIR} ${RAW_READ_FOR} ${RAW_READ_REV}
    
    # trimming
    trimmomatic PE -phred33 -threads ${THREADS} \
        ${RAW_READ_FOR} ${RAW_READ_REV} \
        ${TRIMMED_READ_FOR} ${TRIMMED_READ_UNPAIRED_FOR} \
        ${TRIMMED_READ_REV} ${TRIMMED_READ_UNPAIRED_REV} \
        LEADING:15 TRAILING:15 SLIDINGWINDOW:10:20 MINLEN:20
    
    # alignment
    bwa mem -t ${THREADS} ${REFERENCE} ${TRIMMED_READ_FOR} ${TRIMMED_READ_REV} | \
    samtools view -Sb > ${ALIGNMENT_BAM}
    
    # get statistics
    samtools flagstat ${ALIGNMENT_BAM} > ${ALIGNMENT_STAT}
    
    # sort alignment
    samtools sort -@ ${THREADS} ${ALIGNMENT_BAM} -o ${ALIGNMENT_SORTED_BAM}
    
    # index alignment
    samtools index -@ ${THREADS} ${ALIGNMENT_SORTED_BAM} ${ALIGNMENT_SORTED_BAM}.bai
    
    # variant calling
    bcftools mpileup -Ou -f ${REFERENCE} ${ALIGNMENT_SORTED_BAM} | \
    bcftools call -Ou -mv --ploidy 1 | \
    bcftools filter -s LowQual -e '%QUAL<20 || DP>100' > ${VARIANTS_VCF}
done