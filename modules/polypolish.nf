include './nbt/utils'

process run_polypolish {

    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.polypolish.polished.fasta"
    //publishDir "${params.output_assembly}" , mode: "copy", pattern: "*.polypolish.polished.fasta" 

    tag { sampleId }

    input:
    tuple sampleId, file(sam1), file(sam2)
    tuple sampleId2, file(assembly)
    tuple sampleId3, file(read1), file(read2), file(long_read)

    output:
    tuple sampleId, file("${sampleId}.polypolish.polished.fasta")
    tuple sampleId, file(read1), file(read2), file(long_read)

    script:

    """
    polypolish filter --in1 ${sam1} --in2 ${sam2} --out1 filtered_1.sam --out2 filtered_2.sam
    polypolish polish ${assembly} filtered_1.sam filtered_2.sam | sed 's/_polypolish//g' > ${sampleId}.polypolish.polished.fasta
    polypolish --version | cut -f2 -d" " > polypolish.version.txt
    """
}