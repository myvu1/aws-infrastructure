terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
    }
  }
}

provider "aws" {
  region = "eu-central-1" #gewünschteAWS-Region wählen
}

resource "aws_key_pair" "my_key_pair" {
  key_name = "my-key-pair"
  public_key = file("/home/hmv/.ssh/id_rsa.pub")
}

resource "ansible_group" "group" {
  name     = "test_group"
  children = ["test_dc1"]
  variables = {
    ansible_user       = "ec2_user"
    ansible_connection = "ssh"
  }
}

resource "aws_instance" "my_instance" {
  #count = var.instance_count
  ami           = "ami-04e601abe3e1a910f"  #geeignete AMI-ID für EC2-Instanz wählen
  instance_type = "t2.micro"  #den gewünschten Instanztyp wählen
  #tags = {
  #Name = "vm-${count.index}" 
  #}
  tags = {
    Name = "my_vm" 
  }

  security_groups = [aws_security_group.aws_vm_sg.name]
  key_name      = aws_key_pair.my_key_pair.key_name  #den Namen des Schlüsselpaares für den SSH-Zugriff wählen
}


resource "ansible_host" "my_instance" {
  name   = "my_vm"
  groups = ["test_dc1"]
}


resource "aws_security_group" "aws_vm_sg" {
  name = "aws-vm-sg"
  description = "security group for aws"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 80
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