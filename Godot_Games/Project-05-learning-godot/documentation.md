# Project Documentation: Mini-Game Hub

This project is a dedicated **Mini-Game selection Hub** designed as a central portfolio and practical sandbox for learning Godot 4. The core objective of this repository is to systematically master game engine components—physics, animation, input mapping, UI state trees, sound rendering, and dynamic difficulty scaling—by building focused mini-games.

## Project Concept & Vision

When learning game development, building massive projects early on often leads to scope creep and fatigue. By breaking the journey down into bite-sized, single-screen "Mini-Games," we can target one core gameplay loop at a time. 

### Learning Milestone 1: Side-Scrolling Endless Runner
* **Goal**: Understand 2D physics interaction, manual frame-by-frame Sprite2D animation cycling, area collisions, infinite scrolling visual systems, and persistent state management.
* **Theme**: Play as a legendary Samurai dashing through obstacles (slimes) inside an endless scrolling platform.

### Learning Milestone 2: 3D Chicken Walking Simulator
* **Goal**: Master 3D spatial mechanics, including third-person camera orbiting with SpringArm3D collision damping, WASD movement vectors relative to camera perspective, procedural squash-and-stretch mesh animations driven programmatically in GDScript, 3D Area3D collectibles spawning, and glassmorphic HUD overlays.
* **Theme**: Guide a rigless 3D clay chicken model through a beautiful warm-glow sunset pasture, eating gold corn collectibles and clucking at will!

---

## Pedagogical Goals Completed

1. **State-Driven Sprite sheets**: Loaded custom 96x96px and 24x24px sprite sheets manually. Rather than relying on rigid UI configuration tools, animations are driven via lightweight GDScripts to facilitate a precise understanding of offset regions and vertical/horizontal sprite coordinates.
2. **Infinite Frame Repositioning**: Ground assets are repositioned programmatically, creating a seamless scroll effect under the player without the need for infinite physics worlds.
3. **Soundscapes & Polishing**: Integrated background adventure music along with synchronized jumping and injury audio triggers.
4. **Pause/Overlay Architecture**: Implemented custom canvas overlays that toggle engine runtime speed using `PROCESS_MODE_ALWAYS` and `get_tree().paused`.
5. **Procedural Rigless Animation Engine**: Programmed procedural math (sine-wave waddles, landing squash/stretch matrices, and clucking squash triggers) in GDScript to breathe vibrant claymation life into a rigless 3D mesh.
6. **3D Camera Orbiting & Vector Projection**: Built premium third-person orbiting mechanics using a collision-aware `SpringArm3D` and projected visual camera vectors onto the XZ ground plane to enable natural WASD movement.
7. **3D Billboarding & Atmospheric Environments**: Configured a warm sunset sky with fog, SSAO, and glow, and instantiated floating `Label3D` nodes that billboard-face the camera, float upward, and fade out to pop "+1 Corn" scores directly in 3D space.
