 ////-------------------//
 ///**3D Image Adjust**///
 //-------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* 3D Image Adjust                                		            																											*//
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

uniform int Stereoscopic_Mode_Convert <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Monoscopic\0";
	ui_label = "3D Display Mode Conversion";
	ui_tooltip = "3D display output conversion for SbS and TnB.";
> = 0;

uniform float2 LAdjust<
	ui_type = "drag";
	ui_min = -750.0; ui_max = 750.0;
	ui_label = "Image Position Adjust";
	ui_tooltip = "Adjust the BackBuffer Postion if it's off by a bit.";
> = float2(0.0,0.0);

uniform float2 RAdjust<
	ui_type = "drag";
	ui_min = -750.0; ui_max = 750.0;
	ui_label = "Image Position Adjust";
	ui_tooltip = "Adjust the BackBuffer Postion if it's off by a bit.";
> = float2(0.0,0.0);
	
uniform float2 Horizontal_Vertical_SquishL <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2;
	ui_label = "Horizontal & Vertical Left";
	ui_tooltip = "Adjust Horizontal and Vertical squish cubic distortion value. Default is 1.0.";
> = float2(1,1);

uniform float2 Horizontal_Vertical_SquishR <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2;
	ui_label = "Horizontal & Vertical Right";
	ui_tooltip = "Adjust Horizontal and Vertical squish cubic distortion value. Default is 1.0.";
> = float2(1,1);

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
	
sampler SamplerCL
	{
		Texture = texCL;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
sampler SamplerCR
	{
		Texture = texCR;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
void LR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	
float4 SBSL, SBSR;
	if(Stereoscopic_Mode_Convert == 0) //SbS
	{
		SBSL = tex2D(BackBuffer, float2(texcoord.x*0.5,texcoord.y));
		SBSR = tex2D(BackBuffer, float2(texcoord.x*0.5+0.5,texcoord.y));
	}
	else if(Stereoscopic_Mode_Convert == 1) //TnB
	{
		SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5));
		SBSR = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5+0.5));
	}
	else if(Stereoscopic_Mode_Convert == 2)
	{
		SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y)); //Monoscopic No stereo
	}
	
color = SBSL;
colorT = SBSR;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{	
float4 Out;

	float LtexX = texcoord.x + LAdjust.x * pix.x;
	float LtexY = texcoord.y + LAdjust.y * pix.y;
	
	float RtexX = texcoord.x + RAdjust.x * pix.x;
	float RtexY = texcoord.y + RAdjust.y * pix.y;
	
	float posHL = Horizontal_Vertical_SquishL.y-1;
	float midHL = posHL*BUFFER_HEIGHT/2*pix.y;
		
	float posVL = Horizontal_Vertical_SquishL.x-1;
	float midVL = posVL*BUFFER_WIDTH/2*pix.x;
	
	float posHR = Horizontal_Vertical_SquishR.y-1;
	float midHR = posHR*BUFFER_HEIGHT/2*pix.y;
		
	float posVR = Horizontal_Vertical_SquishR.x-1;
	float midVR = posVR*BUFFER_WIDTH/2*pix.x;

	
	if( Stereoscopic_Mode_Convert == 0)
	{
		Out = texcoord.x < 0.5 ? tex2D(SamplerCL,float2((LtexX*Horizontal_Vertical_SquishL.x)-midVL,(LtexY*Horizontal_Vertical_SquishL.y)-midHL)) : tex2D(SamplerCR,float2((RtexX*Horizontal_Vertical_SquishR.x)-midVR,(RtexY*Horizontal_Vertical_SquishR.y)-midHR));
	}
	else if (Stereoscopic_Mode_Convert == 1)
	{
		Out = texcoord.y < 0.5 ? tex2D(SamplerCL,float2((LtexX*Horizontal_Vertical_SquishL.x)-midVL,(LtexY*Horizontal_Vertical_SquishL.y)-midHL)) :  tex2D(SamplerCR,float2((RtexX*Horizontal_Vertical_SquishR.x)-midVR,(RtexY*Horizontal_Vertical_SquishR.y)-midHR));
	}
	else if (Stereoscopic_Mode_Convert == 2 )
	{
		Out = tex2D(BackBuffer,float2((texcoord.x*Horizontal_Vertical_SquishL.x)-midVL,(texcoord.y*Horizontal_Vertical_SquishL.y)-midHL));
	}
	
	return Out;
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
technique Image_Adjuster

{		
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = LR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;

		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
