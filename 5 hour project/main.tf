
provider "aws" {
    region = "us-east-1"
    }

resource "aws_vpc" "vm_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "vm-vpc"
    }
}
resource "aws_instance" "vm" {
    ami = "ami-0abcdef1234567890"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    subnet_id = aws_subnet.public_sub[0].id
    vpc_security_group_ids = [aws_security_group.vm_sg.id]
    tags = {
        Name = "vm"
    }
    }

resource "aws_security_group" "vm_sg" {
    name = "vm_sg"
    description = "Security group for VM"
    vpc_id = aws_vpc.vm_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
}


resource "aws_subnet" "public_sub" {
    count = 2
    vpc_id = aws_vpc.vm_vpc.id
    cidr_block = "10.0.${count.index}.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "public-subnet-${count.index + 1}"
    }
}

resource "aws_lb" "vm_lb" {
    name = "jacob-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.vm_sg.id]
    subnets = aws_subnet.public_sub[*].id
    enable_deletion_protection = false

    tags = {
        Name = "vm-lb"
    }
}

resource "aws_lb_target_group" "vm_tg" {
    name = "jacob-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vm_vpc.id

    tags = {
        Name = "vm-tg"
    }
}

resource "aws_lb_listener" "vm_listener" {
    load_balancer_arn = aws_lb.vm_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.vm_tg.arn
    }
}

resource "aws_lb_target_group_attachment" "vm_tg_attachment" {
    target_group_arn = aws_lb_target_group.vm_tg.arn
    target_id = aws_instance.vm.id
}

resource "aws_internet_gateway" "vm_igw" {
    vpc_id = aws_vpc.vm_vpc.id

    tags = {
        Name = "vm-igw"
    }
}

resource "aws_route_table" "vm_rt" {
    vpc_id = aws_vpc.vm_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vm_igw.id
    }
}

resource "aws_route_table_association" "vm_rta" {
    count = 2
    subnet_id = aws_subnet.public_sub[count.index].id
    route_table_id = aws_route_table.vm_rt.id

}

resource "null_resource" "waiting_for_vm_ip" {
    provisioner "local-exec" {
    command = <<EOT
      interval=30
      times=5
      for i in $(seq 1 $${times}); do
          if [ -z "${aws_instance.vm.public_ip}" ]; then
              echo "Waiting for VM to get public IP..."
              sleep $${interval}
          else
              exit 0
          fi
      done
      echo "ERROR: couldn't find associated public IP for VM"
      exit 1
    EOT
  }

  depends_on = [aws_instance.vm]
    }

locals {
  vm_ip_after_wait = aws_instance.vm.public_ip
  _enforce_dep     = null_resource.waiting_for_vm_ip.id
}


output "vm_public_ip" {
    value = local.vm_ip_after_wait
    description = "Public IP of the VM"
}

output "vm_id" {
    value = aws_instance.vm.id
    description = "ID of the VM"
}

output "lb_dns_name" {
    value = aws_lb.vm_lb.dns_name
    description = "DNS name of the Load Balancer"
}
