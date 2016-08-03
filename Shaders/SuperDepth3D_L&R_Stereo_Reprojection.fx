 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v2.0 L & R Eye Rework of Code																											*//
 //* For Reshade 3.0																																								*//
 //* --------------------------																																						*//
 //* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																								*//
 //* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																				*//
 //* I would also love to hear about a project you are using it with.																												*//
 //* https://creativecommons.org/licenses/by/3.0/us/																																*//
 //*																																												*//
 //* Have fun,																																										*//
 //* Jose Negrete AKA BlueSkyDefender																																				*//
 //*																																												*//
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				*//	
 //* ---------------------------------																																				*//
 //*																																												*//
 //* Original work was based on Shader Based on forum user 04348 and be located here http://reshade.me/forum/shader-presentation/1594-3d-anaglyph-red-cyan-shader-wip#15236			*//
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
uniform int AltDepthMap <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent AltDepthMap.";
> = 0;

uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 100;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes.";
> = 25;

uniform int Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point.";
> = 0;

uniform int WA <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Warp Adjust";
	ui_tooltip = "Adjust the warp in both eyes.";
> = 0;

uniform bool DepthFlip <
	ui_label = "Depth Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

uniform bool DepthMap <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform int CustomDM <
	ui_type = "combo";
	ui_items = "Custom Off\0Custom One +\0Custom One -\0Custom Two +\0Custom Two -\0Custom Three +\0Custom Three -\0Custom Four +\0Custom Four -\0Custom Five +\0Custom Five -\0Custom Six +\0Custom Six -\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Adjust your own Custom Depth Map.";
> = 0;

uniform float Far <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
	ui_label = "Far";
	ui_tooltip = "Far Depth Map Adjustment.";
> = 1.5;
 
 uniform float Near <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
	ui_label = "Near";
	ui_tooltip = "Near Depth Map Adjustment.";
> = 1.5;

uniform bool BD <
	ui_label = "Barrel Distortion";
	ui_tooltip = "Barrel Distortion for HMD type Displays.";
> = false;

uniform float Hsquish <
	ui_type = "drag";
	ui_min = 1; ui_max = 2;
	ui_label = "Horizontal Squish";
	ui_tooltip = "Horizontal squish cubic distortion value. Default is 1.050.";
> = 1.050;

uniform float K <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Lens Distortion";
	ui_tooltip = "Lens distortion coefficient. Default is -0.15.";
> = -0.15;

uniform float KCube <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Cubic Distortion";
	ui_tooltip = "Cubic distortion value. Default is 0.5.";
> = 0.5;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#include "ReShade.fxh"

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerCL
	{
		Texture = texCL;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
sampler SamplerCR
	{
		Texture = texCR;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
sampler2D SamplerCC
	{
		Texture = texCC;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
//Left Eye Depth Map Information
float SbSdepthL (float2 texcoord) 
	
	{

	 float4 color = tex2D(SamplerCC, texcoord);

			if (DepthFlip)
			texcoord.y =  1 - texcoord.y;


	float4 depthL = ReShade::GetLinearizedDepth(float2(texcoord.x, texcoord.y));

	if (CustomDM == 0)
	{		
		//Naruto
		if (AltDepthMap == 0)
		{
		depthL = (pow(abs(depthL),0.75));
		}
	}
	else
	{
		//Custom One +
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthL = (-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Custom One -
		if (CustomDM == 2)
		{
		float cF = Far;
		float cN = Near;
		depthL = 1-(-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Custom Two +
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthL = (1 - cF) / (cN - cF * depthL); 
		}
		
		//Custom Two -
		if (CustomDM == 4)
		{
		float cF  = Far;
		float cN = Near;
		depthL = 1 - (1 - cF) / (cN - cF * depthL); 
		}
		
		//Custom Three +
		if (CustomDM == 5)
		{
		float cF  = Far;
		float cN = Near;
		depthL = (cF * 1/depthL + cN);
		}
		
		//Custom Three -
		if (CustomDM == 6)
		{
		float cF  = Far;
		float cN = Near;
		depthL = 1 - (cF * 1/depthL + cN);
		}
		
		//Custom Four +
		if (CustomDM == 7)
		{
		float cF = Far;
		float cN = Near;
		depthL = log(depthL/cF)/log(cN/cF);
		}
		
		//Custom Four -
		if (CustomDM == 8)
		{
		float cF = Far;
		float cN = Near;		
		depthL = 1 - log(depthL/cF)/log(cN/cF);
		}
		
		//Custom Five +
		if (CustomDM == 9)
		{
		float cF = Far;
		float cN = Near;
		depthL = (cF) / (cF - depthL * ((1 - cN) / (cF - cN * depthL)) * (cF - 1));
		}
		
		//Custom Five -
		if (CustomDM == 10)
		{
		float cF = Far;
		float cN = Near;
		depthL = 1 - (cF) / (cF - depthL * ((1 - cN) / (cF - cN * depthL)) * (cF - 1));
		}
		
		//Custom Six +
		if (CustomDM == 11)
		{
		float cF = Far;
		float cN = Near;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
		
		//Custom Six -
		if (CustomDM == 12)
		{
		float cF = Far;
		float cN = Near;
		depthL = 1 - (cN - depthL * cN) + (depthL*cF);
		}
	}

    float4 DL =  depthL;

	color.r = 1 - DL.r;
	
	return color.r;	
	}

//Right Eye Depth Map Information	
float SbSdepthR (float2 texcoord) 	
{

	 float4 color = tex2D(SamplerCC, texcoord);

			if (DepthFlip)
			texcoord.y =  1 - texcoord.y;
	
	float4 depthR = ReShade::GetLinearizedDepth(float2(texcoord.x, texcoord.y));
		
	if (CustomDM == 0)
	{		
		//Naruto
		if (AltDepthMap == 0)
		{
		depthR = (pow(abs(depthR),0.75));
		}
	}
	else
	{
		//Custom One +
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthR = (-0+(pow(abs(depthR),cN))*cF);
		}
		
		//Custom One -
		if (CustomDM == 2)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1-(-0+(pow(abs(depthR),cN))*cF);
		}
		
		//Custom Two +
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthR = (1 - cF) / (cN - cF * depthR); 
		}
		
		//Custom Two -
		if (CustomDM == 4)
		{
		float cF  = Far;
		float cN = Near;
		depthR = 1 - (1 - cF) / (cN - cF * depthR); 
		}
		
		//Custom Three +
		if (CustomDM == 5)
		{
		float cF  = Far;
		float cN = Near;
		depthR = (cF * 1/depthR + cN);
		}
		
		//Custom Three -
		if (CustomDM == 6)
		{
		float cF  = Far;
		float cN = Near;
		depthR = 1 - (cF * 1/depthR + cN);
		}
		
		//Custom Four +
		if (CustomDM == 7)
		{
		float cF = Far;
		float cN = Near;	
		depthR = log(depthR/cF)/log(cN/cF);
		}
		
		//Custom Four -
		if (CustomDM == 8)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1 - log(depthR/cF)/log(cN/cF);
		}
		
		//Custom Five +
		if (CustomDM == 9)
		{
		float cF = Far;
		float cN = Near;
		depthR = (cF) / (cF - depthR * ((1 - cN) / (cF - cN * depthR)) * (cF - 1));
		}
		
		//Custom Five -
		if (CustomDM == 10)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1 - (cF) / (cF - depthR * ((1 - cN) / (cF - cN * depthR)) * (cF - 1));
		}
		
		//Custom Six +
		if (CustomDM == 11)
		{
		float cF = Far;
		float cN = Near;
		depthR = (cN - depthR * cN) + (depthR*cF);
		}
		
		//Custom Six -
		if (CustomDM == 12)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1 - (cN - depthR * cN) + (depthR*cF);
		}
	}

    float4 DR = depthR;	

	color.r = 1 - DR.r;

	return color.r;	
	}

//////////////////////////////////////////Render Left Screen//////////////////////////////////////////////////
void PS_renderL(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
	const float samples[3] = {0.5, 0.66, 1};
	float minDepthL = 1.0;
	float2 uv = 0;
	float Parallax = 1;
	
	//color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y)).rgb;

	//Left Eye
	[unroll]
	for (int j = 0; j < 3; ++j)
	{
		uv.x = samples[j] * Depth;
		minDepthL= min(minDepthL,SbSdepthL(texcoord.xy+uv*pix.xy));

			float parallaxL = Depth * (1 - Parallax / minDepthL);
			
			color.rgb = tex2D(ReShade::BackBuffer, texcoord.xy + float2(parallaxL,0)*pix.xy).rgb;
		}
	}


//////////////////////////////////////////Render Right Screen//////////////////////////////////////////////////
void PS_renderR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
	const float samples[3] = {0.5, 0.66, 1};
	float minDepthR = 1.0;
	float2 uv = 0;
	float Parallax = 1;
	
	//color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y)).rgb;

	//Left Eye
	[unroll]
	for (int j = 0; j < 3; ++j)
	{
		uv.x = samples[j] * Depth;
		minDepthR= min(minDepthR,SbSdepthR(texcoord.xy+uv*pix.xy));

			float parallaxR = Depth * (1 - Parallax / minDepthR);
			
			color.rgb = tex2D(ReShade::BackBuffer, texcoord.xy - float2(parallaxR,0)*pix.xy).rgb;
		}
	}


//////////////////////////////////////////////////////Barrle_Distortion/////////////////////////////////////////////////////
float3 BDL(float2 texcoord)

{
	float k = K;
	float kcube = KCube;

	float r2 = (texcoord.x-0.5) * (texcoord.x-0.5) + (texcoord.y-0.5) * (texcoord.y-0.5);       
	float f = 0.0;

	f = 1 + r2 * (k + kcube * sqrt(r2));

	float x = f*(texcoord.x-0.5)+0.5;
	float y = f*(texcoord.y-0.5)+0.5;
	float3 BDListortion = tex2D(SamplerCL,float2(x,y)).rgb;

	return BDListortion.rgb;
}

float3 BDR(float2 texcoord)

{
	float k = K;
	float kcube = KCube;

	float r2 = (texcoord.x-0.5) * (texcoord.x-0.5) + (texcoord.y-0.5) * (texcoord.y-0.5);       
	float f = 0.0;

	f = 1 + r2 * (k + kcube * sqrt(r2));

	float x = f*(texcoord.x-0.5)+0.5;
	float y = f*(texcoord.y-0.5)+0.5;
	float3 BDRistortion = tex2D(SamplerCR,float2(x,y)).rgb;

	return BDRistortion.rgb;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
	if(BD)
	{
	float pos = Hsquish-1;
	float mid = pos*BUFFER_HEIGHT/2*pix.y;
	color = texcoord.x > 0.5 ? BDL(float2(texcoord.x*2-1 + Perspective * pix.x,(texcoord.y*Hsquish)-mid)).rgb : BDR(float2(texcoord.x*2 - Perspective * pix.x,(texcoord.y*Hsquish)-mid)).rgb;
	}
	else
	{
	color = texcoord.x > 0.5 ? tex2D(SamplerCL, float2(texcoord.x*2-1 + Perspective * pix.x, texcoord.y)).rgb : tex2D(SamplerCR, float2(texcoord.x*2 - Perspective * pix.x, texcoord.y)).rgb;
	}
}


///////////////////////////////////////////////Depth Map View//////////////////////////////////////////////////////////////////////

float4 PS(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
		
	float4 color = tex2D(SamplerCC, texcoord);
		
		
		if (DepthFlip)
		texcoord.y = 1 - texcoord.y;
		
		float4 depthM = ReShade::GetLinearizedDepth(texcoord.xy);
		
		if (CustomDM == 0)
	{	
		//Naruto
		if (AltDepthMap == 0)
		{
		depthM = (pow(abs(depthM),0.75));
		}
	}
	else
	{
		//Custom One +
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthM = (-0+(pow(abs(depthM),cN))*cF);
		}
		
		//Custom One -
		if (CustomDM == 2)
		{
		float cF = Far;
		float cN = Near;
		depthM = 1-(-0+(pow(abs(depthM),cN))*cF);
		}
		
		//Custom Two +
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthM = (1 - cF) / (cN - cF * depthM); 
		}
		
		//Custom Two -
		if (CustomDM == 4)
		{
		float cF  = Far;
		float cN = Near;
		depthM = 1 - (1 - cF) / (cN - cF * depthM); 
		}
		
		//Custom Three +
		if (CustomDM == 5)
		{
		float cF  = Far;
		float cN = Near;
		depthM = (cF * 1/depthM + cN);
		}
		
		//Custom Three -
		if (CustomDM == 6)
		{
		float cF  = Far;
		float cN = Near;
		depthM = 1 - (cF * 1/depthM + cN);
		}
		
		//Custom Four +
		if (CustomDM == 7)
		{
		float cF = Far;
		float cN = Near;	
		depthM = log(depthM/cF)/log(cN/cF);
		}
		
		//Custom Four -
		if (CustomDM == 8)
		{
		float cF = Far;
		float cN = Near;	
		depthM = 1 - log(depthM/cF)/log(cN/cF);
		}
		
		//Custom Five +
		if (CustomDM == 9)
		{
		float cF = Far;
		float cN = Near;
		depthM = (cF) / (cF - depthM * ((1 - cN) / (cF - cN * depthM)) * (cF - 1));
		}
		
		//Custom Five -
		if (CustomDM == 10)
		{
		float cF = Far;
		float cN = Near;
		depthM = 1 - (cF) / (cF - depthM * ((1 - cN) / (cF - cN * depthM)) * (cF - 1));
		}
		
		//Custom Six +
		if (CustomDM == 11)
		{
		float cF = Far;
		float cN = Near;
		depthM = (cN - depthM * cN) + (depthM * cF);
		}
		
		//Custom Six -
		if (CustomDM == 12)
		{
		float cF = Far;
		float cN = Near;
		depthM = 1 - (cN - depthM * cN) + (depthM * cF);
		}
	}
	
	float4 DM = depthM;
	
	if (DepthMap)
	{
	color.rgb = DM.rrr;				
	}
	return color;
	}

//*Rendering passes*//

technique Super_Depth3D
	{
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderL;
			RenderTarget = texCL;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderR;
			RenderTarget = texCR;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;
			RenderTarget = texCC;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS;
		}
	}
