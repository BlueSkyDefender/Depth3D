 ////---------------------//
 ///**Cues Unsharp Mask**///
 //---------------------////

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
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform float Contrast <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "Contrast";
	ui_tooltip = "Use if your Game is Too Dark";
> = 0;

uniform float Power <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 1.5;
	ui_label = "Shade Power";
	ui_tooltip = "Adjust the Shade Power Lower is Higher & Higher is Lower.\n"
				 "This improves AO, Shadows, & Darker Areas in game.\n"
				 "Number 1.0 is default.";
> = 1.0;

uniform float Spread <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 20.0;
	ui_label = "Shade Fill";
	ui_tooltip = "Adjust This to have the shade effect to fill in areas.\n"
				 "This is used for gap filling. AKA, Fake AO.\n"
				 "Number 7.5 is default.";
> = 7.5;

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
	
texture texB { Width = BUFFER_WIDTH*0.5; Height = BUFFER_HEIGHT*0.5; Format = RGBA8; MipLevels = 8;};

sampler SamplerBlur
	{
		Texture = texB;
		MipLODBias = 1.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)                                                                          
{
	float4 CC = tex2D(BackBuffer, texcoord);

	float2 samples[10] = { float2(-0.695914, 0.457137), float2(-0.203345, 0.620716), float2(0.962340, -0.194983), float2(0.473434, -0.480026), float2(0.519456, 0.767022), 
						   float2(0.185461, -0.893124), float2(0.507431, 0.064425), float2(0.896420, 0.412458), float2(-0.321940, -0.932615), float2(-0.791559, -0.597705) };  
			
	float2 Adjust = float2(Spread,Spread)*pix;

		[unroll]
		for (int i = 0; i < 10; i++)
		{  
			CC += tex2D(BackBuffer, texcoord + Adjust * samples[i]);
		} 
		
		CC *= 0.09090909f;
		
		color = CC;
}

float4 Adjust(in float2 texcoord : TEXCOORD0)
{
float2 S = float2(Spread * pix.x,Spread * 0.5 * pix.y);// Hoizontal Sepration needs to be stronger
float4 H = lerp(tex2D(SamplerBlur, float2(texcoord.x + S.x, texcoord.y)),tex2D(SamplerBlur, float2(texcoord.x - S.x, texcoord.y)),0.5);
float4 V = lerp(tex2D(SamplerBlur, float2(texcoord.x, texcoord.y + S.y)),tex2D(SamplerBlur, float2(texcoord.x, texcoord.y - S.y)),0.5);
float4 HVC = lerp(H,V,0.50);

return HVC; 
}

float3 GS(float3 color)
{
    float grayscale = dot(color.rgb, float3(0.3, 0.59, 0.11));
    color.r = grayscale;
    color.g = grayscale;
    color.b = grayscale;
	return clamp(color,0.003,1.0);//clamping to protect from over Dark.
}

float DepthCues(float2 texcoord : TEXCOORD0)
{
	//Luma (SD video)	float3(0.299, 0.587, 0.114)
	//Luma (HD video)	float3(0.2126, 0.7152, 0.0722) https://en.wikipedia.org/wiki/Luma_(video)
	//Luma (HDR video)	float3(0.2627, 0.6780, 0.0593) https://en.wikipedia.org/wiki/Rec._2100
	float3 RGB_A, RGB_B, Luma_Coefficient = float3(0.2627, 0.6780, 0.0593);
		
	//Formula for Image Pop = Original + (Original / Blurred) * Amount.
	RGB_A = GS( tex2D(BackBuffer,texcoord).rgb ) / GS( Adjust(texcoord).rgb );
	float3 FGPop = GS(RGB_A.rgb);
	
	//Formula for BackGround Pop = Original + (Original - Blurred) * Amount .
	RGB_B = GS(tex2D(BackBuffer,texcoord).rgb) - GS(Adjust(texcoord).rgb);
	float3 BGPop = GS(1-RGB_B.rgb * Power);
	
	//RGB = saturate(RGB_A);
	float Combine = dot(lerp(FGPop,BGPop,0.5),Luma_Coefficient);
	
	return saturate(Combine);
}

float4 CuesOut(float2 texcoord : TEXCOORD0)
{		
	float4 Out, Combine = tex2D(BackBuffer,texcoord) * DepthCues(texcoord).xxxx;
	float Con = Contrast;
			
	Con = (Con < 0.0) ? max(Con/100.0, -100.0) : min(Con, 100.0);
	Combine.rgb=(Combine.rgb-0.5)*max(Con+1.0, 0.0)+0.5;
		
	float4 Debug_Done = DepthCues(texcoord).xxxx;
		
	if (!Debug_View)
	{
		Out = Combine;
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
technique Monocular_Cues
{
			pass BlurFilter
		{
			VertexShader = PostProcessVS;
			PixelShader = Blur;
			RenderTarget = texB;
		}	
			pass CuesUnsharpMask
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
