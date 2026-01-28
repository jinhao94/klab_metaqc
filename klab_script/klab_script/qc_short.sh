#!/bin/bash
# Author：Jinhao 

function display_help() {
    echo ""
    echo -e "A pipeline for metagenome data quality control and remove host contamination."
    echo -e "Author jinh"
    echo "-_-!!!"
    # echo "Last update 20200410 : More space saved, and higher efficiency than before. All the outputs will be gzip format. So be patient."
    echo "Last update 20221031 : Using the snakemake framework to adapt the large sample queue."
    echo "The max number of parallel sample is 5！"
    echo "Usage: klab_metaqc qc -i Sample_list -o qc_result_folder -t host_type" 
    echo "Note1: There are following types host: | human | c57mouse | c57mouse_metatran | None (means no host)"
    echo "Note2: So you must chose only one of host type above!!!"
    echo "Note3: the sample list format"
    echo "A10 /userdata1/XX/XX/A10.r1.fq.gz"
    echo "A10 /userdata1/XX/XX/A10.r2.fq.gz"
    echo "The Sample_List shoud be Tab or speace delimited."

    echo "   -s, --sample_list          Sample list (From Klab_qc list). [*Required]"
    echo "   -o, --qc_result_folder     Output folder.  [*Required]"
    echo "   -t, --host_type            host type | human | c57mouse | c57mouse_metatran | None (means no host) "
    echo "   -j, --jobs                 Number of jobs will be run. The maximum was 3. (Default: 1)"
    # echo "   -f, --froce                Overwrite output file"
    echo "   -h, --help                 Show this message"
    echo " "
    exit 1
}

# echo $#
if [ $# -eq 0  ];then
    echo "Please input parameters!"
    display_help
fi

## default settings.
perfix=/ddnstor/imau_sunzhihong/mnt1/database/host_db

job=1
froce="N"
outfolder="None"; sample_list="None"

#
while [ "$1" != "" ]; do
    case $1 in
        -o | --qc_result_folder ) shift
                                  outfolder=$1
                                  ;;
        -s | --sample_list)      shift
                                  sample_list=$1
                                  ;;
        -t | --type)              shift
                                  type=$1
                                  ;;
        -j | --jobs)              shift
                                  job=$1
                                  ;;
        * )                       display_help
                                  exit 1
    esac
    shift
done

##############
if [ $outfolder == "None" ] || [ $sample_list == "None" ]; then
    echo "Please input required parameters!"
    display_help
fi


if [ $job -gt 4 ]; then
    job=4
fi

let threads=$job*20

if [[ $type == "human" ]];then
    host_path=${perfix}/human/human
elif [[ $type == "c57mouse" ]];then
    host_path=${perfix}/c57mouse/mouse_C57BL_6NJ
elif [[ $type == "c57mouse_metatran" ]];then
    host_path=${perfix}/c57mouse_tran/c57mouse_tran
# elif [[ $type == "deer" ]];then
#     host_path=${perfix}/deer/deer
# elif [[ $type == "goat" ]];then
#     host_path=${perfix}/goat/goat
# elif [[ $type == "pig" ]];then
#     host_path=${perfix}/pig/pig
# elif [[ $type == "sheep" ]];then
#     host_path=${perfix}/sheep/sheep
elif [[ $type == "None" ]];then
    echo "No host"
else 
    echo "Wrong host type! Exit! "
    exit
fi

## file name 
yaml="${outfolder}.yaml"
new_sample_list="${outfolder}.snk.yaml"

# if [[ "$sample_list" = /* ]]; then
#     file_path=$sample_list
# else
#     file_path=$PWD/${sample_list}
# fi
less $sample_list | perl -e 'while(<>){chomp; @s=split /\t/; if(@s[0] ne $n){print "$_\t"; $n=@s[0]}else{print "@s[1]\n"} }' > $new_sample_list

## create the yaml files
echo -e "workdir: '${outfolder}'" > $yaml
echo -e "db_path: '${host_path}' " >> $yaml
echo -e "host: '${type}' " >> $yaml
echo -e "file_names_txt: '${file_path}' " >> $yaml

source activate snakemake
# snakemake -s qc.snakemake.py --configfile $yaml -r -p --cores $threads -j $threads
snakemake -s /ddnstor/imau_sunzhihong/mnt1/script/script/qc.short.snakemake.py --config workdir=${outfolder} db_path=${host_path} host=${type} file_names_txt=$PWD/${new_sample_list} -r -p --cores $threads -j $threads
