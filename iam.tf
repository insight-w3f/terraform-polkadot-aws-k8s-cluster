
resource "aws_iam_role" "this" {
  name = "${var.cluster_id}EKSClusterRole"
  path = "/eks/clster/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["eks.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.cluster_id}_eks_instance_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

