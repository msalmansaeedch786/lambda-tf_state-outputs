#!/bin/bash

bucketname=$1
if [[ $(aws s3api create-bucket --bucket $bucketname) ]]; then
	echo "$bucketname created!"
else
	echo "Error in creating $bucketname"
fi

