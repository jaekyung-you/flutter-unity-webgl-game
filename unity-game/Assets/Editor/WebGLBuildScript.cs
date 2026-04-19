using UnityEditor;
using UnityEngine;

public class WebGLBuildScript
{
    [MenuItem("Build/Build WebGL")]
    public static void BuildWebGL()
    {
        ApplyWebGLSettings();

        string outputPath = "Builds/WebGL";
        BuildPlayerOptions opts = new BuildPlayerOptions
        {
            scenes = GetScenePaths(),
            locationPathName = outputPath,
            target = BuildTarget.WebGL,
            options = BuildOptions.None
        };

        var report = BuildPipeline.BuildPlayer(opts);
        Debug.Log("Build result: " + report.summary.result);
    }

    public static void ApplyWebGLSettings()
    {
        // Disable compression so Flutter assets loading works without server headers
        PlayerSettings.WebGL.compressionFormat = WebGLCompressionFormat.Disabled;

        // Disable threading (SharedArrayBuffer requires COOP/COEP headers)
        PlayerSettings.WebGL.threadsSupport = false;

        // Memory
        PlayerSettings.WebGL.memorySize = 256;

        // Template
        PlayerSettings.WebGL.template = "APPLICATION:Default";

        Debug.Log("WebGL settings applied.");
    }

    private static string[] GetScenePaths()
    {
        var scenes = new System.Collections.Generic.List<string>();
        foreach (var scene in EditorBuildSettings.scenes)
        {
            if (scene.enabled)
                scenes.Add(scene.path);
        }
        return scenes.ToArray();
    }
}
