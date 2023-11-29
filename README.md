# Three Tier SAP JAVA on HANA DB Deployment using Automation

## Description
This automation solution is designed for the deployment of **Three Tier SAP JAVA on HANA DB** using IBM Cloud Schematics or CLI. The SAP solution will be deployed on top of one of the following Operating Systems: **Red Hat Enterprise Linux 8.6 for SAP**, **Red Hat Enterprise Linux 8.4 for SAP**, **SUSE Linux Enterprise Server 15 SP 4 for SAP**, **SUSE Linux Enterprise Server 15 SP 3 for SAP**, in an existing IBM Cloud Gen2 VPC, using an existing bastion host with secure remote SSH access.

In order to track the events specific to the resources deployed by this solution, the [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov) to be used should be specified. IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen.

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 Prerequisites](#12-prerequisites)
- [1.3 VSI Configuration](#13-vsi-configuration)
- [1.4 VPC Configuration](#14-vpc-configuration)
- [1.5 Files description and structure](#15-files-description-and-structure)
- [2.1 Executing the deployment of **Three Tier SAP Java HANA Stack** in GUI (Schematics)](#21-executing-the-deployment-of-three-tier-sap-java-hana-stack-in-gui-schematics)
- [2.2 Executing the deployment of **Three Tier SAP Java HANA Stack** in CLI](#22-executing-the-deployment-of-three-tier-sap-java-hana-stack-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS05** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

SAP JAVA installation media used for this deployment is the default one for **SAP Netweaver 7.5** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Prerequisites

- A Deployment Server (BASTION Server) in the same VPC should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- On the Deployment Server, download the SAP kits from the SAP Portal. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.

## 1.3 VSI Configuration
The VSIs are deployed with one of the following Operating Systems for DB server: Red Hat Enterprise Linux 8.6 for SAP HANA (amd64), Red Hat Enterprise Linux 8.4 for SAP HANA (amd64), Suse Linux Enterprise Server 15 SP 4 for SAP HANA (amd64) or Suse Linux Enterprise Server 15 SP 3 for SAP HANA (amd64) and with one of the following Operating Systems for APP server: Red Hat Enterprise Linux 8.6 for SAP Applications (amd64), Red Hat Enterprise Linux 8.4 for SAP Applications (amd64), Suse Enterprise Linux 15 SP4 for SAP Applications (amd64) or Suse Enterprise Linux 15 SP3 for SAP Applications (amd64). The SSH keys are configured to allow root user access. The following storage volumes are creating during the provisioning:

HANA DB VSI Disks:
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Updated on 2023-03-08

  Note: LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, excepting **`vx2d-44x616`** and **`vx2d-88x1232`** profiles, where **`/hana/data`** and **`/hana/shared`** won't be manged by LVM, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Updated on 2023-03-08 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations#hana-iaas-mx2-16x128-32x256-configure) - Updated on 2022-05-19

  For example, in case of deploying a HANA VM, using the default value for VSI profile `mx2-16x128`, the automation will execute the following storage setup:  
  - 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
    - the volume group will contain the following logical volumes (created with three stripes):
      - `<sid>_hana_data_lv` - size 988 GB
      - `<sid>_hana_log_lv` - size 256 GB
      - `<sid>_hana_shared` - size 256 GB
  - 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
  - 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

SAP JAVA APP VSI Disks:
- 1 x 40 GB disk with 10 IOPS / GB - SWAP
- 1 x 128 GB disk with 10 IOPS / GB - DATA

## 1.4 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

 ## 1.5 Files description and structure:

 - `modules` - directory containing the terraform modules.
 - `ansible`  - directory containing the SAP ansible playbooks.
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (VPC, Hostname, Private IP).
 - `integration*.tf & generate*.tf` files - contain the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI.
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `sch.auto.tfvars` - contains programatic variables.

In order to perform the deployment you can use either the CLI component or the GUI component (Schematics) of the automation solution.

## 2.1 Executing the deployment of **Three Tier SAP Java HANA Stack** in GUI (Schematics)

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
  -  Terraform scripts for the deployment of two VSIs, in an EXISTING VPC, with Subnet and Security Group. The VSIs are intended to be used: one for the data base instance and the other for the application instance.
  -  The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0. Note: The deployment was tested with Terraform 1.5.7
  -  Bash scripts used for the checking of the prerequisites required by SAP VSIs deployment and for the integration into a single step in IBM Schematics GUI of the VSI provisioning and the **Three Tier SAP Java HANA Stack** installation.
  -  Ansible scripts to configure Three Tier SAP JAVA primary application server and a HANA 2.0 node. Please note that Ansible is started by Terraform and must be available on the same host.

## IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).

## Input parameters
The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables, as below:

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).
PRIVATE_SSH_KEY | id_rsa private key content in OpenSSH format (Sensitive* value). This private key should be used only during the provisioning and is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | File path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_abap_db2_dst<br /> Default value: "ansible/id_rsa".
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSIs. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> ["r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e"]
BASTION_FLOATING_IP | The BASTION FLOATING IP. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.
RESOURCE_GROUP | The name of an EXISTING Resource Group, previously created by the user. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | Availability zone for VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet, in the same VPC, region and zone as the VSIs to be created. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets).
SECURITY_GROUP | The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
DB_HOSTNAME | The Hostname for the DB VSI. The hostname must have up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note *611361 - Hostnames of SAP ABAP Platform servers*
DB_PROFILE |  The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs is available [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc). <br> Details about all x86 instance profiles are available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "mx2-16x128"
DB_IMAGE | The OS image used for DB VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Supported images: ibm-redhat-8-6-amd64-sap-hana-4, ibm-redhat-8-4-amd64-sap-hana-7, ibm-sles-15-4-amd64-sap-hana-5, ibm-sles-15-3-amd64-sap-hana-8. Default value: ibm-ibm-redhat-8-6-amd64-sap-hana-4
APP_HOSTNAME | The Hostname for the DB VSI. The hostname must have up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note *611361 - Hostnames of SAP ABAP Platform servers*
APP_PROFILE |  The profile used for the APP VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "bx2-4x16"
APP_IMAGE | The OS image used for the APP VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Supported images: ibm-redhat-8-6-amd64-sap-applications-4, ibm-redhat-8-4-amd64-sap-applications-7, ibm-sles-15-4-amd64-sap-applications-6, ibm-sles-15-3-amd64-sap-applications-9. Default value: ibm-redhat-8-6-amd64-sap-applications-4

**Activity Tracker input parameters:**

Parameter | Description
----------|------------
ATR_NAME | The name of the EXISTENT Activity Tracker instance, in the same region chosen for SAP system deployment.

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
HANA_SID | The SAP system ID, which identifies the SAP HANA system | <ul><li>Consists of exactly three alphanumeric characters and the first character must be a letter</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
HANA_SYSNO | The instance number of the SAP HANA system| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HANA_SYSTEM_USAGE  | SAP HANA System Usage | Default: custom<br> Valid values: production, test, development, custom
HANA_COMPONENTS | SAP HANA Components | Default: server<br> Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file (See Obs*) | As downloaded from SAP Support Portal
SAP_SID | The SAP system ID. Identifies the entire SAP system. <br /> Default value: DB1 | <ul><li>Consists of exactly three alphanumeric characters and the first character must be a letter</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
SAP_CI_INSTANCE_NUMBER | The SAP central instance number. Technical identifier for internal processes of PAS.  <br /> Default value: 00 | <ul><li>Consists of a two-digit number from 00 to 97. </li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming.</li></ul>
SAP_SCS_INSTANCE_NUMBER | The central service instance number. Technical identifier for internal processes of SCS.  <br /> Default value: 01 | <ul><li>Consists of a two-digit number from 00 to 97. </li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming.</li></ul>
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation. (Sensitive* value). | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSEXE_FILE | Path to IGS archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPJVM_FILE | Path to SAP JVM archive (SAR) | As downloaded from SAP Support Portal
KIT_JAVA_EXPORT | Path to JAVA Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path
KIT_HDBCLIENT_FILE | Path to SAP HANA client file (SAR) | As downloaded from SAP Support Portal

**Obs***: <br />
 - **SAP Main Password.**
The password for the SAP system will be hidden during the schematics apply step and will not be available after the deployment.

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.
- OS **image** for **DB VSI.** Supported OS images for DB VSIs: ibm-redhat-8-6-amd64-sap-hana-4, ibm-redhat-8-4-amd64-sap-hana-7, ibm-sles-15-4-amd64-sap-hana-5, ibm-sles-15-3-amd64-sap-hana-8.
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable:  DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"
- OS **image** for **SAP APP VSI**. Supported OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-applications-4, ibm-redhat-8-4-amd64-sap-applications-7, ibm-sles-15-4-amd64-sap-applications-6, ibm-sles-15-3-amd64-sap-applications-9. 
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable: APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
-  SAP **HANA Installation path kit**
     - Supported SAP HANA versions on Red Hat 8 and Suse 15: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
     - Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"
     - Default variable:  KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"

## Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the private IP addresses of the VSI hosts, the hostnames, the storage layount for HANA VSI and the activity tracker name.  

## 2.2 Executing the deployment of **Three Tier SAP Java HANA Stack** in CLI

The solution is based on Terraform scripts and Ansible playbooks executed in CLI and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
  -  Terraform scripts for the deployment of two VSIs, in an EXISTING VPC, with Subnet and Security Group. The VSIs are intended to be used: one for the database instance and the other for the application instance.
  -  The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0. Note: The deployment was tested with Terraform 1.5.7
  -  Ansible scripts to configure Three Tier SAP JAVA primary application server and a HANA 2.0 node. Please note that Ansible is started by Terraform and must be available on the same host.

## IBM Cloud API Key

For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).

## Input parameter file

The `input.auto.tfvars` file must be used to make the desired configuration, as in the example bellow:

**VSI input parameters**

```shell
##########################################################
# General VPC variables:
######################################################

REGION = "eu-de"
# The cloud region where to deploy the solution. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-2"
# Availability zone for VSIs, in the REGION. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-2"

VPC = "ic4sap"
# The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.
# The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# The name of an EXISTING Resource Group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# The name of an EXISTING Subnet, in the same VPC and ZONE where the VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. 
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c","r011-8f72v884-c17f-4500-af8f-d05900374t3c"]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSIs. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# The path to an existing id_rsa private key file, with 0600 permissions. The private key must be in OpenSSH format.
# This private key is used only during the provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_java" , "~/.ssh/id_rsa_java" , "/root/.ssh/id_rsa".

##########################################################
# DB VSI variables:
##########################################################

DB_HOSTNAME = "sapjavdb"
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: HOSTNAME = "ic4sap"

DB_PROFILE = "mx2-16x128"
# The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).
# For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) 
# Default value: "mx2-16x128"

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"
# OS image for DB VSI. Supported OS images for DB VSIs: ibm-redhat-8-6-amd64-sap-hana-4, ibm-redhat-8-4-amd64-sap-hana-7, ibm-sles-15-4-amd64-sap-hana-5, ibm-sles-15-3-amd64-sap-hana-8.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4" 

##########################################################
# SAP APP VSI variables:
##########################################################

APP_HOSTNAME = "sapjavci"
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Example: HOSTNAME = "ic4sap"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
# OS image for SAP APP VSI. Supported OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-applications-4, ibm-redhat-8-4-amd64-sap-applications-7, ibm-sles-15-4-amd64-sap-applications-6, ibm-sles-15-3-amd64-sap-applications-9.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP_IMAGE = "ibm-redhat-8-46-amd64-sap-applications-4" 

##########################################################
# Activity Tracker variables:
##########################################################

ATR_NAME = "Activity-Tracker-SAP-eu-de"
# The name of the EXISTENT Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tracker-SAP-eu-de"

```

**SAP input parameters**

```shell
##########################################################
# SAP HANA configuration
##########################################################

HANA_SID = "HDB"
# The SAP system ID, which identifies the SAP HANA system. Should follow the SAP rules for SID naming.
# Consists of three alphanumeric characters and the first character must be a letter. 
# Does not include any of the reserved IDs listed in SAP Note 1979280
# Example: HANA_SID = "HDB"

HANA_SYSNO = "00"
# The instance number of the SAP HANA system. Should follow the SAP rules for instance number naming.
# Consists of two-digit number from 00 to 97
# Must be unique on a host
# Example: HANA_SYSNO = "01"

HANA_SYSTEM_USAGE = "custom"
# SAP HANA System usage. Default: custom. Suported values: production, test, development, custom
# Example: HANA_SYSTEM_USAGE = "custom"

HANA_COMPONENTS = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: HANA_COMPONENTS = "server"

KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"
# SAP HANA Installation kit path (ZIP file), as downloaded from SAP Support Portal
# Supported SAP HANA versions on Red Hat 8 and Suse 15: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
# Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "JV1"
# The SAP system ID identifies the entire SAP system. 
# Consists of three alphanumeric characters and the first character must be a letter. 
# Does not include any of the reserved IDs listed in SAP Note 1979280

SAP_SCS_INSTANCE_NUMBER = "01"
# The central service instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_SCS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "00"
# The SAP central instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "06"

##########################################################
# SAP JAVA APP Installation kit path
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE = "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
KIT_SAPEXE_FILE = "/storage/NW75HDB/SAPEXE_801-80002573.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75HDB/SAPEXEDB_801-80002572.SAR"
KIT_IGSEXE_FILE = "/storage/NW75HDB/igsexe_13-80003187.sar"
KIT_IGSHELPER_FILE = "/storage/NW75HDB/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
KIT_HDBCLIENT_FILE = "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
KIT_SAPJVM_FILE = "/storage/NW75HDB/SAPJVM8_73-80000202.SAR"
KIT_JAVA_EXPORT = "/storage/NW75HDB/export"
```

**SAP Main Password**
The password for the SAP system (all users that are created during the installation) will be asked interactively during terraform plan step and will not be available after the deployment. It must contain at least one digit (0-9). It must not contain \ (backslash) and " (double quote)

## Steps to follow:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY' and 'SAP_MAIN_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase: 'IBMCLOUD_API_KEY' and 'SAP_MAIN_PASSWORD'.
```

### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
