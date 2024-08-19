#!/bin/bash

# Function to display usage
help() {
    echo "Usage: $0 {create|delete|list|upload|download|delete-obj|list-obj} <bucket_name> <file_name|object_key>"
    echo "  create: Create an S3 bucket"
    echo "  delete: Delete an S3 bucket"
    echo "  list: List all S3 buckets"
    echo "  upload: Upload a file to an S3 bucket"
    echo "  download: Download a file from an S3 bucket"
    echo "  delete-obj: Delete an object from an S3 bucket"
    echo "  list-obj: List all objects in an S3 bucket"
    exit 1
}



# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "AWS CLI is not configured. Please configure it using 'aws configure' before running this script."
    exit 1
fi

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    help
fi

# Get the operation, bucket name, and file name/object key from arguments
operation=$1
bucket_name=$2
file_name=$3
object_key=$3  # For delete-obj and download, use object_key

# Perform the operation based on the argument
case $operation in
    create)
        if [ -z "$bucket_name" ]; then
            echo "Error: bucket_name is required for create operation."
            echo "run $0 help"
        fi
        echo "Creating bucket: $bucket_name"
        aws s3 mb s3://"$bucket_name"
        ;;
    delete)
        if [ -z "$bucket_name" ]; then
            echo "Error: bucket_name is required for delete operation."
            echo "run $0 help"
        fi
        echo "Deleting bucket: $bucket_name"
        aws s3 rb s3://"$bucket_name" --force
        ;;
    list)
        echo "Listing all buckets"
        aws s3 ls
        ;;
    upload)
        if [ -z "$bucket_name" ] || [ -z "$file_name" ]; then
            echo "Error: bucket_name and file_name are required for upload operation."
            help
        fi
        echo "Uploading $file_name to bucket: $bucket_name"
        aws s3 cp "$file_name" s3://"$bucket_name"/
        ;;$
    download)
        if [ -z "$bucket_name" ] || [ -z "$object_key" ]; then
            echo "Error: bucket_name and object_key are required for download operation."
            echo "run $0 help"
        fi
        echo "Downloading $object_key from bucket: $bucket_name"
        aws s3 cp s3://"$bucket_name"/"$object_key" .
        ;;
    delete-obj)
        if [ -z "$bucket_name" ] || [ -z "$object_key" ]; then
            echo "Error: bucket_name and object_key are required for delete-obj operation."
            echo "run $0 help"
        fi
        echo "Deleting object $object_key from bucket: $bucket_name"
        aws s3 rm s3://"$bucket_name"/"$object_key"
        ;;
    list-obj)
        if [ -z "$bucket_name" ]; then
            echo "Error: bucket_name is required for list-obj operation."
            echo "run $0 help"
        fi
        echo "Listing objects in bucket: $bucket_name"
        aws s3 ls s3://"$bucket_name"/
        ;;
    *)
        echo "Error: Invalid operation."
        echo "run $0 help"
        ;;
esac