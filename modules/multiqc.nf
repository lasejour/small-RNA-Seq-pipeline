#!/usr/bin/env nextflow

/*
Basic process for running multiqc
Expects input channel with:
- A path to all the relevant log files
- config file as the second parameter
- output directory path as third parameter
- tag value for the last value
*/

process MULTIQC {
        tag "Gathering logs..."

        publishDir "${params.output}/multiQC/$tag", mode: 'copy'

        input:
        path log_dir
        path config_file
        val tag
        val step

        output:
        path "multiqc_report.html"
        path "multiqc_data"
        path "multiqc_data/initial_multiqc_fastqc.txt", optional: true, emit: initial_log
        path "multiqc_data/cleaned_multiqc_fastqc.txt", optional: true, emit: cleaned_log
        path "multiqc_data/genome_multiqc_star.txt", optional: true, emit: genome_log
        path "multiqc_data/ribo_multiqc_star.txt", optional: true, emit: ribo_log
        path "multiqc_data/spacer_multiqc_star.txt", optional: true, emit: spacer_log
        path "multiqc_data/multiqc_salmon.txt", optional: true, emit: salmon_log
        path "multiqc_data/multiqc_cutadapt.txt", optional: true, emit: cutadapt_log

        script:

        if (step == "fastqc" && tag == "initialQC") {
            """
            multiqc $log_dir -c $config_file
            mv "multiqc_data/multiqc_fastqc.txt" "multiqc_data/initial_multiqc_fastqc.txt"
            """
        } else if (step == "fastqc" && tag == "cleanedQC") {
            """
            multiqc $log_dir -c $config_file
            mv "multiqc_data/multiqc_fastqc.txt" "multiqc_data/cleaned_multiqc_fastqc.txt"
            """
        } else if (step == "star" && tag == "genomeMultiQC") {
            """
            multiqc $log_dir -c $config_file
            mv "multiqc_data/multiqc_star.txt" "multiqc_data/genome_multiqc_star.txt"
            """
        } else if (step == "star" && tag == "riboMULTIQC") {
            """
            multiqc $log_dir -c $config_file
            mv "multiqc_data/multiqc_star.txt" "multiqc_data/ribo_multiqc_star.txt"
            """
        } else if (step == "star" && tag == "spacerMULTIQC") {
            """
            multiqc $log_dir -c $config_file
            mv "multiqc_data/multiqc_star.txt" "multiqc_data/spacer_multiqc_star.txt"
            """
        } else {
            """
            multiqc $log_dir -c $config_file
            """

        }

}
