using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ObstacleSpawner : MonoBehaviour
{
    [Header("Obstacle Prefabs")]
    public GameObject[] obstaclePrefabs;

    [Header("Spawn Settings")]
    public float spawnX = 12f;
    public float spawnY = -2.5f;
    public float minInterval = 1.2f;
    public float maxInterval = 2.5f;
    public float difficultyRampTime = 30f; // seconds until max difficulty

    [Header("Scroll Speed")]
    public float initialSpeed = 6f;
    public float maxSpeed = 12f;

    private List<GameObject> activeObstacles = new();
    private Queue<GameObject>[] pools;
    private bool isSpawning;
    private float elapsed;
    private Coroutine spawnCoroutine;

    public float CurrentSpeed { get; private set; }

    void Awake()
    {
        CurrentSpeed = initialSpeed;
        pools = new Queue<GameObject>[obstaclePrefabs.Length];
        for (int i = 0; i < obstaclePrefabs.Length; i++)
            pools[i] = new Queue<GameObject>();
    }

    public void StartSpawning()
    {
        isSpawning = true;
        elapsed = 0f;
        CurrentSpeed = initialSpeed;
        spawnCoroutine = StartCoroutine(SpawnLoop());
    }

    public void StopSpawning()
    {
        isSpawning = false;
        if (spawnCoroutine != null) StopCoroutine(spawnCoroutine);

        foreach (var obs in activeObstacles)
        {
            var mover = obs.GetComponent<ObstacleMover>();
            if (mover != null) mover.SetMoving(false);
        }
    }

    public void ClearAll()
    {
        foreach (var obs in activeObstacles)
            ReturnToPool(obs);
        activeObstacles.Clear();
    }

    void Update()
    {
        if (!isSpawning) return;
        elapsed += Time.deltaTime;
        float t = Mathf.Clamp01(elapsed / difficultyRampTime);
        CurrentSpeed = Mathf.Lerp(initialSpeed, maxSpeed, t);
    }

    private IEnumerator SpawnLoop()
    {
        yield return new WaitForSeconds(1.5f); // initial delay
        while (isSpawning)
        {
            SpawnObstacle();
            float t = Mathf.Clamp01(elapsed / difficultyRampTime);
            float interval = Mathf.Lerp(maxInterval, minInterval, t);
            yield return new WaitForSeconds(interval);
        }
    }

    private void SpawnObstacle()
    {
        int idx = Random.Range(0, obstaclePrefabs.Length);
        GameObject obs = GetFromPool(idx);
        obs.transform.position = new Vector3(spawnX, spawnY, 0f);
        obs.SetActive(true);

        var mover = obs.GetComponent<ObstacleMover>();
        if (mover != null)
        {
            mover.spawner = this;
            mover.SetMoving(true);
        }

        activeObstacles.Add(obs);
    }

    public void ReturnToPool(GameObject obs)
    {
        obs.SetActive(false);
        activeObstacles.Remove(obs);
        for (int i = 0; i < obstaclePrefabs.Length; i++)
        {
            if (obs.name.StartsWith(obstaclePrefabs[i].name))
            {
                pools[i].Enqueue(obs);
                return;
            }
        }
        pools[0].Enqueue(obs);
    }

    private GameObject GetFromPool(int idx)
    {
        if (pools[idx].Count > 0)
            return pools[idx].Dequeue();

        var obj = Instantiate(obstaclePrefabs[idx]);
        obj.name = obstaclePrefabs[idx].name + "_pooled";
        return obj;
    }
}
