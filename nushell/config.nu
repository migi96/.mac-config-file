# Nushell Config File
# version = "0.95.0"

# ──────────────────────────────────────────────────────────────────────────────
# Theme Configuration
# ──────────────────────────────────────────────────────────────────────────────
let dark_theme = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: { bg: red fg: white }
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_external_resolved: light_yellow_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_garbage: { fg: white bg: red attr: b}
    shape_glob_interpolation: cyan_bold
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
    shape_raw_string: light_purple
}

# ──────────────────────────────────────────────────────────────────────────────
# Main Configuration
# ──────────────────────────────────────────────────────────────────────────────
$env.config = {
    show_banner: false
    ls: {
        use_ls_colors: true
        clickable_links: true
    }
    rm: {
        always_trash: false
    }
    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
    }
    error_style: "fancy"
    datetime_format: {
        # normal: '%a, %d %b %Y %H:%M:%S %z'
        # table: '%m/%d/%y %I:%M:%S%p'
    }
    explore: {
        status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" },
        command_bar_text: { fg: "#C4C9C6" },
        highlight: { fg: "black", bg: "yellow" },
        status: {
            error: { fg: "white", bg: "red" },
            warn: {}
            info: {}
        },
        selected_cell: { bg: light_blue },
    }
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        external: {
            enable: true
            max_results: 100
            completer: null
        }
        use_ls_colors: true
    }
    filesize: {
    }
    cursor_shape: {
        emacs: block
        vi_insert: block
        vi_normal: underscore
    }
    color_config: $dark_theme
    footer_mode: 25
    float_precision: 2
    buffer_editor: "nvim"
    use_ansi_coloring: true
    bracketed_paste: true
    edit_mode: vi
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }
    render_right_prompt_on_last_line: false
    use_kitty_protocol: false
    highlight_resolved_externals: false
    recursion_limit: 50
    plugins: {}
    plugin_gc: {
        default: {
            enabled: true
            stop_after: 10sec
        }
        plugins: {}
    }
    hooks: {
        pre_prompt: [{||
            # HypeShell hook - runs after command completes, before next prompt
            let start = ($env.HYPESHELL_START? | default 0)
            if $start > 0 {
                let exit_code = $env.LAST_EXIT_CODE
                let now = (date now | format date '%s' | into int)
                let duration = $now - $start
                let cwd = $env.PWD
                let git_branch = (do -i { ^git symbolic-ref --short HEAD } | complete | if $in.exit_code == 0 { $in.stdout | str trim } else { "" })
                let last_cmd = (try { history | last 1 | get command.0 } catch { "" })
                let msg = $"($exit_code)|($duration)|($cwd)|($git_branch)||($last_cmd)"
                do -i { $msg | ^nc -U $"($env.HOME)/.hypeshell/monitor.sock" }
                $env.HYPESHELL_START = 0
            }
        }]
        pre_execution: [{||
            # HypeShell hook - record command start time
            $env.HYPESHELL_START = (date now | format date '%s' | into int)
        }]
        env_change: {
            PWD: [{|before, after| null }]
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
    }
    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: ide_completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: ide
                min_completion_width: 0,
                max_completion_width: 50,
                max_completion_height: 10,
                padding: 0,
                border: true,
                cursor_offset: 0,
                description_mode: "prefer_right"
                min_description_width: 0
                max_description_width: 50
                max_description_height: 10
                description_offset: 1
                correct_cursor_pos: false
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]
    keybindings: [
        {
            name: delete_one_word_backward
            modifier: alt
            keycode: backspace
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: backspaceword}
        }
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: ide_completion_menu
            modifier: control
            keycode: char_n
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: ide_completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: help_menu }
        }
        {
            name: completion_previous_menu
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
        }
        {
            name: next_page_menu
            modifier: control
            keycode: char_x
            mode: emacs
            event: { send: menupagenext }
        }
        {
            name: undo_or_previous_page_menu
            modifier: control
            keycode: char_z
            mode: emacs
            event: {
                until: [
                    { send: menupageprevious }
                    { edit: undo }
                ]
            }
        }
        {
            name: escape
            modifier: none
            keycode: escape
            mode: [emacs, vi_normal, vi_insert]
            event: { send: esc }
        }
        {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
        }
        {
            name: quit_shell
            modifier: control
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrld }
        }
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: { send: clearscreen }
        }
        {
            name: search_history
            modifier: control
            keycode: char_q
            mode: [emacs, vi_normal, vi_insert]
            event: { send: searchhistory }
        }
        {
            name: open_command_editor
            modifier: control
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: openeditor }
        }
        {
            name: move_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: move_down
            modifier: none
            keycode: down
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: move_left
            modifier: none
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuleft }
                    { send: left }
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: none
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { send: menuright }
                    { send: right }
                ]
            }
        }
        {
            name: move_one_word_left
            modifier: control
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movewordleft }
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: control
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintwordcomplete }
                    { edit: movewordright }
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: none
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: char_a
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: none
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { edit: movetolineend }
                ]
            }
        }
        {
            name: move_to_line_end_or_take_history_hint
            modifier: control
            keycode: char_e
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: historyhintcomplete }
                    { edit: movetolineend }
                ]
            }
        }
        {
            name: move_to_line_start
            modifier: control
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolinestart }
        }
        {
            name: move_to_line_end
            modifier: control
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: { edit: movetolineend }
        }
        {
            name: move_up
            modifier: control
            keycode: char_p
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menuup }
                    { send: up }
                ]
            }
        }
        {
            name: move_down
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menudown }
                    { send: down }
                ]
            }
        }
        {
            name: delete_one_character_backward
            modifier: none
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspace }
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: backspace
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: delete_one_character_forward
            modifier: none
            keycode: delete
            mode: [emacs, vi_insert]
            event: { edit: delete }
        }
        {
            name: delete_one_character_forward
            modifier: control
            keycode: delete
            mode: [emacs, vi_insert]
            event: { edit: delete }
        }
        {
            name: delete_one_character_backward
            modifier: control
            keycode: char_h
            mode: [emacs, vi_insert]
            event: { edit: backspace }
        }
        {
            name: delete_one_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: move_left
            modifier: none
            keycode: backspace
            mode: vi_normal
            event: { edit: moveleft }
        }
        {
            name: newline_or_run_command
            modifier: none
            keycode: enter
            mode: emacs
            event: { send: enter }
        }
        {
            name: move_left
            modifier: control
            keycode: char_b
            mode: emacs
            event: {
                until: [
                    { send: menuleft }
                    { send: left }
                ]
            }
        }
        {
            name: move_right_or_take_history_hint
            modifier: control
            keycode: char_f
            mode: emacs
            event: {
                until: [
                    { send: historyhintcomplete }
                    { send: menuright }
                    { send: right }
                ]
            }
        }
        {
            name: redo_change
            modifier: control
            keycode: char_g
            mode: emacs
            event: { edit: redo }
        }
        {
            name: undo_change
            modifier: control
            keycode: char_z
            mode: emacs
            event: { edit: undo }
        }
        {
            name: paste_before
            modifier: control
            keycode: char_y
            mode: emacs
            event: { edit: pastecutbufferbefore }
        }
        {
            name: cut_word_left
            modifier: control
            keycode: char_w
            mode: emacs
            event: { edit: cutwordleft }
        }
        {
            name: cut_line_to_end
            modifier: control
            keycode: char_k
            mode: emacs
            event: { edit: cuttoend }
        }
        {
            name: cut_line_from_start
            modifier: control
            keycode: char_u
            mode: emacs
            event: { edit: cutfromstart }
        }
        {
            name: swap_graphemes
            modifier: control
            keycode: char_t
            mode: emacs
            event: { edit: swapgraphemes }
        }
        {
            name: move_one_word_left
            modifier: alt
            keycode: left
            mode: emacs
            event: { edit: movewordleft }
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: right
            mode: emacs
            event: {
                until: [
                    { send: historyhintwordcomplete }
                    { edit: movewordright }
                ]
            }
        }
        {
            name: move_one_word_left
            modifier: alt
            keycode: char_b
            mode: emacs
            event: { edit: movewordleft }
        }
        {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: char_f
            mode: emacs
            event: {
                until: [
                    { send: historyhintwordcomplete }
                    { edit: movewordright }
                ]
            }
        }
        {
            name: delete_one_word_forward
            modifier: alt
            keycode: delete
            mode: emacs
            event: { edit: deleteword }
        }
        {
            name: delete_one_word_backward
            modifier: alt
            keycode: backspace
            mode: emacs
            event: { edit: backspaceword }
        }
        {
            name: delete_one_word_backward
            modifier: alt
            keycode: char_m
            mode: emacs
            event: { edit: backspaceword }
        }
        {
            name: cut_word_to_right
            modifier: alt
            keycode: char_d
            mode: emacs
            event: { edit: cutwordright }
        }
        {
            name: upper_case_word
            modifier: alt
            keycode: char_u
            mode: emacs
            event: { edit: uppercaseword }
        }
        {
            name: lower_case_word
            modifier: alt
            keycode: char_l
            mode: emacs
            event: { edit: lowercaseword }
        }
        {
            name: capitalize_char
            modifier: alt
            keycode: char_c
            mode: emacs
            event: { edit: capitalizechar }
        }
        {
            name: copy_selection
            modifier: control_shift
            keycode: char_c
            mode: emacs
            event: { edit: copyselection }
        }
        {
            name: cut_selection
            modifier: control_shift
            keycode: char_x
            mode: emacs
            event: { edit: cutselection }
        }
        {
            name: select_all
            modifier: control_shift
            keycode: char_a
            mode: emacs
            event: { edit: selectall }
        }
    ]
}

# ──────────────────────────────────────────────────────────────────────────────
# Navigation & Directory Shortcuts
# ──────────────────────────────────────────────────────────────────────────────
def --env cx [arg] {
    cd $arg
    ls -l
}

# ──────────────────────────────────────────────────────────────────────────────
# General Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias nv = nvim
alias v = nvim
alias d = nvim .
alias b = cd ..
alias c = clear
alias cl = clear
alias lea = exit
alias y = yazi
alias ai = yazi
alias mx = tmux
alias co = opencode
alias gem = gemini

# ──────────────────────────────────────────────────────────────────────────────
# Config & Shell Management
# ──────────────────────────────────────────────────────────────────────────────
alias nsh = nvim ~/.config/nushell/config.nu
# Note: 'source' is a parser keyword and cannot be aliased in nushell
# Use 'source ~/.config/nushell/config.nu' directly, or restart nushell

# ──────────────────────────────────────────────────────────────────────────────
# Development Tools
# ──────────────────────────────────────────────────────────────────────────────
alias pa = php artisan
alias ser = php artisan serve
alias pip = /opt/homebrew/bin/pip3
alias hss = python hype.py --config
alias hst = python hype.py
alias th = flutter-watch

# ──────────────────────────────────────────────────────────────────────────────
# Directory Navigation Shortcuts
# ──────────────────────────────────────────────────────────────────────────────
alias mow = cd ~/development/web/
alias mla = cd ~/development/web/laravel/
alias mob = cd ~/development/mobile/flutter_projects/
alias moz = cd ~/development/mobile/flutter_projects/zien/Alzien-Cars-App/
alias yar = cd ~/development/mobile/flutter_projects/sa/SayaraTech-Cutomer-App
alias vel = cd ~/development/laravel/
alias nvp = cd ~/.config/nvim/lua/migbyte/plugins/

# ──────────────────────────────────────────────────────────────────────────────
# ls/eza Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias l = ls --all
alias ll = ls -l
alias lt = eza --tree --level=2 --long --icons --git

# ──────────────────────────────────────────────────────────────────────────────
# Git Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias gc = git commit -m
alias gca = git commit -a -m
alias gp = git push origin HEAD
alias gpu = git pull origin
alias gst = git status
alias glog = git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit
alias gdiff = git diff
alias gco = git checkout
alias gb = git branch
alias gba = git branch -a
alias gadd = git add
alias ga = git add -p
alias gcoall = git checkout -- .
alias gr = git remote
alias gre = git reset

# ──────────────────────────────────────────────────────────────────────────────
# Kubernetes Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias k = kubectl
alias ka = kubectl apply -f
alias kg = kubectl get
alias kd = kubectl describe
alias kdel = kubectl delete
alias kl = kubectl logs -f
alias kgpo = kubectl get pod
alias kgd = kubectl get deployments
alias kc = kubectx
alias kns = kubens
alias ke = kubectl exec -it

# ──────────────────────────────────────────────────────────────────────────────
# Home Manager & Aerospace (if using Nix)
# ──────────────────────────────────────────────────────────────────────────────
alias hms = /nix/store/6kc5srg83nkyg21am089xx7pvq44kn2c-home-manager/bin/home-manager switch
alias as = aerospace
alias asr = atuin scripts run

# ──────────────────────────────────────────────────────────────────────────────
# Custom Functions
# ──────────────────────────────────────────────────────────────────────────────

# Aerospace window switcher with fzf
def ff [] {
    aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
}

# Create directory and cd into it
def mkd [dirname: string] {
    mkdir $dirname
    cd $dirname
}

# Copy last command output to clipboard
def clc [] {
    let cmd = (history | last | get command)
    let output = (nu -c $cmd | complete)
    let result = $"Command: ($cmd)\n\nOutput:\n($output.stdout)"
    $result | pbcopy
    print "Copied to clipboard!"
}

# Flutter watch with tmux - split window and auto-reload on dart file changes
def flutter-watch [...args: string] {
    let flutter_args = ($args | str join " ")
    tmux send-keys $"flutter run ($flutter_args) --pid-file=/tmp/tf1.pid" Enter
    tmux split-window -v
    tmux send-keys 'npx -y nodemon -e dart -x "cat /tmp/tf1.pid | xargs kill -s USR1"' Enter
    tmux resize-pane -y 5 -t 1
    tmux select-pane -t 0
}

# Alternate name for flutter-watch
alias flw = flutter-watch

# ──────────────────────────────────────────────────────────────────────────────
# Neovim / Avante Helpers
# ──────────────────────────────────────────────────────────────────────────────

# Open Neovim with Avante zen mode
def avn [] {
    nvim -c 'lua vim.defer_fn(function()require("avante.api").zen_mode()end, 100)'
}

# Clear Avante cache
def avc [] {
    bash -c 'rm -rf ~/.local/share/nvim/avante* ~/.local/state/nvim/avante* ~/.cache/nvim/avante*'
    print "Avante cache cleared"
}

# Clear Avante cache and open Neovim
def avr [] {
    avc
    nvim
}

# Clear github-copilot config
def avd [] {
    rm -rf ~/.config/github-copilot
}

# Clear Copilot auth and prompt re-authentication
def cre [] {
    rm -rf ~/.config/github-copilot
    rm -rf ~/.local/share/nvim/github-copilot
    print "Copilot auth cleared! Restart Neovim and run <leader>ca to re-authenticate."
}

# ──────────────────────────────────────────────────────────────────────────────
# Flutter Helpers
# ──────────────────────────────────────────────────────────────────────────────

# Flutter full clean: clean + pub get + pod install
def fclean [] {
    flutter clean
    flutter pub get
    bash -c "cd ios && pod install --repo-update"
}

# ──────────────────────────────────────────────────────────────────────────────
# HypeShell Helpers
# ──────────────────────────────────────────────────────────────────────────────

# Run hype.py from current directory
def hy [] {
    bash -c "./hype.py --config"
}

# ──────────────────────────────────────────────────────────────────────────────
# SSH Shortcuts
# ──────────────────────────────────────────────────────────────────────────────

# SSH to Alzien Hetzner server
def azs [] {
    ssh -i ~/.ssh/alzien_hetzner root@46.225.163.21
}

# ──────────────────────────────────────────────────────────────────────────────
# Kitty Helpers
# ──────────────────────────────────────────────────────────────────────────────

# Run kitty commands script
def kitty-cmds [] {
    bash $"($env.HOME)/.config/kitty/kitty_commands.sh"
}

alias cy = kitty-cmds

# ──────────────────────────────────────────────────────────────────────────────
# Git Config Helper
# ──────────────────────────────────────────────────────────────────────────────

# Interactive git user/email configuration
def gitconfig [] {
    print "Git Configuration Setup"
    print "----------------------"

    let git_username = (input "Enter your Git username: ")
    let git_email = (input "Enter your Git email: ")
    let scope_input = (input "Set globally or locally? (global/local) [default: global]: ")
    let scope = if ($scope_input | is-empty) { "global" } else { $scope_input }

    git config $"--($scope)" user.name $git_username
    git config $"--($scope)" user.email $git_email

    let name = (git config $"--($scope)" user.name)
    let email = (git config $"--($scope)" user.email)

    print $"\nGit configuration set successfully!"
    print $"Name:  ($name)"
    print $"Email: ($email)"
    print $"Scope: ($scope)"
}

# ──────────────────────────────────────────────────────────────────────────────
# File Finding & Opening Functions
# ──────────────────────────────────────────────────────────────────────────────

# Find files and open in Neovim
def fh [] { nvim (fd --type f . ~ | fzf) }
def fd-home [] { nvim (fd --type f . ~/Downloads | fzf) }
def fc [] { nvim (fd --type f . ~/.config | fzf) }

# Find specific file types and open in Yazi
def ypdf [] { yazi (fd --type f -e pdf . ~ | fzf) }
def ymd [] { yazi (fd --type f -e md . ~ | fzf) }
def ydart [] { yazi (fd --type f -e dart . ~ | fzf) }
def yjs [] { yazi (fd --type f -e js . ~ | fzf) }
def yhtml [] { yazi (fd --type f -e html . ~ | fzf) }
def ycss [] { yazi (fd --type f -e css . ~ | fzf) }
def yzip [] { yazi (fd --type f -e zip . ~ | fzf) }
def ypng [] { yazi (fd --type f -e png . ~ | fzf) }
def yjpg [] { yazi (fd --type f -e jpg -e jpeg . ~ | fzf) }
def ysvg [] { yazi (fd --type f -e svg . ~ | fzf) }
def yd [] { yazi (fd --type d . ~ | fzf) }

# ──────────────────────────────────────────────────────────────────────────────
# Source External Configurations
# (env.nu is loaded by nushell before config.nu, generating these cache files)
# ──────────────────────────────────────────────────────────────────────────────
source ~/.zoxide.nu
source ~/.cache/carapace/init.nu
source ~/.local/share/atuin/init.nu
use ~/.cache/starship/init.nu

