#!/bin/bash
 ____            _     
| __ )  __ _ ___| |__  
|  _ \ / _` / __| '_ \ 
| |_) | (_| \__ \ | | |
|____/ \__,_|___/_| |_|
                       

#Bash script for a password manager. 
#assumes the username passwords to be in form of chrome login data export
# $PASS is the location of the password file.
# if the password file is sudo protected then the file needs to be run using sudo
# vault -h returns the help menu




PASS="/home/neil/.local/resources/pass"
##############################Check for Arguements
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
	exit
fi
#############################Help 
if [ $1 == "-h" ]
then
echo "Vault is a password manager that allows searching, adding and clipping passwords.
If no options are provided search will be conducted by name 
     Options:

  1) [-s]   : used to search stored usernames and passwords
  can be used with [U] for username, [n] for name, [u] for url or [N] for number
 
  2) [-add] :used to add a new name,url,username and password
 
  3) [-gn]  :used to clip username password pair. Takes name as arguement
 
  4) [-gu]  :used to clip username - password pair. Takes url as arguement 
  
  5) [-gen] :if no arguements are supplied then a 16 character random password is generated. 
             number of characters can be specified as 3rd arguments" 
  exit
fi

##############################Add Arguements
if [ $1 == "-add" ]
then
	read -p "name:" name
	read -p "Username:" user
	read -p "website:" url
	read -p "Password:" pass
	clear
	if [ $url == "" ] 
	then
		url="N\\A"
	fi
	num=`cat $PASS | wc -l`
	num=$((num-1))
	echo "$num,$name,$url,$user,$pass" >> $PASS
	exit
fi
 
#############################Search Arguements

if [ $1 == "-sU" ]
then
		var=$2
		awk -F, -v var=$var '$4 ~ var' $PASS | awk -F, 'BEGIN {OFS="\t"} \
			{ print "%-20s %-40s\n", $1, $2, $3, $4}' |head 5| column -t
	    exit
fi

if [ $1 == "-sn" ]
	then
		var=$2
		awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, 'BEGIN {OFS="\t"} \
			{ print  $1, $2, $3, $4 }'|head -5| column -t
	    exit
fi

if [ $1 == "-su" ]
	then
		var=$2
		awk -F, -v var=$var '$3 ~ var' $PASS | awk -F, 'BEGIN {OFS="\t"} \
			{ print $1, $2, $3, $4 }' |head -5| column -t
        exit
fi

if [ $1 == "-sN" ]
	then
		var=$2
		awk -F, -v var=$var '$1 ~ var' $PASS | awk -F, 'BEGIN {OFS="\t"} \
			{ print $1, $2, $3, $4 }' |head -5| column -t
        exit
fi
 
######################################Get Username and Password
if [ $1 == "-gn" ]
then
		var=$2
        #Searches the name column for whatever user inputs
        search=`awk -F, -v var=$var '$2 ~ var' $PASS`

        #if search doesn't return anthing exits
		if [ -z "$search" ]
		then 
			echo "No records match that name"
			exit
        fi

        #Check number of results from search
        numResults=`echo "$search" | wc -l`
        #Let user choose option if theres more than one record for same website  
        if [ $numResults -gt 1 ]
        then
            echo "Choose one of the following options by typing it's corresponding number"
           
            #Returns the output of the search in comma separated format 
            #but hides line record number, url and password
	    	optns=`echo "$search" | awk -F, 'BEGIN {OFS=","} \
			{ print $2, $4 }'|head -5`

            #prints each line in optns with a option number 
            echo "Format: name, username"
            for i in $(seq 1 $numResults)
            do
                currOpt=`echo "$optns"| sed -n "$i"p`
                echo "$i) $currOpt "
            done
            read optnNum
          
            #searches the optn for the record with the username
            #that the user specified in above menu
          
            user=`echo "$optns" | awk -F, '{ print $2}'|sed -n "$optnNum"p`
            result=`echo "$search" |awk -F, -v var=$user '$4 ~ var'` # This is the record we want
            name=`echo "$result" | awk -F, '{print $2}'`
            password=`echo "$result" | awk -F, '{ print $5}'`
		else
            #name
            name=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $2}'`
            #username
            user=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $4}'`
            #password
            password=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $5}'`
        fi
 
        echo "Clipping username for $user at $name"
        echo $user|xclip -sel clip
        echo "Press enter for password"
        read -s trash
        echo $password|xclip -sel clip
        exit
        
elif [ $1 == "-gu" ]
then
        var=$2
        #Searches the name column for whatever user inputs
        search=`awk -F, -v var=$var '$3 ~ var' $PASS`

        #if search doesn't return anthing exits
        if [ -z "$search" ]
        then 
            echo "No records match that name"
            exit
        fi

        #Check number of results from search
        numResults=`echo "$search" | wc -l`
        #Let user choose option if theres more than one record for same website  
        if [ $numResults -gt 1 ]
        then
            echo "Choose one of the following options by typing it's corresponding number"
           
            #Returns the output of the search in comma separated format 
            #but hides line record number, url and password
            optns=`echo "$search" | awk -F, 'BEGIN {OFS=","} \
            { print $2, $3, $4 }'`

            #prints each line in optns with a option number 
            echo "Format: name, url , username"
            for i in $(seq 1 $numResults)
            do
                currOpt=`echo "$optns"| sed -n "$i"p`
                echo "$i) $currOpt "
            done
            read optnNum
           
            #searches the optn for the record with the username
            #that the user specified in above menu
            user=`echo "$optns" | awk -F, '{ print $3}'|sed -n "$optnNum"p`
            result=`echo "$search" |awk -F, -v var=$user '$4 ~ var'` # This is the record we want
            name=`echo "$result" | awk -F, '{print $2}'`
            password=`echo "$result" | awk -F, '{ print $5}'`
        else
            #name
            name=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $2}'`
            #username
            user=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $4}'`
            #password
            password=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $5}'`
        fi
 
            echo "Clipping username for $user at $name"
            echo $user|xclip -sel clip
			echo "Press enter for password"
            read $trash
            echo "Done."
            echo $password|xclip -sel clip
            exit
fi
################################Generate password
if [ $1 == "-gen" ]
then
	if [ -z $2 ]
	then
    newPass=`openssl rand -base64 16`
	echo $newPass|xclip -sel clip
	echo "16 character random password clipped"
	exit
	fi
    newPass=`openssl rand -base64 $2`
	echo $newPass|xclip -sel clip
	echo "$2 character random password clipped"
	exit
fi


###############################Directly searching by website name
var=$1
#Searches the name column for whatever user inputs
search=`awk -F, -v var=$var '$2 ~ var' $PASS`

#if search doesn't return anthing exits
if [ -z "$search" ]
then 
    echo "No records match that name"
    exit
fi

#Check number of results from search
numResults=`echo "$search" | wc -l`
#Let user choose option if theres more than one record for same website  
if [ $numResults -gt 1 ]
then
    echo "Choose one of the following options by typing it's corresponding number"
   
    #Returns the output of the search in comma separated format 
    #but hides line record number, url and password
    optns=`echo "$search" | awk -F, 'BEGIN {OFS=","} \
    { print $2, $4 }'|head -5`

    #prints each line in optns with a option number 
    echo "Format: name, username"
    for i in $(seq 1 $numResults)
    do
        currOpt=`echo "$optns"| sed -n "$i"p`
        echo "$i) $currOpt "
    done
    read optnNum
  
    #searches the optn for the record with the username
    #that the user specified in above menu
  
    user=`echo "$optns" | awk -F, '{ print $2}'|sed -n "$optnNum"p`
    result=`echo "$search" |awk -F, -v var=$user '$4 ~ var'` # This is the record we want
    name=`echo "$result" | awk -F, '{print $2}'`
    password=`echo "$result" | awk -F, '{ print $5}'`
else
    #name
    name=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $2}'`
    #username
    user=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $4}'`
    #password
    password=`awk -F, -v var=$var '$2 ~ var' $PASS | awk -F, '{ print $5}'`
fi

echo "Clipping username for $user at $name"
echo $user|xclip -sel clip
echo "Press enter for password"
read -s trash
echo $password|xclip -sel clip
exit
