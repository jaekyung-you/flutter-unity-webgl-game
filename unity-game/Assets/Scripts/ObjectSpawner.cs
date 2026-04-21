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
        if (fo != null)
        {
            fo.spawner = this;
            fo.speedMultiplier = GetSpeedMultiplier(prefab.name);
        }
        obj.SetActive(true);
    }

    private static float GetSpeedMultiplier(string prefabName)
    {
        switch (prefabName.ToLower())
        {
            case "document_pile":    return 0.8f;  // 서류더미 — 묵직하게 느리게
            case "kpi_bomb":         return 1.5f;  // KPI 폭탄 — 가장 빠름
            case "meeting_mail":     return 0.9f;  // 회의 메일 — 보통
            case "overtime_notice":  return 1.1f;  // 야근 통보 — 약간 빠름
            case "overwork_coffee":  return 1.0f;  // 야근 커피 — 기준 속도
            case "revision_laptop":  return 1.2f;  // 수정 요청 — 조급하게
            case "urgent_phone":     return 1.4f;  // 긴급 전화 — 빠름
            default:                 return 1.0f;
        }
    }
}
