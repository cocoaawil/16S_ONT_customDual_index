include './nbt/utils'

process run_checkM {

    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)
        //path checkM_database

    output:
        path("*.tsv")
        path("*.txt")

    script:
    """
    export CHECKM_DATA_PATH=${params.checkMDB}
    #export CHECKM_DATA_PATH=./checkMDB
    checkm lineage_wf -t ${task.cpus} \
        -f ${sampleId}.checkm.tsv \
        --tab_table \
        --pplacer_threads ${task.cpus} \
        -x fa \
        ./ \
        ./

    checkm | grep '...:::' | sed 's/.*CheckM v//;s/ .*//' > "checkM.version.txt"

    """

}