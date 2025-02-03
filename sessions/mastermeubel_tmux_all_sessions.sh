#!/bin/bash

SESSION_NAME="mastermeubel-front"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    cd "/home/haze/dev/work/mastermeubel-frontend"
    tmux new-session -d -s "$SESSION_NAME"
    tmux rename-window -t "$SESSION_NAME:0" "neovim"
    tmux send-keys -t "$SESSION_NAME:neovim" "cd '/home/haze/dev/work/mastermeubel-frontend'" C-m
    tmux send-keys -t "$SESSION_NAME:neovim" "nvim ." C-m
    tmux new-window -t "$SESSION_NAME" -n "git"
    tmux send-keys -t "$SESSION_NAME:git" "cd '/home/haze/dev/work/mastermeubel-frontend'" C-m
    tmux send-keys -t "$SESSION_NAME:git" "" C-m
    tmux new-window -t "$SESSION_NAME" -n "run"
    tmux send-keys -t "$SESSION_NAME:run" "cd '/home/haze/dev/work/mastermeubel-frontend'" C-m
    tmux send-keys -t "$SESSION_NAME:run" "npm run dev" C-m
    tmux new-window -t "$SESSION_NAME" -n "shell"
    tmux send-keys -t "$SESSION_NAME:shell" "cd '/home/haze/dev/work/mastermeubel-frontend'" C-m
    tmux send-keys -t "$SESSION_NAME:shell" "" C-m
fi

#!/bin/bash
# Create a tmux session with the name mastermeubel-back
SESSION_NAME="mastermeubel-back"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    cd "/home/haze/dev/work/mastermeubel-backend"
    tmux new-session -d -s "$SESSION_NAME"
    tmux rename-window -t "$SESSION_NAME:0" "neovim"
    tmux send-keys -t "$SESSION_NAME:neovim" "cd '/home/haze/dev/work/mastermeubel-backend'" C-m
    tmux send-keys -t "$SESSION_NAME:neovim" "nvim ." C-m
    tmux new-window -t "$SESSION_NAME" -n "git"
    tmux send-keys -t "$SESSION_NAME:git" "cd '/home/haze/dev/work/mastermeubel-backend'" C-m
    tmux send-keys -t "$SESSION_NAME:git" "" C-m
    tmux new-window -t "$SESSION_NAME" -n "run"
    tmux send-keys -t "$SESSION_NAME:run" "cd '/home/haze/dev/work/mastermeubel-backend'" C-m
    tmux send-keys -t "$SESSION_NAME:run" "php artisan serve" C-m
    tmux new-window -t "$SESSION_NAME" -n "shell"
    tmux send-keys -t "$SESSION_NAME:shell" "cd '/home/haze/dev/work/mastermeubel-backend'" C-m
    tmux send-keys -t "$SESSION_NAME:shell" "" C-m
fi


tmux attach-session -t "$SESSION_NAME:0"
