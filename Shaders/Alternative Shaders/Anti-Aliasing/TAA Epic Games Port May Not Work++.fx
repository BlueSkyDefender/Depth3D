// Temporal AA (aka Motion Blur) -=WIP=- based on Epic Games' implementation:
// https://de45xmedrsdbp.cloudfront.net/Resources/files/TemporalAA_small-59732822.pdf
//
// Originally written by yvt for https://www.shadertoy.com/view/4tcXD2
// Feel free to use this in your shader!

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DM0 Normal\0DM1 Reversed\0";
	ui_label = "·Depth Map Selection·";
	ui_tooltip = "Linearization for the zBuffer also known as Depth Map.\n"
			     "DM0 is Z-Normal and DM1 is Z-Reversed.\n";
	ui_category = "Depth Map";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.0; ui_step = 0.125;
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "This allows for you to adjust the DM precision.\n"
				 "Adjust this to keep it as low as possible.\n"
				 "Default is 7.5";
	ui_category = "Depth Map";
> = 7.5;

uniform bool Depth_Map_Flip <
	ui_label = " Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Map";
> = false;

uniform bool Mask_TAA <
	ui_label = "Mask TAA";
	ui_tooltip = "THis mask Tries to remove Ghosting.";
> = false;

uniform int Mask_Power <
	ui_type = "drag";
	ui_min = 1; ui_max = 5;
	ui_label = "Motion Seeking Mask";
	ui_tooltip = "The power of Seeking things in motion.\n"
				 "Default is One.";
> = 1;

uniform bool DeBug <
	ui_label = "DeBug View";
	ui_tooltip = "See whats wrong.";
> = false;

uniform bool Past_Frames <
	ui_label = "Past Frames";
	ui_tooltip = "How many Past Frames single or Max.";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
texture DepthBufferTex : DEPTH;

sampler DepthBufferTAA
	{
		Texture = DepthBufferTex;
	};

texture BackBufferTex : COLOR;

sampler BackBufferTAA
	{
		Texture = BackBufferTex;
	};

texture CurrentBackBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;};

sampler CBackBufferTAA
	{
		Texture = CurrentBackBufferTAA;
	};

texture CurrentDepthBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};

sampler CDepthBufferTAA
	{
		Texture = CurrentDepthBufferTAA;
	};
///////////////////////////////////////////////////////////Past Samplers/////////////////////////////////////////////////////////////
texture PastBackBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;};

sampler PBackBufferTAA
	{
		Texture = PastBackBufferTAA;
	};

texture PastSingleDepthBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};

sampler PDepthBufferTAA
	{
		Texture = PastSingleDepthBufferTAA;
	};

texture PastSingleBackBufferTAA  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;};

sampler PSBackBufferTAA
	{
		Texture = PastSingleBackBufferTAA;
	};
//////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////
float Depth(float2 texcoord)
{
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
	//Conversions to linear space.....
	float zBuffer = tex2Dlod(DepthBufferTAA, float4(texcoord,0,0)).x, Far = 1., Near = 0.125/Depth_Map_Adjust; //Near & Far Adjustment

	float2 C = float2( Far / Near, 1. - Far / Near ), Z = float2( zBuffer, 1-zBuffer );
	//MAD - RCP
	if (Depth_Map == 0) //DM0 Normal
		zBuffer = rcp(Z.x * C.y + C.x);
	else if (Depth_Map == 1) //DM1 Reverse
		zBuffer = rcp(Z.y * C.y + C.x);
	return smoothstep(0,1,zBuffer);
}
///////////////////////////////////////////////////////////TAA/////////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define iResolution float2(BUFFER_WIDTH, BUFFER_HEIGHT)

// YUV-RGB conversion routine from Hyper3D
float3 encodePalYuv(float3 rgb)
{   rgb = pow(rgb, 2.0); // gamma correction
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

	return pow(float3(dot(ycc, YCbCr2R), dot(ycc, YCbCr2G), dot(ycc, YCbCr2B)),rcp(2.0));
}

float4 Mask(float2 texcoord : TEXCOORD)
{   
	float current_buffer = Depth(texcoord);
	float past_single_buffer = tex2D(PDepthBufferTAA, texcoord).x;//Past Single Buffer
		
	//Used for a mask calculation
	//Velosity Mask
	float V = distance(abs(current_buffer),abs(past_single_buffer));
	
	float a = (V * pow(2,Mask_Power));	
	return a;
}

float4 TAA(float2 texcoord)
{
    float4 LastColor = tex2Dlod(PSBackBufferTAA,float4(texcoord,0,0) );//Past single Back Buffer

		if(Past_Frames)
			LastColor = tex2Dlod(PBackBufferTAA,float4(texcoord,0,0) );//Past many Back Buffer

    float3 antialiased = LastColor.xyz;
    float mixRate = min(LastColor.w, 0.5);

    float3 in0 = tex2D(BackBufferTAA, texcoord).xyz;

    antialiased = lerp(antialiased * antialiased, in0 * in0, mixRate);
    antialiased = sqrt(antialiased);

    float3 in1 = tex2D(BackBufferTAA, texcoord + float2(+pix.x, 0.0)).xyz;
    float3 in2 = tex2D(BackBufferTAA, texcoord + float2(-pix.x, 0.0)).xyz;
    float3 in3 = tex2D(BackBufferTAA, texcoord + float2(0.0, +pix.y)).xyz;
    float3 in4 = tex2D(BackBufferTAA, texcoord + float2(0.0, -pix.y)).xyz;
    float3 in5 = tex2D(BackBufferTAA, texcoord + float2(+pix.x, +pix.y)).xyz;
    float3 in6 = tex2D(BackBufferTAA, texcoord + float2(-pix.x, +pix.y)).xyz;
    float3 in7 = tex2D(BackBufferTAA, texcoord + float2(+pix.x, -pix.y)).xyz;
    float3 in8 = tex2D(BackBufferTAA, texcoord + float2(-pix.x, -pix.y)).xyz;

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

    mixRate = rcp(1.0 / mixRate + 1.0);

    float3 diff = antialiased - preclamping;
    float clampAmount = dot(diff,diff);

    mixRate += clampAmount * 4.0;
    mixRate = clamp(mixRate, 0.05, 0.5);

    antialiased = decodePalYuv(antialiased);

    float4 Done = float4(antialiased,mixRate);

	float M = saturate(lerp(Mask(texcoord).r,1,0));

	if(DeBug)
		Done = mixRate;
	
	if(Mask_TAA)
		Done = lerp(Done,tex2D(BackBufferTAA,texcoord),1-M);
		
    return Done;
}

void Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	color = TAA(texcoord);
}

void Current_BackBufferTAA(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0, out float depth : SV_Target1)
{
	color = tex2D(BackBufferTAA,texcoord);
	depth = Depth(texcoord);
}

void Past_BackBufferTAA(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingleC : SV_Target0, out float4 PastSingleD : SV_Target1, out float4 Past : SV_Target2)
{
	PastSingleC = tex2D(CBackBufferTAA,texcoord);
	PastSingleD = tex2D(CDepthBufferTAA,texcoord);
	Past = tex2D(BackBufferTAA,texcoord);
}

///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{ // Vertex shader generating a triangle covering the entire screen
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
			RenderTarget0 = CurrentBackBufferTAA;
			RenderTarget1 = CurrentDepthBufferTAA;
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
			RenderTarget1 = PastSingleDepthBufferTAA;
			RenderTarget2 = PastBackBufferTAA;

		}
	}
