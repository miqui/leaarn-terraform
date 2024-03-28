variable "instance_count" {
  type        = number
  description = "The number of instances to launch."
  default     = 0
  validation {
    condition     = can(parseint(var.instance_count, 10))
    error_message = "The instance count must be a whole number."
  }
 
  validation {
    condition     = var.instance_count >= 0
    error_message = "The instance count can not be negative."
  }
}
 
resource "aws_instance" "hello_world" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
 
  tags = merge(var.tags, {
    Name : "${var.name_prefix}-${count.index}"
  })
}
