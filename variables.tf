variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "File path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_java"
}

variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "id_rsa private key content in OpenSSH format (Sensitive value). This private key should be used only during the provisioning and is recommended to be changed after the SAP deployment."
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSIs. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys"
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "BASTION_FLOATING_IP" {
	type		= string
	description = "The BASTION FLOATING IP. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message."
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group, previously created by the user. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups"
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy the solution. The regions and zones for VPC are available here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations in IBM Cloud Schematics: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
	validation {
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east"], var.REGION )
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE" {
	type		= string
	description	= "Availability zone for VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc"
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet, in the same VPC, region and zone as the VSIs to be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "DB_HOSTNAME" {
	type		= string
	description = "The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP"
	validation {
		condition     = length(var.DB_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_PROFILE" {
	type		= string
	description = "The profile for the DB VSI. The certified profiles for SAP HANA in IBM VPC: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc"
	default		= "mx2-16x128"
	validation {
		condition     = contains(keys(jsondecode(file("files/hana_volume_layout.json")).profiles), "${var.DB_PROFILE}")
		error_message = "The chosen storage PROFILE for HANA VSI \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
	}
}

variable "DB_IMAGE" {
	type		= string
	description = "OS image for DB VSI. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-4"
	validation {
		condition     = length(regexall("^(ibm-redhat-8-6-amd64-sap-hana|ibm-redhat-8-4-amd64-sap-hana|ibm-sles-15-3-amd64-sap-hana|ibm-sles-15-4-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
		error_message = "The OS SAP DB_IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-x\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 }
}

variable "APP_HOSTNAME" {
	type		= string
	description = "The Hostname for the APP VSI. The hostname should be up to 13 characters, as required by SAP"
	validation {
		condition     = length(var.APP_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME)) > 0
		error_message = "The APP_HOSTNAME is not valid."
	}
}

variable "APP_PROFILE" {
	type		= string
	description = "The profile for the APP VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. For more information, check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
	default		= "bx2-4x16"
}

variable "APP_IMAGE" {
	type		= string
	description = "OS image for APP VSI. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-applications-4"
	validation {
			condition     = length(regexall("^(ibm-redhat-8-6-amd64-sap-applications|ibm-redhat-8-4-amd64-sap-applications|ibm-sles-15-3-amd64-sap-applications|ibm-sles-15-4-amd64-sap-applications)-[0-9][0-9]*", var.APP_IMAGE)) > 0
			error_message = "The OS SAP APP_IMAGE must be one of \"ibm-redhat-8-6-amd64-sap-applications-x\" ,  \"ibm-redhat-8-4-amd64-sap-applications-x\" , \"ibm-sles-15-4-amd64-sap-applications-x\" or \"ibm-sles-15-3-amd64-sap-applications-x\"."
 }
}

data "ibm_is_instance" "db-vsi" {
  depends_on = [module.db-vsi]
  name    =  var.DB_HOSTNAME
}

data "ibm_is_instance" "app-vsi" {
  depends_on = [module.app-vsi]
  name    =  var.APP_HOSTNAME
}

variable "HANA_SID" {
	type		= string
	description = "The SAP HANA system ID. Identifies the entire SAP HANA system. Consists of three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280."
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0
		error_message = "The HANA_SID is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "The instance number of the SAP HANA system. Should follow the SAP rules for instance number naming. Consists of two-digit number from 00 to 97. Must be unique on a host"
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "SAP HANA System usage. Suported values: production, test, development, custom"
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE ) 
		error_message = "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "SAP HANA Components. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp"
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS ) 
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "SAP HANA Installation kit path (ZIP file), as downloaded from SAP Support Portal"
	default		= "/storage/HANADB/51055299.ZIP"
}

variable "SAP_SID" {
	type		= string
	description = "The SAP system ID. Identifies the entire SAP system. Consists of three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280."
	default		= "S4A"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.SAP_SID)) > 0
		error_message = "The SAP_SID is not valid."
	}
}

variable "SAP_SCS_INSTANCE_NUMBER" {
	type		= string
	description = "The central service instance number. Technical identifier for internal processes of SCS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming."
	default		= "01"
	validation {
		condition     = var.SAP_SCS_INSTANCE_NUMBER >= 0 && var.SAP_SCS_INSTANCE_NUMBER <=97
		error_message = "The SAP_SCS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "The SAP central instance number. Technical identifier for internal processes of PAS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming"
	default		= "00"
	validation {
		condition     = var.SAP_CI_INSTANCE_NUMBER >= 0 && var.SAP_CI_INSTANCE_NUMBER <=97
		error_message = "The SAP_CI_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "The SAP MAIN Password. Common password for all users that are created during the installation. Must be 8 to 14 characters long, must contain at least one digit (0-9) and one uppercase letter, and must not contain \\ (backslash) and \" (double quote)."
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.SAP_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary, as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR), as downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "Path to SAP Kernel OS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPEXE_801-80002573.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "Path to SAP Kernel DB archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPEXEDB_801-80002572.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "Path to IGS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/igsexe_13-80003187.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "Path to IGS Helper archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "Path to SAP HANA client file (SAR), as downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
}

variable "KIT_SAPJVM_FILE" {
	type		= string
	description = "Path to SAP JVM archive (SAR), as downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SAPJVM8_73-80000202.SAR"
}

variable "KIT_JAVA_EXPORT" {
	type		= string
	description = "Path to JAVA Installation Export dir. The archives downloaded from SAP Support Portal should be present in this path"
	default		= "/storage/NW75HDB/export"
}

##############################################################
# The variables used in Activity Tracker service.
##############################################################

variable "ATR_NAME" {
  type        = string
  description = "The name of the EXISTING Activity Tracker instance, in the same region as HANA VSI. The list of available Activity Tracker is available here: https://cloud.ibm.com/observe/activitytracker"
  default = ""
}

# ATR variables and conditions

locals {
	ATR_ENABLE = true
}

resource "null_resource" "check_atr_name" {
  count             = local.ATR_ENABLE == true ? 1 : 0
  lifecycle {
    precondition {
      condition     = var.ATR_NAME != "" && var.ATR_NAME != null
      error_message = "The name of an EXISTENT Activity Tracker in the same region must be specified."
    }
  }
}

data "ibm_resource_instance" "activity_tracker" {
  count             = local.ATR_ENABLE == true ? 1 : 0
  name              = var.ATR_NAME
  location          = var.REGION
  service           = "logdnaat"
}
