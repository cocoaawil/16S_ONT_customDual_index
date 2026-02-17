include './nbt/utils'

process run_medaka{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_medaka_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.{fa,fai}"
    publishDir "${params.output_assembly}/" , mode: "copy", pattern: "*.{fa,fai}"
    

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly), file(long_read)


    output:
    tuple sampleId, path("*.fa")
    tuple sampleId, path("*.bam"), path("*.bam.bai"), path("*.bed"), path("*.hdf"), path("*.fai")
    tuple sampleId, file(long_read)

    script:
    """
    medaka_consensus \
        -i ${long_read} \
        -d ${assembly} \
        -o ./ \
        -t ${task.cpus}

    mv ./*/calls_to_draft.bam ${sampleId}_calls_to_draft.bam
    mv ./*/calls_to_draft.bam.bai ${sampleId}_calls_to_draft.bam.bai
    mv ./*/consensus.fasta ${sampleId}.consensus.fa
    mv ./*/consensus.fasta.gaps_in_draft_coords.bed ${sampleId}_consensus.fasta.gaps_in_draft_coords.bed
    mv ./*/consensus_probs.hdf ${sampleId}_consensus_probs.hdf

    samtools faidx ${sampleId}.consensus.fa

    echo \$(medaka --version 2>&1) | sed -e 's/medaka //g' > medaka.version.txt
    """

}

process run_medaka_longfirst{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_medaka_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}", pattern: "*.fa"

    tag { sampleId }
    
    input:
    tuple sampleId, file(assembly)
    tuple sampleId, file(read1), file(read2), file(long_read)


    output:
    tuple sampleId, path("*.fa")
    tuple sampleId, path("*.bam"), path("*.bam.bai"), path("*.bed"), path("*.hdf")
    tuple sampleId, file(read1), file(read2), file(long_read)

    script:
    """
    medaka_consensus \
        -i ${long_read} \
        -d ${assembly} \
        -o ./ \
        -t ${task.cpus}

    mv ./calls_to_draft.bam ${sampleId}_calls_to_draft.bam
    mv ./calls_to_draft.bam.bai ${sampleId}_calls_to_draft.bam.bai
    mv ./consensus.fasta ${sampleId}_consensus.fa
    mv ./consensus.fasta.gaps_in_draft_coords.bed ${sampleId}_consensus.fasta.gaps_in_draft_coords.bed
    mv ./consensus_probs.hdf ${sampleId}_consensus_probs.hdf

    echo \$(medaka --version 2>&1) | sed -e 's/medaka //g' > medaka.version.txt
    """

}