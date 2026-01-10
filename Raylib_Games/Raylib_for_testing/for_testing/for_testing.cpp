#include "raylib.h"
#include <vector>
#include <string>
#include <stack>

// --- Configuration ---
const int SCREEN_WIDTH = 900;
const int SCREEN_HEIGHT = 720;
const int CELL_SIZE = 40; // The size of one maze cell in pixels

// --- Maze Layout ---
// You can create your own mazes here.
// 'S' = Start, 'E' = End, '#' = Wall, ' ' = Path
const std::vector<std::string> maze_layout = {
    "#####################",
    "#S      #   #       #",
    "# ##### # # # ##### #",
    "# #   #   #   #   # #",
    "# # ### ##### ### # #",
    "#   #   # # #   #   #",
    "### ### # # # ##### #",
    "# #   #   # # #   # #",
    "# ### # ### # # ### #",
    "#   #   # #   #   # #",
    "### ### # # ##### # #",
    "# #   # # #       # #",
    "# # ### # ####### # #",
    "# #     #   #   #   #",
    "# ########### # ### #",
    "#             #   #E#",
    "####################",
};

// --- Game State ---
enum GameState { SOLVING, SOLVED, STUCK };

// Global variables for the solver
Vector2 startPos;
Vector2 endPos;
std::stack<Vector2> path_stack;
std::vector<std::vector<bool>> visited_cells;
GameState current_state;

// --- Helper Functions ---

// Finds the 'S' and 'E' characters in the maze to set start/end positions
void InitializeMaze() {
    for (int y = 0; y < maze_layout.size(); ++y) {
        for (int x = 0; x < maze_layout[y].size(); ++x) {
            if (maze_layout[y][x] == 'S') startPos = { (float)x, (float)y };
            if (maze_layout[y][x] == 'E') endPos = { (float)x, (float)y };
        }
    }
}

// Resets the solver's progress to start over
void ResetSolver() {
    // Clear the stack completely
    while (!path_stack.empty()) {
        path_stack.pop();
    }

    // Reset the visited grid to all false
    visited_cells.assign(maze_layout.size(), std::vector<bool>(maze_layout[0].size(), false));

    // Place the solver at the start
    path_stack.push(startPos);
    visited_cells[(int)startPos.y][(int)startPos.x] = true;
    current_state = SOLVING;
}

// The core logic for the Depth-First Search algorithm
void UpdateSolver() {
    if (current_state != SOLVING || path_stack.empty()) {
        return;
    }

    Vector2 current = path_stack.top();

    // Check if the end has been reached
    if (current.x == endPos.x && current.y == endPos.y) {
        current_state = SOLVED;
        return;
    }

    // --- Explore Neighbors (Up, Down, Left, Right) ---
    int dx[] = { 0, 0, -1, 1 };
    int dy[] = { -1, 1, 0, 0 };
    bool moved = false;

    for (int i = 0; i < 4; ++i) {
        int next_x = current.x + dx[i];
        int next_y = current.y + dy[i];

        // Check if the next cell is valid
        if (next_x >= 0 && next_x < maze_layout[0].size() &&
            next_y >= 0 && next_y < maze_layout.size() &&
            maze_layout[next_y][next_x] != '#' &&
            !visited_cells[next_y][next_x])
        {
            visited_cells[next_y][next_x] = true;
            path_stack.push({ (float)next_x, (float)next_y });
            moved = true;
            break; // Move one step per frame for visualization
        }
    }

    // --- DEAD END: Backtrack ---
    // If no move was made, we are at a dead end. "Loop back" by popping the stack.
    if (!moved) {
        path_stack.pop();
        // If the stack becomes empty, the maze is unsolvable
        if (path_stack.empty()) {
            current_state = STUCK;
        }
    }
}


// --- Main Entry Point ---
int main(void) {
    // Initialization
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Raylib Maze Solver");
    InitializeMaze();
    ResetSolver();
    SetTargetFPS(15); // Controls the speed of the solver

    // Main game loop
    while (!WindowShouldClose()) {
        // --- Update ---
        if (IsKeyPressed(KEY_R)) {
            ResetSolver();
        }
        UpdateSolver();

        // --- Draw ---
        BeginDrawing();
        ClearBackground(DARKGRAY);

        // Center the maze on the screen
        const int offset_x = (SCREEN_WIDTH - (maze_layout[0].size() * CELL_SIZE)) / 2;
        const int offset_y = (SCREEN_HEIGHT - (maze_layout.size() * CELL_SIZE)) / 2;

        // Draw the maze layout
        for (int y = 0; y < maze_layout.size(); ++y) {
            for (int x = 0; x < maze_layout[y].size(); ++x) {
                Color cell_color;
                switch (maze_layout[y][x]) {
                case '#': cell_color = BLACK; break;
                case 'S': cell_color = GREEN; break;
                case 'E': cell_color = RED; break;
                default:
                    // Draw visited cells
                    if (visited_cells[y][x]) {
                        cell_color = Fade(YELLOW, 0.4f);
                    }
                    else {
                        cell_color = LIGHTGRAY;
                    }
                    break;
                }
                DrawRectangle(offset_x + x * CELL_SIZE, offset_y + y * CELL_SIZE, CELL_SIZE, CELL_SIZE, cell_color);
            }
        }

        // Draw the current path from the stack in a different color
        if (!path_stack.empty()) {
            std::stack<Vector2> temp_stack = path_stack;
            while (!temp_stack.empty()) {
                Vector2 pos = temp_stack.top();
                temp_stack.pop();
                if (maze_layout[(int)pos.y][(int)pos.x] != 'S' && maze_layout[(int)pos.y][(int)pos.x] != 'E') {
                    DrawRectangle(offset_x + pos.x * CELL_SIZE, offset_y + pos.y * CELL_SIZE, CELL_SIZE, CELL_SIZE, Fade(BLUE, 0.5f));
                }
            }
        }

        // Draw the solver agent
        if (!path_stack.empty()) {
            Vector2 player_pos = path_stack.top();
            DrawRectangle(
                offset_x + player_pos.x * CELL_SIZE + CELL_SIZE / 4,
                offset_y + player_pos.y * CELL_SIZE + CELL_SIZE / 4,
                CELL_SIZE / 2,
                CELL_SIZE / 2,
                BLUE
            );
        }

        // Draw status text
        const char* status_text = "";
        Color status_color = BLACK;
        switch (current_state) {
        case SOLVING: status_text = "Solving... Press 'R' to reset."; status_color = RAYWHITE; break;
        case SOLVED: status_text = "SOLVED! Press 'R' to play again."; status_color = LIME; break;
        case STUCK: status_text = "STUCK! This maze is unsolvable. Press 'R' to reset."; status_color = RED; break;
        }
        DrawText(status_text, 10, 10, 20, status_color);


        EndDrawing();
    }

    // De-Initialization
    CloseWindow();

    return 0;
}