#!/usr/bin/bash
function set_initial_board()
{
    local board="${1}"
    
    board[0,0]="r"; board[0,1]="n"; board[0,2]="b"; board[0,3]="q"; board[0,4]="k"; board[0,5]="b"; board[0,6]="n"; board[0,7]="r"
    board[1,0]="p"; board[1,1]="p"; board[1,2]="p"; board[1,3]="p"; board[1,4]="p"; board[1,5]="p"; board[1,6]="p"; board[1,7]="p"
    board[2,0]="."; board[2,1]="."; board[2,2]="."; board[2,3]="."; board[2,4]="."; board[2,5]="."; board[2,6]="."; board[2,7]="."
    board[3,0]="."; board[3,1]="."; board[3,2]="."; board[3,3]="."; board[3,4]="."; board[3,5]="."; board[3,6]="."; board[3,7]="."
    board[4,0]="."; board[4,1]="."; board[4,2]="."; board[4,3]="."; board[4,4]="."; board[4,5]="."; board[4,6]="."; board[4,7]="."
    board[5,0]="."; board[5,1]="."; board[5,2]="."; board[5,3]="."; board[5,4]="."; board[5,5]="."; board[5,6]="."; board[5,7]="."
    board[6,0]="P"; board[6,1]="P"; board[6,2]="P"; board[6,3]="P"; board[6,4]="P"; board[6,5]="P"; board[6,6]="P"; board[6,7]="P"
    board[7,0]="R"; board[7,1]="N"; board[7,2]="B"; board[7,3]="Q"; board[7,4]="K"; board[7,5]="B"; board[7,6]="N"; board[7,7]="R"
}

function board_to_string()
{
    local -n board=$1
    local output="  a b c d e f g h\n"

    for ((i=0; i<8; i++)); do
        output+=$((8-i))" "
        for ((j=0; j<8; j++)); do
            output+="${board[$i,$j]} "
        done
        output+=$((8-i))"\n"
    done

    output+="  a b c d e f g h"
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
game_index=0
for ((i=0; i<$end_index; i++)); do
     # Get the following from uci_moves
    from_raw=5
    from_col=2
    to_raw=4
    to_col=5
    # TODO: handle castling 4 different 

    board[to_raw,to_col]="${board[from_raw,from_colcol]}"
    board[from_raw,from_colcol]="."
    game[game_index]="$(board_to_string board)"
    game_index=$((game_index+1))

done

echo "$(board_to_string board)"


while true; do
    exit 0
done





