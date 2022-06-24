import json
import boto3
import cfnresponse

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

            if bucket_name and bucket_key:
                
                # download terraform state file
                s3.meta.client.download_file(bucket_name, bucket_key, '/tmp/state_file.tfstate')
                state_file = json.load(open('/tmp/state_file.tfstate'))

                response_data = {}
                
                # desired output exists
                if desired_output and desired_output != '':
                    response_data[desired_output] = state_file['outputs'][desired_output]['value']
                
                # prepare response data with all values
                else:
                    outputs = state_file['outputs']
                    for key in outputs.keys():
                        response_data[key] = outputs[key]['value']

                cfnresponse.send(event, context, cfnresponse.SUCCESS, response_data)

            else:
                cfnresponse.send(event, context, cfnresponse.FAILED, {'Reason': 'Bucket name or key not provided'})

        # Delete Request
        elif event['RequestType'] == 'Delete':
            cfnresponse.send(event, context, cfnresponse.SUCCESS, {'message': 'RequestType::Delete'})

        else:
            cfnresponse.send(event, context, cfnresponse.FAILED, {'Reason': 'RequestType is not supported'})

    except Exception as error:
        cfnresponse.send(event, context, cfnresponse.FAILED, {'Reason': error})
