# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.kit_sapcar_file}
${var.kit_swpm_file}
${var.kit_sapexe_file}
${var.kit_sapexedb_file}
${var.kit_igsexe_file}
${var.kit_igshelper_file}
${var.kit_saphotagent_file}
${var.kit_hdbclient_file}
${var.kit_sapjvm_file}
${var.kit_java_export}/*.*
${var.kit_saphana_file}
    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${var.DB-HOSTNAME}"
}