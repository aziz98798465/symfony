# 📖 MindCare - Vue d'ensemble du projet

**Date**: Mai 2026 | **Statut**: Production-Ready | **Version**: 1.0.0

---

## 🎯 Qu'est-ce que MindCare?

**MindCare** est une plateforme web complète de **gestion de cabinet médical et suivi psychologique**. C'est un système SaaS (Software as a Service) que les psychologues peuvent utiliser pour gérer leurs patients, leurs rendez-vous, et offrir un suivi psychologique avancé.

### Cas d'usage principales
- **Psychologues**: Créer des événements, voir leurs patients, recevoir des alertes psychologiques
- **Patients**: Réserver des rendez-vous, tenir un journal émotionnel, accéder à leur dossier médical
- **Administrateurs**: Gérer les utilisateurs, les alertes, modérer le forum
- **Forum**: Communauté de soutien entre patients

---

## 🏢 Contexte Organisationnel

### Parties prenantes
| Rôle | Description | Accès |
|------|-------------|-------|
| **Psychologues** | Créateurs de contenu, gestionnaires de patients | Dashboard psychologue |
| **Patients** | Utilisateurs finaux, consommateurs de services | Dashboard patient |
| **Administrateurs** | Modérateurs, superviseurs système | Panel admin |
| **Développeurs** | Maintenance, nouvelles features | GitHub, Staging env |

### Statistiques du projet
- **Entités**: 16 modèles de données
- **Contrôleurs**: 27 contrôleurs
- **Routes**: 100+ endpoints
- **Templates**: 40+ templates Twig
- **Dépendances PHP**: 50+
- **Dépendances JS**: 10+

---

## 🛠️ Stack Technologique (Vue d'ensemble)

```
FRONTEND
├── Twig (Templates HTML)
├── Stimulus.js (Interactivité légère)
├── TurboJS (Navigation SPA)
├── Chart.js (Graphiques)
├── Bootstrap 5 (CSS framework)
└── Webpack (Bundler assets)

BACKEND
├── Symfony 6.4 (Framework web)
├── PHP 8.2 (Langage serveur)
├── Doctrine ORM (Object-Relational Mapping)
├── Messenger (Async jobs)
├── Security (JWT Auth + RBAC)
└── Form Builder (Validation)

DATABASE
├── MariaDB 10.4 (Base de données)
├── 16 Tables relationnelles
└── Doctrine Migrations (Schema versioning)

INFRASTRUCTURE
├── Docker (Containerization)
├── Apache/Nginx (Web server)
├── Git/GitHub (Version control)
└── CI/CD (GitHub Actions)

INTEGRATIONS EXTERNES
├── Twilio (SMS notifications)
├── Zoom (Video conferencing)
├── HuggingFace (AI sentiment analysis)
├── Groq (LLM for chatbot)
├── Google Analytics (Tracking)
└── Gmail (Email sending)
```

---

## 📊 Architecture applicative

### Flux d'une requête utilisateur
```
1. Client (Browser) → HTTPS Request
2. Load Balancer/CDN
3. Web Server (Apache/Nginx)
4. Symfony Router
5. Security Layer (JWT validation + RBAC)
6. Controller + Business Logic
7. Doctrine ORM → SQL Query
8. Database (MariaDB)
9. Response + Template Rendering
10. Assets (JS/CSS compiled)
11. Back to Client (HTML + Assets)
```

### Couches applicatives

#### Couche Présentation
- **Frontend**: Twig templates + Stimulus.js interactivity
- **API**: JSON endpoints pour SPA/Mobile
- **Assets**: CSS compilé, JavaScript bundlé

#### Couche Métier
- **Controllers**: Gestion des requêtes HTTP
- **Services**: Logique métier découplée
- **Forms**: Validation et transformation données
- **Security**: Authentification JWT + Autorisation

#### Couche Données
- **Entities**: Modèles Doctrine
- **Repositories**: Requêtes personnalisées
- **Migrations**: Versioning du schéma
- **Database**: MariaDB tables relationnelles

---

## 📦 Composants principaux

### 1. Authentification & Sécurité
```
Entry Point → JWT Token Validation → User Loading → Role Checking → Access Control
   │                 │                    │                │              │
 /login         LexikJWT          Security User       RBAC              Allow/Deny
              Token Generator      Manager             Matrix
```

### 2. Gestion des réservations
```
Event (Psychologue crée) 
  ↓
Capacity limit
  ↓
User reserves
  ↓
If full → Waiting list (is_waiting_list = 1)
  ↓
If slot freed → Auto-move from waitlist
```

### 3. Suivi psychologique
```
Patient behavior
  ↓
Journal entry / Mood tracking
  ↓
AI Analysis (HuggingFace/Groq)
  ↓
Sentiment detection
  ↓
Alert if concerning → Notification to Psychologist
```

### 4. Système d'alertes
```
Critical Event Detected
  ↓
Messenger Message Created
  ↓
Handler processes async
  ↓
Email to Psychologist
  ↓
SMS via Twilio
  ↓
Platform Notification
```

---

## 🗄️ Modèle de données simplifié

```
User (Utilisateur - Base)
├── Email, Password (Auth)
├── Roles: ADMIN, PSYCHOLOGIST, PATIENT, STUDENT
└── Profile: Name, Avatar, Bio

Psychologist (extends User)
├── SpecializationAreas
├── ExperienceYears
└── Available Slots

Patient (extends User)
├── PatientFile
├── MedicalHistory
├── Treatments
└── Allergies

Event (Événement)
├── Created by: Psychologist
├── Title, Description
├── DateTime
├── Capacity
└── Reservations[]

EventReservation (Réservation)
├── Event reference
├── User reference
├── Status: PENDING, CONFIRMED, CANCELLED
├── is_waiting_list: Boolean
└── waiting_position: Integer

PatientFile (Dossier)
├── Patient reference
├── JournalEntries[]
├── Moods[]
├── Alerts[]
└── Documents[]

JournalEmotionnel (Journal)
├── Patient reference
├── Content, Date
├── Mood (1-10 scale)
└── Tags

PsychologicalAlert (Alerte)
├── Patient reference
├── Severity: LOW, MEDIUM, HIGH
├── Description
└── Resolved flag

SujetForum (Sujet Forum)
├── Title, Description
├── Created by: User
├── Messages[]
└── IsApproved: Boolean

MessageForum (Message Forum)
├── SujetForum reference
├── Author reference
├── Content, Date
└── Likes[]
```

---

## 🔐 Flux d'authentification

```
┌─────────────────────────────────────────┐
│ USER VISITS /login                      │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│ SUBMIT CREDENTIALS (email, password)    │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│ AuthController::login()                 │
│ - Validate email exists                 │
│ - Check password (bcrypt)               │
└──────────────────┬──────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
    ✅ VALID            ❌ INVALID
        │                     │
   ┌────▼─────┐         ┌────▼──────┐
   │ Generate  │         │ Return    │
   │ JWT Token │         │ 401 Error │
   │ (Signed)  │         └───────────┘
   └────┬─────┘
        │
   ┌────▼─────────────────────┐
   │ Return JWT to client      │
   │ (localStorage/cookie)     │
   └────┬─────────────────────┘
        │
   ┌────▼──────────────────────────┐
   │ CLIENT STORES TOKEN           │
   │ Authorization: Bearer TOKEN   │
   └────┬──────────────────────────┘
        │
   ┌────▼────────────────────────────────┐
   │ NEXT REQUEST includes JWT           │
   │ LexikJWTAuthenticationBundle        │
   │ - Validates signature (HMAC-SHA256) │
   │ - Extracts user_id and roles        │
   │ - Loads User from database          │
   └────┬─────────────────────────────────┘
        │
   ┌────▼─────────┐
   │ ACCESS GRANT │
   │ or DENIED    │
   └──────────────┘
```

---

## 🚀 Déploiement (Options)

| Option | Pros | Cons |
|--------|------|------|
| **Docker** | Reproductibilité, Scalable, Microservices | Courbe apprentissage |
| **VPS/Serveur** | Control total, Pas cher | Maintenance, Scaling difficile |
| **PaaS** (Heroku, Railway) | Déploiement facile | Cher, Vendor lock-in |
| **Kubernetes** | High-availability, Auto-scaling | Complexité, Overkill pour PME |

### Déploiement recommandé
```
GitHub (Source de vérité)
    ↓ (push main branch)
GitHub Actions (CI/CD Pipeline)
    ├─ Run tests
    ├─ Build Docker image
    └─ Push to Docker Registry
        ↓
Docker Registry
    ↓ (pull image)
Production Server
    └─ Run container + migrations
```

---

## 📈 Croissance future

### Features planifiées
- [ ] Mobile app (React Native)
- [ ] Video consultation intégrée
- [ ] Payment integration (Stripe)
- [ ] Analytics avancés
- [ ] ML-based recommendations
- [ ] Multi-language support
- [ ] HIPAA compliance

### Scaling strategy
```
Niveau 1 (Actuellement)
├── Monolithic Symfony app
├── Single MariaDB
└── Single server

Niveau 2 (Futur)
├── Microservices (API + Worker)
├── Database replication
├── Redis cache layer
└── Load balancer

Niveau 3 (Scalabilité max)
├── Kubernetes orchestration
├── Auto-scaling pods
├── Distributed database
└── CDN for assets
```

---

## 📚 Documentation

| Document | Contenu |
|----------|---------|
| **DEPLOYMENT_GUIDE.md** | Guide complet de déploiement production |
| **ARCHITECTURE.md** | Architecture détaillée + diagrammes |
| **QUICKSTART.md** | Setup local + développement |
| **PROJECT_OVERVIEW.md** | Ce document (vue d'ensemble) |

---

## 🎓 Principes de développement

### Clean Code
```php
// ✅ BON - Classes/Methods avec responsabilité unique
class ReservationService
{
    public function createReservation(User $user, Event $event): EventReservation
    {
        // Une seule responsabilité: créer une réservation
    }
}

// ❌ MAUVAIS - Dieu classe (fait trop)
class ReservationManager
{
    public function handleEverything() { ... }
}
```

### DRY (Don't Repeat Yourself)
```php
// ✅ BON - Code réutilisable
private function sendNotification(User $user, string $message): void
{
    // Utilisé par: Email, SMS, Push notifications
}

// ❌ MAUVAIS - Duplication
public function sendEmail(...) { ... }
public function sendSMS(...) { ... }
public function sendPush(...) { ... }
// (Même logique répétée)
```

### SOLID Principles
- **Single Responsibility**: Chaque classe une raison de changer
- **Open/Closed**: Ouvert pour extension, fermé pour modification
- **Liskov Substitution**: Sous-classes remplaçables par parent
- **Interface Segregation**: Clients ne dépendent que du nécessaire
- **Dependency Inversion**: Dépendre d'abstractions, pas implémentations

---

## 🔄 Workflow de développement

```
1. Créer une branche
   git checkout -b feature/ma-feature

2. Développer + Tester
   - Écrire le code
   - Exécuter php bin/console lint:*
   - Tests unitaires
   - Tests manuels

3. Commit + Push
   git add .
   git commit -m "feat: Ajouter ma feature"
   git push origin feature/ma-feature

4. Pull Request
   - Créer PR sur GitHub
   - Revue de code
   - Approbation

5. Merge
   - Merge to main
   - Déclenche CI/CD

6. Deploy
   - Image Docker buildée
   - Déployée en production
   - Migrations runées
```

---

## 📞 Support & Maintenance

### Heures d'affaires
- 📅 Lun-Ven: 9h-17h
- 📞 Email: support@mindcare.com
- 🐛 Issues: GitHub Issues

### SLA (Service Level Agreement)
| Sévérité | Temps de réponse | Temps de résolution |
|----------|------------------|-------------------|
| Critical | 30 min | 4h |
| High | 2h | 8h |
| Medium | 8h | 24h |
| Low | 24h | 48h |

---

## 📊 Monitoring & Métriques

### Métriques clés
```
Performance
├── Response time < 200ms
├── Database queries < 50ms
└── Asset load < 100ms

Availability
├── Uptime > 99.5%
├── Error rate < 0.1%
└── API availability > 99%

User Experience
├── Page load < 3s
├── User retention > 70%
└── Crash rate < 0.5%
```

### Alertes activées
- Database down
- High error rate (> 5%)
- High memory usage (> 80%)
- Slow queries (> 1s)
- Server unresponsive

---

## 🎉 Conclusion

MindCare est une application **production-ready**, **scalable**, et **secure** conçue pour moderniser les soins psychologiques. Avec son architecture en couches, ses intégrations externes, et sa gestion d'authentification robuste, elle offre une plateforme complète pour les psychologues et leurs patients.

### Points forts
✅ Architecture propre et maintenable
✅ Stack technologique moderne
✅ Sécurité multi-couches
✅ Scalable et performante
✅ Bien documentée
✅ Prête pour production

### Prochaines étapes
1. Consulter **QUICKSTART.md** pour setup local
2. Lire **ARCHITECTURE.md** pour comprendre le design
3. Voir **DEPLOYMENT_GUIDE.md** pour produire

---

**Dernière mise à jour**: Mai 2026
**Mainteneur**: Aziz (GitHub: @aziz98798465)
**Repository**: https://github.com/aziz98798465/symfony
**Licence**: Propriétaire
