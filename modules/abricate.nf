include './nbt/utils'

process Abricate_CARD {
    // abricate command use with CARD DB (The Comprehensive Antibiotic Resistance Database)
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, path('*.csv')
        path('abricate_version.txt')

    script:
    """
    abricate ${assembly} \
        --threads ${task.cpus} \
        --quiet \
        --csv \
        --db card > ${sampleId}_abricate_card.csv

    abricate --version > abricate_version.txt
    abricate --list | grep DATABASE >> abricate_version.txt
    abricate --list | grep card >> abricate_version.txt
    """
}

process Abricate_MEGARes {
    // abricate command use with MEGARes DB (MEGARes: an Antimicrobial Database for High-Throughput Sequencing)
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, path('*.csv')
        path('abricate_version.txt')

    script:
    """
    abricate ${assembly} \
        --threads ${task.cpus} \
        --quiet \
        --csv \
        --db megares > ${sampleId}_abricate_megares.csv

    abricate --version > abricate_version.txt
    abricate --list | grep DATABASE >> abricate_version.txt
    abricate --list | grep megares >> abricate_version.txt
    """
}

process Abricate_ResFinder {
    // abricate command use with resfinder DB (resistant gene DB)
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, path('*.csv')
        path('abricate_version.txt')

    script:
    """
    abricate ${assembly} \
        --threads ${task.cpus} \
        --quiet \
        --csv \
        --db resfinder > ${sampleId}_abricate_resfinder.csv

    abricate --version > abricate_version.txt
    abricate --list | grep DATABASE >> abricate_version.txt
    abricate --list | grep resfinder >> abricate_version.txt
    """
}

process Abricate_PlasmidFinder {
    // abricate command use with PlasmidFinder DB
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, path('*.csv')
        path('abricate_version.txt')

    script:
    """
    abricate ${assembly} \
        --threads ${task.cpus} \
        --quiet \
        --csv \
        --db plasmidfinder > ${sampleId}_abricate_plasmidfinder.csv

    abricate --version > abricate_version.txt
    abricate --list | grep DATABASE >> abricate_version.txt
    abricate --list | grep plasmidfinder >> abricate_version.txt

    """
}

process Abricate_VFDB {
    // abricate command use with VFDB DB (Virulence factors database)
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, path('*.csv')
        path('abricate_version.txt')

    script:
    """
    abricate ${assembly} \
        --threads ${task.cpus} \
        --quiet \
        --csv \
        --db vfdb > ${sampleId}_abricate_vfdb.csv

    abricate --version > abricate_version.txt
    abricate --list | grep DATABASE >> abricate_version.txt
    abricate --list | grep vfdb >> abricate_version.txt
    """
}

process Abricate_ecoli_vf {
    // abricate command use with Ecoli_VF DB (Escherichia coli virulence factors)
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, path('*.csv')
        path('abricate_version.txt')

    script:
    """
    abricate ${assembly} \
        --threads ${task.cpus} \
        --quiet \
        --csv \
        --db ecoli_vf > ${sampleId}_abricate_ecoli_vf.csv

    abricate --version > abricate_version.txt
    abricate --list | grep DATABASE >> abricate_version.txt
    abricate --list | grep ecoli_vf >> abricate_version.txt
    """
}

process Abricate_NCBI_AMRFinderPlus {
    // abricate command use with NCBI_AMRFinderPlus DB
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleId, file(assembly)

    output:
        tuple sampleId, path('*.csv')
        path('abricate_version.txt')

    script:
    """
    abricate ${assembly} \
        --threads ${task.cpus} \
        --quiet \
        --csv \
        --db ncbi > ${sampleId}_abricate_ncbi_amrfinderplus.csv

    abricate --version > abricate_version.txt
    abricate --list | grep DATABASE >> abricate_version.txt
    abricate --list | grep ncbi >> abricate_version.txt
    """
}

process Abricate_Summary {
    // abricate sum multiple result to one table
    
    // conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/abricate_env'
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }

    input:
        tuple sampleIds, file(abricate_results)

    output:
        tuple sampleIds, path('abricate_summary.csv')
        path('abricate_version.txt')
        path('abricate_concat.csv')

    script:
    """
    abricate --summary --csv ${abricate_results} > abricate_summary.csv
    awk -F "," 'NR==1 {print \$0} FNR!=1 {print \$0}' *.csv > abricate_concat.csv
    abricate --version > abricate_version.txt
    """
}





