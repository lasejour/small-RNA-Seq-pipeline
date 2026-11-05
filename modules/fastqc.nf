#!/usr/bin/env nextflow

/*
Basic process for running fastqc
Expects input channel with:
- sample name, fastqs in tuple as first parameter
- output directory path as second parameter
*/

process FASTQC {

        tag "sample: $sample_name"

        publishDir "${params.output}/$sample_name/$tag", mode: 'copy'

        input:
        tuple val(sample_name), path(read_files)
        val tag

        output:
        path "*_fastqc.{zip,html}", emit: fastqc_out

        script:
        """
        fastqc -q $read_files
        """
}
