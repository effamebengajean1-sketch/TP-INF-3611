# Partie 1 - Script Bash create_users.sh

## Description
Script adapté aux permissions disponibles (useradd non autorisé).
Lit users.txt et génère les commandes pour configurer chaque utilisateur.

## Fonctionnalités implémentées
1. Lecture fichier users.txt
2. Vérification existence utilisateurs
3. Génération commandes pour 9 exigences du TP
4. Logging détaillé
5. Génération script de commandes exécutables

## Exécution
1. ./create_users.sh
2. Vérifier le log: configure_users_*.log
3. Exécuter: sudo bash commands_to_execute_*.sh

## Testé avec succès
✓ sudo passwd user24 (mot de passe configuré)
✓ sudo passwd user26

## Nécessite admin
- Création groupe students-inf-361
- Création utilisateurs manquants
- Configuration quotas disque
