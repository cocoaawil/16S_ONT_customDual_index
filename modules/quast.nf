include './nbt/utils'

process run_quast{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly), file(long_read)


    output:
    path("*.tsv")
    path("*.pdf")
    path("*.html")
    

    script:
    """
    quast.py ${assembly} \
        --output-dir ./ \
        --threads $task.cpus

    mv report.tsv ${sampleId}_quast_report.tsv
    mv report.pdf ${sampleId}_quast_report.pdf
    mv report.html ${sampleId}_quast_report.html
    mv icarus.html ${sampleId}_icarus.html

    echo \$(quast.py --version 2>&1) | sed 's/^.*QUAST v//; s/ .*\$//' > quast.version.txt
    """

}

process run_quast_short{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)
    tuple sampleId2, file(read1), file(read2)


    output:
    path("*.tsv")
    path("*.pdf")
    path("*.html")
    

    script:
    """
    # quast.py ${assembly} \
    #    --pe1 ${read1} \
    #    --pe2 ${read2} \
    #    --output-dir ./ \
    #    --threads $task.cpus

    quast.py ${assembly} \
        --output-dir ./ \
        --threads $task.cpus

    mv report.tsv ${sampleId}_quast_report.tsv
    mv report.pdf ${sampleId}_quast_report.pdf
    mv report.html ${sampleId}_quast_report.html
    mv icarus.html ${sampleId}_icarus.html

    echo \$(quast.py --version 2>&1) | sed 's/^.*QUAST v//; s/ .*\$//' > quast.version.txt
    """

}

process run_quast_long{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)
    tuple sampleId2, file(long_read)


    output:
    path("*.tsv")
    path("*.pdf")
    path("*.html")
    

    script:
    """
    #quast.py ${assembly} \
    #    --single ${long_read} \
    #    --output-dir ./ \
    #    --threads $task.cpus
    
    quast.py ${assembly} \
        --output-dir ./ \
        --threads $task.cpus

    mv report.tsv ${sampleId}_quast_report.tsv
    mv report.pdf ${sampleId}_quast_report.pdf
    mv report.html ${sampleId}_quast_report.html
    mv icarus.html ${sampleId}_icarus.html

    echo \$(quast.py --version 2>&1) | sed 's/^.*QUAST v//; s/ .*\$//' > quast.version.txt
    """

}

process run_quast_hybrid{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)
    tuple sampleId2, file(read1), file(read2), file(long_read)


    output:
    path("*.tsv")
    path("*.pdf")
    path("*.html")
    

    script:
    """
    ## quast.py ${assembly} \
        ## --pe1 ${read1} \
        ## --pe2 ${read2} \
        ## --output-dir ./ \
        ## --threads $task.cpus

    quast.py ${assembly} \
        --output-dir ./ \
        --threads $task.cpus

    mv report.tsv ${sampleId}_quast_report.tsv
    mv report.pdf ${sampleId}_quast_report.pdf
    mv report.html ${sampleId}_quast_report.html
    mv icarus.html ${sampleId}_icarus.html

    echo \$(quast.py --version 2>&1) | sed 's/^.*QUAST v//; s/ .*\$//' > quast.version.txt
    """

}