include './nbt/utils'

process run_minibar {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(trim_fastq), file(oligofile) 

    output:
        tuple sampleId, file("*.fastq")

    script:
    prefix=trim_fastq.simpleName
    """
    /home/jovyan/sw/python2/bin/python2.7 \${PATHMINIBAR_PARSE}/minibar.py -T -F ${oligofile} ${prefix}.fastq && \\
    rm -f *unk.fastq *Multiple_Matches.fastq

    """

}

process run_minibar_getperfectindex {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(alltrimfqindex) 

    output:
        //tuple sampleId, file("perfindex_*.fastq"), file("filelist.txt")
        tuple sampleId, file("perfindex_*.fastq")

    script:
    prefix=alltrimfqindex.simpleName
    """
    #printf "%s\\n" ${alltrimfqindex.join(' ')} | sed 's/ /\\n/g' >> filelist.txt
    #cat filelist.txt | while read fq; do
    #    /nbt_main/home/alisa/Softwaresw/rubyinstall/ruby-3.3.1/ruby /nbt_main/home/alisa/projectamr/bin/minibar_parse.1.rb \$fq > perfindex_\$fq
    #done
    ruby \${PATHMINIBAR_PARSE}/minibar_parse.1.rb ${prefix}.fastq > perfindex_${prefix}.fastq

    """

}
