# setup an amazon managed service for prometheus(AMP) workspace
resource "aws_prometheus_workspace" "tf_prometheus_workspace" {
  alias = "tf-prometheus-workspace"
}

# setup an amazon grafana workspace
resource "aws_grafana_workspace" "tf_batch_grafana_workspace" {
  name                      = "tf-batch-grafana-workspace"
  account_access_type       = "CURRENT_ACCOUNT"
  permission_type           = "SERVICE_MANAGED"
  authentication_providers  = ["AWS_SSO"]
  notification_destinations = ["SNS"]
  role_arn                  = aws_iam_role.tf_batch_grafana_iam_role.arn

  data_sources = [
    "XRAY",
    "CLOUDWATCH",
    "PROMETHEUS"
  ]
}

# create grafana role
resource "aws_iam_role" "tf_batch_grafana_iam_role" {
  name = "tf-batch-grafana-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}

# policy to allow grafana to access cloudwatch
resource "aws_iam_policy" "tf_batch_grafana_cloudwatch_policy" {
  name = "tf-batch-grafana-cloudwatch-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Sid" : "AllowReadingMetricsFromCloudWatch",
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowReadingLogsFromCloudWatch",
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# policy to allow grafana to access prometheus
resource "aws_iam_policy" "tf_batch_grafana_prometheus_policy" {
  name = "tf-batch-grafana-prometheus-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "aps:ListWorkspaces",
          "aps:DescribeWorkspace",
          "aps:QueryMetrics",
          "aps:GetLabels",
          "aps:GetSeries",
          "aps:GetMetricMetadata"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# policy to allow grafana to access xray
resource "aws_iam_policy" "tf_batch_grafana_xray_policy" {
  name = "tf-batch-grafana-xray-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:BatchGetTraces",
          "xray:GetTraceSummaries",
          "xray:GetTraceGraph",
          "xray:GetGroups",
          "xray:GetTimeSeriesServiceStatistics",
          "xray:GetInsightSummaries",
          "xray:GetInsight",
          "ec2:DescribeRegions"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "tf_batch_cloudwatch_policy_attachment" {
  name       = "tf-batch-cloudwatch-policy-attachment"
  roles      = [aws_iam_role.tf_batch_grafana_iam_role.name]
  policy_arn = aws_iam_policy.tf_batch_grafana_cloudwatch_policy.arn
}

resource "aws_iam_policy_attachment" "tf_batch_prometheus_policy_attachment" {
  name       = "tf-batch-prometheus-policy-attachment"
  roles      = [aws_iam_role.tf_batch_grafana_iam_role.name]
  policy_arn = aws_iam_policy.tf_batch_grafana_prometheus_policy.arn
}

resource "aws_iam_policy_attachment" "tf_batch_xray_policy_attachment" {
  name       = "tf-batch-xray-policy-attachment"
  roles      = [aws_iam_role.tf_batch_grafana_iam_role.name]
  policy_arn = aws_iam_policy.tf_batch_grafana_xray_policy.arn
}

resource "aws_grafana_role_association" "tf_batch_grafana_role_association" {
  role         = "ADMIN"
  user_ids     = [var.aws_iam_user_id]
  workspace_id = aws_grafana_workspace.tf_batch_grafana_workspace.id
}
