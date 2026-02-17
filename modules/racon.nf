include './nbt/utils'

process run_racon_2round{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_racon_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.fa"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)
    tuple sampleId2, file(long_read)


    output:
    tuple sampleId, file("${sampleId}*.fa"), file(long_read)
    
    

    script:
    """
    minimap2 -t ${task.cpus} ${assembly} ${long_read} > ${sampleId}.minimap.racon.paf

    racon -t ${task.cpus} ${long_read} ${sampleId}.minimap.racon.paf ${assembly} > ${sampleId}_round1.fa

    minimap2 -t ${task.cpus} ${sampleId}_round1.fa ${long_read} > ${sampleId}.minimap.racon.round2.paf

    racon -t ${task.cpus} ${long_read} ${sampleId}.minimap.racon.round2.paf ${sampleId}_round1.fa > ${sampleId}.racon.concensus.fa

    """
}