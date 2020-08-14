# IAM

resource "aws_iam_role" "jenkins" {
    name = "${var.project}-jenkins"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins" {
    name = "${var.project}-jenkins"
    role = "${aws_iam_role.jenkins.name}"
}

resource "aws_iam_role_policy" "jenkins" {
  name = "${var.project}-jenkins"
  role = "${aws_iam_role.jenkins.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::*"]
    }
  ]
}
EOF
}

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
  tags = {
    Name = "${var.project}-${var.instance_name}"
    Environment = var.app_env
  }
}

