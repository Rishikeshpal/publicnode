# Score VPC Demo

Infrastructure-as-code example satisfying the “Score” requirements. It builds a
minimal AWS environment with:

- one VPC containing a public and a private subnet
- an Internet Gateway and NAT Gateway so both subnets reach the internet
- two EC2 instances (Amazon Linux 2023):
  - **Public host** in the public subnet, whose inbound SSH is restricted to a
    single IP address
  - **Private host** in the private subnet, reachable only from the public host
- Terraform outputs for quick reference (instance IDs, IPs, subnet IDs, etc.)

The configuration lives under `terraform/` and can be deployed or destroyed with
standard Terraform commands.

## Prerequisites

- Terraform >= 1.5.0 (OpenTofu also works – adjust commands accordingly)
- AWS credentials with permissions to create networking, EC2, and IAM resources
- An existing EC2 key pair name in the target region (for SSH access)
- The public IPv4 address you want to allow through the bastion (e.g.
  `203.0.113.10/32`)

## Usage

```bash
cd terraform
terraform init
terraform apply -var='project_name=score-demo' \
                -var='region=us-east-1' \
                -var='allowed_ip_cidr=203.0.113.10/32' \
                -var='key_name=your-keypair-name'
```

Terraform will show a plan and ask for confirmation. After provisioning,
outputs include the public host public IP and the private host private IP.

### Destroying

```bash
cd terraform
terraform destroy -var='project_name=score-demo' \
                  -var='region=us-east-1' \
                  -var='allowed_ip_cidr=203.0.113.10/32' \
                  -var='key_name=your-keypair-name'
```

## Files

- `terraform/main.tf` – core infrastructure definitions (leverages the community
  [`terraform-aws-modules/vpc/aws`](https://github.com/terraform-aws-modules/terraform-aws-vpc)
  module)
- `terraform/variables.tf` – input variables
- `terraform/provider.tf` – Terraform and AWS provider settings
- `terraform/outputs.tf` – handy outputs

## Access Model

1. SSH to the **public host** using the supplied key pair and the output
   `public_host_public_ip`. Inbound access is restricted to `allowed_ip_cidr`.
2. From the public host, SSH into the **private host** using its private IP.
   Only traffic originating from the public host security group is allowed.

Both instances have outbound access to the internet:

- Public host routes traffic directly via the Internet Gateway
- Private host routes through the NAT Gateway in the public subnet

## Notes

- The NAT Gateway incurs hourly charges; destroy the stack when finished.
- For OpenTofu users, replace `terraform` in the commands above with `tofu`.

