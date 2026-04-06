# 🧠 Guide de Mise en Œuvre du Routage Intelligent (Task-Based Routing)

L'objectif de cette configuration est l'automatisation de la sélection du modèle LLM en fonction de la complexité et de la nature de la requête utilisateur. Cette approche permet d'optimiser l'usage de la VRAM (**12 Go sur RTX 4070 Ti**) et de réduire la latence globale du système.

---

## 🛠️ Étape 1 : Préparation de l'Infrastructure Ollama

L'architecture repose sur la coexistence de modèles aux capacités distinctes. Il est nécessaire de s'assurer de la présence des modèles suivants sur le serveur :

```bash
# Modèle "Dispatcher" (Léger et analytique)
ollama pull llama3.1:8b

# Modèles "Experts" (Spécialisés et Haute Performance)
ollama pull qwen2.5:14b
ollama pull qwen2.5-coder
ollama pull phi-4
ollama pull deepseek-r1
```

---

## 🛠️ Étape 2 : Création du Script de Routage Automatisé

Un script Shell est utilisé pour orchestrer la communication entre le dispatcher et l'expert. Ce processus se déroule en deux phases : l'analyse de l'intention et l'exécution de la tâche.

1. **Création du fichier source :**
   ```bash
   nano ~/ia_router.sh
   ```

2. **Insertion du code logique :**
   ```bash
   #!/bin/bash

   # Récupération de la requête utilisateur
   USER_PROMPT="$1"

   # Vérification de la présence d'un argument
   if [ -z "$USER_PROMPT" ]; then
       echo "Usage: ia 'votre question ici'"
       exit 1
   fi

   # PHASE 1 : Analyse par le Dispatcher (Llama 3.1 8B)
   # Le prompt système impose une réponse concise limitée au nom du modèle cible.
   SYSTEM_INSTRUCTION="Tu es un routeur. Réponds UNIQUEMENT par le nom du modèle. 
   Règles : 
   - Code (Python, C++, Bash, HTML) -> qwen2.5-coder
   - Maths/Logique/Preuve -> phi-4
   - Analyse complexe/Réflexion -> deepseek-r1
   - Question générale difficile -> qwen2.5:14b
   - Chat simple/Rapide -> llama3.1:8b"

   # Extraction du nom du modèle (nettoyage des caractères spéciaux)
   MODEL=$(ollama run llama3.1:8b "$SYSTEM_INSTRUCTION Requête : $USER_PROMPT" | tr -d '\r' | xargs)

   # PHASE 2 : Information visuelle sur le routage
   echo -e "\033[1;34m[Système]\033[0m Routage vers l'expert : \033[1;32m$MODEL\033[0m"

   # PHASE 3 : Exécution de la requête par le modèle expert
   ollama run "$MODEL" "$USER_PROMPT"
   ```

---

## 🛠️ Étape 3 : Intégration Globale au Système

Pour permettre un accès universel à la fonction de routage depuis n'importe quel point du terminal, le script doit être rendu exécutable et associé à un alias système.

1. **Attribution des droits d'exécution :**
   ```bash
   chmod +x ~/ia_router.sh
   ```

2. **Configuration de l'alias permanent :**
   ```bash
   echo "alias ia='~/ia_router.sh'" >> ~/.bashrc
   source ~/.bashrc
   ```

---

## 🚦 Analyse des Performances et Gestion de la VRAM

| Phase | Modèle Sollicité | Impact VRAM | Temps de réponse |
| :--- | :--- | :--- | :--- |
| **Routage** | `llama3.1:8b` | ~5.0 Go | < 1s |
| **Exécution** | Variable (8B à 14B) | ~5.0 à 9.5 Go | Variable selon complexité |

### Avantages de la méthode
- **Efficience énergétique :** Le processeur **i7-3770** n'est pas surchargé par des calculs inutiles si un modèle léger suffit.
- **Stabilité de la mémoire :** La gestion séquentielle évite le dépassement de la capacité de 12 Go de la carte graphique, prévenant ainsi les erreurs de type "Out of Memory" (OOM).
- **Précision :** Chaque domaine (code, logique, rédaction) est traité par le modèle ayant le meilleur score sur les benchmarks spécifiques.

---

## 📝 Mise à jour de la documentation (README.md)

Il est recommandé d'ajouter la mention suivante au guide de maintenance :

> **Note sur le Routage Intelligent :** > La commande `ia` automatise la sélection du modèle. En cas de réponse inappropriée du dispatcher, il convient de vérifier la clarté de la requête initiale ou d'ajuster les règles de sélection dans le fichier `~/ia_router.sh`.
