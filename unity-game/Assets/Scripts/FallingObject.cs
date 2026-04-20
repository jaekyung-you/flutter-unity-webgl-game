using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
public class FallingObject : MonoBehaviour
{
    [HideInInspector] public ObjectSpawner spawner;

    private Rigidbody2D rb;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    void OnEnable()
    {
        if (rb != null) rb.linearVelocity = Vector2.zero;
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
