#!/bin/bash

#Author: Bernhard Ludwig
#Based on docker-convenience-scripts by: Guido Diepen

#Convenience script that can help me to easily create a backup of a given
#data volume. The script is mainly useful if you are using named volumes

OUTDIR="$(pwd)/archives"
OUTFILE="/$1.tgz"
USR_ID=$(id --user)
GRP_ID=$(id --group)
mkdir -p $OUTDIR

#First check if the user provided all needed arguments
if [ "$1" = "" ]
then
        echo "Please provide a source volume name"
        exit
fi

#Check if the source volume name does exist
docker volume inspect $1 > /dev/null 2>&1
if [ "$?" != "0" ]
then
        echo "The source volume \"$1\" does not exist"
        exit
fi

#Now check if the destination file name does not yet exist
if [ -f "$OUTDIR$OUTFILE" ]
then
        echo "The destination file \"$OUTDIR$OUTFILE\" already exists"
        exit
fi


echo "Creating archive \"$OUTDIR$OUTFILE\"..."
echo "Archiving data from source volume \"$1\" to \"$OUTFILE\"..."
docker run --rm \
           -i \
           -t \
           -v $1:/from \
           -v $OUTDIR:/to \
           alpine ash -c "cd /from ; tar -cpzf /to$OUTFILE .; chown $USR_ID:$GRP_ID /to$OUTFILE"
