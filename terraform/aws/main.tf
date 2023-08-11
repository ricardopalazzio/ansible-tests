provider "aws" {
  region = "us-east-1"
}


variable "ami_id" {
  description = "debian 12 ami id"
  default     = "ami-06db4d78cb1d3bbf9"
}

resource "aws_default_vpc" "default_vpc" {
  force_destroy = false
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  # using default VPC
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "TLS from VPC"

    # we should allow incoming and outoging
    # TCP packets
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "bechmark"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "ec2_m5_debian" {
  ami             = var.ami_id
  instance_type   = "m5.2xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-m5"
  }
}

resource "aws_instance" "ec2_m5a_debian" {
  ami             = var.ami_id
  instance_type   = "m5a.2xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-m5a"
  }
}

resource "aws_instance" "ec2_m6i_debian" {
  ami             = var.ami_id
  instance_type   = "m6i.2xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-m6i"
  }
}

resource "aws_instance" "ec2_m6a_debian" {
  ami             = var.ami_id
  instance_type   = "m6a.2xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-m6a"
  }
}

resource "aws_instance" "ec2_c6a_debian" {
  ami             = var.ami_id
  instance_type   = "c6a.xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-c6a"
  }
}

resource "aws_instance" "ec2_c6i_debian" {
  ami             = var.ami_id
  instance_type   = "c6i.xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-c6i"
  }
}


resource "aws_instance" "ec2_c6a4_debian" {
  ami             = var.ami_id
  instance_type   = "c6a.4xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-c6a4"
  }
}

resource "aws_instance" "ec2_c6i4_debian" {
  ami             = var.ami_id
  instance_type   = "c6i.4xlarge"
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name  = "benchmark-c6i4"
  }
}

output "instance_ips" {
  value = [
    aws_instance.ec2_m5_debian.public_ip,
    aws_instance.ec2_m5a_debian.public_ip,
    aws_instance.ec2_m6i_debian.public_ip,
    aws_instance.ec2_m6a_debian.public_ip,
    aws_instance.ec2_c6i_debian.public_ip,
    aws_instance.ec2_c6a_debian.public_ip,
    aws_instance.ec2_c6i4_debian.public_ip,
    aws_instance.ec2_c6a4_debian.public_ip
  ]
}
 resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      user = "admin",
      instances = [
        { name = "ec2_m5_debian", ip = aws_instance.ec2_m5_debian.public_ip },
        { name = "ec2_m5a_debian", ip = aws_instance.ec2_m5_debian.public_ip },
        { name = "ec2_m6i_debian", ip = aws_instance.ec2_m6i_debian.public_ip },
        { name = "ec2_m6a_debian", ip = aws_instance.ec2_m6a_debian.public_ip },
        { name = "ec2_c6i_debian", ip = aws_instance.ec2_c6i_debian.public_ip },
        { name = "ec2_c6a_debian", ip = aws_instance.ec2_c6a_debian.public_ip },
        { name = "ec2_c6i4_debian", ip = aws_instance.ec2_c6i4_debian.public_ip },
        { name = "ec2_c6a4_debian", ip = aws_instance.ec2_c6a4_debian.public_ip }
      ]
    }
  )
  filename = "hosts"
}