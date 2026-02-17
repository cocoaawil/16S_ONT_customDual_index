include './nbt/utils'

process run_mobileElementFinder{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_medaka_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)


    output:
    tuple sampleId, path("*.fna"), path("*.txt"), path("*.csv")

    script:
    """
    mefinder find --temp-dir . --contig ${assembly} ${sampleId}
    """

}