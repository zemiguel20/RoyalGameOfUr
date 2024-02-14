using System.Collections.Generic;

/// <summary>
/// Note: this class is currently static, but we might make it something like a singleton.
/// This class keeps track of all of the moves in a single game, so that this data can be stored.
/// </summary>
public static class GameDataManager 
{
    private static List<TestMoveData> moves;

    public static void OnGameStart()
    {
        moves = new List<TestMoveData>();
    }

    public static void AddMove(TestMoveData moveData)
    {
        moves.Add(moveData);
    }

    // This will likely become a callback on an event from the GameManager.
    public static void OnGameEnd()
    {
        SaveSystem.Save(moves, true);
    }
}
