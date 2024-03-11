[System.Serializable]
public class Temp_PlayerData
{
    public int age { get; private set; }
    public Gender gender { get; private set; }

    public Temp_PlayerData(int age, Gender gender)
    {
        this.age = age;
        this.gender = gender;
    }
}
