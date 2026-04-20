using UnityEditor;
using UnityEngine;
using UnityEditor.SceneManagement;

public static class SceneSetup
{
    [MenuItem("Build/Setup Game Scene")]
    public static void SetupScene()
    {
        EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        // --- Camera ---
        var cam = GameObject.Find("Main Camera");
        cam.transform.position = new Vector3(0, 0, -10);
        var camera = cam.GetComponent<Camera>();
        camera.backgroundColor = new Color(0.08f, 0.08f, 0.12f);
        camera.orthographic = true;
        camera.orthographicSize = 5;

        // --- Static background ---
        var bg = CreateSprite("Background", new Color(0.1f, 0.1f, 0.15f));
        bg.transform.position = new Vector3(0, 0, 1);
        bg.transform.localScale = new Vector3(20, 12, 1);

        // --- Player ---
        var player = CreateSprite("Player", new Color(0.2f, 0.6f, 1f));
        player.transform.position = new Vector3(0, -4.0f, 0);
        player.transform.localScale = new Vector3(0.8f, 0.8f, 1);
        player.tag = "Player";

        var rb = player.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0f;
        rb.freezeRotation = true;
        rb.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
        rb.simulated = false;

        var playerCol = player.AddComponent<BoxCollider2D>();
        playerCol.size = new Vector2(0.7f, 0.7f);
        playerCol.isTrigger = true;

        var pc = player.AddComponent<PlayerController>();
        pc.moveSpeed = 5f;

        // --- FallingObject placeholder prefab ---
        System.IO.Directory.CreateDirectory(Application.dataPath + "/Prefabs");

        var foObj = CreateSprite("FallingObject", new Color(1f, 0.8f, 0f));
        foObj.transform.localScale = new Vector3(0.6f, 0.6f, 1);
        foObj.tag = "FallingObject";

        var foRb = foObj.AddComponent<Rigidbody2D>();
        foRb.gravityScale = 0f;
        foRb.freezeRotation = true;

        var foCol = foObj.AddComponent<BoxCollider2D>();
        foCol.isTrigger = false;

        foObj.AddComponent<FallingObject>();
        foObj.SetActive(false);

        // Save as prefab
        var prefabPath = "Assets/Prefabs/FallingObject.prefab";
        PrefabUtility.SaveAsPrefabAsset(foObj, prefabPath);
        Object.DestroyImmediate(foObj);
        var foP = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);

        // --- ObjectSpawner ---
        var spawnerObj = new GameObject("ObjectSpawner");
        var spawner = spawnerObj.AddComponent<ObjectSpawner>();
        spawner.objectPrefabs = new GameObject[] { foP };
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

        EditorSceneManager.SaveScene(
            UnityEngine.SceneManagement.SceneManager.GetActiveScene(),
            "Assets/Scenes/GameScene.unity");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("[KalToeWang] Scene setup complete. Open Assets/Scenes/GameScene.unity");
    }

    private static GameObject CreateSprite(string name, Color color)
    {
        var obj = new GameObject(name);
        var sr = obj.AddComponent<SpriteRenderer>();
        sr.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UISprite.psd");
        sr.color = color;
        return obj;
    }
}
