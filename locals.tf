locals {
  folder_repo_name = trimsuffix(basename(var.ansible_repo), ".git")
}