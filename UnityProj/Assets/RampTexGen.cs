using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class RampTexGen : MonoBehaviour
{
    public Gradient gradient;

    public int width = 128;
    public int height = 10;

    void OnValidate()
    {
        var baseMap = new Texture2D(width, height);

        var count = baseMap.width * baseMap.height;
        var cols = new Color[count];
        for (var w = 0; w < width; w++)
        {
            for (var h = 0; h < height; h++)
            {
                var col1 = gradient.Evaluate((w) * 1f / width);
                cols[w + h * width] = col1;
            }
        }

        baseMap.SetPixels(cols);
        baseMap.Apply();

        var bytes = baseMap.EncodeToPNG();
        File.WriteAllBytes(Application.dataPath + "/RampTex.png", bytes);

        AssetDatabase.Refresh();
    }
}