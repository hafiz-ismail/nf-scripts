#!/bin/bash
#SBATCH --job-name=fq-to-bambu
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=15G
#SBATCH --output=logs/%x_%j.out

set -euo pipefail

module load miniforge
conda activate nf-sgnex

nextflow run -resume ../nf-scripts/workflows/fq-to-bambu.nf \
-with-report ../results/20260129_fq-to-bambu/reports/report.html \
-with-timeline ../results/20260129_fq-to-bambu/reports/timeline.html \
-with-trace ../results/20260129_fq-to-bambu/reports/trace.txt \
--refFa ../raw-data/sgnex/chr22/reference/hg38_chr22.fa \
--refGtf ../raw-data/sgnex/chr22/reference/hg38_chr22.gtf \
--outdir ../results/20260129_fq-to-bambu-retry/ \
--reads '../raw-data/sgnex/chr22/fastq/*.fastq.gz' # Note to wrap globs in quotation ('') marks.
