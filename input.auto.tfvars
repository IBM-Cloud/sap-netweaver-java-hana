##########################################################
# General VPC variables:
######################################################

REGION = ""
# The cloud region where to deploy the solution. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = ""
# The cloud region where to deploy the solution. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

VPC = ""
# The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

SECURITY_GROUP = ""
# The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.
# The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = ""
# The name of an EXISTING Resource Group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = ""
# The name of an EXISTING Subnet, in the same VPC and ZONE where the VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. 
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [""]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSIs. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8..................3c", "r010-f.......................h"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# Input your existing id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_abap_ase-syb_std" , "~/.ssh/id_rsa_abap_ase-syb_std" , "/root/.ssh/id_rsa".

##########################################################
# DB VSI variables:
##########################################################

DB_HOSTNAME = ""
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: HOSTNAME = "ic4sap"

DB_PROFILE = "mx2-16x128"
# The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).
# For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) 
# Default value: "mx2-16x128"

DB_IMAGE = "ibm-redhat-9-4-amd64-sap-hana-3"
# OS image for DB VSI. 
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6" 

##########################################################
# SAP APP VSI variables:
##########################################################

APP_HOSTNAME = ""
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Example: HOSTNAME = "ic4sap"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-9-4-amd64-sap-applications-3"
# OS image for SAP APP VSI. 
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-6" 

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

HANA_TENANT = "JV1"
# SAP HANA tenant name
# Example:HANA_TENANT = "HDB_TEN1"

HANA_SYSTEM_USAGE = "custom"
# SAP HANA System usage. Default: custom. Suported values: production, test, development, custom
# Example: HANA_SYSTEM_USAGE = "custom"

HANA_COMPONENTS = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: HANA_COMPONENTS = "server"

KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev77/IMDB_SERVER20_077_0-80002031.SAR"
# SAP HANA Installation kit path (ZIP/SAR file), as downloaded from SAP Support Portal
# Example: KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev77/IMDB_SERVER20_077_0-80002031.SAR"

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

JAVA_PRODUCT_INSTANCES = []
# The list of JAVA product instances. The list can contain the following elements: AdobeDocumentServices, BIJAVA, BPM, 
# CentralProcessScheduling, CompositionPlatform, DevelopmentInfrastructure, EPCore-ApplicationPortal, EnterprisePortal, 
# EnterpriseServicesRepository, PDFExport
# Example: JAVA_PRODUCT_INSTANCES = ["AdobeDocumentServices", "BIJAVA"]

JAVA_NODES = "2"
# The number of JAVA server nodes

##########################################################
# SAP JAVA APP Installation kit path
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75HDB/SAPCAR_1300-70007716.EXE"
KIT_SWPM_FILE = "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR"
KIT_SAPEXE_FILE = "/storage/NW75HDB/KERNEL/7.54UC/SAPEXE_400-80007612.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75HDB/KERNEL/7.54UC/SAPEXEDB_400-80007611.SAR"
KIT_IGSEXE_FILE = "/storage/NW75HDB/KERNEL/7.54UC/igsexe_5-80007786.sar"
KIT_IGSHELPER_FILE = "/storage/NW75HDB/KERNEL/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR"
KIT_HDBCLIENT_FILE = "/storage/NW75HDB/IMDB_CLIENT20_022_32-80002082.SAR"
KIT_SAPJVM_FILE = "/storage/NW75HDB/SAPJVM81/SAPJVM8_102-80000202.SAR"
KIT_JAVA_EXPORT_FILE = "/storage/NW75HDB/JAVAEXP/SP22/51055106.ZIP"
