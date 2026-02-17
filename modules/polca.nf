include './nbt/utils'

process run_polca {

    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.{fa,fai}"
    publishDir "${params.output_assembly}/" , mode: "copy", pattern: "*.{fa,fai}"

    tag { sampleId }

    input:
    tuple sampleId, file(assembly)
    tuple sampleId2, file(read1), file(read2), file(long_read)

    output:
    tuple sampleId, file("${sampleId}.polca.polished.fa")
    tuple sampleId, file(read1), file(read2), file(long_read)
    file("${sampleId}.polca.polished.fa.fai")

    script:

    """

    polca.sh -a ${assembly} -r '${read1} ${read2}' -t ${task.cpus} -m 64G
    mv *.PolcaCorrected.fa ${sampleId}.polca.polished.fa
    echo \$(masurca --version 2>&1) | sed 's/^.* version //' > polca.version.txt

    samtools faidx ${sampleId}.polca.polished.fa

    """
}