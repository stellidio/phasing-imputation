#!bin/bash

#create a file with all gene's locations
#1st column represents gene's name
#2nd column represents the chromosome
#3rd column represents a specific chromosome position near to the start of the gene
#4th column represents a specific chromosome position near to the end of the gene

genes_locations_file="genes_locs.txt"

cat > $genes_locations_file << EndOfMessage
gene1,1,gene1_startloc,gene1_endloc
gene2,1,gene2_startloc,gene2_endloc
gene3,2,gene3_startloc,gene3_endloc
gene4,6,gene4_startloc,gene4_endloc
gene5,7,gene5_startloc,gene5_endloc
gene6,7,gene6_startloc,gene6_endloc
gene7,10,gene7_startloc,gene7_endloc
gene8,12,gene8_startloc,gene8_endloc
gene9,16,gene9_startloc,gene9_endloc
gene10,19,gene10_startloc,gene10_endloc
gene11,19,gene11_startloc,gene11_endloc
#gene12,X,gene12_startloc,gene12_endloc
EndOfMessage

echo "Created file $genes_locations_file"

#create a variable with the initial vcf file which contains all chromosomes and all samples
initial_vcf="Initial_Genomes.vcf"

#create an empty file and an empty temp file to fill in later with the chrosomome numbers
chr_num="chr_list.txt"
chr_num_temp="chr_list.txt.tmp"
rm -f $chr_num

#create a file which contains all the sample names, each one in each line
sampleID="samplenames.txt"
samples_names=$(grep SAMPLE $initial_vcf)
echo  ${samples_names} | tr " " "\n" > $sampleID
sed -i -n '/SAMPLE/p' $sampleID

#create a variable with a name used a base for all the names of the output files
initial_vcf_basename="Initial_Genomes"

#create a variable with the vcftools executable
vcftools="/path/to/vcftools"

#create a variable with the shapeit executable
shapeit="/path/to/shapeit"

#create a variable with the impute2 executable
impute2="/path/to/impute2"

# Read genes_locs file line by line
while IFS= read line
do
    # display $line
    echo "$line"

    #split the line and define each of its element(0,1,2,3) as variable
    fields=(${line//,/ })
    gene="${fields[0]}"
    chromosome="${fields[1]}"
    start="${fields[2]}"
    finish="${fields[3]}"
    
    #do not do the previous in lines with #, just ingore them
    if [[ $line == '#'* ]]; then
       echo "Ignoring line: $line"
       continue
    fi

    echo "Running phasing+imputation. GENE:$gene  chr:$chromosome  start:$start  finish:$finish"

    #print in a .txt all the chromosome numbers that are used
    echo "${chromosome}" >> $chr_num
    #short the chromosome numbers/remove the duplicated
    sort -u $chr_num > $chr_num_temp && mv $chr_num_temp $chr_num

    #the vcftools output file with the initial_vcf_basename followed by _chr and the chromosome variable
    vcf_chr="${initial_vcf_basename}_chr${chromosome}"

    #create a variable with the execution commands of vcftools to extract each chromosome from the initial vcf
    extract_chromosome="$vcftools --vcf $initial_vcf --chr chr$chromosome --recode --out $vcf_chr"
    echo "Running command:"
    echo $extract_chromosome
    
    #evaluate the previous variable
    eval "$extract_chromosome"

    echo "FINISHED CHROMOSOME SPLIT!!"

    filename='samplenames.txt'
    filelines=`cat $filename`
    for line in $filelines ; do
	    echo $lile
	    vcf_spl_inp="${initial_vcf_basename}_chr${chromosome}.recode.vcf"
	    vcf_spl_out="${initial_vcf_basename}_chr${chromosome}_${line}"

	    #extract each sample from each extracted chromosome
	    extract_sample="$vcftools --vcf $vcf_spl_inp --indv $line --recode --out $vcf_spl_out"
	    echo "Running command:"
	    echo $extract_sample
	    
	    #evaluate the previous variable
	    eval "$extract_sample"
	    
	    echo "FINISHED SAMPLE SPLIT!!"
	    
	    vcf_nomiss_inp="${initial_vcf_basename}_chr${chromosome}_${line}.recode.vcf"
	    vcf_nomiss_out="${initial_vcf_basename}_chr${chromosome}_${line}_nomiss"

	    #remove missing values from each created file
	    remove_missing="$vcftools --vcf $vcf_nomiss_inp --max-missing 1 --recode --out $vcf_nomiss_out"
	    echo "Running command:"
	    echo $remove_missing
	    
	    eval "$remove_missing"
	    
	    echo "FINISHED REMOVE MISSING"
	    
	    #sort/put in order the chromosome location in each file 
	    vcf_nonsorted="${initial_vcf_basename}_chr${chromosome}_${line}_nomiss.recode.vcf"
	    vcf_sorted="${initial_vcf_basename}_chr${chromosome}_${line}_nomiss_sorted.recode.vcf"
	    vcf_sortedok="${initial_vcf_basename}_chr${chromosome}_${line}_nomiss_sortedok.recode.vcf"
	    header_file="${initial_vcf_basename}_chr${chromosome}_${line}_nomiss_header.txt"
	    egrep -v "^#" $vcf_nonsorted | sort -k 2 -n > $vcf_sorted
	    egrep "^#" $vcf_nonsorted > $header_file
	    cat $header_file $vcf_sorted > $vcf_sortedok
	    
	    echo "SORTING OK!!"

    
    done


done <"$genes_locations_file"


#check alignment and phasing process

refpanel_dir="/path/to/1000GP_Phase3"

sample_file="samplenames.txt"
sample_lines=`cat $sample_file`
chr_file="chr_list.txt"
chr_lines=`cat $chr_file`
for line1 in $chr_lines
do
        for line2 in $sample_lines
        do
                echo ${initial_vcf_basename}_chr${line1}_${line2}
		
		#check alignmnet process with shapeit
		check_vcf_inp="${initial_vcf_basename}_chr${line1}_${line2}_nomiss_sortedok.recode.vcf"
		check_vcf_out="${initial_vcf_basename}_chr${line1}_${line2}_nomiss_sortedok_alignment"

		#checl alignment of each created file with shapeit
		check_alignment="$shapeit -check --input-vcf $check_vcf_inp -M $refpanel_dir/genetic_map_chr${line1}_combined_b37.txt --input-ref $refpanel_dir/1000GP_Phase3_chr${line1}.hap.gz $refpanel_dir/1000GP_Phase3_chr${line1}.legend.gz $refpanel_dir/1000GP_Phase3.sample --output-log $check_vcf_out"
		            
		echo "Running command:"
                echo $check_alignment
		eval "$check_alignment"

                echo "FINISHED ALIGNMENT"

		#phasing process with shapeit
		phase_exclude="${initial_vcf_basename}_chr${line1}_${line2}_nomiss_sortedok_alignment.snp.strand.exclude"
		phase_out="${initial_vcf_basename}_chr${line1}_${line2}_nomiss_sortedok_phased"
		phasing_fun="$shapeit --input-vcf $check_vcf_inp -M $refpanel_dir/genetic_map_chr${line1}_combined_b37.txt --input-ref $refpanel_dir/1000GP_Phase3_chr${line1}.hap.gz $refpanel_dir/1000GP_Phase3_chr${line1}.legend.gz $refpanel_dir/1000GP_Phase3.sample --exclude-snp $phase_exclude -O $phase_out"
		echo "Running command:"
                echo $phasing_fun
                eval "$phasing_fun"

                echo "PHASING FINISHED"
        done
done


#imputation process
while IFS= read line
do
    # display $line or do somthing with $line
    echo "$line"

    fields=(${line//,/ })
    gene="${fields[0]}"
    chromosome="${fields[1]}"
    start1="${fields[2]}"
    finish="${fields[3]}"

    if [[ $line == '#'* ]]; then
       echo "Ignoring line: $line"
       continue
    fi

    for line3 in $sample_lines
    do
            echo ${initial_vcf_basename}_chr${chromosome}_${line3}_${start1}_${finish}  

            impute_inp="${initial_vcf_basename}_chr${chromosome}_${line3}_nomiss_sortedok_phased.haps"
	    impute_out="${initial_vcf_basename}_chr${chromosome}_${line3}_${start1}_${finish}_nomiss_sortedok_phased_imputed"

	    imputation="$impute2 -use_prephased_g -known_haps_g $impute_inp -h $refpanel_dir/1000GP_Phase3_chr${chromosome}.hap.gz -l $refpanel_dir/1000GP_Phase3_chr${chromosome}.legend.gz -m $refpanel_dir/genetic_map_chr${chromosome}_combined_b37.txt -Ne 20000 -int $start1 $finish -o $impute_out -phase"
	    echo "Running command:"
	    echo $imputation
	    
	    eval "$imputation"
	    
	    echo "IMPUTATION FINISHED"

	    #transformation _haps to _haps.haps
	    trans_inp="${initial_vcf_basename}_chr${chromosome}_${line3}_${start1}_${finish}_nomiss_sortedok_phased_imputed_haps"
	    trans_out="${initial_vcf_basename}_chr${chromosome}_${line3}_${start1}_${finish}_nomiss_sortedok_phased_imputed_merged_haps.haps"
	    cat $trans_inp |sort -k3n |sed "s/---/chr${chromosome}/g" > $trans_out

	    #rename _phased.sample the same name as the previous transformation output
	    rename_inp="${initial_vcf_basename}_chr${chromosome}_${line3}_nomiss_sortedok_phased.sample"
	    rename_out="${initial_vcf_basename}_chr${chromosome}_${line3}_${start1}_${finish}_nomiss_sortedok_phased_imputed_merged_haps.sample"
	    cp $rename_inp $rename_out

	    #convert .haps file to .vcf file with shapeit
	    convert_inp="${initial_vcf_basename}_chr${chromosome}_${line3}_${start1}_${finish}_nomiss_sortedok_phased_imputed_merged_haps"
	    convert_out="${initial_vcf_basename}_chr${chromosome}_${line3}_${start1}_${finish}_nomiss_sortedok_phased_imputed_merged_haps.vcf"
	    convert_to_vcf="$shapeit -convert --input-haps $convert_inp --output-vcf $convert_out"

            eval "$convert_to_vcf"

            echo "CONVERTION FINISHED"


    done

done <"$genes_locations_file"




