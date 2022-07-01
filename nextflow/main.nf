// enable dsl2 
nextflow.enable.dsl=2

params.help = null

println """\

G E R M L I N E  V A R I A N T  D I S C O V E R Y 
=================================================
BWA     : BWA 0.7.12
Annovar : Annovar 4.18
Picard  : Picard 2.18.25
Samtools: Samtools 1.15.1
GATK    : GenomeAnalysisTK 4.1.3.0
"""
.stripIndent()

// import nextflow modules
include { bam_qc } from "./modules/bam_qc.nf"
include { bam_prep } from "./modules/bam_prep.nf"
include { fastq_qc } from "./modules/fastq_qc.nf"
include { fastq_prep } from "./modules/fastq_prep.nf"
include { dna_alignment } from "./modules/dna_alignment.nf"
include { variant_discovery } from "./modules/variant_discovery.nf"
include { variant_annotation } from "./modules/variant_annotation.nf"

// define main workflow
workflow {

    main:
        // read in dbsnp files
        dbsnp = Channel.fromPath("${params.dbsnp}/*")
            .collect()
        
        // read in bwa genome index files
        genome_bwa_files = Channel.fromPath("${params.genome_bwa_files}/*")
            .collect()

        // read in the genome files
        genome_fasta_files = Channel.fromPath("${params.genome_fasta_files}/*")
            .collect()

        // create channel with data
        fastqs = Channel.fromFilePairs("${params.fastqs}/*_{1,2}.fastq", flat: true)

        // prep the raw fastq files
        fastq_prep(
            fastqs
        )

        // perform qc on preped fastq files
        fastq_qc(
            fastq_prep.out
        )

        // allign the reads onto the reference genome
        dna_alignment(
            fastq_prep.out,
            genome_fasta_files,
            genome_bwa_files
        )

        // prep the raw bam files
        bam_prep(
            dna_alignment.out,
            genome_fasta_files
        )

        // perform bam qc
        bam_qc(
            dna_alignment.out
        )

        // call germline variants
        variant_discovery(
            bam_prep.out,
            genome_fasta_files,
            dbsnp
        )

        // annotate variants
        variant_annotation(
            variant_discovery.out,
            genome_fasta_files
        )
}
