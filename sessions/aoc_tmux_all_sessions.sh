#!/bin/bash

SESSION_NAME="aoc"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
    tmux rename-window -t "$SESSION_NAME:0" "nvim"
    tmux send-keys -t "$SESSION_NAME:nvim" "cd '/home/haze/dev/personal/aoc/go-aoc-2024'" C-m
    tmux send-keys -t "$SESSION_NAME:nvim" "nvim ." C-m

    tmux split-window -h -t "$SESSION_NAME:nvim"
    tmux send-keys -t "$SESSION_NAME:nvim" "cd '/home/haze/dev/personal/aoc/go-aoc-2024'" C-m
fi


tmux attach-session -t "$SESSION_NAME:0"
