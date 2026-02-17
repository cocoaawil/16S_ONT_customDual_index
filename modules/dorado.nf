include './nbt/utils'

process run_dorado {
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { pod5_path }

    input:
        tuple sampleIds, path(pod5_path)

    output:
        tuple sampleIds, path('*.bam')
        tuple sampleIds, path('*.fq.gz')


    script:
    """
    echo ${pod5_path}
    #\${DORADO_BIN}/dorado basecaller --trim all --device cuda:all ${params.model} ${pod5_path} > ${sampleIds}.bam
    \${DORADO_BIN}/dorado basecaller ${params.model} ${pod5_path} > ${sampleIds}.bam
    #mv calls*.bam ${sampleIds}.bam

    #samtools fastq --threads $task.cpus -s ${sampleIds}.fq.gz ${sampleIds}.bam

    picard SamToFastq -I ${sampleIds}.bam -F ${sampleIds}.fq

    gzip ${sampleIds}.fq

    """
    //--models-directory ${params.doradoModelPath}

}
