using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

/// <summary>
/// Menu: Build/Setup Game Scene
/// Programmatically creates the entire game scene so the user doesn't have to wire
/// everything up manually in the Inspector.
/// </summary>
public static class SceneSetup
{
    [MenuItem("Build/Setup Game Scene")]
    public static void SetupScene()
    {
        var scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        // --- Camera ---
        var cam = GameObject.Find("Main Camera");
        cam.transform.position = new Vector3(0, 0, -10);
        cam.GetComponent<Camera>().backgroundColor = new Color(0.53f, 0.81f, 0.98f);
        cam.GetComponent<Camera>().orthographic = true;
        cam.GetComponent<Camera>().orthographicSize = 5;

        // --- Ground ---
        var ground = CreateSprite("Ground", new Color(0.4f, 0.8f, 0.4f));
        ground.transform.position = new Vector3(0, -3.5f, 0);
        ground.transform.localScale = new Vector3(30, 1, 1);
        ground.tag = "Ground";
        AddBoxCollider(ground);
        var groundLayer = CreateLayer("Ground");
        ground.layer = groundLayer;

        // --- Player ---
        var player = CreateSprite("Player", Color.blue);
        player.transform.position = new Vector3(-5, -2.8f, 0);
        player.transform.localScale = new Vector3(0.8f, 0.8f, 1);
        player.tag = "Player";
        player.layer = groundLayer;

        var rb = player.AddComponent<Rigidbody2D>();
        rb.freezeRotation = true;
        rb.collisionDetectionMode = CollisionDetectionMode2D.Continuous;

        var playerCol = player.AddComponent<BoxCollider2D>();
        playerCol.size = new Vector2(0.8f, 0.8f);

        var playerAnim = player.AddComponent<Animator>();

        var groundCheck = new GameObject("GroundCheck");
        groundCheck.transform.SetParent(player.transform);
        groundCheck.transform.localPosition = new Vector3(0, -0.45f, 0);

        var pc = player.AddComponent<PlayerController>();
        pc.jumpForce = 12f;
        pc.groundLayer = LayerMask.GetMask("Ground");
        pc.groundCheck = groundCheck.transform;

        // --- Obstacle Prefab (Cactus placeholder) ---
        var obstaclePrefabDir = "Assets/Prefabs";
        System.IO.Directory.CreateDirectory(Application.dataPath + "/../Assets/Prefabs");

        var cactus = CreateSprite("Cactus", Color.green);
        cactus.transform.localScale = new Vector3(0.6f, 1.2f, 1);
        cactus.tag = "Obstacle";
        AddBoxCollider(cactus);
        cactus.AddComponent<ObstacleMover>();
        cactus.SetActive(false);

        // --- Spawner ---
        var spawnerObj = new GameObject("ObstacleSpawner");
        var spawner = spawnerObj.AddComponent<ObstacleSpawner>();
        spawner.spawnX = 12f;
        spawner.spawnY = -2.7f;

        // --- Background scrollers (2 planes for seamless loop) ---
        var bg1 = CreateSprite("Background1", new Color(0.53f, 0.81f, 0.98f));
        bg1.transform.position = new Vector3(0, 1, 1);
        bg1.transform.localScale = new Vector3(22, 10, 1);
        var sc1 = bg1.AddComponent<BackgroundScroller>();
        sc1.scrollSpeed = 1.5f;
        sc1.resetX = 22f;

        var bg2 = CreateSprite("Background2", new Color(0.53f, 0.81f, 0.98f));
        bg2.transform.position = new Vector3(22, 1, 1);
        bg2.transform.localScale = new Vector3(22, 10, 1);
        var sc2 = bg2.AddComponent<BackgroundScroller>();
        sc2.scrollSpeed = 1.5f;
        sc2.resetX = 22f;

        // --- Canvas UI ---
        var canvas = new GameObject("Canvas");
        var c = canvas.AddComponent<Canvas>();
        c.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.AddComponent<CanvasScaler>();
        canvas.AddComponent<GraphicRaycaster>();

        var scoreObj = CreateText("ScoreText", canvas.transform, "0",
            new Vector2(0, -30), new Vector2(200, 60), 48, TextAnchor.UpperCenter);

        var gameOverPanel = new GameObject("GameOverPanel");
        gameOverPanel.transform.SetParent(canvas.transform, false);
        var panelImg = gameOverPanel.AddComponent<Image>();
        panelImg.color = new Color(0, 0, 0, 0.6f);
        var rt = gameOverPanel.GetComponent<RectTransform>();
        rt.anchorMin = Vector2.zero;
        rt.anchorMax = Vector2.one;
        rt.offsetMin = rt.offsetMax = Vector2.zero;

        var gameOverText = CreateText("GameOverText", gameOverPanel.transform, "GAME OVER",
            Vector2.zero, new Vector2(400, 80), 56, TextAnchor.MiddleCenter);

        var bestScoreText = CreateText("BestScoreText", gameOverPanel.transform, "BEST: 0",
            new Vector2(0, -70), new Vector2(300, 50), 32, TextAnchor.MiddleCenter);

        var restartText = CreateText("RestartText", gameOverPanel.transform, "탭하여 재시작",
            new Vector2(0, -130), new Vector2(300, 50), 28, TextAnchor.MiddleCenter);

        gameOverPanel.SetActive(false);

        // --- GameManager ---
        var gmObj = new GameObject("GameManager");
        var gm = gmObj.AddComponent<GameManager>();
        gm.scoreText = scoreObj.GetComponent<Text>();
        gm.gameOverPanel = gameOverPanel;
        gm.bestScoreText = bestScoreText.GetComponent<Text>();
        gm.player = pc;
        gm.spawner = spawner;
        gm.scrollers = new BackgroundScroller[] { sc1, sc2 };

        // Link spawner prefabs
        // (set via Inspector after prefab is saved)

        EditorSceneManager.SaveScene(scene, "Assets/Scenes/GameScene.unity");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("Scene setup complete. Open Assets/Scenes/GameScene.unity");
    }

    private static GameObject CreateSprite(string name, Color color)
    {
        var obj = new GameObject(name);
        var sr = obj.AddComponent<SpriteRenderer>();
        sr.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UISprite.psd");
        sr.color = color;
        return obj;
    }

    private static void AddBoxCollider(GameObject obj)
    {
        obj.AddComponent<BoxCollider2D>();
    }

    private static GameObject CreateText(string name, Transform parent, string content,
        Vector2 anchoredPos, Vector2 sizeDelta, int fontSize, TextAnchor alignment)
    {
        var obj = new GameObject(name);
        obj.transform.SetParent(parent, false);
        var text = obj.AddComponent<Text>();
        text.text = content;
        text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        text.fontSize = fontSize;
        text.alignment = alignment;
        text.color = Color.white;
        var rt = obj.GetComponent<RectTransform>();
        rt.anchoredPosition = anchoredPos;
        rt.sizeDelta = sizeDelta;
        return obj;
    }

    private static int CreateLayer(string layerName)
    {
        // Find or create layer (read-only at runtime; editor-only approach)
        for (int i = 8; i < 32; i++)
        {
            if (string.IsNullOrEmpty(LayerMask.LayerToName(i)))
            {
                // Add via SerializedObject
                var tagManager = new SerializedObject(
                    AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
                var layers = tagManager.FindProperty("layers");
                layers.GetArrayElementAtIndex(i).stringValue = layerName;
                tagManager.ApplyModifiedProperties();
                return i;
            }
            if (LayerMask.LayerToName(i) == layerName)
                return i;
        }
        return 0;
    }
}
