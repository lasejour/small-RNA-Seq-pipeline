# small-RNA-Seq-pipeline
End-to-end Nextflow pipeline for analyzing small RNAs from quality assessment, adapter trimming, genome and transcriptome mapping to quantification.

## Pipeline Overview
![Pipeline DAG](dag.png)

The pipeline handles small RNA-Seq fastq files:
- Initial and post-trimming QC (FastQC & MultiQC)
- Adapter trimming (Cutadapt)
- small rna biotype (snRNA, miRs, isomiRs) detection (Manatee)

## Requirements
- Nextflow >= 25.10
- Conda (for the local profile)
- All tool versions are managed per-process in smRNA_nextflow.config.
- To create an environment with all the necessary tools, users can create a conda environment with the environment.yml file.

## Installation
```
git clone https://github.com/lasejour/small-RNA-Seq-pipeline.git
cd small-RNA-Seq-pipeline
```

---

## Usage

```
nextflow run main.nf \\
  --fastq_dir 'data/' \\
  --pattern '*.fastq.gz'
  --output my_results
  -profile local
  -params-file smRNA-params.yml
```

or

```
nextflow run main.nf \
  --sample_file 'sample_file.csv' \
  --output my_results \
  -profile local \
  -params-file params.yml
```

For help:
```
nextflow run main.nf --help
```

---

## Input

The pipeline accepts reads in two ways:

Option 1 - Directory + pattern
```
--fastq_dir data/
--pattern '*.fastq.gz'
```

Option 2 - Sample sheet (CSV):
```
SampleName,Read1
sample,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz
```

---

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `--fastq_dir` | Path to input FASTQ directory | — |
| `--pattern` | Regex pattern to match FASTQ files | — |
| `--sample_file` | Path to CSV sample sheet (alternative to fastq_dir) | — |
| `--output` | Path to results directory | `results` |
| `--primary_assembly` | Path to primary assembly fasta file that Manatee will use | — |
| `--bowtie_genome_index` | Path to Bowtie index of primary assembly | — |
| `--nc_annotation` |  Path to transcriptome fasta file, containing sequences of non-coding genes for genome| — |
| `--transcriptome_index` | Path to Bowtie index of transcriptome fasta file | — |
| `--manatee_file` | Path to Manatee executable | — |

---

## Outputs

All results are written to `--output` (default: `results/`):

| Directory | Contents |
|---|---|
| sample_names |
| `initialQC/` | FastQC and MultiQC reports on raw reads |
| `cleanedQC/` | FastQC and MultiQC reports post-trimming |
| `trimming/`  | Trimmed FASTQ files and trimming logs |
| `manatee/`   | Manatee quantification result files |
| `multiQC/`   | MultiQC summary |

| `pipeline_info/` | Execution timeline, report, trace, and DAG |

---

## Tools & Versions

| Tool | Version |
|---|---|
| FastQC | 0.12.1 |
| Cutadapt | 4.9 |
| manatee | 1.0 |
| Salmon | 1.10.2 |
| MultiQC | 1.17 |

---
