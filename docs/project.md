# Setup

This project uses Godot `4.3`. .NET support is not required.

FBX models are imported using the FBX2glTF. Go to `Editor -> Configure FBX Importer...`, download the importer using the link in the window, set the path to the importer's executable, and finally restart the project.

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
