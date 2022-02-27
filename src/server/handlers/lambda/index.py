import json
import csv
import boto3
import os
import datetime as dt

s3 = boto3.client('s3')

def handler(event, context):
    
    datestamp = dt.datetime.now().strftime("%Y/%m/%d")
    timestamp = dt.datetime.now().strftime("%s")
    
    filename_json = "/tmp/file_{ts}.json".format(ts=timestamp)
    filename_csv = "/tmp/file_{ts}.csv".format(ts=timestamp)
    keyname_s3 = "uploads/output/{ds}/{ts}.json".format(ds=datestamp, ts=timestamp)
    
    json_data = []

    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        key_name = record['s3']['object']['key']
        
    s3_object = s3.get_object(Bucket=bucket_name, Key=key_name)
    data = s3_object['Body'].read()
    contents = data.decode('utf-8')
    
    with open(filename_csv, 'a') as csv_data:
        csv_data.write(contents)
    
    with open(filename_csv) as csv_data:
        csv_reader = csv.DictReader(csv_data)
        for csv_row in csv_reader:
            json_data.append(csv_row)
            
    with open(filename_json, 'w') as json_file:
        json_file.write(json.dumps(json_data))
    
    with open(filename_json, 'r') as json_file_contents:
        response = s3.put_object(Bucket="snoop-json-eu-west-1-snoop-app20220227180520131000000001", Key=keyname_s3, Body=json_file_contents.read())

    os.remove(filename_csv)
    os.remove(filename_json)

    return {
        'statusCode': 200,
        'body': json.dumps('CSV converted to JSON and available at: {bucket}/{key}'.format(bucket=bucket_name,key=keyname_s3))
    }


