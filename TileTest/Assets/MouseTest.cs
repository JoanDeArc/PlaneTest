using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseTest : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        // get mouse pos
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;


        if (Physics.Raycast(ray, out hit, 100))
        {
            //		renderer.material.SetVector("_ObjPos", Vector4(obj.position.x,obj.position.y,obj.position.z,0));
            GetComponent<Renderer>().material.SetVector("mousePos", new Vector4(hit.point.x, -hit.point.z, hit.point.y, 0));
            Debug.Log(hit.point);

        }
    }
}
