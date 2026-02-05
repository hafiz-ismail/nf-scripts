#!/bin/bash
#SBATCH --job-name=fqtobambu-withqc
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --output=logs/%x_%j.out

set -euo pipefail

module load nextflow
module load miniforge

# Verify executor configuration
nextflow config | grep 'executor'

nextflow run -resume ../nf-scripts/workflows/fq-to-bambu.nf \
-with-report ../results/20260205_fq-to-bambu/reports/report.html \
-with-timeline ../results/20260205_fq-to-bambu/reports/timeline.html \
-with-trace ../results/20260205_fq-to-bambu/reports/trace.txt \
--refFa ../raw-data/sgnex/chr22/reference/hg38_chr22.fa \
--refGtf ../raw-data/sgnex/chr22/reference/hg38_chr22.gtf \
--reads '../raw-data/sgnex/chr22/fastq/*.fastq.gz' \
--outdir ../results/20260205_fq-to-bambu/
