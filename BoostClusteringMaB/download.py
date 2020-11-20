import boto3
import argparse

service_name = 's3'
endpoint_url = 'https://kr.object.ncloudstorage.com'
region_name = 'kr-standard'

parser = argparse.ArgumentParser(description='ncloudDownload')
parser.add_argument('--access_key', type=str)
parser.add_argument('--secret_key', type=str)

if __name__ == "__main__":
    args = parser.parse_args()
    s3 = boto3.client(service_name, endpoint_url=endpoint_url, aws_access_key_id=args.access_key, aws_secret_access_key=args.secret_key)
    bucket_name = 'boostcamp-map-b'

    object_name = 'Pods.zip'
    local_file_path = './Pods.zip'

    s3.download_file(bucket_name, object_name, local_file_path)
