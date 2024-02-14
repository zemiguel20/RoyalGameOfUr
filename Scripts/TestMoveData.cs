[System.Serializable]
public class TestMoveData
{
    // Since I am using System.Json.Serialization, I need to use properties rather than fields.
	public uint PlayerId { get; private set; }
	public uint PieceId {get; private set;}
	public uint TileId {get; private set;}

    public TestMoveData(uint playerId, uint pieceId, uint tileId)
    {
        PlayerId = playerId;
        PieceId = pieceId;
        TileId = tileId;
    }

    /// <summary>
    /// Override of the ToString method for debugging purposes.
    /// </summary>
    /// <returns> Readable string displaying all values of TestData. </returns>
    public override string ToString()
    {
        return $"Move:\n" +
            $"Player Id: {PlayerId}\n" +
            $"Piece Id: {PieceId}\n" +
            $"Tile Id: {TileId}" ;
    }
}
