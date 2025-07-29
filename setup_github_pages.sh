#!/bin/bash

# Script pour configurer GitHub Pages pour Infractions Mali
# Auteur: Yacouba Santara
# Date: 15 Janvier 2025

echo "🚀 Configuration de GitHub Pages pour Infractions Mali"
echo "=================================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier si gh CLI est installé
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) n'est pas installé.${NC}"
    echo -e "${YELLOW}📥 Installation de GitHub CLI...${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install gh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh
    else
        echo -e "${RED}❌ Système d'exploitation non supporté. Veuillez installer GitHub CLI manuellement.${NC}"
        echo "📖 Documentation: https://github.com/cli/cli#installation"
        exit 1
    fi
fi

# Vérifier si l'utilisateur est connecté à GitHub
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}🔐 Connexion à GitHub requise...${NC}"
    gh auth login
fi

echo -e "${GREEN}✅ GitHub CLI configuré${NC}"

# Activer GitHub Pages via l'API GitHub
echo -e "${BLUE}🌐 Activation de GitHub Pages...${NC}"

# Activer GitHub Pages pour le dossier /docs
gh api repos/santultimate/infractions-mali/pages \
  --method POST \
  --field source_type=branch \
  --field source_branch=main \
  --field source_path=/docs

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ GitHub Pages activé avec succès !${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub Pages pourrait déjà être activé ou nécessiter une configuration manuelle.${NC}"
fi

echo ""
echo -e "${BLUE}📋 Instructions manuelles (si nécessaire) :${NC}"
echo "1. Aller sur https://github.com/santultimate/infractions-mali/settings/pages"
echo "2. Dans 'Source', sélectionner 'Deploy from a branch'"
echo "3. Choisir la branche 'main' et le dossier '/docs'"
echo "4. Cliquer sur 'Save'"
echo ""

# Attendre quelques secondes pour que GitHub Pages se déploie
echo -e "${YELLOW}⏳ Attente du déploiement de GitHub Pages...${NC}"
sleep 30

# Vérifier si la page est accessible
echo -e "${BLUE}🔍 Vérification de l'accessibilité de la page...${NC}"

if curl -s -o /dev/null -w "%{http_code}" "https://santultimate.github.io/infractions-mali/privacy-policy.html" | grep -q "200"; then
    echo -e "${GREEN}✅ Page de politique de confidentialité accessible !${NC}"
    echo -e "${GREEN}🌐 URL: https://santultimate.github.io/infractions-mali/privacy-policy.html${NC}"
else
    echo -e "${YELLOW}⚠️  La page n'est pas encore accessible. Cela peut prendre quelques minutes.${NC}"
    echo -e "${BLUE}🔄 Vérifiez dans quelques minutes: https://santultimate.github.io/infractions-mali/privacy-policy.html${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Configuration terminée !${NC}"
echo ""
echo -e "${BLUE}📚 URLs importantes :${NC}"
echo "• Page principale: https://santultimate.github.io/infractions-mali/"
echo "• Politique de confidentialité: https://santultimate.github.io/infractions-mali/privacy-policy.html"
echo "• Repository: https://github.com/santultimate/infractions-mali"
echo ""
echo -e "${BLUE}🔧 Prochaines étapes :${NC}"
echo "1. Tester le lien dans l'application Flutter"
echo "2. Vérifier que la page s'ouvre correctement"
echo "3. Personnaliser le contenu si nécessaire"
echo ""
echo -e "${GREEN}✨ Configuration GitHub Pages terminée avec succès !${NC}" 