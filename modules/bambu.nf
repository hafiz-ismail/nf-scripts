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


process CREATE_RCFILES {
  cpus 1
  memory params.memory
  time '12.h'
  
  conda 'bioconda::bioconductor-bambu=3.12.1 \
  conda-forge::r-biocmanager \
  bioconda::bioconductor-biocfilecache'
  // BiocManager fixes a 'Install 'BiocManager' from CRAN to get 'BioCann' contrib.url' error
  // BiocFileCache is needed to save RCfiles

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
      ncore = ${task.cpus},
      quant = FALSE,
      discovery = FALSE,
      rcOutDir = './')

    """
}

// Use the previous annotations file oso
process BAMBU {
  conda 'bioconda::bioconductor-bambu=3.12.1'
  
  publishDir params.outdir, mode: 'copy'

  cpus params.cpus
  memory '256 GB'
  time '12.h'

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
      ncore = ${task.cpus})

    saveRDS(se, 'bambu-results.rds')
    """
}