using UnityEngine;
using UnityEngine.UI;
using System.Runtime.InteropServices;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    [Header("UI")]
    public Text scoreText;
    public GameObject gameOverPanel;
    public Text bestScoreText;

    [Header("References")]
    public PlayerController player;
    public ObstacleSpawner spawner;
    public BackgroundScroller[] scrollers;

    [DllImport("__Internal")]
    private static extern void SendScoreToFlutter(int score);

    [DllImport("__Internal")]
    private static extern void SendGameOverToFlutter(int finalScore, int bestScore);

    private int score;
    private int bestScore;
    private bool isPlaying;
    private float scoreTimer;

    void Awake()
    {
        Instance = this;
    }

    void Start()
    {
        bestScore = PlayerPrefs.GetInt("BestScore", 0);
        ShowGameOver(false);
    }

    void Update()
    {
        if (!isPlaying) return;

        scoreTimer += Time.deltaTime;
        if (scoreTimer >= 0.1f)
        {
            scoreTimer = 0f;
            score++;
            UpdateScoreUI();

#if UNITY_WEBGL && !UNITY_EDITOR
            SendScoreToFlutter(score);
#endif
        }
    }

    public void StartGame()
    {
        score = 0;
        isPlaying = true;
        scoreTimer = 0f;
        UpdateScoreUI();
        ShowGameOver(false);

        player.StartRunning();
        spawner.StartSpawning();
        foreach (var s in scrollers) s.SetScrolling(true);
    }

    public void TriggerGameOver()
    {
        if (!isPlaying) return;
        isPlaying = false;

        player.Die();
        spawner.StopSpawning();
        foreach (var s in scrollers) s.SetScrolling(false);

        if (score > bestScore)
        {
            bestScore = score;
            PlayerPrefs.SetInt("BestScore", bestScore);
        }

        ShowGameOver(true);

#if UNITY_WEBGL && !UNITY_EDITOR
        SendGameOverToFlutter(score, bestScore);
#endif
    }

    // Called from Flutter via JS bridge
    public void OnFlutterStartGame(string _)
    {
        StartGame();
    }

    public void OnFlutterRestartGame(string _)
    {
        spawner.ClearAll();
        StartGame();
    }

    private void UpdateScoreUI()
    {
        if (scoreText != null)
            scoreText.text = score.ToString();
    }

    private void ShowGameOver(bool show)
    {
        if (gameOverPanel != null)
            gameOverPanel.SetActive(show);

        if (show && bestScoreText != null)
            bestScoreText.text = "BEST: " + bestScore;
    }
}
