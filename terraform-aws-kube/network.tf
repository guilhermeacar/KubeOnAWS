resource "aws_vpc" "VPC-K8S" {
  cidr_block = "10.50.0.0/16"
  tags = {
    Name = "VPC-K8S"
  }
}

resource "aws_subnet" "sb-priv-k8s-a" {
  vpc_id            = aws_vpc.VPC-K8S.id
  cidr_block        = "10.50.1.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "sb-priv-k8s-a"
  }
}

resource "aws_subnet" "sb-priv-k8s-b" {
  vpc_id            = aws_vpc.VPC-K8S.id
  cidr_block        = "10.50.2.0/24"
  availability_zone = "sa-east-1b"

  tags = {
    Name = "sb-priv-k8s-b"
  }
}

resource "aws_subnet" "sb-priv-k8s-c" {
  vpc_id            = aws_vpc.VPC-K8S.id
  cidr_block        = "10.50.3.0/24"
  availability_zone = "sa-east-1c"

  tags = {
    Name = "sb-priv-k8s-c"
  }
}

resource "aws_subnet" "sb-pub-k8s-a" {
  vpc_id            = aws_vpc.VPC-K8S.id
  cidr_block        = "10.50.4.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "sb-pub-k8s-a"
  }
}

resource "aws_subnet" "sb-pub-k8s-b" {
  vpc_id            = aws_vpc.VPC-K8S.id
  cidr_block        = "10.50.5.0/24"
  availability_zone = "sa-east-1b"

  tags = {
    Name = "sb-pub-k8s-b"
  }
}

resource "aws_subnet" "sb-pub-k8s-c" {
  vpc_id            = aws_vpc.VPC-K8S.id
  cidr_block        = "10.50.6.0/24"
  availability_zone = "sa-east-1c"

  tags = {
    Name = "sb-pub-k8s-c"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC-K8S.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.VPC-K8S.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "rt-public"
  }
}

resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.VPC-K8S.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat-gw.id
  }

  tags = {
    Name = "rt-private"
  }
}

resource "aws_route_table_association" "rt-association-pub-a" {
  subnet_id      = aws_subnet.sb-pub-k8s-a.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rt-association-pub-b" {
  subnet_id      = aws_subnet.sb-pub-k8s-b.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rt-association-pub-c" {
  subnet_id      = aws_subnet.sb-pub-k8s-c.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rt-association-priv-a" {
  subnet_id      = aws_subnet.sb-priv-k8s-a.id
  route_table_id = aws_route_table.rt-private.id
}

resource "aws_route_table_association" "rt-association-priv-b" {
  subnet_id      = aws_subnet.sb-priv-k8s-b.id
  route_table_id = aws_route_table.rt-private.id
}

resource "aws_route_table_association" "rt-association-priv-c" {
  subnet_id      = aws_subnet.sb-priv-k8s-c.id
  route_table_id = aws_route_table.rt-private.id
}
