using Godot;
using System.Collections.Generic;

public partial class Temp_SaveTester : Node
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		SavePlayerDataExample();
		SaveGameDataExample();
	}

	/// <summary>
	/// Example of how we would save the player data to a file.
	/// We should ask this player data when a player first starts the game.
	/// In the demo of writing to a local file, we should override the file or create a new one.
	/// </summary>
	private static void SavePlayerDataExample()
	{
		Temp_PlayerData playerData = new Temp_PlayerData(21, Gender.Female);
		SaveSystem.Save(playerData, false);
	}

    /// <summary>
    /// Example of how we would save a game.
	/// Some sort of GameDataManager will keep track of all the moves in the game.
	/// When the game end, this component will append all of the moves to the file.
    /// </summary>
    private static void SaveGameDataExample()
	{
		List<TestMoveData> data = new List<TestMoveData>()
		{
			new TestMoveData(1, 1, 1),
			new TestMoveData(2, 1, 3),
			new TestMoveData(1, 1, 4),
			new TestMoveData(2, 1, 5),
		};

		SaveSystem.Save(data, true);
	}
}
