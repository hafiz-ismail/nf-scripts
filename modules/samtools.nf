#!/usr/bin/env nextflow

process SAMTOOLS {
  publishDir params.outdir, mode: 'copy'

  input:
    tuple val(sample_id), path(sam)

  output:
    path "${sample_id}-sorted.bam", emit: bam
    path "${sample_id}-sorted.bam.bai", emit: index
  
  """
    samtools view -b $sam > "${sample_id}.bam"
    samtools sort "${sample_id}.bam" -o "${sample_id}-sorted.bam"
    samtools index "${sample_id}-sorted.bam"
  """
}