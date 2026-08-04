# Enables GuardDuty: continuous, ML-driven threat detection across
# CloudTrail management/data events, VPC Flow Logs, and DNS logs.
#
# This is a detective control that complements the preventive controls
# elsewhere in this module (password policy, public access blocks). It
# catches the things prevention alone cannot: compromised credentials
# being used from an unusual location, an EC2 instance communicating
# with a known command-and-control IP, reconnaissance API calls from
# a leaked access key, etc.

resource "aws_guardduty_detector" "this" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"
}
