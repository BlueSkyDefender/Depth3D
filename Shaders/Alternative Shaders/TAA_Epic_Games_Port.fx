// Temporal AA Epic Games' implementation+ Magic:
// https://de45xmedrsdbp.cloudfront.net/Resources/files/TemporalAA_small-59732822.pdf
//
// Originally written by yvt for https://www.shadertoy.com/view/4tcXD2
// Feel free to use this in your shader!



uniform float Clamping_Adjust <
	ui_type = "drag";
	ui_min = 0; ui_max = 0.5;
	ui_label = "Clamping Adjust";
	ui_tooltip = "Adjust Clamping that effects Blur.\n"
				 "Default is Zero.";
	ui_category = "TAA";
> = 0.0;

uniform int Clamping <
	ui_type = "combo";
	ui_items = "All Differences\0Some Differences\0";
	ui_label = "Clamping Type";
	ui_tooltip = "Clamping Type changes the type of masking used for TAA.";
	ui_category = "TAA";
> = 1;

uniform int Past_Frame <
	ui_type = "combo";
	ui_items = "Default\0User Mode\0";
	ui_label = "Past Frame";
	ui_tooltip = "Select the Past Frame Blending.";
	ui_category = "TAA";
> = 0;

uniform float Persistence <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.00;
	ui_label = "User Adjust";
	ui_tooltip = "Increase persistence of the frames.";
	ui_category = "TAA";
> = 1.0;

uniform bool HFR_AA <
	ui_label = "HFR AA";
	ui_label = "This allows most monitors to assist in AA if your FPS is 60 or above and Locked to your monitors refresh-rate.";
	ui_category = "HFRAA";
> = false;

uniform float HFR_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Mask Adjustment";
	ui_tooltip = "Use this to adjust the Mask.\n"
				 "Default is 1.00";
	ui_category = "HFRAA";
> = 0.5;

uniform bool Debug <
	ui_label = "Debug View";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
texture BackBufferTex : COLOR;

sampler BackBuffer
	{
		Texture = BackBufferTex;
	};

texture CurrentBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;};

sampler CBackBuffer
	{
		Texture = CurrentBackBuffer;
	};

texture PastBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;};

sampler PBackBuffer
	{
		Texture = PastBackBuffer;
	};

texture PastSingleBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;};

sampler PSBackBuffer
	{
		Texture = PastSingleBackBuffer;
	};
//Total amount of frames since the game started.
uniform uint framecount < source = "framecount"; >;
///////////////////////////////////////////////////////////TAA/////////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define iResolution float2(BUFFER_WIDTH, BUFFER_HEIGHT)
#define Alternate framecount % 2 == 0

float4 BB_H(float2 TC)
{
  float Shift;
  if(Alternate && HFR_AA)
    Shift = pix.x;

	return tex2D(BackBuffer, TC + float2(+Shift * saturate(HFR_Adjust), 0.0));
}

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
{   float Per = 1-Persistence;
    float4 PastColor = tex2Dlod(PSBackBuffer,float4(texcoord,0,0) );//Past Back Buffer

  if(Past_Frame == 1)
  {
    PastColor = tex2Dlod(PBackBuffer,float4(texcoord,0,0) );
		PastColor = (1-Per) * tex2D(PSBackBuffer, texcoord) + Per * PastColor;
	}

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
	float MB = Clamping_Adjust;

    float3 minColor = min(min(min(in0, in1), min(in2, in3)), in4) - MB;
    float3 maxColor = max(max(max(in0, in1), max(in2, in3)), in4) + MB;
    minColor = lerp(minColor, min(min(min(in5, in6), min(in7, in8)), minColor), 0.5);
    maxColor = lerp(maxColor, max(max(max(in5, in6), max(in7, in8)), maxColor), 0.5);

   	float3 preclamping = antialiased;
    antialiased = clamp(antialiased, minColor, maxColor);

    mixRate = rcp(1.0 / mixRate + 1.0);

    float3 diff = antialiased - preclamping;

	if(Clamping)
    	diff.x = dot(diff,diff);
    else
    	diff.x = length(diff);

    float clampAmount = diff.x;

    mixRate += clampAmount * 4.0;
    mixRate = clamp(mixRate, 0.05, 0.5);

    antialiased = decodePalYuv(antialiased);

	if(Debug)
		antialiased = mixRate;

    return float4(antialiased,mixRate);
}

void Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	color = TAA(texcoord);
}

void Current_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	color = BB_H(texcoord);
}

void Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target0, out float4 Past : SV_Target1)
{
	PastSingle = tex2D(CBackBuffer,texcoord);
	Past = BB_H(texcoord);
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
			PixelShader = Current_BackBuffer;
			RenderTarget = CurrentBackBuffer;
		}
			pass Out
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
			pass PBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BackBuffer;
			RenderTarget0 = PastSingleBackBuffer;
			RenderTarget1 = PastBackBuffer;

		}
	}
