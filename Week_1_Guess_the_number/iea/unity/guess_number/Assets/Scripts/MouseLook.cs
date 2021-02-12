using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseLook : MonoBehaviour
{

    public float mouse_sensitivity = 100f;
    public Transform player_body;
    float x_rot = 0f;

    // Start is called before the first frame update
    void Start()
    {
        // Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        float mouse_x = Input.GetAxis("Mouse X") * mouse_sensitivity * Time.deltaTime;
        float mouse_y = Input.GetAxis("Mouse Y") * mouse_sensitivity * Time.deltaTime;

        x_rot -= mouse_y;
        // clamp rotation
        x_rot = Mathf.Clamp(x_rot, -90f, 90f);

        transform.localRotation = Quaternion.Euler(x_rot, 0f, 0f);
        player_body.Rotate(Vector3.up * mouse_x);
    }

    // FixedUpdate can run once, zero, or several times per frame,
    // depending on how many physics frames per second are set in
    // the time settings, and how fast/slow the framerate is
    void FixedUpdate()
    {

    }
}
