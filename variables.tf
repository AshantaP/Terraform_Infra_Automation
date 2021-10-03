variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-south-1"
}

variable "key_name" {
  description = " SSH keys to connect to ec2 instance"
  default     =  "terraformkey"
}

variable "instance_type" {
  description = "instance type for ec2"
  default     =  "t2.micro"
}

variable "security_group" {
  description = "Name of security group"
  default     = "my-jenkins-security-group"
}

variable "tag_name" {
  description = "Tag Name of for Ec2 instance"
  default     = "my-ec2-instance"
}

variable "ami_id" {
  description = "AMI for Ubuntu Ec2 instance"
  default     = "ami-0c1a7f89451184c8b"
}
variable "access_key" {
  description = "Creds for access key"
  default = "AKIAT2Y5BMUZ4XU262AL"
}

variable "secret_key" {
  description = "Creds for secret key"
  default = "yr2X5ijYHLeQ87bWQEfDbBOljlLlez+UAxKf7O4a"
  
}
