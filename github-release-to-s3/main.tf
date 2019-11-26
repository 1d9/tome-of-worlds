data "external" "getGithubRelease" {
  program = ["sh", "${path.module}/scripts/getGithubRelease.sh"]

  query = {
    repo = var.github_repo_name,
    release = var.github_repo_release,
    file = var.github_repo_release_filename,
  }
}

# Get a unique name for the archive, that isn't the bucket name since that isn't safe for filenames
resource "random_pet" "archive_directory" {
  keepers = {
    directory_name = "${var.bucket_name}"
  }
}

data "external" "unzipArchive" {
  program = ["sh", "${path.module}/scripts/unzipArchive.sh"]

  query = {
    archive = "${data.external.getGithubRelease.result.file}",
    destination = "${random_pet.archive_directory.keepers.directory_name}",
  }
}

locals {
  content-types = {
    png = "image/png",
    html = "text/html",
    js = "text/javascript",
    otf = "font/otf",
    css = "text/css"
  }
  destination = data.external.unzipShowdownArchive.result.destination
  files = fileset(local.destination, "**/*.{png,html,js,otf,css}")
}

data "aws_s3_bucket" "site_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_object" "site_files" {
  for_each = local.files

  acl = "public-read"
  bucket = data.aws_s3_bucket.site_bucket.bucket
  key    = each.value

  source = "${local.destination}/${each.value}"
  etag =    filemd5("${local.destination}/${each.value}")

  content_type = local.content-types[element(split(".", each.value), length(split(".", each.value)) - 1)]
}
