include './nbt/utils'

process guppy_basecaller{
    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    tuple sampleId, file(fast5_path)

    output:
    file("*.fastq*")

    script:
    caller_thread = ${task.cpus}/${params.guppyNumCaller}
    """
    guppy_basecaller --input_path ${fast5_path} \
        --save_path . \
        --flowcell ${params.flowcellID} \
        --kit ${parmas.ontKit} \
        --num_callers ${params.guppyNumCaller} \
        --cpu_threads_per_caller ${caller_thread}

    """    
}