provider "aws" {
    region = "ap-south-1"
    access_key = "AKIAT2Y5BMUZZJVTPAKM"
    secret_key = "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"
  
}

#Create VPC

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "production"
    }
  
}

#Create Internet Gateway

resource "aws_internet_gateway" "prod-gw" {
    vpc_id = aws_vpc.prod-vpc.id
    tags = {
      "Name" = "prod-gateway"
    }
  
}

#Custom Routing Table
resource "aws_route_table" "prod-route-table" {
    vpc_id = aws_vpc.prod-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod-gw.id

    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.prod-gw.id

    }

    tags = {
      "Name" = "prod-route-table"
    }
  
}

# 4. Create a Subnet

resource "aws_subnet" "prod-subnet" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      "Name" = "prod-subnet"
    }
  
}
# 5. Associate with subnet to Routing Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port# 22, 80, 443

resource "aws_security_group" "allow_web" {
    name = "allow_web_traffic"
    description = "Allow web inbound traffic"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        
    }
    ingress {
        description = "SSH"
        from_port = 2
        to_port = 2
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      "Name" = "allow_web"
    }
  
}

# 7. Create a network interface with an IP in the subnet that was created in step-4

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.prod-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]


}
# 8. Assign an Elastip IP to the network interface created in step-7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.prod-gw]
}

# 9. Create ubuntu server and install apache-2

resource "aws_instance" "web-server-instance" {
    ami = "ami-0c1a7f89451184c8b"
    instance_type = "t2.micro"
    availability_zone = "ap-south-1a"
    key_name = "main-key"

    network_interface {
      device_index = "0"
      network_interface_id = aws_network_interface.web-server-nic.id
      
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install apache2 -y
                sudo systemctl start apache2 -y
                sudo bash -c "echo your very fast webserver > /var/www/html/index.html'
                EOF
    tags = {
      "Name" = "web-server"
    }
  
}
