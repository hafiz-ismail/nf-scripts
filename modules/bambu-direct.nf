#!/usr/bin/env nextflow

params.cpus = 8
params.memory = '64 GB'

process CREATE_ANNOTATIONS {
  conda 'bioconda::bioconductor-bambu=3.12.1'
  
  cpus 1
  memory params.memory
  time '1.h'

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


process BAMBU_DIRECT {
  conda 'bioconda::bioconductor-bambu=3.12.1'

  publishDir params.outdir, mode: 'copy'

  cpus params.cpus
  memory params.memory
  time '12.h'

  input:
    path bams
    path refFa
    path annotations

  output:
    path "bambu-results.rds"
    """
    #!/usr/bin/env Rscript --vanilla
    library(bambu)

    bams_vec <- unlist(strsplit("$bams", split = " "))

    se <- bambu(reads = bams_vec, 
      annotations = readRDS("$annotations"),
      genome = "$refFa",
      ncore = ${task.cpus})

    saveRDS(se, 'bambu-results.rds')
    """
}