# lambda_function.py
import json
from get_s3_object import get_s3_object
from create_event_json import create_event_json

def lambda_handler(event, context):
    # EventBridge
    if 'source' in event and event.get('source') == 'aws.events':
        return create_event_json(event, context)
    
    # API Gateway
    elif 'httpMethod' in event and 'path' in event:
        return get_s3_object(event, context)
    
    else:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Unknown event source'})
        }