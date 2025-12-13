#!/bin/bash
# Nastavit GIT verzovací nástroj pro spolupráci s github.com

git config --global user.name "Marek Vach"
git config --global user.email "marek@vach.cz"

log "Testuji SSH spojení s GitHubem..."
# Použijeme expect pro automatické 'yes' při první autentizaci
expect <<'EOF'
spawn ssh -T git@github.com
expect {
    "Are you sure you want to continue connecting (yes/no)?" {
        send "yes\r"
        exp_continue
    }
    eof
}
EOF
