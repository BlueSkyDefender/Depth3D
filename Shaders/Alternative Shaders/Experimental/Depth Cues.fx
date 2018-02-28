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

uniform float Power <
	ui_type = "drag";
	ui_min = 1.5; ui_max = 2.5;
	ui_label = "Shade Power";
	ui_tooltip = "Adjust the Shade Power Lower is Higher & Higher is Lower.\n"
				 "This improves AO, Shadows, & Darker Areas in game.\n"
				 "Number 2.0 is default.";
> = 2.0;

uniform float HV_Seperation <
	ui_type = "drag";
	ui_min = 2.5; ui_max = 12.5;
	ui_label = "Hoizontal & Vertical Seperation";
	ui_tooltip = "Determines the seperation between 4 points & Shade.\n"
				 "HV Seperation is 75/25 with a 50% reduction on V.\n"
				 "Hoizontal is more important than Vertical.\n"
				 "Number 6.250 is default.";
> = 6.250;

uniform float Spread <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 10.0;
	ui_label = "Shade Fill";
	ui_tooltip = "Adjust This to have the shade effect to fill in areas.\n"
				 "This is used for gap filling. AKA, Fake AO.\n"
				 "Number 5.0 is default.";
> = 5.0;

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
> = false;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define TextureSize float2(BUFFER_WIDTH, BUFFER_HEIGHT)
#define Sharpen_Power 0.5 //correction for BGpop errors

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
	
texture texB { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; MipLevels = 8;};

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
float4 CA = tex2D(BackBuffer, texcoord), CB = tex2D(BackBuffer, texcoord), CC;
const float offset[5] = {0.0, 1.0, 2.0, 3.0, 4.0};
const float weight[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};
	
	CA *= weight[0];
	CB *= weight[0];
	
float hstep = Spread * pix.x; // If only one use 3.750
float vstep = Spread * pix.y;

	[loop]
	for (int i = 0; i < 5; i++)
	{ 
		CA += (tex2D(BackBuffer, float2(texcoord.x + hstep * offset[i],texcoord.y + vstep * offset[i])) * weight[i]) + 
			  (tex2D(BackBuffer, float2(texcoord.x - hstep * offset[i], texcoord.y - vstep * offset[i])) * weight[i]);
			  
		CB += (tex2D(BackBuffer, float2(texcoord.x - hstep * offset[i],texcoord.y + vstep * offset[i])) * weight[i]) + 
			  (tex2D(BackBuffer, float2(texcoord.x + hstep * offset[i], texcoord.y - vstep * offset[i])) * weight[i]);
	} 
	
	CC = lerp(CA,CB,0.5);

	color = CC;
}

float4 Adjust(in float2 texcoord : TEXCOORD0)
{
float2 S = float2(HV_Seperation * pix.x,HV_Seperation * 0.5 * pix.y);

float4 H = lerp(tex2D(SamplerBlur, float2(texcoord.x + S.x, texcoord.y)),tex2D(SamplerBlur, float2(texcoord.x - S.x, texcoord.y)),0.5);
float4 V = lerp(tex2D(SamplerBlur, float2(texcoord.x, texcoord.y + S.y)),tex2D(SamplerBlur, float2(texcoord.x, texcoord.y - S.y)),0.5);
float4 HVC = lerp(H,V,0.25);// Hoizontal Sepration needs to be stronger

return HVC; 
}


float4 BGAdjust(in float2 texcoord : TEXCOORD0)
{
float2 S = float2(7.5,7.5);
S = float2(S.x * pix.x,S.y * 0.5 * pix.y);
float4 H = lerp(tex2D(SamplerBlur, float2(texcoord.x + S.x, texcoord.y)),tex2D(SamplerBlur, float2(texcoord.x - S.x, texcoord.y)),0.5);
float4 V = lerp(tex2D(SamplerBlur, float2(texcoord.x, texcoord.y + S.y)),tex2D(SamplerBlur, float2(texcoord.x, texcoord.y - S.y)),0.5);
float4 Combine = lerp(H,V,0.25);// Hoizontal Sepration needs to be stronger
return Combine; 
}

float3 GS(float3 color)
{
    float grayscale = dot(color.rgb, float3(0.3, 0.59, 0.11));
    color.r = grayscale;
    color.g = grayscale;
    color.b = grayscale;
	return clamp(color,0.003,1.0);//clamping to protect from over Dark.
}

float4 Sharpen_Out(float2 texcoord : TEXCOORD0)
{
	float4 RGBA;	
	//Formula for unsharp masking is Sharpened = Original + (Original - Blurred) * Amount.	
	RGBA = tex2D(BackBuffer,texcoord) - tex2D(SamplerBlur,texcoord);
	RGBA = saturate(RGBA * Sharpen_Power);
	RGBA = tex2D(BackBuffer,texcoord) + RGBA;
	
	return RGBA;
}

float4 DepthCues(float2 texcoord : TEXCOORD0)
{
	//Luma (SD video)	float3(0.299, 0.587, 0.114)
	//Luma (HD video)	float3(0.2126, 0.7152, 0.0722) https://en.wikipedia.org/wiki/Luma_(video)
	//Luma (HDR video)	float3(0.2627, 0.6780, 0.0593) https://en.wikipedia.org/wiki/Rec._2100
	float4 RGBA, A=tex2D(BackBuffer,texcoord);
	float3 RGB, Luma_Coefficient = float3(0.2627, 0.6780, 0.0593);
	float Con = 1.0 - 0.1875;
		
	//Formula for Image Pop = Original + (Original / Blurred) * Amount * Original.
	RGB = GS(tex2D(BackBuffer,texcoord).rgb * Con) / GS(Adjust(texcoord).rgb);
	float Grayscale = dot(RGB, smoothstep(0,1,Luma_Coefficient * Power));

	//Formula for BackGround Pop = Original + (Original - Blurred) * Amount .
	RGB = GS(tex2D(BackBuffer,texcoord).rgb) - GS(BGAdjust(texcoord).rgb);
	float BGGrayscale = dot(RGB, smoothstep(0,1,Luma_Coefficient * 2.0));
	float3 BGPop = GS(1-BGGrayscale);
	
	RGBA = saturate(Grayscale) + tex2D(BackBuffer,texcoord);
	float4 Combine = float4(lerp(GS(RGBA.rgb),BGPop.rgb,0.250),A.a);
	
	return Combine;
}

float4 CuesOut(float2 texcoord : TEXCOORD0)
{		
	float4 Out;

	float4 Combine = DepthCues(texcoord) * Sharpen_Out(texcoord);
	
	float4 Debug_Done = DepthCues(texcoord);
		
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
