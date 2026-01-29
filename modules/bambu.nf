#!/usr/bin/env nextflow
// Remember to set these params
// Or to make it modular, I need to bring back my old scripts.
// Come back to this, I just work on the minimap2 and sam2bam for now.

params.refFa = '~/scratch/20260122_bambu/reference/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa'
params.refGtf = '/scratch/20260122_bambu/reference/Homo_sapiens.GRCh38.91.gtf'
params.outdir = '/scratch/20260122_bambu/20260126_results'

process MAKE_ANNOTATIONS {
//  cpus 32
//  memory '64 GB'

  input:
  path refFa
  path refGtf

  output:
    path "annotations.rds"

    """
    #!/usr/bin/env Rscript --vanilla
    library(bambu)
    annotations <- prepareAnnotations("$refGtf")
    saveRDS(annotations, 'annotations.rds')
    """
}


process MAKE_RCFILES {
//  cpus 32
//  memory '64 GB'

  input:
  tuple path(bam), path(refFa), path(refGtf), path(annotations)
  // No collecting, pass one bam at a time (queue)

  output:
    path "*.rds"
    """
    #!/usr/bin/env Rscript --vanilla
    library(bambu)

    bambu(reads = "$bam", 
      annotations = readRDS("$annotations"),
      genome = "$refFa",
      ncore = 32,
      quant = FALSE,
      discovery = FALSE,
      rcOutDir = './')

    """
}

// Use the previous annotations file oso
process BAMBU {
  publishDir params.outdir, mode: 'copy'

  cpus 32
  memory '64 GB'

  input:
    path rcfiles
    path refFa
    path annotations

  output:
    path "bambu-results.rds"

    """
    #!/usr/bin/env Rscript --vanilla
    library(bambu)

    reads_vec <- unlist(strsplit("$rcfiles", split = " "))

    se <- bambu(reads = reads_vec, 
      annotations = readRDS("$annotations"),
      genome = "$refFa",
      ncore = 32)

    saveRDS(se, 'bambu-results.rds')
    """
}


// This kind of stuff should be in a main.nf script instead
// Can be a truncated main.nf to directly Bambu a .bam file.

// workflow {
//   MAKE_ANNOTATIONS(Channel.fromPath(params.refFa), Channel.fromPath(params.refGtf))
// 
//   files_ch = Channel.fromPath("bam_all/**/*.bam")
//   .combine(Channel.fromPath(params.refFa))
//   .combine(Channel.fromPath(params.refGtf))
//   .combine(MAKE_ANNOTATIONS.out)

//  MAKE_RCFILES(files_ch)

//  BAMBU(MAKE_RCFILES.out.collect(),
//         Channel.fromPath(params.refFa),
//         MAKE_ANNOTATIONS.out)
//  }

