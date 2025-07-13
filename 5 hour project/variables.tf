variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default = "us-east-1"
validation {
  condition     = contains(["us-east-1"], var.aws_region)
    error_message = "The AWS region must be us-east-1."
}  
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  validation {
    condition     = contains(["ami-02bf8ce06a8ed6092", "ami-0af9b40b1a16fe700"], var.ami_id)
    error_message = "The AMI ID must be ami-0abcdef1234567890"
  }
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  validation {
    condition     = contains(["t2.micro", "t2.medium"], var.instance_type)
    error_message = "The instance type must be one of t2.micro or t2.medium."
  }
  
}

variable "availability_zone" {
  description = "The availability zone to deploy the EC2 instance in"
  type        = list(string)
  default = ["us-east-1a", "us-east-1b"]
  validation {
    condition     = alltrue([
      for az in var.availability_zone :contains(["us-east-1a", "us-east-1b"], az)
    ])
    error_message = "The availability zone must be one of us-east-1a or us-east-1b."
  }
  
}

variable "lb_name" {
  description = "The name of the load balancer"
  type        = string
}

variable "tg-name" {
  description = "the name of the target group"
  type = string
}