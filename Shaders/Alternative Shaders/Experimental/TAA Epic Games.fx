// Temporal AA based on Epic Games' implementation:
// https://de45xmedrsdbp.cloudfront.net/Resources/files/TemporalAA_small-59732822.pdf
// 
// Originally written by yvt for https://www.shadertoy.com/view/4tcXD2
// Feel free to use this in your shader!

uniform float3 T <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.0;
	ui_label = "T";
	ui_tooltip = "T.";
> = float3(0.0,0.0,0.0);

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture PastBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PastBB
	{
		Texture = PastBackBuffer;
	};
///////////////////////////////////////////////////////////TAA/////////////////////////////////////////////////////////////////////	
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define iResolution float2(BUFFER_WIDTH, BUFFER_HEIGHT)

// YUV-RGB conversion routine from Hyper3D
float3 encodePalYuv(float3 rgb)
{
    return float3(
        dot(rgb, float3(0.299, 0.587, 0.114)),
        dot(rgb, float3(-0.14713, -0.28886, 0.436)),
        dot(rgb, float3(0.615, -0.51499, -0.10001))
    );
}

float3 decodePalYuv(float3 yuv)
{	

    return float3(
        dot(yuv, float3(1.0, 0., 1.13983)),
        dot(yuv, float3(1.0, -0.39465, -0.58060)),
        dot(yuv, float3(1.0, 2.03211, 0.))
    );
}

float4 TAA_Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float2 uv = texcoord;
    float4 lastColor = tex2D(PastBB, uv);//Past Back Buffer
    
    float3 antialiased = lastColor.xyz;
    float mixRate = min(lastColor.w, 0.5);
    
    float2 off = pix;
    float3 in0 = tex2D(BackBuffer, uv).xyz;
    
    antialiased = lerp(antialiased * antialiased, in0 * in0, mixRate);
    antialiased = sqrt(antialiased);
    
    float3 in1 = tex2D(BackBuffer, uv + float2(+off.x, 0.0)).xyz;
    float3 in2 = tex2D(BackBuffer, uv + float2(-off.x, 0.0)).xyz;
    float3 in3 = tex2D(BackBuffer, uv + float2(0.0, +off.y)).xyz;
    float3 in4 = tex2D(BackBuffer, uv + float2(0.0, -off.y)).xyz;
    float3 in5 = tex2D(BackBuffer, uv + float2(+off.x, +off.y)).xyz;
    float3 in6 = tex2D(BackBuffer, uv + float2(-off.x, +off.y)).xyz;
    float3 in7 = tex2D(BackBuffer, uv + float2(+off.x, -off.y)).xyz;
    float3 in8 = tex2D(BackBuffer, uv + float2(-off.x, -off.y)).xyz;
    
    antialiased = encodePalYuv(antialiased);
    in0 = encodePalYuv(in0);
    in1 = encodePalYuv(in1);
    in2 = encodePalYuv(in2);
    in3 = encodePalYuv(in3);
    in4 = encodePalYuv(in4);
    in5 = encodePalYuv(in5);
    in6 = encodePalYuv(in6);
    in7 = encodePalYuv(in7);
    in8 = encodePalYuv(in8);
    
    float3 minColor = min(min(min(in0, in1), min(in2, in3)), in4);
    float3 maxColor = max(max(max(in0, in1), max(in2, in3)), in4);
    minColor = lerp(minColor, min(min(min(in5, in6), min(in7, in8)), minColor), 0.5);
    maxColor = lerp(maxColor, max(max(max(in5, in6), max(in7, in8)), maxColor), 0.5);
    
   	float3 preclamping = antialiased;
    antialiased = clamp(antialiased, minColor, maxColor);
    
    mixRate = 1.0 / (1.0 / mixRate + 1.0);
    
    float3 diff = antialiased - preclamping;
    float clampAmount = dot(diff, diff);
    
    mixRate += clampAmount * 4.0;
    mixRate = clamp(mixRate, 0.05, 0.5);
    
    antialiased = decodePalYuv(antialiased);
        
    return float4(antialiased, mixRate);
}

float4 Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return tex2D(BackBuffer,texcoord);
}

///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////
// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
technique TAA
	{
			pass TAAOut
		{
			VertexShader = PostProcessVS;
			PixelShader = TAA_Out;
		}
			pass PBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BackBuffer;
			RenderTarget = PastBackBuffer;
		}
	}