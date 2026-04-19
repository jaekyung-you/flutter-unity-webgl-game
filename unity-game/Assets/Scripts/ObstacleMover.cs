using UnityEngine;

public class ObstacleMover : MonoBehaviour
{
    public ObstacleSpawner spawner;
    private bool moving;
    private float despawnX = -14f;

    public void SetMoving(bool value) => moving = value;

    void Update()
    {
        if (!moving || spawner == null) return;

        transform.Translate(Vector3.left * spawner.CurrentSpeed * Time.deltaTime);

        if (transform.position.x < despawnX)
            spawner.ReturnToPool(gameObject);
    }
}
