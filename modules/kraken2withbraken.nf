include './nbt/utils'

process run_kraken2report {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(allqcfasta)

    output:
        tuple sampleId, file("*_report.txt")

    script:
    prefix=allqcfasta.simpleName
    """
    #for i in *.fasta
    #do
    #    filename=\$(basename "\$i")
    #    fname="\${filename%*.fasta}"
    #    kraken2 --db /nbt_main/share/pachyderm/amr/db/kraken_db/k2_standard_16gb_20240605 \
    #    --threads 32 \
    #    --use-names \
    #    --output \${fname}.kraken \
    #    --report \${fname}_report.txt --report-zero-counts \${fname}.fasta
    #done
    filename=\$(basename ${allqcfasta})
    fname="\${filename%*.fasta}"
    kraken2 --db /cu-share/sw/kraken_db/k2_standard_16gb_20240605 \
    --threads 32 \
    --use-names \
    --output \${fname}.kraken \
    --report \${fname}_report.txt \${fname}.fasta
    """
} //--report \${fname}_report.txt --report-zero-counts \${fname}.fasta

process run_braken {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(reportkraken)

    output:
        tuple sampleId, file("*_outreport_*.txt")

    script:
    
    """
    for i in *_report.txt
    do
     filename=\$(basename "\$i")
     fname="\${filename%_report.txt}"
     
     if grep -w 'S' <(awk '{print \$4}' \${fname}_report.txt) > /dev/null; then
        if [[ "${params.dbtaxonomy}" == *"ncbi_16s_18s"* || "${params.dbtaxonomy}" == *"gg2"* ]]; then
        bracken -d ${params.dbtaxonomy} -i \${fname}_report.txt -r 1000 -l S -o \${fname}_outreport_S.txt -t 1
        else
        bracken -d ${params.dbtaxonomy} -i \${fname}_report.txt -r 100 -l S -o \${fname}_outreport_S.txt -t 1
        fi
     else
        if [[ "${params.dbtaxonomy}" == *"ncbi_16s_18s"* || "${params.dbtaxonomy}" == *"gg2"* ]]; then
        level=\$(awk 'END {print \$4}' \${fname}_report.txt)
        bracken -d ${params.dbtaxonomy} -i \${fname}_report.txt -r 1000 -l \${level} -o \${fname}_outreport_\${level}.txt -t 1
        else
        level=\$(awk 'END {print \$4}' \${fname}_report.txt)
        bracken -d ${params.dbtaxonomy} -i \${fname}_report.txt -r 100 -l \${level} -o \${fname}_outreport_\${level}.txt -t 1
        fi
     fi
    done

    """
}

process getlisttaxabraken {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(reportbracken)

    output:
        tuple sampleId, file("result*.txt"), file("result*.xlsx")

    script:
    
    """
    printf "%s\\n" ${reportbracken.join(' ')} | sed 's/ /\\n/g' >> filelist.txt
    
    getresultex2_1usedModiaddPercentcleancode.sh filelist.txt > resultalltaxonAllsample.txt && \\
    pythonconvert.py resultalltaxonAllsample.txt resultalltaxonAllsample.xlsx

    getresultex2withTOPeachfile.sh filelist.txt > resultTOPtaxaAllsample.txt && \\
    pythonconvert.py resultTOPtaxaAllsample.txt resultTOPtaxaAllsample.xlsx
    
    """
}
