#!/bin/bash

if [ ! -r $1 ]; then #if the file doesn't exist or is not readable by the script
    exit 1;
fi

files=$( tar xvf $1 )

#Changes the delimeter character to newline, so that the for loops work correctly
IFS='
'
#Create the directory in which the git repos will be placed if it doesn't already exist
if [ ! -d assignments ]; then
    mkdir assignments
fi
for filename in $files
do
    #If the file is a txt file and is readable
    if [ ${filename: -4} == ".txt" -a -r $filename ]; then
        content=$( cat $filename )
        for line in $content
        do
            #Only lines starting with https are taken into account
            if [[ $line == "https"* ]]; then
                #Keeps only the repository name from the URL
                dir_name=$( echo "$line" | cut -d'/' -f 5 | cut -d'.' -f 1 )
                git clone $line "assignments/$dir_name" > /dev/null 2> /dev/null
                #Checks if the cloning was successful and outputs the appropriate message to the appropriate stream
                if [ $? -eq 0 ]; then
                    echo "$line: Cloning OK"
                else
                    >&2 echo "$line: Cloning FAILED"
                fi
                break
            fi
        done
    fi
done


for file in assignments/*
do
    #Finds all the files in the directory except for the ones made by git
    files=$(find $file -name ".git" -prune -o -print)
    directories=-1 #The current directory is also counted with find, so we remove it manually
    txtfiles=0
    otherfiles=0
    for line in $files
    do
        if [ -d $line ]; then
            ((directories++))
        elif [[ ${line: -4} == ".txt" ]]; then
            ((txtfiles++))
        else
            ((otherfiles++))
        fi
    done
    reponame=$( echo $file | cut -d'/' -f 2 )
    echo "$reponame:"
    echo "Number of directories: $directories"
    echo "Number of txt files: $txtfiles"
    echo "Number of other files: $otherfiles"
    #Check if the directory structure is correct
    if [ -f $file/dataA.txt -a -d $file/more -a -f $file/more/dataB.txt -a -f $file/more/dataC.txt -a $txtfiles -eq 3 -a $otherfiles -eq 0 -a $directories -eq 1 ]; then
        echo "Directory structure is OK"
    else
        echo "Directory structure is not OK"
    fi
done
#This ensures that the output is correct the 2nd, 3rd etc time the script is ran
rm -rf assignments
exit 0