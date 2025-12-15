#!/bin/bash
# INF 361 - TP 1 - Configuration automatique des utilisateurs
# ADAPTÉ aux permissions sudo disponibles
# Auteur: user26
# Date: $(date +%Y-%m-%d)

# === CONFIGURATION ===
GROUP_NAME="${1:-students-inf-361}"
USERS_FILE="users.txt"
LOG_FILE="./configure_users_$(date +%Y%m%d_%H%M%S).log"

# === FONCTIONS ===
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# === VÉRIFICATIONS ===
if [ ! -f "$USERS_FILE" ]; then
    echo "ERREUR: Fichier $USERS_FILE introuvable!"
    exit 1
fi

# === DÉBUT ===
log_message "=== DÉBUT SCRIPT ADAPTÉ ==="
log_message "Groupe cible: $GROUP_NAME"
log_message "Permissions disponibles: usermod, passwd, groupmod, pkill"

# NOTE: Le groupe doit être créé manuellement par admin
if getent group "$GROUP_NAME" >/dev/null; then
    log_message "Groupe $GROUP_NAME existe"
else
    log_message "ATTENTION: Groupe $GROUP_NAME n'existe pas"
    log_message "  -> Demander à l'admin: sudo groupadd $GROUP_NAME"
fi

# === TRAITEMENT DES UTILISATEURS ===
log_message "Lecture du fichier $USERS_FILE"

USER_COUNT=0
CONFIGURED_COUNT=0

while IFS=';' read -r username password fullname phone email preferred_shell; do
    # Skip comments and empty lines
    [[ "$username" =~ ^# ]] && continue
    [[ -z "$username" ]] && continue
    
    USER_COUNT=$((USER_COUNT + 1))
    log_message "--- Traitement de: $username ---"
    
    # 1. Vérifier si l'utilisateur existe
    if id "$username" &>/dev/null; then
        log_message "✓ Utilisateur existe"
        
        # 2. Vérifier/installer le shell (LOGIC ONLY)
        current_shell=$(getent passwd "$username" | cut -d: -f7)
        log_message "  Shell actuel: $current_shell"
        log_message "  Shell souhaité: $preferred_shell"
        
        if [[ "$preferred_shell" != "$current_shell" ]]; then
            if grep -q "$preferred_shell" /etc/shells; then
                log_message "  -> À faire: sudo usermod -s $preferred_shell $username"
            else
                log_message "  -> Shell $preferred_shell non disponible"
                log_message "  -> Utiliser /bin/bash par défaut"
                preferred_shell="/bin/bash"
            fi
        fi
        
        # 3. Configurer informations utilisateur (GECOS)
        # Format: "Full Name,Phone,Email"
        gecos_info="$fullname,$phone,$email"
        log_message "  Infos GECOS: $gecos_info"
        log_message "  -> À faire: sudo usermod -c '$gecos_info' $username"
        
        # 4. Ajouter au groupe students-inf-361 (si groupe existe)
        if getent group "$GROUP_NAME" >/dev/null; then
            log_message "  -> À faire: sudo usermod -aG $GROUP_NAME $username"
        fi
        
        # 5. Configurer mot de passe (HASH SHA-512)
        log_message "  Mot de passe par défaut: $password"
        log_message "  -> À faire: sudo passwd $username"
        log_message "     (Entrer manuellement: $password)"
        log_message "  -> Forcer changement: sudo chage -d 0 $username"
        
        # 6. Ajouter au groupe sudo (mais bloquer 'su')
        log_message "  -> À faire: sudo usermod -aG sudo $username"
        log_message "  -> Bloquer 'su': sudo tee /etc/group.sudo.deny <<<'$GROUP_NAME'"
        
        # 7. Message de bienvenue
        welcome_file="/home/$username/WELCOME.txt"
        welcome_msg="Bienvenue $fullname!\\nCompte: $username\\nServeur: $(hostname)"
        log_message "  -> Créer: echo -e \"$welcome_msg\" > $welcome_file"
        log_message "  -> Ajouter à .bashrc: echo 'cat ~/WELCOME.txt' >> /home/$username/.bashrc"
        
        # 8. Limite disque 15GB (quotas)
        log_message "  -> Quota 15GB: sudo setquota -u $username 15G 15G 0 0 /home"
        
        # 9. Limite mémoire 20% RAM
        log_message "  -> Limite mémoire: echo '$username hard memlock 20%' >> /etc/security/limits.conf"
        
        CONFIGURED_COUNT=$((CONFIGURED_COUNT + 1))
        
    else
        log_message "✗ Utilisateur $username n'existe pas"
        log_message "  -> ACTION REQUISE: sudo useradd -m -c '$fullname,$phone,$email' -s $preferred_shell $username"
    fi
    
done < "$USERS_FILE"

# === RAPPORT FINAL ===
log_message "=== RAPPORT ==="
log_message "Utilisateurs dans fichier: $USER_COUNT"
log_message "Utilisateurs configurables: $CONFIGURED_COUNT"
log_message "Actions nécessitant admin:"
log_message "  1. Création groupe: sudo groupadd $GROUP_NAME"
log_message "  2. Création users manquants: sudo useradd ..."
log_message "  3. Configuration quotas: sudo setquota"
log_message ""
log_message "=== FIN SCRIPT ADAPTÉ ==="
log_message "NOTE: Ce script génère les commandes nécessaires"
log_message "      Exécuter les commandes 'À faire:' manuellement"

# Générer un script des commandes à exécuter
COMMAND_FILE="commands_to_execute_$(date +%H%M%S).sh"
echo "#!/bin/bash" > "$COMMAND_FILE"
echo "# Commandes générées par create_users_adapted.sh" >> "$COMMAND_FILE"
echo "# Exécuter avec sudo" >> "$COMMAND_FILE"
echo "" >> "$COMMAND_FILE"

# Extraire toutes les commandes 'À faire:' du log
grep "-> À faire:" "$LOG_FILE" | sed 's/.*-> À faire: //' >> "$COMMAND_FILE"

chmod +x "$COMMAND_FILE"
log_message "Script de commandes généré: $COMMAND_FILE"
