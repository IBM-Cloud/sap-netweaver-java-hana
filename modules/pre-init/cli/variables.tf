variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "KIT_IGSHELPER_FILE"
    validation {
    condition = fileexists("${var.KIT_IGSHELPER_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "KIT_SAPCAR_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPCAR_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "KIT_SWPM_FILE"
    validation {
    condition = fileexists("${var.KIT_SWPM_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "KIT_SAPHOSTAGENT_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPHOSTAGENT_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "KIT_SAPEXE_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPEXE_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "KIT_SAPEXEDB_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPEXEDB_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "KIT_IGSEXE_FILE"
    validation {
    condition = fileexists("${var.KIT_IGSEXE_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "KIT_HDBCLIENT_FILE"
	default		= "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
    validation {
    condition = fileexists("${var.KIT_HDBCLIENT_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SAPJVM_FILE" {
	type		= string
	description = "KIT_SAPJVM_FILE"
	default		= "/storage/NW75HDB/SAPJVM8_73-80000202.SAR"
    validation {
    condition = fileexists("${var.KIT_SAPJVM_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_JAVA_EXPORT" {
	type		= string
	description = "KIT_JAVA_EXPORT"
	default		= "/storage/NW75HDB/export"
}