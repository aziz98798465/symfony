# Documentation Application CRUD - Ressources et Commentaires
## Migration vers JavaFX

---

## 📋 Table des Matières

1. [Vue d'ensemble du système actuel](#vue-densemble-du-système-actuel)
2. [Architecture actuelle](#architecture-actuelle)
3. [Entités principales](#entités-principales)
4. [Fonctionnalités CRUD](#fonctionnalités-crud)
5. [Endpoints API/Routes](#endpoints-apiroutes)
6. [Relations entre les entités](#relations-entre-les-entités)
7. [Guide de migration JavaFX](#guide-de-migration-javafx)

---

## 🔍 Vue d'ensemble du système actuel

### Stack technologique actuel
- **Backend**: Symfony 6
- **ORM**: Doctrine
- **Base de données**: MySQL/PostgreSQL
- **Frontend**: Twig & JavaScript (Webpack)
- **Authentification**: JWT (Lexik JWT Bundle)
- **Pagination**: KnpPaginator

### Fonctionnalités principales
- Gestion des **Ressources** (Articles/Vidéos)
- Gestion des **Commentaires** sur les ressources
- Modération de contenu (OpenAI)
- Système d'authentification utilisateur
- Recherche et filtrage
- Pagination

---

## 🏗️ Architecture actuelle

```
Symfony Application
│
├── 📁 src/
│   ├── Entity/              # Modèles de données
│   │   ├── Resource.php
│   │   ├── Commentaire.php
│   │   └── User.php
│   │
│   ├── Controller/          # Contrôleurs (Logique métier)
│   │   ├── ResourceController.php
│   │   └── CommentaireController.php
│   │
│   ├── Repository/          # Access data layer
│   │   ├── ResourceRepository.php
│   │   └── CommentaireRepository.php
│   │
│   └── Service/             # Services métier
│       ├── OpenAiModerationService.php
│       └── ResourceChatbotService.php
│
├── 📁 config/
│   └── packages/            # Configuration Doctrine, JWT, etc.
│
├── 📁 templates/            # Templates Twig
│   └── resource/
│       ├── index.html.twig
│       └── show.html.twig
│
└── 📁 migrations/           # Migrations Doctrine
```

---

## 📊 Entités principales

### 1. Entity: Ressource

#### Propriétés / Champs

| Champ | Type | Validation | Description |
|-------|------|----------|-------------|
| `id` | INT | Primary Key, Auto-increment | Identifiant unique |
| `title` | VARCHAR(255) | NotBlank, Length(3-255) | Titre de la ressource |
| `description` | TEXT | NotBlank, Length(10-5000) | Description détaillée |
| `type` | VARCHAR(20) | Choice(article, video) | Type de ressource |
| `filePath` | VARCHAR(255) | Optional, URL Format | Chemin du fichier/PDF |
| `videoUrl` | VARCHAR(500) | Optional, Valid URL | Lien YouTube/Vidéo |
| `imageUrl` | VARCHAR(500) | Optional, Regex Path | URL de l'image/thumbnail |
| `createdAt` | DATETIME | Not Null | Date de création |
| `user_id` | INT | Foreign Key → User | Créateur de la ressource |

#### Relations

```
Resource (One) ←→ (Many) Commentaire
Resource (Many) ←→ (One) User
```

#### Constantes

```php
const TYPE_ARTICLE = 'article';
const TYPE_VIDEO = 'video';
```

#### Endpoints/Routes

- **INDEX**: GET `/resources` → Liste paginée avec recherche
- **SHOW**: GET `/resources/{id}` → Détail + Formulaire commentaire
- **CREATE**: POST `/resources` (admin seul)
- **UPDATE**: PUT `/resources/{id}` (admin seul)
- **DELETE**: DELETE `/resources/{id}` (admin seul)

---

### 2. Entity: Commentaire

#### Propriétés / Champs

| Champ | Type | Validation | Description |
|-------|------|----------|-------------|
| `id` | INT | Primary Key, Auto-increment | Identifiant unique |
| `resource_id` | INT | Foreign Key → Resource | Ressource commentée |
| `user_id` | INT | Foreign Key → User | Auteur du commentaire |
| `authorName` | VARCHAR(100) | NotBlank, Length(2-100), Regex | Nom de l'auteur |
| `authorEmail` | VARCHAR(180) | NotBlank, Email | Email de l'auteur |
| `content` | TEXT | NotBlank, Length(5-2000) | Contenu du commentaire |
| `rating` | INT | Range(1-5), NotNull | Note de 1 à 5 étoiles |
| `createdAt` | DATETIME | Not Null | Date de création |
| `editToken` | VARCHAR(64) | Optional | Token pour édition anonyme |
| `approved` | BOOLEAN | Default: false | Statut d'approbation (modération) |

#### Relations

```
Commentaire (Many) ←→ (One) Resource
Commentaire (Many) ←→ (One) User
```

#### Endpoints/Routes / Actions

- **CREATE**: POST sur `/resources/{id}` → Création commentaire
- **DELETE**: POST `/commentaire/{id}/delete` → Suppression (propriétaire ou admin)
- **EDIT**: POST `/commentaire/{id}/edit` (à implémenter)
- **APPROVE**: POST `/admin/commentaire/{id}/approve` (admin)

---

## 🔄 Fonctionnalités CRUD

### Ressource CRUD

#### ✅ CREATE - Créer une ressource

**Contexte**: Admin seulement

**Données requises**:
```json
{
  "title": "Mon Article de Santé",
  "description": "Description réelle de minimum 10 caractères...",
  "type": "article|video",
  "filePath": "/uploads/document.pdf",
  "videoUrl": "https://www.youtube.com/watch?v=xxxxx",
  "imageUrl": "https://exemple.com/image.jpg",
  "user_id": 1
}
```

**Validation serveur**:
- Titre: 3-255 caractères, obligatoire
- Description: 10-5000 caractères, obligatoire
- Type: article ou video uniquement
- VideoUrl: URL valide si fournie
- ImageUrl: Regex `/^(https?:\/\/|\/uploads\/).+/`

**Résultat**: Création en BD, redirection vers la ressource

---

#### ✅ READ - Lire/Afficher les ressources

**LIST RESOURCES** (Avec recherche)
```
GET /resources?q=mental&page=1
Résultat: Affichage paginé (6 par page)
       Recherche dans title ET description
```

**SHOW RESOURCE DETAIL**
```
GET /resources/{id}
Inclut:
  - Infos ressource
  - Tous les commentaires approuvés
  - Formulaire de commentaire (si user connecté)
```

---

#### ✅ UPDATE - Modifier une ressource

**Contexte**: Admin seulement

**Données modifiables**:
- title
- description
- type
- filePath
- videoUrl
- imageUrl

**Flux**:
1. Récupérer la ressource: GET `/resources/{id}/edit`
2. Soumettre changements: PUT `/resources/{id}`

**Validation**: Même que CREATE

---

#### ✅ DELETE - Supprimer une ressource

**Contexte**: Admin seulement

**Flux**:
1. POST `/resources/{id}/delete`
2. Supprime la ressource ET tous ses commentaires (orphanRemoval: true)

---

### Commentaire CRUD

#### ✅ CREATE - Ajouter un commentaire

**Contexte**: User connecté seulement

**Données requises**:
```json
{
  "resource_id": 1,
  "authorName": "Jean Dupont",
  "authorEmail": "jean@example.com",
  "content": "Commentaire constructif avec minimum 5 caractères...",
  "rating": 4,
  "user_id": 2
}
```

**Validation serveur**:
- authorName: 2-100 caractères, regex unicode
- authorEmail: Format email valide
- content: 5-2000 caractères, modération OpenAI
- rating: 1-5, obligatoire
- resource_id: Doit exister

**Modération**: Si OpenAI configured, vérifie le contenu pour:
- Spam
- Contenu offensant
- Langage abusif

---

#### ✅ READ - Afficher les commentaires

**Sur la page de ressource**:
```
GET /resources/{id}
Affiche tous les commentaires approuvés liés à la ressource
Tri: Récents en premier
```

---

#### ✅ UPDATE - Modifier un commentaire

**Contexte**: Propriétaire du commentaire OU admin

**Données modifiables**:
- authorName
- authorEmail
- content
- rating

**Endpoint** (à implémenter):
```
PUT /commentaire/{id}/edit
```

---

#### ✅ DELETE - Supprimer un commentaire

**Contexte**: Propriétaire OU admin

**Flux**:
```
POST /commentaire/{id}/delete
  ↓
Vérification CSRF token
  ↓
Vérification propriétaire ou ROLE_ADMIN
  ↓
S'il est valide: Suppression
Redirection: Vers la ressource parente ou index
```

---

## 🌐 Endpoints API / Routes

### RESSOURCE Routes

```
┌─────────────────────────────────────────────────────┐
│              RESSOURCE ENDPOINTS                    │
├──────────────┬──────────┬────────────────────────────┤
│ Route        │ Méthode  │ Rôle requis               │
├──────────────┼──────────┼────────────────────────────┤
│ /resources   │ GET      │ Public (Anonyme OK)       │
│ /resources   │ POST     │ ROLE_ADMIN                │
│ /resources/1 │ GET      │ Public                    │
│ /resources/1 │ PUT/POST │ ROLE_ADMIN                │
│ /resources/1 │ DELETE   │ ROLE_ADMIN                │
└──────────────┴──────────┴────────────────────────────┘
```

### COMMENTAIRE Routes

```
┌──────────────────────────────────────────────────────┐
│            COMMENTAIRE ENDPOINTS                     │
├──────────────────────┬──────────┬──────────────────────┤
│ Route                │ Méthode  │ Rôle requis          │
├──────────────────────┼──────────┼──────────────────────┤
│ /commentaire/1/delete│ POST     │ Propriétaire/ADMIN   │
│ /commentaire/1/edit  │ POST     │ Propriétaire/ADMIN   │
│ /admin/commentaire   │ GET      │ ROLE_ADMIN           │
│ /admin/commentaire/1 │ PUT/POST │ ROLE_ADMIN (approve) │
└──────────────────────┴──────────┴──────────────────────┘
```

---

## 🔗 Relations entre les entités

### Diagramme ER

```
┌─────────────────────┐
│      User           │
├─────────────────────┤
│ id (PK)            │
│ email              │
│ firstName          │
│ lastName           │
│ roles[]            │
└─────────────────────┘
       ▲     ▲
       │ 1   │ 1
       │     │
       │     │ creates
       │     │
    │  │  │  │
    │  │  │  │
    │  │  │  └───────────┐
    │  │  │               │
    │  │  │  ┌─────────────────────┐
    │  │  │  │     Resource        │
    │  │  │  ├─────────────────────┤
    │  │  └──┤ id (PK)            │
    │  │     │ title              │
    │  │     │ description        │
    │  │     │ type               │
    │  │     │ videoUrl           │
    │  │     │ imageUrl           │
    │  │     │ createdAt          │
    │  │     │ user_id (FK)       │
    │  │     └─────────────────────┘
    │  │             │
    │  │             │ 1
    │  │             │
    │  │             │ N
    │  │             │
    │  │     ┌─────────────────────┐
    │  │     │   Commentaire       │
    │  └─────┤─────────────────────┤
    │        │ id (PK)            │
    │        │ resource_id (FK)   │
    │        │ user_id (FK) ──────┘
    │        │ authorName         │
    │        │ authorEmail        │
    │        │ content            │
    │        │ rating             │
    │        │ createdAt          │
    │        │ approved           │
    └────────┤ editToken          │
             └─────────────────────┘
```

### Relations Doctrine

**Resource → Commentaire**
```php
#[ORM\OneToMany(
    mappedBy: 'resource',
    targetEntity: Commentaire::class,
    orphanRemoval: true  // Supprime les commentaires si la resource est supprimée
)]
private Collection $commentaires;
```

**Commentaire → Resource**
```php
#[ORM\ManyToOne(inversedBy: 'commentaires')]
#[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
private ?Resource $resource = null;
```

---

## 🎯 Guide de migration JavaFX

### Phase 1: Préparation

#### 1.1 Analyser les données

**Base de données MySQL → JDBC Connection**

```sql
-- Tables à inclure
SELECT * FROM resource;
SELECT * FROM commentaire;
SELECT * FROM `user`;
```

#### 1.2 Dépendances Maven recommandées

```xml
<!-- JDK: 17+ -->
<!-- JavaFX SDK: 21 LTS -->
<!-- JDBC Driver: mysql-connector-java:8.0+ -->
<!-- ORM Alternative: Hibernate/JPA -->
```

---

### Phase 2: Architecture JavaFX

```
JavaFX Application
│
├── 📁 src/main/java/com/app/
│   │
│   ├── model/
│   │   ├── Resource.java
│   │   ├── Commentaire.java
│   │   └── User.java
│   │
│   ├── dao/                    # Data Access Objects (remplace Repository)
│   │   ├── ResourceDAO.java
│   │   ├── CommentaireDAO.java
│   │   └── DatabaseConnection.java
│   │
│   ├── service/                # Business Logic
│   │   ├── ResourceService.java
│   │   ├── CommentaireService.java
│   │   └── ModerationService.java
│   │
│   ├── controller/             # FXML Controllers
│   │   ├── ResourceListController.java
│   │   ├── ResourceDetailController.java
│   │   ├── CommentaireFormController.java
│   │   └── AdminPanelController.java
│   │
│   └── App.java               # Main Application
│
├── 📁 src/main/resources/
│   ├── com/app/views/         # FXML Layouts
│   │   ├── resource_list.fxml
│   │   ├── resource_detail.fxml
│   │   └── comment_form.fxml
│   │
│   └── com/app/styles/        # CSS
│       └── style.css
│
└── pom.xml
```

---

### Phase 3: Modèles de données

#### 3.1 Classe Resource

```java
package com.app.model;

import java.time.LocalDateTime;

public class Resource {
    public static final String TYPE_ARTICLE = "article";
    public static final String TYPE_VIDEO = "video";
    
    private int id;
    private String title;
    private String description;
    private String type;
    private String filePath;
    private String videoUrl;
    private String imageUrl;
    private LocalDateTime createdAt;
    private int userId;
    
    // Constructeurs
    public Resource() {}
    
    public Resource(String title, String description, String type, int userId) {
        this.title = title;
        this.description = description;
        this.type = type;
        this.userId = userId;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    // ... autres getters/setters
}
```

#### 3.2 Classe Commentaire

```java
package com.app.model;

import java.time.LocalDateTime;

public class Commentaire {
    private int id;
    private int resourceId;
    private int userId;
    private String authorName;
    private String authorEmail;
    private String content;
    private int rating;         // 1-5
    private LocalDateTime createdAt;
    private boolean approved;
    
    // Constructeurs
    public Commentaire() {}
    
    public Commentaire(int resourceId, String authorName, String authorEmail, 
                       String content, int rating, int userId) {
        this.resourceId = resourceId;
        this.authorName = authorName;
        this.authorEmail = authorEmail;
        this.content = content;
        this.rating = rating;
        this.userId = userId;
        this.createdAt = LocalDateTime.now();
        this.approved = false;
    }
    
    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    // ... autres getters/setters
}
```

---

### Phase 4: Data Access Layer (DAO)

#### 4.1 Base de connexion

```java
package com.app.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/nom_base";
    private static final String USER = "root";
    private static final String PASSWORD = "";
    private static Connection connection;
    
    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
        }
        return connection;
    }
}
```

#### 4.2 ResourceDAO

```java
package com.app.dao;

import com.app.model.Resource;
import java.sql.*;
import java.util.*;

public class ResourceDAO {
    
    // CREATE
    public void create(Resource resource) throws SQLException {
        String sql = "INSERT INTO resource (title, description, type, file_path, video_url, image_url, created_at, id_user) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, resource.getTitle());
            stmt.setString(2, resource.getDescription());
            stmt.setString(3, resource.getType());
            stmt.setString(4, resource.getFilePath());
            stmt.setString(5, resource.getVideoUrl());
            stmt.setString(6, resource.getImageUrl());
            stmt.setInt(7, resource.getUserId());
            
            stmt.executeUpdate();
            
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    resource.setId(keys.getInt(1));
                }
            }
        }
    }
    
    // READ - Get all
    public List<Resource> findAll() throws SQLException {
        List<Resource> resources = new ArrayList<>();
        String sql = "SELECT * FROM resource ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                resources.add(mapRowToResource(rs));
            }
        }
        return resources;
    }
    
    // READ - Get by ID
    public Resource findById(int id) throws SQLException {
        String sql = "SELECT * FROM resource WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToResource(rs);
                }
            }
        }
        return null;
    }
    
    // UPDATE
    public void update(Resource resource) throws SQLException {
        String sql = "UPDATE resource SET title = ?, description = ?, type = ?, file_path = ?, " +
                     "video_url = ?, image_url = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, resource.getTitle());
            stmt.setString(2, resource.getDescription());
            stmt.setString(3, resource.getType());
            stmt.setString(4, resource.getFilePath());
            stmt.setString(5, resource.getVideoUrl());
            stmt.setString(6, resource.getImageUrl());
            stmt.setInt(7, resource.getId());
            
            stmt.executeUpdate();
        }
    }
    
    // DELETE
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM resource WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }
    
    // SEARCH
    public List<Resource> search(String query) throws SQLException {
        List<Resource> resources = new ArrayList<>();
        String sql = "SELECT * FROM resource WHERE LOWER(title) LIKE ? OR LOWER(description) LIKE ? " +
                     "ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + query.toLowerCase() + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    resources.add(mapRowToResource(rs));
                }
            }
        }
        return resources;
    }
    
    // Helper
    private Resource mapRowToResource(ResultSet rs) throws SQLException {
        Resource resource = new Resource();
        resource.setId(rs.getInt("id"));
        resource.setTitle(rs.getString("title"));
        resource.setDescription(rs.getString("description"));
        resource.setType(rs.getString("type"));
        resource.setFilePath(rs.getString("file_path"));
        resource.setVideoUrl(rs.getString("video_url"));
        resource.setImageUrl(rs.getString("image_url"));
        resource.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        resource.setUserId(rs.getInt("id_user"));
        return resource;
    }
}
```

#### 4.3 CommentaireDAO

```java
package com.app.dao;

import com.app.model.Commentaire;
import java.sql.*;
import java.util.*;

public class CommentaireDAO {
    
    // CREATE
    public void create(Commentaire commentaire) throws SQLException {
        String sql = "INSERT INTO commentaire (id_resource, id_user, author_name, author_email, content, rating, created_at, approved) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, commentaire.getResourceId());
            stmt.setInt(2, commentaire.getUserId());
            stmt.setString(3, commentaire.getAuthorName());
            stmt.setString(4, commentaire.getAuthorEmail());
            stmt.setString(5, commentaire.getContent());
            stmt.setInt(6, commentaire.getRating());
            stmt.setBoolean(7, commentaire.isApproved());
            
            stmt.executeUpdate();
            
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    commentaire.setId(keys.getInt(1));
                }
            }
        }
    }
    
    // READ - By Resource ID
    public List<Commentaire> findByResourceId(int resourceId) throws SQLException {
        List<Commentaire> commentaires = new ArrayList<>();
        String sql = "SELECT * FROM commentaire WHERE id_resource = ? AND approved = true ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, resourceId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    commentaires.add(mapRowToCommentaire(rs));
                }
            }
        }
        return commentaires;
    }
    
    // READ - By ID
    public Commentaire findById(int id) throws SQLException {
        String sql = "SELECT * FROM commentaire WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToCommentaire(rs);
                }
            }
        }
        return null;
    }
    
    // UPDATE
    public void update(Commentaire commentaire) throws SQLException {
        String sql = "UPDATE commentaire SET author_name = ?, author_email = ?, content = ?, rating = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, commentaire.getAuthorName());
            stmt.setString(2, commentaire.getAuthorEmail());
            stmt.setString(3, commentaire.getContent());
            stmt.setInt(4, commentaire.getRating());
            stmt.setInt(5, commentaire.getId());
            
            stmt.executeUpdate();
        }
    }
    
    // DELETE
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM commentaire WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }
    
    // APPROVE (Admin)
    public void approve(int id) throws SQLException {
        String sql = "UPDATE commentaire SET approved = true WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }
    
    // Helper
    private Commentaire mapRowToCommentaire(ResultSet rs) throws SQLException {
        Commentaire commentaire = new Commentaire();
        commentaire.setId(rs.getInt("id"));
        commentaire.setResourceId(rs.getInt("id_resource"));
        commentaire.setUserId(rs.getInt("id_user"));
        commentaire.setAuthorName(rs.getString("author_name"));
        commentaire.setAuthorEmail(rs.getString("author_email"));
        commentaire.setContent(rs.getString("content"));
        commentaire.setRating(rs.getInt("rating"));
        commentaire.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        commentaire.setApproved(rs.getBoolean("approved"));
        return commentaire;
    }
}
```

---

### Phase 5: Services métier

```java
package com.app.service;

import com.app.dao.ResourceDAO;
import com.app.dao.CommentaireDAO;
import com.app.model.Resource;
import com.app.model.Commentaire;
import java.sql.SQLException;
import java.util.List;

public class ResourceService {
    private ResourceDAO resourceDAO = new ResourceDAO();
    private CommentaireDAO commentaireDAO = new CommentaireDAO();
    
    // Validation
    private void validateResource(Resource resource) throws IllegalArgumentException {
        if (resource.getTitle() == null || resource.getTitle().length() < 3) {
            throw new IllegalArgumentException("Titre invalide (3-255 caractères)");
        }
        if (resource.getDescription() == null || resource.getDescription().length() < 10) {
            throw new IllegalArgumentException("Description invalide (10-5000 caractères)");
        }
        if (!resource.getType().equals(Resource.TYPE_ARTICLE) && 
            !resource.getType().equals(Resource.TYPE_VIDEO)) {
            throw new IllegalArgumentException("Type invalide");
        }
    }
    
    public void createResource(Resource resource) throws SQLException, IllegalArgumentException {
        validateResource(resource);
        resourceDAO.create(resource);
    }
    
    public List<Resource> getAllResources() throws SQLException {
        return resourceDAO.findAll();
    }
    
    public Resource getResourceById(int id) throws SQLException {
        return resourceDAO.findById(id);
    }
    
    public void updateResource(Resource resource) throws SQLException, IllegalArgumentException {
        validateResource(resource);
        resourceDAO.update(resource);
    }
    
    public void deleteResource(int id) throws SQLException {
        // Supprime les commentaires associés
        List<Commentaire> comments = commentaireDAO.findByResourceId(id);
        for (Commentaire c : comments) {
            commentaireDAO.delete(c.getId());
        }
        resourceDAO.delete(id);
    }
    
    public List<Resource> searchResources(String query) throws SQLException {
        return resourceDAO.search(query);
    }
}
```

---

### Phase 6: Controllers JavaFX (FXML)

#### 6.1 ResourceListController.java

```java
package com.app.controller;

import com.app.model.Resource;
import com.app.service.ResourceService;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import java.sql.SQLException;
import java.util.List;

public class ResourceListController {
    @FXML private TextField searchField;
    @FXML private TableView<Resource> resourceTable;
    @FXML private TableColumn<Resource, Integer> idColumn;
    @FXML private TableColumn<Resource, String> titleColumn;
    @FXML private TableColumn<Resource, String> typeColumn;
    @FXML private Button newResourceBtn;
    @FXML private Button deleteBtn;
    
    private ResourceService resourceService = new ResourceService();
    private ObservableList<Resource> resourceList;
    
    @FXML
    public void initialize() {
        setupTableColumns();
        loadResources();
        
        searchField.textProperty().addListener((obs, oldVal, newVal) -> {
            try {
                searchResources(newVal);
            } catch (SQLException e) {
                showError("Erreur de recherche: " + e.getMessage());
            }
        });
    }
    
    private void setupTableColumns() {
        idColumn.setCellValueFactory(cellData -> 
            javafx.beans.binding.Bindings.createObjectBinding(() -> cellData.getValue().getId()));
        titleColumn.setCellValueFactory(cellData -> 
            javafx.beans.binding.Bindings.createObjectBinding(() -> cellData.getValue().getTitle()));
        typeColumn.setCellValueFactory(cellData -> 
            javafx.beans.binding.Bindings.createObjectBinding(() -> cellData.getValue().getType()));
    }
    
    private void loadResources() {
        try {
            List<Resource> resources = resourceService.getAllResources();
            resourceList = FXCollections.observableArrayList(resources);
            resourceTable.setItems(resourceList);
        } catch (SQLException e) {
            showError("Erreur lors du chargement: " + e.getMessage());
        }
    }
    
    private void searchResources(String query) throws SQLException {
        if (query.isEmpty()) {
            loadResources();
        } else {
            List<Resource> resources = resourceService.searchResources(query);
            resourceList = FXCollections.observableArrayList(resources);
            resourceTable.setItems(resourceList);
        }
    }
    
    @FXML
    private void handleNewResource() {
        // Ouvrir fenêtre édition
        openResourceEditWindow(null);
    }
    
    @FXML
    private void handleDeleteResource() {
        Resource selected = resourceTable.getSelectionModel().getSelectedItem();
        if (selected == null) {
            showWarning("Sélectionnez une ressource à supprimer");
            return;
        }
        
        if (confirmDelete()) {
            try {
                resourceService.deleteResource(selected.getId());
                loadResources();
                showInfo("Ressource supprimée");
            } catch (SQLException e) {
                showError("Erreur suppression: " + e.getMessage());
            }
        }
    }
    
    private void openResourceEditWindow(Resource resource) {
        // Implémenter fenêtre d'édition modal
    }
    
    private void showError(String message) {
        Alert alert = new Alert(Alert.AlertType.ERROR);
        alert.setTitle("Erreur");
        alert.setContentText(message);
        alert.showAndWait();
    }
    
    private void showInfo(String message) {
        Alert alert = new Alert(Alert.AlertType.INFORMATION);
        alert.setTitle("Succès");
        alert.setContentText(message);
        alert.showAndWait();
    }
    
    private void showWarning(String message) {
        Alert alert = new Alert(Alert.AlertType.WARNING);
        alert.setTitle("Attention");
        alert.setContentText(message);
        alert.showAndWait();
    }
    
    private boolean confirmDelete() {
        Alert alert = new Alert(Alert.AlertType.CONFIRMATION);
        alert.setTitle("Confirmer la suppression");
        alert.setContentText("Êtes-vous sûr? Les commentaires associés seront aussi supprimés.");
        return alert.showAndWait().filter(response -> response == ButtonType.OK).isPresent();
    }
}
```

---

### Phase 7: FXML Layouts

#### 7.1 resource_list.fxml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?import javafx.geometry.*?>
<?import javafx.scene.control.*?>
<?import javafx.scene.layout.*?>

<VBox xmlns="http://javafx.com/javafx/17" xmlns:fx="http://javafx.com/fxml/1" 
      fx:controller="com.app.controller.ResourceListController" spacing="10" padding="15">
    
    <HBox spacing="10">
        <TextField fx:id="searchField" promptText="Rechercher..." HBox.hgrow="ALWAYS"/>
        <Button fx:id="newResourceBtn" text="+ Nouvelle Ressource" onAction="#handleNewResource"/>
    </HBox>
    
    <TableView fx:id="resourceTable" VBox.vgrow="ALWAYS">
        <columns>
            <TableColumn fx:id="idColumn" text="ID" prefWidth="50"/>
            <TableColumn fx:id="titleColumn" text="Titre" prefWidth="300"/>
            <TableColumn fx:id="typeColumn" text="Type" prefWidth="100"/>
        </columns>
    </TableView>
    
    <HBox spacing="10">
        <Button fx:id="deleteBtn" text="Supprimer" onAction="#handleDeleteResource" style="-fx-text-fill: white; -fx-background-color: #dc3545;"/>
    </HBox>
</VBox>
```

---

### 📝 Checklist de migration

- [ ] **Préparation**
  - [ ] Exporter schéma DB
  - [ ] Configurer JDBC
  - [ ] Ajouter dépendances Maven

- [ ] **Phase modèles**
  - [ ] Créer `Resource.java`
  - [ ] Créer `Commentaire.java`
  - [ ] Créer `User.java`

- [ ] **Phase DAO**
  - [ ] `DatabaseConnection.java`
  - [ ] `ResourceDAO.java` (CRUD complet)
  - [ ] `CommentaireDAO.java` (CRUD complet)

- [ ] **Phase Services**
  - [ ] `ResourceService.java` (validation + métier)
  - [ ] `CommentaireService.java` (validation + métier)

- [ ] **Phase UI**
  - [ ] `ResourceListController.java`
  - [ ] `ResourceDetailController.java`
  - [ ] `CommentaireFormController.java`
  - [ ] FXML layouts

- [ ] **Tests**
  - [ ] Tester CRUD Ressource
  - [ ] Tester CRUD Commentaire
  - [ ] Tester recherche
  - [ ] Tester suppression cascade

---

## 📚 Références utiles

### Frameworks et outils
- **JavaFX**: https://openjfx.io/
- **Maven**: https://maven.apache.org/
- **JDBC**: https://docs.oracle.com/javase/tutorial/jdbc/
- **MySQL Connector**: https://dev.mysql.com/downloads/connector/

### Best Practices
- Modèle MVC/DAO pour séparation des responsabilités
- Utiliser des `PreparedStatement` pour sécurité SQL
- Paginer les résultats larges
- Valider les données côté serveur
- Gérer les exceptions proprement

---

## 📧 Contact & Support

Pour questions sur cette documentation, consultez le code Symfony original:
- **Controllers**: `src/Controller/ResourceController.php`, `src/Controller/CommentaireController.php`
- **Entities**: `src/Entity/Resource.php`, `src/Entity/Commentaire.php`
- **Repositories**: `src/Repository/ResourceRepository.php`, `src/Repository/CommentaireRepository.php`

---

**Généré le**: 13 Avril 2026  
**Version**: 1.0  
**Statut**: Prêt pour migration JavaFX
