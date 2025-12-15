
## Réponses aux questions :

### 1. Procédure de modification SSH :
- Sauvegarde du fichier de configuration
- Édition avec nano/vim
- Test avec `sshd -t`
- Redémarrage du service
- Test de connexion depuis nouvelle session

### 2. Risque principal :
Perte d'accès au serveur si configuration SSH invalide.

### 3. Paramètres de sécurité :
- Port 2222 (évite scans automatiques)
- PermitRootLogin no (bloque root)
- PasswordAuthentication no (force clés SSH)
- MaxAuthTries 3 (limite tentatives)
- Protocol 2 (SSH v2 seulement)
