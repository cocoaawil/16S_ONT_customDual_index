include './nbt/utils'

process run_mlst{
    
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_mlst_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleIds }
    
    input:
        tuple sampleIds, file(assemblys)
    
    
    output:
        tuple sampleIds, file("*.tsv")

    script:
    """
    mlst --threads ${task.cpus} *.fa > sum_mlst.tsv

    """
}