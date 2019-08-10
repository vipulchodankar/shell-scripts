#first parameter is number whose table is to be found
#second parameter is number upto which table is to be found
NUM=$1
for ((i = 1 ; i <= $2 ; i++)); do
	echo "$NUM * $i = $((NUM*i))"
done
