# 🏭 Guide Technique : Infrastructure d'IA Générative Locale

Ceci est un guide technique comprenant les procédures d'installation, les prérequis, la maintenance et l'intégration Python. Ce document constitue une référence pour la gestion d'un laboratoire IA sur une configuration réelle recyclée pour l'occasion.

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

## 🧠 6. Synthèse Technique des Modèles LLM (Ollama)

Cette documentation analyse les forces et limites des modèles installés, en fonction de leur architecture et de leur empreinte mémoire sur la **RTX 4070 Ti**.

### 1. Modèles Spécialisés (Métiers, Logique & Vision)

| Modèle | Points Forts | Limites | Cas d'Usage |
| :--- | :--- | :--- | :--- |
| **Qwen2.5-Coder** (4.7 GB) | Excellence en programmation. Syntaxe rigoureuse (Python, JS, Bash). | Moins performant pour la rédaction littéraire. | Développement, automatisation, scripts. |
| **DeepSeek-R1** (5.2 GB) | Raisonnement par "Chaîne de Pensée" (CoT). Idéal pour les problèmes complexes. | Latence initiale élevée due à la phase de réflexion. | Mathématiques, logique pure, diagnostic. |
| **Llama3.2-Vision** (7.8 GB) | Analyse multimodale (Texte + Image). Identification d'objets et OCR. | Capacités de rédaction inférieures aux modèles textuels purs. | Lecture de schémas, UI/UX, analyse visuelle. |
| **Aya Expanse 8B** (5.1 GB) | Expertise multilingue (101 langues). Respect des nuances culturelles. | Moins "technique" que Qwen ou Phi-4. | Traduction haute fidélité, correction grammaticale. |

### 2. Modèles Polyvalents "Haute Performance" (9B - 12B)
*Ces modèles occupent entre 6 et 10 Go de VRAM, permettant une exécution 100% GPU sans latence.*

#### **Phi-4** (9.1 GB)
* **Forces :** Densité de connaissances exceptionnelle. Très performant sur les benchmarks de compréhension fine.
* **Limites :** Nécessite des instructions (prompts) structurées.
* **Verdict :** La référence actuelle pour la productivité et la synthèse d'informations.

#### **Mistral-Nemo** (7.1 GB)
* **Forces :** Optimisation NVIDIA. Fenêtre de contexte native de **128k tokens**.
* **Limites :** Un peu moins créatif dans la génération de texte libre que Gemma.
* **Verdict :** Le meilleur pour l'analyse de documents volumineux et les contextes étendus.

#### **Qwen 3.5 (9b)** & **Llama 3.1 (8b)**
* **Forces :** Grande stabilité. Standards de l'industrie avec une excellente compréhension du français.
* **Limites :** Performances globales légèrement en retrait face à Phi-4.
* **Verdict :** Modèles polyvalents "tout-terrain" pour des requêtes générales.

### 3. Modèles à Haute Capacité (Gemma 4)

| Variante | Capacités | Impact Infrastructure (12 Go VRAM) |
| :--- | :--- | :--- |
| **Gemma 4 : e4b** (9.6 GB) | Grande finesse sémantique. Ton très naturel et créatif. | **Optimal.** Chargement intégral sur GPU. Fluidité maximale. |
| **Gemma 4 : 26b** (17 GB) | Niveau d'abstraction et d'intelligence supérieur. | **Critique.** Débordement (~5 Go) sur RAM système (DDR3). Débit très lent. |

---

### 📊 Matrice de Sélection Opérationnelle



| Objectif | Modèle Recommandé | Priorité Technique |
| :--- | :--- | :--- |
| **Vitesse & Latence faible** | `qwen2.5-coder` / `mistral` | Faible empreinte VRAM |
| **Qualité de Raisonnement** | `deepseek-r1` / `phi4` | Logique multicouche |
| **Traduction & Linguistique** | `aya-expanse` | Diversité du tokenizer |
| **Analyse de Longs Textes** | `mistral-nemo` | Fenêtre de contexte (128k) |
| **Richesse Sémantique** | `gemma4:e4b` | Paramétrage créatif |
| **Analyse de Documents Visuels**| `llama3.2-vision` | Inférence multimodale |

---

### 🛠️ Rappel de Maintenance (VRAM)
Pour garantir une performance constante, il est recommandé de redémarrer le service Ollama (`sudo systemctl restart ollama`) après l'utilisation intensive du modèle **Gemma 4 : 26b**, afin de purger la VRAM et d'éviter que les modèles légers ne soient ralentis par des résidus de mémoire.


#### 🛠️ Préconisation de Maintenance
Pour garantir une performance constante, il est recommandé de redémarrer le service Ollama (`sudo systemctl restart ollama`) après l'utilisation intensive du modèle **Gemma 4 : 26b**, afin de libérer totalement la mémoire vidéo et d'éviter la fragmentation de la VRAM pour les modèles plus légers.


---

## 📋 7. Protocoles de Surveillance et Limites

* **Surveillance VRAM :** Utiliser `nvtop` ou `nvidia-smi`. Si la VRAM sature, le système bascule sur la RAM (DDR3), ce qui divise la vitesse par 50.
* **Redémarrage :** Ollama démarre via *systemd*. L'interface Docker redémarre automatiquement via le flag `--restart always`.
* **Contexte :** Pour l'analyse de documents longs, régler le **Context Length** à **8192** (ou 16384 pour les modèles < 14B) dans les paramètres d'Open WebUI.
* **Sécurité :** L'ouverture à `0.0.0.0` expose l'IA à votre réseau local. Utilisez un mot de passe fort sur Open WebUI.
*  **Monitoring :** Lancer ``ssh -t login@IP "./monitor_ai.sh"`` pour visualiser les charges CPU et GPU 
