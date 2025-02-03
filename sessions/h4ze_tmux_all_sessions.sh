#!/bin/bash
SESSION_NAME="h4ze"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    cd "/home/haze/dev/personal/h4ze"
    tmux new-session -d -s "$SESSION_NAME"
    tmux rename-window -t "$SESSION_NAME:0" "nvim"
    tmux send-keys -t "$SESSION_NAME:nvim" "cd '/home/haze/dev/personal/h4ze'" C-m
    tmux send-keys -t "$SESSION_NAME:nvim" "nvim ." C-m
    tmux new-window -t "$SESSION_NAME" -n "git"
    tmux send-keys -t "$SESSION_NAME:git" "cd '/home/haze/dev/personal/h4ze'" C-m
    tmux send-keys -t "$SESSION_NAME:git" "" C-m
    tmux new-window -t "$SESSION_NAME" -n "run"
    tmux send-keys -t "$SESSION_NAME:run" "cd '/home/haze/dev/personal/h4ze'" C-m
    tmux send-keys -t "$SESSION_NAME:run" "npm run dev" C-m
    tmux new-window -t "$SESSION_NAME" -n "zsh"
    tmux send-keys -t "$SESSION_NAME:zsh" "cd '/home/haze/dev/personal/h4ze'" C-m
    tmux send-keys -t "$SESSION_NAME:zsh" "" C-m
fi

tmux attach-session -t "$SESSION_NAME"
