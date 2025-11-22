# Rule AlignmentMtDNA:

def get_readgroup(wildcards):
    return r'@RG\tID:{0}\tSM:{0}\tPL:{1}'.format(wildcards.sampleName, config['params']['platform'])

rule Align2RawRef:
    input:
        r1 = "input/fastq/{sampleName}.mtDNA.R1.fastq.gz",
        r2 = "input/fastq/{sampleName}.mtDNA.R2.fastq.gz"
    output:
        mtDNA_cram = "input/mtDNA_cram/{sampleName}.raw.cram",
        mtDNA_cram_index = "input/mtDNA_cram/{sampleName}.raw.cram.crai"
    params:
        bwa = config['tools']['bwa'],
        samtools = config['tools']['samtools'],
        ref = config['params']['mito_refPlusDecoy'],
        # readgroup = r'@RG\tID:{0}\tSM:{0}\tPL:{1}'.format(wildcards.sampleName,config['params']['platform'])
        readgroup = get_readgroup
    threads:
        config['threads']
    shell:
        "{params.bwa} mem -Y -M -t {threads} -K 10000000 -R '{params.readgroup}' {params.ref} {input.r1} {input.r2} | {params.samtools} sort -@ {threads} --reference {params.ref} --output-fmt CRAM -o {output.mtDNA_cram} - && {params.samtools} index -@ {threads} {output.mtDNA_cram}"

rule Align2ShiftedRef:
    input:
        r1 = "input/fastq/{sampleName}.mtDNA.R1.fastq.gz",
        r2 = "input/fastq/{sampleName}.mtDNA.R2.fastq.gz"
    output:
        mtDNA_cram = "input/mtDNA_cram/{sampleName}.shifted.cram",
        mtDNA_cram_index = "input/mtDNA_cram/{sampleName}.shifted.cram.crai"
    params:
        bwa = config['tools']['bwa'],
        samtools = config['tools']['samtools'],
        ref = config['params']['mito_shifted_refPlusDecoy'],
        readgroup = get_readgroup
    threads:
        config['threads']
    shell:
        "{params.bwa} mem -Y -M -t {threads} -K 10000000 -R '{params.readgroup}' {params.ref} {input.r1} {input.r2} | {params.samtools} sort -@ {threads} --reference {params.ref} --output-fmt CRAM -o {output.mtDNA_cram} - && {params.samtools} index -@ {threads} {output.mtDNA_cram}"
