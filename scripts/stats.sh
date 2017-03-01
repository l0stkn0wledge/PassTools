#!/bin/bash
IFS=$'\t\n'

# Function design count the password character usage
# by class and stores the values to the global values
# which are used in the main operation of the script 
# to output the results to the screen.

charclass () {
	local NLOW=$(grep -c -E "[[:lower:]]" $TMPFILENAME)
	local NUPP=$(grep -c -E "[[:upper:]]" $TMPFILENAME)
	local NDIG=$(grep -c -E "[[:digit:]]" $TMPFILENAME)
	local NSPC=$(grep -c -E "[[:punct:] | [:blank:]]" $TMPFILENAME)
 
	local NLU=$(grep -E "[[:lower:]]" $TMPFILENAME | grep -c -E "[[:upper:]]")
	local NLD=$(grep -E "[[:lower:]]" $TMPFILENAME | grep -c -E "[[:digit:]]")
	local NLS=$(grep -E "[[:lower:]]" $TMPFILENAME | grep -c -E "[[:punct:] | [:blank:]]")
	local NLDS=$(grep -E "[[:lower:]]" $TMPFILENAME | grep -E "[[:digit:]]" | grep -c -E "[[:punct:] | [:blank:]]")
	local NLUD=$(grep -E "[[:lower:]]" $TMPFILENAME | grep -E "[[:upper:]]" | grep -c -E "[[:digit:]]")
	local NLUS=$(grep -E "[[:lower:]]" $TMPFILENAME | grep -E "[[:upper:]]" | grep -c -E "[[:punct:] | [:blank:]]")
	local NALL=$(grep -E "[[:lower:]]" $TMPFILENAME | grep -E "[[:upper:]]" | grep -E "[[:digit:]]" | grep -c -E "[[:punct:] | [:blank:]]")
 
	local NUD=$(grep -E "[[:upper:]]" $TMPFILENAME | grep -c -E "[[:digit:]]")
	local NUS=$(grep -E "[[:upper:]]" $TMPFILENAME | grep -c -E "[[:punct:] | [:blank:]]")
	local NUDS=$(grep -E "[[:upper:]]" $TMPFILENAME | grep -E "[[:digit:]]" | grep -c -E "[[:punct:] | [:blank:]]")
 
	local NDS=$(grep -E "[[:digit:]]" $TMPFILENAME | grep -c -E "[[:punct:] | [:blank:]]")

	QUADCOUNT=$NALL
	TRIPCOUNT=$(($NLUS + $NLUD + $NLDS + $NUDS - 4 * $QUADCOUNT))
	DUALCOUNT=$(($NUD + $NUS + $NDS + $NLD + $NLU + $NLS - 3*$TRIPCOUNT - 6*$QUADCOUNT))
	SINGLECOUNT=$(($NLOW + $NUPP + $NDIG + $NSPC - 2*$DUALCOUNT - 3*$TRIPCOUNT - 4*$QUADCOUNT))
}

if [ $# -lt 1 ] 
then
	echo "Usage: stats.sh [results file] [wordlist]"
	echo ""
	echo "results file - combined output of username:password"
	echo "wordlist - Optional file of private terms (e.g. Company names/locations/etc)"
	echo "Be sure the wordlist is one word per line"
	exit -1
fi

TMPFILENAME=$(mktemp)
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



charclass
printf "\n%35s\n" "Password Composition Analysis"
printf "%20s%20s\n" "# of Types" "Count"
printf "%40s\n" "==============================="
printf "%20s%20d\n" "1" $SINGLECOUNT
printf "%20s%20d\n" "2" $DUALCOUNT
printf "%20s%20d\n" "3" $TRIPCOUNT
printf "%20s%20d\n" "4" $QUADCOUNT

PASSCOUNT=$(grep -c -i -E "p[a@4][zs$5]{1,2}w[o0]rd" $TMPFILENAME)
SEASONCOUNT=$(grep -c -i -E "f[a4@][\|!l1]|[@4a]utumn|[zs5$]pr[i!|1l]ng|[zs5$]umm[3e]r|w[i!|1l]nt[3e]r" $TMPFILENAME)
SECRETCOUNT=$(grep -c -i -E "[zs5$][e3][c\(]r[e3][t\+]" $TMPFILENAME)
MONTHCOUNT=$(grep -c -i -E "January|February|March|April|May|June|July|August|September|October|November|December" $TMPFILENAME)
DAYCOUNT=$(grep -c -i -E "Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday" $TMPFILENAME)
printf "\n%35s\n" "Standard Word Analysis"
printf "%20s%20s\n" "Word" "Count"
printf "%40s\n" "==============================="
printf "%20s%20d\n" "Password" $PASSCOUNT
printf "%20s%20d\n" "Secret" $SECRETCOUNT
printf "%20s%20d\n" "Seasons" $SEASONCOUNT
printf "%20s%20d\n" "Months" $MONTHCOUNT
printf "%20s%20d\n" "Days of the Week" $DAYCOUNT

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
