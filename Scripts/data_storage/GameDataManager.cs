using System.Collections.Generic;

/// <summary>
/// Note: this class is currently static, but we might make it something like a singleton.
/// This class keeps track of all of the moves in a single game, so that this data can be stored.
/// </summary>
public static class GameDataManager 
{
    private static Temp_PlayerData player1Data;
    private static Temp_PlayerData? player2Data;

    private static List<TestMoveData> moves;

    public static void OnGameStart(Temp_PlayerData playerData1, Temp_PlayerData playerData2 = null)
    {
        player1Data = playerData1;
        player2Data = playerData2;

        moves = new List<TestMoveData>();
    }

    public static void AddMove(TestMoveData moveData)
    {
        moves.Add(moveData);
    }

    // This will likely become a callback on an event from the GameManager.
    public static void OnGameEnd()
    {
        GameData gameData = new GameData(player1Data, player2Data, moves);
        SaveSystem.Save(gameData, true);
    }
}
