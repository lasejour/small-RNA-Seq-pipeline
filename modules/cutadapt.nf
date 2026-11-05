#!/usr/bin/env nextflow

/*
Basic process for running trimming
Expects input channel with:
- sample name, fastqs in tuple as first parameter
- adapters file as the second parameter
- output directory path as third parameter
*/

process CUTADAPT {

        tag "sample: $sample_name"
        cpus 4

        publishDir "${params.output}/$sample_name/trimming", mode: 'copy'

        input:
        tuple val(sample_name), path(read_files)
        path adapters

        output:
        tuple val(sample_name), path("*.trimmed.fastq.gz"), emit: trimmed_fastqs
        path "*cutadapt.log", emit: trim_logs

        script:
        if (params.prep == "single-end") {
              """
              cutadapt -j $task.cpus -q 10 -a file:$adapters -m 17 -o ${sample_name}.trimmed.fastq.gz $read_files > ${sample_name}.cutadapt.log
              """
        } else {
              """
              cutadapt -j $task.cpus -q 10 -a file:$adapters -A file:$adapters -m 17 -o ${sample_name}_R1.trimmed.fastq.gz -p ${sample_name}_R2.trimmed.fastq.gz $read_files > ${sample_name}.cutadapt.log
              """
        }
}
