# Terraform AWS Modules

Some modules for my common AWS architectures using terraform 0.12

## Commands

```bash
# Select an example folder
cd examples/<module_example>

# Initialize
terraform init

# Manage resources
terraform plan | apply | destroy
```

## AWS

All modules in this project use the AWS provider.

It's supposed that AWS CLI is already installed and a IAM user with enough privileges is configured.

## Modules

All modules have a running snippet under the `examples` folder.

### MongoDB

Resources:

- ECS FARGATE cluster
- Mongo 4.0 Docker Container
- Network Load Balancer
- EFS data persistence

Configuration:

| VARIABLE         | TYPE   | DEFAULT | DESCRIPTION                |
| ---------------- | ------ | ------- | -------------------------- |
| region           | string | -       | AWS Region                 |
| db_port          | number | 27017   | MongoDB Server Port        |
| db_root_username | string | root    | MongoDB Superuser username |
| db_root_password | string | root    | MongoDB Superuser password |
| tags             | map    | {}      | Map of AWS tags            |
