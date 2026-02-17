include './nbt/utils'

process run_nextstrain{
    errorStrategy 'ignore'

    tag { key }

    publishDir "${outputPrefixPath(params, task)}"
    //storeDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    input:
    tuple sampleIds, file(alignedDedupFasta)

    output:
    tuple file("*.nwk"), file("*.json")

    script:
    key=sampleIds.join("-")
    """
    ### Build tree with method iqtree 
    augur tree --alignment ${alignedDedupFasta} \
        --nthreads ${task.cpus} \
        --method ${params.nextstrain_method} \
        --output tree_${params.nextstrain_method}_raw.nwk

    ### Refine tree
    augur refine --tree tree_${params.nextstrain_method}_raw.nwk \
        --alignment ${alignedDedupFasta} \
        --metadata ${params.nextstrain_metadata} \
        --timetree \
        --root ${params.nextstrain_root} \
        --coalescent ${params.nextstrain_coalescent} \
        --output-tree tree_${params.nextstrain_method}.nwk \
        --output-node-data branch_lengths_${params.nextstrain_method}.json

    ### ancestral
    augur ancestral --tree tree_${params.nextstrain_method}.nwk \
        --alignment ${alignedDedupFasta} \
        --inference ${params.nextstrain_inference} \
        --output-node-data nt_muts.json

    ### traits
    augur traits --tree tree_${params.nextstrain_method}.nwk \
        --metadata ${params.nextstrain_metadata} \
        --columns ${params.nextstrain_columns} \
        --output-node-data traits.json

    ### export
    augur export v2 \
        --tree tree_${params.nextstrain_method}.nwk \
        --metadata ${params.nextstrain_metadata} \
        --node-data branch_lengths_${params.nextstrain_method}.json traits.json nt_muts.json  \
        --auspice-config ${params.auspice_config} \
        --lat-longs ${params.geo_info} \
        --output final_report_auspice.json
    """
}