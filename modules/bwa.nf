include './nbt/utils'

process run_bwamem {

    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.sam"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)
    tuple sampleId2, file(read1), file(read2), file(long_read)


    output:
    tuple sampleId, file("${sampleId}.alignments_1.sam"), file("${sampleId}.alignments_2.sam")
    tuple sampleId, file(assembly)
    tuple sampleId, file(read1), file(read2), file(long_read)

    
    script:
    """

    bwa index ${assembly}
    bwa mem -t ${task.cpus} -a ${assembly} ${read1} > ${sampleId}.alignments_1.sam
    bwa mem -t ${task.cpus} -a ${assembly} ${read2} > ${sampleId}.alignments_2.sam
    echo \$(bwa 2>&1) | sed 's/^.* Version: //; s/ .*\$//' > bwa.version.txt
    
    """

}