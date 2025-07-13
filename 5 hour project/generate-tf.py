from jinja2 import Environment, FileSystemLoader
env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('main.tf.j2')

aws_region = str(input("enter your AWS region: "))
ami_id = str(input("enter your AMI ID: "))
instance_type = str(input("enter your instance type: "))
availability_zone = str(input("enter your availability zone: "))
lb_name = str(input("enter your load balancer name: "))
tg_name = str(input("enter your target group name: "))


data = {'aws_region': aws_region,
        'ami_id': ami_id,
        'instance_type': instance_type,
        'availability_zone': availability_zone,
        'lb_name': lb_name,
        'tg_name': tg_name}


output = template.render(data)
try:
    with open('main.tf', 'w') as f:
        f.write(output)
except Exception as e:
    print(f"Error writing to file: {e}")

print("Terraform configuration file 'main.tf' has been generated successfully.")