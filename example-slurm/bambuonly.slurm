#!/bin/bash
#SBATCH --job-name=bambu-only
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --output=logs/%x_%j.out

set -euo pipefail

module load nextflow
module load miniforge

# Verify executor configuration
nextflow config | grep 'executor'

nextflow run ../nf-scripts/workflows/bambu-only.nf \
-with-report ../results/20260203_bambuonly-trialbulk/reports/report-64core.html \
-with-timeline ../results/20260203_bambuonly-trialbulk/reports/timeline-64core.html \
-with-trace ../results/20260203_bambuonly-trialbulk/reports/trace-64core.txt \
--refFa ../raw-data/sgnex/reference/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa \
--refGtf ../raw-data/sgnex/reference/Homo_sapiens.GRCh38.91.gtf \
--outdir ../results/20260203_bambuonly-trialbulk/ \
--bams '../raw-data/sgnex/bam/genome/**/*.bam' \
--cpus 64 \
--memory '512 GB'