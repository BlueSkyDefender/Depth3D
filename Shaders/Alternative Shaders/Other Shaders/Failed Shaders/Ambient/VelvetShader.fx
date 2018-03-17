 ////----------//
 ///**FakeAmbient**///
 //----------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Fake Ambient is an Image Enhancement by Unsharp Masking the Depth Buffer.       																						*//
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
 //*            																																									*//
 //* Image Enhancement by Unsharp Masking the Depth Buffer            																												*//
 //* https://www.uni-konstanz.de/mmsp/pubsys/publishedFiles/LuCoDe06.pdf           																									*//
 //* https://dl.acm.org/citation.cfm?id=1142016           																															*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Normal\0Normal Reversed\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 2;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform float Balance <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Effect and BackBuffer Balance";
	ui_tooltip = "Adjust the Shade Blance for $%@$.\n"
				 "Number 0.5 is default.";
> = 0.5;


uniform float Spread <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 32.5;
	ui_label = "Shade Fill";
	ui_tooltip = "Adjust This to have the shade effect to fill in areas.\n"
				 "Number 7.5 is default.";
> = 7.5;

uniform int FakeAmbient <
	ui_type = "combo";
	ui_items = "Off No Color\0Avrage Ambient\0You Pick\0";
	ui_label = "Fake Ambient Modes";
	ui_tooltip = "Pick your Fake Ambient Mode.";
> = 2;

uniform float3 TintColor <
	ui_type = "color";
	ui_label = "Tint Color";
	ui_tooltip = "Which color tint";
	> = float3(0.0, 0.0, 0.0);

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
> = false;
	
/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
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
	
texture texFullGuss { Width = BUFFER_WIDTH*0.5; Height = BUFFER_HEIGHT*0.5; Format = RGBA8; MipLevels = 8;};

sampler SamplerBlur
	{
		Texture = texFullGuss;
		MipLODBias = 3.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////	
texture texLumC {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumC																
	{
		Texture = texLumC;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
float3 LumC(in float2 texcoord : TEXCOORD0)
	{
		float3 lumCoeff = float3(0.2125, 0.7154, 0.0721);
		float3 Luminance = tex2Dlod(SamplerLumC,float4(texcoord,0,0)).rgb; //Average Luminance Texture Sample 
		return lerp(dot(Luminance, lumCoeff),Luminance,7.5);
	}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float3 zBuffer(in float2 texcoord : TEXCOORD0)    
{		
		float3 DM;
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Depth_Map_Adjust
		//Conversions to linear space.....
		//Near & Far Adjustment
		float FGNear = 0.125/25; //Division Depth Map Adjust - Near
		float BGNear = 0.125/125; //Division Depth Map Adjust - Near
		float Near = 0.125/0.5; //Division Depth Map Adjust - Near
		float Far = 1; //Far Adjustment
		
		//1. Raw ZBuffer
		float Raw = Far * Near / (Far + zBuffer * (Near - Far));
		
		//2. Raw ZBuffer Reverse
		float RawReverse = Far * Near / (Near + zBuffer * (Far - Near));
		
		//1. Normal
		float NormalFG = Far * FGNear / (Far + zBuffer * (FGNear - Far));
		float NormalBG = Far * BGNear / (Far + zBuffer * (BGNear - Far));
		
		//2. Reverse
		float NormalReverseFG = Far * FGNear / (FGNear + zBuffer * (Far - FGNear));
		float NormalReverseBG = Far * BGNear / (BGNear + zBuffer * (Far - BGNear));
		
		if (Depth_Map == 0)
		{
		DM.x = NormalFG;
		DM.y = NormalBG;
		DM.z = Raw;
		}		
		else if (Depth_Map == 1)
		{
		DM.x = NormalReverseFG;
		DM.y = NormalReverseBG;
		DM.z = RawReverse;
		}
	
return smoothstep(0.003,1.0,1-DM.xyz);
}

void Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)                                                                          
{
	float3 CC = zBuffer(texcoord);

		float2 samples[10] = { float2(-0.695914, 0.457137), float2(-0.203345, 0.620716), float2(0.962340, -0.194983), float2(0.473434, -0.480026), float2(0.519456, 0.767022), 
						   float2(0.185461, -0.893124), float2(0.507431, 0.064425), float2(0.896420, 0.412458), float2(-0.321940, -0.932615), float2(-0.791559, -0.597705) };  
						   
	float2 Adjust = float2(Spread,Spread) * pix;

		[unroll]
		for (int i = 0; i < 10; i++)
		{  
			CC += zBuffer(texcoord + Adjust * samples[i]);
		} 
		
		CC *= 0.09090909f;
		
		color = float4(CC,1);
}

float3 Adjust(in float2 texcoord : TEXCOORD0)
{
float2 S = float2(Spread * pix.x,Spread * pix.y);

float3 H = lerp(tex2D(SamplerBlur, float2(texcoord.x + S.x, texcoord.y)).xyz,tex2D(SamplerBlur, float2(texcoord.x - S.x, texcoord.y)).xyz,0.5);
float3 V = lerp(tex2D(SamplerBlur, float2(texcoord.x, texcoord.y + S.y)).xyz,tex2D(SamplerBlur, float2(texcoord.x, texcoord.y - S.y)).xyz,0.5);
float3 HVC = lerp(H,V,0.5);

return HVC; 
}

float Valvet(float2 texcoord : TEXCOORD0)
{
	//Luma (SD video)	float3(0.299, 0.587, 0.114)
	//Luma (HD video)	float3(0.2126, 0.7152, 0.0722) https://en.wikipedia.org/wiki/Luma_(video)
	//Luma (HDR video)	float3(0.2627, 0.6780, 0.0593) https://en.wikipedia.org/wiki/Rec._2100
	float A = tex2D(BackBuffer,texcoord).a, APower = 5.0f;
	float3 RGB_A, RGB_B, RGB_C, Luma_Coefficient = float3(0.2126, 0.7152, 0.0722);
	
	if(FakeAmbient == 1)
	APower = 15.0f;
	
	//Formula for Valvet = Original * (1-Original - 1-Blurred) * Amount.
	RGB_A = zBuffer(texcoord).xxx  -  Adjust(texcoord).xxx ;
	RGB_A = dot(RGB_A,Luma_Coefficient * APower);
	
	RGB_B = zBuffer(texcoord).yyy  -  Adjust(texcoord).yyy ;
	RGB_B = dot(RGB_B,Luma_Coefficient * APower);

	RGB_C = zBuffer(texcoord).zzz  -  Adjust(texcoord).zzz ;
	RGB_C = dot(RGB_C,Luma_Coefficient * APower);
	
	//Foreground and Background mix adjust
	float Combine = lerp(RGB_A,RGB_B,0.5);
	
	Combine = lerp(Combine,RGB_C,0.125);	
	
	return smoothstep(0,1,Combine);
}
float4 Average_Luminance_Color(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float3 Average_Lum = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).rgb;
	return float4(Average_Lum,1);
}
float4 CuesOut(float2 texcoord : TEXCOORD0)
{		
	float4 Out;
	float3 Mix;
	
	if(FakeAmbient == 0)
	{
		Mix = 1-Valvet(texcoord).xxx;
	}
	else if(FakeAmbient == 1)
	{
		Mix = 1-(LumC(texcoord) * Valvet(texcoord).xxx);
	}
	else
	{
		float3 lumCoeff = float3(0.2125, 0.7154, 0.0721);
		Mix = 1-(lerp(dot(TintColor, lumCoeff),TintColor,5) * Valvet(texcoord).xxx);
	}
	
	float4 Combine = 1-(float4(Mix,1) * 1-tex2D(BackBuffer, texcoord));
	float4 Debug_Done = 1-float4(Mix,1);
		
	if (!Debug_View)
	{
		Out = lerp(Combine,tex2D(BackBuffer, texcoord),Balance);
	}
	else
	{		
		Out = Debug_Done;
	}
	
	return Out;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = CuesOut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
	if(timer <= 10000)
	{
	//DEPTH
	//D
	float PosXD = -0.035+PosX, offsetD = 0.001;
	float4 OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
	float4 TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
	D = OneD-TwoD;
	
	//E
	float PosXE = -0.028+PosX, offsetE = 0.0005;
	float4 OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
	float4 TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
	float4 ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
	E = (OneE-TwoE)+ThreeE;
	
	//P
	float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
	float4 OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.682));
	float4 TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.682));
	float4 ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
	P = (OneP-TwoP) + ThreeP;

	//T
	float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
	float4 OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
	float4 TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
	T = OneT+TwoT;
	
	//H
	float PosXH = -0.0071+PosX;
	float4 OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
	float4 TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
	float4 ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.003,0.009));
	H = (OneH-TwoH)+ThreeH;
	
	//Three
	float offsetFive = 0.001, PosX3 = -0.001+PosX;
	float4 OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
	float4 TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
	float4 ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
	Three = (OneThree-TwoThree)+ThreeThree;
	
	//DD
	float PosXDD = 0.006+PosX, offsetDD = 0.001;	
	float4 OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
	float4 TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
	DD = OneDD-TwoDD;
	
	//Dot
	float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;		
	float4 OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
	Dot = OneDot;
	
	//INFO
	//I
	float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
	float4 OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
	float4 TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
	float4 ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
	I = OneI+TwoI+ThreeI;
	
	//N
	float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
	float4 OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
	float4 TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
	N = OneN-TwoN;
	
	//F
	float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
	float4 OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
	float4 TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
	float4 ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
	F = (OneF-TwoF)+ThreeF;
	
	//O
	float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
	float4 OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
	float4 TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
	O = OneO-TwoO;
	}
	
	Website = D+E+P+T+H+Three+DD+Dot+I+N+F+O ? float4(1.0,1.0,1.0,1) : Color;
	
	if(timer >= 10000)
	{
	Done = Color;
	}
	else
	{
	Done = Website;
	}

	return Done;
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
technique Velvet_Shader
{
			pass GussBlurFilter
		{
			VertexShader = PostProcessVS;
			PixelShader = Blur;
			RenderTarget = texFullGuss;
		}	
			pass AverageLuminanceandColor
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Luminance_Color;
			RenderTarget = texLumC;
		}
			pass FaleAO
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
