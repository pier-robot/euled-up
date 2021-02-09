using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public CharacterController controller;
    // public float speed = 12f;
    public float rotate_speed = 3f;

    // Update is called once per frame
    void Update()
    {
        // Rotate camera with A and D keys
        transform.Rotate(0, Input.GetAxis("Horizontal") * rotate_speed, 0);

        // Commented code below would enable for the player to move with WASD
        // But we opted for only rotating the view with A/D
        // float x = Input.GetAxis("Horizontal");
        // float z = Input.GetAxis("Vertical");
        // Vector3 move = transform.right * x + transform.forward * z;
        // controller.Move(move * speed * Time.deltaTime);

    }
}
