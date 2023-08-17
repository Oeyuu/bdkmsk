module "msk_cluster" {
  source = "terraform-aws-modules/msk-kafka-cluster/aws"

  name                   = local.name
  kafka_version          = "3.4.0"
  number_of_broker_nodes = 3
  enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"

  broker_node_client_subnets  = module.vpc.private_subnets
  broker_node_instance_type   = "kafka.t3.small"
  broker_node_security_groups = [module.security_group.security_group_id]
  broker_node_storage_info = {
    ebs_storage_info = { volume_size = 10 }
  }

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  configuration_name = "msk-config"
  configuration_server_properties = {
    "allow.everyone.if.no.acl.found" = true
    "auto.create.topics.enable"      = false
    "delete.topic.enable"            = false
    "default.replication.factor"     = 3
    "min.insync.replicas"            = 2
    "num.io.threads"                 = 8
    "num.network.threads"            = 5
    "num.partitions"                 = 1
    "num.replica.fetchers"           = 2
    "replica.lag.time.max.ms"        = 30000
    "socket.receive.buffer.bytes"    = 102400
    "socket.request.max.bytes"       = 104857600
    "socket.send.buffer.bytes"       = 102400
    "unclean.leader.election.enable" = true
    "zookeeper.session.timeout.ms"   = 18000
  }

  jmx_exporter_enabled    = true
  node_exporter_enabled   = true
  cloudwatch_logs_enabled = true


  scaling_max_capacity = 512
  scaling_target_value = 80

  client_authentication = {
    sasl = {
      scram = true
      iam   = true
    }
  }
  create_scram_secret_association          = true
  scram_secret_association_secret_arn_list = [for x in aws_secretsmanager_secret.this : x.arn]

  #   # schema registry
  #   schema_registries = {
  #     team_a = {
  #       name = "team_a"
  #     }
  #     team_b = {
  #       name = "team_b"
  #     }
  #   }
  #   schemas = {
  #     team_a_tweets = {
  #       schema_registry_name = "team_a"
  #       schema_name          = "tweets"
  #       description          = "Schema that contains all the tweets"
  #       compatibility        = "FORWARD"
  #       schema_definition    = "{\"type\": \"record\", \"name\": \"r1\", \"fields\": [ {\"name\": \"f1\", \"type\": \"int\"}, {\"name\": \"f2\", \"type\": \"string\"} ]}"
  #       tags                 = { Team = "Team A" }
  #     }
  #     team_b_records = {
  #       schema_registry_name = "team_b"
  #       schema_name          = "records"
  #       description          = "Schema that contains all the records"
  #       compatibility        = "FORWARD"
  #       schema_definition = jsonencode({
  #         type = "record"
  #         name = "r1"
  #         fields = [
  #           {
  #             name = "f1"
  #             type = "int"
  #           },
  #           {
  #             name = "f2"
  #             type = "string"
  #           },
  #           {
  #             name = "f3"
  #             type = "boolean"
  #           }
  #         ]
  #       })
  #       tags = { Team = "Team B" }
  #     }
  #   }

  #   tags = local.tags
}


resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "msk" {
  description         = "msk"
  enable_key_rotation = true

  tags = local.tags
}

resource "random_password" "this" {
  length           = 20
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "this" {
  for_each = toset(local.secrets)

  name        = "AmazonMSK_${each.value}_${random_pet.this.id}"
  description = "Secret for ${local.name} - ${each.value}"
  kms_key_id  = aws_kms_key.msk.key_id

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = toset(local.secrets)

  secret_id = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode({
    username = each.value,
    password = random_password.this.result
  })
}

resource "aws_secretsmanager_secret_policy" "this" {
  for_each = toset(local.secrets)

  secret_arn = aws_secretsmanager_secret.this[each.key].arn
  policy     = <<-POLICY
  {
    "Version" : "2012-10-17",
    "Statement" : [ {
      "Sid": "AWSKafkaResourcePolicy",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "kafka.amazonaws.com"
      },
      "Action" : "secretsmanager:getSecretValue",
      "Resource" : "${aws_secretsmanager_secret.this[each.key].arn}"
    } ]
  }
  POLICY
}
