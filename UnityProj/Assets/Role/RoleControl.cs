using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class RoleControl : MonoBehaviour
{
    public CharacterController characterController;
    public float speed;
    public Animator animator;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        var h = Input.GetAxis("Horizontal");
        var v = Input.GetAxis("Vertical");

        var vec = new Vector3(h, 0, v).normalized;
        animator.SetBool("run", (vec.magnitude>0));

        characterController.Move(vec*speed*Time.deltaTime);
    }
}
