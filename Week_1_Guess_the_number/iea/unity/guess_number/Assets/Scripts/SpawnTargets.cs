using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class SpawnTargets : MonoBehaviour
{

    public GameObject player;
    public GameObject pf_target;
    public GameObject pf_fireworks;

    public int min = 1;
    public int max = 20;

    private float radius = 5f;

    public int guess = 0;

    // Start is called before the first frame update
    void Start()
    {
        guess = Random.Range(min, max);

        for(int i = min; i < max; ++i)
        {
            // Spawn max - min numbered targets in a circle facing the player
            // Math works nicely with up to 30 targets but then it's too many objects
            // in once circle.. and didn't bother to figure out how to do many levels of
            float angle = i * Mathf.PI * 2 / (max - min);
            float x = Mathf.Cos(angle) * radius;
            float z = Mathf.Sin(angle) * radius;
            Vector3 pos = transform.position + new Vector3(x, 2.0f, z);
            float angleDegrees = -angle*Mathf.Rad2Deg +90f;
            Quaternion rot = Quaternion.Euler(0, angleDegrees, 0);

            GameObject target = Instantiate(pf_target, pos, rot, this.transform) as GameObject;
            target.name = ("target" + i.ToString());
            target.GetComponent<MyID>().id = i;

            // look at player - not used as the math above does a pretty circle for us
            // target.GetComponent<LookAtPlayer>().target = player.transform;
            // target.GetComponent<LookAtPlayer>().player = player;

            // flip upwards - maybe? - they kept looking down to the floor..
            target.transform.Rotate(0f, 90f, 90f);

            // set text
            TextMeshPro m_text = target.GetComponentInChildren<TextMeshPro>();
            m_text.SetText(i.ToString());
        }
    }

    // Update is called once per frame
    void Update()
    {

    }
}
