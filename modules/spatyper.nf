include './nbt/utils'

process run_spatyper {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, file("*.txt")

    script:
    """
     spaTyper \
        -f ${assembly} \
        -d ${params.spatypeDB} \
        --output ${sampleId}.tmp.res.txt
    edit_spatype_res.awk ${sampleId}.tmp.res.txt > ${sampleId}.spatype.txt
    rm ${sampleId}.tmp.res.txt
    """

}

process run_sum_spatype {
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleID, file(spa_results)

    output:
        file("*.txt")

    script:
    """
    awk 'NR==1 {print \$0} NR!=1&&FNR>1 {print \$0}' *.txt > sum_spatype_res.txt 
    """
}