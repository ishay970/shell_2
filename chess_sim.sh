#!/usr/bin/bash

function board_to_string()
{
    local output="  a b c d e f g h\n"

    for ((i=0; i<8; i++)); do
        output+=$((8-i))" "
        for ((j=0; j<8; j++)); do
            output+="${board[$i,$j]} "
        done
        output+=$((8-i))"\n"
    done

    output+="  a b c d e f g h\n"

    echo -e "$output"
}

game_file="$1"

if [ -z "$game_file" ]; then
    echo "Missig game file"
    exit 1
fi
if [ ! -f "$game_file" ]; then
    echo "$game_file is not a file"
    exit 1
fi

pgn_moves="$(grep -v "\[" $game_file | xargs)"
if [ -z "$pgn_moves" ]; then
    echo "Invalid game file"
    exit 1
fi

uci_moves=($(python parse_moves.py "$pgn_moves"))
if [ "$uci_moves" = "No valid moves found." ]; then
    echo "No valid moves found"
    exit 1
fi

echo "Metadata from PGN file:"
echo "$(grep "\[" "$game_file")"
echo

curr_index=0
end_index=${#uci_moves[@]}

declare -A board=(
    [0,0]="r" [0,1]="n" [0,2]="b" [0,3]="q" [0,4]="k" [0,5]="b" [0,6]="n" [0,7]="r"
    [1,0]="p" [1,1]="p" [1,2]="p" [1,3]="p" [1,4]="p" [1,5]="p" [1,6]="p" [1,7]="p"
    [2,0]="." [2,1]="." [2,2]="." [2,3]="." [2,4]="." [2,5]="." [2,6]="." [2,7]="."
    [3,0]="." [3,1]="." [3,2]="." [3,3]="." [3,4]="." [3,5]="." [3,6]="." [3,7]="."
    [4,0]="." [4,1]="." [4,2]="." [4,3]="." [4,4]="." [4,5]="." [4,6]="." [4,7]="."
    [5,0]="." [5,1]="." [5,2]="." [5,3]="." [5,4]="." [5,5]="." [5,6]="." [5,7]="."
    [6,0]="P" [6,1]="P" [6,2]="P" [6,3]="P" [6,4]="P" [6,5]="P" [6,6]="P" [6,7]="P"
    [7,0]="R" [7,1]="N" [7,2]="B" [7,3]="Q" [7,4]="K" [7,5]="B" [7,6]="N" [7,7]="R"
)

declare -A game
# Set initial board:
game[0]="$(board_to_string board)"
game_index=1

for ((i=0; i<$end_index; i++)); do

    # Handle castling
    case ${uci_moves[$i]} in

    "e8g8")
        board[0,6]="${board[0,4]}"
        board[0,4]="."
        board[0,5]="${board[0,7]}"
        board[0,7]="."
        ;;
    "e1g1")
        board[7,6]="${board[7,4]}"
        board[7,4]="."
        board[7,5]="${board[7,7]}"
        board[7,7]="."
        ;;
    "e8c8")
        board[0,2]="${board[0,4]}"
        board[0,4]="."
        board[0,3]="${board[0,0]}"
        board[0,0]="."
        ;;
    "e1c1")
        board[7,2]="${board[7,4]}"
        board[7,4]="."
        board[7,3]="${board[7,0]}"
        board[7,0]="."
        ;;
    *)
    # Get the following from uci_moves
        from_raw=$(printf "%d\n" "'${uci_moves[$i]:0:1}")
        from_raw=$((from_raw - 97))
        from_col=$(("${uci_moves[$i]:1:1}"-1))
        from_col=$((7-from_col))
        to_raw=$(printf "%d\n" "'${uci_moves[$i]:2:1}")
        to_raw=$((to_raw - 97))
        to_col=$(("${uci_moves[$i]:3:1}"-1))
        to_col=$((7-to_col))
        to_tool="${uci_moves[$i]:4:1}"
    
        if [ -z "${to_tool}" ]; then
            board[$to_col,$to_raw]="${board[$from_col,$from_raw]}"
        else
    # Handle the case where pown gets the the end of the board
            board[$to_col,$to_raw]=${to_tool}
        fi
        board[$from_col,$from_raw]="."
        ;;
    esac
    game[$game_index]="$(board_to_string board)"
    game_index=$((game_index+1))

done

# Print move 0:
echo "Move $curr_index/$end_index"
echo "${game[$curr_index]}"

while true; do
    echo "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    cmd=""
    while [ -z "${cmd}" ]; do
        read -n 1 cmd > /dev/null
    done

    case $cmd in
    d)
        curr_index=$((curr_index + 1))
        if [ $curr_index -gt $end_index ]; then
            echo "No more moves available."
            curr_index=$end_index
            continue
        fi
        ;;
    a)
        if [ $curr_index != "0" ]; then
            curr_index=$((curr_index - 1))
        fi
        ;;
    w)
        curr_index=0
        ;;
    s)
        curr_index=$end_index
        ;;
    q)
        echo "Exiting."
        echo "End of game."
        exit 0
        ;;
    *)
        echo "Invalid key pressed: $cmd"
        continue
        ;;
    esac

    echo "Move $curr_index/$end_index"
    echo "${game[$curr_index]}"
    
done

