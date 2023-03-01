
printf "\t"
cut -f1 $1|sort | tr "\n" "\t" | sed "s/\t$/\n/g"

while test $# -gt 0; do
	a=${1/.txt/}
	printf ${a/dist-/}"\t"
	sort -k1 $1| cut -f2 | tr "\n" "\t" | sed "s/\t$/\n/g"
	shift
done
#printf "%s\t" "${1%.*}" | sed "s/.*dist\-//g" 
#printf "%s\t" "mix" 

