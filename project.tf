provider "aws" {
    region = "enter your region"
    access_key = "Enter Your access key"
    secret_key = "Enter Your secret key"
}
# CREATE A VPC 
resource "aws_vpc" "Myvpc" {
    cidr_block = "192.168.0.0/16"
    tags = {
        name = "My-Production"
    }
}

#CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.Myvpc.id
}

#CREATE ROUTE TABLE

resource "aws_route_table" "Route_table" {
    vpc_id = aws_vpc.Myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
    }

    tags = {
        name = "Pro-RT"

    }
}

#CREATE A SUBNET
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = "192.168.1.0/24"
    availability_zone = "us-east-1a"
    
}
resource "aws_subnet" "subnet-2" {
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = "192.168.2.0/24"
    availability_zone = "us-east-1b"  
}
resource "aws_subnet" "subnet-3" {
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = "192.168.3.0/24"
    availability_zone = "us-east-1c"
}
    
resource "aws_subnet" "subnet-4" {
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = "192.168.4.0/24"
    availability_zone = "us-east-1d"

}

#Associate subnet with Route-table
resource "aws_route_table_association" "subnet_association" {
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.Route_table.id
}
# 6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "Access_webserver" {
    name = "Allow_web-traffic"
    description = "allow inbound traffic"
    vpc_id = aws_vpc.Myvpc.id

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description ="SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Creating a network interface
resource "aws_network_interface" "nic" {
    subnet_id = aws_subnet.subnet-1.id
    private_ips = ["192.168.1.45"]
    security_groups = [aws_security_group.Access_webserver.id]
}

#Creating Elastic IPS
resource "aws_eip" "Elastic_IP" {
    vpc = true
    network_interface = aws_network_interface.nic.id
    associate_with_private_ip = "192.168.1.45"
    depends_on = [aws_internet_gateway.gateway]
}

#Create an ubuntu server
resource "aws_instance" "Ubuntu-instance" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "My-linux-AccessKey"

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your ubuntu web server > /var/www/html/index.html'
                EOF
    tags = {
        name = "ubuntu-server"
    }
}

