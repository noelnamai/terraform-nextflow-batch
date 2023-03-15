// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow dnaAlignment {
    
    take:
        // fastqs: channel of [val(sample), path(forward), path(reverse)]
        // genome_fasta_files: channel of [path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)]
        // genome_bwa_files: channel of [path(genome_fasta_amb), path(genome_fasta_ann), path(genome_fasta_bwt), path(genome_fasta_pac), path(genome_fasta_sa)]
        fastqs
        genome_fasta_files
        genome_bwa_files

    main:
        // allign the raw reads onto the reference genome
        align_reads(
            fastqs,
            genome_fasta_files,
            genome_bwa_files
        )
        
        // convert sam and sort the bam file
        sam2bam(
            align_reads.out
        )
        
        // index bam files
        index_bam(
            sam2bam.out
        )
        
    emit:
        index_bam.out
}

// read alignment using burrows-wheeler aligner mem algorithm
process align_reads {
    
    cpus = 8
    memory = "30.GB"
    
    container "noelnamai/bwa:0.7.12"

    input:
    tuple val(sample), path(forward), path(reverse)
    tuple path(genome_fasta_dict), path(genome_fasta), path(genome_fasta_fai)
    tuple path(genome_fasta_amb), path(genome_fasta_ann), path(genome_fasta_bwt), path(genome_fasta_pac), path(genome_fasta_sa)
    
    output:
    tuple val(sample), path("${sample}.sam")
    
    script:
    """
    bwa mem \
    -t ${task.cpus} \
    -M ${genome_fasta} ${forward} ${reverse} \
    > "${sample}.sam"
    """
}

// use samtools to convert sam to sorted bam file
process sam2bam {
    
    cpus = 2
    memory = "15.GB"
    
    container "noelnamai/samtools:1.15.1"
    
    input:
    tuple val(sample), file(sam)
    
    output:
    tuple val(sample), path("${sam.baseName}.sorted.bam")
    
    script:
    """
    samtools view \
    -b ${sam} \
    | samtools sort \
    --threads ${task.cpus} \
    -o "${sam.baseName}.sorted.bam"
    """
}

// use samtools to index the bam file
process index_bam {
    
    cpus = 2
    memory = "15.GB"
    
    container "noelnamai/samtools:1.15.1"
    publishDir path: "$params.results/$sample", mode: "copy"
    
    input:
    tuple val(sample), file(bam)
    
    output:
    tuple val(sample), path("${bam.baseName}.bam"), path("${bam.baseName}.bam.bai")
    
    script:
    """
    samtools index ${bam}
    """
}
