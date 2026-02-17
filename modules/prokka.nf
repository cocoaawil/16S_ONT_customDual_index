include './nbt/utils'

process run_prokka{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_prokka_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)


    output:
    tuple sampleId, file("${sampleId}.gff")
    tuple sampleId, path("${sampleId}*")
    
    

    script:
    """
    prokka --outdir ./ \
        --locustag ${sampleId} \
        --prefix ${sampleId} \
        --kingdom ${params.prokka_kingdom} \
        --cpus $task.cpus \
        --force \
        ${assembly}

    echo \$(prokka --version 2>&1) | sed 's/^.*prokka //' > prokka.version.txt
    """
}