nextflow.preview.dsl=2
/*
================================================================================
=                           Sinonkt Style I N I T                              =
================================================================================
*/
//

include './modules/nbt/utils'

if (params.exportKeySchema) exit 0, printKeySchema()
if (params.exportValueSchema) exit 0, printValueSchema()

params.MAINTAINERS = [
  'Worawich Phornsiricharoenphant (worawich.ph@gmail.com)'
]

def schema = readAvroSchema("${workflow.projectDir}/schemas/value.avsc")
__params = getDefaultThenResolveParams(schema, params)

include './modules/nbt/log' params(__params)
include helpMessage from './modules/nbt/help' params(__params)

if (params.version) exit 0, workflowVersionMessage()
if (params.help) exit 0, helpMessage(schema)

/*
================================================================================
=                   Sinonkt Style Workflows definitions                        =
================================================================================
*/

include { guppy_basecaller } from './modules/guppy' params(__params)
include { kraken2_classify; kraken2_classify_longread; kraken2_classify_contig; kraken2_taxon_filter; kraken2_sum_report    } from './modules/kraken2' params(__params)
//include { kraken2_classify_longread } from './modules/kraken2' params(__params)
//include { kraken2_classify_contig } from './modules/kraken2' params(__params)
//include { kraken2_taxon_filter } from './modules/kraken2' params(__params)
include { run_nanoplot  } from './modules/nanoplot' params(__params)
include { pgap_annotation } from './modules/pgap' params(__params)
include { run_porechop } from './modules/porechop' params(__params)
include { shortreadtrimming; shortreadFastQC } from './modules/qc.nf' params(__params)
include { Shortread_assembly; Hybrid_assembly } from './modules/unicycler.nf' params(__params)
include { run_checkM } from './modules/checkm' params(__params)
include { run_flye_ont; run_flye_ont_longfirst } from './modules/flye.nf' params(__params)
include { run_medaka; run_medaka_longfirst } from './modules/medaka.nf' params(__params)
include { run_quast; run_quast_short; run_quast_long; run_quast_hybrid } from './modules/quast.nf' params(__params)
include { run_prokka } from './modules/prokka.nf' params(__params)
include { Abricate_CARD; Abricate_ecoli_vf; Abricate_MEGARes; Abricate_NCBI_AMRFinderPlus; Abricate_PlasmidFinder; Abricate_ResFinder; Abricate_VFDB } from './modules/abricate.nf' params(__params)
include { Abricate_Summary as Abricate_Summary_card } from './modules/abricate.nf' params(__params)
include { Abricate_Summary as Abricate_Summary_ecoliVF } from './modules/abricate.nf' params(__params)
include { Abricate_Summary as Abricate_Summary_megares } from './modules/abricate.nf' params(__params)
include { Abricate_Summary as Abricate_Summary_amrfinderplus } from './modules/abricate.nf' params(__params)
include { Abricate_Summary as Abricate_Summary_plasmidfinder } from './modules/abricate.nf' params(__params)
include { Abricate_Summary as Abricate_Summary_resfinder } from './modules/abricate.nf' params(__params)
include { Abricate_Summary as Abricate_Summary_vfdb } from './modules/abricate.nf' params(__params)
include { GTDBTK_classify_wf } from './modules/gtdbtk.nf' params(__params)
include { run_roary } from './modules/roary.nf' params(__params)
include { run_spatyper } from './modules/spatyper.nf' params(__params)
include { run_sum_spatype } from './modules/spatyper.nf' params(__params)
include { run_sccmec } from './modules/staphopia_sccmec.nf' params(__params)
include { run_mlst } from './modules/mlst.nf' params(__params)
include { run_racon_2round } from './modules/racon.nf' params(__params)
include { run_raxml } from './modules/raxml.nf' params(__params)
include { run_busco } from './modules/busco.nf' params(__params)
include { run_amrfinderplus } from './modules/amrfinderplus.nf' params(__params)
include { run_seqsero2 } from './modules/seqsero2.nf' params(__params)
include { run_ssuissero } from './modules/ssuissero.nf' params(__params)
include { run_cgviewbuilder } from './modules/cgview.nf' params(__params)
include { run_dorado } from './modules/dorado.nf' params(__params)
include { run_bwamem } from './modules/bwa.nf' params(__params)
include { run_polca } from './modules/polca.nf' params(__params)
include { run_polypolish } from './modules/polypolish.nf' params(__params)
include { run_nextstrain } from './modules/nextstrain.nf' params(__params)
include { run_filtlong } from './modules/filtlong.nf' params(__params)
include { run_mobileElementFinder } from './modules/mefinder.nf' params(__params)
include { qualityfilter; singlereadFastQC; catallsample } from './modules/mergefq.nf' params(__params)
include { run_minibar; run_minibar_getperfectindex } from './modules/minibar.nf' params(__params)
include { run_seqkit; run_seqkitinfasta } from './modules/qcbylength.nf' params(__params)
include { run_kraken2report; run_braken; getlisttaxabraken } from './modules/kraken2withbraken.nf' params(__params)
include { run_iqtree } from './modules/iqtree.nf' params(__params)

workflow Mergefastq {
take:
    qc_fastqs
main:
    allfq = catallsample(qc_fastqs)    
emit:
    allfq
}

workflow Nanopore16SJunya {
take:
   mergefqdata
main:
  //mergefqdata.view()
  trim_n_fq = run_porechop(mergefqdata)
  oligodata = Channel.fromPath(params.indexnanofile)
      .map { file_path ->
      def filename_no_ext = file_path.getName().split("\\.")[0]
      return [ filename_no_ext, file_path ] }
      //oligodata.view()
      trimfq_oligo = trim_n_fq.merge(oligodata) { left, right -> [ *left, *right.tail() ] }
      //trimfq_oligo.view()
  qc_trimfq_ind = run_minibar(trimfq_oligo)
  //qc_trimfq_ind.view() 
  getind = qc_trimfq_ind
    .flatMap { sampleList, fqFiles -> //separate fqFiles from list to many tuple in [basename, file]
        fqFiles.collect { fqfile ->
            def name = fqfile.getBaseName() //getBaseName() get only name file
            tuple(name, fqfile) //get pattern in [name, path]
        }
    }
    .set { fq_split_channel } //set new channel in fq_split_channel and send fq_split_channel to the next process
  perfqc_trimfq_ind = run_minibar_getperfectindex(fq_split_channel)
  //perfqc_trimfq_ind.view()

  perfqc_valid_fqs = perfqc_trimfq_ind.filter { sampleID, fqfile -> fqfile.size() > 0 && fqfile.text.trim()}
  getlength_perfqc = run_seqkit(perfqc_valid_fqs)
  datainfasta_ind = run_seqkitinfasta(getlength_perfqc)
  getkrakenreport = run_kraken2report(datainfasta_ind)
  groupreportout = groupTupleWithoutCommonKey(getkrakenreport, false)
  reportbracken = run_braken(groupreportout)
  getlisttaxabraken(reportbracken)

}

workflow ShortreadAssembly {
  take:
    fastqs
  main:
    (fastqs_trim, trim_report) = shortreadtrimming(fastqs)
    shortreadFastQC(fastqs_trim)
    (classify_fq, unclassify_fq, kraken_report) = kraken2_classify(fastqs_trim)
    //classify_fq_ready = classify_fq.map{ [it.first(), it.last()[0], it.last()[1]] }
    (assembly, assembly_log, assembly_input) = Shortread_assembly(classify_fq)
    run_quast_short(assembly, assembly_input)
    (prokka_gff, prokka_result) = run_prokka(assembly)
    all_prokka_gff = groupTupleWithOutKey(prokka_gff).map{ [it.first().flatten(), it.last().flatten()] }

    if (__params.enableRoary == true){
      (pan_genome, core_gene_aln, other_output) = run_roary(all_prokka_gff)

      if (__params.enableRAXML == true){
        run_raxml(core_gene_aln)
      }
    }

    spa_res = run_spatyper(assembly)
    group_spa_res = groupTupleWithoutCommonKey(spa_res,false)
    //group_spa_res.view()
    run_sum_spatype(group_spa_res)

    group_assembly = groupTupleWithoutCommonKey(assembly,false)
    //group_assembly.view()
    //run_sccmec(group_assembly)
    run_mlst(group_assembly)

    busco_db = Channel.fromPath("${__params.busco_datasets}")
    assembly_busco = assembly.combine(busco_db)
    run_busco(assembly_busco)
    //run_busco(assembly)
    run_cgviewbuilder(prokka_result)

  emit:
    assembly
}

workflow LongreadAssembly {
  take:
    fastqs
  main:

    filt_l_fastq = run_filtlong(fastqs)
    trim_l_fastq = run_porechop(filt_l_fastq)
    (nanoplot_html,nanoplot_png,nanoplot_txt,nanoplot_log) = run_nanoplot(trim_l_fastq)
    (classify_l_fq, unclassify_l_fq, kraken_l_report) = kraken2_classify_longread(trim_l_fastq)
    
    
    (assembly, assembly_log, assembly_input) = run_flye_ont(classify_l_fq)

    //assembly.combine(classify_l_fq, by: 0)
    //assembly.view()
    assembly.view()
    racon_concensus = run_racon_2round(assembly, assembly_input)

    //racon_concensus.combine(classify_l_fq, by: 0)

    (polish_assembly, polish_log, polish_input) = run_medaka(racon_concensus)
    run_quast_long(polish_assembly, polish_input)
    
    (prokka_gff, prokka_result) = run_prokka(polish_assembly)
    all_prokka_gff = groupTupleWithOutKey(prokka_gff).map{ [it.first().flatten(), it.last().flatten()] }

    all_prokka_gff.view()
    aon = prokka_gff.collect()

    if (__params.enableRoary == true){
      (pan_genome, core_gene_aln, other_output) = run_roary(all_prokka_gff)

      if (__params.enableRAXML == true){
        run_raxml(core_gene_aln)
      }
    }
    

    run_spatyper(polish_assembly)
    //run_sccmec(polish_assembly)

    group_assembly = groupTupleWithoutCommonKey(polish_assembly,false)
    run_mlst(group_assembly)

    busco_db = Channel.fromPath("${__params.busco_datasets}")
    assembly_busco = assembly.combine(busco_db)
    run_busco(assembly_busco)
    //run_busco(polish_assembly)
    run_cgviewbuilder(prokka_result)

  emit:
    polish_assembly
}

workflow HybridAssembly {
  take:
    fastqs
  main:

    long_fastq = fastqs.map{[it.first(),it.last()]}
    short_fastq = fastqs.map{[it.first(),it[1],it[2]]}


    (fastqs_trim, trim_report) = shortreadtrimming(short_fastq)
    (fastqc_res,fastqc_zip) = shortreadFastQC(fastqs_trim)
    (classify_fq, unclassify_fq, kraken_report) = kraken2_classify(fastqs_trim)
    //classify_fq_ready = classify_fq.map{ [it.first(), it.last()[0], it.last()[1]] }

    filt_l_fastq = run_filtlong(long_fastq)
    trim_l_fastq = run_porechop(filt_l_fastq)
    //trim_l_fastq = run_porechop(long_fastq)
    (nanoplot_html,nanoplot_png,nanoplot_txt,nanoplot_log) = run_nanoplot(trim_l_fastq)
    (classify_l_fq, unclassify_l_fq, kraken_l_report) = kraken2_classify_longread(trim_l_fastq)
    
    all_fastq = classify_fq.join(classify_l_fq)
    all_fastq.view()
    (assembly, assembly_log, assembly_input) = Hybrid_assembly(all_fastq)
    run_quast_hybrid(assembly, assembly_input)

    (prokka_gff, prokka_result) = run_prokka(assembly)
    all_prokka_gff = groupTupleWithOutKey(prokka_gff).map{ [it.first().flatten(), it.last().flatten()] }

    if (__params.enableRoary == true){
      (pan_genome, core_gene_aln, other_output) = run_roary(all_prokka_gff)

      if (__params.enableRAXML == true){
        run_raxml(core_gene_aln)
      }
    }

    run_spatyper(assembly)
    //run_sccmec(assembly)

    group_assembly = groupTupleWithoutCommonKey(assembly,false)
    run_mlst(group_assembly)

    busco_db = Channel.fromPath("${__params.busco_datasets}")
    assembly_busco = assembly.combine(busco_db)
    run_busco(assembly_busco)
    //run_busco(assembly)
    run_cgviewbuilder(prokka_result)
  
  emit:
    assembly
}

workflow HybridAssemblyLong {
  take:
    fastqs
  main:

    long_fastq = fastqs.map{[it.first(),it.last()]}
    short_fastq = fastqs.map{[it.first(),it[1],it[2]]}


    (fastqs_trim, trim_report) = shortreadtrimming(short_fastq)
    (fastqc_res,fastqc_zip) = shortreadFastQC(fastqs_trim)
    (classify_fq, unclassify_fq, kraken_report) = kraken2_classify(fastqs_trim)
    //classify_fq_ready = classify_fq.map{ [it.first(), it.last()[0], it.last()[1]] }

    filt_l_fastq = run_filtlong(long_fastq)
    trim_l_fastq = run_porechop(filt_l_fastq)
    (nanoplot_html,nanoplot_png,nanoplot_txt,nanoplot_log) = run_nanoplot(trim_l_fastq)
    (classify_l_fq, unclassify_l_fq, kraken_l_report) = kraken2_classify_longread(trim_l_fastq)
    
    all_fastq = classify_fq.join(classify_l_fq)
    all_fastq.view()
    (assembly, assembly_log, assembly_input) = run_flye_ont_longfirst(all_fastq)

    (polish_assembly, polish_log, polish_input) = run_medaka_longfirst(assembly, assembly_input)
    (alignment_result, input_assembly, bwa_input ) = run_bwamem(polish_assembly, polish_input)

    (polypolish_assembly, original_input) = run_polypolish(alignment_result,input_assembly,bwa_input)

    (polca_polish_assembly, polca_input, polca_other) = run_polca(polypolish_assembly, original_input)

    run_quast_hybrid(polca_polish_assembly, polca_input)
    checkM_db = Channel.fromPath("${__params.checkMDB}")
    //run_checkM(polca_polish_assembly,checkM_db)
    run_checkM(polca_polish_assembly)

    (prokka_gff, prokka_result) = run_prokka(polca_polish_assembly)
    all_prokka_gff = groupTupleWithOutKey(prokka_gff).map{ [it.first().flatten(), it.last().flatten()] }

    if (__params.enableRoary == true){
      (pan_genome, core_gene_aln, other_output) = run_roary(all_prokka_gff)

      if (__params.enableRAXML == true){
        run_raxml(core_gene_aln)
      }
    }

    run_spatyper(polca_polish_assembly)
    //run_sccmec(assembly)

    group_assembly = groupTupleWithoutCommonKey(polca_polish_assembly,false)
    run_mlst(group_assembly)

    busco_db = Channel.fromPath("${__params.busco_datasets}")
    assembly_busco = assembly.combine(busco_db)
    run_busco(assembly_busco)
    //run_busco(polca_polish_assembly)
    run_cgviewbuilder(prokka_result)
  
  emit:
    polca_polish_assembly
}

workflow Phylogenetic {
  take:
    assembly
  main:
    (prokka_gff, prokka_result) = run_prokka(assembly)
    all_prokka_gff = groupTupleWithOutKey(prokka_gff).map{ [it.first().flatten(), it.last().flatten()] }

    (pan_genome, core_gene_aln, other_output) = run_roary(all_prokka_gff)

    run_raxml(core_gene_aln)
    run_iqtree(core_gene_aln)    
}

workflow PhylogeneticNextstrain {
  take:
    assembly
  main:
    (prokka_gff, prokka_result) = run_prokka(assembly)
    all_prokka_gff = groupTupleWithOutKey(prokka_gff).map{ [it.first().flatten(), it.last().flatten()] }

    (pan_genome, core_gene_aln, other_output) = run_roary(all_prokka_gff)

    run_raxml(core_gene_aln)
    run_iqtree(core_gene_aln)
    run_nextstrain(core_gene_aln) 
}

workflow PostAnalysis {
  take:
    assembly
  main:
    (classify_l_fq, unclassify_l_fq, kraken_l_report) = kraken2_classify_contig(assembly)
    all_kraken_l_report = groupTupleWithOutKey(kraken_l_report).map{ [it.first().flatten(), it[1].flatten(), it.last().flatten()] }
    kraken2_sum_report(all_kraken_l_report)

    (card_res, card_version) = Abricate_CARD(assembly)
    all_card_res = groupTupleWithOutKey(card_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary_card(all_card_res)

    (ecoli_vf_res, ecoli_vf_version) = Abricate_ecoli_vf(assembly)
    all_ecoli_vf_res = groupTupleWithOutKey(ecoli_vf_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary_ecoliVF(all_ecoli_vf_res)

    (megares_res, megares_version) = Abricate_MEGARes(assembly)
    all_megares_res = groupTupleWithOutKey(megares_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary_megares(all_megares_res)

    (amrfinder_res, amrfinder_version) = Abricate_NCBI_AMRFinderPlus(assembly)
    all_amrfinder_res = groupTupleWithOutKey(amrfinder_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary_amrfinderplus(all_amrfinder_res)

    (plasmidfinder_res, plasmidfinder_version) = Abricate_PlasmidFinder(assembly)
    all_plasmidfinder_res = groupTupleWithOutKey(plasmidfinder_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary_plasmidfinder(all_plasmidfinder_res)

    (resfinder_res, card_version) = Abricate_ResFinder(assembly)
    all_resfinder_res = groupTupleWithOutKey(resfinder_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary_resfinder(all_resfinder_res)

    (vfdb_res, vfdb_version) = Abricate_VFDB(assembly)
    all_vfdb_res = groupTupleWithOutKey(vfdb_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary_vfdb(all_vfdb_res)

    all_assembly = groupTupleWithOutKey(assembly).map{ [it.first().flatten(), it.last().flatten()] }
    GTDBTK_classify_wf(all_assembly)

    amrfinder_db = Channel.fromPath("${__params.amrfinderDB}")
    assembly_db =  assembly.combine(amrfinder_db)
    run_amrfinderplus(assembly_db)

    run_seqsero2(assembly)
    run_ssuissero(assembly)
    run_mobileElementFinder(assembly)

}

workflow Abricate_card {
  take:
    assembly
  main:
    (card_res, card_version) = Abricate_CARD(assembly)
    all_card_res = groupTupleWithOutKey(card_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary(all_card_res)
}

workflow Abricate_ecoliVF {
  take:
    assembly
  main:
    (ecoli_vf_res, ecoli_vf_version) = Abricate_ecoli_vf(assembly)
    all_ecoli_vf_res = groupTupleWithOutKey(ecoli_vf_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary(all_ecoli_vf_res)

}

workflow Abricate_megares {
  take:
    assembly
  main:
    (megares_res, megares_version) = Abricate_MEGARes(assembly)
    all_megares_res = groupTupleWithOutKey(megares_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary(all_megares_res)
}
workflow Abricate_amrfinderplus {
  take:
    assembly
  main:
    (amrfinder_res, amrfinder_version) = Abricate_NCBI_AMRFinderPlus(assembly)
    all_amrfinder_res = groupTupleWithOutKey(amrfinder_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary(all_amrfinder_res)
}
workflow Abricate_plasmidfinder {
  take:
    assembly
  main:
    (plasmidfinder_res, plasmidfinder_version) = Abricate_PlasmidFinder(assembly)
    all_plasmidfinder_res = groupTupleWithOutKey(plasmidfinder_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary(all_plasmidfinder_res)
}

workflow Abricate_resfinder {
  take:
    assembly
  main:
    (resfinder_res, card_version) = Abricate_ResFinder(assembly)
    all_resfinder_res = groupTupleWithOutKey(resfinder_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary(all_resfinder_res)
}

workflow Abricate_vfdb {
  take:
    assembly
  main:
    (vfdb_res, vfdb_version) = Abricate_VFDB(assembly)
    all_vfdb_res = groupTupleWithOutKey(vfdb_res).map{ [it.first().flatten(), it.last().flatten()] }
    Abricate_Summary(all_vfdb_res)
}






/*
================================================================================
=                           Sinonkt Style M A I N                              =
================================================================================
*/

workflow {

  sample_list = []
  sample_list_json = []
  if (__params.selectedSampleIds != null){
    myFile = file(__params.selectedSampleIds)
    all  = myFile.readLines()
    for( line in all ) {
      sample_list.add(line)
      //sample_list_json.add(__params.json + "/" + line + "_result_test.json")
    }
  }

  pod5_path_list = []
  if (__params.pod5folderlist != null){
    mypod5dirFile = file(__params.pod5folderlist)
    all_dir  = mypod5dirFile.readLines()
    for( pod5_dir in all_dir ) {
      pod5_path_list.add(pod5_dir)
    }
  }


  if(__params.selectedSampleIds != null){
    if(__params.mode == "pod5"){
      pod5_path = Channel.fromList(pod5_path_list)
      (bam, long_read) = run_dorado(pod5_path)


    }else if(__params.mode == "pod5_assembly"){
      pod5_path = Channel.fromList(pod5_path_list)
      (bam, long_read) = run_dorado(pod5_path)
      asm_res = LongreadAssembly(long_read)
      pos_res = PostAnalysis(asm_res)


    }else if(__params.mode == "shortRead"){
      pairs = Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq.gz")
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq"))
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq"))
          .map { [it.first(), *it.last()] }
          .filter {sample_list.contains(it.first())}
      
      asm_res = ShortreadAssembly(pairs)
      
      pos_res = PostAnalysis(asm_res)

    }else if(__params.mode == "longRead") {
      long_read = Channel.fromPath(("${__params.long_fastqs}/*.fq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq.gz"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
          .filter {sample_list.contains(it.first())}
      
      asm_res = LongreadAssembly(long_read)
      pos_res = PostAnalysis(asm_res)
      
    }else if(__params.mode == "hybrid"){

      pairs = Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq.gz")
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq"))
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq"))
          .map { [it.first(), *it.last()] }
          .filter {sample_list.contains(it.first())}

      long_read = Channel.fromPath(("${__params.long_fastqs}/*.fq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
          .filter {sample_list.contains(it.first())}

      all_input = pairs.join(long_read)

      //l_input = all_input.map{[it.first(),it.last()]}
      s_input = all_input.map{[it.first(),it[1],it[2]]}.view()

      //input = Channel.fromPath(${__params.inputCSV}).splitCsv(header: false, sep: ',')

      //input.view()

      asm_res = HybridAssembly(pairs.join(long_read))
      //asm_res = HybridAssembly(input)
      pos_res = PostAnalysis(asm_res)   
    }else if(__params.mode == "phylo"){
      sequence = Channel.fromPath(("${__params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
          .filter {sample_list.contains(it.first())}

      run_raxml(sequence)

    }else if(__params.mode == "taxo"){
      sequence = Channel.fromPath(("${params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
          .filter {sample_list.contains(it.first())}

      kraken2_classify_contig(sequence)
      all_assembly = groupTupleWithOutKey(sequence).map{ [it.first().flatten(), it.last().flatten()] }
      GTDBTK_classify_wf(all_assembly)

    }else if(__params.mode == "hybrid_long"){
      pairs = Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq.gz")
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq"))
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq"))
          .map { [it.first(), *it.last()] }

      long_read = Channel.fromPath(("${__params.long_fastqs}/*.fq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fq"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
          .filter {sample_list.contains(it.first())}

      all_input = pairs.join(long_read)
      asm_res = HybridAssemblyLong(pairs.join(long_read))
      pos_res = PostAnalysis(asm_res)
    
    }else if(__params.mode == "custom_phylo"){
      sequence = Channel.fromPath(("${__params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
          .filter {sample_list.contains(it.first())}
      
      Phylogenetic(sequence)
    }else if(__params.mode == "custom_phyloNextstrain"){
      sequence = Channel.fromPath(("${__params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
          .filter {sample_list.contains(it.first())}
      
      PhylogeneticNextstrain(sequence)
    }
  }else{
    if(__params.mode == "pod5"){
      pod5_path = Channel.fromList(pod5_path_list)
      pod5_path_tuples = pod5_path.map { 
        path -> def basename = path.tokenize('/')[-1] 
        tuple(basename, path)
      }
      //pod5_path = Channel.fromList(pod5_path_list)
        //.map { [(it.name =~ \/([^\/]+)$, it] }
      // pod5_path_tuples.view()
      (bam, long_read) = run_dorado(pod5_path_tuples)
      (filter_fastqs,repotqc) = qualityfilter(long_read)
      singlereadFastQC(filter_fastqs) 
      groupfastq = groupTupleWithoutCommonKey(filter_fastqs, false)
      //groupfastq.view()
     fqallmerge = Mergefastq(groupfastq)
     Nanopore16SJunya(fqallmerge)

    }else if(__params.mode == "pod5_assembly"){
      pod5_path = Channel.fromList(pod5_path_list)
      pod5_path_tuples = pod5_path.map { 
        path -> def basename = path.tokenize('/')[-1] 
        tuple(basename, path)
      }
      //pod5_path = Channel.fromList(pod5_path_list)
        //.map { [(it.name =~ \/([^\/]+)$, it] }
      pod5_path_tuples.view()
      (bam, long_read) = run_dorado(pod5_path_tuples)

      asm_res = LongreadAssembly(long_read)
      pos_res = PostAnalysis(asm_res)

    }else if(__params.mode == "shortRead"){
      pairs = Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq.gz")
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq"))
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq"))
          .map { [it.first(), *it.last()] }

      asm_res = ShortreadAssembly(pairs)
      pos_res = PostAnalysis(asm_res)

    }else if(__params.mode == "longRead"){
      long_read = Channel.fromPath(("${__params.long_fastqs}/*.fq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq.gz"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
      
      asm_res = LongreadAssembly(long_read)
      pos_res = PostAnalysis(asm_res)
      
    }else if(__params.mode == "hybrid"){
      pairs = Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq.gz")
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq"))
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq"))
          .map { [it.first(), *it.last()] }

      long_read = Channel.fromPath(("${__params.long_fastqs}/*.fq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }

      all_input = pairs.join(long_read)
      
      //data = file("${__params.inputCSV}")
      //input = Channel.from(parseCsv(data))
      //input.view()
      //input = Channel.fromPath("${__params.inputCSV}").splitCsv(header: false, sep: ',')
      //input = Channel.of(sample_csv_list)

      //input.view()

      //l_input = all_input.map{[it.first(),it.last()]}
      //s_input = all_input.map{[it.first(),it[1],it[2]]}.view()
      //input.view()
      asm_res = HybridAssembly(pairs.join(long_read))
      //asm_res = HybridAssembly(input)
      pos_res = PostAnalysis(asm_res)
      
    }else if(__params.mode == "phylo"){
      sequence = Channel.fromPath(("${__params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }

      run_raxml(sequence)

    }else if(__params.mode == "taxo"){
      sequence = Channel.fromPath(("${__params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }

      kraken2_classify_contig(sequence)
      all_assembly = groupTupleWithOutKey(sequence).map{ [it.first().flatten(), it.last().flatten()] }
      GTDBTK_classify_wf(all_assembly)

    }else if(__params.mode == "hybrid_long"){
      pairs = Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq.gz")
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_R{1,2}.fastq"))
          .mix(Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fq"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq.gz"),
              Channel.fromFilePairs("${__params.short_fastqs}/*_{1,2}.fastq"))
          .map { [it.first(), *it.last()] }

      long_read = Channel.fromPath(("${__params.long_fastqs}/*.fq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fastq.gz"))
          .mix(Channel.fromPath("${__params.long_fastqs}/*.fq"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }

      all_input = pairs.join(long_read)
      asm_res = HybridAssemblyLong(pairs.join(long_read))
      pos_res = PostAnalysis(asm_res)

    }else if(__params.mode == "custom_phylo"){
      sequence = Channel.fromPath(("${__params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
      
      Phylogenetic(sequence)
    }else if(__params.mode == "custom_phyloNextstrain"){
      sequence = Channel.fromPath(("${__params.sequence_fasta}/*.fa"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.aln"))
          .mix(Channel.fromPath("${__params.sequence_fasta}/*.fasta"))
          .map { [(it.name =~ /^([^.]+)/)[0][1], it] }
      
      PhylogeneticNextstrain(sequence)
    }
  }

  //pairs.join(long_read).view()
  //asm_res = ShortreadAssembly(pairs)

  //pairs.view()
  //long_read.view()


}

workflow.onComplete { handleCompleteMessage() }
workflow.onError { handleErrorMessage() }

  // you should see all parameters list in value avro schema + "exampleEnumPath" that've been autmatic resolved from exampleEnum.
  /*
  println(__params)
  fastas = Channel.fromPath("${__params.input}") ///tarafs/data/home/awilanth/awilanth/testPhyloflow/rawfastaMLphylo/All100include3outgroup.fasta
    .map { filePath -> [filePath.simpleName, filePath]}
    ^
  ####|##################################################################################################################
      |-- A little bit of message transformation that change from:
   [sample1, [/path/to/sample1_R1.fq.gz, /path/to/sample1_R2.fq.gz]]             2-Length Tuple (array) for each message.
      |
      to following by spread the last element
      |
      v
   [sample1, /path/to/sample1_R1.fq.gz, /path/to/sample1_R2.fq.gz]               3-Legth Array for each message.
  */
  //output = ExampleSubWorkflow(pairs)
  
  /*
  if (__params.inputtype == 'pedmap' && __params.sharedcaseoption == false) {
  datain = Channel.fromFilePairs("${__params.input}/*.{ped,map}")
    .map { [it.first(), *it.last() ]}
    .ifEmpty { error "No matching plink files in .ped/map" }
    
  datain.view()
  bedbimfam = ConvertMapPedToBedBimFam(datain)
  Getresultqcbedbimfam(bedbimfam)
  
  }
  else if (__params.inputtype == 'bedbimfam' && __params.sharedcaseoption == false) {
    datain = Channel.fromFilePairs("${__params.input}/*.{bed,bim,fam}", size:3)
    .map { [it.first(), *it.last() ]}
    .ifEmpty { error "No matching plink files in .bed/bim/fam" }

    //datain.view()
    bedbimfam = Getresultqcbedbimfam(datain)  
  }
  else if (__params.sharedcaseoption == true) {
    incase = Channel.value([__params.databasecase, file(__params.databasecaseBed), file(__params.databasecaseBim), file(__params.databasecaseFam)])
    .view()
    bedbimfam = Getresultqcbedbimfam(incase)
  }
  else{
    error "cannot find any plink files, please select inputtype in pedmap or bedbimfam with command --inputtype pedmap or --inputtype bedbimfam"
  }

  casedata = Channel.fromFilePairs("Getresultqcbedbimfam/Finalpredataremovedup/*.{bed,bim,fam,log}", size:4)
                .map { [it.first(), *it.last() ]}
  ctrldata = Channel.fromFilePairs("Getresultqcbedbimfam/Finalpredataremovedupctrl/*.{bed,bim,fam,log}", size:4)
                .map { [it.first(), *it.last() ]}

  if (__params.methodgwas == 'assocplink'){
  selectnodeipcaps = Channel.fromPath("Getresultqcbedbimfam/IPCAPs/node*.txt")
                .filter { nodefile ->
                // loads all lines in the file into memory, then counts
                long count = nodefile.readLines().size()
                if (count <= 20) println ">>> WARNING: file ${nodefile} does not have enough lines and will not be included"
                count > 20
                }
  //selectnodeipcaps.view()
  caseconvert = GWASrunanalysiscase(casedata, selectnodeipcaps)
  //caseconvert.view()
  checkcasesam = groupTupleWithoutCommonKey(caseconvert,true)
  ctrlconvert = GWASrunanalysisctrl(ctrldata, selectnodeipcaps)
  checkctrlsam = groupTupleWithoutCommonKey(ctrlconvert,true)
  
  ResultGWASassocplink(checkcasesam,checkctrlsam)
  }
  else if (__params.methodgwas == 'fastlmm'){
    Runfastlmmforall(casedata, ctrldata)
  }
}

workflow.onComplete { handleCompleteMessage() }
workflow.onError { handleErrorMessage() } */

//How to run this nextflow
//nfrun ../nxf-spapaH/main.nf --inputtype pedmap --databasectrl nhes_unimpute_build38_test  --r2Threshold 0.04 --ipcapsrun --pcarun --admixrun
//nfrun ../nxf-spapaH/main.nf --inputtype pedmap --databasectrl nhes_unimpute_build38_test  --r2Threshold 0.04 --ipcapsrun --pcarun --admixrun --methodgwas fastlmm -resume
//nfrun ../nxf-spapaH/main.nf --inputtype pedmap --databasectrl nhes_unimpute_build38_test  --r2Threshold 0.04 --ipcapsrun --pcarun --admixrun --methodgwas assocplink -resume

//script for user who select shared case database (local database)
//nfrun ../nxf-spapaH/main.nf --sharedcaseoption --databasecase ckd_unimpute_build38_test --databasectrl nhes_unimpute_build38_test --r2Threshold 0.04 --ipcapsrun
//nfrun ../nxf-spapaH/main.nf --sharedcaseoption --databasecase ckd_unimpute_build38_test --databasectrl nhes_unimpute_build38_test --r2Threshold 0.04 --ipcapsrun --methodgwas assocplink -resume
