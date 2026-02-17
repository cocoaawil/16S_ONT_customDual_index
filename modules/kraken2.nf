include './nbt/utils'

process kraken2_prepare_db{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    path db_zip

    output:
    tuple val("${db.simpleName}"), path("database")

    script:
    """
    mkdir db_tmp
    tar -xf "${db_zip}" -C db_tmp
    mkdir database
    mv `find db_tmp/ -name "*.k2d"` database/
    """    
}

process kraken2_classify{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    tuple sampleId, file(fastq1), file(fastq2)

    output:
    tuple sampleId, file("${sampleId}_classified_1.fastq.gz"), file("${sampleId}_classified_2.fastq.gz")
    tuple sampleId, file("*unclassified*")
    tuple sampleId, file("*report.txt"), file("*raw.kraken2.log")  


    script:
    """
    kraken2 \
        --db ${params.krakenDB} \
        --threads ${task.cpus} \
        --unclassified-out ${sampleId}_unclassified#.fastq \
        --classified-out ${sampleId}_classified#.fastq \
        --report ${sampleId}.kraken2.report.txt \
        --gzip-compressed \
        --paired \
        ${fastq1} ${fastq2}

    pigz -p ${task.cpus} *.fastq
    cp .command.log ${sampleId}.raw.kraken2.log
    """
}

process kraken2_classify_longread{
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    tuple sampleId, file(long_fastq)

    output:
    tuple sampleId, file("*_classified*")
    tuple sampleId, file("*_unclassified*")
    tuple sampleId, file("*report.txt"), file("*raw.kraken2.log")  


    script:
    """
    input=${long_fastq}
    if [[ ${long_fastq} != *.gz ]]; then
        pigz -p ${task.cpus} ${long_fastq}
        input=${long_fastq}.gz
    fi


    kraken2 \
        --db ${params.krakenDB} \
        --threads ${task.cpus} \
        --unclassified-out ${sampleId}_unclassified.fastq \
        --classified-out ${sampleId}_classified.fastq \
        --report ${sampleId}.kraken2.report.txt \
        --gzip-compressed \
        \${input}

    pigz -p ${task.cpus} *.fastq
    cp .command.log ${sampleId}.raw.kraken2.log
    """
}

process kraken2_classify_contig{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    tuple sampleId, file(contig)

    output:
    tuple sampleId, file("*_classified*")
    tuple sampleId, file("*_unclassified*")
    tuple sampleId, file("*report.txt"), file("*raw.kraken2.log")  


    script:
    """
    kraken2 \
        --db ${params.krakenDB} \
        --threads ${task.cpus} \
        --unclassified-out ${sampleId}_unclassified.fastq \
        --classified-out ${sampleId}_classified.fastq \
        --report ${sampleId}.kraken2.report.txt \
        ${contig}

    pigz -p ${task.cpus} *.fastq
    cp .command.log ${sampleId}.raw.kraken2.log
    """
}

process kraken2_taxon_filter{
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    tuple sampleId, file(fastq1), file(fastq2)
    tuple sampleId, file(kraken_report), file(kraken_raw_res) 

    output:
    tuple sampleId, file("${sampleId}_filtered_1.fastq"), file("${sampleId}_filtered_2.fastq")
    
    script:
    """
        extract_kraken_reads.py -k ${kraken_raw_res} \
            -1 S19.classified_1.fastq \
            -2 S19.classified_2.fastq \
            -o ${sampleId}_filtered_1.fastq \
            -o2 ${sampleId}_filtered_2.fastq \
            -t ${params.taxonID}
    """
}

process kraken2_sum_report {
    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    errorStrategy 'ignore'

    //storeDir "${params.outputNGS}/${workflowName(task)}/${processName(task)}"
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
    tuple sampleId, file(kraken_report), file(kraken_raw_res) 

    output:
    file("combine_kraken2_report.txt")

    script:
    """
        #report_list=""
        #for report in ${kraken_report}
        #do
        #    report_list="\${report_list} \${report}"
        #done

        report="${kraken_report}"
        report_list=\$(echo \$dummy | cut -d "[" -f2 | cut -d "]" -f1 | sed 's/,//g')

        dummy="${sampleId}"
        #samplenames_list=\$(echo \$dummy | cut -d "[" -f2 | cut -d "]" -f1 | awk -F "," '{print \$0}')
        samplenames_list=\$(echo \$dummy | cut -d "[" -f2 | cut -d "]" -f1 | sed 's/,//g')

        combine_kreports.py -r ${kraken_report} \
            --sample-names \$samplenames_list \
            -o combine_kraken2_report.txt
    """
}