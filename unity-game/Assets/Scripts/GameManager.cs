using UnityEngine;
using System.Runtime.InteropServices;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    [Header("References")]
    public PlayerController player;
    public ObjectSpawner spawner;

    [Header("Burnout")]
    public int maxBurnout = 5;

#if UNITY_WEBGL && !UNITY_EDITOR
    [DllImport("__Internal")] private static extern void SendScoreToFlutter(int score);
    [DllImport("__Internal")] private static extern void SendGameOverToFlutter(int finalScore, int bestScore);
    [DllImport("__Internal")] private static extern void SendBurnoutToFlutter(int current, int max);
    [DllImport("__Internal")] private static extern void SendDodgeToFlutter(int count);
#endif

    private int score;
    private int bestScore;
    private int burnoutCount;
    private int dodgeCount;
    private bool isPlaying;
    private bool isPaused;
    private float scoreTimer;

    void Awake() { Instance = this; }

    void Start()
    {
        bestScore = PlayerPrefs.GetInt("BestScore", 0);
    }

    void Update()
    {
        if (!isPlaying || isPaused) return;
        scoreTimer += Time.deltaTime;
        if (scoreTimer >= 1f)
        {
            scoreTimer = 0f;
            score++;
#if UNITY_WEBGL && !UNITY_EDITOR
            SendScoreToFlutter(score);
#endif
        }
    }

    public void StartGame()
    {
        score = 0;
        burnoutCount = 0;
        dodgeCount = 0;
        isPlaying = true;
        isPaused = false;
        scoreTimer = 0f;
        Time.timeScale = 1f;
        player.StartMoving();
        spawner.StartSpawning();
    }

    public void TriggerHit()
    {
        if (!isPlaying) return;
        burnoutCount++;
#if UNITY_WEBGL && !UNITY_EDITOR
        SendBurnoutToFlutter(burnoutCount, maxBurnout);
#endif
        if (burnoutCount >= maxBurnout)
            TriggerGameOver();
    }

    public void IncrementDodge()
    {
        if (!isPlaying) return;
        dodgeCount++;
#if UNITY_WEBGL && !UNITY_EDITOR
        SendDodgeToFlutter(dodgeCount);
#endif
    }

    public void TriggerGameOver()
    {
        if (!isPlaying) return;
        isPlaying = false;
        Time.timeScale = 1f;
        player.StopMoving();
        spawner.StopSpawning();
        if (score > bestScore)
        {
            bestScore = score;
            PlayerPrefs.SetInt("BestScore", bestScore);
        }
#if UNITY_WEBGL && !UNITY_EDITOR
        SendGameOverToFlutter(score, bestScore);
#endif
    }

    public void OnFlutterStartGame(string _) => StartGame();

    public void OnFlutterRestartGame(string _)
    {
        spawner.ClearAll();
        StartGame();
    }

    public void OnFlutterPause(string _)
    {
        if (!isPlaying) return;
        isPaused = !isPaused;
        Time.timeScale = isPaused ? 0f : 1f;
    }
}
