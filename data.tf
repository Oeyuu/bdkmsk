data "aws_availability_zones" "available" {}

# data "aws_iam_policy_document" "this" {
#  for_each = toset(local.secrets)

#   statement {
#     effect = "Allow"
#     principals {
#       identifiers = ["kafka.amazonaws.com"]
#       type        = "Service"
#     }
#     actions   = ["secretsmanager:getSecretValue"]
#     resources = [aws_secretsmanager_secret.this[each.key].arn]
#   }
# }

