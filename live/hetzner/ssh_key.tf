resource "hcloud_ssh_key" "default" {
  name       = "${var.project_name}-key"
  public_key = file(var.hetzner_ssh_public_key_path)
}
