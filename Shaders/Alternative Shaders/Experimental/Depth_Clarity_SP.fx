 ///**Depth Unsharp Mask**///
 ////----------------------//
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
 //*                                                                                                            																	*//
 //* 											Bilateral Filter Made by mrharicot ported over to Reshade by BSD																	*//
 //*											GitHub Link for sorce info github.com/SableRaf/Filters4Processin																	*//
 //* 											Shadertoy Link https://www.shadertoy.com/view/4dfGDH  Thank You.																	*//	 
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The resolution of the Bilateral Filtered Image. For 4k Use 2, 1.75 or 1.5. For 1440p Use 1.5, 1.375, or 1.25. For 1080p use 1.25, or 1.
#define Image_Division 1

uniform float contrast <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "Contrast";
	ui_tooltip = "Use if your Game is Too Dark";
> = 0;

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DirectX\0DirectX Alt\0OpenGL\0OpenGL Alt\0Raw Buffer\0Special\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 0.25; ui_max = 50.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map and sharpness.";
> = 5.0;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset is for the Special Depth Map Only";
> = 0.5;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform bool No_Depth_Map <
	ui_label = "No Depth Map";
	ui_tooltip = "If you have No Depth Buffer turn this On.";
> = false;

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
		
texture texF { Width = BUFFER_WIDTH/Image_Division; Height = BUFFER_HEIGHT/Image_Division; Format = RGBA8;};

sampler SamplerF
	{
		Texture = texF;
	};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
	
	return 1-saturate(float4(zBuffer.rrr,1));	
}
#define SIGMA 20
#define BSIGMA 0.1
#define MSIZE 10

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

float normpdf3(in float3 v, in float sigma)
{
	return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
}

void Filters(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)                                                                          
{
//Bilateral Filter//                                                                                                                                                                   
float3 c = tex2D(BackBuffer,texcoord.xy).rgb;
float sampleOffset = Depth(texcoord).r/0.5; //Depth Buffer Offset	
	const int kSize = (MSIZE-1)/2;	
	
	float weight[MSIZE] = 
	{  
	0.031225216, 
	0.033322271, 
	0.035206333, 
	0.036826804, 
	0.038138565, 
	0.039104044, 
	0.039695028, 
	0.039894000, 
	0.039695028, 
	0.039104044
	};  
		float3 final_colour;
		float Z;
		[unroll]
		for (int j = 0; j <= kSize; ++j)
		{
			weight[kSize+j] = normpdf(float(j), SIGMA);
			weight[kSize-j] = normpdf(float(j), SIGMA);
		}
		
		float3 cc;
		float factor;
		float bZ = 1.0/normpdf(0.0, BSIGMA);
		
		[loop]
		for (int i=-kSize; i <= kSize; ++i)
		{
			for (int j=-kSize; j <= kSize; ++j)
			{
			
				float2 XY;
				
				if(No_Depth_Map)
				{
					XY = float2(float(i),float(j))*(pix/0.5);
					cc = tex2D(BackBuffer,texcoord.xy+XY).rgb;
				}
				else
				{
					XY = float2(float(i),float(j))*pix;
					cc = tex2D(BackBuffer,texcoord.xy+XY*sampleOffset).rgb;
				}
				factor = normpdf3(cc-c, BSIGMA)*bZ*weight[kSize+j]*weight[kSize+i];
				Z += factor;
				final_colour += factor*cc;

			}
		}
		
		float4 Bilateral_Filter = float4(final_colour/Z, 1.0);
		
	color = Bilateral_Filter;
}

void Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color: SV_Target)
{	
	float4 Out;
	float R,G,B,A = 1;

	R = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).r - tex2D(SamplerF,float2(texcoord.x,texcoord.y)).r;
	G = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).g - tex2D(SamplerF,float2(texcoord.x,texcoord.y)).g;
	B = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).b - tex2D(SamplerF,float2(texcoord.x,texcoord.y)).b;
	
	R = saturate(R);
	G = saturate(G);
	B = saturate(B);
	
	float4 Combine = (float4(R,G,B,A))+tex2D(BackBuffer,float2(texcoord.x,texcoord.y)) * (1.0+contrast)/1.0;

	if (View_Adjustment == 0)
	{
	Out = Combine;
	}
	else
	{
	Out = texcoord.y > 0.5 ? tex2D(SamplerF,float2(texcoord.x,texcoord.y * 2 - 1)) : 1 - Depth(float2(texcoord.x,texcoord.y * 2));
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

technique Smart_Sharp
{			
			pass FilterOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Filters;
			RenderTarget = texF;
		}
			pass UnsharpMask
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}