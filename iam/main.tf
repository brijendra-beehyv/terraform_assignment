provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_user" "devops_user" {
  name = "devops-user-2"

  tags = {
    Role = "DevOps"
  }
}

resource "aws_iam_user_login_profile" "login" {
  user = aws_iam_user.devops_user.name

  password_reset_required = true
}

resource "aws_iam_group" "admin_group" {
  name = "admin-2"
}

resource "aws_iam_group_policy_attachment" "admin_policy" {
  group      = aws_iam_group.admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_membership" "a-membership" {
  name  = "demo group"
  group = aws_iam_group.admin_group.id
  users = [aws_iam_user.devops_user.id]
}
