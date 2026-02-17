include './nbt/utils'

process run_seqsero2 {
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
    path("*_result.tsv")
    path("*_result.txt")
    path "versions.yml"


    script:
    //def args = task.ext.args ?: ''
    //def prefix = task.ext.prefix ?: "${meta.id}"
    """
    SeqSero2_package.py \
        -d ./ \
        -n ${sampleId} \
        -p ${task.cpus} \
        -m k \
        -t 4 \
        -i ${assembly}

    mv SeqSero_result.txt ${sampleId}_SeqSero_result.txt
    mv SeqSero_result.tsv ${sampleId}_SeqSero_result.tsv 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqsero2: \$( echo \$( SeqSero2_package.py --version 2>&1) | sed 's/^.*SeqSero2_package.py //' )
    END_VERSIONS
    """
}