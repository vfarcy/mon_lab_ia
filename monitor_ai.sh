#!/bin/bash
SESSION="IA_MONITOR"

# On vérifie si la session existe déjà
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  # 1. Créer la session et lancer NVTOP en arrière-plan (-d)
  tmux new-session -d -s $SESSION 'nvtop'
  
  # 2. DIVISER la fenêtre de la session (split) et y lancer HTOP
  # Le "-v" crée une séparation horizontale (un en haut, un en bas)
  tmux split-window -t $SESSION -v 'htop'
  
  # 3. (Optionnel) Équilibrer les panneaux pour qu'ils fassent 50/50
  tmux select-layout -t $SESSION even-vertical
fi

# S'attacher à la session pour voir le résultat
tmux attach-session -t $SESSION
