import os
import glob
from pathlib import Path
import snakemake
import gzip

workdir: config['workdir']
host = config['host']
db_path = config['db_path']
get_fastp_report_sh = "/ddnstor/imau_sunzhihong/mnt1/script/klab_script/get_fastp_report.sh"
get_rmhost_report_sh = "/ddnstor/imau_sunzhihong/mnt1/script/klab_script/get_rmhost_report.sh"
get_final_report_sh = "/ddnstor/imau_sunzhihong/mnt1/script/klab_script/get_final_report.sh"


sample_list = {}
with open(config['file_names_txt'],'r') as f:
    for line in f:
        items = line.strip().split("\t")
        sample_list[items[0]] = items[1:]

# print(sample_list)

sample_id = list(sample_list.keys())

rule all:
    input:
        expand("clean_data.files/{sample}.clean.r{format}.fq.gz", sample = sample_id, format = [1,2]),
        "QC_report.tsv"

rule run_fastp:
    input: 
        lambda wildcards: sample_list[wildcards.sample][0],
        lambda wildcards: sample_list[wildcards.sample][1]
    output:
        temp("clean_data_info/{sample}/{sample}.qc.r1.fq.gz"),
        temp("clean_data_info/{sample}/{sample}.qc.r2.fq.gz"),
        "clean_data_info/{sample}/{sample}.josn",
        "clean_data_info/{sample}/{sample}.html",
        "clean_data_info/{sample}/{sample}.fastp.err",
        "clean_data_info/{sample}/{sample}.fastp.log"
    # params:
    #     err = "clean_data/{sample}/{sample}.fastp.log",
    #     log = "clean_data/{sample}/{sample}.fastp.err"
    threads: 15
    shell:
        """
        fastp -q 20 -u 30 -n 5 -y -Y 30 -l 90 -w {threads} --trim_poly_g -i {input[0]} -I {input[1]} -o {output[0]} -O {output[1]} -j {output[2]} -h {output[3]} 1>{output[4]} 2>{output[5]}
        """


rule run_bowtie2:
    input:
        rules.run_fastp.output
    output: 
        "clean_data_info/{sample}/{sample}.clean.r1.fq.gz",
        "clean_data_info/{sample}/{sample}.clean.r2.fq.gz"
    params:
        host_db = db_path,
        outpath = "clean_data_info/{sample}/{sample}.clean.r%.fq.gz",
        err_log = "clean_data_info/{sample}/{sample}.bowtie.err",
        out_log = "clean_data_info/{sample}/{sample}.bowtie.log"
    threads: 15
    shell:
        """
        bowtie2 --dovetail --very-sensitive -p {threads} -x {params.host_db} -1 {input[0]} -2 {input[1]} --un-conc-gz {params.outpath} -S /dev/null 1>{params.out_log} 2>{params.err_log} 
        """

def get_qc_input(wildcards):
    if host == "None":
        return(rules.run_fastp.output)
    else:
        #return(expand("clean_data/{sample}/{sample}.qc.r{format}.fq.gz", sample = sample_id, format = [1,2]))
        return(rules.run_bowtie2.output)

rule run_qc_links:
    input:
        get_qc_input
    output:
        protected("clean_data.files/{sample}.clean.r1.fq.gz"),
        protected("clean_data.files/{sample}.clean.r2.fq.gz")
    shell:
        """
        mv $PWD/{input[0]} {output[0]}
        mv $PWD/{input[1]} {output[1]}
        """

## for final_data summary
rule qc_nohost_report:
    input:
        expand("clean_data_info/{sample}/{sample}.fastp.log", sample = sample_id)
        # "clean_data/{sample}/{sample}.fastp.log"
    output:
        "QC_nohost_report.tsv"
    params:
        fastp_report_script = get_fastp_report_sh
    shell:
        """
        {params.fastp_report_script} clean_data_info | sed '1iSample\tRaw_r1_reads\tRaw_r1_bases\tRaw_r2_reads\tRaw_r2_bases\tTrimmed_r1_reads\tTrimmed_r1_bases\tTrimmed_r2_reads\tTrimmed_r2_bases\tTrimmed_total_reads' > {output}
        """

rule qc_bowtie_report:
    input:
        fastq = expand("clean_data.files/{sample}.clean.r{format}.fq.gz", sample = sample_id, format = [1,2]),
        per_report = rules.qc_nohost_report.output
    output:
        "QC_rmhost_report.tsv"
    threads: 30
    params:
        rmhost_report_script = get_rmhost_report_sh
    shell:
        """
        seqkit stats -j 3 --all -T {input.fastq} | {params.rmhost_report_script} | csvtk join -t -T -H {input.per_report} - | sed '1iSample\tRaw_r1_reads\tRaw_r1_bases\tRaw_r2_reads\tRaw_r2_bases\tTrimmed_r1_reads\tTrimmed_r1_bases\tTrimmed_r2_reads\tTrimmed_r2_bases\tTrimmed_total_reads\tFinal_r1_num_seqs\tFinal_r1_sum_len\tFinal_r1_min_len\tFinal_r1_avg_len\tFinal_r1_max_len\tFinal_r2_num_seqs\tFinal_r2_sum_len\tFinal_r2_min_len\tFinal_r2_avg_len\tFinal_r2_max_len' > {output}
        """

def get_qc_final_report_input(wildcards):
    if host == "None":
        return(rules.qc_nohost_report.output)
    else:
        return(rules.qc_bowtie_report.output)

rule qc_final_report:
    input:
        get_qc_final_report_input
    output:
        "QC_report.tsv"
    params:
        final_report_script = get_final_report_sh
    shell:
        """
        {params.final_report_script} {input} > {output}
        """ 