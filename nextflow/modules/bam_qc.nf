// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow bamQC {
    
    take:
        // bams: channel of [val(sample), path(bam), path(bai)]
        bams
    
    main:
        // generate summary mapping statistics
        mapping_stats(
            bams
        )
        
    emit:
        mapping_stats.out
}

// use samtools to generate summary mapping statistics
process mapping_stats {
    
    cpus = 2
    memory = "15.GB"
    
    container "noelnamai/samtools:1.15.1"
    publishDir path: "$params.results/$sample", mode: "copy"
    
    input:
    tuple val(sample), path(bam), path(bai)
    
    output:
    tuple val(sample), path("${sample}.mapping.statistic.txt")
    
    script:
    """
    samtools flagstat ${bam} > "${sample}.mapping.statistic.txt"
    """
}
