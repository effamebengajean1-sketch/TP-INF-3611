#!/bin/bash

echo "🔧 Configuration GitHub pour TP INF 3611"
echo "========================================"

# 1. Vérifier Git
echo "1. Vérification Git..."
if ! command -v git &> /dev/null; then
    echo "❌ Git non installé"
    sudo apt install git -y
fi

# 2. Configurer Git
echo "2. Configuration Git..."
git config --global user.name "effamebengajean1-sketch"
git config --global user.email "effamebengajean1@gmail.com"

# 3. Ajouter fichiers
echo "3. Ajout des fichiers..."
git add .
git status

# 4. Commit
echo "4. Commit..."
git commit -m "TP INF 3611 - Administration Systèmes et Réseaux

Livrables:
- Partie 0: Sécurisation SSH
- Partie 1: Script Bash create_users.sh
- Partie 2: Playbook Ansible
- Partie 3: Configuration Terraform
- 31 utilisateurs dans users.txt

Date: $(date +%Y-%m-%d)
Auteur: Jean Effa Mebenga"

# 5. Demander création dépôt
echo ""
echo "📌 ÉTAPE IMPORTANTE:"
echo "1. Ouvre https://github.com/new"
echo "2. Crée le dépôt: TP-INF-3611"
echo "3. NE coche PAS 'Initialize with README.md'"
echo "4. Clique sur 'Create repository'"
echo ""
read -p "Appuie sur ENTREE quand le dépôt est créé..."

# 6. Configurer remote
echo "5. Configuration remote..."
git remote add origin https://github.com/effamebengajean1-sketch/TP-INF-3611.git

# 7. Pousser
echo "6. Push sur GitHub..."
git branch -M main
echo ""
echo "⚠️  Quand on te demande le mot de passe:"
echo "   Username: effamebengajean1-sketch"
echo "   Password: COLLE_TON_TOKEN_GITHUB"
echo ""
git push -u origin main

echo ""
echo "✅ Succès! Vérifie: https://github.com/effamebengajean1-sketch/TP-INF-3611"
