# Project setup

This project uses Godot 4.2 . C# support is not required, but using the .NET version of the engine will still work just as fine.

The project contains models in FBX format, and thus the Godot Engine's FBX2glTF importer is needed.
The engine should automatically prompt to install and configure the importer, but if not, then go to `Editor -> Configure FBX Importer...`, which manually opens the corresponding  window.

# Folders

The following list describes the upper level folder of the project, which mainly organize files by type. Within these folders some files can be further organized by scope, but it is not a strict rule.
- `addons`: external plugins
- `animations`: animation data resources.
- `audio`: game sounds.
- `builds`: target folder when exporting the project.
- `docs`: technical documentation of the project.
- `materials`: all materials.
- `models`: all 3D model files.
- `physics_materials`: all physics materials.
- `resources`: custom resource files (e.g. rulesets).
- `scenes`: all scenes and prefabs.
- `scripts`: all code, mainly game scripts.
- `shaders`: all shaders
- `test`: isolated test scenes for whatever needs testing (e.g. dice rolling physics)
- `textures`: all textures used by materials and 3D models
- `ui`: contains fonts, sprites, and resources used within the game UI.

# Architecture

The following diagram gives a general overview of the core parts of the game. For more details there are comments in the code, and also take a look at the scene structure.


![](images/game_ur_core_diagram.svg)