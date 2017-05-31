 ////--------------------------//
 ///**SuperDepth3D_FlashBack**///
 //--------------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.6 FlashBack																														*//
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
 //* Original work was based on Shader Based on forum user 04348 and be located here http://reshade.me/forum/shader-presentation/1594-3d-anaglyph-red-cyan-shader-wip#15236			*//
 //*																																												*//
//* AO Work was based on the shader code of a Devmaster Dev																															*//
 //* code was take from http://forum.devmaster.net/t/disk-to-disk-ssao/17414																										*//
 //* arkano22 Disk to Disk AO GLSL code adapted to be used to add more detail to the Depth Map.																						*//
 //* http://forum.devmaster.net/users/arkano22/																																		*//
 //*																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The size of the Depth Map. For 4k Use 2 or 2.5. For 1440p Use 1.5 or 2. For 1080p use 1. This may cause errors in Weapon Depth Maps.
#define Depth_Map_Division 1.0

// Determines The Max Depth amount. The larger the amount harder it will hit on FPS will be.
#define Depth_Max 30

//uniform float2 X <
	//ui_type = "drag";
	//ui_min = 0.0; ui_max = 2.0;
	//ui_label = "X";
	//ui_tooltip = "Determines the X point. Default is 0";
//> = float2(0.0,1.0);

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 50.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map for your games.";
> = 7.5;

uniform int Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = Depth_Max;
	ui_label = "Divergence Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.";
> = 15;

uniform float Near_Depth <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 100.0;
	ui_label = "Near Depth Adjustment";
	ui_tooltip = "Determines the amount of depth near the cam, zero is off.\n" 
				 "Default is 0.0";
> = 0.0;

uniform float Weapon_Depth <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Weapon Depth Adjustment";
	ui_tooltip = "Pushes or Pulls the FPS Hand in or out of the screen.\n" 
				 "Default is 0";
> = 0;

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

uniform float Offset <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset";
> = 0.5;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform int WDM <
	ui_type = "combo";
	ui_items = "Weapon DM Off\0Custom WDM One\0Custom WDM Two\0Weapon DM 0\0Weapon DM 1\0Weapon DM 2\0Weapon DM 3\0Weapon DM 4\0Weapon DM 5\0Weapon DM 6\0Weapon DM 7\0Weapon DM 8\0Weapon DM 9\0Weapon DM 10\0Weapon DM 11\0Weapon DM 12\0Weapon DM 13\0Weapon DM 14\0Weapon DM 15\0Weapon DM 16\0Weapon DM 17\0Weapon DM 18\0Weapon DM 19\0Weapon DM 20\0Weapon DM 21\0Weapon DM 22\0Weapon DM 23\0Weapon DM 24\0Weapon DM 25\0";
	ui_label = "Weapon Depth Map";
	ui_tooltip = "Pick your weapon depth map for games.";
> = 0;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = -10.0; ui_max = 10.0;
	ui_label = "Weapon Adjust Depth Map";
	ui_tooltip = "Adjust weapon depth map.\n" 
				 "Default is (X 0.010, Y 5.0, Z 1.0)";
> = float3(0.010,5.00,1.00);

uniform float Weapon_Cutoff <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "Weapon Cutoff Point";
	ui_tooltip = "For adjusting the cutoff point of the weapon Depth Map.\n" 
				 "Zero is Auto";
> = 0;

uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Checkerboard 3D\0Anaglyph\0";
	ui_label = "3D Display Mode";
	ui_tooltip = "Stereoscopic 3D display output selection.";
> = 0;

uniform int Downscaling_Support <
	ui_type = "combo";
	ui_items = "Native\0Option One\0Option Two\0";
	ui_label = "Downscaling Support";
	ui_tooltip = "Dynamic Super Resolution & Virtual Super Resolution downscaling support for Line Interlaced & Checkerboard 3D displays.";
> = 0;

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

uniform bool AO <
	ui_label = "3D AO Mode";
	ui_tooltip = "3D ambient occlusion mode switch.\n" 
				 "Default is On.";
> = 1;

uniform float Power <
	ui_type = "drag";
	ui_min = 0.25; ui_max = 0.75;
	ui_label = "AO Power";
	ui_tooltip = "Ambient occlusion power on the depth map.\n" 
				 "Default is 0.500";
> = 0.500;

uniform float Falloff <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2.5;
	ui_label = "AO Falloff";
	ui_tooltip = "Ambient occlusion falloff.\n" 
				 "Default is 1.5";
> = 1.5;

uniform float AO_Shift <
	ui_type = "drag";
	ui_min = 0; ui_max = 0.500;
	ui_label = "AO Shift";
	ui_tooltip = "Determines the Shift from White to Black.\n" 
				 "Default is 0";
> = 0.0;

uniform int Depth_Map_Resolution <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "Depth Map Resolution";
	ui_tooltip = "This will lower the resolution of the Depth Map.\n"
				 "You lose image quality if this is turned on.\n"
				 "Use if you need a fps boost.\n"
				 "Default is 0 Off";
> = 0;

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

texture texDM  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F; MipLevels = 3;}; 

sampler SamplerDM
	{
		Texture = texDM;
	};
	
texture texBlur  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F; MipLevels = 11;}; 

sampler SamplerBlur
	{
		Texture = texBlur;
	};
	
texture texAO  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA32F;}; 

sampler SamplerAO
	{
		Texture = texAO;
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

uniform float frametime < source = "frametime"; >;
/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////

float AL()
{
float AdjustScale = 2;
    
    //Luminance adapted luminance value from 1x1 Texture Mip lvl of 16
	float4 Luminance = tex2Dlod(SamplerBlur,float4(0.5,0.5,0,16));//Average
    
    //Frametime Perceptual Effects 
    float FPE  = (Luminance.r) * (AdjustScale - exp(-frametime));
    
    return saturate(FPE);
}
	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

float4 Depth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord ).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float DDA = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float DA = Depth_Map_Adjust*2; //Depth Map Adjust - Near
		//All 1.0f are Far Adjustment
		
		//0. DirectX Custom Constant Far
		float DirectX = 2.0 * DDA * 1.0f / (1.0f + DDA - zBuffer * (1.0f - DDA));
		
		//1. DirectX Alternative
		float DirectXAlt = pow(abs(zBuffer - 1.0),DA);
		
		//2. OpenGL
		float OpenGL = 2.0 * DDA * 1.0f / (1.0f + DDA - (2.0 * zBuffer - 1.0) * (1.0f - DDA));
		
		//3. OpenGL Reverse
		float OpenGLRev = 2.0 * 1.0f * DDA / (DDA + 1.0f - (2.0 * zBuffer - 1.0) * (DDA - 1.0f));
		
		//4. Raw Buffer
		float Raw = pow(abs(zBuffer),DA);
		
		//5. Old Depth Map from 1.9.5
		float Old = 100 / (1 + 100 - (zBuffer/DDA) * (1 - 100));
		
		//6. Special Depth Map
		float Special = pow(abs(exp(zBuffer)*Offset),(DA*25));
		
		if (Depth_Map == 0)
		{
		zBuffer = DirectX;
		}
		
		else if (Depth_Map == 1)
		{
		zBuffer = DirectXAlt;
		}

		else if (Depth_Map == 2)
		{
		zBuffer = OpenGL;
		}
		
		else if (Depth_Map == 3)
		{
		zBuffer = OpenGLRev;
		}
		
		else if (Depth_Map == 4)
		{
		zBuffer = lerp(DirectXAlt,OpenGLRev,0.5);
		}
		
		else if (Depth_Map == 5)
		{
		zBuffer = lerp(Raw,DirectX,0.5);
		}

		else if (Depth_Map == 6)
		{
		zBuffer = Raw;
		}
		
		else if (Depth_Map == 7)
		{
		zBuffer = lerp(DirectX,OpenGL,0.5);
		}
		
		else if (Depth_Map == 8)
		{
		zBuffer = lerp(Raw,OpenGL,0.5);
		}		
		
		else if (Depth_Map == 9)
		{
		zBuffer = Old;
		}
		
		else if (Depth_Map == 10)
		{
		zBuffer = Special;
		}
		
	return float4(zBuffer.rrr,1);	
}

float4 WeaponDepth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBufferWH = tex2D(DepthBuffer, texcoord ).r; //Weapon Hand Depth Buffer
		//Weapon Depth Map
		//FPS Hand Depth Maps require more precision at smaller scales to work
		if(WDM == 1 || WDM == 3 || WDM == 4 || WDM == 6 || WDM == 7 || WDM == 8 || WDM == 9 || WDM == 10 || WDM == 11 || WDM == 12 || WDM == 13 || WDM == 14 || WDM == 16 || WDM == 17 || WDM == 19 || WDM == 20 || WDM == 21 || WDM == 22 || WDM == 23 || WDM == 24 || WDM == 25 || WDM == 26 || WDM == 27 )
		{
		float constantF = 1.0;	
		float constantN = 0.01;
		zBufferWH = 2.0 * constantN * constantF / (constantF + constantN - (2.0 * zBufferWH - 1.0) * (constantF - constantN));
		}
		else if(WDM == 2 || WDM == 5 || WDM == 15 || WDM == 18)
		{
		zBufferWH = pow(abs(zBufferWH - 1.0),10);
 		}
 		
		//Set Weapon Depth Map settings for the section below.//
		float cWF;
		float cWN;
		float cWP;
		float CoP;
		
		if (WDM == 1)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		if (WDM == 2)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		//Game: Unreal Gold with v227 DX9
		//Weapon Depth Map Zero
		if (WDM == 3)
		{
		cWF = 0.010;
		cWN = -2.5;
		cWP = 0.873;
		CoP = 0.569;
		}
		
		//Game: Borderlands 2 
		//Weapon Depth Map One
		if (WDM == 4)
		{
		cWF = 0.010;
		cWN = -7.500;
		cWP = 0.875;
		CoP = 0.600;
		}
		
		//Game: Call of Duty: Black Ops 
		//Weapon Depth Map Two
		if (WDM == 5)
		{
		cWF = 0.853;
		cWN = 1.500;
		cWP = 1.0003;
		CoP = 0.507;
		}
		
		//Game: Call of Duty: Games 
		//Weapon Depth Map Three
		if (WDM == 6)
		{
		cWF = 0.390;
		cWN = 5;
		cWP = 0.999;
		CoP = 0.254;
		}
		
		//Game: Fallout 4
		//Weapon Depth Map Four
		if (WDM == 7)
		{
		cWF = 0.010;
		cWN = -0.500;
		cWP = 0.9895;
		CoP = 0.252;
		}
		
		//Game: Cryostasis
		//Weapon Depth Map Five		
		if (WDM == 8)
		{
		cWF = 0.015;
		cWN = -87.500;
		cWP = 0.750;
		CoP = 0.666;
		}
		
		//Game: Doom 2016
		//Weapon Depth Map Six
		if (WDM == 9)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.900;
		CoP = 0.4127;
		}
		
		//Game: Metro Games
		//Weapon Depth Map Seven
		if (WDM == 10)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.956;
		CoP = 0.260;
		}
		
		//Game: NecroVision
		//Weapon Depth Map Eight
		if (WDM == 11)
		{
		cWF = 0.010;
		cWN = -20.0;
		cWP = 0.4825;
		CoP = 0.733;
		}
		
		//Game: Quake XP
		//Weapon Depth Map Nine
		if (WDM == 12)
		{
		cWF = 0.010;
		cWN = -25.0;
		cWP = 0.695;
		CoP = 0.341;
		}
		
		//Game: Quake 4
		//Weapon Depth Map Ten
		if (WDM == 13)
		{
		cWF = 0.010;
		cWN = -20.0;
		cWP = 0.500;
		CoP = 0.476;
		}
		
		//Game: Rage
		//Weapon Depth Map Eleven
		if (WDM == 14)
		{
		cWF = 0.010;
		cWN = -7.5;
		cWP = 0.4505;
		CoP = 0.816;
		}
		
		//Game: Return to Castle Wolfensitne
		//Weapon Depth Map Twelve
		if (WDM == 15)
		{
		cWF = 0.010;
		cWN = 100.0;
		cWP = 0.4375;
		CoP = 0.522;
		}

		//Game: S.T.A.L.K.E.R: Games
		//Weapon Depth Map Thirteen
		if (WDM == 16)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.976;
		CoP = 0.508;
		}

		//Game: Skyrim Special Edition
		//Weapon Depth Map Fourteen
		if (WDM == 17)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.905;
		CoP = 0.146;
		}
		
		//Game: Turok Dinosaur Hunter
		//Weapon Depth Map Fifteen
		if (WDM == 18)
		{
		cWF = 0.010;
		cWN = -0.450;
		cWP = 0.01225;
		CoP = 0.473;
		}
		
		//Game: Wolfenstine: New Order ; Old Blood
		//Weapon Depth Map Sixteen
		if (WDM == 19)
		{
		cWF = 0.010;
		cWN = -10.0;
		cWP = 0.4455;
		CoP = 0.548;
		}
		
		//Game: Prey 2017 Object Detail Veary High
		//Weapon Depth Map Seventeen
		if (WDM == 20)
		{
		cWF = 0.010;
		cWN = 3.75;
		cWP = 0.0914;
		CoP = 0.275;
		}
		
		//Game: Prey 2017
		//Weapon Depth Map Eighteen
		if (WDM == 21)
		{
		cWF = 0.010;
		cWN = 5.0;
		cWP = 0.131;
		CoP = 0.285;
		}
		
		//Game: Deus Ex Mankind Divided may not be needed.
		//Weapon Depth Map Nineteen
		if (WDM == 22)
		{
		cWF = 0.010;
		cWN = 150.0;
		cWP = 1.100;
		}

		//Game: Dying Light
		//Weapon Depth Map Twenty
		if (WDM == 23)
		{
		cWF = 0.010;
		cWN = 150.0;
		cWP = 1.045;
		}

		//Game: Kingpin
		//Weapon Depth Map Twenty One
		if (WDM == 24)
		{
		cWF = 0.010;
		cWN = 150.0;
		cWP = 1.100;
		CoP = 0.338;
		}
		
		//Game: SOMA
		//Weapon Depth Map Twenty Two
		if (WDM == 25)
		{
		cWF = 0.010;
		cWN = -150.0;
		cWP = 0.125;
		CoP = 0.900;
		}
		
		//Game: Turok 2: Seeds of Evil
		//Weapon Depth Map Twenty Three
		if (WDM == 26)
		{
		cWF = 0.010;
		cWN = -100.0;
		cWP = -0.050;
		CoP = 3.750;
		}
		
		//Game: Amnesia: Machine for Pigs
		//Weapon Depth Map Twenty Four
		if (WDM == 27)
		{
		cWF = 0.010;
		cWN = -37.5;
		cWP = -0.0075;
		CoP = 7.0;
		}
		
		//Game:
		//Weapon Depth Map Twenty Five
		if (WDM == 28)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		//SWDMS Done//
 		
		//Scaled Section z-Buffer
		
		if (WDM >= 1)
		{
		cWN /= 1000;
		zBufferWH = (cWN * zBufferWH) / ((cWP*zBufferWH)-(cWF));
		}
		
		if (WDM == 18 || WDM == 24) //Turok Dinosaur Hunter ; KingPin
		zBufferWH = 1-zBufferWH;
		
		//Auto Anti Weapon Depth Map Z-Fighting is always on.
		zBufferWH = zBufferWH*AL(); 
		
		if (WDM == 18)
		{
		zBufferWH = smoothstep(0,1,zBufferWH);
		}
		else
		{
		zBufferWH = smoothstep(0,1.250,zBufferWH);
		}
		if (Weapon_Cutoff == 0) //Zero Is auto
		{
		CoP = CoP;
		}
		else	
		{
		CoP = Weapon_Cutoff;
		}
		
		return float4(zBufferWH.rrr,CoP);
}

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0)
{
		float X,Y,W = 1;
		float3 Z;
		
		float DM = Depth(texcoord).r;		
		
		float WD = WeaponDepth(texcoord).r;
		
		float CoP = WeaponDepth(texcoord).w; //Weapon Cutoff Point
				
		float CutOFFCal = (CoP/Depth_Map_Adjust)/2; //Weapon Cutoff Calculation
					
		float NearDepth = step(WD.r,1.0); //Base Cutoff
		
		float D, Done;
		
		float Cutoff = step(DM.r,CutOFFCal);
				
		float Adj = Weapon_Depth/1000; //Push & pull weapon in or out of screen.
					
		if (WDM == 0)
		{
		Done = DM;
		}
		else
		{
		D = lerp(DM,WD,NearDepth);
		Done = lerp(DM,D+Adj,Cutoff);
		}
		
		X = Done;
		Z = Done.rrr;
			
	// Dither for DepthBuffer adapted from gedosato ramdom dither https://github.com/PeterTh/gedosato/blob/master/pack/assets/dx9/deband.fx
	
	float dither_bit  = 8.0;
	float noise = frac(sin(dot(texcoord, float2(12.9898, 78.233))) * 43758.5453 * 1);
	float dither_shift = (1.0 / (pow(2,dither_bit) - 1.0));
	float dither_shift_half = (dither_shift * 0.5);
	dither_shift = dither_shift * noise - dither_shift_half;
	Z += float3(-dither_shift, dither_shift, -dither_shift);
	
	// Dither End
		
		Color = saturate(float4(X,Y,Z.r,W));
}

/////////////////////////////////////////////////////AO/////////////////////////////////////////////////////////////

float3 GetPosition(float2 coords)
{
	float3 DM = tex2Dlod(SamplerDM,float4(coords.xy,0,Depth_Map_Resolution)).rrr;
	return float3(coords.xy*2.5-1.0,10.0)*DM;
}

float2 GetRandom(float2 co)
{
	float random = frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453 * 1);
	return float2(random,random);
}

float3 normal_from_depth(float2 texcoords) 
{
	float depth;
	const float2 offset1 = float2(-10,10);
	const float2 offset2 = float2(10,10);
	  
	float depth1 = tex2Dlod(SamplerDM, float4(texcoords + offset1,0,Depth_Map_Resolution)).r;
	float depth2 = tex2Dlod(SamplerDM, float4(texcoords + offset2,0,Depth_Map_Resolution)).r;
	  
	float3 p1 = float3(offset1, depth1 - depth);
	float3 p2 = float3(offset2, depth2 - depth);
	  
	float3 normal = cross(p1, p2);
	normal.z = -normal.z;
	  
	return normalize(normal);
}

//Ambient Occlusion form factor
float aoFF(in float3 ddiff,in float3 cnorm, in float c1, in float c2)
{
	float S = 1-AO_Shift;
	float3 vv = normalize(ddiff);
	float rd = length(ddiff);
	return (S-clamp(dot(normal_from_depth(float2(c1,c2)),-vv),-1,1.0)) * (1.0 - 1.0/sqrt(-0.001/(rd*rd) + 1000));
}

float4 GetAO( float2 texcoord )
{ 
    //current normal , position and random static texture.
    float3 normal = normal_from_depth(texcoord);
    float3 position = GetPosition(texcoord);
	float2 random = GetRandom(texcoord).xy;
    
    //initialize variables:
    float F = Falloff;
	float iter = 2.5*pix.x;
    float ao, num;
    float incx = F*pix.x;
    float incy = F*pix.y;
    float width = incx;
    float height = incy;
    
    //Depth Map
    float depthM = tex2Dlod(SamplerDM, float4(texcoord,0,Depth_Map_Resolution)).b;
    
		
	//Depth Map linearization
	float constantF = 1.0;	
	float constantN = 0.250;
	depthM = saturate(2.0 * constantN * constantF / (constantF + constantN - (2.0 * depthM - 1.0) * (constantF - constantN)));
    
	//2 iterations 
	[loop]
    for(float i=0.0; i<2; ++i) 
    {
       float npw = (width+iter*random.x)/depthM;
       float nph = (height+iter*random.y)/depthM;
       
		if(AO == 1)
		{
			float3 ddiff = GetPosition(texcoord.xy+float2(npw,nph))-position;
			float3 ddiff2 = GetPosition(texcoord.xy+float2(npw,-nph))-position;
			float3 ddiff3 = GetPosition(texcoord.xy+float2(-npw,nph))-position;
			float3 ddiff4 = GetPosition(texcoord.xy+float2(-npw,-nph))-position;

			ao+=  aoFF(ddiff,normal,npw,nph);
			ao+=  aoFF(ddiff2,normal,npw,-nph);
			ao+=  aoFF(ddiff3,normal,-npw,nph);
			ao+=  aoFF(ddiff4,normal,-npw,-nph);
			num = 8;
		}
		
		//increase sampling area
		   width += incx;  
		   height += incy;		    
    } 
    ao/=num;

	//Luminance adjust used for overbright correction.
	float4 Done = min(1.0,ao);
	float3 lumcoeff = float3(0.299,0.587,0.114);
	float lum = dot(Done.rgb, lumcoeff);
	float3 luminance = float3(lum, lum, lum);
  
    return float4(luminance,1);
}

void AO_in(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	color = GetAO(texcoord);
}

void  BilateralBlur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
//bilateral blur\/
float4 Done;
float4 sum;
float P = Power/10;

float blursize = 2.0*pix.x;

sum += tex2D(SamplerAO, float2(texcoord.x - 4.0*blursize, texcoord.y)) * 0.05;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y - 3.0*blursize)) * 0.09;
sum += tex2D(SamplerAO, float2(texcoord.x - 2.0*blursize, texcoord.y)) * 0.12;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y - blursize)) * 0.15;
sum += tex2D(SamplerAO, float2(texcoord.x + blursize, texcoord.y)) * 0.15;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y + 2.0*blursize)) * 0.12;
sum += tex2D(SamplerAO, float2(texcoord.x + 3.0*blursize, texcoord.y)) * 0.09;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y + 4.0*blursize)) * 0.05;

Done = 1-sum;
//bilateral blur/\

float4 DM = tex2Dlod(SamplerDM,float4(texcoord,0,Depth_Map_Resolution)).bbbb;

	color = lerp(DM,Done,P);
}

float4  RGBAEncode(in float2 texcoord : TEXCOORD0) //RGBA zBuffer Color Channel Encode
{
	float GetDepth = tex2Dlod(SamplerBlur,float4(texcoord.x,texcoord.y,0,Depth_Map_Resolution)).r;
	
	float ZPD, Depth, MS = Divergence*pix.x;
	float ND = Near_Depth/100;
		
	Depth += MS * (1-ZPD/GetDepth);//Convergence also known as ZPD, code is not in full use since Near Depth is in favor.
	
	GetDepth = lerp(GetDepth,1-GetDepth,-ND); //Near Depth code, simple Code to add enhanced depth to the image output.
	
	float Red = (1-texcoord.x)+Divergence*pix.x*GetDepth;
	float Blue = texcoord.x+Divergence*pix.x*GetDepth;
	
	float RedINV = (1-texcoord.x)+Divergence*pix.x*Depth;
	float BlueINV = texcoord.x+Divergence*pix.x*Depth;
	
	float R = lerp(Red,RedINV,0.5); //Red Color Channel
	float B = lerp(Blue,BlueINV,0.5); //Blue Color Channel
	
	return float4(R,0,B,0);
}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////

void PS_calcLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
	float4 Out;
	float2 TCL,TCR;
	
	if (Stereoscopic_Mode == 0)
		{
		if (Eye_Swap)
			{
				TCL.x = (texcoord.x*2) - Perspective * pix.x;
				TCR.x = (texcoord.x*2-1) + Perspective * pix.x;
				TCL.y = texcoord.y;
				TCR.y = texcoord.y;
			}
		else
			{
				TCL.x = (texcoord.x*2-1) - Perspective * pix.x;
				TCR.x = (texcoord.x*2) + Perspective * pix.x;
				TCL.y = texcoord.y;
				TCR.y = texcoord.y;
			}
		}
	else if(Stereoscopic_Mode == 1)
		{
		if (Eye_Swap)
			{
			TCL.x = texcoord.x - Perspective * pix.x;
			TCR.x = texcoord.x + Perspective * pix.x;
			TCL.y = texcoord.y*2;
			TCR.y = texcoord.y*2-1;
			}
		else
			{
			TCL.x = texcoord.x - Perspective * pix.x;
			TCR.x = texcoord.x + Perspective * pix.x;
			TCL.y = texcoord.y*2-1;
			TCR.y = texcoord.y*2;
			}
		}
	else
		{
			TCL.x = texcoord.x - Perspective * pix.x;
			TCR.x = texcoord.x + Perspective * pix.x;
			TCL.y = texcoord.y;
			TCR.y = texcoord.y;
		}
		
	
		float4 cL = tex2D(BackBuffer,float2(TCL.x,TCL.y)); //objects that hit screen boundary is replaced with the BackBuffer 		
		float4 cR = tex2D(BackBuffer,float2(TCR.x,TCR.y)); //objects that hit screen boundary is replaced with the BackBuffer
				
		[loop]
		for (int i = 0; i <= Divergence; i++) 
		{
				//R
				if (RGBAEncode(float2(TCR.x+i*pix.x/0.900,TCR.y)).x >= (1-TCR.x)/1.0025) //Decode R
				{
					cR = tex2Dlod(BackBuffer, float4(TCR.x+i*pix.x/0.9875,TCR.y,0,0));
				}
				
				//L
				if (RGBAEncode(float2(TCL.x-i*pix.x/0.900,TCL.y)).z >= TCL.x/1.0025) //Decode B
				{
					cL = tex2Dlod(BackBuffer, float4(TCL.x-i*pix.x/0.9875,TCL.y,0,0));
				}	
		}
	if(!Depth_Map_View)
		{	
	if (Stereoscopic_Mode == 0)
		{	
			if (Eye_Swap)
			{
				Out = texcoord.x < 0.5 ? cL : cR;
			}
		else
			{
				Out = texcoord.x < 0.5 ? cR : cL;
			}
		}
	else if (Stereoscopic_Mode == 1)
		{	
		if (Eye_Swap)
			{
				Out = texcoord.y < 0.5 ? cL : cR;
			}
		else
			{
				Out = texcoord.y < 0.5 ? cR : cL;
			} 
		}
	else if (Stereoscopic_Mode == 2)
		{	
			float gridL;
				
		if(Downscaling_Support == 0)
			{
				gridL = frac(texcoord.y*(BUFFER_HEIGHT/2));
			}
			else if(Downscaling_Support == 1)
			{
				gridL = frac(texcoord.y*(1080.0/2));
			}
		else
			{
				gridL = frac(texcoord.y*(1081.0/2));
			}
				
		if (Eye_Swap)
			{
				Out = gridL > 0.5 ? cL : cR;
			}
		else
			{
				Out = gridL > 0.5 ? cR : cL;
			} 
			
		}
	else if (Stereoscopic_Mode == 3)
		{	
			float gridy;
			float gridx;
				
		if (Downscaling_Support == 0)
			{
					gridy = floor(texcoord.y*(BUFFER_HEIGHT));
				gridx = floor(texcoord.x*(BUFFER_WIDTH));
			}
		else if (Downscaling_Support == 1)
			{
				gridy = floor(texcoord.y*(1080.0));
				gridx = floor(texcoord.x*(1080.0));
			}
		else
			{
				gridy = floor(texcoord.y*(1081.0));
				gridx = floor(texcoord.x*(1081.0));
			}

		if (Eye_Swap)
			{
				Out = (int(gridy+gridx) & 1) < 0.5 ? cL : cR;
			}
		else
			{
				Out = (int(gridy+gridx) & 1) < 0.5 ? cR : cL;
			} 
			
		}
	else
		{
		float3 L,R;
		if(Eye_Swap)
			{
				L = cL.rgb;
				R = cR.rgb;
			}
		else
			{
				L = cR.rgb;
				R = cL.rgb;
			}
			
			float3 HalfL = dot(L,float3(0.299, 0.587, 0.114));
			float3 HalfR = dot(R,float3(0.299, 0.587, 0.114));
			float3 LC = lerp(HalfL,L,Anaglyph_Desaturation);  
			float3 RC = lerp(HalfR,R,Anaglyph_Desaturation); 
					
			float4 C = float4(LC,1);
			float4 CT = float4(RC,1);
					
		if (Anaglyph_Colors == 0)
			{
				float4 LeftEyecolor = float4(1.0,0.0,0.0,1.0);
				float4 RightEyecolor = float4(0.0,1.0,1.0,1.0);
		
				Out =  (C*LeftEyecolor) + (CT*RightEyecolor);

				}
			else if (Anaglyph_Colors == 1)
				{
						float red = 0.437 * C.r + 0.449 * C.g + 0.164 * C.b
							- 0.011 * CT.r - 0.032 * CT.g - 0.007 * CT.b;
				
					if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

						float green = -0.062 * C.r -0.062 * C.g -0.024 * C.b 
							+ 0.377 * CT.r + 0.761 * CT.g + 0.009 * CT.b;
				
					if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

						float blue = -0.048 * C.r - 0.050 * C.g - 0.017 * C.b 
							-0.026 * CT.r -0.093 * CT.g + 1.234  * CT.b;
				
					if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }


					Out = float4(red, green, blue, 0);
				}
			else if (Anaglyph_Colors == 2)
				{
					float4 LeftEyecolor = float4(0.0,1.0,0.0,1.0);
					float4 RightEyecolor = float4(1.0,0.0,1.0,1.0);
					
					Out =  (C*LeftEyecolor) + (CT*RightEyecolor);
					
				}
			else
				{
					
					
					float red = -0.062 * C.r -0.158 * C.g -0.039 * C.b
						+ 0.529 * CT.r + 0.705 * CT.g + 0.024 * CT.b;
				
					if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

					float green = 0.284 * C.r + 0.668 * C.g + 0.143 * C.b 
						- 0.016 * CT.r - 0.015 * CT.g + 0.065 * CT.b;
				
					if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

					float blue = -0.015 * C.r -0.027 * C.g + 0.021 * C.b 
						+ 0.009 * CT.r + 0.075 * CT.g + 0.937  * CT.b;
				
					if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
						
					Out = float4(red, green, blue, 0);
				}
			}
		}
	else
		{
				float4 DMV = texcoord.x < 0.5 ? GetAO(float2(texcoord.x*2 , texcoord.y*2)) : tex2Dlod(SamplerDM,float4(texcoord.x*2-1 , texcoord.y*2,0,Depth_Map_Resolution)).bbbb;
				Out = texcoord.y < 0.5 ? DMV : tex2Dlod(SamplerBlur,float4(texcoord.x , texcoord.y*2-1 , 0 , Depth_Map_Resolution));
		}
		
		color = Out;
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

technique Depth3D_FlashBack
	{
			pass zbuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget = texDM;
		}
			pass AmbientOcclusion
		{
			VertexShader = PostProcessVS;
			PixelShader = AO_in;
			RenderTarget = texAO;
		}	
			pass BilateralBlur
		{
			VertexShader = PostProcessVS;
			PixelShader = BilateralBlur;
			RenderTarget = texBlur;
		}
			pass StereographicDecodeOutput
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_calcLR;
		}


	}
