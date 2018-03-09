 ////----------------------//
 ///**Depth Unsharp Mask**///
 //----------------------////

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
 //*                                                                                                            																	*//
 //*                                                                                                            																	*//
 //* 											Bilateral Filter Made by mrharicot ported over to Reshade by BSD																	*//
 //*											GitHub Link for sorce info github.com/SableRaf/Filters4Processin																	*//
 //* 											Shadertoy Link https://www.shadertoy.com/view/4dfGDH  Thank You.																	*//	 
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The resolution of the Bilateral Filtered Image. For 4k Use 2, 1.75 or 1.5. For 1440p Use 1.5, 1.375, or 1.25. For 1080p use 1.25, or 1.
#define Image_Division 1

uniform float contrast <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "Contrast";
	ui_tooltip = "Use if your Game is Too Dark";
> = 0;

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Raw\0Raw Reverse\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 0.25; ui_max = 100.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map and sharpness.";
> = 5.0;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform bool No_Depth_Map <
	ui_label = "No Depth Map";
	ui_tooltip = "If you have No Depth Buffer turn this On.";
> = false;

uniform int Output_Selection <
	ui_type = "combo";
	ui_items = "Normal\0Color Only\0Greyscale Only\0";
	ui_label = "Output Selection";
	ui_tooltip = "Select Sharpen output type.";
> = 0;

uniform float Sharpen_Power <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 5;
	ui_label = "Sharpen Power";
	ui_tooltip = "Increases or Decreases the Sharpen power.";
> = 1.0;

uniform bool View_Adjustment <
	ui_label = "View Adjustment";
	ui_tooltip = "Adjust the depth map and Depth Blur.";
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
		
texture texBF { Width = BUFFER_WIDTH/Image_Division; Height = BUFFER_HEIGHT/Image_Division; Format = RGBA8;};

sampler SamplerBF
	{
		Texture = texBF;
	};
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float4 Depth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float DDA = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float DA = Depth_Map_Adjust*2; //Depth Map Adjust - Near
		//All 1.0f are Far Adjustment
	
		//1. Raw Buffer
		float Raw = pow(abs(zBuffer),DA);
		
		//2. Raw Buffer Reverse
		float RawReverse = pow(abs(zBuffer - 1.0),DA);
		

		if (Depth_Map == 0)
		{
		zBuffer = Raw;
		}
		else
		{
		zBuffer = RawReverse;
		}
	
	return 1-saturate(float4(zBuffer.rrr,1));	
}

#define SIGMA 10
#define BSIGMA 0.1125
#define MSIZE 6

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

float normpdf3(in float3 v, in float sigma)
{
	return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
}

void Filters(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)                                                                          
{
	//Bilateral Filter//                                                                                                                                                                   
	float3 c = tex2D(BackBuffer,texcoord.xy).rgb;
	float sampleOffset = Depth(texcoord).r/0.425; //Depth Buffer Offset adjust
	float2 ScreenCal = float2(2.5*pix.x,2.5*pix.y);

	float2 FinCal = ScreenCal;
	
	const int kSize = (MSIZE-1)/2;	
	
	float weight[MSIZE] = 
	{  
	0.031225216, 
	0.033322271, 
	0.035206333, 
	0.036826804, 
	0.038138565, 
	0.039104044
	};  
		float3 final_colour;
		float Z;
		[unroll]
		for (int j = 0; j <= kSize; ++j)
		{
			weight[kSize+j] = normpdf(float(j), SIGMA);
			weight[kSize-j] = normpdf(float(j), SIGMA);
		}
		
		float3 cc;
		float factor;
		float bZ = 1.0/normpdf(0.0, BSIGMA);
		
		[loop]
		for (int i=-kSize; i <= kSize; ++i)
		{
			for (int j=-kSize; j <= kSize; ++j)
			{
			
				float2 XY;
				
				if(No_Depth_Map)
				{
					XY = float2(float(i),float(j))*FinCal;
					cc = tex2D(BackBuffer,texcoord.xy+XY).rgb;
				}
				else
				{
					XY = float2(float(i),float(j))*FinCal;
					cc = tex2D(BackBuffer,texcoord.xy+XY*sampleOffset).rgb;
				}
				factor = normpdf3(cc-c, BSIGMA)*bZ*weight[kSize+j]*weight[kSize+i];
				Z += factor;
				final_colour += factor*cc;

			}
		}
		
		float4 Bilateral_Filter = float4(final_colour/Z, 1.0);
		
	color = Bilateral_Filter;
}

float4 SharderOut(float2 texcoord : TEXCOORD0)
{	
	//Luma (SD video)	float3(0.299, 0.587, 0.114)
	//Luma (HD video)	float3(0.2126, 0.7152, 0.0722) https://en.wikipedia.org/wiki/Luma_(video)
	//Luma (HDR video)	float3(0.2627, 0.6780, 0.0593) https://en.wikipedia.org/wiki/Rec._2100
	float4 Out,RGBA;
	float3 Luma_Coefficient = float3(0.2627, 0.6780, 0.0593),RGB,RGBT,RGBB; //Used in Grayscale calculation I see no diffrence....
	
	RGB = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).rgb - tex2D(SamplerBF,float2(texcoord.x,texcoord.y)).rgb;
	
	float3 Color_Sharp_Control = RGB * Sharpen_Power; 
	float Grayscale_Sharp_Control = dot(RGB, saturate(Luma_Coefficient * Sharpen_Power));
	
	if (Output_Selection == 0)
	{
		RGBA = saturate(lerp(Grayscale_Sharp_Control,float4(Color_Sharp_Control,1),0.5)) + tex2D(BackBuffer,float2(texcoord.x,texcoord.y));
	}
	else if (Output_Selection == 1)
	{
		RGBA = saturate(float4(Color_Sharp_Control,1)) + tex2D(BackBuffer,float2(texcoord.x,texcoord.y));
	}
	else
	{
		RGBA = saturate(Grayscale_Sharp_Control) + tex2D(BackBuffer,float2(texcoord.x,texcoord.y));
	}
	
	float4 Combine = RGBA * (1.0+contrast);

	if (View_Adjustment == 0)
	{
		Out = Combine;
	}
	else
	{
		RGBT = tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2)).rgb - tex2D(SamplerBF,float2(texcoord.x*2,texcoord.y*2)).rgb;
		RGBB = tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2-1)).rgb - tex2D(SamplerBF,float2(texcoord.x*2,texcoord.y*2-1)).rgb;
		
		float3 CSCT = (RGBT * 5) * Sharpen_Power; 
		float GSCT = dot(RGBT, saturate((Luma_Coefficient * 5 ) * Sharpen_Power));
		
		float3 CSCB = (RGBB * 2.5) * Sharpen_Power; 
		float GSCB = dot(RGBB, saturate((Luma_Coefficient * 2.5) * Sharpen_Power));
	
		if (Output_Selection == 0)
			{
				RGB = saturate(lerp(GSCT,CSCT,0.5));
				RGBA = saturate(lerp(GSCB,float4(CSCB,1),0.5)) + tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2-1));
			}
		else if (Output_Selection == 1)
			{
				RGB = saturate(CSCT);
				RGBA = saturate(float4(CSCB,1)) + tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2-1));
			}
		else
			{
				RGB = saturate(GSCT);
				RGBA = saturate(GSCB) + tex2D(BackBuffer,float2(texcoord.x*2,texcoord.y*2-1));
			}
			
		float4 VA_Top = texcoord.x < 0.5 ? float4(RGB,1) : 1 - Depth(float2(texcoord.x*2-1,texcoord.y*2));
		float4 VA_Bottom = texcoord.x < 0.5 ? RGBA : tex2D(SamplerBF,float2(texcoord.x*2-1,texcoord.y*2-1));
		
	Out = texcoord.y < 0.5 ? VA_Top : VA_Bottom;
	
	}
	
	return Out;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = SharderOut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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

technique Smart_Sharp
{			
			pass FilterOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Filters;
			RenderTarget = texBF;
		}
			pass UnsharpMask
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}