using System.Collections.Generic;
using UnityEngine;

//平滑法线到切线，法线Lowpoly模型有用
[ExecuteInEditMode]
public class SmoothNormalToTangent : MonoBehaviour
{
    private void Awake()
    {
        var meshFilter = GetComponent<MeshFilter>();
        if (meshFilter != null)
        {
            var mesh = Instantiate(meshFilter.sharedMesh);
            MeshNormalAverage(mesh);
            meshFilter.sharedMesh = mesh;
        }

        var skinnedMeshRender = GetComponent<SkinnedMeshRenderer>();
        if (skinnedMeshRender != null)
        {
            var mesh = Instantiate(skinnedMeshRender.sharedMesh);
            MeshNormalAverage(mesh);
            skinnedMeshRender.sharedMesh = mesh;
        }
    }

    private static void MeshNormalAverage(Mesh mesh)
    {
        var vertexDict = new Dictionary<Vector3, List<int>>();

        for (var i = 0; i < mesh.vertices.Length; i++)
        {
            var vertex = mesh.vertices[i];
            if (!vertexDict.TryGetValue(vertex, out var indexList))
            {
                indexList = new List<int>();
                vertexDict.Add(vertex, indexList);
            }

            indexList.Add(i);
        }

        var normals = mesh.normals;
        var tangents = mesh.tangents;

        foreach (var kv in vertexDict)
        {
            var indexList = kv.Value;

            var avgNormal = Vector3.zero;
            foreach (var i in indexList)
            {
                avgNormal += mesh.normals[i];
            }

            avgNormal /= indexList.Count;

            foreach (var i in indexList)
            {
                normals[i] = avgNormal;
                tangents[i] = (Vector4)avgNormal;
            }
        }

        mesh.tangents = tangents;
    }
}