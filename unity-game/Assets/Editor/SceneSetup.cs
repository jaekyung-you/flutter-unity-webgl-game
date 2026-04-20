using UnityEditor;
using UnityEngine;
using UnityEditor.SceneManagement;
using System.Collections.Generic;
using System.IO;

public static class SceneSetup
{
    [MenuItem("Build/Setup Game Scene")]
    public static void SetupScene()
    {
        // 1. Ensure "FallingObject" tag exists
        EnsureTag("FallingObject");

        // 2. Set all PNGs in Assets/Sprites/ to Sprite import mode
        ConfigureSpriteImporters();
        AssetDatabase.Refresh();

        // 3. Build scene
        EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        // --- Camera ---
        var cam = GameObject.Find("Main Camera");
        cam.transform.position = new Vector3(0, 0, -10);
        var camera = cam.GetComponent<Camera>();
        camera.backgroundColor = new Color(0.08f, 0.08f, 0.12f);
        camera.orthographic = true;
        camera.orthographicSize = 5;

        // --- Static office background ---
        var bg = CreateColorSprite("Background", new Color(0.1f, 0.1f, 0.15f));
        bg.transform.position = new Vector3(0, 0, 1);
        bg.transform.localScale = new Vector3(20, 12, 1);

        // --- Player ---
        var playerGo = new GameObject("Player");
        playerGo.transform.position = new Vector3(0, -4.0f, 0);
        playerGo.tag = "Player";

        var playerSr = playerGo.AddComponent<SpriteRenderer>();
        var playerSprite = FindSprite("char_male_normal");
        if (playerSprite != null)
        {
            playerSr.sprite = playerSprite;
        }
        else
        {
            playerSr.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UISprite.psd");
            playerSr.color = new Color(0.2f, 0.6f, 1f);
            playerGo.transform.localScale = new Vector3(0.8f, 0.8f, 1f);
        }

        var rb = playerGo.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0f;
        rb.freezeRotation = true;
        rb.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
        rb.simulated = false;

        var playerCol = playerGo.AddComponent<BoxCollider2D>();
        playerCol.size = new Vector2(0.7f, 0.7f);
        playerCol.isTrigger = true;

        var pc = playerGo.AddComponent<PlayerController>();
        pc.moveSpeed = 5f;

        // --- FallingObject prefabs (auto-created from non-char_ sprites) ---
        Directory.CreateDirectory(Application.dataPath + "/Prefabs");
        var fallingPrefabs = BuildFallingObjectPrefabs();

        // --- ObjectSpawner ---
        var spawnerObj = new GameObject("ObjectSpawner");
        var spawner = spawnerObj.AddComponent<ObjectSpawner>();
        spawner.objectPrefabs = fallingPrefabs.ToArray();
        spawner.initialFallSpeed = 3f;
        spawner.maxFallSpeed = 9f;
        spawner.rampDuration = 30f;
        spawner.initialSpawnInterval = 1.5f;
        spawner.minSpawnInterval = 0.5f;

        // --- GameManager ---
        var gmObj = new GameObject("GameManager");
        var gm = gmObj.AddComponent<GameManager>();
        gm.player = pc;
        gm.spawner = spawner;
        gm.maxBurnout = 5;

        // --- Save scene ---
        Directory.CreateDirectory(Application.dataPath + "/Scenes");
        EditorSceneManager.SaveScene(
            UnityEngine.SceneManagement.SceneManager.GetActiveScene(),
            "Assets/Scenes/GameScene.unity");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("[KalToeWang] Scene ready — " + fallingPrefabs.Count + " falling object types.");
    }

    // ---------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------

    private static List<GameObject> BuildFallingObjectPrefabs()
    {
        var prefabs = new List<GameObject>();
        var spritesDir = Application.dataPath + "/Sprites";
        if (!Directory.Exists(spritesDir)) return prefabs;

        foreach (var fullPath in Directory.GetFiles(spritesDir, "*.png"))
        {
            var fileName = Path.GetFileNameWithoutExtension(fullPath);
            if (fileName.StartsWith("char_")) continue;  // skip character sprites

            var assetPath = "Assets/Sprites/" + Path.GetFileName(fullPath);
            var sprite = AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
            if (sprite == null) continue;

            var prefabPath = "Assets/Prefabs/" + fileName + ".prefab";
            var existing = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            if (existing != null)
            {
                prefabs.Add(existing);
                continue;
            }

            var obj = new GameObject(fileName);

            var sr = obj.AddComponent<SpriteRenderer>();
            sr.sprite = sprite;

            var foRb = obj.AddComponent<Rigidbody2D>();
            foRb.gravityScale = 0f;
            foRb.freezeRotation = true;

            var foCol = obj.AddComponent<BoxCollider2D>();
            foCol.isTrigger = false;

            obj.AddComponent<FallingObject>();
            obj.tag = "FallingObject";

            var saved = PrefabUtility.SaveAsPrefabAsset(obj, prefabPath);
            Object.DestroyImmediate(obj);
            if (saved != null) prefabs.Add(saved);
        }

        return prefabs;
    }

    private static void ConfigureSpriteImporters()
    {
        var spritesDir = Application.dataPath + "/Sprites";
        if (!Directory.Exists(spritesDir)) return;

        foreach (var fullPath in Directory.GetFiles(spritesDir, "*.png"))
        {
            var assetPath = "Assets/Sprites/" + Path.GetFileName(fullPath);
            var importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
            if (importer == null || importer.textureType == TextureImporterType.Sprite) continue;
            importer.textureType = TextureImporterType.Sprite;
            importer.spriteImportMode = SpriteImportMode.Single;
            AssetDatabase.ImportAsset(assetPath, ImportAssetOptions.ForceUpdate);
        }
    }

    private static Sprite FindSprite(string nameWithoutExt)
    {
        var path = "Assets/Sprites/" + nameWithoutExt + ".png";
        return AssetDatabase.LoadAssetAtPath<Sprite>(path);
    }

    private static void EnsureTag(string tagName)
    {
        var tagManager = new SerializedObject(
            AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
        var tagsProp = tagManager.FindProperty("tags");
        for (int i = 0; i < tagsProp.arraySize; i++)
            if (tagsProp.GetArrayElementAtIndex(i).stringValue == tagName) return;
        tagsProp.InsertArrayElementAtIndex(tagsProp.arraySize);
        tagsProp.GetArrayElementAtIndex(tagsProp.arraySize - 1).stringValue = tagName;
        tagManager.ApplyModifiedProperties();
    }

    private static GameObject CreateColorSprite(string name, Color color)
    {
        var obj = new GameObject(name);
        var sr = obj.AddComponent<SpriteRenderer>();
        sr.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UISprite.psd");
        sr.color = color;
        return obj;
    }
}
