function claude
    if not set -q TMUX
        command claude $argv
        return
    end

    set -l win_name (basename $PWD)
    set -l colors red blue green yellow purple orange pink cyan
    set -l hash (string sub -l 8 (echo -n $win_name | sha256sum))
    set -l idx (math (printf '%d' 0x$hash) % (count $colors) + 1)
    set -l color $colors[$idx]

    # For -c (continue), inject agent-color into the session jsonl before launch
    # so claude picks it up on resume
    if contains -- -c $argv
        set -l slug (string replace -a '/' '-' $PWD)
        set -l project_dir $HOME/.claude/projects/$slug
        if test -d $project_dir
            set -l session_file (ls -t $project_dir/*.jsonl 2>/dev/null | head -1)
            if test -n "$session_file"
                set -l session_id (string replace -r '.*/' '' $session_file | string replace '.jsonl' '')
                echo "{\"type\":\"agent-color\",\"agentColor\":\"$color\",\"sessionId\":\"$session_id\"}" >> $session_file
            end
        end
    end

    command claude --name $win_name $argv
end
