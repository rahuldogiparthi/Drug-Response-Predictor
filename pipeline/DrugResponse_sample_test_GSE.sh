#!/bin/bash
# Input: GSE number
# DrugResponse_sample_test_GSE.sh GSE_number

E_FILE_NOT_EXIST=70 	#internal software error
E_DOWNLOAD_FAIL=71 	#System error
E_MV_FAIL=72       	#Critical OS file missing 
E_UNZIP_FAIL=73	   	#Cannot create output file
E_TEST_FAIL=74	   	#input/output error

INPUT=$1
DATAPATH='../ResponsePredictor/data'

echo "Download CEL file from NCBI"

var1=$(sed 's/.\{3\}$//' <<< "$INPUT")
URLIN="ftp://ftp.ncbi.nih.gov/geo/series/"$var1"nnn/"$INPUT"/suppl/"$INPUT"_RAW.tar"
echo $URLIN 


if tar -xvf $INPUT"_RAW.tar"; then
echo "unzip successful"
else
echo "Fail to unzip"
exit $E_UNZIP_FAIL
fi

if gunzip *gz; then
echo "unzip successful"
else
echo "Fail to unzip"
exit $E_UNZIP_FAIL
fi


mkdir mtemp

for i in *.[Cc][Ee][Ll]
do
mv $i mtemp
pwd
if R -q -e "source('/home/rahul/Desktop/DrugR/pipeline/ResponsePredictor.R');library(affy);DrugResponse.predict('mtemp','cel','$i','$DATAPATH')"; then
echo "test for $i successful"
else
echo "Fail to process cel files"
rm -r mtemp
rm *tar
rm *_tp.txt
exit $E_TEST_FAIL
fi
mv mtemp/$i .
done



rm -r mtemp
rm *tar
rm *_tp.txt
echo "done"
exit 0
