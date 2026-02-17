include './nbt/utils'

process run_filtlong {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(longread_fastq) 

    output:
        tuple sampleId, file("${sampleId}_filtlong.fastq.gz")

    script:
     """
    filtlong \
        --min_length 500 --keep_percent 95 --target_bases 500000000 \
        ${longread_fastq} | gzip > ${sampleId}_filtlong.fastq.gz

    filtlong --version | sed -e "s/Filtlong //g" > filtlong.version.txt
    """

}



