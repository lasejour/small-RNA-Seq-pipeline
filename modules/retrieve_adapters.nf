#!/usr/bin/env nextflow

/*
Retrieve small RNA-Seq adapters from fastq files
using DNApi, a python tool.
*/

process RETRIEVEADAPTERS {

      tag "$sample_name"

      publishDir "${params.output}/dnapi_adapters", mode: 'copy'

      input:
      tuple val(sample_name), path(read_files)
      path dnapi_file
      path txt2fasta_file

      output:
      path "*_adapter.fasta", emit: out_fasta

      script:
      """
      python $dnapi_file $read_files > ${sample_name}_adapter.txt
      Rscript $txt2fasta_file ${sample_name}_adapter.txt
      """

}
