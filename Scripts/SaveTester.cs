using Godot;
using System.Collections.Generic;
using System.Text.Json;

public partial class SaveTester : Node
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		GD.Print("Wowie");

        List<TestMoveData> data = new List<TestMoveData>()
		{
			new TestMoveData(1, 1, 1),
			new TestMoveData(2, 1, 3),
			new TestMoveData(1, 1, 4),
			new TestMoveData(2, 1, 5),
		};

		SaveSystem.Save(data);
	}
}
