#!/bin/bash

if [ ! -r $1 ]; then #if the file doesn't exist or is not readable by the script
    exit 1;
fi
websites_file=$( cat $1 )

check_sites()
{
    #Checks if the line begins with a # (if it does, it is ignored as a comment)
    if [[ ! $1 =~ ^\# ]]; then

        site_file=$(echo "${1}.html" | tr -d '/' ) #this removes all slashes from the domain name to save the html into a file
        #(so, for example, https://www.google.com/ becomes https:www.google.com.html)
        new_site_file=$(echo "${1}-new.html" | tr -d '/')
        
        site=$(curl $1 2> /dev/null)
        if [ $? -eq 0 ]; then #if the html was retrieved successfully

            if [ -f  $site_file ]; then #if the site has been checked before

                echo "$site" > $new_site_file
                diff $site_file $new_site_file > /dev/null

                if [ $? -ne 0 ]; then #if the site has changed since the last time this script was run
                    echo "$1"
                    mv $new_site_file $site_file
                else
                    rm $new_site_file
                fi
            else
                echo "$1 INIT" 
                echo "$site" > $site_file
            fi
        else
            if [ -f $site_file ]; then
                if [ "$(cat $site_file)" != "FAILED" ]; then #if the site could not be retrieved, but has been retrieved at a previous time
                    echo "$1 FAILED"
                    echo "FAILED" > $site_file
                fi
            else
                echo "$1 FAILED INIT"
                echo "FAILED" > $site_file
            fi
        fi
    fi
}

#Changes the delimeter character to newline, so that the for loop works correctly
IFS='
'
for line in $websites_file
do
    check_sites $line &
done
wait
exit 0