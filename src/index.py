import sys
import json
import boto3 

sys.path.append('./lib')
import cfn_resource_response

def handler(event, context):
    try:
        s3 = boto3.resource('s3')

        # Create OR Update Request
        if event['RequestType'] == 'Create' or event['RequestType'] == 'Update':

            # fetch properties
            resource_properties = event['ResourceProperties']
            bucket_name = resource_properties.get('BucketName', None)
            bucket_key = resource_properties.get('BucketKey', None)
            desired_output = resource_properties.get('DesiredOutput', None)

            response_data = {}
            if bucket_name and bucket_key:
                
                # download terraform state file
                s3.meta.client.download_file(bucket_name, bucket_key, '/tmp/state_file.tfstate')
                state_file = json.load(open('/tmp/state_file.tfstate'))
                
                # desired output exists
                if desired_output and desired_output != '':
                    response_data[desired_output] = state_file['outputs'][desired_output]['value']
                
                # prepare response data with all values
                else:
                    outputs = state_file['outputs']
                    for key in outputs.keys():
                        response_data[key] = outputs[key]['value']

                cfn_resource_response.send(event, context, 'SUCCESS', response_data)

            else:
                cfn_resource_response.send(event, context, 'FAILED', {'Reason': 'Bucket name or key not provided'})

        # Delete Request
        elif event['RequestType'] == 'Delete':
            cfn_resource_response.send(event, context, 'SUCCESS', {'message': 'RequestType::Delete'})

        else:
            cfn_resource_response.send(event, context, 'FAILED', {'Reason': 'RequestType is not supported'})

    except Exception as error:
        cfn_resource_response.send(event, context, 'FAILED', {'Reason': error})
