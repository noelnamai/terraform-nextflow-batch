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
include { bamQC } from "./modules/bam_qc.nf"
include { bamPrep } from "./modules/bam_prep.nf"
include { fastqQC } from "./modules/fastq_qc.nf"
include { fastqPrep } from "./modules/fastq_prep.nf"
include { dnaAlignment } from "./modules/dna_alignment.nf"
include { variantDiscovery } from "./modules/variant_discovery.nf"
include { variantAnnotation } from "./modules/variant_annotation.nf"

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
        fastqPrep(
            fastqs
        )

        // perform qc on preped fastq files
        fastqQC(
            fastqPrep.out
        )

        // allign the reads onto the reference genome
        dnaAlignment(
            fastqPrep.out,
            genome_fasta_files,
            genome_bwa_files
        )

        // prep the raw bam files
        bamPrep(
            dnaAlignment.out,
            genome_fasta_files
        )

        // perform bam qc
        bamQC(
            dnaAlignment.out
        )

        // call germline variants
        variantDiscovery(
            bamPrep.out,
            genome_fasta_files,
            dbsnp
        )

        // annotate variants
        variantAnnotation(
            variantDiscovery.out,
            genome_fasta_files
        )
}
