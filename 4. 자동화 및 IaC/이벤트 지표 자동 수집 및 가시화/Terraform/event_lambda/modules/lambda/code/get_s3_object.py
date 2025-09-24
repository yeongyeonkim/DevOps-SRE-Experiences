import boto3
import json
import os
from datetime import datetime

def get_s3_object(event, context):
    s3_client = boto3.client('s3')
    
    try:
        # S3에서 직접 파일 읽기
        response = s3_client.get_object(
            Bucket=os.environ.get('S3_BUCKET_NAME'),
            Key=os.environ.get('JSON_FILE_KEY')
        )
        
        # JSON 데이터 파싱
        data = json.loads(response['Body'].read())
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json',
                'Cache-Control': 'no-cache'
            },
            'body': json.dumps(data)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }