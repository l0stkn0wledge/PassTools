#!/bin/bash
IFS=$'\t\n'

if [ $# -lt 1 ] 
then
	echo "Usage: stats.sh [results file] [wordlist]"
	echo ""
	echo "results file - combined output of username:password"
	echo "wordlist - Optional file of private terms (e.g. Company names/locations/etc)"
	echo "Be sure the wordlist is one word per line"
	exit -1
fi

TMPFILENAME=$(mktemp.exe)
cut -d':' -f2 $1 > $TMPFILENAME

printf "\n%35s\n" "Password Length Analysis"
printf "%20s%20s\n" "Length" "Count"
printf "%40s\n" "==============================="
LENSUB7=$(grep -c -E "^.{0,6}$" $TMPFILENAME)
printf "%20s%20d\n" ">=6" $LENSUB7

for (( i=7 ; i < 13; i++ )); do
	LENGTH=$(grep -c -E "^.{$i}$" $TMPFILENAME)
	printf "%20d%20d\n" "$i" $LENGTH
done
LENPLUS12=$(grep -c -E "^.{13,}$" $TMPFILENAME)
printf "%20s%20d\n" "13+" $LENPLUS12

PASSCOUNT=$(grep -c -i -E "p[a@4][zs$5]{1,2}w[o0]rd" $TMPFILENAME)
SEASONCOUNT=$(grep -c -i -E "f[a4@][\|!l1]|[@4a]utumn|[zs5$]pr[i!|1l]ng|[zs5$]umm[3e]r|w[i!|1l]nt[3e]r" $TMPFILENAME)
SECRETCOUNT=$(grep -c -i -E "[zs5$][e3][c\(]r[e3][t\+]" $TMPFILENAME)
printf "\n%35s\n" "Standard Word Analysis"
printf "%20s%20s\n" "Word" "Count"
printf "%40s\n" "==============================="
printf "%20s%20d\n" "Password" $PASSCOUNT
printf "%20s%20d\n" "Secret" $SECRETCOUNT
printf "%20s%20d\n" "Seasons" $SEASONCOUNT


if [ $# -eq 2 ]
then
	WORDLIST=($(cat $2))
	LEN=${#WORDLIST[@]}
	printf "\n%35s\n" "Wordlist Analysis"
	printf "%20s%20s\n" "Word" "Count"
	printf "%40s\n" "==============================="
	for (( i=0 ; i < $LEN; i++ )); do
		WORD=$(echo ${WORDLIST[i]} | sed 's/\r\n//g')
		COUNT=$(grep -c -i $WORD $TMPFILENAME)
		printf "%20s%20d\n" $WORD $COUNT
	done
fi

rm -f $TMPFILENAME

exit 0	
