//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

float4x4 tWVP: WORLDVIEWPROJECTION;
Texture2D texture2d; 

float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };


SamplerState g_samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};



cbuffer cbPerDraw : register( b0 )
{
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 

	float4x4 tTex  <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
};

float4 ts : TARGETSIZE;
float4x4 tt : TEXTUREMATRIX;

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
}; 

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //position (projected)

	float2 p = mul(input.TexCd,tWVP).xy;
	/*float2 hr = ts * 0.5f;
	p += hr;
	//p *= tw.zw * 0.5f;*/
	
	
	p *= ts.zw; //* float2(2.0f-2.0f) +float2(1.0f,-1.0f);
	p *= 2.0;
	p.x -=1;
	p.y = -p.y + 1;
	
	
	Out.PosWVP  = float4(p,0,1);
    Out.TexCd = mul(input.TexCd,tt);
    return Out;
}




float4 PS_Tex(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * cAmb;
	col = mul(col,tColor);
	col.a *= Alpha;
    return col;
}

float4 PS_TexBGR(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd).bgra * cAmb;
	col = mul(col,tColor);
	col.a *= Alpha;
    return  col;
}



float4 PS_NoTex(vs2ps In): SV_Target
{
    float4 col = cAmb;
	col = mul(col,tColor);
	col.a *= Alpha;
    return  col;
}




technique11 Constant
{
	pass P0
	{
		SetHullShader( 0 );
		SetDomainShader( 0 );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_Tex() ) );
	}
}

technique11 ConstantBGR
{
	pass P0
	{
		SetHullShader( 0 );
		SetDomainShader( 0 );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_TexBGR() ) );
	}
}

technique11 ConstantNoTex
{
	pass P0
	{
		SetHullShader( 0 );
		SetDomainShader( 0 );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS_NoTex() ) );
	}
}



 
