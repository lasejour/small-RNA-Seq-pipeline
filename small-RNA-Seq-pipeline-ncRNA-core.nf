#!/usr/bin/env nextflow

include { FASTQC } from './modules/fastqc.nf'
include { FASTQC as cleanedQC } from './modules/fastqc.nf'
include { MULTIQC } from './modules/multiqc.nf'
include { MULTIQC as cleanedMULTIQC } from './modules/multiqc.nf'

include { RETRIEVEADAPTERS } from './modules/retrieve_adapters.nf'

include { CUTADAPT } from './modules/cutadapt.nf'

include { MANATEE } from './modules/manatee.nf'

params.sample_file = ""
params.pattern = ""
params.fastq_dir = ""
params.adapters = ""
//params.perl_modules_dir = ""


def helpMessage() {
    log.info """
    =========================================
     small RNA-Seq Pipeline ncRNA core v2.0
    =========================================
    Usage:
        nextflow run small-RNA-pipeline-ncRNA-core.nf [options]

    Required arguments:
    * Either
        --fastq_dir               Path to input FASTQ files (e.g. 'data/')
        --pattern                 Regex to find FASTQ files (e.g. '*{R1,R2}*.fastq.gz')

    * Or
        --sample_file             Path to sample list with sample names and read locations (i.e refer to README.md for format)


    Optional arguments:
        --output                  Path to results directory (default: 'results')

    Manatee arguments:
	--primary_assembly	  Path to primary assembly fasta file that Manatee will use
	--bowtie_genome_index	  Path to Bowtie index of primary assembly
	--nc_annotation		  Path to transcriptome file, containing sequences of non-coding genes for genome
	--transcriptome_index	  Path to Bowtie index of transcriptome fasta file
	--manatee_file		  Path to Manatee executable 
	
	* Defining your own parameters	
        -smRNA-params-file        Path to parameters file (default: smRNA-params.yml)


    Example:
        nextflow run small-RNA-Seq-pipeline-ncRNA-core.nf \\
            --fastq_dir 'data/' \\
            --pattern '*_{1,2}.fastq.gz'
            --output my_results
            -profile local
            -params-file smRNA-params.yml
    =========================================
    """.stripIndent()

}

if (params.help) {
    helpMessage()
    exit 0
}



if (params.sample_file) {
    raw_reads_ch = Channel
          .fromPath(params.sample_file, checkIfExists: true)
          .splitCsv(header: true, strip: true)
          .map { row ->
                def sample = row.SampleName
                def read_file     = file(row.Path, checkIfExists: true)

                if (!sample) error "Missing 'SampleName' field in row: ${row}"
                if (!read_file)     error "Path not found for sample: ${sample}"
                return [sample, read_file]
          }

} else if (!params.sample_file && params.fastq_dir && params.pattern ) {
    Channel
          .fromPath("${params.fastq_dir}/${params.pattern}", checkIfExists: true)
          .ifEmpty { exit 1, "You provided an empty directory" }
          .map { file -> tuple(file.simpleName, file) }
          .set { raw_reads_ch }

} else {
    error """
      No input provided. Please specify either:
        --input      Path to a CSV samplesheet OR
        --fastq_dir  Directory containing paired FASTQ files and
        --pattern    A grep pattern that includes the fastq files
      """
}

workflow {

      // Initial QC with fastqc and multiqc
      FASTQC( raw_reads_ch, "initialQC" )
      initial_fastqc_ch = FASTQC.out.fastqc_out.collect()
      MULTIQC( initial_fastqc_ch, params.multiqc_config, "initialQC", "fastqc" )

      // trim adapters
      if (!params.adapters) {

          RETRIEVEADAPTERS( raw_reads_ch, params.dnapi_file, params.txt2fasta_file )
          CUTADAPT( raw_reads_ch, RETRIEVEADAPTERS.out.out_fasta )

      } else {

          CUTADAPT( raw_reads_ch, params.adapters )

      }
      // cleaned QC
      cleanedQC( CUTADAPT.out.trimmed_fastqs, "cleanedQC" )
      post_trimming_logs_ch = cleanedQC.out.fastqc_out
        .mix(CUTADAPT.out.trim_logs)
        .collect()
      cleanedMULTIQC( post_trimming_logs_ch, params.multiqc_config, "cleanedQC", "fastqc")

      MANATEE( CUTADAPT.out.trimmed_fastqs, tuple(params.primary_assembly, params.bowtie_genome_index), tuple(params.nc_annotation, params.transcriptome_index), params.perl_modules_dir, params.manatee_file )


}

workflow.onComplete {

    println "small RNA-Seq workflow finished!"
    println "Duration: ${workflow.duration}"

}
