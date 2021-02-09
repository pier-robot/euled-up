using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerShoot : MonoBehaviour
{
    public KeyCode shootKey = KeyCode.Mouse0;  // LMB click
    public GameObject projectile;
    public float shootForce;

    private float destroy_time = 5f;

    // Use this for initialization
    void Start () {

    }

    // Update is called once per frame
    void Update ()
    {
        if (Input.GetKeyDown(shootKey))
        {
            GameObject shot = GameObject.Instantiate(
                projectile, transform.position, transform.rotation);
            shot.GetComponent<Rigidbody>().AddForce(Camera.main.transform.forward * shootForce);
            Destroy(shot, destroy_time);
        }
    }
}