// enable dsl2 
nextflow.enable.dsl=2

// define main workflow
workflow fastqPrep {
    
    take:
        // fastqs: channel of [val(sample), path(forward), path(reverse)]
        fastqs
        
    main:
        // downsample fastq files
        input_fastqs = params.downsample ?
            fastqs = sample_fastqs(
                fastqs
            )
            : fastqs

        // trim adapters on each fastq file
        trim_adapters(
            input_fastqs
        )
    
    emit:
        trim_adapters.out
}

// downsample fastq files
process sample_fastqs {

    cpus = 2
    memory = "15.GB"
    
    storeDir params.storedir
    container "noelnamai/seqtk:1.3"
    
    input:
    tuple val(sample), path(forward), path(reverse)
    
    output:
    tuple val(sample), path("${forward.baseName}.sampled.fastq"), path("${reverse.baseName}.sampled.fastq")
    
    script:
    """
    seqtk sample -s 100 ${forward} 0.01 > ${forward.baseName}.sampled.fastq
    seqtk sample -s 100 ${reverse} 0.01 > ${reverse.baseName}.sampled.fastq
    """
}

// trimmomatic process to trim adapters
process trim_adapters {
    
    cpus = 2
    memory = "15.GB"
    
    container "noelnamai/trimmomatic:0.39"
    
    input:
    tuple val(sample), path(forward), path(reverse)
    
    output:
    tuple val(sample), path("${forward.baseName}.trimmed.paired.fastq"), path("${reverse.baseName}.trimmed.paired.fastq")
    
    script:
    """
    java -Xmx4g -jar /opt/trimmomatic-0.39.jar PE \
    -phred33 \
    ${forward} ${reverse} \
    ${forward.baseName}.trimmed.paired.fastq ${forward.baseName}.trimmed.unpaired.fastq \
    ${reverse.baseName}.trimmed.paired.fastq ${reverse.baseName}.trimmed.unpaired.fastq \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
    LEADING:3 \
    TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36
    """
}
