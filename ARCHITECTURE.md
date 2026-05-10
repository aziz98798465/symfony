# Architecture MindCare - Documentation Détaillée

## 🏗️ Vue d'ensemble de l'architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CLIENTS                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │   Web Browser    │  │   Mobile App     │  │   API Clients    │  │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  │
└───────────┼──────────────────────┼──────────────────────┼───────────┘
            │                      │                      │
            └──────────────────────┼──────────────────────┘
                                   │ HTTPS
┌──────────────────────────────────▼──────────────────────────────────┐
│                    REVERSE PROXY / LOAD BALANCER                     │
│                  (Nginx / Apache / Cloudflare CDN)                   │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│                                                                       │
│                      SYMFONY 6.4 APPLICATION LAYER                   │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                   REQUEST HANDLING                             │ │
│  │  ┌─────────────────────────────────────────────────────────┐  │ │
│  │  │ 1. HttpKernel → 2. Routing → 3. Controller Dispatch    │  │ │
│  │  └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              SECURITY & AUTHENTICATION                      │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │ JWT Token Validation → Role-Based Access Control   │   │   │
│  │  │ Roles: ROLE_ADMIN, ROLE_PSYCHOLOGIST, ROLE_PATIENT │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    CONTROLLERS (27)                            │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │ │
│  │  │ AuthController│  │ ForumController│ │ AdminController      │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │ │
│  │  │ PatientFile  │  │ Reservation  │  │   Mood      │         │ │
│  │  │ Controller   │  │  Controllers │  │ Controller   │         │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │ │
│  │  + 21 autres contrôleurs...                                    │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │              SERVICES & BUSINESS LOGIC                        │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ • EmailService      • TwilioService                      │ │ │
│  │  │ • PDFGenerator      • ZoomIntegrationService            │ │ │
│  │  │ • AIAnalysisService • GoogleAnalyticsService            │ │ │
│  │  │ • NotificationService • FileUploadService               │ │ │
│  │  │ • UserService       • ReservationService                │ │ │
│  │  │ + Services métier personnalisés...                      │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │           FORM VALIDATION & DATA TRANSFORMATION              │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Symfony Forms (Type Classes)                             │ │ │
│  │  │ • EventReservationType • PatientFileType                │ │ │
│  │  │ • EventType            • LoginFormType                  │ │ │
│  │  │ • 10 autres Form Types...                               │ │ │
│  │  │                                                          │ │ │
│  │  │ Validation Rules: Constraints, Custom Validators        │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │               TEMPLATING LAYER (Twig)                        │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Base Template → Inheritance                             │ │ │
│  │  │ ├── Admin Templates                                      │ │ │
│  │  │ ├── Auth Templates                                       │ │ │
│  │  │ ├── Forum Templates                                      │ │ │
│  │  │ ├── Reservation Templates                                │ │ │
│  │  │ ├── Patient File Templates                               │ │ │
│  │  │ ├── Email Templates                                      │ │ │
│  │  │ └── +15 autres templates...                              │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │          FRONTEND ASSETS (JavaScript + CSS)                  │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Webpack Encore (Bundler)                                 │ │ │
│  │  │ └─ Stimulus.js (Lightweight Controllers)                 │ │ │
│  │  │ └─ TurboJS (SPA Navigation)                              │ │ │
│  │  │ └─ Chart.js (Graphiques)                                 │ │ │
│  │  │ └─ Bootstrap & Custom CSS                                │ │ │
│  │  │ └─ Compiled to: /public/build/                           │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │               MESSAGING & ASYNC JOBS                         │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ Symfony Messenger                                        │ │ │
│  │  │ ├── Transport: Doctrine (Default)                        │ │ │
│  │  │ ├── Messages: Email, SMS, Notifications                  │ │ │
│  │  │ └── Handlers: Async Processing                           │ │ │
│  │  │                                                          │ │ │
│  │  │ Command (Cron): php bin/console messenger:consume        │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │         EVENT LISTENERS & HOOKS (Lifecycle)                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ • RequestEvent         • ResponseEvent                   │ │ │
│  │  │ • PrePersistEvent      • PostPersistEvent                │ │ │
│  │  │ • PreUpdateEvent       • PostUpdateEvent                 │ │ │
│  │  │ • Custom Domain Events                                   │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
└───────────────────────────────────────┬──────────────────────────────┘
                                        │
                      ┌─────────────────┼─────────────────┐
                      │                 │                 │
        ┌─────────────▼───┐  ┌──────────▼──────┐  ┌──────▼────────┐
        │   DATABASE      │  │ FILE STORAGE    │  │  CACHE LAYER  │
        │   LAYER         │  │                 │  │                │
        └─────────────────┘  └─────────────────┘  └────────────────┘
```

---

## 💾 Data Model (ERD Simplifié)

```
USER (Base utilisateur)
  │
  ├─── ROLE_ADMIN
  ├─── ROLE_PSYCHOLOGIST
  │    └─── EVENT (Crée des événements)
  │         └─── RESOURCE (Matériaux pédagogiques)
  │         └─── RESERVATION
  │              └─── WAITING_LIST
  │
  └─── ROLE_PATIENT
       ├─── PATIENT_FILE
       │    ├─── JOURNAL_EMOTIONNEL
       │    ├─── MOOD (Données d'humeur)
       │    └─── PSYCHOLOGICAL_ALERT
       │
       ├─── APPOINTMENT (Rendez-vous)
       │
       ├─── FORUM_PARTICIPATION
       │    └─── MESSAGE_FORUM
       │         └─── LIKE_MESSAGE
       │
       └─── RESERVATION (Sujets de séances)
            └─── EVENT_RESERVATION
```

### Entités principales

#### 1. **User (Utilisateurs)**
```
id (PK)
email (Unique)
password (Hash bcrypt)
firstName
lastName
roles (Array)
isActive
createdAt
updatedAt
```

#### 2. **Event (Événements)**
```
id (PK)
title
description
dateStart
dateEnd
capacity
currentReservations
createdBy (FK → User)
availableSlots
```

#### 3. **EventReservation (Réservations)**
```
id (PK)
event_id (FK)
user_id (FK)
reservationDate
status (PENDING, CONFIRMED, CANCELLED)
is_waiting_list (BOOLEAN) ← ✨ NOUVEAU
waiting_position (INT | NULL) ← ✨ NOUVEAU
```

#### 4. **PatientFile (Dossier Patient)**
```
id (PK)
patient_id (FK)
medicalHistory
allergies
treatments
notes
lastUpdated
```

#### 5. **JournalEmotionnel (Journal)**
```
id (PK)
patient_id (FK)
content
mood (1-10)
date
tags
```

#### 6. **PsychologicalAlert (Alertes)**
```
id (PK)
patient_id (FK)
severity (LOW, MEDIUM, HIGH)
description
relatedJournal_id (FK)
createdAt
resolvedAt
```

#### 7. **SujetForum (Sujets Forum)**
```
id (PK)
title
description
createdBy_id (FK)
createdAt
updatedAt
isApproved
```

#### 8. **MessageForum (Messages Forum)**
```
id (PK)
sujet_id (FK)
author_id (FK)
content
createdAt
updatedAt
isApproved
```

---

## 🔄 Flux de requête

```
1. REQUEST REÇUE
   └─ https://mindcare.com/mes-reservations

2. ROUTING
   └─ config/routes.yaml
   └─ Match: mes_reservations → ReservationController::list()

3. SECURITY CHECK
   └─ JWT Token validation
   └─ Role check (ROLE_PATIENT)
   └─ Accès refusé si unauthorized

4. CONTROLLER ACTION
   └─ ReservationController::list()
   └─ Appelle ReservationRepository::findByUser($user)

5. QUERY DATABASE
   └─ Doctrine ORM génère SQL
   └─ SELECT * FROM reservation_event 
      WHERE user_id = ? AND is_waiting_list = 0

6. FORM & VALIDATION
   └─ EventReservationType (Symfony Forms)
   └─ Validation constraints appliquées

7. RENDERING
   └─ templates/reservation/list.html.twig
   └─ Passe $reservations à Twig

8. RESPONSE
   └─ HTML généré
   └─ Assets (JS/CSS) chargés
   └─ Envoyé au client

9. FRONTEND ENHANCEMENT
   └─ Stimulus.js controllers activés
   └─ TurboJS navigation
   └─ Chart.js graphiques
```

---

## 🔐 Sécurité & Authentification

### JWT Authentication Flow
```
LOGIN REQUEST
    ↓
AuthController::login()
    ↓
Validate credentials (email + password)
    ↓
Generate JWT Token
    └─ Header: { "alg": "HS256", "typ": "JWT" }
    └─ Payload: { "user_id": 1, "email": "...", "roles": [...] }
    └─ Signature: HMAC-SHA256(secret)
    ↓
Return token to client
    ↓
CLIENT STORES TOKEN (localStorage / cookies)
    ↓
SUBSEQUENT REQUESTS include token in Authorization header
    └─ Authorization: Bearer eyJhbGc...
    ↓
LexikJWTAuthenticationBundle validates token
    ↓
Access granted to protected routes
```

### Role-Based Access Control (RBAC)
```
ROLES:
├── ROLE_ADMIN
│   ├── Gestion des utilisateurs
│   ├── Gestion des alertes
│   ├── Modération forum
│   └── Statistiques
│
├── ROLE_PSYCHOLOGIST
│   ├── Créer des événements
│   ├── Voir les réservations
│   ├── Accéder aux dossiers patients
│   └── Voir les alertes
│
├── ROLE_PATIENT
│   ├── Voir ses rendez-vous
│   ├── Réserver des événements
│   ├── Accéder à son dossier
│   ├── Forum accès
│   └── Journal émotionnel
│
└── ROLE_STUDENT
    ├── Accès limité
    └── Consultation seulement
```

---

## 📦 Intégrations externes

### 1. Twilio (SMS)
```
EVENT: Nouvelle réservation
    ↓
Messenger Message créé
    ↓
MessageHandler en background
    ↓
TwilioService::sendSMS()
    ↓
API Twilio
    ↓
SMS envoyé au patient
```

### 2. Zoom Integration
```
EVENT: Rendez-vous vidéo créé
    ↓
ZoomService::createMeeting()
    ↓
API Zoom
    ↓
URL meeting retourné
    ↓
Stored en DB + envoyé par email
```

### 3. AI Services
```
Patient inputs: Journal entry
    ↓
AIAnalysisService (HuggingFace / Groq)
    ↓
Sentiment analysis
    ↓
Result sauvegardé
    ↓
Alert créée si sentiment dangereux
```

### 4. Google Analytics
```
Application
    ↓
Google Analytics Service
    ↓
Track events: login, reservation, forum_post
    ↓
Dashboard analytics.google.com
```

### 5. Email (Gmail/SMTP)
```
EVENT: User registration
    ↓
Messenger Message
    ↓
MailerService::sendWelcomeEmail()
    ↓
Twig template rendering
    ↓
SMTP Server (Gmail / Custom)
    ↓
Email délivré
```

---

## 🚀 Cycle de déploiement

```
LOCAL DEVELOPMENT
    ↓
    ├─ npm install    (Dépendances JS)
    ├─ composer install (Dépendances PHP)
    ├─ npm run dev    (Webpack dev server)
    ├─ symfony serve  (Serveur Symfony)
    ├─ docker-compose up (DB local)
    └─ php bin/console doctrine:migrations:migrate (DB setup)
    ↓
GIT PUSH
    ↓
    ├─ git add .
    ├─ git commit -m "message"
    └─ git push origin main
    ↓
CI/CD PIPELINE (GitHub Actions)
    ↓
    ├─ Run tests
    ├─ Code quality checks
    ├─ Build Docker image
    └─ Push to registry
    ↓
PRODUCTION DEPLOYMENT
    ↓
    ├─ Docker pull latest image
    ├─ Run migrations
    ├─ Clear cache
    ├─ Warm up assets
    └─ Start container
    ↓
MONITORING
    ↓
    ├─ Error logs
    ├─ Performance metrics
    ├─ Uptime monitoring
    └─ Database backups
```

---

## 📊 Performance Optimization Tips

| Optimization | Implementation |
|--------------|-----------------|
| **Query Optimization** | Doctrine query builder avec `select()` explicite, eager loading |
| **Caching** | Redis cache, query result cache, HTTP caching headers |
| **Asset Compression** | Webpack Encore with minification, gzip compression |
| **Database Indexing** | Index sur FK, fields courants dans WHERE clauses |
| **Lazy Loading** | Doctrine lazy loading, pagination |
| **CDN** | CloudFlare, Amazon CloudFront pour static assets |
| **HTTPS/HTTP2** | Let's Encrypt SSL, enable h2 |
| **Async Jobs** | Messenger pour emails, SMS, analyses lourdes |

---

## 🔍 Monitoring & Logging

### Logs importants
```
var/log/prod.log          # Application logs
var/log/dev.log           # Development logs
Apache error.log          # Web server errors
Apache access.log         # Request log
MySQL error.log           # Database errors
```

### Key Metrics to Monitor
- Request response time
- Database query performance
- Error rate
- User activity
- Email delivery rate
- API availability

---

## 📚 Ressources Utiles

- [Symfony Documentation](https://symfony.com/doc/current/)
- [Doctrine ORM Guide](https://www.doctrine-project.org/)
- [Docker Documentation](https://docs.docker.com/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

---

**Dernière mise à jour**: May 2026
**Version**: 1.0
