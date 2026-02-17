include './nbt/utils'

process run_flye_ont{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.{fa,gfa,txt,gv,log,json}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(long_read)


    output:
    tuple sampleId, path("*.fa")
    tuple sampleId, path("*gfa"), path("*.txt"), path("*.gv"), path("*.log"), path("*.json")
    tuple sampleId, file(long_read)

    script:
    """
    flye --nano-raw ${long_read} \
        --out-dir ./ \
        --threads ${task.cpus}

    mv ./*.fasta ${sampleId}.fa
    mv ./*.gfa ${sampleId}_graph.gfa
    mv ./*.gv ${sampleId}_graph.gv
    mv ./*.txt ${sampleId}_asm_info.txt
    mv ./*.log ${sampleId}_flye.log
    mv ./*.json ${sampleId}_params.json
    """

}

process run_flye_ont_longfirst{
    // Process to run flye wiht long read input. Dedicate for input channel that contain shrot read. (sub process for hybrid assembly wiht long read first)
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(read1), file(read2), file(long_read)


    output:
    tuple sampleId, path("*.fa")
    tuple sampleId, path("*gfa"), path("*.txt"), path("*.gv"), path("*.log"), path("*.json")
    tuple sampleId, file(read1), file(read2), file(long_read)

    script:
    """
    flye --nano-raw ${long_read} \
        --out-dir ./ \
        --threads ${task.cpus}

    mv ./*.fasta ${sampleId}.fa
    mv ./*.gfa ${sampleId}_graph.gfa
    mv ./*.gv ${sampleId}_graph.gv
    mv ./*.txt ${sampleId}_asm_info.txt
    mv ./*.log ${sampleId}_flye.log
    mv ./*.json ${sampleId}_params.json
    """

}