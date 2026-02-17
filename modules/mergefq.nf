include './nbt/utils'

process qualityfilter{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'

    errorStrategy 'ignore'

    tag { sampleId }

    publishDir "${outputPrefixPath(params, task)}"
    //publishDir "${s3OutputPrefixPath(params, task)}"
    
    input:
        //tuple sampleId, file(fastq1), file(fastq2), file(long_read)
        tuple sampleId, file(fastqz)

    output:
        tuple sampleId, file("filter*.gz")
        tuple sampleId, file("*_fastp.html"), file("*_fastp.json")

    script:
        prefix=fastqz.simpleName 
    """
    fastplong --qualified_quality_phred ${params.qscore} \
    --unqualified_percent_limit 40 \
    -i ${fastqz} \
    -o filter${fastqz} \
    -h filter${prefix}_fastp.html \
    -j filter${prefix}_fastp.json

    """

}

process singlereadFastQC {
    
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'

    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    //tuple sampleId, file(fastq1), file(fastq2), file(long_read)
    tuple sampleId, file(trimfastqs)

    output:
    tuple sampleId, file("*_fastqc.{html,zip,data.txt}")
    tuple sampleId, file("*.zip")

    script:
    """
    fastqc -t ${task.cpus} \
        -f fastq \
        -o . \
        ${trimfastqs}

    for zipFile in ./*.zip; do
        unzip \$zipFile
        unzipped_dir=\${zipFile%.zip}
        signature=\$(basename \$unzipped_dir)
        mv \${unzipped_dir}/fastqc_data.txt \${signature}.data.txt
        rm -rf \$unzipped_dir
    done
    """
}

process catallsample{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'

    errorStrategy 'ignore'

    tag { sampleId }

    publishDir "${outputPrefixPath(params, task)}"
    //publishDir "${s3OutputPrefixPath(params, task)}"
    
    input:
        //tuple sampleId, file(fastq1), file(fastq2), file(long_read)
        tuple sampleId, file(qcfastqz)

    output:
        tuple sampleId, file("allmergedrun.fastq.gz")

    script:
       
        """
        cat ${qcfastqz.join(' ')} > allmergedrun.fastq.gz

        """

}
