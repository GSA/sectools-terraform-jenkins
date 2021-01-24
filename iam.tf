# Data source
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# IAM


## Role configuration

resource "aws_iam_role" "jenkins" {
  name               = "${var.project}-jenkins"
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

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins.arn
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project}-jenkins"
  role = aws_iam_role.jenkins.name
}

## User Configuration

resource "aws_iam_user" "jenkins" {
  name = "${var.project}-jenkins"
  path = "/system/"
  tags = {
    Name = "${var.project}-jenkins"
  }
}

## Group Configuration

resource "aws_iam_group" "jenkins" {
  name = "${var.project}-jenkins"
}

resource "aws_iam_group_policy_attachment" "jenkins" {
  group      = aws_iam_group.jenkins.name
  policy_arn = aws_iam_policy.jenkins.arn
}


resource "aws_iam_group_membership" "jenkins" {
  name = "${var.project}-jenkins"
  users = [
    aws_iam_user.jenkins.name
  ]
  group = aws_iam_group.jenkins.name
}

resource "aws_iam_policy" "jenkins" {
  name   = "${var.project}-jenkins"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::*/*"
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:sectools-jenkins/pipelines/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DeregisterImage",
                "ec2:DeleteSnapshot",
                "ec2:DescribeInstances",
                "ec2:CreateKeyPair",
                "ec2:DescribeRegions",
                "ec2:CreateImage",
                "ec2:CopyImage",
                "ec2:ModifyImageAttribute",
                "ec2:DescribeSnapshots",
                "ec2:DeleteVolume",
                "iam:PassRole",
                "ec2:ModifySnapshotAttribute",
                "ec2:CreateSecurityGroup",
                "sts:DecodeAuthorizationMessage",
                "ec2:DescribeVolumes",
                "ec2:CreateSnapshot",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeInstanceStatus",
                "ec2:DetachVolume",
                "ec2:TerminateInstances",
                "iam:GetInstanceProfile",
                "ec2:DescribeTags",
                "ec2:CreateTags",
                "ec2:RegisterImage",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateVolume",
                "ec2:DescribeImages",
                "ec2:GetPasswordData",
                "ec2:DescribeImageAttribute",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeSubnets",
                "ec2:DeleteKeyPair",
                "ec2:AssociateIamInstanceProfile"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
