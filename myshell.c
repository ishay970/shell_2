#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <sys/wait.h>
#include <errno.h>
#include <stdbool.h> 

#define MAX_COMMANDS 100   // Maximum number of commands in history
#define MAX_INPUT_SIZE 100 // Maximum command input size

// Command history variables
char *history[MAX_COMMANDS];
int history_count = 0;

// Store the original PATH variable
char *original_path = NULL;

// Function to add command to history
void add_to_history(char *command) {
    if (history_count < MAX_COMMANDS) {
        history[history_count++] = strdup(command);
    }
}

// Function to print command history
void print_history() {
    for (int i = 0; i < history_count; i++) {
        printf("%d %s\n", i + 1, history[i]);
    }
}

// Function to restore the original PATH environment variable
void restore_original_path() {
    if (original_path != NULL) {
        setenv("PATH", original_path, 1);
        free(original_path);
    }
}

// Signal handler to ensure the PATH is restored on exit
void handle_signal(int sig) {
    restore_original_path();
    exit(0);
}

// Register signal handlers for graceful exit
void register_signal_handlers() {
    signal(SIGINT, handle_signal);  // Handle Ctrl+C
    signal(SIGTERM, handle_signal); // Handle kill signals
    signal(SIGHUP, handle_signal);  // Handle hangup signals
    signal(SIGQUIT, handle_signal); // Handle Ctrl+
    }

void handle_echo(char *args[]) {
    bool inside_quotes = false;
    
    // Loop through the arguments and print them, removing quotes
    for (int i = 1; args[i] != NULL; i++) {
        char *arg = args[i];
        if (arg[0] == '"' || arg[strlen(arg) - 1] == '"') {
            inside_quotes = true;  // We found quotes, skip them
        }

        for (int j = 0; j < strlen(arg); j++) {
            if (arg[j] != '"') {
                printf("%c", arg[j]);
            }
        }

        // Add a space between the arguments
        if (args[i + 1] != NULL) {
            printf(" ");
        }
    }
    printf("\n");
}

int main(int argc, char *argv[]) {
    char input[MAX_INPUT_SIZE];  // Buffer for user input
    char *args[10];              // Parsed command and arguments

    // Save the original PATH
    original_path = strdup(getenv("PATH"));

    // Modify PATH to include directories passed as command-line arguments
    if (argc > 1) {
        char new_path[4096];
        strcpy(new_path, argv[1]);

        for (int i = 2; i < argc; i++) {
            strcat(new_path, ":");
            strcat(new_path, argv[i]);
        }

        // Append the original PATH at the end
        strcat(new_path, ":");
        strcat(new_path, original_path);

        // Set the new PATH
        setenv("PATH", new_path, 1);
    }

    // Register signal handlers for safe termination
    register_signal_handlers();

while (1) {
        // Display prompt and read user input
        printf("$ ");
        fflush(stdout);

        if (fgets(input, sizeof(input), stdin) == NULL) {
            perror("fgets failed");
            continue;
        }

        // Remove newline character from input
        input[strcspn(input, "\n")] = 0;

        // Check if the input is empty (after removing the newline)
        if (strlen(input) == 0) {
            continue;  // Skip to the next iteration if the input is empty
        }

        // Parse input into command and arguments
        args[0] = strtok(input, " ");
        if (args[0] == NULL) {
            continue;  // Skip to the next iteration if no command was entered
        }

        int i = 1;
        while ((args[i++] = strtok(NULL, " ")) != NULL);

        // Handle built-in "exit" command
        if (strcmp(args[0], "exit") == 0) {
            restore_original_path();
            exit(0);
        }

        // Handle built-in "cd" command
        else if (strcmp(args[0], "cd") == 0) {
            if (args[1] == NULL || chdir(args[1]) != 0) {
                perror("cd failed");
            }
            continue;
        }

        // Handle built-in "pwd" command
        else if (strcmp(args[0], "pwd") == 0) {
            char cwd[1024];
            if (getcwd(cwd, sizeof(cwd)) != NULL) {
                printf("%s\n", cwd);
            } else {
                perror("getcwd failed");
            }
            continue;
        }

        // Handle built-in "history" command
        else if (strcmp(args[0], "history") == 0) {
            print_history();
            continue;
        }

        // Handle built-in "echo" command
        else if (strcmp(args[0], "echo") == 0) {
            handle_echo(args);
            continue;
        }

        // For all other commands, execute using fork and execvp
        pid_t pid = fork();
        if (pid == 0) {
            // Child process: Execute the command
            if (execvp(args[0], args) == -1) {
                perror("execvp failed");
                exit(EXIT_FAILURE);
            }
        } else if (pid > 0) {
            // Parent process: Wait for the child process to finish
            wait(NULL);
        } else {
            perror("fork failed");
        }
    }

    return 0;
}