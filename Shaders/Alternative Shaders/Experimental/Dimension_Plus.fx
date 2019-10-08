////-----------//
///**Depth3D**///
//-----------////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* Depth Map Based 3D post-process shader Depth3D v1.4.0                                                                                                                         
//* For Reshade 3.0 & 4.0                                                                                                                                                         
//* ---------------------------------------------------------------------------------------------------                                                                          
//*                                                                                                                                                                             
//* This Shader is an simplified version of SuperDepth3D.fx a shader I made for ReShade's collection standard effects. For the use with stereo 3D screens.                  
//* Also had to rework Philippe David http://graphics.cs.brown.edu/games/SteepParallax/index.html code to work with reshade. This is used for the parallax effect.               
//* This idea was taken from this shader here located at https://github.com/Fubaxiusz/fubax-shaders/blob/596d06958e156d59ab6cd8717db5f442e95b2e6b/Shaders/VR.fx#L395              
//* It's also based on Philippe David Steep Parallax mapping code. If I missed any information please contact me so I can make corrections.                                      
//* 													Multi-licensing	
//* LICENSE
//* ============
//* Overwatch & Code out side the work of people mention above is licenses under: Attribution-NoDerivatives 4.0 International
//*
//* You are free to:
//* Share - copy and redistribute the material in any medium or format
//* for any purpose, even commercially.
//* The licensor cannot revoke these freedoms as long as you follow the license terms.
//* Under the following terms:
//* Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. 
// *You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
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
//* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader                                                                            
//*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//USER EDITABLE PREPROCESSOR FUNCTIONS START//

//Alt Z Linearization
#define ALTZ 1

//USER EDITABLE PREPROCESSOR FUNCTIONS END//
#include "ReShadeUI.fxh"
#include "ReShade.fxh"

uniform float Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = 100; ui_step = 0.5;
	ui_label = "·Divergence Slider·";
	ui_tooltip = "Divergence increases differences between the left and right retinal images and allows you to experience depth.\n" 
				 "The process of deriving binocular depth information is called stereopsis.\n"
				 "You can override this value.";
	ui_category = "Divergence & Convergence";
> = 50.0;

uniform float Pivot_Point <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "·Pivot Point Slider·";
	ui_tooltip = "Pivot Point works like convergence in an 3D image.";
	ui_category = "Divergence & Convergence";
> = 0.5;

uniform bool invertX <
	ui_label = " Invert X";
	ui_tooltip = "Invert X.";
> = false;

uniform bool invertY <
	ui_label = " Invert Y";
	ui_tooltip = "Invert Y.";
> = false;

uniform float Auto_Depth_Range <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = " Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n" 
				 "Default is 0.4375f, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.4375;

//Depth Buffer Adjust//
uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Z-Buffer Normal\0Z-Buffer Reversed\0";
	ui_label = "·Z-Buffer Selection·";
	ui_tooltip = "Select Depth Buffer Linearization.";
	ui_category = "Depth Buffer Adjust";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.0; ui_step = 0.125;
	ui_label = " Z-Buffer Adjustment";
	ui_tooltip = "This allows for you to adjust Depth Buffer Precision.\n"
	             "Try to adjust this to keep it as low as possible.\n"
	             "Don't go too high with this adjustment.\n"
	             "Default is 5.0";
	ui_category = "Depth Buffer Adjust";
> = 5.0;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Depth Map Offset";
	ui_tooltip = "Depth Map Offset is for non conforming ZBuffer.\n"
				 "It,s rare if you need to use this in any game.\n"
				 "Use this to make adjustments to DM 0 or DM 1.\n"
				 "Default and starts at Zero and it's Off.";
	ui_category = "Depth Buffer Adjust";
> = 0;

uniform bool Depth_Map_View <
	ui_label = " Display Depth";
	ui_tooltip = "Display the Depth Buffer.";
	ui_category = "Depth Buffer Adjust";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = " Flip Depth";
	ui_tooltip = "Flip the Depth Buffer if it is upside down.";
	ui_category = "Depth Buffer Adjust";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix ReShade::PixelSize
#define Tsize float2(BUFFER_WIDTH,BUFFER_HEIGHT)
sampler DepthBuffer
{
	Texture = ReShade::DepthBufferTex;
};

sampler BackBuffer
{
	Texture = ReShade::BackBufferTex;
	AddressU = BORDER;
	AddressV = BORDER;
	AddressW = BORDER;
};	
	
uniform float2 Mousecoords < source = "mousepoint"; > ;	
/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLumi {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumi																
	{
		Texture = texLumi;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
		
float Lumi(in float2 texcoord : TEXCOORD0)
	{
		float Luminance = tex2Dlod(SamplerLumi,float4(texcoord,0,11)).r; //Average Luminance Texture Sample 

		return Luminance;
	}
	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

float Depth(in float2 texcoord : TEXCOORD0)
{		
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBuffer = tex2Dlod(DepthBuffer,float4(texcoord,0,0)).x; //Depth Buffer
	
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1., Near = 0.125/Depth_Map_Adjust, DA = Depth_Map_Adjust * 2.0f; //Depth Map Adjust - Near
	
	float2 Offsets = float2(1 + Offset,1 - Offset), Z = float2( zBuffer, 1-zBuffer );
	
	if (Offset > 0)
	Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));

	#if ALTZ == 1
	[branch] if (Depth_Map == 0)//DM0. Normal
		zBuffer = pow(abs(Z.x),DA);		
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = pow(abs(Z.y),DA);
	#else
	[branch] if (Depth_Map == 0)//DM0. Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = Far * Near / (Far + Z.y * (Near - Far));
	#endif
	return zBuffer;
}

float AutoDepthRange( float d, float2 texcoord )
{
	float LumAdjust_ADR = smoothstep(-0.0175,Auto_Depth_Range,Lumi(texcoord));
    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
}

float zBuffer(in float2 texcoord : TEXCOORD0)
{	
	float DM = Depth(texcoord);
	
		if (Auto_Depth_Range > 0)
			DM = AutoDepthRange(DM,texcoord);

	return DM;
}

float2 Parallax( float2 Diverge, float2 Coordinates)
{
	float D = abs(length(Diverge)) * 2; 
	float Cal_Steps = D + (D * 0.04);
	
	//ParallaxSteps
	float Steps = clamp(Cal_Steps,0,255);
	
	// Offset per step progress & Limit
	float LayerDepth = rcp(Steps);

	//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
	float2 MS = Diverge * pix;
	float2  deltaCoordinates = MS * LayerDepth, ParallaxCoord = Coordinates, DB_Offset = (Diverge * 0.025) * pix;
	float CurrentDepthMapValue = zBuffer(ParallaxCoord), CurrentLayerDepth = 0;

	[loop] //Steep parallax mapping
    for ( int i = 0; i < Steps; i++ )
    {	// Doing it this way should stop crashes in older version of reshade, I hope.
        if (CurrentDepthMapValue <= CurrentLayerDepth)
			break; // Once we hit the limit Stop Exit Loop.
        // Shift coordinates horizontally in linear fasion
        ParallaxCoord -= deltaCoordinates;
        // Get depth value at current coordinates
		CurrentDepthMapValue = zBuffer( ParallaxCoord - DB_Offset);
        // Get depth of next layer
        CurrentLayerDepth += LayerDepth;
    }
   	
	// Parallax Occlusion Mapping
	float2 PrevParallaxCoord = ParallaxCoord + deltaCoordinates, DepthDifference;
	float afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
	float beforeDepthValue = zBuffer( ParallaxCoord ) - CurrentLayerDepth + LayerDepth;
		
	// Interpolate coordinates
	float weight = afterDepthValue / (afterDepthValue - beforeDepthValue);
	ParallaxCoord = PrevParallaxCoord * max(0,weight) + ParallaxCoord * min(1,1.0f - weight);
	

	ParallaxCoord += DB_Offset;
	

	
	return ParallaxCoord;
}

float4 PS_calcLRUD(float2 texcoord)
{
	float2 TexCoords = texcoord,Center;
	float4 color;
	float2 MousecoordsXY = (Tsize - Mousecoords) * pix;
	Center = MousecoordsXY - 0.5;
	
	if( invertX )
		Center.x = -Center.x;
	if( invertY )
		Center.y = -Center.y;
		
	float PP = Divergence * Pivot_Point;
	
	float2 Per = (Center * pix) * PP;
					
	texcoord = Parallax(float2(Center.x * Divergence,Center.y * Divergence) , texcoord + Per);					
		
	if(!Depth_Map_View)
	{	

			color = tex2Dlod(BackBuffer, float4(texcoord,0,0));

	}
		else
	{		
			float3 RGB = Depth(texcoord).xxx;
			color = float4(RGB.r,AutoDepthRange(RGB.g,TexCoords),RGB.b,1.0);
	}

	return float4(color.rgb,1.0);
}

float4 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float3 Average_Lum = Depth(texcoord).xxx;
	return float4(Average_Lum,1.0);
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y;	
	float3 Color = PS_calcLRUD(texcoord).rgb,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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

//*Rendering passes*//
technique Dimension_Plus
< ui_tooltip = "This Shader should be the VERY LAST Shader in your master shader list.\n"
	           "You can always Drag shaders around by clicking them and moving them."; >
	           //"For more help you can always contact me at DEPTH3D.info."; >//Website WIP
{
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLumi;
	}
		pass StereoOut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
}
