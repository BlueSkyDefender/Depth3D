 ////------------- --//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.8          																														*//
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

// Determines The Max Depth amount. The larger the amount harder it will hit on FPS will be.
#define Depth_Max 50

// Enable this to fix the problem when there is a full screen Game Map Poping out of the screen. AKA Full Black Depth Map Fix. I have this off by default. Zero is off, One is On.
#define FBDMF 0

// BOTW Fix WIP
#define AADM 0

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = " 0 Normal\0 1 Normal Reversed-Z\0 3 Offset \0 4 Offset Reversed-Z\0 5 Offset Normal\0";
	ui_label = "Depth Map Selection";
	ui_tooltip = "linearization for the zBuffer also Depth Map One to Four.\n"
			    "Normally you want to use 1 or 2.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 100.0;
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
> = 35;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.375;
	ui_label = "Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect.\n"
				"For FPS Games this should be around 0.005-0.075.\n"
				"Also Controlls Auto ZPD power level.\n"
				"If Pop is ON use a lower value.\n"
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
	ui_min = 0; ui_max = 6;
	ui_label = "Balance";
	ui_tooltip = "Balance between ZPD Depth and Scene Depth and works with ZPD option above.\n"
				"Example Zero is 50/50 equal between ZPD Depth and Scene Depth.\n"
				"One is 62.5/37.5, Three is 75/25, and Five is 87.5/12.5\n"
				"Default is Three.";
> = 3;

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
				"Default is 1.250";
> = 1.250;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0;

uniform int DepthPlus <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 10;
	ui_label = "Depth Plus";
	ui_tooltip = "This is to turn on Depth Plus a depth and pop enhancment toggle.\n" 
				 "Default is 0, Zero is off.";
> = 0.0;

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
	ui_items = "Weapon DM Off\0Custom WDM\0 WDM 0\0 WDM 1\0 WDM 2\0 WDM 3\0 WDM 4\0 WDM 5\0 WDM 6\0 WDM 7\0 WDM 8\0 WDM 9\0 WDM 10\0 WDM 11\0 WDM 12\0 WDM 13\0 WDM 14\0 WDM 15\0 WDM 16\0 WDM 17\0 WDM 18\0 WDM 19\0 WDM 20\0 WDM 21\0 WDM 22\0 WDM 23\0 WDM 24\0 WDM 25\0 HUD Mode One\0";
	ui_label = "Weapon Depth Map";
	ui_tooltip = "Pick your weapon depth map for games.";
> = 0;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 100.0;
	ui_label = "Weapon Adjust Depth Map";
	ui_tooltip = "Adjust weapon depth map for FPS Hand & also HUD Mode.\n"
				 "X, is FPS Hand Scale Adjustment & Adjusts HUD Mode.\n"
				 "Y, is Cutoff Point Adjustment.\n"
				 "Y, Zero is Auto.\n"
				 "Default is (X 0.250, Y 0, Z 0).";
> = float3(0.0,0.250,0.0);

uniform float Weapon_Depth <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Weapon Depth Adjustment";
	ui_tooltip = "Pushes or Pulls the FPS Hand in or out of the screen.\n"
				 "This also used to fine tune the Weapon Hand.\n" 
				 "Default is 0";
> = 0;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Edges selection for your screen output.";
> = 1;

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

uniform bool Auto_Depth_Range <
	ui_label = "Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.";
> = false;

uniform bool Eye_Swap <
	ui_label = "Swap Eyes";
	ui_tooltip = "L/R to R/L.";
> = false;

uniform float Cross_Cursor_Size <
	ui_type = "drag";
	ui_min = 1; ui_max = 100;
	ui_label = "Cross Cursor Size";
	ui_tooltip = "Pick your size of the cross cursor.\n" 
				 "Default is 25";
> = 25.0;

uniform float3 Cross_Cursor_Color <
	ui_type = "color";
	ui_label = "Cross Cursor Color";
	ui_tooltip = "Pick your own cross cursor color.\n" 
				 " Default is (R 255, G 255, B 255)";
> = float3(1.0, 1.0, 1.0);

uniform bool InvertY <
	ui_label = "Invert Y-Axis";
	ui_tooltip = "Invert Y-Axis for the cross cursor.";
> = false;

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
	float4 Mpointer; 
	 
	if (!InvertY)
	{
		Mpointer = all(abs(Mousecoords - position.xy) < Cross_Cursor_Size) * (1 - all(abs(Mousecoords - position.xy) > Cross_Cursor_Size/(Cross_Cursor_Size/2))) ? float4(Cross_Cursor_Color, 1.0) : tex2D(BackBuffer, texcoord);//cross
	}
	else
	{
		Mpointer = all(abs(float2(Mousecoords.x,BUFFER_HEIGHT-Mousecoords.y) - position.xy) < Cross_Cursor_Size) * (1 - all(abs(float2(Mousecoords.x,BUFFER_HEIGHT-Mousecoords.y) - position.xy) > Cross_Cursor_Size/(Cross_Cursor_Size/2))) ? float4(Cross_Cursor_Color, 1.0) : tex2D(BackBuffer, texcoord);//cross
	}
	
	return Mpointer;
}

/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLum {Width = 256/2; Height = 256/2; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLum																
	{
		Texture = texLum;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
texture texLumWeapon {Width = 256/2; Height = 256/2; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
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
		float Luminance = tex2Dlod(SamplerLumWeapon,float4(texcoord,0,0)).g; //Average Luminance Texture Sample 

		return Luminance;
	}
	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

float2 Depth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float Far = 1; //Far Adjustment
		float DA = Depth_Map_Adjust*10; //Depth Map Adjust - Near
		
		//0. Normal
		float Normal = Far * Near / (Far + zBuffer * (Near - Far));
		
		//1. Reverse
		float NormalReverse = Far * Near / (Near + zBuffer * (Far - Near));

		//2. Offset
		float Offset = min(1,pow(abs(exp(zBuffer)*Offsets),DA));
		
		//3. Offset Reverse
		float OffsetReverse = Far * Near / (Near + min(1,pow(abs(exp(zBuffer)*Offsets),1.75)) * (Far - Near));
		
		//4. Offset Normal
		float OffsetNormal = Far * Near / (Far + min(1,pow(abs(exp(zBuffer)*Offsets),1.75)) * (Near - Far));		
		
		float2 DM;
		
		if (Depth_Map == 0)
		{
		DM.x = Normal;
		}		
		else if (Depth_Map == 1)
		{
		DM.x = NormalReverse;
		}
		else if (Depth_Map == 2)
		{
		DM.x = Offset;
		}
		else if (Depth_Map == 3)
		{
		DM.x = OffsetReverse;
		}
		else
		{
		DM.x = OffsetNormal;
		}
		
		if (Depth_Map == 0)
		{
		DM.y = Normal;
		}		
		else if (Depth_Map == 1)
		{
		DM.y = NormalReverse;
		}
		else if (Depth_Map == 2)
		{
		DM.y = Offset;
		}
		else if (Depth_Map == 3)
		{
		DM.y = OffsetReverse;
		}
		else
		{
		DM.y = OffsetNormal;
		}
		
	return float2(DM.x,DM.y);	
}

float2 WeaponDepth(in float2 texcoord : TEXCOORD0)
{
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
			CoP = 0.276;
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
			WA_Y = 0.125;
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

		//TEXT MODE 26 Adjust
		else if(WDM == 28) //Text mode one.
		{
			WA_X = Weapon_Adjust.x;
			WA_Y = 100;
			CoP = 0.252;
		}
		
		//WDM 24 ; Dying Light
		else if(WDM == 26)
		{
			WA_X = 2.000;
			WA_Y = -40.0;
			CoP = 2.0;
		}
						
		//SWDMS Done//
 		
		//Scaled Section z-Buffer
		
		if(WDM >= 1)
		{
			WA_X /= 250;
			WA_Y /= 250;
			zBufferWH = WA_Y*zBufferWH/(WA_X-zBufferWH);
		
			if(WDM == 24)
			zBufferWH += 1;
		}
		
		float Adj = Weapon_Depth/375; //Push & pull weapon in or out of screen.
		zBufferWH = smoothstep(Adj,1,zBufferWH) ;//Weapon Adjust smoothstep range from Adj-1
		
		//Auto Anti Weapon Depth Map Z-Fighting is always on.
		
		float AA,AL = abs(smoothstep(0,1,LumWeapon(texcoord)*2));
		
		if( WDM == 1 || WDM == 22 || WDM == 24 || WDM == 28 )//WDM Adjust,SOMA, and HUD mode.
		{
			zBufferWH = zBufferWH;
		}
		else
		{
			zBufferWH = lerp(zBufferWH*AL,zBufferWH,0.025);
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
		
		float AverageLuminance = Depth(texcoord).x;	
		
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
		G = AverageLuminance;
		B = RDM;
		
	Color = float4(R,G,B,A);
}

void Average_Luminance(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
	float3 Average_Luminance = tex2D(SamplerDM,float2(texcoord.x,texcoord.y)).ggg;
	color = float4(Average_Luminance,1);
}

float Conv(float D,float2 texcoord)
{
	float Z, ZP, Con = ZPD, NF_Power;
						
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
		
		if (AADM)
		{
			if (ALC >= 0.01)
			{
				AL = AL/1.250;
			}
			if (ALC >= 0.125)
			{
				AL = AL/1.0;
			}
			if (ALC >= 0.250)
			{
				AL = AL/0.750;
			}
			if (ALC >= 0.3125)
			{
				AL = AL/0.5;
			}
			if (ALC >= 0.375)
			{
				AL = AL/0.75;
			}
			if (ALC >= 0.450)
			{
				AL = AL/1.0;
			}
			if (ALC >= 0.500)
			{
				AL = AL/1.250;
			}
			else if (ALC < 0.01)
			{
				AL = AL/1.75;
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
		
		if(Balance == 0)
		{
			NF_Power = 0.5;
		}
		else if(Balance == 1)
		{
			NF_Power = 0.625;
		}
		else if(Balance == 2)
		{
			NF_Power = 0.6875;
		}
		else if(Balance == 3)
		{
			NF_Power = 0.75;
		}
		else if(Balance == 4)
		{
			NF_Power = 0.78125;
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
	
		Z = lerp(1-Z/D,D,ZP);
		
    return Z;
}

float SS(float edge0, float edge1, float x)
{
		if(DepthPlus == 1)//ZPD linked
		{
			edge0 /= 2.0;
		}
		else if(DepthPlus == 2)//ZDP linked +
		{
			edge0 /= 2.5;
		}
		else if(DepthPlus == 3)//ZDP linked ++
		{
			edge0 /= 3.75;
		}
		else if(DepthPlus == 4)//ZDP linked +++
		{
			edge0 /= 4.25;
		}
		else if(DepthPlus == 5)//ZDP linked ++++
		{
			edge0 /= 5.0;
		}
		else if(DepthPlus == 6)//ZDP linked +++++
		{
			edge0 /= 6.25;
		}
		else if(DepthPlus == 7)//ZDP linked ++++++
		{
			edge0 /= 7.5;
		}
		else if(DepthPlus == 8)//ZDP linked +++++++
		{
			edge0 /= 8.75;
		}
		else if(DepthPlus == 9)//ZDP linked ++++++++
		{
			edge0 /= 9.25;
		}
		else if(DepthPlus == 10)//ZDP linked +++++++++
		{
			edge0 /= 10.0;
		}

    // Scale, bias
    x = (x - edge0)/(edge1 - edge0); 
    // Evaluate polynomial
    return x*x*(3 - 2*x);
}

float AutoDepthRange( float d, float2 texcoord )
{
	float LumAdjust = smoothstep(-0.0175,0.300,Lum(texcoord));
    return min(1,( d - 0 ) / ( LumAdjust - 0));
}

void  Disocclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
float X, Y, A, B, DP =  Divergence, Disocclusion_PowerA, Disocclusion_PowerB , DBD = tex2Dlod(SamplerDM,float4(texcoord,0,0)).r;
float2 DM, DMA, DMB, dirA, dirB;

//DBD Adjustment Start
DBD = (DBD - 0.025)/(1 - 0.025); 
DBD = DBD*DBD*(3 - 2*DBD);
DBD = ( DBD - 1.0f ) / ( -187.5f - 1.0f );
//DBD Adjustment End

	DP *= Disocclusion_Power_Adjust;
		
	if ( Disocclusion_Adjust == 1 || Disocclusion_Adjust == 4 || Disocclusion_Adjust == 6 || Disocclusion_Adjust == 9 ) // Radial    
	{
		Disocclusion_PowerA = DP/125;
	}
	else if ( Disocclusion_Adjust == 2 || Disocclusion_Adjust == 5 || Disocclusion_Adjust == 7 || Disocclusion_Adjust == 10 ) // Normal  
	{
		Disocclusion_PowerA = DP/350;
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
					DM += tex2Dlod(SamplerDM,float4(texcoord + dirA * weightA[i] * A ,0,0)).rb/11;
					if(Disocclusion_Adjust == 4 || Disocclusion_Adjust == 5)
					{
						DMA += tex2Dlod(SamplerDM,float4(texcoord + dirB * weightA[i] * B ,0,0)).rb/11;
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
					DM += tex2Dlod(SamplerDM,float4(texcoord + dirA * weightB[i] * A ,0,0)).rb/17;
					if( Disocclusion_Adjust == 9 || Disocclusion_Adjust == 10 )
					{
						DMB += tex2Dlod(SamplerDM,float4(texcoord + dirB * weightB[i] * B ,0,0)).rb/17;
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

	X = DM.x;
	Y = DM.y;
	
	if (Auto_Depth_Range)
	{
		X = AutoDepthRange(X,texcoord);
		Y = AutoDepthRange(Y,texcoord);
	}
	color = float4(X,DM.x,Y,1);
}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////

float4 PS_calcLR(in float2 texcoord : TEXCOORD0)
{
	float2 TCL, TCR;
	float4 color, Right, Left, cR, cL;
	float DepthR = 1, DepthL = 1, ConAlt, MS, P, N, S, L, R;
	float samplesA[3] = {0.5,0.75,1.0};
	float samplesB[5] = {0.5,0.625,0.75,0.875,1.0};
	
	//MS is Max Separation P is Perspective Adjustment
	P = Perspective * pix.x;
	MS = Divergence * pix.x;
	
		if(Eye_Swap)
		{
			if ( Stereoscopic_Mode == 0)
			{
				TCL.x = (texcoord.x*2-1) - P;
				TCR.x = (texcoord.x*2) + P;
				TCL.y = texcoord.y;
				TCR.y = texcoord.y;
			}
			else if( Stereoscopic_Mode == 1 )
			{
				TCL.x = texcoord.x - P;
				TCR.x = texcoord.x + P;
				TCL.y = texcoord.y*2-1;
				TCR.y = texcoord.y*2;
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
				TCR.x = (texcoord.x*2-1) - P;
				TCL.x = (texcoord.x*2) + P;
				TCR.y = texcoord.y;
				TCL.y = texcoord.y;
			}
			else if(Stereoscopic_Mode == 1)
			{
				TCR.x = texcoord.x - P;
				TCL.x = texcoord.x + P;
				TCR.y = texcoord.y*2-1;
				TCL.y = texcoord.y*2;
			}
			else
			{
				TCR.x = texcoord.x - P;
				TCL.x = texcoord.x + P;
				TCR.y = texcoord.y;
				TCL.y = texcoord.y;
			}
		}
				
		if (View_Mode == 0)
			N = 3;
		else if (View_Mode == 1)
			N = 5;
		else if (View_Mode == 2)
			N = 1.025;
		else if (View_Mode == 3)
			N = Divergence/1.01;
				
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
				S = lerp(i*(Divergence/1.025), (Divergence/1.025),0.5);
				DepthL = min(DepthL,tex2Dlod(SamplerDis,float4(TCL.x+S*pix.x,TCL.y,0,0)).b);
				DepthR = min(DepthR,tex2Dlod(SamplerDis,float4(TCR.x-S*pix.x,TCR.y,0,0)).r);
			}
			else if (View_Mode == 3)
			{
				S = i;
				DepthL = min(DepthL,tex2Dlod(SamplerDis,float4(TCL.x+S*pix.x,TCL.y,0,0)).b);
				DepthR = min(DepthR,tex2Dlod(SamplerDis,float4(TCR.x-S*pix.x,TCR.y,0,0)).r);
			}
		}
		
		if (DepthPlus >= 1)//ZPD linked
			{
				DepthR = SS(-ZPD,1.25,DepthR); // Depth Plus is basicly smooth step with out the clamps. Seemed to give more Depth to a Image. 
				DepthL = SS(-ZPD,1.25,DepthL); // This will cause some FPS Hand Pop out. This is tolerable. 		
			}	
			
			DepthR = MS * Conv(DepthR,texcoord);
			DepthL = MS * Conv(DepthL,texcoord);
		
		float ReprojectionRight = DepthR; //Zero Parallax Distance controll
		float ReprojectionLeft =  DepthL;
	
		if(Custom_Sidebars == 0)
			{
				Left = tex2D(BackBufferMIRROR, float2(TCL.x + ReprojectionLeft, TCL.y));
				Right = tex2D(BackBufferMIRROR, float2(TCR.x - ReprojectionRight, TCR.y));
			}
			else if(Custom_Sidebars == 1)
			{
				Left = tex2D(BackBufferBORDER, float2(TCL.x + ReprojectionLeft, TCL.y));
				Right = tex2D(BackBufferBORDER, float2(TCR.x - ReprojectionRight, TCR.y));
			}
			else
			{
				Left = tex2D(BackBufferCLAMP, float2(TCL.x + ReprojectionLeft, TCL.y));
				Right = tex2D(BackBufferCLAMP, float2(TCR.x - ReprojectionRight, TCR.y));
			}
	
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
		if(Stereoscopic_Mode == 0)
		{	
			color = texcoord.x < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 1)
		{	
			color = texcoord.y < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 2)
		{
			float gridL;
			
			if(Scaling_Support == 0)
			{
				gridL = frac(texcoord.y*(2160.0/2));
			}			
			else if(Scaling_Support == 1)
			{
				gridL = frac(texcoord.y*(BUFFER_HEIGHT/2)); //Native
			}
			else if(Scaling_Support == 2)
			{
				gridL = frac(texcoord.y*(1080.0/2));
			}
			else if(Scaling_Support == 3)
			{
				gridL = frac(texcoord.y*(1081.0/2));
			}
			else if(Scaling_Support == 4)
			{
				gridL = frac(texcoord.y*(1050.0/2));
			}
			else if(Scaling_Support == 5)
			{
				gridL = frac(texcoord.y*(1051.0/2));
			}

			color = gridL > 0.5 ? cL : cR;	
		}
		else if(Stereoscopic_Mode == 3)
		{
			float gridC;
			
			if(Scaling_Support == 0)
			{
				gridC = frac(texcoord.x*(3840.0/2));
			}			
			else if(Scaling_Support == 1)
			{
				gridC = frac(texcoord.x*(BUFFER_WIDTH/2)); //Native
			}
			else if(Scaling_Support == 2)
			{
				gridC = frac(texcoord.x*(1920.0/2));
			}
			else if(Scaling_Support == 3)
			{
				gridC = frac(texcoord.x*(1921.0/2));
			}
			else if(Scaling_Support == 6)
			{
				gridC = frac(texcoord.x*(1280.0/2));
			}
			else if(Scaling_Support == 7)
			{
				gridC = frac(texcoord.x*(1281.0/2));
			}

			color = gridC > 0.5 ? cL : cR;		
		}
		else if(Stereoscopic_Mode == 4)
		{
			float gridy;
			float gridx;

			if(Scaling_Support == 1)
			{
			gridy = floor(texcoord.y*(BUFFER_HEIGHT)); //Native
			gridx = floor(texcoord.x*(BUFFER_WIDTH)); //Native
			}
			else if(Scaling_Support == 2)
			{
			gridy = floor(texcoord.y*(1080.0));
			gridx = floor(texcoord.x*(1920.0));
			}
			else if(Scaling_Support == 3)
			{
			gridy = floor(texcoord.y*(1081.0));
			gridx = floor(texcoord.x*(1921.0));
			}
			else if(Scaling_Support == 6)
			{
			gridy = floor(texcoord.y*(720.0));
			gridx = floor(texcoord.x*(1280.0));
			}
			else if(Scaling_Support == 7)
			{
			gridy = floor(texcoord.y*(721.0));
			gridx = floor(texcoord.x*(1281.0));
			}
			
			color = (int(gridy+gridx) & 1) < 0.5 ? cL : cR;
		}
		else
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
			float4 Top = texcoord.x < 0.5 ? Lum(float2(texcoord.x*2,texcoord.y*2)).xxxx : tex2Dlod(SamplerDM,float4(texcoord.x*2-1 , texcoord.y*2,0,0)).rrbb;
			color = texcoord.y < 0.5 ? Top : tex2Dlod(SamplerDis,float4(texcoord.x,texcoord.y*2-1,0,0)).rrrr;
	}
	float Average_Luminance = texcoord.y < 0.5 ? 0.5 : tex2D(SamplerDM,float2(texcoord.x,texcoord.y)).g;
	return float4(color.rgb,Average_Luminance);
}

void Average_Luminance_Weapon(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
	float3 Average_Luminance = PS_calcLR(float2(texcoord.x,(texcoord.y + 0.500) * 0.500 + 0.250)).www;
	color = float4(Average_Luminance,1);
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	//#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	float HEIGHT = BUFFER_HEIGHT/2,WIDTH = BUFFER_WIDTH/2;	
	float2 LCD,LCE,LCP,LCT,LCH,LCThree,LCDD,LCDot,LCI,LCN,LCF,LCO;
	float size = 9.5,set = BUFFER_HEIGHT/2,offset = (set/size),Shift = 50;
	float4 Color = float4(PS_calcLR(texcoord).rgb,1),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;

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
			pass AverageLuminance
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Luminance;
			RenderTarget = texLum;
		}
			pass Disocclusion
		{
			VertexShader = PostProcessVS;
			PixelShader = Disocclusion;
			RenderTarget = texDis;
		}
			pass AverageLuminanceWeapon
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Luminance_Weapon;
			RenderTarget = texLumWeapon;
		}
			pass StereoOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}

	}
