// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow variantAnnotation {

    take:
        // vcf: channel of [val(sample), val(vcf)]
        // genome_fasta_files: channel of [path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)]
        vcf
        genome_fasta_files

    main:
        // annotate variants
        annotate_variants(
            vcf,
            genome_fasta_files
        )

    emit:
        annotate_variants.out
}

// annotate variants using gatk funcotator
process annotate_variants {
    
    cpus = 2
    memory = "15.GB"
    
    container "broadinstitute/gatk:4.1.3.0"
    publishDir path: "$params.results/$sample", mode: "copy"
    
    input:
    tuple val(sample), path(vcf)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)
    
    output:
    tuple val(sample), path("${vcf.baseName}.annotated.vcf")
    
    script:
    """
    gatk --java-options "-Xmx4g" FuncotatorDataSourceDownloader \
    --germline true \
    --validate-integrity true \
    --extract-after-download true

    gatk --java-options "-Xmx4g" Funcotator \
    --variant ${vcf} \
    --reference ${genome_fasta} \
    --ref-version hg38 \
    --data-sources-path funcotator_dataSources.v1.6.20190124g \
    --output-file-format VCF \
    --output "${vcf.baseName}.annotated.vcf"
    """
}
