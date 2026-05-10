# 🚀 QUICKSTART - Configuration & Déploiement Rapide

## Installation en 5 minutes

### Prérequis
- PHP 8.2+
- Composer
- Node.js & npm
- MySQL 5.7+ ou MariaDB 10.3+
- Git
- Docker (optionnel)

---

## 1️⃣ Cloner le projet

```bash
git clone https://github.com/aziz98798465/symfony.git mindcare
cd mindcare
```

---

## 2️⃣ Installation des dépendances

### Backend (PHP)
```bash
composer install
```

### Frontend (JavaScript)
```bash
npm install
```

---

## 3️⃣ Configuration d'environnement

### Créer le fichier .env.local
```bash
cp .env .env.local
```

### Éditer `.env.local` pour vos paramètres locaux
```env
###> symfony/framework-bundle ###
APP_ENV=dev
APP_DEBUG=1
APP_SECRET=your_secret_key_here_for_dev
###< symfony/framework-bundle ###

###> doctrine/doctrine-bundle ###
DATABASE_URL="mysql://root:password@127.0.0.1:3306/mindcare?serverVersion=10.4.32-MariaDB&charset=utf8mb4"
###< doctrine/doctrine-bundle ###

###> symfony/mailer ###
MAILER_FROM=dev@mindcare.local
MAILER_DSN=smtp://localhost:1025
###< symfony/mailer ###

# Optionnel pour développement local:
RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
RECAPTCHA_SECRET_KEY=6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe
```

> **Note**: Les clés reCAPTCHA ci-dessus sont les clés de test officielles de Google

---

## 4️⃣ Initialiser la base de données

### Créer la base de données
```bash
php bin/console doctrine:database:create
```

### Exécuter les migrations
```bash
php bin/console doctrine:migrations:migrate
```

### (Optionnel) Charger des données de test
```bash
php bin/console doctrine:fixtures:load
```

---

## 5️⃣ Compiler les assets

```bash
# Mode développement (avec watch)
npm run watch

# Mode production
npm run build
```

---

## 6️⃣ Démarrer l'application

### Option A: Serveur Symfony intégré
```bash
symfony serve
# OU
php -S 127.0.0.1:8000 -t public/
```

### Option B: Apache + PHP-FPM
```bash
# Configurer Apache pour pointer vers public/
# puis redémarrer Apache
sudo systemctl restart apache2
```

### Option C: Docker (recommandé)
```bash
docker-compose up -d

# Puis dans le conteneur:
docker exec mindcare_app php bin/console doctrine:migrations:migrate
```

---

## 7️⃣ Vérifier l'installation

```bash
# Afficher les routes
php bin/console debug:router

# Valider la structure
php bin/console doctrine:schema:validate

# Afficher les informations
php bin/console about
```

---

## 📂 Structure des fichiers à connaître

```
mindcare/
├── public/              # Racine web (index.php ici)
├── src/                 # Code source
├── config/              # Configuration Symfony
├── templates/           # Templates Twig
├── assets/              # JS/CSS sources
├── migrations/          # Migrations DB
├── .env                 # Variables d'env (versionné)
├── .env.local           # Variables locales (NON versionné)
├── composer.json        # Dépendances PHP
├── package.json         # Dépendances JS
└── Dockerfile           # Configuration Docker
```

---

## 🔧 Configuration recommandée

### 1. IDE (VS Code)
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "php.validate.executablePath": "C:\\php\\php.exe",
  "[php]": {
    "editor.defaultFormatter": "felixbecker.php-intellisense"
  }
}
```

### 2. Extensions recommandées
- Symfony for VSCode
- Twig Language 2
- YAML
- REST Client

### 3. Git hooks (optionnel)
```bash
# Pré-commit checks
php bin/console lint:twig templates/
php bin/console lint:yaml config/
```

---

## 🌐 Accès à l'application

### URLs locales
| URL | Description |
|-----|-------------|
| `http://localhost:8000` | Accueil |
| `http://localhost:8000/admin` | Panel admin |
| `http://localhost:8000/forum` | Forum |
| `http://localhost:8000/mes-reservations` | Mes réservations |
| `http://localhost:8000/mon-dossier` | Dossier patient |

### Comptes de test
```
Admin:
- Email: admin@mindcare.local
- Password: admin123

Psychologist:
- Email: psych@mindcare.local
- Password: psych123

Patient:
- Email: patient@mindcare.local
- Password: patient123
```

---

## 🐛 Debugging

### Activer le profiler Symfony
```env
# Dans .env.local
SYMFONY_DEBUG=1
SYMFONY_DEBUG_MAIL_CATCHER=1
```

### Accéder au profiler
```
http://localhost:8000/_profiler/latest
```

### Logs temps réel
```bash
tail -f var/log/dev.log
```

### Console de débogage
```bash
php bin/console debug:container
php bin/console debug:routes
php bin/console debug:config
```

---

## 📱 Commandes utiles

```bash
# Afficher l'état de santé
php bin/console about

# Effacer le cache
php bin/console cache:clear

# Réchauffer le cache
php bin/console cache:warmup

# Valider le schéma DB
php bin/console doctrine:schema:validate

# Créer une migration
php bin/console make:migration

# Créer une entité
php bin/console make:entity

# Créer un contrôleur
php bin/console make:controller

# Lancer les tests
php bin/phpunit

# Vérifier la syntaxe PHP
php -l src/Controller/HomeController.php
```

---

## 🚨 Problèmes courants

### Erreur: "SQLSTATE[42S22]: Column not found"
```bash
# Solution:
php bin/console doctrine:migrations:migrate --no-interaction
```

### Erreur: "Migration not found"
```bash
# Réinitialiser les migrations:
php bin/console doctrine:migrations:sync-metadata-storage
php bin/console doctrine:migrations:migrate
```

### Assets non chargés (CSS/JS)
```bash
# Recompiler:
npm run dev
php bin/console asset-map:compile
```

### Permissions denied
```bash
# Fix permissions (Linux/Mac):
sudo chown -R $USER:$USER .
chmod -R 755 var/
chmod -R 755 public/uploads/
```

### Base de données vide
```bash
# Charger les migrations ET data fixtures:
php bin/console doctrine:migrations:migrate
php bin/console doctrine:fixtures:load --no-interaction
```

---

## 📊 Vérification Post-Installation

Après installation, vérifier:

- [ ] `php bin/console about` s'exécute sans erreur
- [ ] `http://localhost:8000/` affiche la page d'accueil
- [ ] `http://localhost:8000/_profiler/` accessible (dev)
- [ ] Base de données créée et tables présentes
- [ ] Assets compilés dans `public/build/`
- [ ] Formulaires s'affichent correctement
- [ ] Login/Logout fonctionne
- [ ] Forum accessible
- [ ] Pas d'erreurs dans `var/log/dev.log`

---

## 🚀 Déploiement en production

### Avant de déployer
```bash
# 1. Tester en mode prod local
APP_ENV=prod composer install --no-dev -o
APP_ENV=prod npm run build
php bin/console cache:clear --env=prod

# 2. Vérifier les tests
php bin/phpunit

# 3. Vérifier les migrations
php bin/console doctrine:migrations:list

# 4. Vérifier la configuration prod
php bin/console debug:config symfony
```

### Déployer avec Git
```bash
# Sur le serveur
git clone https://github.com/aziz98798465/symfony.git
cd symfony

# Configuration prod
cp .env .env.prod.local
# ... éditer avec vraies valeurs ...

# Installation
composer install --no-dev -o --apcu-autoloader
npm install --production
npm run build

# Initialiser BD
php bin/console doctrine:migrations:migrate --no-interaction

# Permissions
chmod 777 var/cache var/log public/uploads

# Clear cache
php bin/console cache:clear --env=prod
```

### Avec Docker
```bash
# Build image
docker build -t mindcare:latest .

# Run container
docker run -d \
  --name mindcare \
  -p 80:80 \
  -e APP_ENV=prod \
  -e DATABASE_URL="mysql://..." \
  mindcare:latest

# Migrations en container
docker exec mindcare php bin/console doctrine:migrations:migrate
```

---

## 📞 Support

Pour des questions:
- 📖 Docs: https://symfony.com/doc/6.4/
- 🐛 Issues: https://github.com/aziz98798465/symfony/issues
- 💬 Discussions: https://github.com/aziz98798465/symfony/discussions

---

**Dernière mise à jour**: Mai 2026
**Tested avec**: PHP 8.2, Symfony 6.4, MariaDB 10.4
