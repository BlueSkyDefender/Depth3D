////-------------------//
 ///**SuperDepth3DHMD**///
 //-------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.4																																	*//
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
 //* 																																												*//
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform int IPD <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Optical Pupillary Distance Adjust";
	ui_tooltip = "Determines the distance between your eyes. Default is 0";
> = 0;

uniform int Polynomial_Barrel_Distortion <
	ui_type = "combo";
	ui_items = "Off\0Polynomial Distortion\0";
	ui_label = "Polynomial Barrel Distortion";
	ui_tooltip = "Barrel Distortion for HMD type Displays.";
> = 0;

uniform int Stereoscopic_Mode_Convert <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0";
	ui_label = "3D Display Mode Conversion";
	ui_tooltip = "3D display output conversion for SbS and TnB.";
> = 0;

uniform float Lens_Center <
	ui_type = "drag";
	ui_min = 0.475; ui_max = 0.575;
	ui_label = "Lens Center";
	ui_tooltip = "Adjust Lens Center. Default is 0.5";
> = 0.5;

uniform float LD_k1<
	ui_type = "drag";
	ui_min = -1; ui_max = 5;
	ui_label = "Lens Distortion k1";
	ui_tooltip = "Lens distortion value. Not is 0.0";
> = 0.01;

uniform float Lens_Distortion <
	ui_type = "drag";
	ui_min = -1; ui_max = 5;
	ui_label = "Lens Distortion k2";
	ui_tooltip = "Lens distortion value. Not is 0.0";
> = 0.01;

uniform float3 Polynomial_Colors <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 2.0;
	ui_tooltip = "Adjust the Polynomial Distortion Red, Green, Blue. Default is (R 1.0, G 1.0, B 1.0)";
	ui_label = "Polynomial Color Distortion";
> = float3(1.0, 1.0, 1.0);

uniform float2 Horizontal_Vertical_Squish <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2;
	ui_label = "Lens Zoom & Aspect Ratio";
	ui_tooltip = "Adjust Horizontal and Vertical squish cubic distortion value. Default is 1.0.";
> = float2(1,1);

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Select how you like the Edge of the screen to look like.";
> = 1;

//Add Profiles here

uniform int HMD_Profiles <
	ui_type = "combo";
	ui_items = "Off\0Profile One\0";
	ui_label = "Head Mounted Display Profiles";
	ui_tooltip = "Preset Head Mounted Display Profiles";
> = 0;

////////////////////////////////////////////////HMD Profiles/////////////////////////////////////////////////////////////////
//Lens Distortion Area//
float LD_k2()
{
float L_D = Lens_Distortion;
if (HMD_Profiles == 0)
{
 L_D;
}

if (HMD_Profiles == 1)
{
 L_D = -0.5;
}
return L_D;
}

//Horizontal Vertical Squish Area//
float2 H_V_S()
{
float2 H_V_S = Horizontal_Vertical_Squish;
if (HMD_Profiles == 0)
{
 H_V_S.x = 1 / H_V_S.x;
 H_V_S.y = H_V_S.y * H_V_S.x * 2;
}

if (HMD_Profiles == 1)
{
 H_V_S = float2(1,1.25);
}
return H_V_S;
}

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
	
sampler SamplerCLMIRROR
	{
		Texture = texCL;
		AddressU = MIRROR;
		AddressV = MIRROR;
		AddressW = MIRROR;
	};
	
sampler SamplerCLBORDER
	{
		Texture = texCL;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

sampler SamplerCLCLAMP
	{
		Texture = texCL;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};

sampler SamplerCRMIRROR
	{
		Texture = texCR;
		AddressU = MIRROR;
		AddressV = MIRROR;
		AddressW = MIRROR;
	};
	
sampler SamplerCRBORDER
	{
		Texture = texCR;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
sampler SamplerCRCLAMP
	{
		Texture = texCR;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
////////////////////////////////////////////////////Polynomial_Distortion/////////////////////////////////////////////////////
void LR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	
float4 SBSL, SBSR;
	if(Stereoscopic_Mode_Convert == 0)
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x*0.5,texcoord.y));
	SBSR = tex2D(BackBuffer, float2(texcoord.x*0.5+0.5,texcoord.y));
	}
	else
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5));
	SBSR = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5+0.5));
	}
	
color = SBSL;
colorT = SBSR;
}

float2 DL(float2 p, float k_RGB) //Cubic Lens Distortion Left
{
	float LC = 1-Lens_Center;
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * LD_k1 * k_RGB + (LD_k2() * k_RGB * r2 * r2);

	 p.x = newRadius * (p.x-0.5)+0.5;
	 p.y = newRadius * (p.y-0.5)+0.5;
	
	return p;
}

float2 DR(float2 p, float k_RGB) //Cubic Lens Distortion Right
{
	float LC = Lens_Center;
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * LD_k1 * k_RGB + (LD_k2() * k_RGB * r2 * r2);

	 p.x = newRadius  * (p.x-0.5)+0.5;
	 p.y = newRadius  * (p.y-0.5)+0.5;
	
	return p;
}

float4 PDL(float2 texcoord)		//Texture = texCL Left

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = 1 / Polynomial_Colors.x;
		Green = 1/ Polynomial_Colors.y;
		Blue = 1/ Polynomial_Colors.z;
		
		uv_red = DL(texcoord.xy-sectorOrigin,Red) + sectorOrigin;
		uv_green = DL(texcoord.xy-sectorOrigin,Green) + sectorOrigin;
		uv_blue = DL(texcoord.xy-sectorOrigin,Blue) + sectorOrigin;
		
		if(Custom_Sidebars == 0)
		{
		color_red = tex2D(SamplerCLMIRROR, uv_red).r;
		color_green = tex2D(SamplerCLMIRROR, uv_green).g;
		color_blue = tex2D(SamplerCLMIRROR, uv_blue).b;
		}
		else if(Custom_Sidebars == 1)
		{
		color_red = tex2D(SamplerCLBORDER, uv_red).r;
		color_green = tex2D(SamplerCLBORDER, uv_green).g;
		color_blue = tex2D(SamplerCLBORDER, uv_blue).b;
		}
		else
		{
		color_red = tex2D(SamplerCLCLAMP, uv_red).r;
		color_green = tex2D(SamplerCLCLAMP, uv_green).g;
		color_blue = tex2D(SamplerCLCLAMP, uv_blue).b;
		}

		if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
		{
			color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
		}
		else
		{
			color = float4(0,0,0,1);
		}
		return color;
		
	}
	
	float4 PDR(float2 texcoord)		//Texture = texCR Right

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0); //sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = 1 / Polynomial_Colors.x;
		Green = 1 / Polynomial_Colors.y;
		Blue = 1 / Polynomial_Colors.z;
		
		uv_red = DR(texcoord.xy-sectorOrigin,Red) + sectorOrigin;
		uv_green = DR(texcoord.xy-sectorOrigin,Green) + sectorOrigin;
		uv_blue = DR(texcoord.xy-sectorOrigin,Blue) + sectorOrigin;
		
		if(Custom_Sidebars == 0)
		{
		color_red = tex2D(SamplerCRMIRROR, uv_red).r;
		color_green = tex2D(SamplerCRMIRROR, uv_green).g;
		color_blue = tex2D(SamplerCRMIRROR, uv_blue).b;
		}
		else if(Custom_Sidebars == 1)
		{
		color_red = tex2D(SamplerCRBORDER, uv_red).r;
		color_green = tex2D(SamplerCRBORDER, uv_green).g;
		color_blue = tex2D(SamplerCRBORDER, uv_blue).b;
		}
		else
		{
		color_red = tex2D(SamplerCRCLAMP, uv_red).r;
		color_green = tex2D(SamplerCRCLAMP, uv_green).g;
		color_blue = tex2D(SamplerCRCLAMP, uv_blue).b;
		}

		if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
		{
			color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
		}
		else
		{
			color = float4(0,0,0,1);
		}
		return color;
		
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{	

	float posH = H_V_S().y - 1;
	float midH = posH*BUFFER_HEIGHT/2*pix.y;
		
	float posV = H_V_S().x-1;
	float midV = posV*BUFFER_WIDTH/2*pix.x;
	
	color = texcoord.x < 0.5 ? PDL(float2(((texcoord.x*2)*H_V_S().x)-midV + IPD * pix.x,(texcoord.y*H_V_S().y)-midH)) : PDR(float2(((texcoord.x*2-1)*H_V_S().x)-midV - IPD * pix.x,(texcoord.y*H_V_S().y)-midH));

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

technique Polynomial_Barrel_Distortion_HMDs
{			
			pass SinglePassStereo
		{
			VertexShader = PostProcessVS;
			PixelShader = LR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;
		}
			pass SidebySidePolynomialBarrelDistortion
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;	
		}
}