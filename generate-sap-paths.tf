# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.KIT_SAPCAR_FILE}
${var.KIT_SWPM_FILE}
${var.KIT_SAPEXE_FILE}
${var.KIT_SAPEXEDB_FILE}
${var.KIT_IGSEXE_FILE}
${var.KIT_IGSHELPER_FILE}
${var.KIT_SAPHOSTAGENT_FILE}
${var.KIT_HDBCLIENT_FILE}
${var.KIT_SAPJVM_FILE}
${var.KIT_JAVA_EXPORT}/*.*
${var.KIT_SAPHANA_FILE}
    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${var.DB_HOSTNAME}"
}