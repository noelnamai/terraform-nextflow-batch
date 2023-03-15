// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow variantDiscovery {

    take:
        // bams: channel of [val(sample), path(bam), path(bai)]
        // genome_fasta_files: channel of [path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)]
        // dbsnp: channel of [path(dbsnp), path(dbsnp_vcf)]
        bams
        genome_fasta_files
        dbsnp

    main:
        // add read groups and sort bam
        call_variants(
            bams,
            genome_fasta_files,
            dbsnp
        )

        // filter variant calls
        filter_variants(
            call_variants.out,
            genome_fasta_files
        )

        // combine all the vcf files
        merge_vcfs(
            filter_variants.out
                .groupTuple(),
            genome_fasta_files
        )

        // sort vcf files by coordinate
        sort_vcf(
            merge_vcfs.out,
            genome_fasta_files
        )

    emit:
        sort_vcf.out
}

// call variants with haplotype caller
process call_variants {

    cpus = 2
    memory = "15.GB"

    container "broadinstitute/gatk:4.1.3.0"

    input:
    tuple val(sample), path(bam), path(bai)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)
    tuple path(dbsnp), path(dbsnp_idx)

    output:
    tuple val(sample), path("${bam.baseName}.haplotype.caller.vcf")

    script:
    """
    gatk --java-options "-Xmx4g" HaplotypeCaller \
    --input ${bam} \
    --reference ${genome_fasta} \
    --sequence-dictionary ${genome_fasta_dict} \
    --dbsnp ${dbsnp} \
    --output "${bam.baseName}.haplotype.caller.vcf"
    """	
}

// filter variant calls based on info and formart annotations
process filter_variants {

    cpus = 2
    memory = "5.GB"

    container "broadinstitute/gatk:4.1.3.0"

    input:
    tuple val(sample), path(vcf)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)

    output:
    tuple val(sample), path("${vcf.baseName}.filtered.vcf")

    script:
    """
    gatk --java-options "-Xmx4g" VariantFiltration \
    --variant ${vcf} \
    --reference ${genome_fasta} \
    --filter-name "filter" \
    --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
    --output "${vcf.baseName}.filtered.vcf"
    """
}

// combine all the vcf files into one final file
process merge_vcfs {

    cpus = 2
    memory = "15.GB"
    
    container "broadinstitute/gatk:4.1.3.0"

    input:
    tuple val(sample), path(vcfs)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)

    output:
    tuple val(sample), path("${sample}.haplotype.caller.filtered.merged.vcf")

    script:
    list=vcfs.join(" -I ")
    """
    gatk --java-options "-Xmx4g" MergeVcfs \
    --INPUT $list \
    --REFERENCE_SEQUENCE ${genome_fasta} \
    --SEQUENCE_DICTIONARY ${genome_fasta_dict} \
    --OUTPUT "${sample}.haplotype.caller.filtered.merged.vcf"
    """
}

// sort vcf files by contigs and then by coordinate
process sort_vcf {

    cpus = 2
    memory = "15.GB"

    container "broadinstitute/gatk:4.1.3.0"
    publishDir path: "$params.results/$sample", mode: "copy"

    input:
    tuple val(sample), path(vcf)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)

    output:
    tuple val(sample), path("${vcf.baseName}.sorted.vcf")

    script:
    """
    gatk --java-options "-Xmx4g" SortVcf \
    --INPUT ${vcf} \
    --REFERENCE_SEQUENCE ${genome_fasta} \
    --SEQUENCE_DICTIONARY ${genome_fasta_dict} \
    --OUTPUT "${vcf.baseName}.sorted.vcf"
    """
}
