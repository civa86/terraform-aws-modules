# Terraform AWS Modules

## Pre-requisites

1. Access to an AWS account.
2. `aws-cli` is installed and configured (see [the AWS CLI guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) for instructions).
3. Terraform is installed (see [the Terraform website](https://www.terraform.io/) for instructions).

- [Terraform 0.12](https://www.terraform.io/downloads.html)
- [AWS CLI]()
- IAM credential with right privileges

## Modules

```bash
.
├── examples
│   ├── docker-machine  # Example for docker-machine module
│   └── mongodb         # Example of mongodb module
└── modules
    ├── docker-machine  # Docker EC2 Instance
    └── mongodb         # MongoDB with ECS Fargate
```

---

## Docker Machine

```bash
cd examples/docker-machine
ssh-keygen -f ./key.pem
terraform init
terraform apply
```

| VARIABLE        | TYPE   | DEFAULT  | DESCRIPTION             |
| --------------- | ------ | -------- | ----------------------- |
| region          | string | -        | AWS Region              |
| project_name    | string | -        | Name of the project     |
| ssh_private_key | string | -        | Path of SSH private Key |
| ssh_public_key  | string | -        | Path of SSH public Key  |
| instance_type   | string | t1.micro | Type of EC2 instance    |
| tags            | map    | {}       | Map of AWS tags         |

---

## MongoDB

```bash
cd examples/mongodb
terraform init
terraform apply
```

| VARIABLE         | TYPE   | DEFAULT | DESCRIPTION                |
| ---------------- | ------ | ------- | -------------------------- |
| region           | string | -       | AWS Region                 |
| db_port          | number | 27017   | MongoDB Server Port        |
| db_root_username | string | root    | MongoDB Superuser username |
| db_root_password | string | root    | MongoDB Superuser password |
| tags             | map    | {}      | Map of AWS tags            |
