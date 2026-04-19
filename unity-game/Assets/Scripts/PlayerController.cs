using UnityEngine;

[RequireComponent(typeof(Rigidbody2D), typeof(Animator))]
public class PlayerController : MonoBehaviour
{
    [Header("Jump")]
    public float jumpForce = 12f;
    public LayerMask groundLayer;
    public Transform groundCheck;
    public float groundCheckRadius = 0.15f;

    private Rigidbody2D rb;
    private Animator anim;
    private bool isGrounded;
    private bool isAlive;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        anim = GetComponent<Animator>();
        rb.simulated = false;
    }

    void Update()
    {
        if (!isAlive) return;

        isGrounded = Physics2D.OverlapCircle(groundCheck.position, groundCheckRadius, groundLayer);
        anim.SetBool("isGrounded", isGrounded);

        bool jumpInput = Input.GetMouseButtonDown(0) || Input.GetKeyDown(KeyCode.Space);
#if UNITY_IOS || UNITY_ANDROID
        if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
            jumpInput = true;
#endif
        if (jumpInput && isGrounded)
            Jump();
    }

    public void StartRunning()
    {
        isAlive = true;
        rb.simulated = true;
        anim.SetTrigger("run");
    }

    public void Die()
    {
        isAlive = false;
        rb.simulated = false;
        anim.SetTrigger("die");
    }

    private void Jump()
    {
        rb.linearVelocity = new Vector2(rb.linearVelocity.x, 0f);
        rb.AddForce(Vector2.up * jumpForce, ForceMode2D.Impulse);
        anim.SetTrigger("jump");
    }

    void OnCollisionEnter2D(Collision2D col)
    {
        if (col.gameObject.CompareTag("Obstacle"))
            GameManager.Instance.TriggerGameOver();
    }
}
