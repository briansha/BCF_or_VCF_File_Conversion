version development

## Version 04-05-2021
##
## This workflow converts BCF files to VCF files or vice-versa using BCFTools.
## This workflow assumes users have thoroughly read the BCFTools documentation for the view command section.
## BCFTools documentation: http://samtools.github.io/bcftools/bcftools.html
##
## Input files need to all be either BCF or VCF files and will be converted according to the --output-type parameter.
##
## Cromwell version support - Successfully tested on v59
##
## Distributed under terms of the MIT License
## Copyright (c) 2021 Brian Sharber
## Contact <brian.sharber@vumc.org>

workflow BCF_To_VCF {

    input {
        Array[File] input_file
        Array[String] output_name
        File? index_file
        Int? memory
        Int? disk
        Int? threads  
    }
    
    scatter (file_and_output in zip(input_file, output_name)) {
        call Convert_File { 
          input: 
            input_file = file_and_output.left,
            output_name = file_and_output.right,
            index_file = index_file,
            memory = memory,
            disk = disk,
            threads = threads       
      }
    }

    output {
        Array[File] output_files = Convert_File.converted_file
    }
    
    meta {
    	author : "Brian Sharber"
        email : "brian.sharber@vumc.org"
        description : "Run BCFTOOLS"
    }
}

task Convert_File {

    # Refer to BCFTools documentation for the descriptions to most of these parameters.
    input {
        File input_file
        File? index_file
        String docker_image # Docker image containing BCFTools.
        Int? memory
        Int? disk
        Int? threads
        
        Boolean drop_genotypes
        Boolean header_only
        Boolean no_header
        Int? compression_level
        Boolean no_version
        String? output_type
        String output_name
        Array[String]? regions
        File? regions_file
        Array[String]? targets
        File? targets_file
        Boolean trim_alt_alleles
        Boolean force_samples
        Boolean no_update
        Array[String]? samples
        File? samples_file
        
        Int? min_ac_int
        String? min_ac_string
        Int? max_ac_int
        String? max_ac_string
        String? exclude
        Array[String]? apply_filters
        String? genotype
        String? include
        Boolean known
        Int? min_alleles
        Int? max_alleles
        Boolean novel
        Boolean phased
        Boolean exclude_phased
        Float? min_af_float
        String? min_af_string
        Float? max_af_float
        String? max_af_string
        Boolean uncalled
        Boolean exclude_uncalled
        Array[String]? types
        Array[String]? exclude_types
        Boolean private
        Boolean exclude_private
    }

    command <<<
        bcftools view \
        ~{if drop_genotypes then "--drop-genotypes " else " "} \
        ~{if header_only then "--header-only " else " "} \
        ~{if no_header then "--no-header " else " "} \
        ~{if defined(compression_level) then "--compression-level ~{compression_level} " else " "} \
        ~{if no_version then "--no-version " else " "} \
        ~{if defined(output_type) then "--output-type ~{output_type} " else " "} \
        ~{if defined(output_name) then "--output-file ~{output_name} " else " "} \
        ~{if defined(targets) then "--targets ~{targets} " else " "} \
        ~{if defined(targets_file) then "--targets-file ~{targets_file} " else " "} \
        ~{if defined(threads) then "--threads ~{threads} " else " "} \
        ~{if trim_alt_alleles then "--trim-alt-alleles " else " "} \
        ~{if force_samples then "--force-samples " else " "} \
        ~{if no_update then "--no-update " else " "} \
        ~{if defined(samples) then "--samples ~{samples} " else " "} \
        ~{if defined(samples_file) then "--samples-file ~{samples_file} " else " "} \
        ~{if defined(min_ac_int) then "--min-ac ~{min_ac_int} ~{min_ac_string} " else " "} \
        ~{if defined(max_ac_int) then "--max-ac ~{max_ac_int} ~{max_ac_string} " else " "} \
        ~{if defined(exclude) then "--exclude ~{exclude} " else " "} \
        ~{if defined(apply_filters) then "--apply-filters ~{apply_filters} " else " "} \
        ~{if defined(genotype) then "--genotype ~{genotype} " else " "} \
        ~{if defined(include) then "--include ~{include} " else " "} \
        ~{if known then "--known " else " "} \
        ~{if defined(min_alleles) then "--min-alleles ~{min_alleles} " else " "} \
        ~{if defined(max_alleles) then "--max-alleles ~{max_alleles} " else " "} \
        ~{if novel then "--novel " else " "} \
        ~{if phased then "--phased " else " "} \
        ~{if exclude_phased then "--exclude-phased " else " "} \
        ~{if defined(min_af_float) then "--min-af ~{min_af_float} ~{min_af_string} " else " "} \
        ~{if defined(min_af_float) then "--max-af ~{max_af_float} ~{max_af_string} " else " "} \
        ~{if uncalled then "--uncalled " else " "} \
        ~{if exclude_uncalled then "--exclude-uncalled " else " "} \
        ~{if defined(types) then "--types ~{types} " else " "} \
        ~{if defined(exclude_types) then "--exclude-types ~{exclude_types} " else " "} \
        ~{if private then "--private " else " "} \
        ~{if exclude_private then "--exclude_private " else " "} \
        ~{input_file} \
        ~{if defined(regions) then "--regions ~{regions} " else " "} \
        ~{if defined(regions_file) then "--regions-file ~{regions_file} " else " "}
    >>>
    
    output {
        File converted_file = "${output_name}"
    }

    runtime {
        docker: docker_image
        memory: memory + " GiB"
	disks: "local-disk " + disk + " HDD"
        cpu: threads
    }
}
