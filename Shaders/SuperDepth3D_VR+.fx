	////--------------------//
	///**SuperDepth3D_VR+**///
	//--------------------////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//* Depth Map Based 3D post-process shader v3.6.6
	//* For Reshade 4.4+ I think...
	//* ---------------------------------
	//*
	//* Original work was based on the shader code from
	//* Also Fu-Bama a shader dev at the reshade forums https://reshade.me/forum/shader-presentation/5104-vr-universal-shader
	//* Also had to rework Philippe David http://graphics.cs.brown.edu/games/SteepParallax/index.html code to work with ReShade. This is used for the parallax effect.
	//* This idea was taken from this shader here located at https://github.com/Fubaxiusz/fubax-shaders/blob/596d06958e156d59ab6cd8717db5f442e95b2e6b/Shaders/VR.fx#L395
	//* It's also based on Philippe David Steep Parallax mapping code.
	//* Text rendering code Ported from https://www.shadertoy.com/view/4dtGD2 by Hamneggs for ReShadeFX
	//* If I missed any information please contact me so I can make corrections.
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
namespace SuperDepth3DVR
{
	#if exists "Overwatch.fxh"                                           //Overwatch Interceptor//
		#include "Overwatch.fxh"
		#define OSW 0
	#else// DA_X = [ZPD] DA_Y = [Depth Adjust] DA_Z = [Offset] DA_W = [Depth Linearization]
		static const float DA_X = 0.025, DA_Y = 7.5, DA_Z = 0.0, DA_W = 0.0;
		// DC_X = [Depth Flip] DC_Y = [Auto Balance] DC_Z = [Auto Depth] DC_W = [Weapon Hand]
		static const float DB_X = 0, DB_Y = 0, DB_Z = 0.1, DB_W = 0.0;
		// DC_X = [Barrel Distortion K1] DC_Y = [Barrel Distortion K2] DC_Z = [Barrel Distortion K3] DC_W = [Barrel Distortion Zoom]
		static const float DC_X = 0, DC_Y = 0, DC_Z = 0, DC_W = 0;
		// DD_X = [Horizontal Size] DD_Y = [Vertical Size] DD_Z = [Horizontal Position] DD_W = [Vertical Position]
		static const float DD_X = 1, DD_Y = 1, DD_Z = 0.0, DD_W = 0.0;
		// DE_X = [ZPD Boundary Type] DE_Y = [ZPD Boundary Scaling] DE_Z = [ZPD Boundary Fade Time] DE_W = [Weapon Near Depth Max]
		static const float DE_X = 0, DE_Y = 0.5, DE_Z = 0.25, DE_W = 0.0;
		// DF_X = [Weapon ZPD Boundary] DF_Y = [Separation] DF_Z = [ZPD Balance] DF_W = [Weapon Edge & Weapon Scale]
		static const float DF_X = 0.0, DF_Y = 0.0, DF_Z = 0.5, DF_W = 0.0;
		// DG_X = [Special Depth X] DG_Y = [Special Depth Y] DG_Z = [Weapon Near Depth Min] DG_W = [Check Depth Limit]
		static const float DG_X = 0.0, DG_Y = 0.0, DG_Z = 0.0, DG_W = 0.0;
		// DH_X = [LBC Size Offset X] DH_Y = [LBC Size Offset Y] DH_Z = [LBC Pos Offset X] DH_W = [LBC Pos Offset X]
		static const float DH_X = 1.0, DH_Y = 1.0, DH_Z = 0.0, DH_W = 0.0;
		// DI_X = [LBM Offset X] DI_Y = [LBM Offset Y] DI_Z = [Weapon Near Depth Trim] DI_W = [OIF Check Depth Limit]
		static const float DI_X = 0.0, DI_Y = 0.0, DI_Z = 0.25, DI_W = 0.0;
		// DJ_X = [Range Smoothing] DJ_Y = [Menu Detection Type] DJ_Z = [Match Threshold] DJ_W = [Check Depth Limit Weapon Primary]
		static const float DJ_X = 0, DJ_Y = 0.0, DJ_Z = 0.0, DJ_W = 0.100;
		// DK_X = [FPS Focus Method] DK_Y = [Eye Eye Selection] DK_Z = [Eye Fade Selection] DK_W = [Eye Fade Speed Selection]	
		static const float DK_X = 0, DK_Y = 0.0, DK_Z = 0, DK_W = 1;
		// DL_X = [Not Used Here] DL_Y = [De-Artifact] DL_Z = [Compatibility Power] DL_W = [Not Used Here]
		static const float DL_X = 0.5, DL_Y = 0, DL_Z = 0, DL_W = 0.05;		
		// DN_X = [Position A & B] DN_Y = [Position C & D] DM_Z = [Position E & F] DN_W = [Menu Size Main]	
		static const float DN_X = 0.0, DN_Y = 0.0, DN_Z = 0.0, DN_W = 0.0;
		// DO_X = [Position A & A] DO_Y = [Position A & B] DO_Z = [Position B & B] DO_W = [AB Menu Tresh]	
		static const float DO_X = 0.0, DO_Y = 0.0, DO_Z = 0.0, DO_W = 1000.0;
		// DP_X = [Position C & C] DP_Y = [Position C & D] DP_Z = [Position D & D] DP_W = [CD Menu Tresh]	
		static const float DP_X = 0.0, DP_Y = 0.0, DP_Z = 0.0, DP_W = 1000.0;
		// DQ_X = [Position E & E] DQ_Y = [Position E & F] DQ_Z = [Position F & F] DQ_W = [EF Menu Tresh]	
		static const float DQ_X = 0.0, DQ_Y = 0.0, DQ_Z = 0.0, DQ_W = 1000.0;
		// DR_X = [Position G & G] DR_Y = [Position G & H] DR_Z = [Position H & H] DR_W = [GH Menu Tresh]	
		static const float DR_X = 0.0, DR_Y = 0.0, DR_Z = 0.0, DR_W = 1000.0;
		// DR_X = [Null X] DR_Y = [Null Y] DR_Z = [Null Z] DR_W = [Check Depth Limit Weapon Secondary]
		static const float DS_X = 0.0, DS_Y = 0.0, DS_Z = 0.0, DS_W = 1.0;
		// WSM = [Weapon Setting Mode]
		#define OW_WP "WP Off\0Custom WP\0"
		static const int WSM = 0;
		//Triggers
		static const int DRS = 0, MAC = 0, ARW = 0, OIL = 0, MMS = 0, NVK = 0, NDG = 0, FTM = 0, SPO = 0, MMD = 0, SMP = 0, LBR = 0, HQT = 0, AFD = 0, MDD = 0, FPS = 1, SMS = 1, OIF = 0, NCW = 0, RHW = 0, NPW = 0, IDF = 0, SPF = 0, BDF = 0, HMT = 0, HMC = 0, DFW = 0, NFM = 0, DSW = 0, LBC = 0, LBS = 0, LBM = 0, DAA = 0, NDW = 0, PEW = 0, WPW = 0, FOV = 0, EDW = 0, SDT = 0;
		//Overwatch.fxh State
		#define OSW 1
	#endif
	//USER EDITABLE PREPROCESSOR FUNCTIONS START//
	
	// RE Fix is used to fix the issue with Resident Evil's 2 Remake 1-Shot cutscenes.
	#define RE_Fix 0 //Default 0 is Off. One is High and Ten is Low        1-15
	
	// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key using keycode info
	// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
	#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	
	// Rare Games like Among the Sleep Need this to be turned on.
	#define Invert_Depth 0 //Default 0 is Off. One is On.
	
	// Barrel Distortion Correction For SuperDepth3D for non conforming BackBuffer.
	#define BD_Correction 0 //Default 0 is Off. One is On.
	
	// Horizontal & Vertical Depth Buffer Resize for non conforming DepthBuffer.
	// Also used to enable Image Position Adjust is used to move the Z-Buffer around.
	#define DB_Size_Position 0 //Default 0 is Off. One is On.
	
	// Auto Letter Box Correction
	#define LB_Correction 0 //[Zero is Off] [One is Auto Hoz] [Two is Auto Vert]
	// Auto Letter Box Masking
	#define LetterBox_Masking 0 //[Zero is Off] [One is Auto Hoz] [Two is Auto Vert]
	
	// Specialized Depth Triggers
	#define SD_Trigger 0 //Default is off. One is Mode A other Modes not added yet.
	
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
	
	//Menu Masking 
	//The First value is Menu Masking This can be set from 0 Off to 1 2 3 4 and each value from 1-4 is a direction The first direction is LEFT to Right and so on.
	//This Need many values for positions of specific pixel locations for at least 2 White and 1 Black to detect if an menu is open.
	//The next 3 Positions need to be a Detection match with an match treshold. 
	//Then you can set  Menu Size for at least 3 diffrent Menus that open.
	//I don't expect any one to be able to use this fuction. But, It going to be used by Overwatch for some games. The first game is Poppy Playtime Chapter 1.
	#define Menu_Masking 0 //Set from 0 Off to 1 > 2 < 3 ^ 4 \/ Directions
	
	static const float4 POS_XYZW[3] = { float4( 0.0, 0.0,   0.0, 0.0), //Pos A = XY Menu_Type X & B = ZW Menu_Type Y 
										float4( 0.0, 0.0,   0.0, 0.0), //Pos C = XY Menu_Type Z & D = ZW Match
										float4( 0.0, 0.0,   0.0, 0.0)};//Pos E = XY Match & F = ZW Match
	
	static const float4 Set_Menu_Size = float4( 0.0, 0.0, 0.0, 0.0 );  //Size = Menu [ABC] D E F
	static const float3 Menu_Type = float3(3, 0, 3); //Default [ A White | B Black | C White] But, it can be anything. 
	static const float3 Set_Match_Threshold =float3( 0.0, 0.0, 0.0 );  //Set Match Threshold for D E F
	
	// Delay Frame for instances the depth bufferis 1 frame behind useful for games that need "Copy Depth Buffer
	// Before Clear Operation," Is checked in the API Depth Buffer tab in ReShade.
	#define D_Frame 0 //This should be set to 0 most of the times this will cause latency by one frame.
	
	//Text Information Key Default Menu Key
	#define Text_Info_Key 93

	//Fast Trigger Mode
	#define Fast_Trigger_Mode FTM //To override or activate this set it to 0 or 1 This only works if Overwatch tells the shader to do it or not.
	
	//USER EDITABLE PREPROCESSOR FUNCTIONS END//
	#if !defined(__RESHADE__) || __RESHADE__ < 40000
		#define Compatibility 1
	#else
		#define Compatibility 0
	#endif
	
	#if __RESHADE__ >= 40300
		#define Compatibility_DD 1
	#else
		#define Compatibility_DD 0
	#endif
	//DX9 0x9000 and OpenGL
	#if __RENDERER__ == 0x9000 || __RENDERER__ >= 0x10000
		#define RenderLimitations 1
	#else
		#define RenderLimitations 0
	#endif
	//DX12 Check
	#if __RENDERER__ >= 0xc000
		#define DXTwelve 1
		#define ISDX 1
	#else
		#define DXTwelve 0
		#define ISDX 0
	#endif
	 //Vulkan: 0x20000
	#if __RENDERER__ >= 0x20000 //Is Vulkan
		#define ISVK 1
	#else
		#define ISVK 0
	#endif
	//DX9 Check
	#if __RENDERER__ == 0x9000
		#define DX9 1
	#else
		#define DX9 0
	#endif
	//Flip Depth for OpenGL and Reshade 5.0 since older Profiles Need this.
	#if __RESHADE__ >= 50000 && __RENDERER__ >= 0x10000 && __RENDERER__ <= 0x20000
		#define Flip_Opengl_Depth 1
	#else
		#define Flip_Opengl_Depth 0
	#endif
	//Resolution Scaling because I can't tell your monitor size.
	#if (BUFFER_HEIGHT <= 720)
		#define Max_Divergence 25.0	
	#elif (BUFFER_HEIGHT <= 1080)
		#define Max_Divergence 50.0
	#elif (BUFFER_HEIGHT <= 1440)
		#define Max_Divergence 75.0
	#elif (BUFFER_HEIGHT <= 2160)
		#define Max_Divergence 100.0
	#else
		#define Max_Divergence 125.0//Wow Must be the future and 8K Plus is normal now. If you are hear use AI infilling...... Future person.
	#endif                          //With love <3 Jose Negrete..
	//New ReShade PreProcessor stuff
	#if UI_MASK
		#ifndef Mask_Cycle_Key
			#define Mask_Cycle_Key Set_Key_Code_Here
		#endif
	#else
		#define Mask_Cycle_Key Set_Key_Code_Here
	#endif
	//This preprocessor is for Super3D Mode for really close to full Res images per I using Channel Compression
	#ifndef Super3D_Mode
		#define Super3D_Mode 0
	#endif
	#define SuperDepth Super3D_Mode
	//This preprocessor is for HelixVision Mode that creates a Double Sized texture on the Horizontal axis.
	#ifndef HelixVision_Mode
		#define HelixVision_Mode 0
	#endif
	//Render Buffer Resolution limit.
	#define RenderBufferWidth (BUFFER_WIDTH * 2) > 4096
	//Render Buffer Warnings for HelixVision
	#if RenderLimitations
		#if RenderBufferWidth
			#define HelixVision 0
			#if HelixVision
				#warning "HelixVision Mode Will NOT work on DirectX 9.0c and OpenGL at current resolution. To Support this consider the Super3D Format for your application." //#error "Will NOT work on DirectX 9.0c and OpenGL."
			#endif
		#else
			#define HelixVision HelixVision_Mode
		#endif
	#else
		#define HelixVision HelixVision_Mode
		#if HelixVision
			#if DXTwelve
				#warning "DirectX 12 not supported in the HelixVision app, But, if added should work."
			#endif
		#endif
	#endif
	//uniform float3 TEST < ui_type = "drag"; ui_min = 0.0; ui_max = 1.0; > = 0.0;
	#if !SuperDepth && !HelixVision
	uniform int IPD <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0; ui_max = 100;
		ui_label = "·Interpupillary Distance·";
		ui_tooltip = "Determines the distance between your eyes.\n"
					 "Default is 0.";
		ui_category = "Eye Focus Adjustment";
	> = 0;
	#else
	static const int IPD = 0;
	#endif
	
	//Divergence & Convergence//
	uniform float Divergence <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 100; ui_step = 0.5;
		ui_label = "·Divergence Slider·";
		ui_tooltip = "Divergence increases differences between the left and right retinal images and allows you to experience depth.\n"
					 "The process of deriving binocular depth information is called stereopsis.";
		ui_category = "Divergence & Convergence";
	> = 50;
	
	uniform float2 ZPD_Separation <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.250;
		ui_label = " ZPD & Sepration";
		ui_tooltip = "Zero Parallax Distance controls the focus distance for the screen Pop-out effect also known as Convergence.\n"
					"Separation is a way to increase the intensity of Divergence without a performance cost.\n"
					"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
					"Default is 0.025, Zero is off.";
		ui_category = "Divergence & Convergence";
	> = float2(DA_X,DF_Y);
	
	uniform float ZPD_Balance <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " ZPD Balance";
		ui_tooltip = "Zero Parallax Distance balances between ZPD Depth and Scene Depth.\n"
					"Default is Zero is full Convergence and One is Full Depth.";
		ui_category = "Divergence & Convergence";
	> = DF_Z;
	
	uniform int Auto_Balance_Ex <
		ui_type = "combo";
		ui_items = "Off\0Left\0Center\0Right\0Center Wide\0Left Wide\0Right Wide\0";
//		ui_items = "Off\0Left\0Center\0Right\0Center Wide\0Left Wide\0Right Wide\0Eye Tracker\0Eye Tracker Alt\0";
		ui_label = " ZPD Auto Balance";
		ui_tooltip = "Automatically Balance between ZPD Depth and Scene Depth.\n"
					 "Default is Off.";
		ui_category = "Divergence & Convergence";
	> = 2;
	
	uniform int ZPD_Boundary <
		ui_type = "combo";
		ui_items = "BD0 Off\0BD1 Full\0BD2 Narrow\0BD3 Wide\0BD4 FPS Center\0BD5 FPS Narrow\0BD6 FPS Edge\0BD7 FPS Mixed\0";	
		ui_label = " ZPD Boundary Detection";
		ui_tooltip = "This selection menu gives extra boundary conditions to ZPD.\n"
					 			 "This treats your screen as a virtual wall.\n"
					 		   "Default is Off.";
		ui_category = "Divergence & Convergence";
	> = DE_X;
	
	uniform float2 ZPD_Boundary_n_Fade <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 0.5;
		ui_label = " ZPD Boundary & Fade Time";
		ui_tooltip = "This selection menu gives extra boundary conditions to scale ZPD & lets you adjust Fade time.";
		ui_category = "Divergence & Convergence";
	> = float2(DE_Y,DE_Z);
	
	uniform int View_Mode <
		ui_type = "combo";
		ui_items = "VM0 Normal \0VM1 Alpha \0VM2 Reiteration \0VM3 Stamped \0VM4 Mixed \0VM5 Adaptive \0";
		ui_label = "·View Mode·";
		ui_tooltip = "Changes the way the shader fills in the occlude sections in the image.\n"
					"Normal      | Normal output used for most games with it's streched look.\n"
					"Alpha       | Like Normal But with a bit more sepration in the gap filling.\n"
					"Reiteration | Same thing as Stamped but with brakeage points.\n"
					"Stamped     | Stamps out a transparent area on the occluded area.\n"
					"Mixed       | Used for higher amounts of Semi-Transparent objects like foliage.\n"
					"Adaptive    | is a scene adapting infilling that uses disruptive reiterative sampling.\n"
					"\n"
					"Warning: Also Make sure you turn on Performance Mode before you close this menu.\n"
					"\n"
					"Default is Alpha.";
	ui_category = "Occlusion Masking";
	> = 1;

	uniform int View_Mode_Warping <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 5.0;
		ui_label = " Halo Reduction";
		ui_tooltip = "This warps the depth in some View Modes to hide or minimize the Halo in Most Games.\n"
					 "With this on it should Hide the Halo a little better depending the View Mode it works on.\n"
					 "Default is 3 and Zero is Off.";
		ui_category = "Occlusion Masking";
	> = 3;

	uniform int Custom_Sidebars <
		ui_type = "combo";
		ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
		ui_label = " Edge Handling";
		ui_tooltip = "Edges selection for your screen output.";
		ui_category = "Occlusion Masking";
	> = 1;
	
	uniform float Edge_Adjust <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;                                                                                                  
		ui_label = " Edge Reduction";
		ui_tooltip = "This Decreses the Edge at the cost of warping the Image.\n"
					 "Default is 50.0%.";
		ui_category = "Occlusion Masking";
	> = 0.5;
	
	uniform float Max_Depth <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.5; ui_max = 1.0;
		ui_label = " Max Depth";
		ui_tooltip = "Max Depth lets you clamp the max depth range of your scene.\n"
					 "So it's not hard on your eyes looking off in to the distance .\n"
					 "Default and starts at One and it's Off.";
		ui_category = "Occlusion Masking";
	> = 1.0;
		
	uniform float Range_Blend <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		ui_label = " Range Smoothing";
		ui_tooltip = "This blends Two Depth Buffer at a distance to fill in missing information that is needed to compleat a image.\n"
					 "With this on it should help with tress and other foliage that needs to be reconstructed by Temporal Methods.\n"
					 "Default is Zero, Off.";
		ui_category = "Occlusion Masking";
	> = DJ_X;	
	
	uniform int Performance_Level <
		ui_type = "combo";
		ui_items = "Performant\0Normal\0Performant + VRS\0Normal + VRS\0";
		ui_label = " Performance Mode";
		ui_tooltip = "Performance Mode Lowers or Raises Occlusion Quality Processing so that there is a performance is adjustable.\n"
					 "Varable Rate Shading focuses the quality of the samples in lighter areas of the screen.\n"
					 "Please enable the 'Performance Mode Checkbox,' in ReShade's GUI.\n"
					 "It's located in the lower bottom right of the ReShade's Main UI.\n"
					 "Default is Performant + VRS.";
		ui_category = "Occlusion Masking";
	> = 2;
	
	uniform int Switch_VRS <
		ui_type = "combo";
		ui_items = "Auto\0High\0Med\0Low\0Very Low\0";
		ui_label = " VRS Performance";
		ui_tooltip = "Use this to set Varable Rate Shading to manually selection or automatic mod.\n"
			   "Default is Automatic.";
		ui_category = "Occlusion Masking";
	> = 0;	
	
	uniform float Compatibility_Power <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = -1.0; ui_max = 1.0;
		ui_label = " Compatibility Power";
		ui_tooltip = "Not all games need a high offset for infilling.\n"
					 "This option lets you increase this offset in both directions to limit artifacts.\n"
					 "With this on it should work better in games with TAA, FSR,and or DLSS sometimes.\n"
					 "Default is Zero.";
		ui_category = "Compatibility Options";
	> = DL_Z;

	uniform float De_Artifacting <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = -1; ui_max = 1;
		ui_label = " De-Artifacting";
		ui_tooltip = "This when the image does not match the depth buffer causing artifacts.\n"
					 "Use this on fur, hair, and other things that can cause artifacts at a high cost.\n"
					 "I find a value of 0.5 is good enough in most cases.\n"
					 "Default is Zero and it's Off.";
		ui_category = "Compatibility Options";
	> = DL_Y;		
	
	uniform float2 DLSS_FSR_Offset <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 5.0;
		ui_label = " Upscailer Offset XY";
		ui_tooltip = "This Offset is for non conforming ZBuffer Postion witch is normaly 1 pixel wide.\n"
					 "This issue only happens sometimes when using things like DLSS or FSR.\n"
					 "This does not solve for TAA artifacts like Jittering or smearing.\n"
					 "Default and starts at Zero and it's Off. With a max offset of 5pixels Wide.";
		ui_category = "Compatibility Options";
		ui_category_closed = true;
	> = 0;
	
	
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
		ui_min = -1.0; ui_max = 1.0;
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
		ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n"
					 "Default is 0.1f, Zero is off.";
		ui_category = "Depth Map";
	> = DB_Z;
	
	uniform bool Depth_Map_View <
		ui_label = " Depth Map View";
		ui_tooltip = "Display the Depth Map.";
		ui_category = "Depth Map";
	> = false;
	// New Menu Detection Code
	uniform bool Depth_Detection <
		ui_label = " Depth Detection";
		ui_tooltip = "Use this to dissable/enable in game Depth Detection.";
		ui_category = "Depth Map";
	> = true;
	
	uniform bool Depth_Map_Flip <
		ui_label = " Depth Map Flip";
		ui_tooltip = "Flip the depth map if it is upside down.";
		ui_category = "Depth Map";
	> = DB_X;
	#if DB_Size_Position || SPF == 2 || LB_Correction
	uniform float2 Horizontal_and_Vertical <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 2;
		ui_label = "·Horizontal & Vertical Size·";
		ui_tooltip = "Adjust Horizontal and Vertical Resize. Default is 1.0.";
		ui_category = "Reposition Depth";
	> = float2(DD_X,DD_Y);
	
	uniform float2 Image_Position_Adjust<
		ui_type = "drag";
		ui_min = -1.0; ui_max = 1.0;
		ui_label = " Horizontal & Vertical Position";
		ui_tooltip = "Adjust the Image Position if it's off by a bit. Default is Zero.";
		ui_category = "Reposition Depth";
	> = float2(DD_Z,DD_W);
	
	#if LB_Correction
	uniform float2 H_V_Offset <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 2;
		ui_label = " Horizontal & Vertical Size Offset";
		ui_tooltip = "Adjust Horizontal and Vertical Resize Offset for Letter Box Correction. Default is 1.0.";
		ui_category = "Reposition Depth";
	> = float2(1.0,1.0);
	
	uniform float2 Image_Pos_Offset <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 2;
		ui_label = " Horizontal & Vertical Position Offset";
		ui_tooltip = "Adjust the Image Position if it's off by a bit for Letter Box Correction. Default is Zero.";
		ui_category = "Reposition Depth";
	> = float2(0.0,0.0);
	
	uniform bool LB_Correction_Switch <
		ui_label = " Letter Box Correction Toggle";
		ui_tooltip = "Use this to turn off and on the correction when LetterBox Detection is active.";
		ui_category = "Reposition Depth";
	> = true;
	#else
	static const bool LB_Correction_Switch = true;
	static const float2 H_V_Offset = float2(DH_X,DH_Y);
	static const float2 Image_Pos_Offset  = float2(DH_Z,DH_W);
	#endif
	
	uniform bool Alinement_View <
		ui_label = " Alinement View";
		ui_tooltip = "A Guide to help aline the Depth Buffer to the Image.";
		ui_category = "Reposition Depth";
	> = false;
	#else
	static const bool Alinement_View = false;
	static const float2 Horizontal_and_Vertical = float2(DD_X,DD_Y);
	static const float2 Image_Position_Adjust = float2(DD_Z,DD_W);
	
	static const bool LB_Correction_Switch = true;
	static const float2 H_V_Offset = float2(DH_X,DH_Y);
	static const float2 Image_Pos_Offset  = float2(DH_Z,DH_W);
	#endif
	//Weapon Hand Adjust//
	uniform int WP <
		ui_type = "combo";
		ui_items = OW_WP;
		ui_label = "·Weapon Profiles·";
		ui_tooltip = "Pick Weapon Profile for your game or make your own.";
		ui_category = "Weapon Hand Adjust";
	> = DB_W;
	
	uniform float4 Weapon_Adjust <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 250.0;
		ui_label = " Weapon Hand Adjust";
		ui_tooltip = "Adjust Weapon depth map for your games.\n"
					 "X, CutOff Point used to set a different scale for first person hand apart from world scale.\n"
					 "Y, Precision is used to adjust the first person hand in world scale.\n"
					 "W, Scale is used to compress or rescale the weapon.\n"
		             "Default is float2(X 0.0, Y 0.0, Z 0.0, W 0.0)";
		ui_category = "Weapon Hand Adjust";
	> = float4(0.0,0.0,0.0,0.0);
	
	uniform float4 WZPD_and_WND <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.5;
		ui_label = " Weapon ZPD, Min, Auto, & Trim";
		ui_tooltip = "WZPD controls the focus distance for the screen Pop-out effect also known as Convergence for the weapon hand.\n"
					"Weapon ZPD Is for setting a Weapon Profile Convergence, so you should most of the time leave this Default.\n"
					"Weapon Min is used to adjust min weapon hand of the weapon hand when looking at the world near you.\n"
					"Weapon Auto is used to auto adjust trimming when looking at a object or out to distance.\n"
					"Weapon Trim is used cutout a location in the depth buffer so that Min and Auto can use.\n"
					"Default is (ZPD X 0.03, Min Y 0.0, Auto Z 0.0, Trim Z 0.250 ) & Zero is off.";
		ui_category = "Weapon Hand Adjust";	
	> = float4(0.03,DG_Z,DE_W,DI_Z);
	
	uniform float2 Weapon_Depth_Edge <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Screen Edge Adjust & Near Scale";
		ui_tooltip = "This Tool is to help with screen Edge adjustments and Weapon Hand scaling near the screen";
		ui_category = "Weapon Hand Adjust";	
	> = DF_W;
	
	uniform float2 Weapon_ZPD_Boundary <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 0.5;
		ui_label = " Weapon Screen Boundary Detection";
		ui_tooltip = "This selection menu gives extra boundary conditions to WZPD.";
		ui_category = "Weapon Hand Adjust";
	> = DF_X;
	#if HUD_MODE || HMT
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
	> = float2(HMC,0.5);
	#endif
	
	uniform int Focus_Reduction_Type <
		ui_type = "combo";
		ui_items = "World\0Weapon\0Mix\0";
		ui_label = "·Focus Type·";
		ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
					"This may induce Eye Strain so take this as an Warning.";
		ui_category = "FPS Focus";
	> = FPS;
	
	uniform int FPSDFIO <
		ui_type = "combo";
		ui_items = "Off\0Press\0Hold\0";
		ui_label = " Activation Type";
		ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
					"This may induce Eye Strain so take this as an Warning.";
		ui_category = "FPS Focus";
	> = DK_X;

	uniform int Eye_Fade_Selection <
		ui_type = "combo";
		ui_items = "Both\0Right Only\0Left Only\0";
		ui_min = 0; ui_max = 2;
		ui_label = " Eye Selection";
		ui_tooltip ="Eye Selection: One is Right Eye only, Two is Left Eye Only, and Zero Both Eyes.\n"
					"Default is Both.";
		ui_category = "FPS Focus";
	> = DK_Y;
	
	uniform int2 Eye_Fade_Reduction_n_Power <
		ui_type = "slider";
		ui_min = 0; ui_max = 4;
		ui_label = " Eye Fade Options";
		ui_tooltip ="X, Fade Reduction: Decreases the depth amount by a current percentage.\n"
					"Y, Fade Speed: Decreases or Incresses how fast it changes.\n"
					"Default is X[ 0 ] Y[ 1 ].";
		ui_category = "FPS Focus";
	> = int2(DK_Z,DK_W);

	
	//Cursor Adjustments
	uniform int Cursor_Type <
		ui_type = "combo";
		ui_items = "Off\0Reticle\0Diamond\0Dot\0Cross\0Cursor\0";
		ui_label = "·Cursor Selection·";
		ui_tooltip = "Choose the cursor type you like to use.\n"
								 "Default is Zero.";
		ui_category = "Cursor Adjustments";
	> = 0;
	
	uniform int3 Cursor_SC <
		ui_type = "drag";
		ui_min = 0; ui_max = 10;
		ui_label = " Cursor Adjustments";
		ui_tooltip = "This controlls the Size & Color.\n"
								 "Defaults are ( X 1, Y 0, Z 0).";
		ui_category = "Cursor Adjustments";
	> = int3(1,0,0);
	
	uniform bool Cursor_Lock <
		ui_label = " Cursor Lock";
		ui_tooltip = "Screen Cursor to Screen Crosshair Lock.";
		ui_category = "Cursor Adjustments";
	> = false;
	
	uniform bool Toggle_Cursor <
		ui_label = " Cursor Toggle";
		ui_tooltip = "Turns Screen Cursor Off and On with out cycling once set to the type above.";
		ui_category = "Cursor Adjustments";
	> = true;
	
	#if BD_Correction
	uniform int BD_Options <
		ui_type = "combo";
		ui_items = "On\0Off\0Guide\0";
		ui_label = "·Distortion Options·";
		ui_tooltip = "Use this to Turn Off, Turn On, & to use the BD Alinement Guide.\n"
					 "Default is ON.";
		ui_category = "Distortion Corrections";
	> = 0;
	uniform float3 Colors_K1_K2_K3 <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = -2.0; ui_max = 2.0;
		ui_tooltip = "Adjust the Distortion K1, K2, & K3.\n"
					 "Default is 0.0";
		ui_label = " BD K1 K2 K3";
		ui_category = "Distortion Corrections";
	> = float3(DC_X,DC_Y,DC_Z);
	
	uniform float Zoom <
		ui_type = "drag";
		ui_min = -0.5; ui_max = 0.5;
		ui_label = " BD Zoom";
		ui_category = "Distortion Corrections";
	> = DC_W;
	#else
		#if BDF
		uniform bool BD_Options <
			ui_label = "·Toggle Barrel Distortion·";
			ui_tooltip = "Use this if you modded the game to remove Barrel Distortion.";
			ui_category = "Distortion Corrections";
		> = !true;
		#else
			static const int BD_Options = 1;
		#endif
	static const float3 Colors_K1_K2_K3 = float3(DC_X,DC_Y,DC_Z);
	static const float Zoom = DC_W;
	#endif
	
	#if !SuperDepth && !HelixVision
	uniform int Barrel_Distortion <
		ui_type = "combo";
		ui_items = "Off\0Blinders A\0Blinders B\0";
		ui_label = "·Barrel Distortion·";
		ui_tooltip = "Use this to disable or enable Barrel Distortion A & B.\n"
					 "This also lets you select from two different Blinders.\n"
				     "Default is Blinders A.\n";
		ui_category = "Image Adjustment";
	> = 0;
	
	uniform float FoV <
		ui_type = "slider";
		ui_min = 0; ui_max = 0.5;
		ui_label = " Field of View";
		ui_tooltip = "Lets you adjust the FoV of the Image.\n"
					 "Default is 0.0.";
		ui_category = "Image Adjustment";
	> = 0;
	
	uniform float3 Polynomial_Colors_K1 <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Polynomial Distortion K1";
		ui_tooltip = "Adjust the Polynomial Distortion K1_Red, K1_Green, & K1_Blue.\n"
					 "Default is (R 0.22, G 0.22, B 0.22)";
		ui_category = "Image Adjustment";
	> = float3(0.22, 0.22, 0.22);
	
	uniform float3 Polynomial_Colors_K2 <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Polynomial Distortion K2";
		ui_tooltip = "Adjust the Polynomial Distortion K2_Red, K2_Green, & K2_Blue.\n"
					 "Default is (R 0.24, G 0.24, B 0.24)";
		ui_category = "Image Adjustment";
	> = float3(0.24, 0.24, 0.24);
	
	uniform int Theater_Mode <
		ui_type = "combo";
		ui_items = "Off\0Theater Mode Normal\0Theater Mode AR\0";
		ui_label = " Theater Modes";
		ui_tooltip = "Sets the VR Shader into Theater mode for CellPhone VR or Nreal Glasses.\n"
					 "The 2nd Option is the same as the first. But, Zoomed in.\n"
				     "Default is Off.\n";
		ui_category = "Image Adjustment";
	> = 0;
	
	#else
	static const int Barrel_Distortion = 0;
	static const float FoV = 0;
	static const float3 Polynomial_Colors_K1 = float3(0.22, 0.22, 0.22);
	static const float3 Polynomial_Colors_K2 = float3(0.24, 0.24, 0.24);
	static const int Theater_Mode = 0;
	#endif
	
	uniform int Color_Correction <
		ui_type = "combo";
		ui_items = "Off\0On\0";
		ui_label = "·Color Correction·";
		ui_tooltip = "Partial Luma Preserved Color Correction.\n"
					"Removes Tint and or Color Cast in an automatic way while enhancing contrast.\n"
					"This works by sampling the image and creating a min and max color map and adjusting the image accordingly.\n"
					"Default is Off.";
		ui_category = "Image Effects";
	> = 0;

	uniform float Correction_Strength <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Correction Factor";
		ui_tooltip = "This gives full control over Color Correction Factor.\n"
					"It can make dark areas brighter, Try to leave this on low to preserve atmosphere.\n"
					"Default is 0.0f, Low.";
		ui_category = "Image Effects";
	> = 0.0;
	
	uniform float Blinders <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Blinders";
		ui_tooltip = "Lets you adjust blinders sensitivity.\n"
					 "Default is Zero, Off.";
		ui_category = "Image Effects";
	> = 0;
	
	uniform float Adjust_Vignette <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		ui_label = " Vignette";
		ui_tooltip = "Soft edge effect around the image.";
		ui_category = "Image Effects";
	> = 0.0;
	#if !HelixVision //Removed because HelixVision_Mode Has Built in sharpening.
	uniform float Sharpen_Power <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 5.0;
		ui_label = " SmartSharp";
		ui_tooltip = "Adjust this to clear up the image the game, movie picture & etc.\n"
					 "This is Smart Sharp Jr code based on the Main Smart Sharp shader.\n"
					 "It can be pushed more and looks better then the basic USM.";
		ui_category = "Image Effects";
	> = 0;
	#else
	static const float Sharpen_Power = 0;
	#endif
	uniform float Saturation <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		ui_label = " Saturation";
		ui_tooltip = "Lets you saturate image, basically adds more color.";
		ui_category = "Image Effects";
	> = 0;
	
	uniform bool Toggle_Deband <
		ui_label = " Deband Toggle";
		ui_tooltip = "Turns on automatic Depth Aware Deband this is used to reduce or remove the color banding in the image.";
		ui_category = "Image Effects";
	> = true;
	
	#if !SuperDepth && !HelixVision
		uniform bool NCAOC < // Non Companion App Overlay Compatibility
		ui_label = " Alternative Overlay Mode";
		ui_tooltip = "Sets the VR Shader to Non Companion App Overlay Compatibility.\n"
					 "This lets the overlay work in other Desktop Mirroring software.";
		ui_category = "Extra Options";
	> = false;
	#else
		static const int NCAOC = 0;
	#endif
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; mode = "toggle";>;
	uniform bool Mask_Cycle < source = "key"; keycode = Mask_Cycle_Key; toggle = true; >;
	uniform bool Text_Info < source = "key"; keycode = Text_Info_Key; toggle = true; mode = "toggle";>;
	uniform bool CLK < source = "mousebutton"; keycode = Cursor_Lock_Key; toggle = true; mode = "toggle";>;
	uniform bool Trigger_Fade_A < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
	uniform bool Trigger_Fade_B < source = "mousebutton"; keycode = Fade_Key;>;
	uniform bool overlay_open < source = "overlay_open"; >;
	uniform float2 Mousecoords < source = "mousepoint"; > ;
	uniform bool Alternate < source = "framecount";>;     // Alternate Even Odd frames
	uniform float frametime < source = "frametime";>;
	uniform float timer < source = "timer"; >;
	
	static const float Auto_Balance_Clamp = 0.5; //This Clamps Auto Balance's max Distance.
	
	#if Compatibility_DD
	uniform bool DepthCheck < source = "bufready_depth"; >;
	#endif
	
	#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	#define Interpupillary_Distance IPD * pix.x
	#define AI Interlace_Anaglyph.x * 0.5 //Optimization for line interlaced Adjustment.
	#define Res int2(BUFFER_WIDTH, BUFFER_HEIGHT)
	#define ARatio Res.x / Res.y
	
	float3 RE_Set(float Auto_Switch)
	{
		#if OIL == 1
			float OIL_Switch[2] = {OIF.x,OIF.y};	
		#elif ( OIL == 2 )
			float OIL_Switch[3] = {OIF.x,OIF.y,OIF.z};	
		#elif ( OIL == 3 )
			float OIL_Switch[4] = {OIF.x,OIF.y,OIF.z,OIF.w};	
		#else
			float OIL_Switch[1] = {OIF.x};	
		#endif   	
		int Scale_Auto_Switch = clamp((Auto_Switch * 4) - 1,0 , 3 );
		float Set_RE = OIL_Switch[Scale_Auto_Switch];

		int REF_Trigger = RE_Fix > 0 || Set_RE > 0;
		return float3(REF_Trigger, RE_Fix > 0 ? RE_Fix : Set_RE , Scale_Auto_Switch); 
	}
	
	float4 RE_Set_Adjustments()
	{
		#if OIL == 1
			float OIL_Switch[4] = {OIF.x,OIF.y,0,0};	
		#elif ( OIL == 2 )
			float OIL_Switch[4] = {OIF.x,OIF.y,OIF.z,0};	
		#elif ( OIL == 3 )
			float OIL_Switch[4] = {OIF.x,OIF.y,OIF.z,OIF.w};	
		#else
			float OIL_Switch[4] = {OIF.x,0,0,0};	
		#endif 
		return float4(RE_Fix > 0 ? RE_Fix : OIL_Switch[0], OIL_Switch[1], OIL_Switch[2], OIL_Switch[3]);
	}
	
	float Scale(float val,float max,float min) //Scale to 0 - 1
	{
		return (val - min) / (max - min);
	}
	
	float fmod(float a, float b)
	{
		float c = frac(abs(a / b)) * abs(b);
		return a < 0 ? -c : c;
	}
	
	float2 Min_Divergence() // and set scale
	{   float Min_Div = max(1.0, Divergence), D_Scale = min(1.25,Scale(Min_Div,100.0,1.0));
		return float2(lerp( 1.0, Max_Divergence, D_Scale), D_Scale);
	}
	
		float2 Set_Pop_Min()
	{
		#if SPO
		return Set_Popout( WP, DG_W , WZPD_and_WND.y);
		#else
		return float2( DG_W, WZPD_and_WND.y );
		#endif
	}
	
	float RN_Value(float i)
	{
		return round(i * 10.0f);// * 0.1f;
	}
	
	float FN_Value(float i)
	{
		return floor(i * 10.0f);// * 0.1f;
	}
	
	float Vin_Pattern(float2 TC, float2 V_Power)
	{	//Focuse away from center
		TC *= (1.0 - TC.yx); 
	    float Vin = TC.x*TC.y * V_Power.x, Use_Depth = 1;// step(PrepDepth( texcoord.xy )[0][0] + 0.30, 0.375);
	    return 1-saturate(pow(abs(Vin),V_Power.y));	
	}
	///////////////////////////////////////////////////////////Conversions/////////////////////////////////////////////////////////////
	float3 RGBtoYCbCr(float3 rgb) // For Super3D a new Stereo3D output.
	{   float TCoRF[1];//The Chronicles of Riddick: Assault on Dark Athena FIX I don't know why it works.......
		float Y  =  .299 * rgb.x + .587 * rgb.y + .114 * rgb.z; // Luminance
		float Cb = -.169 * rgb.x - .331 * rgb.y + .500 * rgb.z; // Chrominance Blue
		float Cr =  .500 * rgb.x - .419 * rgb.y - .081 * rgb.z; // Chrominance Red
		return float3(Y,Cb + 128./255.,Cr + 128./255.);
	}
	
	#if SuperDepth //The Chronicles of Riddick: Assault on Dark Athena FIX I don't know why it works.......
	float3 youknow(float2 Idontknow)
	{
		float whatisgoing;
		float3 on;
		return  whatisgoing+on;
	}
	#endif
	///////////////////////////////////////////////////////////////3D Starts Here/////////////////////////////////////////////////////////////////
	texture DepthBufferTex : DEPTH;
	sampler DepthBuffer
		{
			Texture = DepthBufferTex;
			AddressU = BORDER;
			AddressV = BORDER;
			AddressW = BORDER;
			//Used Point for games like AMID Evil that don't have a proper Filtering.
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	
	texture BackBufferTex : COLOR;
	
	sampler BackBuffer
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
	#if D_Frame || DFW
	texture texCF { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = RGBA8; };
	
	sampler SamplerCF
		{
			Texture = texCF;
		};
	
	texture texDF { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = RGBA8; };
	
	sampler SamplerDF
		{
			Texture = texDF;
		};
	#endif
	texture texDMVR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; MipLevels = 6;};
	
	sampler SamplerDMVR
		{
			Texture = texDMVR;
		};
	
	texture texzBufferVR_P  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RG16F; MipLevels = 6; };
	
	sampler SamplerzBufferVR_P
		{
			Texture = texzBufferVR_P;
			AddressU = MIRROR;
			AddressV = MIRROR;
			AddressW = MIRROR;
			MagFilter = POINT;
			MinFilter = POINT;	
			MipFilter = POINT;
	
		};
		
	texture texzBufferVR_L  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R16F; MipLevels = 8; };
	//not doing mips here?
	sampler SamplerzBufferVR_L
		{
			Texture = texzBufferVR_L;
			AddressU = MIRROR;
			AddressV = MIRROR;
			AddressW = MIRROR;
		};
		
	texture texzBufferBlurVR < pooled = true; > { Width = BUFFER_WIDTH / 2.0 ; Height = BUFFER_HEIGHT / 2.0; Format = RG16F; MipLevels = 6; };
	
	sampler SamplerzBuffer_BlurVR
		{
			Texture = texzBufferBlurVR;
		};
		
	#if UI_MASK
	texture TexMaskA < source = "DM_Mask_A.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
	sampler SamplerMaskA { Texture = TexMaskA;};
	texture TexMaskB < source = "DM_Mask_B.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
	sampler SamplerMaskB { Texture = TexMaskB;};
	#endif
	//////////////////////////////////////////////////////////Stored Textures/////////////////////////////////////////////////////////////////////
	texture texPBVR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
	
	sampler SamplerPBBVR
		{
			Texture = texPBVR;
			AddressU = BORDER;
			AddressV = BORDER;
			AddressW = BORDER;
		};
	///////////////////////////////////////////////////////Left Right Textures////////////////////////////////////////////////////////////////////
	#if BUFFER_COLOR_BIT_DEPTH == 10 //This PreProcessor is not a bool it really is 8 or 10.
		#define RGBA RGB10A2
	#else
		#define RGBA RGBA8
	#endif
	
	#if Compatibility_DD
	#define RGBAC RGB10A2
	#else
	#define RGBAC RGBA8
	#endif
	
	#if HelixVision
	texture DoubleTex  { Width = BUFFER_WIDTH * 2; Height = BUFFER_HEIGHT; Format = RGBA; };
	
	sampler SamplerDouble
		{
			Texture = DoubleTex;
			AddressU = BORDER;
			AddressV = BORDER;
			AddressW = BORDER;
		};
	#else
	texture LeftTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBAC; };
	
	sampler SamplerLeft
		{
			Texture = LeftTex;
			AddressU = BORDER;
			AddressV = BORDER;
			AddressW = BORDER;
		};
	
	texture RightTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBAC; };
	
	sampler SamplerRight
		{
			Texture = RightTex;
			AddressU = BORDER;
			AddressV = BORDER;
			AddressW = BORDER;
		};
	#endif
	
	texture Info_Tex < pooled = true; >  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };
	sampler SamplerInfo { Texture = Info_Tex;};
	
	#define Scale_Buffer 160 / BUFFER_WIDTH
	////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////
	texture texLumVR {Width = BUFFER_WIDTH * Scale_Buffer; Height = BUFFER_HEIGHT * Scale_Buffer; Format = RGBA16F; MipLevels = 8;};
	
	sampler SamplerLumVR
		{
			Texture = texLumVR;
		};
	
	texture2D texMinMaxRGB { Width = 2; Height = 1; Format = RGBA16f; };
	sampler2D samplerMinMaxRGB
	{ 
		Texture = texMinMaxRGB;
		MagFilter = POINT;
		MinFilter = POINT;
		MipFilter = POINT;
	};
	
	texture2D texMinMaxRGBLastFrame { Width = BUFFER_WIDTH * Scale_Buffer; Height = BUFFER_HEIGHT * Scale_Buffer; Format = RGBA16f; };
	sampler2D samplerMinMaxRGBLastFrame 
	{
		 Texture = texMinMaxRGBLastFrame;
		 MagFilter = POINT;
		 MinFilter = POINT;
		 MipFilter = POINT;
	};

	void MinMaxRGB(float4 vpos : SV_Position, float2 texcoord : TexCoord, out float4 minmaxRGB : SV_Target0)
	{
		float3 color, minRGB = 1.0, maxRGB = 0.0;
		int2 SIZE_STEPS = Res/15;
		if(Color_Correction)
		{ 
		for(int y = 0; y <= Res.y; y+= SIZE_STEPS.y) 
		{
			for(int x = 0; x <= Res.x; x+= SIZE_STEPS.x) 
			{
				color = tex2Dfetch(BackBufferCLAMP, uint4(x, y,0,0)).rgb;
				
				if(color.r <= 0.01 && color.g <= 0.01 && color.b <= 0.01)
					color = tex2Dlod(BackBufferCLAMP, float4(texcoord,0,0)).rgb;
					
				maxRGB.rgb = lerp(maxRGB.rgb, color.rgb, step(maxRGB.rgb, color.rgb));
				minRGB.rgb = lerp(minRGB.rgb, color.rgb, step(color.rgb, minRGB.rgb));
			}
		}

		float factor = saturate(0.1 * frametime * 0.01);

		float avgMax = dot( maxRGB.xyz, 0.333333f ) * lerp(3,1,Correction_Strength);

		minRGB.rgb = lerp(tex2D(samplerMinMaxRGBLastFrame, float2(0.25, 0)).rgb, minRGB.rgb, factor);
		maxRGB.rgb = lerp(tex2D(samplerMinMaxRGBLastFrame, float2(0.75, 0)).rgb, maxRGB.rgb * ( 1.0f - avgMax ) + avgMax, factor);

		minmaxRGB.rgb = saturate(texcoord.x < 0.5 ? minRGB.rgb : maxRGB.rgb);
		minmaxRGB.a = 1.0;
		}
		else
		minmaxRGB = 0;
	}
	
	float2 Lum(float2 texcoord)
	{   //Luminance
			return saturate(tex2Dlod(SamplerLumVR,float4(texcoord,0,11)).xy);//Average Luminance Texture Sample
	}
	////////////////////////////////////////////////////Distortion Correction//////////////////////////////////////////////////////////////////////
	#if BD_Correction || BDF
	float2 D(float2 p, float k1, float k2, float k3) //Lens + Radial lens undistort filtering Left & Right
	{   // Normalize the u,v coordinates in the range [-1;+1]
		p = (2. * p - 1.);
		// Calculate Zoom
		p *= 1 + Zoom;
		// Calculate l2 norm
		float r2 = p.x*p.x + p.y*p.y;
		float r4 = r2 * r2;
		float r6 = r4 * r2;
		// Forward transform
		float x2 = p.x * (1. + k1 * r2 + k2 * r4 + k3 * r6);
		float y2 = p.y * (1. + k1 * r2 + k2 * r4 + k3 * r6);
		// De-normalize to the original range
		p.x = (x2 + 1.) * 1. * 0.5;
		p.y = (y2 + 1.) * 1. * 0.5;
	
	return p;
	}
	#endif
	///////////////////////////////////////////////////////////3D Image Adjustments/////////////////////////////////////////////////////////////////////
	#if D_Frame || DFW
	float4 CurrentFrame(in float4 position : SV_Position, in float2 texcoords : TEXCOORD) : SV_Target
	{
			return tex2Dlod(BackBufferCLAMP,float4(texcoords,0,0));
	}
	
	float4 DelayFrame(in float4 position : SV_Position, in float2 texcoords : TEXCOORD) : SV_Target
	{
		return tex2Dlod(SamplerCF,float4(texcoords,0,0));
	}
	
	float4 CSB(float2 texcoords)
	{
		if(Depth_Map_View == 0)
			return tex2Dlod(SamplerDF,float4(texcoords,0,0));
		else
			return tex2D(SamplerzBufferVR_P,texcoords).xxxx;
	}
	#else
	float4 CSB(float2 texcoords)
	{   //Cal Basic Vignette
		float2 TC = -texcoords * texcoords*32 + texcoords*32;
		float WTF_Fable = 0.00000000000001;
		if(!Depth_Map_View)
			return tex2Dlod(BackBuffer,float4(texcoords,0,0)) * smoothstep(WTF_Fable,(WTF_Fable+Adjust_Vignette)*27.0f,TC.x * TC.y) ;
		else
			return tex2Dlod(SamplerzBufferVR_P,float4(texcoords,0,0)).xxxx;
	}
	#endif
	
	#if LBC || LBM || LB_Correction || LetterBox_Masking
	int LBSensitivity( float inVal )
	{
		#if LBS
			return inVal < 0.005; //Less Sensitive
		#else
			return inVal == 0; //Sensitive
		#endif
	}
	
	float SLLTresh(float2 TCLocations, float MipLevel)
	{ 
		return tex2Dlod(SamplerDMVR,float4(TCLocations,0, MipLevel)).w;
	}
	
	bool LBDetection()//Active RGB Detection
	{   float2 Letter_Box_Reposition = LBR ? float2(0.250,0.875) : float2(0.1,0.5);   
		float MipLevel = 5,Center = SLLTresh(float2(0.5,0.5), 7) > 0, Top_Left = LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.x,0.09), MipLevel));
		if ( LetterBox_Masking == 2 || LB_Correction == 2 || LBC == 2 || LBM == 2 || SMP == 2)//Left_Center | Right_Center | Center
			return LBSensitivity(SLLTresh(float2(0.1,0.5), MipLevel)) && LBSensitivity(SLLTresh(float2(0.9,0.5), MipLevel)) && Center; //Vert
		else       //Top | Bottom | Center
			return Top_Left && LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.y,0.91), MipLevel)) && Center; //Hoz
	}
	#else
	bool LBDetection()//Stand in for not crashing when not in use
	{	
		return 0;
	}	
	#endif
	
	#if SDT || SD_Trigger
	float TargetedDepth(float2 TC)
	{
		return smoothstep(0,1,tex2Dlod(SamplerzBufferVR_P,float4(TC,0,0)).y);
	}
	
	float SDTriggers()//Specialized Depth Triggers
	{   float Threshold = 0.001;//Both this and the options below may need to be adjusted. A Value lower then 7.5 will break this.!?!?!?!
		if ( SD_Trigger == 1 || SDT == 1)//Top _ Left                             //Center_Left                             //Botto_Left
			return (TargetedDepth(float2(0.95,0.25)) >= Threshold ) && (TargetedDepth(float2(0.95,0.5)) >= Threshold) && (TargetedDepth(float2(0.95,0.75)) >= Threshold) ? 0 : 1;
		else																	  //Center				
			return (TargetedDepth(float2(0.5,0.1)) >= 1 ) && (TargetedDepth(float2(0.5,0.5)) < 1) && (TargetedDepth(float2(0.5,0.9)) >= 1) ? 0 : 1;
	}
	#else
	float SDTriggers()//Stand in for not crashing when not in use
	{	
		return 0;
	}
	#endif
	
	#if MMD || MDD || Menu_Masking
	float3 C_Tresh(float2 TCLocations)//Color Tresh
	{ 
		return tex2Dlod(BackBufferCLAMP,float4(TCLocations,0, 0)).rgb;
	}
	
	bool Check_Color(float2 Pos_IN, float C_Value)
	{	float3 RGB_IN = C_Tresh(Pos_IN);
		return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) == C_Value;
	}
	#endif
	
	#if MDD || Menu_Masking
	int Color_Likelyhood(float2 Pos_IN, float C_Value, int Switcher)
	{	float3 RGB_IN = C_Tresh(Pos_IN);
		return FN_Value(RGB_IN.r) + FN_Value(RGB_IN.g) + FN_Value(RGB_IN.b) == C_Value ? Switcher : 0;
	}
	
	float Menu_Size()//Active RGB Detection
	{ 
			#if Menu_Masking
			float2 Pos_A = POS_XYZW[0].xy, Pos_B = POS_XYZW[0].zw, Pos_C = POS_XYZW[1].xy,
				   Pos_D = POS_XYZW[1].zw, Pos_E = POS_XYZW[2].xy, Pos_F = POS_XYZW[2].zw;
			float Menu_Size_Selection[5] = { 0.0, Set_Menu_Size.x, Set_Menu_Size.y, Set_Menu_Size.z, Set_Menu_Size.w };
			float4 MT_Values = Menu_Type;
			float3 SMT_Values = Set_Match_Threshold;
			#elif MDD
			float2 Pos_A = DN_X.xy, Pos_B = DN_X.zw, Pos_C = DN_Y.xy,
				   Pos_D = DN_Y.zw, Pos_E = DN_Z.xy, Pos_F = DN_Z.zw;
			float Menu_Size_Selection[5] = { 0.0, DN_W.x, DN_W.y, DN_W.z, DN_W.w };
			float4 MT_Values = DJ_Y;
			float3 SMT_Values = DJ_Z;
			#endif		
			#if MAC
			float Menu_AC_To_C = Check_Color(Pos_A, MT_Values.x);
			#else
			float Menu_AC_To_C = Check_Color(Pos_A, MT_Values.x) || Check_Color(Pos_A, MT_Values.w);
			#endif
			float Menu_Detection = Menu_AC_To_C &&                                      //X & W is wiled Card. If MAC is enabled this is Disabled.
				   Check_Color(Pos_B, MT_Values.y) &&                                   //Y
				  (Check_Color(Pos_C, MT_Values.z) || Check_Color(Pos_C, MT_Values.w)), //Z & W is wiled Card.
				  Menu_Change = Menu_Detection + Color_Likelyhood(Pos_D, SMT_Values.x , 1) + Color_Likelyhood(Pos_E, SMT_Values.y , 2) + Color_Likelyhood(Pos_F, SMT_Values.z, 3);
	
			return Menu_Detection > 0 ? Menu_Size_Selection[clamp((int)Menu_Change,0,4)] : 0;
	}	
	#endif
	
	#if MMD //Simple Menu Masking
	bool Check_Color_MinMax_A(float2 Pos_IN)
	{	float3 RGB_IN = C_Tresh(Pos_IN);
		if ( MMS == 1 || MMS == 2)
			return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) >= 29.0;
		else
			return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) <= 1.0;
	}
	
	bool Check_Color_MinMax_B(float2 Pos_IN)
	{	float3 RGB_IN = C_Tresh(Pos_IN);
		if ( MMS == 2)
			return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) >= 29.0;
		else
			return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) <= 1.0;
	}	
	float4 Simple_Menu_Detection()//Active RGB Detection
	{ 
		return float4( Check_Color(DO_X.xy, DO_W.x) && Check_Color_MinMax_A(DO_X.zw) && Check_Color( DO_Y.xy, DO_W.y),
					   Check_Color(DO_Y.zw, DO_W.z) && Check_Color_MinMax_A(DO_Z.xy) && Check_Color( DO_Z.zw, DO_W.w),
					   Check_Color(DP_X.xy, DP_W.x) && Check_Color_MinMax_A(DP_X.zw) && Check_Color( DP_Y.xy, DP_W.y),
					   Check_Color(DP_Y.zw, DP_W.z) && Check_Color_MinMax_A(DP_Z.xy) && Check_Color( DP_Z.zw, DP_W.w) );
	}
		#if MMD == 3 || MMD == 4
		float4 Simple_Menu_Detection_EX()//Active RGB Detection Extended
		{ 
			return float4( Check_Color(DQ_X.xy, DQ_W.x) && Check_Color_MinMax_B(DQ_X.zw) && Check_Color( DQ_Y.xy, DQ_W.y),
						   Check_Color(DQ_Y.zw, DQ_W.z) && Check_Color_MinMax_B(DQ_Z.xy) && Check_Color( DQ_Z.zw, DQ_W.w),
					   	Check_Color(DR_X.xy, DR_W.x) && Check_Color_MinMax_B(DR_X.zw) && Check_Color( DR_Y.xy, DR_W.y),
					   	Check_Color(DR_Y.zw, DR_W.z) && Check_Color_MinMax_B(DR_Z.xy) && Check_Color( DR_Z.zw, DR_W.w) );
		}
		#endif
	#endif
	/////////////////////////////////////////////////////////////Cursor///////////////////////////////////////////////////////////////////////////
	float4 EdgeMask(float4 color, float2 texcoords, float Adjust_Value)
	{	
		float2 center = float2(0.5,texcoords.y); // Direction of effect.   
		float BaseVal = 1.0,
			  Dist  = distance( center, texcoords ) * 2.0, 
			  EdgeMask = clamp((BaseVal-Dist) / (BaseVal-Adjust_Value),0.125,1); 
	    return color * EdgeMask;    
	}

	#define FLT_EPSILON  1.192092896e-07 // smallest such that Value + FLT_EPSILON != Value		
	float DepthEdge(float Mod_Depth, float Depth, float2 texcoords, float Adjust_Value )
	{   Adjust_Value -= FLT_EPSILON;
		float2 center = float2(0.5,texcoords.y); // Direction of effect.   
		float BaseVal = 1.0,
			  Dist  = distance( center, texcoords ) * 2.0, 
			  EdgeMask = saturate((BaseVal-Dist) / (BaseVal-Adjust_Value)),
			  Set_Weapon_Scale_Near = -min(0.5,Weapon_Depth_Edge.y);//So it don't hang the game. 
	    return lerp(Depth,(Mod_Depth - Set_Weapon_Scale_Near) / (1 + Set_Weapon_Scale_Near), EdgeMask );    
	}

	float CCBox(float2 TC, float2 size) 
	{
		TC = abs(TC)-size;
	    return length(max(TC,0.0)) + min(max(TC.x,TC.y),0.0);
	}
	
	float CCRetical(float2 TC, float2 size) 
	{	 float2 BTC = abs(TC)-(size * 0.25);
	    return min(CCBox(TC, float2( size.x, size.y / 9)), 
				   CCBox( TC, float2( size.x / 9, size.y))) * -length(max(BTC,0.0)) + min(max(BTC.x,BTC.y),0.0);
	}
	
	float CCCross(float2 TC, float2 size) 
	{
	    return min(CCBox(TC, float2( size.x, size.y / 9)), 
				   CCBox( TC, float2( size.x / 9, size.y))) ;
	}
	
	float CCCursor(float2 TC, float2 size) 
	{
	    return CCBox(TC-size, size ) * CCBox(TC-size * 1.25, size * 0.375) * CCBox(TC-size * 1.25, size * 0.750);
	}
	
	float CCCBox(float2 TC, float2 size) 
	{
		float Rot = radians(45);
	    float2 Rotationtexcoord = TC ;
	    float sin_factor = sin(Rot), cos_factor = cos(Rot);
	    Rotationtexcoord = mul(Rotationtexcoord ,float2x2(float2( cos_factor, -sin_factor) ,float2( sin_factor,  cos_factor) ));
		
	    return   CCBox(Rotationtexcoord, size ) *  CCBox(Rotationtexcoord, size * 0.6 ) ;
	}
	
	float4 MouseCursor(float2 texcoord, float2 pos)
	{   float4 Out = CSB(texcoord),Color, Exp_Darks, Exp_Brights;
			float Cursor;
			if(Cursor_Type > 0)
			{
				float CCScale = lerp(0.005,0.025,Scale(Cursor_SC.x,10,0));//scaling
				float2 MousecoordsXY = texcoord - (Mousecoords * pix), Scale_Cursor = float2(CCScale,CCScale* ARatio );
	
				if (Cursor_Lock && !CLK)
				MousecoordsXY = texcoord - float2(0.5,lerp(0.5,0.5725,Scale(Cursor_SC.z,10,0) ));
	
				if(Toggle_Cursor)
				{
				if(Cursor_Type == 1)
					Cursor = smoothstep( 0.0, 2 / pix.y, CCRetical( MousecoordsXY.xy, Scale_Cursor  * 0.75 ) ) ;
				else if (Cursor_Type == 2)
					Cursor = smoothstep( 0.0, 2 / pix.y, -CCCBox( MousecoordsXY.xy, CCScale * 0.375 ) ) ;
				else if (Cursor_Type == 3)
					Cursor = smoothstep( 0.0, 2 / pix.y, -CCBox( MousecoordsXY.xy, CCScale * 0.25 ) ) ;	
				else if (Cursor_Type == 4)
					Cursor = smoothstep( 0.0, 2 / pix.y, -CCCross( MousecoordsXY.xy, Scale_Cursor  * 0.75  ) ) ;			
				else if (Cursor_Type == 5)
					Cursor = smoothstep( 0.0, 2 / pix.y, -CCCursor( MousecoordsXY.xy, Scale_Cursor  * 0.5  ) ) ;
				}
	
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

			if(Toggle_Deband)
			{
				//Code I asked Marty McFly | Pascal for and he let me have.
				const float SEARCH_RADIUS = 1, Depth_Sample = tex2Dlod(SamplerzBufferVR_P,float4(texcoord,0,0)).x < 0.98;
				const float2 magicdot = float2(0.75487766624669276, 0.569840290998);
				const float3 magicadd = float3(0, 0.025, 0.0125) * dot(magicdot, 1);
				float3 dither = frac(dot(pos.xy, magicdot) + magicadd);
				
				//LinerSampleDepth
				float LinerSampleDepth = rcp( exp2( BUFFER_COLOR_BIT_DEPTH ) - 1.0);
				
				float2 shift;
				sincos(6.283 * 30.694 * dither.x, shift.x, shift.y);
				shift = shift * dither.x - 0.5;
				
				texcoord.xy = texcoord.xy + lerp(0,37.5 * pix,SEARCH_RADIUS);
				
				float3 scatter =  CSB(texcoord + shift * lerp(0,pix * 75,SEARCH_RADIUS)).rgb;
				float3 diff = Depth_Sample ? abs(Out.rgb - scatter) : all(Out.rgb - scatter); 
					   diff.x = max(max(diff.x, diff.y), diff.z) ;
				
				Out.rgb = lerp(Out.rgb, scatter, diff.x <= LinerSampleDepth);
			}
			
			float3 minRGB = tex2D(samplerMinMaxRGB, float2(0.25,0.0)).rgb;
			float3 maxRGB = tex2D(samplerMinMaxRGB, float2(0.75,0.0)).rgb;
			
			if(Color_Correction)
				Out.rgb = saturate( (Out.rgb - minRGB) / (maxRGB-minRGB) );
		
			Out = Cursor ? Color.rgb : Out.rgb;
	
			return Out;
	}
	//////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////
	float DMA() //Small List of internal Multi Game Depth Adjustments.
	{ 
		#if !OSW 
		return DMA_Overwatch( WP, Depth_Map_Adjust);
		#else
		return Depth_Map_Adjust;
		#endif
	}
	
	float4 TC_SP(float2 texcoord)
	{   float LBDetect = tex2D(SamplerLumVR,float2(1, 0.083)).z;
		float2 H_V_A, H_V_B, X_Y_A, X_Y_B, S_texcoord = texcoord;
		#if BD_Correction || BDF
		if(BD_Options == 0 || BD_Options == 2)
		{
			float3 K123 = Colors_K1_K2_K3 * 0.1;
			texcoord = D(texcoord.xy,K123.x,K123.y,K123.z);
		}
		#endif
		
		#if DB_Size_Position || SPF || LBC || LB_Correction || SDT || SD_Trigger
		
			#if SDT || SD_Trigger
				X_Y_A = float2(Image_Position_Adjust.x,Image_Position_Adjust.y) + (SDTriggers() ? float2( DG_X , DG_Y) : 0.0);
			#endif

			#if LBC || LB_Correction
				X_Y_A = Image_Position_Adjust + (LBDetect && LB_Correction_Switch ? Image_Pos_Offset : 0.0f );
				X_Y_B = Image_Position_Adjust + Image_Pos_Offset;
					if((SDT == 2 || SD_Trigger == 2) && SDTriggers() && LBDetect)
					   X_Y_A = float2(Image_Position_Adjust.x,Image_Position_Adjust.y); 
			#else
				X_Y_A = float2(Image_Position_Adjust.x,Image_Position_Adjust.y);
			#endif


	
		texcoord.xy += float2(-X_Y_A.x,X_Y_A.y)*0.5;
		S_texcoord.xy += float2(-X_Y_B.x,X_Y_B.y)*0.5;
		
			#if LBC || LB_Correction
				H_V_A = Horizontal_and_Vertical * (LBDetect && LB_Correction_Switch ? H_V_Offset : 1.0f );
				H_V_B = Horizontal_and_Vertical * H_V_Offset;
					if((SDT == 2 || SD_Trigger == 2) && SDTriggers() && LBDetect)
						H_V_A = Horizontal_and_Vertical;	
			#else
				H_V_A = Horizontal_and_Vertical;
			#endif
			
		float2 midHV_A = (H_V_A-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
		texcoord = float2((texcoord.x*H_V_A.x)-midHV_A.x,(texcoord.y*H_V_A.y)-midHV_A.y);

		float2 midHV_B = (H_V_B-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
		S_texcoord = float2((S_texcoord.x*H_V_B.x)-midHV_B.x,(S_texcoord.y*H_V_B.y)-midHV_B.y);
		#endif
		return float4(texcoord,S_texcoord);
	}
	/* Not needed Yet may add it in later. If I feel like it.
	float Log_DB(float DB)
	{
		const float C = 0.01;
		// RESHADE LOGARITHMIC DEPTH FUNCTIONS FROM RESHADE.FXH
		zBuffer = (exp(zBuffer * log(C + 1.0)) - 1.0) / C;
	}
	*/
	float Depth(float2 texcoord)
	{
		//Conversions to linear space.....
		float zBuffer = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x, Far = 1.0, Near = 0.125/DMA(); //Near & Far Adjustment
	
		//Man Why can't depth buffers Just Be Normal
		float2 C = float2( Far / Near, 1.0 - Far / Near ), Z = Offset < 0 ? min( 1.0, zBuffer * ( 1.0 + abs(Offset) ) ) : float2( zBuffer, 1.0 - zBuffer );
	
		if(Offset > 0 || Offset < 0)
			Z = Offset < 0 ? float2( Z.x, 1.0 - Z.y ) : min( 1.0, float2( Z.x * (1.0 + Offset) , Z.y / (1.0 - Offset) ) );
		//MAD - RCP
		if (Depth_Map == 0) //DM0 Normal
			zBuffer = rcp(Z.x * C.y + C.x);
		else if (Depth_Map == 1) //DM1 Reverse
			zBuffer = rcp(Z.y * C.y + C.x);
		return saturate(zBuffer);
	}
	//Weapon Setting//
	float4 WA_XYZW()
	{
		float4 WeaponSettings_XYZW = Weapon_Adjust;
		#if WSM >= 1
			WeaponSettings_XYZW = Weapon_Profiles(WP, Weapon_Adjust);
		#endif
		//"X, CutOff Point used to set a different scale for first person hand apart from world scale.\n"
		//"Y, Precision is used to adjust the first person hand in world scale.\n"
		//"Z, Tuning is used to fine tune the precision adjustment above.\n"
		//"W, Scale is used to compress or rescale the weapon.\n"	
		return float4(WeaponSettings_XYZW.xyz,-WeaponSettings_XYZW.w + 1);
	}
	//Weapon Depth Buffer//
	float2 WeaponDepth(float2 texcoord)
	{   //Conversions to linear space.....
		float zBufferWH = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x, Far = 1.0, Near = 0.125/(0.00000001 + WA_XYZW().y);  //Near & Far Adjustment
	
		float2 Offsets = float2(1 + WA_XYZW().z,1 - WA_XYZW().z), Z = float2( zBufferWH, 1-zBufferWH );
	
		if (WA_XYZW().z > 0)
		Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));
	
		[branch] if (Depth_Map == 0)//DM0. Normal
			zBufferWH = Far * Near / (Far + Z.x * (Near - Far));
		else if (Depth_Map == 1)//DM1. Reverse
			zBufferWH = Far * Near / (Far + Z.y * (Near - Far));
	
		return float2(saturate(zBufferWH), WA_XYZW().x);
	}
	//3x2 and 2x3 not supported on older ReShade versions. I had to use 3x3. Old Values for 3x2
	float3x3 PrepDepth(float2 texcoord)//[0][0] = R | [0][1] = G | [1][0] = B //[1][1] = A | [2][0] = D | [2][1] = DM
	{   int Flip_Depth = Flip_Opengl_Depth ? !Depth_Map_Flip : Depth_Map_Flip;
	
		if (Flip_Depth)
			texcoord.y =  1 - texcoord.y;
	
		texcoord.xy -= DLSS_FSR_Offset.xy * pix;
	
		float4 DM = Depth(TC_SP(texcoord).xy).xxxx;
		float R, G, B, A, WD = WeaponDepth(TC_SP(texcoord).xy).x, CoP = WeaponDepth(TC_SP(texcoord).xy).y, CutOFFCal = (CoP/DMA()) * 0.5; //Weapon Cutoff Calculation
		CutOFFCal = step(DM.x,CutOFFCal);
	
		[branch] if (WP == 0)
			DM.x = DM.x;
		else
		{
			DM.x = lerp(DM.x,WD,CutOFFCal);
			DM.y = lerp(0.0,WD,CutOFFCal);
			DM.z = lerp(0.5,WD,CutOFFCal);
		}
	
		R = DM.x; //Mix Depth
		G = DM.y > saturate(smoothstep(0,2.5,DM.w)); //Weapon Mask
		B = DM.z; //Weapon Hand
		A = ZPD_Boundary >= 4 ? max( G, R) : R; //Grid Depth
	
		return float3x3( saturate(float3(R, G, B)) , 													   //[0][0] = R | [0][1] = G | [0][2] = B
						 saturate(float3(A,Depth( SDT == 1 || SD_Trigger == 1 ? texcoord : TC_SP(texcoord).xy).x,DM.w)) , //[1][0] = A | [1][1] = D | [1][2] = DM 
								  float3(0,0,0) );														  //[2][0] = Null | [2][1] = Null | [2][2] = Null
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
	{ float TCoRF[1], Trigger_Fade, AA = Fade_Time_Adjust, PStoredfade = tex2D(SamplerLumVR,float2(0,0.083)).z;
		if(Eye_Fade_Reduction_n_Power.y == 0)
			AA *= 0.75;
		if(Eye_Fade_Reduction_n_Power.y == 2)
			AA *= 1.25;
		if(Eye_Fade_Reduction_n_Power.y == 3)
			AA *= 1.375;
		if(Eye_Fade_Reduction_n_Power.y == 4)
			AA *= 1.5;
		//Fade in toggle.
		if(FPSDFIO == 1)
			Trigger_Fade = Trigger_Fade_A;
		else if(FPSDFIO == 2)
			Trigger_Fade = Trigger_Fade_B;
	
		return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/((1-AA)*1000))); ///exp2 would be even slower
	}
	
	float Auto_Adjust_Cal(float Val)
	{
		return (1-(Val*2.))*1000;
	}
	
	float2x4 Fade(float2 texcoord)
	{   //Check Depth
		float CD, Detect, Detect_Out_of_Range;
		if(ZPD_Boundary > 0)
		{
			#if LBM || LetterBox_Masking
			const float2 LB_Dir = float2(0.150,0.850);
			#else
			const float2 LB_Dir = float2(0.125,0.875);
			#endif   
			float4 Switch_Array = ZPD_Boundary == 6 ? float4(0.825,0.850,0.875,0.900) : float4(1.0,0.875,0.75,0.625);
			//Normal A & B for both	
			const float CDArray_X_A0[7] = { LB_Dir.x, 0.25, 0.375, 0.5, 0.625, 0.75, LB_Dir.y}, 
						CDArray_X_B0[7] = { 0.25, 0.375, 0.4375, 0.5, 0.5625, 0.625, 0.75}, 
						CDArray_X_C0[9] = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9};
							
			const float CDArray_Y_A0[5] = { 0.3, 0.5, 0.625, 0.75, 0.875}, 
						CDArray_Y_B0[5] = { 0.3, 0.4, 0.5, 0.625, 0.75},
						CDArray_Y_C0[4] = { 0.25, 0.5, 0.75, 0.875};

			float CDArrayZPD_A[7] = { ZPD_Separation.x * Switch_Array.w, ZPD_Separation.x * Switch_Array.z, ZPD_Separation.x * Switch_Array.y, ZPD_Separation.x * Switch_Array.x, ZPD_Separation.x * Switch_Array.y, ZPD_Separation.x * Switch_Array.z, ZPD_Separation.x * Switch_Array.w },
				  CDArrayZPD_B[7] = { ZPD_Separation.x * 0.3, ZPD_Separation.x * 0.5, ZPD_Separation.x * 0.75, ZPD_Separation.x, ZPD_Separation.x * 0.75, ZPD_Separation.x * 0.5, ZPD_Separation.x * 0.3},
	 			 CDArrayZPD_C[9] = { ZPD_Separation.x * 0.5625, ZPD_Separation.x * 0.75, ZPD_Separation.x * 0.875, ZPD_Separation.x * 0.9375, 
									   ZPD_Separation.x,
									   ZPD_Separation.x * 0.9375, ZPD_Separation.x * 0.875, ZPD_Separation.x * 0.75, ZPD_Separation.x * 0.5625 };	
			//Screen Space Detector 7x6 Grid from between 0 to 1 and ZPD Detection becomes stronger as it gets closer to the Center.
			float Shift_Per_Frame = Alternate ? 0 : 0.0625;
			float2 GridXY; int2 iXY = ( ZPD_Boundary == 3 ? int2( 9, 4) : int2( 7, 5) );//was 12/4 and 7/7 This reduction saves 0.1 ms and should show no diff to the user.
			[loop]                                                                       //I was thinking the lowest I can go would be 9/4 along with 7/5
			for( int iX = 0 ; iX < iXY.x; iX++ )                                         //7 * 7 = 49 | 12 * 4 = 48 | 7 * 6 = 42 | 9 * 4 = 36 | 7 * 5 = 35
			{   [loop]
				for( int iY = 0 ; iY < iXY.y; iY++ )
				{
					if(ZPD_Boundary == 1 || ZPD_Boundary == 6 || ZPD_Boundary == 7)
						GridXY = float2( CDArray_X_A0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 2 || ZPD_Boundary == 5)
						GridXY = float2( CDArray_X_B0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 3)
						GridXY = float2( CDArray_X_C0[iX], CDArray_Y_C0[min(3,iY)]);
					else if(ZPD_Boundary == 4)
						GridXY = float2( CDArray_X_A0[iX], CDArray_Y_B0[iY]);
					//GridXY.x += fmod(CDArray_Y_C0[min(3,iY)],0.25) ? 0.05 : 0;
					if( AFD )
						GridXY.x += Shift_Per_Frame;

					float ZPD_I = ZPD_Boundary == 3 ?  CDArrayZPD_C[iX] : (ZPD_Boundary == 2 || ZPD_Boundary == 5  ? CDArrayZPD_B[iX] : CDArrayZPD_A[iX]);		

					float PDepth = PrepDepth(GridXY)[1][0];
					
					if(ZPD_Boundary >= 4)
					{
						if ( PDepth == 1 )
							ZPD_I = 0;
					}
					// CDArrayZPD[i] reads across prepDepth.......
					CD = 1 - ZPD_I / PDepth;
	
					if ( CD < -Set_Pop_Min().x )
						Detect = 1;
					//Used if Depth Buffer is way out of range or if you need granuality.
					if(RE_Set(0).x)
					{					
						if ( CD < -DI_W.x && Detect_Out_of_Range <= 1)
							Detect_Out_of_Range = 1;		
							
						#if OIL >= 1
						if ( CD < -DI_W.y && Detect_Out_of_Range <= 2)
							Detect_Out_of_Range = 2;							
						#endif
						#if OIL >= 2
						if ( CD < -DI_W.z && Detect_Out_of_Range <= 3)
							Detect_Out_of_Range = 3;							
						#endif
						#if OIL >= 3	
						if ( CD < -DI_W.w && Detect_Out_of_Range <= 4)
							Detect_Out_of_Range = 4;
						#endif							
					}
				}
			}
		}
		int Sat_D_O_R = saturate(Detect_Out_of_Range);
		float ZPD_BnF = Auto_Adjust_Cal(Fast_Trigger_Mode && Sat_D_O_R ? 0.5 : ZPD_Boundary_n_Fade.y);		
		float Trigger_Fade_A = Detect, Trigger_Fade_B = Detect_Out_of_Range >= 1, Trigger_Fade_C = Detect_Out_of_Range >= 2, Trigger_Fade_D = Detect_Out_of_Range, Trigger_Fade_E = Detect_Out_of_Range >= 4, AA = Auto_Adjust_Cal(ZPD_Boundary_n_Fade.y), 
			  PStoredfade_A = tex2D(SamplerLumVR,float2(0, 0.250)).z, PStoredfade_B = tex2D(SamplerLumVR,float2(0, 0.416)).z, PStoredfade_C = tex2D(SamplerLumVR,float2(1, 0.416)).z, PStoredfade_D = tex2D(SamplerLumVR,float2(1, 0.250)).z, PStoredfade_E = tex2D(SamplerLumVR,float2(1, 0.583)).z;
		//Fade in toggle.
		float2 CallFT = 1.0 - exp(float2(-frametime/AA,-frametime/ZPD_BnF));//exp2 would be even slower
		return float2x4( float4(PStoredfade_A + (Trigger_Fade_A - PStoredfade_A) * CallFT.x,  
								PStoredfade_B + (Trigger_Fade_B - PStoredfade_B) * CallFT.y,
								PStoredfade_C + (Trigger_Fade_C - PStoredfade_C) * CallFT.y, 
								PStoredfade_D + (Trigger_Fade_D - PStoredfade_D) * CallFT.y),
						 float4(PStoredfade_E + (Trigger_Fade_E - PStoredfade_E) * CallFT.y,
								0,
								0,
								saturate(Detect_Out_of_Range * 0.25)) );
	}
	
	float Motion_Blinders(float2 texcoord)
	{   float Trigger_Fade = tex2Dlod(SamplerLumVR,float4(texcoord,0,11)).x * lerp(0.0,25.0,Blinders), AA = (1-Fade_Time_Adjust)*1000, PStoredfade = tex2D(SamplerLumVR,float2(1,0.916)).z;
		return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp2(-frametime/AA)); ///exp2 would be even slower
	}
	#define FadeSpeed_AW 0.375
	float AltWeapon_Fade()
	{
		float  ExAd = (1-(FadeSpeed_AW * 2.0))*1000, Current =  min(0.75f,smoothstep(0,0.25f,PrepDepth(0.5f)[0][0])), Past = tex2D(SamplerLumVR,float2(0,0.750)).z;
		return Past + (Current - Past) * (1.0 - exp(-frametime/ExAd));
	}
	#define FadeSpeed_AF 0.4375
	float Weapon_ZPD_Fade(float Weapon_Con)
	{
		float  ExAd = (1-(FadeSpeed_AF * 2.0))*1000, Current =  Weapon_Con, Past = tex2D(SamplerLumVR,float2(0,0.916)).z;
		return Past + (Current - Past) * (1.0 - exp(-frametime/ExAd));
	}
	//////////////////////////////////////////////////////////Depth Map Alterations/////////////////////////////////////////////////////////////////////
		float2 Auto_Balance_Selection()
	{
			float4 XYArray[9] = { float4 ( 0.0  , 0.0, 0.0  , 0.0),        //Off                  0
								  float4 ( 0.25 , 0.5, 0.0  , 0.0),        //Left                 1
								  float4 ( 0.5  , 0.5, 0.0  , 0.0),        //Center               2
								  float4 ( 0.75 , 0.5, 0.0  , 0.0),        //Right                3
								  float4 ( 0.375, 0.5, 0.625, 0.5),        //Center Wide          4
								  float4 ( 0.25 , 0.5, 0.375, 0.5),        //Left Wide            5
								  float4 ( 0.75 , 0.5, 0.625, 0.5),        //Right Wide           6
								  float4 (0,0,0.0,0.0), //Eye Tracker     7
								  float4 (0,0,0.0,0.0)};//Eye Tracker Alt 8
			
		float AB_EX = lerp(Depth(XYArray[Auto_Balance_Ex].xy) , Depth(XYArray[Auto_Balance_Ex].zw), Auto_Balance_Ex > 3 && Auto_Balance_Ex < 7 ? 0.5 : 0 );
		return float2(Auto_Balance_Ex > 0 ? saturate(lerp(AB_EX * 2 , Lum(float2(0.5,0.5)).y , 0.25) ) : 1, saturate(lerp( Depth( float2(0.5,0.5) ) * 2 , Lum(float2(0.5,0.5)).y , 0.25) ) ) ;
	}

	float4 DepthMap(in float4 position : SV_Position,in float2 texcoord : TEXCOORD) : SV_Target
	{
		float4 DM = float4(PrepDepth(texcoord)[0][0],PrepDepth(texcoord)[0][1],PrepDepth(texcoord)[0][2],PrepDepth(texcoord)[1][1]);
		float R = DM.x, G = DM.y, B = DM.z, Auto_Scale = WZPD_and_WND.z > 0 ? lerp(lerp(1.0,0.625,saturate(WZPD_and_WND.z * 2)),1.0,lerp(Auto_Balance_Selection().y , smoothstep(0,0.5,tex2D(SamplerLumVR,float2(0,0.750)).z), 0.5)) : 1;
		float2 Min_Trim = float2(Set_Pop_Min().y, WZPD_and_WND.w * Auto_Scale);
		//Fade Storage
		float3 Fade_Pass_A = float3( tex2D(SamplerzBuffer_BlurVR,float2(0,0.083)).y,
									 tex2D(SamplerzBuffer_BlurVR,float2(0,0.250)).y,
									 tex2D(SamplerzBuffer_BlurVR,float2(0,0.416)).y );
		float3 Fade_Pass_B = float3( tex2D(SamplerzBuffer_BlurVR,float2(0,0.583)).y,
									 tex2D(SamplerzBuffer_BlurVR,float2(0,0.750)).y,
									 tex2D(SamplerzBuffer_BlurVR,float2(0,0.916)).y );
		float ScaleND = saturate(lerp(R,1.0f,smoothstep(min(-Min_Trim.x,0),1.0f,R)));
	
		if (Min_Trim.x > 0)
			R = saturate(lerp(ScaleND,R,smoothstep(0,Min_Trim.y,ScaleND)));
			
		if ( Weapon_Depth_Edge.x > 0)//1.0 needs to be adjusted when doing far scaling
			R = lerp(DepthEdge(R, DM.x, texcoord, 1-Weapon_Depth_Edge.x),DM.x,smoothstep(0,1.0,DM.x));
	
		if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TL
			R = Fade_in_out(texcoord);
		if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR
			R = Fade_Pass_A.x;
		if(   texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BL
			R = Fade_Pass_A.y;
		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
			R = Fade_Pass_A.z;

		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
			G = Fade_Pass_B.x;
		if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TL
			G = Fade_Pass_B.y;
		if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR
			G = Fade_Pass_B.z;
			
				//Luma Map
		float3 Color = tex2D(BackBufferCLAMP,texcoord ).rgb;
			   Color.x = max(Color.r, max(Color.g, Color.b)); 
	
		return saturate(float4(R,G,B,Color.x));
	}
	
	float AutoDepthRange(float d, float2 texcoord )
	{ float LumAdjust_ADR = smoothstep(-0.0175,Auto_Depth_Adjust,Lum(texcoord).y);
	    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
	}
	
	float3 Conv(float2 MD_WHD,float2 texcoord)
	{	float D = MD_WHD.x, Z = ZPD_Separation.x, WZP = 0.5, ZP = 0.5, W_Convergence = WZPD_and_WND.x, WZPDB, Distance_From_Bottom = 0.9375, ZPD_Boundary = ZPD_Boundary_n_Fade.x, Store_WC;
	    //Screen Space Detector.
		if (abs(Weapon_ZPD_Boundary.x) > 0)
		{   float WArray[8] = { 0.5, 0.5625, 0.625, 0.6875, 0.75, 0.8125, 0.875, 0.9375};
			float MWArray[8] = { 0.4375, 0.46875, 0.5, 0.53125, 0.625, 0.75, 0.875, 0.9375};
			float WZDPArray[8] = { 1.0, 0.5, 0.75, 0.5, 0.625, 0.5, 0.55, 0.5};//SoF ZPD Weapon Map
			[unroll] //only really only need to check one point just above the center bottom and to the right.
			for( int i = 0 ; i < 8; i++ )
			{
				if((WP == 22 || WP == 4) && WSM == 1)//SoF & BL 2
					WZPDB = 1 - (WZPD_and_WND.x * WZDPArray[i]) / tex2Dlod(SamplerDMVR,float4(float2(WArray[i],0.9375),0,0)).z;
				else
				{
					if (Weapon_ZPD_Boundary.x < 0) //Code for Moving Weapon Hand stablity.
						WZPDB = 1 - WZPD_and_WND.x / tex2Dlod(SamplerDMVR,float4(float2(MWArray[i],Distance_From_Bottom),0,0)).z;
					else //Normal
						WZPDB = 1 - WZPD_and_WND.x / tex2Dlod(SamplerDMVR,float4(float2(WArray[i],Distance_From_Bottom),0,0)).z;
				}
	
				if ( WZPDB < -DJ_W ) // Default -0.1
					W_Convergence *= 1.0-abs(Weapon_ZPD_Boundary.x);
				 //Used if Weapon Buffer is way out of range.
				if (Weapon_ZPD_Boundary.y > Weapon_ZPD_Boundary.x)
				{
					if ( WZPDB < -DS_W )
						W_Convergence *= 1.0-abs(Weapon_ZPD_Boundary.y);
				}
			}
		}
		//Store Weapon Convergence for Smoothing.
		Store_WC = W_Convergence;
		
		W_Convergence = 1 - tex2D(SamplerLumVR,float2(0,0.916)).z / MD_WHD.y;// 1-W_Convergence/D
		float WD = MD_WHD.y; //Needed to seperate Depth for the  Weapon Hand. It was causing problems with Auto Depth Range below.
	
			if (Auto_Depth_Adjust > 0)
				D = AutoDepthRange(D,texcoord);
	
				ZP = saturate( ZPD_Balance * max(0.5, Auto_Balance_Selection().x));

			float4 Set_Adjustments = RE_Set_Adjustments();
			float DOoR_A = smoothstep(0,1,tex2D(SamplerLumVR,float2(0, 0.250)).z), //ZPD_Boundary
				  DOoR_B = smoothstep(0,1,tex2D(SamplerLumVR,float2(0, 0.416)).z),  //Set_Adjustments X
				  DOoR_C = smoothstep(0,1,tex2D(SamplerLumVR,float2(1, 0.416)).z),    //Set_Adjustments Y
				  DOoR_D = smoothstep(0,1,tex2D(SamplerLumVR,float2(1, 0.250)).z),      //Set_Adjustments Z
				  DOoR_E = smoothstep(0,1,tex2D(SamplerLumVR,float2(1, 0.583)).z);        //Set_Adjustments W
				  
			float2 Detection_Switch_Amount = RE_Set(tex2D(SamplerLumVR,float2(1,0.750)).z).yz;																   

			if(RE_Set(0).x)
			{
				if(Fast_Trigger_Mode && Detection_Switch_Amount.y > 0)
					Set_Adjustments = Detection_Switch_Amount.x;
	
	
				DOoR_B = lerp(ZPD_Boundary, Set_Adjustments.x, DOoR_B);
					#if OIL == 0
					DOoR_E = DOoR_B;
					#endif
	
				#if OIL >= 1
				DOoR_C = lerp(DOoR_B, Set_Adjustments.y, DOoR_C);
					#if OIL == 1
					DOoR_E = DOoR_C;
					#endif	
				#endif
				
				#if OIL >= 2	
				DOoR_D = lerp(DOoR_C, Set_Adjustments.z, DOoR_D);
					#if OIL == 2
					DOoR_E = DOoR_D;
					#endif	
				#endif		
				
				#if OIL >= 3	
				DOoR_E = lerp(DOoR_D, Set_Adjustments.w, DOoR_E);
				#endif		
			}
			else
			DOoR_E = lerp(ZPD_Boundary, Detection_Switch_Amount.x, DOoR_B);
		
			if(Fast_Trigger_Mode)
				DOoR_A = saturate(DOoR_A+DOoR_B+DOoR_C+DOoR_D+DOoR_E);
			
			Z *= lerp( 1, DOoR_E, DOoR_A);
			
			float Convergence = 1 - Z / D;
			if (ZPD_Separation.x == 0)
				ZP = 1;
	
			if (WZPD_and_WND.x <= 0)
				WZP = 1;
	
			ZP = min(ZP,Auto_Balance_Clamp);
	
	    return float3( lerp( Convergence,min(saturate(Max_Depth),D), ZP), lerp(W_Convergence,WD,WZP), Store_WC);
	}
	
	float3 DB_Comb( float2 texcoord)
	{
		// X = Mix Depth | Y = Weapon Mask | Z = Weapon Hand | W = Normal Depth
		float4 DM = float4(tex2Dlod(SamplerDMVR,float4(texcoord,0,0)).xyz,PrepDepth( SDT == 1 || SD_Trigger == 1 ? TC_SP(texcoord).xy : texcoord )[1][1]);
		//Hide Temporal passthrough
		if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if(texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if(1-texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
			
		if (WP == 0 || WZPD_and_WND.x <= 0)
			DM.y = 0;
			
		float FadeIO = Focus_Reduction_Type == 0 ? 1 : smoothstep(0,1,1-Fade_in_out(texcoord).x), FD_Adjust = 0.125;	
	
		if( Eye_Fade_Reduction_n_Power.x == 1)
			FD_Adjust = 0.20;
		if( Eye_Fade_Reduction_n_Power.x == 2)
			FD_Adjust = 0.25;
		if( Eye_Fade_Reduction_n_Power.x == 3)
			FD_Adjust = 0.30;
		if( Eye_Fade_Reduction_n_Power.x == 4)
			FD_Adjust = 0.35;
	
		//Handle Convergence Here
		float3 HandleConvergence = Conv(DM.xz,texcoord).xyz;
			   HandleConvergence.y *= WA_XYZW().w;
			   HandleConvergence.y = lerp(HandleConvergence.y + FD_Adjust, HandleConvergence.y, FadeIO);
		DM.y = lerp( HandleConvergence.x, HandleConvergence.y, DM.y);
		//Better mixing for eye Comfort
		DM.z = DM.y;
		DM.y += lerp(DM.y,DM.x,DM.w);
		DM.y *= 0.5f;
		DM.y = lerp(DM.y,DM.z,0.9375f);
	
		float Edge_Adj = saturate(lerp(0.5,1.0,Edge_Adjust));
		
			DM = lerp(lerp(EdgeMask( DM, texcoord, 0.955 ),DM,  Edge_Adj), DM, saturate(1-DM.y) );
			
		if (Depth_Detection == 1)
		{
			if (!DepthCheck)
				DM = 0.0625;
		}
		
		#if MDD || Menu_Masking	
			float MSDT = Menu_Size(), Direction = texcoord.x < MSDT;
	
			#if (MDD  == 2 || Menu_Masking == 2)		
				Direction = texcoord.x > MSDT;
			#elif (MDD  == 3 || Menu_Masking == 3)		
				Direction = texcoord.y < MSDT;
			#elif (MDD  == 4 || Menu_Masking == 4)
				Direction = texcoord.y > MSDT;
			#endif
			if( MSDT > 0)
				DM = Direction ? 0.0625 : DM;
		#endif	
	
		#if MMD
		if(MMD == 1)
		{
			if( Simple_Menu_Detection().x == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection().y == 1)
				DM = 0.0625;
		}	
		else
		{		
			if( Simple_Menu_Detection().x == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection().y == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection().z == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection().w == 1)
				DM = 0.0625;
			#if MMD == 3 || MMD == 4
			if( Simple_Menu_Detection_EX().x == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_EX().y == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_EX().z == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_EX().w == 1)
				DM = 0.0625;
			#endif
		}
		#endif	
		
		if (Cancel_Depth)
			DM = 0.0625;
	
		#if Invert_Depth || IDF
			DM.y = 1 - DM.y;
		#endif
	
		#if UI_MASK
			DM.y = lerp(DM.y,0,step(1.0-HUD_Mask(texcoord),0.5));
		#endif
	
		#if LBM || LetterBox_Masking
			float LB_Dir = LetterBox_Masking == 2 || LBM == 2 ? texcoord.x : texcoord.y;
			float LB_Detection = tex2D(SamplerLumVR,float2(1,0.083)).z,LB_Masked = LB_Dir > DI_Y && LB_Dir < DI_X ? DM.y : 0.0125;
			
			if(LB_Detection)
				DM.y = LB_Masked;	
		#endif
	
		return float3(DM.y,PrepDepth( SDT == 2 || SD_Trigger == 2 ? TC_SP(texcoord).zw : texcoord)[1][1],HandleConvergence.z);
	}
	#define Adapt_Adjust 0.7 //[0 - 1]
	////////////////////////////////////////////////////Depth & Special Depth Triggers//////////////////////////////////////////////////////////////////
	void zBuffer(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Point_Out : SV_Target0 , out float Linear_Out : SV_Target1)
	{  //Temporal adaptation https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
		float  ExAd = (1-Adapt_Adjust)*1250, Lum = tex2Dlod(SamplerDMVR,float4(texcoord,0,12)).w, PastLum = tex2D(SamplerLumVR,float2(0,0.583)).z;
	
		float3 Set_Depth = DB_Comb( texcoord.xy ).xyz;
		
		if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2) 
			Set_Depth.y = PastLum + (Lum - PastLum) * (1.0 - exp(-frametime/ExAd));	
		if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
			Set_Depth.y = AltWeapon_Fade();
		if(   texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) 
			Set_Depth.y = Weapon_ZPD_Fade(Set_Depth.z);
		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
			Set_Depth.y = Motion_Blinders(texcoord);	
		
		Point_Out = Set_Depth.xy; 
		Linear_Out = Set_Depth.x;	
	}
	static const float Blur_Adjust = 3.0;
		
	void zBuffer_Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Blur_Out : SV_Target0)
	{   
		float2 StoredTC = texcoord;
			              texcoord.x *= 2; 
		float simple_Blur = tex2Dlod(SamplerzBufferVR_L,float4(texcoord,0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferVR_L,float4(texcoord + float2( pix.x * Blur_Adjust * 2, pix.y),0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferVR_L,float4(texcoord + float2( pix.x * Blur_Adjust   , pix.y),0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferVR_L,float4(texcoord + float2(-pix.x * Blur_Adjust   , pix.y),0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferVR_L,float4(texcoord + float2(-pix.x * Blur_Adjust * 2, pix.y),0, 0.0)).x;
		
		float Corners = tex2Dlod(SamplerzBufferVR_P,float4(StoredTC * float2( 2, 1) - float2( 1 , 0),0, 2)).x;
			  Corners = ddx(Corners) * ddy(Corners);
		//Fade Storage
		float2x4 Fade_Pass = Fade(StoredTC);	
		const int Num_of_Values = 6; //4 total array values that map to the textures width.
		float Storage_Array[Num_of_Values] = { Fade_Pass[0][0],
	                                		   Fade_Pass[0][1],
	                                		   Fade_Pass[0][2], 
	                                		   Fade_Pass[0][3],
											   Fade_Pass[1][3],
											   Fade_Pass[1][0] };
		//Set a avr size for the Number of lines needed in texture storage.
		float Grid = floor(texcoord.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);	
		  
		Blur_Out = float2(StoredTC.x < 0.5 ? min(1,simple_Blur * 0.2) : saturate(Corners > 0.001), Storage_Array[int(fmod(Grid,Num_of_Values))]);
	}		
	float4 GetDB(float2 texcoord)
	{
		float VMW = View_Mode == 1 ? View_Mode_Warping : clamp(View_Mode_Warping,0, View_Mode == 5 ? 2 : 1);
		float Depth_Blur = View_Mode_Warping > 0 ? min(tex2Dlod(SamplerzBufferVR_L, float4( texcoord, 0, clamp(VMW,0,5) ) ).x,tex2Dlod(SamplerzBufferVR_L, float4( texcoord, 0, 0) ).x) : tex2Dlod(SamplerzBufferVR_L, float4( texcoord, 0, 0) ).x;
	
		float3 DepthBuffer_LP = float3(Depth_Blur,tex2Dlod(SamplerzBufferVR_P, float4( texcoord, 0, 0) ).x, tex2Dlod(SamplerzBufferVR_P, float4(texcoord,0, 0) ).y );
		
		float Min_Blend = tex2Dlod(SamplerzBuffer_BlurVR, float4( texcoord * float2( 0.5 , 1), 0, 0) ).x;// min(tex2Dlod(SamplerzBufferVR_L, float4( texcoord, 0, 3.5) ).x,tex2Dlod(SamplerzBufferVR_L, float4( texcoord, 0, 2.5 ) ).x) ;
		if( Range_Blend > 0)
			   DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,  Min_Blend ,(smoothstep(0.5,1.0, Min_Blend) *  Min_Divergence().y) * saturate(Range_Blend));
			   
		if(View_Mode == 0 || View_Mode == 3)	
			DepthBuffer_LP.x = DepthBuffer_LP.y;
						
		float Mix_Past_Current_Corner_Mask = tex2Dlod(samplerMinMaxRGBLastFrame,float4(texcoord,0,0)).w + saturate(tex2Dlod(SamplerzBuffer_BlurVR, float4( texcoord * float2( 0.5 , 1) + float2(0.5,0), 0, 5 ) ).x * 100);	

			  if(De_Artifacting >= 0)
			  	Mix_Past_Current_Corner_Mask = 1;
			
		float Separation = lerp(1.0,5.0,ZPD_Separation.y); 	
		return float4(Separation * DepthBuffer_LP.xy, DepthBuffer_LP.z, Mix_Past_Current_Corner_Mask);
	}
	//Perf Level selection                             X    Y      Z      W              X    Y      Z      W
	static const float4 Performance_LvL[2] = { float4( 0.5, 0.5095, 0.679, 0.5 ), float4( 1.0, 1.019, 1.425, 1.0) };
	static const float  VRS_Array[5] = { 0.5, 0.5, 0.25, 0.125 , 0.0625 };
	//////////////////////////////////////////////////////////Parallax Generation///////////////////////////////////////////////////////////////////////
	float2 Parallax(float Diverge, float2 Coordinates) // Horizontal parallax offset & Hole filling effect
	{   
		float  MS = Diverge * pix.x; int Perf_LvL = fmod(Performance_Level,2);      
		float2 ParallaxCoord = Coordinates, CBxy = floor( float2(Coordinates.x * BUFFER_WIDTH, Coordinates.y * BUFFER_HEIGHT));
		float GetDepth = smoothstep(0,1, GetDB(Coordinates).z ), CB_Done = fmod(CBxy.x+CBxy.y,2),
				   Perf = Performance_LvL[Perf_LvL].x;
		//Would Use Switch....
		if( View_Mode == 2)
			Perf = Performance_LvL[Perf_LvL].z;
		if( View_Mode == 3)
			Perf = Performance_LvL[Perf_LvL].x;
		if( View_Mode == 4)
		{
			if( GetDepth >= 0.999 )
				Perf = CB_Done ? 0.5 : 1.000;
			else
				Perf = CB_Done ? 1.020: 1.040;
			
			Perf = lerp(Perf,1.425f,0.5);
		}
		if( View_Mode == 5)
		{
			if( GetDepth >= 0.999 )
				Perf = CB_Done ? 1.016: 1.017;
			else if( GetDepth >= 0.875)
				Perf = CB_Done ? 1.018: 1.019;
			else
				Perf = CB_Done ? 1.020: 1.021;
		}
		//Luma Based VRS
		float Auto_Adptive = Switch_VRS == 0 ? lerp(0.05,1.0,smoothstep(0.00000001f, 0.375, tex2D(SamplerzBufferVR_P,0).y ) ) : 1,
			  Luma_Adptive = smoothstep(0.0,saturate(VRS_Array[Switch_VRS] * Auto_Adptive), tex2Dlod(SamplerDMVR,float4(Coordinates,0,9)).w);
		if( Performance_Level > 1 )
			Perf *= saturate(Luma_Adptive * 0.5 + 0.5  );
		//ParallaxSteps Calculations
		float MinNum = 25, D = abs(Diverge), Cal_Steps = D * Perf, Steps = clamp( Cal_Steps, Perf_LvL ? MinNum : lerp( MinNum, min( MinNum, D), GetDepth >= 0.999 ), Performance_Level > 1 ? lerp(100,50,saturate(Vin_Pattern(Coordinates, float2(15.0,2.5)))) : 100 );//Foveated Rendering Point of attack 16-256 limit samples.
		// Offset per step progress & Limit
		float LayerDepth = rcp(Steps), TP = Compatibility_Power >= 0 ? lerp(0.025, 0.05,Compatibility_Power) : lerp(0.0225, 0.05,abs(Compatibility_Power) * saturate(Vin_Pattern(Coordinates, float2(15.0,3.0))));
			  D = Diverge < 0 ? -75 : 75;
	
		//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
		float deltaCoordinates = MS * LayerDepth, CurrentDepthMapValue = GetDB( ParallaxCoord).x, CurrentLayerDepth = 0.0f,
			  DB_Offset = D * TP * pix.x, VM_Switch = View_Mode == 1 ? 0.125 : 1;
			  
		[loop] //Steep parallax mapping
		while ( CurrentDepthMapValue > CurrentLayerDepth )
		{   
			// Shift coordinates horizontally in linear fasion
		    ParallaxCoord.x -= deltaCoordinates; 
		    // Get depth value at current coordinates
		    if ( De_Artifacting != 0 && GetDB(ParallaxCoord).w )
				CurrentDepthMapValue = min(GetDB( ParallaxCoord ).x, GetDB( ParallaxCoord - float2(MS * lerp(0,0.125,saturate(abs(De_Artifacting))),0)).x);
			else
				CurrentDepthMapValue = GetDB( ParallaxCoord ).x;
		    // Get depth of next layer
		    CurrentLayerDepth += LayerDepth;
		}
		
		if( View_Mode <= 1 )	
	   	ParallaxCoord.x += DB_Offset * VM_Switch;
	    
		float2 PrevParallaxCoord = float2( ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y), Depth_Adjusted = 1-saturate(float2(GetDepth * 5.0, GetDepth));
		//Anti-Weapon Hand Fighting
		float Weapon_Mask = tex2Dlod(SamplerDMVR,float4(Coordinates,0,0)).y, ZFighting_Mask = 1.0-(1.0-tex2Dlod(SamplerLumVR,float4(Coordinates,0,1.400)).w - Weapon_Mask);
			  ZFighting_Mask = ZFighting_Mask * (1.0-Weapon_Mask);
		float2 PCoord = float2(View_Mode <= 1 ? PrevParallaxCoord.x : ParallaxCoord.x, PrevParallaxCoord.y ) ;
			   PCoord.x -= 0.0025 * MS;
		float Get_DB = GetDB( PCoord ).x, 
			  Get_DB_ZDP = WP > 0 ? lerp(Get_DB, abs(Get_DB), ZFighting_Mask) : Get_DB;
		// Parallax Occlusion Mapping
		float beforeDepthValue = Get_DB_ZDP, afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
			  beforeDepthValue += LayerDepth - CurrentLayerDepth;
		// Depth Diffrence for Gap masking and depth scaling in Normal Mode.
		float DepthDiffrence = afterDepthValue - beforeDepthValue;//, DD_Map = abs(DepthDiffrence) > 0.064;//For AI infilling
		float weight = afterDepthValue / min(-0.0125,DepthDiffrence);
			  weight = lerp(weight,weight + (2.0 * Depth_Adjusted.y),0.5);
	
			ParallaxCoord.x = lerp( ParallaxCoord.x, PrevParallaxCoord.x, weight);
		//This is to limit artifacts.
		if( View_Mode > 0 )
			ParallaxCoord.x += DB_Offset;
		
		if( View_Mode <= 1 )
		{
			if(Diverge < 0)
				ParallaxCoord.x += DepthDiffrence * 2.5 * pix.x;
			else
				ParallaxCoord.x -= DepthDiffrence * 2.5 * pix.x;
		}
	
		return ParallaxCoord;
	}
	//////////////////////////////////////////////////////////////HUD Alterations///////////////////////////////////////////////////////////////////////
	#if HUD_MODE || HMT
	float3 HUD(float3 HUD, float2 texcoord )
	{
		float3 StoredHUD = HUD;
		float Mask_Tex, CutOFFCal = ((HUD_Adjust.x * 0.5)/DMA()) * 0.5, COC = step(PrepDepth(texcoord)[1][2],CutOFFCal); //HUD Cutoff Calculation
		//This code is for hud segregation.
		if (HUD_Adjust.x > 0)
			HUD = COC > 0 ? tex2D(BackBufferCLAMP,texcoord).rgb : HUD;
	
		#if UI_MASK
		    if (Mask_Cycle == true)
		        Mask_Tex = tex2Dlod(SamplerMaskB,float4(texcoord.xy,0,0)).a;
		    else
		        Mask_Tex = tex2Dlod(SamplerMaskA,float4(texcoord.xy,0,0)).a;
	
			float MACV = step(1.0-Mask_Tex,0.5); //Mask Adjustment Calculation Var
			//This code is for hud segregation.
			HUD = MACV > 0 ? tex2D(BackBufferCLAMP,texcoord).rgb : HUD;
		#endif
		return  texcoord.x < 0.001 || 1-texcoord.x < 0.001 ? StoredHUD : HUD;
	}
	#endif
	///////////////////////////////////////////////////////////Stereo Calculation///////////////////////////////////////////////////////////////////////
	float4 saturation(float4 C)
	{
	  float greyscale = dot(C.rgb, float3(0.2125, 0.7154, 0.0721));
	   return lerp(greyscale.xxxx, C, (Saturation + 1.0));
	}
	
	#if HelixVision
	void LR_Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 Double : SV_Target0)
	#else
	void LR_Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 Left : SV_Target0, out float4 Right : SV_Target1)//, out float StoreBB : SV_Target2)
	#endif
	{   float2 StoreTC = texcoord; //StoreBB = dot(tex2D(BackBufferCLAMP,texcoord).rgb,float3(0.2125, 0.7154, 0.0721));
		//Field of View
		float fov = FoV-(FoV*0.2), F = -fov + 1,HA = (F - 1)*(BUFFER_WIDTH*0.5)*pix.x;
		//Field of View Application
		float2 Z_A = float2(Theater_Mode == 2 ? 0.75 : 1.0,1.0); //Theater Mode
		if(!Theater_Mode)
		{
			Z_A = float2(1.0,0.5); //Full Screen Mode
			texcoord.x = (texcoord.x*F)-HA;
		}
		//Texture Zoom & Aspect Ratio//
		float X = Z_A.x;
		float Y = Z_A.y * Z_A.x * 2;
		float midW = (X - 1)*(BUFFER_WIDTH*0.5)*pix.x;
		float midH = (Y - 1)*(BUFFER_HEIGHT*0.5)*pix.y;
	
		texcoord = float2((texcoord.x*X)-midW,(texcoord.y*Y)-midH);
		//Store Texcoords for left and right eye
		float2 TCL = texcoord,TCR = texcoord;
		//IPD Right Adjustment
		TCL.x -= Interpupillary_Distance*0.5f;
		TCR.x += Interpupillary_Distance*0.5f;
	
		float D =  Min_Divergence().x;
	
		float FadeIO = Focus_Reduction_Type == 1 ? 1 : smoothstep(0,1,1-Fade_in_out(texcoord).x), FD = D, FD_Adjust = Focus_Reduction_Type == 2 ? 0.4375 : 0.1;
	
		if( Eye_Fade_Reduction_n_Power.x == 1)
			FD_Adjust = Focus_Reduction_Type == 2 ? 0.500 : 0.2;
		if( Eye_Fade_Reduction_n_Power.x == 2)
			FD_Adjust = Focus_Reduction_Type == 2 ? 0.625 : 0.3;
		if( Eye_Fade_Reduction_n_Power.x == 3)
			FD_Adjust = Focus_Reduction_Type == 2 ? 0.750 : 0.4;	
		if( Eye_Fade_Reduction_n_Power.x == 4)
			FD_Adjust = Focus_Reduction_Type == 2 ? 0.875 : 0.5;
			
		if(Focus_Reduction_Type == 1)
			FD_Adjust = 1.0;		
	
		if (FPSDFIO >= 1)
			FD = lerp(FD * FD_Adjust,FD,FadeIO);
	
		float2 DLR = float2(FD,FD);
		if( Eye_Fade_Selection == 1)
				DLR = float2(D,FD);
		else if( Eye_Fade_Selection == 2)
				DLR = float2(FD,D);
				
	//Left & Right Parallax for Stereo Vision
	#if HUD_MODE || HMT
		float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25.) * pix.x;
	#endif
	
	#if HelixVision
		float4 L = saturation( float4(MouseCursor( Parallax(-DLR.x, float2(TCL.x * 2,TCL.y)), position.xy).rgb,1.0) ),
			   R = saturation( float4(MouseCursor( Parallax( DLR.y, float2(TCR.x  * 2 - 1,TCR.y)), position.xy).rgb,1.0) );
		#if HUD_MODE || HMT
			L.rgb = HUD(L.rgb,float2((TCL.x * 2) - HUD_Adjustment,TCL.y));
			R.rgb = HUD(R.rgb,float2((TCR.x  * 2 - 1) + HUD_Adjustment,TCR.y));
		#endif
		Double = StoreTC.x < 0.5 ? L : R; //Stereoscopic 3D using Reprojection Left & Right
	#else
		Left =  saturation(float4(MouseCursor( Parallax(-DLR.x, TCL), position.xy).rgb,1.0) ) ; //Stereoscopic 3D using Reprojection Left
		Right = saturation(float4(MouseCursor( Parallax( DLR.y, TCR), position.xy).rgb,1.0) ) ;//Stereoscopic 3D using Reprojection Right
		#if HUD_MODE || HMT
			Left.rgb = HUD(Left.rgb,float2(TCL.x - HUD_Adjustment,TCL.y));
			Right.rgb = HUD(Right.rgb,float2(TCR.x + HUD_Adjustment,TCR.y));
		#endif
	#endif
	}
	///////////////////////////////////////////////////////////Barrel Distortion///////////////////////////////////////////////////////////////////////
	float4 Circle(float4 C, float2 TC)
	{
		if(Barrel_Distortion == 2)
			discard;
	
		float2 C_A = float2(1.0f,1.1375f), midHV = (C_A-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
	
		float2 uv = float2(TC.x,TC.y);
	
		uv = float2((TC.x*C_A.x)-midHV.x,(TC.y*C_A.y)-midHV.y);
	
		float borderA = 2.5; // 0.01
		float borderB = 0.003;//Vignette*0.1; // 0.01
		float circle_radius = 0.55; // 0.5
		float4 circle_color = 0; // vec4(1.0, 1.0, 1.0, 1.0)
		float2 circle_center = 0.5; // vec2(0.5, 0.5)
		// Offset uv with the center of the circle.
		uv -= circle_center;
	
		float dist =  sqrt(dot(uv, uv));
	
		float t = 1.0 + smoothstep(circle_radius, circle_radius+borderA, dist)
					  - smoothstep(circle_radius-borderB, circle_radius, dist);
	
		return lerp(circle_color, C,t);
	}
	
	float Vignette(float2 TC)
	{   float CalculateV = lerp(1.0,0.25,smoothstep(0,1, Motion_Blinders(TC) ));
		float2 IOVig = float2(CalculateV * 0.75,CalculateV),center = float2(0.5,0.5); // Position for the innter and Outer vignette + Magic number scaling
		float distance = length(center-TC),Out = 0;
		// Generate the Vignette with Clamp which go from outer Viggnet ring to inner vignette ring with smooth steps
		if(Blinders > 0)
			Out = 1-saturate((IOVig.x-distance) / (IOVig.y-IOVig.x));
		return Out;
	}
	//SamplerDouble
	float3 L(float2 texcoord)
	{
		#if HelixVision
			float3 Left;
		#else
			float3 Left = tex2D(SamplerLeft,texcoord).rgb;
		#endif
		return lerp(Left,0,Vignette(texcoord));
	}
	
	float3 R(float2 texcoord)
	{
		#if HelixVision
			float3 Right;
		#else
			float3 Right = tex2D(SamplerRight,texcoord).rgb;
		#endif
		return lerp(Right,0,Vignette(texcoord));
	}
	
	float2 BD(float2 p, float k1, float k2) //Polynomial Lens + Radial lens undistortion filtering Left & Right
	{
		if(!Barrel_Distortion)
			discard;
		// Normalize the u,v coordinates in the range [-1;+1]
		p = (2.0f * p - 1.0f) / 1.0f;
		// Calculate Zoom
		if(!Theater_Mode)
			p *= 0.83;
		else
			p *= 0.8;
		// Calculate l2 norm
		float r2 = p.x*p.x + p.y*p.y;
		float r4 = pow(r2,2);
		// Forward transform
		float x2 = p.x * (1.0 + k1 * r2 + k2 * r4);
		float y2 = p.y * (1.0 + k1 * r2 + k2 * r4);
		// De-normalize to the original range
		p.x = (x2 + 1.0) * 1.0 / 2.0;
		p.y = (y2 + 1.0) * 1.0 / 2.0;
	
		if(!Theater_Mode)
		{
		//Blinders Code Fast
		float C_A1 = 0.45f, C_A2 = C_A1 * 0.5f, C_B1 = 0.375f, C_B2 = C_B1 * 0.5f, C_C1 = 0.9375f, C_C2 = C_C1 * 0.5f;//offsets
		if(length(p.xy*float2(C_A1,1.0f)-float2(C_A2,0.5f)) > 0.5f)
			p = 1000;//offscreen
		else if(length(p.xy*float2(1.0f,C_B1)-float2(0.5f,C_B2)) > 0.5f)
			p = 1000;//offscreen
		else if(length(p.xy*float2(C_C1,1.0f)-float2(C_C2,0.5f)) > 0.625f)
			p = 1000;//offscreen
		}
	
	return p;
	}
	// For Super3D a new Stereo3D output Left and Right Image compression
	float3 YCbCrLeft(float2 texcoord)
	{
		return RGBtoYCbCr(L(texcoord));
	}
	
	float3 YCbCrRight(float2 texcoord)
	{
		return RGBtoYCbCr(R(texcoord));
	}
	///////////////////////////////////////////////////////////Stereo Distortion Out///////////////////////////////////////////////////////////////////////
	float3 PS_calcLR(float2 texcoord)
	{
		float2 gridxy = floor(float2(texcoord.x * BUFFER_WIDTH, texcoord.y * BUFFER_HEIGHT)), TCL = float2(texcoord.x * 2,texcoord.y), TCR = float2(texcoord.x * 2 - 1,texcoord.y), uv_redL, uv_greenL, uv_blueL, uv_redR, uv_greenR, uv_blueR;
		float4 color, Left, Right, color_redL, color_greenL, color_blueL, color_redR, color_greenR, color_blueR;
		float K1_Red = Polynomial_Colors_K1.x, K1_Green = Polynomial_Colors_K1.y, K1_Blue = Polynomial_Colors_K1.z;
		float K2_Red = Polynomial_Colors_K2.x, K2_Green = Polynomial_Colors_K2.y, K2_Blue = Polynomial_Colors_K2.z;
		float Y_Left, Y_Right, CbCr_Left, CbCr_Right, CbCr;
	
		if(Barrel_Distortion == 0 || SuperDepth == 1)
		{   if(!SuperDepth)
			{   //Had to change float4 to float3.... Error only shows under linux.
				if(HelixVision)
				{
					Left.rgb = tex2D(BackBufferCLAMP,texcoord).rgb;
					//Right.rgb = R(float2(texcoord.x - 1,texcoord.y)).rgb;
				}
				else
				{
					Left.rgb = L(TCL).rgb;
					Right.rgb = R(TCR).rgb;
				}
			}
			else // For Super3D a new Stereo3D output.
			{
				Y_Left = YCbCrLeft(texcoord).x;
				Y_Right = YCbCrRight(texcoord).x;
	
				CbCr_Left = texcoord.x < 0.5 ? YCbCrLeft(texcoord * 2).y : YCbCrLeft(texcoord * 2 - float2(1,0)).z;
				CbCr_Right = texcoord.x < 0.5 ? YCbCrRight(texcoord * 2 - float2(0,1)).y : YCbCrRight(texcoord * 2 - 1 ).z;
	
				CbCr = texcoord.y < 0.5 ? CbCr_Left : CbCr_Right;
			}
		}
		else
		{
			uv_redL = BD(TCL.xy,K1_Red,K2_Red);
			uv_greenL = BD(TCL.xy,K1_Green,K2_Green);
			uv_blueL = BD(TCL.xy,K1_Blue,K2_Blue);
	
			color_redL = L(uv_redL).r;
			color_greenL = L(uv_greenL).g;
			color_blueL = L(uv_blueL).b;
	
			Left = float4(color_redL.x, color_greenL.y, color_blueL.z, 1.0);
	
			uv_redR = BD(TCR.xy,K1_Red,K2_Red);
			uv_greenR = BD(TCR.xy,K1_Green,K2_Green);
			uv_blueR = BD(TCR.xy,K1_Blue,K2_Blue);
	
			color_redR = R(uv_redR).r;
			color_greenR = R(uv_greenR).g;
			color_blueR = R(uv_blueR).b;
	
			Right = float4(color_redR.x, color_greenR.y, color_blueR.z, 1.0);
		}
	
		if(!overlay_open || NCAOC)
		{
			if(!SuperDepth)
			{
				if(Barrel_Distortion == 1) // Side by Side for VR
					color = texcoord.x < 0.5 ? Circle(Left,float2(texcoord.x*2,texcoord.y)) : Circle(Right,float2(texcoord.x*2-1,texcoord.y));
				else//Helix Vison Mode
					color =  HelixVision ? Left : texcoord.x < 0.5 ? Left : Right;
			}
			else
			{	// Super3D Mode
				color.rgb = float3(Y_Left,Y_Right,CbCr);
			}
		}
		else
		{
				color.rgb = HelixVision ? Left.rgb : fmod(gridxy.x+gridxy.y,2) ? R(texcoord) : L(texcoord);
		}
	
		if (BD_Options == 2 || Alinement_View)
			color.rgb = dot(0.5-tex2D(BackBuffer,texcoord).rgb,0.333) / float3(1,tex2D(SamplerzBufferVR_L,texcoord).x,1);
	
		return color.rgb;
	}
	/////////////////////////////////////////////////////////Average Luminance Textures/////////////////////////////////////////////////////////////////
	float Past_BufferVR(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		return tex2D(SamplerDMVR,texcoord).w;
	}
	
	void Averager(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 AL : SV_Target0, out float4 Other : SV_Target1)
	{	
		float Average_ZPD = PrepDepth( texcoord )[0][0];
		// SamplerDMVR 0 is Weapon State storage and SamplerDMVR 1 is Boundy State storage	
		const int Num_of_Values = 6; //6 total array values that map to the textures width.
		float Storage__Array_A[Num_of_Values] = { tex2D(SamplerDMVR,0).x,                //0.083
	                                			  tex2D(SamplerDMVR,1).x,                //0.250
	                               			   tex2D(SamplerDMVR,int2(0,1)).x,        //0.416
	                                			  tex2D(SamplerzBufferVR_P,0).y,         //0.583
												  tex2D(SamplerzBufferVR_P,1).y,         //0.750
												  tex2D(SamplerzBufferVR_P,int2(0,1)).y};//0.916
		float Storage__Array_B[Num_of_Values] = { LBDetection(),                         //0.083
	                                			  tex2D(SamplerDMVR,int2(1,0)).y,        //0.250
	                               			   tex2D(SamplerDMVR,int2(1,0)).x,        //0.416
	                                			  tex2D(SamplerDMVR,1).y,                //0.583
												  tex2D(SamplerDMVR,0).y,                //0.750
												  tex2D(SamplerzBufferVR_P,int2(1,0)).y};//0.916
		//Set a avr size for the Number of lines needed in texture storage.
		float Grid = floor(texcoord.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);	
		//Motion_Detection
		AL = float4(length(tex2D(SamplerDMVR,texcoord).w - tex2D(SamplerPBBVR,texcoord).x),Average_ZPD,texcoord.x < 0.5 ? Storage__Array_A[int(fmod(Grid,Num_of_Values))] : Storage__Array_B[int(fmod(Grid,Num_of_Values))] ,tex2Dlod(SamplerDMVR,float4(texcoord,0,0)).y);
		Other = float4(tex2D(samplerMinMaxRGB, texcoord).rgb,saturate(tex2Dlod(SamplerzBuffer_BlurVR, float4( texcoord * float2( 0.5 , 1) + float2(0.5,0), 0, 5 ) ).x * 100));
	}
	////////////////////////////////////////////////////////////////////Logo////////////////////////////////////////////////////////////////////////////
	#define _f float // Text rendering code copied/pasted from https://www.shadertoy.com/view/4dtGD2 by Hamneggs
	static const _f CH_A    = _f(0x69f99), CH_B    = _f(0x79797), CH_C    = _f(0xe111e),
					CH_D    = _f(0x79997), CH_E    = _f(0xf171f), CH_F    = _f(0xf1711),
					CH_G    = _f(0xe1d96), CH_H    = _f(0x99f99), CH_I    = _f(0xf444f),
					CH_J    = _f(0x88996), CH_K    = _f(0x95359), CH_L    = _f(0x1111f),
					CH_M    = _f(0x9fb99), CH_N    = _f(0x9bd99), CH_O    = _f(0x69996),
					CH_P    = _f(0x79711), CH_Q    = _f(0x69b5a), CH_R    = _f(0x79759),
					CH_S    = _f(0xe1687), CH_T    = _f(0xf4444), CH_U    = _f(0x99996),
					CH_V    = _f(0x999a4), CH_W    = _f(0x999f9), CH_X    = _f(0x99699),
					CH_Y    = _f(0x99e8e), CH_Z    = _f(0xf843f), CH_0    = _f(0x6bd96),
					CH_1    = _f(0x46444), CH_2    = _f(0x6942f), CH_3    = _f(0x69496),
					CH_4    = _f(0x99f88), CH_5    = _f(0xf1687), CH_6    = _f(0x61796),
					CH_7    = _f(0xf8421), CH_8    = _f(0x69696), CH_9    = _f(0x69e84),
					CH_APST = _f(0x66400), CH_PI   = _f(0x0faa9), CH_UNDS = _f(0x0000f),
					CH_HYPH = _f(0x00600), CH_TILD = _f(0x0a500), CH_PLUS = _f(0x02720),
					CH_EQUL = _f(0x0f0f0), CH_SLSH = _f(0x08421), CH_EXCL = _f(0x33303),
					CH_QUES = _f(0x69404), CH_COMM = _f(0x00032), CH_FSTP = _f(0x00002),
					CH_QUOT = _f(0x55000), CH_BLNK = _f(0x00000), CH_COLN = _f(0x00202),
					CH_LPAR = _f(0x42224), CH_RPAR = _f(0x24442);

	//returns the status of a bit in a bitmap. This is done value-wise, so the exact representation of the float doesn't really matter.
	float getBit( float map, float index )
	{   // Ooh -index takes out that divide :)
	    return fmod( floor( map * exp2(-index) ), 2.0 );
	}
	
	float drawChar( float Char,inout float2 posXY, float2 charsize, float2 TC, float shift)
	{	
		posXY.x += shift;  
		// Subtract our position from the current TC so that we can know if we're inside the bounding box or not.
	    TC -= posXY;
	    // Divide the screen space by the size, so our bounding box is 1x1.
	    TC /= charsize;
	    // Create a place to store the result & Branchless bounding box check.
	    float res = step(0.0,min(TC.x,TC.y)) - step(1.0,max(TC.x,TC.y));
	    // Go ahead and multiply the TC by the bitmap size so we can work in bitmap space coordinates.
	    TC *= float2(4,5);//Map Size
	    // Get the appropriate bit and return it.
	    res*=getBit( Char, 4.0*floor(TC.y) + floor(TC.x) );
	    return saturate(res);
	}
	
	#if (RHW || NCW || NPW || NFM || PEW || DSW || OSW || DAA || NDW || WPW || FOV || EDW)
		#define Text_Timer 30000
	#else
		#define Text_Timer 25000
	#endif
	
	float3 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		float Menu_Open = overlay_open ? 1 : 0;
		float3 Color = PS_calcLR(texcoord).rgb, SBS_3D = float3(1,0,0), Super3D = float3(0,0,1);
		//RGBW / R = SBS-3D / G = ?????? / B = Super3D / W = ??????
		float3 Format = !SuperDepth ? SBS_3D : Super3D;
		//Ok so I have to invert the pattern because for some reason the unity app I made can only read Integers values from ReShade.....
		float2 ScreenPos = float2(1-texcoord.x,1-texcoord.y) * Res;//This Bugg was waisted a entire day. But, this is the workaround for that.
		float Debug_Y = 1.0;// Set this higher so you can see it when Debugging
		if(all(abs(float2(1.0,BUFFER_HEIGHT)-ScreenPos.xy) < float2(1.0,Debug_Y)))
			Color = Menu_Open ? Format : 0;
		if(all(abs(float2(3.0,BUFFER_HEIGHT)-ScreenPos.xy) < float2(1.0,Debug_Y)))
			Color = Menu_Open ? 0 : Format;
		if(all(abs(float2(5.0,BUFFER_HEIGHT)-ScreenPos.xy) < float2(1.0,Debug_Y)))
			Color = Menu_Open ? Format : 0;
		
		//Color = tex2D(SamplerLumVR,texcoord).z ;
		
		float InfoTexture = tex2D(SamplerInfo,texcoord).x;
		
		float2 TCL = texcoord, TCR = texcoord, TC;
		
		if(!overlay_open || NCAOC)
		{
			if(!SuperDepth &! HelixVision )
			{
			TCL.x = TCL.x*2;
			TCR.x = TCR.x*2-1;
			TC = texcoord.x < 0.5;
			}
		}

		InfoTexture = TC ? tex2D(SamplerInfo,TCL).x : tex2D(SamplerInfo,TCR).x;
		
		float3 Webinfo = SuperDepth  ? Menu_Open ? InfoTexture : float3(InfoTexture.xx,0) : InfoTexture;

		return  timer <= Text_Timer || Text_Info ? Color + Webinfo : Color;
	}
	
	///////////////////////////////////////////////////////////////////SmartSharp Jr.//////////////////////////////////////////////////////////////////////
	#define SIGMA 0.25
	#define MSIZE 3
	
	float normpdf3(in float3 v, in float sigma)
	{
		return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
	}
	
	float LI(float3 RGB)
	{
		return dot(RGB,float3(0.2126, 0.7152, 0.0722));
	}
	
	float3 SmartSharp(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{   float Sharp_This = overlay_open ? 0 : Sharpen_Power,mx, mn;
		float2 tex_offset = pix; // Gets texel offset
		float3 c = tex2D(BackBuffer, texcoord).rgb;
		if(Sharp_This > 0)
		{
			//Bilateral Filter//                                                Q1         Q2       Q3        Q4
		const int kSize = MSIZE * 0.5; // Default M-size is Quality 2 so [MSIZE 3] [MSIZE 5] [MSIZE 7] [MSIZE 9] / 2.
	
		float3 final_color, cc;
		float2 RPC_WS = pix * 1.5;
		float Z, factor;
	
		[loop]
		for (int i=-kSize; i <= kSize; ++i)
		{
			for (int j=-kSize; j <= kSize; ++j)
			{
				cc = tex2Dlod(BackBuffer, float4(texcoord.xy + float2(i,j) * RPC_WS * rcp(kSize * 2.0f),0,0)).rgb;
				factor = normpdf3(cc-c, SIGMA);
				Z += factor;
				final_color += factor * cc;
			}
		}
	
		final_color = saturate(final_color/Z);
	
		mn = min( min( LI(c), LI(final_color)), LI(cc));
		mx = max( max( LI(c), LI(final_color)), LI(cc));
	
	   // Smooth minimum distance to signal limit divided by smooth max.
	    float rcpM = rcp(mx), CAS_Mask;// = saturate(min(mn, 1.0 - mx) * rcpM);
	
		// Shaping amount of sharpening masked
		CAS_Mask = saturate(min(mn, 2.0 - mx) * rcpM);
	
		float3 Sharp_Out = c + (c - final_color) * Sharp_This;
		//Consideration for Super3D mode
		c = SuperDepth ? lerp(c,float3(Sharp_Out.rg,c.b),CAS_Mask) : lerp(c,Sharp_Out,CAS_Mask);
		}
	
		return c;
	}
	
	float3 InfoOut(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{   float3 Color;
		float2 TC = float2(texcoord.x,1-texcoord.y);
		float BT = smoothstep(0,1,sin(timer*(3.75/1000))), Size = 1.1, DisableDRS, Depth3D, Read_Help, Emu, SetFoV, PostEffects, NoPro, NotCom, ModFix, Needs, AspectRaito, Network, OW_State, SetAA, SetWP, DGDX, DXVK;
		//Text Information
		float2 charSize = float2(.00875, .0125) * Size;// Set a general character size...
		// Starting position.
		float2 charPos = float2( 0.009, 0.9725);
		float2 Shift_Adjust = float2( 0.01, 0.009) * Size;
		//Check Depth/Add-on Options: Copy Depth Clear/Frame
		#if DSW
			Needs += drawChar( CH_C, charPos.xy, charSize, TC, 0 );
			Needs += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_K, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_UNDS, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );	
			Needs += drawChar( CH_COLN, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_Y, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );  	
			Needs += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_F, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			Needs += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x );
			Needs += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		#if ARW 
			charPos = float2( 0.009, 0.955);
			AspectRaito += drawChar( CH_C, charPos.xy, charSize, TC, 0 );
			AspectRaito += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_K, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
			AspectRaito += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );			
			AspectRaito += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_UNDS, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			AspectRaito += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Emulator Detected
		#if (EDW)
			charPos = float2( 0.009, 0.9375);
			Emu += drawChar( CH_E, charPos.xy, charSize, TC, 0 );
			Emu += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_U, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			Emu += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Disable CA/MB/Dof/Grain		
		#if PEW
			charPos = float2( 0.009, 0.920);
			PostEffects += drawChar( CH_D, charPos.xy, charSize, TC, 0 );
			PostEffects += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_B, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_B, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_F, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_G, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			PostEffects += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Check TAA/MSAA/SS/DLSS/FSR/XESS		
		#if DAA
			charPos = float2( 0.009, 0.9025);
			SetAA += drawChar( CH_C, charPos.xy, charSize, TC, 0 ); 
			SetAA += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_K, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetAA += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetAA += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetAA += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetAA += drawChar( CH_F, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetAA += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_SLSH, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetAA += drawChar( CH_X, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetAA += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetAA += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Disable Dynamic Resolution Scaling		
		#if DRS
			charPos = float2( 0.009, 0.885);
			DisableDRS += drawChar( CH_D, charPos.xy, charSize, TC, 0 );
			DisableDRS += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_B, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_Y, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_U, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
			DisableDRS += drawChar( CH_G, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Set Weapon		
		#if WPW
			charPos = float2( 0.009, 0.8675);
			SetWP += drawChar( CH_S, charPos.xy, charSize, TC, 0 ); 
			SetWP += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_W, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x ); 
			SetWP += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Net Play		
		#if NDW
			charPos = float2( 0.009, 0.850);
			Network += drawChar( CH_N, charPos.xy, charSize, TC, 0 );
			Network += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			Network += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			Network += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			Network += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x );
			Network += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			Network += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			Network += drawChar( CH_Y, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Set FoV		
		#if FOV
			charPos = float2( 0.009, 0.8325);
			SetFoV += drawChar( CH_S, charPos.xy, charSize, TC, 0 );
			SetFoV += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetFoV += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetFoV += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetFoV += drawChar( CH_F, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetFoV += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			SetFoV += drawChar( CH_V, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Read Help		
		#if RHW
			charPos = float2( 0.894, 0.9725);
			Read_Help += drawChar( CH_R, charPos.xy, charSize, TC, 0 );
			Read_Help += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			Read_Help += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			Read_Help += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			Read_Help += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			Read_Help += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x );
			Read_Help += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			Read_Help += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			Read_Help += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Text Warnings
		charPos = float2( 0.009, 0.018);
		//No Profile
		#if NPW
			NoPro += drawChar( CH_N, charPos.xy, charSize, TC, 0 );
			NoPro += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_F, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			NoPro += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Incompatible		
		#if NCW
			NotCom += drawChar( CH_I, charPos.xy, charSize, TC, 0 ); 
			NotCom += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_P, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_B, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_L, charPos.xy, charSize, TC, Shift_Adjust.x );
			NotCom += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Needs Mod		
		#if NFM
			ModFix += drawChar( CH_N, charPos.xy, charSize, TC, 0 );
			ModFix += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			ModFix += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			ModFix += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			ModFix += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			ModFix += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			ModFix += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x );
			ModFix += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			ModFix += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.y );
		#endif
		//Need DXVK
		#if NVK && !ISVK
			DXVK += drawChar( CH_N, charPos.xy, charSize, TC, 0 );
			DXVK += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_X, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_V, charPos.xy, charSize, TC, Shift_Adjust.x );
			DXVK += drawChar( CH_K, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Use DGVOODOO2
		#if NDG && !ISDX
			DGDX += drawChar( CH_N, charPos.xy, charSize, TC, 0 ); 
			DGDX += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_G, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_V, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_D, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_O, charPos.xy, charSize, TC, Shift_Adjust.x );
			DGDX += drawChar( CH_2, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//Overwatch.fxh Missing
		#if OSW
			OW_State += drawChar( CH_O, charPos.xy, charSize, TC, 0 );
			OW_State += drawChar( CH_V, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_E, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_R, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_W, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_A, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_T, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_C, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_FSTP, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_F, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_X, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_H, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_BLNK, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_M, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_S, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_I, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_N, charPos.xy, charSize, TC, Shift_Adjust.x );
			OW_State += drawChar( CH_G, charPos.xy, charSize, TC, Shift_Adjust.x );
		#endif
		//New Size
		float D3D_Size_A = 1.375,D3D_Size_B = 0.75;
		float2 charSize_A = float2(.00875, .0125) * D3D_Size_A, charSize_B = float2(.00875, .0125) * D3D_Size_B;
		//New Start Pos
		charPos = float2( 0.862, 0.018);
		Shift_Adjust = float2( 0.01, 0.008) * D3D_Size_A;
		//Depth3D.Info Logo/Website
		Depth3D += drawChar( CH_D, charPos.xy, charSize_A, TC, 0);
		Depth3D += drawChar( CH_E, charPos.xy, charSize_A, TC, Shift_Adjust.x ); 
		Depth3D += drawChar( CH_P, charPos.xy, charSize_A, TC, Shift_Adjust.x ); 
		Depth3D += drawChar( CH_T, charPos.xy, charSize_A, TC, Shift_Adjust.x ); 
		Depth3D += drawChar( CH_H, charPos.xy, charSize_A, TC, Shift_Adjust.x ); 
		Depth3D += drawChar( CH_3, charPos.xy, charSize_A, TC, Shift_Adjust.x ); 
		Depth3D += drawChar( CH_D, charPos.xy, charSize_A, TC, Shift_Adjust.y ); 
		Depth3D += drawChar( CH_FSTP, charPos.xy, charSize_A, TC, Shift_Adjust.y );
		charPos = float2( 0.960, 0.018);
		Shift_Adjust = float2( 0.01, 0.008) * D3D_Size_B;
		Depth3D += drawChar( CH_I, charPos.xy, charSize_B, TC, 0); 
		Depth3D += drawChar( CH_N, charPos.xy, charSize_B, TC, Shift_Adjust.x ); 
		Depth3D += drawChar( CH_F, charPos.xy, charSize_B, TC, Shift_Adjust.x );
		Depth3D += drawChar( CH_O, charPos.xy, charSize_B, TC, Shift_Adjust.x );

		//Website
		return Depth3D+Read_Help+PostEffects+NoPro+NotCom+Network+ModFix+Needs+OW_State+SetAA+SetWP+SetFoV+Emu+DGDX+DXVK+AspectRaito+DisableDRS ? (1-texcoord.y*50.0+48.85)*texcoord.y-0.500: 0;
	}	
	///////////////////////////////////////////////////////////////////ReShade.fxh//////////////////////////////////////////////////////////////////////
	void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
	{// Vertex shader generating a triangle covering the entire screen
		texcoord.x = (id == 2) ? 2.0 : 0.0;
		texcoord.y = (id == 1) ? 2.0 : 0.0;
		position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
	}
	//*Rendering passes*//	
	technique Information
	< ui_label = "Information";
	//toggle = Text_Info_Key;
	 hidden = true; 
	 enabled = true;
	 timeout = 1;
	 ui_tooltip = "Help Technique."; >
	{
			pass Help
		{
			VertexShader = PostProcessVS;
			PixelShader = InfoOut;
			RenderTarget = Info_Tex;
		}
	}
	technique SuperDepth3D_VR
	< ui_tooltip = "Suggestion : Please enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
				   "             Do this once you set your 3D settings of course."; >
	{
		#if D_Frame || DFW
			pass Delay_Frame
		{
			VertexShader = PostProcessVS;
			PixelShader = DelayFrame;
			RenderTarget = texDF;
		}
			pass Current_Frame
		{
			VertexShader = PostProcessVS;
			PixelShader = CurrentFrame;
			RenderTarget = texCF;
		}
		#endif
			pass DepthBuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget0 = texDMVR;
		}
			pass zbufferVR
		{
			VertexShader = PostProcessVS;
			PixelShader = zBuffer;
			RenderTarget0 = texzBufferVR_P;
			RenderTarget1 = texzBufferVR_L;
		}
			pass Blur_DepthBuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = zBuffer_Blur;
			RenderTarget = texzBufferBlurVR;
		}
			pass Color_Correction
		{
			VertexShader = PostProcessVS;
			PixelShader = MinMaxRGB;
			RenderTarget = texMinMaxRGB;
		}
			pass StereoBuffers
		{
			VertexShader = PostProcessVS;
			PixelShader = LR_Out;
			#if HelixVision
			RenderTarget0 = DoubleTex;//Can run into DX9 size Limitations
			#else
			RenderTarget0 = LeftTex;
			RenderTarget1 = RightTex;
			#endif
		}
			pass StereoOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
		#if !HelixVision //Removed because HelixVision_Mode Has Built in sharpening.
			pass USMOut
		{
			VertexShader = PostProcessVS;
			PixelShader = SmartSharp;
		}
		#endif
			pass AverageLuminance
		{
			VertexShader = PostProcessVS;
			PixelShader = Averager;
			RenderTarget0 = texLumVR;
			RenderTarget1 = texMinMaxRGBLastFrame;
		}
			pass PastBBVR
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BufferVR;
			RenderTarget = texPBVR;
		}
	}
}