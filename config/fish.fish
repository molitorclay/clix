# Nord theme colors
set --global fish_color_autosuggestion 68615e
set --global fish_color_cancel -r
set --global fish_color_command green
set --global fish_color_comment 68615e
set --global fish_color_cwd green
set --global fish_color_cwd_root red
set --global fish_color_end brblack
set --global fish_color_error red
set --global fish_color_escape yellow
set --global fish_color_history_current --bold
set --global fish_color_host normal
set --global fish_color_host_remote yellow
set --global fish_color_match --background=brblue
set --global fish_color_normal normal
set --global fish_color_operator blue
set --global fish_color_param 9c9491
set --global fish_color_quote yellow
set --global fish_color_redirection cyan
set --global fish_color_search_match bryellow --background=68615e
set --global fish_color_selection white --bold --background=68615e
set --global fish_color_status red
set --global fish_color_user brgreen
set --global fish_color_valid_path --underline
set --global fish_pager_color_completion normal
set --global fish_pager_color_description yellow --dim
set --global fish_pager_color_prefix white --bold
set --global fish_pager_color_progress brwhite --background=cyan
set --global fish_pager_color_selected_background -r

# Tide prompt layout
set --global _tide_left_items os nix_shell pwd git newline character
set --global _tide_right_items status cmd_duration context jobs nix_shell time

# Aliases
alias vim nvim
alias vi nvim
alias cat bat
alias nb "nix flake update clix --flake ~/nixconf/ && sudo nixos-rebuild switch --flake ~/nixconf/"
