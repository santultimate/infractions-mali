# Infractions Mali - Application de Sécurité Routière

Une application mobile Flutter moderne pour la sécurité routière au Mali, permettant aux utilisateurs de signaler et consulter les infractions routières, radars, contrôles de police et autres alertes en temps réel.

## 🚀 Fonctionnalités Principales

### 🔐 Authentification & Sécurité
- **Connexion Google & Facebook** : Authentification sécurisée avec Firebase Auth
- **Vérification email** : Système de vérification automatique des emails
- **Gestion de session** : Connexion persistante avec déconnexion
- **Profil utilisateur** : Affichage du nom et photo de profil

### 🗺️ Cartographie & Géolocalisation
- **Carte communautaire** : Visualisation des alertes signalées par les utilisateurs
- **Carte interactive** : Intégration OpenStreetMap avec filtrage par distance
- **Géolocalisation précise** : Utilisation du GPS pour localiser les alertes
- **Filtrage intelligent** : Recherche et filtres par type d'alerte

### 📱 Interface Utilisateur
- **Design moderne** : Interface Material Design 3 avec thème sombre/clair
- **Animations fluides** : Transitions et animations pour une meilleure UX
- **Responsive** : Adaptation automatique à différentes tailles d'écran
- **Accessibilité** : Support des lecteurs d'écran et navigation au clavier

### 🌍 Internationalisation
- **Multi-langues** : Support français et anglais avec `easy_localization`
- **Traduction complète** : Tous les textes traduits et localisés
- **Format local** : Dates, nombres et formats adaptés à la région

### 🔔 Notifications & Communication
- **Push notifications** : Alertes en temps réel avec Firebase Messaging
- **Feedback utilisateur** : Messages de confirmation et d'erreur
- **Statistiques** : Suivi des alertes, commentaires et signalements

### 💰 Monétisation
- **Orange Money** : Intégration pour les dons et soutien du projet
- **Google AdMob** : Publicités bannières et interstitielles (configurées)
- **Modèle économique** : Application gratuite avec options de soutien

## 🛠️ Technologies Utilisées

### Frontend
- **Flutter 3.2+** : Framework cross-platform
- **Dart 3.0+** : Langage de programmation
- **Material Design 3** : Système de design moderne

### Backend & Services
- **Firebase Auth** : Authentification utilisateur
- **Firebase Firestore** : Base de données NoSQL en temps réel
- **Firebase Messaging** : Notifications push
- **Google Sign-In** : Connexion Google
- **Facebook Auth** : Connexion Facebook

### Cartographie & Localisation
- **Flutter Map** : Intégration OpenStreetMap
- **Geolocator** : Services de géolocalisation
- **LatLong2** : Calculs géographiques

### Outils & Bibliothèques
- **Easy Localization** : Internationalisation
- **Google Mobile Ads** : Publicités AdMob
- **Shared Preferences** : Stockage local
- **HTTP** : Requêtes réseau
- **Mocktail** : Tests unitaires

## 📋 Prérequis

- **Flutter SDK** : Version 3.2.3 ou supérieure
- **Dart SDK** : Version 3.0 ou supérieure
- **Android Studio** ou **VS Code** avec extensions Flutter
- **Compte Firebase** : Pour l'authentification et la base de données
- **Compte Google Cloud** : Pour les services Google
- **Compte Facebook Developer** : Pour l'authentification Facebook

## 🚀 Installation

### Configuration GitHub
1. **Créer un nouveau repository** sur GitHub :
   - Allez sur [GitHub](https://github.com)
   - Cliquez sur "New repository"
   - Nom : `infractions-mali`
   - Description : `Application de sécurité routière pour le Mali`
   - Public ou Private selon votre préférence
   - **Ne pas** initialiser avec README, .gitignore ou licence

2. **Connecter le repository local** :
   ```bash
   git remote add origin https://github.com/yacouba-santara/infractions-mali.git
   git branch -M main
   git push -u origin main
   ```

3. **Vérifier le lien de la politique de confidentialité** :
   - Le lien dans l'application pointe vers : `https://github.com/yacouba-santara/infractions-mali/blob/main/PRIVACY_POLICY.md`
   - Assurez-vous que votre nom d'utilisateur GitHub est `yacouba-santara` ou modifiez le lien dans `assets/lang/fr.json` et `assets/lang/en.json`

### 1. Cloner le projet
```bash
git clone https://github.com/yacouba-santara/infractions-mali.git
cd infractions-mali
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Configuration Firebase
1. Créer un projet Firebase
2. Ajouter les applications Android et iOS
3. Télécharger les fichiers de configuration :
   - `google-services.json` pour Android
   - `GoogleService-Info.plist` pour iOS
4. Placer les fichiers dans les dossiers appropriés

### 4. Configuration des services
1. **Google Sign-In** : Configurer les OAuth credentials
2. **Facebook Auth** : Configurer l'application Facebook
3. **AdMob** : Créer les unités publicitaires
4. **Orange Money** : Configurer les paramètres de paiement

### 5. Variables d'environnement
Créer un fichier `.env` à la racine du projet :
```env
FIREBASE_PROJECT_ID=votre-projet-id
GOOGLE_SIGN_IN_CLIENT_ID=votre-client-id
FACEBOOK_APP_ID=votre-facebook-app-id
ADMOB_APP_ID=votre-admob-app-id
```

## 🏗️ Architecture du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── alert.dart           # Modèle d'alerte
│   ├── comment.dart         # Modèle de commentaire
│   ├── infraction.dart      # Modèle d'infraction
│   └── orange_money_payment.dart
├── screens/                  # Écrans de l'application
│   ├── home_screen.dart     # Écran principal
│   ├── login_screen.dart    # Écran de connexion
│   ├── community_map_screen.dart
│   ├── interactive_map_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
├── services/                 # Services métier
│   ├── auth_service.dart    # Service d'authentification
│   ├── alert_service.dart   # Service de gestion des alertes
│   ├── comment_service.dart # Service de commentaires
│   ├── infraction_service.dart
│   └── orange_money_service.dart
└── widgets/                  # Composants réutilisables
    ├── add_alert_dialog.dart
    ├── infraction_card.dart
    ├── comment_section.dart
    ├── ad_banner.dart
    ├── ad_interstitial.dart
    ├── orange_money_donation_dialog.dart
    ├── alert_list_overlay.dart
    └── app_background.dart
```

## 🧪 Tests

### Tests unitaires
```bash
flutter test
```

### Tests d'intégration
```bash
flutter test integration_test/
```

### Tests de widgets
```bash
flutter test test/widget_test.dart
```

## 📱 Compilation

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔧 Configuration

### Android
- **Min SDK** : 21 (Android 5.0)
- **Target SDK** : 34 (Android 14)
- **Permissions** : Localisation, Internet, Caméra

### iOS
- **Min iOS** : 12.0
- **Target iOS** : 17.0
- **Permissions** : Localisation, Caméra, Notifications

## 📊 Métriques & Analytics

L'application collecte des métriques anonymes pour améliorer l'expérience utilisateur :
- Nombre d'alertes créées
- Types d'alertes les plus populaires
- Zones géographiques actives
- Temps d'utilisation
- Taux de conversion des publicités

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment contribuer :

1. **Fork** le projet
2. Créer une **branche** pour votre fonctionnalité
3. **Commit** vos changements
4. **Push** vers la branche
5. Ouvrir une **Pull Request**

### Standards de code
- Suivre les conventions Dart/Flutter
- Ajouter des tests pour les nouvelles fonctionnalités
- Documenter le code avec des commentaires
- Respecter les principes SOLID

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Développeur

**Yacouba Santara**
- Développeur Flutter passionné
- Spécialisé dans les applications mobiles
- Expert en sécurité routière et cartographie

## 📞 Support

Pour toute question ou problème :
- **Email** : support@infractions-mali.com
- **GitHub Issues** : [Créer une issue](https://github.com/votre-username/infractions_mali/issues)
- **Documentation** : [Wiki du projet](https://github.com/votre-username/infractions_mali/wiki)

## 🙏 Remerciements

- **Firebase** pour l'infrastructure backend
- **OpenStreetMap** pour les données cartographiques
- **Flutter Team** pour le framework exceptionnel
- **Communauté Flutter** pour le support et les ressources

---

**Infractions Mali** - Rendre les routes du Mali plus sûres, une alerte à la fois ! 🚗🛣️
