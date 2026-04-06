# 🏭 Guide Technique : Infrastructure d'IA Générative Locale

Ceci est un guide technique comprenant les procédures d'installation, les prérequis, la maintenance et l'intégration Python de programmes python aux LLMs. Ce document constitue une référence pour la gestion d'un laboratoire IA sur une configuration réelle recyclée pour l'occasion.

---

## 📋 1. Prérequis Système et Matériels
L'efficacité de l'inférence (génération de texte) dépend de l'équilibre entre la bande passante mémoire du GPU et la capacité du processeur à gérer les flux de données.

* **Processeur (CPU) :** Minimum 4 cœurs / 8 threads (ex: **Intel i7-3770**). Assure le chargement initial des modèles.
* **Accélérateur Graphique (GPU) :** Carte **NVIDIA RTX** (Architecture Pascal ou plus récente). Une **RTX 4070 Ti (12 Go VRAM)** est le cœur de calcul.
* **Mémoire Vive (RAM) :** **16 Go minimum** (**32 Go recommandés**) pour stabiliser le système.
* **Stockage :** SSD (NVMe ou SATA) avec **50 Go à 100 Go libres**.

---

## 🚀 2. Capacités et Seuils d'Efficacité (RTX 4070 Ti)
Le facteur limitant pour l'IA locale est la **VRAM (12 Go)**. Voici les performances attendues selon la taille des modèles (en quantification Q4_K_M) :

| Taille du Modèle | Occupation VRAM | Vitesse / Fluidité | Statut |
| :--- | :--- | :--- | :--- |
| **7B - 9B** | ~5.5 Go | 🚀 Ultra-rapide (>100 t/s) | **Idéal** |
| **12B - 14B** | ~9.5 Go | ⚡ Très fluide | **Optimal (Équilibre)** |
| **26B - 32B** | ~11.5 Go | 🐢 Stable mais lent | **Maximum possible** |
| **70B+** | > 35 Go | 🧊 Inexploitable | **Hors limite** |

---

## 🛠️ 3. Procédure d'Installation Pas à Pas

### Étape A : Installation du Moteur (Ollama)
1.  **Installation via script officiel :**
    ```bash
    curl -fsSL https://ollama.com/install.sh | sh
    ```
2.  **Configuration du réseau (Accès distant et Docker) :**
    ```bash
    sudo systemctl edit ollama
    ```
    Insérer les lignes suivantes entre les lignes de commentaires :
    ```ini
    [Service]
    Environment="OLLAMA_HOST=0.0.0.0"
    Environment="OLLAMA_ORIGINS=*"
    ```
3.  **Redémarrage du service :**
    ```bash
    sudo systemctl daemon-reload && sudo systemctl restart ollama
    ```

### Étape B : Déploiement de l'Interface (Open WebUI)
1.  **Installation de Docker :**
    ```bash
    sudo apt update && sudo apt install docker.io -y
    sudo usermod -aG docker $USER
    ```
2.  **Lancement du conteneur :**
    ```bash
    docker run -d -p 3000:8080 \
      --add-host=host.docker.internal:host-gateway \
      -v open-webui:/app/backend/data \
      --name open-webui \
      --restart always \
      ghcr.io/open-webui/open-webui:main
    ```
3.  **Au boot éventuellement  :**

    Si erreur 500, alors relancer avec :
     ```bash
     docker start open-webui
     ```

    Ob bien automatiser définitivement le lancement du serveur web au boot avec :

    ```bash 
    docker update --restart always open-webui
    ```

---

## 💻 4. Intégrations et Développement

### Intégration VS Code (Alternative à Copilot)
Pour utiliser l'IA directement dans l'éditeur de code :
1.  Installer l'extension **Continue** depuis le Marketplace VS Code.
2.  Dans le fichier de configuration de Continue (`config.json`), ajouter le provider Ollama :
    ```json
    {
      "models": [
        {
          "title": "Qwen 2.5 Coder 14B",
          "provider": "ollama",
          "model": "qwen2.5-coder:14b",
          "apiBase": "http://localhost:11434"
        }
      ],
      "tabAutocompleteModel": {
        "title": "Qwen 2.5 Coder 7B",
        "provider": "ollama",
        "model": "qwen2.5-coder:7b"
      }
    }
    ```

### Intégration Python
Installer la bibliothèque : `pip install ollama`.
```python
import ollama
response = ollama.chat(model='qwen2.5-coder:14b', messages=[
    {'role': 'user', 'content': 'Génère un script Python de nettoyage de logs.'}
])
print(response['message']['content'])
```

---

## 🛠️ 5. Maintenance et Mises à jour

* **Mise à jour Interface :**
    ```bash
    docker pull ghcr.io/open-webui/open-webui:main
    docker rm -f open-webui
    # Relancer la commande de l'Étape B
    ```
* **Mise à jour Moteur :** Relancer le script d'installation d'Ollama (`curl -fsSL...`).
* **Gestion des modèles :** `ollama list` (voir), `ollama rm [nom]` (supprimer).

---

Voici la mise à jour de ta section **6. Synthèse Technique**, optimisée pour intégrer **Qwen2.5:14B** comme pièce maîtresse de ton dispositif. J'ai harmonisé le style avec tes autres sections et ajusté les données de VRAM pour ta **RTX 4070 Ti**.

---

## 🧠 6. Synthèse Technique des Modèles LLM (Ollama)

Cette documentation analyse les forces et limites des modèles installés, en fonction de leur architecture et de leur empreinte mémoire sur la **RTX 4070 Ti (12 Go)**.

### 1. Le "Daily Driver" : Le compromis idéal


#### **Qwen2.5 : 14B** (9.0 GB)
* **Forces :** Excellence en programmation, mathématiques et instructions complexes. Architecture ultra-moderne.
* **Impact VRAM :** Occupant ~9.2 GB, il laisse la place nécessaire au cache de contexte (KV Cache) pour des réponses fluides.
* **Verdict :** Le modèle principal du Lab. Il remplace avantageusement les modèles 7B et 8B pour toutes les tâches de production.

---

### 2. Modèles Spécialisés (Métiers, Logique & Vision)

| Modèle | Points Forts | Limites | Cas d'Usage |
| :--- | :--- | :--- | :--- |
| **Qwen2.5-Coder** (4.7 GB) | Syntaxe rigoureuse (Python, JS, Bash). | Moins performant pour la rédaction littéraire. | Développement, scripts, automatisation. |
| **DeepSeek-R1** (5.2 GB) | Raisonnement par "Chaîne de Pensée" (CoT). | Latence initiale (phase de réflexion). | Logique pure, diagnostic, mathématiques. |
| **Llama3.2-Vision** (7.8 GB) | Analyse multimodale (Texte + Image). | Rédaction textuelle en retrait. | OCR, analyse de schémas, UI/UX. |
| **Aya Expanse 8B** (5.1 GB) | Expertise multilingue (101 langues). | Moins technique que Qwen ou Phi-4. | Traduction, nuances culturelles. |

---

### 3. Modèles Polyvalents "Haute Performance"

#### **Phi-4** (9.1 GB)
* **Forces :** Densité de connaissances exceptionnelle. Très fin sur les benchmarks de compréhension.
* **Limites :** Sensible à la structure du prompt.
* **Verdict :** La référence pour la synthèse d'informations complexes.

#### **Mistral-Nemo** (7.1 GB)
* **Forces :** Optimisation NVIDIA. Fenêtre de contexte native de **128k tokens**.
* **Limites :** Moins créatif que la série Gemma.
* **Verdict :** Idéal pour l'analyse de documents volumineux.

---

### 4. Modèles à Haute Capacité (Gemma 4)

| Variante | Capacités | Impact Infrastructure (12 Go VRAM) |
| :--- | :--- | :--- |
| **Gemma 4 : e4b** (9.6 GB) | Finesse sémantique et ton naturel. | **Optimal.** Chargement 100% GPU. Fluidité maximale. |
| **Gemma 4 : 26b** (17 GB) | Intelligence supérieure (niveau GPT-4). | **Critique.** Débordement (~5 Go) sur RAM DDR3. Débit très lent. |

---

### 📊 Matrice de Sélection Opérationnelle

| Objectif | Modèle Recommandé | Priorité Technique |
| :--- | :--- | :--- |
| **Polyvalence & Puissance** | `qwen2.5:14b` | **Équilibre VRAM/Intelligence** |
| **Vitesse & Latence** | `qwen2.5-coder` / `mistral` | Faible empreinte mémoire |
| **Qualité de Raisonnement** | `deepseek-r1` / `phi4` | Logique multicouche |
| **Analyse de Longs Textes** | `mistral-nemo` | Fenêtre de contexte (128k) |
| **Analyse Visuelle** | `llama3.2-vision` | Inférence multimodale |

---

### 🛠️ Préconisation de Maintenance
Pour garantir une performance constante, il est recommandé de redémarrer le service Ollama (`sudo systemctl restart ollama`) après l'utilisation intensive du modèle **Gemma 4 : 26b**. Cela permet de purger la VRAM, d'éviter la fragmentation de la mémoire vidéo et de garantir que les modèles comme **Qwen2.5:14B** s'exécutent de nouveau à 100% sur le GPU.
### 🛠️ Rappel de Maintenance (VRAM)
Pour garantir une performance constante, il est recommandé de redémarrer le service Ollama (`sudo systemctl restart ollama`) après l'utilisation intensive du modèle **Gemma 4 : 26b**, afin de purger la VRAM et d'éviter que les modèles légers ne soient ralentis par des résidus de mémoire.


#### 🛠️ Préconisation de Maintenance
Pour garantir une performance constante, il est recommandé de redémarrer le service Ollama (`sudo systemctl restart ollama`) après l'utilisation intensive du modèle **Gemma 4 : 26b**, afin de libérer totalement la mémoire vidéo et d'éviter la fragmentation de la VRAM pour les modèles plus légers.


---

## 📝 7. Mamba


### 🐍 Gestion des environnements Python avec Mamba

L'exécution de modèles d'IA (Ollama, Whisper, Stable Diffusion) sur une architecture NVIDIA nécessite une gestion rigoureuse des dépendances. L'utilisation de **Miniforge3** et de l'exécutable **Mamba** permet d'assurer cette stabilité.

### Fonctionnalités principales
1. **Isolation :** Création d'environnements étanches. Cela permet d'exécuter simultanément des projets nécessitant des versions de Python distinctes (ex: 3.10 pour la Vision et 3.12 pour le Code) sans conflit système.
2. **Optimisation GPU :** Mamba gère l'installation des frameworks (`PyTorch`, `TensorFlow`) en adéquation avec les pilotes CUDA installés (ex: **RTX 4070 Ti**).
3. **Performance :** Grâce à un moteur de résolution écrit en C++, **Mamba** surpasse `conda` et `pip` en rapidité lors de l'analyse des dépendances et de l'installation des paquets.


### 🛠️ Procédure d'installation sur Ubuntu

En l'absence de l'outil sur le système, la procédure est la suivante :

1. **Téléchargement de l'installeur :**
   ```bash
   wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
   ```

2. **Exécution de l'installation :**
   ```bash
   bash Miniforge3-Linux-x86_64.sh
   ```
   *Suivre les instructions : acceptation de la licence et validation de l'initialisation (conda init).*

3. **Prise en compte des modifications :**
   ```bash
   source ~/.bashrc
   ```

4. **Vérification de l'état du système :**
   ```bash
   mamba info
   ```

### 🚀 Commandes usuelles de gestion


| Action | Commande |
| :--- | :--- |
| **Création d'un environnement** | `mamba create -n nom_env python=3.11` |
| **Activation de l'environnement** | `mamba activate nom_env` |
| **Installation de bibliothèques GPU** | `mamba install pytorch-cuda=12.1 -c pytorch -c nvidia` |
| **Liste des environnements disponibles** | `mamba env list` |
| **Nettoyage (après installation)** | `rm Miniforge3-Linux-x86_64.sh` |


---


## 📋 8. Protocoles de Surveillance et Limites

* **Surveillance VRAM :** Utiliser `nvtop` ou `nvidia-smi`. Si la VRAM sature, le système bascule sur la RAM (DDR3), ce qui divise la vitesse par 50.
* **Redémarrage :** Ollama démarre via *systemd*. L'interface Docker redémarre automatiquement via le flag `--restart always`.
* **Contexte :** Pour l'analyse de documents longs, régler le **Context Length** à **8192** (ou 16384 pour les modèles < 14B) dans les paramètres d'Open WebUI.
* **Sécurité :** L'ouverture à `0.0.0.0` expose l'IA à votre réseau local. Utilisez un mot de passe fort sur Open WebUI.
*  **Monitoring :** Lancer ``ssh -t login@IP "./monitor_ai.sh"`` pour visualiser les charges CPU et GPU du lab IA (voir aussi ``glances``).
