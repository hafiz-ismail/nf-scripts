#!/usr/bin/env nextflow

process SAMTOOLS {
  conda 'bioconda::samtools'
  
  cpus 1
  memory '8 GB'
  time '1.h'

  // publishDir params.outdir, mode: 'copy'

  input:
    tuple val(sample_id), path(sam)

  output:
    path "${sample_id}.stats", emit: stats
    path "${sample_id}.flagstat", emit: flagstat

    path "${sample_id}-sorted.bam", emit: bam
    path "${sample_id}-sorted.bam.bai", emit: index
  
  """
    samtools view -b $sam > "${sample_id}.bam"

    samtools stats "${sample_id}.bam" > "${sample_id}.stats"
    samtools flagstat "${sample_id}.bam" > "${sample_id}.flagstat"

    samtools sort "${sample_id}.bam" -o "${sample_id}-sorted.bam"
    samtools index "${sample_id}-sorted.bam"
  """
}