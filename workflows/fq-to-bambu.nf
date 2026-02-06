#!/usr/bin/env nextflow

include { NANOPLOT } from '../modules/nanoplot.nf'
include { MINIMAP2_ALIGN } from '../modules/minimap2.nf'
include { SAMTOOLS } from '../modules/samtools.nf'
include { CREATE_BW } from '../modules/deeptools.nf'
include { CREATE_ANNOTATIONS; CREATE_RCFILES; BAMBU } from '../modules/bambu.nf'
include { MULTIQC } from '../modules/multiqc.nf'

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

  NANOPLOT(reads_ch)
  MINIMAP2_ALIGN(reads_ch.combine(Channel.fromPath(params.refFa)))


  sam_ch = MINIMAP2_ALIGN.out
    .map { sam -> tuple(sam.baseName, sam) }
  SAMTOOLS(sam_ch)

  dt_ch = SAMTOOLS.out.bam
    .map { bam -> tuple(bam.baseName, bam) }
  CREATE_BW(dt_ch)

  CREATE_ANNOTATIONS(Channel.fromPath(params.refFa), Channel.fromPath(params.refGtf))

  files_ch = SAMTOOLS.out.bam
    .combine(Channel.fromPath(params.refFa))
    .combine(Channel.fromPath(params.refGtf))
    .combine(CREATE_ANNOTATIONS.out)

  CREATE_RCFILES(files_ch)

  BAMBU(CREATE_RCFILES.out.collect(),
         Channel.fromPath(params.refFa),
         CREATE_ANNOTATIONS.out)

  // Aggregate QC files
  multiqc_ch = NANOPLOT.out
    .mix(SAMTOOLS.out.stats)
    .mix(SAMTOOLS.out.flagstat)
    .collect()

  MULTIQC(multiqc_ch)
}