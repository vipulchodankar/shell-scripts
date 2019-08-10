#first parameter is value whose factorial you wish to find
factorial=1;
for ((i = 1 ; i <= $1 ; i++)); do
	factorial=$((factorial * i))
done
echo "$1! = $factorial"

