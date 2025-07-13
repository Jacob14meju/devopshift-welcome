import boto3
import json
from boto3 import ClientError

vms = boto3.client('ec2')

vm = vms.describe_instances()

try:
    for reservation in vm['reservations']:
        for instance in reservation['Instances']:
            instance_state = "Instance state: " + instance['State']['Name']
            instance_id =  "Instance ID: " + instance['InstanceId']
            instance_ip =  'instance ip: ' + instance['PublicIpAddress']
            print(instance_state)
            print(instance_id)
            print(instance_ip)
    lbs = boto3.client('elbv2')

    response = lbs.describe_load_balancers()

    for lb in response['LoadBalancers']:
        lb_dns_name = 'load balancer dns name: ' + lb['DNSName']
        print(lb_dns_name)

    fin = {'instance state:': instance_state,
    'instance_id': instance_id,
    'instance_ip': instance_ip,
    'load_balancer_dns_name': lb_dns_name}

    with open('aws_validation.json', 'w') as f:
        f.write(json.dump(fin))

except ClientError as e:
    err = e.response['Error']['Message']
    print(f'Error: {err}')