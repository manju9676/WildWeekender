resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.myvpc.id
  name = "my-security-group"
  description = "Allow all traffic from anywhere"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
