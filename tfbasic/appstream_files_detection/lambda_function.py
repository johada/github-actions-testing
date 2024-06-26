import boto3
import json
import os
import re
import urllib.parse



dynamodbClient = boto3.client('dynamodb')
table_name = 'test_appstream_files_detection_table'
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

def check_for_backupfiles(filePath):
    regex_pattern_logix_backup = r'\.BAK\d{3}\.ACD$'
    regex_pattern_arena_backup = r'\.Backup\.DOE$'
    regex_pattern_part = r'\.part$'
    combined_pattern = f"{regex_pattern_logix_backup}|{regex_pattern_arena_backup}|{regex_pattern_part}"
    
    filename = os.path.basename(filePath)
    pattern = re.compile(combined_pattern,re.IGNORECASE)
    # Check if the filename matches the regex pattern
    if pattern.search(filename):
        return True
    else: 
        return False

def getIgnoreExtensions():
    return ['.sem', '.wrk']


def getDynamoDbRecord(object_key):
    # Ignore folders
    _, extension = os.path.splitext(object_key)

    if extension == '' or check_for_backupfiles(object_key) or extension.lower()  in getIgnoreExtensions() :
        return None, None

    else:
        user_path = object_key.split('user/custom/')
        # Ignore metada for .vault folder
        if user_path[1].split('/')[1] == '.vault':
            return None, None

        aws_user_id_sha256 = user_path[1].split('/')
        pk =  aws_user_id_sha256[0]
        sk = "/".join(aws_user_id_sha256[1:])
        return pk, sk


def queryRecordByPk(pk):
    query_params = {
        'TableName': table_name,
        'KeyConditionExpression': 'pk = :val',
        'ExpressionAttributeValues': {
            ':val': {'S': pk}
        }
    }

    # Perform the query
    response = dynamodbClient.query(**query_params)
    return response


def saveRecord(pk, eventTime, sk, size):
    table.put_item(
        Item={
            'pk': pk,
            'sk': sk,
            'eventTime': eventTime,
            'size': size
        }
    )

def deleteRecord(pk, sk):
    _ = dynamodbClient.delete_item(
        TableName=table_name,
        Key={
            'pk': {'S': pk},
            'sk': {'S': sk}
        }
    )



def lambda_handler(event, context):
    for record in event['Records']:
        # Extracting event data
        event_name = record['eventName']
        object_key = record['s3']['object']['key']
        eventTime = record['eventTime']
        pk, sk = getDynamoDbRecord(object_key)
        sk_unquote_plus = urllib.parse.unquote_plus(sk)

        if pk != None and event_name != 'ObjectRemoved:Delete':
            size = record['s3']['object']['size']
            response = queryRecordByPk(pk)
            if response['Count'] <= 10:
                saveRecord(pk,eventTime, sk_unquote_plus,size)
            else:
                sorted_items = sorted(response['Items'], key=lambda x: x['eventTime']['S'])
                oldest_item = sorted_items[0]
                deleteRecord(oldest_item['pk']['S'], oldest_item['sk']['S'])
                saveRecord(pk,eventTime, sk_unquote_plus,size)
                
                
        elif pk != None and event_name == 'ObjectRemoved:Delete':
            deleteRecord(pk, sk_unquote_plus)



    return {
        'statusCode': 200,
        'body': json.dumps('Metadata saved successfully')
    }