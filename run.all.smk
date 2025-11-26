# include the config file
configfile: "config.yaml"

import os

def check_cram_files_os(folder_path):
    if not os.path.exists(folder_path):
        print(f"Warning: Folder '{folder_path}' does not exist.")
        raise Exception("Folder does not exist.")
    all_entries = os.listdir(folder_path)
    
    for entry in all_entries:
        full_path = os.path.join(folder_path, entry)
        if os.path.isfile(full_path) and entry.endswith('.cram'):
            return True
    return False

folder = "input/cram/"
if check_cram_files_os(folder):
    (sampleNameList,) = glob_wildcards("input/cram/{sampleName}.cram")
else:
    (sampleNameList,) = glob_wildcards("input/cram/{sampleName}.bam")

# define a function to return target files based on config settings
def run_all_input(wildcards):

    run_all_files = []
    
    if config['modules']['extract_reads']:
        run_all_files.extend(expand("input/fastq/{sampleName}.mtDNA.R1.fastq.gz", sampleName=sampleNameList))
        run_all_files.extend(expand("input/fastq/{sampleName}.mtDNA.R2.fastq.gz", sampleName=sampleNameList))

    if config['modules']['alignment']:
        run_all_files.extend(expand("input/mtDNA_cram/{sampleName}.raw.cram", sampleName=sampleNameList)),
        run_all_files.extend(expand("input/mtDNA_cram/{sampleName}.raw.cram.crai", sampleName=sampleNameList)),
        run_all_files.extend(expand("input/mtDNA_cram/{sampleName}.shifted.cram", sampleName=sampleNameList)),
        run_all_files.extend(expand("input/mtDNA_cram/{sampleName}.shifted.cram.crai", sampleName=sampleNameList)),
        

    if config['modules']['var_calling']:
        run_all_files.append("output/01.mito_vcf/{id}.samples.vcf".format(id = config['samples']['id']))

    return run_all_files

# rule run all, the files above are the targets for snakemake
rule run_all:
    input:
        run_all_input
smk_path = config['params']['smk_path']
include: smk_path+"/1.ExtractMtDNAReads.smk"
include: smk_path+"/2.AlignmentMtDNA.smk"
include: smk_path+"/3.VariantCalling.smk"
