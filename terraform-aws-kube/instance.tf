resource "aws_network_interface" "NIC-k8s-master-node" {
  subnet_id       = aws_subnet.sb-priv-k8s-a.id
  security_groups = [aws_security_group.k8s-master.id]
  tags = {
    Name = "k8s-master-node"
  }
}

resource "aws_network_interface" "NIC-k8s-worker-node-1" {
  subnet_id       = aws_subnet.sb-priv-k8s-b.id
  security_groups = [aws_security_group.k8s-worker.id]

  tags = {
    Name = "k8s-worker-node-1"
  }
}

resource "aws_network_interface" "NIC-k8s-worker-node-2" {
  subnet_id       = aws_subnet.sb-priv-k8s-c.id
  security_groups = [aws_security_group.k8s-worker.id]

  tags = {
    Name = "k8s-worker-node-2"
  }
}

resource "aws_network_interface" "NIC-k8s-nfs" {
  subnet_id       = aws_subnet.sb-priv-k8s-c.id
  security_groups = [aws_security_group.k8s-nfs.id]

  tags = {
    Name = "k8s-nfs"
  }
}



resource "aws_instance" "k8s-master-node" {
  ami           = "ami-077518a464c82703b"
  instance_type = "t3.micro"
  key_name      = "k8s-prod"


  network_interface {
    network_interface_id = aws_network_interface.NIC-k8s-master-node.id
    device_index         = 0
  }
  tags = {
    Name = "k8s-master-node"
  }
}

resource "aws_instance" "k8s-worker-node-1" {
  ami           = "ami-077518a464c82703b"
  instance_type = "t3.micro"
  key_name      = "k8s-prod"


  network_interface {
    network_interface_id = aws_network_interface.NIC-k8s-worker-node-1.id
    device_index         = 0
  }
  tags = {
    Name = "k8s-worker-node-1"
  }
}

resource "aws_instance" "k8s-worker-node-2" {
  ami           = "ami-077518a464c82703b"
  instance_type = "t3.micro"
  key_name      = "k8s-prod"

  network_interface {
    network_interface_id = aws_network_interface.NIC-k8s-worker-node-2.id
    device_index         = 0
  }
  tags = {
    Name = "k8s-worker-node-2"
  }
}

resource "aws_instance" "k8s-bastion" {
  ami                         = "ami-0deebba34ef22f5a9"
  instance_type               = "t3.micro"
  key_name                    = "k8s-prod"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.sb-pub-k8s-a.id
  vpc_security_group_ids      = [aws_security_group.k8s-bastion.id]
  user_data                   = <<EOF
  #!/bin/bash
  apt-get update
  apt-get -y install ansible 

  EOF


  tags = {
    Name = "k8s-bastion"
  }
}

resource "aws_instance" "nat-gw" {
  ami                         = "ami-0800f9916b7655289"
  instance_type               = "t3.micro"
  key_name                    = "k8s-prod"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.sb-pub-k8s-b.id
  vpc_security_group_ids      = [aws_security_group.nat-gw.id]
  source_dest_check           = false
  user_data                   = <<EOF
  #!/bin/bash
  sudo sysctl -w net.ipv4.ip_forward=1
  sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  sudo yum install -y iptables-services
  sudo service iptables save

  EOF

  tags = {
    Name = "nat-gw"
  }
}

resource "aws_instance" "k8s-nfs" {
  ami           = "ami-0800f9916b7655289"
  instance_type = "t3.micro"
  key_name      = "k8s-prod"
  user_data                   = <<EOF
  #!/bin/bash
  mkdir /opt/k8s
  chmod -R 755 /opt/k8s/
  chown nfsnobody:nfsnobody /opt/k8s/
  echo "/opt/k8s    10.50.0.0/16(rw,sync,no_root_squash,no_all_squash)" > /etc/exports
  systemctl restart nfs-server

  EOF

  network_interface {
    network_interface_id = aws_network_interface.NIC-k8s-nfs.id
    device_index         = 0
  }
  tags = {
    Name = "k8s-nfs"
  }
}

