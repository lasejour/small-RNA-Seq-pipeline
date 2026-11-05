#!/usr/bin/env nextflow

/*
Running Manatee for small RNA-Seq reads

Necessary tools for operation:
- Perl5 with Set::IntervalTree module
- Samtools
- Bowtie-1.3.1

Necessary parameters:
- organism primary assembly file
- corresponding Bowtie genome index
- small RNA annotation file
- corresponding Bowtie small RNA index
- perl modules directory
*/

process MANATEE {

      tag "sample: $sample_name"
      maxForks 6

      publishDir "${params.output}/manatee/${sample_name}", mode: 'copy'

      input:
      tuple val(sample_name), path(read_files)
      tuple val(primary_assembly_file), val(genome_index)
      tuple val(nc_annotation_file), val(transcriptome_index)
      val perl_mod_dir
      path manatee_exec

      output:
      path "*_trimmed_Manatee"

      script:
      """
      perl -I ${perl_mod_dir} -Mlocal::lib
      zcat $read_files > ${sample_name}_trimmed.fastq

      $manatee_exec -i ${sample_name}_trimmed.fastq -o ${sample_name}_trimmed_Manatee \
      -index "$genome_index" -genome "$primary_assembly_file" \
      -annotation "$nc_annotation_file" -t_index "$transcriptome_index" -cores 6

      rm ${sample_name}_trimmed.fastq
      """






}
