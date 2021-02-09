using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAtPlayer : MonoBehaviour
{

    // Component is currently disabled

    public GameObject player;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        // Rotate self every frame so it keeps looking at target
        transform.LookAt(player.transform, Vector3.up);
    }
}
