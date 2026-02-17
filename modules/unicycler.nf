include './nbt/utils'

process Shortread_assembly{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.{fa,fai,gfa}"
    publishDir "${params.output_assembly}/" , mode: "copy", pattern: "*.{fa,fai}"
 
    tag { sampleId }
    
    input:
    tuple sampleId, file(read1), file(read2)

    output:
    tuple sampleId, path("${sampleId}.scaffolds.fa")
    tuple sampleId, path("${sampleId}.scaffolds.fa.fai"), path("${sampleId}.assembly.gfa"), path("${sampleId}.unicycler.log"), path('*.version.txt')
    tuple sampleId, file(read1), file(read2)

    script:
    """
    unicycler \
        --threads ${task.cpus} \
        -1 ${read1} -2 ${read2} \
        -o ./

    mv assembly.fasta ${sampleId}.scaffolds.fa
    mv assembly.gfa ${sampleId}.assembly.gfa
    mv unicycler.log ${sampleId}.unicycler.log

    samtools faidx ${sampleId}.scaffolds.fa

    echo \$(unicycler --version 2>&1) | sed 's/^.*Unicycler v//; s/ .*\$//' > unicycler.version.txt
    """

}

process Hybrid_assembly{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.{fa,fai,gfa}"
    publishDir "${params.output_assembly}/" , mode: "copy", pattern: "*.{fa,fai}" 

    tag { sampleId }
    
    input:
    tuple sampleId, file(read1), file(read2), file(long_read)


    output:
    tuple sampleId, path("${sampleId}.scaffolds.fa")
    tuple sampleId, path("${sampleId}.scaffolds.fa.fai"), path("${sampleId}.assembly.gfa"), path("${sampleId}.unicycler.log"), path('*.version.txt')
    tuple sampleId, file(read1), file(read2), file(long_read)

    script:
    """
    unicycler \
        --threads ${task.cpus} \
        -1 ${read1} -2 ${read2} -l ${long_read} \
        --out ./

    mv assembly.fasta ${sampleId}.scaffolds.fa
    mv assembly.gfa ${sampleId}.assembly.gfa
    mv unicycler.log ${sampleId}.unicycler.log

    echo \$(unicycler --version 2>&1) | sed 's/^.*Unicycler v//; s/ .*\$//' > unicycler.version.txt

    samtools faidx ${sampleId}.scaffolds.fa

    """

}