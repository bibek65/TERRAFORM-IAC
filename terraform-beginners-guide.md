# Terraform for Beginners — Complete Guide

---

## Table of Contents

1. [What is Terraform?](#1-what-is-terraform)
2. [Why Terraform?](#2-why-terraform)
3. [Core Concepts](#3-core-concepts)
   - [HCL — HashiCorp Configuration Language](#31-hcl--hashicorp-configuration-language)
   - [Blocks](#32-blocks)
   - [State File](#33-state-file)
   - [Resource Block](#34-resource-block)
   - [Data Block](#35-data-block)
   - [Variable Block](#36-variable-block)
   - [Locals Block](#37-locals-block)
   - [Output Block](#38-output-block)
4. [Installation](#4-installation)
5. [Terraform Workflow](#5-terraform-workflow)
6. [Hands-On: Create an S3 Bucket (Local Backend)](#6-hands-on-create-an-s3-bucket-local-backend)
7. [Remote Backend](#7-remote-backend)
8. [Terraform Workspaces](#8-terraform-workspaces)
9. [Terraform Modules](#9-terraform-modules)
10. [Summary & Cheat Sheet](#10-summary--cheat-sheet)

---

## 1. What is Terraform?

**Terraform** is an open-source **Infrastructure as Code (IaC)** tool created by **HashiCorp**. It lets you define, provision, and manage cloud infrastructure using a simple, human-readable configuration language called **HCL (HashiCorp Configuration Language)**.

Instead of manually clicking around in the AWS Console (or any cloud provider), you write `.tf` files that describe what infrastructure you want — and Terraform builds it for you.

```
┌─────────────────────────────────────────────────────┐
│                  YOU (Developer)                     │
│                                                     │
│   Write .tf files describing desired infrastructure │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│                   TERRAFORM                          │
│                                                     │
│   Reads .tf files → Plans changes → Applies them    │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│              CLOUD PROVIDER (AWS, Azure, GCP...)     │
│                                                     │
│   Infrastructure is created/updated/destroyed       │
│   (EC2, S3, VPC, RDS, Lambda, etc.)                 │
└─────────────────────────────────────────────────────┘
```

**Key idea:** You write WHAT you want, and Terraform figures out HOW to make it happen.

---

## 2. Why Terraform?

| Problem (Without Terraform) | Solution (With Terraform) |
|---|---|
| Manual setup through cloud console — slow, error-prone | Automated, repeatable infrastructure provisioning |
| No record of what was created or changed | `.tf` files act as documentation + source of truth |
| Hard to replicate environments (dev, staging, prod) | Same code → same infrastructure every time |
| Difficult to collaborate on infrastructure | Store `.tf` files in Git — review, version, collaborate |
| Vendor lock-in with cloud-specific tools | Works with AWS, Azure, GCP, Kubernetes, and 3000+ providers |
| Deleting/cleaning up resources is risky | `terraform destroy` cleanly removes everything it created |

### Terraform vs Other Tools

```
┌─────────────────────────────────────────────────────────────┐
│                    IaC Tools Comparison                      │
├─────────────────┬──────────────┬─────────────┬──────────────┤
│    Feature      │  Terraform   │ CloudForm.  │   Ansible    │
├─────────────────┼──────────────┼─────────────┼──────────────┤
│ Multi-Cloud     │     ✅       │     ❌      │     ✅       │
│ Declarative     │     ✅       │     ✅      │  Procedural  │
│ State Mgmt      │     ✅       │  Built-in   │     ❌       │
│ Language        │     HCL      │  JSON/YAML  │    YAML      │
│ Community       │   Huge       │  AWS only   │    Huge      │
└─────────────────┴──────────────┴─────────────┴──────────────┘
```

---

## 3. Core Concepts

### 3.1 HCL — HashiCorp Configuration Language

HCL is the language Terraform uses. It is **declarative** — you describe the **desired end state**, not the step-by-step instructions.

```hcl
# This is HCL — simple, readable, and declarative
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
}
```

### 3.2 Blocks

Everything in Terraform is organized into **blocks**. A block is a container for configuration.

```
┌─────────────────────────────────────────────────────────┐
│                   Terraform Blocks                       │
├──────────────┬──────────────────────────────────────────┤
│  terraform   │ Settings, required providers, backend    │
│  provider    │ Configure cloud provider (AWS, GCP...)   │
│  resource    │ Create infrastructure (S3, EC2...)       │
│  data        │ Read existing infrastructure             │
│  variable    │ Input parameters                         │
│  locals      │ Computed local values                    │
│  output      │ Display values after apply               │
└──────────────┴──────────────────────────────────────────┘
```

**General block syntax:**

```hcl
block_type "label_1" "label_2" {
  argument_1 = "value"
  argument_2 = 42
}
```

### 3.3 State File

The **state file** (`terraform.tfstate`) is Terraform's memory. It keeps track of the real-world resources Terraform manages.

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────┐
│  .tf Files   │       │  terraform.tfstate│       │  Real Cloud  │
│  (Desired    │──────▶│  (What Terraform  │──────▶│  Resources   │
│   State)     │       │   knows about)    │       │  (Actual)    │
└──────────────┘       └──────────────────┘       └──────────────┘
        │                       │                         │
        │        terraform plan compares these            │
        └───────────────────────┼─────────────────────────┘
                                │
                         Shows DIFF
                    (what needs to change)
```

**Important rules about the state file:**
- ⚠️ **Never edit** `terraform.tfstate` manually
- ⚠️ **Never commit** it to Git (add to `.gitignore`)
- ✅ Use a **remote backend** (like S3) for team collaboration
- The state file can contain **sensitive data** (passwords, keys)

### 3.4 Resource Block

A **resource** block tells Terraform to **create and manage** a piece of infrastructure.

```hcl
# Syntax:
# resource "<PROVIDER>_<TYPE>" "<LOCAL_NAME>" { ... }

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-app-data-bucket-12345"

  tags = {
    Name        = "MyAppBucket"
    Environment = "dev"
  }
}
```

```
resource "aws_s3_bucket" "my_bucket"
   │          │              │
   │          │              └─ Local name (used to reference within Terraform)
   │          └─ Resource type (from AWS provider)
   └─ Block type
```

### 3.5 Data Block

A **data** block reads information about **existing** infrastructure that Terraform does NOT manage.

```hcl
# Syntax:
# data "<PROVIDER>_<TYPE>" "<LOCAL_NAME>" { ... }

# Read info about an existing S3 bucket (not created by this Terraform)
data "aws_s3_bucket" "existing_bucket" {
  bucket = "some-bucket-that-already-exists"
}

# Use the data somewhere else
output "bucket_arn" {
  value = data.aws_s3_bucket.existing_bucket.arn
}
```

```
┌─────────────────────────────────────────────────┐
│         resource vs data                         │
├────────────────────┬────────────────────────────┤
│   resource         │   data                     │
├────────────────────┼────────────────────────────┤
│ Creates NEW infra  │ Reads EXISTING infra       │
│ Terraform manages  │ Terraform does NOT manage  │
│ Can update/destroy │ Read-only                  │
└────────────────────┴────────────────────────────┘
```

### 3.6 Variable Block

**Variables** are input parameters that make your Terraform code reusable.

```hcl
# Declare a variable
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-default-bucket"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  # No default = Terraform will ASK you for a value
}

# Use the variable with var.<name>
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
  }
}
```

**Ways to pass variable values:**

```
┌────────────────────────────────────────────────────────┐
│            How to Set Variable Values                   │
├─────────────────────────┬──────────────────────────────┤
│ 1. Default value        │ default = "value" in block   │
│ 2. CLI flag             │ -var="bucket_name=my-bucket" │
│ 3. .tfvars file         │ terraform.tfvars file        │
│ 4. Environment variable │ TF_VAR_bucket_name=my-bucket │
│ 5. Interactive prompt   │ Terraform asks during apply  │
└─────────────────────────┴──────────────────────────────┘

Priority (highest to lowest):
  CLI -var  >  .tfvars file  >  ENV variable  >  default value
```

### 3.7 Locals Block

**Locals** are like private variables computed inside your Terraform code. They cannot be set by users — only by you in the code.

```hcl
locals {
  project_name = "myapp"
  environment  = "dev"

  # Computed value combining other locals/variables
  bucket_name = "${local.project_name}-${local.environment}-data"
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = local.bucket_name
  tags   = local.common_tags
}
```

```
┌────────────────────────────────────────────────────┐
│         variable vs locals                          │
├─────────────────────┬──────────────────────────────┤
│   variable          │   locals                     │
├─────────────────────┼──────────────────────────────┤
│ Set by USER         │ Set in CODE only             │
│ Input to module     │ Internal computation         │
│ var.name            │ local.name                   │
│ Can have default    │ Always has a value           │
└─────────────────────┴──────────────────────────────┘
```

### 3.8 Output Block

**Outputs** display useful information after `terraform apply` completes.

```hcl
output "bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.arn
}
```

---

## 4. Installation

### Linux (Ubuntu/Debian)

```bash
# 1. Install dependencies
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

# 2. Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# 3. Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# 4. Install Terraform
sudo apt-get update && sudo apt-get install terraform

# 5. Verify installation
terraform -version
```

### macOS

```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform -version
```

### Windows

```powershell
# Using Chocolatey
choco install terraform

# OR download from: https://developer.hashicorp.com/terraform/downloads
# Extract the zip and add terraform.exe to your PATH

# Verify
terraform -version
```

### AWS CLI Setup (Required for AWS Provider)

```bash
# Install AWS CLI
# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
# Enter:
#   AWS Access Key ID: <your-access-key>
#   AWS Secret Access Key: <your-secret-key>
#   Default region: us-east-1
#   Default output format: json
```

---

## 5. Terraform Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                    Terraform Workflow                              │
│                                                                   │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│   │  Write    │    │  Init    │    │   Plan   │    │  Apply   │  │
│   │  .tf      │───▶│          │───▶│          │───▶│          │  │
│   │  files    │    │ Download │    │ Preview  │    │ Create   │  │
│   │          │    │ providers│    │ changes  │    │ infra    │  │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│                                                        │         │
│                                                        ▼         │
│                                                  ┌──────────┐   │
│                                                  │ Destroy  │   │
│                                                  │ (cleanup)│   │
│                                                  └──────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

| Command | What It Does |
|---|---|
| `terraform init` | Initializes the project, downloads provider plugins |
| `terraform plan` | Shows what changes will be made (dry run) |
| `terraform apply` | Actually creates/updates the infrastructure |
| `terraform destroy` | Deletes all resources managed by Terraform |
| `terraform fmt` | Formats `.tf` files to canonical style |
| `terraform validate` | Validates syntax and configuration |
| `terraform output` | Shows output values |
| `terraform state list` | Lists all resources in state |

---

## 6. Hands-On: Create an S3 Bucket (Local Backend)

We'll create a simple S3 bucket using Terraform with the **local backend** (state file stored on your machine).

### Project Structure

```
01-local-backend/
├── main.tf           # Main resources
├── provider.tf       # Provider configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── terraform.tfvars  # Variable values
```

> 📁 See the [01-local-backend/](01-local-backend/) folder for the complete working code.

### Step-by-Step

#### Step 1: Create `provider.tf`

```hcl
# provider.tf — Configure the AWS provider

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

#### Step 2: Create `variables.tf`

```hcl
# variables.tf — Input variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
```

#### Step 3: Create `main.tf`

```hcl
# main.tf — Create an S3 bucket

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "terraform-beginners"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

#### Step 4: Create `outputs.tf`

```hcl
# outputs.tf — Display useful info after apply

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.arn
}

output "bucket_region" {
  description = "Region of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.region
}
```

#### Step 5: Create `terraform.tfvars`

```hcl
# terraform.tfvars — Set values for variables

aws_region  = "us-east-1"
bucket_name = "my-terraform-beginner-bucket-12345"
environment = "dev"
```

#### Step 6: Run Terraform Commands

```bash
# Navigate to project folder
cd 01-local-backend/

# 1. Initialize — downloads AWS provider plugin
terraform init

# 2. Format — auto-format your .tf files
terraform fmt

# 3. Validate — check for syntax errors
terraform validate

# 4. Plan — preview what will be created
terraform plan

# 5. Apply — create the infrastructure!
terraform apply
# Type "yes" when prompted

# 6. Check outputs
terraform output

# 7. When done, destroy everything
terraform destroy
# Type "yes" when prompted
```

```
What happens when you run these commands:

terraform init
  └─▶ Creates .terraform/ directory
  └─▶ Downloads AWS provider plugin
  └─▶ Creates .terraform.lock.hcl (dependency lock)

terraform plan
  └─▶ Reads .tf files
  └─▶ Compares with state file (empty for first run)
  └─▶ Shows: "+ aws_s3_bucket.my_bucket will be created"

terraform apply
  └─▶ Runs plan again
  └─▶ Asks for confirmation ("yes")
  └─▶ Creates S3 bucket in AWS
  └─▶ Updates terraform.tfstate file
  └─▶ Shows outputs

terraform destroy
  └─▶ Reads state file
  └─▶ Shows: "- aws_s3_bucket.my_bucket will be destroyed"
  └─▶ Asks for confirmation ("yes")
  └─▶ Deletes S3 bucket from AWS
  └─▶ Updates state file
```

---

## 7. Remote Backend

By default, Terraform stores state **locally** in `terraform.tfstate`. For teams, you should use a **remote backend** to store state in a shared location.

### Why Remote Backend?

```
┌─────────────────────────────────────────────────────────────┐
│              Local Backend (Default)                          │
│                                                              │
│  Developer A          Developer B                            │
│  ┌───────────┐        ┌───────────┐                         │
│  │ .tfstate  │        │ .tfstate  │    ❌ Two different      │
│  │ (local)   │        │ (local)   │       state files!       │
│  └───────────┘        └───────────┘    ❌ Conflicts!         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Remote Backend (S3)                              │
│                                                              │
│  Developer A          Developer B                            │
│  ┌───────────┐        ┌───────────┐                         │
│  │           │        │           │                          │
│  └─────┬─────┘        └─────┬─────┘                         │
│        │                    │                                │
│        └────────┬───────────┘                                │
│                 ▼                                             │
│        ┌──────────────┐                                      │
│        │  S3 Bucket   │     ✅ Single source of truth        │
│        │  .tfstate    │     ✅ State locking with DynamoDB   │
│        └──────────────┘     ✅ Versioning & encryption       │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure

```
02-remote-backend/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

> 📁 See the [02-remote-backend/](02-remote-backend/) folder for the complete working code.

### Step 1: Create the Backend S3 Bucket & DynamoDB Table First

> ⚠️ You must create the backend S3 bucket BEFORE using it. You can create it manually in the AWS console or with a separate Terraform project.

### Step 2: Configure Remote Backend in `provider.tf`

```hcl
# provider.tf — Remote backend configuration

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Store state remotely in S3
  backend "s3" {
    bucket         = "my-terraform-state-bucket-12345"
    key            = "beginners-guide/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
```

### Step 3: Run Terraform

```bash
cd 02-remote-backend/

# Init will configure the remote backend
terraform init

# Now plan and apply as usual
terraform plan
terraform apply
```

```
What happens with remote backend:

terraform init
  └─▶ Connects to S3 bucket
  └─▶ Downloads existing state (if any)
  └─▶ All future state operations go to S3

terraform apply
  └─▶ Locks state via DynamoDB (prevents conflicts)
  └─▶ Reads state from S3
  └─▶ Creates resources
  └─▶ Writes updated state to S3
  └─▶ Releases DynamoDB lock
```

### Migrating from Local to Remote

If you already have a local state and want to move to remote:

```bash
# 1. Add the backend "s3" block to your provider.tf
# 2. Run init with migration flag
terraform init -migrate-state

# Terraform will ask:
# "Do you want to copy existing state to the new backend?"
# Type "yes"
```

---

## 8. Terraform Workspaces

**Workspaces** allow you to manage multiple environments (dev, staging, prod) using the **same Terraform code** but with **separate state files**.

```
┌─────────────────────────────────────────────────────────┐
│                  Terraform Workspaces                     │
│                                                          │
│  Same .tf code ──┬──▶ workspace: dev   ──▶ dev state    │
│                  │                                       │
│                  ├──▶ workspace: staging──▶ staging state│
│                  │                                       │
│                  └──▶ workspace: prod  ──▶ prod state   │
│                                                          │
│  Each workspace has its own terraform.tfstate             │
└─────────────────────────────────────────────────────────┘
```

### Project Structure

```
03-workspaces/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

> 📁 See the [03-workspaces/](03-workspaces/) folder for the complete working code.

### Workspace-Aware Configuration

```hcl
# main.tf — Using workspaces

locals {
  environment = terraform.workspace     # "default", "dev", "staging", "prod"

  bucket_name = "myapp-${local.environment}-data-12345"

  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "app_data" {
  bucket = local.bucket_name
  tags   = local.common_tags
}
```

### Workspace Commands

```bash
cd 03-workspaces/
terraform init

# List workspaces (* = current)
terraform workspace list
# * default

# Create and switch to "dev" workspace
terraform workspace new dev

# Apply — creates S3 bucket "myapp-dev-data-12345"
terraform apply

# Create and switch to "prod" workspace
terraform workspace new prod

# Apply — creates S3 bucket "myapp-prod-data-12345"
terraform apply

# Switch between workspaces
terraform workspace select dev

# Show current workspace
terraform workspace show
# dev
```

```
Workspace Commands Summary:

terraform workspace list           # List all workspaces
terraform workspace new <name>     # Create + switch to new workspace
terraform workspace select <name>  # Switch to existing workspace
terraform workspace show           # Show current workspace
terraform workspace delete <name>  # Delete a workspace
```

---

## 9. Terraform Modules

A **module** is a reusable package of Terraform code. Instead of copying the same resource blocks everywhere, you write them once in a module and call it multiple times.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Without Modules                                │
│                                                                  │
│  project-a/main.tf        project-b/main.tf                     │
│  ┌──────────────┐         ┌──────────────┐                      │
│  │ S3 bucket    │         │ S3 bucket    │   ❌ Duplicated code  │
│  │ versioning   │         │ versioning   │   ❌ Hard to maintain │
│  │ tags         │         │ tags         │                       │
│  │ encryption   │         │ encryption   │                       │
│  └──────────────┘         └──────────────┘                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     With Modules                                  │
│                                                                   │
│                  modules/s3-bucket/                                │
│                  ┌──────────────┐                                  │
│                  │ S3 bucket    │   ✅ Write once                  │
│                  │ versioning   │   ✅ Reuse everywhere            │
│                  │ tags         │   ✅ Easy to maintain             │
│                  │ encryption   │                                  │
│                  └──────┬───────┘                                  │
│                 ┌───────┴────────┐                                 │
│                 ▼                ▼                                 │
│  project-a/main.tf    project-b/main.tf                           │
│  module "bucket" {    module "bucket" {                            │
│    source = "../.."     source = "../.."                           │
│    name = "app-a"       name = "app-b"                             │
│  }                    }                                            │
└─────────────────────────────────────────────────────────────────┘
```

### Project Structure

```
04-modules/
├── modules/
│   └── s3-bucket/
│       ├── main.tf           # S3 resource definitions
│       ├── variables.tf      # Module inputs
│       └── outputs.tf        # Module outputs
├── main.tf                   # Root — calls the module
├── provider.tf               # Provider config
├── variables.tf              # Root variables
├── outputs.tf                # Root outputs
└── terraform.tfvars          # Variable values
```

> 📁 See the [04-modules/](04-modules/) folder for the complete working code.

### Module Code: `modules/s3-bucket/`

**modules/s3-bucket/variables.tf**

```hcl
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}
```

**modules/s3-bucket/main.tf**

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

**modules/s3-bucket/outputs.tf**

```hcl
output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}
```

### Root Code: Using the Module

**main.tf (root)**

```hcl
# Create multiple S3 buckets using the same module

module "app_data_bucket" {
  source = "./modules/s3-bucket"

  bucket_name       = "${var.project_name}-app-data-${var.environment}"
  environment       = var.environment
  enable_versioning = true
}

module "logs_bucket" {
  source = "./modules/s3-bucket"

  bucket_name       = "${var.project_name}-logs-${var.environment}"
  environment       = var.environment
  enable_versioning = false
}
```

**outputs.tf (root)**

```hcl
output "app_data_bucket_name" {
  value = module.app_data_bucket.bucket_id
}

output "app_data_bucket_arn" {
  value = module.app_data_bucket.bucket_arn
}

output "logs_bucket_name" {
  value = module.logs_bucket.bucket_id
}

output "logs_bucket_arn" {
  value = module.logs_bucket.bucket_arn
}
```

### Running

```bash
cd 04-modules/

# Init will detect and download the local module
terraform init

terraform plan
# You'll see TWO S3 buckets being created:
#   module.app_data_bucket.aws_s3_bucket.this
#   module.logs_bucket.aws_s3_bucket.this

terraform apply
```

---

## 10. Summary & Cheat Sheet

### Concept Map

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        TERRAFORM OVERVIEW                                │
│                                                                          │
│  ┌───────────┐    ┌──────────────┐    ┌─────────┐    ┌──────────────┐   │
│  │ variables │───▶│              │───▶│  state  │───▶│ Cloud Infra  │   │
│  │ .tfvars   │    │   .tf files  │    │  .tfstate│    │ (AWS S3 etc) │   │
│  └───────────┘    │              │    └─────────┘    └──────────────┘   │
│                   │  - resource  │                                       │
│  ┌───────────┐    │  - data      │    ┌─────────┐                       │
│  │  locals   │───▶│  - provider  │    │ backend │                       │
│  └───────────┘    │  - output    │    │ (local/ │                       │
│                   │  - module    │    │  remote) │                       │
│  ┌───────────┐    │              │    └─────────┘                       │
│  │  modules  │───▶│              │                                       │
│  └───────────┘    └──────────────┘    ┌──────────┐                      │
│                                       │workspace │                      │
│                                       │dev|stg|  │                      │
│                                       │prod      │                      │
│                                       └──────────┘                      │
└─────────────────────────────────────────────────────────────────────────┘
```

### Quick Reference

| What | Syntax | Example |
|---|---|---|
| Define a resource | `resource "type" "name" {}` | `resource "aws_s3_bucket" "b" {}` |
| Read existing infra | `data "type" "name" {}` | `data "aws_s3_bucket" "b" {}` |
| Declare variable | `variable "name" {}` | `variable "region" { type = string }` |
| Use variable | `var.name` | `var.region` |
| Define local | `locals { name = "val" }` | `locals { env = "dev" }` |
| Use local | `local.name` | `local.env` |
| Define output | `output "name" { value = ... }` | `output "id" { value = aws_s3_bucket.b.id }` |
| Call module | `module "name" { source = "..." }` | `module "bucket" { source = "./modules/s3" }` |
| Use module output | `module.name.output` | `module.bucket.bucket_id` |
| Current workspace | `terraform.workspace` | `"dev"`, `"prod"` |

### .gitignore for Terraform Projects

```gitignore
# Local .terraform directory
.terraform/

# State files (when using local backend)
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Variable files with sensitive data
*.tfvars
!example.tfvars

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI configuration files
.terraformrc
terraform.rc

# Lock file (keep this in Git!)
# .terraform.lock.hcl
```

---

**Happy Terraforming! 🚀**

Start with the `01-local-backend/` example, get comfortable, then progress through remote backend, workspaces, and modules.
