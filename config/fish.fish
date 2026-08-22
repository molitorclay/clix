

fish_config theme choose 'Bay Cruise'

set -g fish_greeting ""
set -g fish_key_bindings fish_vi_key_bindings

set -U tide_character_icon '🐠'
set -U tide_character_vi_icon_default '🐡'
set -U tide_character_vi_icon_visual '🖌️'

# Set fish prompt
if not set -q _tide_left_items
#  tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Round --powerline_prompt_heads=Round --powerline_prompt_tails=Round --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Dotted --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Few icons' --transient=Yes
  tide configure --auto --style=Classic --prompt_colors='True color' --classic_prompt_color=Dark --show_time='24-hour format' --classic_prompt_separators=Slanted --powerline_prompt_heads=Slanted --powerline_prompt_tails=Slanted --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Few icons' --transient=No
end

# Aliases
set -gx EDITOR nvim
alias vim nvim
alias vi nvim
alias cat bat
alias ls eza
alias tree 'eza --tree -I ".git"'
alias grep ripgrep

# nix aliases
alias nb "nix flake update clix --flake ~/nixconf/ && sudo nixos-rebuild switch --flake ~/nixconf/"
alias fastfetch 'nix run nixpkgs#fastfetch -- --logo NixOS --logo-color-1 "#FF0018" --logo-color-2 "#FF8C00" --logo-color-3 "#FFFF41" --logo-color-4 "#008018" --logo-color-5 "#0000F9" --logo-color-6 "#86007D"'

function ns
    NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#{ $argv }
end

function nr
    NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#$argv[1] -- $argv[2..]
end
