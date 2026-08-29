# AWS Security Hardening Terraform Module

Reusable, opinionated Terraform module that applies a CIS AWS Foundations
Benchmark-aligned security baseline to an AWS account — in one `terraform
apply`, not a checklist of manual console clicks.

Built as part of a hands-on portfolio demonstrating production-style cloud
security engineering: infrastructure as code, least-privilege guardrails,
detective controls, and continuous compliance monitoring.

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Provider%20%3E%3D5.0-232F3E?logo=amazonaws&logoColor=white)
![CIS](https://img.shields.io/badge/CIS%20AWS%20Foundations-v1.4.0-1F4E79)
![License](https://img.shields.io/badge/License-MIT-1F4E79)

---

## Why this exists

Most AWS accounts start from an insecure default: no centralized audit
trail, no account-wide guardrail against public S3 buckets, weak IAM
password requirements, and no automated threat detection. Every one of
those gaps has caused real, well-documented breaches.

This module closes those gaps as **code**, so the baseline is:

- **Repeatable** — the same hardened baseline can be applied to every new
  AWS account (dev, staging, prod) with no drift between them
- **Reviewable** — changes to the security posture go through pull
  request review like any other code change, not an undocumented console
  click
- **Auditable** — the Terraform state and Git history are themselves
  evidence for ISO 27001 / SOC 2 control testing ("show me how access
  logging is configured" → point to `modules/cloudtrail`)

## What it deploys

| Control area | Resource(s) | CIS AWS Foundations control |
|---|---|---|
| **Identity hardening** | Account-wide IAM password policy (14-char minimum, complexity, 90-day rotation, 24-password reuse prevention) | 1.5 – 1.11 |
| **Data exposure prevention** | Account-level S3 Block Public Access | 2.1.5 |
| **Audit logging** | Multi-region CloudTrail, log file validation, KMS-encrypted + versioned log bucket, TLS-only bucket policy | 3.1 – 3.7 |
| **Configuration compliance** | AWS Config recorder + delivery channel + managed rules (public S3 buckets, unencrypted S3/EBS, missing MFA) | 2.x / continuous |
| **Threat detection** | GuardDuty (CloudTrail, VPC Flow Logs, DNS logs, S3 protection, EKS audit logs, EBS malware scanning) | 4.15 / detective |
| **Aggregated compliance view** | Security Hub subscribed to the CIS AWS Foundations Benchmark v1.4.0 standard | reporting layer |

## Architecture

```
                       ┌────────────────────┐
                       │   Security Hub      │  ← aggregated findings +
                       │ (CIS v1.4.0 scored) │    compliance score
                       └─────────▲───────────┘
                                 │ findings
              ┌──────────────────┼──────────────────┐
              │                  │                   │
     ┌────────┴───────┐ ┌────────┴────────┐ ┌────────┴────────┐
     │   GuardDuty      │ │   AWS Config     │ │  CloudTrail      │
     │ (threat detect)  │ │ (config drift)   │ │ (audit log)      │
     └────────▲─────────┘ └────────▲─────────┘ └────────▲─────────┘
              │                    │                    │
     VPC Flow Logs /       Resource config       Management +
     DNS logs / S3         snapshots to           data events to
     data events            S3 (encrypted)         S3 (KMS + validated)

     ┌───────────────────────────────────────────────────────────┐
     │  Preventive guardrails (always-on, account-wide)            │
     │  • IAM account password policy                              │
     │  • S3 account-level Block Public Access                     │
     └───────────────────────────────────────────────────────────┘
```

## Repository structure

```
aws-security-hardening-terraform/
├── main.tf                          # Root module wiring
├── variables.tf                     # Root input variables
├── outputs.tf                       # Root outputs
├── versions.tf                      # Provider/version constraints
├── modules/
│   ├── iam-password-policy/         # CIS 1.5-1.11
│   ├── s3-account-public-access-block/  # CIS 2.1.5
│   ├── cloudtrail/                  # CIS 3.1-3.7
│   ├── config/                      # Continuous compliance recording
│   ├── guardduty/                   # Threat detection
│   └── security-hub/                # Aggregated compliance dashboard
├── examples/
│   └── complete/                    # Full working example + tfvars
├── .github/workflows/
│   └── terraform-ci.yml             # fmt, validate, tflint, Checkov scan
├── .gitignore
├── LICENSE
└── README.md
```

Each module is self-contained (its own `main.tf`, `variables.tf`,
`outputs.tf`) so individual controls can be consumed independently if a
team only needs, say, the CloudTrail baseline.

## Usage

```hcl
module "aws_security_baseline" {
  source = "github.com/ooladipo/aws-security-hardening-terraform"

  aws_region   = "eu-central-1"
  environment  = "prod"
  project_name = "acme-corp"

  log_retention_days  = 365
  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = true
}
```

See [`examples/complete`](./examples/complete) for a full runnable example.

```bash
cd examples/complete
cp terraform.tfvars.example terraform.tfvars   # edit as needed
terraform init
terraform plan
terraform apply
```

> **Note:** this module creates account-wide resources (IAM password
> policy, S3 account public access block, CloudTrail, GuardDuty detector,
> Security Hub subscription). Most AWS accounts can only have **one** of
> each of these. Run against a sandbox/test account first, or use
> `enable_*` flags to disable services already managed elsewhere (e.g. by
> AWS Organizations / Control Tower).

## Security concepts demonstrated

**Defense in depth, not a single control.** Preventive controls
(password policy, public access block) stop known-bad configurations
from happening. Detective controls (GuardDuty, Config) catch what
prevention misses or what changes after deployment. Security Hub ties
both layers into one prioritized view — this mirrors how a real security
program is structured, not just a list of AWS services.

**Least-privilege IAM for the automation itself.** The Config recorder
role uses AWS's managed `AWS_ConfigRole` policy rather than a hand-rolled
`*:*` policy, scoping the automation's own permissions to only what
Config needs.

**Encryption and integrity of the audit trail.** CloudTrail logs are
encrypted with a dedicated customer-managed KMS key (not the default S3
key), and log file validation is enabled so tampering with a log file
after the fact is cryptographically detectable — a control auditors
specifically test for in PCI DSS Requirement 10 and ISO 27001 Annex A.8.

**Secure-by-default storage.** Every S3 bucket this module creates
(CloudTrail logs, Config logs) is versioned, encrypted, has public access
blocked at the bucket level, and denies any request that isn't over TLS
— on top of the account-wide Block Public Access guardrail, which is a
deliberate belt-and-suspenders approach.

**Everything as reviewable code.** Nothing here was clicked in the
console. Every control change goes through Git history, `terraform plan`
diff review, and CI validation (`terraform fmt`, `terraform validate`,
`tflint`, and a Checkov static security scan that fails the build on
high-severity misconfigurations) before it reaches an account.

## Mapping to compliance frameworks

| Framework | Where this module helps |
|---|---|
| **ISO 27001** | Annex A.8 (asset/log protection), A.5.15 (access control), A.8.16 (monitoring) — CloudTrail + Config outputs are usable as direct audit evidence |
| **PCI DSS** | Req. 10 (audit logging), Req. 8 (password policy), Req. 1/6 (secure configuration via Config rules) |
| **SOC 2** | CC6 (logical access), CC7 (system monitoring) trust service criteria |
| **NIS2** | Continuous monitoring and incident detection expectations for essential/important entities |

## Roadmap

- [ ] Add AWS Organizations SCP examples for multi-account guardrails
- [ ] Add Terratest-based automated tests (`tests/`)
- [ ] Add a cost-estimate note (GuardDuty/Config pricing considerations)
- [ ] Extend Config rule set to cover CIS sections 4.x (networking)

## License

MIT — see [LICENSE](./LICENSE).

---

