include './nbt/utils'

process run_porechop {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(longread_fastq) 

    output:
        tuple sampleId, file("${prefix}_trimmed.fastq*")

    script:
    prefix=longread_fastq.simpleName
    """
    if [[ ${params.method} == "nano16SJunya" ]]; then
        porechop -i "${longread_fastq}" -t "${task.cpus}" --format fastq -o ${prefix}_trimmed.fastq --extra_end_trim -1
    else
        porechop -i "${longread_fastq}" -t "${task.cpus}" --format fastq.gz -o ${sampleId}_trimmed.fastq.gz
    fi
    """

}