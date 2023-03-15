// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow fastqQC {
    
    take:
        // fastqs: channel of [val(sample), path(forward), path(reverse)]
        fastqs
        
    main:
        // perform qc on each fastq file
        fastqc(
            fastqs
                .map{ it -> [it[0], [it[1], it[2]]]}
                .transpose()
        )
        
        emit:
            fastqc.out
}

// perform qc check on raw sequence fastq files
process fastqc {
    
    cpus = 2
    memory = "15.GB"
    
    container "noelnamai/fastqc:0.11.9"
    publishDir path: "$params.results/$sample", mode: "copy"
    
    input:
    tuple val(sample), path(fastq)
    
    output:
    tuple val(sample), path("*.html")
    
    script:
    """
    /usr/bin/fastqc ${fastq} \
    --noextract \
    --threads ${task.cpus}
    """
} 
