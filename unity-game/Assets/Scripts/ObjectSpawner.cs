using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSpawner : MonoBehaviour
{
    public GameObject[] objectPrefabs;
    public float initialFallSpeed = 3f;
    public float maxFallSpeed = 9f;
    public float rampDuration = 30f;
    public float initialSpawnInterval = 1.5f;
    public float minSpawnInterval = 0.5f;

    public float CurrentSpeed { get; private set; }

    private readonly List<GameObject> pool = new List<GameObject>();
    private Coroutine spawnCoroutine;
    private float elapsedTime;
    private bool isSpawning;

    public void StartSpawning()
    {
        elapsedTime = 0f;
        isSpawning = true;
        CurrentSpeed = initialFallSpeed;
        if (spawnCoroutine != null) StopCoroutine(spawnCoroutine);
        spawnCoroutine = StartCoroutine(SpawnLoop());
    }

    public void StopSpawning()
    {
        isSpawning = false;
        if (spawnCoroutine != null)
        {
            StopCoroutine(spawnCoroutine);
            spawnCoroutine = null;
        }
    }

    public void ClearAll()
    {
        foreach (var obj in pool)
        {
            if (obj != null) obj.SetActive(false);
        }
    }

    public void ReturnToPool(GameObject obj)
    {
        obj.SetActive(false);
    }

    void Update()
    {
        if (!isSpawning) return;
        elapsedTime += Time.deltaTime;
        float t = Mathf.Clamp01(elapsedTime / rampDuration);
        CurrentSpeed = Mathf.Lerp(initialFallSpeed, maxFallSpeed, t);
    }

    private IEnumerator SpawnLoop()
    {
        while (isSpawning)
        {
            SpawnObject();
            float t = Mathf.Clamp01(elapsedTime / rampDuration);
            float interval = Mathf.Lerp(initialSpawnInterval, minSpawnInterval, t);
            yield return new WaitForSeconds(interval);
        }
    }

    private void SpawnObject()
    {
        if (objectPrefabs == null || objectPrefabs.Length == 0) return;

        float halfWidth = Camera.main.orthographicSize * Camera.main.aspect;
        float spawnX = Random.Range(-halfWidth + 1f, halfWidth - 1f);
        float spawnY = Camera.main.transform.position.y + Camera.main.orthographicSize + 1f;

        var prefab = objectPrefabs[Random.Range(0, objectPrefabs.Length)];
        string poolName = prefab.name + "_pooled";

        GameObject obj = pool.Find(o => o != null && !o.activeSelf && o.name == poolName);

        if (obj == null)
        {
            obj = Instantiate(prefab);
            obj.name = poolName;
            pool.Add(obj);
        }

        obj.transform.position = new Vector3(spawnX, spawnY, 0f);
        var fo = obj.GetComponent<FallingObject>();
        if (fo != null) fo.spawner = this;
        obj.SetActive(true);
    }
}
