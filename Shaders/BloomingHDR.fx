 ////----------------//
 ///**Blooming HDR**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* HDR Bloom AKA FakeHDR + Bloom                                               																									*//
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

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

uniform float CBT_Adjust <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Extracting Bright Colors";
	ui_tooltip = "Use this to set the color based brightness threshold for what is and what isn't allowed.\n"
				"This is the most important setting, use Debug View to adjust this.\n"
				"Number 0.5 is default.";
	ui_category = "HDR Adjustments";
> = 0.5;

uniform float HDR_Adjust <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.5; ui_max = 2.0;
	ui_label = "HDR Adjust";
	ui_tooltip = "Use this to adjust HDR levels for your content.\n"
				"Number 1.125 is default.";
	ui_category = "HDR Adjustments";
> = 1.125;

uniform bool Auto_Exposure <
	ui_label = "Auto Exposure";
	ui_tooltip = "This will enable the shader to adjust exposure automaticly.\n"
				"You will still need to adjust exposure below.";
	ui_category = "HDR Adjustments";
> = false;

uniform float Exposure<
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Exposure";
	ui_tooltip = "Use this to set HDR exposure for your content.\n"
				"Number 0.100 is default.";
	ui_category = "HDR Adjustments";
> = 0.100;

uniform float Saturation <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 2.5;
	ui_label = "Bloom Saturation";
	ui_tooltip = "Adjustment The amount to adjust the saturation of the color.\n"
				"Number 1.0 is default.";
	ui_category = "HDR Adjustments";
> = 1.0;

uniform float Spread <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 12.5; ui_max = 37.5; ui_step = 0.5;
	ui_label = "Bloom Spread";
	ui_tooltip = "Adjust This to have the Bloom effect to fill in areas.\n"
				 "This is used for Bloom gap filling.\n"
				 "Number 25.0 is default.";
	ui_category = "HDR Adjustments";
> = 25.0;

uniform int Luma_Coefficient <
	ui_type = "combo";
	ui_label = "Luma";
	ui_tooltip = "Changes how color get used for the other effects.\n";
	ui_items = "SD video\0HD video\0HDR video\0Intensity\0";
	ui_category = "HDR Adjustments";
> = 0;

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
	ui_category = "Debugging";
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
texture texBC { Width = BUFFER_WIDTH * 0.5; Height = BUFFER_HEIGHT * 0.5; Format = RGBA8; MipLevels = 4;};

sampler SamplerBC
	{
		Texture = texBC;
		MipLODBias = 3.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
					
texture texM { Width = BUFFER_WIDTH * 0.5; Height = BUFFER_HEIGHT * 0.5; Format = RGBA8; MipLevels = 3;};

sampler SamplerMip
	{
		Texture = texM;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
texture PastSingle_BackBuffer { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;};

sampler PSBackBuffer
	{
		Texture = PastSingle_BackBuffer;
	};
		
//Total amount of frames since the game started.
uniform uint framecount < source = "framecount"; >;	
uniform float frametime < source = "frametime";>;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define Alternate framecount % 2 == 0  
#define MipLevelAdjust 2 //This is used for removing banding in the Bloom.

float3 Luma()
{
	float3 Luma;
	
	if (Luma_Coefficient == 0)
	{
		Luma = float3(0.299, 0.587, 0.114); // (SD video)
	}
	else if (Luma_Coefficient == 1)
	{
		Luma = float3(0.2126, 0.7152, 0.0722); // (HD video) https://en.wikipedia.org/wiki/Luma_(video)
	}
	else if (Luma_Coefficient == 2)
	{
		Luma = float3(0.2627, 0.6780, 0.0593); // (HDR video) https://en.wikipedia.org/wiki/Rec._2100
	}
	else
	{
		Luma = float3(0.3333, 0.3333, 0.3333); // Intensity
	}
	return Luma;
}

/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLumAvg {Width = 256; Height = 256; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256 map only has nine mip levels; 0-1-2-3-4-5-6-7-8 : 256,128,64,32,16,8,4,2, and 1 (1x1).
																				
sampler SamplerLum																
	{
		Texture = texLumAvg;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 So you would only have to adjust the boxes from Image to 8.
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
		AddressU = Clamp; 
		AddressV = Clamp;
	};
	
texture PStexLumAvg {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
																				
sampler SamplerPSLum																
	{
		Texture = PStexLumAvg;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
		AddressU = Clamp; 
		AddressV = Clamp;
	};
	
float Luminance(float4 pos : SV_Position, float2 texcoords : TEXCOORD) : SV_Target
{
	float2 tex_offset = 5.0f * pix; // gets texel offset
    float4 result = tex2D(BackBuffer,texcoords); // current fragment's contribution
	
	result += tex2D(BackBuffer,texcoords + float2(-1.0f * tex_offset.x,-0.5f * tex_offset.y));
		
	result += tex2D(BackBuffer,texcoords + float2(0.5f * tex_offset.x, -1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(0,                   -1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(-1.0f * tex_offset.x, 				  0));
	
	result += tex2D(BackBuffer,texcoords + float2(0.5f * tex_offset.x, -0.5f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(-0.5f * tex_offset.x, 0.5f * tex_offset.y));

	result += tex2D(BackBuffer,texcoords + float2(1.0f * tex_offset.x,  				  0));
	
	result += tex2D(BackBuffer,texcoords + float2(0,                    1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(-0.5f * tex_offset.x, 1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(1.0f * tex_offset.x,  0.5f * tex_offset.y));
	
	result /= 11;
   
	float GSBB = dot(result.rgb, Luma());
	return GSBB;
}

float Average_Luminance(float2 texcoords : TEXCOORD)
{
	float lum = tex2D(SamplerLum, 0.5).x;
	float lumlast = length(tex2D(PSBackBuffer, 0.0).www);
	//Temporal adaptation https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
   return lumlast + (lum - lumlast) * (1.0 - exp2(-frametime));
}
   
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
float4 BrightColors(float4 position : SV_Position, float2 texcoords : TEXCOORD) : SV_Target //bright-pass filter is applied to dim-down the darkest areas of the scene.
{   
	float4 BC, Color = tex2D(BackBuffer, texcoords);
	// check whether fragment output is higher than threshold, if so output as brightness color.
    float brightness = dot(Color.rgb, Luma());
    
    if(brightness > CBT_Adjust)
        BC.rgb = Color.rgb;
    else
        BC.rgb = float3(0.0, 0.0, 0.0);
	
	float3 intensity = dot(BC.rgb,Luma());
    BC.rgb = lerp(intensity,BC.rgb,Saturation);  
   // The result of the bright-pass filter is then downscaled.
   return float4(BC.rgb,1.0);
}

float4 Blur(float2 texcoords : TEXCOORD0)//Then blurred.                                                                        
{    
    float2 tex_offset = (Spread * 0.25f) * pix; // Gets texel offset
    float4 result = tex2D(SamplerBC,texcoords); // Current fragment's contribution
	if (Alternate)
	{
		result += tex2D(SamplerBC,texcoords + float2(-2.0f * tex_offset.x, -3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-1.0f * tex_offset.x, -3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(0,                    -3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(1.0f * tex_offset.x,  -3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(2.0f * tex_offset.x,  -3.0f * tex_offset.y));

		result += tex2D(SamplerBC,texcoords + float2(-3.0f * tex_offset.x, -2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-2.0f * tex_offset.x, -2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-1.0f * tex_offset.x, -2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(0,                    -2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(1.0f * tex_offset.x,  -2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(2.0f * tex_offset.x,  -2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(3.0f * tex_offset.x,  -2.0f * tex_offset.y));

		result += tex2D(SamplerBC,texcoords + float2(-3.0f * tex_offset.x, -1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-2.0f * tex_offset.x, -1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-1.0f * tex_offset.x, -1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(0,                    -1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(1.0f * tex_offset.x,  -1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(2.0f * tex_offset.x,  -1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(3.0f * tex_offset.x,  -1.0f * tex_offset.y));

		result += tex2D(SamplerBC,texcoords + float2(-3.0f * tex_offset.x, 0));
		result += tex2D(SamplerBC,texcoords + float2(-2.0f * tex_offset.x, 0));
		result += tex2D(SamplerBC,texcoords + float2(-1.0f * tex_offset.x, 0));
    }
    else
    {
		result += tex2D(SamplerBC,texcoords + float2(1.0f * tex_offset.x,  0));
		result += tex2D(SamplerBC,texcoords + float2(2.0f * tex_offset.x,  0));
		result += tex2D(SamplerBC,texcoords + float2(3.0f * tex_offset.x,  0));

		result += tex2D(SamplerBC,texcoords + float2(-3.0f * tex_offset.x, 1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-2.0f * tex_offset.x, 1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-1.0f * tex_offset.x, 1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(0,                    1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(1.0f * tex_offset.x,  1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(2.0f * tex_offset.x,  1.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(3.0f * tex_offset.x,  1.0f * tex_offset.y));

		result += tex2D(SamplerBC,texcoords + float2(-3.0f * tex_offset.x, 2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-2.0f * tex_offset.x, 2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-1.0f * tex_offset.x, 2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(0,                    2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(1.0f * tex_offset.x,  2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(2.0f * tex_offset.x,  2.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(3.0f * tex_offset.x,  2.0f * tex_offset.y));

		result += tex2D(SamplerBC,texcoords + float2(-2.0f * tex_offset.x, 3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(-1.0f * tex_offset.x, 3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(0,                    3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(1.0f * tex_offset.x,  3.0f * tex_offset.y));
		result += tex2D(SamplerBC,texcoords + float2(2.0f * tex_offset.x,  3.0f * tex_offset.y));
   }
   
   result /= 23;
    
   return result;
}

float4 HDROut(float2 texcoord : TEXCOORD0)
{	
	float AL = Average_Luminance(texcoord).x, Ex = Exposure;
	
	if(Auto_Exposure)
	Ex = Ex * AL;
         
	float4 Out;
    float3 TM, Color = tex2D(BackBuffer, texcoord).rgb, HDR = tex2D(BackBuffer, texcoord).rgb;      
    float3 bloomColor = tex2Dlod(SamplerMip, float4(texcoord,0,MipLevelAdjust)).rgb + tex2D(PSBackBuffer, texcoord).rgb; // Merge Current and past frame.
    //Tone Mapping done here.
	TM = 1.0 - exp(-bloomColor * Ex );
	//HDR
	HDR += TM;
	Color = pow(HDR,HDR_Adjust); 
	
	if (!Debug_View)
	{
		Out = float4(Color, 1.0);
	}
	else
	{	
		Out = float4(bloomColor, 1.0);
	}
	
	return Out;
}

float4 MIPs(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
return Blur(float2(texcoord.x, texcoord.y)); 
}

void Past_BackSingleBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target)
{	
	PastSingle = float4(tex2Dlod(SamplerMip, float4(texcoord,0,MipLevelAdjust)).rgb,Average_Luminance(0.0).x);
}

uniform float timer < source = "timer"; >;
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = HDROut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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
technique Blooming_HDR
{	
		pass Bright_Filter
	{
		VertexShader = PostProcessVS;
		PixelShader = BrightColors;
		RenderTarget = texBC;
	}
		pass Blur_Filter
	{
		VertexShader = PostProcessVS;
		PixelShader = MIPs;
		RenderTarget = texM;
	}
		pass AvgLum
    {
        VertexShader = PostProcessVS;
        PixelShader = Luminance;
        RenderTarget = texLumAvg;
    }
		pass HDROut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;	
	}
		pass PSB
	{
		VertexShader = PostProcessVS;
		PixelShader = Past_BackSingleBuffer;
		RenderTarget = PastSingle_BackBuffer;	
	}
}
