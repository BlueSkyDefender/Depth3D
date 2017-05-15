 ////------------------------------------------//
 ///**Polynomial Barrel Distortion for HMDs**///
 //-----------------------------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Barrel Distortion for HMD type Displays For SuperDepth3D v1.1																													*//
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
 //* Also thank you Zapal for your help with fixing a few things in this shader. 																									*//
 //* https://reshade.me/forum/shader-presentation/2128-3d-depth-map-based-stereoscopic-shader?start=900#21236																		*//
 //* 																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform int Interpupillary_Distance <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Interpupillary Distance";
	ui_tooltip = "Determines the distance between your eyes.\n" 
				 "In Monoscopic mode it's x offset calibration.\n"
				 "Default is 0.";
> = 0;

uniform int Stereoscopic_Mode_Convert <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0SbS to Alt-TnB\0TnB to Alt-TnB\0Monoscopic\0";
	ui_label = "3D Display Mode Conversion";
	ui_tooltip = "3D display output conversion for SbS and TnB.";
> = 0;

uniform float Lens_Center <
	ui_type = "drag";
	ui_min = 0.475; ui_max = 0.575;
	ui_label = "Lens Center";
	ui_tooltip = "Adjust Lens Center. Default is 0.5";
> = 0.5;

uniform float Lens_Distortion <
	ui_type = "drag";
	ui_min = -0.325; ui_max = 5;
	ui_label = "Lens Distortion";
	ui_tooltip = "Lens distortion value, positive values of k2 gives barrel distortion, negative give pincushion.\n"
				 "Default is 0.01";
> = 0.01;

uniform float3 Polynomial_Colors <
	ui_type = "drag";
	ui_min = 0.250; ui_max = 2.0;
	ui_tooltip = "Adjust the Polynomial Distortion Red, Green, Blue.\n"
				 "Default is (R 1.0, G 1.0, B 1.0)";
	ui_label = "Polynomial Color Distortion";
> = float3(1.0, 1.0, 1.0);

uniform float2 Zoom_Aspect_Ratio <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2;
	ui_label = "Lens Zoom & Aspect Ratio";
	ui_tooltip = "Lens Zoom amd Aspect Ratio..\n" 
				 "Default is 1.0.";
> = float2(1.0,1.0);

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Select how you like the Edge of the screen to look like.";
> = 1;

uniform bool Diaspora <
	ui_label = "Diaspora Fix";
	ui_tooltip = "A small fix for the game Diaspora.";
> = false;

//////////////////////////////////////////////////HMD Profiles//////////////////////////////////////////////////////////////////

uniform int HMD_Profiles <
	ui_type = "combo";
	ui_items = "Off\0Profile One\0Profile Two\0"; //Add your own Profile here.
	ui_label = "HMD Profiles";
	ui_tooltip = "Head Mounted Display Profiles.";
> = 0;

float4x4 HMDProfiles()
{
float Zoom = Zoom_Aspect_Ratio.x;
float Aspect_Ratio = Zoom_Aspect_Ratio.y;

float IPD = Interpupillary_Distance;
float LC = Lens_Center;
float LD = Lens_Distortion;
float Z = Zoom;
float AR = Aspect_Ratio;
float3 PC = Polynomial_Colors;
float4x4 Done;

	//Make your own Profile here.
	if (HMD_Profiles == 1)
	{
		IPD = 0.0;					//Interpupillary Distance. Default is 0
		LC = 0.5; 					//Lens Center. Default is 0.5
		LD = 0.01;					//Lens Distortion. Default is 0.01
		Z = 1.0;					//Zoom. Default is 1.0
		AR = 1.0;					//Aspect Ratio. Default is 1.0
		PC = float3(1,1,1);			//Polynomial Colors. Default is (Red 1.0, Green 1.0, Blue 1.0)
	}
	
	//Make your own Profile here.
	if (HMD_Profiles == 2)
	{
		IPD = -25.0;				//Interpupillary Distance.
		LC = 0.5; 					//Lens Center. Default is 0.5
		LD = 0.250;					//Lens Distortion. Default is 0.01
		Z = 1.0;					//Zoom. Default is 1.0
		AR = 0.925;					//Aspect Ratio. Default is 1.0
		PC = float3(0.5,0.75,1);	//Polynomial Colors. Default is (Red 1.0, Green 1.0, Blue 1.0)
	}

if(Diaspora)
{
Done = float4x4(float4(IPD,PC.x,Z,0),float4(LC,PC.y,AR,0),float4(LD,PC.z,0,0),float4(0,0,0,0)); //Diaspora frak up 4x4 fix
}
else
{
Done = float4x4(float4(IPD,LC,LD,0),float4(PC.x,PC.y,PC.z,0),float4(Z,AR,0,0),float4(0,0,0,0));
}
return Done;
}

////////////////////////////////////////////////HMD Profiles End/////////////////////////////////////////////////////////////////

//Interpupillary Distance Section//
float IPDS()
{
	float IPDS = HMDProfiles()[0][0];
	return IPDS;
}

//Lens Center Section//
float LCS()
{
	float LCS = HMDProfiles()[0][1];
	return LCS;
}

//Lens Distortion Section//
float LD_k2()
{
	float LD = HMDProfiles()[0][2];
	return LD;
}

//Lens Zoom & Aspect Ratio Section//
float2 Z_A()
{
	float2 ZA = float2(HMDProfiles()[2][0],HMDProfiles()[2][1]);
	return ZA;
}

//Polynomial Colors Section//
float3 P_C()
{
	float3 PC = float3(HMDProfiles()[1][0],HMDProfiles()[1][1],HMDProfiles()[1][2]);
	return PC;
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
	if(Stereoscopic_Mode_Convert == 0 || Stereoscopic_Mode_Convert == 2) //SbS
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x*0.5,texcoord.y));
	SBSR = tex2D(BackBuffer, float2(texcoord.x*0.5+0.5,texcoord.y));
	}
	else if(Stereoscopic_Mode_Convert == 1 || Stereoscopic_Mode_Convert == 3) //TnB
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5));
	SBSR = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5+0.5));
	}
	else
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y)); //Monoscopic No stereo
	}
	
color = SBSL;
colorT = SBSR;
}

float2 DL(float2 p, float k_RGB) //Cubic Lens Distortion Left
{
	float LC = 1-LCS();
	float LD_k1 = 0.01; //Lens distortion value, positive values of k1 give barrel distortion, negative give pincushion.
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * LD_k1 * k_RGB + (LD_k2() * k_RGB * r2 * r2);

	 p.x = newRadius * (p.x-0.5)+0.5;
	 p.y = newRadius * (p.y-0.5)+0.5;
	
	return p;
}

float2 DR(float2 p, float k_RGB) //Cubic Lens Distortion Right
{
	float LC = LCS();
	float LD_k1 = 0.01; //Lens distortion value, positive values of k1 give barrel distortion, negative give pincushion.
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
		
		Red = 1 / P_C().x;
		Green = 1/ P_C().y;
		Blue = 1/ P_C().z;
		
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
		
		Red = 1 / P_C().x;
		Green = 1 / P_C().y;
		Blue = 1 / P_C().z;
		
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
	float4 Out;
	
	float X = Z_A().x;
	float Y = Z_A().y * Z_A().x * 2;
	
	float posH = Y - 1;
	float midH = posH*BUFFER_HEIGHT/2*pix.y;
		
	float posV = X - 1;
	float midV = posV*BUFFER_WIDTH/2*pix.x;
	
	if( Stereoscopic_Mode_Convert == 0 || Stereoscopic_Mode_Convert == 1)
	{
	Out = texcoord.x < 0.5 ? PDL(float2(((texcoord.x*2)*X)-midV + IPDS() * pix.x,(texcoord.y*Y)-midH)) : PDR(float2(((texcoord.x*2-1)*X)-midV - IPDS() * pix.x,(texcoord.y*Y)-midH));
	}
	else if (Stereoscopic_Mode_Convert == 2 || Stereoscopic_Mode_Convert == 3)
	{
	Out = texcoord.y < 0.5 ? PDL(float2((texcoord.x*X)-midV + IPDS() * pix.x,((texcoord.y*2)*Y)-midH)) : PDR(float2((texcoord.x*X)-midV - IPDS() * pix.x,((texcoord.y*2-1)*Y)-midH));
	}
	else
	{
	Out = PDL(float2((texcoord.x*X)-midV + IPDS() * pix.x,(texcoord.y*Y)-midH));
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

technique Polynomial_Barrel_Distortion
{			
			pass StereoMonoPass
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