	////----------------//
	///**SuperDepth3D**///
	//----------------////
	#define SD3D "SuperDepth3D v3.9.9\n"
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//* Depth Map Based 3D post-process shader
	//* For Reshade 3.0+
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
	//* Written by Jose Negrete AKA BlueSkyDefender <UntouchableBlueSky@gmail.com>, October 2022
	//*
	//* Please feel free to contact me if you want to use this in your project.
	//* https://github.com/BlueSkyDefender/Depth3D
	//* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader
	//* https://discord.gg/Q2n97Uj
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

namespace SuperDepth3D
{
	#define D_ViewMode 1
	#if exists "Overwatch.fxh"                                           //Overwatch Interceptor//
		#include "Overwatch.fxh"
		#define OSW 0
	#else// DA_X = [ZPD] DA_Y = [Depth Adjust] DA_Z = [Offset] DA_W = [Depth Linearization]
		static const float DA_X = 0.025, DA_Y = 7.5, DA_Z = 0.0, DA_W = 0.0;
		// DC_X = [Depth Flip] DC_Y = [De-Artifact Scale] DC_Z = [Auto Depth] DC_W = [Weapon Hand]
		static const float DB_X = 0, DB_Y = 0, DB_Z = 0.1, DB_W = 0.0;
		// DC_X = [Barrel Distortion K1] DC_Y = [Barrel Distortion K2] DC_Z = [Barrel Distortion K3] DC_W = [Barrel Distortion Zoom]
		static const float DC_X = 0, DC_Y = 0, DC_Z = 0, DC_W = 0;
		// DD_X = [Horizontal Size] DD_Y = [Vertical Size] DD_Z = [Horizontal Position] DD_W = [Vertical Position]
		static const float DD_X = 1, DD_Y = 1, DD_Z = 0.0, DD_W = 0.0;
		// DE_X = [ZPD Boundary Type] DE_Y = [ZPD Boundary Scaling] DE_Z = [ZPD Boundary Fade Time] DE_W = [Weapon Near Depth Max]
		static const float DE_X = 0, DE_Y = 0.5, DE_Z = 0.25, DE_W = 0.0;
		// DF_X = [Weapon ZPD Boundary] DF_Y = [Separation] DF_Z = [ZPD Balance] DF_W = [Weapon Edge & Weapon Scale]
		static const float DF_X = 0.0, DF_Y = 0.0, DF_Z = 0.15, DF_W = 0.0;
		// DG_X = [Special Depth X] DG_Y = [Special Depth Y] DG_Z = [Weapon Near Depth Min] DG_W = [Check Depth Limit]
		static const float DG_X = 0.0, DG_Y = 0.0, DG_Z = 0.0, DG_W = 0.0;
		// DH_X = [LBC Size Offset X] DH_Y = [LBC Size Offset Y] DH_Z = [LBC Pos Offset X] DH_W = [LBC Pos Offset X]
		static const float DH_X = 1.0, DH_Y = 1.0, DH_Z = 0.0, DH_W = 0.0;
		// DI_X = [LBM Offset X] DI_Y = [LBM Offset Y] DI_Z = [Weapon Near Depth Trim] DI_W = [OIF Check Depth Limit]
		static const float DI_X = 0.0, DI_Y = 0.0, DI_Z = 0.25, DI_W = 0.5;
		// DJ_X = [Range Smoothing] DJ_Y = [Menu Detection Type] DJ_Z = [Match Threshold] DJ_W = [Check Depth Limit Weapon]
		static const float DJ_X = 0, DJ_Y = 0.0, DJ_Z = 0.0, DJ_W = -0.100;
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
		// DU_X = [Position I & I] DU_Y = [Position I & J] DU_Z = [Position J & J] DU_W = [IJ Menu Tresh]	
		static const float DU_X = 0.0, DU_Y = 0.0, DU_Z = 0.0, DU_W = 1000.0;
		// DV_X = [Position K & K] DV_Y = [Position K & L] DV_Z = [Position L & L] DU_W = [KL Menu Tresh]	
		static const float DV_X = 0.0, DV_Y = 0.0, DV_Z = 0.0, DV_W = 1000.0;
		// DX_X = [Position M & M] DX_Y = [Position M & N] DX_Z = [Position N & N] DX_W = [MN Menu Tresh]	
		static const float DX_X = 0.0, DX_Y = 0.0, DX_Z = 0.0, DX_W = 1000.0;
		// DY_X = [Position O & O] DY_Y = [Position O & P] DY_Z = [Position P & P] DY_W = [OP Menu Tresh]	
		static const float DY_X = 0.0, DY_Y = 0.0, DY_Z = 0.0, DY_W = 1000.0;
		// DW_X = [SMD1 Position A & B] DW_Y = [SMD1 Position C] DW_Z = [SMD1 ABCW Menu Tresholds] DW_W = [SMD2 ABCW Menu Tresholds]
		static const float DW_X = 0.0, DW_Y = 0.0, DW_Z = 1000.0, DW_W = 1000.0;
		// DS_X = [Weapon NearDepth Min OIL] DS_Y = [Depth Range Boost] DS_Z = [View Mode State] DS_W = [Check Depth Limit Weapon Secondary]
		static const float DS_X = 0.0, DS_Y = 0.0, DS_Z = D_ViewMode, DS_W = 1.0;
		// DT_X = [SMD2 Position A & B] DT_Y = [SMD2 Position C] DT_Z = [Weapon Hand Mask Z] DT_W = [Rescale Weapon Hand Near]
		static const float DT_X = 0.0, DT_Y = 0.0, DT_Z = 0.0, DT_W = 0.0;
		// DZ_X = [Null X] DZ_Y = [Null Y] DZ_Z = [Null Z] DZ_W = [Null W]
		static const float DZ_X = 0.0, DZ_Y = 0.0, DZ_Z = 0.0, DZ_W = 0.0;
		// WSM = [Weapon Setting Mode]
		#define OW_WP "WP Off\0Custom WP\0"
		static const int WSM = 0;
		//Triggers
		static const float WFB = 0, WND = 0, WRP = 0, SMD = 0, WHM = 0, SDU = 0, ABE = 2, LBE = 0, DRS = 0, MAC = 0, ARW = 0, OIL = 0, MMS = 0, NVK = 0, NDG = 0, FTM = 0, SPO = 0, MMD = 0, SMP = 0, LBR = 0, HQT = 0, AFD = 0, MDD = 0, FPS = 1, SMS = 1, OIF = 0, NCW = 0, RHW = 0, NPW = 0, SPF = 0, BDF = 0, HMT = 0, HMC = 0, DFW = 0, NFM = 0, DSW = 0, BMT = 0, LBC = 0, LBS = 0, LBM = 0, DAA = 0, NDW = 0, PEW = 0, WPW = 0, FOV = 0, EDW = 0, SDT = 0;
		//Overwatch.fxh State
		#define OSW 1
	#endif
	//USER EDITABLE PREPROCESSOR FUNCTIONS START//

	// This shift the detectors for ZPD Boundary Detection. 
	#define Shift_Detectors_Up SDU //Default 0 is Off. One is On
	//To override or activate this SDU change your have to set it too 0 or 1.
	
	// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key using keycode info
	// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
	#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	
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
	//FreePie Compatibility
	#if __RESHADE__ >= 40600
		#if __RESHADE__ > 40700
			#define Compatibility_FP 2
		#else
			#define Compatibility_FP 1
		#endif
	#else
		#define Compatibility_FP 0
	#endif
	
	//Flip Depth for OpenGL and Reshade 5.0 since older Profiles Need this.
	#if __RESHADE__ >= 50000 && __RENDERER__ >= 0x10000 && __RENDERER__ <= 0x20000
		#define Flip_Opengl_Depth 1
	#else
		#define Flip_Opengl_Depth 0
	#endif
	
	#if __VENDOR__ == 0x10DE //AMD = 0x1002 //Nv = 0x10DE //Intel = ???
		#define Ven 1
	#else
		#define Ven 0
	#endif
	 //Vulkan: 0x20000
	#if __RENDERER__ >= 0x20000 //Is Vulkan
		#define ISVK 1
	#else
		#define ISVK 0
	#endif
	
	#if __RENDERER__ >= 0xc000 //Is DX12
		#define ISDX 1
	#else
		#define ISDX 0
	#endif

	#if __RENDERER__ >= 0x10000 && __RENDERER__ <= 0x20000 //Is Opengl
		#define ISOGL 1
	#else
		#define ISOGL 0
	#endif
	
	//Workaround for DX9 for auto Convergence.
	#if __RENDERER__ == 0x9000
		#define DX9_Toggle 1
	#else
		#define DX9_Toggle 0
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
		#define Max_Divergence 125.0//Wow Must be the future and 8K Plus is normal now. If you are here use AI infilling...... Future person.
	#endif                          //With love <3 Jose Negrete..
	//New ReShade PreProcessor stuff
	#if UI_MASK
		#ifndef Mask_Cycle_Key
			#define Mask_Cycle_Key Set_Key_Code_Here
		#endif
	#else
		#define Mask_Cycle_Key Set_Key_Code_Here
	#endif
	//This preprocessor is for Interlaced Reconstruction of Line Interlaced for Top and Bottom and Column Interlaced for Side by Side.
	#ifndef Color_Correction_Mode
		#define Color_Correction_Mode 0
	#endif
	#ifndef Enable_Deband_Mode
		#define Enable_Deband_Mode 0
	#endif
	#ifndef Reconstruction_Mode
		#define Reconstruction_Mode 0
	#endif
	#ifndef Inficolor_3D_Emulator
		#define Inficolor_3D_Emulator 0
	#endif
	#ifndef HDR_Compatible_Mode
		#define HDR_Compatible_Mode 0
	#endif
	#ifndef SD3D_Simple_Mode
		#define SD3D_Simple_Mode 0
	#endif	
	
	//Help / Guide / Information
uniform int SuperDepth3D <
	ui_text = SD3D
			  #if !OSW
			  OVERWATCH
				  #if !NPW
					"                             Profile Loaded\n"
				  #endif 
			  #endif
			  "\n"
				#if DSW
				"Check Depth/Add-on Options: Copy Depth Clear/Frame: You should check it in the Depth/Add-ons tab above.\n"
				"That or you may need to enable/disable Use Extended AR Heuristics or try Extended AR huristics.\n"
				"\n"
				#endif	
			
				#if ARW 
				"Check Aspet Ratio in Add-on: You should check it in the Depth/Add-ons tab above.\n"
				"\n"
				#endif
		
				#if EDW
				"Emulator Detected: Because emulated games are hard to detection you will need to share/make/use a profile for the game you are trying to make work.\n"
				"Extra options are enabled in this mode to allow better support for emulators.\n"
				"Good Luck.\n"
				"\n"
				#endif
				
				#if PEW
				"Disable CA/MB/Dof/Grain: Commen Post effects like chromatic aberration, Motion Blur, Depth of Field, Grain, and Ect. Will/May cause issues with this shader.\n"
				"\n"
				#endif
				
				#if DAA
				"Check TAA/MSAA/SS/DLSS/FSR/XeSS: You may need to enable them or disable the following things correct issues that may happen in your game.\n"
				"\n"
				#endif
			
				#if DRS
				"Disable Dynamic Resolution Scaling: You should disable DRS If it is causing issues in your game.\n"
				"\n"
				#endif
				
				#if WPW
				"Set Weapon: Means you need to manunaly set the Weapon Hand Profile below. To fix the Weapon Hand Issues in your game.\n"
				"\n"
				#endif
			
				#if NDW
				"Net Play: Means you are playing on a Online Game and you may need to use the Add-on Version of ReShade.\n"
				"\n"
				#endif
				
				#if FOV
				"Set FoV: If you set Field of View for a better experiance.\n"
				"\n"
				#endif
			
				#if RHW
				"Read Help: Mean you need to read the Help file for extra information to make the game more enjoyable. I hope to have a website for this some day.\n"
				"\n"
				#endif
		
				#if NPW
				"No Profile: The current game has no profile. This means you need to make one or ask for one to be made for you.\n"
				"\n"
				#endif
			
				#if NCW
				"Incompatible: The current game is incompatible. This may change with a game update or external modifications.\n"
				"\n"
				#endif
			
				#if NFM
				"Needs Mod: The Shader needs a external Mod and or Add-ons to work optimaly or to work at all.\n"
				"It can be anything such as the REFramework or something like the Generic Depth Mod for Reshade.\n"
				"More information in the Read Help doc or Join our Discord https://discord.gg/KrEnCAxkwJ.\n"
				"\n"
				#endif
		
				#if NVK
				"Needs DXVK: Download and use DXVK.\n"
				"\n"
				#endif
		
				#if NDG
				"Needs DGVOODOO2: Download and use DGVooDoo2.\n"
				"\n"
				#endif
		
				#if OSW
				"The header file for Profiles called Overwatch.fxh is Missing.\n"
				"\n"
				#endif
				"__________________________________________________________________\n"
			    "For more information and help please visit http://www.Depth3D.info";
	ui_category = "Depth3D Information";
	ui_category_closed = true;
	ui_label = " ";
	ui_type = "radio";
	>;
	
	//uniform float TEST < ui_type = "drag"; ui_min = 0; ui_max = 1; > = 1.0;
	//Divergence & Convergence//
	uniform float Divergence <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 100; ui_step = 0.5;
		#if !SD3D_Simple_Mode
		ui_label =  "·Depth Adjustment·"; 
		#else
		ui_label =  "·Depth Separation·"; 		
		#endif
		ui_tooltip =  "Increases differences between the left and right images and allows you to experience depth.\n"
					  "The process of deriving binocular depth information is called stereopsis (or stereoscopic vision).";
		ui_category = "Divergence & Convergence";
	> = 50;
	#if !SD3D_Simple_Mode
	uniform float2 ZPD_Separation <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.250;
		ui_label =    " ZPD & Separation";
		ui_tooltip =  "ZPD (Zero Parallax Distance) controls the focus distance for the screen Pop-out effect.\n" //https://manual.reallusion.com/iClone_6/ENU/Pro_6.0/09_3D_Vision/Settings_for_Pop_Out_and_Deep_In_Effect.htm
					  "For FPS Games keep ZPD low since you don't want your gun to pop out of the screen.\n"
					  "\n"
					  "Separation is a way to increase the perception of Depth.\n"
					  "\n"
					  "Default for ZPD is 0.025, for Seperation it's 0.0 and Zero is off.";
		ui_category = "Divergence & Convergence";
	> = float2(DA_X,DF_Y);//0.025,0.000
	#else
		uniform float ZPD_Separation <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.250;
		ui_label =    " ZPD";
		ui_tooltip =  "ZPD (Zero Parallax Distance) controls the focus distance for the screen Pop-out effect.\n" //https://manual.reallusion.com/iClone_6/ENU/Pro_6.0/09_3D_Vision/Settings_for_Pop_Out_and_Deep_In_Effect.htm
					  "For FPS Games keep ZPD low since you don't want your gun to pop out of the screen.\n"
					  "Default for ZPD is 0.025.";
		ui_category = "Divergence & Convergence";
	> = DA_X;//0.025,0.000
	#endif
	uniform float ZPD_Balance <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " ZPD Balance";
		ui_tooltip = "This balances between ZPD Depth and Scene Depth.\n" //***
					 "Changes the prioritization of the 3D effect.\n"
					 "Default is 0 for ZPD Depth and 0.5 is enhanced Scene Depth.";
		ui_category = "Divergence & Convergence";
	> = DF_Z;
	
	#if !Inficolor_3D_Emulator
	uniform int Auto_Balance_Ex <
		ui_type  = "combo";
		ui_items = "Off\0Left\0Center\0Right\0Center Wide\0Left Wide\0Right Wide\0";
//		ui_items = "Off\0Left\0Center\0Right\0Center Wide\0Left Wide\0Right Wide\0Eye Tracker\0Eye Tracker Alt\0";
		ui_label = " ZPD Auto Balance";
		ui_tooltip = "Automatically Balance between ZPD Depth and Scene Depth.\n"
					 "Default is Off.";
		ui_category = "Divergence & Convergence";
	> = ABE;
	#endif
	uniform int ZPD_Boundary <
		ui_type = "combo";
		ui_items = "BD0 Off\0BD1 Full\0BD2 Narrow\0BD3 Wide\0BD4 FPS Center\0BD5 FPS Narrow\0BD6 FPS Edge\0BD7 FPS Mixed\0";		
		ui_label = " ZPD Boundary Detection";
		ui_tooltip = "This selection gives extra boundary conditions to detect for ZPD intrusions.\n"//***
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
		ui_label = " ZPD Scaler¹ & Transition";
		ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level One.\n"
					 "The 2nd option lets you adjust the transition time for LvL One & Two.\n"
					 "Only works when Boundary Detection is enabled.";
		ui_category = "Divergence & Convergence";
	> = float2(DE_Y,DE_Z);
	
	uniform float2 ZPD_Boundary_n_Cutoff <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " ZPD Scaler² & Intrusion";
		ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level two.\n"
					 "lets you adjust how far behind the screen it should detect a intrustion.\n"
					 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
		ui_category = "Divergence & Convergence";
	> = float2(OIF.x,DI_W.x);	
	
	uniform int View_Mode <
		ui_type = "combo";
		ui_items = "VM0 Normal \0VM1 Alpha \0VM2 Reiteration \0VM3 Stamped \0VM4 Mixed \0VM5 Adaptive \0";
		ui_label = "·View Mode·";
		ui_tooltip = "Changes the way the shader fills in the occluded sections in the image.\n"
					"Normal      | Normal output used for most games with a streched look.\n"
					"Alpha       | Like Normal But with a bit more sepration in the infilling.\n"
					"Reiteration | Same thing as Stamped but with brakeage points.\n"
					"Stamped     | Stamps out a transparent area where occlusion happens.\n"
					"Mixed       | Used when high amounts of Semi-Transparent objects like foliage in the image.\n"
					"Adaptive    | is a scene adapting infilling that uses disruptive reiterative sampling.\n"
					"\n"
					"Warning: Also Make sure Performance Mode is active before closing the ReShade menu.\n"
					"\n"
					"Default is Alpha.";
	ui_category = "Occlusion Masking";
	> = DS_Z;

	uniform int View_Mode_Warping <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0; ui_max = 5; // Tried having a max of 6. But, After a year of having that max value it was never used in any profile Max of 5 was used sometimes
		ui_label = " Halo Reduction";
		ui_tooltip = "This distorts the depth in some View Modes to hide or minimize the halo in Most Games.\n"
					 "With this active it should Hide the Halo a little better depending the View Mode it works on.\n"
					 "Default is 3 and Zero is Off.";
		ui_category = "Occlusion Masking";
	> = 3;	

	uniform int Custom_Sidebars <
		ui_type = "combo";
		ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
		ui_label = " Edge Handling";
		ui_tooltip = "Edges selection for screen output.\n"
		  			 "What type of filling to be used on the empty spaces on the edges";
		ui_category = "Occlusion Masking";
	> = 1;
	
	uniform float Edge_Adjust <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;                                                                                                  
		ui_label = " Edge Reduction";
		ui_tooltip = "This Decreses the Edge at the cost of warping the image.\n"
					 "Default is 50.0%.";
		ui_category = "Occlusion Masking";
	> = 0.5;
	
		uniform float Range_Blend <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		ui_label = " Range Smoothing";
		ui_tooltip = "This blends Two Depth Buffers at a distance to fill in missing information that is needed to compleat a image.\n"
					 "With this active, it should help with trees and other foliage that needs to be reconstructed by Temporal Methods.\n"
					 "Default is Zero, Off.";
		ui_category = "Occlusion Masking";
	> = DJ_X;		
	
	uniform int Performance_Level <
		ui_type = "combo";
		ui_items = "Performant\0Normal\0Performant + VRS\0Normal + VRS\0";
		ui_label = " Performance Level";
		ui_tooltip = "Performance Levels Lowers or Raises Occlusion Quality Processing so that the performance is adjusted accordingly.\n"
					 "Varable Rate Shading focuses the quality of the samples in lighter areas of the screen.\n"
					 "Please enable the 'Performance Mode' Checkbox, in ReShade's GUI.\n"
					 "It's located in the lower bottom right of the ReShade's Main.\n"
					 "Default is Performant.";
		ui_category = "Occlusion Masking";
	> = 0;
	
	uniform int Switch_VRS <
		ui_type = "combo";
		ui_items =   "Auto\0High\0Med\0Low\0Very Low\0";
		ui_label =   " VRS Performance";
		ui_tooltip = "Use this to set Varable Rate Shading to manually selection or automatic mode.\n"
			         "Default is Automatic.";
		ui_category = "Occlusion Masking";
	> = 0;
	
	uniform bool Foveated_Mode <
			ui_label = "Foveated Rendering";
			ui_tooltip = "Foveated rendering lowes the quality of the infilling around the center of the image.\n"
						 "In the future when we have a method for eye tracking this should work a lot better.";
			ui_category = "Occlusion Masking";
	> = true;
	
	uniform float Compatibility_Power <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = -1.0; ui_max = 1.0;
		ui_label = " Compatibility Power";
		ui_tooltip = "This option lets you increase this offset in both directions to limit artifacts.\n"
					 "With this active it should work better in games with TAA, XeSS, FSR,and or DLSS sometimes.\n"
					 "Default is Zero.";
		ui_category = "Compatibility Options";
	> = DL_Z;

	uniform float2 De_Artifacting <
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
	> = float2(DL_Y,DB_Y);	
	
	uniform float2 DLSS_FSR_Offset <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 5.0;
		ui_label = " Upscaler Offset"; //***
		ui_tooltip = "This Offset is for non conforming ZBuffer Postion witch is normaly 1 pixel wide.\n"
					 "This issue only happens sometimes when using things like DLSS, XeSS and or FSR.\n"
					 "This does not solve for TAA artifacts like Jittering or Smearing.\n"
					 "Default and starts at 0 and is Off. With a max offset of 5 pixels Wide.";
		ui_category = "Compatibility Options";
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
		ui_label = " Near Plane Adjustment";
		ui_tooltip = "This allows for you to adjust the depth map's near plane.\n"
					 "If a profile is activated ignore this.\n"
					 "Default is 7.5";
		ui_category = "Depth Map";
	> = DA_Y;
	
	uniform float Offset <
		ui_type = "drag";
		ui_min = -1.0; ui_max = 1.0;
		ui_label = " Linear Offset";
		ui_tooltip = "Depth Map Offset is for non conforming ZBuffer.\n"
					 "It's rare if you need to use this in any game.\n"
					 "Default and starts at Zero and it's Off.";
		ui_category = "Depth Map";
	> = DA_Z;
	
	uniform float Auto_Depth_Adjust <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.500;
		ui_label = " Auto Near Plane";
		ui_tooltip = "Automatically adjust Near Plane to prevent excessive pop-out effects.\n"
					 "Default is 0.1, Zero is off.";
		ui_category = "Depth Map";
	> = DB_Z;
	/*
		uniform float Push_Depth < //Experimental Option
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.500;
		ui_label = " Push Depth";
		ui_tooltip = "This option moves the ZPD cutoff point for infilling in by extention it limits the pop-out effect.\n"
					 "Default is 0.0, Zero is off.";
		ui_category = "Depth Map";
	> = 0.0;
	*/
	static const int Push_Depth = 0.0;
	uniform int Range_Boost <
		ui_type = "combo";
		ui_items = "Off\0Offset Based\0Near Plane Based X1\0Near Plane Based X2\0Near Plane Based X3\0Near Plane Based X4\0";
		ui_label = " Boost Range";
		ui_tooltip = "Boost Range details in Depth with out effecting near plane too much.";
		ui_category = "Depth Map";
	> = DS_Y;
	
	uniform int Depth_Map_View <
		ui_type = "combo";
		ui_items = "Off\0Stereo Depth View\0Normal Depth View\0";
		ui_label = " Depth Map View";
		ui_tooltip = "Display the Depth Map.\n"
					 "Default is Off.";
		ui_category = "Depth Map";
	> = 0;

	static const int Depth_Detection = 1;
	
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
					 "Z, Tuning is used to fine tune the precision adjustment above.\n"
					 "W, Scale is used to compress or rescale the weapon.\n"
		             "Default is float2(X 0.0, Y 0.0, Z 0.0, W 1.0)";
		ui_category = "Weapon Hand Adjust";
	> = float4(0.0,0.0,0.0,0.0);

	uniform float4 WZPD_and_WND <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.5;
		ui_label = " Weapon Near, Min, Auto, & Trim";
		ui_tooltip = "Weapon Near: is used to set the Weapon ZPD for when the distortions from options below are to mush of a problem.\n"
					 "Weapon Min : is used to adjust min weapon hand of the weapon hand when looking at the world near you when the above fails.\n"
					 "Weapon Auto: is used to auto adjust trimming when looking around.\n"
					 "Weapon Trim: is used cutout a location in the depth buffer so that Min and Auto scale off of.\n"
					 "Default is (Near X 0.0, Min Y 0.0, Auto Z 0.0, Trim Z 0.250 ) & Zero is off.";
		ui_category = "Weapon Hand Adjust";	
	> = float4(WND,DG_Z,DE_W,DI_Z);// Weapon ZDP was set to 0.03 and is an internal constant value
	
	uniform float4 Weapon_Depth_Edge <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Screen Edge Adjust & Near Scale";
		ui_tooltip = "This Tool is to help with screen Edge adjustments and Weapon Hand scaling near the screen";
		ui_category = "Weapon Hand Adjust";	
	> = DF_W;
	
	uniform float2 Weapon_ZPD_Boundary <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 0.5;
		ui_label = " Weapon Boundary Detection";
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

	#if Reconstruction_Mode	
	uniform int Reconstruction_Type <
		ui_type = "combo";
		ui_items = "CB Reconstruction\0Line Interlace Reconstruction\0Column Interlaced Reconstruction\0";
		ui_label = "·Reconstruction Mode·";
		ui_tooltip = "Stereoscopic reconstructed 3D display output selection.";
		ui_category = "Stereoscopic Options";
	> = 0;
	#endif
	//Stereoscopic Options//
	uniform int Stereoscopic_Mode <
		ui_type = "combo";
		#if Inficolor_3D_Emulator
			ui_items = "TriOviz Inficolor 3D Emulation\0";
			ui_label = " 3D Display Mode";
		#else
			#if Reconstruction_Mode // traduzir todas as opçoes
				ui_items = "Side by Side\0Top and Bottom\0Anaglyph 3D Red/Cyan\0Anaglyph 3D Red/Cyan Dubois\0Anaglyph 3D Red/Cyan Anachrome\0Anaglyph 3D Green/Magenta\0Anaglyph 3D Green/Magenta Dubois\0Anaglyph 3D Green/Magenta Triochrome\0Anaglyph 3D Blue/Amber ColorCode\0";
				ui_label = " 3D Display Modes";
			#else
				ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Quad Lightfield 2x2\0Anaglyph 3D Red/Cyan\0Anaglyph 3D Red/Cyan Dubois\0Anaglyph 3D Red/Cyan Anachrome\0Anaglyph 3D Green/Magenta\0Anaglyph 3D Green/Magenta Dubois\0Anaglyph 3D Green/Magenta Triochrome\0Anaglyph 3D Blue/Amber ColorCode\0";		
				ui_label = "·3D Display Modes·";
			#endif
		#endif
		ui_tooltip = "Stereoscopic 3D display output selection.";
		ui_category = "Stereoscopic Options";
	> = 0;
	
	uniform float2 Interlace_Anaglyph_Calibrate <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Interlace Optimization & Anaglyph Saturation";
		ui_tooltip = "Interlace Optimization is used to reduce aliasing in a Line or Column interlaced images. This has the side effect of softening the image.\n"
		             "Anaglyph Desaturation allows for removing color from an anaglyph 3D image. Zero is Black & White, One is full color.\n"
					 "Default for Interlace Optimization and Anaglyph Desaturation/Saturation is 0.5.";
		ui_category = "Stereoscopic Options";
	> = float2(0.5,0.5);
	
	uniform float2 Anaglyph_Eye_Contrast <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Anaglyph Contrast";
		ui_tooltip = "Per Eye Contrast adjustment for Anaglyph 3D.\n"
					 "Default is set to 0.5 Off.";
		ui_category = "Stereoscopic Options";
	> = float2(0.5,0.5);
	#if Inficolor_3D_Emulator

	uniform float3 Inficolor_Reduce_RGB <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Inficolor Reduce Red, Green & Blue";
		ui_tooltip = "This option lets you reduce or isolated any color in the upper range in the game.\n"
					 "Default is set to 0.5.";
		ui_category = "Stereoscopic Options";
	> = 0.5;	
	
	uniform int Auto_Balance_Ex <
		ui_type = "combo";
		ui_items = "Off\0Left\0Center\0Right\0Center Wide\0Left Wide\0Right Wide\0";
//		ui_items = "Off\0Left\0Center\0Right\0Center Wide\0Left Wide\0Right Wide\0Eye Tracker\0Eye Tracker Alt\0";
		ui_label = " Inficolor Auto Balance";
		ui_tooltip = "Automatically Balance between ZPD Depth and Scene Depth.\n"
					 "Default is Off.";
		ui_category = "Stereoscopic Options";
	> = 2;

	uniform float Inficolor_OverShoot <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Inficolor OverShoot";
		ui_tooltip = "Inficolor 3D OverShoot for Auto Balance.\n"
					 "Default and starts at 0.5 and it's 50% overshoot.";
		ui_category = "Stereoscopic Options";
	> = 0.5;

	uniform float Inficolor_Max_Depth <
		ui_type = "drag";
		ui_min = 0.5; ui_max = 1.0;
		ui_label = " Inficolor Max Depth";
		ui_tooltip = "Max Depth lets you clamp the max depth range of your scene.\n"
					 "So it's not hard on your eyes looking off in to the distance .\n"
					 "Default and starts at One and it's Off.";
		ui_category = "Stereoscopic Options";
	> = 0.875;
	
	uniform float Focus_Inficolor <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Inficolor Focus";
		ui_tooltip = "Adjust this until the image has as little Color Fringing at the near and far range.\n"
					 "Default is set to 0.5.";
		ui_category = "Stereoscopic Options";
	> = 0.5;
	
	#else
		static const float Focus_Inficolor = 0.5;
		static const float Inficolor_Max_Depth = 1.0;
		static const float Inficolor_OverShoot = 0.0;
	#endif
	
	#if Ven && !Inficolor_3D_Emulator
	uniform int Scaling_Support <
		ui_type = "combo";
		ui_items = "SR Native\0SR 2160p A\0SR 2160p B\0SR 1080p A\0SR 1080p B\0SR 1050p A\0SR 1050p B\0SR 720p A\0SR 720p B\0";
		ui_label = " Downscaling Support";
		ui_tooltip = "Dynamic Super Resolution scaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.\n"
					 "Set this to your native Screen Resolution A or B, DSR Smoothing must be set to 0%.\n"
					 "This does not work with a hardware scaling done by VSR.\n"
					 "Default is SR Native.";
		ui_category = "Stereoscopic Options";
	> = 0;
	#else
	static const int Scaling_Support = 0;
	#endif
	#if Inficolor_3D_Emulator
	static const int Perspective = 0;
	
	uniform bool Inficolor_Near_Reduction <
		ui_label = " Inficolor 3D Near Reduction";
		ui_tooltip = "Inficolor 3D Near Depth Reduction Toggle.";
		ui_category = "Stereoscopic Options";
	> = true;
	
	uniform bool Inficolor_Auto_Focus <
		ui_label = " Inficolor Auto Focus";
		ui_tooltip = "Inficolor 3D auto Focusing.";
		ui_category = "Stereoscopic Options";
	> = false;

	#else
	static const int Inficolor_Near_Reduction = 0;
	
	uniform int Perspective <
		ui_type = "slider";
		ui_min = -100; ui_max = 100;
		ui_label = " Perspective Slider";
		ui_tooltip = "Determines the perspective point of the two images this shader produces.\n" // ipd = Interpupillary distance 
					 "For an HMD, use Polynomial Barrel Distortion shader to adjust for IPD or use SuperDepth3D_VR+.fx.\n"
					 "Do not use this perspective adjustment slider to adjust for IPD.\n"
					 "Default is Zero.";
		ui_category = "Stereoscopic Options";
	> = 0;
	#endif
	uniform bool Eye_Swap <
		ui_label = " Swap Eyes";
		ui_tooltip = "L/R to R/L."; // E/D ou D/E

		ui_category = "Stereoscopic Options";
	> = false;
	
	uniform int Focus_Reduction_Type <
		ui_type = "combo";
		ui_items = "World\0Weapon\0Mix\0";
		ui_label = "·Focus Type·";
		ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
					"This may induce Eye Strain so take this as a Warning.";
		ui_category = "FPS Focus";
	> = FPS;
	
	uniform int FPSDFIO <
		ui_type = "combo";
		ui_items = "Off\0Press\0Hold\0";
		ui_label = " Activation Type";
		ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
					"This may induce Eye Strain so take this as a Warning.";
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

	uniform int Weapon_Reduction_n_Power <
		ui_type = "slider";
		ui_min = 0; ui_max = 8;
		ui_label = " Weapon Reduction";
		ui_tooltip ="Weapon Reduction: Adjusts the Weapon in world space by a current percentage.\n"
					"Default is [ 0 ].";
		ui_category = "FPS Focus";
	> = WRP;
	
	uniform int2 World_n_Fade_Reduction_Power <
		ui_type = "slider";
		ui_min = 0; ui_max = 8;
		ui_label = " World & Fade Options";
		ui_tooltip ="X, World Reduction: Decreases the ammount of world depth by a current percentage.\n"
					"Y, Fade Speed: Decreases or Incresses how fast it changes.\n"
					"Default is X[ 0 ] Y[ 1 ].";
		ui_category = "FPS Focus";
	> = int2(DK_Z,DK_W);
	/*
	uniform bool FPS_Focus_Smoothing <
		ui_label = " Auto FPS Smoothing";
		ui_tooltip = "Increases Halo Reduction to the max value of Five.\n"
					 "This can allow a slight improvment in aiming.\n"
					 "Default is Off.";
		ui_category = "FPS Focus";
	> = false;
	*/
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
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
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
		ui_tooltip = "Turns Screen Cursor Off and On without cycling, once set to the option above.";
		ui_category = "Cursor Adjustments";
	> = true;
	
	#if BD_Correction
	uniform int BD_Options <
		ui_type = "combo";
		ui_items = "On\0Off\0Guide\0";
		ui_label = "·Distortion Options·";
		ui_tooltip = "Use this to Turn Off, Turn On, & to use the BD Alignment Guide.\n"
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
		ui_tooltip = "Adjust Distortions K1, K2, & K3.\n" // k stands for coefficient 
					 "Default is 0.0";
		ui_label = " Barrel Distortion K1 K2 K3 ";
		ui_category = "Distortion Corrections";
	> = float3(DC_X,DC_Y,DC_Z);
	
	uniform float Zoom <
		ui_type = "drag";
		ui_min = -0.5; ui_max = 0.5;
		ui_label = " Barrel Distortion Zoom";
		ui_tooltip = "Adjust Zoom Distortions.\n"// ajustar distorçao causada pelo zoom
					 			 "Default is 0.0";
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
	#if Color_Correction_Mode
	uniform int Color_Correction <
		ui_type = "combo";
		ui_items = "Off\0On\0";
		ui_label = "·Color Correction·";
		ui_tooltip = "Partial Luma Preserved Color Correction.\n"
					"Removes Tint and or Color Cast in an automatic way while enhancing contrast.\n"
					"This works by sampling the image and creating a min and max color map and adjusting the image accordingly.\n"
					"Default is Off.";
		ui_category = "Miscellaneous Options";
	> = 0;

	uniform float Correction_Strength <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Correction Factor";
		ui_tooltip = "This gives full control over Color Correction Factor.\n"
					"It can make dark areas brighter, Try to leave this on low to preserve atmosphere.\n"
					"Default is 0.0, Low.";
		ui_category = "Miscellaneous Options";
	> = 0.0;
	#endif
	#if Color_Correction_Mode || Enable_Deband_Mode
	uniform bool Toggle_Deband <
		ui_label = " Deband Toggle";
		ui_tooltip = "Turns on automatic Depth Aware Deband this is used to reduce or remove the color banding in the image.";
		ui_category = "Miscellaneous Options";
	> = true;
	#endif
	uniform bool Vert_3D_Pinball <
	#if Color_Correction_Mode
		ui_label = " Swap 3D Axis";
	#else
		ui_label = "·Swap 3D Axis·";	
	#endif
		ui_tooltip = "Use this to swap the axis that the Parallax is generated.\n"
					 "Useful for 3D Pinball Games, You may have to swap eyes.\n"
					 "Default is Off.";
		ui_category = "Miscellaneous Options";
	> = false;

	//Extra Informaton
uniform int Extra_Information <
	ui_text =   "Profiles Info:\n"
				"If the shader loads a profile, avoid using [ZPD] and [Depth Map] optons. \n"
				"Since adjusting options like Near Plane Adjustment, Flip, ZPD, Offset, & Ect.\n"
				"Can and will break the profiles that are already in the Overwatch.fxh.\n"
				"If you want to make your own profile delete Overwatch.fxh.\n"
				"\n"
				"New Profiles:\n"
				"If the shader starts up and says 'No Profile,' the first thing you should do is\n"
				"enable depth view in the game and set the depth where it looks like a B&W gradient\n"
				"that shows up as dark near you and lighter as it moves into the distance.\n"
				"If it doesn't look like that, set the [Depth Map] from DM0 to DM1.\n"
				"At this point, check orientation. If it looks upside down, just use [Flip].\n"
				"Disable the depth buffer view, and in-game, adjust the [Near Plane] until it looks nice.\n"
				"Be careful not to have screen violations, That's where an object starts to stick out.\n"
				"It should look like you are looking into a portal, and the objects are inside of it.\n"
				"Ignore the FPS options here since it will be way more complicated for this mini guide.\n"
				"\n"
				"Boundary Detection:\n"				
				"[ZPD Boundary Detection] Should be set at this time to 1-3 for most games.\n"
				"Now move the camrea until it something near the screen violates the Boundary Detection.\n"
				"Now adjust [ZPD Scaler¹] from 0.5-0.875 once that looks good move on to the option below.\n"
				"[ZPD Scaler²] & [Intrusion] Move the camrea where it clip a little and adjust the 1st opion\n"
				"where it looks good too you. Then move the 2nd slider until it stops working and adjust it\n"
				"to about 1.0 - 0.5. This will start to make sense the more profiles you make over time.\n"
				"This should serve you well in the majority of games.\n"				
				"\n"
				"Youtube Guides:\n"
				"Some already exist and more will come in time. For more information goto\n"
				"https://www.youtube.com/@BlueSkyDefender\n"
				"\n"
				"Performance:\n"
				"To lower the cost of the shader use the lower cost Performance Levels Like.\n"
				"[Performance + VRS v ]\n"
				"|Normal + VRS        |\n"
				"\n"
				"Performance Ex:\n"
				"Also please enable the 'Performance Mode' Checkbox, in ReShade's GUI.\n"
				"It's located in the lower bottom right of the ReShade's Main Menu.\n"
				"\n"
				"Preprocessors:\n"
				"Color Correcting  | Is the process of restoring the original colors in the scenes.\n"
				"Deband            | Is used to correct for banding issues in the image.\n"
				"HDR compatibility | Allows for HDR support in the shader when HDR is available.\n"
				"Inficolor 3D      | Modify the shader to accommodate Inficolor glasses for 3D content.\n"
				"Reconstruction    | Is a diffrent way to render the images out.\n"
				"\n"
				"Active Keys:\n"
				"Menu Key          | Is used to toggle on-screen information you see at startup.\n"
				"Mouse Button 4    | Is used to unlock and lock the on screen cursor.\n"
				"_______________________________________________________________________________\n"
			    "Try reading the Read Help doc or Join our Discord https://discord.gg/KrEnCAxkwJ";
	ui_category = "Depth3D Guidelines";
	ui_category_closed = true;
	ui_label = " ";
	ui_type = "radio";
	>;

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; mode = "toggle";>;
	uniform bool Mask_Cycle < source = "key"; keycode = Mask_Cycle_Key; toggle = true; mode = "toggle";>;
	uniform bool Text_Info < source = "key"; keycode = Text_Info_Key; toggle = true; mode = "toggle";>;
	uniform bool CLK < source = "mousebutton"; keycode = Cursor_Lock_Key; toggle = true; mode = "toggle";>;
	uniform bool Trigger_Fade_A < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
	uniform bool Trigger_Fade_B < source = "mousebutton"; keycode = Fade_Key;>;
	uniform float2 Mousecoords < source = "mousepoint"; > ;
	uniform float frametime < source = "frametime";>;
	uniform bool Alternate < source = "framecount";>;     // Alternate Even Odd frames
	uniform float timer < source = "timer"; >;
	
	#if HDR_Compatible_Mode == 1
		#define BC_SPACE 1
	#else
		#define BC_SPACE 0
	#endif

	static const float3x3 BT709_To_BT2020 = float3x3(
	  0.627225305694944,  0.329476882715808,  0.0432978115892484,
	  0.0690418812810714, 0.919605681354755,  0.0113524373641739,
	  0.0163911702607078, 0.0880887513437058, 0.895520078395586);
	
	static const float3x3 BT2020_To_BT709 = float3x3(
	   1.66096379471340,   -0.588112737547978, -0.0728510571654192,
	  -0.124477196529907,   1.13281946828499,  -0.00834227175508652,
	  -0.0181571579858552, -0.100666415661988,  1.11882357364784);

	float4 NormalizeScRGB(float4 RGB)
	{
	  RGB.rgb = RGB.rgb / 125.f; // normalize 10000 nits to 1.0
	  RGB.rgb = mul(BT709_To_BT2020, RGB.rgb); // rotate into BT.2020 primaries so colors outside of BT.709 don't get lost to clipping
	
	  return RGB;
	}
	
	float4 ExpandScRGB(float4 RGB)
	{
	  RGB.rgb = mul(BT2020_To_BT709, RGB.rgb); // rotate back into valid scRGB/BT.709 values
	  RGB.rgb = RGB.rgb * 125.f; // expand into valid scRGB values again
	
	  return RGB;
	}
	
	#if Compatibility_FP
	uniform float3 motion[2] < source = "freepie"; index = 0; >;
	//. motion[0] is yaw, pitch, roll and motion[1] is x, y, z. In ReShade 4.8+ in ReShade 4.7 it is x = y / y = z
	//float3 FP_IO_Rot(){return motion[0];}
	float3 FP_IO_Pos()
	{
	#if Compatibility_FP == 1
		#warning "Eye Tracking enhanced features need ReShade 4.8.0 and above."
		return motion[1].yzz;
	#elif Compatibility_FP == 2
		return motion[1];
	#endif
	}
	#else
	//float3 FP_IO_Rot(){return 0;}
	float3 FP_IO_Pos(){return 0;}
	#warning "Eye Tracking Need ReShade 4.6.0 and above."
	#endif
	
	static const float Auto_Balance_Clamp = 0.5; //This Clamps Auto Balance's max Distance.
	
	#if Compatibility_DD
	uniform bool DepthCheck < source = "bufready_depth"; >;
	#endif

	//Resolution Scaling so that auto anti cross talk works.
	#define Comb_Size BUFFER_HEIGHT + BUFFER_WIDTH
	#if ( Comb_Size <= 3360)
		#if ( Comb_Size <= 1400)
			#if (Set_Depth_Res >= 2 )
				#define Max_Mips 8
			#else
				#define Max_Mips 9
			#endif
		#else
			#if (Set_Depth_Res >= 2 )
				#define Max_Mips 10
			#else
				#define Max_Mips 11
			#endif
		#endif
	#else
		#if (Set_Depth_Res >= 2 )
			#define Max_Mips 11
		#else
			#define Max_Mips 12
		#endif
	#endif

	float3 RE_Set(float Auto_Switch)
	{
		#if OIL == 1
			float OIL_Switch[2] = {ZPD_Boundary_n_Cutoff.x,OIF.y};	
		#elif ( OIL == 2 )
			float OIL_Switch[3] = {ZPD_Boundary_n_Cutoff.x,OIF.y,OIF.z};	
		#elif ( OIL == 3 )
			float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff.x,OIF.y,OIF.z,OIF.w};	
		#else
			float OIL_Switch[1] = {ZPD_Boundary_n_Cutoff.x};	
		#endif   	
		int Scale_Auto_Switch = clamp((Auto_Switch * 4) - 1,0 , 3 );
		float Set_RE = OIL_Switch[Scale_Auto_Switch];

		int REF_Trigger = Set_RE > 0;
		return float3(REF_Trigger, Set_RE , Scale_Auto_Switch); 
	}
	
	float4 RE_Set_Adjustments()
	{
		#if OIL == 1
			float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff.x,OIF.y,0,0};	
		#elif ( OIL == 2 )
			float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff.x,OIF.y,OIF.z,0};	
		#elif ( OIL == 3 )
			float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff.x,OIF.y,OIF.z,OIF.w};	
		#else
			float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff.x,0,0,0};	
		#endif 
		return float4(OIL_Switch[0], OIL_Switch[1], OIL_Switch[2], OIL_Switch[3]);
	}

	float Scale(float val,float max,float min) //Scale to 0 - 1
	{
		return (val - min) / (max - min);
	}
	
	float2 Min_Divergence() // and set scale
	{   
		#if SD3D_Simple_Mode
		float Diverge = Divergence <= 50 ? Divergence : 50;
		#else
		float Diverge = Divergence;
		#endif	    
		float Min_Div = max(1.0, Diverge), D_Scale = min(1.25,Scale(Min_Div,100.0,1.0));
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

	float fmod(float a, float b)
	{
		float c = frac(abs(a / b)) * abs(b);
		return a < 0 ? -c : c;
	}
	
	//#define E_O_Switch fmod(abs(Perspective),2)
	float Re_Scale_WN()
	{
		return saturate(WZPD_and_WND.x);
	}
	
	float Perspective_Switch()// Need to Fix Inficolor Perspective calculation.
	{
		float Min_Div = max(1.0, Divergence), D_Scale = Scale(Min_Div,100.0,1.0);   
		float I_3D_E = (Min_Divergence().x * lerp(1.0,2.0,Focus_Inficolor)); //This is to fix strange offset issue don't know why it need to be offset by one pixel to work.???
		I_3D_E += (Re_Scale_WN()*200)*D_Scale;
		float Perspective_Out = Perspective, Push_Depth = (Re_Scale_WN()*100.0)*D_Scale;
		//float PER_Switch = Stereoscopic_Mode == 0 || Stereoscopic_Mode == 5 ?  E_O_Switch ? Perspective : Perspective + 1 :  E_O_Switch ? Perspective + 1 : Perspective;
		if( Inficolor_3D_Emulator) 
			Perspective_Out = Eye_Swap ? I_3D_E : -I_3D_E;
		else
			Perspective_Out = Eye_Swap ? Perspective + Push_Depth : Perspective - Push_Depth;	
		return Perspective_Out;	
	}

	#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	#define Per Vert_3D_Pinball ? float2( 0, (Perspective_Switch() * pix.x) ) : float2( (Perspective_Switch() * pix.x), 0) //Per is Perspective
	#define texsize int2(BUFFER_WIDTH, BUFFER_HEIGHT)
	#define AI Interlace_Anaglyph_Calibrate.x * 0.5 //Optimization for line interlaced Adjustment.
	#define ARatio texsize.x / texsize.y
	#define FLT_EPSILON  1.192092896e-07 // smallest such that Value + FLT_EPSILON != Value	
				
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
	}//Code Not used for anything...
	///////////////////////////////////////////////////////////////3D Starts Here///////////////////////////////////////////////////////////
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
	texture texDMN { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = RGBA16F; MipLevels = Max_Mips; };
	
	sampler SamplerDMN
		{
			Texture = texDMN;
		};
	
	texture texzBufferN_P { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = RG16F; };
	
	sampler SamplerzBufferN_P
		{
			Texture = texzBufferN_P;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	
	texture texzBufferN_L { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = R16F; MipLevels = 8; };
	
	sampler SamplerzBufferN_L
		{
			Texture = texzBufferN_L;
		};
		
	#if Reconstruction_Mode
		#if BC_SPACE == 1
			#define Color_Format RGBA16
		#else
			#define Color_Format RGB10A2
		#endif
	texture texSD_CB_L { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format;};
	
	sampler Sampler_SD_CB_L
		{
			Texture = texSD_CB_L;
		};
	texture texSD_CB_R { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format;};
	
	sampler Sampler_SD_CB_R
		{
			Texture = texSD_CB_R;
		};
	#endif

	#if DX9_Toggle
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = R16F; MipLevels = 6; }; // Needs to be RG16F If external Texture is given for DownSample. Not needed if external texture is already down sampled.
	#else
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = RG16F; MipLevels = 6; }; // Needs to be RG16F If external Texture is given for DownSample. Not needed if external texture is already down sampled.
	#endif
	
	sampler SamplerzBuffer_BlurN
		{
			Texture = texzBufferBlurN;
		};
	

	texture texzBufferN_M { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = R16F; };
	
	sampler SamplerzBufferN_Mixed
		{
			Texture = texzBufferN_M;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	
	#if UI_MASK
	texture TexMaskA < source = "DM_Mask_A.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
	sampler SamplerMaskA { Texture = TexMaskA;};
	texture TexMaskB < source = "DM_Mask_B.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
	sampler SamplerMaskB { Texture = TexMaskB;};
	#endif
	texture Info_Tex < pooled = true; >  { Width = 800; Height = 600; Format = R8;};
	sampler SamplerInfo { Texture = Info_Tex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	#define Scale_Buffer 160 / BUFFER_WIDTH
	////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////
	texture texLumN {Width = BUFFER_WIDTH * Scale_Buffer; Height = BUFFER_HEIGHT * Scale_Buffer; Format = RGBA16F; MipLevels = 8;};
	
	sampler SamplerLumN
		{
			Texture = texLumN;
		};
	#if Color_Correction_Mode	
	texture2D texMinMaxRGBLastFrame { Width = BUFFER_WIDTH * Scale_Buffer; Height = BUFFER_HEIGHT * Scale_Buffer; Format = RGBA16f; };
	sampler2D samplerMinMaxRGBLastFrame 
	{
		 Texture = texMinMaxRGBLastFrame;
		 MagFilter = POINT;
		 MinFilter = POINT;
		 MipFilter = POINT;
	};
	
	texture2D texMinMaxRGB { Width = 2; Height = 1; Format = RGBA16f; };
	sampler2D samplerMinMaxRGB
	{ 
		Texture = texMinMaxRGB;
		MagFilter = POINT;
		MinFilter = POINT;
		MipFilter = POINT;
	};
	
	void MinMaxRGB(float4 vpos : SV_Position, float2 texcoord : TexCoord, out float4 minmaxRGB : SV_Target0)
	{
		float3 color, minRGB = 1.0, maxRGB = 0.0;
		int2 SIZE_STEPS = texsize/15;
		if(Color_Correction)
		{ 
		for(int y = 0; y <= texsize.y; y+= SIZE_STEPS.y) 
		{
			for(int x = 0; x <= texsize.x; x+= SIZE_STEPS.x) 
			{
				color = tex2Dfetch(BackBufferCLAMP, uint4(x, y,0,0) ).rgb;
				
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
	#endif
	float2 Lum(float2 texcoord)
	{ 
		return saturate(tex2Dlod(SamplerLumN,float4(texcoord,0,11)).xy);//Average Depth Brightnes Texture Sample
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
	#if (RHW || NCW || NPW || NFM || PEW || DSW || OSW || DAA || NDW || WPW || FOV || EDW)
		#define Text_Timer 30000
	#else
		#define Text_Timer 25000
	#endif
	
	bool Helper_Fuction()
	{
		return tex2D(SamplerInfo,float2(0.911,0.968)).x;
	}

	float Info_Fuction()
	{
		return timer <= Text_Timer || Text_Info;
	}	

	#if D_Frame || DFW
	float4 CurrentFrame(in float4 position : SV_Position, in float2 texcoords : TEXCOORD) : SV_Target
	{
		if(Custom_Sidebars == 0)
			return tex2Dlod(BackBufferMIRROR,float4(texcoords,0,0));
		else if(Custom_Sidebars == 1)
			return tex2Dlod(BackBufferBORDER,float4(texcoords,0,0));
		else
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
			return tex2D(SamplerzBufferN_P,texcoords).xxxx;
	}
	#else
	float4 CSB(float2 texcoords)
	{
		#if BC_SPACE == 1
		if(Custom_Sidebars == 0 && Depth_Map_View == 0)
			return NormalizeScRGB(tex2Dlod(BackBufferMIRROR,float4(texcoords,0,0)));
		else if(Custom_Sidebars == 1 && Depth_Map_View == 0)
			return NormalizeScRGB(tex2Dlod(BackBufferBORDER,float4(texcoords,0,0)));
		else if(Custom_Sidebars == 2 && Depth_Map_View == 0)
			return NormalizeScRGB(tex2Dlod(BackBufferCLAMP,float4(texcoords,0,0)));
		else
			return NormalizeScRGB(tex2Dlod(SamplerzBufferN_P,float4(texcoords,0,0)).x);
		#else
		if(Custom_Sidebars == 0 && Depth_Map_View == 0)
			return tex2Dlod(BackBufferMIRROR,float4(texcoords,0,0));
		else if(Custom_Sidebars == 1 && Depth_Map_View == 0)
			return tex2Dlod(BackBufferBORDER,float4(texcoords,0,0));
		else if(Custom_Sidebars == 2 && Depth_Map_View == 0)
			return tex2Dlod(BackBufferCLAMP,float4(texcoords,0,0));
		else
			return tex2Dlod(SamplerzBufferN_P,float4(texcoords,0,0)).x;
		#endif

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
		return tex2Dlod(SamplerDMN,float4(TCLocations * float2(0.5,1),0, TCLocations.x < 1.0 ? MipLevel : 0)).w;
	}
	
	bool LBDetection()//Active RGB Detection
	{   float2 Letter_Box_Reposition = float2(0.1,0.5);
		if (LBR == 1) 
			Letter_Box_Reposition = float2(0.250,0.875);
		if (LBR == 2) 
			Letter_Box_Reposition = float2(0.5,0.625);
			
		float2 Letter_Box_Elevation = LBE ? LBE == 2 ? float2(0.035,0.965) : float2(0.045,0.955) : float2(0.09,0.91);    
		float MipLevel = 5,Center = SLLTresh(float2(0.5,0.5), 7) > 0, Top_Left = LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.x,Letter_Box_Elevation.x), MipLevel));
		if ( LetterBox_Masking == 2 || LB_Correction == 2 || LBC == 2 || LBM == 2 || SMP == 2)//Left_Center | Right_Center | Center
			return LBSensitivity(SLLTresh(float2(0.1,0.5), MipLevel)) && LBSensitivity(SLLTresh(float2(0.9,0.5), MipLevel)) && Center; //Vert
		else       //Top | Bottom | Center
			return Top_Left && LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.y,Letter_Box_Elevation.y), MipLevel)) && Center; //Hoz
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
		return smoothstep(0,1,tex2Dlod(SamplerzBufferN_P,float4(TC,0,0)).y);
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
	
	#if MMD || MDD || SMD
	float3 C_Tresh(float2 TCLocations)//Color Tresh
	{ 
		return tex2Dlod(BackBufferCLAMP,float4(TCLocations,0, 0)).rgb;
	}
	
	bool Check_Color(float2 Pos_IN, float C_Value)
	{	float3 RGB_IN = C_Tresh(Pos_IN);
		return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) == C_Value;
	}
	#endif
	
	#if MDD || SMD
	int Color_Likelyhood(float2 Pos_IN, float C_Value, int Switcher)
	{	float3 RGB_IN = C_Tresh(Pos_IN);
		return FN_Value(RGB_IN.r) + FN_Value(RGB_IN.g) + FN_Value(RGB_IN.b) == C_Value ? Switcher : 0;
	}
		#if MDD	
		float Menu_Size()//Active RGB Detection
		{ 
	
			float2 Pos_A = DN_X.xy, Pos_B = DN_X.zw, Pos_C = DN_Y.xy,
				   Pos_D = DN_Y.zw, Pos_E = DN_Z.xy, Pos_F = DN_Z.zw;
			float Menu_Size_Selection[5] = { 0.0, DN_W.x, DN_W.y, DN_W.z, DN_W.w };
			float4 MT_Values = DJ_Y;
			float3 SMT_Values = DJ_Z;
	
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
	
			#if SMD //Simple Menu Detection	
			float Simple_Menu_A()//Active RGB Detection
			{ 
				float2 Pos_A = DW_X.xy, Pos_B = DW_X.zw, Pos_C = DW_Y.xy;
				float4 ST_Values = DW_Z;
		
				//Wild Card Always On
				float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);

				float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
				
				float Menu_Detection = Menu_X &&                          //X & W is wiled Card. If MAC is enabled this is Disabled.
									   Check_Color(Pos_B, ST_Values.y) && //Y
									   Menu_Z;                            //Z & W is wiled Card.
		
				return Menu_Detection > 0;
			}
				#if SMD == 2
				float Simple_Menu_B()//Active RGB Detection
				{ 
					float2 Pos_A = DT_X.xy, Pos_B = DT_X.zw, Pos_C = DT_Y.xy;
					float4 ST_Values = DW_W;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card. If MAC is enabled this is Disabled.
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					return Menu_Detection > 0;
				}
				#endif		
			#endif
	#endif
	
	
#if MMD //Simple Menu Masking
		
		#define abs_Leniency abs(MML)
		#define MM_Leniency MML < 0 ? float2(30.0,0.0) : float2(28.0,2.0)
		
		bool Check_Color_MinMax_A(float2 Pos_IN)
		{   float3 RGB_IN = C_Tresh(Pos_IN);
			float2 Leniency_Switch = abs_Leniency >= 1 ? MM_Leniency : float2(29.0,1.0);
			if ( MMS >= 1)
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) >= Leniency_Switch.x;
			else
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) <= Leniency_Switch.y;
		}
		
		float4 Simple_Menu_Detection_A()//Active RGB Detection
		{ 
			return float4( Check_Color(DO_X.xy, DO_W.x) && Check_Color_MinMax_A(DO_X.zw) && Check_Color( DO_Y.xy, DO_W.y),
						   Check_Color(DO_Y.zw, DO_W.z) && Check_Color_MinMax_A(DO_Z.xy) && Check_Color( DO_Z.zw, DO_W.w),
						   Check_Color(DP_X.xy, DP_W.x) && Check_Color_MinMax_A(DP_X.zw) && Check_Color( DP_Y.xy, DP_W.y),
						   Check_Color(DP_Y.zw, DP_W.z) && Check_Color_MinMax_A(DP_Z.xy) && Check_Color( DP_Z.zw, DP_W.w) );
		}
		
		#if MMD >= 2
		bool Check_Color_MinMax_B(float2 Pos_IN)
		{   float3 RGB_IN = C_Tresh(Pos_IN);
			float2 Leniency_Switch = abs_Leniency >= 2 ? MM_Leniency : float2(29.0,1.0);
			if ( MMS >= 2)
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) >= Leniency_Switch.x;
			else
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) <= Leniency_Switch.y;
		}
		
		float4 Simple_Menu_Detection_B()//Active RGB Detection Extended
		{ 
			return float4( Check_Color(DQ_X.xy, DQ_W.x) && Check_Color_MinMax_B(DQ_X.zw) && Check_Color( DQ_Y.xy, DQ_W.y),
						   Check_Color(DQ_Y.zw, DQ_W.z) && Check_Color_MinMax_B(DQ_Z.xy) && Check_Color( DQ_Z.zw, DQ_W.w),
					   	Check_Color(DR_X.xy, DR_W.x) && Check_Color_MinMax_B(DR_X.zw) && Check_Color( DR_Y.xy, DR_W.y),
					   	Check_Color(DR_Y.zw, DR_W.z) && Check_Color_MinMax_B(DR_Z.xy) && Check_Color( DR_Z.zw, DR_W.w) );
		}
		#endif
		
		#if MMD >= 3
		bool Check_Color_MinMax_C(float2 Pos_IN)
		{   float3 RGB_IN = C_Tresh(Pos_IN);
			float2 Leniency_Switch = abs_Leniency >= 3 ? MM_Leniency : float2(29.0,1.0);
			if ( MMS >= 3)
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) >= Leniency_Switch.x;
			else
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) <= Leniency_Switch.y;
		}
		
		float4 Simple_Menu_Detection_C()//Active RGB Detection Extended
		{ 
			return float4( Check_Color(DU_X.xy, DU_W.x) && Check_Color_MinMax_C(DU_X.zw) && Check_Color( DU_Y.xy, DU_W.y),
						   Check_Color(DU_Y.zw, DU_W.z) && Check_Color_MinMax_C(DU_Z.xy) && Check_Color( DU_Z.zw, DU_W.w),
					   	Check_Color(DV_X.xy, DV_W.x) && Check_Color_MinMax_C(DV_X.zw) && Check_Color( DV_Y.xy, DV_W.y),
					   	Check_Color(DV_Y.zw, DV_W.z) && Check_Color_MinMax_C(DV_Z.xy) && Check_Color( DV_Z.zw, DV_W.w) );
		}
		#endif

		#if MMD >= 4
		bool Check_Color_MinMax_D(float2 Pos_IN)
		{   float3 RGB_IN = C_Tresh(Pos_IN);
			float2 Leniency_Switch = abs_Leniency >= 4 ? MM_Leniency : float2(29.0,1.0);
			if ( MMS >= 4)
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) >= Leniency_Switch.x;
			else
				return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) <= Leniency_Switch.y;
		}
		
		float4 Simple_Menu_Detection_D()//Active RGB Detection Extended
		{ 
			return float4( Check_Color(DX_X.xy, DX_W.x) && Check_Color_MinMax_D(DX_X.zw) && Check_Color( DX_Y.xy, DX_W.y),
						   Check_Color(DX_Y.zw, DX_W.z) && Check_Color_MinMax_D(DX_Z.xy) && Check_Color( DX_Z.zw, DX_W.w),
					   	Check_Color(DY_X.xy, DY_W.x) && Check_Color_MinMax_D(DY_X.zw) && Check_Color( DY_Y.xy, DY_W.y),
					   	Check_Color(DY_Y.zw, DY_W.z) && Check_Color_MinMax_D(DY_Z.xy) && Check_Color( DY_Z.zw, DY_W.w) );
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
/*	
	#define FLT_EPSILON  1.192092896e-07 // smallest such that Value + FLT_EPSILON != Value		
	float DepthEdge(float Mod_Depth, float Depth, float2 texcoords, float Adjust_Value, float Masker,float LR_Masker)
	{   Adjust_Value -= FLT_EPSILON;
		float2 center = float2(0.5,texcoords.y); // Direction of effect.   
		float BaseVal = 1.0,
			  Dist  = distance( center, texcoords ) * 2.0, 
			  EdgeMask = saturate((BaseVal-Dist) / (BaseVal-Adjust_Value)); 
			  Masker = lerp(LR_Masker,max(Masker,LR_Masker),EdgeMask);
	    return lerp(Depth,Mod_Depth, lerp(EdgeMask,Masker,0.5) );    
	}
*/		
	float DepthEdge(float Mod_Depth, float Depth, float2 texcoords, float Adjust_Value )
	{   Adjust_Value -= FLT_EPSILON;
		float2 center = float2(0.5,texcoords.y); // Direction of effect.   
		float BaseVal = 1.0,
			  Dist  = distance( center, texcoords ) * 2.0, 
			  EdgeMask = saturate((BaseVal-Dist) / (BaseVal-Adjust_Value)),
			  Set_Weapon_Scale_Near = -min(0.5,Weapon_Depth_Edge.y);//So it don't hang the game. 
		float Scale_Depth = 1+(Weapon_Depth_Edge.z*4);
			  Mod_Depth = (Mod_Depth - Set_Weapon_Scale_Near) / (1.0 + Set_Weapon_Scale_Near);
		float Near_Mod_Depth =  Scale_Depth * Mod_Depth;
	    return lerp(Depth, lerp(Mod_Depth,Near_Mod_Depth + Weapon_Depth_Edge.w,saturate((1-Depth)*0.125)), EdgeMask );   
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

	float3 regamma(float3 c) { return float3(pow(abs(c.r),1.0/2.2), pow(abs(c.g),1.0/2.2), pow(abs(c.b),1.0/2.2));} 

	float4 MouseCursor(float2 texcoord , float2 pos )
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
		#if Color_Correction_Mode || Enable_Deband_Mode
			if(Toggle_Deband)
			{
				//Code I asked Marty McFly | Pascal for and he let me have.
				const float SEARCH_RADIUS = 1, Depth_Sample = tex2Dlod(SamplerzBufferN_P,float4(texcoord,0,0)).x < 0.98;
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
		#endif			
		#if Color_Correction_Mode
			float3 minRGB = tex2D(samplerMinMaxRGB, float2(0.25,0.0)).rgb;
			float3 maxRGB = tex2D(samplerMinMaxRGB, float2(0.75,0.0)).rgb;
			if(Color_Correction)
			Out.rgb = saturate( (Out.rgb - minRGB) / (maxRGB-minRGB) );
		#endif	
			
			Out = Cursor ? Color.rgb : Out.rgb;
		#if Inficolor_3D_Emulator
			float3 ReGamma = regamma(Out.rgb), blend_RGB = float3(dot(ReGamma, float3(1,-1,-1)), dot(ReGamma, float3(-1,1,-1)),dot(ReGamma, float3(-1,-1,1))) ;
	    	Out.r *= lerp(1,lerp(1, 0.5, smoothstep(-0.250, 0.0, blend_RGB.r)),Inficolor_Reduce_RGB.x);
	    	Out.g *= lerp(1,lerp(1, 0.5, smoothstep(-0.375, 0.0, blend_RGB.g)),Inficolor_Reduce_RGB.y);
	    	Out.b *= lerp(1,lerp(1, 0.5, smoothstep(-0.500, 0.0, blend_RGB.b)),Inficolor_Reduce_RGB.z);
	    #endif
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
	{	float LBDetect = tex2Dlod(SamplerLumN,float4(0.5,0.5,0,0)).x;
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
	
	float Depth(float2 texcoord)
	{
		float RangeBoost = 1.5;
		if( Range_Boost == 3)
			RangeBoost = 2.0;
		if( Range_Boost == 4)
			RangeBoost = 3.0;
		if( Range_Boost == 5)
			RangeBoost = 4.0;
        //Conversions to linear space.....
		float zBuffer = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x, Far = 1.0, Near_A = 0.125/DMA(), Near_B = 0.125/(DMA()*RangeBoost); //Near & Far Adjustment
		float2 Two_Ch_zBuffer, Store_zBuffer = float2( zBuffer, 1.0 - zBuffer );
		float4 C = float4( Far / Near_A, 1.0 - Far / Near_A, Far / Near_B, 1.0 - Far / Near_B);
		float2 Z = Offset < 0 ? min( 1.0, zBuffer * ( 1.0 + abs(Offset) ) ) : Store_zBuffer;
		//May add this later need to check emulators.
		//if (Range_Boost == 2)
		//	Store_zBuffer = Z;
			
		if(Offset > 0 || Offset < 0)
			Z = Offset < 0 ? float2( Z.x, 1.0 - Z.y ) : min( 1.0, float2( Z.x * (1.0 + Offset) , Z.y / (1.0 - Offset) ) );
		
		float2 C_Switch = Range_Boost >= 2 ? C.zw : C.xy;
			
		if (Depth_Map == 0) //DM0 Normal
			Two_Ch_zBuffer = rcp(float2(Z.x,Store_zBuffer.x) * float2(C_Switch.y,C.y) + float2(C_Switch.x,C.x));//MAD - RCP
		else if (Depth_Map == 1) //DM1 Reverse
			Two_Ch_zBuffer = rcp(float2(Z.y,Store_zBuffer.y) * float2(C_Switch.y,C.y) + float2(C_Switch.x,C.x));//MAD - RCP
		
		if(Range_Boost)
			zBuffer = lerp(Two_Ch_zBuffer.y,Two_Ch_zBuffer.x,saturate(Two_Ch_zBuffer.y));
		else
			zBuffer = Two_Ch_zBuffer.x;
		
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
	//3x2 and 2x3 not Emu on older ReShade versions. I had to use 3x3. Old Values for 3x2
	float3x3 PrepDepth(float2 texcoord)
	{   int Flip_Depth = Flip_Opengl_Depth ? !Depth_Map_Flip : Depth_Map_Flip;
	
		if (Flip_Depth)
			texcoord.y =  1 - texcoord.y;
		
		//Texture Zoom & Aspect Ratio//
		//float X = TEST.x;
		//float Y = TEST.y * TEST.x * 2;
		//float midW = (X - 1)*(BUFFER_WIDTH*0.5)*pix.x;	
		//float midH = (Y - 1)*(BUFFER_HEIGHT*0.5)*pix.y;	
					
		//texcoord = float2((texcoord.x*X)-midW,(texcoord.y*Y)-midH);	
		
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
		
		float Weapon_Masker = lerp(0.0,WD,CutOFFCal);
	
		R = DM.x; //Mix Depth
		G = DM.y > saturate(smoothstep(0,2.5,DM.w)); //Weapon Mask
		B = DM.z; //Weapon Hand
		A = ZPD_Boundary >= 4 ? max( G, R) : R; //Grid Depth
			
		return float3x3( saturate(float3(R, G, B)), 	                                                      			//[0][0] = R | [0][1] = G | [0][2] = B
						 saturate(float3(A, Depth( SDT == 1 || SD_Trigger == 1 ? texcoord : TC_SP(texcoord).xy).x, DM.w)),//[1][0] = A | [1][1] = D | [1][2] = DM
								  float3(Weapon_Masker > saturate(smoothstep(0,2.5,DM.w)),0,0) );                         //[2][0] = 0 | [2][1] = 0 | [2][2] = 0
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
	{ float TCoRF[1], Trigger_Fade, AA = Fade_Time_Adjust, PStoredfade = tex2D(SamplerLumN,float2(0,0.083)).z;
		if(World_n_Fade_Reduction_Power.y == 0)
			AA *= 0.75;
		if(World_n_Fade_Reduction_Power.y == 1)
			AA *= 1.0;
		if(World_n_Fade_Reduction_Power.y == 3)
			AA *= 1.25;
		if(World_n_Fade_Reduction_Power.y == 4)
			AA *= 1.375;
		if(World_n_Fade_Reduction_Power.y == 5)
			AA *= 1.5;
		if(World_n_Fade_Reduction_Power.y == 6)
			AA *= 1.625;
		if(World_n_Fade_Reduction_Power.y == 7)
			AA *= 1.75;
		if(World_n_Fade_Reduction_Power.y == 8)//instant
			AA *= 2.0;
		//Fade in toggle.
		if(FPSDFIO == 1 )//|| FPSDFIO == 3 )
			Trigger_Fade = Trigger_Fade_A;
		else if(FPSDFIO == 2)// || FPSDFIO == 4 )
			Trigger_Fade = Trigger_Fade_B;
	
		return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/((1-AA)*1000))); ///exp2 would be even slower
	}
	
	float Auto_Adjust_Cal(float Val)
	{
		return (1-(Val*2.))*1000;
	}
	
	float3x3 Fade(float2 texcoord)
	{   //Check Depth
		float CD, Detect, Detect_Out_of_Range = -1;//Done to not trigger FTM if set to 0
		if(ZPD_Boundary > 0)
		{
			#if LBM || LetterBox_Masking
			const float2 LB_Dir = float2(0.150,0.850);
			#else
			const float2 LB_Dir = float2(0.125,0.875);
			#endif   
			//Normal A & B for both	
			const float CDArray_X_A0[7] = { LB_Dir.x, 0.25, 0.375, 0.5, 0.625, 0.75, LB_Dir.y}, 
						CDArray_X_B0[7] = { 0.25, 0.375, 0.4375, 0.5, 0.5625, 0.625, 0.75}, 
						CDArray_X_C0[9] = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9};
			float Bottom_Edge = ZPD_Boundary == 6 ? 0.95 : 0.9;
			#if LBC || LB_Correction
			float LetterBox_Detection_A = LBDetection() ? 0.85 : Bottom_Edge;
			float LetterBox_Detection_B = LBDetection() ? 0.85 : 0.875;
			float4 Shift_UP = Shift_Detectors_Up == 1 ? float4(0.375, 0.5, 0.6875, LetterBox_Detection_A) : float4(0.5, 0.65, 0.775, LetterBox_Detection_A);
			float CDArray_Y_A0[5] = { 0.25, Shift_UP.x, Shift_UP.y, Shift_UP.z, Shift_UP.w}, 
			      CDArray_Y_B0[5] = { 0.25, 0.375, 0.5, 0.6875, LetterBox_Detection_B},
				  CDArray_Y_C0[4] = { 0.25, 0.5, 0.75, LetterBox_Detection_B};
			#else	
			float4 Shift_UP = Shift_Detectors_Up == 1 ? float4(0.375, 0.5, 0.6875, Bottom_Edge) : float4(0.5, 0.65, 0.775, Bottom_Edge);
			float CDArray_Y_A0[5] = { 0.25, Shift_UP.x, Shift_UP.y, Shift_UP.z, Shift_UP.w}, 
			      CDArray_Y_B0[5] = { 0.25, 0.375, 0.5, 0.6875, 0.875},
				  CDArray_Y_C0[4] = { 0.25, 0.5, 0.75, 0.875};
			#endif	  
			float Shift_Values = 0.025;
			if( ZPD_Boundary == 1 || ZPD_Boundary == 4 || ZPD_Boundary == 6 || ZPD_Boundary == 7)
				Shift_Values = 0.031;	
			//Screen Space Detector 7x6 Grid from between 0 to 1 and ZPD Detection becomes stronger as it gets closer to the Center.
			float3 XY = floor(texcoord.xyx * texsize.xyx * pix.xyx * float3(7,7,9));
			float2 GridXY; int2 iXY = ( ZPD_Boundary == 3 ? int2( 9, 4) : int2( 7, 5) );//was 12/4 and 7/7 This reduction saves 0.1 ms and should show no diff to the user.
			[loop]                                                                     //I was thinking the lowest I can go would be 9/4 along with 7/5
			for( int iX = 0 ; iX < iXY.x; iX++ )                                         //7 * 7 = 49 | 12 * 4 = 48 | 7 * 6 = 42 | 9 * 4 = 36 | 7 * 5 = 35
			{   [unroll]
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
					//We shift the lower half here to have a better spread.
					if(ZPD_Boundary != 4)
						GridXY.x += texcoord.y < 0.6 ? 0.0 : fmod(XY.y,2) ? Shift_Values : -Shift_Values;

						GridXY.y += fmod(XY.x,2) ? 0.0 : 0.05;

					float ZPD_I = ZPD_Separation.x;
					// tex2Dlod(SamplerDMN,float4(GridXY,0,2)).x; // Does improve performance I tought it did.					
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
						if ( CD < -ZPD_Boundary_n_Cutoff.y && Detect_Out_of_Range <= 1)
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
		uint Sat_D_O_R = Detect_Out_of_Range == Fast_Trigger_Mode;
		float ZPD_BnF = Auto_Adjust_Cal(Sat_D_O_R ? 0.5-FLT_EPSILON : ZPD_Boundary_n_Fade.y);		
		float Trigger_Fade_A = Detect, Trigger_Fade_B = Detect_Out_of_Range >= 1, Trigger_Fade_C = Detect_Out_of_Range >= 2, Trigger_Fade_D = Detect_Out_of_Range >= 3, Trigger_Fade_E = Detect_Out_of_Range >= 4, 
			  PStoredfade_A = tex2D(SamplerLumN,float2(0, 0.250)).z, PStoredfade_B = tex2D(SamplerLumN,float2(0, 0.416)).z, PStoredfade_C = tex2D(SamplerLumN,float2(1, 0.416)).z, PStoredfade_D = tex2D(SamplerLumN,float2(1, 0.250)).z, PStoredfade_E = tex2D(SamplerLumN,float2(1, 0.583)).z;
		//Fade in toggle.
		float CallFT = 1.0 - exp(-frametime/ZPD_BnF);//exp2 would be even slower
		return float3x3( float3( PStoredfade_A + (Trigger_Fade_A - PStoredfade_A) * CallFT,
								 PStoredfade_B + (Trigger_Fade_B - PStoredfade_B) * CallFT, 
								 PStoredfade_C + (Trigger_Fade_C - PStoredfade_C) * CallFT ),
						 float3( PStoredfade_D + (Trigger_Fade_D - PStoredfade_D) * CallFT,
								 PStoredfade_E + (Trigger_Fade_E - PStoredfade_E) * CallFT,
								 saturate(Detect_Out_of_Range * 0.25)                        ),
						 float3(0,0,0)                                                       ); 
	}
	#define FadeSpeed_AW 0.375
	float AltWeapon_Fade()
	{
		float  ExAd = (1-(FadeSpeed_AW * 2.0))*1000, Current =  min(0.75f,smoothstep(0,0.25f,PrepDepth(0.5f)[0][0])), Past = tex2D(SamplerLumN,float2(0,0.750)).z;
		return Past + (Current - Past) * (1.0 - exp(-frametime/ExAd));
	}
	#define FadeSpeed_AF 0.4375
	float Weapon_ZPD_Fade(float Weapon_Con)
	{
		float  ExAd = (1-(FadeSpeed_AF * 2.0))*1000, Current =  Weapon_Con, Past = tex2D(SamplerLumN,float2(0,0.916)).z;
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
								  float4 (FP_IO_Pos().x,FP_IO_Pos().y,0.0,0.0), //Eye Tracker     7
								  float4 (FP_IO_Pos().x,FP_IO_Pos().y,0.0,0.0)};//Eye Tracker Alt 8
			
		float Overshoot = 1 + saturate(Inficolor_OverShoot), 
			  AB_EX = lerp(Depth(XYArray[Auto_Balance_Ex].xy) , Depth(XYArray[Auto_Balance_Ex].zw), Auto_Balance_Ex > 3 && Auto_Balance_Ex < 7 ? 0.5 : 0 );
		return float2(Auto_Balance_Ex > 0 ? Inficolor_3D_Emulator ? Overshoot * saturate(AB_EX * 2) : saturate(lerp(AB_EX * 2 , Lum(float2(0.5,0.5)).y , 0.25) ) : 1,
					  saturate(lerp( Depth( float2(0.5,0.5) ) * 2 , Lum(float2(0.5,0.5)).y , 0.25) ) ) ;
	}
	
	float4 DepthMap(in float4 position : SV_Position,in float2 texcoord : TEXCOORD) : SV_Target
	{
		float4 DM = float4(PrepDepth(texcoord)[0][0],PrepDepth(texcoord)[0][1],PrepDepth(texcoord)[0][2],PrepDepth(texcoord)[1][1]);
		float R = DM.x, G = DM.y, B = DM.z, Auto_Scale = 1;
		float SP_Min = Set_Pop_Min().y, Select_Min_LvL_Trigger;float3 Level_Control = DS_X;
		//Auto Scale
		if(WZPD_and_WND.z > 0)
			Auto_Scale = lerp(lerp(1.0,0.5,saturate(WZPD_and_WND.z * 2)),1.0,lerp(Auto_Balance_Selection().y , smoothstep(0,0.5,tex2D(SamplerLumN,float2(0,0.750)).z), 0.5));

		//Fade Storage
		#if DX9_Toggle
		float3x3 Fade_Pass = Fade(texcoord); //[0][0] = F | [0][1] = F | [0][2] = F
						 					 //[1][0] = F | [1][1] = N | [1][2] = 0
											 //[2][0] = 0 | [2][1] = 0 | [2][2] = 0
		float2 Min_Trim = float2(SP_Min,Inficolor_3D_Emulator ? WZPD_and_WND.w : WZPD_and_WND.w) * Auto_Scale;
		#else
		float3 Fade_Pass_A = float3( tex2D(SamplerzBuffer_BlurN,float2(0,0.083)).y,
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.250)).y,
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.416)).y );
		float3 Fade_Pass_B = float3( tex2D(SamplerzBuffer_BlurN,float2(0,0.583)).y,
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.750)).y,
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.916)).y );

			float Scale_Auto_Switch = Level_Control.y == 0 ? Fade_Pass_A.x : Level_Control.z == 2 ? Fade_Pass_B.y * 4 >= Level_Control.y : Fade_Pass_B.y * 4 == Level_Control.y;
			
			if(Level_Control.z >= 1)
				Select_Min_LvL_Trigger = Scale_Auto_Switch;
				
			SP_Min = lerp(SP_Min,Level_Control.x, saturate(Select_Min_LvL_Trigger) );
			
			float2 Min_Trim = float2(SP_Min, Inficolor_3D_Emulator ? WZPD_and_WND.w : WZPD_and_WND.w) * Auto_Scale;
		#endif
						 
		if(Inficolor_3D_Emulator && Inficolor_Near_Reduction)
			Min_Trim = float2((Min_Trim.x * 2 + Min_Trim.x) * 0.5, min( 0.3, (Min_Trim.y * 2.5 + Min_Trim.y) * 0.5) );
			
		float ScaleND = saturate(lerp(R,1.0f,smoothstep(min(-Min_Trim.x,0),1.0f,R)));
		float Edge_Adj = 0.5;
		
		if (Min_Trim.x > 0)
			R = saturate(lerp(ScaleND,R,smoothstep(0,Min_Trim.y,ScaleND)));
			//R = DepthEdge( R, DM.x, texcoord, 0.550, PrepDepth(texcoord)[2][0], tex2Dlod(SamplerzBuffer_BlurN,float4(texcoord,0,6)).y);	
		if ( Weapon_Depth_Edge.x > 0)//1.0 needs to be adjusted when doing far scaling
			R = lerp(DepthEdge(R, DM.x, texcoord, 1-Weapon_Depth_Edge.x),DM.x,smoothstep(0,1.0,DM.x));
		
		if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TL
			R = Fade_in_out(texcoord);
		#if DX9_Toggle
			if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR
				R = Fade_Pass[0][0];
			if(   texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BL
				R = Fade_Pass[0][1];
			if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
				R = Fade_Pass[0][2];

			if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
				G = Fade_Pass[1][0];
			if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TL
				G = Fade_Pass[1][2];
			if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR
				G = Fade_Pass[1][1];
		#else
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
		#endif	
		//Luma Map
		float3 Color = texcoord.x < 0.5 ? tex2D(BackBufferCLAMP,texcoord * float2(2,1) ).rgb : step(0.9,tex2D(BackBufferCLAMP,texcoord * float2(2,1) - float2(1,0) ).rgb);
			   Color.x = max(Color.r, max(Color.g, Color.b)); 
		
		return saturate(float4(R,G,B,Color.x));
	}
	
	float AutoDepthRange(float d, float2 texcoord )
	{ float LumAdjust_ADR = smoothstep(-0.0175,min(0.5,Auto_Depth_Adjust),Lum(texcoord).y);
	    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
	}
		
	float3 Conv(float2 MD_WHD,float2 texcoord)
	{	float WConverge = 0.030, D = MD_WHD.x, Z = ZPD_Separation.x, WZP = 0.5, ZP = 0.5, W_Convergence = Inficolor_Near_Reduction ? WConverge * 0.8 : WConverge, WZPDB, Distance_From_Bottom = lerp(0.9375,1.0,saturate(WFB)), ZPD_Boundary = ZPD_Boundary_n_Fade.x, Store_WC, Set_Max_Depth = 1.0;
	    //Screen Space Detector.
		if (abs(Weapon_ZPD_Boundary.x) > 0)
		{   float WArray[6] = { 0.4, 0.5, 0.6, 0.7, 0.8, 0.9};
			[unroll] //only really only need to check one point just above the center bottom and to the right.
			for( int i = 0 ; i < 6; i++ )
			{
				WZPDB  = 1 - WConverge / tex2Dlod(SamplerDMN, float4(float2(WArray[i],Distance_From_Bottom), 0, 0)).z;
					
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
		//MD_WHD.y is Weapon Hand Depth
		W_Convergence = 1 - tex2D(SamplerLumN,float2(0,0.916)).z / MD_WHD.y;// 1-W_Convergence/D
		float WD = MD_WHD.y; //Needed to seperate Depth for the  Weapon Hand. It was causing problems with Auto Depth Range below.
	
			if (Auto_Depth_Adjust > 0)
				D = AutoDepthRange(D,texcoord);

				ZP = saturate( ZPD_Balance * max(0.5, Auto_Balance_Selection().x));
				
			float4 Set_Adjustments = RE_Set_Adjustments();float2 SC_Adjutment = DT_W;
			float DOoR_A = smoothstep(0,1,tex2D(SamplerLumN,float2(0, 0.250)).z), //ZPD_Boundary
				  DOoR_B = smoothstep(0,1,tex2D(SamplerLumN,float2(0, 0.416)).z),   //Set_Adjustments X
				  DOoR_C = smoothstep(0,1,tex2D(SamplerLumN,float2(1, 0.416)).z),     //Set_Adjustments Y
				  DOoR_D = smoothstep(0,1,tex2D(SamplerLumN,float2(1, 0.250)).z),       //Set_Adjustments Z
				  DOoR_E = smoothstep(0,1,tex2D(SamplerLumN,float2(1, 0.583)).z),         //Set_Adjustments W
				  SetLvL = smoothstep(0,1,tex2D(SamplerLumN,float2(1, 0.750)).z);           //Set_Level			
			if(SC_Adjutment.y > 0.0)
				W_Convergence *= lerp(SC_Adjutment.x , 1.0,MD_WHD.x > SC_Adjutment.y);
			//The Switch Array B 0.750 that switches the OIL value in RE_Set.
			//Z is a LvL between 0 - 3
			//Y is current value of ZPD Value	  
			//float2 Detection_Switch_Amount = RE_Set(tex2D(SamplerLumN,float2(1,0.750)).z).yz;//Y = X and Z = Y																   
			float Detection_Switch_Amount = RE_Set(SetLvL).y;//Y = X																   

			if(RE_Set(0).x)
			{
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
			
			Z *= lerp( 1, DOoR_E, DOoR_A);
			
			float Convergence = 1 - Z / D;
			if (ZPD_Separation.x == 0)
				ZP = 1;
	
			ZP = min(ZP, Auto_Balance_Clamp);
	
	#if Inficolor_3D_Emulator
		Set_Max_Depth = Inficolor_Max_Depth;
	#endif
		D = min(saturate(Set_Max_Depth),D);
	   return float3( lerp(Convergence,lerp(D,Convergence,saturate(Convergence)), ZP), lerp(W_Convergence,WD,WZP), Store_WC);
	}
	
	float3 DB_Comb(float2 texcoord)
	{
		// X = Mix Depth | Y = Weapon Mask | Z = Weapon Hand | W = Normal Depth
		float4 DM = float4(tex2Dlod(SamplerDMN,float4(texcoord,0,0)).xyz,PrepDepth( SDT == 1 || SD_Trigger == 1 ? TC_SP(texcoord).xy : texcoord )[1][1]);
		//Hide Temporal passthrough
		if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if(texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
			
		if (WP == 0)
			DM.y = 0;
	
		float FadeIO = Focus_Reduction_Type == 0 ? 1 : smoothstep(0,1,1-Fade_in_out(texcoord).x), FD_Adjust = 0.050;	
	
		if( Weapon_Reduction_n_Power.x == 1)
			FD_Adjust = 0.075;
		if( Weapon_Reduction_n_Power.x == 2)
			FD_Adjust = 0.100;
		if( Weapon_Reduction_n_Power.x == 3)
			FD_Adjust = 0.125;
		if( Weapon_Reduction_n_Power.x == 4)
			FD_Adjust = 0.150;
		if( Weapon_Reduction_n_Power.x == 5)
			FD_Adjust = 0.175;
		if( Weapon_Reduction_n_Power.x == 6)
			FD_Adjust = 0.200;
		if( Weapon_Reduction_n_Power.x == 7)
			FD_Adjust = 0.225;
		if( Weapon_Reduction_n_Power.x == 8)
			FD_Adjust = 0.250;
		//Handle Convergence Here
		float3 HandleConvergence = Conv(DM.xz,texcoord).xyz;
			   HandleConvergence.y *= WA_XYZW().w;
			   HandleConvergence.y = lerp(HandleConvergence.y + FD_Adjust, HandleConvergence.y, FadeIO);
		DM.y = lerp( HandleConvergence.x, HandleConvergence.y, DM.y);
	
		float Edge_Adj = saturate(lerp(0.5,1.0,Edge_Adjust));
		
			DM = lerp(lerp(EdgeMask( DM, texcoord, 0.955 ),DM,  Edge_Adj), DM, saturate(1-DM.y) );	
			
		if (Depth_Detection == 1)
		{
			if (!DepthCheck)
				DM = 0.0625;
		}
	
		#if MDD	
			float MSDT = Menu_Size(), Direction = texcoord.x < MSDT;
	
			#if (MDD  == 2 )		
				Direction = texcoord.x > MSDT;
			#elif (MDD  == 3 )		
				Direction = texcoord.y < MSDT;
			#elif (MDD  == 4 )
				Direction = texcoord.y > MSDT;
			#endif
			if( MSDT > 0)
				DM = Direction ? 0.0625 : DM;
		#endif	
		
		#if MMD		
			if( Simple_Menu_Detection_A().x == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_A().y == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_A().z == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_A().w == 1)
				DM = 0.0625;
			#if MMD >= 2
			if( Simple_Menu_Detection_B().x == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_B().y == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_B().z == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_B().w == 1)
				DM = 0.0625;
			#endif
			#if MMD >= 3
			if( Simple_Menu_Detection_C().x == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_C().y == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_C().z == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_C().w == 1)
				DM = 0.0625;
			#endif
			#if MMD >= 4
			if( Simple_Menu_Detection_D().x == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_D().y == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_D().z == 1)
				DM = 0.0625;
			if( Simple_Menu_Detection_D().w == 1)
				DM = 0.0625;
			#endif
		#endif	
		
		#if SMD	
			DM = Simple_Menu_A() ? 0.0625 : DM;
			#if SMD == 2	
				DM = Simple_Menu_B() ? 0.0625 : DM;
			#endif
		#endif
		
		if (Cancel_Depth)
			DM = 0.0625;
	
		#if UI_MASK
			DM.y = lerp(DM.y,0,step(1.0-HUD_Mask(texcoord),0.5));
		#endif
	
		#if LBM || LetterBox_Masking
			float LB_Dir = LetterBox_Masking == 2 || LBM == 2 ? texcoord.x : texcoord.y;
			float LB_Detection = tex2D(SamplerLumN,float2(0.5,0.5)).x,LB_Masked = LB_Dir > DI_Y && LB_Dir < DI_X ? DM.y : 0.0125;
			
			if(LB_Detection)
				DM.y = LB_Masked;	
		#endif
		// Should expand on this as a way to rescale Depth in a specific location around the weapon hand.
		#if WHM //For now it's just UI masking for Diablo 4		
		float Mask = tex2Dlod(SamplerDMN,float4(texcoord,0,7.5)).y;
		if(WP > 0)
			DM.y = lerp(DM.y,0.025 ,smoothstep(0,DT_Z,Mask));
		#endif
		
		return float3(DM.y,PrepDepth( SDT == 2 || SD_Trigger == 2 ? TC_SP(texcoord).zw : texcoord)[1][1],HandleConvergence.z);
	}
	#define Adapt_Adjust 0.7 //[0 - 1]
	////////////////////////////////////////////////////Depth & Special Depth Triggers//////////////////////////////////////////////////////////////////
	void Mod_Z(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Point_Out : SV_Target0 , out float Linear_Out : SV_Target1)
	{   //Temporal adaptation https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
		float  ExAd = (1-Adapt_Adjust)*1250, Lum = tex2Dlod(SamplerDMN,float4(texcoord,0,12)).w, PastLum = tex2D(SamplerLumN,float2(0,0.583)).z;
	
		float3 Set_Depth = DB_Comb( texcoord.xy ).xyz;
		
		if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2) //TL
			Set_Depth.y = PastLum + (Lum - PastLum) * (1.0 - exp(-frametime/ExAd));	
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BR
			Set_Depth.y = AltWeapon_Fade();
		if(  texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BL
			Set_Depth.y = Weapon_ZPD_Fade(Set_Depth.z);
		
		Point_Out = Set_Depth.xy; 
		Linear_Out = Set_Depth.x;//is z when above code is on.	
	}
	
	static const float Blur_Adjust = 3.0;
	
	void zBuffer_Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Blur_Out : SV_Target0)
	{   
		float2 StoredTC = texcoord;
		float simple_Blur = tex2Dlod(SamplerzBufferN_L,float4(texcoord,0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferN_L,float4(texcoord + float2( pix.x * Blur_Adjust * 2, pix.y),0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferN_L,float4(texcoord + float2( pix.x * Blur_Adjust   , pix.y),0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferN_L,float4(texcoord + float2(-pix.x * Blur_Adjust   , pix.y),0, 0.0)).x;
		simple_Blur += tex2Dlod(SamplerzBufferN_L,float4(texcoord + float2(-pix.x * Blur_Adjust * 2, pix.y),0, 0.0)).x;
		
		#if !DX9_Toggle
		//Fade Storage
		float3x3 Fade_Pass = Fade(texcoord); //[0][0] = F | [0][1] = F | [0][2] = F
						 					 //[1][0] = F | [1][1] = N | [1][2] = 0
											 //[2][0] = 0 | [2][1] = 0 | [2][2] = 0
		const int Num_of_Values = 6; //4 total array values that map to the textures width.
		float Storage_Array[Num_of_Values] = { Fade_Pass[0][0],
	                                		   Fade_Pass[0][1],
	                                		   Fade_Pass[0][2], 
	                                		   Fade_Pass[1][0],
											   Fade_Pass[1][2],
											   Fade_Pass[1][1] };
		//Set a avr size for the Number of lines needed in texture storage.
		float Grid = floor(texcoord.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);							 
		simple_Blur = min(1,simple_Blur * 0.2);
		Blur_Out = float2( simple_Blur, Storage_Array[int(fmod(Grid,Num_of_Values))] );
		#else
		Blur_Out = simple_Blur;
		#endif
	}
	
	float2 Artifact_Adjust() { return float2(abs(De_Artifacting.x),De_Artifacting.y); }

	float Depth_Seperation()
	{
		#if !SD3D_Simple_Mode
		return ZPD_Separation.y;
		#else
		float Cal_Separation_Offset =  1 + (4 * DF_Y);
		return lerp(0.0,0.250,max(0,Scale(Divergence * Cal_Separation_Offset,100.0,50.0)));
		#endif
	}
		
	float GetDB(float2 texcoord)
	{
		#if Reconstruction_Mode  
		if( Vert_3D_Pinball )	
			texcoord.xy = texcoord.yx;	
		#else
		if(Vert_3D_Pinball && Stereoscopic_Mode != 5)	
			texcoord.xy = texcoord.yx;
		#endif
		bool VM_5_Bool = View_Mode == 5;
		float GetDepth = smoothstep(0,1, tex2Dlod(SamplerzBufferN_P, float4(texcoord,0, 1) ).y), Sat_Range = saturate(Range_Blend);
		uint VMW = View_Mode == 1 ? View_Mode_Warping : lerp(6, VM_5_Bool ? 0 :View_Mode_Warping, VM_5_Bool ? GetDepth : 1);
		
		float2 Base_Depth_Buffers = float2(tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, 0) ).x,tex2Dlod(SamplerzBufferN_P, float4( texcoord, 0, 0) ).x);	
		float2 Base_Depth_SubSampled = float2(tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, 2) ).x,tex2Dlod(SamplerzBufferN_P, float4( texcoord, 0, 2) ).x);
		float2 Base_Depth = lerp(Base_Depth_Buffers.xy,Base_Depth_SubSampled.xy,Sat_Range);
		/*
		float FadeIO = smoothstep(0,1,tex2D(SamplerDMN,0).x);
		if(FPS_Focus_Smoothing)
			VMW = lerp(VMW, 5,FadeIO);
		*/			
		float Depth_Blur = min(tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, clamp(VMW,0,5) ) ).x,Base_Depth.x);

		float2 DepthBuffer_LP = float2(Depth_Blur,Base_Depth.y);
	    //float Basic_UI = saturate(tex2Dlod(SamplerDMN,float4(texcoord* float2(0.5,1) + float2(0.5,0),0,4.5)).w * 25);
		// Basic_UI_TEST = tex2Dlod(SamplerDMN,float4(texcoord * float2(0.5,1),0,(uint)lerp(0,10,Basic_UI))).w;
		float2 Min_Blend = float2(min(DepthBuffer_LP,tex2Dlod(SamplerzBuffer_BlurN, float4( texcoord, 0, 1.0 ) ).x));
		
		if( Range_Blend > 0)
			   DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,  Min_Blend.xy ,(smoothstep(0.5,1.0, Min_Blend.x) *  Min_Divergence().y) * Sat_Range);

		//Text Lifting Not viable Yet Need time to work on this
		//if( TEST > 0)
		//	   DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,  min(DepthBuffer_LP.xy,saturate(tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, (uint)lerp(0,12,Basic_UI) ) ).x  * 0.01)) ,Basic_UI * saturate(TEST));

		if(View_Mode == 0 || View_Mode == 3)	
			DepthBuffer_LP.x = DepthBuffer_LP.y;		
	
		#if Inficolor_3D_Emulator
		float Separation = lerp(1.0,5.0,(Depth_Seperation() * 0.5 + Depth_Seperation()) * 0.5);	
		#else
		float Separation = lerp(1.0,5.0,Depth_Seperation()); 	
		#endif
		
		return Separation * DepthBuffer_LP.x;
	}
	
	void Mix_Z(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float MixOut : SV_Target0)
	{ 
		MixOut = GetDB( texcoord );
	}
	
	float GetMixed(float2 texcoord)
	{
		return tex2Dlod(SamplerzBufferN_Mixed,float4(texcoord,0,0)).x;
	}
	//Perf Level selection & Array access               X    Y      Z      W              X    Y      Z      W
	//static const float2 Performance_LvL[2] = { float4( 0.5, 0.5095, 0.679, 0.5 ), float4( 1.0, 1.019, 1.425, 1.0) };
	//Perf Level selection & Array access                X      Y               X    Y  
	static const float2 Performance_LvL0[2] = { float2( 0.5  , 0.679), float2( 1.0, 1.425) };
	static const float2 Performance_LvL1[2] = { float2( 0.375, 0.479), float2( 0.5, 0.679) };
	static const float  VRS_Array[5] = { 0.5, 0.5, 0.25, 0.125 , 0.0625 };
	//////////////////////////////////////////////////////////Parallax Generation///////////////////////////////////////////////////////////////////////
	float2 Parallax(float Diverge, float2 Coordinates, float IO) // Horizontal parallax offset & Hole filling effect
	{
	    float  MS = Diverge * pix.x; uint Perf_LvL = fmod(Performance_Level,2);  
		float2 ParallaxCoord = Coordinates, Default_Offset = View_Mode == 1 || View_Mode >= 5 ? float2(50.0,150.0) : float2(75.0,175.0), CBxy = floor( float2(Coordinates.x * BUFFER_WIDTH, Coordinates.y * BUFFER_HEIGHT));
		float GetDepth = smoothstep(0,1, tex2Dlod(SamplerzBufferN_P, float4(Coordinates,0, 1) ).y), CB_Done = fmod(CBxy.x+CBxy.y,2),
			Perf = Performance_Level > 1 ? lerp(Performance_LvL1[Perf_LvL].x,Performance_LvL0[Perf_LvL].x,GetDepth) : Performance_LvL0[Perf_LvL].x;
		//Would Use Switch....
		if( View_Mode == 2)
			Perf = Performance_Level > 1 ? lerp(Performance_LvL1[Perf_LvL].y,Performance_LvL0[Perf_LvL].y,GetDepth) : Performance_LvL0[Perf_LvL].y;
		if( View_Mode == 4)
			Perf = CB_Done ? 0.679f : 0.367f;
		if( View_Mode == 5)
			Perf = lerp(0.375f,0.679f,GetDepth);				
		//Luma Based VRS
		float Auto_Adptive = Switch_VRS == 0 ? lerp(0.05,1.0,smoothstep(0.00000001f, 0.375, tex2D(SamplerzBufferN_P,0).y ) ) : 1,
			  Luma_Adptive = smoothstep(0.0,saturate(VRS_Array[Switch_VRS] * Auto_Adptive), tex2Dlod(SamplerDMN,float4(Coordinates * float2(0.5,1),0,8)).w);
		if( Performance_Level > 1 )
			Perf *= saturate(Luma_Adptive * 0.5 + 0.5  );	
		//ParallaxSteps Calculations
		float MinNum = 20, D = abs(Diverge), Cal_Steps = D * Perf, FOV_Ren = Foveated_Mode ? lerp(100, MinNum, saturate(Vin_Pattern(Coordinates, float2(15.0,3.0))) * saturate(GetDepth * 4) ) : 50,
			  Steps  = clamp( Cal_Steps, MinNum, FOV_Ren );//Foveated Rendering Point of attack 16-256 limit samples.
		//float MinNum = 20, D = abs(Diverge), Cal_Steps = D * Perf, Steps = clamp( Cal_Steps, Performance_Level ? MinNum : lerp( MinNum, min( MinNum, D), GetDepth >= 0.999 ), lerp(100,View_Mode == 6 ? lerp(50, 20, saturate(GetDepth * 15)) : 50,saturate(Vin_Pattern(Coordinates, float2(15.0,2.5)))) );
		float LayerDepth = rcp(Steps), TP = Compatibility_Power >= 0 ? lerp(0.025, 0.05,Compatibility_Power) : lerp(0.0225, 0.05,abs(Compatibility_Power) * saturate(Vin_Pattern(Coordinates, float2(15.0,3.0))));
		float US_Offset = lerp(Default_Offset.x,Default_Offset.y,GetDepth * 0.5); D = Diverge < 0 ? -US_Offset : US_Offset;
	
		//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
		float deltaCoordinates = MS * LayerDepth, CurrentDepthMapValue = GetMixed( ParallaxCoord).x, CurrentLayerDepth = -Re_Scale_WN()-saturate(Push_Depth)*0.1,
			  DB_Offset = D * TP * pix.x, VM_Switch = View_Mode == 1 || View_Mode >= 5 ? 0.125 : lerp(1.0,0.125,GetDepth);
		
		float Mod_Depth = saturate(GetDepth * lerp(1,15,abs(Artifact_Adjust().y))), Reverse_Depth = Artifact_Adjust().y < 0 ? 1-Mod_Depth : Mod_Depth,
			  Scale_With_Depth = Artifact_Adjust().y == 0 ? 1 : Reverse_Depth;
			  
		float2 Artifacting_Adjust = float2(MS * lerp(0,0.125,saturate(Artifact_Adjust().x * Scale_With_Depth)),0);
		// Perform the conditional check outside the loop
		bool applyArtifacting = Artifact_Adjust().x != 0;
		
			if( View_Mode >= 2 && View_Mode < 5)
				applyArtifacting = 0;
								
		[loop] //Steep parallax mapping
		while ( CurrentDepthMapValue > CurrentLayerDepth )
		{   
			// Shift coordinates horizontally in linear fasion
		    ParallaxCoord.x -= deltaCoordinates;
		    // Get depth value at current coordinates
		    float G_Depth = GetMixed(ParallaxCoord).x;  
		    if ( applyArtifacting )
				CurrentDepthMapValue = min(G_Depth.x, GetMixed( ParallaxCoord - Artifacting_Adjust).x);
			else
				CurrentDepthMapValue = G_Depth.x;				
		    // Get depth of next layer
		    CurrentLayerDepth += LayerDepth;
		}
			
		if( View_Mode <= 1 || View_Mode >= 5 )	
	   	ParallaxCoord.x += DB_Offset * VM_Switch;
	    
		float2 PrevParallaxCoord = float2( ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y), Depth_Adjusted = 1-saturate(float2(GetDepth * 5.0, GetDepth));
		//Anti-Weapon Hand Fighting
		float Weapon_Mask = tex2Dlod(SamplerDMN,float4(Coordinates,0,0)).y, ZFighting_Mask = 1.0-(1.0-tex2Dlod(SamplerLumN,float4(Coordinates,0,1.400)).w - Weapon_Mask);
			  ZFighting_Mask = ZFighting_Mask * (1.0-Weapon_Mask);
		float2 PCoord = float2(View_Mode <= 1 || View_Mode >= 5 ? PrevParallaxCoord.x : ParallaxCoord.x, PrevParallaxCoord.y ) ;	
			   //PCoord.x -= 0.005 * MS;		   
		float Get_DB = GetMixed( PCoord ).x, 
			  Get_DB_ZDP = WP > 0 ? lerp(Get_DB, abs(Get_DB), ZFighting_Mask) : Get_DB;
		// Parallax Occlusion Mapping
		float beforeDepthValue = Get_DB_ZDP, afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
			  beforeDepthValue += LayerDepth - CurrentLayerDepth;
		// Depth Diffrence for Gap masking and depth scaling in Normal Mode.
		float DepthDiffrence = afterDepthValue - beforeDepthValue, DD_Map = abs(DepthDiffrence);
		float2 DD_Spread = saturate(float2(DD_Map > 0.064,DD_Map > 0.128));
		float weight = afterDepthValue / min(-0.0125,DepthDiffrence);
			  weight = lerp(weight + (2.0 * Depth_Adjusted.y) * DD_Spread.x,weight,0.75);//Reversed the logic since it seems look better this way and it leans towards the normal output.
		float Weight = weight;
		//ParallaxCoord.x = lerp( ParallaxCoord.x, PrevParallaxCoord.x, weight); //Old		
		ParallaxCoord.x = PrevParallaxCoord.x * weight + ParallaxCoord.x * (1 - Weight);
		//This is to limit artifacts.	
		ParallaxCoord.x += lerp(lerp(DB_Offset, DB_Offset * 1.25, DD_Spread.x ), DB_Offset * 1.375, DD_Spread.y );// Also boost in some areas using DD_Map

	#if Reconstruction_Mode
		if(Reconstruction_Type == 1 )
			ParallaxCoord.y += IO * pix.y; //Optimization for line interlaced.
		if(Reconstruction_Type == 2)
			ParallaxCoord.x += IO * pix.x; //Optimization for column interlaced.
	#else	
		if(Stereoscopic_Mode == 2)
			ParallaxCoord.y += IO * pix.y; //Optimization for line interlaced.
		else if(Stereoscopic_Mode == 3)
			ParallaxCoord.x += IO * pix.x; //Optimization for column interlaced.
	#endif

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
	
			float MACV = step(1.0-Mask_Tex,0.5); //Mask Adjustment Calculation Variable
			//This code is for hud segregation.
			HUD = MACV > 0 ? tex2D(BackBufferCLAMP,texcoord).rgb : HUD;
		#endif
		return  texcoord.x < 0.001 || 1-texcoord.x < 0.001 ? StoredHUD : HUD;
	}
	#endif
	///////////////////////////////////////////////////////////Stereo Conversions///////////////////////////////////////////////////////////////////////
	float Anaglyph_Selection(int Selection)
	{
		float2 Anaglyph_Array[7] = { float2(6, 2),
									 float2(7, 3),
									 float2(8, 4),
									 float2(9, 5),
									 float2(10, 6),
									 float2(11, 7),
									 float2(12, 8),
									};
		return Reconstruction_Mode ? Anaglyph_Array[Selection].y : Anaglyph_Array[Selection].x;
	}

	float4 Stereo_Convert(float2 texcoord, float4 L, float4 R)
	{   float2 TC = texcoord; float4 color, accum, image = 1;
		float2 gridxy, GXYArray[9] = {
			float2(TC.x * BUFFER_WIDTH, TC.y * BUFFER_HEIGHT), //Native
			float2(TC.x * 3840.0, TC.y * 2160.0),
			float2(TC.x * 3841.0, TC.y * 2161.0),
			float2(TC.x * 1920.0, TC.y * 1080.0),
			float2(TC.x * 1921.0, TC.y * 1081.0),
			float2(TC.x * 1680.0, TC.y * 1050.0),
			float2(TC.x * 1681.0, TC.y * 1051.0),
			float2(TC.x * 1280.0, TC.y * 720.0),
			float2(TC.x * 1281.0, TC.y * 721.0)
		};
		
		gridxy = floor(GXYArray[Scaling_Support]);
		#if Reconstruction_Mode
		if(Stereoscopic_Mode == 0)
			color = texcoord.x < 0.5 ? L : R;
		if(Stereoscopic_Mode == 1)
			color = texcoord.y < 0.5 ? L : R;
		#endif
		#if Inficolor_3D_Emulator
			float DeGhost = 0.06, LOne, ROne;
			//L.rgb += lerp(-1, 1,Anaglyph_Eye_Brightness.x); R.rgb += lerp(-1, 1,Anaglyph_Eye_Brightness.y);
			float3 HalfLA = dot(L.rgb,float3(0.299, 0.587, 0.114)), HalfRA = dot(R.rgb,float3(0.299, 0.587, 0.114));
			float3 LMA = lerp(HalfLA,L.rgb,lerp(0,2,Interlace_Anaglyph_Calibrate.y)), RMA = lerp(HalfRA,R.rgb,lerp(0,2,Interlace_Anaglyph_Calibrate.y));
			float2 Contrast = lerp(0.875,1.125,Anaglyph_Eye_Contrast);		
			// Left/Right Image
			float4 cA = float4(saturate(LMA),1);
			float4 cB = float4(saturate(RMA),1);

			cA = (cA - 0.5) * Contrast.x + 0.5; cB = (cB - 0.5) * Contrast.y + 0.5;
			
			float3 leftEyeColor = float3(1.0,0.0,1.0) * 1.0625; //magenta
			float3 rightEyeColor = float3(0.0,1.0,0.0) * 1.0625; //green
						
			color = saturate((cA.rgb*leftEyeColor)+(cB.rgb*rightEyeColor));
		#else
		if(Stereoscopic_Mode >= Anaglyph_Selection(0))
		{
			float DeGhost = 0.06, LOne, ROne;
			//L.rgb += lerp(-1, 1,Anaglyph_Eye_Brightness.x); R.rgb += lerp(-1, 1,Anaglyph_Eye_Brightness.y);
			float3 HalfLA = dot(L.rgb,float3(0.299, 0.587, 0.114)), HalfRA = dot(R.rgb,float3(0.299, 0.587, 0.114));
			float3 LMA = lerp(HalfLA,L.rgb,lerp(0,2,Interlace_Anaglyph_Calibrate.y)), RMA = lerp(HalfRA,R.rgb,lerp(0,2,Interlace_Anaglyph_Calibrate.y));
			float2 Contrast = lerp(0,2,Anaglyph_Eye_Contrast);		
			// Left/Right Image
			float4 cA = float4(saturate(LMA),1);
			float4 cB = float4(saturate(RMA),1);
			//cA = (cA - 0.5) * Contrast.x + 0.5; cB = (cB - 0.5) * Contrast.y + 0.5;

			if( Stereoscopic_Mode == Anaglyph_Selection(0) || Stereoscopic_Mode == Anaglyph_Selection(1) ) 
			{
				//cA = (cA - 0.5) * Contrast.x + 0.5; cB = (cB - 0.5) * Contrast.y + 0.5;
				LOne = Contrast.x*0.45;
				ROne = Contrast.y;
				accum = saturate(cA*float4(LOne,(1.0-LOne)*0.5,(1.0-LOne)*0.5,1.0));
				cA.r = pow(accum.r+accum.g+accum.b, 1.00);
				
				accum = saturate(cB*float4(1.0-ROne,ROne,0.0,1.0));
				cB.g = pow(accum.r+accum.g+accum.b, 1.15);
				
				accum = saturate(cB*float4(1.0-ROne,0.0,ROne,1.0));
				cB.b = pow(accum.r+accum.g+accum.b, 1.15);
			}
	
			if( Stereoscopic_Mode == Anaglyph_Selection(3) || Stereoscopic_Mode == Anaglyph_Selection(4) ) 
			{//float4(cB.r,cA.g,cB.b,1.0
				//cA = (cA - 0.5) * Contrast.x + 0.5; cB = (cB - 0.5) * Contrast.y + 0.5;
				
				LOne = Contrast.x;
				ROne = Contrast.y*0.8;
	
				accum = saturate(cB*float4(ROne,1.0-ROne,0.0,1.0));
				cB.r = pow(accum.r+accum.g+accum.b, 1.15);
	
				accum = saturate(cA*float4((1.0-LOne)*0.5,LOne,(1.0-LOne)*0.5,1.0));
				cA.g = pow(accum.r+accum.g+accum.b, 1.05);
	
				accum = saturate(cB*float4(0.0,1.0-ROne,ROne,1.0));
				cB.b = pow(accum.r+accum.g+accum.b, 1.15);
				
			}
	
			if (Stereoscopic_Mode == Anaglyph_Selection(0)) // Anaglyph 3D Colors Red/Cyan
				color =  float4(cA.r,cB.g,cB.b,1.0);
			else if (Stereoscopic_Mode == Anaglyph_Selection(1)) // Anaglyph 3D Dubois Red/Cyan
			{		
				float red = 0.437 * cA.r + 0.449 * cA.g + 0.164 * cA.b - 0.011 * cB.r - 0.032 * cB.g - 0.007 * cB.b;
	
				if (red > 1) { red = 1; }   if (red < 0) { red = 0; }
	
				float green = -0.062 * cA.r -0.062 * cA.g -0.024 * cA.b + 0.377 * cB.r + 0.761 * cB.g + 0.009 * cB.b;
	
				if (green > 1) { green = 1; }   if (green < 0) { green = 0; }
	
				float blue = -0.048 * cA.r - 0.050 * cA.g - 0.017 * cA.b -0.026 * cB.r -0.093 * cB.g + 1.234  * cB.b;
	
				if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
	
				color = float4(red, green, blue, 0);
			}
			else if (Stereoscopic_Mode == Anaglyph_Selection(2)) // Anaglyph 3D Deghosted Red/Cyan Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
			{
				LOne = Contrast.x*0.45;
				ROne = Contrast.y;
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
			else if (Stereoscopic_Mode == Anaglyph_Selection(3)) // Anaglyph 3D Green/Magenta
				color = float4(cB.r,cA.g,cB.b,1.0);
			else if (Stereoscopic_Mode == Anaglyph_Selection(4)) // Anaglyph 3D Dubois Green/Magenta
			{
				float red = -0.062 * cA.r -0.158 * cA.g -0.039 * cA.b + 0.529 * cB.r + 0.705 * cB.g + 0.024 * cB.b;
	
				if (red > 1) { red = 1; }   if (red < 0) { red = 0; }
	
				float green = 0.284 * cA.r + 0.668 * cA.g + 0.143 * cA.b - 0.016 * cB.r - 0.015 * cB.g + 0.065 * cB.b;
	
				if (green > 1) { green = 1; }   if (green < 0) { green = 0; }
	
				float blue = -0.015 * cA.r -0.027 * cA.g + 0.021 * cA.b + 0.009 * cB.r + 0.075 * cB.g + 0.937  * cB.b;
	
				if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
	
				color = float4(red, green, blue, 0);
			}
			else if (Stereoscopic_Mode == Anaglyph_Selection(5))// Anaglyph 3D Deghosted Green/Magenta Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
			{
				LOne = Contrast.x*0.45;
				ROne = Contrast.y*0.8;
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
			else if (Stereoscopic_Mode == Anaglyph_Selection(6)) // Anaglyph 3D Blue/Amber Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
			{
				LOne = Contrast.x*0.45;
				ROne = Contrast.y;
				float D[1];//The Chronicles of Riddick: Assault on Dark Athena FIX I don't know why it works.......
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
		#endif
		return color;
	}
	///////////////////////////////////////////////////////////Stereo Calculation///////////////////////////////////////////////////////////////////////
	#if Reconstruction_Mode
	void CB_Reconstruction(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float3 Left : SV_Target0, out float3 Right : SV_Target1)
	#else
	float3 PS_calcLR(float2 texcoord, float2 position)
	#endif
	{   float2 Persp = Per;
		if(Stereoscopic_Mode == 0)
			Persp *= 0.5;
		//if(Stereoscopic_Mode == 5)//Need to work on this later.
		//	Persp *= 0.25;
		float2 TCL = texcoord, TCR = texcoord, TCL_T = texcoord, TCR_T = texcoord, TexCoords = texcoord;
		TCL += Persp; TCR -= Persp; TCL_T += Persp; TCR_T -= Persp;
		#if !Reconstruction_Mode
			#if !Inficolor_3D_Emulator
			[branch] if (Stereoscopic_Mode == 0)
			{
				TCL.x = TCL.x*2;
				TCR.x = TCR.x*2-1;
			}
			else if(Stereoscopic_Mode == 1)
			{
				TCL.y = TCL.y*2;
				TCR.y = TCR.y*2-1;
			}
			else if(Stereoscopic_Mode == 5)
			{
				TCL = float2(TCL.x*2,TCL.y*2);
				TCL_T = float2(TCL_T.x*2-1,TCL_T.y*2);
				TCR = float2(TCR.x*2-1,TCR.y*2-1);
				TCR_T = float2(TCR_T.x*2,TCR_T.y*2-1);
			}
			#endif
		#endif
	
		#if Inficolor_3D_Emulator
		if (Depth_Detection == 1)
		{
			if (!DepthCheck)
				Persp = 0;
		}	
		
		if (Cancel_Depth)
			Persp = 0;
			
		if(Inficolor_Auto_Focus)
			Persp *= lerp(0.75,1.0, smoothstep(0,0.5,tex2D(SamplerLumN,float2(0,0.750)).z));
		#endif
	
		float D = Eye_Swap ? -Min_Divergence().x : Min_Divergence().x;
	
		float FadeIO = Focus_Reduction_Type == 1 ? 1 : smoothstep(0,1,1-Fade_in_out(texcoord).x), FD = D, FD_Adjust = 0.25;
	
		if( World_n_Fade_Reduction_Power.x == 1)
			FD_Adjust = 0.3125;
		if( World_n_Fade_Reduction_Power.x == 2)
			FD_Adjust = 0.375;
		if( World_n_Fade_Reduction_Power.x == 3)
			FD_Adjust = 0.4375;	
		if( World_n_Fade_Reduction_Power.x == 4)
			FD_Adjust = 0.50;
		if( World_n_Fade_Reduction_Power.x == 5)
			FD_Adjust = 0.5625;
		if( World_n_Fade_Reduction_Power.x == 6)
			FD_Adjust = 0.625;
		if( World_n_Fade_Reduction_Power.x == 7)
			FD_Adjust = 0.6875;
		if( World_n_Fade_Reduction_Power.x == 8)//Should expand to 0.875? it would be Power == 10
			FD_Adjust = 0.75;
	
		if (FPSDFIO >= 1)
			FD = lerp(FD * FD_Adjust,FD,FadeIO);
	
		float2 DLR = float2(FD,FD);
		if( Eye_Fade_Selection == 1)
				DLR = float2(D,FD);
		else if( Eye_Fade_Selection == 2)
				DLR = float2(FD,D);
	
		float4 color, Left_T, Right_T, L, R, Left_Right;
		#if Reconstruction_Mode

		float3 Pattern = float3( floor(TexCoords.y*texsize.y) + floor(TexCoords.x*texsize.x), floor(TexCoords.x*texsize.x), floor(TexCoords.y*texsize.y));
		float Pattern_Type = fmod(Pattern.x,2); //CB
	
		if(Reconstruction_Type == 1 )
			Pattern_Type = fmod(Pattern.z,2); //LI
		if(Reconstruction_Type == 2 )
			Pattern_Type = fmod(Pattern.y,2); //CI
			
		float4 Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
	
			if(Vert_3D_Pinball)
				Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).yx, position.xy ).rgb;		
			else
				Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w), position.xy ).rgb;	
		#else
		float3 CB_Pattern = float3( floor(TexCoords.y*texsize.y) + floor(TexCoords.x*texsize.x), floor(TexCoords.x*texsize.x), floor(TexCoords.y*texsize.y));
		float Pattern_Type = fmod(CB_Pattern.x,2); //CB

		if(Stereoscopic_Mode == 0)
			Pattern_Type = TexCoords.x < 0.5; //SBS
		if( Stereoscopic_Mode == 1)
			Pattern_Type = TexCoords.y < 0.5; //TnB
		if(Stereoscopic_Mode == 2)
			Pattern_Type = fmod(CB_Pattern.z,2); //LI
		if( Stereoscopic_Mode == 3)
			Pattern_Type = fmod(CB_Pattern.y,2); //CI

		float4 Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);

		if(Stereoscopic_Mode == 5)
			Shift_LR = TexCoords.y < 0.5 ? TexCoords.x < 0.5 ? float4(-DLR.x,TCL,AI) : float4(-DLR.x * 0.33333333,TCL_T,AI) : TexCoords.x < 0.5 ? float4(DLR.y * 0.33333333, TCR_T, -AI) : float4(DLR.y, TCR, -AI);

		if(Stereoscopic_Mode >= 6 || Inficolor_3D_Emulator)
		{		
			if(Vert_3D_Pinball)
			{
				L.rgb = MouseCursor(Parallax(-DLR.x, TCL.yx, AI).yx, position.xy ).rgb;
				R.rgb = MouseCursor(Parallax( DLR.y, TCR.yx,-AI).yx, position.xy ).rgb;
			}
			else
			{
				L.rgb = MouseCursor(Parallax(-DLR.x,TCL, AI), position.xy ).rgb;
				R.rgb = MouseCursor(Parallax( DLR.y,TCR,-AI), position.xy ).rgb;
			}
		}
		else	
		{
			if(Vert_3D_Pinball && Stereoscopic_Mode != 5)
				Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).yx, position.xy ).rgb;		
			else
				Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w), position.xy ).rgb;		
		}
		#endif
	
		#if HUD_MODE || HMT
		float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25.) * pix.x;
		
		if(Stereoscopic_Mode >= 6 || (Inficolor_3D_Emulator && !Reconstruction_Mode))
		{
			L.rgb = HUD(L.rgb,float2(TCL.x - HUD_Adjustment,TCL.y)).rgb;
			R.rgb = HUD(R.rgb,float2(TCR.x + HUD_Adjustment,TCR.y)).rgb;
		}
		else
			Left_Right.rgb = HUD(Left_Right.rgb,float2(Shift_LR.y - HUD_Adjustment,Shift_LR.z)).rgb;
			
		#endif
		//Convert Stereo
		#if Reconstruction_Mode
		color.rgb = Left_Right.rgb;
		#else
		color.rgb = Stereoscopic_Mode >= 6 || Inficolor_3D_Emulator ? Stereo_Convert( TexCoords, L, R).rgb : Left_Right.rgb;
		#endif

		if (Depth_Map_View == 2)
			color.rgb = tex2D(SamplerzBufferN_P,TexCoords).xxx;
		
		
		float DepthBlur, Alinement_Depth = tex2Dlod(SamplerzBufferN_P,float4(TexCoords,0,0)).x, Depth = Alinement_Depth;
		const float DBPower = 1.0, Con = 11, weight[11] = { 0.0,0.010,-0.010,0.020,-0.020,0.030,-0.030,0.040,-0.040,0.050,-0.050 };
		if(BD_Options == 2 || Alinement_View)
		{
			float2 dir = 0.5 - TexCoords; 
			[loop]
			for (int i = 0; i < 11; i++)
			{
				DepthBlur += tex2Dlod(SamplerzBufferN_L,float4(TexCoords + dir * weight[i] * DBPower,0,2) ).x;
			}
			
			Alinement_Depth = ( Alinement_Depth + DepthBlur ) * 0.08333;
		}
	
		if (BD_Options == 2 || Alinement_View)
			color.rgb = dot(tex2D(BackBufferBORDER,TexCoords).rgb,0.333) * float3((Depth/Alinement_Depth> 0.998),1,(Depth/Alinement_Depth > 0.998));
		if( Helper_Fuction() == 0 || timer <= 0)  
			color.rgb *= TexCoords.xyx;
		
	#if Reconstruction_Mode
		Left.rgb = Pattern_Type ? 0 : color.rgb ; 
		Right.rgb= Pattern_Type ? color.rgb  : 0;
	#else
		return color.rgb;
	#endif
	}
	///////////////////////////////////////////////////////Average & Information Textures///////////////////////////////////////////////////////////////
	#if Color_Correction_Mode
	void Average_Info(float4 position : SV_Position, float2 texcoord : TEXCOORD, out  float4 Average : SV_Target0, out  float4 Color_Correction : SV_Target1)
	#else
	void Average_Info(float4 position : SV_Position, float2 texcoord : TEXCOORD, out  float4 Average : SV_Target0)
	#endif
	{	
		float Average_ZPD = PrepDepth( texcoord )[0][0];
	
		const int Num_of_Values = 6; //6 total array values that map to the textures width.
		float Storage_Array_A[Num_of_Values] = { tex2D(SamplerDMN,0).x,    			//0.083 //TL Fade in Out
	                                             tex2D(SamplerDMN,1).x,                //0.250 //BR Fade X Level 0
	                                             tex2D(SamplerDMN,int2(0,1)).x,        //0.416 //BL Fade Y Level 1
	                                             tex2D(SamplerzBufferN_P,0).y,         //0.583 //TL
								             	tex2D(SamplerzBufferN_P,1).y,         //0.750 //BR 
								             	tex2D(SamplerzBufferN_P,int2(0,1)).y};//0.916 //BL
												
		float Storage_Array_B[Num_of_Values] = { 1.0,                                   //0.083
	                                			 tex2D(SamplerDMN,int2(1,0)).y,         //0.250 //TR Fade Z Level 3
	                               			  tex2D(SamplerDMN,int2(1,0)).x,         //0.416 //TR Fade Z Level 2
	                                			 tex2D(SamplerDMN,1).y,                 //0.583 //BR Fade Z Level 4
												 tex2D(SamplerDMN,0).y,                 //0.750 //TL Fade W The Switch
												 1.0};                                  //0.916 												 
		//Set a avr size for the Number of lines needed in texture storage.
		float Grid = floor(texcoord.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);
		//Where LBDetection() is slot X in the float4 below I can do an array like in slot Z If I need to send more information.	
		Average = float4(LBDetection(),Average_ZPD, texcoord.x < 0.5 ? Storage_Array_A[int(fmod(Grid,Num_of_Values))] : Storage_Array_B[int(fmod(Grid,Num_of_Values))],tex2Dlod(SamplerDMN,float4(texcoord,0,0)).y);
		
		#if Color_Correction_Mode
			Color_Correction = float4(tex2D(samplerMinMaxRGB, texcoord).rgb,1);	
		#endif
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	#if Reconstruction_Mode
	float4 Direction(float2 texcoord,float dx, float dy, int Switcher) //Load Pixel
	{	texcoord += float2(dx, dy);
		if(Switcher == 1) 
			return tex2D(Sampler_SD_CB_L, texcoord ) ;
		else
			return tex2D(Sampler_SD_CB_R, texcoord ) ;
	}
	
	float colorDiffBlend(float3 a, float3 b)
	{
	    float3 differential = a - b;
	    return rcp(length(differential) + 0.001);
	}
	
	float4 differentialBlend(float2 texcoord, int Switcher, int Set_Direction)
	{    
		float4 Up     = Direction(texcoord, 0.0  ,-pix.y, Switcher),
		       Down   = Direction(texcoord, 0.0  , pix.y, Switcher),
		       Left   = Direction(texcoord,-pix.x, 0.0  , Switcher),
		       Right  = Direction(texcoord, pix.x, 0.0  , Switcher),
			   Center = Direction(texcoord, 0.0  , 0.0  , Switcher), 
               Result;
	
	    float verticalWeight = colorDiffBlend(Up.rgb, Down.rgb);
	    float horizontalWeight = colorDiffBlend(Left.rgb, Right.rgb);
		float4 VertResult = (Up + Down) * verticalWeight;
		float4 HorzResult = (Left + Right) * horizontalWeight;
	    
		if(Set_Direction == 1)
			Result = Center + VertResult * 0.5 * rcp(verticalWeight) ;
		else if(Set_Direction == 2)
			Result = Center + HorzResult * 0.5 * rcp(horizontalWeight);//Uni_LR( texcoord, Switcher );
		else
			Result = Center + (VertResult + HorzResult) * 0.5 * rcp(verticalWeight + horizontalWeight);
			
	    return Result;
	}
	#endif
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
	
	float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{   float4 Color;
		float2 TCL = texcoord, TCR = texcoord, TC;
		float DX9_Helper = Info_Fuction();
		#if !DX9_Toggle && !ISOGL
		DX9_Helper = position.z;
		#endif
		if (Stereoscopic_Mode == 0 && !Inficolor_3D_Emulator )
		{
			TCL.x = TCL.x*2;
			TCR.x = TCR.x*2-1;
			TC = texcoord.x < 0.5;
		}
		
		if (Stereoscopic_Mode == 1 && !Inficolor_3D_Emulator )
		{
			TCL.y = TCL.y*2;
			TCR.y = TCR.y*2-1;
			TC = texcoord.y < 0.5;
		}
		//Stereo Left TCL and Right TCR
		Color = TC ? tex2D(SamplerInfo,TCL).x : tex2D(SamplerInfo,TCR).x;
		
		#if Reconstruction_Mode
		Color.rgb = Stereo_Convert( texcoord, differentialBlend(TCL, 0, Reconstruction_Type), differentialBlend(TCR, 1, Reconstruction_Type) ).rgb;	  	
		#else
		Color.rgb = PS_calcLR(texcoord, position.xy).rgb;
		#endif
		Color = DX9_Helper ? Color.rgba + Color.w : Color; //Blend Color
		#if BC_SPACE == 1
	    Color = ExpandScRGB(Color);
	    #else
	    Color = Color;
	    #endif
	    //float Basic_UI = saturate(tex2Dlod(SamplerDMN,float4(texcoord* float2(0.5,1) + float2(0.5,0),0,4)).w * 5);
		//Color = tex2Dlod(SamplerDMN,float4(texcoord * float2(0.5,1),0,(uint)lerp(0,10,Basic_UI))).w;
		//Color = texcoord.x > 0.5 ? Color : tex2D(SamplerDMN,0).x;
		return Color.rgba;
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
		//Check TAA/MSAA/SS/DLSS/FSR/XeSS		
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
	void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{// Vertex shader generating a triangle covering the entire screen
		texcoord.x = (id == 2) ? 2.0 : 0.0;
		texcoord.y = (id == 1) ? 2.0 : 0.0;
		position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), timer <= Text_Timer || Text_Info, 1.0);
	}

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
	
	technique SuperDepth3D
	< ui_tooltip = "Suggestion : You Can Enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
				   			 "Do this once you set your 3D settings of course."; >
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
		#else
			pass Average_Information
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Info;
			RenderTarget0 = texLumN;
			#if Color_Correction_Mode
			RenderTarget1 = texMinMaxRGBLastFrame;
			#endif
		}
		#endif
			pass Blur_DepthBuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = zBuffer_Blur;
			RenderTarget0 = texzBufferBlurN;
		}
			pass DepthBuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget = texDMN;
		}	
			pass Modzbuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = Mod_Z;
			RenderTarget0 = texzBufferN_P;
			RenderTarget1 = texzBufferN_L;
		}
			pass MixDepth
		{
			VertexShader = PostProcessVS;
			PixelShader = Mix_Z;
			RenderTarget0 = texzBufferN_M;
		}
		#if Color_Correction_Mode
			pass Color_Correction
		{
			VertexShader = PostProcessVS;
			PixelShader = MinMaxRGB;
			RenderTarget = texMinMaxRGB;
		}
		#endif

		#if Reconstruction_Mode
			pass Muti_Mode_Reconstruction
		{
			VertexShader = PostProcessVS;
			PixelShader = CB_Reconstruction;
			RenderTarget0 = texSD_CB_L;
			RenderTarget1 = texSD_CB_R;
		}
		#endif
		
			pass StereoOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
		#if D_Frame || DFW
			pass Average_Information
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Info;
			RenderTarget0 = texLumN;
			#if Color_Correction_Mode
			RenderTarget1 = texMinMaxRGBLastFrame;
			#endif
		}
		#endif
	}
}