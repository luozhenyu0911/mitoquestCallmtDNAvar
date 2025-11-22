# Rule for SNV calling using mitoquest

rule extractMtDNAReads:
    input:
        input_cram = "input/cram/{sampleName}.sorted.markdup.BQSR.cram"
    output:
        mtDNA_cram = "input/mtDNA_cram/{sampleName}.mtDNA.cram"
    params:
        gatk = config['tools']['gatk'],
        ref = config['params']['human_ref']
    shell:
        "{params.gatk} PrintReads -R {params.ref} -I {input.input_cram} -L chrM --read-filter MateOnSameContigOrNoMappedMateReadFilter --read-filter MateUnmappedAndUnmappedReadFilter -O {output.mtDNA_cram}"

rule convert_cram_to_fastq:
    input:
        mtDNA_cram = "input/mtDNA_cram/{sampleName}.mtDNA.cram"
    output:
        r1 = "input/fastq/{sampleName}.mtDNA.R1.fastq.gz",
        r2 = "input/fastq/{sampleName}.mtDNA.R2.fastq.gz"
    params:
        samtools = config['tools']['samtools']
    shell:
        "{params.samtools} collate -Ou {input.mtDNA_cram} | {params.samtools} fastq -N -1 {output.r1} -2 {output.r2} - && rm {input.mtDNA_cram}"

