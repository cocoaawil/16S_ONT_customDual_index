include './nbt/utils'

process run_nanoplot {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}/$sampleId"
    publishDir "${s3OutputPrefixPath(params, task)}/$sampleId"

    tag { sampleId }

    input:
        tuple sampleId, file(longread_fastq) 

    output:
        path("*.html")
        path("*.txt")
        path("*.log")

    script:
    """
     NanoPlot \
        -t $task.cpus \
        --fastq ${longread_fastq}
    """

}