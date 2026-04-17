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

Ce guide interactif récapitule les concepts fondamentaux pour réussir l'infrastructure Inception. Clique sur les différentes sections pour explorer le contenu.

### 📑 Sommaire
- [L'Arborescence du Projet](#arborescence)
- [Chapitre 1 : Les Fondations & Système](#chapitre-1)
- [Chapitre 2 : Philosophie Docker & Pièges Fatals](#chapitre-2)
- [Chapitre 3 : Dictionnaire Dockerfile](#chapitre-3)
- [Chapitre 4 : Les 3 Services & Leurs Chemins](#chapitre-4)
- [Chapitre 5 : L'Orchestration (Compose)](#chapitre-5)
- [Chapitre 6 : Cheat Sheet Commandes](#chapitre-6)

---

<details>
<summary><b>💡 Conseils en or pour réussir de manière fluide</b></summary>
<br>

* **Prends des notes :** Il te sera demandé de rédiger un README comparant les VM aux conteneurs, et les Volumes aux Bind Mounts.
* **Construis brique par brique :** Ne lance pas tout d'un coup. Rédige le Dockerfile de NGINX en premier et teste-le seul. Ensuite MariaDB. Enfin WordPress.
* **Sois rigoureux sur l'arborescence :** Tes fichiers de configuration devront être dans un dossier `srcs` précis, et ton `Makefile` à la racine.
* **Inspecte tes conteneurs :** Apprends très tôt à lire les logs de l'intérieur quand un service refuse de démarrer.

</details>

---

<h3 id="arborescence">📂 L'Arborescence du Projet</h3>

Voici la structure stricte attendue pour ton rendu :

<pre><code>/mon_projet_inception
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── requirements/
│   │   ├── mariadb/
│   │   │   ├── conf/
│   │   │   ├── tools/
│   │   │   └── Dockerfile
│   │   ├── nginx/
│   │   │   ├── conf/
│   │   │   ├── tools/
│   │   │   └── Dockerfile
│   │   └── wordpress/
│   │       ├── conf/
│   │       ├── tools/
│   │       └── Dockerfile
└── .gitignore</code></pre>

---

<h3 id="chapitre-1">🚀 CHAPITRE 1 : Les Fondations & Système</h3>

Avant de conteneuriser, il faut comprendre où tes conteneurs vont vivre. Ton projet doit tourner sur une **Machine Virtuelle** (Debian ou Alpine Linux).

<details>
<summary><b>La Configuration de la VM</b></summary>
<br>

* **OS :** Debian Bookworm (sans interface graphique).
* **RAM :** 2 Go | **CPU :** 6 Processeurs | **Disque :** 20 Go.
* **Installation initiale :**
<pre><code>sudo apt-get install docker.io docker-compose</code></pre>
* **Le piège du sudo :** Ajoute ton utilisateur au groupe Docker pour éviter de taper `sudo` à chaque fois :
<pre><code>sudo usermod -aG docker $USER
newgrp docker</code></pre>

</details>

<details>
<summary><b>Les Chemins "Système" vitaux (Debian)</b></summary>
<br>

* `/var/lib/apt/lists/*` : Le cache des catalogues d'installation. À supprimer à chaque `apt-get update` pour alléger l'image.
* `/usr/local/bin/` : Le dossier magique pour tes propres scripts (`entrypoint.sh`). Avec un `chmod +x`, ils deviennent exécutables de n'importe où.
* `/etc/hosts` : *(Sur ta machine physique/VM)* Gère tes DNS locaux. Ajoute `127.0.0.1 login.42.fr` pour que ton navigateur redirige correctement vers ton infra.

</details>

---

<h3 id="chapitre-2">🏗️ CHAPITRE 2 : La Philosophie Docker (L'art de l'isolation)</h3>

Un conteneur n'est absolument pas une machine virtuelle.

<details>
<summary><b>1. Build vs Run</b></summary>
<br>

* **Le Build (Dockerfile) :** C'est l'usine. Docker installe les paquets et fabrique une "Image" inerte (le plan de construction).
* **Le Run (Compose) :** C'est le démarrage. Docker allume l'image (crée l'instance), branche le réseau et les volumes.

</details>

<details>
<summary><b>2. Le concept du PID 1 (Processus Principal)</b></summary>
<br>

Un conteneur meurt si son processus principal s'arrête. Maintenir un conteneur en vie avec une boucle infinie (`tail -f`, `sleep infinity`) est une **très mauvaise pratique**.
* **NGINX :** On utilise `daemon off;` pour rester au premier plan.
* **PHP :** On utilise `-F` (Foreground) et `exec` pour que PHP devienne le maître du conteneur.

</details>

<details>
<summary><b>3. Le Volume Masking (Écrasement)</b></summary>
<br>

* **Problème :** Si tu installes WordPress dans `/var/www/wordpress` au *Build*, le volume branché au *Run* va tout écraser car il est vide.
* **Solution :** Installe les outils (`wget`, `php`) au *Build*. Au *Run*, l'`entrypoint.sh` télécharge WordPress directement dans le volume monté.

</details>

---

<h3 id="chapitre-3">📜 CHAPITRE 3 : Le Dictionnaire du Dockerfile</h3>

Chaque ligne crée un "calque". Tu ne pourras pas utiliser d'images toutes prêtes, tu dois écrire tes Dockerfiles de zéro.

| Instruction | Explication & Rôle |
| :--- | :--- |
| `FROM` | **Définit l'OS de base.** Exemple : `FROM debian:bookworm` |
| `RUN` | **S'exécute à la CRÉATION.** Installe les paquets. *Règle d'or : Toujours faire `apt-get update` et `rm -rf /var/lib/apt/lists/*` sur la même ligne.* |
| `COPY` | **Injecte.** Copie tes scripts/configs depuis ton PC vers le conteneur. |
| `EXPOSE` | **Informatif.** Indique les ports d'écoute internes (443, 9000, 3306). |
| `CMD` / `ENTRYPOINT` | **S'exécute au DÉMARRAGE.** C'est le PID 1 qui maintient le conteneur en vie. Exemple : `ENTRYPOINT ["/chemin/script.sh"]` |

---

<h3 id="chapitre-4">🛠️ CHAPITRE 4 : Les 3 Services & Leurs Chemins</h3>

<details>
<summary><b>🛡️ NGINX (Le Portier / Reverse Proxy)</b></summary>
<br>

**Définition :** Serveur web open-source conçu pour une faible utilisation mémoire via une approche asynchrone (un processus maître gère plusieurs travailleurs). Il sert de seul point d'entrée.

* **Port :** 443 (HTTPS uniquement).
* **Sécurité :** Protocoles TLSv1.2 ou TLSv1.3 uniquement.
* **Chemins vitaux :**
  * `/etc/nginx/nginx.conf` : Fichier de config principal (à remplacer via `COPY`).
  * `/var/www/html/` (ou `wordpress/`) : Document Root, là où NGINX cherche les pages web.
  * `/var/log/nginx/error.log` : Ton meilleur ami pour le débogage (les erreurs de syntaxe).

</details>

<details>
<summary><b>🐬 MariaDB (Le Coffre / Base de données)</b></summary>
<br>

* **Port :** 3306.
* **Chemins vitaux :**
  * `/etc/mysql/mariadb.conf.d/50-server.cnf` : Config pour écouter sur `0.0.0.0` (accessible par WP).
  * `/var/lib/mysql/` : Le coffre-fort physique des données. **À exporter en Volume impérativement !**
  * `/run/mysqld/` : Dossier pour le fichier `.sock`. Pense à faire un `mkdir -p` s'il n'existe pas.

</details>

<details>
<summary><b>🐘 WordPress & PHP-FPM (Le Moteur)</b></summary>
<br>

* **Port :** 9000.
* **Outil :** `WP-CLI` utilisé dans l'`entrypoint.sh` pour installer WP et créer les utilisateurs automatiquement.
* **Chemins vitaux :**
  * `/etc/php/8.2/fpm/pool.d/www.conf` : Dit à PHP-FPM d'écouter sur le port 9000.
  * `/run/php/` : Dossier de processus PHP. Souvent besoin d'un `mkdir -p` au démarrage.

</details>

---

<h3 id="chapitre-5">🎼 CHAPITRE 5 : L'Orchestration (Docker Compose)</h3>

Faire tourner un conteneur seul, c'est bien. Faire communiquer plusieurs conteneurs ensemble de manière sécurisée, c'est le rôle de `docker-compose.yml`.

1. **Variables d'environnement (`.env`) :** Ne **jamais** exposer tes mots de passe en clair. Utilise un `.env` pour cacher `$SQL_PASSWORD`, etc.
2. **Réseau Interne (Network) :** Permet d'appeler un service par son nom. NGINX peut parler à WP via `fastcgi_pass wordpress:9000`.
3. **Les Volumes (Bind Mounts vs Volumes Named) :** * **Base de données :** Mappe `/var/lib/mysql/`
   * **Site Web :** Mappe `/var/www/wordpress/` vers un dossier hôte (ex: `/home/login/data/`) pour résoudre l'équation de la persistance.

---

<h3 id="chapitre-6">💻 CHAPITRE 6 : Cheat Sheet Commandes</h3>

Voici les commandes essentielles pour gérer ton infra au quotidien :

<details>
<summary><b>🟢 Lancement et Arrêt</b></summary>

<pre><code># Construire et allumer l'infrastructure (en arrière-plan) :
docker-compose -f srcs/docker-compose.yml up -d --build

# Éteindre temporairement (sans détruire) :
docker-compose -f srcs/docker-compose.yml stop

# Éteindre et tout détruire proprement (y compris les volumes/disques) :
docker-compose -f srcs/docker-compose.yml down -v</code></pre>
</details>

<details>
<summary><b>🔍 Inspection et Débogage</b></summary>

<pre><code># Voir qui est en vie (les conteneurs qui tournent) :
docker ps

# Voir tout le monde (même les conteneurs qui ont planté) :
docker ps -a

# Lire le rapport de crash (les logs d'erreur) d'un service :
docker logs nginx
docker logs mariadb
docker logs wordpress

# Entrer physiquement à l'intérieur d'un conteneur en vie :
docker exec -it nginx bash
docker exec -it mariadb bash
docker exec -it wordpress bash</code></pre>
</details>

<details>
<summary><b>🧹 Nettoyage</b></summary>

<pre><code># Supprimer tout ce qui est inutile (images ratées, caches, vieux réseaux) :
docker system prune -af</code></pre>
</details>

---

<p align="center">
  <i>"One container is not enough. We need to go deeper."</i><br>
  <b>Projet Inception</b>
</p>

🕵️ 1. L'inspection des Ports (La règle d'or de NGINX)
Le sujet exige que NGINX soit le seul point d'entrée de ton infrastructure. L'évaluateur va vérifier que tu n'as pas accidentellement ouvert les ports de la base de données au reste du monde.

La commande : docker ps

Ce qu'il faut regarder : * Sur la ligne de nginx, dans la colonne "PORTS", tu dois voir 0.0.0.0:443->443/tcp. Cela veut dire que le port 443 de ton PC est relié au conteneur.

Sur les lignes de mariadb et wordpress, tu ne dois absolument pas voir de 0.0.0.0 ! Leurs ports (3306 et 9000) ne doivent être ouverts qu'en interne.

💀 2. Le test anti-triche (Le PID 1 et l'OS)
L'évaluateur va vérifier si tu as utilisé des rustines interdites (tail -f, sleep infinity, bash) pour maintenir tes conteneurs en vie.

La commande PID : docker exec -it nginx ps aux (à faire aussi sur mariadb et wordpress).

Ce qu'il faut regarder : La toute première ligne du résultat (celle qui a le PID numéro 1) DOIT être le programme officiel (nginx, mariadbd ou php-fpm). Si c'est écrit /bin/bash ou sleep, tu as un zéro direct.

La commande OS : docker exec -it nginx cat /etc/os-release

Ce qu'il faut regarder : Cela affichera "Debian GNU/Linux 12 (bookworm)", ce qui prouve à l'évaluateur que tu as bien utilisé l'avant-dernière version stable comme exigé.

🔄 3. Le "Crash Test" (La résilience)
Le sujet stipule : "Vos conteneurs doivent redémarrer en cas de crash". L'évaluateur va essayer de détruire un service pour voir comment ton Docker réagit.

La commande : docker kill mariadb (Cette commande assassine le conteneur de manière brutale).

La vérification : Tape immédiatement docker ps. Tu verras que MariaDB est toujours là, mais que sa colonne "STATUS" indiquera Up 2 seconds (au lieu de 10 minutes pour les autres). Cela prouve que Docker a détecté le crash et a automatiquement relancé la base de données !

📂 4. L'inspection des Volumes (Le paradoxe résolu)
Le correcteur va vérifier ta fameuse "entourloupe" des Named Volumes et tester la persistance.

L'inspection Docker : docker volume ls (pour montrer qu'ils existent) puis docker volume inspect mariadb_data. Tu pourras lui montrer fièrement la ligne "Device": "/home/kkraft/data/mariadb" pour prouver que tu respectes la règle des Named Volumes ET du stockage local.

Le test de persistance : 1. Va dans ton vrai dossier physique : cd /home/kkraft/data/wordpress et crée un fichier texte bidon : touch hack.txt.
2. Va à l'intérieur de ton conteneur : docker exec -it wordpress ls /var/www/wordpress.
3. Le fichier hack.txt apparaîtra dans le terminal du conteneur. Tu viens de prouver que le pont physique existe bien.

👥 5. La vérification WordPress / Base de données
Le sujet exige deux utilisateurs dans la base de données, dont un administrateur ne s'appelant pas "admin".

Le test rapide depuis le terminal : Tu peux utiliser WP-CLI directement depuis l'extérieur du conteneur pour lister les utilisateurs et prouver que tes variables d'environnement ont bien fonctionné !

La commande : docker exec -it wordpress wp user list --allow-root

Le résultat attendu : Un tableau propre s'affichera dans ton terminal montrant tes deux utilisateurs (ton boss et ton auteur) avec leurs rôles respectifs.

🧹 6. Le bouton Nucléaire (Le Makefile)
En fin de soutenance, on te demandera de prouver que ton projet peut s'effacer totalement.

La commande : make fclean

La vérification : Après l'exécution, tape docker ps -a (il ne doit plus rien avoir), docker images (vide), et docker volume ls (vide).

Si tu maîtrises l'explication de ces quelques commandes docker exec, docker ps, et docker volume, tu donneras l'image d'un étudiant qui contrôle parfaitement son infrastructure et qui ne s'est pas contenté de copier-coller des tutoriels. Tu as toutes les clés en main !