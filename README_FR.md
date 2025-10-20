# Contrat de Dépôt de Données Utilisateur FAIR DAO

[English](README.md)  ·  [简体中文](README_CN.md)  ·  [Русский](README_RU.md)  ·  [Español](README_ES.md)  ·  [Français](README_FR.md)  ·  [العربية](README_AR.md)

## Introduction
Le contrat de dépôt de données utilisateur est le service de stockage de données principal de FAIR DAO pour les autres contrats intelligents. Il offre des fonctionnalités de stockage de données sécurisées et flexibles avec des mécanismes complets de contrôle d'accès.

## Fonctionnalités Principales

### 1. Gestion des Administrateurs
- **Ajouter/Supprimer des Administrateurs**: Les propriétaires peuvent ajouter ou supprimer des administrateurs avec des permissions configurables
- **Contrôle d'Accès Basé sur les Rôles**: Distingue entre les administrateurs réguliers et les propriétaires dotés de privilèges élevés

### 2. Gestion des Clés
- **Attribution des Administrateurs de Clés**: Attribuer des administrateurs spécifiques pour contrôler l'accès à des clés particulières
- **Configuration par Lot des Administrateurs de Clés**: Définir efficacement les administrateurs pour plusieurs clés simultanément
- **Suivi des Clés**: Maintenir un index de toutes les clés enregistrées

### 3. Fonctions de Stockage de Données
- **Stockage de Données Spécifiques à l'Utilisateur**: Stocker et récupérer des données associées à des adresses utilisateur spécifiques
- **Stockage de Données Partagées**: Stocker et récupérer des données accessibles par plusieurs contrats/utilisateurs
- **Suivi des Horodatages**: Enregistrer automatiquement des horodatages pour toutes les modifications de données

### 4. Mécanismes de Sécurité
- **Arrêt d'Urgence**: Arrêter les opérations critiques du contrat en cas d'incident de sécurité
- **Vérification des Autorisations**: Contrôle d'accès strict pour toutes les opérations sensibles

### 5. Fonctions de Requête
- **Informations sur les Administrateurs**: Récupérer la liste des administrateurs et leurs autorisations
- **Informations sur les Clés**: Accéder aux clés enregistrées et leurs administrateurs attribués
- **État du Contrat**: Vérifier si le contrat est en mode d'arrêt d'urgence

## Fonctions du Contrat

### Gestion des Administrateurs
- `addManager(address manager, bool withOwnerPermission)`: Ajouter un nouvel administrateur avec des autorisations de propriétaire facultatives
- `removeManager(uint256 index, address manager)`: Supprimer un administrateur existant
- `isManager(address user)`: Vérifier si une adresse est un administrateur
- `getOwnerCount()`: Obtenir le nombre de propriétaires
- `getManagerCount()`: Obtenir le nombre total d'administrateurs

### Gestion des Clés
- `setKeyManagers(bytes32[] keys, address oldManager, address manager)`: Définir des administrateurs pour plusieurs clés
- `isKeyManager(bytes32 key, address user)`: Vérifier si une adresse est un administrateur d'une clé spécifique
- `getKeyAtIndex(uint256 index)`: Obtenir une clé à un index spécifique

### Opérations sur les Données
- `setUserData(address targetUser, bytes32 key, bytes data)`: Stocker des données pour un utilisateur spécifique
- `getUserData(address targetUser, bytes32 key)`: Récupérer des données spécifiques à un utilisateur
- `setSharedData(bytes32 key, bytes32 sharedValueId, bytes data)`: Stocker des données partagées
- `getSharedData(bytes32 key, bytes32 sharedValueId)`: Récupérer des données partagées

### Fonctions de Sécurité
- `enableEmergencyStop()`: Arrêter les opérations critiques du contrat
- `disableEmergencyStop()`: Reprendre les opérations du contrat
- `isEmergencyStopped()`: Vérifier si le contrat est en mode d'arrêt d'urgence

## Contributions

* Les demandes de tirage (PR) et les rapports de problèmes sont les bienvenus. Veuillez consulter les [lignes directrices de contribution](https://github.com/fair-dao/.github/blob/main/CONTRIBUTING_FR.md).
* **Lors de votre contribution, veuillez laisser votre adresse de portefeuille TRON (au moins une fois). Chaque trimestre, nous évaluons la contribution et répartissons des tokens Fair en récompense aux participants actifs.**

## Licence

* Copyright (c) 2025 FAIR DAO. Tous droits réservés.
* Distribué sous la Licence Publique Générale GNU version 3 ([GPLv3](LICENSE)).