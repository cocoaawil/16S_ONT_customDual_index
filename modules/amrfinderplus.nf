include './nbt/utils'

process run_amrfinderplus {
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    tuple sampleId, file(assembly), path(db)
    

    output:
    tuple sampleId, path("${sampleId}*.tsv")        
    path "versions.yml"                            
    //env VER                                       
    //env DBVER                                    

    when:
    task.ext.when == null || task.ext.when

    script:
    //def args = task.ext.args ?: ''
    //def is_compressed = fasta.getName().endsWith(".gz") ? true : false
    //prefix = task.ext.prefix ?: "${meta.id}"
    //organism_param = meta.containsKey("organism") ? "--organism ${meta.organism} --mutation_all ${prefix}-mutations.tsv" : ""
    //asta_name = fasta.getName().replace(".gz", "")
    //fasta_param = "-n"
    //if (meta.containsKey("is_proteins")) {
        //if (meta.is_proteins) {
            //fasta_param = "-p"
       //}
    //}
    """
    amrfinder -n ${assembly} \
        --database ${db} \
        --threads $task.cpus > ${sampleId}.tsv
    VER=\$(amrfinder --version)
    DBVER=\$(echo \$(amrfinder --database ${db} --database_version 2> stdout) | rev | cut -f 1 -d ' ' | rev)
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        amrfinderplus: \$(amrfinder --version)
        amrfinderplus-database: \$(echo \$(echo \$(amrfinder --database ${db} --database_version 2> stdout) | rev | cut -f 1 -d ' ' | rev))
    END_VERSIONS
    """
}