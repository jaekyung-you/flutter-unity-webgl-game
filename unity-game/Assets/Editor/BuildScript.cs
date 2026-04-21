using UnityEditor;
using UnityEngine;
using System.IO;

public class BuildScript
{
    public static void BuildWebGL()
    {
        string buildPath = Path.Combine(Application.dataPath, "../Builds/WebGL");
        Directory.CreateDirectory(buildPath);

        BuildPlayerOptions opts = new BuildPlayerOptions
        {
            scenes = new[] { "Assets/Scenes/GameScene.unity" },
            locationPathName = buildPath,
            target = BuildTarget.WebGL,
            options = BuildOptions.None,
        };

        BuildPipeline.BuildPlayer(opts);
    }
}
