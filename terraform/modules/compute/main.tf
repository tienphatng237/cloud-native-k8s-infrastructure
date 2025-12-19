resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "k0s_controller" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [var.k0s_sg_id]

  tags = {
    Name = "k0s-controller"
  }
}

resource "aws_instance" "k0s_workers" {
  count                  = 2
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[count.index + 1]
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [var.k0s_sg_id]

  tags = {
    Name = "k0s-worker-${count.index + 1}"
  }
}

resource "aws_instance" "observability" {
  count                  = 2
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[count.index + 3]
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [var.k0s_sg_id]

  tags = {
    Name = "observability-${count.index + 1}"
  }
}

resource "aws_instance" "openvpn" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [var.openvpn_sg_id]

  source_dest_check = false
}
