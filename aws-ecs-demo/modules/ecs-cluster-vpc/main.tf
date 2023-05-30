resource "aws_vpc" "main" {
  cidr_block = var.vpcCIDR
  
  tags       = {
    Name = "${var.env} Cluster's VPC"
    Env  = "${var.env}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags       = {
    Name = "${var.env} Internet Gateway"
    Env  = "${var.env}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.privateSubnets, count.index)
  availability_zone = element(var.availabilityZones, count.index)
  count             = length(var.privateSubnets)
}
 
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.publicSubnets, count.index)
  availability_zone       = element(var.availabilityZones, count.index)
  count                   = length(var.publicSubnets)
  map_public_ip_on_launch = true
}

# For public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}
 
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
 
resource "aws_route_table_association" "public" {
  count          = length(var.publicSubnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# For private subnets
resource "aws_nat_gateway" "main" {
  count         = length(var.privateSubnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]
}
 
resource "aws_eip" "nat" {
  count = length(var.privateSubnets)
  vpc = true
}

resource "aws_route_table" "private" {
  count  = length(var.privateSubnets)
  vpc_id = aws_vpc.main.id
}
 
resource "aws_route" "private" {
  count                  = length(compact(var.privateSubnets))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}
 
resource "aws_route_table_association" "private" {
  count          = length(var.privateSubnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}