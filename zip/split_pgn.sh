
#!/bin/bash

# Function to print usage and exit
function print_usage_and_exit() {
    echo "Usage: $0 <source_pgn_file> <destination_directory>"
    exit 1
}

# Check for the correct number of arguments
if [ "$#" -ne 2 ]; then
    print_usage_and_exit
fi

# Assign arguments to variables
input_file="$1"
dest_dir="$2"

# Check if the source PGN file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' does not exist."
    exit 1
fi

# Check if the destination directory exists, create it if it doesn't
if [ ! -d "$dest_dir" ]; then
    mkdir -p "$dest_dir"
    echo "Created directory '$dest_dir'."
fi

# Initialize variables
game_count=0
game_data=""

# Read the source PGN file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    # Check if the line starts with '[Event ' and contains text inside parentheses
    if [[ "$line" =~ ^\[Event\  ]]; then
        if [ -n "$game_data" ]; then
            # Save the previous game data into a new file
            game_count=$((game_count + 1))
            output_file="$dest_dir/$(basename "$input_file" .pgn)_$game_count.pgn"
            echo "$game_data" > "$output_file"
            echo "Saved game to $output_file"
            game_data=""
        fi
    fi
    # Append the current line to the game data
    game_data+="$line"$'\n'
done < "$input_file"

# Save the last game in the file (if it exists)
if [ -n "$game_data" ]; then
    game_count=$((game_count + 1))
    output_file="$dest_dir/$(basename "$input_file" .pgn)_$game_count.pgn"
    echo "$game_data" > "$output_file"
    echo "Saved game to $output_file"
fi

echo "All games have been split and saved to '$dest_dir'."



# #!/bin/bash

# #filename: split_pgn.sh

# # run:  ./pgn_split.sh capmemel24.pgn try1

# # Function to display usage message
# usage () {
#     echo "Usage: $0 <source_pgn_file> <destination_directory>"
#     exit 1
# }

# if [ "$#" -ne 2 ]; then
#     usage
# fi

# input_file="$1"
# dest_dir="$2"

# if [ ! -f "$input_file" ]; then
#     echo "Error: File '$input_file' does not exist."
#     exit 1
# fi

# # Create the destination directory if it does not exist
# if [ ! -d "$dest_dir" ]; then
#     mkdir -p "$dest_dir"
#     echo "Created directory '$dest_dir'."
# fi

# game_count=0
# output_file=""

# while IFS= read -r line; do

#     if [[ "$line" =~ ^\[Event\  ]]; then
#         if [ -n "$output_file" ]; then
#             output_file=""
#         fi
#         game_count=$((game_count + 1))
#         output_file="$dest_dir/$(basename "$input_file" .pgn)_$game_count.pgn"
#         echo "Saved game to $output_file"
#     fi

#     if [ -n "$output_file" ]; then
#         echo "$line" >> "$output_file"
#     fi
# done < "$input_file"

# echo "All games have been split and saved to '$dest_dir'."
