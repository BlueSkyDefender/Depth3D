 ////----------//
 ///**HDRish**///
 //----------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* HDRish                                  																																			*//
 //* For Reshade 3.0																																								*//
 //* --------------------------																																						*//
 //*																																												*//
 //* Have fun,																																										*//
 //* Jose Negrete AKA BlueSkyDefender																																				*//
 //*																																												*//
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				*//	
 //* ---------------------------------																																				*//
 //*		Shader was made by Zavie and was ported to reshade by BSD.																												*//
 //*		This shader experiments the effect of different tone mapping operators.																									*//
 //*		This is still a work in progress.																																		*//
 //*		More info: https://github.com/worleydl/hdr-shaders/																														*//
 //*		http://slideshare.net/ozlael/hable-john-uncharted2-hdr-lighting																											*//
 //*		http://filmicgames.com/archives/75																																		*//
 //*		http://filmicgames.com/archives/183																																		*//
 //*		http://filmicgames.com/archives/190																																		*//
 //*		http://imdoingitwrong.wordpress.com/2010/08/19/why-reinhard-desaturates-my-blacks-3/																					*//
 //*		http://mynameismjp.wordpress.com/2010/04/30/a-closer-look-at-tone-mapping/																								*//
 //*		http://renderwonk.com/publications/s2010-color-course/																													*//
 //*		--																																										*//
 //*		Zavie                                                                                                         															*//
 //*																																												*//
 //* 	Notes this shader should not work for use unless some how you can enable HDR out in it's raw form.																																											*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform int HDR_Tonemap_Select <
	ui_type = "combo";
	ui_items = "Off\0Linear ToneMapping\0Simple Reinhard ToneMapping\0Luma Based Reinhard ToneMapping\0White Preserving Luma Based Reinhard ToneMapping\0Rom Bin Da House ToneMapping\0Filmic ToneMapping\0Uncharted 2 ToneMapping\0";
	ui_label = "HDR Tonemaper Selection";
	ui_tooltip = "Select the different tone mapping operators.\n"
			    "Normally pick what looks good too you.";
> = 0;

uniform float gamma <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 3.0;
	ui_label = "Gamma";
	ui_tooltip = "Use this to set the proper Gamma for your content.";
> = 2.2;

uniform bool HDR_To_SDR_Tonemap <
	ui_label = "HDR To SDR conversion";
	ui_tooltip = "Turn on to convert HDR to LDR.";
> = false;

uniform float source_peak <
	ui_type = "drag";
	ui_min = 500; ui_max = 2000;
	ui_label = "Source Peak";
	ui_tooltip = "Mastering display Max peak luminance information is needed from the source video.";
> = 1200.0;

uniform float ldr_nits <
	ui_type = "drag";
	ui_min = 87.5; ui_max = 250;
	ui_label = "LDR nits";
	ui_tooltip = "low dynamic range of your screen.";
> = 100.0;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float3 encodePalYuv(float3 rgb)
{
	float3 RGB2Y =  float3( 0.299, 0.587, 0.114);
	float3 RGB2Cb = float3(-0.14713, -0.28886, 0.436);
	float3 RGB2Cr = float3(0.615,-0.51499,-0.10001);

	return float3(dot(rgb, RGB2Y), dot(rgb, RGB2Cb), dot(rgb, RGB2Cr));
}

float3 decodePalYuv(float3 ycc)
{	
	float3 YCbCr2R = float3( 1.000, 0.000, 1.13983);
	float3 YCbCr2G = float3( 1.000,-0.39465,-0.58060);
	float3 YCbCr2B = float3( 1.000, 2.03211, 0.000);
	return float3(dot(ycc, YCbCr2R), dot(ycc, YCbCr2G), dot(ycc, YCbCr2B));
}

float3 recSevenONinetoTwentyTwenty(float3 RGB)
{	
	float3 YCbCr2R = float3( 0.9498, 0.0456039, 0.00459609);
	float3 YCbCr2G = float3( -0.0543343,1.03836,0.0159787);
	float3 YCbCr2B = float3( -0.00293135, -0.00986865, 1.0128);
	return float3(dot(RGB, YCbCr2R), dot(RGB, YCbCr2G), dot(RGB, YCbCr2B));
}

float3 linearToneMapping(float3 color)
{
	float exposure = 1.0f;
	color = clamp(exposure * color, 0.0f, 1.0f);
	color = pow(color, 1.0f / gamma );
	return color;
}

float3 simpleReinhardToneMapping(float3 color)
{
	float exposure = 1.5f;
	color *= exposure/(1.0f + color / exposure);
	color = pow(color, 1.0f / gamma );
	return color;
}

float3 lumaBasedReinhardToneMapping(float3 color)
{
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	float toneMappedLuma = luma / (1.0f + luma);
	color *= toneMappedLuma / luma;
	color = pow(color, 1.0f / gamma );
	return color;
}

float3 whitePreservingLumaBasedReinhardToneMapping(float3 color)
{
	float white = 2.0f;
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	float toneMappedLuma = luma * (1.0f + luma / (white*white)) / (1.0f + luma);
	color *= toneMappedLuma / luma;
	color = pow(color, 1.0f / gamma );
	return color;
}

float3 RomBinDaHouseToneMapping(float3 color)
{
    color = exp( -1.0f / ( 2.72f*color + 0.15f ) );
	color = pow(color, 1.0f / gamma );
	return color;
}

float3 filmicToneMapping(float3 color)
{
	color = max(float3(0.0f,0.0f,0.0f), color - float3(0.004f,0.004f,0.004f));
	color = (color * (6.2f * color + 0.5f)) / (color * (6.2f * color + 1.7f) + 0.06f);
	return color;
}

float3 Uncharted2Tonemap(float3 x)
{
 	float A = 0.15f;
	float B = 0.50f;
	float C = 0.10f;
	float D = 0.20f;
	float E = 0.02f;
	float F = 0.30f;
   return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

float3 Uncharted2ToneMapping(float3 color)
{
	float W = 11.2f;
	float exposure = 2.0f;
	color *= exposure;
	color = Uncharted2Tonemap(color);
	float white = Uncharted2Tonemap(W);
	color /= white;
	color = pow(color, 1.0f / gamma );
	return color;
}

//HDR to SDR

float3 recTwentyTwentytoSevenONine(float3 RGB)
{	
	float3 YCbCr2R = float3( 1.0502, -0.0461625, -0.00403752);
	float3 YCbCr2G = float3( 0.054899,0.9605045,-0.0154028);
	float3 YCbCr2B = float3( 0.00357453, 0.00922547, 0.9872);
	return float3(dot(RGB, YCbCr2R), dot(RGB, YCbCr2G), dot(RGB, YCbCr2B));
}

float3 HableTonemap(float3 x)
{
	float A,B,C,D,E,F;
	A = 0.22f;
	B = 0.30f;
	C = 0.10f;
	D = 0.20f;
	E = 0.01f;
	F = 0.30f;
   return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

float3 HableToneMapping(float3 color)
{	
	float W = 11.2f;
	float exposure = source_peak/ldr_nits;
	color *= exposure;
	color = HableTonemap(color);
	float white = 1.0f/HableTonemap(W);
	color *= white;
	color = pow(color, exposure );
	color = pow(color, 1.0f / gamma );
	return color;
}

uniform int random < source = "random"; min = 1; max = 10; >;
float4 SharderOut(float2 texcoord : TEXCOORD0)
{	
	float4 Color = tex2D(BackBuffer, texcoord);

	if(!HDR_To_SDR_Tonemap)
	{ 
		Color.rgb = recSevenONinetoTwentyTwenty(Color.rgb); //Good
		
		if(HDR_Tonemap_Select)
		{	
			Color.rgb = linearToneMapping(Color.rgb);
		}
		else if(HDR_Tonemap_Select == 1)
		{
			Color.rgb = simpleReinhardToneMapping(Color.rgb);
		}
		else if(HDR_Tonemap_Select == 2)
		{
			Color.rgb = lumaBasedReinhardToneMapping(Color.rgb);
		}
		else if(HDR_Tonemap_Select == 3)
		{
			Color.rgb = whitePreservingLumaBasedReinhardToneMapping(Color.rgb);
		}
		else if(HDR_Tonemap_Select == 4)
		{
			Color.rgb = RomBinDaHouseToneMapping(Color.rgb);
		}
		else if(HDR_Tonemap_Select == 5)
		{
			Color.rgb = filmicToneMapping(Color.rgb);
		}
		else if(HDR_Tonemap_Select == 6)
		{
			Color.rgb = Uncharted2ToneMapping(Color.rgb);
		}
		else
		{
			Color = tex2D(BackBuffer, texcoord);
		}
	}
	else
	{
		Color.rgb = HableToneMapping(Color.rgb);
		Color.rgb = recTwentyTwentytoSevenONine(Color.rgb); //Good
	}
	
	return float4(Color.rgb,Color.a); 
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;

float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	//#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	float HEIGHT = BUFFER_HEIGHT/2,WIDTH = BUFFER_WIDTH/2;	
	float2 LCD,LCE,LCP,LCT,LCH,LCThree,LCDD,LCDot,LCI,LCN,LCF,LCO;
	float size = 9.5,set = BUFFER_HEIGHT/2,offset = (set/size),Shift = 50;
	float4 Color = SharderOut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;

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

technique HDR
{		
			pass LDRtoHDR
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}