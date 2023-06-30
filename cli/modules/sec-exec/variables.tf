variable "IP" {
    type = string
    description = "IP used to execute ansible"
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "SAP_MAIN_PASSWORD"
}
