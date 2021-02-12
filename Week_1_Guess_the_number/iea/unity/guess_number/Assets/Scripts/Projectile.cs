using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projectile : MonoBehaviour {

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Target")
        {
            Debug.Log("Hit: " + collision.gameObject.name);
            // Get target collision object's id value
            int id = collision.gameObject.GetComponent<MyID>().id;
            // Get the number to guess
            int guess = collision.gameObject.GetComponentInParent<SpawnTargets>().guess;

            if (id == guess)
            {
                Debug.Log("Woo");
                // Instantiate some fireworks
                Quaternion rotation = Quaternion.Euler(-90, 0, 0);
                GameObject fire = collision.gameObject.GetComponentInParent<SpawnTargets>().pf_fireworks;
                GameObject fire_instance = Instantiate(
                    fire,
                    collision.gameObject.transform.position,
                    rotation,
                    collision.gameObject.transform
                );
                Destroy(fire_instance, 5f);
            }
            else if (id > guess)
            {
                Debug.Log("try lower");
                // Move targets down to point towards a lower value?
            }
            else if (id < guess)
            {
                Debug.Log("try higher");
                // Move targets up to point towards a bigger value?
            }
        }
    }
}