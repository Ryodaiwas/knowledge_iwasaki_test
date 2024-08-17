
# vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "knowledgebase_vpc"
  }
}

locals {
  private_subnets = {
    private-1a = {
      name = "private-1a",
      cidr = "10.0.10.0/24",
      az   = "ap-northeast-1a"
    },
    private-1c = {
      name = "private-1c",
      cidr = "10.0.11.0/24",
      az   = "ap-northeast-1c"
    },
    private-1d = {
      name = "private-1d",
      cidr = "10.0.12.0/24",
      az   = "ap-northeast-1d"
    },
  }
  public_subnets = {
    public_1a = {
      name = "public-1a",
      cidr = "10.0.20.0/24",
      az   = "ap-northeast-1a"
    },
    public_1c = {
      name = "public-1c",
      cidr = "10.0.21.0/24",
      az   = "ap-northeast-1c"
    },
    public_1d = {
      name = "public-1d",
      cidr = "10.0.22.0/24",
      az   = "ap-northeast-1d"
    }
  }
}


resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = {
    Name = each.value.name
  }
}


resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.main.id

  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = {
    Name = each.value.name
  }
}


# インターネットゲートウェイの作成
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "knowledgebase-igw"
  }
}


# ルートテーブルの作成
resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "${each.value.name}-rt"
  }
}

resource "aws_route_table" "public" {
  for_each = local.public_subnets
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "${each.value.name}-rt"
  }
}

# サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
}
# インターネットゲートウェイとルートテーブルの関連付け
resource "aws_route" "igw" {
  for_each               = local.public_subnets
  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}


