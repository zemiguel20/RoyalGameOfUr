using System.IO;
using System.Text.Json;

/// <summary>
/// Generic C# Saving System, depending on System.Text.Json.
/// </summary>
public static class SaveSystem
{
    public static string fileName = "./Test.txt";

    public static void Save<T>(T saveData)
    {
        StreamWriter writer = new StreamWriter(fileName, false);
        writer.WriteLine(JsonSerializer.Serialize(saveData));
        writer.Close();
        writer.Dispose();
    }

    public static T Load<T>()
    {
        if (!File.Exists(fileName)) return default;

        StreamReader reader = new StreamReader(fileName);
        T data = JsonSerializer.Deserialize<T>(reader.BaseStream);
        reader.Close();
        reader.Dispose();

        return data;
    }

    public static void DeleteDataFile()
    {
        if (DataFileExists())
        {
            File.Delete(fileName);
        }
    }

    public static bool DataFileExists()
    {
        return File.Exists(fileName);
    }
}
