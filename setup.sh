#!/bin/bash

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}-------------------------------------------------------------${NC}"
echo -e "${GREEN}---        [+] Initialisation du Youtube-Killer...        ---${NC}"
echo -e "${GREEN}-------------------------------------------------------------${NC}"

# Création du dossier s'il n'existe pas
mkdir -p certs

# Génération de l'Autorité Racine (RootCA)
echo -e "${GREEN}[+] Génération de votre Autorité de Certification personnelle...${NC}"
openssl req -x509 -nodes -new -sha256 -days 3650 -newkey rsa:2048 \
  -keyout certs/rootCA.key -out certs/rootCA.pem \
  -subj "/C=FR/O=Procrastination-Killer-Local-CA/CN=Procrastination-Killer-Local-CA"

# Création configuration des extensions (SAN)
cat > certs/server.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = youtube.com
DNS.2 = www.youtube.com
DNS.3 = instagram.com
DNS.4 = www.instagram.com
DNS.5 = tiktok.com
DNS.6 = localhost
EOF

# Génération de la clé du serveur et de la demande (CSR)
echo -e "${GREEN}[+] Génération du certificat serveur pour Nginx...${NC}"
openssl req -new -nodes -newkey rsa:2048 \
  -keyout certs/nginx.key -out certs/nginx.csr \
  -subj "/C=FR/ST=Paris/L=Paris/O=ProcrastinationKiller/CN=localhost"

# Signature du certificat par le Root CA
openssl x509 -req -in certs/nginx.csr -CA certs/rootCA.pem -CAkey certs/rootCA.key \
  -CAcreateserial -out certs/nginx.crt -days 365 -sha256 -extfile certs/server.ext

# Nettoyage des fichiers temporaires
rm certs/nginx.csr certs/server.ext

echo -e "${GREEN}-------------------------------------------------------------${NC}"
echo -e "${GREEN}---          INSTALLATION TERMINÉE AVEC SUCCÈS !          ---${NC}"
echo -e "${GREEN}-------------------------------------------------------------${NC}"
echo -e "Dernière étape manuelle importante :"
echo -e "1. Ouvrir votre navigateur (Firefox/Chrome)."
echo -e "2. Se rendre dans les paramètres de certificats."
echo -e "3. Importer le fichier suivant dans les AUTORITÉS :"
echo -e "   -> ${RED}$(pwd)/certs/rootCA.pem${NC}"
echo -e "4. Cochez 'Faire confiance pour identifier des sites web'."
echo -e "-------------------------------------------------------------"
echo -e "Ensuite, lancez : docker compose up -d"