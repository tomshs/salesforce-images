
# Basis: aktuelles offizielles Node-Image (enthält npm)
FROM node:latest

# Optional: noninteractive für apt
ENV DEBIAN_FRONTEND=noninteractive

# Systempakete: git (Pflicht für sfdx-git-delta) und ca-certificates
# Außerdem: bash-completion optional hilfreich, clean-up für kleinere Images
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git \
      ca-certificates \
      bash-completion \
 && rm -rf /var/lib/apt/lists/*

# Salesforce CLI global via npm installieren (neueste Version)
# Hinweis: Installation über npm ist von Salesforce dokumentiert
RUN npm install -g @salesforce/cli

# (Empfohlen) Updates der CLI nicht automatisch im Container anstoßen
ENV SF_AUTOUPDATE_DISABLE=true

# Git-Delta-Plugin für Salesforce CLI installieren
# Das Plugin heißt "sfdx-git-delta" und wird via "sf plugins install" eingebunden
RUN sf plugins install sfdx-git-delta || \
    (echo "Plugin ist unsigniert – Installation wird erzwungen" && printf "y\n" | sf plugins install sfdx-git-delta)

# Verifizieren (optional):
# - sf Version
# - installiertes Plugin
RUN sf --version && sf plugins

# Standard-Workdir
WORKDIR /workspace

# Standardbefehl: Shell (kann in CI überschrieben werden)
CMD [ "bash" ]
