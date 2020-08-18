

# Security Groups

resource "aws_security_group" "jenkins" {
  name = "${var.project}-jenkins"
  vpc_id = var.vpc_id
  description = "Security Group for allowing access to and from the Jenkins host(s)."
  # SSH access from jump hosts
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.jump_host_cidr_list
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = var.jump_host_cidr_list
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-jenkins"
    Environment = var.app_env
  }  
}

# Create instances

## Jenkins host

resource "aws_instance" "jenkins_1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_private_id
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
  iam_instance_profile = aws_iam_instance_profile.jenkins.id
  key_name = var.aws_key_name
  root_block_device {
    volume_size = 200
  }
  tags = {
    Name = "${var.project}-${var.instance_name}"
    Environment = var.app_env
  }
}

