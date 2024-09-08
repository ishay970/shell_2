#!/bin/bash

# Check if file exists
if [ ! -f "$1" ]; then
    echo "File does not exist: $1"
    exit 1
fi

# Display PGN Metadata
echo "Metadata from PGN file:"
grep -E '^\[' "$1"

# Extract the moves in PGN format
pgn_moves=$(grep -v '^\[' "$1" | tr '\n' ' ' | sed 's/[^0-9a-zA-Z. ]//g')
# Convert PGN moves to UCI using parse_moves.py
uci_moves=$(python3 parse_moves.py "$pgn_moves")
uci_moves_array=($uci_moves)
num_moves=${#uci_moves_array[@]}
function display_board {
    echo "  a b c d e f g h"
    for i in {8..1}; do
        echo -n "$i "
        for j in {a..h}; do
            echo -n "${board[$j$i]} "
        done
        echo "$i"
    done
    echo "  a b c d e f g h"
}

# Initialize board
declare -A board=(
    [a8]="r" [b8]="n" [c8]="b" [d8]="q" [e8]="k" [f8]="b" [g8]="n" [h8]="r"
    [a7]="p" [b7]="p" [c7]="p" [d7]="p" [e7]="p" [f7]="p" [g7]="p" [h7]="p"
    [a2]="P" [b2]="P" [c2]="P" [d2]="P" [e2]="P" [f2]="P" [g2]="P" [h2]="P"
    [a1]="R" [b1]="N" [c1]="B" [d1]="Q" [e1]="K" [f1]="B" [g1]="N" [h1]="R"
)

# Empty squares
for i in {a..h}; do
    for j in {3..6}; do
        board[$i$j]="."
    done
done

display_board
current_move=0
while true; do
    echo "Move $current_move/$num_moves"
    echo "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    read -n 1 key
    echo
    echo

    case $key in
        d)
            if ((current_move < num_moves)); then
                # Process the next move
                current_move=$((current_move + 1))
                # Update board state using UCI move here...
                display_board
            else
                echo "No more moves available."
            fi
            ;;
        a)
            if ((current_move > 0)); then
                # Undo the last move
                current_move=$((current_move - 1))
                # Revert board state here...
                display_board
            fi
            ;;
        w)
            # Reset to start
            current_move=0
            # Reset board state here...
            display_board
            ;;
        s)
            # Go to the end
            current_move=$num_moves
            # Apply all moves here...
            display_board
            ;;
        q)
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid key pressed: $key"
            ;;
    esac
done
