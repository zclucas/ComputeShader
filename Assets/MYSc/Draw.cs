using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Draw : MonoBehaviour
{
    // Start is called before the first frame update
    public ComputeBuffer Buff_data;
    public ComputeBuffer Buff_Cull;
    public ComputeBuffer Buff_Args;
    public uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
    public int DrawCount;
    public int CacheCount;
    public Material material;
    public Mesh DrawMesh;
    public Camera CameraMain;
    public ComputeShader CS;
    private int Kernel;
    private Bounds bounds = new Bounds(Vector3.zero, Vector3.one * 100);
    private Vector3[] dot = new Vector3[2];
    public struct infos
	{
        public Matrix4x4 TF;
        public int index;
	}
    void Start()
    {
        Buff_Args = new ComputeBuffer(1, sizeof(uint) * 5, ComputeBufferType.IndirectArguments);
        Buff_data = new ComputeBuffer(DrawCount, 68);
        Buff_Cull = new ComputeBuffer(DrawCount, 68, ComputeBufferType.Append);
        if(CS!=null)
        Kernel = CS.FindKernel("CSMain");
        dot[0] = new Vector3(-0.5f, -0.5f, -0.5f);
        dot[1] = new Vector3(0.5f, 0.5f, 0.5f);
    }

    // Update is called once per frame
    void Update()
    {
        if (CacheCount != DrawCount)
            SetData();
        
		if (CS != null)
		{
            CS.SetBuffer(Kernel, "data", Buff_data);
            Buff_Cull.SetCounterValue(0);
            CS.SetBuffer(Kernel, "Res", Buff_Cull);
            CS.SetVectorArray("plane", PlaneTool.Camera_Plane(CameraMain));
            CS.SetFloat("_Time", Time.time / 20);
            CS.Dispatch(Kernel, DrawCount / 256, 1, 1);
            ComputeBuffer.CopyCount(Buff_Cull, Buff_Args, sizeof(uint));
            material.SetBuffer("data", Buff_Cull);
        }
		else
		{
            material.SetBuffer("data", Buff_data);
            Buff_Args.SetData(args);
        }
        Graphics.DrawMeshInstancedIndirect(DrawMesh, 0, material, bounds, Buff_Args);
    }
    void SetData()
	{
        if (material == null) return;
        infos[] infos = new infos[DrawCount];
		for (int i = 0; i < DrawCount; i++)
		{
            float dis = Random.Range(20, 100);
            float deg = Random.Range(0, Mathf.PI * 2);
            float hei = Random.Range(-30, 30);
            Quaternion rotate = Quaternion.Euler(new Vector3(Random.Range(0, 360), Random.Range(0, 360), Random.Range(0, 360)));
            float size = Random.Range(0.2f, 2.5f);
            Vector3 pos = new Vector3(dis * Mathf.Cos(deg), hei, dis * Mathf.Sin(deg));
            infos[i].TF = Matrix4x4.TRS(pos, rotate, new Vector3(size,size,size));
            infos[i].index= Random.Range(0, 4);
        }
        Buff_data.SetData(infos);
		if (DrawMesh.subMeshCount <= 1)
		{
            args[0] = DrawMesh.GetIndexCount(0);
            args[1] = (uint)DrawCount;
            args[2] = DrawMesh.GetIndexStart(0);
            args[3] = DrawMesh.GetBaseVertex(0);
		}
		else
		{
            args[0] = args[1] = args[2] = args[3] = args[4] = 0;
		}
        CacheCount = DrawCount;
	}
	private void OnDisable()
	{
        Buff_Args?.Release();
        Buff_Cull?.Release();
        Buff_data?.Release();
	}
}
