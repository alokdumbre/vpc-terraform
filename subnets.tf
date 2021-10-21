resource "aws_subnet" "public_1" {

  # The VPC ID.
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "10.0.1.0/24"

  # The AZ for the subnet.
  availability_zone = "ap-southeast-2a"

  # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource.
  tags = {
    Name                        = "public-ap-southeast-2a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}
resource "aws_subnet" "public_2" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "10.0.2.0/24"

  # The AZ for the subnet.
  availability_zone = "ap-southeast-2b"

  # Required for EKS. Instances launched into the subnet should be assigned a public IP address.
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource.
  tags = {
    Name                        = "public-ap-southeast-2b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "private_1" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "10.0.3.0/24"

  # The AZ for the subnet.
  availability_zone = "ap-southeast-2a"

  # A map of tags to assign to the resource.
  tags = {
    Name                              = "private-ap-southeast-2a"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_2" {
  # The VPC ID
  vpc_id = aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block = "10.0.4.0/24"

  # The AZ for the subnet.
  availability_zone = "ap-southeast-2b"

  # A map of tags to assign to the resource.
  tags = {
    Name                              = "private-ap-southeast-2b"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}
