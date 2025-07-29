# 📚 Documentation Infractions Mali

Ce dossier contient la documentation publique de l'application **Infractions Mali**, hébergée sur GitHub Pages.

## 🌐 Pages disponibles

### [Politique de Confidentialité](./privacy-policy.html)
- **URL :** https://santultimate.github.io/infractions-mali/privacy-policy.html
- **Description :** Politique de confidentialité complète de l'application
- **Contenu :** RGPD, collecte de données, droits utilisateur, sécurité

## 🚀 Configuration GitHub Pages

### 1. Activation de GitHub Pages
1. Aller dans les **Settings** du repository
2. Scroller jusqu'à la section **Pages**
3. Dans **Source**, sélectionner **Deploy from a branch**
4. Choisir la branche **main** et le dossier **/docs**
5. Cliquer sur **Save**

### 2. URL de la page
- **URL principale :** https://santultimate.github.io/infractions-mali/
- **Politique de confidentialité :** https://santultimate.github.io/infractions-mali/privacy-policy.html

## 📁 Structure des fichiers

```
docs/
├── README.md                 # Ce fichier
├── privacy-policy.html       # Page de politique de confidentialité
└── assets/                   # Ressources (images, CSS, JS)
    ├── images/
    │   ├── favicon.png       # Icône du site
    │   └── og-image.png      # Image pour les réseaux sociaux
    ├── css/
    └── js/
```

## 🔧 Personnalisation

### Ajouter une nouvelle page
1. Créer un fichier HTML dans le dossier `docs/`
2. Utiliser le même style CSS que `privacy-policy.html`
3. Ajouter un lien dans ce README
4. Commiter et pousser les changements

### Modifier le style
- Le CSS est intégré dans chaque fichier HTML
- Utiliser les classes CSS existantes pour la cohérence
- Tester sur mobile et desktop

## 📱 Responsive Design

Toutes les pages sont optimisées pour :
- **Desktop :** Largeur maximale 900px
- **Tablet :** Adaptation automatique
- **Mobile :** Marges réduites, police adaptée

## 🔗 Intégration dans l'application

### Flutter
```dart
// Dans les fichiers de traduction
"privacy_policy_url": "https://santultimate.github.io/infractions-mali/privacy-policy.html"

// Dans le code
void _openPrivacyPolicy() {
  final url = Uri.parse('privacy_policy_url'.tr());
  launchUrl(url, mode: LaunchMode.externalApplication);
}
```

### Mise à jour automatique
- Les changements sont automatiquement déployés
- Délai : 1-5 minutes après push
- Vérifier sur https://santultimate.github.io/infractions-mali/

## 📊 Analytics (Optionnel)

Pour ajouter Google Analytics :
1. Créer un compte Google Analytics
2. Récupérer l'ID de mesure (GA_MEASUREMENT_ID)
3. Remplacer `GA_MEASUREMENT_ID` dans le script des pages HTML

## 🎨 Thème et couleurs

- **Couleur principale :** #667eea (Bleu)
- **Couleur secondaire :** #764ba2 (Violet)
- **Police :** Segoe UI, Tahoma, Geneva, Verdana, sans-serif
- **Gradient :** linear-gradient(135deg, #667eea 0%, #764ba2 100%)

## 📞 Support

Pour toute question concernant la documentation :
- **Email :** privacy@infractions-mali.com
- **GitHub :** https://github.com/santultimate/infractions-mali/issues
- **Développeur :** Yacouba Santara

---

**Dernière mise à jour :** 15 Janvier 2025
**Version :** 1.0.0 