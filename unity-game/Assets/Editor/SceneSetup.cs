using UnityEditor;
using UnityEngine;
using UnityEditor.SceneManagement;
using System.Collections.Generic;
using System.IO;

public static class SceneSetup
{
    // All sprites are 512x512px at PPU=512 → world size 1.0 unit at scale 1.0
    // Camera orthographicSize=5 → screen height=10 units, iPhone15 portrait width≈4.6 units
    // Player  : target 1.3 units tall → scale 1.3
    // Falling : target 0.7 units tall → scale 0.7 (smaller than player so it's dodgeable)
    private const float PlayerScale  = 1.3f;
    private const float FallingScale = 0.7f;

    [MenuItem("Build/Setup Game Scene")]
    public static void SetupScene()
    {
        EnsureTag("FallingObject");
        ConfigureSpriteImporters();
        AssetDatabase.Refresh();

        EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        // --- Camera ---
        var cam = GameObject.Find("Main Camera");
        cam.transform.position = new Vector3(0, 0, -10);
        var camera = cam.GetComponent<Camera>();
        camera.backgroundColor = new Color(0.08f, 0.08f, 0.12f);
        camera.orthographic = true;
        camera.orthographicSize = 5;

        // --- Background ---
        // game_background.png is 610x1290 at PPU=100 → 6.1x12.9 units
        // scale 0.78 fills camera height (12.9*0.78≈10 units) and width (6.1*0.78≈4.76 units)
        var bgSprite = FindSprite("game_background");
        GameObject bg;
        if (bgSprite != null)
        {
            bg = new GameObject("Background");
            var bgSr = bg.AddComponent<SpriteRenderer>();
            bgSr.sprite = bgSprite;
            bgSr.sortingOrder = -10;
        }
        else
        {
            bg = CreateColorSprite("Background", new Color(0.08f, 0.08f, 0.12f));
        }
        bg.transform.position = new Vector3(0, 0, 1);
        bg.transform.localScale = bgSprite != null ? new Vector3(0.78f, 0.78f, 1f) : new Vector3(20, 12, 1);

        // --- Player ---
        var playerGo = new GameObject("Player");
        playerGo.transform.position = new Vector3(0, -3.8f, 0);
        playerGo.transform.localScale = new Vector3(PlayerScale, PlayerScale, 1f);
        playerGo.tag = "Player";

        var playerSr = playerGo.AddComponent<SpriteRenderer>();
        var normalSprite = FindSprite("char_male_normal");
        playerSr.sprite = normalSprite;

        var rb = playerGo.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0f;
        rb.freezeRotation = true;
        rb.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
        rb.simulated = false;

        var playerCol = playerGo.AddComponent<BoxCollider2D>();
        playerCol.size = new Vector2(0.7f, 0.8f); // local-space collider (~0.91×1.04 world units at scale 1.3)
        playerCol.isTrigger = true;

        var pc = playerGo.AddComponent<PlayerController>();
        pc.moveSpeed = 5f;

        // Assign all character sprites (male default + female)
        pc.normalSprite  = normalSprite;
        pc.hitSprite     = FindSprite("char_male_hit");
        pc.burnoutSprite = FindSprite("char_male_burnout");
        pc.fallSprite    = FindSprite("char_male_fall");
        pc.femaleNormal  = FindSprite("char_female_normal");
        pc.femaleHit     = FindSprite("char_female_hit");
        pc.femaleBurnout = FindSprite("char_female_burnout");
        pc.femaleFall    = FindSprite("char_female_fall");

        // --- FallingObject prefabs ---
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

    private static List<GameObject> BuildFallingObjectPrefabs()
    {
        var prefabs = new List<GameObject>();
        var spritesDir = Application.dataPath + "/Sprites";
        if (!Directory.Exists(spritesDir)) return prefabs;

        foreach (var fullPath in Directory.GetFiles(spritesDir, "*.png"))
        {
            var fileName = Path.GetFileNameWithoutExtension(fullPath);
            if (fileName.StartsWith("char_") || fileName == "game_background") continue;

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
            obj.transform.localScale = new Vector3(FallingScale, FallingScale, 1f);

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
            var fileName = Path.GetFileNameWithoutExtension(fullPath);
            var assetPath = "Assets/Sprites/" + Path.GetFileName(fullPath);
            var importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
            if (importer == null) continue;

            importer.textureType = TextureImporterType.Sprite;
            importer.spriteImportMode = SpriteImportMode.Single;
            // Use same PPU for all; scale is controlled via transform
            importer.spritePixelsPerUnit = fileName == "game_background" ? 100f : 512f;
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
