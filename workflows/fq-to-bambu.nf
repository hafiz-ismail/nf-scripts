#!/usr/bin/env nextflow

include { MINIMAP2_ALIGN } from '../modules/minimap2.nf'
include { SAMTOOLS } from '../modules/samtools.nf'
include { CREATE_ANNOTATIONS; CREATE_RCFILES; BAMBU } from '../modules/bambu.nf'

// Define my params here
params.refFa = '/path/to/reference/genome/'
params.refGtf = '/path/to/annotations/'
params.reads = '/path/to/reads.fastq'
params.outdir = '/path/to/save/results/'

workflow {
  reads_ch = Channel.fromPath(params.reads)
    .map { fq -> 
        def read = (fq.name =~ /(.*)\.fastq(\.gz)?$/)[0][1] // Strip the whole .fastq.gz
        tuple(read, fq)
    }
    .combine(Channel.fromPath(params.refFa))
  MINIMAP2_ALIGN(reads_ch)


  sam_ch = MINIMAP2_ALIGN.out
    .map { sam -> tuple(sam.baseName, sam) }
  SAMTOOLS(sam_ch)



  CREATE_ANNOTATIONS(Channel.fromPath(params.refFa), Channel.fromPath(params.refGtf))

  files_ch = SAMTOOLS.out.bam
    .combine(Channel.fromPath(params.refFa))
    .combine(Channel.fromPath(params.refGtf))
    .combine(CREATE_ANNOTATIONS.out)

  CREATE_RCFILES(files_ch)

  BAMBU(CREATE_RCFILES.out.collect(),
         Channel.fromPath(params.refFa),
         CREATE_ANNOTATIONS.out)
}