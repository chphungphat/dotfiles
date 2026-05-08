#!/bin/bash

set -euo pipefail

INSTALL_DIR="$HOME/.local/share/jdtls"
JDTLS_REPO="eclipse-jdtls/eclipse.jdt.ls"
JDTLS_MIRROR="https://download.eclipse.org/jdtls/milestones"
LOMBOK_MAVEN="https://repo1.maven.org/maven2/org/projectlombok/lombok"
VERSION_FILE_JDTLS="$INSTALL_DIR/JdtlsVersion.txt"
VERSION_FILE_LOMBOK="$INSTALL_DIR/LombokVersion.txt"
TMP_TARBALL="/tmp/jdtls.tar.gz"
TMP_LOMBOK="/tmp/lombok.jar"
TMP_EXTRACT="/tmp/jdtls-extract"

trap 'rm -f "$TMP_TARBALL" "$TMP_LOMBOK"; rm -rf "$TMP_EXTRACT"' EXIT

## JDTLS

echo "Fetching latest jdtls version..."
JDTLS_TAG=$(curl -fsSL "https://api.github.com/repos/${JDTLS_REPO}/tags?per_page=1" | jq -r '.[0].name')
JDTLS_VERSION="${JDTLS_TAG#v}"

if [[ -z "$JDTLS_TAG" || "$JDTLS_TAG" == "null" ]]; then
  echo "error: could not parse jdtls version from GitHub API response" >&2
  exit 1
fi

echo "Latest jdtls: $JDTLS_TAG"

if [[ -f "$VERSION_FILE_JDTLS" ]] && [[ "$(cat "$VERSION_FILE_JDTLS")" == "$JDTLS_TAG" ]]; then
  echo "jdtls $JDTLS_TAG already installed, skipping"
else
  JDTLS_TARBALL=$(curl -fsSL "${JDTLS_MIRROR}/${JDTLS_VERSION}/" \
    | grep -oE "jdt-language-server-${JDTLS_VERSION}-[0-9]+\.tar\.gz" \
    | head -1)

  if [[ -z "$JDTLS_TARBALL" ]]; then
    echo "error: could not find jdtls tarball for version ${JDTLS_VERSION}" >&2
    exit 1
  fi

  echo "Downloading jdtls $JDTLS_TAG..."
  curl -fL --progress-bar "${JDTLS_MIRROR}/${JDTLS_VERSION}/${JDTLS_TARBALL}" -o "$TMP_TARBALL"

  echo "Extracting..."
  rm -rf "$TMP_EXTRACT"
  mkdir -p "$TMP_EXTRACT"
  tar -xzf "$TMP_TARBALL" -C "$TMP_EXTRACT"

  if ls "$INSTALL_DIR/plugins/lombok"*.jar &>/dev/null; then
    echo "Preserving existing lombok jar..."
    cp "$INSTALL_DIR/plugins/lombok"*.jar "$TMP_EXTRACT/plugins/"
  fi

  echo "Installing to $INSTALL_DIR..."
  rm -rf "$INSTALL_DIR"
  mv "$TMP_EXTRACT" "$INSTALL_DIR"

  printf '%s' "$JDTLS_TAG" > "$VERSION_FILE_JDTLS"
  echo "jdtls $JDTLS_TAG installed"
fi

## LOMBOK

echo "Fetching latest lombok version..."
LOMBOK_VERSION=$(curl -fsSL "${LOMBOK_MAVEN}/maven-metadata.xml" \
  | sed -n 's/.*<release>\(.*\)<\/release>.*/\1/p')

if [[ -z "$LOMBOK_VERSION" ]]; then
  echo "error: could not parse lombok version from Maven Central" >&2
  exit 1
fi

echo "Latest lombok: $LOMBOK_VERSION"

if [[ -f "$VERSION_FILE_LOMBOK" ]] && [[ "$(cat "$VERSION_FILE_LOMBOK")" == "$LOMBOK_VERSION" ]]; then
  echo "lombok $LOMBOK_VERSION already installed, skipping"
else
  mkdir -p "$INSTALL_DIR/plugins"
  rm -f "$INSTALL_DIR/plugins/lombok"*.jar

  echo "Downloading lombok $LOMBOK_VERSION..."
  curl -fL --progress-bar "${LOMBOK_MAVEN}/${LOMBOK_VERSION}/lombok-${LOMBOK_VERSION}.jar" -o "$TMP_LOMBOK"

  cp "$TMP_LOMBOK" "$INSTALL_DIR/plugins/lombok-${LOMBOK_VERSION}.jar"

  printf '%s' "$LOMBOK_VERSION" > "$VERSION_FILE_LOMBOK"
  echo "lombok $LOMBOK_VERSION installed"
fi

## VERIFY

LAUNCHER=$(ls "$INSTALL_DIR/plugins/org.eclipse.equinox.launcher_"*.jar 2>/dev/null || true)
LOMBOK_JAR=$(ls "$INSTALL_DIR/plugins/lombok"*.jar 2>/dev/null || true)

if [[ -n "$LAUNCHER" ]] && [[ -n "$LOMBOK_JAR" ]]; then
  echo "Verification OK"
  echo "  launcher: $(basename "$LAUNCHER")"
  echo "  lombok:   $(basename "$LOMBOK_JAR")"
else
  [[ -z "$LAUNCHER" ]] && echo "WARNING: launcher jar not found" >&2
  [[ -z "$LOMBOK_JAR" ]] && echo "WARNING: lombok jar not found" >&2
fi
