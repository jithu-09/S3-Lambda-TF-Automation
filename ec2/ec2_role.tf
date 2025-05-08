#Create a role that allows EC2 to access ECR to push and pull images and attach them to EC2.

resource "aws_iam_role" "ec2" {
  name = "ec2-docker-role"
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid = "" #Sid is for identifying the statement, it is a string
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-docker-instance-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role_policy_attachment" "bastian" {
   role = aws_iam_role.ec2.name
   policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}