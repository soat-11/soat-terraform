resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_soat.id

  tags = {
    Name = "igw-${aws_vpc.vpc_soat.id}"
  }

}

resource "aws_internet_gateway_attachment" "igw_attachment" {
  vpc_id              = aws_vpc.vpc_soat.id
  internet_gateway_id = aws_internet_gateway.igw.id
}
