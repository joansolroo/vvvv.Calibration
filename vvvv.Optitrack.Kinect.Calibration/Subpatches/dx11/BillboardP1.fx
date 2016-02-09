//@author: vvvv group
//@help: draws a mesh with a constant color
//@tags: template, basic
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;

//material properties
float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

float Alpha = 1;

//texture

Texture2D texture2d <string uiname="Texture";>;
SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

float4x4 tTex <bool uvspace=true; string uiname="Texture Transform";>;
//the data structure: vertexshader to pixelshader
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos : SV_POSITION;
    float4 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
float4x4 TransformInP <string uiname="TransformInP";>;
float3 PositionW;

bool OnTop = true;
bool ApplyViewProjection = true;

vs2ps VS(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

	float4 PosW;
	PosW.xyz = PositionW;
	PosW.w = 1.0f;
	
	float4 PosP;
	if (ApplyViewProjection)
		PosP = mul(PosW, tWVP);
	
	PosP /= PosP.w;
	PosP.xy *= 2.0f;
	
    //transform position
	Pos = mul(Pos, TransformInP);
    Out.Pos = Pos + PosP;
	
	if (OnTop)
		Out.Pos.z /= 100.0f;

    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): SV_TARGET
{
    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0

    float4 col = texture2d.Sample(g_samLinear, In.TexCd) * cAmb;
    col.a *= Alpha;
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------




technique10 TBillboard
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
