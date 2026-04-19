using UnityEngine;

public class BackgroundScroller : MonoBehaviour
{
    public float scrollSpeed = 3f;
    public float resetX = 20f;  // when to reset position
    public float startX = 0f;   // original X position

    private bool scrolling;

    public void SetScrolling(bool value) => scrolling = value;

    void Update()
    {
        if (!scrolling) return;

        transform.Translate(Vector3.left * scrollSpeed * Time.deltaTime);

        if (transform.position.x <= -resetX)
            transform.position = new Vector3(startX, transform.position.y, transform.position.z);
    }

    void Start()
    {
        startX = transform.position.x;
    }
}
