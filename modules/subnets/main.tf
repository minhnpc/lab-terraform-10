
resource "aws_subnet" "subnet10" {
  vpc_id                  = var.vpc_id
  availability_zone       = count.index + 1 <= 2 ? "ap-southeast-1a" : "ap-southeast-1b"
  count                   = 4
  map_public_ip_on_launch = (count.index + 1) % 2 == 1 ? false : true

  cidr_block = "10.${var.num}.${count.index + 1}.0/24"

  tags = {
    key   = "environment"
    value = "${var.env}"
    Name  = "${var.env}-${(count.index + 1) % 2 == 1 ? "private" : "public"}-subnet"
  }

}
