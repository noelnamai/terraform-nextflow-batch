// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow bamPrep {
    
    take:
        // bams: channel of [val(sample), path(bam), path(bai)]
        // genome_fasta_files: channel of [path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)]
        bams               
        genome_fasta_files
        
    main:
        // use samtools to split bam file by chromosome
        split_bam(
            bams,
            genome_fasta_files
        )
        
        // add read groups and sort bam
        add_read_groups(
            split_bam.out.transpose(),
            genome_fasta_files
        )
        
        // index bam files
        index_splitted_bam(
            add_read_groups.out
        )
    emit:
        index_splitted_bam.out
}

// use picard to split the bam file
process split_bam {
    
    cpus = 2
    memory = "15.GB"
    
    container "broadinstitute/gatk:4.1.3.0"
    
    input:
    tuple val(sample), path(bam), path(bai)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)
    
    output:
    tuple val(sample), path("${sample}_*.bam")
    
    script:
    """
    gatk --java-options "-Xmx4g" SplitSamByNumberOfReads \
    --INPUT ${bam} \
    --REFERENCE_SEQUENCE ${genome_fasta} \
    --SPLIT_TO_N_FILES 100 \
    --OUTPUT ./ \
    --OUT_PREFIX ${sample}
    """
}

// add read groups and sort bam using picard tools
process add_read_groups {

    cpus = 2
    memory = "15.GB"

    container "broadinstitute/gatk:4.1.3.0"
    
    input:
    tuple val(sample), path(bam)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)
    
    output:
    tuple val(sample), path("${bam.baseName}.grouped.sorted.bam")
    
    script:
    """
    gatk --java-options "-Xmx4g" AddOrReplaceReadGroups \
    --INPUT ${bam} \
    --REFERENCE_SEQUENCE ${genome_fasta} \
    --SORT_ORDER coordinate \
    --RGLB ${sample} \
    --RGPL illumina \
    --RGPU ${sample} \
    --RGSM ${sample} \
    --OUTPUT "${bam.baseName}.grouped.sorted.bam"
    """
}

// use samtools to index the split bam file
process index_splitted_bam {

    cpus = 2
    memory = "15.GB"

    container "noelnamai/samtools:1.15.1"

    input:
    tuple val(sample), file(bam)

    output: 
    tuple val(sample), path("${bam.baseName}.bam"), path("${bam.baseName}.bam.bai")

    script:
    """
    samtools index ${bam}
    """
}
