terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
  region     = "ap-southeast-2"
}
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "terra-vpc"
  }
}

resource "aws_subnet" "privateSub1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "priv-subnet-1"
  }
}

resource "aws_subnet" "privateSub2" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "priv-subnet-2"
  }
}

resource "aws_subnet" "publicSub1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-1"
  }
}

resource "aws_subnet" "publicSub2" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "IGW-terra-vpc"
  }
}

resource "aws_eip" "elasticip" {
  vpc      = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.publicSub2.id

  tags = {
    Name = "Nat-Gateway-terra-vpc"
  }
}

resource "aws_route_table" "vpcpubRT" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }


  tags = {
    Name = "Public-RouteTable"
  }
}
resource "aws_route_table_association" "pubassociate1" {
  subnet_id      = "${aws_subnet.publicSub1.id}"
  route_table_id = "${aws_route_table.vpcpubRT.id}"
}
resource "aws_route_table_association" "pubassociate2" {
  subnet_id      = "${aws_subnet.publicSub2.id}"
  route_table_id = "${aws_route_table.vpcpubRT.id}"
}

resource "aws_route_table" "vpcprivRT" {
  vpc_id = "${aws_vpc.main.id}"

  route {

    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw.id}"
    
  }


  tags = {
    Name = "Private-RouteTable"
  }
}

resource "aws_route_table_association" "privassociate1" {
  subnet_id      = "${aws_subnet.privateSub1.id}"
  route_table_id = "${aws_route_table.vpcprivRT.id}"
}
resource "aws_route_table_association" "privassociate2" {
  subnet_id      = "${aws_subnet.privateSub2.id}"
  route_table_id = "${aws_route_table.vpcprivRT.id}"
}


############################ SG part #############################################

resource "aws_security_group" "Apachesg" {
  name        = "wp"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "All traffic allow" 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Apachesg"
  }
}

resource "aws_instance" "Apacheinstance" {
  ami           = "ami-0210560cedcb09f07"   ###Amazon linux 2 instance #####
  instance_type = "t2.micro"
  key_name      = "clusterKey"
  subnet_id =  aws_subnet.publicSub1.id
  vpc_security_group_ids = [ aws_security_group.Apachesg.id ]
  tags = {
    Name = "Apache linux instance"
  }
}

#######################SG for private instance ###############################

resource "aws_security_group" "privec2sg" {
  name        = "basic"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "All traffic allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "DBinstance" {
  ami           = "ami-0210560cedcb09f07"
  instance_type = "t2.micro"
  key_name      = "clusterKey"
  subnet_id =  aws_subnet.privateSub1.id
  vpc_security_group_ids = [ aws_security_group.privec2sg.id ]
  tags = {
    Name = "private EC2 instance"
  }
}
