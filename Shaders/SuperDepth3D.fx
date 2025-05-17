	////----------------//
	///**SuperDepth3D**///
	//----------------////
	#define SD3D "SuperDepth3D v4.7.9\n"
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
	#if exists "AXAA.fxh"
		#include "AXAA.fxh"
		#define AXAA_EXIST 1
	#else
		#warning "Missing AXAA.fxh Header File"
		#define AXAA_EXIST 0
	#endif
	
	#define D_ViewMode 1
	#if exists "Overwatch.fxh"                                           //Overwatch Interceptor//
		#include "Overwatch.fxh"
		#define OSW 0
	#else// DA_X = [ZPD] DA_Y = [Depth Adjust] DA_Z = [Offset X] DA_W = [Depth Linearization]
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
		// DI_X = [LBM Offset XY] DI_Y = [Boost Mode Pop Level Adjuster] DI_Z = [Weapon Near Depth Trim] DI_W = [OIF Check Depth Limit]
		static const float DI_X = 0.0, DI_Y = 0.0, DI_Z = 0.25, DI_W = 0.5;
		// DJ_X = [Range Smoothing] DJ_Y = [Menu Detection Type] DJ_Z = [Match Threshold] DJ_W = [Check Depth Limit Weapon]
		static const float DJ_X = 0, DJ_Y = 0.0, DJ_Z = 0.0, DJ_W = -0.100;
		// DK_X = [FPS Focus Method] DK_Y = [Eye Eye Selection] DK_Z = [Eye Fade Selection] DK_W = [Eye Fade Speed Selection]	
		static const float DK_X = 0, DK_Y = 0.0, DK_Z = 0, DK_W = 1;
		// DL_X = [Not Used Here] DL_Y = [De-Artifact] DL_Z = [Compatibility Power] DL_W = [Not Used Here]
		static const float DL_X = 0.5, DL_Y = 0, DL_Z = 0, DL_W = 0.05;		
		// DM_X = [HQ Tune] DM_Y = [HQ VRS] DM_Z = [HQ Smooth] DM_W = [HQ Trim]
		static const float DM_X = 4, DM_Y = 1, DM_Z = 1, DM_W = 0.0;
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
		// DZ_X = [Text Position A & B] DZ_Y = [Text Position C] DZ_Z = [ABC Menu Tresholds] DZ_W = [Text Adjustment]
		static const float DZ_X = 0.0, DZ_Y = 0.0, DZ_Z = 1000.0, DZ_W = 0.0;
		// DAA_X = [Position A & B] DAA_Y = [Position C] DAA_Z = [ABCD Menu Tresholds] DAA_W = [Warping Masking]
		static const float DAA_X = 0.0, DAA_Y = 0.0, DAA_Z = 1000.0, DAA_W = 1;		
		// DBB_X = [Position A & B] DBB_Y = [Position C] DBB_Z = [ABCD Menu Tresholds] DBB_W = [Depth Max Adjust]
		static const float DBB_X = 0.0, DBB_Y = 0.0, DBB_Z = 1000.0, DBB_W = 0.0;		
		// DCC_X = [Position A & B] DCC_Y = [Position C] DCC_Z = [ABCD Menu Tresholds] DCC_W = [Isolating Weapon Stencil Amount]
		static const float DCC_X = 0.0, DCC_Y = 0.0, DCC_Z = 1000.0, DCC_W = 0.0;
		// DDD_X = [Position A & B] DDD_Y = [Position C & UI Pos] DDD_Z = [ABCW Stencil Menu Tresholds] DDD_W = [Stencil Adjust]
		static const float DDD_X = 0.0, DDD_Y = 0.0, DDD_Z = 1000.0, DDD_W = 0.0;
		// DEE_X = [Position A & B] DEE_Y = [Position C & UI Pos] DEE_Z = [ABCW Stencil Menu Tresholds] DEE_W = [Stencil Adjust]
		static const float DEE_X = 0.0, DEE_Y = 0.0, DEE_Z = 1000.0, DEE_W = 0.0;
		// DFF_X = [Position A & B] DFF_Y = [Position C & UI Pos] DFF_Z = [ABCW Stencil Menu Tresholds] DFF_W = [Stencil Adjust]
		static const float DFF_X = 0.0, DFF_Y = 0.0, DFF_Z = 1000.0, DFF_W = 0.0;
		// DGG_X = [Position A & B] DGG_Y = [Position C & UI Pos] DGG_Z = [ABCW Stencil Menu Tresholds] DGG_W = [Stencil Adjust]
		static const float DGG_X = 0.0, DGG_Y = 0.0, DGG_Z = 1000.0, DGG_W = 0.0;
		// DHH_X = [Position A & B] DHH_Y = [Position C] DHH_Z = [ABCD Menu Tresholds] DHH_W = [Smart Convergence]
		static const float DHH_X = 0.0, DHH_Y = 0.0, DHH_Z = 1000.0, DHH_W = 0.0;	
		// DII_X = [Position A & B] DII_Y = [Position C] DII_Z = [ABCD Menu Tresholds] DII_W = [Offset Y]
		static const float DII_X = 0.0, DII_Y = 0.0, DII_Z = 1000.0, DII_W = 0.0;
		// DJJ_X = [Position A & B] DJJ_Y = [Position C & UI Pos] DJJ_Z = [ABCW Stencil Menu Tresholds] DJJ_W = [Stencil Adjust]
		static const float DJJ_X = 0.0, DJJ_Y = 0.0, DJJ_Z = 1000.0, DJJ_W = 0.0;
		// DKK_X = [SDT Position A & B] DKK_Y = [SDT Position C] DKK_Z = [SDT ABCD Menu Tresholds] DKK_W = [Last OIF Check Depth Limit Boundary & Cutoff]
		static const float DKK_X = 0.0, DKK_Y = 0.0, DKK_Z = 1000.0, DKK_W = 0.0;
		// DLL_X = [Position A & B] DLL_Y = [Position C & UI Pos] DLL_Z = [ABCW Stencil Menu Tresholds] DLL_W = [Stencil Adjust]
		static const float DLL_X = 0.0, DLL_Y = 0.0, DLL_Z = 1000.0, DLL_W = 0.0;
		// DMM_X = [Lock Position A & B] DMM_Y = [Lock Position C] DMM_Z = [Lock ABCW Menu Tresholds] DMM_W = [Isolating Weapon Stencil Amount]
		static const float DMM_X = 0.0, DMM_Y = 0.0, DMM_Z = 1000.0, DMM_W = 0.0;
		// DNN_X = [Horizontal Scale] DNN_Y = [Vertical Scale] DNN_Z = [Flip Scale] DNN_W = [Game Depth Near Plane Values]
		static const float DNN_X = 1.0, DNN_Y = 1.0, DNN_Z = 0.0, DNN_W = 1.0;
		// WSM = [Weapon Setting Mode]
		#define OW_WP "WP Off\0Custom WP\0"
		#define G_Info "Missing Overwatch.fxh Information.\n"
		#define G_Note "Note: If you pulled this file intentionally, please ignore this message.\n"
		static const int WMM = 0, SDD = 0, DMM = 0, LBL = 0, LBD = 0, WSM = 0, TSC = 0;
		static const int2 DOL = 0;
		//Triggers 
		static const float HNR = 0, THF = 0, EGB = 0,PLS = 0, MGA = 0, WZD = 0, KHM = 0, DAO = 0, LDT = 0, ALM = 0, SSF = 0, SNF = 0, SSE = 0, SNE = 0, EDU = 0, LBI = 0,ISD = 0, ASA = 1, IWS = 0, SUI = 0, SSA = 0, SNA = 0, SSB = 0, SNB = 0,SSC = 0, SNC = 0,SSD = 0, SND = 0, LHA = 0, WBS = 0, TMD = 0, FRM = 0, AWZ = 0, CWH = 0, WBA = 0, WFB = 0, WND = 0, WRP = 0, MML = 0, SMD = 0, WHM = 0, SDU = 0, ABE = 2, LBE = 0, HQT = 0, HMD = 0.5, MAC = 0, OIL = 0, MMS = 0, FTM = 0, FMM = 0, SPO = 0, MMD = 0, LBR = 0, AFD = 0, MDD = 0, FPS = 1, SMS = 1, OIF = 0, NCW = 0, RHW = 0, NPW = 0, SPF = 0, BDF = 0, HMT = 0, HMC = 0, DFW = 0, NFM = 0, DSW = 0, LBC = 0, LBS = 0, LBM = 0, DAA = 0, NDW = 0, PEW = 0, WPW = 0, FOV = 0, EDW = 0, SDT = 0;
		//Overwatch.fxh State
		#define OSW 1
	#endif
	
	//USER EDITABLE PREPROCESSOR FUNCTIONS START//

	// Experimental DLP mode for Side By Side and the lesser supported Top n Bottom
	#define EX_DLP_FS_Mode 0  //Default 0 is Off. One is On
	//Please note this mode should run at your DLP native resolution at 720p or 1080p Native 120hz Auto Mode.
	//Keeping a stable 120hz in game is required. Not sure if this is something we can enforce for now.
	//Lot of issues with this mode that needs to be looked into. For now it's something to try out for fun.
	//Keep in mind this Frame Sequential only for testing and no usable unless the game can keep a steady frame rate of around 120.
	//It also has Debug options for advance users.

	// This shift the detectors for ZPD Boundary Detection. 
	#define Shift_Detectors_Up SDU //Default 0 is Off. One is On
	//To override or activate this SDU change your have to set it too 0 or 1.
	
	#ifndef Cancel_Depth_Key
	// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key using keycode info
	// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
		#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	#endif
	
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
	#define Mouse_Key_Four 4 //Forward Mouse Button
	#define Mouse_Key_Three 3 //Back Mouse Button
	#define Mouse_Key_Two 2 //Middle Mouse Button
 
	#define Fade_Key 1 // Set default on mouse 1
	#define Fade_Time_Adjust 0.5625 // From 0 to 1 is the Fade Time adjust for this mode. Default is 0.5625;
	
	// Delay Frame for instances the depth bufferis 1 frame behind useful for games that need "Copy Depth Buffer
	// Before Clear Operation," Is checked in the API Depth Buffer tab in ReShade.
	#ifndef Delay_Frame_Mode
		#if DFW
			#define Delay_Frame_Mode 1
		#else
			#define Delay_Frame_Mode 0
		#endif
	#endif
	//Change Delay_Frame_Mode to 1 to enable this option.
	#define D_Frame Delay_Frame_Mode //This should be set to 0 most of the times this will cause latency by one frame.
	
	//Text Information Key Default Menu Key
	#define Text_Info_Key 93
	
	//Fast Trigger Mode
	#define Fast_Trigger_Mode FTM //To override or activate this set it to 0 or 1 This only works if Overwatch tells the shader to do it or not.

	//Lower Height Adjustment
	#define Lower_Height_Adjust LHA //To override or activate this set it to 0 or 1 This only works if Overwatch tells the shader to do it or not.
	
	//USER EDITABLE PREPROCESSOR FUNCTIONS END//
	#if !defined(__RESHADE__) || __RESHADE__ < 40000
		#define Compatibility 1
	#else
		#define Compatibility 0
	#endif
	
	#if __RESHADE__ >= 50000
		#define Compatibility_00 1
	#else
		#define Compatibility_00 0
	#endif
	
	#if __RENDERER__ == 0x9000
		#if __RESHADE__ <= 60303
			#define Compatibility_01 1
		#else
			#define Compatibility_01 0
		#endif	
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
	
	#ifndef Use_2D_Plus_Depth
	    #define Use_2D_Plus_Depth 0
	#endif
	
	#if Use_2D_Plus_Depth
		#define Virtual_Reality_Mode 0 
		#define Inficolor_3D_Emulator 0
		#define Reconstruction_Mode 0
		#define REST_UI_Mode 0
		#define Super3D_Mode 0
		#define Anaglyph_Mode 0
	#else
		//This preprocessor is for Interlaced Reconstruction of Line Interlaced for Top and Bottom and Column Interlaced for Side by Side.
		#ifndef Virtual_Reality_Mode
		    #define Virtual_Reality_Mode 0    
		#endif
		
		#if !Virtual_Reality_Mode
		
			#ifndef Anaglyph_Mode
			    #define Anaglyph_Mode 0
			#endif
		
		    #ifndef Inficolor_3D_Emulator
		        #define Inficolor_3D_Emulator 0
		    #endif
		
		    #if !REST_UI_Mode
		    	#if !Anaglyph_Mode
			        #ifndef Reconstruction_Mode
			            #define Reconstruction_Mode 0
			        #endif
			    #else
			        #define Reconstruction_Mode 0
			    #endif			    	
		    #else
		        #define Reconstruction_Mode 0
		    #endif
		
		#else
			#define Anaglyph_Mode 0
		    #define Reconstruction_Mode 0
		    #define Inficolor_3D_Emulator 0
		#endif 
	
		// This is for REST Add-On
		#if Inficolor_3D_Emulator || Reconstruction_Mode || Virtual_Reality_Mode || Anaglyph_Mode
		    #define REST_UI_Mode 0
		#else
		    #ifndef REST_UI_Mode
		        #define REST_UI_Mode 0
		    #endif
		#endif 
		
		#if Virtual_Reality_Mode
		    // This preprocessor is for Super3D Mode for close-to-full-res images using channel compression
		    #ifndef Super3D_Mode
		        #define Super3D_Mode 0
		    #endif
		#endif
	#endif
	#ifndef Enable_Deband_Mode
	    #define Enable_Deband_Mode 0
	#endif
	
	#ifndef HDR_Compatible_Mode
	    #define HDR_Compatible_Mode 0
	#endif
	/* //Placed on Hold
	#ifndef Filter_Final_Image
	    #define Filter_Final_Image 0
	#endif
	*/
	
	#ifndef Legacy_Mode
	    #define Legacy_Mode 0
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
				G_Note
			  "\n"
				#if DSW
				"Check Depth/Add-on Options: Copy Depth Clear/Frame: You should check it in the Depth/Add-ons tab above. Alternatively, you may need to enable/disable Use Extended AR Heuristics or try Extended AR heuristics.\n"
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
				"Disable CA/MB/DoF/Grain: Common post effects like Chromatic Aberration, Motion Blur, Depth of Field, Grain, etc. They will/may cause issues with this shader.\n"
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
				"\n"
				"It can be anything such as the REFramework or something like the Generic Depth Mod for Reshade.\n"
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
				#if Legacy_Mode
				"Legacy Mode is still a Work In Progress.\n"
				"\n"

				#endif
				G_Info
				"__________________________________________________________________\n"
			    "For more information and help please visit http://www.Depth3D.info\n"
				"Discord: https://discord.gg/KrEnCAxkwJ";
	ui_category = "Depth3D Information";
	ui_category_closed = false;
	ui_label = " ";
	ui_type = "radio";
	>;
	#if MGA > 0
	uniform int Set_Game_Profile <
		ui_type = "combo";
		ui_items = MG_App;
		ui_label = "·Select Game·";
		ui_tooltip = "This sets the profile for a application that has a multiple amount of games.";
		ui_category = "Game Selection";
	> = 0;	
	#endif
	//uniform float TEST < ui_type = "slider"; ui_min = 0; ui_max = 1.0; > = 0.00;
	//Divergence & Convergence//
	uniform float Depth_Adjustment < //This change was made to make it more simple for users
		ui_type = "slider";
		ui_min = 0.0; ui_max = 100; ui_step = 0.5;
		ui_label =  "·Depth Adjustment·"; 
		ui_tooltip =  "Increases differences between the left and right images and allows you to experience depth.\n"
					  "The process of deriving binocular depth information is called stereopsis (or stereoscopic vision).\n"
					  "Default is 50% and Max is 100%.";
		ui_category = "Divergence & Separation";
	> = 50;

	static const float Separation_Adjust = DF_Y;//Is now internal adjusted.
	
	uniform float ZPD_OverShoot <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label =  " Smart Convergence"; 
		ui_tooltip =  "ZPD OverShoot controls the focus distance for the screen Pop-out effect in the distance.\n"
					  "If you see me do not adjust base ZPD (Zero Parallax Distance) below.\n"
					  "Default for ZPD is 0.0 Off.";
		ui_category = "Divergence & Separation";
	> = DHH_W;

	#if Virtual_Reality_Mode
		#if !Super3D_Mode
			uniform int IPD <
				ui_type = "drag";
				ui_min = 0; ui_max = 100;
				ui_label = " IPD";
				ui_tooltip = "Interpupillary Distance Determines the distance between your eyes.\n"
							 "Not Needed if you use VR software that calculate this.\n"
							 "Default is 0.";
				ui_category = "Divergence & Separation";
			> = 0;
		#else
			static const int Perspective = 0;
		#endif
	#else
	#if !Use_2D_Plus_Depth
		#if !Inficolor_3D_Emulator
		uniform int Perspective <
			ui_type = "slider";
			ui_min = -100; ui_max = 100;
			ui_label = " Perspective Slider";
			ui_tooltip = "Determines the perspective point of the two images this shader produces.\n" // ipd = Interpupillary distance 
						 "For an HMD, use Polynomial Barrel Distortion shader to adjust for IPD.fx.\n"
						 "Do not use this perspective adjustment slider to adjust for IPD.\n"
						 "Default is Zero.";
				ui_category = "Divergence & Separation";
		> = 0;
		#endif
	#else
		static const int Perspective = 0;
	#endif
	#endif
		uniform float Zero_Parallax_Distance <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 0.250;
		ui_label =  "·Zero Parallax Distance·"; 
		ui_tooltip =  "ZPD (Zero Parallax Distance) controls the base focus distance for the screen Pop-out effect.\n" //https://manual.reallusion.com/iClone_6/ENU/Pro_6.0/09_3D_Vision/Settings_for_Pop_Out_and_Deep_In_Effect.htm
					  "For FPS Games keep ZPD low since you don't want your gun to pop out of the screen too much.\n"
					  "Do not change this is the game has a modern profile.\n"
					  "Default for ZPD is 0.025.";
		#if !NPW
		ui_category_closed = true;
		#endif
		ui_category = "Zero Parallax Distance";
	> = DA_X;	
	
	uniform float ZPD_Balance <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " ZPD Balance";
		ui_tooltip = "This balances between ZPD Depth and Scene Depth.\n" //***
					 "Changes the prioritization of the 3D effect.\n"
					 "Default is 0 for ZPD Depth and 0.5 is enhanced Scene Depth.";
		ui_category = "Zero Parallax Distance";
	> = DF_Z;
	
	uniform int ZPD_Boundary <
		ui_type = "combo";
		ui_items = "BD0 Off\0BD1 Full\0BD2 Narrow\0BD3 Wide\0BD4 FPS Center\0BD5 FPS Narrow\0BD6 FPS Edge\0BD7 FPS Mixed\0";		
		ui_label = " ZPD Boundary Detection";
		ui_tooltip = "This selection gives extra boundary conditions to detect for ZPD intrusions.\n"//***
					 "Default is Off.";
		ui_category = "Zero Parallax Distance";
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
		ui_category = "Zero Parallax Distance";
	> = float2(DE_Y,DE_Z);
	
	//Workaround it only reads from the first value.
	static const float CutOff_Value = DI_W;	
	
	uniform float2 ZPD_Boundary_n_Cutoff_A <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " ZPD Scaler² & Intrusion";
		ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Two.\n"
					 "lets you adjust how far behind the screen it should detect a intrustion.\n"
					 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
		ui_category = "Zero Parallax Distance";
	> = float2(OIF.x,CutOff_Value);	

	#if EDW
		uniform float2 ZPD_Boundary_n_Cutoff_B <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 2.5;
			ui_label = " ZPD Scaler³ & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Three.\n"
						 "lets you adjust how far behind the screen it should detect a intrustion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = float2(OIF.y,DI_W.y);	

		uniform float2 ZPD_Boundary_n_Cutoff_C <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 3.75;
			ui_label = " ZPD Scaler4 & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Four.\n"
						 "lets you adjust how far behind the screen it should detect a intrustion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = float2(OIF.z,DI_W.z);	

		uniform float2 ZPD_Boundary_n_Cutoff_D <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 5.0;
			ui_label = " ZPD Scaler5 & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Five.\n"
						 "lets you adjust how far behind the screen it should detect a intrustion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = float2(OIF.w,DI_W.w);

		uniform float2 ZPD_Boundary_n_Cutoff_End <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 5.0;
			ui_label = " ZPD Scaler6 & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Six.\n"
						 "lets you adjust how far behind the screen it should detect a intrustion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = DKK_W;	
	#endif
	
	uniform bool ZPD_Screen_Edge_Avoidance <
			ui_label = "ZPD Edge Guard";
			ui_tooltip = "ZPD Screen Edge Avoidance system called Edge Guard.\n"
						 "This allows more popout near the edge.";
			ui_category = "Zero Parallax Distance";
	> = EGB;
	#if !Use_2D_Plus_Depth
		#if Legacy_Mode
		//static const int View_Mode = 0;
		///*
		uniform int View_Mode <
			ui_type = "combo";
			ui_items = "VM0 Stamped \0VM1 Blend \0";
			ui_label = "·View Mode·";
			ui_tooltip = "Changes the way the shader fills in the occluded sections in the image.\n"
						"Stamped      | Stamps out a transparent area where occlusion happens.\n"
						"Blend        | Like Normal But but blends the the in the information.\n"
						"\n"
						"Warning: Also Make sure Performance Mode is active before closing the ReShade menu.\n"
						"\n"
						"Default is Blend.";
		ui_category = "Occlusion Masking";
		> = DS_Z;
		//*/
		#else
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
		#endif
	#endif
	uniform int Warping_Masking <
		ui_type = "combo";
		ui_items = "M0 Full \0M1 Masked \0M2 Half \0";
		#if !Use_2D_Plus_Depth
			//#if Legacy_Mode
			//ui_label = "·Halo Priority·";
			//#else
			ui_label = " Halo Priority";
			//#endif
		#else
		ui_label = "·Halo Priority·";
		#endif
		ui_tooltip = "This option creates a mask that prioritizes forground objects and ignore distance objects.\n"
					"Full      | No masking and applys Halo Reduction to the entire Image.\n"
					"Masked    | This will allow things in the the distance to looks shaper.\n"
					"Half      | Same thing as Masked above but stronger and is closer to Full.\n"
					 "Default is Masked and Zero is Off.";
		ui_category = "Occlusion Masking";
	> = DAA_W;	

	uniform int Weapon_Near_Halo_Reduction <
		ui_type = "combo";
		ui_items = "HNR Off \0HNR On\0";
		ui_label = " Halo Near Reduction";
		ui_tooltip = "This option creates a mask that prioritizes Near objects like Weapon Hands and sets it to Max.\n"
					//"Full      | No masking and applys Halo Reduction to the entire Image.\n"
					//"Masked    | This will allow things in the the distance to looks shaper.\n"
					//"Half      | Same thing as Masked above but stronger and is closer to Full.\n"
					 "Default is Halo Near Reduction Off.";
		ui_category = "Occlusion Masking";
	> = HNR;	

	uniform int View_Mode_Warping <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0; ui_max = 9;
		ui_label = " Halo Reduction";
		ui_tooltip = "This distorts the depth in some View Modes to hide or minimize the halo in Most Games.\n"
					 "With this active it should Hide the Halo a little better depending the View Mode it works on.\n"
					 "Default is 5 and Zero is Off.";
		ui_category = "Occlusion Masking";
	> = DM_X;	

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
	#if !Use_2D_Plus_Depth
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
	> = PLS;
	
	uniform bool Foveated_Mode <
			ui_label = "Foveated Rendering";
			ui_tooltip = "Foveated rendering lowes the quality of the infilling around the center of the image.\n"
						 "In the future when we have a method for eye tracking this should work a lot better.";
			ui_category = "Occlusion Masking";
	> = FRM;
	#endif
	#if !Use_2D_Plus_Depth
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

	uniform int Target_High_Frequency <
		ui_label = " De-Artifact HF";
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0; ui_max = 3;
		ui_tooltip = "Some times We get artifacting on Hair Since it's hard to know where the hair is in the image.\n"
					 "We target High Frequency Infomrtion in the hopes of Mitigating it there.\n"
					 "Default is Zero and it's Off.";
		ui_category = "Compatibility Options";
	> = THF;

	uniform bool De_Art_Opt <
		ui_label = " De-Artifact Hoz";
		ui_tooltip = "Some times We get artifacting on the Hoz axis around round or sloped objects.\n"
					 "Enable this if you want to also target this issue.\n"
					 "Default is Off.";
		ui_category = "Compatibility Options";
	> = DAO;
		#endif
	uniform int Select_SS <
		ui_type = "combo";
		ui_items = "DLSS\0FSR\0XeSS\0Variant One\0";
		ui_label = " Upscaling Algorithm";
		ui_tooltip = "Use this to match Super Sampling type.\n"
					 "Default is FSR.";
		ui_category = "Scaling Corrections";
	> = 1;
	
	uniform int Easy_SS_Scaling <
		//ui_category_closed = false;
		ui_type = "combo";	
		//ui_items = "Off\0Quality           - Good\0Balanced          - Fair\0Performance       - Avoid\0Ultra Performance - Do Not Use\0";
		//ui_items = "Off\0Ultra Quality     - Good\0Quality           - Good\0Balanced          - Fair\0Performance       - Avoid\0";	
		ui_items = "Off\0[XeSS] Ultra Quality | [DLSS/FSR] Quality           \0[XeSS] Quality       | [DLSS/FSR] Balanced          \0[XeSS] Balanced      | [DLSS/FSR] Performance       \0[XeSS] Performance   | [DLSS/FSR] Ultra Performance \0";	
		ui_label = " Upscaling Quality";
		ui_tooltip = "Use to adjust the DepthBuffer to match the BackBuffer when using some types of Super Sampling in some games.\n"
					"Ultra Quality     | Best.\n"
					"Quality           | Good.\n"
					"Balanced          | Fair.\n"
					"Performance       | Avoid.\n"
					"Ultra Performance | Do Not Use.\n"
					"\n"
					"Default is Off.";			 
		ui_category = "Scaling Corrections";
	> = 0;
	/*
	uniform float SS_Scaling_Adjuster <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = -0.5; ui_max = 0.5;
		ui_label = " Upscaler Adjust";
		ui_tooltip = "This lets you adjust existing values to fit the screen.";
		ui_category = "Scaling Corrections";
	> = 0.0;
	*/
	
	uniform float2 DLSS_FSR_Offset <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = -5.0; ui_max = 5.0;
		ui_label = " Upscaler Offset";
		ui_tooltip = "This Offset is for non conforming ZBuffer Postion witch is normaly 1 pixel wide.\n"
					 "This issue only happens sometimes when using things like DLSS, XeSS and or FSR.\n"
					 "This does not solve for TAA artifacts like Jittering or Smearing.\n"
					 "Default and starts at 0 and is Off. With a max offset of 5 pixels Wide.";
		ui_category = "Scaling Corrections";
	> = 0;
	#if !Compatibility_01
	uniform uint2 Starting_Resolution <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0; ui_max = 0;
		ui_label = " Upscaler Guided";
		ui_tooltip = "This lets you set existing known value and automatically scales if a change was detected\n"
					 "Set it to the Depth Buffers starting resolution or maybe your native res.\n"
					 "Default is 0 and it is Off.";
		ui_category = "Scaling Corrections";
	> = uint2(0,0);
	#endif
	#if !DX9_Toggle 
	uniform int Auto_Scaler_Adjust <
		ui_type = "combo";
			ui_items = "Off\0ON\0";
		ui_label = " Auto Scaler";
		ui_tooltip = "Shift the depth map if a slight misalignment is detected.";
		ui_category = "Scaling Corrections";
	> = ASA;
		#if LBC || LB_Correction || EDW
		uniform int LBD_Switcher <
			ui_type = "combo";
				ui_items = "Off\0Direction X&Y\0Direction X\0Direction Y\0";
			ui_label = " Letter Box Scaler";
			ui_tooltip = "Force Shift the depth map if a slight misalignment is detected.\n"
						 "Turns off when Letter Box is not detected.";
			ui_category = "Scaling Corrections";
		> = LBD;	
		#endif	
	#endif
	
	uniform int Depth_Map <
		ui_type = "combo";
		ui_items = "DM0 Normal\0DM1 Reversed\0";
		ui_label = "·Depth Map Selection·";
		ui_tooltip = "Linearization for the zBuffer also known as Depth Map.\n"
				     "DM0 is Z-Normal and DM1 is Z-Reversed.\n";
		ui_category = "Depth Map";
		#if !NPW
		ui_category_closed = true;
		#endif
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
	
	uniform float2 Offset <
		ui_type = "drag";
		ui_min = -1.0; ui_max = 1.0;
		ui_label = " Linear Offset";
		ui_tooltip = "Depth Map Offset is for non conforming ZBuffer.\n"
					 "It's rare if you need to use this in any game.\n"
					 "Default and starts at Zero and it's Off.";
		ui_category = "Depth Map";
	> = float2(DA_Z,DII_W);
	
	uniform float Auto_Depth_Adjust <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.500;
		ui_label = " Auto Near Plane";
		ui_tooltip = "Automatically adjust Near Plane to prevent excessive pop-out effects.\n"
					 "Default is 0.1, Zero is off.";
		ui_category = "Depth Map";
	> = DB_Z;

	uniform float PopOut_Target <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Popout Target";
		ui_tooltip = "Popout Target: use to adjust for for when the distortions when objects are coming to far out of the screen like Weapon Hands.\n"
					 "The Point of this is to set a target that the Shader will Try to reach only when Popout is detected.\n"
					 "Default is Zero & it's off.";
		ui_category = "Depth Map";	
	> = WND;	
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
			ui_label = "·Horizontal & Vertical Size Center·";
			ui_tooltip = "Adjust Horizontal and Vertical Resize from the Center. Default is 1.0.";
			ui_category = "Reposition Depth";
		> = float2(DD_X,DD_Y);
		
		uniform float2 Image_Position_Adjust<
			ui_type = "drag";
			ui_min = -1.0; ui_max = 1.0;
			ui_label = " Horizontal & Vertical Position";
			ui_tooltip = "Adjust the Image Position if it's off by a bit. Default is Zero.";
			ui_category = "Reposition Depth";
		> = float2(DD_Z,DD_W);

		uniform float2 Horizontal_and_Vertical_TL <
			ui_type = "drag";
			ui_min = 0.0; ui_max = 2;
			ui_label = " Horizontal & Vertical Scale";
			ui_tooltip = "Adjust Horizontal and Vertical Resize from the Top Left. Default is 1.0.";
			ui_category = "Reposition Depth";
		> = float2(DNN_X,DNN_Y);

		uniform bool Flip_HV_Scale <
			ui_label = " Flip Scale";
			ui_tooltip = "Turn this on to flip the scaling from Top Left <-> Bottom Right.\n"
					     "To Bottom Right <-> Top Left.";
			ui_category = "Reposition Depth";
		> = DNN_Z;
	
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
		static const float2 Horizontal_and_Vertical_TL = float2(DNN_X,DNN_Y);
		
		static const bool Flip_HV_Scale = DNN_Z;
		
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
		#if !NPW
		ui_category_closed = true;
		#endif
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
		ui_tooltip = "Null: This Option is empty for now and will be reworked later.\n"
					 "Weapon Min : is used to adjust min weapon hand of the weapon hand when looking at the world near you when the above fails.\n"
					 "Weapon Auto: is used to auto adjust trimming when looking around.\n"
					 "Weapon Trim: is used cutout a location in the depth buffer so that Min and Auto scale off of.\n"
					 "Default is (Near X 0.0, Min Y 0.0, Auto Z 0.0, Trim Z 0.250 ) & Zero is off.";
		ui_category = "Weapon Hand Adjust";	
	> = float4(0,DG_Z,DE_W,DI_Z);// Weapon ZDP was set to 0.03 and is an internal constant value
	
	uniform float4 Weapon_Depth_Edge <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Screen Edge Adjust & Near Scale";
		ui_tooltip = "This Tool is to help with screen Edge adjustments and Weapon Hand scaling near the screen";
		ui_category = "Weapon Hand Adjust";	
	> = DF_W;
	
	uniform float2 Weapon_ZPD_Boundary <
		ui_type = "slider";
		ui_min = -1.0; ui_max = 1.0;
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

	#if Use_2D_Plus_Depth
		static const int Stereoscopic_Mode = 0;
		static const float Anaglyph_Saturation = 0.5;
		static const float Interlace_Optimization = 0.5;
		static const float2 Anaglyph_Eye_Contrast = 0.0;
		static const int Scaling_Support = 0;
		static const int Eye_Swap = 0;
		static const int Inficolor_Near_Reduction = 0;
		static const float Focus_Inficolor = 0.5;
		static const float Inficolor_Max_Depth = 1.0;
		static const float Inficolor_OverShoot = 0.0;
	#else
		#if Virtual_Reality_Mode
			static const int Reconstruction_Type = 0;
		#else
			#if Reconstruction_Mode	
			uniform int Reconstruction_Type <
				ui_type = "combo";
				ui_items = "CB Reconstruction\0Line Interlace Reconstruction\0Column Interlaced Reconstruction\0";
				ui_label = "·Reconstruction Mode·";
				ui_tooltip = "Stereoscopic reconstructed 3D display output selection.";
				ui_category = "Stereoscopic Options";
			> = 0;
			#endif
		#endif
		//Stereoscopic Options//
		#if Super3D_Mode && Virtual_Reality_Mode
		static const int Stereoscopic_Mode = 0;
		static const float Anaglyph_Saturation = 0.5;
		static const float Interlace_Optimization = 0.5;
		static const float2 Anaglyph_Eye_Contrast = 0.0;
		static const int Scaling_Support = 0;
		
		static const int Inficolor_Near_Reduction = 0;
		static const float Focus_Inficolor = 0.5;
		static const float Inficolor_Max_Depth = 1.0;
		static const float Inficolor_OverShoot = 0.0;
			#else
			uniform int Stereoscopic_Mode <
				ui_type = "combo";
				#if Virtual_Reality_Mode
							ui_items = "Side by Side\0Top and Bottom\0Checkerboard 3D\0";
							ui_label = " 3D Display Modes";
				#else
					#if Inficolor_3D_Emulator || Anaglyph_Mode
						#if Anaglyph_Mode && !Inficolor_3D_Emulator
							ui_items = "Anaglyph 3D Red-Cyan\0Anaglyph 3D Red-Cyan Dubois\0Anaglyph 3D Red-Cyan Anachrome\0Anaglyph 3D Red-Cyan LCD Optimized Anaglyph\0Anaglyph 3D Green-Magenta\0Anaglyph 3D Green-Magenta Dubois\0Anaglyph 3D Green-Magenta Triochrome\0Anaglyph 3D Blue-Amber ColorCode\0Anaglyph 3D Red-Blue Optimized\0Anaglyph 3D Magenta-Cyan\0";
							ui_label = " 3D Display Mode";
						#else
							ui_items = "TriOviz Inficolor 3D Emulation Alpha\0TriOviz Inficolor 3D Emulation Beta\0";
							ui_label = " 3D Display Mode";
						#endif
					#else
						#if Reconstruction_Mode
							#if EX_DLP_FS_Mode
								ui_items = "Side by Side\0Top and Bottom\0Frame Sequential\0";
								ui_label = " 3D Display Modes";
							#else
								ui_items = "Side by Side\0Top and Bottom\0";
								ui_label = " 3D Display Modes";
							#endif
						#else
							#if EX_DLP_FS_Mode
								ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Quad Lightfield 2x2\0Frame Sequential\0";		
								ui_label = "·3D Display Modes·";
							#else
								#if REST_UI_Mode
									ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Quad Lightfield 2x2 - Not Working\0";		
								#else
									ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Quad Lightfield 2x2\0";		
								#endif
								ui_label = "·3D Display Modes·";
							#endif
						#endif
					#endif
				#endif
				ui_tooltip = "Stereoscopic 3D display output selection.";
				ui_category = "Stereoscopic Options";
			> = 0;
		//Interlace_Anaglyph_Calibrate
			#if Anaglyph_Mode || Inficolor_3D_Emulator
				uniform float Anaglyph_Saturation <
					ui_type = "drag";
					ui_min = 0.0; ui_max = 1.0;
					ui_label = " Anaglyph Saturation";
					ui_tooltip = "Anaglyph Desaturation allows for removing color from an anaglyph 3D image. Zero is Black & White, One is full color.\n"
								 "Default for Anaglyph Desaturation/Saturation is 0.5.";
					ui_category = "Stereoscopic Options";
				> = 0.5;
				static const float Interlace_Optimization = 0.5;
				
				uniform float2 Anaglyph_Eye_Contrast <
					ui_type = "drag";
					ui_min = 0.0; ui_max = 1.0;
					ui_label = " Anaglyph Contrast";
					ui_tooltip = "Per Eye Contrast adjustment for Anaglyph 3D.\n"
								 "Default is set to 0.5 Off.";
					ui_category = "Stereoscopic Options";
				> = float2(0.5,0.5);
				
			#else
				uniform float Interlace_Optimization <
					ui_type = "drag";
					ui_min = 0.0; ui_max = 1.0;
					ui_label = " Interlace Optimization";
					ui_tooltip = "Interlace Optimization is used to reduce aliasing in a Line or Column interlaced images. This has the side effect of softening the image.\n"
								 "Default for Interlace Optimization is 0.5.";
					ui_category = "Stereoscopic Options";
				> = 0.5;
				static const float Anaglyph_Saturation = 0.5;
			#endif			

			#if Inficolor_3D_Emulator
		
			uniform float3 Inficolor_Reduce_RGB <
				ui_type = "drag";
				ui_min = 0.0; ui_max = 1.0;
				ui_label = " Inficolor Reduce Red, Green & Blue";
				ui_tooltip = "This option lets you reduce or isolated any color in the upper range in the game.\n"
							 "Default is set to 0.5.";
				ui_category = "Stereoscopic Options";
			> = 0.5;	
			/*
			uniform float Inficolor_OverShoot <
				ui_type = "drag";
				ui_min = 0.0; ui_max = 1.0;
				ui_label = " Inficolor OverShoot";
				ui_tooltip = "Inficolor 3D OverShoot for Auto Balance.\n"
							 "Default and starts at 0.5 and it's 50% overshoot.";
				ui_category = "Stereoscopic Options";
			> = 0.5;
			*/
			uniform float Inficolor_Max_Depth <
				ui_type = "drag";
				ui_min = 0.5; ui_max = 1.0;
				ui_label = " Inficolor Max Depth";
				ui_tooltip = "Max Depth lets you clamp the max depth range of your scene.\n"
							 "So it's not hard on your eyes looking off in to the distance .\n"
							 "Default and starts at One and it's Off.";
				ui_category = "Stereoscopic Options";
			> = 1.0;
			
			uniform float Focus_Inficolor <
				ui_type = "drag";
				ui_min = 0.0; ui_max = 1.5;
				ui_label = " Inficolor Focus";
				ui_tooltip = "Adjust this until the image has as little Color Fringing at the near and far range.\n"
							 "Default is set to 0.5.";
				ui_category = "Stereoscopic Options";
			> = 0.5;
			
			#else
				static const float Focus_Inficolor = 0.5;
				static const float Inficolor_Max_Depth = 1.0;
				//static const float Inficolor_OverShoot = 0.0;
			#endif
			
			#if Ven && !Inficolor_3D_Emulator && !Anaglyph_Mode
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
			#endif
			
			#if EX_DLP_FS_Mode
			//https://paulbourke.net/stereographics/blueline/
			//https://lists.gnu.org/archive/html/bino-list/2013-03/pdfz6rW7jUrgI.pdf
			uniform int FS_Mode <
				ui_type = "combo";
				ui_items = "Off\0DLP Mode\0Blue Line FS\0Marked FS\0";
				ui_label = " Frame Sequential Mode";
				ui_tooltip = "This DLP mode added the Color Code to a Stereo Image so that the DLP Projector's Auto-Mode can enable.\n"
							 "This is for 3-D Ready Second-generation DLP Projectors that can detect the solid color of the last active line.\n"
							 "Please Note: Frame Sync is not supported yet, If you think you can help with this message me.\n"
							 "Default is Off.";
				ui_category = "Stereoscopic Options";
			> = false;	
			#endif
		#endif		
		uniform bool Eye_Swap <
			ui_label = " Swap Eyes";
			ui_tooltip = "L/R to R/L."; // E/D ou D/E
	
			ui_category = "Stereoscopic Options";
		> = false;
	#endif
	
	uniform int Focus_Reduction_Type <
		ui_type = "combo";
		ui_items = "World\0Weapon\0Mix\0";
		ui_label = "·Focus Type·";
		ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
					"This may induce Eye Strain so take this as a Warning.";
		ui_category_closed = true;
		ui_category = "FPS Focus";
	> = FPS;
	
	uniform int FPSDFIO <
		ui_type = "combo";
		ui_items = "Off\0Press\0Hold\0Stencil\0Press & Stencil\0Hold & Stencil\0";
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
	
	uniform bool Toggle_On_Boundary <
		ui_label = " On Boundary Activation";
		ui_tooltip = "Turns on when the first boundy hit is detected from the weapon profile above.";
		ui_category = "FPS Focus";
	> = WZD;
	
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

	uniform int Cursor_Lock_Button_Selection <
		ui_type = "combo";
		ui_items = "Use Cursor Lock\0Mouse 2\0Mouse 3\0Mouse 4\0";
		ui_label = "Cursor Lock Button Selection";
		ui_tooltip = "Choose what mouse button to.\n"
								 "Default is Use Cursor Lock.";
		ui_category = "Cursor Adjustments";
	> = 0;

	uniform int Cursor_Toggle_Button_Selection <
		ui_type = "combo";
		ui_items = "Use Cursor Toggle\0Mouse 2\0Mouse 3\0Mouse 4\0";
		ui_label = "Cursor Toggle Button Selection";
		ui_tooltip = "Choose what mouse button to.\n"
								 "Default is Use Toggle.";
		ui_category = "Cursor Adjustments";
	> = 0;
	#if REST_UI_Mode	
	uniform int Cursor_REST_Button_Selection <
		ui_type = "combo";
		ui_items = "Use Rest Toggle\0Mouse 2\0Mouse 3\0Mouse 4\0";
		ui_label = "Cursor Toggle Button Selection";
		ui_tooltip = "Choose what mouse button to.\n"
								 "Default is Use Rest.";
		ui_category = "Cursor Adjustments";
	> = 0;
	#endif
	uniform bool Cursor_Lock <
		ui_label = " Cursor Lock";
		ui_tooltip = "Screen Cursor to Screen Crosshair Lock.";
		ui_category = "Cursor Adjustments";
	> = false;	
	
	uniform bool Toggle_Cursor <
		ui_label = " Cursor Toggle";
		ui_tooltip = "Turns Screen Cursor Off and On without cycling, once set to the option above.";
		ui_category = "Cursor Adjustments";
	> = false;
	#if REST_UI_Mode
	uniform bool Toggle_REST <
		ui_label = " Cursor Switch";
		ui_tooltip = "Switches the Screen Cursor from one layer to an other layer.";
		ui_category = "Cursor Adjustments";
	> = false;
	#endif
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
	//#if Super3D_Mode && Virtual_Reality_Mode
	#if Virtual_Reality_Mode && !Super3D_Mode
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
		ui_items = "Off\0Theater Mode Normal\0Theater Mode Extended\0Theater Mode Max\0";
		ui_label = " Theater Modes";
		ui_tooltip = "Sets the VR Shader into Theater mode for CellPhone VR or AR Glasses.\n"
					 "The 2nd Option is the same as the first. But, Zoomed in as a tradeoff.\n"
				     "Default is Off.\n";
		ui_category = "Image Adjustment";
	> = 0;	
	#else
	static const int Barrel_Distortion = 0;
	static const float3 Polynomial_Colors_K1 = float3(0.22, 0.22, 0.22);
	static const float3 Polynomial_Colors_K2 = float3(0.24, 0.24, 0.24);
		#if !Super3D_Mode
			#if !Anaglyph_Mode
			uniform int Theater_Mode <
				ui_type = "combo";
				ui_items = "Off\0Theater Mode Normal\0Theater Mode Extended\0Theater Mode Max\0";
				ui_label = "·Theater Modes·";
				ui_tooltip = "Sets the VR Shader into Theater mode for CellPhone VR or AR Glasses.\n"
							 "The 2nd Option is the same as the first. But, Zoomed in as a tradeoff.\n"
						     "Default is Off.\n";
				ui_category = "Image Effects";
			> = 0;	
			uniform float FoV <
				ui_type = "slider";
				ui_min = 0; ui_max = 0.5;
				ui_label = " Field of View";
				ui_tooltip = "Lets you adjust the FoV of the Image.\n"
							 "Default is 0.0.";
				ui_category = "Image Effects";
			> = 0;
			#else
			static const int Theater_Mode = 0;
			static const float FoV = 0;
			#endif			
		#else
		static const int Theater_Mode = 0;
		static const float FoV = 0;
		#endif
	#endif

	uniform float Adjust_Vignette <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		#if Virtual_Reality_Mode || Super3D_Mode || Anaglyph_Mode
		ui_label = "·Vignette·";	
		#else
		ui_label = " Vignette";
		#endif
		ui_tooltip = "Soft edge effect around the image.";
		ui_category = "Image Effects";
	> = 0.0;

	uniform float Sharpen_Power <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 5.0;
		ui_label = " SmartSharp";
		ui_tooltip = "Adjust this to clear up the image the game, movie picture & etc.\n"
					 "This is Smart Sharp Jr code based on the Main Smart Sharp shader.\n"
					 "It can be pushed more and looks better then the basic USM.";
		ui_category = "Image Effects";
	> = 0;

	uniform float Saturation <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		ui_label = " Saturation";
		ui_tooltip = "Lets you saturate image, basically adds more color.";
		ui_category = "Image Effects";
	> = 0;

	#if AXAA_EXIST
	uniform bool USE_AXAA <
		ui_label = " Adaptive approXimate Anti-Aliasing";
		ui_tooltip = "Adaptive approXimate Anti-Aliasing is Based on LG's modifications to FXAA.";
		ui_category = "Image Effects";
	> = false;
	#endif
	
	#if Enable_Deband_Mode
	uniform bool Toggle_Deband <
		ui_label = " Deband Toggle";
		ui_tooltip = "Turns on automatic Depth Aware Deband this is used to reduce or remove the color banding in the image.";
		ui_category = "Miscellaneous Options";
	> = true;
	#endif
	
	#if !Use_2D_Plus_Depth
	uniform bool Vert_3D_Pinball <
		ui_label = "Swap 3D Axis";	
		ui_tooltip = "Use this to swap the axis that the Parallax is generated.\n"
					 "Useful for 3D Pinball Games, You may have to swap eyes.\n"
					 "Default is Off.";
		ui_category = "Miscellaneous Options";
	> = false;
	#else
	static const bool Vert_3D_Pinball = false;
	#endif
	
	#if WHM	
	uniform float UI_Seeking_Strength <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " UI Adjust";
		ui_tooltip = "This gives control over adjusting seeking for UI when it's enabled.\n"
					"Default is 0.0.";
		ui_category = "Miscellaneous Options";
	> = DT_Z;
	#else
	static const float UI_Seeking_Strength = DT_Z;	
	#endif	
/* //Slated for deletion and with a link to a Help Guide online	
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
				//"Color Correcting  | Is the process of restoring the original colors in the scenes.\n"
				"Deband            | Is used to correct for banding issues in the image.\n"
				"HDR compatibility | Allows for HDR support in the shader when HDR is available.\n"
				"Inficolor 3D      | Modify the shader to accommodate Inficolor glasses for 3D content.\n"
				"Reconstruction    | Is a diffrent way to render the images out.\n"
				"\n"
				"Active Keys:\n"
				"Menu Key          | Is used to toggle on-screen information you see at startup.\n"
				"Mouse Button 4    | Is used to unlock and lock the on screen cursor at default.\n"
				"_______________________________________________________________________________\n"
			    "Try reading the Read Help doc or Join our Discord https://discord.gg/KrEnCAxkwJ";
	ui_category = "Depth3D Guidelines";
	ui_category_closed = true;
	ui_label = " ";
	ui_type = "radio";
	>;
*/
	// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key using keycode info
	// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
	//	#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	//Extra Informaton
uniform int Extra_Information <
	ui_text =   "Preprocessors:\n"
				//"Color Correcting  | Is the process of restoring the original colors in the scenes.\n"
				//"Deband            | Is used to correct for banding issues in the image.\n"
				//"HDR compatibility | Allows for HDR support in the shader when HDR is available.\n"
				//"Inficolor 3D      | Modify the shader to accommodate Inficolor glasses for 3D content.\n"
				//"Reconstruction    | Is a diffrent way to render the images out.\n"
				"Cancel Depth Key  | Lets you set a key to disable Depth.\n"
				"                  | Ex. Key Code for Num Pad Decimal Point is 110.\n"
				"                  | Go-to http://keycode.info/ to look for other keys.\n"
				"\n"
				//"Active Keys:\n"
				//"Menu Key          | Is used to toggle on-screen information you see at startup.\n"
				//"Mouse Button 4    | Is used to unlock and lock the on screen cursor at default.\n"
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

	uniform bool CLK_04 < source = "mousebutton"; keycode = Mouse_Key_Four; toggle = true; mode = "toggle";>;
	uniform bool CLK_03 < source = "mousebutton"; keycode = Mouse_Key_Three; toggle = true; mode = "toggle";>;
	uniform bool CLK_02 < source = "mousebutton"; keycode = Mouse_Key_Two; toggle = true; mode = "toggle";>;

	uniform bool Trigger_Fade_A < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
	uniform bool Trigger_Fade_B < source = "mousebutton"; keycode = Fade_Key;>;
	uniform bool Menu_Open < source = "overlay_open"; >;
	uniform float2 Mousecoords < source = "mousepoint"; > ;
	uniform float frametime < source = "frametime";>;
	uniform bool Alternate < source = "framecount";>;     // Alternate Even Odd frames
	uniform int Frames < source = "framecount";>;     // Alternate Even Odd frames
	uniform float timer < source = "timer"; >;
	#define FLT_EPSILON  1.192092896e-07 // smallest such that Value + FLT_EPSILON != Value	
	
	float2 Divergence_Switch()
	{
		float2 Divergence = float2(100,Depth_Adjustment);
		#if Legacy_Mode
				Divergence = float2(Depth_Adjustment,100);
		#endif
		#if Inficolor_3D_Emulator
			#if Legacy_Mode
				Divergence.x = Depth_Adjustment.x * 0.5;
			#endif
			return float2(Divergence.x,Divergence.y * 0.5) + FLT_EPSILON;
		#else
			return Divergence + FLT_EPSILON;		
		#endif
	}

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
	
	#if HDR_Compatible_Mode == 1
		#define BC_SPACE 1
	#else
		#define BC_SPACE 0
	#endif

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
	sampler BackBuffer_SD
	{
		Texture = BackBufferTex;
	};	
		
	#if D_Frame	
		texture texCF { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = RGBA8; };
		
		sampler SamplerCF
		{
			Texture = texCF;		
		};
		
		texture texDF { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = RGBA8; };
		
		sampler DF_BackBufferMIRROR
		{
			Texture = texDF;
			AddressU = MIRROR;
			AddressV = MIRROR;
			AddressW = MIRROR;
		};
			
		sampler DF_BackBufferBORDER
		{
			Texture = texDF;
			AddressU = BORDER;
			AddressV = BORDER;
			AddressW = BORDER;
		};
			
		sampler DF_BackBufferCLAMP
		{
			Texture = texDF;
			AddressU = CLAMP;
			AddressV = CLAMP;
			AddressW = CLAMP;	
		};
		
		#define BackBuffer_M DF_BackBufferMIRROR
		#define BackBuffer_B DF_BackBufferBORDER
		#define BackBuffer_C DF_BackBufferCLAMP
		
		#define Non_Point_Sampler BackBuffer_C
		
	#else
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
		
		#define BackBuffer_M BackBufferMIRROR
		#define BackBuffer_B BackBufferBORDER
		#define BackBuffer_C BackBufferCLAMP

		#define Non_Point_Sampler BackBuffer_C
			
	#endif	
	
	texture texDMN { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = RG16F; MipLevels = Max_Mips; }; //Mips Used
	
	sampler SamplerDMN
		{
			Texture = texDMN;
		};
	#if WHM
		#define Color_Format_A RG8
	#else
		#define Color_Format_A R8
	#endif
	texture texCN { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = Color_Format_A; MipLevels = Max_Mips; }; //Mips Used
	
	sampler SamplerCN
		{
			Texture = texCN;
		};
	
	texture texzBufferN_P { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = RG16F; };
	
	sampler SamplerzBufferN_P
		{
			Texture = texzBufferN_P;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	
	texture texzBufferN_L { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = RG16F; MipLevels = 8; }; //Mips Used
	
	sampler SamplerzBufferN_L
		{
			Texture = texzBufferN_L;
		};
		
	#if Reconstruction_Mode || Virtual_Reality_Mode || Anaglyph_Mode
		#if BC_SPACE == 1
			#define Color_Format_B RGBA16
		#else
			#define Color_Format_B RGB10A2
		#endif
		#if !Anaglyph_Mode
		texture texSD_CB_L { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format_B;};
		
		sampler Sampler_SD_CB_L
			{
				Texture = texSD_CB_L;
			};
		texture texSD_CB_R { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format_B;};
		
		sampler Sampler_SD_CB_R
			{
				Texture = texSD_CB_R;
			};
		#else
		texture texSD_RL { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format_B; MipLevels = 1;};
		
		sampler Sampler_SD_RL
			{
				Texture = texSD_RL;
			};		
		#endif
	#endif

	#if DX9_Toggle
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = R16F; MipLevels = 6; }; // Needs to be RG16F If external Texture is given for DownSample. Not needed if external texture is already down sampled.
	#else
		#if TMD
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = RG16F; MipLevels = 6; }; // Needs to be RG16F If external Texture is given for DownSample. Not needed if external texture is already down sampled.
		#else
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = R16F; MipLevels = 6; }; // Needs to be RG16F If external Texture is given for DownSample. Not needed if external texture is already down sampled.
		#endif	
	#endif
		sampler SamplerzBuffer_BlurN
		{
			Texture = texzBufferBlurN;
		};
	//Can expand this to RG16F used to pass information to Avr Tex	
	texture texzBufferBlurEx < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = R16F;  };

	sampler SamplerzBuffer_BlurEx
	{
		Texture = texzBufferBlurEx;
	};
	
	texture texzBufferN_M { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = R16F; }; //Do not use mips in this buffer
	
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
	texture Info_Tex { Width = 960; Height = 540; Format = RGBA8;};
	sampler SamplerInfo { Texture = Info_Tex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

	#define Scale_Buffer 160 / BUFFER_WIDTH
	////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////
	texture texAvrN {Width = BUFFER_WIDTH * Scale_Buffer; Height = BUFFER_HEIGHT * Scale_Buffer; Format = RGBA16F; MipLevels = 8;}; //Mips Used

	sampler SamplerAvrB_N
		{
			Texture = texAvrN;
		};

	sampler SamplerAvrP_N
		{
			Texture = texAvrN;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
		
	float Avr_Mix(float2 texcoord)
	{ 
		return saturate(tex2Dlod(SamplerAvrB_N,float4(texcoord,0,11)).y);//Average Depth Brightnes Texture Sample
	}		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	float Min3(float x, float y, float z)
	{
	    return min(x, min(y, z));
	}
	
	float Max3(float x, float y, float z)
	{
	    return max(x, max(y, z));
	}
	
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
	
	static const float Auto_Balance_Clamp = 0.5; //This Clamps Auto Balance's max Distance.
	
	#if Compatibility_00
	uniform bool DepthCheck < source = "bufready_depth"; >;
	#endif

	float3 RE_Set(float Auto_Switch)
	{
		#if EDW // Set By SuperDepth3D
			float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff_A.x,ZPD_Boundary_n_Cutoff_B.x,ZPD_Boundary_n_Cutoff_C.x,ZPD_Boundary_n_Cutoff_D.x};		
		#else // Set by Overwatch
			#if OIL == 1
				float OIL_Switch[2] = {ZPD_Boundary_n_Cutoff_A.x,OIF.y};	
			#elif ( OIL == 2 )
				float OIL_Switch[3] = {ZPD_Boundary_n_Cutoff_A.x,OIF.y,OIF.z};	
			#elif ( OIL >= 3 )
				float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff_A.x,OIF.y,OIF.z,OIF.w};	
			#else
				float OIL_Switch[1] = {ZPD_Boundary_n_Cutoff_A.x};	
			#endif
		#endif 	
		int Scale_Auto_Switch = clamp((Auto_Switch * 5) - 1,0 , 3 );
		float Set_RE = OIL_Switch[Scale_Auto_Switch];

		int REF_Trigger = Set_RE > 0;
		
		//X is a Bool to enable the extra Levels
		//Y is the Set_Level Number from the auto Switch
		//Z is not used
		return float3(REF_Trigger, Set_RE , Scale_Auto_Switch); 
	}
	
	float4 RE_Set_Adjustments()
	{
		#if EDW // Set By SuperDepth3D
			float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff_A.x,ZPD_Boundary_n_Cutoff_B.x,ZPD_Boundary_n_Cutoff_C.x,ZPD_Boundary_n_Cutoff_D.x};		
		#else // Set by Overwatch
			#if OIL == 1
				float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff_A.x,OIF.y,0,0};	
			#elif ( OIL == 2 )
				float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff_A.x,OIF.y,OIF.z,0};	
			#elif ( OIL >= 3 )
				float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff_A.x,OIF.y,OIF.z,OIF.w};	
			#else
				float OIL_Switch[4] = {ZPD_Boundary_n_Cutoff_A.x,0,0,0};	
			#endif 
		#endif
		return float4(OIL_Switch[0], OIL_Switch[1], OIL_Switch[2], OIL_Switch[3]);
	}

	float2 RE_Extended()
	{
		#if EDW
		return ZPD_Boundary_n_Cutoff_End.xy;
		#else
		return DKK_W;
		#endif
	}

	float Scale(float val,float max,float min) //Scale to 0 - 1
	{
		return (val - min) / (max - min);
	}
	
	//Resolution Scaling because I can't tell your monitor size. Each level is 25 more then it should be.
	float CalculateMaxDivergence(uint x)
	{   // Doing what commented out does not work for some reason.So I have to do this strange thing below.
		//#define Max_Divergence (BUFFER_HEIGHT / 2160) * 100.
		//static const float Max_Divergence = (BUFFER_HEIGHT / 2160) * 100.; //BUFFER_WIDTH	
		float numerator = x;
		float denominator = 2160.0;
		
		float reciprocalDenominator = rcp(denominator);
		return numerator * reciprocalDenominator;
	}
  	
	float2 Min_Divergence() // and set scale
	{   
		float Diverge = Divergence_Switch().x;	    
		float Min_Div = max(1.0, Diverge), D_Scale = min(1.25,Scale(Min_Div,100.0,1.0));
		float MD_Adjust = CalculateMaxDivergence(BUFFER_HEIGHT) * 100.0;
		return float2(lerp( 1.0, MD_Adjust, D_Scale), D_Scale);
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
	float2 Re_Scale_WN()
	{   //float Near_Plane_Popout = WZPD_and_WND.x;//Old Way
		float Value = PopOut_Target;
		//int Switch = tex2Dlod(SamplerAvrP_N,float4(0.5.xx,0,12)).w > 0;
		float S_More = tex2D(SamplerzBufferN_L,0).y;
		//Value = Switch ? Value * 0.5 : Value;
		float Near_Plane_Popout = lerp( Value * 0.5, Value, S_More );
		return float2(abs(Near_Plane_Popout),Near_Plane_Popout >= 0 ? 100.0 : 75.0); // Used to be  0 : 1; Now I just set to Zero = 100.0 if One = 75.0 
	}	

	float Perspective_Switch()
	{  
	    float Scale_Value_Cal =  Re_Scale_WN().y;
	    	  Scale_Value_Cal *= CalculateMaxDivergence(BUFFER_HEIGHT); 
		float Min_Div = max(1.0, Divergence_Switch().x), D_Scale = Scale(Min_Div,100.0,1.0); 

		#if Virtual_Reality_Mode && !Super3D_Mode
		float Pers = IPD;
		#else
		#if Legacy_Mode
		float IC_Diverge = Divergence_Switch().x * 0.5;
		#else
		float IC_Diverge = Divergence_Switch().y;
		#endif
		float I_3D_Divergence = Eye_Swap ? IC_Diverge * lerp(0.25,0.75,1-Focus_Inficolor) : -IC_Diverge * lerp(0.25,0.75,1-Focus_Inficolor) ;	    	 
  	  float Pers = Inficolor_3D_Emulator ?  I_3D_Divergence : Perspective;
  	  #endif  	  
		float Perspective_Out = Pers, Push_Depth = (Re_Scale_WN().x*Scale_Value_Cal)*D_Scale;
		#if !Use_2D_Plus_Depth
			#if Legacy_Mode
			Perspective_Out = Inficolor_3D_Emulator ? I_3D_Divergence : Perspective;
			#else
			Perspective_Out = Eye_Swap ? Pers + Push_Depth : Pers - Push_Depth;
			#endif
		#endif
		return Perspective_Out;	
	}

	#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	#define Per Vert_3D_Pinball ? float2( 0, (Perspective_Switch() * pix.x) ) : float2( (Perspective_Switch() * pix.x), 0) //Per is Perspective
	#define Res int2(BUFFER_WIDTH, BUFFER_HEIGHT)
	#define AI Interlace_Optimization * 0.5 //Optimization for line interlaced Adjustment.
	#define ARatio pix.y / pix.x
				
	float RN_Value(float i)
	{
		return round(i * 10.0f);// * 0.1f;
	}
	
	float FN_Value(float i)
	{
		return floor(i * 10.0f);// * 0.1f;
	}

	float4 AdjustSaturation(float4 color)
	{ 
		float hueShift = 0.0;
		float saturation = 1+Saturation;

		// Hue adjustment
		float3 hueAdjust = 1.0 - min(abs(hueShift - float3(0.0, 2.0, 1.0)), 1.0);
		
		// Ensure red component consistency using dot product
		hueAdjust.x = 1.0 - dot(hueAdjust.yz, 1.0);
		
		// Apply hue adjustment to the input texture color
		float3 colorAdjusted = float3(
									    dot(color.xyz, hueAdjust.xyz),
									    dot(color.xyz, hueAdjust.zxy),
									    dot(color.xyz, hueAdjust.yzx)
									 );
		
		// Blend the adjusted color with grayscale
		float3 grayscale = dot(colorAdjusted, float3(0.333, 0.333, 0.333) );
		float3 finalColor = lerp(grayscale, colorAdjusted, saturation);

		return float4(finalColor, color.w);
	}
	
	float Vin_Pattern(float2 TC, float2 V_Power)
	{	//Focuse away from center
		TC *= (1.0 - TC.yx); 
	    float Vin = TC.x*TC.y * V_Power.x, Use_Depth = 1;// step(PrepDepth( texcoord.xy )[0][0] + 0.30, 0.375);
	    return 1-saturate(pow(abs(Vin),V_Power.y));	
	}
	///////////////////////////////////////////////////////////Conversions/////////////////////////////////////////////////////////////
	float3 RGBtoYCbCr(float3 rgb) // For Super3D a new Stereo3D output.
	{
		float Y  =  .299 * rgb.x + .587 * rgb.y + .114 * rgb.z; // Luminance
		float Cb = -.169 * rgb.x - .331 * rgb.y + .500 * rgb.z; // Chrominance Blue
		float Cr =  .500 * rgb.x - .419 * rgb.y - .081 * rgb.z; // Chrominance Red
		return float3(Y,Cb + 128./255.,Cr + 128./255.);
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
		#define Text_Timer 15000
	#else
		#define Text_Timer 12500
	#endif
	
	bool Helper_Fuction()
	{
		return tex2D(SamplerInfo,float2(0.911,0.968)).x;
	}

	float Info_Fuction()
	{
		return timer <= Text_Timer || Text_Info;
	}	

	float4 CSB(float2 texcoords)
	{ 
		float2 TC = -texcoords * texcoords*32 + texcoords*32;
		float Vin = Adjust_Vignette > 0 ? saturate(smoothstep(FLT_EPSILON,(FLT_EPSILON+Adjust_Vignette)*27.0f,TC.x * TC.y)) : 1;
		
		#if BC_SPACE == 1
		if(Custom_Sidebars == 0 && Depth_Map_View == 0)
			return NormalizeScRGB(tex2Dlod(BackBuffer_M,float4(texcoords,0,0)) *  Vin);
		else if(Custom_Sidebars == 1 && Depth_Map_View == 0)
			return NormalizeScRGB(tex2Dlod(BackBuffer_B,float4(texcoords,0,0)) *  Vin);
		else if(Custom_Sidebars == 2 && Depth_Map_View == 0)
			return NormalizeScRGB(tex2Dlod(BackBuffer_C,float4(texcoords,0,0)) *  Vin);
		else
			return NormalizeScRGB(tex2Dlod(SamplerzBufferN_P,float4(texcoords,0,0)).x);
		#else
		if(Custom_Sidebars == 0 && Depth_Map_View == 0)
			return tex2Dlod(BackBuffer_M,float4(texcoords,0,0)) *  Vin;
		else if(Custom_Sidebars == 1 && Depth_Map_View == 0)
			return tex2Dlod(BackBuffer_B,float4(texcoords,0,0)) *  Vin;
		else if(Custom_Sidebars == 2 && Depth_Map_View == 0)
			return tex2Dlod(BackBuffer_C,float4(texcoords,0,0)) *  Vin;
		else
			return tex2Dlod(SamplerzBufferN_P,float4(texcoords,0,0)).x;
		#endif

	}
	
	#if LBC || LBM || LB_Correction || LetterBox_Masking
	int LBSensitivity( float inVal )
	{
		#if LBS
			#if LBS == 2
			return inVal < 0.0225; //Even More Less Sensitive
			#else
			return inVal < 0.005; //Less Sensitive
			#endif
		#else
			return inVal == 0; //Sensitive
		#endif
	}
	
	float SLLTresh(float2 TCLocations, float MipLevel)
	{ 
		return tex2Dlod(SamplerCN,float4(TCLocations,0, MipLevel)).x;
	}
	
	bool LBDetection()//Active RGB Detection
	{   int Letter_Box_Center_Mips_Level_Senstivity = 7;   
		float2 Letter_Box_Reposition = float2(0.1,0.5);
		if (LBR == 1) 
			Letter_Box_Reposition = float2(0.250,0.875);
		if (LBR == 2) 
			Letter_Box_Reposition = float2(0.5,0.625);
		if (LBR == 3) 
			Letter_Box_Reposition = float2(0.50,0.5);
		
		if (LBI)
			Letter_Box_Reposition.x = 1-Letter_Box_Reposition.x;		
	
		if (LBL == 1)
			Letter_Box_Center_Mips_Level_Senstivity = 8;
		if (LBL == 2)
			Letter_Box_Center_Mips_Level_Senstivity = 9;
		if (LBL == 3)
			Letter_Box_Center_Mips_Level_Senstivity = 10;
		if (LBL >= 4)
			Letter_Box_Center_Mips_Level_Senstivity = 11;
			
		//Letter Box Detection Map
		
		//Center (0.5,0.5) 
		
		//Letter Box Reposition & Letter Box Elevation Zero
		//Top    (0.1,0.09)   LBE One = (0.1,0.045)  LBE Two = (0.1,0.035)  

		//Bottom (0.5,0.91)   LBE One = (0.5,0.955)  LBE Two = (0.5,0.965)
		
		//Letter Box Reposition One
		//Top    (0.250,0.09 )LBE One = (0.250,0.045)LBE Two = (0.250,0.035)

		//Bottom (0.875,0.91) LBE One = (0.875,0.955)LBE Two = (0.875,0.965)
		
		//Letter Box Reposition Two
		//Top    (0.5,0.09)   LBE One = (0.50,0.045) LBE Two = (0.5,0.035)
 
		//Bottom (0.625,0.91) LBE One = (0.625,0.955)LBE Two = (0.625,0.965)
		
		float2 Letter_Box_Elevation = LBE ? LBE == 2 ? float2(0.035,0.965) : float2(0.045,0.955) : float2(0.09,0.91);    
		float MipLevel = 5,Center = SLLTresh(float2(0.5,0.5), Letter_Box_Center_Mips_Level_Senstivity) > 0, 
			  Top_Pos = LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.x,Letter_Box_Elevation.x), MipLevel));
		if ( LetterBox_Masking == 2 || LB_Correction == 2 || LBC == 2 || LBM == 2 || SMP == 2)//Left_Center | Right_Center | Center
			return LBSensitivity(SLLTresh(float2(0.075,0.5), MipLevel)) && LBSensitivity(SLLTresh(float2(0.925,0.5), MipLevel)) && Center; //Vert
		else       //Top | Bottom | Center
			return Top_Pos && LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.y,Letter_Box_Elevation.y), MipLevel)) && Center; //Hoz
	}
	#else
	bool LBDetection()//Stand in for not crashing when not in use
	{	
		return 0;
	}	
	#endif

	#if MMD || MDD || SMD || TMD || SUI || SDT || SD_Trigger
	float3 C_Tresh(float2 TCLocations)//Color Tresh
	{ 
		return tex2Dlod(Non_Point_Sampler,float4(TCLocations,0, 0)).rgb;
	}
	
	bool Check_Color(float2 Pos_IN, float C_Value)
	{	float3 RGB_IN = C_Tresh(Pos_IN);
		return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) == C_Value;
	}
	
		#if SDT || SD_Trigger	
		float SDT_Lock_Menu_Detection()//Active RGB Detection
		{ 
			float2 Pos_A = DKK_X.xy, Pos_B = DKK_X.zw, Pos_C = DKK_Y.xy;
			float4 ST_Values = DKK_Z;
	
			//Wild Card Always On
			float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
			float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
			
			float Menu_Detection = Menu_X &&                          //X & W is wiled Card.
								   Check_Color(Pos_B, ST_Values.y) && //Y
								   Menu_Z;                            //Z & W is wiled Card.
	
			return !(Menu_Detection > 0);
		}
		#endif
	
		#if LMD //Text Menu Detection One
		float Lock_Menu_Detection()//Active RGB Detection
		{ 
			float Menu_Detection_0, Menu_Detection_1;
			float2 Pos_A_0 = DCC_X.xy, Pos_B_0 = DCC_X.zw, Pos_C_0 = DCC_Y.xy;
			float4 ST_Values_0 = DCC_Z;
	
			//Wild Card Always On
			float Menu_X_0 = Check_Color(Pos_A_0, ST_Values_0.x) || Check_Color(Pos_A_0, ST_Values_0.w);
	
			float Menu_Z_0 = Check_Color(Pos_C_0, ST_Values_0.z) || Check_Color(Pos_C_0, ST_Values_0.w);
			
			Menu_Detection_0 = Menu_X_0 &&                          //X & W is wiled Card.
							   Check_Color(Pos_B_0, ST_Values_0.y) && //Y
							   Menu_Z_0;                            //Z & W is wiled Card.
								   
			#if LMD > 1 //Text Menu Detection Two
				float2 Pos_A_1 = DMM_X.xy, Pos_B_1 = DMM_X.zw, Pos_C_1 = DMM_Y.xy;
				float4 ST_Values_1 = DMM_Z;
		
				//Wild Card Always On
				float Menu_X_1 = Check_Color(Pos_A_1, ST_Values_1.x) || Check_Color(Pos_A_1, ST_Values_1.w);
		
				float Menu_Z_1 = Check_Color(Pos_C_1, ST_Values_1.z) || Check_Color(Pos_C_1, ST_Values_1.w);
				
				Menu_Detection_1 = Menu_X_1 &&                          //X & W is wiled Card.
								   Check_Color(Pos_B_1, ST_Values_1.y) && //Y
								   Menu_Z_1;                            //Z & W is wiled Card.
			#endif	
	
			//return !(Menu_Detection_0 > 0);
			return (Menu_Detection_0 <= 0) || (Menu_Detection_1 <= 0);
		}
		#else
		float Lock_Menu_Detection()
		{ 
			return true;
		}
		#endif		
	#endif
	
	#if MDD || SMD || TMD || SUI
		#if MDD
		int Color_Likelyhood(float2 Pos_IN, float C_Value, int Switcher)
		{ 
			return Check_Color(Pos_IN,C_Value) ? Switcher : 0;
		}	
		
		float2 Menu_Size()//Active RGB Detection
		{ 
	
			float2 Pos_A = DN_X.xy, Pos_B = DN_X.zw, Pos_C = DN_Y.xy,
				   Pos_D = DN_Y.zw, Pos_E = DN_Z.xy, Pos_F = DN_Z.zw;
			float Menu_Size_Selection[5] = { 0.0, DN_W.x, DN_W.y, DN_W.z, DN_W.w };
			float4 MT_Values = DJ_Y;
			float4 SMT_Values = DJ_Z;
			//Wild Card Always On
			float Menu_X = Check_Color(Pos_A, MT_Values.x) || Check_Color(Pos_A, MT_Values.w); 
			float Menu_Z = Check_Color(Pos_C, MT_Values.z) || Check_Color(Pos_C, MT_Values.w);
			
			float Menu_Detection = Menu_X &&                                //X & W is wiled Card.
				   				Check_Color(Pos_B, MT_Values.y) &&       //Y
				  				 Menu_Z,                                  //Z & W is wiled Card.
				  Menu_Change = Menu_Detection + Color_Likelyhood(Pos_D, SMT_Values.x , 1) + Color_Likelyhood(Pos_E, SMT_Values.y , 2) + Color_Likelyhood(Pos_F, SMT_Values.z, 3);
			if(Lock_Menu_Detection())
				return float2(Menu_Detection > 0 ? Menu_Size_Selection[clamp((int)Menu_Change,0,4)] : 0, SMT_Values.w);
			else
				return 0;
		}		
		#endif

			#if SUI //Stencil UI & Detection
				float Stencil_n_Detection_A()//Active RGB Detection
				{ 
					float2 Pos_A = DDD_X.xy, Pos_B = DDD_X.zw, Pos_C = DDD_Y.xy;
					float4 ST_Values = DDD_Z;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					if( ISD )
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					else
						return (Menu_Detection > 0);
				}
				#if SUI >= 2
				float Stencil_n_Detection_B()//Active RGB Detection
				{ 
					float2 Pos_A = DEE_X.xy, Pos_B = DEE_X.zw, Pos_C = DEE_Y.xy;
					float4 ST_Values = DEE_Z;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					if( ISD )
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					else
						return (Menu_Detection > 0);
				}
				#endif
				#if SUI >= 3
				float Stencil_n_Detection_C()//Active RGB Detection
				{ 
					float2 Pos_A = DFF_X.xy, Pos_B = DFF_X.zw, Pos_C = DFF_Y.xy;
					float4 ST_Values = DFF_Z;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					if( ISD )
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					else
						return (Menu_Detection > 0);
				}
				#endif
				#if SUI >= 4
				float Stencil_n_Detection_D()//Active RGB Detection
				{ 
					float2 Pos_A = DGG_X.xy, Pos_B = DGG_X.zw, Pos_C = DGG_Y.xy;
					float4 ST_Values = DGG_Z;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					if( ISD )
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					else
						return (Menu_Detection > 0);
				}
				#endif
				#if SUI >= 5
				float Stencil_n_Detection_E()//Active RGB Detection
				{ 
					float2 Pos_A = DJJ_X.xy, Pos_B = DJJ_X.zw, Pos_C = DJJ_Y.xy;
					float4 ST_Values = DJJ_Z;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					if( ISD )
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					else
						return (Menu_Detection > 0);	
				}
				#endif
				#if SUI >= 6
				float Stencil_n_Detection_F()//Active RGB Detection
				{ 
					float2 Pos_A = DLL_X.xy, Pos_B = DLL_X.zw, Pos_C = DLL_Y.xy;
					float4 ST_Values = DLL_Z;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					if( ISD )
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					else
						return (Menu_Detection > 0);	
				}
				#endif
			#endif
	
			#if SMD //Simple Menu Detection	
			float Simple_Menu_A()//Active RGB Detection
			{ 
				float2 Pos_A = DW_X.xy, Pos_B = DW_X.zw, Pos_C = DW_Y.xy;
				float4 ST_Values = DW_Z;
		
				//Wild Card Always On
				float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);

				float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
				
				float Menu_Detection = Menu_X &&                          //X & W is wiled Card. 
									   Check_Color(Pos_B, ST_Values.y) && //Y
									   Menu_Z;                            //Z & W is wiled Card.
		
				return (Menu_Detection > 0) && Lock_Menu_Detection();
			}
				#if SMD >= 2
				float Simple_Menu_B()//Active RGB Detection
				{ 
					float2 Pos_A = DT_X.xy, Pos_B = DT_X.zw, Pos_C = DT_Y.xy;
					float4 ST_Values = DW_W;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card.
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					return (Menu_Detection > 0) && Lock_Menu_Detection();
				}
				#endif

					#if SMD >= 3
					float Simple_Menu_C()//Active RGB Detection
					{ 
						float2 Pos_A = DAA_X.xy, Pos_B = DAA_X.zw, Pos_C = DAA_Y.xy;
						float4 ST_Values = DAA_Z;
				
						//Wild Card Always On
						float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
		
						float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
						
						float Menu_Detection = Menu_X &&                          //X & W is wiled Card.
											   Check_Color(Pos_B, ST_Values.y) && //Y
											   Menu_Z;                            //Z & W is wiled Card.
				
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					}
					#endif
				
						#if SMD >= 4
						float Simple_Menu_D()//Active RGB Detection
						{ 
							float2 Pos_A = DBB_X.xy, Pos_B = DBB_X.zw, Pos_C = DBB_Y.xy;
							float4 ST_Values = DBB_Z;
					
							//Wild Card Always On
							float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
			
							float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
							
							float Menu_Detection = Menu_X &&                          //X & W is wiled Card.
												   Check_Color(Pos_B, ST_Values.y) && //Y
												   Menu_Z;                            //Z & W is wiled Card.
					
							return (Menu_Detection > 0) && Lock_Menu_Detection();
						}
						#endif
						
							#if SMD >= 5
							float Simple_Menu_E()//Active RGB Detection
							{ 
								float2 Pos_A = DHH_X.xy, Pos_B = DHH_X.zw, Pos_C = DHH_Y.xy;
								float4 ST_Values = DHH_Z;
						
								//Wild Card Always On
								float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
				
								float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
								
								float Menu_Detection = Menu_X &&                          //X & W is wiled Card.
													   Check_Color(Pos_B, ST_Values.y) && //Y
													   Menu_Z;                            //Z & W is wiled Card.
						
								return (Menu_Detection > 0) && Lock_Menu_Detection();
							}
							#endif
							
								#if SMD >= 6
								float Simple_Menu_F()//Active RGB Detection
								{ 
									float2 Pos_A = DII_X.xy, Pos_B = DII_X.zw, Pos_C = DII_Y.xy;
									float4 ST_Values = DII_Z;
							
									//Wild Card Always On
									float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
					
									float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
									
									float Menu_Detection = Menu_X &&                          //X & W is wiled Card.
														   Check_Color(Pos_B, ST_Values.y) && //Y
														   Menu_Z;                            //Z & W is wiled Card.
							
									return (Menu_Detection > 0) && Lock_Menu_Detection();
								}
								#endif

			#endif
			
			#if TMD //Text Menu Detection
				#if TMD == 1
				#else
				float Text_Menu_Detection()//Active RGB Detection
				{ 
					float2 Pos_A = DZ_X.xy, Pos_B = DZ_X.zw, Pos_C = DZ_Y.xy;
					float4 ST_Values = DZ_Z;
			
					//Wild Card Always On
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W is wiled Card.
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W is wiled Card.
			
					return (Menu_Detection > 0) && Lock_Menu_Detection();
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
			  //Scale_Depth *= smoothstep(0.5,0,Depth);
			  Mod_Depth = (Mod_Depth - Set_Weapon_Scale_Near) / (1.0 + Set_Weapon_Scale_Near);
		float Near_Mod_Depth =  Scale_Depth * Mod_Depth;
		float WDE_W = Weapon_Depth_Edge.w >= 0 ? Weapon_Depth_Edge.w : lerp(abs(Weapon_Depth_Edge.w) * 0.5,abs(Weapon_Depth_Edge.w),saturate(tex2D(SamplerzBufferN_L,0).y * 2));
	    return lerp(Depth, lerp(Mod_Depth,Near_Mod_Depth + WDE_W,saturate((1-Depth)*0.125)), EdgeMask );   
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

	float4 MouseCursor(float3 texcoord , float2 pos, int Switch,int UI_Mode )
	{ 
			//DX9 fails if I don't use tex2Dlod here
			float4 Out = UI_Mode ? tex2Dlod(BackBuffer_SD,float4(texcoord.xy,0,0)) : CSB(texcoord.xy),Color, Exp_Darks, Exp_Brights;
			float Cursor;
			if(Cursor_Type > 0 && Switch)
			{
				float CCScale = lerp(0.005,0.025,Scale(Cursor_SC.x,10,0));//scaling
				float2 MousecoordsXY = texcoord.xy - (Mousecoords * pix), Scale_Cursor = float2(CCScale,CCScale* ARatio );

				bool CLK_L = !Cursor_Lock;
				
				if(Cursor_Lock_Button_Selection == 1)
					CLK_L = CLK_02;
				if(Cursor_Lock_Button_Selection == 2)
					CLK_L = CLK_03;					
				if(Cursor_Lock_Button_Selection == 3)
					CLK_L = CLK_04;	
			
				if (!CLK_L)
				MousecoordsXY = texcoord.xy - float2(0.5,lerp(0.5,0.5725,Scale(Cursor_SC.z,10,0) ));

				bool CLK_T = Toggle_Cursor;

				if(Cursor_Toggle_Button_Selection == 1)
					CLK_T = CLK_02;
				if(Cursor_Toggle_Button_Selection == 2)
					CLK_T = CLK_03;					
				if(Cursor_Toggle_Button_Selection == 3)
					CLK_T = CLK_04;
					
				if(!CLK_T)
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
		#if Enable_Deband_Mode
			if(Toggle_Deband)
			{
				//Code I asked Marty McFly | Pascal for and he let me have.
				const float SEARCH_RADIUS = 1, Depth_Sample = tex2Dlod(SamplerzBufferN_P,float4(texcoord.xy,0,0)).x < 0.98;
				const float2 magicdot = float2(0.75487766624669276, 0.569840290998);
				const float3 magicadd = float3(0, 0.025, 0.0125) * dot(magicdot, 1);
				float3 dither = frac(dot(pos.xy, magicdot) + magicadd);
				
				//LinerSampleDepth
				float LinerSampleDepth = rcp( exp2( BUFFER_COLOR_BIT_DEPTH ) - 1.0);
				
				float2 shift;
				sincos(6.283 * 30.694 * dither.x, shift.x, shift.y);
				shift = shift * dither.x - 0.5;
				
				texcoord.xy = texcoord.xy + lerp(0,37.5 * pix,SEARCH_RADIUS);
				
				float3 scatter =  CSB(texcoord.xy + shift * lerp(0,pix * 75,SEARCH_RADIUS)).rgb;
				float3 diff = Depth_Sample ? abs(Out.rgb - scatter) : all(Out.rgb - scatter); 
					   diff.x = max(max(diff.x, diff.y), diff.z) ;
				
				Out.rgb = lerp(Out.rgb, scatter, diff.x <= LinerSampleDepth);
			}
		#endif				
			
			Out = Cursor ? Color.rgb : Out.rgb;
		#if Inficolor_3D_Emulator
			float3 ReGamma = regamma(Out.rgb), blend_RGB = float3(dot(ReGamma, float3(1,-1,-1)), dot(ReGamma, float3(-1,1,-1)),dot(ReGamma, float3(-1,-1,1))) ;
	    	Out.r *= lerp(1,lerp(1, 0.5, smoothstep(-0.250, 0.0, blend_RGB.r)),Inficolor_Reduce_RGB.x);
	    	Out.g *= lerp(1,lerp(1, 0.5, smoothstep(-0.375, 0.0, blend_RGB.g)),Inficolor_Reduce_RGB.y);
	    	Out.b *= lerp(1,lerp(1, 0.5, smoothstep(-0.500, 0.0, blend_RGB.b)),Inficolor_Reduce_RGB.z);
	    #endif
			return float4(Out.rgb,texcoord.z);
	}
	
	//////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////

	float DMA() //Small List of internal Multi Game Depth Adjustments.
	{ 
		float NP_Adjust_Value = 1.0;
		
		#if MGA > 0
		if(Set_Game_Profile > 0)
			NP_Adjust_Value = dot(DNN_W, float4(Set_Game_Profile == 1, Set_Game_Profile == 2, Set_Game_Profile == 3, Set_Game_Profile == 4));
		#endif
		
		#if !OSW 
		return DMA_Overwatch( WP, Depth_Map_Adjust) * NP_Adjust_Value;
		#else
		return Depth_Map_Adjust * NP_Adjust_Value;
		#endif
	}

	float2 ScaleSize(float2 Starting_Size, float2 Current_Size) 
	{	
	    // Calculate the scaling factor as the ratio of heights between Current_Size and Starting_Size
 	   float2 scaleFactor_XY = Current_Size.xy / Starting_Size.xy;
	    return scaleFactor_XY;
	}
	
	float Depth(float2 texcoord)
	{   //May have to move this around. But, it seems good in it's current location.
		#if !Compatibility_01	
		float2 Current_Size = tex2Dsize(DepthBuffer);
		float2 Adjust_Size_XY = ScaleSize(Starting_Resolution, Current_Size); 
		
		if(Adjust_Size_XY.y != 0 && Starting_Resolution.y != 0)	
			texcoord.y = texcoord.y / Adjust_Size_XY.y;
			
		if(Adjust_Size_XY.x != 0 && Starting_Resolution.x != 0)	
			texcoord.x = texcoord.x / Adjust_Size_XY.x;
		#endif
        //Conversions to linear space.....
		float zBuffer = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x;

		// Set RangeBoost based on Range_Boost value
		float RangeBoost = (Range_Boost == 3) ? 2.0 :
		                   (Range_Boost == 4) ? 3.0 :
		                   (Range_Boost == 5) ? 4.0 : 1.5;

		//define near/far values with adjustments		                   
		float Far = 1.0, FLT_DMA = DMA() + FLT_EPSILON;
		float Near_A = 0.125 / FLT_DMA;
		float Near_B = 0.125 / (FLT_DMA * RangeBoost);
		
		float2 Two_Ch_zBuffer, Store_zBuffer = float2( zBuffer, 1.0 - zBuffer );
		float4 C = float4( Far / Near_A, 1.0 - Far / Near_A, Far / Near_B, 1.0 - Far / Near_B);

	    float InputSwitch = tex2Dlod(SamplerAvrP_N,float4(1, 0.8125,0,0)).z; //tex2D(SamplerzBuffer_BlurN,float2(0,0.9375)).x
	    if(DOL.x > 0)
			InputSwitch = int(InputSwitch * 5 ) >= DOL.y;		
		else
			InputSwitch = 1;
		
		float2 O = InputSwitch ? Offset : 0.0;
		float2 Z = O.x < 0 ? 
								min( 1.0, zBuffer * ( 1.0 + abs(O.x) ) ) : 
																			  Store_zBuffer;
		//May add this later need to check emulators.
		//if (Range_Boost == 2)
		//	Store_zBuffer = Z;
	
		if(O.x != 0)
			Z = O.x < 0 ? float2( Z.x, 1.0 - Z.y ) 
													  : 
													    min( 1.0, float2( Z.x * (1.0 + O.x) , Z.y / (1.0 - O.x) ) );
		if(O.y != 0)
			Z = pow(Z,1+O.y);
		
		float2 C_Switch = Range_Boost >= 2 ? C.zw : C.xy;
			
		if (Depth_Map == 0) //DM0 Normal
			Two_Ch_zBuffer = rcp(float2(Z.x,Store_zBuffer.x) * float2(C_Switch.y,C.y) + float2(C_Switch.x,C.x));//MAD - RCP
		else if (Depth_Map == 1) //DM1 Reverse
			Two_Ch_zBuffer = rcp(float2(Z.y,Store_zBuffer.y) * float2(C_Switch.y,C.y) + float2(C_Switch.x,C.x));//MAD - RCP
		
		if(Range_Boost)//Offset Based
			zBuffer = lerp(Two_Ch_zBuffer.y,Two_Ch_zBuffer.x,saturate(Two_Ch_zBuffer.y));
		else
			zBuffer = Two_Ch_zBuffer.x;

		#if ALM == 1
			return smoothstep(0,1,zBuffer);
		#else
			return saturate(zBuffer);
		#endif
	}

	#if SDT || SD_Trigger
	float TargetedDepth(float2 TC)
	{
		return smoothstep(0,1,Depth(TC).x);
	}
	
	float SDTriggers()//Specialized Depth Triggers
	{   float Threshold = 0.001;//Both this and the options below may need to be adjusted. A Value lower then 7.5 will break this.!?!?!?!
		if ( SD_Trigger == 1 || SDT == 1)//Top _ Left                             //Center_Left                             //Botto_Left
			return (TargetedDepth(float2(0.95,0.25)) >= Threshold ) && (TargetedDepth(float2(0.95,0.5)) >= Threshold) && (TargetedDepth(float2(0.95,0.75)) >= Threshold) ? 0 : 1;
		else if ( SD_Trigger == 3 || SDT == 3) //Top Center                     Center                           Bottom Center                   
			return (TargetedDepth(float2(0.25,0.9)) >= 1 ) && (TargetedDepth(float2(0.5,0.5)) < 1) && (TargetedDepth(float2(0.75,0.9)) >= 1) ? 1 : 0;			
		else
			return ((TargetedDepth(float2(0.5,0.10)) <= 1 ) && //Top
				   ((TargetedDepth(float2(0.5,0.25)) <= 1 ) && //Center Top
					(TargetedDepth(float2(0.5,0.50)) <= 1 ))&& //Center
					(TargetedDepth(float2(0.5,0.75)) <  1 ) && //Center Bottom
					(TargetedDepth(float2(0.5,0.90)) <  1 ))? 0 : 1;//Bottom
	}
	#endif	
	
	float4 TC_SP(float2 texcoord)
	{  
		float LBDetect = tex2Dlod(SamplerAvrP_N,float4(1, 0.0625,0,0)).z;
		//Need to work on this later. So far it seem fine.....
		float2 H_V_A, H_V_B, X_Y_A, X_Y_B, S_texcoord = texcoord;
		bool SDT_Bool = 1;
		
		#if SDT == 3 || SD_Trigger == 3
			SDT_Bool = SDTriggers();
		#endif
		
		#if DB_Size_Position || SPF || LBC || LB_Correction

			#if LBC || LB_Correction
				X_Y_A = Image_Position_Adjust + (LBDetect && SDT_Bool && LB_Correction_Switch ? Image_Pos_Offset : 0.0f ); //Error Used here as a trigger
			#else
				X_Y_A = float2(Image_Position_Adjust.x,Image_Position_Adjust.y);
			#endif

		texcoord.xy += float2(-X_Y_A.x,X_Y_A.y)*0.5;
		
			#if LBC || LB_Correction
				H_V_A = Horizontal_and_Vertical * (LBDetect && SDT_Bool && LB_Correction_Switch ? H_V_Offset : 1.0f );     //Error Used here as a trigger
				//H_V_B = Horizontal_and_Vertical * H_V_Offset;	
			#else
				H_V_A = Horizontal_and_Vertical;
			#endif
			
		float2 midHV_A = (H_V_A-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
		texcoord = float2((texcoord.x*H_V_A.x)-midHV_A.x,(texcoord.y*H_V_A.y)-midHV_A.y);
		//Non LB Resizing.
		if(!Flip_HV_Scale)
			texcoord *= Horizontal_and_Vertical_TL;
		else
		{
			texcoord = 1-texcoord;
			texcoord = 1-texcoord * Horizontal_and_Vertical_TL;
		}
		#endif
		//Need to add a method to disable this when three pixels are detected.
		//Will to this Someday.
		#if SDT || SD_Trigger		
			X_Y_B = Image_Position_Adjust + float2(DG_X,DG_Y);
			
			S_texcoord.xy += float2(-X_Y_B.x,X_Y_B.y)*0.5;
			//Will work on this later.
			//float2 midHV_B = (H_V_B-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
			//S_texcoord = float2((S_texcoord.x*H_V_B.x)-midHV_B.x,(S_texcoord.y*H_V_B.y)-midHV_B.y);
		#endif
		
		return float4(texcoord,S_texcoord);
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
	#define WPPP 1
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
		//texcoord.xy *= TEST.x; //Need to do a best Guess algo for standared DLSS,FSR,and XeSS
		texcoord.xy -= DLSS_FSR_Offset.xy * pix;

		float SS_Scaling = 1;
		//Select_SS 0 //DLSS
		//Select_SS 1 //FSR
		//Select_SS 2 //XeSS
		//Select_SS 3 //Custom
		if(Select_SS == 3)
		{
		    switch (Easy_SS_Scaling) 
		    {
		        case 1:
		            SS_Scaling = 1.2195;
		            break;
		        case 2:
		            SS_Scaling = 1.460;
		            break;
		        case 3:
		            SS_Scaling = 1.818;
		            break;
		        case 4:
		            SS_Scaling = 2.513;
		            break;
		    }
		}
		else
		{
		    switch (Easy_SS_Scaling) 
		    {
		        case 1:
		            SS_Scaling = Select_SS == 2 ? 1.303 : 1.5;
		            break;
		        case 2:
		            if(Select_SS == 2)
		                SS_Scaling = 1.5;
		            else
		                SS_Scaling = Select_SS == 1 ? 1.7 : 1.73;
		            break;
		        case 3:
		            SS_Scaling = Select_SS == 2 ? 1.7 : 2.0;
		            break;
		        case 4:
		            SS_Scaling = Select_SS == 2 ? 2.0 : 3.0;
		            break;
		    }
		}
		
		texcoord.xy /= SS_Scaling;
		//texcoord.xy /= TEST;
		
        //Manual Adjustment
		//texcoord *= 1-clamp(SS_Scaling_Adjuster,-0.5,0.5);	

	
		float4 DM = Depth(TC_SP(texcoord).xy).xxxx;
		float R, G, B, A, WD = WeaponDepth(TC_SP(texcoord).xy).x, CoP = WeaponDepth(TC_SP(texcoord).xy).y, CutOFFCal = (CoP/DMA()) * 0.5; //Weapon Cutoff Calculation
		CutOFFCal = step(DM.x,CutOFFCal);
	
		[branch] 
		if (WP == 0)
			DM.x = DM.x;
		else if(WP != 0 && WMM == 1)//Weapon Mix Mode added for Doom The Dark Ages
		{
			DM.x = DM.x;
			DM.y = lerp(0.0,WD,CutOFFCal);
			DM.z = lerp(0.5,WD,CutOFFCal);
			DM.x = lerp(lerp(DM.y,DM.x,0.5),DM.x,DM.x);
		}	
		else
		{
			//DM.x = lerp(DM.x,WD,CutOFFCal); // Removed
			DM.y = lerp(0.0,WD,CutOFFCal);
			DM.z = lerp(0.5,WD,CutOFFCal);
		}
		
		float Weapon_Masker = lerp(0.0,WD,CutOFFCal);
	
		R = DM.x; //Mix Depth
		G = DM.z; //Weapon Hand
		B = DM.y > saturate(smoothstep(0,2.5,DM.w)); //Weapon Mask
		
		#if IWS
		float Isolating_Weapon_Stencil = texcoord.x+(texcoord.y*0.5) < DCC_W;
		A = ZPD_Boundary >= 4 ? Isolating_Weapon_Stencil ? R : max( B, R) : R; //Grid Depth Stenciled
		#else
		A = ZPD_Boundary >= 4 ? max( B, R) : R; //Grid Depth
		#endif
	
		#if HUD_MODE || HMT
		float HUDCutOFFCal = ((HUD_Adjust.x * 0.5)/DMA()) * 0.5;
		
		float COC = step(DM.w,HUDCutOFFCal); //HUD Cutoff Calculation
		
		//This code is for hud segregation.
		if (HUD_Adjust.x > 0)
			A = COC ? 0.5 : A;
		#endif
		
		return float3x3( saturate(float3(R, G, 0)),											  //[0][0] = R | [0][1] = G | [0][2] = B
						 saturate(float3(A, Depth( TC_SP(texcoord).xy ).x, DM.w)),			   //[1][0] = A | [1][1] = D | [1][2] = DM
								  float3(Weapon_Masker > saturate(smoothstep(0,2.5,DM.w)),0,0) );//[2][0] = 0 | [2][1] = 0 | [2][2] = 0
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
	float Fade_in_out()
	{ float TCoRF[1], Trigger_Fade, AA = Fade_Time_Adjust, PStoredfade = tex2D(SamplerAvrP_N,float2(0,0.0625)).z;
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
		#if SUI
		float SnD_Toggle = SNA ? Stencil_n_Detection_A() : 0;
			#if SUI >= 2
			  SnD_Toggle = SNB ? Stencil_n_Detection_B() : SnD_Toggle;
			#endif
				#if SUI >= 3
				  SnD_Toggle = SNC ? Stencil_n_Detection_C() : SnD_Toggle;
				#endif
					#if SUI >= 4
					  SnD_Toggle = SND ? Stencil_n_Detection_D() : SnD_Toggle;
					#endif
						#if SUI >= 5
						  SnD_Toggle = SNE ? Stencil_n_Detection_E() : SnD_Toggle;
						#endif
							#if SUI >= 6
							  SnD_Toggle = SNF ? Stencil_n_Detection_F() : SnD_Toggle;
							#endif
		#else
		float SnD_Toggle = 0;
		#endif
	
		//Fade in toggle.
		if(FPSDFIO == 1 )
			Trigger_Fade = Trigger_Fade_A;
		else if(FPSDFIO == 2)
			Trigger_Fade = Trigger_Fade_B;
		else if(FPSDFIO == 3)
			Trigger_Fade = SnD_Toggle;
		else if(FPSDFIO == 4)
			Trigger_Fade = Trigger_Fade_A || SnD_Toggle;			
		else if(FPSDFIO == 5)
			Trigger_Fade = Trigger_Fade_B || SnD_Toggle;
			
		if(Toggle_On_Boundary)	
		{
		    if( WP > 0)
				Trigger_Fade = tex2D(SamplerAvrP_N, float2(1, 0.6875)).z >= 1 && Trigger_Fade;
			else //tex2Dlod(SamplerAvrP_N,float4(1, 0.1875,0,0)).z = N
				Trigger_Fade = tex2D(SamplerAvrP_N, float2(0, 0.1875)).z > 0.125 && Trigger_Fade;
		}
		
		return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/((1-AA)*1000))); ///exp2 would be even slower
	}
	
	float Auto_Adjust_Cal(float Val)
	{
		return (1-(Val*2.))*1000;
	}

	bool CWH_Mask(float2 StoredTC)
	{
		//Create Mask for Weapon Hand Consideration for ZPD boundary condition.
		float2 Shape_TC = StoredTC;
		float Shape_Out, Shape_One, Shape_Two, Shape_Three, Shape_Four, SO_Switch = 0.75, ST_Switch = 0.45, FO_Switch = 0.8125, STT_Switch = 0.35, SF_Switch = 0.550, STTT_Switch = 0.45;
		
		if(CWH >= 3 && CWH <= 4)
		{
			SO_Switch = 0.325;
			ST_Switch = 0.75 ;
		}
	
		if(CWH == 5)
		{
			FO_Switch = 0.5;
		}
		
		if(CWH == 6)
		{
			STT_Switch = 0.55;
			SF_Switch = 0.675;
			ST_Switch = 0.325;
			STTT_Switch = 0.4;
		}	
	
		if(CWH == 7)
		{
			STT_Switch = 0.1875;
			SF_Switch = 0.75;
			//ST_Switch = 0.325;
			STTT_Switch = 0.4;
		}

		if(CWH == 8)
		{
			//STT_Switch = 0.25;
			SF_Switch = 0.75;
			//ST_Switch = 0.325;
			//STTT_Switch = 0.4;
			SO_Switch = 0.625;
			
		}

		if(CWH == 10)
		{
			ST_Switch = 0.2;
		}

		// Conditions for Shape_One
		bool Shape_One_C1 = (Shape_TC.x / Shape_TC.y * SO_Switch) > 1;
		bool Shape_One_C2 = (((1 - Shape_TC.x) / Shape_TC.y) * FO_Switch ) > 1;
		Shape_One = saturate(Shape_One_C1 || Shape_One_C2); 
		
		// Conditions for Shape_Two
		bool Shape_Two_C1 = (1 - Shape_TC.x < STTT_Switch && 1 - Shape_TC.y < ST_Switch);
		Shape_Two = saturate(1 - Shape_Two_C1); 
		
		// Conditions for Shape_Three
		float Shape_Three_C1 = (1 - Shape_TC.x - STT_Switch) / (1 - Shape_TC.y);
		Shape_Three = saturate(Shape_Three_C1 > 1); 
		
		// Conditions for Shape_Four
		float Shape_Four_C1 = Shape_TC.x < 0.3  && 1-Shape_TC.x < 0.9 && Shape_TC.y > SF_Switch;
		Shape_Four = 1-Shape_Four_C1; 
		
		// Calculate Shape_Out
		Shape_Out = Shape_One + (1 - Shape_Three);
		Shape_Out *= Shape_One + Shape_Two;
		Shape_Out *= Shape_Four;

		if(CWH == 2 || CWH == 4 && CWH != 5)
		Shape_Out = Shape_TC.x < 0.5 ? 1 : Shape_Out;
		
		if(CWH == 7 || CWH == 9 || CWH == 10)
			Shape_Out = Shape_TC.x < 0.125 || Shape_TC.x > 0.875 || Shape_TC.y < 0.7 ? 1 : Shape_Out;
		
		return Shape_Out;
	}			

	float2 Shift_Mask(float2 texcoord)
	{
		float4 Shift_XY = floor(texcoord.xxyy * Res.xxyy * pix.xxyy * float4(7,9,7,9));
		return float2(fmod(Shift_XY.x,2),fmod(ZPD_Boundary == 3 ? Shift_XY.w : Shift_XY.z,2));
	}
	/*
	float P_Depth(float2 TC)
	{
		//A = ZPD_Boundary >= 4 ? max( B, R) : R; //Grid Depth
		float2 MD_W = tex2Dlod(SamplerDMN,float4(TC,0,0)).xy;
		float W_Masking = MD_W.y == 0.5 ? 0 : 1;
		MD_W.x = ZPD_Boundary >= 4 ? max( W_Masking, MD_W.x) : MD_W.x; //Grid Depth
		return MD_W.x;
	}
	*/
	float3x3 Fade(float2 texcoord)
	{   //Check Depth
		float CD, Detect, Detect_Out_of_Range = -1, ZPD_Scaler_One_Boundary = Set_Pop_Min().x;//Done to not trigger FTM if set to 0
		if(ZPD_Boundary > 0)
		{
			int Detect_More_Mode = DMM;
			#if LBM || LetterBox_Masking
			const float2 LB_Dir = float2(0.150,0.850);
			#else
			const float2 LB_Dir = float2(0.125,0.875);
			#endif   
			//Normal A & B for both	
			const float CDArray_X_A0[7] = { LB_Dir.x, 0.25, 0.375, 0.5, 0.625, 0.75, LB_Dir.y}, 
						CDArray_X_B0[7] = { 0.25, 0.375, 0.4375, 0.5, 0.5625, 0.625, 0.75}, 
						CDArray_X_C0[9] = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9},
						CDArray_X_C1[13] = { 0.1, 0.1666667, 0.2333333, 0.3, 0.3666667, 0.4333333, 0.5, 0.5666667, 0.6333333, 0.7, 0.7666667, 0.8333333, 0.9 };

			float Bottom_Edge_A = ZPD_Boundary == 6 || SDD ? 0.95 : 0.9;
			float Bottom_Edge_B = SDD ? 0.95 : 0.875;
			
			float LetterBox_Detection_A = LBDetection() || EDU ? 0.85 : Bottom_Edge_A;
			float LetterBox_Detection_B = LBDetection() || EDU ? 0.85 : Bottom_Edge_B;
			float4 Shift_UP = Shift_Detectors_Up == 1 ? float4(0.375, 0.5, 0.6875, LetterBox_Detection_A) : float4(0.5, 0.65, 0.775, LetterBox_Detection_A);
			float CDArray_Y_A0[5] = { 0.25, Shift_UP.x, Shift_UP.y, Shift_UP.z, Shift_UP.w}, 
			      CDArray_Y_B0[5] = { 0.25, 0.375, 0.5, 0.6875, LetterBox_Detection_B},
				  CDArray_Y_C0[4] = { 0.25, 0.5, 0.75, LetterBox_Detection_B};
	  
			//Screen Space Detector 7x6 Grid from between 0 to 1 and ZPD Detection becomes stronger as it gets closer to the Center if you use ZPD Screen Edge Avoidance.
			float2 GridXY; int2 iXY = ( ZPD_Boundary == 3 ? int2( Detect_More_Mode ? 12 : 9, 4) : int2( 7, 5) );//was 12/4 and 7/7 This reduction saves 0.1 ms and should show no diff to the user.
			[loop]                                                                     //I was thinking the lowest I can go would be 9/4 along with 7/5
			for( int iX = 0 ; iX < iXY.x; iX++ )                                         //7 * 7 = 49 | 12 * 4 = 48 | 7 * 6 = 42 | 9 * 4 = 36 | 7 * 5 = 35
			{   [loop] 
				for( int iY = 0 ; iY < iXY.y; iY++ )
				{
					if(ZPD_Boundary == 1 || ZPD_Boundary == 6 || ZPD_Boundary == 7)
						GridXY = float2( CDArray_X_A0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 2 || ZPD_Boundary == 5)
						GridXY = float2( CDArray_X_B0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 3)
						GridXY = float2( Detect_More_Mode ? CDArray_X_C1[iX] : CDArray_X_C0[iX], CDArray_Y_C0[min(3,iY)]);
					else if(ZPD_Boundary == 4)
						GridXY = float2( CDArray_X_A0[iX], CDArray_Y_B0[iY]);
					//We shift the lower half here to have a better spread.
					if(texcoord.y > 0.6 && texcoord.y < 0.8)						
						GridXY.y += Shift_Mask(texcoord).x ? 0.0 : 0.05;

					float ZPD_I = Zero_Parallax_Distance;
					//#if !DX9_Toggle
					//float PDepth = tex2Dlod(SamplerDMN,float4(GridXY,0,0)).x;
					//#else				
					float PDepth = PrepDepth(GridXY)[1][0];
					//#endif	
					if(ZPD_Boundary >= 4 && PDepth == 1)
							ZPD_I = 0;
					
					//Weapon Hand Consideration
					#if CWH
						bool WHC_Mask = tex2D(SamplerInfo,GridXY).y;//CWH_Mask(GridXY);
						if (WHC_Mask == 1)
						    PDepth *= 1+WBA;
					#endif					
					// CDArrayZPD[i] reads across prepDepth.......
					CD = 1 - ZPD_I / PDepth;
					
					if( ZPD_Screen_Edge_Avoidance )
						CD *= tex2Dlod(SamplerInfo,float4(GridXY,0,0)).z;
						
					if ( CD < -ZPD_Scaler_One_Boundary )
						Detect = 1;
					//Used if Depth Buffer is way out of range or if you need granuality.
					if(RE_Set(0).x)
					{					
							if ( CD < -ZPD_Boundary_n_Cutoff_A.y && Detect_Out_of_Range <= 1)
								Detect_Out_of_Range = 1;	
					
						#if EDW	

							if ( CD < -ZPD_Boundary_n_Cutoff_B.y && Detect_Out_of_Range <= 2)
								Detect_Out_of_Range = 2;							

							if ( CD < -ZPD_Boundary_n_Cutoff_C.y && Detect_Out_of_Range <= 3)
								Detect_Out_of_Range = 3;							
	
							if ( CD < -ZPD_Boundary_n_Cutoff_D.y && Detect_Out_of_Range <= 4)
								Detect_Out_of_Range = 4;

							if ( CD < -RE_Extended().y && Detect_Out_of_Range <= 5)
								Detect_Out_of_Range = 5;
						#else	
													
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
							#if OIL >= 4	
							if ( CD < -RE_Extended().y && Detect_Out_of_Range <= 5)
								Detect_Out_of_Range = 5;
							#endif	
					
						#endif							
					}
				}
			}
		}
	    uint Sat_D_O_R = Detect_Out_of_Range == Fast_Trigger_Mode;
	    float ZPD_BnF = Auto_Adjust_Cal(Sat_D_O_R ? 0.5 - FLT_EPSILON : ZPD_Boundary_n_Fade.y);
	    float PStoredfade_A = tex2D(SamplerAvrP_N, float2(0, 0.1875)).z,//0 
			  PStoredfade_B = tex2D(SamplerAvrP_N, float2(0, 0.3125)).z,//1
			  PStoredfade_C = tex2D(SamplerAvrP_N, float2(1, 0.1875)).z,//2
			  PStoredfade_D = tex2D(SamplerAvrP_N, float2(1, 0.3125)).z,//3
			  PStoredfade_E = tex2D(SamplerAvrP_N, float2(1, 0.4375)).z,//4
			  PStoredfade_F = tex2D(SamplerAvrP_N, float2(1, 0.5625)).z;//5
	
	    // Fade in toggle.
	    float CallFT = 1.0 - exp(-frametime / ZPD_BnF); // exp2 would be even slower
	    return float3x3(float3(PStoredfade_A + (Detect - PStoredfade_A) * CallFT,
	                           PStoredfade_B + ((Detect_Out_of_Range >= 1) - PStoredfade_B) * CallFT,
	                           PStoredfade_C + ((Detect_Out_of_Range >= 2) - PStoredfade_C) * CallFT),
	                    float3(PStoredfade_D + ((Detect_Out_of_Range >= 3) - PStoredfade_D) * CallFT,
	                           PStoredfade_E + ((Detect_Out_of_Range >= 4) - PStoredfade_E) * CallFT,
	                           PStoredfade_F + ((Detect_Out_of_Range >= 5) - PStoredfade_F) * CallFT),
	                    float3(saturate(Detect_Out_of_Range * 0.2), 0, 0));
						 
	}
	#define FadeSpeed_AW 0.375
	float AltWeapon_Fade()
	{
		float  ExAd = (1-(FadeSpeed_AW * 2.0))*1000, Current =  min(0.75f,smoothstep(0,0.25f,PrepDepth(0.5f)[0][0])), Past = tex2D(SamplerAvrP_N,float2(0,0.5625)).z;
		return Past + (Current - Past) * (1.0 - exp(-frametime/ExAd));
	}
	#define FadeSpeed_AF 0.4375
	float Weapon_ZPD_Fade(float Weapon_Con)
	{
		float  ExAd = (1-(FadeSpeed_AF * 2.0))*1000, Current =  Weapon_Con, Past = tex2D(SamplerAvrP_N,float2(0,0.6875)).z;
		return Past + (Current - Past) * (1.0 - exp(-frametime/ExAd));
	}
	#define FadeSpeed_OS 0.75

	float OverShoot_Fade()
	{
		float Current, Past, Rate;
		float3 PD_ABC = float3(PrepDepth(0.5f)[0][0],PrepDepth(float2(0.75,0.5))[0][0],PrepDepth(float2(0.25,0.5))[0][0]);
		float Min_Depth = Min3(PD_ABC.x, PD_ABC.y, PD_ABC.z);
		
		Past = tex2D(SamplerAvrP_N,float2(1,0.9375)).z;
		Current = smoothstep(0,0.25,Min_Depth);
		
		Rate = FadeSpeed_OS; //0-1
		
		return lerp(Past, Current, Rate * frametime/1000);
	}
	
	//////////////////////////////////////////////////////////Depth Map Alterations/////////////////////////////////////////////////////////////////////
	float Auto_Scaler() // Look into merging this with Auto Balance
	{    	
		return saturate(lerp( Depth( float2(0.5,0.5) ) * 2 , Avr_Mix(float2(0.5,0.5)).x , 0.25) ) ;
	}
	
	void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 DM_Out : SV_Target0 , out float2 Color_Out : SV_Target1)
	{
		float4 DM = float4(PrepDepth(texcoord)[0][0],PrepDepth(texcoord)[0][1],0,PrepDepth(texcoord)[1][1]);
		float R = DM.x, G = DM.y, B = DM.z, Auto_Scale = 1;
		float SP_Min = Set_Pop_Min().y, Select_Min_LvL_Trigger;float3 Level_Control = DS_X;
		//Auto Scale
		if(WZPD_and_WND.z > 0)
			Auto_Scale = lerp(lerp(1.0,0.1,saturate(WZPD_and_WND.z * 2)),1.0,lerp(saturate(Auto_Scaler() * 2.5) , smoothstep(0,0.5,tex2D(SamplerAvrP_N,float2(0,0.5625)).z), 0.5));
		else if(WZPD_and_WND.z < 0)
			Auto_Scale = lerp(1.0,lerp(1.0,0.1,saturate(abs(WZPD_and_WND.z) * 2)),saturate(Auto_Scaler() * 2.5));
			
		//Fade Storage
		#if DX9_Toggle
		float3x3 Fade_Pass = Fade(texcoord); //[0][0] = F | [0][1] = F | [0][2] = F
						 					//[1][0] = F | [1][1] = F | [1][2] = F
											 //[2][0] = N | [2][1] = 0 | [2][2] = 0
		float2 Min_Trim = float2(SP_Min,WZPD_and_WND.w);
		#else
		float3 Fade_Pass_A = float3( tex2D(SamplerzBuffer_BlurN,float2(0,0.0625)).x,  //[0][0]
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.1875)).x,  //[0][1]
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.3125)).x );//[0][2]
		float3 Fade_Pass_B = float3( tex2D(SamplerzBuffer_BlurN,float2(0,0.4375)).x,  //[1][0]
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.5625)).x,  //[1][1]
									 tex2D(SamplerzBuffer_BlurN,float2(0,0.6875)).x );//[1][2]
		float  Fade_Pass_C =         tex2D(SamplerzBuffer_BlurN,float2(0,0.9375)).x;  //[2][0] = N
																        
			float Scale_Auto_Switch = Level_Control.y == 0 ? Fade_Pass_A.x : Level_Control.z == 2 ? Fade_Pass_B.y * 4 >= Level_Control.y : Fade_Pass_B.y * 4 == Level_Control.y;
			
			if(Level_Control.z >= 1)
				Select_Min_LvL_Trigger = Scale_Auto_Switch;
				
			SP_Min = lerp(SP_Min,Level_Control.x, saturate(Select_Min_LvL_Trigger) );
			
			float2 Min_Trim = float2(SP_Min,WZPD_and_WND.w);
		#endif
						 
		if(Inficolor_3D_Emulator && Inficolor_Near_Reduction)
			Min_Trim = float2((Min_Trim.x * 2.5 + Min_Trim.x) * 0.5, min( 0.3, (Min_Trim.y * 2.5 + Min_Trim.y) * 0.5) );
			
		float ScaleND = saturate(lerp(R,1.0f,smoothstep(min(-Min_Trim.x,0),1.0f,R)));
		float Edge_Adj = 0.5;
		
		if (Min_Trim.x > 0)
		{
			R = saturate(lerp(ScaleND,R,smoothstep(0,Min_Trim.y,ScaleND)));			
			R = lerp(DM.x,R,Auto_Scale);
		}
			//R = DepthEdge( R, DM.x, texcoord, 0.550, PrepDepth(texcoord)[2][0], tex2Dlod(SamplerzBuffer_BlurN,float4(texcoord,0,6)).y);	
		if ( Weapon_Depth_Edge.x > 0)//1.0 needs to be adjusted when doing far scaling
			R = lerp(DepthEdge(R, DM.x, texcoord, 1-Weapon_Depth_Edge.x),DM.x,smoothstep(0,1.0,DM.x));
		
		if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TL OG Fade
			R = Fade_in_out().x;
		#if DX9_Toggle
			if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR 0
				R = Fade_Pass[0][0];
			if(   texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BL 1
				R = Fade_Pass[0][1];
			if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR 2
				R = Fade_Pass[0][2];

			if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR 3
				G = Fade_Pass[1][0];
			if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TL 4
				G = Fade_Pass[1][1];
			if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR 5
				G = Fade_Pass[1][2];
			if(   texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BL N
				G = Fade_Pass[2][0];
		#else
			if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR 0
				R = Fade_Pass_A.x;//[0][0]
			if(   texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BL 1
				R = Fade_Pass_A.y;//[0][1]
			if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR 2
				R = Fade_Pass_A.z;//[0][2]

			if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR 3
				G = Fade_Pass_B.x;//[1][0]
			if(   texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TL 4
				G = Fade_Pass_B.y;//[1][1]
			if( 1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BR 5
				G = Fade_Pass_B.z;//[1][2]
			if(   texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)//BL N
				G = Fade_Pass_C;  //[2][0]
		#endif	
		//Luma Map
		float3 Color, Color_A = tex2D(Non_Point_Sampler,texcoord ).rgb;//, Color_B = step(0.9,tex2D(BackBufferCLAMP,texcoord ).rgb);
			   Color.x = max(Color_A.r, max(Color_A.g, Color_A.b)); 
		#if WHM 
		float2 TC_Off = texcoord * float2(2,1);// - float2(1,0);
		float2 Offsets = float2(5,5)*pix;
		float3 center = tex2D(Non_Point_Sampler, TC_Off).xyz;
		float3 right = tex2D(Non_Point_Sampler, TC_Off + float2(Offsets.x, 0.0)).xyz;
		float3 left = tex2D(Non_Point_Sampler, TC_Off + float2(-Offsets.x, 0.0)).xyz;
		float3 up = tex2D(Non_Point_Sampler, TC_Off + float2(0.0, Offsets.y)).xyz;
		float3 down = tex2D(Non_Point_Sampler, TC_Off + float2(0.0, -Offsets.y)).xyz;
		
		float3 Color_UI_MAP = -4.0 * center + right + left + up + down; //We mask it out later
		
		Color.y = max(Color_UI_MAP.r, max(Color_UI_MAP.g, Color_UI_MAP.b));
		#endif
		
		DM_Out = saturate(float2(R,G));
		
		Color_Out = saturate(Color.xy);
	}
	
	float AutoDepthRange(float d, float2 texcoord )
	{ float LumAdjust_ADR = smoothstep(-0.0175,min(0.5,Auto_Depth_Adjust),Avr_Mix(texcoord).x);
	    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
	}
		
	float4 Conv(float2 MD_WHD,float2 texcoord,float2 abs_WZPDB)
	{   float WConverge = 0.030, D = MD_WHD.x, Z = Zero_Parallax_Distance, WZP = 0.5, ZP = 0.5, OS_Value = saturate(OverShoot_Fade()),
			  W_Convergence = Inficolor_Near_Reduction ? WConverge * 0.75 : WConverge, WZPDB, WZPD_Switch, 
			  Distance_From_Bottom = lerp(0.9375,1.0,saturate(WFB)), ZPD_Boundary_Adjust = ZPD_Boundary_n_Fade.x, Store_WC;
	    //Screen Space Detector.
		if (abs_WZPDB.x > 0)
		{
			#if WBS			   
			float WArray[6] = { 0.1, 0.2, 0.3, 0.7, 0.8, 0.9};
			#else
			float WArray[6] = { 0.4, 0.5, 0.6, 0.7, 0.8, 0.9};
			#endif
			[unroll] //only really only need to check one point just above the center bottom and to the right.
			for( int i = 0 ; i < 6; i++ )
			{
				WZPDB  = 1 - WConverge / tex2Dlod(SamplerDMN, float4(float2(WArray[i],Distance_From_Bottom), 0, 0)).y;
				if(Weapon_ZPD_Boundary.x >= 0)
				{	
					if ( WZPDB < -DJ_W ) // Default -0.1
					{
						W_Convergence *= 1.0-abs_WZPDB.x;
						WZPD_Switch = 1;
					}
					 //Used if Weapon Buffer is way out of range.
					if (abs_WZPDB.y > abs_WZPDB.x)
					{
						if ( WZPDB < -DS_W )
						{
							W_Convergence *= 1.0-abs_WZPDB.y;
							WZPD_Switch = 2;
						}
					}
				}
				else
				{
					if ( WZPDB < -DJ_W ) // Default -0.1
						WZPD_Switch = 1;
					 //Used if Weapon Buffer is way out of range.
					if (abs_WZPDB.y > abs_WZPDB.x)
					{
						if ( WZPDB < -DS_W )
							WZPD_Switch = 2;
					}
				}
			}
		}
		//Store Weapon Convergence for Smoothing.
		Store_WC = W_Convergence;
		//MD_WHD.y is Weapon Hand Depth
		W_Convergence = 1 - tex2D(SamplerAvrP_N,float2(0,0.6875)).z / MD_WHD.y;// 1-W_Convergence/D
		float WD = MD_WHD.y; //Needed to seperate Depth for the  Weapon Hand. It was causing problems with Auto Depth Range below.
	
			if (Auto_Depth_Adjust > 0)
				D = AutoDepthRange(D,texcoord);
			// Used to scale for Auto Balance here 0 means we are looking close at something.
			if(ZPD_Balance >= 0)
				ZP = saturate( abs(ZPD_Balance) * (OS_Value * OS_Value));// * MD_WHD.x);

			float4 Set_Adjustments = RE_Set_Adjustments();float2 SC_Adjutment = DT_W;
			float DOoR_A = smoothstep(0,1,tex2D(SamplerAvrP_N,float2(0, 0.1875)).z), //ZPD_Boundary    0
				  DOoR_B = smoothstep(0,1,tex2D(SamplerAvrP_N,float2(0, 0.3125)).z),   //Set_Adjustments 1
				  DOoR_C = smoothstep(0,1,tex2D(SamplerAvrP_N,float2(1, 0.1875)).z),     //Set_Adjustments 2
				  DOoR_D = smoothstep(0,1,tex2D(SamplerAvrP_N,float2(1, 0.3125)).z),       //Set_Adjustments 3
				  DOoR_E = smoothstep(0,1,tex2D(SamplerAvrP_N,float2(1, 0.4375)).z),         //Set_Adjustments 4 
				  DOoR_F = smoothstep(0,1,tex2D(SamplerAvrP_N,float2(1, 0.5625)).z),		   //Set_Adjustments 5
				  SetLvL = smoothstep(0,1,tex2D(SamplerAvrP_N,float2(1, 0.8125)).z); //Set_Level N
			
			if(SC_Adjutment.y > 0.0)
				W_Convergence *= lerp(SC_Adjutment.x , 1.0,MD_WHD.x > SC_Adjutment.y);
			//The Switch Array B 0.750 that switches the OIL value in RE_Set.
			//Z is a LvL between 0 - 3
			//N is current value of ZPD Value	  															   
			float Detection_Switch_Amount = RE_Set(SetLvL).y;//Y = X																   

			if(RE_Set(0).x)
			{
				DOoR_B = lerp(ZPD_Boundary_Adjust, Set_Adjustments.x, DOoR_B);
					#if OIL == 0
					DOoR_F = DOoR_B;
					#endif
	
				#if OIL >= 1
				DOoR_C = lerp(DOoR_B, Set_Adjustments.y, DOoR_C);
					#if OIL == 1
					DOoR_F = DOoR_C;
					#endif	
				#endif
				
				#if OIL >= 2	
				DOoR_D = lerp(DOoR_C, Set_Adjustments.z, DOoR_D);
					#if OIL == 2
					DOoR_F = DOoR_D;
					#endif	
				#endif		

				#if OIL >= 3	
				DOoR_E = lerp(DOoR_D, Set_Adjustments.w, DOoR_E);
					#if OIL == 3
					DOoR_F = DOoR_E;
					#endif	
				#endif	
				
				#if OIL >= 4	
				DOoR_F = lerp(DOoR_E, RE_Extended().x, DOoR_F);
				#endif		
			}
			else
			DOoR_F = lerp(ZPD_Boundary_Adjust, Detection_Switch_Amount.x, DOoR_B);
			
			//Want to add a Over Shoot Value to ZDP
			//I need to make sure that if it's near 
			//it is closer to the original value
			if(ZPD_OverShoot > 0)
				Z = lerp(Z,Z * (1+min(0.75,0.75 * ZPD_OverShoot)),OS_Value);
			
			Z *= lerp( 1, DOoR_F, DOoR_A);
			
			float Convergence = 1 - Z / D;
			if (Zero_Parallax_Distance == 0)
				ZP = 1;
	
			ZP = min(ZP, Auto_Balance_Clamp);

		//* lerp(1,2,D) // place this after saturate(Convergence)
		float Mod_Depth = lerp(Convergence,lerp(D,Convergence,saturate(Convergence) ), ZP);
	#if Inficolor_3D_Emulator
		Mod_Depth = lerp(Mod_Depth,min(saturate(Inficolor_Max_Depth),Mod_Depth),saturate(D * 0.5));
	#endif
	   return float4( Mod_Depth, lerp(W_Convergence,WD,WZP), Store_WC, WZPD_Switch); //The last two are for the weapon hand
	}

	float WeaponMask(float2 TC,float Mips)
	{
		if(WP == 0)
			return 1;
		else
			return tex2Dlod(SamplerDMN,float4(TC,0,Mips)).y == 0.5 ? 0 : 1;
	}

	float4 DB_Comb(float2 texcoord)
	{
		float Auto_Adjust_Weapon_Depth = 1, Anti_Weapon_Z = abs(AWZ);
		float2 MD_W = tex2Dlod(SamplerDMN,float4(texcoord,0,0)).xy;
		// X = Mix Depth | Y = Weapon Mask | Z = Weapon Hand | W = Normal Depth
		float4 DM = float4(MD_W.x,WeaponMask(texcoord,0),MD_W.y,PrepDepth( texcoord )[1][1]);
		//FLT_EPSILON was added here to help prevent crashing
		DM.x += FLT_EPSILON;//Needed on X
		DM.z += FLT_EPSILON;//Needed on Z
		DM.w += FLT_EPSILON;//Needed on W
		//Hide Temporal passthrough
		if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if(texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)
			DM = PrepDepth(texcoord)[0][0];
			
		#if SDM
		float Sten_D_M = 0.0;
		if(DM.y >= 0.9999)
			Sten_D_M = 1.0;
		#endif
		//float Store_DMX = DM.x;	
		
		if (WP == 0)
			DM.y = 0;	
	
		//Handle Convergence Here
		float2 WZPDB = abs(Weapon_ZPD_Boundary);
		float4 HandleConvergence = Conv(DM.xz,texcoord,WZPDB).xyzw;
			   HandleConvergence.y *= WA_XYZW().w;
			   
			   if(HandleConvergence.w == 1)
			   	HandleConvergence.y *= 1-WZPDB.x;
			   if(HandleConvergence.w == 2)
			   	HandleConvergence.y *= 1-WZPDB.y;

		float FadeIO = Focus_Reduction_Type == 0 ? 1 : smoothstep(0, 1, 1 - Fade_in_out().x), FD_Adjust = 0.050;	
	
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
			   	
			   HandleConvergence.y = lerp(HandleConvergence.y + FD_Adjust, HandleConvergence.y, FadeIO);
		if(Anti_Weapon_Z > 0)//Anti-Weapon Hand Z-Fighting
		{
			float AAWD_Adjust = tex2Dlod(SamplerDMN,float4(float2(AWZ < 0 ? 0.55 : 0.50,0.525),0,8)).x;
			Auto_Adjust_Weapon_Depth = lerp(0.5,1.0,smoothstep(0,1,AAWD_Adjust * (Anti_Weapon_Z > 1 ? 12.5 : 7.5)));
		}
		
		DM.y = lerp( HandleConvergence.x, HandleConvergence.y * Auto_Adjust_Weapon_Depth, DM.y);
	
		float Edge_Adj = saturate(lerp(0.5,1.0,Edge_Adjust));
		#if Inficolor_3D_Emulator
			float UI_Detection_Mask = 0.5;
		#else
			float UI_Detection_Mask = 0.0625;
		#endif
			DM = lerp(lerp(EdgeMask( DM, texcoord, 0.955 ),DM,  Edge_Adj), DM, saturate(1-DM.y) );	
		#if Compatibility_00	
		if (Depth_Detection == 1)
		{
			if (!DepthCheck)
				DM = UI_Detection_Mask;
		}
		#endif
		#if SDM
			if(Sten_D_M)
				DM = DBB_W;
		#endif
		
		#if MDD	
			float MSDT_A = Menu_Size().x, MSDT_B = abs(Menu_Size().y), Direction = texcoord.x < MSDT_A, Other_Direction = texcoord.y > 1-MSDT_B;
			
			#if (MDD  == 2 )		
				Direction = texcoord.x > MSDT_A;
			#elif (MDD  == 3 )		
				Direction = texcoord.y < MSDT_A;
			#elif (MDD  == 4 )
				Direction = texcoord.y > MSDT_A;
			#endif
			if( MSDT_A > 0)
			{
				DM = Direction ? UI_Detection_Mask : DM;
				
				if(Menu_Size().y < 0)
					Other_Direction = texcoord.y < MSDT_B;
					
				DM = Other_Direction ? UI_Detection_Mask : DM;
			}
		#endif	
		
		#if MMD
		float4 SMD_Lock_A = Simple_Menu_Detection_A() && Lock_Menu_Detection();		
			if( SMD_Lock_A.x == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_A.y == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_A.z == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_A.w == 1)
				DM = UI_Detection_Mask;
			#if MMD >= 2
		float4 SMD_Lock_B = Simple_Menu_Detection_B() && Lock_Menu_Detection();
			if( SMD_Lock_B.x == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_B.y == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_B.z == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_B.w == 1)
				DM = UI_Detection_Mask;
			#endif
			#if MMD >= 3
		float4 SMD_Lock_C = Simple_Menu_Detection_C() && Lock_Menu_Detection();
			if( SMD_Lock_C.x == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_C.y == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_C.z == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_C.w == 1)
				DM = UI_Detection_Mask;
			#endif
			#if MMD >= 4
		float4 SMD_Lock_D = Simple_Menu_Detection_D() && Lock_Menu_Detection();
			if( SMD_Lock_D.x == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_D.y == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_D.z == 1)
				DM = UI_Detection_Mask;
			if( SMD_Lock_D.w == 1)
				DM = UI_Detection_Mask;
			#endif
		#endif	
		
		#if SMD //May Do one or two more levels	
			DM = Simple_Menu_A() ? UI_Detection_Mask : DM;
			#if SMD >= 2	
				DM = Simple_Menu_B() ? UI_Detection_Mask : DM;
			#endif
				#if SMD >= 3	
					DM = Simple_Menu_C() ? UI_Detection_Mask : DM;
				#endif
					#if SMD >= 4	
						DM = Simple_Menu_D() ? UI_Detection_Mask : DM;
					#endif
						#if SMD >= 5	
							DM = Simple_Menu_E() ? UI_Detection_Mask : DM;
						#endif
							#if SMD >= 6	
								DM = Simple_Menu_F() ? UI_Detection_Mask : DM;
							#endif
		#endif	
		
		if (Cancel_Depth)
			DM = UI_Detection_Mask;
	
		#if UI_MASK
			DM.y = lerp(DM.y,0,step(1.0-HUD_Mask(texcoord),0.5));
		#endif
		
		#if KHM 
		if(WP > 0)
		{		
			float Cal_Depth = saturate(Conv(tex2Dlod(SamplerDMN,float4(texcoord,0,8.5)).x,texcoord,0.0).x);
			DM.y = lerp( WeaponMask(texcoord ,5.5) && texcoord.y > 0.5 ? Cal_Depth : DM.y ,Cal_Depth,WeaponMask(texcoord ,0));
		}
		#endif
		
		// Should expand on this as a way to rescale Depth in a specific location around the weapon hand.
		#if WHM 		
		float DT_Switch = DT_Z < 0;
		float Mask_A = tex2Dlod(SamplerAvrB_N,float4(texcoord * float2(0.5,1) ,0,4.0)).x;
		float Mask_B = tex2Dlod(SamplerAvrB_N,float4(texcoord * float2(0.5,1) + float2(0.5,0) ,0,2.0)).x * 0.5;
		if(WP > 0)
		{
		
			if (DT_Switch)
			{
				float Blur_Mask = tex2Dlod(SamplerDMN,float4(texcoord,0,6)).x;
				DM.y = lerp(DM.y,saturate(DM.y),WeaponMask(texcoord,0));
				float Weapon_Depth_Gen = lerp(DM.y,lerp(0.0,0.2,Blur_Mask) * lerp(2,1,FadeIO) ,smoothstep(0,abs(UI_Seeking_Strength),Mask_A) * lerp(1-FD_Adjust,1,FadeIO));
				DM.y = lerp(DM.y,Weapon_Depth_Gen,WeaponMask(texcoord,0));
			}
			else
			{   //For Diablo
				float UI_MASK_A = tex2Dlod(SamplerCN,float4(texcoord * float2(0.5,1)  ,0,6)).y ;

				UI_MASK_A =  lerp( 0, saturate(UI_MASK_A * 2.0),Mask_A); 				
				DM.y = WeaponMask(texcoord,0) ? 0.0 : DM.y;//Not sure if this was the best thing to do to mask it.
				DM.y = lerp(DM.y, lerp(WeaponMask(texcoord,0) ? 0.5 : DM.y,0.025,saturate( Mask_A + Mask_B )) ,smoothstep(0,abs(  UI_Seeking_Strength  ),UI_MASK_A) );// * lerp(1-FD_Adjust,1,FadeIO));
			}		
		
		}
		#endif

		#if HUD_MODE || HMT // Need to check on Weapon Near if it's too low and needs adjustment for pop out. 
		float HUDCutOFFCal = ((HUD_Adjust.x * 0.5)/DMA()) * 0.5, COC = step(PrepDepth(texcoord)[1][2],HUDCutOFFCal); //HUD Cutoff Calculation

		//This code is for hud segregation.
		if (HUD_Adjust.x > 0)
			DM.y = COC ? 0.001 + lerp(-0.25,0.25,saturate(HUD_Adjust.y)) : DM.y ;
		#endif
	
		return float4(DM.y,PrepDepth( texcoord )[1][1],HandleConvergence.z,HandleConvergence.w);
	}
	#define Adapt_Adjust 0.7 //[0 - 1]
	////////////////////////////////////////////////////Depth & Special Depth Triggers//////////////////////////////////////////////////////////////////
	void Mod_Z(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Point_Out : SV_Target0 , out float2 Linear_Out : SV_Target1)
	{   //Temporal adaptation based on https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
		float ExAd_A = (1-Adapt_Adjust)*1250, Current_A = tex2Dlod(SamplerCN,float4(texcoord,0,12)).x, Past_A = tex2D(SamplerAvrP_N,float2(0,0.4375)).z;
		float ExAd_B = (1-Adapt_Adjust)*1250, Current_B = smoothstep(0,0.1,tex2Dlod(SamplerAvrP_N,float4(0.5.xx,0,12)).w), Past_B = tex2D(SamplerAvrP_N,float2(0,0.8125)).z;
		//Temporal again but for Popout.
					//Popout Detection
			//Color = tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w > 0; // Detect if there is pop out.
			//Color = smoothstep(0,0.1,tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w); //Scale Popout linerly 
		
		float4 Set_Depth = DB_Comb( texcoord.xy ).xyzw;
		
		if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)    //TL
			Set_Depth.y = Past_A + (Current_A - Past_A) * (1.0 - exp(-frametime/ExAd_A));	
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BR
			Set_Depth.y = AltWeapon_Fade();
		if(  texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BL
			Set_Depth.y = Weapon_ZPD_Fade(Set_Depth.z);
		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
			Set_Depth.y = Set_Depth.w;		
		//For High Frequency Information.
		float HF_Info = saturate(ddx(Set_Depth.x) * ddy(Set_Depth.x));
			
		if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)    //TL
			HF_Info = Past_B + (Current_B - Past_B) * (1.0 - exp(-frametime/ExAd_B));		
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BR
			HF_Info = 0;
		if(  texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BL
			HF_Info = OverShoot_Fade();
		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
			HF_Info = 0;
			
		Point_Out = Set_Depth.xy; 
		Linear_Out = float2(Set_Depth.x,HF_Info);
	}
	
	void zBuffer_Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Blur_Out : SV_Target0, out float2 Info_Ex : SV_Target1)
	{   
		float2 StoredTC = texcoord;
		float Invert_Depth_Mask =  1-smoothstep(0.0,0.5,PrepDepth( StoredTC * float2(2.0, 1) - float2(1.0,0.0)  )[1][1]);
		float Text_Mask;
		float Average_ZPD = PrepDepth( texcoord )[0][0];
		#if TMD
				#if DX9_Toggle
				texcoord.x *= 2.0;
				#endif
		float3 CCC = tex2D(Non_Point_Sampler,texcoord ).rgb;

			#if TMD == 1		
			float Gen_Mask = step(0.8f,(CCC.r+CCC.g+CCC.b)/3);
			#else
			float Gen_Mask = step(DZ_W.y,(CCC.r+CCC.g+CCC.b)/3);
			#endif
			   Text_Mask = saturate(Gen_Mask.x);
		#endif
		
		#if !DX9_Toggle
		//Fade Storage		
		float3x3 Fade_Pass = Fade(StoredTC); //[0][0] = F | [0][1] = F | [0][2] = F
						 					//[1][0] = F | [1][1] = F | [1][2] = F
											 //[2][0] = N | [2][1] = 0 | [2][2] = 0
		const int Num_of_Values = 8; //4 total array values that map to the textures width.
		float Storage_Array[Num_of_Values] = { Fade_Pass[0][0],
	                                		   Fade_Pass[0][1],
	                                		   Fade_Pass[0][2], 
	                                		   Fade_Pass[1][0],
											   Fade_Pass[1][1],
											   Fade_Pass[1][2],
											   0.0,
											   Fade_Pass[2][0] };
		//Set a avr size for the Number of lines needed in texture storage.
		float Grid = floor(StoredTC.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);							 

		Blur_Out = float2( StoredTC < 0.5 ? Storage_Array[int(fmod(Grid,Num_of_Values))] : Invert_Depth_Mask, Text_Mask);
		#else
		Blur_Out = StoredTC < 0.5 ? Text_Mask : Invert_Depth_Mask;
		#endif
		Info_Ex = float2(Average_ZPD,0);
	}
	
	#if SUI
		float Stencil_Masking(float2 TC, float2 Pos, float2 UI_Mask_Size, float UI_Mask_Inversion,int SSS)
		{
			if(SSS == 1)//Square
			{
			TC += Pos - 0.5;
			float UI_Direction = TC.x < UI_Mask_Size.x || TC.y < UI_Mask_Size.y;
				  UI_Direction += 1-TC.x < UI_Mask_Size.x || 1-TC.y < UI_Mask_Size.y;
			float UI_D = saturate(UI_Direction);
			return lerp(UI_D,1-UI_D,UI_Mask_Inversion);
			}
			else if(SSS == 2) //Circle
			{
			TC -= Pos;
			float d = length(TC * float2(ARatio,1)) - UI_Mask_Size.x;
			float t = saturate(1.0 - d > 0.9999999);
			return lerp(t,1-t,UI_Mask_Inversion);
			}
			else
			return 0;
		}

		float Stencil_Sampler(float3 TC_W)
		{
			return saturate(tex2Dlod(SamplerzBufferN_L, float4( TC_W.xy, 0, 4) ).x + (0.5-TC_W.z));		
		}			
	#endif
	#if !Use_2D_Plus_Depth
	float2 Artifact_Adjust() { return float2(abs(De_Artifacting.x),De_Artifacting.y); }
	#endif
	float Depth_Seperation()
	{
		return min(0.25,Separation_Adjust);
	}
	
	//This is where Depth Is adjusted. Since it's no longer adjusted by Divergence.	
	float Smooth_Tune_Boost() 
	{
		//float RCP_Diverge = 100 * rcp(Divergence_Switch().x);
		float S_T_Adjust = min(1.25,abs(Divergence_Switch().y) * 0.01);// * RCP_Diverge;
	    return abs(lerp(0.01f,1.0f,S_T_Adjust));
	}
	
	static const float  VMW_Array[10] = { 0.0, 1.0, 2.0, 3.0 , 3.5 , 4.0, 4.5 , 5.0, 5.5, 6.0 };	
	float GetDB(float2 texcoord)
	{
		#if TMD
			//UI Lift Masking 
			float TMD_LvL = TMD == 1 ? 60 : 600;
			#if DX9_Toggle  
		    float Basic_UI = tex2Dlod(SamplerzBuffer_BlurN, float4( texcoord * float2(0.5,1.0) , 0, 2.5 ) ).x;
		    #else
		    float Basic_UI = tex2Dlod(SamplerzBuffer_BlurN, float4( texcoord, 0, 2.5 ) ).y;
			#endif
			Basic_UI = saturate( Basic_UI * TMD_LvL);
		#endif
		
		#if Reconstruction_Mode || Virtual_Reality_Mode
		if( Vert_3D_Pinball )	
			texcoord.xy = texcoord.yx;	
		#else
		if(Vert_3D_Pinball && Stereoscopic_Mode != 5)	
			texcoord.xy = texcoord.yx;
		#endif
		float LR_Depth_Mask = 1-saturate(tex2Dlod(SamplerzBuffer_BlurN, float4( texcoord  * float2(0.5,1) + float2(0.5,0), 0, 2.5 ) ).x * 5.0);	
		float2 Base_Depth_Buffers = float2(tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, 0) ).x,tex2Dlod(SamplerzBufferN_P, float4( texcoord, 0, 0) ).x);
	
		float GetDepth = smoothstep(0,1, tex2Dlod(SamplerzBufferN_P, float4(texcoord,0, 1) ).y), Sat_Range = saturate(Range_Blend);
		
		float Base_Depth_SubSampled = tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, lerp(0.0,4.0,Base_Depth_Buffers.x)) ).x;
		float Base_Depth = lerp(Base_Depth_Buffers.x,Base_Depth_SubSampled,LR_Depth_Mask.x*Sat_Range);
		
		uint VMW_Switch = View_Mode_Warping;
		#if LBM || LetterBox_Masking
		float LB_Detection = tex2D(SamplerAvrP_N,float2(1,0.0625)).z;
		if(LB_Detection)
			VMW_Switch *= 0.5;
		#endif
		uint VM_Mip_Cal = VMW_Array[clamp(VMW_Switch,0,9)], ISV_Switch = 3;

		float FadeIO = smoothstep(0,1,tex2D(SamplerDMN,0).x);
		if(FPSDFIO > 0)
			ISV_Switch = lerp(ISV_Switch,6,FadeIO);

		//Smoothing is not masked so that things that will cause distortions is smooth stronger then thing that don't need it.
		LR_Depth_Mask = smoothstep(Warping_Masking == 2 ? 0.75 : 1,0,tex2Dlod(SamplerzBufferN_L,float4(texcoord,0,ISV_Switch)).x*(1-LR_Depth_Mask));
		float VMW = Warping_Masking == 0 ? VM_Mip_Cal : lerp(VM_Mip_Cal,0,LR_Depth_Mask.x);
		#if TMD == 1
			VMW = lerp(clamp(VMW,0,6.0),6.0,Basic_UI);
		#else
			VMW = clamp(VMW,0,6.0);
		#endif
		
		float Near_Mask = tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, 9 ) ).x * 0.5;
		if(Weapon_Near_Halo_Reduction)
			VMW = lerp(VMW,9,Near_Mask);//int(lerp(VMW,9,Near_Mask));
		
		float Min_Blend = min(tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, VMW ) ).x,Base_Depth.x);

		float2 DepthBuffer_LP = float2(Min_Blend,Base_Depth_Buffers.y);
	
		#if TMD
			#if TMD == 1
			#else
				float Text_Direction = texcoord.x < DZ_W.z || texcoord.y < DZ_W.w;
				#if (TMD  == 3 ) // Reverse
				Text_Direction = 1-texcoord.x < DZ_W.z || 1-texcoord.y < DZ_W.w;
				#elif (TMD  == 4 ) // Mirror
				Text_Direction += 1-texcoord.x < DZ_W.z || 1-texcoord.y < DZ_W.w;
				#endif
				
			if( DZ_W.x > 0 && Text_Menu_Detection())
			{
				if(Text_Direction)
				DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,  min(DepthBuffer_LP.xy,saturate(tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, (uint)lerp(0,12,Basic_UI) ) ).x  * 0.01)) ,Basic_UI * saturate(DZ_W.x));
			}
			#endif
		#endif
		
		#if SUI
			float2 UI_A_Mask_Pos = 1-DDD_Y.zw;
			//Auto Depth 0.5 > needs more detection points will update that later.
			float UI_A_Mask_Depth = DDD_W.w < 0.5 ? DDD_W.w : Stencil_Sampler(float3( 1-UI_A_Mask_Pos,DDD_W.w));
			float2 UI_A_Mask_Size= DDD_W.xy;
			if(Stencil_n_Detection_A())
				DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,UI_A_Mask_Depth,Stencil_Masking(texcoord,UI_A_Mask_Pos,UI_A_Mask_Size,DDD_W.z,SSA));
				#if SUI >= 2
				float2 UI_B_Mask_Pos = 1-DEE_Y.zw;
				//Auto Depth 0.5 > needs more detection points will update that later.
				float UI_B_Mask_Depth = DEE_W.w < 0.5 ? DEE_W.w : Stencil_Sampler(float3( 1-UI_B_Mask_Pos,DEE_W.w));
				float2 UI_B_Mask_Size= DEE_W.xy;
				if(Stencil_n_Detection_B())
					DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,UI_B_Mask_Depth,Stencil_Masking(texcoord,UI_B_Mask_Pos,UI_B_Mask_Size,DEE_W.z,SSB));
				#endif
					#if SUI >= 3
					float2 UI_C_Mask_Pos = 1-DFF_Y.zw;
					//Auto Depth 0.5 > needs more detection points will update that later.
					float UI_C_Mask_Depth = DFF_W.w < 0.5 ? DFF_W.w : Stencil_Sampler(float3( 1-UI_C_Mask_Pos,DFF_W.w));
					float2 UI_C_Mask_Size= DFF_W.xy;
					if(Stencil_n_Detection_C())
						DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,UI_C_Mask_Depth,Stencil_Masking(texcoord,UI_C_Mask_Pos,UI_C_Mask_Size,DFF_W.z,SSC));
					#endif
						#if SUI >= 4
						float2 UI_D_Mask_Pos = 1-DGG_Y.zw;
						//Auto Depth 0.5 > needs more detection points will update that later.
						float UI_D_Mask_Depth = DGG_W.w < 0.5 ? DGG_W.w : Stencil_Sampler(float3( 1-UI_D_Mask_Pos,DGG_W.w));
						float2 UI_D_Mask_Size= DGG_W.xy;
						if(Stencil_n_Detection_D())
							DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,UI_D_Mask_Depth,Stencil_Masking(texcoord,UI_D_Mask_Pos,UI_D_Mask_Size,DGG_W.z,SSD));
						#endif
							#if SUI >= 5
							float2 UI_E_Mask_Pos = 1-DJJ_Y.zw;
							//Auto Depth 0.5 > needs more detection points will update that later.
							float UI_E_Mask_Depth = DJJ_W.w < 0.5 ? DJJ_W.w : Stencil_Sampler(float3( 1-UI_E_Mask_Pos,DJJ_W.w));
							float2 UI_E_Mask_Size= DJJ_W.xy;
							if(Stencil_n_Detection_E())
								DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,UI_E_Mask_Depth,Stencil_Masking(texcoord,UI_E_Mask_Pos,UI_E_Mask_Size,DJJ_W.z,SSE));
							#endif
								#if SUI >= 6
								float2 UI_F_Mask_Pos = 1-DLL_Y.zw;
								//Auto Depth 0.5 > needs more detection points will update that later.
								float UI_F_Mask_Depth = DLL_W.w < 0.5 ? DLL_W.w : Stencil_Sampler(float3( 1-UI_F_Mask_Pos,DLL_W.w));
								float2 UI_F_Mask_Size= DLL_W.xy;
								if(Stencil_n_Detection_F())
									DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,UI_F_Mask_Depth,Stencil_Masking(texcoord,UI_F_Mask_Pos,UI_F_Mask_Size,DLL_W.z,SSF));
								#endif
		#endif	
		#if !Use_2D_Plus_Depth
		if(View_Mode == 0 || View_Mode == 3)	
			DepthBuffer_LP.x = DepthBuffer_LP.y;		
		#endif
		float Separation = lerp(1.0,5.0,Depth_Seperation()); 	
		
		float Boost_Range_Depth = DepthBuffer_LP.x, Pop_Adjust = saturate(DI_Y);
		float Max_Clamp = Pop_Adjust > 0 ? 5.0 : 2.5 ;
		if(Pop_Adjust > 0)//Boost_Mode from 2018
		{
			float2 Clamp_Near = max(0,float2(tex2Dlod(SamplerzBufferN_P, float4(texcoord,0, 0) ).y, DepthBuffer_LP.x));	
			float Mid_Point = Clamp_Near.y > 0.5 ? Clamp_Near.x : Clamp_Near.y;
			float RCP_Diverge = saturate(0.01 * Divergence_Switch().y);
			float Cal_Power_Blend = lerp(1.75,1.25,RCP_Diverge);
			
			  Boost_Range_Depth = lerp(DepthBuffer_LP.x * 2 - 1,DepthBuffer_LP.x * 3 - 1.5, Mid_Point * 0.25 + 0.25);
			  Boost_Range_Depth = lerp(DepthBuffer_LP.x,Boost_Range_Depth * 0.5 + 0.5, Clamp_Near.y);
			  Boost_Range_Depth = lerp(DepthBuffer_LP.x,Boost_Range_Depth, Clamp_Near.y * 0.5 + 0.5);
			  Boost_Range_Depth = lerp(DepthBuffer_LP.x,Boost_Range_Depth,Cal_Power_Blend * Pop_Adjust);
		}	  
		
		return clamp((Separation * Boost_Range_Depth) * Smooth_Tune_Boost(),-1.5,Max_Clamp);
	}
	
	int3 Shift_Depth()
	{
		float If_Has_Depth = tex2Dlod(SamplerAvrB_N,float4(float2(0.5,0.5),0,12)).y < 1;
	
		float Check_Depth_Pos_Bot_A = PrepDepth(float2(0.25,0.999))[0][0];
		float Check_Depth_Pos_Bot_B = PrepDepth(float2(0.75,0.999))[0][0];
		float Check_Depth_Pos_Bot_C = PrepDepth(float2(0.50,0.999))[0][0];
		
		float Check_Depth_Pos_Corner = PrepDepth(float2(0.999,0.999))[0][0];
	
		float Check_Depth_Pos_Side_A = PrepDepth(float2(0.999,0.5))[0][0];//It was 1.0 , 0.5
		float Check_Depth_Pos_Side_B = PrepDepth(float2(0.999,0.75))[0][0];
		
		int Check_Depth_Shift_A = Check_Depth_Pos_Bot_A * Check_Depth_Pos_Bot_B * Check_Depth_Pos_Side_A * Check_Depth_Pos_Corner;
		int Check_Depth_Shift_B = Check_Depth_Pos_Side_B * Check_Depth_Pos_Side_A * Check_Depth_Pos_Corner;
		int Check_Depth_Shift_C = Check_Depth_Pos_Bot_A * Check_Depth_Pos_Bot_B * Check_Depth_Pos_Bot_C  * Check_Depth_Pos_Corner;
		
		return int3(Check_Depth_Shift_A == 1, Check_Depth_Shift_B == 1, Check_Depth_Shift_C == 1 ) && If_Has_Depth;	    
	}	
	
	void Mix_Z(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float MixOut : SV_Target0)
	{
		#if BD_Correction || BDF
		if(BD_Options == 0 || BD_Options == 2)
		{
			float3 K123 = Colors_K1_K2_K3 * 0.1;
			texcoord = D(texcoord.xy,K123.x,K123.y,K123.z);
		}
		#endif
		
		float2 Shift_TC = texcoord;
			
		//work on this
		#if SDT || SD_Trigger
			#if LDT
				if( SDTriggers() && SDT_Lock_Menu_Detection())
					Shift_TC = TC_SP(Shift_TC).zw;
			#else
				if( SDTriggers() )
					Shift_TC = TC_SP(Shift_TC).zw;
			#endif
		#endif
		#if !DX9_Toggle  		
			float2 Depth_Size = tex2Dsize(DepthBuffer);
			//float Depth_AR = Depth_Size.x/Depth_Size.y;
			//float modifiedAR = Depth_AR - floor(Depth_AR);
			Depth_Size = rcp(Depth_Size);
			
			#if DB_Size_Position || SPF || LBC || LB_Correction
			int LBD_Switch = LBD_Switcher > 0 ? 1 : !LBDetection();
			if(Auto_Scaler_Adjust)
			{
				if(LBDetection())
				{
					if(Shift_Depth().x && LBD_Switch && LBD_Switcher == 1)
						Shift_TC *= 1-Depth_Size * 2.5;
					if(Shift_Depth().y && LBD_Switch && LBD_Switcher == 2)
						Shift_TC.x *= 1-Depth_Size.x * 3.0;
					if(Shift_Depth().z && LBD_Switch && LBD_Switcher == 3)
						Shift_TC.y *= 1-Depth_Size.y*2.5;
				}
				else
				{
					if(Shift_Depth().x)
						Shift_TC *= 1-Depth_Size * 2.5;
					if(Shift_Depth().y)
						Shift_TC.x *= 1-Depth_Size.x * 3.0;
					if(Shift_Depth().z)
						Shift_TC.y *= 1-Depth_Size.y*2.5;
				}				
			}
			#else
			if(Auto_Scaler_Adjust)
			{
				if(Shift_Depth().x)
					Shift_TC *= 1-Depth_Size * 2.5;
				if(Shift_Depth().y)
					Shift_TC.x *= 1-Depth_Size.x * 3.0;
				if(Shift_Depth().z)
					Shift_TC.y *= 1-Depth_Size.y*2.5;
				//Shift_TC.y -= Depth_Size.y;		
			}
			#endif
		#endif		
		MixOut = GetDB( Shift_TC );
		
		#if LBM || LetterBox_Masking
			float LB_Dir = LetterBox_Masking == 2 || LBM == 2 ? texcoord.x : texcoord.y;
			float2 Cal_LB_Mask = saturate(float2(DI_X,1-DI_X));
			float LB_Detection = tex2D(SamplerAvrP_N,float2(1,0.0625)).z,LB_Masked = LB_Dir > Cal_LB_Mask.y && LB_Dir < Cal_LB_Mask.x ? MixOut : 0.0125;
			
			if(LB_Detection)
				MixOut = LB_Masked;	
		#endif
			
		//MixOut = MixOut;
	}
	
	float GetMixed(float2 texcoord) //Sensitive Buffer.
	{
		//Careful not to shift here because we run out of memory in DX9
		return tex2Dlod(SamplerzBufferN_Mixed,float4(texcoord,0,0)).x;//Do not use mips on this buffer
	}
	#if !Use_2D_Plus_Depth
	float2 De_Art(float2 sp, float2 Shift_n_Zoom)
	{  //sp.y * Shift_n_Zoom.y + (1-Shift_n_Zoom.y)*0.5
		//if(De_Artifacting.x < 0)
		if( De_Art_Opt )
			return float2(sp.x - Shift_n_Zoom.x,sp.y * Shift_n_Zoom.y + (1-Shift_n_Zoom.y)*0.5);//lerp(ZoomDir,0, Depth);
		else
			return float2(sp.x - Shift_n_Zoom.x,sp.y);//lerp(ZoomDir,0, Depth);
	}	
	//#define BATCH_SIZE 2
	//Perf Level selection & Array access               X    Y      Z      W              X    Y      Z      W
	//static const float2 Performance_LvL[2] = { float4( 0.5, 0.5095, 0.679, 0.5 ), float4( 1.0, 1.019, 1.425, 1.0) };
	//Perf Level selection & Array access                X      Y               X    Y  
	static const float2 Performance_LvL0[2] = { float2( 0.5  , 0.679), float2( 1.0, 1.425) };
	static const float2 Performance_LvL1[2] = { float2( 0.375, 0.479), float2( 0.5, 0.679) };
	static const float  VRS_Array[5] = { 0.5, 0.5, 0.25, 0.125 , 0.0625 };
	static const float  HFI_Array[4] = { 0, 5, 6, 7};
	//////////////////////////////////////////////////////////Parallax Generation///////////////////////////////////////////////////////////////////////
	float3 Parallax(float Diverge, float2 Coordinates, float IO) // Horizontal parallax offset & Hole filling effect
	{
	    float  MS = Diverge * pix.x; uint Perf_LvL = fmod(Performance_Level,2); 		
		float2 ParallaxCoord = Coordinates, CBxy = floor( float2(Coordinates.x * BUFFER_WIDTH, Coordinates.y * BUFFER_HEIGHT));
		float LR_Depth_Mask = saturate(tex2Dlod(SamplerzBuffer_BlurN, float4( Coordinates  * float2(0.5,1) + float2(0.5,0), 0, 3.0 ) ).x * 2.5);
		float GetDepth = smoothstep(0,1, tex2Dlod(SamplerzBufferN_L, float4(Coordinates,0, 2.0) ).x), CB_Done = fmod(CBxy.x+CBxy.y,2),
			  Perf = Performance_Level > 1 ? lerp(Performance_LvL1[Perf_LvL].x,Performance_LvL0[Perf_LvL].x,GetDepth) : Performance_LvL0[Perf_LvL].x;

		float DepthLR = 1, LRDepth = 1, LDepthR, sumW, DLR, Num, S[6] = {0.5,0.6,0.7,0.8,0.9,1.01};
		#if Legacy_Mode
			MS = -MS;

			[loop]
			for ( int i = 0 ; i < 6; ++i )
			{   
				Num = S[i] * MS;
				LRDepth = min(LRDepth, GetMixed(float2(ParallaxCoord.x + Num, ParallaxCoord.y)).x );	
	
				if(View_Mode == 1)
				{							
					float w0 = 1.0, w1 = 0.50, w2 = 0.375, w3 = 0.250, w4 = 0.125, w5 = 0.0625, w6 = 0.03125;
					sumW = w0 + w1 + w2 + w3 + w4 + w5 + w6;
					float Mix_Depth = min(DepthLR,GetMixed(float2(ParallaxCoord.x + 0.500 * MS, ParallaxCoord.y)).x) * w0;
					float Cal_Mid_Depth = Mix_Depth;
						  Mix_Depth += GetMixed(float2(ParallaxCoord.x + 0.5833 * MS, ParallaxCoord.y)).x * w1;
						  Mix_Depth += GetMixed(float2(ParallaxCoord.x + 0.6667 * MS, ParallaxCoord.y)).x * w2;
						  Mix_Depth += GetMixed(float2(ParallaxCoord.x + 0.7500 * MS, ParallaxCoord.y)).x * w3;
						  Mix_Depth += GetMixed(float2(ParallaxCoord.x + 0.8333 * MS, ParallaxCoord.y)).x * w4;
						  Mix_Depth += GetMixed(float2(ParallaxCoord.x + 0.9167 * MS, ParallaxCoord.y)).x * w5;
						  Mix_Depth += GetMixed(float2(ParallaxCoord.x + 1.0000 * MS, ParallaxCoord.y)).x * w6;
					Mix_Depth /= sumW;
		
					Mix_Depth = min(Mix_Depth,Cal_Mid_Depth);
					//Test with Cal_Mid_Depth & LRDepth
					DLR = abs(Mix_Depth - LRDepth);
					DLR = lerp(saturate(1-DLR) * 0.1 + 0.1,saturate(1-DLR) * 0.2 + 0.2,LRDepth);	
					DepthLR = lerp(Mix_Depth,LRDepth,DLR);
				}		
			}
			//Reprojection Left and Right
			if(View_Mode == 1 || View_Mode == 2)
				ParallaxCoord = float2(Coordinates.x + MS * DepthLR, Coordinates.y);
			else
				ParallaxCoord = float2(Coordinates.x + MS * LRDepth, Coordinates.y);

			return float3(ParallaxCoord,DepthLR); 
		#else
			//Would Use Switch....
			if( View_Mode == 2)
				Perf = Performance_Level > 1 ? lerp(Performance_LvL1[Perf_LvL].y,Performance_LvL0[Perf_LvL].y,GetDepth) : Performance_LvL0[Perf_LvL].y;
			if( View_Mode == 4)
				Perf = lerp( CB_Done ? 0.679f : 0.367f,0.367f, saturate((GetDepth * 0.5)/LR_Depth_Mask) );
			if( View_Mode == 5)
				Perf = lerp(0.375f,0.679f,GetDepth);				
				
			//Luma Based VRS
			float Luma_Map = smoothstep(0.0,0.375, tex2Dlod(SamplerCN,float4(Coordinates,0,7)).x);
			if( Performance_Level > 1 )
					Perf *= lerp(0.25,1.0,smoothstep(0.0,0.25,saturate( Luma_Map )));
			//Foveated Calculations	
			float Foveated_Mask = saturate(Vin_Pattern(Coordinates, float2(16.0,2.0))), MaxMix = lerp(100, 50, saturate(GetDepth * 2 - 1) );	
			if(Foveated_Mode)
				MaxMix = lerp(75, 25, saturate(Foveated_Mask * saturate(GetDepth * 2 - 1 ) ));
	
			//Extra scaleing for the main Loop
			float Mod_Depth = saturate(GetDepth * lerp(1,15,abs(Artifact_Adjust().y))), Reverse_Depth = Artifact_Adjust().y < 0 ? 1-Mod_Depth : Mod_Depth,
				  Scale_With_Depth = Artifact_Adjust().y == 0 ? 1 : Reverse_Depth;
				  
			//De-Artifacting.
			float AA_Value = Artifact_Adjust().x;
			float Corners = saturate(tex2Dlod(SamplerzBufferN_L,float4(Coordinates,0,HFI_Array[Target_High_Frequency])).y);
			float Smooth_C = smoothstep(0.0,1.0,Corners * 1000);
				  if(Target_High_Frequency > 0)
				  AA_Value = lerp(AA_Value,1.0,Smooth_C);
				  
			//Adjustments and Switching for De-Artifacting.	  
			float AA_Switch = De_Artifacting.x < 0 ? lerp(0.3 * AA_Value,AA_Value ,smoothstep(0.0,1.0,Foveated_Mask)): AA_Value;
			float2 Artifacting_Adjust = float2(MS.x * lerp(0,0.125,clamp(AA_Switch * Scale_With_Depth,0,2)),1.0 - (MS.x * lerp(0,0.25,clamp(AA_Value * Scale_With_Depth,0,2))));
			// Perform the conditional check outside the loop
			bool applyArtifacting = (AA_Value != 0);
			
			if( View_Mode >= 2 && View_Mode < 5)
					applyArtifacting = 0;	
					
				//ParallaxSteps Calculations
				float MinNum = 25, MaxNum = MaxMix, D = abs(Diverge), Cal_Steps = D * Perf,
					  Steps  = clamp( Cal_Steps, MinNum, MaxNum );//Foveated Rendering Point of attack 16-256 limit samples.
	
				float N = 0.5,F = 1.0, Z = tex2Dlod(SamplerzBuffer_BlurN, float4( Coordinates  * float2(0.5,1) + float2(0.5,0), 0, 1 ) ).x;
			    float ZS = smoothstep(0.5,1.0,( Z - N ) / ( F - N));
				float Auto_Compatibility_Power = abs(Compatibility_Power) ? Compatibility_Power : lerp(-0.25,0.0, ZS );
		
				float LayerDepth = rcp(Steps),  TP = lerp(0.025, 0.05,Auto_Compatibility_Power) * ( Compatibility_Power >= 0 ? 1 : Foveated_Mask );
				float D_Range = lerp(75,25,GetDepth), US_Offset = Diverge < 0 ? -D_Range : D_Range;
			
				//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
				float deltaCoordinates = MS.x * LayerDepth, CurrentDepthMapValue = min(1,GetMixed( ParallaxCoord).x), CurrentLayerDepth = -Re_Scale_WN().x,
					  DB_Offset = US_Offset * TP * pix.x;
	
			
			[loop] //Steep parallax mapping Ray Marcher
			while ( CurrentDepthMapValue >= CurrentLayerDepth )
			{   
				if(CurrentDepthMapValue < CurrentLayerDepth)//Had to do this check to keep it from crashing
					break;
				// Shift coordinates horizontally in linear fasion
			    ParallaxCoord.x -= deltaCoordinates; 
			    // Get depth value at current coordinates
			    float G_Depth = GetMixed(ParallaxCoord).x;  
			    if ( applyArtifacting )
					CurrentDepthMapValue = min(G_Depth.x, GetMixed( De_Art(ParallaxCoord, Artifacting_Adjust ) ).x);
				else
					CurrentDepthMapValue = G_Depth.x;				
			    // Get depth of next layer
			    CurrentLayerDepth += LayerDepth;
			}
			
				if( View_Mode <= 1 || View_Mode >= 5 )	
			   	ParallaxCoord.x += DB_Offset * 0.125;
		    
				float2 PrevParallaxCoord = float2( ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y);
				//Anti-Weapon Hand Fighting                                         // Set to 6.0 if it I want it Stronger.
				float Weapon_Mask = WeaponMask(Coordinates,0), ZFighting_Mask = 1.0-(1.0-WeaponMask(Coordinates,5.5) - Weapon_Mask); //tex2Dlod(SamplerDMN,float4(Coordinates,0,0)).y, ZFighting_Mask = 1.0-(1.0-tex2Dlod(SamplerDMN,float4(Coordinates ,0,5.5)).y - Weapon_Mask);
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
				float2 DD_Spread = saturate(float2(DD_Map > 0.032,DD_Map > lerp(0.128,0.064 ,LR_Depth_Mask )));//was 0.064 may add this back later.
				float weight = afterDepthValue / min(-0.0125,DepthDiffrence);
					  weight = lerp(weight + 2.0 * DD_Spread.x,weight,0.75);//Reversed the logic since it seems look better this way and it leans towards the normal output.
				float Weight = weight;
				//ParallaxCoord.x = lerp( ParallaxCoord.x, PrevParallaxCoord.x, weight); //Old		
				ParallaxCoord.x = PrevParallaxCoord.x * weight + ParallaxCoord.x * (1 - Weight);
				//This is to limit artifacts.	
				ParallaxCoord.x += lerp(DB_Offset, DB_Offset * 2.0, DD_Spread.y );// Also boost in some areas using DD_Map
	
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
			
			return float3(ParallaxCoord,DD_Map >= 0.06);
		#endif
	}

	///////////////////////////////////////////////////////////Stereo Conversions///////////////////////////////////////////////////////////////////////
	#if !Virtual_Reality_Mode
	uint4 Frame_Selector()
	{
		int FS_RM = Reconstruction_Mode ? 2 : 6;
		return uint4(fmod(Alternate,2),fmod(Frames,4),0,FS_RM);
	}

	float Anaglyph_Selection(int Selection)
	{
		float Anaglyph_Array[10] = { 0,
									 1,
									 2,
									 3,
									 4,
									 5,
									 6,
									 7,
									 8,
									 9
									};
		float Anaglyph = Anaglyph_Array[Selection].x;//Reconstruction_Mode ? Anaglyph_Array[Selection].y : Anaglyph_Array[Selection].x;
		return Anaglyph;
	}
	
	float4 Stereo_Convert(float2 texcoord, float4 cL, float4 cR)
	{   float4 L = float4(cL.rgb,0),R = float4(cR.rgb,0);   
		float2 TC = texcoord; float4 color, accum, image = 1, color_saturation = lerp(0,2,Anaglyph_Saturation);
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
		if (Stereoscopic_Mode == Frame_Selector().w && EX_DLP_FS_Mode)
		{
			color = Frame_Selector().x ? L : R;
		}
		#if Inficolor_3D_Emulator || Anaglyph_Mode
			float3 HalfLA = dot(L.rgb,float3(0.299, 0.587, 0.114)), HalfRA = dot(R.rgb,float3(0.299, 0.587, 0.114));
			float3 LMA = lerp(HalfLA,L.rgb,color_saturation.xxx), RMA = lerp(HalfRA,R.rgb,color_saturation.xxx);
			float2 Contrast = lerp(0.875,1.125,Anaglyph_Eye_Contrast);		
			// Left/Right Image
			float4 cA = float4(saturate(LMA),1);
			float4 cB = float4(saturate(RMA),1);
			cA = (cA - 0.5) * Contrast.x + 0.5; cB = (cB - 0.5) * Contrast.y + 0.5;
			#if !Anaglyph_Mode || Inficolor_3D_Emulator
			if(Stereoscopic_Mode == 0)
			{
				float3 leftEyeColor = float3(1.0,0.0,1.0); //magenta
				float3 rightEyeColor = float3(0.0,1.0,0.0); //green
				
				color = saturate(((cA.rgb*leftEyeColor)+(cB.rgb*rightEyeColor)));// * float3(1,1,rcp(1+Deghost)));
			}
			else
			{
				float red = cA.r;// Left
				float green = dot(cB.rgb,float3(0.299, 0.587, 0.114)); 	
				float blue = cA.b;
		
				color = float4(red, green, blue, 0);		
			}
			/* Extra options med Deghosting
			else
			{
				float red = lerp(cA.r , cA.b, 0.5);// Left
				float green = lerp(cB.g , cB.b, 0.5); // Right
				float blue = cA.b;
				//float blue = dot(cA.rgb,float3(0.299, 0.587, 0.114));
		
				color = float4(red, green, blue, 0);				
			}
			else //Max Deghosing
			{
				float red = cA.r + cA.b;// Left
				float green = cB.g + cB.b; // Right
				float blue = dot(cB.rgb,float3(0.299, 0.587, 0.114)) + dot(cA.rgb,float3(0.299, 0.587, 0.114));
		
				color = float4(red, green, blue * 0.5, 0);
			}
			*/
			#else	
			if(Stereoscopic_Mode >= Anaglyph_Selection(0))
			{
				float DeGhost = 0.06, LOne, ROne;
				//L.rgb += lerp(-1, 1,Anaglyph_Eye_Brightness.x); R.rgb += lerp(-1, 1,Anaglyph_Eye_Brightness.y);
				float3 HalfLA = dot(L.rgb,float3(0.299, 0.587, 0.114)), HalfRA = dot(R.rgb,float3(0.299, 0.587, 0.114));
				float3 LMA = lerp(HalfLA,L.rgb,color_saturation.xxx), RMA = lerp(HalfRA,R.rgb,color_saturation.xxx);
				float2 Contrast = lerp(0,2,Anaglyph_Eye_Contrast);		
				// Left/Right Image
				float4 cA = float4(saturate(LMA),1);
				float4 cB = float4(saturate(RMA),1);
				//cA = (cA - 0.5) * Contrast.x + 0.5; cB = (cB - 0.5) * Contrast.y + 0.5;
	
				if( Stereoscopic_Mode == Anaglyph_Selection(0) || Stereoscopic_Mode == Anaglyph_Selection(1) || Stereoscopic_Mode == Anaglyph_Selection(3) || Stereoscopic_Mode == Anaglyph_Selection(8) ) 
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
		
				if( Stereoscopic_Mode == Anaglyph_Selection(2) || Stereoscopic_Mode == Anaglyph_Selection(5) ) 
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
				// Anaglyph Start
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
				else if (Stereoscopic_Mode == Anaglyph_Selection(3)) // Anaglyph 3D Colors Red/Cyan LCD Optimized Anaglyph https://cybereality.com/rendepth-red-cyan-anaglyph-filter-optimized-for-stereoscopic-3d-on-lcd-monitors/
				{   //LCD Optimized Anaglyph by Andres Hernandez - AKA cybereality
				
					const float3 gammaMap = float3(1.6, 0.8, 1.0);
					const float3x3 left_filter = float3x3( float3(0.4561   ,-0.400822  ,-0.0152161  ),
														   float3(0.500484 ,-0.0378246 ,-0.0205971  ),
														   float3(0.176381 ,-0.0157589 ,-0.00546856 ));
					const float3x3 right_filter = float3x3( float3(-0.0434706  , 0.378476   ,-0.0721527),
														    float3(-0.0879388  , 0.73364    ,-0.112961 ),
														    float3(-0.00155529 , -0.0184503 , 1.2264   ));
				
						color.rgb = saturate(mul(cA.rgb, left_filter));// Left
						color.rgb += saturate(mul(cB.rgb,right_filter));// Right
						color.rgb = pow(color.rgb,rcp(gammaMap.rgb));
				}
				else if (Stereoscopic_Mode == Anaglyph_Selection(4)) // Anaglyph 3D Green/Magenta
					color = float4(cB.r,cA.g,cB.b,1.0);
				else if (Stereoscopic_Mode == Anaglyph_Selection(5)) // Anaglyph 3D Dubois Green/Magenta
				{
					float red = -0.062 * cA.r -0.158 * cA.g -0.039 * cA.b + 0.529 * cB.r + 0.705 * cB.g + 0.024 * cB.b;
		
					if (red > 1) { red = 1; }   if (red < 0) { red = 0; }
		
					float green = 0.284 * cA.r + 0.668 * cA.g + 0.143 * cA.b - 0.016 * cB.r - 0.015 * cB.g + 0.065 * cB.b;
		
					if (green > 1) { green = 1; }   if (green < 0) { green = 0; }
		
					float blue = -0.015 * cA.r -0.027 * cA.g + 0.021 * cA.b + 0.009 * cB.r + 0.075 * cB.g + 0.937  * cB.b;
		
					if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
		
					color = float4(red, green, blue, 0);
				}
				else if (Stereoscopic_Mode == Anaglyph_Selection(6))// Anaglyph 3D Deghosted Green/Magenta Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
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
				else if (Stereoscopic_Mode == Anaglyph_Selection(7)) // Anaglyph 3D Blue/Amber Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
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
				else if (Stereoscopic_Mode == Anaglyph_Selection(8)) // Anaglyph 3D Red/Blue Optimized https://stereo.jpn.org/eng/stphmkr/help/stereo_13.htm
				{   // Note to self I need to revist all modes http://www.flickr.com/photos/e_dubois/5230654930/
					
					float red = ( cA.r * 299 + cA.g * 587 + cA.b* 114 +  cB.r * 0 +  cB.g * 0 +  cB.b * 0 ) / 1000;
					//float green = (cA.r * 0 + cA.g * 0 + cA.b * 0 + cB.r * 0 + cB.g * 0 + cB.b * 0) / 1000;
					float blue = (cA.r * 0 + cA.g * 0 + cA.b * 0 + cB.r * 299 + cB.g * 587 + cB.b * 114) / 1000;
		
					color = float4(red, 0, blue, 0);			
				}
				else if (Stereoscopic_Mode == Anaglyph_Selection(9)) // Anaglyph 3D Magenta-Cyan
				{
					float red = cA.r + cA.b;// Left
					float green = cB.g + cB.b; // Right
					//float blue = max(cA.r,max(cA.g,cA.b)) + max(cB.r,max(cB.g,cB.b));
					//float blue = min(cA.r,min(cA.g,cA.b)) + min(cB.r,min(cB.g,cB.b));
					float blue = dot(cB.rgb,float3(0.299, 0.587, 0.114)) + dot(cA.rgb,float3(0.299, 0.587, 0.114));
			
					color = float4(red, green, blue * 0.5, 0);
				}
	
			}		
			#endif	
		#else

		#endif
		return color;
	}
	#endif
	///////////////////////////////////////////////////////////Stereo Calculation///////////////////////////////////////////////////////////////////////
	float2 FoVCal(float2 texcoord)
	{	   //Field of View
			float fov = FoV-(FoV*0.2), F = -fov + 1,HA = (F - 1)*(BUFFER_WIDTH*0.5)*pix.x,AR_Scale = 1.0;
			//Field of View Application
			if(Theater_Mode == 2)
				AR_Scale = 0.875;
			if(Theater_Mode == 3)
				AR_Scale = 0.75;
			float2 Z_A = float2(AR_Scale,1.0); //Theater Mode
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
			
			return texcoord;
	}

	#if Reconstruction_Mode || Virtual_Reality_Mode || Anaglyph_Mode
		#if Anaglyph_Mode
		void Anaglyph(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 LR_Out: SV_Target0)
		#else
		void CB_Reconstruction(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Left : SV_Target0, out float4 Right : SV_Target1)
		#endif
	#else
	float3 PS_calcLR(float2 texcoord, float2 position)
	#endif
	{
		#if REST_UI_Mode
			bool CLK_L = Toggle_REST;
			if(Cursor_Lock_Button_Selection == 1)
				CLK_L = CLK_02;
			if(Cursor_Lock_Button_Selection == 2)
				CLK_L = CLK_03;					
			if(Cursor_Lock_Button_Selection == 3)
				CLK_L = CLK_04;
				
			float Mouse_Toggle_Click = !CLK_L;
		#else
			float Mouse_Toggle_Click = 1;
		#endif
		float D = Eye_Swap ? -Min_Divergence().x : Min_Divergence().x;

		float FadeIO = Focus_Reduction_Type == 1 ? 1 : smoothstep(0, 1, 1 - Fade_in_out().x), FD = D, FD_Adjust = 0.2;
						
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
		if( World_n_Fade_Reduction_Power.x == 8)
			FD_Adjust = 0.75;

		if (FPSDFIO >= 1)
			FD = lerp(FD * FD_Adjust,FD,FadeIO);
	
		float2 DLR = float2(FD,FD),Persp = Per;
		float Per_Fade = lerp(FD_Adjust,1.0,FadeIO);
		
		if( Eye_Fade_Selection == 0)
			Persp *= Per_Fade;
		if( Eye_Fade_Selection == 1)
		{
			Persp *= float2(1,Per_Fade); 
			DLR = float2(D,FD);
		}
		else if( Eye_Fade_Selection == 2)
		{
			Persp *= float2(Per_Fade,1);
			DLR = float2(FD,D); 
		}
  
		if(Stereoscopic_Mode == 0 && !Inficolor_3D_Emulator && !Anaglyph_Mode)
			Persp *= 0.5f;
		//if(Stereoscopic_Mode == 5)//Need to work on this later.
		//	Persp *= 0.25;
		float2 TCL = texcoord, TCR = texcoord, TCL_T = texcoord, TCR_T = texcoord, TexCoords = texcoord;


		#if Inficolor_3D_Emulator
		if(Inficolor_Auto_Focus)
			Persp *= lerp(0.75,1.0, saturate(smoothstep(-0.0175,min(0.5,0.13),Avr_Mix(texcoord).x)) );
		#endif

		TCL += Persp; TCR -= Persp; TCL_T += Persp; TCR_T -= Persp;
		#if !Virtual_Reality_Mode
			#if !Reconstruction_Mode
				#if !Inficolor_3D_Emulator
					#if !Anaglyph_Mode
						[branch] if (Stereoscopic_Mode == 0 && !REST_UI_Mode )
						{
							TCL.x = TCL.x*2;
							TCR.x = TCR.x*2-1;
						}
						else if(Stereoscopic_Mode == 1 && !REST_UI_Mode )
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
			#endif
		#endif
		float4 color, Left_T, Right_T, L, R, Left_Right;
		//FoV Cal for left and right eye.
		if(Stereoscopic_Mode == 0)
		{
			TCL = FoVCal(TCL);
			TCR = FoVCal(TCR);
		}
		
		float3 Pattern = float3( floor(TexCoords.y*Res.y) + floor(TexCoords.x*Res.x), floor(TexCoords.x*Res.x), floor(TexCoords.y*Res.y));
		float Pattern_Type = fmod(Pattern.x,2); //CB
		#if Virtual_Reality_Mode
				float4 Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
		
				if(Vert_3D_Pinball)
					Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).yxz, position.xy , Mouse_Toggle_Click, 0);		
				else
					Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).xyz, position.xy , Mouse_Toggle_Click, 0);	
		#else
			#if Reconstruction_Mode	
			if(Reconstruction_Type == 1 )
				Pattern_Type = fmod(Pattern.z,2); //LI
			if(Reconstruction_Type == 2 )
				Pattern_Type = fmod(Pattern.y,2); //CI
				
			float4 Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
		
				if(Vert_3D_Pinball)
					Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).yxz, position.xy , Mouse_Toggle_Click, 0);		
				else
					Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).xyz, position.xy , Mouse_Toggle_Click, 0);	
			#else
				#if REST_UI_Mode
				if(Stereoscopic_Mode == 2 || Stereoscopic_Mode == 1)
					Pattern_Type = fmod(Pattern.z,2); //LI
				if( Stereoscopic_Mode == 3 || Stereoscopic_Mode == 0)
					Pattern_Type = fmod(Pattern.y,2); //CI
				#else
				if(Stereoscopic_Mode == 0)
					Pattern_Type = TexCoords.x < 0.5; //SBS
				if( Stereoscopic_Mode == 1)
					Pattern_Type = TexCoords.y < 0.5; //TnB
				if(Stereoscopic_Mode == 2)
					Pattern_Type = fmod(Pattern.z,2); //LI
				if( Stereoscopic_Mode == 3)
					Pattern_Type = fmod(Pattern.y,2); //CI
				#endif
			float4 Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
	
			if(Stereoscopic_Mode == 5)
				Shift_LR = TexCoords.y < 0.5 ? TexCoords.x < 0.5 ? float4(-DLR.x,TCL,AI) : float4(-DLR.x * 0.33333333,TCL_T,AI) : TexCoords.x < 0.5 ? float4(DLR.y * 0.33333333, TCR_T, -AI) : float4(DLR.y, TCR, -AI);
	
			if(Stereoscopic_Mode >= 6 || Inficolor_3D_Emulator || Anaglyph_Mode)
			{		
				if(Vert_3D_Pinball)
				{
					L = MouseCursor(Parallax(-DLR.x, TCL.yx, AI).yxz, position.xy , Mouse_Toggle_Click, 0);
					R = MouseCursor(Parallax( DLR.y, TCR.yx,-AI).yxz, position.xy , Mouse_Toggle_Click, 0);
				}
				else
				{
					L = MouseCursor(Parallax(-DLR.x,TCL, AI).xyz, position.xy , Mouse_Toggle_Click, 0);
					R = MouseCursor(Parallax( DLR.y,TCR,-AI).xyz, position.xy , Mouse_Toggle_Click, 0);
				}
			}
			else	
			{
				if(Vert_3D_Pinball && Stereoscopic_Mode != 5)
					Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).yxz, position.xy , Mouse_Toggle_Click, 0);		
				else
					Left_Right = MouseCursor(Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w).xyz, position.xy , Mouse_Toggle_Click, 0);		
			}
			#endif
		#endif
				//Left_Right.rgb *= 1-Left_Right.w;
		//Convert Stereo
		#if Reconstruction_Mode || Virtual_Reality_Mode
		color.rgb = Left_Right.rgb;
		#else
		color.rgb = Stereoscopic_Mode >= 6 || Inficolor_3D_Emulator || Anaglyph_Mode ? Stereo_Convert( TexCoords, L, R).rgb : Left_Right.rgb;
		#endif
		
		color = AdjustSaturation(color);
		
		if (Depth_Map_View == 2)
			color.rgb = tex2D(SamplerzBufferN_P,TexCoords).xxx;
				
		float DepthBlur, Alinement_Depth = tex2Dlod(SamplerzBufferN_Mixed,float4(TexCoords,0,0)).x, Depth = Alinement_Depth;
		const float DBPower = 50, Con = 9;
		const float2 cardinalOffsets[9] = {
										    float2( 0,  0),  // Center (no offset)
										    float2(-1,  0),  // Left
										    float2( 1,  0),  // Right
										    float2( 0, -1),  // Down
										    float2( 0,  1),  // Up
										    float2(-2, -2),  // Down Left
										    float2( 2, -2),  // Down Right
										    float2(-2,  2),  // Up Left
										    float2( 2,  2)   // Up Right
										  };
		if(BD_Options == 2 || Alinement_View)
		{
			float2 dir = 0.5 - TexCoords; 
			[loop]
			for (int i = 0; i < Con; i++)
			{
				DepthBlur += tex2Dlod(SamplerzBufferN_Mixed,float4(TexCoords + dir * cardinalOffsets[i] * pix * DBPower,0,1) ).x;
			}
			
			Alinement_Depth = ( Alinement_Depth + DepthBlur ) * 0.1;
		}
	
		if (BD_Options == 2 || Alinement_View)
			color.rgb = dot(tex2D(BackBuffer_B,TexCoords).rgb,0.333) * float3((Depth/Alinement_Depth> 0.998),1,(Depth/Alinement_Depth > 0.998));
		if( Helper_Fuction() == 0 || timer <= 0)  
			color.rgb *= TexCoords.xyx;
		
	#if Reconstruction_Mode || Virtual_Reality_Mode 
		Left.rgb = Pattern_Type ? 0 : color.rgb ; 
		Right.rgb= Pattern_Type ? color.rgb  : 0;
		Left.w = 1.0; 
		Right.w= 1.0;
	#else
		#if Anaglyph_Mode
		LR_Out = color.rgba;
		#else
		return color.rgb;
		#endif
	#endif
	}
	#endif
	///////////////////////////////////////////////////////Average & Information Textures///////////////////////////////////////////////////////////////
	void Average_Info(float4 position : SV_Position, float2 texcoord : TEXCOORD, out  float4 Average : SV_Target0)
	{   float Half_Buffer = texcoord.x < 0.5;
		float Average_ZPD = tex2Dlod(SamplerzBuffer_BlurEx,float4(texcoord,0,0)).x;
		float Detect_Popout = tex2Dlod(SamplerzBufferN_L,float4(texcoord,0,1)).x < 0;
		//0.083 //0.0625
		//0.250 //0.1875
		//0.416 //0.3125
		//0.583 //0.4375
		//0.750 //0.5625
		//0.916 //0.6875
		        //0.8125
		        //0.9375	
		const int Num_of_Values = 8; //8 total array values that map to the textures width.
		float Storage_Array_A[Num_of_Values] = { tex2D(SamplerDMN,0).x,    			 //0.0625 //TL Fade in Out
	                                             tex2D(SamplerDMN,1).x,                 //0.1875 //BR Fade X Level 0
	                                             tex2D(SamplerDMN,int2(0,1)).x,         //0.3125 //BL Fade Y Level 1
	                                             tex2D(SamplerzBufferN_P,0).y,          //0.4375 //TL
								             	tex2D(SamplerzBufferN_P,1).y,          //0.5625 //BR AltWeapon_Fade
								             	tex2D(SamplerzBufferN_P,int2(0,1)).y,  //0.6875 //BL Weapon_ZPD_Fade
												 tex2D(SamplerzBufferN_L,0).y,          //0.8125 //TL Popout detection
												 1.0}; 			                     //0.9375								 
												 //LBDetection Seems to be causing issues with TC_SP.xy											 
		float Storage_Array_B[Num_of_Values] = { LBDetection(),                         //0.0625                     
	                                			 tex2D(SamplerDMN,int2(1,0)).x,         //0.1875 //TR Fade Z Level 2
	                               			  tex2D(SamplerDMN,int2(1,0)).y,         //0.3125 //TR Fade Z Level 3
	                                			 tex2D(SamplerDMN,0).y,                 //0.4375 //BR Fade Z Level 4
												 tex2D(SamplerDMN,1).y,                 //0.5625 //TL Fade Z Level 5
												 tex2D(SamplerzBufferN_P,int2(1,0)).y,  //0.6875 
												 tex2D(SamplerDMN,int2(0,1)).y,         //0.8125 //BL Fade W The Switch
												 tex2D(SamplerzBufferN_L,int2(0,1)).y}; //0.9375 //BL OverShoot_Fade()
		//Set a avr size for the Number of lines needed in texture storage.
		float Grid = floor(texcoord.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);
		#if WHM 
		float UI_MAP = texcoord.x < 0.5 ? WeaponMask(texcoord * float2(2,1),7.5) : WeaponMask(texcoord * float2(2,1) - float2(1,0),7.0);
 	   #else
		float UI_MAP = 0.0;
			//#if GMT
			 //	UI_MAP = WeaponMask(texcoord * float2(2,1),7.5) ;
			//#endif
		#endif 	   
		Average = float4(UI_MAP, Average_ZPD, Half_Buffer ? Storage_Array_A[int(fmod(Grid,Num_of_Values))] : Storage_Array_B[int(fmod(Grid,Num_of_Values))],Detect_Popout);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	float colorDiffBlend(float3 a, float3 b)
	{
	    float3 differential = a - b;
	    return rcp(length(differential) + 0.001);
	}

	#if Reconstruction_Mode || Virtual_Reality_Mode
	float4 Direction(float2 texcoord,float dx, float dy, int Switcher) //Load Pixel
	{	texcoord += float2(dx, dy);
		if(Switcher == 1) 
			return tex2D(Sampler_SD_CB_L, texcoord ) ;
		else
			return tex2D(Sampler_SD_CB_R, texcoord ) ;
	}
	
	float4 differentialBlend(float2 texcoord, int Switcher, int Set_Direction)
	{    
		if ((texcoord.x > 1 || texcoord.x < 0) || (texcoord.y > 1 || texcoord.y < 0))
		    return 0;

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
			Result = Center + HorzResult * 0.5 * rcp(horizontalWeight);
		else
			Result = Center + (VertResult + HorzResult) * 0.5 * rcp(verticalWeight + horizontalWeight);
			
	    return Result;
	}
	#endif
	/* //Placed on Hold
	#if Filter_Final_Image
	float4 Dir(sampler Tex, float2 texcoord,float dx, float dy) //Load Pixel
	{	   texcoord += float2(dx, dy);
			return tex2D(Tex, texcoord ) ;
	}
	
	float4 CBBlend(sampler Tex,float2 texcoord)
	{    
		if ((texcoord.x > 1 || texcoord.x < 0) || (texcoord.y > 1 || texcoord.y < 0))
		    return 0;

		float4 Up     = Dir(Tex,texcoord, 0.0  ,-pix.y),
		       Down   = Dir(Tex,texcoord, 0.0  , pix.y),
		       Left   = Dir(Tex,texcoord,-pix.x, 0.0  ),
		       Right  = Dir(Tex,texcoord, pix.x, 0.0  ),
			   Center = Dir(Tex,texcoord, 0.0  , 0.0  ), 
               Result;
	
	    float verticalWeight = colorDiffBlend(Up.rgb, Down.rgb);
	    float horizontalWeight = colorDiffBlend(Left.rgb, Right.rgb);
		float4 VertResult = (Up + Down) * verticalWeight;
		float4 HorzResult = (Left + Right) * horizontalWeight;
	    
		Result = Center + (VertResult + HorzResult) * 0.5 * rcp(verticalWeight + horizontalWeight);
			
	    return Result * 0.5;
	}
	#endif	
	*/
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
	#if !Use_2D_Plus_Depth
		#if Virtual_Reality_Mode	
		///////////////////////////////////////////////////////////Barrel Distortion///////////////////////////////////////////////////////////////////////
		int VR_Stereoscopic_Mode()
		{
			return Menu_Open ? 3 : Stereoscopic_Mode;
		}
		
		float4 Circle(float4 C, float2 TC)
		{
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
		
		float2 BD(float2 p, float k1, float k2) //Polynomial Lens + Radial lens undistortion filtering Left & Right
		{
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
		
		//SamplerDouble
		float3 L(float2 texcoord)
		{
			float3 Left;
			if(VR_Stereoscopic_Mode() == 0 || VR_Stereoscopic_Mode() == 1)
				Left = differentialBlend(texcoord, 0, Reconstruction_Type).rgb;
			else
				Left = tex2Dlod(Sampler_SD_CB_L,float4(texcoord,0,0)).rgb;
	
			return Left;
		}
		
		float3 R(float2 texcoord)
		{
			float3 Right;
			if(VR_Stereoscopic_Mode() == 0 || VR_Stereoscopic_Mode() == 1)
				Right = differentialBlend(texcoord, 1, Reconstruction_Type).rgb;
			else
				Right = tex2Dlod(Sampler_SD_CB_R,float4(texcoord,0,0)).rgb;
	
			return Right;
		}
		#if Super3D_Mode
		// For Super3D a new Stereo3D output Left and Right Image compression
		float3 YCbCrLeft(float2 texcoord)
		{
			return RGBtoYCbCr(L(texcoord));
		}
		
		float3 YCbCrRight(float2 texcoord)
		{
			return RGBtoYCbCr(R(texcoord));
		}
		#endif
			float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
			{   float4 Color;
				float2 TCL = texcoord, TCR = texcoord, TC;
				float Text_Helper = Info_Fuction();
				#if !Super3D_Mode
					if (VR_Stereoscopic_Mode() == 0  )
					{
						TCL.x = TCL.x*2;
						TCR.x = TCR.x*2-1;
						TC = texcoord.x < 0.5;
					}
					
					if (VR_Stereoscopic_Mode() == 1  )
					{
						TCL.y = TCL.y*2;
						TCR.y = TCR.y*2-1;
						TC = texcoord.y < 0.5;
					}
					//Stereo Left TCL and Right TCR
					Color = TC ? tex2D(SamplerInfo,TCL).x : tex2D(SamplerInfo,TCR).x;
					
					float2 uv_redL, uv_greenL, uv_blueL, uv_redR, uv_greenR, uv_blueR;
					float4 Left, Right, color_redL, color_greenL, color_blueL, color_redR, color_greenR, color_blueR;
					float K1_Red = Polynomial_Colors_K1.x, K1_Green = Polynomial_Colors_K1.y, K1_Blue = Polynomial_Colors_K1.z;
					float K2_Red = Polynomial_Colors_K2.x, K2_Green = Polynomial_Colors_K2.y, K2_Blue = Polynomial_Colors_K2.z;
					if(Barrel_Distortion >= 1)
					{
						uv_redL = BD(TCL.xy,K1_Red,K2_Red);
						uv_greenL = BD(TCL.xy,K1_Green,K2_Green);
						uv_blueL = BD(TCL.xy,K1_Blue,K2_Blue);
				
						uv_redR = BD(TCR.xy,K1_Red,K2_Red);
						uv_greenR = BD(TCR.xy,K1_Green,K2_Green);
						uv_blueR = BD(TCR.xy,K1_Blue,K2_Blue);
			
						color_redL = L(uv_redL).r;
						color_greenL = L(uv_greenL).g;
						color_blueL = L(uv_blueL).b;	
				
						color_redR = R(uv_redR).r;
						color_greenR = R(uv_greenR).g;
						color_blueR = R(uv_blueR).b;
		
						Left = float4(color_redL.x, color_greenL.y, color_blueL.z, 1.0);
						Right = float4(color_redR.x, color_greenR.y, color_blueR.z, 1.0);
					
						if (Barrel_Distortion == 2)
						{
							Left = Circle(Left,TCL);
							Right = Circle(Right,TCR);
						}
					}
					else
					{
						Left =  L(TCL);
						Right = R(TCR);
					}
					
					float3 Left_CB = Left.rgb;//differentialBlend(TCL, 0, Reconstruction_Type).rgb;
					float3 Right_CB = Right.rgb;//differentialBlend(TCR, 1, Reconstruction_Type).rgb;
					if(VR_Stereoscopic_Mode() == 0 || VR_Stereoscopic_Mode() == 1)
						Color.rgb = TC ? Left_CB : Right_CB;
					else
						Color.rgb = L(texcoord) + R(texcoord);	  	
				#else // Super3D Mode
					float Y_Left = YCbCrLeft(texcoord).x;
					float Y_Right = YCbCrRight(texcoord).x;
		
					float CbCr_Left = texcoord.x < 0.5 ? YCbCrLeft(texcoord * 2).y : YCbCrLeft(texcoord * 2 - float2(1,0)).z;
					float CbCr_Right = texcoord.x < 0.5 ? YCbCrRight(texcoord * 2 - float2(0,1)).y : YCbCrRight(texcoord * 2 - 1 ).z;
		
					float CbCr = texcoord.y < 0.5 ? CbCr_Left : CbCr_Right;

					Color.rgb = Menu_Open ? L(texcoord) + R(texcoord) : float3(Y_Left,Y_Right,CbCr);
				#endif
				
				Color = Text_Helper ? Color.rgba + Color.w : Color; //Blend Color
				
				float4 SBS_3D = float4(1,0,0,1), Super3D = float4(0,0,1,1);
				//RGBW / R = SBS-3D / G = ?????? / B = Super3D / W = ??????
				float3 Format = !Super3D_Mode ? SBS_3D.rgb : Super3D.rgb;
				//Ok so I have to invert the pattern because for some reason the unity app I made can only read Integers values from ReShade.....
				float2 ScreenPos = float2(1-texcoord.x,1-texcoord.y) * Res;
				float Debug_Y = 1.0;// Set this higher so you can see it when Debugging
				if(all(abs(float2(1.0,BUFFER_HEIGHT)-ScreenPos.xy) < float2(1.0,Debug_Y)))
					Color.rgb = Menu_Open ? Format : 0;
				if(all(abs(float2(3.0,BUFFER_HEIGHT)-ScreenPos.xy) < float2(1.0,Debug_Y)))
					Color.rgb = Menu_Open ? 0 : Format;
				if(all(abs(float2(5.0,BUFFER_HEIGHT)-ScreenPos.xy) < float2(1.0,Debug_Y)))
					Color.rgb = Menu_Open ? Format : 0;	
				
				#if BC_SPACE == 1
			    Color = ExpandScRGB(Color);
			    #else
			    Color = Color;
			    #endif
				return Color.rgba;
			}
		#else
			float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
			{   float4 Color;
				float2 TCL = texcoord, TCR = texcoord, TC;
				float Text_Helper = Info_Fuction(), FramePos = Frame_Selector().x;
		
				if (Stereoscopic_Mode == 0 && !Inficolor_3D_Emulator && !Anaglyph_Mode)
				{
					TCL.x = TCL.x*2;
					TCR.x = TCR.x*2-1;
					TC = texcoord.x < 0.5;
				}
				
				if (Stereoscopic_Mode == 1 && !Inficolor_3D_Emulator && !Anaglyph_Mode)
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
					#if Anaglyph_Mode //Need to add blur here on blue channel.				
						float Acc = 0.0, Blur_Blue = 0.0;
						float S[7] = { -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5 };
						float W[7] = { 0.035, 0.100, 0.233, 0.264, 0.233, 0.100, 0.035 }; // Normalized Gaussian weights (σ ≈ 0.75)
						float MS = Min_Divergence().x * pix.x;
		
						if(Stereoscopic_Mode == Anaglyph_Selection(8))
						{
							Color.rg = tex2D(Sampler_SD_RL,texcoord).rg;
						
							[loop]
							for (int i = 0; i < 7; ++i)
							{
							    float Num = S[i] * MS;
							    float weight = W[i];
							    Blur_Blue += tex2Dlod(Sampler_SD_RL, float4(float2(texcoord.x + Num * 0.6666666666666667, texcoord.y), 0, 1)).b * weight;
							    Acc += weight;
							}
							Color.b = Blur_Blue / Acc;
						}
						else
						{
							Color.rgb = tex2D(Sampler_SD_RL,texcoord).rgb;
							/*
							[loop]
							for (int i = 0; i < 7; ++i)
							{
							    float Num = S[i] * MS;
							    float weight = W[i];
							    Blur_Blue += tex2Dlod(Sampler_SD_RL, float4(float2(texcoord.x + Num * 0.6666666666666667, texcoord.y), 0, 1)).b * weight;
							    Acc += weight;
							}
							Color.b = Blur_Blue / Acc;
							*/
						}					
					#else
					Color.rgb = PS_calcLR(texcoord, position.xy).rgb;
					#endif					
					#if EX_DLP_FS_Mode
					//DLP Markers SbS
					if(FS_Mode == 1 && Stereoscopic_Mode == 0 )
						if(texcoord.y > 0.999)
							Color.rgb = FramePos ? float3(0.0,1.0,1.0) : float3(1.0,0.0,0.0);
						
					//DLP Markers TnB
					if(FS_Mode == 1 && Stereoscopic_Mode == 1 )
					{
						if(texcoord.y > 0.999)
							Color.rgb = FramePos ? float3(1.0,1.0,0.0) : float3(0.0,0.0,1.0);
							
						if(texcoord.y > 0.499 && texcoord.y < 0.500)
							Color.rgb = FramePos ? float3(1.0,1.0,0.0) : float3(0.0,0.0,1.0);
					}
					//DLP FS
					if(FS_Mode == 1 && Stereoscopic_Mode == Frame_Selector().w )
						if(texcoord.y > 0.999)
							Color.rgb = Frame_Selector().y >= 2 ? float3(0.0,1.0,0.0) : float3(1.0,0.0,1.0);
					//Blue Line FS
					if(FS_Mode == 2 && Stereoscopic_Mode == Frame_Selector().w )
						if(texcoord.y > 0.999)
						{
							Color.rgb = 0;
							if(Frame_Selector().x)
								Color.rgb = texcoord.x > 0.75 ? Color.rgb : float3(0.0,0.0,1.0);
							else
								Color.rgb = texcoord.x > 0.25 ? Color.rgb : float3(0.0,0.0,1.0);
						}
					
					if(FS_Mode == 3 && Stereoscopic_Mode == Frame_Selector().w )
						if(1-texcoord.y > 0.9995 && 1-texcoord.x > 0.9995)
						{
							Color.rgb = 0;
							if(Frame_Selector().x)
								Color.rgb = 1;
						}
					#endif		
			
				#endif
				Color = Text_Helper ? Color.rgba + Color.w : Color; //Blend Color
				#if BC_SPACE == 1
			    Color = ExpandScRGB(Color);
			    #else
			    Color = Color;
			    #endif
			    //Color = OverShoot_Fade();
			    //Color = Shift_Depth().z;
			    
			    //tex2D(SamplerzBuffer_BlurN,float2(0,0.9375)).x
			    //tex2D(SamplerAvrP_N,float2(1, 0.8125)).z
			    //float InputSwitch = tex2D(SamplerzBuffer_BlurN,float2(0,0.9375)).x;
				//return int(InputSwitch * 5 ) >= 5;
				//Popout Detection
				//Color = tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w > 0; // Detect if there is pop out.
				//Color = smoothstep(0,0.1,tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w); //Scale Popout linerly 
				//Color = tex2D(SamplerzBufferN_L,0).y;
				/*
				float Value = 1.0;
				int Switch = tex2Dlod(SamplerAvrP_N,float4(0.5.xx,0,12)).w > 0;
				float S_More = tex2D(SamplerzBufferN_L,0).y;
				//Value = Switch ? Value * 0.5 : Value;
				
				Color = lerp( Value * 0.5, Value, S_More );
				*/
				//Color = Parallax(TEST, texcoord, 0).z;
				return Color.rgba;
			}
		#endif
	#else
	float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
			#if Use_2D_Plus_Depth
			float Mouse_Toggle_Click = 1;
			#else
			bool CLK_L = Toggle_REST;
			if(Cursor_Lock_Button_Selection == 1)
				CLK_L = CLK_02;
			if(Cursor_Lock_Button_Selection == 2)
				CLK_L = CLK_03;					
			if(Cursor_Lock_Button_Selection == 3)
				CLK_L = CLK_04;
				
			float Mouse_Toggle_Click = !CLK_L;
			#endif
		
			if (Depth_Map_View == 2)
				return MouseCursor(float3(texcoord.xy,0), position.xy , Mouse_Toggle_Click, 0);
			else
				return texcoord.x < 0.5 ?  MouseCursor(float3(texcoord.xy * float2(2,1),0), position.xy , Mouse_Toggle_Click, 0) : 1-GetMixed(texcoord * float2(2,1) - float2(1.0, 0.0)).x;
	}
	#endif	
	float4 InfoOut(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
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
		float4 Out = Depth3D+Read_Help+PostEffects+NoPro+NotCom+Network+ModFix+Needs+OW_State+SetAA+SetWP+SetFoV+Emu+DGDX+DXVK+AspectRaito+DisableDRS ? (1-texcoord.y*50.0+48.85)*texcoord.y-0.500: 0;

		const int Num_of_Values = 9; 
		float ZDP_Array[Num_of_Values] = {  0.25,   
											0.50,                
											0.75,         
											1.000,          
											1.000,         
											1.000,
											0.75,
											0.50,
											0.25    };


		//Set a avr size for the Number of lines needed in texture storage.
		float Grid = floor(texcoord.x * BUFFER_WIDTH * BUFFER_RCP_WIDTH * Num_of_Values);
		
		Grid = ZDP_Array[int(fmod(Grid,Num_of_Values))];
		
		/*
		const int Num_of_Values = 7;
		// Updated array with combined central value
		float ZDP_Array[Num_of_Values] = { 
											0.900,     // Edge
											0.950,     // First gradient
											0.975,     // Second gradient
											1.000,     // Combined center
											0.975,     // Second gradient
											0.950,     // First gradient
											0.900      // Edge
										 };
		
		// Map texture coordinate to the grid
		float Grid = floor(texcoord.x * BUFFER_WIDTH * (BUFFER_RCP_WIDTH * 0.5 +  0.5) * Num_of_Values * 2);
		
		// Use modulo to loop through the array
		ZPD_I *= saturate(1-ZDP_Array[int(fmod(Grid, Num_of_Values))]);
		*/
		return float4(Out.x,1-CWH_Mask(texcoord).x,Grid,1);
	}	
	
	#define SIGMA 0.25
	#define MSIZE 3
	
	float normpdf3(in float3 v, in float sigma)
	{
		return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
	}
	
	float LI(in float3 value)
	{
		return min( max( value.r, value.g ), value.b );
	}	
		
	float4 Sharp(sampler Tex, float2 texcoord, float maxRadius)
	{
	    float4 final_color, nc;
	    float Sharp_This = Sharpen_Power, mx, mn;
	
	    // Get the original color of the current pixel (center)
	    float4 centerColor = tex2D(Tex, texcoord);

	    #if !Virtual_Reality_Mode
	    if (Sharp_This > 0 && Stereoscopic_Mode != 4) //Blocks it when CB mode
	    #else
	    if (Sharp_This > 0 && Stereoscopic_Mode != 2) //Blocks it when CB mode
	    #endif
	    {
			//Bilateral Filter//                                                Q1         Q2       Q3        Q4
			const int kSize = MSIZE * 0.5; // Default M-size is Quality 2 so [MSIZE 3] [MSIZE 5] [MSIZE 7] [MSIZE 9] / 2.
			
			float2 RPC_WS = pix * 1.5;
			float Z, factor;
			
			[loop]
			for (int i=-kSize; i <= kSize; ++i)
			{
				for (int j=-kSize; j <= kSize; ++j)
				{
					nc = tex2Dlod(Tex, float4(texcoord.xy + float2(i,j) * RPC_WS * rcp(kSize * 2.0f),0,0)).rgb;
					factor = normpdf3(nc.rgb-centerColor.rgb, SIGMA);
					Z += factor;
					final_color += factor * nc;
				}
			}
			
			final_color = saturate(final_color/Z);
			
			mn = min( min( LI(centerColor.rgb), LI(final_color.rgb)), LI(nc.rgb));
			mx = max( max( LI(centerColor.rgb), LI(final_color.rgb)), LI(nc.rgb));
			
			// Smooth minimum distance to signal limit divided by smooth max.
			float rcpM = rcp(mx), CAS_Mask;// = saturate(min(mn, 1.0 - mx) * rcpM);
			
			// Shaping amount of sharpening masked
			CAS_Mask = saturate(min(mn, 2.0 - mx) * rcpM);
			
			float Mask_Two = 1-LI(centerColor.rgb);
			
			float3 Sharp_Out = centerColor.rgb + (centerColor.rgb - final_color.rgb) * Sharp_This;
	        #if !Virtual_Reality_Mode
	        	centerColor.rgb = lerp(centerColor.rgb,Sharp_Out,CAS_Mask * Mask_Two);
	        #else
	        	//Consideration for Super3D mode
				centerColor.rgb = Super3D_Mode ? lerp(centerColor.rgb,float3(Sharp_Out.rg,centerColor.b),CAS_Mask) : lerp(centerColor.rgb,Sharp_Out,CAS_Mask);
			#endif	        
	    }
	    return centerColor;
	}
	/* //Placed on Hold
	#if Filter_Final_Image
	float4 MixModeBlend(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{  

	    return CBBlend(BackBuffer_SD,texcoord);
	}
	#endif	
	*/
	float4 SmartSharpJr(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{  
		float4 Color = tex2D(BackBuffer_SD,texcoord);//dot(Color.rgb,0.333);//
		 Color.w = max(Color.r, max(Color.g, Color.b));
		 //Color.w = dot(Color.rgb,0.333);
	    return float4(Sharp(BackBuffer_SD, texcoord, 1.0).rgb,Color.w);
	}
	#if AXAA_EXIST
	float4 AXAA_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{  
		return USE_AXAA ? AXAA(BackBuffer_SD,texcoord) : tex2D(BackBuffer_SD,texcoord);
	}
	#endif
	
	#if REST_UI_Mode //Thankyou Tjandra for this option for people. 
	float4 REST_Conversion_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		float2 TC = texcoord;
		float2 hw_offset = pix.xy / 2.0;
		
		//if(Eye_Swap)
		//	hw_offset= -hw_offset;
		
		if(Stereoscopic_Mode == 0)
			TC.x = texcoord.x < 0.5 ? texcoord.x * 2.0 + hw_offset.x : texcoord.x * 2.0 - 1.0 - hw_offset.x;
		
		if(Stereoscopic_Mode == 1)
			TC.y = texcoord.y < 0.5 ? texcoord.y * 2.0 + hw_offset.y : texcoord.y * 2.0 - 1.0 - hw_offset.y;
		//tex2D(BackBuffer_B,TC)
		//             MouseCursor(TC  , position.xy , Mouse_Toggle_Click, 0).rgb;

			bool CLK_L = Toggle_REST;
			if(Cursor_REST_Button_Selection == 1)
				CLK_L = CLK_02;
			if(Cursor_REST_Button_Selection == 2)
				CLK_L = CLK_03;					
			if(Cursor_REST_Button_Selection == 3)
				CLK_L = CLK_04;
				
			float Mouse_Toggle_Click = CLK_L;
			
		float4 Color = MouseCursor( float3(TC,0) , position.xy , Mouse_Toggle_Click, 1);
			   Color.w = max(Color.r, max(Color.g, Color.b));
		return Color;
	}
	#endif
	
	#if D_Frame
	float4 CurrentFrame(in float4 position : SV_Position, in float2 texcoords : TEXCOORD) : SV_Target
	{
		return tex2Dlod(BackBuffer_SD,float4(texcoords,0,0));
	}
	
	float4 DelayFrame(in float4 position : SV_Position, in float2 texcoords : TEXCOORD) : SV_Target
	{
		return tex2Dlod(SamplerCF,float4(texcoords,0,0));
	}
	#endif
	
	///////////////////////////////////////////////////////////////////ReShade.fxh//////////////////////////////////////////////////////////////////////
	void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{// Vertex shader generating a triangle covering the entire screen
		texcoord.x = (id == 2) ? 2.0 : 0.0;
		texcoord.y = (id == 1) ? 2.0 : 0.0;
		position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
	}

	technique Information_SD
	< ui_label = "Information";
	//toggle = Text_Info_Key;
	 hidden = true;
	 enabled = true;
	 #if Compatibility_00
	 timeout = 2;
	 #else 
	 timeout = 1250;
	 #endif
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
		#if D_Frame
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
			pass Average_Information
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Info;
			RenderTarget0 = texAvrN;
		}	
			pass Blur_DepthBuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = zBuffer_Blur;
			RenderTarget0 = texzBufferBlurN;
			RenderTarget1 = texzBufferBlurEx;
		}
			pass DepthBuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget0 = texDMN;
			RenderTarget1 = texCN;
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

		#if Reconstruction_Mode || Virtual_Reality_Mode || Anaglyph_Mode
			pass Muti_Mode_Reconstruction
		{
			VertexShader = PostProcessVS;
			#if Anaglyph_Mode
			PixelShader = Anaglyph;
			RenderTarget0 = texSD_RL;
			#else
			PixelShader = CB_Reconstruction;
			RenderTarget0 = texSD_CB_L;
			RenderTarget1 = texSD_CB_R;
			#endif
		}
		#endif
		
			pass StereoOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
		/* //Placed on Hold
		#if Filter_Final_Image
			pass BlendOut
		{
			VertexShader = PostProcessVS;
			PixelShader = MixModeBlend;
		}
		#endif
		*/
		#if !REST_UI_Mode
				pass USMOut
			{
				VertexShader = PostProcessVS;
				PixelShader = SmartSharpJr;
			}	
			#if AXAA_EXIST
				pass AXAA
			{
				VertexShader = PostProcessVS;
				PixelShader = AXAA_PS;
			}
			#endif
		#endif
	}
	#if REST_UI_Mode
	technique REST_3D_UI	
	< ui_label = "REST 3D UI Separation";
	 hidden = true;
	 enabled = true;
	 ui_tooltip = "Make sure this is unchecked in REST."; >
	{
		pass Reconstruct
		{
			VertexShader= PostProcessVS;
			PixelShader= REST_Conversion_PS;
		}
			pass USMOut
		{
			VertexShader = PostProcessVS;
			PixelShader = SmartSharpJr;
		}	
		#if AXAA_EXIST
			pass AXAA
		{
			VertexShader = PostProcessVS;
			PixelShader = AXAA_PS;
		}
		#endif
	}
	#endif	
	
}