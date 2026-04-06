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
