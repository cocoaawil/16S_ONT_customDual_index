include './nbt/utils'

process GTDBTK_classify_wf {
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_gtdbtk_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleIds }

    input:
        tuple sampleIds, file(assemblys)

    output:
        tuple sampleIds, path('*.tsv')

    script:
        """
        gtdbtk classify_wf \
            --extension fasta \
            --extension fa \
            --genome_dir ./ \
            --out_dir ./ \
            --mash_db ./ \
            --cpus ${task.cpus}
        """

}