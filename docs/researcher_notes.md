# Notes for using this game for research

In the `Settings` autoload there is a flag `research_mode`. If this is set to `true`, when the game is finished, a game record file will be created and the end game screen will show a menu with the survey link and a button to send the game record file to a file server. See the `EndScreen` class.

Both the survey and file server URLs are present as constants on the `EndScreen` class. The URLs should be set accordingly. Note: the survey link property in the SurveyButton node will be overridden by the script, so define it in the previous mentioned constant.

The `GameRecord` data structure can be created from the data in the `BoardGame` node. The `BoardGame` holds a list of all the `TurnSummary` objects. The relevant data structures have a `to_json()` method that transforms it into the format that can be saved as file. To change the layout of the data and how it is saved to text, this functions should be adapted.

The `GameRecordSaver` autoload has the API and functionality to write the data to a file, or to send it to the server through HTTP.