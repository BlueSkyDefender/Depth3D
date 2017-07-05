 ////----------------------//
 ///**Depth Unsharp Mask**///
 //----------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Based Unsharp Mask                                      																													*//
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
 //*                                                                            																									*//
 //*                                                                                                            																	*//
 //* 																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The Max Depth amount.
#define Depth_Max 15

uniform float contrast <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "contrast";
	ui_tooltip = "contrast";
> = 0;

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DirectX\0DirectX Alt\0OpenGL\0OpenGL Alt\0Raw Buffer\0Special\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 50.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map for your games.";
> = 7.5;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset";
> = 0.5;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform float D_Adjust <
	ui_type = "drag";
	ui_min = 1; ui_max = 5;
	ui_label = "Depth Adjust";
	ui_tooltip = "Depth Adjust";
> = 2.5;

uniform bool View_Adjustment <
	ui_label = "View Adjustment";
	ui_tooltip = "Adjust the depth map and Depth Blur.";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture DepthBufferTex : DEPTH;

sampler DepthBuffer 
	{ 
		Texture = DepthBufferTex; 
	};
	
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture texDM  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA32F;}; 

sampler SamplerDM
	{
		Texture = texDM;
	};
	
texture BOut  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA32F;}; 

sampler SamplerBOut
	{
		Texture = BOut;
		AddressU = MIRROR;
		AddressV = MIRROR;
		AddressW = MIRROR;
	};

	
float4 Depth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float DDA = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float DA = Depth_Map_Adjust*2; //Depth Map Adjust - Near
		//All 1.0f are Far Adjustment
		
		//0. DirectX Custom Constant Far
		float DirectX = 2.0 * DDA * 1.0f / (1.0f + DDA - zBuffer * (1.0f - DDA));
		
		//1. DirectX Alternative
		float DirectXAlt = pow(abs(zBuffer - 1.0),DA);
		
		//2. OpenGL
		float OpenGL = 2.0 * DDA * 1.0f / (1.0f + DDA - (2.0 * zBuffer - 1.0) * (1.0f - DDA));
		
		//3. OpenGL Reverse
		float OpenGLRev = 2.0 * 1.0f * DDA / (DDA + 1.0f - (2.0 * zBuffer - 1.0) * (DDA - 1.0f));
		
		//4. Raw Buffer
		float Raw = pow(abs(zBuffer),DA);
		
		//5. Old Depth Map from 1.9.5
		float Old = 100 / (1 + 100 - (zBuffer/DDA) * (1 - 100));
		
		//6. Special Depth Map
		float Special = pow(abs(exp(zBuffer)*Offset),(DA*25));
		
		if (Depth_Map == 0)
		{
		zBuffer = DirectX;
		}
		
		else if (Depth_Map == 1)
		{
		zBuffer = DirectXAlt;
		}

		else if (Depth_Map == 2)
		{
		zBuffer = OpenGL;
		}
		
		else if (Depth_Map == 3)
		{
		zBuffer = OpenGLRev;
		}
		else if (Depth_Map == 4)
		{
		zBuffer = Raw;
		}		
		else if (Depth_Map == 5)
		{
		zBuffer = Special;
		}
	
	return float4(zBuffer.rrr,1);	
}

void DitherDepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0)
{
		float R,G,B,A = 1;
		
		float DM = Depth(texcoord).r;
		
		R = DM;
		G = DM;
		B = DM;
		
	// Dither for DepthBuffer adapted from gedosato ramdom dither https://github.com/PeterTh/gedosato/blob/master/pack/assets/dx9/deband.fx
	// I noticed in some games the depth buffer started to have banding so this is used to remove that.
			
	float dither_bit  = 6.0;
	float noise = frac(sin(dot(texcoord, float2(12.9898, 78.233))) * 43758.5453 * 1);
	float dither_shift = (1.0 / (pow(2,dither_bit) - 1.0));
	float dither_shift_half = (dither_shift * 0.5);
	dither_shift = dither_shift * noise - dither_shift_half;
	R += -dither_shift;
	R += dither_shift;
	R += -dither_shift;
	G += -dither_shift;
	G += dither_shift;
	G += -dither_shift;
	B += -dither_shift;
	B += dither_shift;
	B += -dither_shift;
	
	// Dither End	
	
	Color = 1-float4(R,G,B,A);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void GaussianBlurImage(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0)                                                                          
{                                                                                                                                                                   
		
		//Associated Depth Blur AKA Simple Dof
		float3 col;
		
		float sampleOffset =  tex2D(SamplerDM,texcoord).r/0.5; 
		
		col  = tex2D(BackBuffer, texcoord + float2(pix.x, -pix.y) * D_Adjust * sampleOffset).rgb;
		col += tex2D(BackBuffer, texcoord - pix * D_Adjust * sampleOffset).rgb;
		col += tex2D(BackBuffer, texcoord + pix * D_Adjust * sampleOffset).rgb;
		col += tex2D(BackBuffer, texcoord - float2(pix.x, -pix.y) * D_Adjust * sampleOffset).rgb;

		col = col/4;
		
    Color = float4(col,1);
}

void Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color: SV_Target)
{	
	float4 Out;
	float3 NR,NG,NB,R,G,B;
	if (View_Adjustment == 0)
	{
	NR = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).rgb - tex2D(SamplerBOut,float2(texcoord.x,texcoord.y)).rgb;

	R = (NR.rrr+NR.ggg+NR.bbb)/3;

	Out = float4(R,1)+tex2D(BackBuffer,float2(texcoord.x,texcoord.y));
		
	Out = lerp(Out,tex2D(BackBuffer,float2(texcoord.x,texcoord.y)),0.5) * (1.0+contrast)/1.0;
	}
	else
	{
	Out = texcoord.y > 0.5 ? tex2D(SamplerBOut,float2(texcoord.x,texcoord.y * 2 - 1)) : tex2D(SamplerDM,float2(texcoord.x,texcoord.y * 2));
	}
	
	color = Out;
}


///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////

// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

//*Rendering passes*//

technique VR_Clarity
{			
			pass zbuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = DitherDepthMap;
			RenderTarget = texDM;
		}
			pass BlurImage
		{
			VertexShader = PostProcessVS;
			PixelShader = GaussianBlurImage;
			RenderTarget = BOut;
		}
			pass UnsharpMask
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}