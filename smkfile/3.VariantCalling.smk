# create the input file for variant calling
rule create_inputfile_for_variant_calling:
    input:
        raw_crams = expand("input/mtDNA_cram/{sampleName}.raw.cram", sampleName=sampleNameList),
        shifted_crams = expand("input/mtDNA_cram/{sampleName}.shifted.cram", sampleName=sampleNameList)
    output:
        raw_bam_list = "input/mtDNA_bam_list/raw_bam_list.txt",
        shifted_bam_list = "input/mtDNA_bam_list/shifted_bam_list.txt"
    run:
        with open(output.raw_bam_list, 'w') as raw_bam_list_file, open(output.shifted_bam_list, 'w') as shifted_bam_list_file:
            for sampleName in sampleNameList:
                raw_bam = "input/mtDNA_cram/{sampleName}.raw.cram".format(sampleName=sampleName)
                shifted_bam = "input/mtDNA_cram/{sampleName}.shifted.cram".format(sampleName=sampleName)
                raw_bam_list_file.write(raw_bam + "\n")
                shifted_bam_list_file.write(shifted_bam + "\n")

# Rule for SNV calling using mitoquest
rule VarCalling_raw:
    input:
        raw_ref_fa = config['params']['mito_ref'],
        raw_bam_list = "input/mtDNA_bam_list/raw_bam_list.txt"
    output:
        "output/01.mito_vcf/mito_raw_calling/{id}.non_control.vcf.gz".format(id = config['samples']['id']),
    threads:
        config['threads']
    params:
        mitoquest = config['tools']['mitoquest'],
        mapQ = config['params']['mapQ'],
        baseQ = config['params']['baseQ']
    shell:
        "{params.mitoquest} caller -t {threads} -f {input.raw_ref_fa} -r chrM:576-16024 --pairs-map-only -q {params.mapQ} -Q {params.baseQ} -b {input.raw_bam_list} -o {output}"

# Rule for SNV calling using mitoquest
rule VarCalling_shifted:
    input:
        shifted_ref_fa = config['params']['mito_shifted_ref'],
        shifted_bam_list = "input/mtDNA_bam_list/shifted_bam_list.txt"
    output:
        "output/01.mito_vcf/mito_shifted_calling/{id}.control.vcf.gz".format(id = config['samples']['id']),
    threads:
        config['threads']
    params:
        mitoquest = config['tools']['mitoquest'],
        mapQ = config['params']['mapQ'],
        baseQ = config['params']['baseQ']
    shell:
        "{params.mitoquest} caller -t {threads} -f {input.shifted_ref_fa} -r chrM:8024-9145 --pairs-map-only -q {params.mapQ} -Q {params.baseQ} -b {input.shifted_bam_list} -o {output}"


# Rule for merging the two VCF files
rule mitoVCF_merging:
    input:
        control_vcf = "output/01.mito_vcf/mito_raw_calling/{id}.non_control.vcf.gz",
        non_control_vcf = "output/01.mito_vcf/mito_shifted_calling/{id}.control.vcf.gz"
    output:
        "output/01.mito_vcf/{id}.samples.vcf"
    params:
        scripts_dir = config['params']['scripts_dir'],
        python = config['params']['python'],
        ref_dir = config['params']['ref_dir']
    shell:
        """
        {params.python} {params.scripts_dir}/merge_cr_ncr_vcf.py -v1 {input.non_control_vcf} \
                    -r1 {params.ref_dir}/Homo_sapiens.GRCh38.chrM_rCRS.non_control_region.interval_list \
                    -v2 {input.control_vcf} \
                    -r2 {params.ref_dir}/Homo_sapiens.GRCh38.chrM_rCRS.control_region.shifted_by_8000_bp.interval_list \
                    -o {output}
        """

