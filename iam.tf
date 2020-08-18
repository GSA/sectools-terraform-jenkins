# IAM


## Role configuration

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

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins.arn
}

resource "aws_iam_instance_profile" "jenkins" {
    name = "${var.project}-jenkins"
    role = "${aws_iam_role.jenkins.name}"
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
  name = "${var.project}-jenkins"
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
    },
    {
      "Effect": "Allow",
      "Action": [
          "ecr:PutImageTagMutability",
          "ecr:StartImageScan",
          "ecr:ListTagsForResource",
          "ecr:BatchDeleteImage",
          "ecr:UploadLayerPart",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:CompleteLayerUpload",
          "ecr:TagResource",
          "ecr:DescribeRepositories",
          "ecr:DeleteRepositoryPolicy",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetLifecyclePolicy",
          "ecr:PutLifecyclePolicy",
          "ecr:DescribeImageScanFindings",
          "ecr:CreateRepository",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImageScanningConfiguration",
          "ecr:DeleteLifecyclePolicy",
          "ecr:PutImage",
          "ecr:UntagResource",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:StartLifecyclePolicyPreview",
          "ecr:InitiateLayerUpload",
          "ecr:GetRepositoryPolicy",
          "ecr:GetAuthorizationToken"
      ],
      "Resource": [
          "arn:aws:ecr:us-east-1:*"
      ]  
    }
  ]
}
EOF
}