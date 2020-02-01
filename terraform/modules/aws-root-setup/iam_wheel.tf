# Similar to a *nix system the wheel group allows the use of a root
# role which has elevated permissions.
resource "aws_iam_group" "wheel" {
  name = "wheel"
}

data "aws_iam_policy_document" "wheel_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    resources = [
      aws_iam_role.root.arn,
    ]
  }
}

resource "aws_iam_group_policy" "wheel_policy" {
  name  = "wheel-assumes-root"
  group = aws_iam_group.wheel.id

  policy = data.aws_iam_policy_document.wheel_policy.json
}

# This sets up the role that's used rather than the "real" root
# credentials.
data "aws_caller_identity" "self" {}
data "aws_iam_policy_document" "root_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.account_id]
    }
  }
}

resource "aws_iam_role" "root" {
  name               = "root"
  assume_role_policy = data.aws_iam_policy_document.root_policy.json
}

resource "aws_iam_role_policy_attachment" "root" {
  role       = aws_iam_role.root.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "root_arn" {
  value = aws_iam_role.root.arn
}
