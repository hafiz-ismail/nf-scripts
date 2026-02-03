#!/usr/bin/env nextflow

include { CREATE_ANNOTATIONS; CREATE_RCFILES; BAMBU } from '../modules/bambu.nf'

// Define my params here
params.refFa = '/path/to/reference/genome/'
params.refGtf = '/path/to/annotations/'
params.bams = '/path/to/files.bam'
params.outdir = '/path/to/save/results/'

workflow {
  CREATE_ANNOTATIONS(Channel.fromPath(params.refFa), Channel.fromPath(params.refGtf))

  files_ch = Channel.fromPath(params.bams)
    .combine(Channel.fromPath(params.refFa))
    .combine(Channel.fromPath(params.refGtf))
    .combine(CREATE_ANNOTATIONS.out)

  CREATE_RCFILES(files_ch)

  BAMBU(CREATE_RCFILES.out.collect(),
         Channel.fromPath(params.refFa),
         CREATE_ANNOTATIONS.out)
}