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

# Other

**Necessary End Screen Updates:**
1. Open end_screen.tscn (scenes/ui/end_screen.tscn)<br>
    ![Endscreen File Location](endscreen_location.png)
    <br><br>
2. Select the EndScreen node. Here you can change the Survey Link variable.
    ![Endscreen Survey Link](endscreen_survey_link.png)
    <br><br>
3. Select the TextLabel node inside of SurveyMenu. Here you can change the text displayed in the endscreen.
    ![Endscreen Survey Text](endscreen_survey_text.png)
    <br><br>

**To link the session id to the survey:**
1. Open end_screen.gd (scripts/ui/end_screen.gd)
2. Navigate to the bottom of the _on_game_ended function.
    ![Endscreen Code](endscreen_code.png)
3. Make sure the survey_button.url is set to a link with the session id included, for example: survey_link + GameDataCollector.current_game_data.uuid. This format can vary depending on the format you wish the link to be. <br><br>


**Getting familiar with the project** <br>
If you want to add new features to this game. It might be useful to get a better understanding of how the core of the boardgame is implemented.<br><br><br>
![Core Diagram](game_ur_core_diagram.svg)