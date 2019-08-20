#if !defined(TESSELLATION_INCLUDED_HLSL)
#define TESSELLATION_INCLUDED_HLSL


struct TessellationFactors {
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

struct TessellationControlPoint {
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
};

#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) data.fieldName = \
		patch[0].fieldName * barycentricCoordinates.x + \
		patch[1].fieldName * barycentricCoordinates.y + \
		patch[2].fieldName * barycentricCoordinates.z;
//------------------------hull shader-----------------------
//input patch and output the factors
TessellationFactors MyPatchConstantFunction(InputPatch<TessellationControlPoint, 3> patch){
    TessellationFactors f;
    f.edge[0] = 10;//each edge
    f.edge[1] = 10;
    f.edge[2] = 10;
	f.inside = 10;//inside
	return f;
}
 
//VertexData data format,each patch contain 3 vertices
[UNITY_domain("tri")]//tell work with triangle
[outputcontrolpoints(3)]
[outputtopology("triangle_cw")]//clockwise or counterclockwise of new vertices
[UNITY_partitioning("integer")]//partition type
[UNITY_patchconstantfunc("MyPatchConstantFunction")]//stand out how many parts the patch should be cut
TessellationControlPoint MyHullProgram(InputPatch<TessellationControlPoint,3> patch,uint id:SV_OutputControlPointID){
    return patch[id];
}

//-------------------------domain shader ------------------

//output of tessellation stage
//SV_DomainLocation: barycentric each vertex point,used to derive the final vertices
[domain("tri")]
InterpolatorsVertex  MyDomainProgram(TessellationFactors factors,
                    OutputPatch<TessellationControlPoint, 3> patch,
                    float3 barycentricCoordinates : SV_DomainLocation){

    VertexData data;
	MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
 MY_DOMAIN_PROGRAM_INTERPOLATE(normal)
	MY_DOMAIN_PROGRAM_INTERPOLATE(tangent)
	MY_DOMAIN_PROGRAM_INTERPOLATE(uv)
	MY_DOMAIN_PROGRAM_INTERPOLATE(uv1)
	MY_DOMAIN_PROGRAM_INTERPOLATE(uv2)

    return MyVertexProgram(data);
}

#endif