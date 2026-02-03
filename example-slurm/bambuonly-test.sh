#!/bin/bash

# Verify executor configuration
echo "Checking Nextflow configuration..."
nextflow config -profile "$PROFILE" | grep -q "executor.*slurm" || {
    echo "WARNING: SLURM executor not detected!"
    echo "Current executor:"
    nextflow config -profile "$PROFILE" | grep executor
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
}

echo "SLURM executor configured"
echo ""

nextflow run -resume ../nf-scripts/workflows/bambu-only.nf \
-with-report ../results/20260203_bambuonly-trial/reports/report.html \
-with-timeline ../results/20260203_bambuonly-trial/reports/timeline.html \
-with-trace ../results/20260203_bambuonly-trial/reports/trace.txt \
--refFa ../raw-data/sgnex/chr22/reference/hg38_chr22.fa \
--refGtf ../raw-data/sgnex/chr22/reference/hg38_chr22.gtf \
--outdir ../results/20260203_bambuonly-trial/ \
--bams '../raw-data/sgnex/chr22/bam/*.bam'