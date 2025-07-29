# 🚀 Configuration GitHub - Infractions Mali

## Étapes rapides pour créer le repository GitHub

### 1. Créer le repository sur GitHub
1. Allez sur [GitHub](https://github.com)
2. Cliquez sur **"New repository"**
3. Remplissez les informations :
   - **Repository name** : `infractions-mali`
   - **Description** : `Application de sécurité routière pour le Mali`
   - **Visibility** : Public ou Private
   - **❌ NE PAS** cocher "Add a README file"
   - **❌ NE PAS** cocher "Add .gitignore"
   - **❌ NE PAS** cocher "Choose a license"
4. Cliquez sur **"Create repository"**

### 2. Utiliser le script automatique (Recommandé)
```bash
./setup_github.sh
```

Le script va :
- Demander votre nom d'utilisateur GitHub
- Mettre à jour automatiquement les liens de la politique de confidentialité
- Configurer le remote Git
- Pousser le code vers GitHub

### 3. Configuration manuelle (Alternative)

Si vous préférez faire manuellement :

```bash
# 1. Mettre à jour les liens avec votre nom d'utilisateur
# Remplacez "votre-username" par votre nom d'utilisateur GitHub
sed -i '' "s/yacouba-santara/votre-username/g" assets/lang/fr.json
sed -i '' "s/yacouba-santara/votre-username/g" assets/lang/en.json

# 2. Configurer le remote Git
git remote add origin https://github.com/votre-username/infractions-mali.git
git branch -M main
git push -u origin main
```

### 4. Vérification

Après la configuration, vérifiez que :
- ✅ Le repository est créé sur GitHub
- ✅ Le code est poussé avec succès
- ✅ Le lien de la politique de confidentialité fonctionne dans l'app
- ✅ Le fichier `PRIVACY_POLICY.md` est visible sur GitHub

### 5. Test de la politique de confidentialité

1. Lancez l'application : `flutter run -d chrome`
2. Cliquez sur le menu hamburger (☰)
3. Sélectionnez "À propos"
4. Cliquez sur "Voir la politique de confidentialité"
5. Le lien devrait ouvrir le fichier sur GitHub

## 🔗 Liens utiles

- **Repository** : `https://github.com/votre-username/infractions-mali`
- **Politique de confidentialité** : `https://github.com/votre-username/infractions-mali/blob/main/PRIVACY_POLICY.md`
- **Issues** : `https://github.com/votre-username/infractions-mali/issues`

## 📝 Notes importantes

- Assurez-vous que votre nom d'utilisateur GitHub est correct dans les liens
- Le fichier `PRIVACY_POLICY.md` doit être à la racine du repository
- La politique de confidentialité est conforme au RGPD
- Tous les liens dans l'application pointent vers votre repository GitHub

---

**Développé avec ❤️ par Yacouba Santara pour la sécurité routière au Mali** 