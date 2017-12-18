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
	float Con = (1.0 - 0.1875)/1.0;
		
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
	//#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	float HEIGHT = BUFFER_HEIGHT/2,WIDTH = BUFFER_WIDTH/2;	
	float2 LCD,LCE,LCP,LCT,LCH,LCThree,LCDD,LCDot,LCI,LCN,LCF,LCO;
	float size = 9.5,set = BUFFER_HEIGHT/2,offset = (set/size),Shift = 50;
	float4 Color = CuesOut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;

	if(timer <= 10000)
	{
	//DEPTH
	//D
	float offsetD = (size*offset)/(set-((size/size)+(size/size)));
	LCD = float2(-90-Shift,0); 
	float4 OneD = all(abs(LCD+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoD = all(abs(LCD+float2(WIDTH*offsetD,HEIGHT)-position.xy) < float2(size,size*1.5));
	D = OneD-TwoD;
	//
	
	//E
	float offs = (size*offset)/(set-(size/size)/2);
	LCE = float2(-62-Shift,0); 
	float4 OneE = all(abs(LCE+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoE = all(abs(LCE+float2(WIDTH*offs,HEIGHT)-position.xy) < float2(size*0.875,size*1.5));
	float4 ThreeE = all(abs(LCE+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	E = (OneE-TwoE)+ThreeE;
	//
	
	//P
	float offsetP = (size*offset)/(set-((size/size)*5));
	float offsP = (size*offset)/(set-(size/size)*-11);
	float offseP = (size*offset)/(set-((size/size)*4.25));
	LCP = float2(-37-Shift,0);
	float4 OneP = all(abs(LCP+float2(WIDTH,HEIGHT/offsetP)-position.xy) < float2(size,size*1.5));
	float4 TwoP = all(abs(LCP+float2((WIDTH)*offsetD,HEIGHT/offsetP)-position.xy) < float2(size,size));
	float4 ThreeP = all(abs(LCP+float2(WIDTH/offseP,HEIGHT/offsP)-position.xy) < float2(size*0.200,size));
	P = (OneP-TwoP)+ThreeP;
	//

	//T
	float offsetT = (size*offset)/(set-((size/size)*16.75));
	float offsetTT = (size*offset)/(set-((size/size)*1.250));
	LCT = float2(-10-Shift,0);
	float4 OneT = all(abs(LCT+float2(WIDTH,HEIGHT*offsetTT)-position.xy) < float2(size/4,size*1.875));
	float4 TwoT = all(abs(LCT+float2(WIDTH,HEIGHT/offsetT)-position.xy) < float2(size,size/4));
	T = OneT+TwoT;
	//
	
	//H
	LCH = float2(13-Shift,0);
	float4 OneH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size/2,size*2));
	float4 ThreeH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	H = (OneH-TwoH)+ThreeH;
	//
	
	//Three
	float offsThree = (size*offset)/(set-(size/size)*1.250);
	LCThree = float2(38-Shift,0);
	float4 OneThree = all(abs(LCThree+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoThree = all(abs(LCThree+float2(WIDTH*offsThree,HEIGHT)-position.xy) < float2(size*1.2,size*1.5));
	float4 ThreeThree = all(abs(LCThree+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	Three = (OneThree-TwoThree)+ThreeThree;
	//
	
	//DD
	float offsetDD = (size*offset)/(set-((size/size)+(size/size)));
	LCDD = float2(65-Shift,0);
	float4 OneDD = all(abs(LCDD+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoDD = all(abs(LCDD+float2(WIDTH*offsetDD,HEIGHT)-position.xy) < float2(size,size*1.5));
	DD = OneDD-TwoDD;
	//
	
	//Dot
	float offsetDot = (size*offset)/(set-((size/size)*16));
	LCDot = float2(85-Shift,0);	
	float4 OneDot = all(abs(LCDot+float2(WIDTH,HEIGHT*offsetDot)-position.xy) < float2(size/3,size/3.3));
	Dot = OneDot;
	//
	
	//INFO
	//I
	float offsetI = (size*offset)/(set-((size/size)*18));
	float offsetII = (size*offset)/(set-((size/size)*8));
	float offsetIII = (size*offset)/(set-((size/size)*5));
	LCI = float2(101-Shift,0);	
	float4 OneI = all(abs(LCI+float2(WIDTH,HEIGHT*offsetI)-position.xy) < float2(size,size/4));
	float4 TwoI = all(abs(LCI+float2(WIDTH,HEIGHT/offsetII)-position.xy) < float2(size,size/4));
	float4 ThreeI = all(abs(LCI+float2(WIDTH,HEIGHT*offsetIII)-position.xy) < float2(size/4,size*1.5));
	I = OneI+TwoI+ThreeI;
	//
	
	//N
	float offsetN = (size*offset)/(set-((size/size)*7));
	float offsetNN = (size*offset)/(set-((size/size)*5));
	LCN = float2(126-Shift,0);	
	float4 OneN = all(abs(LCN+float2(WIDTH,HEIGHT/offsetN)-position.xy) < float2(size,size/4));
	float4 TwoN = all(abs(LCN+float2(WIDTH*offsetNN,HEIGHT*offsetNN)-position.xy) < float2(size/5,size*1.5));
	float4 ThreeN = all(abs(LCN+float2(WIDTH/offsetNN,HEIGHT*offsetNN)-position.xy) < float2(size/5,size*1.5));
	N = OneN+TwoN+ThreeN;
	//
	
	//F
	float offsetF = (size*offset)/(set-((size/size*7)));
	float offsetFF = (size*offset)/(set-((size/size)*5));
	float offsetFFF = (size*offset)/(set-((size/size)*-7.5));
	LCF = float2(153-Shift,0);	
	float4 OneF = all(abs(LCF+float2(WIDTH,HEIGHT/offsetF)-position.xy) < float2(size,size/4));
	float4 TwoF = all(abs(LCF+float2(WIDTH/offsetFF,HEIGHT*offsetFF)-position.xy) < float2(size/5,size*1.5));
	float4 ThreeF = all(abs(LCF+float2(WIDTH,HEIGHT/offsetFFF)-position.xy) < float2(size,size/4));
	F = OneF+TwoF+ThreeF;
	//
	
	//O
	float offsetO = (size*offset)/(set-((size/size*-5)));
	LCO = float2(176-Shift,0);	
	float4 OneO = all(abs(LCO+float2(WIDTH,HEIGHT/offsetO)-position.xy) < float2(size,size*1.5));
	float4 TwoO = all(abs(LCO+float2(WIDTH,HEIGHT/offsetO)-position.xy) < float2(size/1.5,size));
	O = OneO-TwoO;
	//
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