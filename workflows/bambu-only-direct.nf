#!/usr/bin/env nextflow

include { CREATE_ANNOTATIONS; BAMBU_DIRECT } from '../modules/bambu-direct.nf'

// Define my params here
params.refFa = '/path/to/reference/genome/'
params.refGtf = '/path/to/annotations/'
params.bams = '/path/to/files.bam'
params.outdir = '/path/to/save/results/'
params.cpus = 8

workflow {
  CREATE_ANNOTATIONS(Channel.fromPath(params.refFa), Channel.fromPath(params.refGtf))

  BAMBU_DIRECT(Channel.fromPath(params.bams).collect(),
         Channel.fromPath(params.refFa),
         CREATE_ANNOTATIONS.out)
}