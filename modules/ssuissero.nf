include './nbt/utils'

process run_ssuissero {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/ssuissero_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, file("*.tsv")

    script:
    """

        SsuisSero.sh -i ${assembly} \
            -o . \
            -s ${sampleId} \
            -x fasta \
            -t ${task.cpus}

    """

}
