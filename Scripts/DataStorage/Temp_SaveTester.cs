using Godot;
using System.Collections.Generic;

public partial class Temp_SaveTester : Node
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		SaveGameDataExample();
	}

    /// <summary>
    /// Example of how we would save a game.
	/// Some sort of GameDataManager will keep track of all the moves in the game.
	/// When the game ends, this component will append all of the moves to the file.
    /// </summary>
    private static void SaveGameDataExample()
	{
        Temp_PlayerData playerData = new Temp_PlayerData(21, Gender.Female);
        GameDataManager.OnGameStart(playerData);

        GameDataManager.AddMove(new TestMoveData(1, 1, 1));
        GameDataManager.AddMove(new TestMoveData(2, 6, 3));
        GameDataManager.AddMove(new TestMoveData(1, 7, 1));
        GameDataManager.AddMove(new TestMoveData(2, 4, 2));

		GameDataManager.OnGameEnd();
	}
}
