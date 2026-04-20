using UnityEngine;

[RequireComponent(typeof(Rigidbody2D), typeof(SpriteRenderer))]
public class FallingObject : MonoBehaviour
{
    [HideInInspector] public ObjectSpawner spawner;

    // Falling objects occupy this fraction of screen height
    private const float TargetHeightRatio = 0.08f;

    private Rigidbody2D rb;
    private SpriteRenderer sr;
    private bool scaled;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        sr = GetComponent<SpriteRenderer>();
    }

    void OnEnable()
    {
        if (rb != null) rb.linearVelocity = Vector2.zero;

        // Scale once per prefab instance (sprite doesn't change)
        if (!scaled && sr != null && sr.sprite != null && Camera.main != null)
        {
            float screenHeight = Camera.main.orthographicSize * 2f;
            float targetWorldH = screenHeight * TargetHeightRatio;
            float spriteH = sr.sprite.bounds.size.y;
            if (spriteH > 0f)
                transform.localScale = Vector3.one * (targetWorldH / spriteH);
            scaled = true;
        }
    }

    void Update()
    {
        if (spawner != null)
            rb.linearVelocity = Vector2.down * spawner.CurrentSpeed;

        float despawnY = Camera.main.transform.position.y - Camera.main.orthographicSize - 1f;
        if (transform.position.y < despawnY)
        {
            GameManager.Instance.IncrementDodge();
            spawner.ReturnToPool(gameObject);
        }
    }
}
