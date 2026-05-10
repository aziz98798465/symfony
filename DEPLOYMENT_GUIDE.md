# 🚀 Guide de Déploiement - MindCare (Symfony 6.4)

---

## 📋 Table des matières
1. [Vue d'ensemble du projet](#vue-densemble)
2. [Architecture](#architecture)
3. [Stack Technologique](#stack-technologique)
4. [Structure du projet](#structure-du-projet)
5. [Configuration pour production](#configuration-pour-production)
6. [Déploiement](#déploiement)
7. [Vérification après déploiement](#vérification-après-déploiement)

---

## Vue d'ensemble

**MindCare** est une plateforme de gestion des rendez-vous médicaux et suivi psychologique construite avec **Symfony 6.4** et **PHP 8.2**.

### Fonctionnalités principales :
- ✅ Gestion des utilisateurs (Psychologues, Patients, Administrateurs)
- ✅ Réservations d'événements et rendez-vous
- ✅ Forum de discussion avec modération
- ✅ Journal émotionnel personnel
- ✅ Alertes psychologiques
- ✅ Authentification JWT
- ✅ Intégration Twilio (SMS)
- ✅ Intégration Zoom
- ✅ Analyse IA (HuggingFace, Groq)
- ✅ Google Analytics
- ✅ Système de fichiers patient

---

## Architecture

### Architecture en couches
```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (Twig Templates)                │
│              (avec Stimulus.js & TurboJS)                   │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   Symfony 6.4 (Backend)                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Controllers (27 contrôleurs)                        │   │
│  │ Services (Business Logic)                           │   │
│  │ Forms (Type de formulaires)                         │   │
│  │ Security (Authentification JWT + Roles)            │   │
│  │ Event Listeners (Hooks du cycle de requête)         │   │
│  │ Messages/Handlers (Queue asynchrone)               │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    Database Layer                           │
│  ┌──────────────────────┐      ┌──────────────────────┐   │
│  │ Doctrine ORM         │      │ Doctrine Migrations  │   │
│  │ 16 Entities          │      │ Version 20260510...  │   │
│  │ Repositories         │      │ (Auto-versioning)    │   │
│  └──────────────────────┘      └──────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────▼────────────────────┐
         │  MySQL/MariaDB (10.4.32)          │
         │  Database: mindcare               │
         └───────────────────────────────────┘
```

### Services externes
```
                    ┌─ Twilio (SMS)
                    ├─ Zoom API (Vidéoconférences)
    MindCare App ───┼─ HuggingFace (Sentiment Analysis)
                    ├─ Groq API (LLM)
                    ├─ Google Analytics
                    └─ Gmail (Mailer)
```

---

## Stack Technologique

### Backend
| Composant | Version | Rôle |
|-----------|---------|------|
| **PHP** | 8.2 | Langage serveur |
| **Symfony** | 6.4 | Framework web |
| **Doctrine ORM** | 3.6.2 | ORM & migrations |
| **MariaDB** | 10.4.32 | Base de données |

### Frontend
| Composant | Version | Rôle |
|-----------|---------|------|
| **Twig** | 3.23 | Moteur de templates |
| **Stimulus.js** | 3.2.2 | Framework JS léger |
| **TurboJS** | 3.0.0 | Navigation SPA |
| **Chart.js** | 4.5.1 | Graphiques |
| **Webpack** | 5.74.0 | Bundler assets |

### Dépendances principales
```
Authentification:      Lexik JWT Bundle (2.18.1)
Formulaires:           Symfony Form Bundle
Validation:            Symfony Validator
Paginateur:            KNP Paginator Bundle
Upload fichiers:       Vich Uploader Bundle (2.9.1)
reCAPTCHA:             Karser reCAPTCHA3 Bundle
SMS/Whatsapp:          Twilio SDK (8.11.1)
PDF:                   DOMPDF (3.1.5)
Google Analytics:      Google Analytics Data API
Traduction:            Google Translate PHP
```

### Stockage des assets
- **Webpack Encore**: Compilation des assets (JS, CSS)
- **Répertoire public**: `/public/` (serveur Apache)
- **Uploads**: `/public/uploads/` (fichiers utilisateurs)
- **Cache**: `/var/cache/` (auto-généré)

---

## Structure du projet

### Répertoires clés
```
PI_3A43/
├── public/                    # Racine web publique
│   ├── index.php             # Point d'entrée Symfony
│   ├── build/                # Assets compilés (JS/CSS)
│   ├── uploads/              # Fichiers utilisateurs
│   └── front_assets/         # Assets frontend
│
├── src/                       # Code source applicatif
│   ├── Controller/           # 27 Contrôleurs
│   │   ├── Admin/            # Contrôles administrateur
│   │   ├── Reservation/      # Gestion réservations
│   │   ├── AuthController.php
│   │   ├── PatientFileController.php
│   │   ├── ForumController.php
│   │   └── ...
│   │
│   ├── Entity/               # 16 Entités Doctrine
│   │   ├── User.php          # Utilisateur (RBAC)
│   │   ├── EventReservation.php  # Réservations
│   │   ├── Event.php         # Événements
│   │   ├── PatientFile.php   # Dossier patient
│   │   ├── SujetForum.php    # Sujets forum
│   │   ├── MessageForum.php  # Messages forum
│   │   ├── JournalEmotionnel.php # Journal
│   │   ├── PsychologicalAlert.php # Alertes
│   │   └── ...
│   │
│   ├── Repository/           # Repositories Doctrine
│   │   └── [*Repository.php]
│   │
│   ├── Form/                 # Types de formulaires (Symfony Forms)
│   │   ├── EventReservationType.php
│   │   ├── EventType.php
│   │   ├── PatientFileType.php
│   │   ├── LoginFormType.php
│   │   └── ...
│   │
│   ├── Service/              # Services métier
│   │   ├── Classes personnalisées
│   │   └── Logique applicative
│   │
│   ├── Security/             # Authentification & Autorisation
│   │   ├── AppAuthenticator
│   │   ├── Roles & Permissions
│   │   └── JWT Configuration
│   │
│   ├── Command/              # Commandes CLI (php bin/console)
│   │   └── Commandes Symfony
│   │
│   ├── EventListener/        # Écouteurs d'événements
│   │   └── Hooks du cycle requête
│   │
│   ├── Message/              # Messages Messenger
│   │   └── Queues asynchrones
│   │
│   ├── MessageHandler/       # Gestionnaires messages
│   │   └── Traitement asynchrone
│   │
│   ├── Bundles/              # Bundles personnalisés
│   │   ├── EventCoreBundle/
│   │   ├── EventUIBundle/
│   │   ├── EventAPIBundle/
│   │   └── EventNotificationBundle/
│   │
│   └── Kernel.php            # Noyau Symfony
│
├── config/                    # Configuration
│   ├── bundles.php           # Bundles activés
│   ├── services.yaml         # Services
│   ├── routes.yaml           # Routes
│   ├── packages/             # Configuration packages
│   │   ├── framework.yaml
│   │   ├── doctrine.yaml
│   │   ├── security.yaml
│   │   ├── messenger.yaml
│   │   └── ...
│   └── routes/               # Routes avancées
│
├── templates/                # Templates Twig
│   ├── base.html.twig       # Template parent
│   ├── admin/               # Admin templates
│   ├── auth/                # Authentification
│   ├── forum/               # Forum
│   ├── reservation/         # Réservations
│   ├── patient_file/        # Dossier patient
│   ├── emails/              # Mails
│   └── ...
│
├── migrations/               # Doctrine Migrations
│   ├── Version20260305000126.php  # Cleanup schemas
│   ├── Version20260510154000.php  # Forum structure
│   └── Version20260510180000.php  # Waiting list feature
│
├── assets/                   # Assets sources (JS/CSS)
│   ├── app.js               # Point d'entrée JS
│   ├── bootstrap.js         # Bootstrap JS
│   ├── controllers/         # Contrôleurs Stimulus
│   │   └── hello_controller.js
│   ├── styles/              # Styles CSS/SCSS
│   │   └── app.css
│   └── vendor/              # Dépendances JS
│
├── tests/                    # Tests unitaires
│   ├── bootstrap.php
│   └── Service/
│
├── var/                      # Fichiers générés
│   ├── cache/               # Cache Symfony
│   └── log/                 # Logs applicatif
│
├── vendor/                   # Dépendances Composer
│   └── [toutes les dépendances PHP]
│
├── .env                      # Variables d'environnement
├── .env.local               # Variables locales (NON versionné)
├── .env.prod               # Variables production (si besoin)
│
├── composer.json            # Dépendances PHP
├── composer.lock            # Lock file (versions figées)
│
├── package.json             # Dépendances npm
├── webpack.config.js        # Configuration Webpack
│
├── phpunit.xml.dist         # Configuration PHPUnit
├── phpstan.neon             # Configuration PHPStan (analyse statique)
│
├── docker-compose.yaml      # Compose DEV (PostgreSQL)
├── compose.yaml             # Compose principal
├── compose.override.yaml    # Overrides compose
├── Dockerfile               # Image Docker (PHP 8.2)
│
├── bin/console              # Commande Symfony
│
└── README_INSTALL.md        # Documentation installation
```

### Architecture métier - Entités principales
```
User (RBAC)
├── Psychologist (Psychologues)
├── Patient (Patients)
├── Admin (Administrateurs)
└── Student (Étudiants)

Event (Événements/Rendez-vous)
├── EventReservation (Réservations + Waiting List)
├── Appointment (Rendez-vous)
└── Resource (Ressources)

PatientFile (Dossier patient)
├── JournalEmotionnel (Journaux)
├── Mood (Données d'humeur)
└── PsychologicalAlert (Alertes)

Forum
├── SujetForum (Sujets)
├── MessageForum (Messages)
└── LikeMessage (Likes)

Communication
├── Appointment (Rendez-vous)
└── Commentaire (Commentaires)
```

---

## Configuration pour production

### 1. **Variables d'environnement (.env.prod)**

```env
###> symfony/framework-bundle ###
APP_ENV=prod
APP_DEBUG=0
APP_SECRET=[GÉNÉRER UNE CLÉ SÉCURISÉE: php -r "echo bin2hex(random_bytes(32));"]
###< symfony/framework-bundle ###

###> doctrine/doctrine-bundle ###
DATABASE_URL="mysql://[USER]:[PASSWORD]@[HOST]:[PORT]/mindcare?serverVersion=10.4.32-MariaDB&charset=utf8mb4"
###< doctrine/doctrine-bundle ###

###> symfony/messenger ###
MESSENGER_TRANSPORT_DSN=doctrine://default?auto_setup=0
###< symfony/messenger ###

###> symfony/mailer ###
MAILER_FROM=noreply@mindcare.com
MAILER_DSN=smtp://[SMTP_SERVER]:[PORT]?encryption=tls&username=[USER]&password=[PASSWORD]
###< symfony/mailer ###

###> karser/karser-recaptcha3-bundle ###
RECAPTCHA_SITE_KEY=[VOTRE_SITE_KEY]
RECAPTCHA_SECRET_KEY=[VOTRE_SECRET_KEY]
###< karser/karser-recaptcha3-bundle ###

###> twilio/sdk ###
TWILIO_ACCOUNT_SID=[VOTRE_ACCOUNT_SID]
TWILIO_AUTH_TOKEN=[VOTRE_AUTH_TOKEN]
TWILIO_FROM_NUMBER=[VOTRE_NUMERO]
###< twilio/sdk ###

###> huggingface ###
HUGGINGFACE_API_TOKEN=[VOTRE_TOKEN]
HUGGINGFACE_API_URL=https://router.huggingface.co/v1/chat/completions
###< huggingface ###

###> Groq API (optionnel) ###
GROQ_API_KEY=[VOTRE_GROQ_KEY]
###< Groq API ###
```

### 2. **Configuration Apache (production)**

```apache
<VirtualHost *:80>
    ServerName mindcare.com
    ServerAlias www.mindcare.com
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
        AllowOverride All
        Order allow,deny
        Allow from all
        
        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule ^(.*)$ index.php [QSA,L]
        </IfModule>
    </Directory>

    LogFormat combined
    ErrorLog ${APACHE_LOG_DIR}/mindcare_error.log
    CustomLog ${APACHE_LOG_DIR}/mindcare_access.log combined
</VirtualHost>
```

### 3. **Configuration Nginx (alternative)**

```nginx
server {
    listen 80;
    server_name mindcare.com www.mindcare.com;
    root /var/www/html/public;

    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass php:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        internal;
    }

    access_log /var/log/nginx/mindcare_access.log;
    error_log /var/log/nginx/mindcare_error.log;
}
```

---

## Déploiement

### Option 1: Docker (Recommandé)

#### Build de l'image
```bash
docker build -t mindcare:latest .
```

#### Docker Compose (production)
```yaml
version: '3.8'

services:
  app:
    image: mindcare:latest
    container_name: mindcare_app
    ports:
      - "80:80"
    environment:
      - APP_ENV=prod
      - APP_DEBUG=0
      - DATABASE_URL=mysql://mindcare:password@db:3306/mindcare?serverVersion=10.4.32-MariaDB
    depends_on:
      - db
    volumes:
      - ./public/uploads:/var/www/html/public/uploads
    networks:
      - mindcare_network

  db:
    image: mariadb:10.4.32
    container_name: mindcare_db
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: mindcare
      MYSQL_USER: mindcare
      MYSQL_PASSWORD: password
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - mindcare_network

volumes:
  db_data:

networks:
  mindcare_network:
    driver: bridge
```

#### Lancer les conteneurs
```bash
docker-compose -f compose.yaml up -d
docker exec mindcare_app php bin/console doctrine:migrations:migrate
```

### Option 2: VPS/Serveur dédié

#### Prérequis
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-intl php8.2-zip php8.2-xml apache2 mariadb-server composer npm

# Activer modules Apache
sudo a2enmod rewrite
sudo a2enmod proxy_fcgi
sudo a2enmod setenvif
```

#### Installation de l'application
```bash
# Cloner le repo
cd /var/www
git clone https://github.com/aziz98798465/symfony.git mindcare
cd mindcare

# Installer les dépendances
composer install --no-dev -o
npm install

# Compiler les assets
npm run build

# Permissions
sudo chown -R www-data:www-data /var/www/mindcare
sudo chmod -R 755 /var/www/mindcare/public
sudo chmod -R 777 /var/www/mindcare/var

# Configuration Apache
sudo cp config/apache.conf /etc/apache2/sites-available/mindcare.conf
sudo a2ensite mindcare
sudo systemctl restart apache2
```

#### Initialiser la base de données
```bash
php bin/console doctrine:migrations:migrate --no-interaction
```

#### Vérifier l'installation
```bash
php bin/console about
php bin/console doctrine:database:create
```

### Option 3: Heroku / Railway / Vercel

```bash
# Railway.app exemple
railway init
railway up
```

---

## Vérification après déploiement

### Checklist de vérification

- [ ] **Page d'accueil** : Accès à `/` sans erreurs
- [ ] **Authentification** : Connexion utilisateur fonctionnelle
- [ ] **Forum** : Consultation et création de sujets
- [ ] **Réservations** : `/mes-reservations` sans erreur SQL
- [ ] **Dossier patient** : Accès et édition du dossier
- [ ] **Journal émotionnel** : Création et visualisation des entrées
- [ ] **Alertes** : Système d'alertes psychologiques
- [ ] **Emails** : Réception des mails de notification
- [ ] **SMS** : Envoi/réception SMS via Twilio
- [ ] **Chat IA** : Fonctionnement du chatbot
- [ ] **Assets** : Chargement CSS/JS sans erreurs
- [ ] **Uploads** : Upload de fichiers
- [ ] **PDF** : Génération de PDFs
- [ ] **Google Analytics** : Tracking configuré

### Commandes de diagnostic

```bash
# État de l'application
php bin/console about

# Vérifier les migrations
php bin/console doctrine:migrations:list

# Valider les entités
php bin/console doctrine:schema:validate

# Vérifier les routes
php bin/console debug:router

# Cache
php bin/console cache:clear
php bin/console cache:warmup
```

### Logs à surveiller

```bash
# Logs Symfony
tail -f var/log/prod.log

# Logs Apache
sudo tail -f /var/log/apache2/mindcare_error.log
sudo tail -f /var/log/apache2/mindcare_access.log

# Logs MySQL
mysql -u root -p -e "SELECT * FROM mysql.error_log;"
```

---

## Optimisations production

### Performance
```bash
# Compiler avec optimisations
composer install --no-dev -o --classmap-authoritative

# Compiler les templates
php bin/console cache:warmup

# Webpack production
npm run build
```

### Sécurité
```bash
# Générer une nouvelle APP_SECRET
php -r "echo bin2hex(random_bytes(32));"

# Changer les permissions
sudo chmod 700 /var/www/mindcare/.env
sudo chmod 700 /var/www/mindcare/var

# Certificat SSL
# Utiliser Let's Encrypt
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d mindcare.com -d www.mindcare.com
```

### Monitoring
```bash
# Cron job pour les migrations automatiques
0 2 * * * /usr/bin/php /var/www/mindcare/bin/console doctrine:migrations:migrate --no-interaction

# Backup quotidien
0 3 * * * mysqldump -u mindcare -ppassword mindcare | gzip > /backups/mindcare_$(date +\%Y\%m\%d).sql.gz
```

---

## Support et Documentation

| Ressource | Lien |
|-----------|------|
| Symfony 6.4 Docs | https://symfony.com/doc/6.4/ |
| Doctrine ORM | https://www.doctrine-project.org/projects/doctrine-orm/en/latest/ |
| Twig Templates | https://twig.symfony.com/doc/3.x/ |
| Stimulus.js | https://stimulus.hotwired.dev/ |
| GitHub Repository | https://github.com/aziz98798465/symfony |

---

**Dernière mise à jour**: Mai 2026
**Version**: 1.0.0
**Statut**: Production-Ready ✅
