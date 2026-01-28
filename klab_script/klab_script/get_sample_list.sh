#!/bin/bash
# Author：Jinhao 

function display_help() {
    echo ""
    echo -e "A script to get sample list for futher use."
    echo -e "Author jinh"
    echo "-i, --rawdata_folder    PATH fo rawdata folder where contain your rawdata."
    echo "-s, --Sample_list       Result for sample list."
    echo "-e, --extension         Extension of your rawdata (May be fq.gz or fastq.gz; Default: fq.gz)"
    echo "-t, --type              choose from [F1|F2], (Default: F1)"
    echo "-h, --help              Show this massage."
    echo "Please follow the recommend name format."
    echo "For example, your file is locate in the path XX/XX "
    
    echo "Format 1: 诺和测序原始结果 XX/XX/A10_BDME202034098-1a_1.fq.gz"
    echo "Format 2: Both R1 and r1 can be used, and both .R1 and _R1 is recognized)"
    echo "Format 3: 实验室华大测序仪下机结果)"
    echo "XX/XX/A10_1.fq.gz; XX/XX/A10.1.fq.gz; XX/XX/A10_r1.fq.gz; XX/XX/A10.R1.fq.gz; XX/XX/A10_R1.fq.gz "
    exit
}

# echo $#
if [[ $# -lt 4 ]];then
    echo "Please input parameters!"
    display_help
fi


extension="fq.gz"
type="F1"

while [ "$1" != "" ]; do
    case $1 in
        -i | --rawdata_folder ) shift
                                rawdata_folder=$1
                                ;;
        -s | --sample_list )    shift
                                sample_list=$1
                                ;;
        -e | --extension )      shift
                                extension=$1
                                ;;
        -t | --type )           shift
                                type=$1
                                ;;
        -h | --help )           display_help
                                exit
                                ;;
        * )                     display_help
                                exit 1
    esac
    shift
done

if [ ! -d $rawdata_folder ];then
    echo "$rawdata_folder is not existed"
    display_help
fi

file_num=`tree -if $rawdata_folder | grep "$extension$" -c`
sample_num=`echo $(($file_num/2))`
echo -e "\033[42;37mThe number of file is ${file_num}, and the number of sample is $sample_num. \033[0m"
echo -e ""

# echo "Summarizing the result."
if [[ $type == "F1" ]];then
	tree -if $rawdata_folder | grep "$extension$" | xargs -I foo  echo $PWD/foo | perl -e 'while(<STDIN>){chomp; $ext=@ARGV[0] ; @l=split /\s+/; @s=split /\//, @l[-1] ; if(@s[-1]=~/(.*)_(.*)[\._]([12]|r1|r2|R1|R2)(\.clean\.|.)$ext/){$o=$1 }else{@s[-1]=~/(.*)[\._]([12]|r1|r2|R1|R2).(clean\.)$ext/; $o=$1}; print "$o\t@l[-1]\n"}' $extension | sort -k1,1 > $sample_list
elif [[ $type == "F2" ]]; then
    tree -if $rawdata_folder | grep "$extension$" | xargs -I foo  echo $PWD/foo | perl -e 'while(<STDIN>){chomp; $ext=@ARGV[0]; @l=split /\s+/; @s=split /\//, @l[-1]; if(@s[-1]=~/(.*)[\._]([12]|r1|r2|R1|R2).*$ext/){$o=$1 }; print "$o\t@l[-1]\n"}' $extension | sort -k1,1 > $sample_list
elif [[ $type == "F3" ]]; then
    tree -if $rawdata_folder | grep "$extension$" | xargs -I foo echo $PWD/foo | perl -e 'while(<STDIN>){chomp; $ext=@ARGV[0]; @l=split /\s+/; @s=split /\//, @l[-1]; if(@s[-1]=~/(.*)_[12].*$ext/){$o=$1}; print "$o\t@l[-1]\n"}' $extension | sort -k1,1 > $sample_list
else
    echo "Wrong type, so ues the format 1, please check the result."
    tree -if $rawdata_folder | grep "$extension$" | xargs -I foo  echo $PWD/foo | perl -e 'while(<STDIN>){chomp; $ext=@ARGV[0] ; @l=split /\s+/; @s=split /\//, @l[-1] ; if(@s[-1]=~/(.*)_(.*)[\._]([12]|r1|r2|R1|R2)(\.clean\.|.)$ext/){$o=$1 }else{@s[-1]=~/(.*)[\._]([12]|r1|r2|R1|R2).(clean\.)$ext/; $o=$1}; print "$o\t@l[-1]\n"}' $extension | sort -k1,1 > $sample_list
fi

# check the result
final_sample=`cut -f1  $sample_list | sort -u | wc -l`


if [[ $sample_num -ne $final_sample ]]; then
    echo -e "\033[31mPlease check the result, which contains duplicate samples!!!\033[0m" 
fi

echo "Done, if the number of sample were not consistent with exception, check the extension (it may be the fastq.gz and not fq.gz. Moreover, you can use the shell commond 'tree -if' and arrange the correct sample list in excel (No header)."
