// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow variant_annotation {

    take:
        // vcf: channel of [val(sample), val(vcf)]
        vcf

    main:
        // annotate variants
        annotate_variants(
            vcf
        )

    emit:
        annotate_variants.out
}

// annotate variants using vep
process annotate_variants {
    
    cpus = 4
    memory = "15.GB"
    
    container "noelnamai/vep:106"
    publishDir path: "$params.results/$sample", mode: "copy"
    
    input:
    tuple val(sample), path(vcf)
    
    output:
    tuple val(sample), path("${vcf.baseName}.annotated.vcf")
    
    script:
    """
    /ensembl-vep-release-106/vep \
    --database \
    -i ${vcf} \
    -o "${vcf.baseName}.annotated.vcf"
    """
}
