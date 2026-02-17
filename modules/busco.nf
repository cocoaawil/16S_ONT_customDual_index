include './nbt/utils'

process run_busco {

    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly), path(db)


    output:
    path("short_summary.*.txt")
    path("short_summary.*.json")
    path("*-busco")
    
    
    script:
    """
    busco --cpu $task.cpus \
        --in ${assembly} \
        --out ${sampleId}-busco \
        -m genome \
        --auto-lineage-prok \
        --offline \
        --download_path ${db}

    #mv ${sampleId}-busco/batch_summary.txt ${sampleId}-busco.batch_summary.txt
    mv ${sampleId}-busco/short_summary.*.{json,txt} . || echo "Short summaries were not available: No genes were found."
    """

}


