# Image catalog: every maintained image version is listed here, nowhere else.
#
#   docker buildx bake --print            show all targets with their tags
#   bin/build.sh [target|group ...]       build, add the patch-level tags, check the versions
#
# Adding a version usually means adding one entry below (and moving LATEST if it is the
# newest). Removing a version freezes it: its images stay on Docker Hub but are no longer rebuilt.
# Frozen (EOL) sources live in git history, see tag 26.11.13.
#
# Target names use "-" instead of ".", e.g. php-cli-8-4, php-fpm-8-4-prod, php-deploy-8-4, mariadb-11-8.
# The first tag of a target is its minor tag; bin/build.sh derives the patch tag from it.

variable "NAMESPACE" {
  default = "sandstein"
}

# empty: build for the local platform only (CI builds each platform on a native runner)
variable "PLATFORMS" {
  default = []
}

# --- versions ------------------------------------------------------------------

# version => extensions on top of the common list in docker/php/Dockerfile
#   all: cli and fpm, cli: cli only
variable "PHP" {
  default = {
    "8.2" = { all = "mcrypt memcache", cli = "ioncube_loader" }
    "8.3" = { all = "mcrypt memcache", cli = "" }
    "8.4" = { all = "memcache", cli = "" }
    "8.5" = { all = "", cli = "" }
  }
}
variable "PHP_LATEST" { default = "8.5" } # gets sandstein/php:latest (cli, dev)

variable "MARIADB" { default = ["11.4", "11.8"] }
variable "MYSQL" { default = ["8.4"] }
variable "NODE" { default = ["22", "24", "26"] }
variable "PYTHON" { default = ["3.10"] }
variable "APACHE" { default = ["2.4"] }

# "latest" of the families above is the last entry of their list

# --- groups --------------------------------------------------------------------

group "default" {
  targets = ["php", "php-deploy", "mariadb", "mysql", "node", "python", "apache", "ssh", "selenium-side-runner"]
}

# --- targets -------------------------------------------------------------------

target "_common" {
  context   = "."
  platforms = PLATFORMS
}

function "dash" {
  params = [v]
  result = replace(v, ".", "-")
}

# tags for <repo>:<version> plus latest for the newest version
function "tags" {
  params = [repo, v, versions]
  result = concat(["${NAMESPACE}/${repo}:${v}"], v == versions[length(versions) - 1] ? ["${NAMESPACE}/${repo}:latest"] : [])
}

target "php" {
  inherits   = ["_common"]
  name       = "php-${type}-${dash(v)}${variant == "dev" ? "" : "-${variant}"}"
  matrix     = { type = ["cli", "fpm"], v = keys(PHP), variant = ["dev", "prod"] }
  dockerfile = "docker/php/Dockerfile"
  target     = "${type}-${variant}"
  args = {
    VERSION        = v
    TYPE           = type
    EXTENSIONS     = PHP[v].all
    CLI_EXTENSIONS = PHP[v].cli
  }
  tags = concat(
    ["${NAMESPACE}/php:${type}-${v}${variant == "dev" ? "" : "-${variant}"}"],
    type == "cli" && variant == "dev" && v == PHP_LATEST ? ["${NAMESPACE}/php:latest"] : []
  )
}

# GitLab CI deployment image on top of cli-prod, see the deploy stage in docker/php/Dockerfile
target "php-deploy" {
  inherits   = ["_common"]
  name       = "php-deploy-${dash(v)}"
  matrix     = { v = keys(PHP) }
  dockerfile = "docker/php/Dockerfile"
  target     = "deploy"
  args = {
    VERSION        = v
    TYPE           = "cli"
    EXTENSIONS     = PHP[v].all
    CLI_EXTENSIONS = PHP[v].cli
  }
  tags = ["${NAMESPACE}/php-deploy:${v}"]
}

target "mariadb" {
  inherits   = ["_common"]
  name       = "mariadb-${dash(v)}"
  matrix     = { v = MARIADB }
  dockerfile = "docker/mariadb/Dockerfile"
  args       = { VERSION = v }
  tags       = tags("mariadb", v, MARIADB)
}

target "mysql" {
  inherits   = ["_common"]
  name       = "mysql-${dash(v)}"
  matrix     = { v = MYSQL }
  dockerfile = "docker/mysql/Dockerfile"
  args       = { VERSION = v }
  tags       = tags("mysql", v, MYSQL)
}

target "node" {
  inherits   = ["_common"]
  name       = "node-${dash(v)}"
  matrix     = { v = NODE }
  dockerfile = "docker/node/Dockerfile"
  args       = { VERSION = v }
  tags       = tags("node", v, NODE)
}

target "python" {
  inherits   = ["_common"]
  name       = "python-${dash(v)}"
  matrix     = { v = PYTHON }
  dockerfile = "docker/python/Dockerfile"
  args       = { VERSION = v }
  tags       = tags("python", v, PYTHON)
}

target "apache" {
  inherits   = ["_common"]
  name       = "apache-${dash(v)}"
  matrix     = { v = APACHE }
  dockerfile = "docker/apache/Dockerfile"
  args       = { VERSION = v }
  tags       = tags("apache", v, APACHE)
}

# Debian trixie = 13; no patch tag
target "ssh" {
  inherits   = ["_common"]
  dockerfile = "docker/ssh/Dockerfile"
  args       = { VERSION = "trixie" }
  tags       = ["${NAMESPACE}/ssh:13", "${NAMESPACE}/ssh:trixie", "${NAMESPACE}/ssh:latest"]
}

# tagged with the node major of the base image; bin/build.sh adds the selenium-side-runner version
target "selenium-side-runner" {
  inherits   = ["_common"]
  dockerfile = "docker/selenium-side-runner/Dockerfile"
  args       = { NODE_VERSION = "24" }
  tags       = ["${NAMESPACE}/selenium-side-runner:24", "${NAMESPACE}/selenium-side-runner:latest"]
}
