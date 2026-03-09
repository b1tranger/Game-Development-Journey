# 🎮 That Level Again — Godot Template Tutorial

> A beginner-friendly guide to understanding this platformer puzzle game template built with **Godot 4.4**

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Godot Concepts for Beginners](#2-godot-concepts-for-beginners)
3. [Project Walkthrough](#3-project-walkthrough)
4. [Game Flow](#4-game-flow)
5. [Example Modifications](#5-example-modifications)

---

## 1. Project Overview

### What is this?

This template is a **2D platformer puzzle game** inspired by ["That Level Again"](https://play.google.com/store/apps/details?id=ru.iamtagir.game.android). The key idea: **every level looks the same** (a room with a player, a door, walls, floor, and ceiling) but the **solution changes each time** based on a hint displayed at the top.

### What you'll learn

- How a Godot project is structured
- How scenes, nodes, and scripts work together
- How physics bodies and collision detection work
- How to use signals for communication between objects
- How to manage game state with an Autoload singleton
- How to transition between scenes (menu → levels → win screen)

### Controls

| Key | Action |
|-----|--------|
| A / ← | Move left |
| D / → | Move right |
| W / ↑ / Space | Jump |

### The 5 Puzzle Levels

| Level | Hint | Solution |
|-------|------|----------|
| 1 | "Just reach the door" | Walk right to the door |
| 2 | "Jump over the obstacle" | Jump over the red spike |
| 3 | "The door is locked. Find the key" | Jump to the platform, grab the yellow key |
| 4 | "Look for a hidden switch" | Walk left to touch the nearly invisible button on the wall |
| 5 | "Sometimes doing nothing is the answer" | Stand completely still for 3 seconds |

---

## 2. Godot Concepts for Beginners

### 2.1 Scenes and Nodes

**Nodes** are the building blocks of everything in Godot. A character, a platform, a button, a sound player — each is a node. Nodes are organized in a **tree structure** (parent → children).

**Scenes** are reusable collections of nodes saved as `.tscn` files. Think of them like **prefabs** or **blueprints**:

```
Level1 (Node2D)              ← Root node of the scene
├── Background (ColorRect)    ← A colored rectangle for the background
├── HintLabel (Label)         ← Text showing the puzzle hint
├── Floor (StaticBody2D)      ← The floor (physics body)
│   ├── FloorCollision        ← Its collision shape
│   └── FloorVisual           ← Its visual representation
├── Player (CharacterBody2D)  ← The player (instanced from player.tscn)
└── Door (Area2D)             ← The door/exit (instanced from door.tscn)
```

**Key takeaway**: Scenes can be **instanced** inside other scenes. Our `player.tscn` scene is reused in every level.

### 2.2 Scripts (GDScript)

Scripts are attached to nodes to add behavior. GDScript looks like Python:

```gdscript
extends CharacterBody2D    # This script extends (inherits from) CharacterBody2D

@export var speed: float = 200.0    # Editable in the Godot editor

func _ready() -> void:
    # Called once when the node enters the scene tree
    print("Player is ready!")

func _physics_process(delta: float) -> void:
    # Called every physics frame (60 times per second)
	# 'delta' is the time since the last frame
    velocity.x = speed
    move_and_slide()
```

**Important functions**:
| Function | When it runs |
|----------|-------------|
| `_ready()` | Once, when the node is added to the scene |
| `_process(delta)` | Every frame (for game logic, UI updates) |
| `_physics_process(delta)` | Every physics frame (for movement, collision) |

### 2.3 Physics Bodies

Godot has three main physics body types:

| Type | Use Case | In This Project |
|------|----------|-----------------|
| **StaticBody2D** | Doesn't move. Walls, floors, platforms. | Floor, Walls, Ceiling, Platforms |
| **CharacterBody2D** | Moves with code. Player characters. | Player |
| **RigidBody2D** | Moves with physics simulation. Not used here. | — |

Each physics body needs a **CollisionShape2D** child to define its physical shape.

### 2.4 Area2D and Collision Detection

An **Area2D** detects when other bodies **enter or exit** its area, but doesn't physically block them. It's perfect for:
- Doors (detect player arrival)
- Spikes (detect player touching them)
- Keys (detect player picking them up)
- Hidden buttons (detect player pressing them)

```gdscript
# Area2D can detect bodies entering
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Player entered!")
```

### 2.5 Signals

**Signals** are Godot's way of letting nodes communicate without directly referencing each other (like events in JavaScript):

```gdscript
# DEFINING a signal (in door.gd)
signal level_completed

# EMITTING a signal
level_completed.emit()

# CONNECTING to a signal (in level script)
$Door.level_completed.connect(_on_level_completed)

func _on_level_completed() -> void:
    GameManager.next_level()
```

**Why signals?** They keep code **decoupled**. The door doesn't need to know about the GameManager — it just says "I was completed" and whoever is listening handles it.

### 2.6 Input Map

Instead of checking specific keys, Godot uses **input actions**. You define named actions (like `"jump"`) and map keys to them in `Project > Project Settings > Input Map`:

```gdscript
# Instead of:  if Input.is_key_pressed(KEY_SPACE):
# Use:
if Input.is_action_just_pressed("jump"):
	velocity.y = jump_velocity
```

This project defines: `move_left` (A/←), `move_right` (D/→), `jump` (Space/W/↑).

### 2.7 Autoload (Singleton)

An **Autoload** is a script that is **always loaded**, persists between scenes, and is accessible from anywhere. Perfect for:
- Game managers (tracking current level)
- Score systems
- Settings/audio managers

Our `GameManager` is an autoload — every script can call `GameManager.next_level()` without needing a reference to it.

### 2.8 Groups

**Groups** are tags you can assign to nodes. They let you find nodes across the scene tree:

```gdscript
# Adding a node to a group
$Door.add_to_group("door")

# Finding a node by group (from anywhere)
var door = get_tree().get_first_node_in_group("door")
```

We use this so the Key and HiddenButton can find the Door to unlock it, without needing a direct reference.

---

## 3. Project Walkthrough

### 3.1 File Structure

```
project-04/
├── project.godot              ← Project configuration (name, input map, autoloads)
├── icon.svg                   ← Project icon
├── EXPLANATION.md             ← This file!
│
├── scripts/
│   └── game_manager.gd       ← Autoload: manages level progression
│
├── components/                ← Reusable game objects
│   ├── player.tscn / .gd     ← Player character (movement + jump)
│   ├── door.tscn / .gd       ← Level exit (can be locked)
│   ├── spike.tscn / .gd      ← Hazard (respawns player)
│   ├── key_item.tscn / .gd   ← Collectible key (unlocks door)
│   └── hidden_button.tscn/.gd ← Hidden wall switch (unlocks door)
│
├── scenes/
│   ├── main_menu.tscn / .gd  ← Title screen with Play/Quit
│   ├── win_screen.tscn / .gd ← Victory screen with Play Again/Menu
│   └── levels/
│       ├── level_1.tscn / .gd ← Walk to door
│       ├── level_2.tscn / .gd ← Jump over spike
│       ├── level_3.tscn / .gd ← Find key to unlock door
│       ├── level_4.tscn / .gd ← Find hidden switch
│       └── level_5.tscn / .gd ← Stand still to open door
```

### 3.2 `project.godot` — The Configuration File

This is the heart of every Godot project. It defines:
- **Project name**: "That Level Again - Template"
- **Main scene**: `res://scenes/main_menu.tscn` — the first scene that loads
- **Window size**: 800×480 pixels (landscape)
- **Input map**: Key bindings for `move_left`, `move_right`, `jump`
- **Autoloads**: `GameManager` loaded from `res://scripts/game_manager.gd`
- **Renderer**: Mobile renderer (good for 2D games)

> 💡 The `res://` path prefix means "relative to the project root". All Godot resource paths use this.

### 3.3 `game_manager.gd` — The Game Brain

```gdscript
var level_scenes: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	...
]
var current_level: int = 0
```

Key functions:
- `start_game()` → Sets level to 0, loads Level 1
- `next_level()` → Increments level, loads next or shows win screen
- `restart_game()` → Resets to Level 1
- `go_to_menu()` → Loads main menu scene
- `get_tree().change_scene_to_file(path)` → This is how Godot switches scenes

### 3.4 `player.gd` — Character Controller

The player uses `CharacterBody2D`, which gives us:
- `velocity` — a Vector2 for movement speed
- `move_and_slide()` — moves the body and handles collisions
- `is_on_floor()` — checks if standing on something solid

```gdscript
func _physics_process(delta):
	# Gravity: accelerate downward
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Jump: only when on the floor
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -350.0  # Negative = upward

	# Horizontal movement
	var direction = Input.get_axis("move_left", "move_right")  # Returns -1, 0, or 1
	velocity.x = direction * 200.0

	move_and_slide()
```

### 3.5 `door.gd` — Level Exit

The door is an `Area2D` that can be **locked or unlocked**:
- When `locked = true`, the door is red and doesn't trigger completion
- When `locked = false`, the door is green and emits `level_completed` when touched
- The `unlock()` function changes the state and updates the visual color

### 3.6 Level Scripts

Each level script follows the same pattern:

```gdscript
func _ready():
	# 1. Connect the door's signal
	$Door.level_completed.connect(_on_level_completed)
	# 2. Set the hint text
	$HintLabel.text = "Level X: ..."
	# 3. (Optional) Set up puzzle-specific logic

func _on_level_completed():
	GameManager.next_level()
```

The puzzle-specific logic varies:
- **Level 3**: Sets `$Door.locked = true`, adds door to `"door"` group so the key can find it
- **Level 4**: Same as Level 3, but uses a `HiddenButton` instead of a key
- **Level 5**: Uses `_process()` to track a `still_timer` — if the player doesn't move for 3 seconds, the door unlocks

---

## 4. Game Flow

```
┌──────────────┐
│  Main Menu   │
│  [PLAY]      │──────────┐
│  [QUIT]      │          │
└──────────────┘          ▼
                   ┌──────────────┐
                   │   Level 1    │
                   │ "Just reach  │
                   │  the door"   │
                   └──────┬───────┘
                          ▼
                   ┌──────────────┐
                   │   Level 2    │
                   │ "Jump over   │
                   │the obstacle" │
                   └──────┬───────┘
                          ▼
                   ┌──────────────┐
                   │   Level 3    │
                   │ "Find the    │
                   │    key"      │
                   └──────┬───────┘
                          ▼
                   ┌──────────────┐
                   │   Level 4    │
                   │ "Hidden      │
                   │  switch"     │
                   └──────┬───────┘
                          ▼
                   ┌──────────────┐
                   │   Level 5    │
                   │"Do nothing"  │
                   └──────┬───────┘
                          ▼
                   ┌──────────────┐
          ┌────────│  Win Screen  │────────┐
          │        │ 🎉 YOU WIN!  │        │
          ▼        └──────────────┘        ▼
   [PLAY AGAIN]                      [MAIN MENU]
   (Level 1)                         (Main Menu)
```

**How it works under the hood**:

1. `project.godot` sets `main_menu.tscn` as the starting scene
2. Clicking "PLAY" calls `GameManager.start_game()`
3. `start_game()` sets `current_level = 0` and calls `change_scene_to_file("level_1.tscn")`
4. Completing a level triggers `GameManager.next_level()`
5. `next_level()` checks if there are more levels. If yes, loads the next. If no, loads `win_screen.tscn`
6. Win screen buttons call `restart_game()` or `go_to_menu()`

---

## 5. Example Modifications

Once you understand the template, try these exercises to deepen your learning!

### 🟢 Exercise 1: Add a New Level

**Difficulty**: Easy | **Concepts**: Scene creation, script extension

1. Create `scenes/levels/level_6.gd`:
```gdscript
extends Node2D

func _ready() -> void:
    $Door.level_completed.connect(_on_level_completed)
    $HintLabel.text = "Level " + str(GameManager.get_level_number()) + ": Your custom hint!"

func _on_level_completed() -> void:
    GameManager.next_level()
```

2. Duplicate `level_1.tscn` and rename it to `level_6.tscn`
3. In the scene, change the root node's script to `level_6.gd`
4. Add your unique puzzle mechanic
5. In `game_manager.gd`, add the new level to the array:
```gdscript
var level_scenes: Array[String] = [
	...
	"res://scenes/levels/level_6.tscn",  # Add this line
]
```

### 🟡 Exercise 2: Add a Timer / Score System

**Difficulty**: Medium | **Concepts**: Autoloads, UI, _process()

1. Add variables to `game_manager.gd`:
```gdscript
var elapsed_time: float = 0.0
var is_timing: bool = false

func _process(delta: float) -> void:
	if is_timing:
		elapsed_time += delta
```

2. Start timing in `start_game()`:
```gdscript
func start_game():
	elapsed_time = 0.0
	is_timing = true
	...
```

3. Stop timing and show the score on the win screen:
```gdscript
# In win_screen.gd _ready():
$CenterContainer/VBoxContainer/TimeLabel.text = "Time: " + str(snapped(GameManager.elapsed_time, 0.01)) + "s"
GameManager.is_timing = false
```

### 🟡 Exercise 3: Replace Rectangles with Sprites

**Difficulty**: Medium | **Concepts**: Sprite2D, textures, resources

1. Find or create simple pixel art images (`.png` files)
2. Put them in a new `assets/` folder
3. In `player.tscn`, replace the `ColorRect` with a `Sprite2D`:
   - Remove the `Visual (ColorRect)` node
   - Add a `Sprite2D` node
   - Set its `Texture` property to your image file
4. Adjust the `CollisionShape2D` size to match your sprite

### 🔴 Exercise 4: Add Sound Effects

**Difficulty**: Medium-Hard | **Concepts**: AudioStreamPlayer, resources

1. Find or create sound files (`.wav` or `.ogg` — Godot doesn't support `.mp3` well)
2. Add them to an `assets/sounds/` folder
3. Add `AudioStreamPlayer` nodes to scenes:
```gdscript
# In player.gd — add a jump sound
func _physics_process(delta):
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
        $JumpSound.play()  # Play the sound!
```

4. In the player scene, add an AudioStreamPlayer child and assign the audio file.

### 🔴 Exercise 5: Add Simple Animations

**Difficulty**: Hard | **Concepts**: AnimationPlayer, Tween, visual feedback

1. Add an `AnimationPlayer` to the player scene
2. Create a "walk" animation that slightly bobs the player up and down
3. Create an "idle" animation
4. Switch between them in the player script:
```gdscript
if direction != 0:
    $AnimationPlayer.play("walk")
else:
    $AnimationPlayer.play("idle")
```

**Alternative**: Use a `Tween` for simpler transitions:
```gdscript
# Door opening effect
func unlock():
    locked = false
    var tween = create_tween()
    tween.tween_property($Visual, "color", Color(0.1, 0.7, 0.2), 0.5)
```

---

## Quick Reference

### Common GDScript patterns in this project

```gdscript
# Change scene
get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Get input axis (-1.0 to 1.0)
var direction = Input.get_axis("move_left", "move_right")

# Check for single button press (not held)
if Input.is_action_just_pressed("jump"):

# Connect a signal
$Door.level_completed.connect(_on_level_completed)

# Emit a signal
level_completed.emit()

# Find a node by group
var door = get_tree().get_first_node_in_group("door")

# Remove a node from the scene
queue_free()

# Access the autoload singleton
GameManager.next_level()
```

### Godot Editor Shortcuts

| Shortcut | Action |
|----------|--------|
| F5 | Run the project |
| F6 | Run the current scene |
| Ctrl+S | Save the current scene |
| Ctrl+Shift+S | Save all scenes |
| Ctrl+A | Add a new node |

---

> **Happy learning!** 🚀 Modify this template, break things, fix them, and experiment.
> That's the best way to learn game development with Godot.
