////----------------//
///**SuperDepth3D**///
//----------------////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* Depth Map Based 3D post-process shader v2.2.6
//* For Reshade 3.0+
//* ---------------------------------
//*
//* Original work was based on the shader code from
//* CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology
//* Also Fu-Bama a shader dev at the reshade forums https://reshade.me/forum/shader-presentation/5104-vr-universal-shader
//* Also had to rework Philippe David http://graphics.cs.brown.edu/games/SteepParallax/index.html code to work with ReShade. This is used for the parallax effect.
//* This idea was taken from this shader here located at https://github.com/Fubaxiusz/fubax-shaders/blob/596d06958e156d59ab6cd8717db5f442e95b2e6b/Shaders/VR.fx#L395
//* It's also based on Philippe David Steep Parallax mapping code. If I missed any information please contact me so I can make corrections.
//*
//* LICENSE
//* ============
//* Overwatch Interceptor & Code out side the work of people mention above is licenses under: Copyright (C) Depth3D - All Rights Reserved
//*
//* Unauthorized copying of this file, via any medium is strictly prohibited
//* Proprietary and confidential.
//*
//* You are allowed to obviously download this and use this for your personal use.
//* Just don't redistribute this file unless I authorize it.
//*
//* Have fun,
//* Written by Jose Negrete AKA BlueSkyDefender <UntouchableBlueSky@gmail.com>, December 2019
//*
//* Please feel free to contact me if you want to use this in your project.
//* https://github.com/BlueSkyDefender/Depth3D
//* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader
//* https://discord.gg/Q2n97Uj
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if exists "Overwatch.fxh"                                           //Overwatch Interceptor//
	#include "Overwatch.fxh"
#else// DA_X = [ZPD] DA_Y = [Depth Adjust] DA_Z = [Offset] DA_W = [Depth Linearization]
	static const float DA_X = 0.025, DA_Y = 7.5, DA_Z = 0.0, DA_W = 0.0;
	// DC_X = [Depth Flip] DC_Y = [Auto Balance] DC_Z = [Auto Depth] DC_W = [Weapon Hand]
	static const float DB_X = 0, DB_Y = 0, DB_Z = 0.1, DB_W = 0.0;
	// DC_X = [HUD] DC_Y = [Barrel Distortion K1] DC_Z = [Barrel Distortion K2] DC_W = [Barrel Distortion Zoom]
	static const float DC_X = 0.0, DC_Y = 0, DC_Z = 0, DC_W = 0;
	// DD_X = [Horizontal Size] DD_Y = [Vertical Size] DD_Z = [Horizontal Position] DD_W = [Vertical Position]
	static const float DD_X = 1,DD_Y = 1, DD_Z = 0.0, DD_W = 0.0;
	// DE_X = [ZPD Boundary Type] DE_Y = [ZPD Boundary Scaling] DE_Z = [ZPD Boundary Fade Time] DE_W = [Weapon Near Depth]
	static const float DE_X = 0,DE_Y = 0.5, DE_Z = 0.25, DE_W = 0.0;
	// DF_X = [Weapon ZPD Boundary] DF_Y = [Null_A] DF_Z = [Null_B] DF_W = [Null_C]
	static const float DF_X = 0.0,DF_Y = 0.0, DF_Z = 0.0, DF_W = 0.0;
	// WSM = [Weapon Setting Mode]
	#define OW_WP "WP Off\0Custom WP\0"
	static const int WSM = 0;
	//Triggers
	static const int RE = 0, NC = 0, TW = 0, NP = 0, ID = 0, SP = 0, DC = 0, HM = 0;
#endif
//USER EDITABLE PREPROCESSOR FUNCTIONS START//
//This enables the older SuperDepth3D method of producing an 3D image. This is better for older systems that have an hard time running the new mode.
//Also use this if you like the look of the old mode.
#define Legacy_Mode 0 //Zero is off and One is On.

// Zero Parallax Distance Balance Mode allows you to switch control from manual to automatic and vice versa.
#define Balance_Mode 0 //Default 0 is Automatic. One is Manual.

// RE Fix is used to fix the issue with Resident Evil's 2 Remake 1-Shot cutscenes.
#define RE_Fix 0 //Default 0 is Off. One is On.

// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key using keycode info
// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.

// Rare Games like Among the Sleep Need this to be turned on.
#define Invert_Depth 0 //Default 0 is Off. One is On.

// Barrel Distortion Correction For SuperDepth3D for non conforming BackBuffer.
#define BD_Correction 0 //Default 0 is Off. One is On.

// Horizontal & Vertical Depth Buffer Resize for non conforming DepthBuffer.
// Also used to enable Image Position Adjust is used to move the Z-Buffer around.
#define DB_Size_Postion 0 //Default 0 is Off. One is On.

// HUD Mode is for Extra UI MASK and Basic HUD Adjustments. This is useful for UI elements that are drawn in the Depth Buffer.
// Such as the game Naruto Shippuden: Ultimate Ninja, TitanFall 2, and or Unreal Gold 277. That have this issue. This also allows for more advance users
// Too Make there Own UI MASK if need be.
// You need to turn this on to use UI Masking options Below.
#define HUD_MODE 0 // Set this to 1 if basic HUD items are drawn in the depth buffer to be adjustable.

// -=UI Mask Texture Mask Interceptor=- This is used to set Two UI Masks for any game. Keep this in mind when you enable UI_MASK.
// You Will have to create Three PNG Textures named DM_Mask_A.png & DM_Mask_B.png with transparency for this option.
// They will also need to be the same resolution as what you have set for the game and the color black where the UI is.
// This is needed for games like RTS since the UI will be set in depth. This corrects this issue.
#if ((exists "DM_Mask_A.png") || (exists "DM_Mask_B.png"))
	#define UI_MASK 1
#else
	#define UI_MASK 0
#endif
// To cycle through the textures set a Key. The Key Code for "n" is Key Code Number 78.
#define Set_Key_Code_Here 0 // You can use http://keycode.info/ to figure out what key is what.
// Texture EX. Before |::::::::::| After |**********|
//                    |:::       |       |***       |
//                    |:::_______|       |***_______|
// So :::: are UI Elements in game. The *** is what the Mask needs to cover up.
// The game part needs to be transparent and the UI part needs to be black.

// The Key Code for the mouse is 0-4 key 1 is right mouse button.
#define Cursor_Lock_Key 4 // Set default on mouse 4
#define Fade_Key 1 // Set default on mouse 1
#define Fade_Time_Adjust 0.5625 // From 0 to 1 is the Fade Time adjust for this mode. Default is 0.5625;

//USER EDITABLE PREPROCESSOR FUNCTIONS END//
#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

#if __RESHADE__ >= 43000
	#define Compatibility_DD 1
#else
	#define Compatibility_DD 0
#endif

#if __VENDOR__ == 0x10DE //AMD = 0x1002 //Nv = 0x10DE //Intel = ???
	#define Ven 1
#else
	#define Ven 0
#endif

#if __RENDERER__ >= 0x10000 || __RENDERER__ >= 0x20000
	#define Rend 1
#else
	#define Rend 0
#endif
//Resolution Scaling because I can't tell your monitor size. Each level is 25 more then it should be.
#if (BUFFER_HEIGHT <= 1080)
	#define Max_Divergence 50.0
#elif (BUFFER_HEIGHT <= 1440)
	#define Max_Divergence 75.0
#elif (BUFFER_HEIGHT <= 2160)
	#define Max_Divergence 100.0
#else
	#define Max_Divergence 125.0
#endif
//New ReShade PreProcessor stuff
#if UI_MASK
	#ifndef Mask_Cycle_Key
		#define Mask_Cycle_Key Set_Key_Code_Here
	#endif
#else
	#define Mask_Cycle_Key Set_Key_Code_Here
#endif
//Divergence & Convergence//
uniform float Divergence <
	ui_type = "drag";
	ui_min = 10.0; ui_max = Max_Divergence; ui_step = 0.5;
	ui_label = "·Divergence Slider·";
	ui_tooltip = "Divergence increases differences between the left and right retinal images and allows you to experience depth.\n"
				 "The process of deriving binocular depth information is called stereopsis.";
	ui_category = "Divergence & Convergence";
> = 25;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.250;
	ui_label = " Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect also known as Convergence.\n"
				"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
				"This is controlled by Convergence Mode.\n"
				"Default is 0.025, Zero is off.";
	ui_category = "Divergence & Convergence";
> = DA_X;
#if Balance_Mode
uniform float ZPD_Balance <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " ZPD Balance";
	ui_tooltip = "Zero Parallax Distance balances between ZPD Depth and Scene Depth.\n"
				"Default is Zero is full Convergence and One is Full Depth.";
	ui_category = "Divergence & Convergence";
> = 0.5;

static const int Auto_Balance_Ex = 0;
#else
uniform int Auto_Balance_Ex <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 5;
	ui_label = " Auto Balance";
	ui_tooltip = "Automatically Balance between ZPD Depth and Scene Depth.\n"
				 "Default is Off.";
	ui_category = "Divergence & Convergence";
> = DB_Y;
#endif
uniform int ZPD_Boundary <
	ui_type = "combo";
	ui_items = "Off\0Normal\0Third Person\0FPS Weapon Center\0FPS Weapon Right\0";
	ui_label = " ZPD Boundary Detection";
	ui_tooltip = "This selection menu gives extra boundary conditions to ZPD.\n"
				 			 "This treats your screen as a virtual wall.\n"
				 		   "Default is Off.";
	ui_category = "Divergence & Convergence";
> = DE_X;

uniform float2 ZPD_Boundary_n_Fade <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 0.5;
	ui_label = " ZPD Boundary & Fade Time";
	ui_tooltip = "This selection menu gives extra boundary conditions to scale ZPD & lets you adjust Fade time.";
	ui_category = "Divergence & Convergence";
> = float2(DE_Y,DE_Z);

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "View Mode Normal\0View Mode Alpha\0";
	ui_label = "·View Mode·";
	ui_tooltip = "Changes the way the shader fills in the occlude section in the image.\n"
                 "Normal is default output and Alpha is used for higher amounts of Semi-Transparent objects.\n"
				 "Default is Normal";
	ui_category = "Occlusion Masking";
> = 0;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = " Edge Handling";
	ui_tooltip = "Edges selection for your screen output.";
	ui_category = "Occlusion Masking";
> = 1;

uniform float Depth_Edge_Mask <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = -0.125; ui_max = 1.0;
	ui_label = " Edge Mask";
	ui_tooltip = "Use this to adjust for artifacts.\n"
				 "Default is Zero, Off";
	ui_category = "Occlusion Masking";
> = 0.0;
#if !Legacy_Mode
uniform bool Performance_Mode <
	ui_label = " Performance Mode";
	ui_tooltip = "Performance Mode Lowers Occlusion Quality Processing so that there is a small boost to FPS.\n"
				 "Please enable the 'Performance Mode Checkbox,' in ReShade's GUI.\n"
				 "It's located in the lower bottom right of the ReShade's Main UI.\n"
				 "Default is False.";
	ui_category = "Occlusion Masking";
> = false;
#endif
uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DM0 Normal\0DM1 Reversed\0";
	ui_label = "·Depth Map Selection·";
	ui_tooltip = "Linearization for the zBuffer also known as Depth Map.\n"
			     "DM0 is Z-Normal and DM1 is Z-Reversed.\n";
	ui_category = "Depth Map";
> = DA_W;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.0; ui_step = 0.125;
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "This allows for you to adjust the DM precision.\n"
				 "Adjust this to keep it as low as possible.\n"
				 "Default is 7.5";
	ui_category = "Depth Map";
> = DA_Y;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Depth Map Offset";
	ui_tooltip = "Depth Map Offset is for non conforming ZBuffer.\n"
				 "It,s rare if you need to use this in any game.\n"
				 "Use this to make adjustments to DM 0 or DM 1.\n"
				 "Default and starts at Zero and it's Off.";
	ui_category = "Depth Map";
> = DA_Z;

uniform float Auto_Depth_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = " Auto Depth Adjust";
	ui_tooltip = "The Map Automatically scales to outdoor and indoor areas.\n"
				 "Default is 0.1f, Zero is off.";
	ui_category = "Depth Map";
> = DB_Z;

uniform int Depth_Detection <
	ui_type = "combo";
#if !Compatibility_DD
	ui_items = "Off\0Depth Detection +Sky\0Depth Detection -Sky\0ReShade Depth Detection\0";
#else
	ui_items = "Off\0Depth Detection +Sky\0Depth Detection -Sky\0";
#endif
	ui_label = " Depth Detection";
	ui_tooltip = "Use this to disable/enable in game Depth Detection.";
	ui_category = "Depth Map";
> = 0;

uniform int Depth_Map_View <
	ui_type = "combo";
	ui_items = "Off\0Stero Depth View\0Normal Depth View\0";
	ui_label = " Depth Map View";
	ui_tooltip = "Display the Depth Map";
	ui_category = "Depth Map";
> = 0;

uniform bool Depth_Map_Flip <
	ui_label = " Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Map";
> = DB_X;
#if DB_Size_Postion
uniform float2 Horizontal_and_Vertical <
	ui_type = "drag";
	ui_min = 0.125; ui_max = 2;
	ui_label = " Z Horizontal & Vertical Size";
	ui_tooltip = "Adjust Horizontal and Vertical Resize. Default is 1.0.";
	ui_category = "Depth Map";
> = float2(DD_X,DD_Y);

uniform int2 Image_Position_Adjust<
	ui_type = "drag";
	ui_min = -4096.0; ui_max = 4096.0;
	ui_label = "Z Position";
	ui_tooltip = "Adjust the Image Position if it's off by a bit. Default is Zero.";
	ui_category = "Depth Map";
> = int2(DD_Z,DD_W);
#else
static const float2 Horizontal_and_Vertical = float2(DD_X,DD_Y);
static const int2 Image_Position_Adjust = int2(DD_Z,DD_W);
#endif
//Weapon Hand Adjust//
uniform int WP <
	ui_type = "combo";
	ui_items = OW_WP;
	ui_label = "·Weapon Profiles·";
	ui_tooltip = "Pick Weapon Profile for your game or make your own.";
	ui_category = "Weapon Hand Adjust";
> = DB_W;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 250.0;
	ui_label = " Weapon Hand Adjust";
	ui_tooltip = "Adjust Weapon depth map for your games.\n"
				 "X, CutOff Point used to set a different scale for first person hand apart from world scale.\n"
				 "Y, Precision is used to adjust the first person hand in world scale.\n"
	             "Default is float2(X 0.0, Y 0.0, Z 0.0)";
	ui_category = "Weapon Hand Adjust";
> = float3(0.0,0.0,0.0);

uniform float2 WZPD_and_WND <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.5;
	ui_label = " Weapon ZPD and Near Depth";
	ui_tooltip = "WZPD controls the focus distance for the screen Pop-out effect also known as Convergence for the weapon hand.\n"
				"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
				"This is controlled by Convergence Mode.\n"
				"Default is (X 0.03, Y 0.0) & Zero is off.";
	ui_category = "Weapon Hand Adjust";
> = float2(0.03,DE_W);

uniform int FPSDFIO <
	ui_type = "combo";
	ui_items = "Off\0Press\0Hold Down\0";
	ui_label = " FPS Focus Depth";
	ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
				 "This may induce Eye Strain so take this as an Warning.";
	ui_category = "Weapon Hand Adjust";
> = 0;

uniform int2 Eye_Fade_Reduction_n_Power <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 2;
	ui_label = " Eye Selection & Fade Reduction";
	ui_tooltip = "Fade Reduction decreases the depth amount by a current percentage.\n"
							 "One is Right Eye only, Two is Left Eye Only, and Zero Both Eyes.\n"
							 "Default is int( X 0 , Y 0 ).";
	ui_category = "Weapon Hand Adjust";
> = int2(0,0);

uniform float Weapon_ZPD_Boundary <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 0.5;
	ui_label = " Weapon Screen Boundary Detection";
	ui_tooltip = "This selection menu gives extra boundary conditions to WZPD.";
	ui_category = "Weapon Hand Adjust";
> = DF_X;
#if HUD_MODE || HM
//Heads-Up Display
uniform float2 HUD_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "·HUD Mode·";
	ui_tooltip = "Adjust HUD for your games.\n"
				 "X, CutOff Point used to set a separation point between world scale and the HUD also used to turn HUD MODE On or Off.\n"
				 "Y, Pushes or Pulls the HUD in or out of the screen if HUD MODE is on.\n"
				 "This is only for UI elements that show up in the Depth Buffer.\n"
	             "Default is float2(X 0.0, Y 0.5)";
	ui_category = "Heads-Up Display";
> = float2(DC_X,0.5);
#endif
//Stereoscopic Options//
uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Anaglyph 3D Red/Cyan\0Anaglyph 3D Red/Cyan Dubois\0Anaglyph 3D Red/Cyan Anachrome\0Anaglyph 3D Green/Magenta\0Anaglyph 3D Green/Magenta Dubois\0Anaglyph 3D Green/Magenta Triochrome\0Anaglyph 3D Blue/Amber ColorCode\0";
	ui_label = "·3D Display Modes·";
	ui_tooltip = "Stereoscopic 3D display output selection.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform float2 Interlace_Anaglyph <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Interlace & Anaglyph";
	ui_tooltip = "Interlace Optimization is used to reduce aliasing in a Line or Column interlaced image. This has the side effect of softening the image.\n"
	             "Anaglyph Desaturation allows for removing color from an anaglyph 3D image. Zero is Black & White, One is full color.\n"
	             "Default for Interlace Optimization is 0.5 and for Anaglyph Desaturation is One.";
	ui_category = "Stereoscopic Options";
> = float2(0.5,1.0);
#if Ven
uniform int Scaling_Support <
	ui_type = "combo";
	ui_items = "SR Native\0SR 2160p A\0SR 2160p B\0SR 1080p A\0SR 1080p B\0SR 1050p A\0SR 1050p B\0SR 720p A\0SR 720p B\0";
	ui_label = " Scaling Support";
	ui_tooltip = "Dynamic Super Resolution scaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.\n"
				 "Set this to your native Screen Resolution A or B, DSR Smoothing must be set to 0%.\n"
				 "This does not work with a hardware ware scaling done by VSR.\n"
				 "Default is SR Native.";
	ui_category = "Stereoscopic Options";
> = 0;
#else
static const int Scaling_Support = 0;
#endif
uniform int Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = " Perspective Slider";
	ui_tooltip = "Determines the perspective point of the two images this shader produces.\n"
				 "For an HMD, use Polynomial Barrel Distortion shader to adjust for IPD.\n"
				 "Do not use this perspective adjustment slider to adjust for IPD.\n"
				 "Default is Zero.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform bool Eye_Swap <
	ui_label = " Swap Eyes";
	ui_tooltip = "L/R to R/L.";
	ui_category = "Stereoscopic Options";
> = false;
//Cursor Adjustments
uniform int Cursor_Type <
	ui_type = "combo";
	ui_items = "Off\0FPS\0ALL\0RTS\0";
	ui_label = "·Cursor Selection·";
	ui_tooltip = "Choose the cursor type you like to use.\n"
							 "Default is Zero.";
	ui_category = "Cursor Adjustments";
> = 0;

uniform int2 Cursor_SC <
	ui_type = "drag";
	ui_min = 0; ui_max = 10;
	ui_label = " Cursor Adjustments";
	ui_tooltip = "This controlls the Size & Color.\n"
							 "Defaults are ( X 1, Y 2 ).";
	ui_category = "Cursor Adjustments";
> = int2(1,0);

uniform bool Cursor_Lock <
	ui_label = " Cursor Lock";
	ui_tooltip = "Screen Cursor to Screen Crosshair Lock.";
	ui_category = "Cursor Adjustments";
> = false;
#if BD_Correction
uniform float2 Colors_K1_K2 <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = -1.0; ui_max = 1.0;
	ui_tooltip = "Adjust the Distortion K1 & K2.\n"
				 "Default is 0.0";
	ui_label = "·Distortion K1 & K2·";
	ui_category = "Image Distortion Corrections";
> = float2(DC_Y,DC_Z);

uniform float Zoom <
	ui_type = "drag";
	ui_min = -0.5; ui_max = 0.5;
	ui_label = " BD Zoom";
	ui_category = "Image Distortion Corrections";
> = DC_W;
#else
static const float2 Colors_K1_K2 = float2(DC_Y,DC_Z);
static const float Zoom = DC_W;
#endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; mode = "toggle";>;
uniform bool Mask_Cycle < source = "key"; keycode = Mask_Cycle_Key; toggle = true; mode = "toggle";>;
uniform bool CLK < source = "mousebutton"; keycode = Cursor_Lock_Key; toggle = true; mode = "toggle";>;
uniform bool Trigger_Fade_A < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
uniform bool Trigger_Fade_B < source = "mousebutton"; keycode = Fade_Key;>;
uniform float2 Mousecoords < source = "mousepoint"; > ;
uniform float frametime < source = "frametime";>;
uniform float timer < source = "timer"; >;

static const float Auto_Balance_Clamp = 0.5; //This Clamps Auto Balance's max Distance.

#if !Compatibility
uniform bool DepthCheck < source = "bufready_depth"; >;
#endif

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define Per float2( (Perspective * pix.x) * 0.5, 0) //Per is Perspective
#define AI Interlace_Anaglyph.x * 0.5 //Optimization for line interlaced Adjustment.

float fmod(float a, float b)
{
	float c = frac(abs(a / b)) * abs(b);
	return a < 0 ? -c : c;
}
///////////////////////////////////////////////////////////////3D Starts Here/////////////////////////////////////////////////////////////////
texture DepthBufferTex : DEPTH;
sampler DepthBuffer
	{
		Texture = DepthBufferTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

texture BackBufferTex : COLOR;
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

texture texDMN { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = RGBA16F; };

sampler SamplerDMN
	{
		Texture = texDMN;
	};

texture texzBufferN { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = RG16F; };

sampler SamplerzBufferN
	{
		Texture = texzBufferN;
	};

#if UI_MASK
texture TexMaskA < source = "DM_Mask_A.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler SamplerMaskA { Texture = TexMaskA;};
texture TexMaskB < source = "DM_Mask_B.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler SamplerMaskB { Texture = TexMaskB;};
#endif
////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////
texture texLumN {Width = 256*0.5; Height = 256*0.5; Format = RGBA16F; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1

sampler SamplerLumN
	{
		Texture = texLumN;
	};

float2 Lum(float2 texcoord)
	{   //Luminance
		return saturate(tex2Dlod(SamplerLumN,float4(texcoord,0,11)).xy);//Average Luminance Texture Sample
	}
////////////////////////////////////////////////////Distortion Correction//////////////////////////////////////////////////////////////////////
#if BD_Correction || DC
float2 D(float2 p, float k1, float k2) //Lens + Radial lens undistort filtering Left & Right
{	// Normalize the u,v coordinates in the range [-1;+1]
	p = (2. * p - 1.);
	// Calculate Zoom
	p *= 1 + Zoom;
	// Calculate l2 norm
	float r2 = p.x*p.x + p.y*p.y;
	float r4 = pow(r2,2.);
	// Forward transform
	float x2 = p.x * (1. + k1 * r2 + k2 * r4);
	float y2 = p.y * (1. + k1 * r2 + k2 * r4);
	// De-normalize to the original range
	p.x = (x2 + 1.) * 1. * 0.5;
	p.y = (y2 + 1.) * 1. * 0.5;

return p;
}

float3 PBD(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float2 K1_K2 = Colors_K1_K2.xy * 0.1;
	float2 uv = D(texcoord.xy,K1_K2.x,K1_K2.y);

return tex2D(BackBufferCLAMP,uv).rgb;
}
#endif
///////////////////////////////////////////////////////////3D Image Adjustments/////////////////////////////////////////////////////////////////////
float4 CSB(float2 texcoords)
{
	if(Custom_Sidebars == 0 && Depth_Map_View == 0)
		return tex2Dlod(BackBufferMIRROR,float4(texcoords,0,0));
	else if(Custom_Sidebars == 1 && Depth_Map_View == 0)
		return tex2Dlod(BackBufferBORDER,float4(texcoords,0,0));
	else if(Custom_Sidebars == 2 && Depth_Map_View == 0)
		return tex2Dlod(BackBufferCLAMP,float4(texcoords,0,0));
	else
		return tex2D(SamplerzBufferN,texcoords).xxxx;
}
/////////////////////////////////////////////////////////////Cursor///////////////////////////////////////////////////////////////////////////
float4 MouseCursor(float2 texcoord )
{   float4 Out = CSB(texcoord),Color;
		float A = 0.959375, B = 1-A;
		float Cursor;
		if(Cursor_Type > 0)
		{
			float CCA = 0.005, CCB = 0.00025, CCC = 0.25, CCD = 0.00125, Arrow_Size_A = 0.7, Arrow_Size_B = 1.3, Arrow_Size_C = 4.0;//scaling
			float2 MousecoordsXY = Mousecoords * pix, center = texcoord, Screen_Ratio = float2(1.75,1.0), Size_Color = float2(1+Cursor_SC.x,Cursor_SC.y);
			float THICC = (1.5+Size_Color.x) * CCB, Size = Size_Color.x * CCA, Size_Cubed = (Size_Color.x*Size_Color.x) * CCD;

			if (Cursor_Lock && !CLK)
			MousecoordsXY = float2(0.5,0.5);
			if (Cursor_Type == 3)
			Screen_Ratio = float2(1.6,1.0);

			float S_dist_fromHorizontal = abs((center.x - (Size* Arrow_Size_B) / Screen_Ratio.x) - MousecoordsXY.x) * Screen_Ratio.x, dist_fromHorizontal = abs(center.x - MousecoordsXY.x) * Screen_Ratio.x ;
			float S_dist_fromVertical = abs((center.y - (Size* Arrow_Size_B)) - MousecoordsXY.y), dist_fromVertical = abs(center.y - MousecoordsXY.y);

			//Cross Cursor
			float B = min(max(THICC - dist_fromHorizontal,0),max(Size-dist_fromVertical,0)), A = min(max(THICC - dist_fromVertical,0),max(Size-dist_fromHorizontal,0));
			float CC = A+B; //Cross Cursor

			//Solid Square Cursor
			float SSC = min(max(Size_Cubed - dist_fromHorizontal,0),max(Size_Cubed-dist_fromVertical,0)); //Solid Square Cursor

			if (Cursor_Type == 3)
			{
				dist_fromHorizontal = abs((center.x - Size / Screen_Ratio.x) - MousecoordsXY.x) * Screen_Ratio.x ;
				dist_fromVertical = abs(center.y - Size - MousecoordsXY.y);
			}
			//Cursor
			float C = all(min(max(Size - dist_fromHorizontal,0),max(Size-dist_fromVertical,0)));//removing the line below removes the square.
				  C -= all(min(max(Size - dist_fromHorizontal * Arrow_Size_C,0),max(Size - dist_fromVertical * Arrow_Size_C,0)));//Need to add this to fix a - bool issue in openGL
				  C -= all(min(max((Size * Arrow_Size_A) - S_dist_fromHorizontal,0),max((Size * Arrow_Size_A)-S_dist_fromVertical,0)));
			// Cursor Array //
			if(Cursor_Type == 1)
				Cursor = CC;
			else if (Cursor_Type == 2)
				Cursor = SSC;
			else if (Cursor_Type == 3)
				Cursor = C;

			// Cursor Color Array //
			float3 CCArray[11] = {
			float3(1,1,1),//White
			float3(0,0,1),//Blue
			float3(0,1,0),//Green
			float3(1,0,0),//Red
			float3(1,0,1),//Magenta
			float3(0,1,1),
			float3(1,1,0),
			float3(1,0.4,0.7),
			float3(1,0.64,0),
			float3(0.5,0,0.5),
			float3(0,0,0) //Black
			};
			int CSTT = clamp(Cursor_SC.y,0,10);
			Color.rgb = CCArray[CSTT];
		}

return Cursor ? Color : Out;
}
//////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////
float Depth(float2 texcoord)
{
	#if DB_Size_Postion || SP
	float2 texXY = texcoord + Image_Position_Adjust * pix;
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);
	#endif
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
	//Conversions to linear space.....
	float zBuffer = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x, Far = 1., Near = 0.125/Depth_Map_Adjust; //Near & Far Adjustment

	float2 C = float2( Far / Near, 1. - Far / Near ), Offsets = float2(1 + Offset,1 - Offset), Z = float2( zBuffer, 1-zBuffer );

	if (Offset > 0)
		Z = min( 1., float2( Z.x * Offsets.x , Z.y / Offsets.y  ));
	//MAD - RCP
	if (Depth_Map == 0) //DM0 Normal
		zBuffer = rcp(Z.x * C.y + C.x);
	else if (Depth_Map == 1) //DM1 Reverse
		zBuffer = rcp(Z.y * C.y + C.x);
	return saturate(zBuffer);
}
//////////////////////////////////////////////////////////////Depth HUD Alterations///////////////////////////////////////////////////////////////////////
#if UI_MASK
float HUD_Mask(float2 texcoord )
{   float Mask_Tex;
	    if (Mask_Cycle == 1)
	        Mask_Tex = tex2Dlod(SamplerMaskB,float4(texcoord.xy,0,0)).a;
	    else
	        Mask_Tex = tex2Dlod(SamplerMaskA,float4(texcoord.xy,0,0)).a;

	return saturate(Mask_Tex);
}
#endif
/////////////////////////////////////////////////////////Fade In and Out Toggle/////////////////////////////////////////////////////////////////////
float Fade_in_out(float2 texcoord)
{ float Trigger_Fade, AA = (1-Fade_Time_Adjust)*1000, PStoredfade = tex2D(SamplerLumN,texcoord - 1).z;
	//Fade in toggle.
	if(FPSDFIO == 1)
		Trigger_Fade = Trigger_Fade_A;
	else if(FPSDFIO == 2)
		Trigger_Fade = Trigger_Fade_B;

	return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/AA)); ///exp2 would be even slower
}

float Fade(float2 texcoord)
{ //Check Depth
	float CD, Detect;
	if(ZPD_Boundary > 0)
	{   //Normal A & B for both
		float CDArray_A[7] = { 0.125 ,0.25, 0.375,0.5, 0.625, 0.75, 0.875};
		float CDArray_B[7] = { 0.25 ,0.375, 0.4375, 0.5, 0.5625, 0.625, 0.75};
		float CDArrayZPD[7] = { ZPD * 0.3, ZPD * 0.5, ZPD * 0.75, ZPD, ZPD * 0.75, ZPD * 0.5, ZPD * 0.3 };
		float2 GridXY;
		//Screen Space Detector 7x7 Grid from between 0 to 1 and ZPD Detection becomes stronger as it gets closer to the Center.
		[unroll]
		for( int i = 0 ; i < 7; i++ )
		{
			for( int j = 0 ; j < 7; j++ )
			{
				if(ZPD_Boundary == 1)
				{   GridXY = float2( CDArray_A[i], CDArray_A[j]);
					#if UI_MASK
						CD = max(1 - CDArrayZPD[i] / HUD_Mask(GridXY),1 - CDArrayZPD[i] / Depth( GridXY ));
					#else
						CD = 1 - CDArrayZPD[i] / Depth( GridXY );
					#endif
				}
				else if(ZPD_Boundary == 2 )
				{   GridXY = float2( CDArray_B[i], CDArray_B[j]);
					#if UI_MASK
						CD = max(1 - CDArrayZPD[i] / HUD_Mask(GridXY),1 - CDArrayZPD[i] / Depth( GridXY ));
					#else
						CD = 1 - CDArrayZPD[i] / Depth( GridXY );
					#endif
				}
				else if(ZPD_Boundary == 3)
				{   GridXY = float2( CDArray_A[i], CDArray_B[j]);
					CD = max(1 - CDArrayZPD[i] / saturate(tex2Dlod(SamplerDMN,float4( GridXY ,0,0)).y),1 - CDArrayZPD[i] / Depth( GridXY ));
				}
				else
				{   GridXY = float2( CDArray_B[i], CDArray_B[j]);
					CD = max(1 - CDArrayZPD[i] / saturate(tex2Dlod(SamplerDMN,float4( GridXY ,0,0)).y),1 - CDArrayZPD[i] / Depth( GridXY ));
				}

				if (CD < 0)
					Detect = 1;
			}
		}
	}
	float Trigger_Fade = Detect, AA = (1-(ZPD_Boundary_n_Fade.y*2.))*1000, PStoredfade = tex2Dlod(SamplerLumN,float4(texcoord + 1,0,0)).z;
	//Fade in toggle.
	return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/AA)); ///exp2 would be even slower
}
//////////////////////////////////////////////////////////Depth Map Alterations/////////////////////////////////////////////////////////////////////
float2 WeaponDepth(float2 texcoord)
{
	#if DB_Size_Postion || SP
	float2 texXY = texcoord + Image_Position_Adjust * pix;
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);
	#endif
	//Weapon Setting//
	float3 WA_XYZ = Weapon_Adjust;
	#if WSM >= 1
		WA_XYZ = Weapon_Profiles(WP, Weapon_Adjust);
	#endif
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
	//Conversions to linear space.....
	float zBufferWH = tex2D(DepthBuffer, texcoord).x, Far = 1.0, Near = 0.125/WA_XYZ.y;  //Near & Far Adjustment

	float2 Offsets = float2(1 + WA_XYZ.z,1 - WA_XYZ.z), Z = float2( zBufferWH, 1-zBufferWH );

	if (WA_XYZ.z > 0)
	Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));

	[branch] if (Depth_Map == 0)//DM0. Normal
		zBufferWH = Far * Near / (Far + Z.x * (Near - Far));
	else if (Depth_Map == 1)//DM1. Reverse
		zBufferWH = Far * Near / (Far + Z.y * (Near - Far));

	return float2(saturate(zBufferWH), WA_XYZ.x);
}

float3 DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
	float4 DM = Depth(texcoord).xxxx;
	float R, G, B, WD = WeaponDepth(texcoord).x, CoP = WeaponDepth(texcoord).y, CutOFFCal = (CoP/Depth_Map_Adjust) * 0.5; //Weapon Cutoff Calculation
	CutOFFCal = step(DM.x,CutOFFCal);

	[branch] if (WP == 0)
	{
		DM.x = DM.x;
	}
	else
	{
		DM.x = lerp(DM.x,WD,CutOFFCal);
		DM.y = lerp(0.0,WD,CutOFFCal);
		DM.z = lerp(0.5,WD,CutOFFCal);
	}

	R = DM.x; //Mix Depth
	G = DM.y > smoothstep(0,2.5,DM.w); //Weapon Mask
	B = DM.z; //Weapon Hand
	//A = DM.w; //Normal Depth
	//Fade Storage
	float ScaleND = lerp(R,1,smoothstep(-WZPD_and_WND.y,1,R));

	if (WZPD_and_WND.y > 0)
		R = lerp(ScaleND,R,smoothstep(0,0.25,ScaleND));

	if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
		R = Fade_in_out(texcoord);
	if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
		R = Fade(texcoord);
	//Alpha Don't work in DX9
	return saturate(float3(R,G,B));
}

float AutoDepthRange(float d, float2 texcoord )
{ float LumAdjust_ADR = smoothstep(-0.0175,Auto_Depth_Adjust,Lum(texcoord).y);
	if (RE)
		LumAdjust_ADR = smoothstep(-0.0175,Auto_Depth_Adjust,Lum(texcoord).x);

    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
}
#if RE_Fix || RE
float AutoZPDRange(float ZPD, float2 texcoord )
{   //Adjusted to only effect really intense differences.
	float LumAdjust_AZDPR = smoothstep(-0.0175,0.1875,Lum(texcoord).y);
	if(RE_Fix == 2 || RE == 2)
		LumAdjust_AZDPR = smoothstep(0,0.075,Lum(texcoord).y);
    return saturate(LumAdjust_AZDPR * ZPD);
}
#endif
float2 Conv(float D,float2 texcoord)
{	float Z = ZPD, WZP = 0.5, ZP = 0.5, ALC = abs(Lum(texcoord).x), W_Convergence = WZPD_and_WND.x, WZPDB, Distance_From_Bottom = 0.9375;
    //Screen Space Detector.
	if (abs(Weapon_ZPD_Boundary) > 0)
	{   float WArray[8] = { 0.5, 0.5625, 0.625, 0.6875, 0.75, 0.8125, 0.875, 0.9375};
		float MWArray[8] = { 0.4375, 0.46875, 0.5, 0.53125, 0.625, 0.75, 0.875, 0.9375};
		float WZDPArray[8] = { 1.0, 0.5, 0.75, 0.5, 0.625, 0.5, 0.55, 0.5};//SoF ZPD Weapon Map
		[unroll] //only really only need to check one point just above the center bottom and to the right.
		for( int i = 0 ; i < 8; i++ )
		{
			if(WP == 22 || WP == 4)//SoF & BL 2
				WZPDB = 1 - (WZPD_and_WND.x * WZDPArray[i]) / tex2Dlod(SamplerDMN,float4(float2(WArray[i],0.9375),0,0)).z;
			else
			{
				if (Weapon_ZPD_Boundary < 0) //Code for Moving Weapon Hand stablity.
					WZPDB = 1 - WZPD_and_WND.x / tex2Dlod(SamplerDMN,float4(float2(MWArray[i],Distance_From_Bottom),0,0)).z;
				else //Normal
					WZPDB = 1 - WZPD_and_WND.x / tex2Dlod(SamplerDMN,float4(float2(WArray[i],Distance_From_Bottom),0,0)).z;
			}

			if (WZPDB < -0.1)
				W_Convergence *= 1.0-abs(Weapon_ZPD_Boundary);
		}
	}

	W_Convergence = 1 - W_Convergence / D;
	float WD = D; //Needed to seperate Depth for the  Weapon Hand. It was causing problems with Auto Depth Range below.

	#if RE_Fix || RE
		Z = AutoZPDRange(Z,texcoord);
	#endif
		if (Auto_Depth_Adjust > 0)
			D = AutoDepthRange(D,texcoord);

	#if Balance_Mode
			ZP = saturate(ZPD_Balance);
	#else
		if(Auto_Balance_Ex > 0 )
			ZP = saturate(ALC);
	#endif
		Z *= lerp( 1, ZPD_Boundary_n_Fade.x, smoothstep(0,1,tex2Dlod(SamplerLumN,float4(texcoord + 1,0,0)).z));
		float Convergence = 1 - Z / D;
		if (ZPD == 0)
			ZP = 1;

		if (WZPD_and_WND.x <= 0)
			WZP = 1;

		if (ALC <= 0.025)
			WZP = 1;

		ZP = min(ZP,Auto_Balance_Clamp);

    return float2(lerp(Convergence,D, ZP),lerp(W_Convergence,WD,WZP));
}

float DB( float2 texcoord)
{
	// X = Mix Depth | Y = Weapon Mask | Z = Weapon Hand
	float3 DM = tex2Dlod(SamplerDMN,float4(texcoord,0,0)).xyz;
	//Hide Temporal passthrough
	if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
		DM = Depth(texcoord);
	if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
		DM = Depth(texcoord);

	if (WP == 0 || WZPD_and_WND.x <= 0)
		DM.y = 0;

	DM.y = lerp(Conv(DM.x,texcoord).x, Conv(DM.z,texcoord).y, DM.y);

	#if !Compatibility_DD
	if (Depth_Detection == 1 || Depth_Detection == 2)
	{ //Check Depth at 3 Point D_A Top_Center / Bottom_Center
		float D_A = tex2Dlod(SamplerDMN,float4(float2(0.5,0.0),0,0)).x, D_B = tex2Dlod(SamplerDMN,float4(float2(0.0,1.0),0,0)).x;
		if(Depth_Detection == 2)
		{
			if (D_A == D_B)
				DM = 0.0625;
		}
		else
		{   //Ignores Sky
			if (D_A != 1 && D_B != 1)
			{
				if (D_A == D_B)
					DM = 0.0625;
			}
		}
	}
	else if (Depth_Detection == 3)
	{
		if (!DepthCheck)
			DM = 0.0625;
	}
	#else
	if (Depth_Detection == 1 || Depth_Detection == 2)
	{ //Check Depth at 3 Point D_A Top_Center / Bottom_Center
		float D_A = tex2Dlod(SamplerDMN,float4(float2(0.5,0.0),0,0)).x, D_B = tex2Dlod(SamplerDMN,float4(float2(0.0,1.0),0,0)).x;
		if(Depth_Detection == 2)
		{
			if (D_A == D_B)
				DM = 0.0625;
		}
		else
		{   //Ignores Sky
			if (D_A != 1 && D_B != 1)
			{
				if (D_A == D_B)
					DM = 0.0625;
			}
		}
	}
	#endif

	if (Cancel_Depth)
		DM = 0.0625;

	#if Invert_Depth || ID
		DM.y = 1 - DM.y;
	#endif

	#if UI_MASK
		return lerp(DM.y,0,step(1.0-HUD_Mask(texcoord),0.5));
	#else
		return DM.y;
	#endif
}
//////////////////////////////////////////////////////////Depth Edge Trimming///////////////////////////////////////////////////////////////////////
float2 zBuffer(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{   float Mask = DB( texcoord.xy );
	if(Depth_Edge_Mask > 0 || Depth_Edge_Mask < 0)
	{
		float t = DB( float2( texcoord.x , texcoord.y - pix.y ) ),
			  d = DB( float2( texcoord.x , texcoord.y + pix.y ) ),
			  l = DB( float2( texcoord.x - pix.x , texcoord.y ) ),
			  r = DB( float2( texcoord.x + pix.x , texcoord.y ) );
		float2 n = float2(t - d,-(r - l));
		// Lets make that mask from Edges
		Mask = length(n)*abs(Depth_Edge_Mask);
		Mask = Mask > 0 ? 1-Mask : 1;
		Mask = saturate(lerp(Mask,1,-1));// Super Evil Mix.
		// Final Depth
		if(Depth_Edge_Mask > 0)
			Mask = lerp(0,DB( texcoord.xy ),Mask);
		else if(Depth_Edge_Mask < 0)
			Mask = lerp(1,DB( texcoord.xy ),Mask);
	}

return Depth_Edge_Mask < 0 ? float2(DB( texcoord.xy ),Mask) : float2(Mask,Mask);
}

float2 GetDB(float2 texcoord)
{
	return tex2Dlod(SamplerzBufferN, float4(texcoord,0,0) ).xy;
}

//////////////////////////////////////////////////////////Parallax Generation///////////////////////////////////////////////////////////////////////
float2 Parallax(float Diverge, float2 Coordinates, float IO) // Horizontal parallax offset & Hole filling effect
{   float2 ParallaxCoord = Coordinates;
	float DepthLR = 1, DLR, LRDepth, Perf = 1, Z, MS = Diverge * pix.x, N , S[9] = {0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1.0};
	#if Legacy_Mode
	MS = -MS;
	[loop]//ParallaxCoord.x += MS * 0.2;
	for ( int i = 0 ; i <= 8; ++i )
	{   N = S[i] * MS;
		if(View_Mode == 1)
		{   LRDepth =  min(DepthLR, GetDB(float2(ParallaxCoord.x + N, ParallaxCoord.y)).x );
			DLR = LRDepth;
			LRDepth += min(DepthLR, GetDB(float2(ParallaxCoord.x + (N * 0.75f), ParallaxCoord.y)).x );
			LRDepth += min(DepthLR, GetDB(float2(ParallaxCoord.x + (N * 0.500f), ParallaxCoord.y)).x );
			LRDepth += min(DepthLR, GetDB(float2(ParallaxCoord.x + (N * 0.250f), ParallaxCoord.y)).x );
			DepthLR = min(DepthLR,LRDepth / 4.0f);

			DepthLR = lerp(DepthLR, DLR, 0.1875f);
		}
		else
		DepthLR = min(DepthLR, GetDB(float2(ParallaxCoord.x + N, ParallaxCoord.y)).x );
	}
	//Reprojection Left and Right
	ParallaxCoord = float2(Coordinates.x + MS * DepthLR, Coordinates.y);
	#else
	if(Performance_Mode)
		Perf = .5;
	//ParallaxSteps Calculations
	float D = abs(Diverge), Cal_Steps = (D * Perf) + (D * 0.04), Steps = clamp(Cal_Steps,0,255);
	// Offset per step progress & Limit
	float LayerDepth = rcp(Steps), TP = 0.03;
	//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
	float deltaCoordinates = MS * LayerDepth, CurrentDepthMapValue = GetDB(ParallaxCoord).x, CurrentLayerDepth = 0, DepthDifference;
	float2 DB_Offset = float2(Diverge * TP, 0) * pix;

    if(View_Mode == 1)
    	DB_Offset = 0;
	#if !Compatibility
	[loop] //Steep parallax mapping
	while ( CurrentDepthMapValue > CurrentLayerDepth)
	{   // Shift coordinates horizontally in linear fasion
	    ParallaxCoord.x -= deltaCoordinates;
	    // Get depth value at current coordinates
	    CurrentDepthMapValue = GetDB(float2(ParallaxCoord - DB_Offset)).x;
	    // Get depth of next layer
	    CurrentLayerDepth += LayerDepth;
		continue;
	}
	#else
	[loop] //Steep parallax mapping
	for ( int i = 0; i < Steps; i++ )
	{   // Doing it this way should stop crashes in older version of reshade, I hope.
			if(CurrentDepthMapValue < CurrentLayerDepth)
				break; // Once we hit the limit Stop Exit Loop.
			// Shift coordinates horizontally in linear fasion
			ParallaxCoord.x -= deltaCoordinates;
			// Get depth value at current coordinates
			CurrentDepthMapValue = GetDB(ParallaxCoord - DB_Offset).x;
			// Get depth of next layer
			CurrentLayerDepth += LayerDepth;
	}
	#endif
	// Parallax Occlusion Mapping
	float2 PrevParallaxCoord = float2(ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y);
	float beforeDepthValue = GetDB(ParallaxCoord ).y, afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
		beforeDepthValue += LayerDepth - CurrentLayerDepth;
	// Interpolate coordinates
	float weight = afterDepthValue / (afterDepthValue - beforeDepthValue);
		ParallaxCoord = PrevParallaxCoord * weight + ParallaxCoord * (1. - weight);
	//This is to limit artifacts.
	if(View_Mode == 0)
		ParallaxCoord += DB_Offset * 0.5;
	// Apply gap masking
	DepthDifference = (afterDepthValue-beforeDepthValue) * MS;
	if(View_Mode == 1)
		ParallaxCoord.x -= DepthDifference;
	#endif
	if(Stereoscopic_Mode == 2)
		ParallaxCoord.y += IO * pix.y; //Optimization for line interlaced.
	else if(Stereoscopic_Mode == 3)
		ParallaxCoord.x += IO * pix.x; //Optimization for column interlaced.

	return ParallaxCoord;
}
//////////////////////////////////////////////////////////////HUD Alterations///////////////////////////////////////////////////////////////////////
#if HUD_MODE || HM
float3 HUD(float3 HUD, float2 texcoord )
{
	float Mask_Tex, CutOFFCal = ((HUD_Adjust.x * 0.5)/Depth_Map_Adjust) * 0.5, COC = step(Depth(texcoord).x,CutOFFCal); //HUD Cutoff Calculation
	//This code is for hud segregation.
	if (HUD_Adjust.x > 0)
		HUD = COC > 0 ? tex2D(BackBufferCLAMP,texcoord).rgb : HUD;

	#if UI_MASK
	    if (Mask_Cycle == 1)
	        Mask_Tex = tex2Dlod(SamplerMaskB,float4(texcoord.xy,0,0)).a;
	    else
	        Mask_Tex = tex2Dlod(SamplerMaskA,float4(texcoord.xy,0,0)).a;

		float MAC = step(1.0-Mask_Tex,0.5); //Mask Adjustment Calculation
		//This code is for hud segregation.
		HUD = MAC > 0 ? tex2D(BackBufferCLAMP,texcoord).rgb : HUD;
	#endif
	return HUD;
}
#endif
///////////////////////////////////////////////////////////Stereo Calculation///////////////////////////////////////////////////////////////////////
float3 PS_calcLR(float2 texcoord)
{
	float2 TCL, TCR, TexCoords = texcoord;

	[branch] if (Stereoscopic_Mode == 0)
	{
		TCL = float2(texcoord.x*2,texcoord.y);
		TCR = float2(texcoord.x*2-1,texcoord.y);
	}
	else if(Stereoscopic_Mode == 1)
	{
		TCL = float2(texcoord.x,texcoord.y*2);
		TCR = float2(texcoord.x,texcoord.y*2-1);
	}
	else
	{
		TCL = float2(texcoord.x,texcoord.y);
		TCR = float2(texcoord.x,texcoord.y);
	}

	TCL += Per;
	TCR -= Per;

	float D = Divergence;
	if (Eye_Swap)
		D = -Divergence;

	float FadeIO = smoothstep(0,1,1-Fade_in_out(texcoord).x), FD = D, FD_Adjust = 0.1;

	if( Eye_Fade_Reduction_n_Power.y == 1)
		FD_Adjust = 0.2;
	else if( Eye_Fade_Reduction_n_Power.y == 2)
		FD_Adjust = 0.3;

	if (FPSDFIO == 1 || FPSDFIO == 2)
		FD = lerp(FD * FD_Adjust,FD,FadeIO);

	float2 DLR = float2(FD,FD);
	if( Eye_Fade_Reduction_n_Power.x == 1)
			DLR = float2(D,FD);
	else if( Eye_Fade_Reduction_n_Power.x == 2)
			DLR = float2(FD,D);

	float4 image = 1, accum, color, Left = MouseCursor(Parallax(-DLR.x, TCL, AI)), Right = MouseCursor(Parallax(DLR.y, TCR, -AI));

	#if HUD_MODE || HM
	float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25.) * pix.x;
	Left.rgb = HUD(Left.rgb,float2(TCL.x - HUD_Adjustment,TCL.y)).rgb;
	Right.rgb = HUD(Right.rgb,float2(TCR.x + HUD_Adjustment,TCR.y)).rgb;
	#endif

	float2 gridxy, GXYArray[9] = {
		float2(TexCoords.x * BUFFER_WIDTH, TexCoords.y * BUFFER_HEIGHT), //Native
		float2(TexCoords.x * 3840.0, TexCoords.y * 2160.0),
		float2(TexCoords.x * 3841.0, TexCoords.y * 2161.0),
		float2(TexCoords.x * 1920.0, TexCoords.y * 1080.0),
		float2(TexCoords.x * 1921.0, TexCoords.y * 1081.0),
		float2(TexCoords.x * 1680.0, TexCoords.y * 1050.0),
		float2(TexCoords.x * 1681.0, TexCoords.y * 1051.0),
		float2(TexCoords.x * 1280.0, TexCoords.y * 720.0),
		float2(TexCoords.x * 1281.0, TexCoords.y * 721.0)
	};
	gridxy = floor(GXYArray[Scaling_Support]);

	if(Stereoscopic_Mode == 0)
		color = TexCoords.x < 0.5 ? Left : Right;
	else if(Stereoscopic_Mode == 1)
		color = TexCoords.y < 0.5 ? Left : Right;
	else if(Stereoscopic_Mode == 2)
		color = fmod(gridxy.y,2.0) ? Right : Left;
	else if(Stereoscopic_Mode == 3)
		color = fmod(gridxy.x,2.0) ? Right : Left;
	else if(Stereoscopic_Mode == 4)
		color = fmod(gridxy.x+gridxy.y,2.0) ? Right : Left;
	else if(Stereoscopic_Mode >= 5)
	{
		float Contrast = 1.0, DeGhost = 0.06, LOne, ROne;
		float3 HalfLA = dot(Left.rgb,float3(0.299, 0.587, 0.114)), HalfRA = dot(Right.rgb,float3(0.299, 0.587, 0.114));
		float3 LMA = lerp(HalfLA,Left.rgb,Interlace_Anaglyph.y), RMA = lerp(HalfRA,Right.rgb,Interlace_Anaglyph.y);

		float contrast = (Contrast*0.5)+0.5;

		// Left/Right Image
		float4 cA = float4(LMA,1);
		float4 cB = float4(RMA,1);

		if (Stereoscopic_Mode == 5) // Anaglyph 3D Colors Red/Cyan
			color =  float4(cA.r,cB.g,cB.b,1.0);
		else if (Stereoscopic_Mode == 6) // Anaglyph 3D Dubois Red/Cyan
		{
		float red = 0.437 * cA.r + 0.449 * cA.g + 0.164 * cA.b - 0.011 * cB.r - 0.032 * cB.g - 0.007 * cB.b;

			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = -0.062 * cA.r -0.062 * cA.g -0.024 * cA.b + 0.377 * cB.r + 0.761 * cB.g + 0.009 * cB.b;

			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.048 * cA.r - 0.050 * cA.g - 0.017 * cA.b -0.026 * cB.r -0.093 * cB.g + 1.234  * cB.b;

			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }

			color = float4(red, green, blue, 0);
		}
		else if (Stereoscopic_Mode == 7) // Anaglyph 3D Deghosted Red/Cyan Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
		{
			LOne = contrast*0.45;
			ROne = contrast;
			DeGhost *= 0.1;

			accum = saturate(cA*float4(LOne,(1.0-LOne)*0.5,(1.0-LOne)*0.5,1.0));
			image.r = pow(accum.r+accum.g+accum.b, 1.00);
			image.a = accum.a;

			accum = saturate(cB*float4(1.0-ROne,ROne,0.0,1.0));
			image.g = pow(accum.r+accum.g+accum.b, 1.15);
			image.a = image.a+accum.a;

			accum = saturate(cB*float4(1.0-ROne,0.0,ROne,1.0));
			image.b = pow(accum.r+accum.g+accum.b, 1.15);
			image.a = (image.a+accum.a)/3.0;

			accum = image;
			image.r = (accum.r+(accum.r*DeGhost)+(accum.g*(DeGhost*-0.5))+(accum.b*(DeGhost*-0.5)));
			image.g = (accum.g+(accum.r*(DeGhost*-0.25))+(accum.g*(DeGhost*0.5))+(accum.b*(DeGhost*-0.25)));
			image.b = (accum.b+(accum.r*(DeGhost*-0.25))+(accum.g*(DeGhost*-0.25))+(accum.b*(DeGhost*0.5)));
			color = image;
		}
		else if (Stereoscopic_Mode == 8) // Anaglyph 3D Green/Magenta
			color = float4(cB.r,cA.g,cB.b,1.0);
		else if (Stereoscopic_Mode == 9) // Anaglyph 3D Dubois Green/Magenta
		{

			float red = -0.062 * cA.r -0.158 * cA.g -0.039 * cA.b + 0.529 * cB.r + 0.705 * cB.g + 0.024 * cB.b;

			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = 0.284 * cA.r + 0.668 * cA.g + 0.143 * cA.b - 0.016 * cB.r - 0.015 * cB.g + 0.065 * cB.b;

			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.015 * cA.r -0.027 * cA.g + 0.021 * cA.b + 0.009 * cB.r + 0.075 * cB.g + 0.937  * cB.b;

			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }

			color = float4(red, green, blue, 0);
		}
		else if (Stereoscopic_Mode == 10)// Anaglyph 3D Deghosted Green/Magenta Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
		{
			LOne = contrast*0.45;
			ROne = contrast*0.8;
			DeGhost *= 0.275;

			accum = saturate(cB*float4(ROne,1.0-ROne,0.0,1.0));
			image.r = pow(accum.r+accum.g+accum.b, 1.15);
			image.a = accum.a;

			accum = saturate(cA*float4((1.0-LOne)*0.5,LOne,(1.0-LOne)*0.5,1.0));
			image.g = pow(accum.r+accum.g+accum.b, 1.05);
			image.a = image.a+accum.a;

			accum = saturate(cB*float4(0.0,1.0-ROne,ROne,1.0));
			image.b = pow(accum.r+accum.g+accum.b, 1.15);
			image.a = (image.a+accum.a)*0.33333333;

			accum = image;
			image.r = accum.r+(accum.r*(DeGhost*0.5))+(accum.g*(DeGhost*-0.25))+(accum.b*(DeGhost*-0.25));
			image.g = accum.g+(accum.r*(DeGhost*-0.5))+(accum.g*(DeGhost*0.25))+(accum.b*(DeGhost*-0.5));
			image.b = accum.b+(accum.r*(DeGhost*-0.25))+(accum.g*(DeGhost*-0.25))+(accum.b*(DeGhost*0.5));
			color = image;
		}
		else if (Stereoscopic_Mode == 11) // Anaglyph 3D Blue/Amber Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
		{
			LOne = contrast*0.45;
			ROne = contrast;
			DeGhost *= 0.275;

			accum = saturate(cA*float4(ROne,0.0,1.0-ROne,1.0));
			image.r = pow(accum.r+accum.g+accum.b, 1.05);
			image.a = accum.a;

			accum = saturate(cA*float4(0.0,ROne,1.0-ROne,1.0));
			image.g = pow(accum.r+accum.g+accum.b, 1.10);
			image.a = image.a+accum.a;

			accum = saturate(cB*float4((1.0-LOne)*0.5,(1.0-LOne)*0.5,LOne,1.0));
			image.b = pow(accum.r+accum.g+accum.b, 1.0);
			image.b = lerp(pow(image.b,(DeGhost*0.15)+1.0),1.0-pow(abs(1.0-image.b),(DeGhost*0.15)+1.0),image.b);
			image.a = (image.a+accum.a)*0.33333333;

			accum = image;
			image.r = accum.r+(accum.r*(DeGhost*1.5))+(accum.g*(DeGhost*-0.75))+(accum.b*(DeGhost*-0.75));
			image.g = accum.g+(accum.r*(DeGhost*-0.75))+(accum.g*(DeGhost*1.5))+(accum.b*(DeGhost*-0.75));
			image.b = accum.b+(accum.r*(DeGhost*-1.5))+(accum.g*(DeGhost*-1.5))+(accum.b*(DeGhost*3.0));
			color = saturate(image);
		}
	}

	if (Depth_Map_View == 2)
		color.rgb = tex2D(SamplerzBufferN,TexCoords).xxx;

	return color.rgb;
}
/////////////////////////////////////////////////////////Average Luminance Textures/////////////////////////////////////////////////////////////////
float3 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 ABEA, ABEArray[6] = {
		float4(0.0,1.0,0.0, 1.0),           //No Edit
		float4(0.0,1.0,0.0, 0.750),         //Upper Extra Wide
		float4(0.0,1.0,0.0, 0.5),           //Upper Wide
		float4(0.0,1.0, 0.15625, 0.46875),  //Upper Short
		float4(0.375, 0.250, 0.4375, 0.125),//Center Small
		float4(0.375, 0.250, 0.0, 1.0)      //Center Long
	};
	ABEA = ABEArray[Auto_Balance_Ex];

	float Average_Lum_ZPD = Depth(float2(ABEA.x + texcoord.x * ABEA.y, ABEA.z + texcoord.y * ABEA.w)), Average_Lum_Bottom = Depth( texcoord );
	if(RE)
	Average_Lum_Bottom = tex2D(SamplerDMN,float2( 0.125 + texcoord.x * 0.750,0.95 + texcoord.y)).x;

	float Storage = texcoord < 0.5 ? tex2D(SamplerDMN,0).x : tex2D(SamplerDMN,1).x;

	return float3(Average_Lum_ZPD,Average_Lum_Bottom,Storage);
}
/////////////////////////////////////////////////////////////////////////Logo///////////////////////////////////////////////////////////////////////
float3 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y, Text_Timer = 12500, BT = smoothstep(0,1,sin(timer*(3.75/1000)));
	float D,E,P,T,H,Three,DD,Dot,I,N,F,O,R,EE,A,DDD,HH,EEE,L,PP,Help,NN,PPP,C,Not,No;
	float3 Color = PS_calcLR(texcoord).rgb;

	if(TW || NC || NP)
		Text_Timer = 18750;

	[branch] if(timer <= Text_Timer)
	{ //DEPTH
		//D
		float PosXD = -0.035+PosX, offsetD = 0.001;
		float OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
		D = OneD-TwoD;
		//E
		float PosXE = -0.028+PosX, offsetE = 0.0005;
		float OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
		float TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
		E = (OneE-TwoE)+ThreeE;
		//P
		float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
		float OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.775));
		float TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.680));
		float ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		P = (OneP-TwoP) + ThreeP;
		//T
		float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
		float OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
		float TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
		T = OneT+TwoT;
		//H
		float PosXH = -0.0072+PosX;
		float OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
		float TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
		float ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.00325,0.009));
		H = (OneH-TwoH)+ThreeH;
		//Three
		float offsetFive = 0.001, PosX3 = -0.001+PosX;
		float OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
		float TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
		float ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
		Three = (OneThree-TwoThree)+ThreeThree;
		//DD
		float PosXDD = 0.006+PosX, offsetDD = 0.001;
		float OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DD = OneDD-TwoDD;
		//Dot
		float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;
		float OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
		Dot = OneDot;
		//INFO
		//I
		float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
		float OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
		float TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
		float ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
		I = OneI+TwoI+ThreeI;
		//N
		float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
		float OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
		float TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
		N = OneN-TwoN;
		//F
		float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
		float OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
		float TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
		float ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
		F = (OneF-TwoF)+ThreeF;
		//O
		float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
		float OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
		float TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
		O = OneO-TwoO;
		//Text Warnings
		PosY -= 0.953;
		//R
		float PosXR = -0.480+PosX, PosYR = -0.0025+PosY, offsetR = 0.001, offsetR1 = 0.002,offsetR2 = -0.002,offsetR3 = 0.007;
		float OneR = all( abs(float2( texcoord.x -PosXR, texcoord.y-PosYR)) < float2(0.0025,0.009*0.775));
		float TwoR = all( abs(float2( texcoord.x -PosXR-offsetR, texcoord.y-PosYR)) < float2(0.0025,0.007*0.680));
		float ThreeR = all( abs(float2( texcoord.x -PosXR+offsetR1, texcoord.y-PosY)) < float2(0.0005,0.009));
		float FourR = all( abs(float2( texcoord.x -PosXR+offsetR2, texcoord.y-PosY-offsetR3)) < float2(0.0005,0.0020));
		R = (OneR-TwoR) + ThreeR + FourR;
		//EE
		float PosXEE = -0.472+PosX, offsetEE = 0.0005;
		float OneEE = all( abs(float2( texcoord.x -PosXEE, texcoord.y-PosY)) < float2(0.003,0.009));
		float TwoEE = all( abs(float2( texcoord.x -PosXEE-offsetEE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float ThreeEE = all( abs(float2( texcoord.x -PosXEE, texcoord.y-PosY)) < float2(0.003,0.001));
		EE = (OneEE-TwoEE)+ThreeEE;
		//A
		float PosXA = -0.465+PosX,PosYA = -0.008+PosY;
		float OneA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosY)) < float2(0.002,0.001));
		float TwoA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosY)) < float2(0.002,0.009));
		float ThreeA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosY)) < float2(0.00325,0.009));
		float FourA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosYA)) < float2(0.003,0.001));
		A = (OneA-TwoA)+ThreeA+FourA;
		//DDD
		float PosXDDD = -0.458+PosX, offsetDDD = 0.001;
		float OneDDD = all( abs(float2( texcoord.x -PosXDDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoDDD = all( abs(float2( texcoord.x -PosXDDD-offsetDDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DDD = OneDDD-TwoDDD;
		//HH
		float PosXHH = -0.445+PosX;
		float OneHH = all( abs(float2( texcoord.x -PosXHH, texcoord.y-PosY)) < float2(0.002,0.001));
		float TwoHH = all( abs(float2( texcoord.x -PosXHH, texcoord.y-PosY)) < float2(0.0015,0.009));
		float ThreeHH = all( abs(float2( texcoord.x -PosXHH, texcoord.y-PosY)) < float2(0.00325,0.009));
		HH = (OneHH-TwoHH)+ThreeHH;
		//EEE
		float PosXEEE = -0.437+PosX, offsetEEE = 0.0005;
		float OneEEE = all( abs(float2( texcoord.x -PosXEEE, texcoord.y-PosY)) < float2(0.003,0.009));
		float TwoEEE = all( abs(float2( texcoord.x -PosXEEE-offsetEEE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float ThreeEEE = all( abs(float2( texcoord.x -PosXEEE, texcoord.y-PosY)) < float2(0.003,0.001));
		EEE = (OneEEE-TwoEEE)+ThreeEEE;
		//L
		float PosXL = -0.429+PosX, PosYL = 0.008+PosY, OffsetL = -0.949+PosX,OffsetLA = -0.951+PosX;
		float OneL = all( abs(float2( texcoord.x -PosXL+OffsetLA, texcoord.y-PosYL)) < float2(0.0025,0.001));
		float TwoL = all( abs(float2( texcoord.x -PosXL+OffsetL, texcoord.y-PosY)) < float2(0.0008,0.009));
		L = OneL+TwoL;
		//PP
		float PosXPP = -0.425+PosX, PosYPP = -0.0025+PosY, offsetPP = 0.001, offsetPP1 = 0.002;
		float OnePP = all( abs(float2( texcoord.x -PosXPP, texcoord.y-PosYPP)) < float2(0.0025,0.009*0.775));
		float TwoPP = all( abs(float2( texcoord.x -PosXPP-offsetPP, texcoord.y-PosYPP)) < float2(0.0025,0.007*0.680));
		float ThreePP = all( abs(float2( texcoord.x -PosXPP+offsetPP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		PP = (OnePP-TwoPP) + ThreePP;
		//No Profile / Not Compatible
		PosY += 0.953;
		PosX -= 0.483;
		float PosXNN = -0.458+PosX, offsetNN = 0.0015;
		float OneNN = all( abs(float2( texcoord.x -PosXNN, texcoord.y-PosY)) < float2(0.00325,0.009));
		float TwoNN = all( abs(float2( texcoord.x -PosXNN, texcoord.y-PosY-offsetNN)) < float2(0.002,0.008));
		NN = OneNN-TwoNN;
		//PPP
		float PosXPPP = -0.451+PosX, PosYPPP = -0.0025+PosY, offsetPPP = 0.001, offsetPPP1 = 0.002;
		float OnePPP = all( abs(float2( texcoord.x -PosXPPP, texcoord.y-PosYPPP)) < float2(0.0025,0.009*0.775));
		float TwoPPP = all( abs(float2( texcoord.x -PosXPPP-offsetPPP, texcoord.y-PosYPPP)) < float2(0.0025,0.007*0.680));
		float ThreePPP = all( abs(float2( texcoord.x -PosXPPP+offsetPPP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		PPP = (OnePPP-TwoPPP) + ThreePPP;
		//C
		float PosXC = -0.450+PosX, offsetC = 0.001;
		float OneC = all( abs(float2( texcoord.x -PosXC, texcoord.y-PosY)) < float2(0.0035,0.009));
		float TwoC = all( abs(float2( texcoord.x -PosXC-offsetC, texcoord.y-PosY)) < float2(0.0025,0.007));
		C = OneC-TwoC;
		if(NP)
		No = (NN + PPP) * BT; //Blinking Text
		if(NC)
		Not = (NN + C) * BT; //Blinking Text
		if(TW)
			Help = (R+EE+A+DDD+HH+EEE+L+PP) * BT; //Blinking Text
		//Website
		return D+E+P+T+H+Three+DD+Dot+I+N+F+O+Help+No+Not ? (1-texcoord.y*50.0+48.85)*texcoord.y-0.500: Color;
	}
	else
		return Color;
}
///////////////////////////////////////////////////////////////////ReShade.fxh//////////////////////////////////////////////////////////////////////
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{// Vertex shader generating a triangle covering the entire screen
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

technique SuperDepth3D
< ui_tooltip = "Suggestion : You Can Enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
			   			 "Do this once you set your 3D settings of course."; >
{
	#if BD_Correction || DC
		pass Barrel_Distortion
	{
		VertexShader = PostProcessVS;
		PixelShader = PBD;
	}
	#endif
		pass DepthBuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texDMN;
	}
		pass zbufferLM
	{
		VertexShader = PostProcessVS;
		PixelShader = zBuffer;
		RenderTarget = texzBufferN;
	}
		pass StereoOut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLumN;
	}
}
