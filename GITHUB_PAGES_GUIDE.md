# 🌐 Guide GitHub Pages - Infractions Mali

Ce guide explique comment configurer et utiliser GitHub Pages pour héberger la documentation de l'application Infractions Mali.

## 📋 Table des matières

1. [Configuration automatique](#configuration-automatique)
2. [Configuration manuelle](#configuration-manuelle)
3. [Structure des fichiers](#structure-des-fichiers)
4. [URLs importantes](#urls-importantes)
5. [Personnalisation](#personnalisation)
6. [Dépannage](#dépannage)

## 🚀 Configuration automatique

### Option 1: Script automatique (Recommandé)

```bash
# Exécuter le script de configuration
./setup_github_pages.sh
```

Le script va :
- Vérifier l'installation de GitHub CLI
- Se connecter à GitHub si nécessaire
- Activer GitHub Pages automatiquement
- Vérifier l'accessibilité de la page

### Option 2: GitHub CLI manuel

```bash
# Installer GitHub CLI (si pas déjà fait)
brew install gh  # macOS
# ou
sudo apt install gh  # Linux

# Se connecter à GitHub
gh auth login

# Activer GitHub Pages
gh api repos/santultimate/infractions-mali/pages \
  --method POST \
  --field source_type=branch \
  --field source_branch=main \
  --field source_path=/docs
```

## ⚙️ Configuration manuelle

Si les méthodes automatiques ne fonctionnent pas :

### 1. Aller sur GitHub
- Ouvrir https://github.com/santultimate/infractions-mali
- Cliquer sur **Settings** (onglet)

### 2. Configurer GitHub Pages
- Scroller jusqu'à la section **Pages**
- Dans **Source**, sélectionner **Deploy from a branch**
- Choisir la branche **main**
- Sélectionner le dossier **/docs**
- Cliquer sur **Save**

### 3. Attendre le déploiement
- GitHub va déployer automatiquement
- Délai : 1-5 minutes
- Un message vert apparaîtra quand c'est prêt

## 📁 Structure des fichiers

```
infractions-mali/
├── docs/                          # Dossier GitHub Pages
│   ├── README.md                  # Documentation
│   ├── privacy-policy.html        # Page de politique de confidentialité
│   └── assets/                    # Ressources (optionnel)
│       ├── images/
│       ├── css/
│       └── js/
├── assets/
│   ├── web/                       # Version locale (backup)
│   │   └── privacy_policy.html
│   └── lang/
│       ├── fr.json               # URL GitHub Pages
│       └── en.json               # URL GitHub Pages
└── setup_github_pages.sh         # Script de configuration
```

## 🌐 URLs importantes

### Pages publiques
- **Page principale :** https://santultimate.github.io/infractions-mali/
- **Politique de confidentialité :** https://santultimate.github.io/infractions-mali/privacy-policy.html

### Configuration
- **Settings GitHub Pages :** https://github.com/santultimate/infractions-mali/settings/pages
- **Repository :** https://github.com/santultimate/infractions-mali

## 🎨 Personnalisation

### Modifier le style CSS

Le CSS est intégré dans chaque fichier HTML. Pour modifier le style :

1. Ouvrir `docs/privacy-policy.html`
2. Modifier la section `<style>` dans le `<head>`
3. Commiter et pousser les changements

### Ajouter une nouvelle page

1. Créer un nouveau fichier HTML dans `docs/`
2. Copier la structure de `privacy-policy.html`
3. Modifier le contenu
4. Ajouter un lien dans `docs/README.md`
5. Commiter et pousser

### Exemple de nouvelle page

```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouvelle Page - Infractions Mali</title>
    <!-- Copier le CSS de privacy-policy.html -->
    <style>
        /* CSS ici */
    </style>
</head>
<body>
    <a href="https://github.com/santultimate/infractions-mali" class="back-button" target="_blank">← Retour au projet</a>
    
    <div class="container">
        <div class="header">
            <h1>📄 Nouvelle Page</h1>
            <p class="subtitle">Infractions Routières Mali</p>
        </div>
        
        <!-- Contenu ici -->
        
        <div class="footer">
            <p>Développé avec <span class="heart">❤️</span> par <strong>Yacouba Santara</strong></p>
        </div>
    </div>
</body>
</html>
```

## 🔧 Intégration dans Flutter

### Fichiers de traduction

```json
// assets/lang/fr.json
{
  "privacy_policy_url": "https://santultimate.github.io/infractions-mali/privacy-policy.html"
}

// assets/lang/en.json
{
  "privacy_policy_url": "https://santultimate.github.io/infractions-mali/privacy-policy.html"
}
```

### Code Flutter

```dart
import 'package:url_launcher/url_launcher.dart';

void _openPrivacyPolicy() async {
  final url = Uri.parse('privacy_policy_url'.tr());
  try {
    final canLaunch = await canLaunchUrl(url);
    if (canLaunch) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir l\'URL');
    }
  } catch (e) {
    // Gérer l'erreur
  }
}
```

## 🚨 Dépannage

### Page non accessible

**Problème :** La page retourne une erreur 404

**Solutions :**
1. Vérifier que GitHub Pages est activé dans les settings
2. Attendre 5-10 minutes pour le déploiement
3. Vérifier que les fichiers sont dans le dossier `docs/`
4. Vérifier que la branche est `main`

### Changements non visibles

**Problème :** Les modifications ne s'affichent pas

**Solutions :**
1. Vérifier que les changements sont poussés sur GitHub
2. Attendre le redéploiement automatique
3. Vider le cache du navigateur (Ctrl+F5)
4. Vérifier l'URL exacte

### Erreur de configuration

**Problème :** GitHub Pages ne se configure pas

**Solutions :**
1. Vérifier les permissions du repository
2. Utiliser la configuration manuelle
3. Contacter le support GitHub si nécessaire

## 📊 Monitoring

### Vérifier le statut

```bash
# Vérifier si la page est accessible
curl -I https://santultimate.github.io/infractions-mali/privacy-policy.html

# Vérifier les actions GitHub
gh run list --repo santultimate/infractions-mali
```

### Logs de déploiement

- Aller sur https://github.com/santultimate/infractions-mali/actions
- Vérifier les actions GitHub Pages
- Consulter les logs en cas d'erreur

## 🔄 Mise à jour

### Processus de mise à jour

1. Modifier les fichiers dans `docs/`
2. Commiter les changements
3. Pousser vers GitHub
4. Attendre le déploiement automatique
5. Tester l'URL

### Exemple de commandes

```bash
# Modifier un fichier
nano docs/privacy-policy.html

# Commiter et pousser
git add docs/
git commit -m "📝 Mise à jour de la politique de confidentialité"
git push origin main

# Vérifier après quelques minutes
curl -I https://santultimate.github.io/infractions-mali/privacy-policy.html
```

## 📞 Support

### Ressources utiles

- **Documentation GitHub Pages :** https://docs.github.com/en/pages
- **GitHub CLI :** https://cli.github.com/
- **Repository :** https://github.com/santultimate/infractions-mali

### Contact

- **Email :** privacy@infractions-mali.com
- **GitHub Issues :** https://github.com/santultimate/infractions-mali/issues
- **Développeur :** Yacouba Santara

---

**Dernière mise à jour :** 15 Janvier 2025  
**Version :** 1.0.0 