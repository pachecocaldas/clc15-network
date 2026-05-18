#Cria a VPN
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "clc15-tf-vpc"
  }
}


#Cria as Subnets
#Subnets A

resource "aws_subnet" "subnet_public_1a" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-tf-subnet-1a"
  }
}

resource "aws_subnet" "subnet_private_1a" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-tf-subnet-1a"
  }
}


resource "aws_subnet" "subnet_public_1b" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-tf-subnet-1b"
  }
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.200.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-tf-subnet-1b"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "tf_vpc_igw"
  }
}


#Cria a tr publica apontando para igw
resource "aws_route_table" "tf_public_rt" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "tf_public_rt"
  }
}

#Associa RT Publica nas subnets publicas
resource "aws_route_table_association" "public_1a_association" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_route_table.tf_public_rt.id
}

resource "aws_route_table_association" "public_1b_association" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_route_table.tf_public_rt.id
}


#Cria Elastic Apis para as Nat Gateway

resource "aws_eip" "tf_ip_nat_1a" {
  domain   = "vpc"
}

resource "aws_eip" "tf_ip_nat_1b" {
  domain   = "vpc"
}


#Cria as Nat em suas subnets publicas
resource "aws_nat_gateway" "tf_natgateway_1a" {
  allocation_id = aws_eip.tf_ip_nat_1a.id
  subnet_id     = aws_subnet.subnet_public_1a.id

  tags = {
    Name = "tf_natgw_1a"
  }


  depends_on = [aws_internet_gateway.tf_igw]
}


resource "aws_nat_gateway" "tf_natgateway_1b" {
  allocation_id = aws_eip.tf_ip_nat_1b.id
  subnet_id     = aws_subnet.subnet_public_1b.id

  tags = {
    Name = "tf_natgw_1b"
  }


  depends_on = [aws_internet_gateway.tf_igw]
}


# Cria tabela de rotas privadas para subnet 1A e 1B

resource "aws_route_table" "tf_private_rt_1a" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf_natgateway_1a.id
  }

  tags = {
    Name = "tf_private_rt_1a"
  }
}


resource "aws_route_table" "tf_private_rt_1b" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf_natgateway_1b.id
  }

  tags = {
    Name = "tf_private_rt_1b"
  }
}


#Associa RT Privadas nas subnets privadas
resource "aws_route_table_association" "private_1a_association" {
  subnet_id      = aws_subnet.subnet_private_1a.id
  route_table_id = aws_route_table.tf_private_rt_1a.id
}

resource "aws_route_table_association" "private_1b_association" {
  subnet_id      = aws_subnet.subnet_private_1b.id
  route_table_id = aws_route_table.tf_private_rt_1b.id
}