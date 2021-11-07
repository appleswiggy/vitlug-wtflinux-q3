#!/bin/bash
 
if [ $# -ne 2 ]
then
	echo "Syntax: ./script.sh [ZIPFILE] [DIRECTORY]"
	exit
fi
 
# Check if zip files exists
if [ ! -f $1 ]
then
	echo "Error: The zip file doesn't exist"
	exit
fi
 
# Check if directory exists, if not make one
if [ ! -d $2 ] 
then
	mkdir $2
fi	
 
months=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
 
# unzip the file in temp directory inside specified directory
# and redirect the error to log.txt if there
unzip -qq $1 -d $2/temp 2> $2/log.txt

# check exit code of unzip if success then continue
# else exit control
if [ $? == 0 ]
then
	for file in $2/temp/*
	do
		# split the filename at "_"s
		arr=(${file//"_"/ })
	 
		# generate file content name
		# this is ${REST} name and it 
		# preserves the file extension
		name=""
		for((i=8;i<${#arr[@]};i++))
		do
			name="${name}_${arr[$i]}"
		done
	 
		# extract date from filename
		date=${arr[7]}
		arr2=(${date//"-"/ })
	 
		dd=${arr2[0]}
		month=${arr2[1]}
		year=${arr2[2]}
	 
		# Logic to rename the month name
		# if month name is number like 09
		# it changes it to Sept
		re='^[0-9]+$'
		if [[ $month =~ $re ]]; 
		then
			if [[ $month == 0* ]]
			then
				month=${month:1:1}
			fi
			month=${months[$(( month - 1 ))]}
		fi
	 
		# if month directory doesnt exist, create it
		if [ ! -d $2/$month ]
		then
			mkdir $2/${month}
		fi
	 
		# new name of file
		# file extension is in ${name}
		newName="${dd}_${month}_${year}${name}"
		mv ${file} $2/${month}/${newName}
	done
	 
	# remove the temp directory
	rmdir $2/temp
	
	# remove log.txt as everything ran successfully
	rm $2/log.txt

else
	echo "Some error occured in unzipping. Check log.txt in $2 directory for more details"
fi
