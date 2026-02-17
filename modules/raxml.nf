include './nbt/utils'

process run_raxml{
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(sequence)


    output:
    tuple sampleId, file("RAxML*")
    
    

    script:
    """
    raxmlHPC-HYBRID-AVX2 -T ${task.cpus} -f a -m GTRGAMMAX -p 12345 -x 1234 -# 1000 -s ${sequence} -C -n phylo

    """
}