module "current" {
  source  = "Young-ook/spinnaker/aws//modules/aws-partitions"
  version = ">= 2.0"
}

resource "aws_iam_role" "fis-run" {
  name = join("-", [local.name, "fis"])
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("fis.%s", module.current.partition.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fis-run" {
  policy_arn = format("arn:%s:iam::aws:policy/PowerUserAccess", module.current.partition.partition)
  role       = aws_iam_role.fis-run.id
}
