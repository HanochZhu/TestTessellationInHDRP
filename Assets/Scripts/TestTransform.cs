using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestTransform : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log(this.transform.root);
        //UnityEngine.Experimental.Rendering.HDPipeline.ShaderOptions.CameraRelativeRendering = 0;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
