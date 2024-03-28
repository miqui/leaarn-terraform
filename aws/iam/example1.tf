data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
 
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
 
resource "aws_iam_role" "main" {
  name               = "${var.name_prefix}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}
 
resource "aws_iam_instance_profile" "main" {
  name = aws_iam_role.role.name
  role = aws_iam_role.role.name
}
 
 
resource "aws_instance" "hello_world" {
  count                = var.instance_count
  ami                  = data.aws_ami.ubuntu.id
  subnet_id            = var.subnet_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.main.name
 
  tags = merge(var.tags, {
    Name : "${var.name_prefix}-${count.index}"
  })
}
