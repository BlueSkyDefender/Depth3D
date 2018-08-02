 ////-----------//
 ///**Depth3D**///
 //-------- --////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.9          																														*//
 //* For Reshade 3.0																																								*//
 //* --------------------------																																						*//
 //* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																								*//
 //* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																				*//
 //* I would also love to hear about a project you are using it with.																												*//
 //* https://creativecommons.org/licenses/by/3.0/us/																																*//
 //*																																												*//
 //* Jose Negrete AKA BlueSkyDefender																																				*//
 //*																																												*//
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				*//	
 //* ---------------------------------																																				*//
 //*																																												*//
 //* Original work was based on the shader code of a CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology								*//
 //*																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//USER EDITABLE PREPROCESSOR FUNCTIONS START//

// Determines The resolution of the Depth Map. For 4k Use 1.75 or 1.5. For 1440p Use 1.5 or 1.25. For 1080p use 1. Too low of a resolution will remove too much.
#define Depth_Map_Division 1.5

// Determines the Max Depth amount, in ReShades GUI.
#define Depth_Max 50

// Enable this to fix the problem when there is a full screen Game Map Poping out of the screen. AKA Full Black Depth Map Fix. I have this off by default. Zero is off, One is On.
#define FBDMF 0 //Default 0 is Off. One is On.

//Use Depth Tool to adjust the lower preprocessor definitions below.
//Horizontal & Vertical Depth Buffer Resize for non conforming BackBuffer.
//Ex. Resident Evil 7 Has this problem. So you want to adjust it too around float2(0.9575,0.9575).
#define Horizontal_and_Vertical float2(1.0, 1.0) // 1.0 is Default.

//Image Position Adjust is used to move the Z-Buffer around.
#define Image_Position_Adjust float2(0.0,0.0)

//Zero Is Off One is On.
#define Depth_Boost 0 //0/1/

//USER EDITABLE PREPROCESSOR FUNCTIONS END//
//Divergence & Convergence//
uniform float Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = Depth_Max;
	ui_label = "·Divergence Slider·";
	ui_tooltip = "Determines the amount of Image Warping and Separation.\n" 
				 "You can override this value.";
	ui_category = "Divergence & Convergence";
> = 35.0;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.250;
	ui_label = " Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect also known as Convergence.\n"
				"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
				"Default is 0.025, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.025;

uniform float Auto_Depth_Range <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = " Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n" 
				 "Default is Zero, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.0;
//Occlusion Masking//
uniform int Disocclusion_Selection <
	ui_type = "combo";
	ui_items = "Off\0Radial Blur\0Normal Blur\0";
	ui_label = "·Disocclusion Selection·";
	ui_tooltip = "This is to select the z-Buffer blurring option for low level occlusion masking.\n"
				"Default is Off.";
	ui_category = "Occlusion Masking";
> = 0;

uniform float Disocclusion_Power_Adjust <
	ui_type = "drag";
	ui_min = 0.250; ui_max = 2.5;
	ui_label = " Disocclusion Power Adjust";
	ui_tooltip = "Automatic occlusion masking power adjust.\n"
				"Default is 1.0";
	ui_category = "Occlusion Masking";
> = 1.0;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = " Edge Handling";
	ui_tooltip = "Edges selection for your screen output.";
	ui_category = "Occlusion Masking";
> = 1;
//Depth Map//
uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DM0 Normal\0DM1 Normal Reversed\0DM2 Offset Normal\0DM3 Offset Reversed\0";
	ui_label = "·Depth Map Selection·";
	ui_tooltip = "Linearization for the zBuffer also known as Depth Map.\n"
			     "Normally you want to use DM0 or DM1 in most cases.\n"
			     "Offset settings only work with DM2 or DM3.";
	ui_category = "Depth Map";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 0.250; ui_max = 125.0;
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map for your games.";
	ui_category = "Depth Map";
> = 7.5;

uniform float Offsets <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = " Offset";
	ui_tooltip = "Offset is for the Depth Map 2 and 3 Only.";
	ui_category = "Depth Map";
> = 0.5;

uniform bool Depth_Map_View <
	ui_label = " Depth Map View";
	ui_tooltip = "Display the Depth Map.";
	ui_category = "Depth Map";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = " Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Map";
> = false;

//Stereoscopic Options//
uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Checkerboard 3D\0Anaglyph\0";
	ui_label = "·3D Display Modes·";
	ui_tooltip = "Stereoscopic 3D display output selection.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform float Interlace_Optimization <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.5;
	ui_label = " Interlace Optimization";
	ui_tooltip = "Interlace Optimization Is used to reduce alisesing in a Line or Column interlaced image.\n"
	             "This has the side effect of softening the image.\n"
	             "Default is 0.375";
	ui_category = "Stereoscopic Options";
> = 0.375;

uniform int Anaglyph_Colors <
	ui_type = "combo";
	ui_items = "Red/Cyan\0Dubois Red/Cyan\0Green/Magenta\0Dubois Green/Magenta\0";
	ui_label = " Anaglyph Color Mode";
	ui_tooltip = "Select colors for your 3D anaglyph glasses.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform float Anaglyph_Desaturation <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Anaglyph Desaturation";
	ui_tooltip = "Adjust anaglyph desaturation, Zero is Black & White, One is full color.";
	ui_category = "Stereoscopic Options";
> = 1.0;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = " Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
	ui_category = "Stereoscopic Options";
> = 0;

uniform bool Eye_Swap <
	ui_label = " Swap Eyes";
	ui_tooltip = "L/R to R/L.";
	ui_category = "Stereoscopic Options";
> = false;

//Cursor Adjustments//
uniform float4 Cross_Cursor_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 255.0;
	ui_label = "·Cross Cursor Adjust·";
	ui_tooltip = "Pick your own cross cursor color & Size.\n" 
				 " Default is (R 255, G 255, B 255 , Size 25)";
	ui_category = "Cursor Adjustments";
> = float4(255.0, 255.0, 255.0, 25.0);

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
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
	
sampler BackBufferMIRROR 
	{ 
		Texture = BackBufferTex;
		AddressU = MIRROR;
		AddressV = MIRROR;
		AddressW = MIRROR;
	};

sampler BackBufferBORDER
	{ 
		Texture = BackBufferTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

sampler BackBufferCLAMP
	{ 
		Texture = BackBufferTex;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
texture texDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F;}; 

sampler SamplerDM
	{
		Texture = texDM;
	};
	
texture texDis  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F;}; 

sampler SamplerDis
	{
		Texture = texDis;
	};
			
uniform float2 Mousecoords < source = "mousepoint"; > ;	
////////////////////////////////////////////////////////////////////////////////////Cross Cursor////////////////////////////////////////////////////////////////////////////////////	
float4 MouseCursor(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float2 MousecoordsXY = Mousecoords * pix;
	float2 CC_Size = Cross_Cursor_Adjust.a * pix;
	float2 CC_ModeA = float2(1.25,1.0), CC_ModeB = float2(0.5,0.5);
	float4 Mpointer = all(abs(texcoord - MousecoordsXY) < CC_Size*CC_ModeA) * (1 - all(abs(texcoord - MousecoordsXY) > CC_Size/(Cross_Cursor_Adjust.a*CC_ModeB))) ? float4(Cross_Cursor_Adjust.rgb/255, 1.0) : tex2D(BackBuffer, texcoord);//cross
	
	return Mpointer;
}
/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLum {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLum																
	{
		Texture = texLum;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
		
float Lum(in float2 texcoord : TEXCOORD0)
	{
		float Luminance = tex2Dlod(SamplerLum,float4(texcoord,0,0)).r; //Average Luminance Texture Sample 

		return Luminance;
	}
	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target)
{
		float2 texXY = texcoord + Image_Position_Adjust * pix;		
		float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
		texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
		
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float Far = 1, Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near

		//Raw Z Offset
		float Z = min(1,pow(abs(exp(zBuffer)*Offsets),2));
		float ZR = min(1,pow(abs(exp(zBuffer)*Offsets),50));
		
		//0. Normal
		float Normal = Far * Near / (Far + zBuffer * (Near - Far));
		
		//1. Reverse
		float NormalReverse = Far * Near / (Near + zBuffer * (Far - Near));
		
		//2. Offset Normal
		float OffsetNormal = Far * Near / (Far + Z * (Near - Far));
			  OffsetNormal = lerp(Normal,OffsetNormal,0.875);//mixing
			  
		//3. Offset Reverse
		float OffsetReverse = Far * Near / (Near + ZR * (Far - Near));
			  OffsetReverse = lerp(NormalReverse,OffsetReverse,0.875);//mixing
		
		float DM;
		
		if (Depth_Map == 0)
		{
			DM = Normal;
		}		
		else if (Depth_Map == 1)
		{
			DM = NormalReverse;
		}
		else if (Depth_Map == 2)
		{
			DM = OffsetNormal;
		}
		else
		{
			DM = OffsetReverse;
		}
						
	Color = float4(DM,DM,DM,1.0);
}

float AutoDepthRange( float d, float2 texcoord )
{
	float LumAdjust = smoothstep(-0.0175,Auto_Depth_Range,Lum(texcoord));
    return min(1,( d - 0 ) / ( LumAdjust - 0));
}

float Conv(float D,float2 texcoord)
{
	float Z, ZP, Con = ZPD, NF_Power, MSZ = Divergence * pix.x;

		float Divergence_Locked = Divergence*0.00105;
		float ALC = abs(smoothstep(0,1.0,Lum(texcoord)));
					
		if (ALC <= 0.000425 && FBDMF) //Full Black Depth Map Fix.
		{
			Z = 0;
			Divergence_Locked = 0;
		}
		else
		{
			Z = Con;
			Divergence_Locked = Divergence_Locked;
		}	
		
		Z *= 0.1f;
		
		if (ZPD == 0)
		ZP = 1.0;
		
		float Convergence = 1 - Z / D;		
		
		if (Auto_Depth_Range > 0)
		{
			D = AutoDepthRange(D,texcoord);
		}
			
		if (Depth_Boost)
		{
		D += min(1,lerp(D,1-D,-0.125));
		D *= 0.5;
		}
		
		Z = lerp( MSZ * Convergence, MSZ * D, 0.5);
				
    return Z;
}

void  Disocclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
float X, Y, Z, W = 1, DM, DMA, Out, A, DP =  Divergence, Disocclusion_PowerA, Disocclusion_PowerB , AMoffset = 0.008, BMoffset = 0.00285714, CMoffset = 0.09090909;
float2 dirA, dirB;

	DP *= Disocclusion_Power_Adjust;
		
	if ( Disocclusion_Selection == 1 || Disocclusion_Selection == 4 ) // Radial    
	{
		Disocclusion_PowerA = DP*AMoffset;
	}
	else if ( Disocclusion_Selection == 2 || Disocclusion_Selection == 5 ) // Normal  
	{
		Disocclusion_PowerA = DP*BMoffset;
	}
		
	if (Disocclusion_Selection >= 1) 
	{
		const float weight[11] = {0.0,0.010,-0.010,0.020,-0.020,0.030,-0.030,0.040,-0.040,0.050,-0.050}; //By 10
		
		if( Disocclusion_Selection == 1)
		{
			dirA = 0.5 - texcoord;
			dirB = 0.5 - texcoord;
			A = Disocclusion_PowerA;
		}
		else if ( Disocclusion_Selection == 2 || Disocclusion_Selection == 3 || Disocclusion_Selection == 5)
		{
			dirA = float2(0.5,0.0);
			dirB = float2(0.5,0.0);
			A = Disocclusion_PowerA;
		}
		else if(Disocclusion_Selection == 4)
		{
			dirA = 0.5 - texcoord;
			dirB = float2(0.5,0.0);
			A = Disocclusion_PowerA;
		}
		
		if ( Disocclusion_Selection >= 1 )
		{			
				[loop]
				for (int i = 0; i < 11; i++)
				{	
					DM += tex2Dlod(SamplerDM,float4(texcoord + dirA * weight[i] * A,0,0)).x*CMoffset;
				}
		}
		
	}
	else
	{
		DM = tex2Dlod(SamplerDM,float4(texcoord,0,0)).x;
	}

	X = DM;
	
	X = smoothstep(0,1,X);	
	
	color = float4(X,Y,Z,W);
}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
float4 PS_calcLR(float2 texcoord)
{
	float2 TCL, TCR, TexCoords = texcoord;
	float4 color, Right, Left;
	float DepthR = 1, DepthL = 1, Adjust_A = 0.11111112, Adjust_B = 0.07692307, N, S, X, L, R;
	float samplesA[9] = {0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1.0};

	//MS is Max Separation P is Perspective Adjustment
	float MS = Divergence * pix.x, P = Perspective * pix.x;
					
	if(Eye_Swap)
	{
		if ( Stereoscopic_Mode == 0 )
		{
			TCL = float2((texcoord.x*2-1) - P,texcoord.y);
			TCR = float2((texcoord.x*2) + P,texcoord.y);
		}
		else if( Stereoscopic_Mode == 1 )
		{
			TCL = float2(texcoord.x - P,texcoord.y*2-1);
			TCR = float2(texcoord.x + P,texcoord.y*2);
		}
		else
		{
			TCL = float2(texcoord.x - P,texcoord.y);
			TCR = float2(texcoord.x + P,texcoord.y);
		}
	}	
	else
	{
		if (Stereoscopic_Mode == 0)
		{
			TCL = float2((texcoord.x*2) + P,texcoord.y);
			TCR = float2((texcoord.x*2-1) - P,texcoord.y);
		}
		else if(Stereoscopic_Mode == 1)
		{
			TCL = float2(texcoord.x + P,texcoord.y*2);
			TCR = float2(texcoord.x - P,texcoord.y*2-1);
		}
		else
		{
			TCL = float2(texcoord.x + P,texcoord.y);
			TCR = float2(texcoord.x - P,texcoord.y);
		}
	}
	
	//Optimization for line & column interlaced out.
	if (Stereoscopic_Mode == 2)
	{
		TCL.y = TCL.y + (Interlace_Optimization * pix.y);
		TCR.y = TCR.y - (Interlace_Optimization * pix.y);
	}
	else if (Stereoscopic_Mode == 3)
	{
		TCL.x = TCL.x + (Interlace_Optimization * pix.y);
		TCR.x = TCR.x - (Interlace_Optimization * pix.y);
	}
			
				
	[loop]
	for ( int i = 0 ; i < 9; i++ ) 
	{
		S = samplesA[i] * MS;//9
		DepthL = min(DepthL,tex2Dlod(SamplerDis,float4(TCL.x+S, TCL.y,0,0)).x);
		DepthR = min(DepthR,tex2Dlod(SamplerDis,float4(TCR.x-S, TCR.y,0,0)).x);
	}
		
	DepthL = Conv(DepthL,TexCoords);//Zero Parallax Distance Pass Left
	DepthR = Conv(DepthR,TexCoords);//Zero Parallax Distance Pass Right
			
	float ReprojectionLeft =  DepthL;
	float ReprojectionRight = DepthR;

	if(Custom_Sidebars == 0)
	{
		Left = tex2Dlod(BackBufferMIRROR, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
		Right = tex2Dlod(BackBufferMIRROR, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
	}
	else if(Custom_Sidebars == 1)
	{
		Left = tex2Dlod(BackBufferBORDER, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
		Right = tex2Dlod(BackBufferBORDER, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
	}
	else
	{
		Left = tex2Dlod(BackBufferCLAMP, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
		Right = tex2Dlod(BackBufferCLAMP, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
	}
	
	float4 cL = Left,cR = Right; //Left Image & Right Image

	if ( Eye_Swap )
	{
		cL = Right;
		cR = Left;	
	}
		
	if(!Depth_Map_View)
	{	
	float2 gridxy = floor(float2(TexCoords.x*BUFFER_WIDTH,TexCoords.y*BUFFER_HEIGHT));

			
		if(Stereoscopic_Mode == 0)
		{	
			color = TexCoords.x < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 1)
		{	
			color = TexCoords.y < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 2)
		{
			color = int(gridxy.y) & 1 ? cR : cL;	
		}
		else if(Stereoscopic_Mode == 3)
		{
			color = int(gridxy.x+gridxy.y) & 1 ? cR : cL;
		}
		else if(Stereoscopic_Mode == 4)
		{													
				float3 HalfLA = dot(cL.rgb,float3(0.299, 0.587, 0.114));
				float3 HalfRA = dot(cR.rgb,float3(0.299, 0.587, 0.114));
				float3 LMA = lerp(HalfLA,cL.rgb,Anaglyph_Desaturation);  
				float3 RMA = lerp(HalfRA,cR.rgb,Anaglyph_Desaturation); 
				
				float4 cA = float4(LMA,1);
				float4 cB = float4(RMA,1);
	
			if (Anaglyph_Colors == 0)
			{
				float4 LeftEyecolor = float4(1.0,0.0,0.0,1.0);
				float4 RightEyecolor = float4(0.0,1.0,1.0,1.0);
				
				color =  (cA*LeftEyecolor) + (cB*RightEyecolor);
			}
			else if (Anaglyph_Colors == 1)
			{
			float red = 0.437 * cA.r + 0.449 * cA.g + 0.164 * cA.b
					- 0.011 * cB.r - 0.032 * cB.g - 0.007 * cB.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = -0.062 * cA.r -0.062 * cA.g -0.024 * cA.b 
						+ 0.377 * cB.r + 0.761 * cB.g + 0.009 * cB.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.048 * cA.r - 0.050 * cA.g - 0.017 * cA.b 
						-0.026 * cB.r -0.093 * cB.g + 1.234  * cB.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }

			color = float4(red, green, blue, 0);
			}
			else if (Anaglyph_Colors == 2)
			{
				float4 LeftEyecolor = float4(0.0,1.0,0.0,1.0);
				float4 RightEyecolor = float4(1.0,0.0,1.0,1.0);
				
				color =  (cA*LeftEyecolor) + (cB*RightEyecolor);			
			}
			else
			{
								
			float red = -0.062 * cA.r -0.158 * cA.g -0.039 * cA.b
					+ 0.529 * cB.r + 0.705 * cB.g + 0.024 * cB.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = 0.284 * cA.r + 0.668 * cA.g + 0.143 * cA.b 
						- 0.016 * cB.r - 0.015 * cB.g + 0.065 * cB.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.015 * cA.r -0.027 * cA.g + 0.021 * cA.b 
						+ 0.009 * cB.r + 0.075 * cB.g + 0.937  * cB.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
					
			color = float4(red, green, blue, 0);
			}
		}
	}
		else
	{		
			float4 Top = TexCoords.x < 0.5 ? Lum(float2(TexCoords.x*2,TexCoords.y*2)).xxxx : tex2Dlod(SamplerDM,float4(TexCoords.x*2-1 , TexCoords.y*2,0,0)).xxxx;
			float4 Bottom = TexCoords.x < 0.5 ?  AutoDepthRange(tex2Dlod(SamplerDM,float4(TexCoords.x*2 , TexCoords.y*2-1,0,0)).x,TexCoords) : tex2Dlod(SamplerDis,float4(TexCoords.x*2-1,TexCoords.y*2-1,0,0)).xxxx;
			color = TexCoords.y < 0.5 ? Top : Bottom;
	}
	float Average_Lum = TexCoords.y < 0.5 ? 0.5 : tex2D(SamplerDM,float2(TexCoords.x,TexCoords.y)).g;
	return float4(color.rgb,Average_Lum);
}

float4 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float3 Average_Lum = tex2D(SamplerDM,float2(texcoord.x,texcoord.y)).ggg;
	return float4(Average_Lum,1);
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = float4(PS_calcLR(texcoord).rgb,1),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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

technique Cross_Cursor
{			
			pass Cursor
		{
			VertexShader = PostProcessVS;
			PixelShader = MouseCursor;
		}	
}

technique SuperDepth3D
{
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texDM;
	}
		pass Disocclusion
	{
		VertexShader = PostProcessVS;
		PixelShader = Disocclusion;
		RenderTarget = texDis;
	}
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLum;
	}
		pass StereoOut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
}