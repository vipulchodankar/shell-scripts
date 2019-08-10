#first parameter is nth value
#Will print summation of 0 to n
SUM=0
echo -n "0"
for ((i = 1 ; i <= $1 ; i++)); do
	SUM=$((SUM + i));
	echo -n " + $i"
done
echo " = $SUM"
