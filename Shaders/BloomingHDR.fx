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
uniform float HDR_Adjust <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.5; ui_max = 2.0;
	ui_label = "HDR Adjust";
	ui_tooltip = "Use this to adjust Fake HDR levels for your content.\n"
				"Number 1.125 is default.";
	ui_category = "HDR Adjustments";
> = 1.5;

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
				"Number 0.625 is default.";
	ui_category = "Bloom Adjustments";
> = 0.625;

uniform bool Auto_Bloom_Intensity <
	ui_label = "Auto Bloom Intensity";
	ui_tooltip = "This will enable the shader to adjust Bloom Intensity automaticly.\n"
				"You will still need to adjust exposure below.";
	ui_category = "Bloom Adjustments";
> = false;

uniform float Bloom_Intensity<
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
		ui_label = "Bloom Intensity";
	ui_tooltip = "Use this to set Bloom Intensity for your content.\n"
				"Number 0.1 is default.";
	ui_category = "Bloom Adjustments";
> = 0.1;

uniform float Saturation <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 10.0;
	ui_label = "Bloom Saturation";
	ui_tooltip = "Adjustment The amount to adjust the saturation of the color.\n"
				"Number 2.5 is default.";
	ui_category = "Bloom Adjustments";
> = 2.5;

uniform float Spread <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 50.0; ui_max = 100.0; ui_step = 0.25;
	ui_label = "Bloom Spread";
	ui_tooltip = "Adjust This to have the Bloom effect to fill in areas.\n"
				 "This is used for Bloom gap filling.\n"
				 "Number 75.0 is default.";
	ui_category = "Bloom Adjustments";
> = 75.0;

uniform int Luma_Coefficient <
	ui_type = "combo";
	ui_label = "Luma";
	ui_tooltip = "Changes how color get used for the other effects.\n";
	ui_items = "SD video\0HD video\0HDR video\0Intensity\0";
	ui_category = "Tonemapper Adjustments";
> = 1;

uniform float W <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 20.00;
	ui_label = "Linear White Point Value";
	ui_category = "Tonemapper Adjustments";
> = 11.2;

uniform bool Auto_Exposure <
	ui_label = "Auto Exposure";
	ui_tooltip = "This will enable the shader to adjust Exposure automaticly.\n"
				"You will still need to adjust exposure below.";
	ui_category = "Tonemapper Adjustments";
> = false;

uniform float Exp <
	ui_type = "drag";
	ui_min = 1.00; ui_max = 20.00;
	ui_label = "Exposure";
	ui_category = "Tonemapper Adjustments";
> = 1.0;

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
	ui_category = "Tonemapper Adjustments";
> = 0.5;

uniform int Debug_View <
	ui_type = "combo";
	ui_label = "Debug View";
	ui_items = "Normal View\0Bloom View\0Adapt View\0";
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
	ui_category = "Debugging";
	ui_category = "Tonemapper Adjustments";
> = 0;

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
	
texture texBC { Width = BUFFER_WIDTH * 0.375; Height = BUFFER_HEIGHT * 0.375; Format = RGBA16F; MipLevels = 3;};

sampler SamplerBC
	{
		Texture = texBC;
		MipLODBias = 2;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
					
texture texBlur { Width = BUFFER_WIDTH * 0.375; Height = BUFFER_HEIGHT * 0.375; Format = RGBA16F; MipLevels = 3;};

sampler SamplerBlur
	{
		Texture = texBlur;
		MipLODBias = 2;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;	
	};
	
texture texBloom { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; MipLevels = 6;};

sampler SamplerBloom
	{
		Texture = texBloom;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
		
texture PastSingle_BackBuffer { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};

sampler PSBackBuffer
	{
		Texture = PastSingle_BackBuffer;
	};
		
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
	
texture2D TexAvgLumaLast { Format = R16F; };
sampler SamplerAvgLumaLast { Texture = TexAvgLumaLast; };	
	
float Luminance(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target	
{   
	return dot(tex2D(BackBuffer,texcoord).rgb, Luma());
}

float Average_Luminance(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target	
{
	float AA = 1-Adapt_Adjust, L =  tex2Dlod(SamplerLum,float4(texcoord,0,11)).x, PL = tex2D(SamplerAvgLumaLast, texcoord).x;
	//Temporal adaptation https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
 
	return PL + (L - PL) * (1.0 - exp(-frametime/(AA*1000)));   	
}
   
//////////////////////////////////////////////////////////////	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
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

float4 Blur(float4 position : SV_Position, float2 texcoords : TEXCOORD) : SV_Target//Then blurred.                                                                        
{    
    float2 tex_offset = (Spread * 0.4) * pix; // Gets texel offset
    float4 result = tex2D(SamplerBC,texcoords); // Current fragment's contribution
	
	if (Alternate)
		tex_offset *= 0.5;

		result += tex2D(SamplerBC,texcoords + float2( 0.5, 0) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2(-0.5, 0) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2( 0, 0.5) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2( 0,-0.5) * tex_offset );
		
		result += tex2D(SamplerBC,texcoords + float2( 1.0, 0) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2(-1.0, 0) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2( 0, 1.0) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2( 0,-1.0) * tex_offset );
		
		tex_offset *= 0.75;
		
		result += tex2D(SamplerBC,texcoords + float2( 0.5, 0.5) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2(-0.5,-0.5) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2( 0.5,-0.5) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2(-0.5, 0.5) * tex_offset );
		
		result += tex2D(SamplerBC,texcoords + float2( 0.75, 0.75) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2(-0.75,-0.75) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2( 0.75,-0.75) * tex_offset );
		result += tex2D(SamplerBC,texcoords + float2(-0.75, 0.75) * tex_offset );
	    
   return result / 17;
}

float3 LastBlur(float2 texcoords : TEXCOORD0)
{
	float2 tex_offset = Spread * pix; // Gets texel offset
	float3 result;
	
	if (Alternate)
		tex_offset *= 0.5;
	
		result += tex2D(SamplerBlur,texcoords + float2( 0.5, 0) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2(-0.5, 0) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2( 0, 0.5) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2( 0,-0.5) * tex_offset ).rgb;
		
		result += tex2D(SamplerBlur,texcoords + float2( 1.0, 0) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2(-1.0, 0) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2( 0, 1.0) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2( 0,-1.0) * tex_offset ).rgb;
		
		tex_offset *= 0.75;
		
		result += tex2D(SamplerBlur,texcoords + float2( 0.5, 0.5) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2(-0.5,-0.5) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2( 0.5,-0.5) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2(-0.5, 0.5) * tex_offset ).rgb;
		
		result += tex2D(SamplerBlur,texcoords + float2( 0.75, 0.75) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2(-0.75,-0.75) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2( 0.75,-0.75) * tex_offset ).rgb;
		result += tex2D(SamplerBlur,texcoords + float2(-0.75, 0.75) * tex_offset ).rgb;

   return result / 17;
}

float4 Mix_Bloom(float4 position : SV_Position, float2 texcoords : TEXCOORD) : SV_Target//Then blurred.                                                                        
{  
	return float4(LastBlur(texcoords) + tex2D(PSBackBuffer, texcoords).rgb,1.); // Merge Current and past frame.
}

float3 HableTonemap(float3 x)
{
	float A,B,C,D,E,F;
	A = 0.22f;
	B = 0.30f;
	C = 0.10f;
	D = 0.20f;
	E = 0.01f;
	F = 0.22f;
   return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

float4 HDROut(float2 texcoord : TEXCOORD0)
{	
	float A = 1-tex2D(SamplerAvgLum,0.0).x, BI = Bloom_Intensity, Ex = Exp,NC = smoothstep(0,1,A);
	
	NC = saturate(NC - 0.5);
     	
	if(Auto_Bloom_Intensity)
	{
		BI = 0.375;
		BI *= NC;
	}
	//Blur Acculimation 
	float3 acc = tex2Dlod(SamplerBloom, float4(texcoord,0,0)).rgb;
		   acc += tex2Dlod(SamplerBloom, float4(texcoord,0,1)).rgb;
		   acc += tex2Dlod(SamplerBloom, float4(texcoord,0,2)).rgb;
		   acc += tex2Dlod(SamplerBloom, float4(texcoord,0,3)).rgb;
		   acc += tex2Dlod(SamplerBloom, float4(texcoord,0,4)).rgb;
		   acc += tex2Dlod(SamplerBloom, float4(texcoord,0,5)).rgb;
	   	acc /= 6;	
         
	float4 Out;
    float3 TM, Color = tex2D(BackBuffer, texcoord).rgb, Bloom = acc.rgb, bloomColor = acc.rgb;
	// Do inital de-gamma of the game image to ensure we're operating in the correct colour range.
	if( Gamma > 1.00 )
		Color = pow(abs(Color),Gamma);
	//Bloom Intensity
	bloomColor = 1.0 - exp(-bloomColor * BI);
	
	//Add Bloom
	Color += bloomColor;

	if(Auto_Exposure)
		Ex = A * 1.25;
	//UTM		
	Color *= Ex;  // Exposure Adjustment

	float ExposureBias = 2.0f;
	float3 curr;
	
	float3 lum = Luma().x * Color.r + Luma().y * Color.g + Luma().z * Color.b;
	float3 newLum = HableTonemap(ExposureBias*lum);
	float3 lumScale = newLum / lum;
	curr = Color*lumScale;

	float3 whiteScale = 1.0f/HableTonemap(W);
	
	Color = curr*whiteScale;
    
	// Do the post-tonemapping gamma correction
	if( Gamma > 1.00 )
		Color = pow(abs(Color),1/Gamma);


	//FAKE HDR
	Color = pow(abs(Color),HDR_Adjust) + (Color * 0.5);

	if (Debug_View == 0)
		Out = float4(Color, 1.0);
	else if(Debug_View == 1)
		Out = float4(1. - exp(-Bloom), 1.0);	
	else
		Out = A.xxxx;
		
	return Out;
}

float4 Past_BackSingleBuffer(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{	
	 return float4(LastBlur(texcoord),1.0);
}

float PS_StoreAvgLuma(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    return tex2D(SamplerAvgLum,texcoord).x;
}

uniform float timer < source = "timer"; >;
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
		pass Bright_Filter
	{
		VertexShader = PostProcessVS;
		PixelShader = BrightColors;
		RenderTarget = texBC;
	}
		pass Blur_Filter_One
	{
		VertexShader = PostProcessVS;
		PixelShader = Blur;
		RenderTarget = texBlur;
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
