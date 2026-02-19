#!/usr/bin/env nextflow

process CREATE_BW {
  cpus 8
  memory '64 GB'
  time '2.h'
  
  conda 'bioconda::deeptools'

  publishDir params.outdir, mode: 'copy'

  input:
    tuple val(sample_id), path(bam), path(index)
  // Should still be 1-by-1 matchings

  output:
    path "${sample_id}.bw"

    """
    bamCoverage -b $bam -o "${sample_id}.bw" -p $task.cpus
    """
}