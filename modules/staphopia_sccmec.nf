include './nbt/utils'

process run_sccmec {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleIds, file(assemblys)

    output:
        path("*.txt")

    script:
    """
     staphopia-sccmec \
        --assembly . \
        --ext fa > sum_sccmec.txt

    """

}