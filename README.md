# Multi-Region Azure Deployment Using Terraform and GitHub Actions

## Project Overview

Created Azure infrastructure using Terraform and automated the deployment using GitHub Actions.

The project deployed:

- 2 VMs in Spain Central
- 2 VMs in Israel Central
- 1 VM in Central India

The required networking resources were also created for the VMs.

## CI/CD Workflow

The project used two GitHub Actions workflows:

- **CI workflow:** Triggered manually using **Workflow Dispatch**. It initialized Terraform, validated the configuration, and created the Terraform plan.
- **CD workflow:** Ran automatically after the CI workflow completed successfully. It applied the Terraform plan and created the infrastructure in Azure.

The overall flow was:

```text
Workflow Dispatch
       ↓
Terraform CI
       ↓
Terraform Init
       ↓
Terraform Validate
       ↓
Terraform Plan
       ↓
CI Completed Successfully
       ↓
Terraform CD
       ↓
Terraform Apply
       ↓
Azure Infrastructure Created
```

## Infrastructure Created

### Resource Groups

Created three Resource Groups:

- `rg-spain-central`
- `rg-israel-central`
- `rg-central-india`

### Networking

Created the required:

- Virtual Networks (VNets)
- Subnets
- Network Interfaces (NICs)

Each region had its own networking resources.

### Virtual Machines

The VM deployment was configured as:

| Region | VM Count |
|---|---:|
| Spain Central | 2 |
| Israel Central | 2 |
| Central India | 1 |

## Terraform Configuration

The project used Terraform features such as:

- Variables
- Maps
- `for_each`
- `terraform.tfvars`
- Resource outputs
- Terraform state management

The VM count and regional configuration were controlled through variables, which made it easier to manage different numbers of VMs in different regions.

## Remote Terraform State

Terraform remote state was configured using an **Azure Storage Account**.

The state was stored in:

```text
Resource Group
└── rg-terraform-state
    └── Storage Account
        └── tfstate container
            └── terraform.tfstate
```

The remote backend allowed Terraform state to be maintained centrally and used by the CI/CD workflows.

The Terraform state Resource Group and Storage Account were kept separate from the application infrastructure.

## GitHub Actions Variables

The GitHub Actions workflows used repository variables for the deployment configuration.

For example, the VM count for Israel Central was passed through the GitHub Actions variable:

```text
ISRAEL_VM_COUNT
```

This was important because `terraform.tfvars` was not uploaded to the GitHub repository.

The local `terraform.tfvars` file was used for local Terraform testing, while GitHub Actions variables were used by the CI/CD runner.

## Azure Authentication

Azure authentication was configured for GitHub Actions using **OIDC** and an Azure Service Principal.

This allowed GitHub Actions to authenticate with Azure without storing a long-lived Azure password or secret in the workflow.

## Issues Faced and Resolved

### 1. OIDC and Service Principal

Faced issues while configuring OIDC authentication with GitHub Actions and the Azure Service Principal. The correct Service Principal and required configuration were identified and configured.

### 2. Terraform Remote State Permissions

Faced permission issues while accessing the Azure Storage Account used for the Terraform remote state. The required Storage Blob Data Contributor permission was configured.

### 3. Azure Regional VM Quota

Faced an Azure regional CPU quota limitation while creating VMs in Israel Central. The region had a limited number of approved CPU cores, so the VM count was reduced from 3 to 2.

## Terraform State and Resource Management

Existing Azure resources were initially imported into Terraform state during testing.

Later, the application Resource Groups were deleted to start the deployment with a clean Terraform state. The old resources were removed from the Terraform state, while the separate Terraform state Resource Group and Storage Account were kept.

This allowed the CI/CD pipeline to create the application infrastructure from scratch.

## Verification

The CI/CD deployment was completed through GitHub Actions, and finally, the infrastructure was verified through the **Azure Portal**.

## Final Architecture

```text
                    GitHub Repository
                           |
                           v
                  GitHub Actions CI
                  (Workflow Dispatch)
                           |
                           v
                 Terraform Validation
                           |
                           v
                    Terraform Plan
                           |
                           v
                    CI Successful
                           |
                           v
                  GitHub Actions CD
                  (Automatic Trigger)
                           |
                           v
                  Terraform Apply
                           |
                           v
                    Azure Resources
                           |
        +------------------+------------------+
        |                  |                  |
        v                  v                  v
 Spain Central       Israel Central      Central India
    2 VMs                2 VMs                1 VM
```

## Technologies Used

- Microsoft Azure
- Terraform
- GitHub Actions
- Azure CLI
- Azure Storage
- Azure Resource Manager
- OIDC
- Azure Service Principal
- Git
- GitHub

## Project Outcome

Successfully created a multi-region Azure infrastructure setup using Terraform and automated its deployment through a GitHub Actions CI/CD pipeline. Remote Terraform state, Azure authentication, regional VM configuration, and deployment issues were also handled as part of the project.
