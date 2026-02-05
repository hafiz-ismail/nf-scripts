#!/usr/bin/env nextflow

process NANOPLOT {
  conda 'bioconda::nanoplot'

  cpus 1
  memory '8 GB'
  time '1.h'

  // publishDir params.outdir, mode: 'copy'

  input:
  tuple val(sample_id), path(reads)

  output:
    path "${sample_id}_nanoplot/"

    """
    NanoPlot -t ${task.cpus} --fastq $reads -o "${sample_id}_nanoplot/" -p "${sample_id}_"
    """
}