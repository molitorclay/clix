fish_config theme choose 'Bay Cruise'

tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Round --powerline_prompt_heads=Round --powerline_prompt_tails=Round --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Dotted --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Few icons' --transient=Yes

# Aliases
alias vim nvim
alias vi nvim
alias cat bat
alias nb "nix flake update clix --flake ~/nixconf/ && sudo nixos-rebuild switch --flake ~/nixconf/"
