RWStructuredBuffer<float4> rw : BACKBUFFER;

Texture2D texture2d;
StructuredBuffer<float2> uv;

SamplerState mySampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};


[numthreads(64, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	rw[i.x] = texture2d.SampleLevel(mySampler,uv[i.x],0);


	
	
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







