 ////-------//
 ///**TAA**///
 //-------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Temporal AA "Epic Games" implementation + Some Magic:
 //* For ReShade 3.0+
 //*  ---------------------------------
 //*                                                                           TAA
 //* Due Diligence
 //* Based on port by yvt
 //* https://www.shadertoy.com/view/4tcXD2
 //* https://de45xmedrsdbp.cloudfront.net/Resources/files/TemporalAA_small-59732822.pdf
 //* If I missed any please tell me.
 //*
 //* LICENSE
 //* ============
 //* Image Contrast Enhancement is licenses under: Attribution-NoDerivatives 4.0 International
 //*
 //* You are free to:
 //* Share - copy and redistribute the material in any medium or format
 //* for any purpose, even commercially.
 //* The licensor cannot revoke these freedoms as long as you follow the license terms.
 //* Under the following terms:
 //* Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made.
 //* You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
 //*
 //* NoDerivatives - If you remix, transform, or build upon the material, you may not distribute the modified material.
 //*
 //* No additional restrictions - You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
 //*
 //* https://creativecommons.org/licenses/by-nd/4.0/
 //*
 //* Have fun,
 //* Jose Negrete AKA BlueSkyDefender
 //*
 //* https://github.com/BlueSkyDefender/Depth3D
 //*
 //* Special thank you too "Jak0bW" j4712@web.de For Mouse Compatibility & Guidance.
 //* Please feel free to message him for help and information
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if exists "Overwatch.fxh"                                           //Overwatch Intercepter//
	#include "Overwatch.fxh"
#else //DA_W Depth_Linearization | DB_X Depth_Flip
	static const float DA_W = 0.0, DB_X = 0;
	#define NC 0
	#define NP 0
#endif

uniform float Clamping_Adjust <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
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

uniform float Persistence <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.00;
	ui_label = "User Adjust";
	ui_tooltip = "Increase persistence of the frames this is really the Temporal Part.\n"
				 "Default is 0.25. But, a value around 0.05 is recommended.";
	ui_category = "TAA";
> = 0.25;

uniform bool ColorDelta <
	ui_label = "Use Delta Masking";
	ui_category = "TAA";
> = false;

uniform float Delta_Power <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Delta power";
	ui_tooltip = "Extra Image clamping based on delta between.\n"
				 "Default is 0.25.";
	ui_category = "TAA";
> = 0.25;

//Depth Map//
uniform int Debug <
	ui_type = "combo";
	ui_items = "Normal\0Debug One\0Debug Two\0";
	ui_label = "Debug View";
> = false;

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Normal\0Reverse\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
	ui_category = "Depth Buffer";
> = DA_W;

uniform float Depth_Map_Adjust <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 1.0; ui_max = 1000.0; ui_step = 0.125;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map and sharpness distance.";
	ui_category = "Depth Buffer";
> = 250.0;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Buffer";
> = DB_X;

uniform bool Use_Depth <
	ui_label = "Use Depth Masking";
	ui_category = "Depth Buffer";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
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

texture CurrentBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;};

sampler CBackBuffer
	{
		Texture = CurrentBackBuffer;
	};

texture PastBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;};

sampler PBackBuffer
	{
		Texture = PastBackBuffer;
	};

texture PastSingleBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;};

sampler PSBackBuffer
	{
		Texture = PastSingleBackBuffer;
	};
//Total amount of frames since the game started.
uniform uint framecount < source = "framecount"; >;
uniform float timer < source = "timer"; >;
///////////////////////////////////////////////////////////TAA/////////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define iResolution float2(BUFFER_WIDTH, BUFFER_HEIGHT)
#define Alternate framecount % 2 == 0

float Depth(float2 texcoord)
{
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;

	float zBuffer = tex2D(DepthBuffer, texcoord).x; //Depth Buffer
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1.0, Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near

	float2 Z = float2( zBuffer, 1-zBuffer );

	if (Depth_Map == 0)//DM0. Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = Far * Near / (Far + Z.y * (Near - Far));

	return step(smoothstep(0,1,zBuffer),0.0005);
}


float4 BB_H(float2 TC)
{
	return tex2D(BackBuffer, TC );
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
    float4 PastColor = tex2Dlod(PBackBuffer,float4(texcoord,0,0) );//Past Back Buffer
		   PastColor = (1-Per) * tex2D(BackBuffer, texcoord) + Per * PastColor;

    float3 antialiased = PastColor.xyz;
    float mixRate = min(PastColor.w, 0.5), MB = Clamping_Adjust;//WIP

    float3 BB = tex2D(BackBuffer, texcoord).xyz;

    antialiased = lerp(antialiased * antialiased, BB * BB, mixRate);
    antialiased = sqrt(antialiased);

	const float2 XYoffset[9] = { float2( 0, 0 ), float2( 0,+pix.y ), float2( 0,-pix.y), float2(+pix.x, 0), float2(-pix.x, 0), float2(-pix.x,-pix.y), float2(+pix.x,-pix.y), float2(-pix.x,+pix.y), float2(+pix.x,+pix.y) };

	float3 minColor = encodePalYuv(tex2D(BackBuffer, texcoord + XYoffset[0]).rgb) - MB;
	float3 maxColor = encodePalYuv(tex2D(BackBuffer, texcoord + XYoffset[0]).rgb) + MB;
	for(int i = 1; i < 9; ++i)
	{ //DX9 work around.
		minColor = min(minColor,encodePalYuv(tex2Dlod(BackBuffer, float4(texcoord + XYoffset[i],0,0)).rgb)) - MB;
		maxColor = max(maxColor,encodePalYuv(tex2Dlod(BackBuffer, float4(texcoord + XYoffset[i],0,0)).rgb)) + MB;
	}
	antialiased = encodePalYuv(antialiased);

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
	
	//Need to check for DX9
	float4 Output = float4(antialiased,mixRate);
    if(Use_Depth)
    	Output = lerp(float4(antialiased,mixRate), tex2D(BackBuffer, texcoord), Depth(texcoord));
        
    return Output;
}

void Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y, Scale = 2;
	float3 D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	float4 Color = BB_H(texcoord), M = (tex2D(CBackBuffer,texcoord).rgba - tex2D(PSBackBuffer,texcoord).rgba);
	float Mask = 1;
	
	float4 Per = tex2Dlod(PBackBuffer,float4(texcoord,0,0) );//Past Back Buffer
	
	if(ColorDelta)
	{ 
		Per *= Delta_Power;
		Mask = max(saturate(length(M) * 50.0),length(Per));	
	}
	
	if(Debug == 1)
	Color = TAA(texcoord).w;
	if(Debug == 2)
	Color = float4(1,0,0,1);
   
  float4 T_A_A = lerp(TAA(texcoord),Color,saturate(1-Mask));

  if(texcoord.x < pix.x * Scale && 1-texcoord.y < pix.y * Scale)
    T_A_A = Alternate ? 0 : 1; //Jak0bW Suggestion for Mouse Jiggle Wiggle

	[branch] if(timer <= 12500)
	{
		//DEPTH
		//D
		float PosXD = -0.035+PosX, offsetD = 0.001;
		float3 OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float3 TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
		D = OneD-TwoD;

		//E
		float PosXE = -0.028+PosX, offsetE = 0.0005;
		float3 OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
		float3 TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float3 ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
		E = (OneE-TwoE)+ThreeE;

		//P
		float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
		float3 OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.775));
		float3 TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.680));
		float3 ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		P = (OneP-TwoP) + ThreeP;

		//T
		float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
		float3 OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
		float3 TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
		T = OneT+TwoT;

		//H
		float PosXH = -0.0072+PosX;
		float3 OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
		float3 TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
		float3 ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.00325,0.009));
		H = (OneH-TwoH)+ThreeH;

		//Three
		float offsetFive = 0.001, PosX3 = -0.001+PosX;
		float3 OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
		float3 TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
		float3 ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
		Three = (OneThree-TwoThree)+ThreeThree;

		//DD
		float PosXDD = 0.006+PosX, offsetDD = 0.001;
		float3 OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float3 TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DD = OneDD-TwoDD;

		//Dot
		float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;
		float3 OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
		Dot = OneDot;

		//INFO
		//I
		float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
		float3 OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
		float3 TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
		float3 ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
		I = OneI+TwoI+ThreeI;

		//N
		float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
		float3 OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
		float3 TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
		N = OneN-TwoN;

		//F
		float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
		float3 OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
		float3 TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
		float3 ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
		F = (OneF-TwoF)+ThreeF;

		//O
		float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
		float3 OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
		float3 TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
		O = OneO-TwoO;
		//Website
		color = float4(D+E+P+T+H+Three+DD+Dot+I+N+F+O,1.) ? 1-texcoord.y*50.0+48.35f : T_A_A;
	}
	else
		color = T_A_A;
}

void Current_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0)
{
	color = BB_H(texcoord);
}

void Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingleC : SV_Target0, out float4 Past : SV_Target1)
{
	PastSingleC = tex2D(CBackBuffer,texcoord);
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
