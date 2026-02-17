include './nbt/utils'

process pgap_annotation{

    conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    errorStrategy 'ignore'

    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    
    input:
        tuple sampleId, path(yaml) 
    output:
        path("${sampleId}_results")

    script:
    """
    ./pgap.py -r -o ${sampleId}_results ${yaml}
    """

}