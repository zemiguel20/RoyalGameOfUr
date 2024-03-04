using System.IO;
using System.Text.Json;

/// <summary>
/// Generic C# Saving System, depending on System.Text.Json.
/// </summary>
public static class SaveSystem
{
    public static string fileName = "./LastGame.txt";

    /// <summary>
    /// Writes a json formatted version of an object T to a file.
    /// </summary>
    /// <typeparam name="T"> The data type we want to write to a file. </typeparam>
    /// <param name="saveData"> The data object we want to write to a file. </param>
    /// <param name="overrideFile"> Whether we should override the file, or append text to the file. </param>
    public static void Save<T>(T saveData, bool overrideFile)
    {
        StreamWriter writer = new StreamWriter(fileName, !overrideFile);
        writer.WriteLine(JsonSerializer.Serialize(saveData));
        writer.Close();
        writer.Dispose();
    }

    // Not sure if we would need this, but ill leave it in for now.
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
