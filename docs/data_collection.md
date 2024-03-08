# Data Collection

The game has to collect 2 types of data: objective data about gameplay, and subjective data about the player experience.

The subjective data can be filled in through a survey, hosted in an external platform. In the main menu, or at the end of the match (or other possible cases) the link to the survey is shown to the player.

The game will have a `DataCollector`node that receives signals/events from the gameplay state. It collects data for one game, and sends a POST request to the Data Collection Server with all the data from that game, using a `DataSender`.
The `DataSender` can be configured with the network address of the data server, or it can be configured to write to a local file on the computer. This can be decided at build time.

![Data Collection containers diagram](data_collection_container.svg)

TODO: data flow diagram