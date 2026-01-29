#!/usr/bin/env nextflow

process CREATE_ANNOTATIONS {
//  cpus 8
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


process CREATE_RCFILES {
//  cpus 8
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
      ncore = 8,
      quant = FALSE,
      discovery = FALSE,
      rcOutDir = './')

    """
}

// Use the previous annotations file oso
process BAMBU {
  publishDir params.outdir, mode: 'copy'

  cpus 8
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
      ncore = 8)

    saveRDS(se, 'bambu-results.rds')
    """
}
