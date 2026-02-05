#!/usr/bin/env nextflow

process MULTIQC {
  conda 'bioconda::multiqc'
  
  cpus 1
  memory '8 GB'
  time '1.h'
  
  publishDir params.outdir, mode: 'copy'

  input:
    path '*'

  output:
    path "multiqc_report.html"
  
  """
    multiqc .
  """
}