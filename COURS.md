<h1 align="center">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original.svg" width="40" height="40" />
  Projet Inception - 42 
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/debian/debian-original.svg" width="40" height="40" />
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/OS-Debian%20Bookworm-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/Container-Docker-blue?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/Orchestration-Docker%20Compose-0db7ed?style=for-the-badge&logo=docker" />
</p>

---

## 📘 LE COURS INCEPTION : L'ARCHITECTURE DÉMYSTIFIÉE

Ce guide récapitule les concepts fondamentaux pour réussir l'infrastructure Inception.

### 📑 Sommaire
- [Chapitre 1 : Les Fondations](#chapitre-1)
- [Chapitre 2 : Philosophie Docker](#chapitre-2)
- [Chapitre 3 : Dictionnaire Dockerfile](#chapitre-3)
- [Chapitre 4 : Réseau et Tunnels](#chapitre-4)
- [Chapitre 5 : Les 3 Services](#chapitre-5)
- [Chapitre 6 : Orchestration](#chapitre-6)

---

<h3 id="chapitre-1">🚀 CHAPITRE 1 : La Machine et les Droits</h3>

Avant de conteneuriser, il faut un environnement sain.

* **La VM :** Debian Bookworm sans interface graphique.
    * **RAM :** 2 Go.
    * **CPU :** 6 Processeurs.
    * **Disque :** 20 Go.
* **L'installation :** ```bash
    sudo apt-get install docker.io docker-compose
    ```
* **Le piège du sudo :** Pour éviter de taper `sudo` à chaque commande, on ajoute l'utilisateur au groupe Docker.
    ```bash
    sudo usermod -aG docker $USER
    newgrp docker
    ```

---

<h3 id="chapitre-2">🏗️ CHAPITRE 2 : La Philosophie Docker</h3>

<details>
<summary><b>1. Build vs Run (Clique pour voir)</b></summary>

* **Le Build (Dockerfile) :** C'est l'usine. Docker installe les paquets et fabrique une "Image" inerte.
* **Le Run (Compose) :** C'est le démarrage. Docker allume l'image, branche le réseau et les volumes.
</details>

<details>
<summary><b>2. Le Volume Masking (Écrasement)</b></summary>

* **Problème :** Si tu installes WordPress dans `/var/www/wordpress` au *Build*, le volume branché au *Run* va tout écraser car il est vide.
* **Solution :** On installe les outils (wget, php) au *Build*. Au *Run*, l' `entrypoint.sh` utilise ces outils pour télécharger WordPress directement dans le volume.
</details>

<details>
<summary><b>3. Le PID 1 (Maintenir en vie)</b></summary>

Un conteneur meurt si son processus principal s'arrête.
* **NGINX :** On utilise `daemon off;` pour rester au premier plan.
* **PHP :** On utilise `-F` (Foreground) et `exec` pour que PHP devienne le maître du conteneur.
</details>

---

<h3 id="chapitre-3">📜 CHAPITRE 3 : Le Dictionnaire du Dockerfile</h3>

Chaque ligne crée un "calque". Voici les instructions vitales :

| Instruction | Rôle |
| :--- | :--- |
| `FROM` | Définit l'OS de base (Debian Bookworm). |
| `RUN` | Exécute des commandes d'installation. |
| `COPY` | Injecte tes fichiers de config vers le conteneur. |
| `WORKDIR` | Fixe le dossier par défaut pour le debug. |
| `EXPOSE` | Indique les ports d'écoute internes (443, 9000, 3306). |
| `ENTRYPOINT` | Le script lancé au démarrage du conteneur. |

> **Règle d'or :** Toujours faire `apt-get update` et `rm -rf /var/lib/apt/lists/*` sur la même ligne pour alléger l'image.

---

<h3 id="chapitre-4">🌐 CHAPITRE 4 : Réseau, Protocoles et Tunnels</h3>

1.  **TCP (Le garant) :** Protocole de garantie ("Handshake"). Vérifie que 100% des données arrivent dans l'ordre (SQL, HTML).
2.  **Tunnel VirtualBox :** Redirection de port pour que ton PC physique accède au port 443 de la VM.
3.  **DNS Local :** Modifier le fichier `/etc/hosts` de ton PC hôte pour rediriger `kkraft.42.fr` vers `127.0.0.1`.

---

<h3 id="chapitre-5">🛠️ CHAPITRE 5 : Les 3 Services Inception</h3>

#### 🛡️ NGINX (Le Portier)
* **Port :** 443 (HTTPS uniquement).
* **Sécurité :** TLS 1.2 ou 1.3 uniquement.
* **Test :** Une `502 Bad Gateway` signifie que NGINX est ok mais PHP est éteint.

#### 🐘 WordPress (PHP-FPM)
* **Port :** 9000.
* **Dossier :** `/var/www/wordpress`.
* **WP-CLI :** Utilisé dans l'`entrypoint.sh` pour créer les 2 utilisateurs automatiquement.

#### 🐬 MariaDB (Le Coffre)
* **Port :** 3306.
* **Stockage :** `/var/lib/mysql`.
* **Config :** Doit écouter sur `0.0.0.0` pour être accessible par WordPress.

---

<h3 id="chapitre-6">🎼 CHAPITRE 6 : L'Orchestration</h3>

C'est le rôle de `docker-compose.yml` :

* **Fichier `.env` :** Obligatoire pour cacher les mots de passe `$SQL_PASSWORD`.
* **Volumes (`o: bind`) :** Données stockées dans `/home/kkraft/data/`.
* **Réseau Interne :** Permet d'appeler un service par son nom (ex: `fastcgi_pass wordpress:9000`).

---

<p align="center">
  <i>"One container is not enough. We need to go deeper."</i><br>
  <b>Projet Inception - kkraft</b>
</p>