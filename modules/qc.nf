include './nbt/utils'

process shortreadtrimming{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'

    errorStrategy 'ignore'

    tag { sampleId }

    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"
    
    input:
        //tuple sampleId, file(fastq1), file(fastq2), file(long_read)
        tuple sampleId, file(fastq1), file(fastq2)

    output:
        tuple sampleId, file("${sampleId}_trim_1.fq.gz"), file("${sampleId}_trim_2.fq.gz")
        tuple sampleId, file("${sampleId}_fastp.html"), file("${sampleId}_fastp.json")

    script:
        """
        fastp --qualified_quality_phred 30 \
            --unqualified_percent_limit 20 \
            --length_required 36 \
            --cut_front --cut_front_window_size 1 --cut_front_mean_quality 3 \
            --cut_tail --cut_tail_window_size 1 --cut_tail_mean_quality 3 \
            --cut_right --cut_right_window_size 4 --cut_right_mean_quality 30 \
            --correction \
            --thread $task.cpus \
            --in1 ${fastq1} \
            --in2 ${fastq2} \
            --out1 ${sampleId}_trim_1.fq.gz \
            --out2 ${sampleId}_trim_2.fq.gz \
            -h ${sampleId}_fastp.html \
            -j ${sampleId}_fastp.json    
        """

}

process shortreadFastQC {
    
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'

    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    //tuple sampleId, file(fastq1), file(fastq2), file(long_read)
    tuple sampleId, file(fastq1), file(fastq2)

    output:
    tuple sampleId, file("${sampleId}*_fastqc.{html,zip,data.txt}")
    tuple sampleId, file("${sampleId}*.zip")

    script:
    """
    fastqc -t ${task.cpus} \
        -f fastq \
        -o . \
        ${fastq1} ${fastq2}

    for zipFile in ./*.zip; do
        unzip \$zipFile
        unzipped_dir=\${zipFile%.zip}
        signature=\$(basename \$unzipped_dir)
        mv \${unzipped_dir}/fastqc_data.txt \${signature}.data.txt
        rm -rf \$unzipped_dir
    done
    """
}
