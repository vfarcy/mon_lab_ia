#!/bin/bash
SESSION="IA_MONITOR"

# On vérifie si la session tmux existe déjà
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  # Créer la session et lancer nvtop dans le premier panneau
  tmux new-session -d -s $SESSION 'nvtop'
  # Diviser l'écran horizontalement et lancer nload dans le deuxième panneau
  tmux split-window -h -t $SESSION 'htop'
fi

# S'attacher à la session
tmux attach-session -t $SESSION
