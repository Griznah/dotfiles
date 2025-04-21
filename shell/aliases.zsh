# general aliases
alias ls='eza'
alias v='ls -alh'
alias ll='ls -lh'
alias rwd='cd `/bin/pwd`'
alias dfh='df -h -t ext4 -t zfs -t btrfs|grep -v Filesystem|sort'
alias grep='grep --color'
alias rv='rm -rv'
alias pico='pico -cw'
alias ai='sudo nala install -y'
alias rf='rm -rf'
alias please='sudo'
alias fn='find . -iname'
alias so='ssh bombom@odin'
alias history='history 1'

# Kubernetes related aliases
alias kubecm='kubectl kc'
alias kctx='kubectx'
alias kns='kubens'
alias k='kubectl'
alias h='helm'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
complete -o default -F __start_kubectl k
complete -o default -F __start_kubectl kubecolor
