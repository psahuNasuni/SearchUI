import base64
import json, logging
import pprint
import subprocess

import elasticsearch

import boto3
from datetime import *

# from awscli.errorhandler import ClientError
from elasticsearch.connection.http_requests import RequestsHttpConnection
from requests_aws4auth import AWS4Auth

from elasticsearch import Elasticsearch, helpers


def lambda_handler(event, context):
    # aws_reg = event['Records'][0]['awsRegion']
    # print(aws_reg)
    secret_data_internal = get_secret('nct-nce-internal-' + context.invoked_function_arn[76:], 'us-east-2')
    secret_nct_nce_admin = get_secret('nct/nce/os/admin', 'us-east-2')
    role = secret_data_internal['discovery_lambda_role_arn']
    role_data = '{"backend_roles":["arn:aws:iam::514960042727:user/sarwikar","' + role + '"],"hosts": [],"users": ["automation"]}'
    # data = '{\"backend_roles\":[\"arn:aws:iam::514960042727:user/ssa\"],\"hosts\": [],\"users\": [\"automation\",
    # \"arn:aws:iam::514960042727:user/sarwikar\",\"' + role + '\"]}'
    print(role_data)
    with open("/tmp/" + "/data.json", "w") as write_file:
        write_file.write(role_data)
    link = secret_nct_nce_admin['nac_kibana_url']
    link = link[:link.index('_')]
    username = secret_nct_nce_admin['nac_es_admin_user']
    password = secret_nct_nce_admin['nac_es_admin_password']
    data_file_obj = '/tmp/data.json'
    merge_link = '\"https://' + link + '_opendistro/_security/api/rolesmapping/all_access\"'
    cmd = 'curl -X PUT -u \"' + username + ':' + password + '\" -H "Content-Type:application/json" ' + merge_link + ' -d \"@/tmp/data.json\"'
    print(cmd)
    status, output = subprocess.getstatusoutput(cmd)
    print(output)
    print(link)
    es = launch_es(secret_nct_nce_admin['nac_es_url'], 'us-east-2')
    # search(es, '2021-12-01T09:17:45.274Z')
    resp = search(es, event)
    response = {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": '*'
        },
        "isBase64Encoded": False
    }
    response['body'] = json.dumps(resp)
    return response


def launch_es(link, region):
    # region = 'us-east-2'
    service = 'es'
    credentials = boto3.Session().get_credentials()
    print()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)
    es = Elasticsearch(hosts=[{'host': link, 'port': 443}], http_auth=awsauth, use_ssl=True, verify_certs=True,
                       connection_class=RequestsHttpConnection)
    return es


def search(es, event):
    print('event', event)
    print('queryStringParameters', event['queryStringParameters']['q'])

    try:
        for elem in es.cat.indices(format="json"):
            query = {
                "size": 25,
                "query": {
                    "multi_match": {
                        "query": event['queryStringParameters']['q'],
                        "fields": ["dest_bucket", "object_key", "size", "event_name", "awsRegion", "extension",
                                   "volume_name", "root_handle", "source_bucket", "content", "access_url"]
                    }
                }
            }
            resp = es.search(index=elem['index'], body=query)
            print(resp['hits']['hits'])
            return resp['hits']['hits']
            # for i in resp['hits']['hits']:
            #     pprint.pprint(i)
    except Exception as e:
        logging.error('ERROR: {0}'.format(str(e)))
        logging.error('ERROR: Unable to index line:"{0}"'.format(str(event)))
        print(e)


def get_secret(secret_name, region_name):
    secret = ''
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )

    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + secret_name + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        elif e.response['Error']['Code'] == 'DecryptionFailure':
            print("The requested secret can't be decrypted using the provided KMS key:", e)
        elif e.response['Error']['Code'] == 'InternalServiceError':
            print("An error occurred on service side:", e)
    else:
        # Secrets Manager decrypts the secret value using the associated KMS CMK
        # Depending on whether the secret was a string or binary, only one of these fields will be populated
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
            # print('text_secret_data',secret)
        else:
            secret = base64.b64decode(get_secret_value_response['SecretBinary'])
            # print('text_secret_data',secret)
    return json.loads(secret)

