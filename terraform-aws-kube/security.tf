resource "aws_key_pair" "k8s-prod" {
  key_name   = "k8s-prod"
  public_key = "<sua chave publica>"
}


resource "aws_security_group" "k8s-worker" {
  name        = "k8s-worker"
  description = "k8s-worker"
  vpc_id      = aws_vpc.VPC-K8S.id

  ingress {
    description = "Acesso rede interna"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.VPC-K8S.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-worker"
  }
}

resource "aws_security_group" "k8s-master" {
  name        = "k8s-master"
  description = "k8s-master"
  vpc_id      = aws_vpc.VPC-K8S.id

  ingress {
    description = "Acesso rede interna"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.VPC-K8S.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_security_group" "k8s-bastion" {
  name        = "k8s-bastion"
  description = "k8s-bastion"
  vpc_id      = aws_vpc.VPC-K8S.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<seu ip publico>"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-bastion"
  }
}

resource "aws_security_group" "nat-gw" {
  name        = "nat-gw"
  description = "nat-gw"
  vpc_id      = aws_vpc.VPC-K8S.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<seu ip publico>"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.50.0.0/16"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.50.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.50.0.0/16"]
  }

  tags = {
    Name = "nat-gw"
  }
}

resource "aws_security_group" "k8s-nfs" {
  name        = "k8s-nfs"
  description = "k8s-nfs"
  vpc_id      = aws_vpc.VPC-K8S.id

  ingress {
    description = "Acesso rede interna"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.VPC-K8S.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-nfs"
  }
}

resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "lb-sg"
  vpc_id      = aws_vpc.VPC-K8S.id

  ingress {
    description = "Acesso app publica"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Acesso app publica"
    from_port   = 443
    to_port     = 443
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
    Name = "lb-sg"
  }
}

resource "aws_iam_server_certificate" "test_cert" {
  name             = "test_cert"
  certificate_body = file("cert/you-cert.crt")
  private_key      = file("cert/you-cert.key")
}
