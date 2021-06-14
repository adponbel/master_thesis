#$1:PATH to input directory with the paired-end samples (R1 for forward and R2 for reverse)
#$2:PATH where output directory named adapter_trimmed is created

#create output directory
mkdir $2/adapter_trimmed

#loop for adapter removal with cutadapt
#$3:forward adapter to be trimmed:
#CCTACGGGNGGCWGCAG for V3-V4 region (for zymomock and data for pilot study)
#GTGCCAGCMGCCGCGGTAA for V4 region (for for mock16)

#$4:reverse adapter to be trimmed:
#GACTACHVGGGTATCTAATCC for V3-V4 region (for zymomock and data for pilot study)
#GGACTACHVGGGTWTCTAAT for V4 region (for for mock16)

for i in $1/*_R1_001.fastq.gz
do
  SAMPLE=$(basename ${i} | sed "s/_R1_001\.fastq\.gz//")
  echo ${SAMPLE}_R1_001.fastq.gz ${SAMPLE}_R2_001.fastq.gz
cutadapt -m 100 -e 0.25 -n 1 -j 10 --discard-untrimmed -g $3 -G $4 -o $2/adapter_trimmed/${SAMPLE}_R1_001.fastq.gz -p $2/adapter_trimmed/${SAMPLE}_R2_001.fastq.gz $1/${SAMPLE}_R1_001.fastq.gz $1/${SAMPLE}_R2_001.fastq.gz
done
