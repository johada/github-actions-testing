import boto3
import time
from urllib import parse

TABLE_NAME = "test-token-validation-table"

def lambda_handler(event, _):
    try:
        params = dict(parse.parse_qsl(event['body'], strict_parsing=True))

        authToken = params.get('authenticationToken')


        dynamodb = boto3.client("dynamodb")
        scan = dynamodb.scan(
            TableName=TABLE_NAME,
            FilterExpression="pk = :AuthToken",
            ExpressionAttributeValues={
                ":AuthToken": {"S": authToken}
                }
        )

        count = scan["Count"]
        if count:
            expirationTime = int(scan["Items"][0]["ExpireAt"]["N"])
            if expirationTime < int(time.time()):
                return {
                    'statusCode': 200,
                    'body': '<auth result="no"><message>Token expired</message></auth>'
                }

            return {
                    'statusCode': 200,
                    'body': '<auth result="yes"><username>Administrator</username></auth>'
                }
        else:
            return {
                'statusCode': 200,
                'body': '<auth result="no"><message>Authentication token not found</message></auth>'
            }

    except:
        return {
            'statusCode': 200,
            'body': '<auth result="no"><message>Error calling /userinfo api</message></auth>'
        }

