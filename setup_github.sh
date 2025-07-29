#!/bin/bash

# Script de configuration GitHub pour Infractions Mali
echo "🚀 Configuration GitHub pour Infractions Mali"
echo "=============================================="

# Demander le nom d'utilisateur GitHub
read -p "Entrez votre nom d'utilisateur GitHub: " github_username

if [ -z "$github_username" ]; then
    echo "❌ Nom d'utilisateur GitHub requis"
    exit 1
fi

echo "📝 Mise à jour des liens de la politique de confidentialité..."

# Mettre à jour les liens dans les fichiers de traduction
sed -i '' "s/yacouba-santara/$github_username/g" assets/lang/fr.json
sed -i '' "s/yacouba-santara/$github_username/g" assets/lang/en.json

echo "✅ Liens mis à jour avec le nom d'utilisateur: $github_username"

# Instructions pour créer le repository
echo ""
echo "📋 Instructions pour créer le repository GitHub:"
echo "1. Allez sur https://github.com"
echo "2. Cliquez sur 'New repository'"
echo "3. Nom du repository: infractions-mali"
echo "4. Description: Application de sécurité routière pour le Mali"
echo "5. Choisissez Public ou Private"
echo "6. NE PAS initialiser avec README, .gitignore ou licence"
echo "7. Cliquez sur 'Create repository'"
echo ""

# Demander confirmation
read -p "Avez-vous créé le repository GitHub? (y/n): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    echo "🔗 Configuration du remote Git..."
    
    # Supprimer l'ancien remote s'il existe
    git remote remove origin 2>/dev/null
    
    # Ajouter le nouveau remote
    git remote add origin https://github.com/$github_username/infractions-mali.git
    
    # Renommer la branche en main
    git branch -M main
    
    echo "📤 Poussée du code vers GitHub..."
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo "✅ Code poussé avec succès vers GitHub!"
        echo "🌐 Votre repository est disponible sur: https://github.com/$github_username/infractions-mali"
        echo "📄 Politique de confidentialité: https://github.com/$github_username/infractions-mali/blob/main/PRIVACY_POLICY.md"
    else
        echo "❌ Erreur lors de la poussée vers GitHub"
        echo "Vérifiez que le repository existe et que vous avez les permissions"
    fi
else
    echo "⏳ Veuillez créer le repository GitHub d'abord, puis relancez ce script"
fi

echo ""
echo "🎉 Configuration terminée!" 