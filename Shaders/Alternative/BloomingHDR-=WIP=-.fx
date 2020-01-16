 ////----------------//
 ///**Blooming HDR**///
 //----------------////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                               																									*//
// For Reshade 3.0 HDR Bloom AKA FakeHDR + Bloom
// --------------------------
// LICENSE
// ============
// Blooming HDR is licenses under: Attribution-NoDerivatives 4.0 International
//
// You are free to:
// Share - copy and redistribute the material in any medium or format
// for any purpose, even commercially.
// The licensor cannot revoke these freedoms as long as you follow the license terms.
// Under the following terms:
// Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made.
// You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
//
// NoDerivatives - If you remix, transform, or build upon the material, you may not distribute the modified material.
//
// No additional restrictions - You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
//
// https://creativecommons.org/licenses/by-nd/4.0/
//
// Have fun,
// Jose Negrete AKA BlueSkyDefender
//
// https://github.com/BlueSkyDefender/Depth3D
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if exists "Flare.fx"                                           //Flare Intercepter//
	#define Flare 1
#else
	#define Flare 0
#endif
// Max Bloom ammount.
#define Bloom_Max 250

// This lets you addjust BlurSamples in ReShade UI and disables BlurSamples below.
#define In_UI_Samples 0 //ON 1 - Off 0

//The ammount of samples used for the Bloom, This is used for Blur quality
#define BS 11 //Blur Samples = # * 4 with temporal mixing

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

uniform bool Auto_Bloom_Intensity <
	ui_label = "Auto Bloom Intensity";
	ui_tooltip = "This will enable the shader to adjust Bloom Intensity automaticly.\n"
				 "Auto Bloom Intensity will set Bloom Intensity below.";
	ui_category = "Bloom Adjustments";
> = true;

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
				"X is for primary and Y is for Secondary.\n"
				"Number X 0.5 is default and for Y 0.625.";
	ui_category = "Bloom Adjustments";
> = 0.5;


#if In_UI_Samples
uniform int Blur_Samples <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 5.0; ui_max = 25;
	ui_label = "Bloom Samples";
	ui_tooltip = "The ammount of samples used for the Bloom, This is used for Blur quality.\n"
				 "Blur Samples = # * 4 with temporal mixing.\n"
				 "Number 5 is default.";
	ui_category = "Bloom Adjustments";
> = 5;
#endif

uniform float Bloom_Intensity<
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 5.0;
		ui_label = "Primary Bloom Intensity";
	ui_tooltip = "Use this to set Bloom Intensity for your content.\n"
				"Number 1.0 is default.";
	ui_category = "Bloom Adjustments";
> = 0.5;

uniform float Bloom_Spread <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 50.0; ui_max = Bloom_Max; ui_step = 0.25;
	ui_label = "Primary Bloom Spread";
	ui_tooltip = "Adjust to spread out the primary Bloom.\n"
				 "This is used for spreading Bloom.\n"
				 "Number 50.0 is default.";
	ui_category = "Bloom Adjustments";
> = 50.0;

uniform float Saturation <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 5.0;
	ui_label = "Bloom Saturation";
	ui_tooltip = "Adjustment The amount to adjust the saturation of the color.\n"
				"Number 2.5 is default.";
	ui_category = "Bloom Adjustments";
> = 2.5;

uniform bool Auto_Exposure <
	ui_label = "Auto Exposure";
	ui_tooltip = "This will enable the shader to adjust Exposure automaticly.\n"
			 	"This will disable Exposure adjustment above.";
	ui_category = "Tonemapper Adjustments";
> = true;

uniform int Luma_Coefficient <
	ui_type = "combo";
	ui_label = "Luma";
	ui_tooltip = "Changes how color get used for the other effects.\n";
	ui_items = "SD video\0HD video\0HDR video\0Intensity\0";
	ui_category = "Tonemapper Adjustments";
> = 1;

uniform float WP <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 20.00;
	ui_label = "Linear White Point Value";
	ui_category = "Tonemapper Adjustments";
> = 1.25;

uniform float Exp <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 20.00;
	ui_label = "Exposure";
	ui_category = "Tonemapper Adjustments";
> = 2.0;

uniform float Gamma <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 3.0;
	ui_label = "Gamma value";
	ui_tooltip = "Most monitors/images use a value of 2.2. Setting this to 1 disables the inital color space conversion from gamma to linear.";
	ui_category = "Tonemapper Adjustments";
> = 2.2;

uniform float Adapt_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Eye Adapt Speed";
	ui_tooltip = "Use this to Adjust Eye Adaptation Speed.\n"
				 "Set from Zero to One, Zero is the slowest.\n"
				 "Number 0.5 is default.";
	ui_category = "Eye Adaptation";
> = 0.5;

uniform float Adapt_Seek <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Eye Adapt Seeking";
			ui_tooltip = "Use this to Adjust Eye Seeking Radius for Average Brightness.\n"
				 "Set from 0 to 1, 1 is Full-Screen Average Brightness.\n"
				 "Number 0.5 is default.";
	ui_category = "Eye Adaptation";
> = 0.5;

uniform int Debug_View <
	ui_type = "combo";
	ui_label = "Debug View";
#if S_Bloom
	ui_items = "Normal View\0Bloom View A\0Bloom View B\0";
#else
	ui_items = "Normal View\0Bloom View\0";
#endif
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
	ui_category = "Debugging";
	ui_category = "Tonemapper Adjustments";
> = 0;

//Change Output
#if In_UI_Samples
    #define BlurSamples Blur_Samples
#else
	#define BlurSamples BS
#endif

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define A_Power Bloom_Spread * rcp(BlurSamples)
static const int mSize = BlurSamples;
static const int kSize = (mSize-1) * 0.5;
static const float sigma = 7.0;

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

uniform float timer < source = "timer"; >;

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

texture texMBlur_HV0 { Width = BUFFER_WIDTH * 0.25; Height = BUFFER_HEIGHT *0.25; Format = RGBA16F; MipLevels = 2;};

sampler SamplerBlur_HV0
	{
		Texture = texMBlur_HV0;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};

texture texMBlur_HV1 { Width = BUFFER_WIDTH * 0.25; Height = BUFFER_HEIGHT *0.25; Format = RGBA16F; MipLevels = 2;};

sampler SamplerBlur_HV1
	{
		Texture = texMBlur_HV1;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};

texture texBloom { Width = BUFFER_WIDTH * 0.25 ; Height = BUFFER_HEIGHT * 0.25 ; Format = RGBA16F; MipLevels = 2;};

sampler SamplerBloom
	{
		Texture = texBloom;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};

texture PastSingle_BackBuffer { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = RGBA16F;};

sampler PSBackBuffer
	{
		Texture = PastSingle_BackBuffer;
	};
#if Flare
texture TexFlareShared { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = RGBA16F;};

sampler SamplerFlare
	{
		Texture = TexFlareShared;
	};
#endif
//Total amount of frames since the game started.
uniform uint framecount < source = "framecount"; >;
uniform float frametime < source = "frametime";>;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define Alternate framecount % 2 == 0

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
texture texLum {Width = 256; Height = 256; Format = R16F; MipLevels = 9;}; //Sample at 256x256 map only has nine mip levels; 0-1-2-3-4-5-6-7-8 : 256,128,64,32,16,8,4,2, and 1 (1x1).

sampler SamplerLum
	{
		Texture = texLum;
	};

texture texAvgLum { Format = R16F; };

sampler SamplerAvgLum
	{
		Texture = texAvgLum;
	};

texture TexAvgLumaLast { Format = R16F; };

sampler SamplerAvgLumaLast
	{
		Texture = TexAvgLumaLast;
	};

float Luminance(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float2 texXY = texcoord;
	float2 midHV = (Adapt_Seek-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
	texcoord = float2((texXY.x*Adapt_Seek)-midHV.x,(texXY.y*Adapt_Seek)-midHV.y);

	return dot(tex2D(BackBuffer,texcoord).rgb, Luma());
}

float Average_Luminance(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float AA = (1-Adapt_Adjust)*1000, L =  tex2Dlod(SamplerLum,float4(texcoord,0,11)).x, PL = tex2D(SamplerAvgLumaLast, texcoord).x;
	//Temporal adaptation https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
	return PL + (L - PL) * (1.0 - exp(-frametime/AA));
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float3 Bright_Colors(float2 texcoords)
{
    float4 BC = tex2D(BackBuffer, texcoords);

           // Luma Threshold Thank you Adyss
           BC.a    = dot(BC.rgb, Luma() );//Luma
           BC.rgb /= max(BC.a, 0.001);
           BC.a    = max(0.0, BC.a - CBT_Adjust.x);
           BC.rgb *= BC.a;

           BC.rgb  = lerp(BC.a, BC.rgb, Saturation);

    return saturate(BC.rgb);
}

void Blur_HV0(in float4 position : SV_Position, in float2 texcoords : TEXCOORD0, out float3 color : SV_Target0)
{
	float Z, S = A_Power * 0.666; //Evil Magic Number

	if (Alternate)
		S *= 0.5;

		float kernel[mSize];
		float3 final_colour;
		
		//create the 1-D kernel
		[unroll]
		for (int k = -kSize; k <= kSize; ++k)
		{
			kernel[kSize+k] = normpdf(k, sigma);
		}
		
		//get the normalization factor (as the gaussian has been clamped)
		[unroll]
		for (int n = 0; n < mSize; ++n)
		{
			Z += kernel[n];
		}
		
		//read out the texels
		[unroll]
		for (int h=-kSize; h <= kSize; ++h)
		{
			final_colour += kernel[kSize+h] * Bright_Colors(texcoords + float2(h, 0) * S * pix).rgb;
		}	
		
	color = final_colour / Z; // Get it  Total sum..... :D
}

void CombBlur_HV1(in float4 position : SV_Position, in float2 texcoords : TEXCOORD0, out float3 color : SV_Target0 )
{
	float TM, Z, S = A_Power * 0.666; //Evil Magic Number

	if (Alternate)
	{
		TM = 1;
		S *= 0.5;
	}
		float kernel[mSize];
		float3 final_colour;
		
		//create the 1-D kernel
		[unroll]
		for (int k = -kSize; k <= kSize; ++k)
		{
			kernel[kSize+k] = normpdf(k, sigma);
		}
		
		//get the normalization factor (as the gaussian has been clamped)
		[unroll]
		for (int n = 0; n < mSize; ++n)
		{
			Z += kernel[n];
		}
		
		//read out the texels
		[unroll]
		for (int v=-kSize; v <= kSize; ++v)
		{
			final_colour += kernel[kSize+v] * tex2Dlod(SamplerBlur_HV0,float4(texcoords + float2(0, v) * S * pix,0,TM)).rgb;
		}
		
	color = final_colour / Z; // Get it  Total sum..... :D
 }

float3 LastBlur(float2 texcoords : TEXCOORD0)
{
	float TM, BS0; //Evil Magic Number

	if (Alternate)
	{
		TM = 1;
		BS0 *= 0.5;
		
	}
	float3 acc = tex2Dlod(SamplerBlur_HV1,float4(texcoords,0, TM)).rgb;
	BS0 = Bloom_Spread * 0.333 * 1.5;
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2( pix.x, 0) * BS0, 0, TM)).rgb;
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2(-pix.x, 0) * BS0, 0, TM)).rgb;
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2( 0, pix.y) * BS0, 0, TM)).rgb;
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2( 0,-pix.y) * BS0, 0, TM)).rgb;
	
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2( pix.x, pix.y) * BS0 * 0.666, 0, TM)).rgb;
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2(-pix.x, pix.y) * BS0 * 0.666, 0, TM)).rgb;
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2(-pix.x,-pix.y) * BS0 * 0.666, 0, TM)).rgb;
	acc += tex2Dlod(SamplerBlur_HV1,float4(texcoords + float2( pix.x,-pix.y) * BS0 * 0.666, 0, TM)).rgb;
		 
   return acc * rcp(9);
}

float3 Mix_Bloom(float4 position : SV_Position, float2 texcoords : TEXCOORD) : SV_Target
{
	return LastBlur(texcoords).rgb + tex2D(PSBackBuffer, texcoords).rgb; // Merge Current and past frame.
}

float3 HableTonemap(float3 color, float EX) // Habble
{   float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = WP;
	//Tone map all the things. But, first start with exposure.
	color *= EX;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	return color;
}

 float3 HDR(float3 color)
 {  //Expand HDR
	return color*(sqrt(color*2.0)+1.0);
 }
 
 float3 HDRlum(float3 color)
 {  //Expand HDR
	return color*(sqrt(dot(color, Luma())*2.0)+1.0);
 } 
 
float4 HDROut(float2 texcoords : TEXCOORD0)
{
	float AL = 1-tex2D(SamplerAvgLum,0.0).x, Ex = Exp, BSA = Bloom_Spread * rcp(Bloom_Max*0.5);
	float2 tex_offset = A_Power * pix; // Gets texel offsett
	float BI = Bloom_Intensity, NC = saturate(smoothstep(0,1,AL)), BS0;

	if(Auto_Bloom_Intensity)
		BI *= NC;
	else
		BI = Bloom_Intensity;
	//Blur Acculimation
	float3 acc = tex2Dlod(SamplerBloom,float4(texcoords,0, BSA)).rgb;	
	BS0 = Bloom_Spread * 0.333 * 2.0;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( pix.x, 0) * BS0, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2(-pix.x, 0) * BS0, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( 0, pix.y) * BS0, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( 0,-pix.y) * BS0, 0, BSA)).rgb;
	
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( pix.x, 0) * BS0 * 0.5, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2(-pix.x, 0) * BS0 * 0.5, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( 0, pix.y) * BS0 * 0.5, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( 0,-pix.y) * BS0 * 0.5, 0, BSA)).rgb;
	
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( pix.x, pix.y) * BS0 * 0.666, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2(-pix.x, pix.y) * BS0 * 0.666, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2(-pix.x,-pix.y) * BS0 * 0.666, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( pix.x,-pix.y) * BS0 * 0.666, 0, BSA)).rgb;
	
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( pix.x, pix.y) * BS0 * 0.666 * 0.5, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2(-pix.x, pix.y) * BS0 * 0.666 * 0.5, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2(-pix.x,-pix.y) * BS0 * 0.666 * 0.5, 0, BSA)).rgb;
	acc += tex2Dlod(SamplerBloom,float4(texcoords + float2( pix.x,-pix.y) * BS0 * 0.666 * 0.5, 0, BSA)).rgb;
	
	acc *= rcp(17);
	
	float4 Out;
    float3 Color = tex2D(BackBuffer, texcoords).rgb;
  
	// Do inital de-gamma of the game image to ensure we're operating in the correct colour range.
	if( Gamma > 1. )
		Color = pow(abs(Color),Gamma);
	
	//Bloom should be applied before Tonemapping as otherwise all high ranges will be lost.
	Color += acc * BI;
	
	//Tone map all the things
	if(Auto_Exposure)
		Ex *= AL;
	#if Flare
		Color = HableTonemap(Color,Ex) + tex2D(SamplerFlare, texcoords).rgb;
	#else
		Color = HableTonemap(Color,Ex);
	#endif
	// Do the post-tonemapping gamma correction
	if( Gamma > 1. )
		Color = pow(abs(Color),rcp(Gamma)); 
		
	if (Debug_View == 0)
		Out = float4(Color, 1.);
	else if(Debug_View == 1)
		Out = float4(pow(abs(acc),rcp(Gamma)), 1.);

	return Out;
}

float4 Past_BackSingleBuffer(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return float4(LastBlur(texcoord).rgb,1.0);
}

float PS_StoreAvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    return tex2D(SamplerAvgLum,texcoord).x;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y;
	float3 Color = HDROut(texcoord).rgb,D,E,P,T,H,Three,DD,Dot,I,N,F,O;

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
		return float4(D+E+P+T+H+Three+DD+Dot+I+N+F+O,1.) ? 1-texcoord.y*50.0+48.35f : float4(Color,1.);
	}
	else
		return float4(Color,1.);
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
		pass MIP_Blur_HV_One
	{
		VertexShader = PostProcessVS;
		PixelShader = Blur_HV0;
		RenderTarget0 = texMBlur_HV0;
	}
		pass MIP_Blur_HV_Two
	{
		VertexShader = PostProcessVS;
		PixelShader = CombBlur_HV1;
		RenderTarget0 = texMBlur_HV1;
	}
		pass Temporal_Mixing_Bloom
	{
		VertexShader = PostProcessVS;
		PixelShader = Mix_Bloom;
		RenderTarget = texBloom;
	}
		pass Lum
    {
        VertexShader = PostProcessVS;
        PixelShader = Luminance;
        RenderTarget = texLum;
    }
    	pass Avg_Lum
    {
        VertexShader = PostProcessVS;
        PixelShader = Average_Luminance;
        RenderTarget = texAvgLum;
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

	    pass StoreAvgLuma
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_StoreAvgLuma;
        RenderTarget = TexAvgLumaLast;
    }

}
