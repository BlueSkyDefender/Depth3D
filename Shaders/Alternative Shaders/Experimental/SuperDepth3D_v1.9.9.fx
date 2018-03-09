 ////------------- --//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.9          																														*//
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
 //*																																												*//
 //* Original work was based on the shader code of a CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology								*//
 //*																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The resolution of the Depth Map. For 4k Use 1.75 or 1.5. For 1440p Use 1.5 or 1.25. For 1080p use 1. Too low of a resolution will remove too much.
#define Depth_Map_Division 1.0

// Determines The Max Depth amount.
#define Depth_Max 50

// Enable this to fix the problem when there is a full screen Game Map Poping out of the screen. AKA Full Black Depth Map Fix. I have this off by default. Zero is off, One is On.
#define FBDMF 0

// BOTW Fix WIP....
#define AADM 0

// Change the Cancel Depth Key
// Determines the Cancel Depth Toggle Key useing keycode info
// You can use http://keycode.info/ to figure out what key is what.
// key "." is Key Code 110. Ex. Key 110 is the code for Decimal Point.
#define Cancel_Depth_Key 0

//Horizontal & Vertical Depth Buffer Resize for non conforming BackBuffer.
//Min value is -0.5 & Max value is 0.5 Default is Zero.
//Ex. Resident Evil 7 Has this problem. So you want to adjust it too around -0.0425.
#define Horizontal_and_Vertical 0.0

//Image resizing and BackBuffer fill for Lightberry like systems.
//Do Not Enable This Toggle if you are using Polynomial Barrel Distortion for HMDs.
//Default 0 Off. 1 is Resize mode. 2 is Lightberry Resize Mode.
#define Image_Resize_Modes 0

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = " 0 Normal\0 1 Normal Reversed\0 2 Offset Normal\0 3 Offset Reversed\0";
	ui_label = "Depth Map Selection";
	ui_tooltip = "linearization for the zBuffer also Depth Map One to Four.\n"
			    "Normally you want to use 1 or 2.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 0.250; ui_max = 100.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map for your games.";
> = 7.5;

uniform float Offsets <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset is for the Special Depth Map Only";
> = 0.5;

uniform float Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = Depth_Max;
	ui_label = "Divergence Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.\n" 
				 "You can override this value.";
> = 35.0;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.500;
	ui_label = "Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect.\n"
				"For FPS Games this should be around 0.005-0.075.\n"
				"Also Controlls Auto ZPD power level.\n"
				"Default is 0.010, Zero is off.";
> = 0.010;

uniform int Auto_ZPD <
	ui_type = "combo";
	ui_items = "Off\0Inverted\0Normal\0Inverted Half\0Normal Half\0";
	ui_label = "Auto Zero Parallax Distance Power";
	ui_tooltip = "Auto Zero Parallax Distance Power controls the focus distance for the screen Pop-out effect automatically.\n"
				"Inverted, is if your cam is close to a object you will have less Pop-out.\n"
				"Normal, is if your cam is close to a object you will have more Pop-out.\n"
				"Power of this effect is based off ZPD setting above.\n"
				"Default is Off.";
> = 0;

uniform int Balance <
	ui_type = "drag";
	ui_min = -4.0; ui_max = 6.0;
	ui_label = "Balance";
	ui_tooltip = "Balance between ZPD Depth and Scene Depth and works with ZPD option above.\n"
				"Example Zero is 50/50 equal between ZPD Depth and Scene Depth.\n"
				"Default is Zero.";
> = 0;

uniform int Disocclusion_Adjust <
	ui_type = "combo";
	ui_items = "Off\0Radial Mask\0Normal Mask\0Depth Based\0Radial Depth Mask\0Normal Depth Mask\0Radial Mask X2\0Normal Mask X2\0Depth Based X2\0Radial Depth Mask X2\0Normal Depth Mask X2\0";
	ui_label = "Disocclusion Mask";
	ui_tooltip = "Automatic occlusion masking options.\n"
				"Default is Normal Mask.";
> = 2;

uniform float Disocclusion_Power_Adjust <
	ui_type = "drag";
	ui_min = 0.250; ui_max = 2.5;
	ui_label = "Disocclusion Power Adjust";
	ui_tooltip = "Automatic occlusion masking power adjust.\n"
				"Default is 1.0";
> = 1.0;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map.";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform int WDM <
	ui_type = "combo";
	ui_items = "Weapon DM Off\0Custom WDM\0 WDM 0\0 WDM 1\0 WDM 2\0 WDM 3\0 WDM 4\0 WDM 5\0 WDM 6\0 WDM 7\0 WDM 8\0 WDM 9\0 WDM 10\0 WDM 11\0 WDM 12\0 WDM 13\0 WDM 14\0 WDM 15\0 WDM 16\0 WDM 17\0 WDM 18\0 WDM 19\0 WDM 20\0 WDM 21\0 WDM 22\0 WDM 23\0 WDM 24\0 WDM 25\0 WDM 26\0 WDM 27\0 WDM 28\0 WDM 29\0 WDM 30\0 HUD Mode One\0";
	ui_label = "Weapon Depth Map";
	ui_tooltip = "Pick your weapon depth map for games.";
> = 0;

uniform float4 Weapon_Adjust <
	ui_type = "drag";
	ui_min = -100.0; ui_max = 100.0;
	ui_label = "Weapon Adjust Depth Map";
	ui_tooltip = "Adjust weapon depth map for FPS Hand & also HUD Mode.\n"
				 "X, is FPS Hand Scale Adjustment & Adjusts HUD Mode.\n"
				 "Y, is Cutoff Point Adjustment.\n"
				 "Z, Zero is Auto.\n"
				 "W, is Weapon Depth Adjustment.\n"
				 "Pushes or Pulls the FPS Hand in or out of the screen.\n"
				 "This also used to fine tune the Weapon Hand.\n" 
				 "Default is (X 0.250, Y 0.0, Z 0.0, W 0.0).";
> = float4(0.0,0.250,0.0,0.0);

uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Anaglyph\0";
	ui_label = "3D Display Mode";
	ui_tooltip = "Stereoscopic 3D display output selection.";
> = 0;

uniform int Scaling_Support <
	ui_type = "combo";
	ui_items = " 2160p\0 Native\0 1080p A\0 1080p B\0 1050p A\0 1050p B\0 720p A\0 720p B\0";
	ui_label = "Scaling Support";
	ui_tooltip = "Dynamic Super Resolution , Virtual Super Resolution, downscaling, or Upscaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.";
> = 1;

uniform int Anaglyph_Colors <
	ui_type = "combo";
	ui_items = "Red/Cyan\0Dubois Red/Cyan\0Green/Magenta\0Dubois Green/Magenta\0";
	ui_label = "Anaglyph Color Mode";
	ui_tooltip = "Select colors for your 3D anaglyph glasses.";
> = 0;

uniform float Anaglyph_Desaturation <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Anaglyph Desaturation";
	ui_tooltip = "Adjust anaglyph desaturation, Zero is Black & White, One is full color.";
> = 1.0;

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "View Mode Normal\0View Mode Alpha\0View Mode Beta\0View Mode Gamma\0";
	ui_label = "View Mode";
	ui_tooltip = "Change the way the shader warps the output to the screen.\n"
				 "Default is Normal";
> = 0;

uniform float Auto_Depth_Range <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = "Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n" 
				 "This is still WIP";
> = 0.0;

uniform bool Eye_Swap <
	ui_label = "Swap Eyes";
	ui_tooltip = "L/R to R/L.";
> = false;

uniform float4 Cross_Cursor_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 255.0;
	ui_label = "Cross Cursor Adjust";
	ui_tooltip = "Pick your own cross cursor color & Size.\n" 
				 " Default is (R 255, G 255, B 255 , Size 25)";
> = float4(255.0, 255.0, 255.0, 25.0);

#if Image_Resize_Modes == 1

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Edges selection for your screen output.";
> = 1;

uniform float Resize <
	ui_type = "drag";
	ui_min = -0.250; ui_max = 0.250;
	ui_label = "Image Resizer";
	ui_tooltip = "Use this to resize your image for your screen.\n" 
				 "Default is Zero";
> = 0.0;

#elif Image_Resize_Modes == 2

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges BF\0Black Edges BF\0Stretched Edges BF\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Edges selection for your screen output with and with out Backfill.";
> = 1;

uniform int Resize_Mode <
	ui_type = "combo";
	ui_items = "Mode One\0Mode Two\0";
	ui_label = "Resize Mode";
	ui_tooltip = "Image resizing modes for TnB or SbS.";
> = 0;

uniform float Resize <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.140;
	ui_label = "Image Resizer";
	ui_tooltip = "Use this to resize your image for your screen.\n" 
				 "Default is Zero";
> = 0.0;

uniform int Blur_Spread <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 16.0;
	ui_label = "Blur Spread Ammount";
	ui_tooltip = "Used to adjust Blur Spread Ammount.\n"
				 "Default is 4.0";
> = 4.0;

uniform int BackBuffer_Resolution <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 8.0;
	ui_label = "BackBuffer Image Resolution";
	ui_tooltip = "Use this to adjust BackBuffer Resolution.\n"
				 "Default is 2.0";
> = 2.0;

#else

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Edges selection for your screen output.";
> = 1;

#endif

uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; >;
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
	
#if Image_Resize_Modes == 2
	
texture texBBHalf {Width = BUFFER_WIDTH; Height = BUFFER_WIDTH; Format = RGBA8; MipLevels = 8;}; 
																				
sampler SamplerBBH																
	{
		Texture = texBBHalf;

	};
	
#endif
uniform float2 Mousecoords < source = "mousepoint"; > ;	
////////////////////////////////////////////////////////////////////////////////////Cross Cursor////////////////////////////////////////////////////////////////////////////////////	
float4 MouseCursor(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float2 MousecoordsXY = Mousecoords*pix;
	float CC_Size = Cross_Cursor_Adjust.a * pix.x;
	float4 Mpointer = all(abs(texcoord - MousecoordsXY) < CC_Size) * (1 - all(abs(texcoord - MousecoordsXY) > CC_Size/(Cross_Cursor_Adjust.a*0.5))) ? float4(Cross_Cursor_Adjust.rgb/255, 1.0) : tex2D(BackBuffer, texcoord);//cross
	
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
	
texture texLumWeapon {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256*0.5 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumWeapon																
	{
		Texture = texLumWeapon;
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
	
		float LumWeapon(in float2 texcoord : TEXCOORD0)
	{
		float Luminance = tex2Dlod(SamplerLumWeapon,float4(texcoord,0,0)).r; //Average Luminance Texture Sample 

		return Luminance;
	}
	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

float Depth(in float2 texcoord : TEXCOORD0)
{
		float2 HV = float2(Horizontal_and_Vertical+1.0,Horizontal_and_Vertical+1.0);	
		float midV = (HV.y-1)*(BUFFER_HEIGHT*0.5)*pix.y;		
		float midH = (HV.x-1)*(BUFFER_WIDTH*0.5)*pix.x;			
		texcoord = float2((texcoord.x*HV.x)-midH,(texcoord.y*HV.y)-midV);	
		
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float Far = 1; //Far Adjustment

		//Raw Z Offset
		float Z = min(1,pow(abs(exp(zBuffer)*Offsets),2));
		float ZR = min(1,pow(abs(exp(zBuffer)*Offsets),50));
		
		//0. Normal
		float Normal = Far * Near / (Far + zBuffer * (Near - Far));
		
		//1. Reverse
		float NormalReverse = Far * Near / (Near + zBuffer * (Far - Near));
		
		//2. Offset Normal
		float OffsetNormal = Far * Near / (Far + Z * (Near - Far));
		
		//3. Offset Reverse
		float OffsetReverse = Far * Near / (Near + ZR * (Far - Near));
		
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
		
	return DM;	
}

float2 WeaponDepth(in float2 texcoord : TEXCOORD0)
{
		float2 HV = float2(Horizontal_and_Vertical+1.0,Horizontal_and_Vertical+1.0);
		float midV = (HV.y-1)*(BUFFER_HEIGHT*0.5)*pix.y;		
		float midH = (HV.x-1)*(BUFFER_WIDTH*0.5)*pix.x;			
		texcoord = float2((texcoord.x*HV.x)-midH,(texcoord.y*HV.y)-midV);
		
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBufferWH = tex2D(DepthBuffer, texcoord).r; //Weapon Hand Depth Buffer
		//Weapon Depth Map
		//FPS Hand Depth Maps require more precision at smaller scales to work
		float constantF = 1.0;	
		float constantN = 0.01;
		
		zBufferWH = constantF * constantN / (constantF + zBufferWH * (constantN - constantF));
 		
		//Set Weapon Depth Map settings for the section below.//
		float WA_X; //Weapon_Adjust.x
		float WA_Y; //Weapon_Adjust.y
		float CoP; //Weapon_Adjust.z
		
		if (WDM == 1)
		{
			WA_X = Weapon_Adjust.x;
			WA_Y = Weapon_Adjust.y;
		}
		
		//WDM 0 ; Unreal Gold with v227
		else if(WDM == 2)
		{
			WA_X = 2.855;
			WA_Y = 0.1375;
			CoP = 0.335;
		}
		
		//WDM 1 ; DOOM 2016
		else if(WDM == 3)
		{
			WA_X = 2.775;
			WA_Y = 0.666;
			CoP = 0.2775;
		}
		
		//WDM 2 ; Amnesia Games
		else if(WDM == 4)
		{
			WA_X = 100.0;
			WA_Y = 75.0;
			CoP = 8.0;
		}
		
		//WDM 3 ; BorderLands 2
		else if(WDM == 5)
		{
			WA_X = 2.855;
			WA_Y = 1.0;
			CoP = 0.300;
		}
		
		//WDM 4 ; CoD:AW
		else if(WDM == 6)
		{
			WA_X = 98.0;
			WA_Y = -0.3625;
			CoP = 0.300;
		}
		
		//WDM 5 ; CoD: Black Ops
		else if(WDM == 7)
		{
			WA_X = 2.53945;
			WA_Y = 0.0125;
			CoP = 0.300;
		}
		
		//WDM 6 ; CoD: Black Ops
		else if(WDM == 8)
		{
			WA_X = 5.0;
			WA_Y = 15.625;
			CoP = 0.455;
		}
		
		//WDM 7 ; Wolfenstine: The New Order
		else if(WDM == 9)
		{
			WA_X = 5.500;
			WA_Y = 1.550;
			CoP = 0.550;
		}
		
		//WDM 8 ; Fallout 4
		else if(WDM == 10)
		{
			WA_X = 2.5275;
			WA_Y = 0.0875;
			CoP = 0.255;
		}
		
		//WDM 9 ; Prey 2017 High and <
		else if(WDM == 11)
		{
			WA_X = 19.700;
			WA_Y = -2.600;
			CoP = 0.285;
		}

		//WDM 10 ; Prey 2017 Very High
		else if(WDM == 12)
		{
			WA_X = 28.450;
			WA_Y = -2.600;
			CoP = 0.285;
		}
		
		//WDM 11 ; Metro Redux Games
		else if(WDM == 13)
		{
			WA_X = 2.61375;
			WA_Y = 1.0;
			CoP = 0.260;
		}
		
		//WDM 12 ; NecroVisioN: Lost Company
		else if(WDM == 14)
		{
			WA_X = 5.1375;
			WA_Y = 7.5;
			CoP = 0.485;
		}
		
		//WDM 13 ; Kingpin Life of Crime
		else if(WDM == 15)
		{
			WA_X = 3.925;
			WA_Y = 17.5;
			CoP = 0.400;
		}
	
		//WDM 14 ; Rage64
		else if(WDM == 16)
		{
			WA_X = 5.45;
			WA_Y = 1.0;
			CoP = 0.550;
		}	
		
		//WDM 15 ; Quake DarkPlaces
		else if(WDM == 17)
		{
			WA_X = 2.685;
			WA_Y = 1.0;
			CoP = 0.375;
		}	

		//WDM 16 ; Quake 2 XP
		else if(WDM == 18)
		{
			WA_X = 3.925;
			WA_Y = 16.25;
			CoP = 0.400;
		}
		
		//WDM 17 ; Quake 4
		else if(WDM == 19)
		{
			WA_X = 5.000000;
			WA_Y = 7.0;
			CoP = 0.500;
		}

		//WDM 18 ; RTCW
		else if(WDM == 20)
		{
			WA_X = 3.6875;
			WA_Y = 7.250;
			CoP = 0.400;
		}
	
		//WDM 19 ; S.T.A.L.K.E.R: Games
		else if(WDM == 21)
		{
			WA_X = 2.55925;
			WA_Y = 0.75;
			CoP = 0.255;
		}
		
		//WDM 20 ; Soma
		else if(WDM == 22)
		{
			WA_X = 16.250;
			WA_Y = 87.50;
			CoP = 0.825;
		}
		
		//WDM 21 ; Skyrim: SE
		else if(WDM == 23)
		{
			WA_X = 2.775;
			WA_Y = 1.125;
			CoP = 0.278;
		}
		
		//WDM 22 ; Turok: DH 2017
		else if(WDM == 24)
		{
			WA_X = 2.553125;
			WA_Y = 1.0;
			CoP = 0.500;
		}

		//WDM 23 ; Turok2: SoE 2017
		else if(WDM == 25)
		{
			WA_X = 140.0;
			WA_Y = 500.0;
			CoP = 5.0;
		}
		
		//WDM 24 ; Dying Light
		else if(WDM == 26)
		{
			WA_X = 2.000;
			WA_Y = -40.0;
			CoP = 2.0;
		}
		
		//WDM 25 ; EuroTruckSim2
		else if(WDM == 27)
		{
			WA_X = 2.800;
			WA_Y = 1.0;
			CoP = 0.280;
		}
		
		//WDM 26 ; Prey - 2006
		else if(WDM == 28)
		{
			WA_X = 5.000;
			WA_Y = 2.875;
			CoP = 0.500;
		}
		
		//WDM 27 ; TitanFall 2
		else if(WDM == 29)
		{
			WA_X = 2.77575;
			WA_Y = 0.3625;
			CoP = 0.3625;
		}
		
		//WDM 28 ; Bioshock Remastred
		else if(WDM == 30)
		{
			WA_X = 2.52475;
			WA_Y = 0.05625;
			CoP = 0.260;
		}
								
		//SWDMS Done//
 		
 		//TEXT MODE 31 Adjust
		else if(WDM == 33) //Text mode one.
		{
			WA_X = Weapon_Adjust.x;
			WA_Y = 100;
			CoP = 0.252;
		}
 		
		//Scaled Section z-Buffer
		
		if(WDM >= 1)
		{
			WA_X *= 0.004;
			WA_Y *= 0.004;
			zBufferWH = WA_Y*zBufferWH/(WA_X-zBufferWH);
		
			if(WDM == 24)
			zBufferWH += 1;
		}
		
		float Adj = Weapon_Adjust.w*0.00266666; //Push & pull weapon in or out of screen. Weapon_Depth Adjustment
		zBufferWH = smoothstep(Adj,1,zBufferWH) ;//Weapon Adjust smoothstep range from Adj-1
		
		//Auto Anti Weapon Depth Map Z-Fighting is always on.
		
		float WeaponLumAdjust = abs(smoothstep(0,0.5,LumWeapon(texcoord)*2.5)) * zBufferWH;	
			
		if( WDM == 1 || WDM == 22 || WDM == 24 || WDM == 27 || WDM == 33 )//WDM Adjust,SOMA, EuroTruckSim2, and HUD mode.
		{
			zBufferWH = zBufferWH;
		}
		else
		{
			zBufferWH = lerp(saturate(WeaponLumAdjust),zBufferWH,0.025);
		}
		
		if(Weapon_Adjust.z <= 0) //Zero Is auto
		{
			CoP = CoP;
		}
		else	
		{
			CoP = Weapon_Adjust.z;
		}
		
	return float2(saturate(zBufferWH.r),CoP);
}

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0)
{
		float N, R, G, B, D, LDM, RDM, Cutoff, A = 1;
		
		float2 DM = Depth(texcoord);
		
		float WD = lerp(WeaponDepth(texcoord).x,1,0.0175);
		
		float CoP = WeaponDepth(texcoord).y; //Weapon Cutoff Point
				
		float CutOFFCal = (CoP/Depth_Map_Adjust)/2; //Weapon Cutoff Calculation
		
		Cutoff = step(lerp(DM.x,DM.y,0.5),CutOFFCal);
				
		if (WDM == 0)
		{
			LDM = DM.x;
			RDM = DM.y;
		}
		else
		{
			LDM = lerp(DM.x,WD,Cutoff);
			RDM = lerp(DM.y,WD,Cutoff);
		}
		
		R = LDM;
		G = Depth(texcoord); //AverageLuminance
		B = RDM;
		
	Color = float4(R,G,B,A);
}

float AutoDepthRange( float d, float2 texcoord )
{
	float ADR_Scale = Auto_Depth_Range;
	float LumAdjust = smoothstep(-0.0175,ADR_Scale,Lum(texcoord));
    return min(1,( d - 0 ) / ( LumAdjust - 0));
}

float Conv(float D,float2 texcoord)
{
	float Z, ZP, Con = ZPD, NF_Power, MS = Divergence * pix.x;
						
		//Average Luminance Auto ZDP Start
		float Luminance, LClamp = smoothstep(0,1,Lum(texcoord)); //Average Luminance Texture Sample 
		
		if (Auto_ZPD == 1)
		{
			Luminance = smoothstep(0.01,1,Lum(texcoord)*Con);		
		}
		else if (Auto_ZPD == 2)
		{
			Luminance = smoothstep(0.01,1,Con-(Lum(texcoord)*Con));
		}
		else if (Auto_ZPD == 3)
		{
			Luminance =  smoothstep(0.01,0.5,Lum(texcoord)*Con);	
		}
		else if (Auto_ZPD == 4)
		{
			Luminance =  smoothstep(0.01,0.5,Con-(Lum(texcoord)*Con));
		}	
		else
		{
			Luminance = 0;
		}
		
		float AL = abs(Luminance),ALC = abs(LClamp),ZPDC;
			
		if (ALC <= 0.00005 && FBDMF) //Full Black Depth Map Fix.
		{
			AL = 0;
			ZPDC = 0; 
		}
		else
		{
			AL = AL; //Auto ZDP based on the Auto Anti Weapon Depth Map Z-Fighting code.
			ZPDC = Con; 
		}	
		
		//Using the Luminace to control what happens when really close to link.... May be phased out soon.	
		if (AADM)
		{
			if (ALC >= 0.01)
			{
				AL = AL*0.8;
			}
			if (ALC >= 0.125)
			{
				AL = AL;
			}
			if (ALC >= 0.250)
			{
				AL = AL*1.33333333;
			}
			if (ALC >= 0.3125)
			{
				AL = AL*2.0;
			}
			if (ALC >= 0.375)
			{
				AL = AL*1.33333333;
			}
			if (ALC >= 0.450)
			{
				AL = AL;
			}
			if (ALC >= 0.500)
			{
				AL = AL*0.8;
			}
			else if (ALC < 0.01)
			{
				AL = AL*0.57142857;
			}	
		}
		
		if(Auto_ZPD >= 1)
		{
			Z = AL; //Auto ZDP based on the Auto Anti Weapon Depth Map Z-Fighting code.
		}
		else
		{
			Z = ZPDC;
		}
		//Average Luminance Auto ZDP End
		if(Balance == -4)
		{
			NF_Power = 0.125;
		}		
		if(Balance == -3)
		{
			NF_Power = 0.250;
		}
		if(Balance == -2)
		{
			NF_Power = 0.375;
		}
		else if(Balance == -1)
		{
			NF_Power = 0.425;
		}
		else if(Balance == 0)
		{
			NF_Power = 0.5;
		}
		else if(Balance == 1)
		{
			NF_Power = 0.5625;
		}
		else if(Balance == 2)
		{
			NF_Power = 0.625;
		}
		else if(Balance == 3)
		{
			NF_Power = 0.6875;
		}
		else if(Balance == 4)
		{
			NF_Power = 0.75;
		}
		else if(Balance == 5)
		{
			NF_Power = 0.8125;
		}
		else if(Balance == 6)
		{
			NF_Power = 0.875;
		}
		
		if(ZPD == 0)
		{
			ZP = 1.0;
		}
		else
		{
			ZP = NF_Power;
		}
		
		// You need to readjust the Z-Buffer if your going to use use the Convergence equation. You can do it this way or Use Convergence/1-(-ZPD)
		float DM = ( D - 0 ) / ( (1-Z) - 0);
		float Convergence = 1 - Z / DM;
	 
		if (Auto_Depth_Range > 0)
		{
			D = AutoDepthRange(D,texcoord);
		}
		
		Z = lerp(MS * Convergence,MS * D,ZP);
			
    return Z;
}

void  Disocclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
float X, Y, A, B, DP =  Divergence, Disocclusion_PowerA, Disocclusion_PowerB , DBD = tex2Dlod(SamplerDM,float4(texcoord,0,0)).r , AMoffset = 0.008, BMoffset = 0.00285714, CMoffset = 0.09090909, DMoffset = 0.05882352;
float2 DM, DMA, DMB, dirA, dirB;

//DBD Adjustment Start
DBD = (DBD - 0.025)/(1 - 0.025); 
DBD = DBD*DBD*(3 - 2*DBD);
DBD = ( DBD - 1.0f ) / ( -187.5f - 1.0f );
//DBD Adjustment End

	DP *= Disocclusion_Power_Adjust;
		
	if ( Disocclusion_Adjust == 1 || Disocclusion_Adjust == 4 || Disocclusion_Adjust == 6 || Disocclusion_Adjust == 9 ) // Radial    
	{
		Disocclusion_PowerA = DP*AMoffset;
	}
	else if ( Disocclusion_Adjust == 2 || Disocclusion_Adjust == 5 || Disocclusion_Adjust == 7 || Disocclusion_Adjust == 10 ) // Normal  
	{
		Disocclusion_PowerA = DP*BMoffset;
	}
	else if ( Disocclusion_Adjust == 3 || Disocclusion_Adjust == 8 ) // Depth    
	{
		Disocclusion_PowerA = DBD*DP;
	}
		
	// Mix Depth Start	
	if ( Disocclusion_Adjust == 4 || Disocclusion_Adjust == 5 || Disocclusion_Adjust == 9 || Disocclusion_Adjust == 10 ) //Depth    
	{
		Disocclusion_PowerB = DBD*DP;
	}
	// Mix Depth End
	
	if (Disocclusion_Adjust >= 1) 
	{
		const float weightA[11] = {0.0,0.010,-0.010,0.020,-0.020,0.030,-0.030,0.040,-0.040,0.050,-0.050}; //By 10
		const float weightB[17] = {0.0,0.005,-0.005,0.010,-0.010,0.015,-0.015,0.020,-0.020,0.025,-0.025,0.030,-0.030,0.035,-0.035,0.040,-0.040}; //By 5
		
		if( Disocclusion_Adjust == 1 || Disocclusion_Adjust == 6)
		{
			dirA = 0.5 - texcoord;
			dirB = 0.5 - texcoord;
			A = Disocclusion_PowerA;
			B = Disocclusion_PowerB;
		}
		else if ( Disocclusion_Adjust == 2 || Disocclusion_Adjust == 3 || Disocclusion_Adjust == 7 || Disocclusion_Adjust == 8 || Disocclusion_Adjust == 5 || Disocclusion_Adjust == 10 )
		{
			dirA = float2(0.5,0.0);
			dirB = float2(0.5,0.0);
			A = Disocclusion_PowerA;
			B = Disocclusion_PowerB;
		}
		else if(Disocclusion_Adjust == 4 || Disocclusion_Adjust == 9)
		{
			dirA = 0.5 - texcoord;
			dirB = float2(0.5,0.0);
			A = Disocclusion_PowerA;
			B = Disocclusion_PowerB;
		}
		
		
		if ( Disocclusion_Adjust == 1 || Disocclusion_Adjust == 2 || Disocclusion_Adjust == 3 || Disocclusion_Adjust == 4 || Disocclusion_Adjust == 5 )
		{			
				[loop]
				for (int i = 0; i < 11; i++)
				{	
					DM += tex2Dlod(SamplerDM,float4(texcoord + dirA * weightA[i] * A ,0,0)).rb*CMoffset;
					if(Disocclusion_Adjust == 4 || Disocclusion_Adjust == 5)
					{
						DMA += tex2Dlod(SamplerDM,float4(texcoord + dirB * weightA[i] * B ,0,0)).rb*CMoffset;
					}
				}
		}
		
		if ( Disocclusion_Adjust == 6 || Disocclusion_Adjust == 7 || Disocclusion_Adjust == 8 || Disocclusion_Adjust == 9 || Disocclusion_Adjust == 10 )
		{	
				A *= 1.250;
				B *= 1.250;
				[loop]
				for (int i = 0; i < 17; i++)
				{	
					DM += tex2Dlod(SamplerDM,float4(texcoord + dirA * weightB[i] * A ,0,0)).rb*DMoffset;
					if( Disocclusion_Adjust == 9 || Disocclusion_Adjust == 10 )
					{
						DMB += tex2Dlod(SamplerDM,float4(texcoord + dirB * weightB[i] * B ,0,0)).rb*DMoffset;
					}
				}
		}
		
		if ( Disocclusion_Adjust == 4 || Disocclusion_Adjust == 5 )
		{	
			DM = lerp(DM,DMA,0.5);
		}
		
		if ( Disocclusion_Adjust == 9 || Disocclusion_Adjust == 10 )
		{	
			DM = lerp(DM,DMB,0.5);
		}
	
	}
	else
	{
		DM = tex2Dlod(SamplerDM,float4(texcoord,0,0)).rb;
	}

	if (!Cancel_Depth)
	{
		X = DM.x;
		Y = DM.y;
	}
	else
	{
		X = 0.5;
		Y = 0.5;
	}
		
	color = float4(X,DM.x,Y,1);
}

#if Image_Resize_Modes == 2
float4 BBHalf(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return tex2D(BackBuffer,texcoord);
}

float4 BackBufferBlur(in float2 texcoord : TEXCOORD0)
{
	float2 samples[10] = {
	float2(-0.326212, -0.405805),  
	float2(-0.840144, -0.073580),  
	float2(-0.695914, 0.457137),  
	float2(-0.203345, 0.620716),  
	float2(0.962340, -0.194983),  
	float2(0.473434, -0.480026),  
	float2(0.519456, 0.767022),  
	float2(0.185461, -0.893124),  
	float2(0.507431, 0.064425),  
	float2(0.896420, 0.412458),   
	};  
 
	float4 sum = tex2Dlod(SamplerBBH,float4(texcoord,0,BackBuffer_Resolution));  
	float Adjust = (Blur_Spread*6)*pix.x;
	for (int i = 0; i < 10; i++)
	{  
		sum += tex2Dlod(SamplerBBH, float4(texcoord + Adjust * samples[i],0,BackBuffer_Resolution));  
	} 
	
	sum *= 0.09090909f;

return sum;
}
#endif
/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
float4 PS_calcLR(in float2 texcoord : TEXCOORD0)
{
	float2 TCL, TCR, TexCoords = texcoord;
	float4 color, Right, Left, cR, cL;
	float DepthR = 1, DepthL = 1, ConAlt, MS, P, N, S, L, R;
	float samplesA[3] = {0.5,0.75,1.0};
	float samplesB[5] = {0.5,0.625,0.75,0.875,1.0};
	float samplesC[17] = {0.5,0.53125,0.5625,0.59375,0.625,0.63125,0.6875,0.71875,0.75,0.78125,0.8125,0.84375,0.875,0.90625,0.9375,0.96875,1.0};
	
	//MS is Max Separation P is Perspective Adjustment
	P = Perspective * pix.x;
	MS = Divergence * pix.x;
	
	//Horizontal and Vertical stretch or squish
	#if Image_Resize_Modes == 1
		float4 BB = 0;	
		float2 HV = float2(Resize+1,Resize+1);
		float midV = (HV.y-1)*(BUFFER_HEIGHT*0.5)*pix.y;		
		float midH = (HV.x-1)*(BUFFER_WIDTH*0.5)*pix.x;			
		texcoord = float2((texcoord.x*HV.x)-midH,(texcoord.y*HV.y)-midV);		
	#elif Image_Resize_Modes == 2
		float4 BB = BackBufferBlur(texcoord);
		float2 HV;
		float midH, midV;
		if ( Stereoscopic_Mode == 0 && Resize_Mode == 0 )
		{
			HV = float2(0,(Resize*2)+1);
			midV = (HV.y-1)*(BUFFER_HEIGHT*0.5)*pix.y;
			midH = 0;
			texcoord = float2(texcoord.x,(texcoord.y*HV.y)-midV);
		}
		else if( Stereoscopic_Mode == 1 && Resize_Mode == 0 )
		{
			HV = float2(Resize+1,0);
			midV = 0;
			midH = (HV.x-1)*(BUFFER_WIDTH*0.5)*pix.x;
			texcoord = float2((texcoord.x*HV.x)-midH,texcoord.y);
		}
		else
		{
			HV = float2(Resize+1,(Resize*2)+1);
			midV = (HV.y-1)*(BUFFER_HEIGHT*0.5)*pix.y;
			midH = (HV.x-1)*(BUFFER_WIDTH*0.5)*pix.x;
			texcoord = float2((texcoord.x*HV.x)-midH,(texcoord.y*HV.y)-midV);
		}
	#else
		float4 BB = 0;
		float midH = 0;		
		float midV = 0;	
	#endif
				
		if(Eye_Swap)
		{
			if ( Stereoscopic_Mode == 0 )
			{
				TCL.x = (texcoord.x*2-1) - P - midH;
				TCR.x = (texcoord.x*2) + P + midH;
				TCL.y = texcoord.y;
				TCR.y = texcoord.y;
			}
			else if( Stereoscopic_Mode == 1 )
			{
				TCL.x = texcoord.x - P;
				TCR.x = texcoord.x + P;
				TCL.y = (texcoord.y*2-1) - midV;
				TCR.y = (texcoord.y*2) + midV;
			}
			else
			{
				TCL.x = texcoord.x - P;
				TCR.x = texcoord.x + P;
				TCL.y = texcoord.y;
				TCR.y = texcoord.y;
			}
		}	
		else
		{
			if (Stereoscopic_Mode == 0)
			{
				TCR.x = (texcoord.x*2-1) - P - midH;
				TCL.x = (texcoord.x*2) + P + midH;
				TCR.y = texcoord.y;
				TCL.y = texcoord.y;
			}
			else if(Stereoscopic_Mode == 1)
			{
				TCR.x = texcoord.x - P;
				TCL.x = texcoord.x + P;
				TCR.y = (texcoord.y*2-1) - midV;
				TCL.y = (texcoord.y*2) + midV;
			}
			else
			{
				TCR.x = texcoord.x - P;
				TCL.x = texcoord.x + P;
				TCR.y = texcoord.y;
				TCL.y = texcoord.y;
			}
		}
		
		if(Stereoscopic_Mode == 7)
		{
			DepthL = 0;
			DepthR = 0;
		}
		else
		{	
			if (View_Mode == 0)
				N = 3;
			else if (View_Mode == 1)
				N = 5;
			else if (View_Mode == 2)
				N = 1.025;
			else if (View_Mode == 3)
				N = 17;
					
			[loop]
			for ( int i = 0 ; i < N; i++ ) 
			{
				if (View_Mode == 0)
				{
					S = samplesA[i] * MS;
					DepthL = min(DepthL,tex2Dlod(SamplerDis,float4(TCL.x+S, TCL.y,0,0)).r);
					DepthR = min(DepthR,tex2Dlod(SamplerDis,float4(TCR.x-S, TCR.y,0,0)).b);
				}
				else if (View_Mode == 1)
				{
					S = samplesB[i] * MS;
					DepthL = min(DepthL,tex2Dlod(SamplerDis,float4(TCL.x+S, TCL.y,0,0)).r);
					DepthR = min(DepthR,tex2Dlod(SamplerDis,float4(TCR.x-S, TCR.y,0,0)).b);
				}
				else if (View_Mode == 2)
				{
					float AMoffset = 0.97560975;
					S = lerp(i*(Divergence*AMoffset), (Divergence*AMoffset),0.5);
					DepthL = min(DepthL,tex2Dlod(SamplerDis,float4(TCL.x+S*pix.x,TCL.y,0,0)).b);
					DepthR = min(DepthR,tex2Dlod(SamplerDis,float4(TCR.x-S*pix.x,TCR.y,0,0)).r);
				}
				else if (View_Mode == 3)
				{
					float BMoffset = 0.05882352;
					S = samplesC[i] * MS * 1.125;
					L += tex2Dlod(SamplerDis,float4(TCL.x+S, TCL.y,0,0)).r*BMoffset;
					R += tex2Dlod(SamplerDis,float4(TCR.x-S, TCR.y,0,0)).b*BMoffset;
					DepthL = saturate(L);
					DepthR = saturate(R);
				}
			}
		}
			DepthR = Conv(DepthR,TexCoords);
			DepthL = Conv(DepthL,TexCoords);
			
		float ReprojectionRight = DepthR; //Zero Parallax Distance controll
		float ReprojectionLeft =  DepthL;
			#if Image_Resize_Modes == 2
				if(Custom_Sidebars == 0)
				{
					if ((TCL.x < 1.0 && TCL.x > 0.0 && TCL.y < 1.0 && TCL.y > 0.0) || (TCR.x < 1.0 && TCR.x > 0.0 && TCR.y < 1.0 && TCR.y > 0.0))
					{
						Left = tex2Dlod(BackBufferMIRROR, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
						Right = tex2Dlod(BackBufferMIRROR, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
					}
					else
					{
						Left = BB;
						Right = BB;
					}
				}
				else if(Custom_Sidebars == 1)
				{
					if ((TCL.x < 1.0 && TCL.x > 0.0 && TCL.y < 1.0 && TCL.y > 0.0) || (TCR.x < 1.0 && TCR.x > 0.0 && TCR.y < 1.0 && TCR.y > 0.0))
					{
						Left = tex2Dlod(BackBufferBORDER, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
						Right = tex2Dlod(BackBufferBORDER, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
					}
					else
					{
						Left = BB;
						Right = BB;
					}
				}
				else
				{
					if ((TCL.x < 1.0 && TCL.x > 0.0 && TCL.y < 1.0 && TCL.y > 0.0) || (TCR.x < 1.0 && TCR.x > 0.0 && TCR.y < 1.0 && TCR.y > 0.0))
					{
						Left = tex2Dlod(BackBufferCLAMP, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
						Right = tex2Dlod(BackBufferCLAMP, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
					}
					else
					{
						Left = BB;
						Right = BB;
					}
				}
			#else
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
			#endif
	
			if ( Eye_Swap )
			{
				cL = Right;
				cR = Left;	
			}
			else
			{
				cL = Left;
				cR = Right;
			}
			
	if(!Depth_Map_View)
	{	
	float2 gridxy;

	if(Scaling_Support == 0)
	{
		gridxy = floor(float2(TexCoords.x*3840.0,TexCoords.y*2160.0));
	}	
	else if(Scaling_Support == 1)
	{
		gridxy = floor(float2(TexCoords.x*BUFFER_WIDTH,TexCoords.y*BUFFER_HEIGHT));
	}
	else if(Scaling_Support == 2)
	{
		gridxy = floor(float2(TexCoords.x*1920.0,TexCoords.y*1080.0));
	}
	else if(Scaling_Support == 3)
	{
		gridxy = floor(float2(TexCoords.x*1921.0,TexCoords.y*1081.0));
	}
	else if(Scaling_Support == 4)
	{
		gridxy = floor(float2(TexCoords.x*1680.0,TexCoords.y*1050.0));
	}
	else if(Scaling_Support == 5)
	{
		gridxy = floor(float2(TexCoords.x*1681.0,TexCoords.y*1051.0));
	}
	else if(Scaling_Support == 6)
	{
		gridxy = floor(float2(TexCoords.x*1280.0,TexCoords.y*720.0));
	}
	else if(Scaling_Support == 7)
	{
		gridxy = floor(float2(TexCoords.x*1281.0,TexCoords.y*721.0));
	}
			
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
			color = int(gridxy.x) & 1 ? cR : cL;		
		}
		else if(Stereoscopic_Mode == 4)
		{
			color = int(gridxy.x+gridxy.y) & 1 ? cR : cL;
		}
		else if(Stereoscopic_Mode == 5)
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
			float4 Top = TexCoords.x < 0.5 ? Lum(float2(TexCoords.x*2,TexCoords.y*2)).xxxx : tex2Dlod(SamplerDM,float4(TexCoords.x*2-1 , TexCoords.y*2,0,0)).rrbb;
			float4 Bottom = TexCoords.x < 0.5 ?  AutoDepthRange(tex2Dlod(SamplerDM,float4(TexCoords.x*2 , TexCoords.y*2-1,0,0)).r,TexCoords) : tex2Dlod(SamplerDis,float4(TexCoords.x*2-1,TexCoords.y*2-1,0,0)).rrrr;
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

float4 Average_Luminance_Weapon(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float3 Average_Lum_Weapon = PS_calcLR(float2(texcoord.x,(texcoord.y + 0.500) * 0.500 + 0.250)).www;
	return float4(Average_Lum_Weapon,1);
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

technique Depth3D
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
			pass AverageLuminanceWeapon
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Luminance_Weapon;
			RenderTarget = texLumWeapon;
		}
		#if Image_Resize_Modes == 2
			pass BB_Blur
		{
			VertexShader = PostProcessVS;
			PixelShader = BBHalf;
			RenderTarget = texBBHalf;
		}
		#endif
			pass StereoOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
	}