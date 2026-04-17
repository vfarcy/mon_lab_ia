#!/bin/bash
SESSION="IA_MONITOR"

# On vérifie si la session tmux existe déjà
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  # 1. Créer la session avec nvtop (le panneau du haut)
  tmux new-session -d -s $SESSION 'nvtop'
  
  # 2. Diviser verticalement (-v) pour créer un panneau en bas
  # On demande à htop de se lancer dans ce nouveau panneau
  tmux split-window -t $SESSION -v 'htop'
  
  # Optionnel : Ajuster la taille (donner 60% à nvtop, 40% à htop)
  # tmux resize-pane -t $SESSION:0.0 -D 10
fi

# S'attacher à la session
tmux attach-session -t $SESSION
