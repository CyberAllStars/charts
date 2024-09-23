function init_devspace() {
  devspace init
}

function create_env_var_file() {
  cat > .env <<EOF
DEVSPACE=true
DOCKER=true
DOCKER_COMPOSE=true
RANCHER_DESKTOP=true
TILT=true
EOF
}

function init_postgres() {
  devspace add component --name=postgres --container-image=postgres --port=5432
}

function init_keycloak() {
  devspace add component --name=keycloak --container-image=jboss/keycloak --port=8080
}

function init_argocd() {
  devspace add component --name=argocd --container-image=argoproj/argocd --port=8080
}

function install_plugins() {
    devspace add plugin https://github.com/loft-sh/devspace-plugin-loft --version=v4.0.0-alpha.19
}
function update_plugins() {
    devspace update plugin loft
}

function init_devspace_for_monorepo() {
  init_devspace
  create_env_var_file
  init_postgres
  init_keycloak
  init_argocd
}
init_devspace_for_monorepo
