# Environment Variables
let-env PATH = ($env.HOME | path join "bin" | path append $env.PATH)
let-env PATH = ($env.HOME | path join ".local/bin" | path append $env.PATH)
let-env PATH = ("/usr/local/bin" | path append $env.PATH)
let-env ZSH = ($env.HOME | path join ".oh-my-zsh")
let-env JAVA_HOME = "/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"
let-env PATH = ($env.JAVA_HOME | path join "bin" | path append $env.PATH)
let-env PATH = ($env.HOME | path join "development/flutter/bin" | path append $env.PATH)
let-env PATH = ("/opt/homebrew/opt/ruby/bin" | path append $env.PATH)
let-env PATH = ($env.HOME | path join ".pub-cache/bin" | path append $env.PATH)
let-env CHROME_EXECUTABLE = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
let-env ANDROID_NDK_HOME = "/opt/homebrew/share/android-ndk"
let-env PATH = ($env.HOME | path join "Library/Android/sdk/cmdline-tools/latest/bin" | path append $env.PATH)

# Aliases
alias nv = nvim
alias b = cd ..
alias ssh = nu ~/.config/nushell/config.nu
alias nsh = nvim ~/.config/nushell/config.nu
alias npc = nvim ~/.hammerspoon/init.lua
alias cl = clear

# Searching files
alias fh = nvim (find ~ -type file | fzf)
alias fd = nvim (find ~/Downloads -type file | fzf)
alias fc = nvim (find ~/.config -type file | fzf)

# File-specific Aliases
alias ypdf = yazi (find ~ -type file -name "*.pdf" | fzf)
alias ymd = yazi (find ~ -type file -name "*.md" | fzf)
alias ydart = yazi (find ~ -type file -name "*.dart" | fzf)
alias yjs = yazi (find ~ -type file -name "*.js" | fzf)
alias yhtml = yazi (find ~ -type file -name "*.html" | fzf)
alias ycss = yazi (find ~ -type file -name "*.css" | fzf)
alias yzip = yazi (find ~ -type file -name "*.zip" | fzf)
alias ypng = yazi (find ~ -type file -name "*.png" | fzf)
alias yjpg = yazi (find ~ -type file \( -name "*.jpg" -o -name "*.jpeg" \) | fzf)
alias ysvg = yazi (find ~ -type file -name "*.svg" | fzf)
alias yd = yazi (find ~ -type directory | fzf)

# Directories and Files
alias nly = nvim ~/.config/nvim/lua/migbyte/lazy.lua
alias minit = nvim ~/.config/nvim/init.lua
alias ninit = nvim ~/.config/nvim/lua/migbyte/plugins/init.lua
alias nkey = nvim ~/.config/nvim/lua/migbyte/core/keymaps.lua
alias nvp = cd ~/.config/nvim/lua/migbyte/plugins/
alias cf = cd ~/.config/
alias na = nvim ~/.config/aerospace/aerospace.toml
alias mw = cd ~/flutter_projects/mawjood/mawjood_frontend/
alias web = cd ~/Documents/web/

# Source tmux config
alias stm = tmux source ~/.tmux.conf

# Flutter watch
alias flw = flutter-watch

# Custom Commands
def flutter-watch [@args] {
    tmux send-keys (str join " " "flutter run" $args "--pid-file=/tmp/tf1.pid") Enter
    tmux split-window -v
    tmux send-keys 'npx -y nodemon -e dart -x "cat /tmp/tf1.pid | xargs kill -s USR1"' Enter
    tmux resize-pane -y 5 -t 1
    tmux select-pane -t 0
}

def copy-last-command [] {
    let output = $nu.last_error
    if $output {
        $output | clipboard set
    } else {
        print "No error output to copy"
    }
}
