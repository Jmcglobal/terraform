provider "aws" {
    region = "enter your region"
    access_key = "Enter Access-key"
    secret_key = "Enter secret key"
}

#CREATING A VPC AND DEPLOYING A SUBNET
resource "aws_vpc" "Myvpc" {
    cidr_block = "192.168.0.0/16"
    tags = {
        name = "production"
    }
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = "192.168.1.0/24"
    tags = {
        name = "Myvpc-subnet-1"
    }
}

# CREATING A EC2 INSTANCE AND ADDING TAGS
resource "aws_instance" "Myinstance" {
    ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    #adding tags after first deploy
    tags = {
       name = "Myubuntu"
    }
}
#Provisioning Ec2 instance
# resource "<provider>_<resource_type>" "name"{
#     key ="value"
#     key2 = "anaothervalue"
# }
