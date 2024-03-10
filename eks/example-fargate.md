
### Step 1: Create a Terraform Configuration File

Create a directory for your Terraform configuration and initialize a `main.tf` file inside it. The content below defines the required provider, creates a VPC, an EKS cluster, and configures Fargate profiles for the cluster. 

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_name    = "dev-eks-cluster"
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  fargate_profiles = {
    fargate_dev = {
      name                = "fargate-dev"
      pod_execution_role_arn = module.eks.fargate_pod_execution_role_arn
      subnet_ids          = module.vpc.private_subnets
      selectors           = [
        {
          namespace = "default"
          labels    = {
            Environment = "dev"
          }
        },
        {
          namespace = "kube-system"
        }
      ]
    }
  }
}
```

### Step 2: Initialize Terraform

Navigate to your project directory in the terminal and run:

```shell
terraform init
```

This command initializes Terraform, downloads the AWS provider, and the necessary modules.

### Step 3: Plan and Apply

Generate an execution plan:

```shell
terraform plan
```

Apply the configuration:

```shell
terraform apply
```

You will need to type `yes` when prompted to proceed.

### Step 4: Configure kubectl

After Terraform successfully creates the EKS cluster, you'll need to configure `kubectl` to interact with your new cluster. You can do so by running the AWS CLI update-kubeconfig command:

```shell
aws eks --region us-east-1 update-kubeconfig --name dev-eks-cluster
```

### Step 5: Verify Cluster and Fargate Profile

Verify that your EKS cluster is up and running:

```shell
kubectl get svc
```

Check your Fargate profile:

```shell
aws eks --region us-east-1 describe-fargate-profile --cluster-name dev-eks-cluster --fargate-profile-name fargate-dev
```

This setup creates a basic EKS cluster running on Fargate in a dedicated VPC suitable for development purposes. Adjustments may be necessary based on your specific requirements, such as adding additional Fargate profiles or adjusting the VPC configuration.
