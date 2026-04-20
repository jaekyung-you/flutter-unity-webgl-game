using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
public class PlayerController : MonoBehaviour
{
    [Header("Movement")]
    public float moveSpeed = 5f;

    private Rigidbody2D rb;
    private int moveDirection;
    private bool isAlive;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        rb.simulated = false;
    }

    void Update()
    {
        if (!isAlive) return;

        // Keyboard input (browser + desktop)
        int keyDir = 0;
        if (Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.A))
            keyDir = -1;
        else if (Input.GetKey(KeyCode.RightArrow) || Input.GetKey(KeyCode.D))
            keyDir = 1;

        // Keyboard overrides button input when pressed
        if (keyDir != 0) moveDirection = keyDir;

        rb.linearVelocity = new Vector2(moveSpeed * moveDirection, 0f);

        float halfWidth = Camera.main.orthographicSize * Camera.main.aspect;
        float clampedX = Mathf.Clamp(rb.position.x, -halfWidth + 0.5f, halfWidth - 0.5f);
        rb.position = new Vector2(clampedX, rb.position.y);
    }

    public void StartMoving()
    {
        isAlive = true;
        rb.simulated = true;
        moveDirection = 0;
    }

    public void StopMoving()
    {
        isAlive = false;
        rb.simulated = false;
        rb.linearVelocity = Vector2.zero;
        moveDirection = 0;
    }

    // Called from Flutter via JS bridge (◄ ► buttons)
    public void OnFlutterMoveLeft(string _)
    {
        if (isAlive) moveDirection = -1;
    }

    public void OnFlutterMoveRight(string _)
    {
        if (isAlive) moveDirection = 1;
    }

    public void OnFlutterStopMove(string _)
    {
        if (isAlive) moveDirection = 0;
    }

    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.CompareTag("FallingObject"))
            GameManager.Instance.TriggerHit();
    }
}
