
# Basis: aktuelles offizielles Node-Image
FROM node:latest

ENV DEBIAN_FRONTEND=noninteractive

# Grundpakete: git (für sfdx-git-delta), curl, gpg, ca-certificates
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git curl gpg ca-certificates bash-completion \
 && rm -rf /var/lib/apt/lists/*

# Salesforce CLI via npm (aktuelle Version)
# -> Offiziell dokumentiert, gut für Container/CI
RUN npm install -g @salesforce/cli
ENV SF_AUTOUPDATE_DISABLE=true            
ENV SFDX_DISABLE_AUTOUPDATE=true

# --- Java 21 (Temurin 21 JDK) hinzufügen ---
# Adoptium/Temurin APT-Repo einbinden und temurin-21-jdk installieren
# Funktioniert auf Debian/Ubuntu-Basisimages (Node:latest basiert i.d.R. auf Debian)
RUN set -eux; \
    arch=$(dpkg --print-architecture); \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
      | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(. /etc/os-release && echo $VERSION_CODENAME) main" \
      > /etc/apt/sources.list.d/adoptium.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends temurin-21-jdk; \
    rm -rf /var/lib/apt/lists/*

# Java-Umgebung (optional, oft nicht nötig, aber hilfreich)
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# --- Salesforce-Plugins installieren ---

# 1) Git Delta Plugin (delta deployments)
RUN sf plugins install sfdx-git-delta || \
    (printf "y\n" | sf plugins install sfdx-git-delta)

# 2) Salesforce Code Analyzer (aka sfdx-scanner)
RUN sf plugins install @salesforce/sfdx-scanner

# Verifikation (optional): Versionen & Plugins anzeigen
RUN sf --version && java -version && sf plugins

# Arbeitsverzeichnis
WORKDIR /workspace

# Standard-CMD
CMD [ "bash" ]
