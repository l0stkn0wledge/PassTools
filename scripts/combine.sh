#!/bin/bash
IFS=$'\t\n'

if [ $# -ne 3 ]
then
	echo "Usage: combine.sh [results file] [original file] [output file]"
	echo ""
	echo "If cracking multiple sets, you can use the pot file as the results file"
    	echo "if you have a large pot file, this may take a LONG time to run, so the"
    	echo "recommendation is to always use output files unique for each assessment."
	exit -1
fi

# Create the array of hashes and the found passwords
# The sed in PASSES should make those safe for search later
HASHES=($(cut -d':' -f1 $1 | sed -e 's/[\/&\s]/\\&/g'))
PASSES=($(cut -d':' -f2 $1 | sed -e 's/[\/&\s]/\\&/g'))

# Generate the output file as a copy of the original
# search for the found hashes and only copy out the
# credential pairs that have found hashes.
cut -d':' -f1 $1 | xargs -I {} -xn1 grep {} $2 > $3

LEN=${#HASHES[@]}

# For each found hash in the output file, substitute the hash
# with the found password. This is done globally because users
# may have the same weak passwords.
for (( i=0 ; i < $LEN; i++ )); do
	printf "\r $i of $LEN"
	sed -i "s/${HASHES[$i]}/${PASSES[i]}/g" $3
done

exit 0
