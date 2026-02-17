include './nbt/utils'

process run_iqtree {
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(sequence)


    output:
    tuple sampleId, file("*.treefile")
    
    

    script:
    """
    iqtree2 -s ${sequence} -B 1000 -T AUTO --prefix iqtree
    iqtree2 --version >> iqtree_version.txt
    """
}