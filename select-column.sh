#Simple script to extract a column from a csv file
#first parameter is a csv file
#second parameter is column number
#usage: bash select-column.sh 'csv-file' 'column-number'

for filename in $1
do
	cut -d , -f $2 $filename
done
