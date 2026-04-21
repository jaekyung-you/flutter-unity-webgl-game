using System.Collections;
using UnityEngine;

[RequireComponent(typeof(Rigidbody2D), typeof(SpriteRenderer))]
public class PlayerController : MonoBehaviour
{
    [Header("Movement")]
    public float moveSpeed = 5f;

    [Header("Sprites")]
    public Sprite normalSprite;
    public Sprite hitSprite;
    public Sprite burnoutSprite;
    public Sprite fallSprite;

    [Header("Female Sprites")]
    public Sprite femaleNormal;
    public Sprite femaleHit;
    public Sprite femaleBurnout;
    public Sprite femaleFall;

    private Sprite activeNormal;
    private Sprite activeHit;
    private Sprite activeBurnout;
    private Sprite activeFall;

    private Rigidbody2D rb;
    private SpriteRenderer sr;
    private int moveDirection;
    private bool isAlive;
    private bool isBurnout;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        sr = GetComponent<SpriteRenderer>();
        rb.simulated = false;

        activeNormal = normalSprite;
        activeHit = hitSprite;
        activeBurnout = burnoutSprite;
        activeFall = fallSprite;
    }

    void Update()
    {
        if (!isAlive) return;

        int keyDir = 0;
        if (Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.A))
            keyDir = -1;
        else if (Input.GetKey(KeyCode.RightArrow) || Input.GetKey(KeyCode.D))
            keyDir = 1;

        if (keyDir != 0) moveDirection = keyDir;

        rb.linearVelocity = new Vector2(moveSpeed * moveDirection, 0f);

        float halfWidth = Camera.main.orthographicSize * Camera.main.aspect;
        float clampedX = Mathf.Clamp(rb.position.x, -halfWidth + 0.3f, halfWidth - 0.3f);
        rb.position = new Vector2(clampedX, rb.position.y);
    }

    public void StartMoving()
    {
        isAlive = true;
        isBurnout = false;
        rb.simulated = true;
        moveDirection = 0;
        SetSprite(activeNormal);
    }

    public void StopMoving()
    {
        isAlive = false;
        rb.simulated = false;
        rb.linearVelocity = Vector2.zero;
        moveDirection = 0;
    }

    public void ShowHitFlash()   => StartCoroutine(HitFlashCoroutine());

    public void SetBurnoutState()
    {
        isBurnout = true;
        SetSprite(activeBurnout);
    }

    public void SetFallState()
    {
        StopAllCoroutines();
        SetSprite(activeFall);
    }

    private IEnumerator HitFlashCoroutine()
    {
        SetSprite(activeHit);
        yield return new WaitForSecondsRealtime(0.4f);
        SetSprite(isBurnout ? activeBurnout : activeNormal);
    }

    private void SetSprite(Sprite s)
    {
        if (sr != null && s != null) sr.sprite = s;
    }

    public void OnFlutterMoveLeft(string _)  { if (isAlive) moveDirection = -1; }
    public void OnFlutterMoveRight(string _) { if (isAlive) moveDirection = 1; }
    public void OnFlutterStopMove(string _)  { if (isAlive) moveDirection = 0; }

    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.CompareTag("FallingObject"))
            GameManager.Instance.TriggerHit();
    }

    public void SetCharacter(string characterType)
    {
        if (characterType.ToLower() == "female" && femaleNormal != null)
        {
            activeNormal = femaleNormal;
            activeHit = femaleHit;
            activeBurnout = femaleBurnout;
            activeFall = femaleFall;
        }
        else
        {
            activeNormal = normalSprite;
            activeHit = hitSprite;
            activeBurnout = burnoutSprite;
            activeFall = fallSprite;
        }
        if (isAlive && !isBurnout) SetSprite(activeNormal);
    }
}
