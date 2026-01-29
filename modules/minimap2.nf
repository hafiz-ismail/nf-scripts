#!/usr/bin/env nextflow

// Note that you'll need to pull the sample_id from the filename in your workflow

process MINIMAP2_ALIGN {
  input:
    tuple val(sample_id), path(reads), path(refFa)

  output:
    path "${sample_id}.sam"

  """
    minimap2 -ax splice -uf -k14 $refFa $reads > ${sample_id}.sam
  """
}

// Option to reduce memory usage in Minimap2 -I 2G 
// Option to use multiple threads: -t 8