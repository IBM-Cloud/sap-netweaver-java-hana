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
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east", "ca-tor", "au-syd", "jp-osa", "jp-tok", "eu-es", "br-sao"], var.REGION)
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east, ca-tor, au-syd, jp-osa, jp-tok, eu-es, br-sao."
	}
}

variable "ZONE" {
	type		= string
	description	= "Availability zone for VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc"
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east|ca-tor|au-syd|jp-osa|jp-tok|eu-es|br-sao)-(1|2|3)$", var.ZONE)) > 0
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
		condition     = contains(keys(jsondecode(file("modules/db-vsi/files/hana_vm_volume_layout.json")).profiles), "${var.DB_PROFILE}")
		error_message = "The chosen storage PROFILE for HANA VSI \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
	}
}

variable "DB_IMAGE" {
	type		= string
	description = "OS image for DB VSI. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-9-4-amd64-sap-hana-3"
	validation {
		condition     = length(regexall("^(ibm-redhat-9-4-amd64-sap-hana|ibm-redhat-8-6-amd64-sap-hana|ibm-redhat-8-4-amd64-sap-hana|ibm-sles-15-6-amd64-sap-hana|ibm-sles-15-5-amd64-sap-hana|ibm-sles-15-4-amd64-sap-hana|ibm-sles-15-3-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
		error_message = "The OS SAP DB_IMAGE must be one of \"ibm-redhat-9-4-amd64-sap-hana-x\", \"ibm-redhat-8-6-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-x\", \"ibm-sles-15-6-amd64-sap-hana-x\", \"ibm-sles-15-5-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", or \"ibm-sles-15-3-amd64-sap-hana-x\"."
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
	default		= "ibm-redhat-9-4-amd64-sap-applications-3"
	validation {
		condition     = length(regexall("^(ibm-redhat-9-4-amd64-sap-applications|ibm-redhat-8-6-amd64-sap-applications|ibm-redhat-8-4-amd64-sap-applications|ibm-sles-15-6-amd64-sap-applications|ibm-sles-15-5-amd64-sap-applications|ibm-sles-15-4-amd64-sap-applications|ibm-sles-15-3-amd64-sap-applications)-[0-9][0-9]*", var.APP_IMAGE)) > 0
		error_message = "The OS SAP APP_IMAGE must be one of \"ibm-redhat-9-4-amd64-sap-applications-x\", \"ibm-redhat-8-6-amd64-sap-applications-x\", \"ibm-redhat-8-4-amd64-sap-applications-x\", \"ibm-sles-15-6-amd64-sap-applications-x\", \"ibm-sles-15-5-amd64-sap-applications-x\", \"ibm-sles-15-4-amd64-sap-applications-x\" or \"ibm-sles-15-3-amd64-sap-applications-x\"."
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

variable "HANA_TENANT" {
	type		= string
	description = "The name of the SAP HANA tenant."
	default		= "JV1"
	validation {
		condition     = length(regexall("^[A-Za-z0-9-_]+$", var.HANA_TENANT)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_TENANT)
		error_message = "The name of SAP HANA tenant HANA_TENANT is not valid."
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
	description = "SAP HANA Installation kit path (ZIP/SAR file), as downloaded from SAP Support Portal"
	default		= "/storage/HANADB/SP07/Rev77/IMDB_SERVER20_077_0-80002031.SAR"
}

variable "SAP_SID" {
	type		= string
	description = "The SAP system ID. Identifies the entire SAP system. Consists of three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280."
	default		= "JV1"
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

variable "JAVA_NODES" {
	type		= string
	description = "The number of JAVA server nodes."
	default		= "2"
	validation {
		condition     = var.JAVA_NODES >= 1
		error_message = "The number of JAVA server nodes is not valid."
	}
}

variable "JAVA_PRODUCT_INSTANCES" {
	type		= list(string)
	description = "The list of JAVA product instances. The list can contain the following elements: \"AdobeDocumentServices\", \"BIJAVA\", \"BPM\", \"CentralProcessScheduling\", \"CompositionPlatform\", \"DevelopmentInfrastructure\", \"EPCore-ApplicationPortal\", \"EnterprisePortal\", \"EnterpriseServicesRepository\", \"PDFExport\". Example: JAVA_PRODUCT_INSTANCES = [\"AdobeDocumentServices\", \"BIJAVA\"]"
	default		= []
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "The SAP MAIN Password. Common password for all users that are created during the installation. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z), one uppercase letter (A-Z). It may contain one of the following special characters: !, #, _, @, $. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	validation {
		condition     = length(var.SAP_MAIN_PASSWORD) >= 15 && length(var.SAP_MAIN_PASSWORD) <= 30 && length(regexall("[0-9]",  var.SAP_MAIN_PASSWORD)) > 0 && length(regexall("[a-z]",  var.SAP_MAIN_PASSWORD)) > 0 && length(regexall("[A-Z]",  var.SAP_MAIN_PASSWORD)) > 0 && can(regex("^[a-zA-Z0-9!#_@$]*$", var.SAP_MAIN_PASSWORD)) && length(regexall("^([a-z]|[A-Z])", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid. It must be 15 to 30 characters long. It must contain at least: one digit (0-9), one lowercase letter (a-z), one uppercase letter (A-Z). It may contain one of the following special characters: !, #, _, @, $. It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z)."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary, as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPCAR_1300-70007716.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR), as downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SWPM10SP42_0-20009701.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "Path to SAP Kernel OS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/7.54UC/SAPEXE_400-80007612.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "Path to SAP Kernel DB archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/7.54UC/SAPEXEDB_400-80007611.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "Path to IGS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/7.54UC/igsexe_5-80007786.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "Path to IGS Helper archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/KERNEL/igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/NW75HDB/SAPHOSTAGENT65_65-80004822.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "Path to SAP HANA client file (SAR), as downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/IMDB_CLIENT20_022_32-80002082.SAR"
}

variable "KIT_SAPJVM_FILE" {
	type		= string
	description = "Path to SAP JVM archive (SAR), as downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SAPJVM81/SAPJVM8_102-80000202.SAR"
}

variable "KIT_JAVA_EXPORT_FILE" {
	type		= string
	description = "Path to JAVA Installation Export ZIP file. The archives downloaded from SAP Support Portal should be present in this path"
	default		= "/storage/NW75HDB/JAVAEXP/SP22/51055106.ZIP"
}

locals {
  	java_product_instances_lower = tolist([for inst in var.JAVA_PRODUCT_INSTANCES : "${trimspace(lower(inst))}"])
}

resource "null_resource" "check_java_instances" {
  lifecycle {
	precondition {
		condition     = length(setintersection(["adobedocumentservices", "bijava", "bpm", "centralprocessscheduling", "compositionplatform", "developmentinfrastructure", "epcore-applicationportal", "enterpriseportal", "enterpriseservicesrepository", "pdfexport"], local.java_product_instances_lower)) == length(local.java_product_instances_lower) 
		error_message = "The list can contain the following elements: AdobeDocumentServices, BIJAVA, BPM, CentralProcessScheduling, CompositionPlatform, DevelopmentInfrastructure, EPCore-ApplicationPortal, EnterprisePortal, EnterpriseServicesRepository, PDFExport."
	}
  }
}
