GH_REPO="https://github.com/fluxcd/flux2"
TOOL_NAME="flux"
TOOL_TEST="flux --version"


curl_opts=(-fsSL)

fail() {
  echo -e "asdf-${TOOL_NAME}: $*"
  exit 1
}

get_arch() {
  local arch; arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "$arch" in
  x86_64)
    arch="amd64"
    ;;
  armv7l)
    arch="arm"
    ;;
  esac

  echo "$arch"
}

get_kernel() {
  local kernel="$(uname -s | tr '[:upper:]' '[:lower:]')"

  echo "$kernel"
}

lsb_release() {
  awk -F'=' '/^ID=/ { print $2 }' /etc/os-release | tr '[:upper:]' '[:lower:]'
}

get_platform() {
  local platform="$(uname | tr '[:upper:]' '[:lower:]')"

  echo "$platform"
}

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | awk -F'/' '{ print $3 }' |
    sed 's/^v//'
}

get_download_url() {
  local version="$1"
  local arch="$(get_arch)"
  local platform="$(get_platform)"

  echo "${GH_REPO}/releases/download/v${version}/${TOOL_NAME}_${version}_${platform}_${arch}.tar.gz"
}

download_release() {
  local version="$1"
  local filename="$2"

  local url="$(get_download_url "$version")"

  echo "* Downloading ${TOOL_NAME} release ${version}..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "only supports release installs"
  fi

  local release_file="$install_path/${TOOL_NAME}.tar.gz"
  (
    mkdir -p "${install_path}/bin"
    download_release "$version" "$release_file"

    tar xzf "${install_path}/${TOOL_NAME}.tar.gz" -C "$install_path"
    mv "${install_path}/${TOOL_NAME}" "${install_path}/bin/"
    chmod +x "${install_path}/bin/${TOOL_NAME}"
    rm -rf "${install_path}/${TOOL_NAME}.tar.gz" "$install_path"/${TOOL_NAME}-*

    local tool_cmd="$(echo "$TOOL_TEST" | awk '{ print $1 }')"
    test -x "${install_path}/bin/${tool_cmd}" || fail "Expected ${install_path}/bin/${tool_cmd} to be executable."

    echo "${TOOL_NAME} ${version} installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing version ${version}."
  )
}
