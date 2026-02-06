#!/usr/bin/env nextflow

params.cpus = 8
params.memory = '64 GB'

process CREATE_BW {
  cpus params.cpus
  memory params.memory
  time '1.h'
  
  conda 'bioconda::deeptools'

  publishDir params.outdir, mode: 'copy'

  input:
    tuple val(sample_id), path(bam)
  // Should still be 1-by-1 matchings

  output:
    path "${sample_id}.bw"

    """
    bamCoverage -b $bam -o "${sample_id}.bw"
    """
}