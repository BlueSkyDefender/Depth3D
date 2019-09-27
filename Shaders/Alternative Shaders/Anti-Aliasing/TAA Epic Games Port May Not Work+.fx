// Temporal AA (aka Motion Blur) -=WIP=- based on Epic Games' implementation:
// https://de45xmedrsdbp.cloudfront.net/Resources/files/TemporalAA_small-59732822.pdf
// 
// Originally written by yvt for https://www.shadertoy.com/view/4tcXD2
// Feel free to use this in your shader!

uniform int Motion_Seeking <
	ui_type = "drag";
	ui_min = 1; ui_max = 5;
	ui_label = "Motion Seeking";
	ui_tooltip = "The power of Seeking things in motion.\n" 
				 "Default is One.";
> = 1;

uniform bool DeBug <
	ui_label = "DeBug View";
	ui_tooltip = "See whats wrong.";
	//ui_category = "Depth Buffer";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture CurrentBackBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler CBackBufferTAA
	{
		Texture = CurrentBackBufferTAA;
	};
	
//texture PastBackBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

//sampler PBackBufferTAA
	//{
	//	Texture = PastBackBufferTAA;
	//};

texture PastSingleBackBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PSBackBufferTAA
	{
		Texture = PastSingleBackBufferTAA;
	};
	
///////////////////////////////////////////////////////////TAA/////////////////////////////////////////////////////////////////////	
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define iResolution float2(BUFFER_WIDTH, BUFFER_HEIGHT)

// YUV-RGB conversion routine from Hyper3D
float3 encodePalYuv(float3 rgb)
{
	float3 RGB2Y =  float3( 0.299, 0.587, 0.114);
	float3 RGB2Cb = float3(-0.169,-0.331, 0.500);
	float3 RGB2Cr = float3( 0.500,-0.419,-0.081);

	return float3(dot(rgb, RGB2Y), dot(rgb, RGB2Cb), dot(rgb, RGB2Cr));
}

float3 decodePalYuv(float3 ycc)
{	
	float3 YCbCr2R = float3( 1.000, 0.000, 1.400);
	float3 YCbCr2G = float3( 1.000,-0.343,-0.711);
	float3 YCbCr2B = float3( 1.000, 1.765, 0.000);

	return float3(dot(ycc, YCbCr2R), dot(ycc, YCbCr2G), dot(ycc, YCbCr2B));
}


float4 TAA(float2 texcoord)
{	

    float4 PastColor = tex2Dlod(PSBackBufferTAA,float4(texcoord,0,0) );//Past Back Buffer
    
    float3 antialiased = PastColor.xyz;
    float mixRate = min(PastColor.w, 0.5);

    float3 in0 = tex2D(BackBuffer, texcoord).xyz;
        
    antialiased = lerp(antialiased * antialiased, in0 * in0, mixRate);
    antialiased = sqrt(antialiased);
        
    float3 in1 = tex2D(BackBuffer, texcoord + float2(+pix.x, 0.0)).xyz;
    float3 in2 = tex2D(BackBuffer, texcoord + float2(-pix.x, 0.0)).xyz;
    float3 in3 = tex2D(BackBuffer, texcoord + float2(0.0, +pix.y)).xyz;
    float3 in4 = tex2D(BackBuffer, texcoord + float2(0.0, -pix.y)).xyz;
    float3 in5 = tex2D(BackBuffer, texcoord + float2(+pix.x, +pix.y)).xyz;
    float3 in6 = tex2D(BackBuffer, texcoord + float2(-pix.x, +pix.y)).xyz;
    float3 in7 = tex2D(BackBuffer, texcoord + float2(+pix.x, -pix.y)).xyz;
    float3 in8 = tex2D(BackBuffer, texcoord + float2(-pix.x, -pix.y)).xyz; 
    
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
    
    float3 minColor = min(min(min(in0, in1), min(in2, in3)), in4) ;
    float3 maxColor = max(max(max(in0, in1), max(in2, in3)), in4) ;
    minColor = lerp(minColor, min(min(min(in5, in6), min(in7, in8)), minColor), 0.5);
    maxColor = lerp(maxColor, max(max(max(in5, in6), max(in7, in8)), maxColor), 0.5);
    
   	float3 preclamping = antialiased;
    antialiased = clamp(antialiased, minColor, maxColor);
    
    mixRate = 1.0 / (1.0 / mixRate + 1.0);
    
    float3 diff = antialiased - preclamping;
    float clampAmount = dot(diff,diff);
    
    mixRate += clampAmount * pow(4.0,Motion_Seeking);
    mixRate = clamp(mixRate, 0.05, 0.5);
    
    antialiased = decodePalYuv(antialiased);
    
    float4 Done = float4(antialiased,mixRate);
	
	if(DeBug) 
		Done = mixRate;
    
    return Done;
}

void Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	color = TAA(texcoord);
}

void Current_BackBufferTAA(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	color = tex2D(BackBuffer,texcoord);
}

void Past_BackBufferTAA(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target0)//, out float4 Past : SV_Target1)
{
	PastSingle = tex2D(CBackBufferTAA,texcoord);
	//Past = tex2D(BackBuffer,texcoord);
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
			pass CBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Current_BackBufferTAA;
			RenderTarget = CurrentBackBufferTAA;
		}
			pass Out
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
			pass PBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BackBufferTAA;
			RenderTarget0 = PastSingleBackBufferTAA;
			//RenderTarget1 = PastBackBufferTAA;
			
		}
	}