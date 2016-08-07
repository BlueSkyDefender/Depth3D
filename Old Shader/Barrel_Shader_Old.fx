 ////---------------//
 ///*Barrel Shader*///
 //---------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Barrel Shader v0.2																																								*//
 //* For ReShade 3.0																																								*//
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
 //* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*//
 //*							 				Cubic Lens Distortion HLSL Shader (ported by CeeJay) http://ceejay.dk/																*//
 //*																																												*//
 //*												Original Lens Distortion Algorithm from SSontech (Syntheyes)																	*//
 //*														http://www.ssontech.com/content/lensalg.html																			*//
 //*																																												*//
 //*															r2 = image_aspect*image_aspect*u*u + v*v																			*//
 //*															f = 1 + r2*(k + kcube*sqrt(r2))																						*//
 //*															u' = f*u																											*//
 //*															v' = f*v																											*//
 //*																																												*//
 //*																author : François Tarlier																						*//
 //*												website : http://www.francois-tarlier.com/blog/tag/lens-distortion																*//
 //*																																												*//
 //*											Then again re-ported by BlueSkyDefender. http://github.com/BlueSkyDefender/Depth3D													*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 
uniform float K <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Lens Distortion";
	ui_tooltip = "Lens distortion coefficient.";
> = -0.15;

uniform float KCube <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Cubic Distortion";
	ui_tooltip = "Cubic distortion value.";
> = 0.5;

uniform float Hsquish <
	ui_type = "drag";
	ui_min = 1; ui_max = 1.5;
	ui_label = "Horizontal Squish";
	ui_tooltip = "Horizontal squish cubic distortion value.";
> = 1;

/////////////////////////////////////////////Barrel Shader Starts Here/////////////////////////////////////////////////////////////////
#include "ReShade.fxh"

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

sampler BorderSampler
{
	Texture = BackBufferTex;
	AddressU = Border; AddressV = Border;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
	SRGBTexture = false;
};

float3 BD(float2 texcoord)

{
	
	float k = K;
	
	float kcube = KCube;

	float r2 = (texcoord.x-0.5) * (texcoord.x-0.5) + (texcoord.y-0.5) * (texcoord.y-0.5);       
	float f = 0.0;

	f = 1 + r2 * (k + kcube * sqrt(r2));

	float x = f*(texcoord.x-0.5)+0.5;
	float y = f*(texcoord.y-0.5)+0.5;
	float3 BDistortion = tex2D(BorderSampler,float2(x,y)).rgb;

	return BDistortion.rgb;
}

void  BarrelDistortion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
	float pos = Hsquish-1;
	float mid = pos*1000*pix.y;
	color.rgb = BD(float2(texcoord.x,(texcoord.y*Hsquish)-mid));
}

//*Rendering passes*//

technique Barrel_Shader
	{
			pass

		{
		VertexShader = PostProcessVS;
		PixelShader = BarrelDistortion;
		}
	}
