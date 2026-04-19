using UnityEditor;
using UnityEngine;

/// <summary>
/// Entry point for -executeMethod in batch mode.
/// Run: Unity -batchmode -executeMethod BatchBuild.BuildWebGL -quit
/// </summary>
public static class BatchBuild
{
    public static void BuildWebGL()
    {
        Debug.Log("=== BatchBuild: Setup scene ===");
        SceneSetup.SetupScene();

        Debug.Log("=== BatchBuild: Add scene to build settings ===");
        var scene = new EditorBuildSettingsScene("Assets/Scenes/GameScene.unity", true);
        EditorBuildSettings.scenes = new[] { scene };

        Debug.Log("=== BatchBuild: Apply WebGL settings ===");
        WebGLBuildScript.ApplyWebGLSettings();

        Debug.Log("=== BatchBuild: Build WebGL ===");
        WebGLBuildScript.BuildWebGL();
    }
}
