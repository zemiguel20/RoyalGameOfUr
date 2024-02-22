using System.Collections.Generic;

[System.Serializable]
public class GameData
{
    public Temp_PlayerData player1Data { get; set; }
    // P2 can also be an AI.
    public Temp_PlayerData? player2Data { get; set; }

    public List<TestMoveData> allMoves { get; set; }

    public GameData(
        Temp_PlayerData player1Data, 
        Temp_PlayerData player2Data, 
        List<TestMoveData> allMoves)
    {
        this.player1Data = player1Data;
        this.player2Data = player2Data;
        this.allMoves = allMoves;
    }
    // For future: Ruleset
}
