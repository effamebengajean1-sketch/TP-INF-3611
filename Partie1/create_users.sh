#!/bin/bash
# INF 361 - TP 1 - Automatisation création utilisateurs
# Auteur: user26
# Date: $(date +%Y-%m-%d)

# === CONFIGURATION ===
GROUP_NAME="${1:-students-inf-361}"
USERS_FILE="users.txt"
LOG_FILE="/var/log/create_users_$(date +%Y%m%d_%H%M%S).log"

# === FONCTIONS ===
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# === VÉRIFICATIONS ===
if [ ! -f "$USERS_FILE" ]; then
    echo "ERREUR: Fichier $USERS_FILE introuvable!"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: Exécutez avec sudo!"
    exit 1
fi

# === DÉBUT ===
log_message "=== DÉBUT SCRIPT ==="
log_message "Groupe: $GROUP_NAME"

# 1. Créer le groupe
if ! getent group "$GROUP_NAME" >/dev/null; then
    groupadd "$GROUP_NAME"
    log_message "Groupe $GROUP_NAME créé"
else
    log_message "Groupe $GROUP_NAME existe déjà"
fi

# 2. Lire et traiter users.txt
log_message "Lecture du fichier $USERS_FILE"
log_message "Traitement des utilisateurs..."

# 3. Process each user
while IFS=';' read -r username password fullname phone email shell; do
    # Skip comments and empty lines
    [[ "$username" =~ ^# ]] && continue
    [[ -z "$username" ]] && continue
    
    log_message "Création de: $username"
    
    # Check if shell exists
    if ! grep -q "$shell" /etc/shells; then
        log_message "Shell $shell non trouvé, installation..."
        # Try to install shell (simplified for now)
        log_message "Utilisation de /bin/bash par défaut"
        shell="/bin/bash"
    fi
    
    # Create user with all info
    if ! id "$username" &>/dev/null; then
        useradd -m -c "$fullname - $phone - $email" -s "$shell" "$username"
        log_message "Utilisateur $username créé"
    else
        log_message "Utilisateur $username existe déjà"
    fi
    
    # Add to main group
    usermod -aG "$GROUP_NAME" "$username"
    
    # TODO: Add other features here
    log_message "À faire: config mot de passe, quotas, etc. pour $username"
    
done < "$USERS_FILE"

# === FIN ===
log_message "=== FIN SCRIPT ==="
