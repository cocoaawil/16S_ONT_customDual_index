include './nbt/utils'

process run_seqkit {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        //tuple sampleId, file(perfectindexfq), file(listname)
        tuple sampleId, file(perfectindexfq)

    output:
        tuple sampleId, file("passedQC_*.fastq")

    script:
    prefix=perfectindexfq.simpleName
    """
    seqkit seq ${prefix}.fastq -m 1350 -M 1650 -g > passedQC_${prefix}.fastq
    
    """
} //cat ${listname} | while read i; do
  //   seqkit seq perfindex_\${i} -m 1350 -M 1650 -g > passedQC_\${i}
  //done

process run_seqkitinfasta {

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/amr_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(lengthperffq)

    output:
        tuple sampleId, file("passedQC_*.fasta"), optional: true

    script:
    prefix=lengthperffq.simpleName
    """
    #printf "%s\\n" ${lengthperffq.join(' ')} | sed 's/ /\\n/g' >> filelist.txt && \\
    #sed 's/.fastq//' filelist.txt > getfilelist.txt && \\

    #cat getfilelist.txt | while read i; do
    #    seqkit fq2fa \${i}.fastq -o \${i}.fasta
    #done
    #if [ -s "${lengthperffq}" ] && grep -q '[^[:space:]]' "${lengthperffq}"; then
    if [[ -f "${lengthperffq}" && -s "${lengthperffq}" ]]; then
      seqkit fq2fa ${prefix}.fastq -o ${prefix}.fasta
    fi

    """

}
