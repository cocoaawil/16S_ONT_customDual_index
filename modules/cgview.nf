include './nbt/utils'

process run_cgviewbuilder {

    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, path(prokka_result)


    output:
    path("${sampleId}_cgview.json")
    
    
    script:
    """
    ruby ${params.cgviewBuilder} --sequence ${sampleId}*.gbk --outfile ${sampleId}_cgview.json
    """

}