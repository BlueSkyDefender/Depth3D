	////----------------//
	///**SuperDepth3D**///
	//----------------////
	#define SD3D "SuperDepth3D v5.5.0\n"
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
	#define VEN 0
	#if exists "AXAA.fxh"
		#include "AXAA.fxh"
		#define AXAA_EXIST 1
	#else
		#warning "Missing AXAA.fxh Header File"
		#define AXAA_EXIST 0
	#endif

	#define D_ViewMode 1 //VM1 Alpha. Profiles that set DS_Z keep theirs.
	#if exists "Overwatch.fxh"                                           //Overwatch Interceptor//
		#include "Overwatch.fxh"
		#define OSW 0
	#else// DA_X = [ZPD] DA_Y = [Depth Adjust] DA_Z = [Offset X] DA_W = [Depth Linearization]
		static const float DA_X = 0.025, DA_Y = 7.5, DA_Z = 0.0, DA_W = 0.0;
		// DB_X = [Depth Flip] DB_Y = [De-Artifact Scale] DB_Z = [Auto Depth] DB_W = [Weapon Hand]
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
		// DH_X = [LBC Size Offset X] DH_Y = [LBC Size Offset Y] DH_Z = [LBC Pos Offset X] DH_W = [LBC Pos Offset Y]
		static const float DH_X = 1.0, DH_Y = 1.0, DH_Z = 0.0, DH_W = 0.0;
		// DI_X = [LBM Offset XY] DI_Y = [Boost Mode Pop Level Adjuster] DI_Z = [Weapon Near Depth Trim] DI_W = [OIF Check Depth Limit]
		static const float DI_X = 0.0, DI_Y = 0.0, DI_Z = 0.25, DI_W = 0.5;
		// DJ_X = [Range Smoothing] DJ_Y = [Menu Detection Type] DJ_Z = [Match Threshold] DJ_W = [Check Depth Limit Weapon]
		static const float DJ_X = 0, DJ_Y = 0.0, DJ_Z = 0.0, DJ_W = -0.100;
		// DK_X = [FPS Focus Method] DK_Y = [Eye Eye Selection] DK_Z = [Eye Fade Selection] DK_W = [Eye Fade Speed Selection]	
		static const float DK_X = 0, DK_Y = 0.0, DK_Z = 0, DK_W = 1;
		// DL_X = [Not Used Here] DL_Y = [De-Artifact] DL_Z = [Compatibility Power] DL_W = [Not Used Here]
		static const float DL_X = 0.5, DL_Y = 0.125, DL_Z = 0, DL_W = 0.05;		
		// DM_X = [HQ Tune] DM_Y = [HQ Depth] DM_Z = [HQ Smooth] DM_W = [HQ Trim]
		static const float DM_X = 3, DM_Y = 1, DM_Z = 1, DM_W = 0.0; //3: the old 4 gave mip 3 before the half levels worked.
		// DN_X = [Position A & B] DN_Y = [Position C & D] DN_Z = [Position E & F] DN_W = [Menu Size Main]	
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
		// DV_X = [Position K & K] DV_Y = [Position K & L] DV_Z = [Position L & L] DV_W = [KL Menu Tresh]	
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
		// DMM_X = [Lock Position A & B] DMM_Y = [Lock Position C] DMM_Z = [Lock ABCW Menu Tresholds] DMM_W = [Alpha Stencil UI]
		static const float DMM_X = 0.0, DMM_Y = 0.0, DMM_Z = 1000.0, DMM_W = 0.0;
		// DNN_X = [Horizontal Scale] DNN_Y = [Vertical Scale] DNN_Z = [Flip Scale] DNN_W = [Game Depth Near Plane Values]
		static const float DNN_X = 1.0, DNN_Y = 1.0, DNN_Z = 0.0, DNN_W = 1.0;
		// WSM = [Weapon Setting Mode]
		#define OW_WP "WP Off\0Custom WP\0"
		#define G_Info "Missing Overwatch.fxh Information.\n"
		#define G_Note "Note: If you pulled this file intentionally, please ignore this message.\n"
		static const int EVS = 0, SMSUM = 0, RSV = 0, AJM = 0, MED = 0, SBTDA = 0, SMSBT = 0, UIF = 0, UIL = 0, RCI = 0, AIM = 0, WMM = 0, SDD = 0, DMM = 0, LBD = 0, WSM = 0, ULF = 0;
		static const int2 DOL = 0;
		//Triggers 
		static const float UFC = 0, UIB = 0, HNR = 0, THF = 0, EGB = 0,PLS = 0, MGA = 0, WZD = 0, KHM = 0, DAO = 0, LDT = 0, ALM = 0, SSF = 0, SNF = 0, SSE = 0, SNE = 0, EDU = 0, LBI = 0,ISD = 0, ASA = 1, IWS = 0, SUI = 0, SSA = 0, SNA = 0, SSB = 0, SNB = 0,SSC = 0, SNC = 0,SSD = 0, SND = 0, LHA = 0, WBS = 0, TMD = 0, FRM = 0, AWZ = 0, CWH = 0, WBA = 0, WFB = 0, WND = 0, WNR = 0, ABWS = 0, AFS = 0.4375, WRP = 0, MML = 0, SMD = 0, WHM = 0, SDU = 0, ABE = 2, LBE = 0, HQT = 0, HMD = 0.5, MAC = 0, OIL = 0, MMS = 0, FTM = 0, FMM = 0, SPO = 0, MMD = 0, LBR = 0, AFD = 0, MDD = 0, FPS = 1, SMS = 1, OIF = 0, NCW = 0, RHW = 0, NPW = 0, SPF = 0, BDF = 0, HMT = 0, HMC = 0, DFW = 0, NFM = 0, DSW = 0, LBC = 0, LBS = 0, LBM = 0, DAA = 0, NDW = 0, PEW = 0, WPW = 0, FOV = 0, EDW = 0, SDT = 0;
		//Overwatch.fxh State
		#define OSW 1
	#endif
	
	#if !defined(GDM_WEAPON_DEPTH) //defined(), not #ifndef: ReShade lists #ifndef names in the preprocessor list, and GDM sets this one.
	#define GDM_WEAPON_DEPTH 0 //One uses the dedicated WDEPTH weapon hand buffer and auto cutout. Zero is the legacy shared DepthBuffer path.
	#endif
	
	//USER EDITABLE PREPROCESSOR FUNCTIONS START//

	// Experimental DLP mode for Side By Side and the lesser supported Top n Bottom
	#ifndef EX_DLP_FS_Mode
		#define EX_DLP_FS_Mode 0  //Default 0 is Off. One is On
	#endif
	//Run this mode at your DLP's native 720p or 1080p, 120 Hz Auto Mode.
	//Frame Sequential is for testing only, unusable unless the game holds a steady 120 fps.
	//It has many open issues. For now it is something to try out for fun.
	//It also has Debug options for advanced users.
	
	// Double Buffer Mode exposes a BUFFER_WIDTH*2 SBS texture (DoubleTex) that
	// capture/export addons (VRExport, VRScreenCap, KatangaVR, etc.) can read via
	// the ReShade addon API.
	#ifndef DoubleBuffer_Mode
		#define DoubleBuffer_Mode 0  //Default 0 is Off. One is On
	#endif

	// Focus Depth Mode: Inficolor's depth handling on the other 3D outputs. The convergence follows Depth Adjustment and
	// a Focus plane (it takes over Perspective), Depth Adjustment is halved, and Max Depth, Focus, 3D Near Reduction and
	// Auto Focus are added. The depth is balanced around the focus plane instead of the screen, so both ends double less.
	#ifndef Focus_Depth_Mode
		#define Focus_Depth_Mode 0  //Default 0 is Off. One is On
	#endif

	// Shifts the ZPD Boundary Detection detectors up.
	#define Shift_Detectors_Up SDU //Default 0 is Off. One is On
	//To override SDU, set this to 0 or 1.
	
	#ifndef Cancel_Depth_Key
	// Sets the Cancel Depth toggle key by keycode.
	// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
		#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	#endif
	
	// Barrel Distortion Correction for a non-conforming BackBuffer.
	#define BD_Correction 0 //Default 0 is Off. One is On.
	
	// Horizontal & Vertical Depth Buffer Resize for a non-conforming DepthBuffer.
	// Also enables Image Position Adjust, which moves the Z-Buffer around.
	#define DB_Size_Position 0 //Default 0 is Off. One is On.
	
	// Exact Depth Buffer Fit, fed by the Generic Depth Mod add-on: the real rendered viewport inside the
	// depth texture. Unreal pads it and renders top left (Moss: 1440 in 1536), leaving dead rows at the bottom.
	// While on, the content based Letter Box Detection stands down. Without the add-on the uniforms read 0,
	// so nothing changes. Defaults to 1 so "Reset all to default" cannot compile it out; the runtime
	// "depth_autofit" uniform switches it on and off.
	#if !defined(GDM_DEPTH_AUTOFIT) //defined(), not #ifndef: ReShade lists #ifndef names in the preprocessor list, and GDM sets this one.
		#define GDM_DEPTH_AUTOFIT 1
	#endif
	
	//Internal: infill debug views.
	#define INFILL_DEBUG 0 //[Zero is Off] [One is On]

	//Internal, experimental: nearest depth chain (16 texel runs) so the parallax march can jump empty
	//stretches. Same image in DX10+. Off in DX9: there it skipped past occluders and tore objects' outer
	//edges (VM1, 2026-10-02; Global_Depth3D has no chain and was clean).
	#define POM_MINH (1 && !DX9_Toggle) //[Zero is Off] [One is On]

	//Internal: depth change in px that runs the hole taps. 0.5 is the original. Higher skips slopes and floors;
	//pixels under it get no hole mask, so the infill blur can only shrink there, never spread onto objects.
	#define HOLE_TRIGGER_PX 1.0
	//Internal: background side reach taps in the hole check. 5 is the original. Each tap can only add mask, so fewer
	//taps only shrink it (thin objects in the reach may be missed) and never reach into the protected object side.
	#define HOLE_REACH_TAPS 5

	//Internal, DX10+: Line, Column, Checkerboard, Reconstruction and VR march each eye together in a buffer, then
	//put the pixels back.
	//Same image, the GPU just runs it faster.
	#define IL_EYE_BUFFER 1 //[Zero is Off] [One is On]
	
	//Internal: Depth AA readout in G of texSmooth, DX10+ only.
	#define DEPTH_AA_PREVIEW 0 //[Zero is Off] [One is Edge Mask] [Two is Straight Edge]
	#if DEPTH_AA_PREVIEW
		#define AA_Format RG16F
		#define AA_Type float2
	#else
		#define AA_Format R16F
		#define AA_Type float
	#endif
	
	// Auto Letter Box Correction
	#define LB_Correction 0 //[Zero is Off] [One is Auto Hoz] [Two is Auto Vert]
	// Auto Letter Box Masking
	#define LetterBox_Masking 0 //[Zero is Off] [One is Auto Hoz] [Two is Auto Vert]
	
	// Specialized Depth Triggers
	#define SD_Trigger 0 //Default is Off. One is Mode A, other modes not added yet.
	
	// HUD Mode adds an extra UI MASK and basic HUD adjustments for UI elements drawn in the Depth Buffer,
	// like Naruto Shippuden: Ultimate Ninja, TitanFall 2 and Unreal Gold 277. Advanced users can make their own UI MASK.
	// Turn this on to use the UI Masking options below.
	#define HUD_MODE 0 // Set to 1 to adjust basic HUD items drawn in the depth buffer.
		
	// Mouse key codes are 0-4, 1 is the right mouse button.
	#define Mouse_Key_Four 4 //Forward Mouse Button
	#define Mouse_Key_Three 3 //Back Mouse Button
	#define Mouse_Key_Two 2 //Middle Mouse Button
 
	#define Fade_Key 1 // Default is mouse 1
	#define Fade_Time_Adjust 0.5625 // Fade Time for this mode, from 0 to 1. Default is 0.5625.
	
	// Delay Frame for when the depth buffer is 1 frame behind. Useful for games that need "Copy Depth Buffer
	// Before Clear Operation" checked in ReShade's API Depth Buffer tab.
	#ifndef Delay_Frame_Mode
		#if DFW
			#define Delay_Frame_Mode 1
		#else
			#define Delay_Frame_Mode 0
		#endif
	#endif
	//Change Delay_Frame_Mode to 1 to enable this option.
	#define D_Frame Delay_Frame_Mode //Keep 0 most of the time, 1 adds one frame of latency.
	
	//Text Information Key, default is the Menu Key
	#define Text_Info_Key 93
	
	//Fast Trigger Mode
	#define Fast_Trigger_Mode FTM //Set to 0 or 1 to override, otherwise Overwatch decides.

	//Lower Height Adjustment
	#define Lower_Height_Adjust LHA //Set to 0 or 1 to override, otherwise Overwatch decides.

	#define Profiler_Mode 0 //For making your own profiles to submit to BlueSkyDefender, aka Depth3D Main Dev.
	
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

	#if __RESHADE__ <= 60303
		#define Compatibility_02 1
	#else
		#define Compatibility_02 0
	#endif	
	
	//Flip Depth for OpenGL on ReShade 5.0+, since older profiles need this.
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

	#if __RENDERER__ >= 0x10000 && __RENDERER__ <= 0x20000 //Is OpenGL
		#define ISOGL 1
	#else
		#define ISOGL 0
	#endif

	//OpenGL compile time: the GL driver compiles every pass from text at each launch, and [unroll] there becomes a
	//forced unroll hint, so every loop body is copied out before compiling. In OpenGL the hint is dropped and the
	//driver decides. Same maths, same image. Other APIs keep them.
	#if ISOGL
		#define SD_UNROLL
	#else
		#define SD_UNROLL [unroll]
	#endif
	
	//DX9 workaround for auto Convergence.
	#if __RENDERER__ == 0x9000
		#define DX9_Toggle 1
	#else
		#define DX9_Toggle 0
	#endif
	//DX9 has no room for the infill debug sliders: ps_3_0 has only 224 constant registers, all used,
	//so they fail with error X4509. DX9 falls back to the fixed defaults, DX10+ keeps them.
	#if DX9_Toggle && INFILL_DEBUG
		#undef INFILL_DEBUG
		#define INFILL_DEBUG 0
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
	//New ReShade Preprocessor stuff	
	#ifndef Use_2D_Plus_Depth
	    #define Use_2D_Plus_Depth 0
	#endif

	#ifndef M_Edge
	    #define M_Edge MED
	#endif
	
	#if Use_2D_Plus_Depth
		#undef Virtual_Reality_Mode
		#define Virtual_Reality_Mode 0 
		#undef Inficolor_3D_Emulator
		#define Inficolor_3D_Emulator 0
		#undef Reconstruction_Mode
		#define Reconstruction_Mode 0
		#undef REST_UI_Mode
		#define REST_UI_Mode 0
		#undef Super3D_Mode
		#define Super3D_Mode 0
		#undef Anaglyph_Mode
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
		    	#if !Anaglyph_Mode && !EX_DLP_FS_Mode
			        #ifndef Reconstruction_Mode
			            #define Reconstruction_Mode 0
			        #endif
			    #else
			        #undef Reconstruction_Mode
			        #define Reconstruction_Mode 0
			    #endif
		    #else
		        #undef Reconstruction_Mode
		        #define Reconstruction_Mode 0
		    #endif
		
		#else
			#undef Anaglyph_Mode
			#define Anaglyph_Mode 0
		    #undef Reconstruction_Mode
		    #define Reconstruction_Mode 0
		    #undef Inficolor_3D_Emulator
		    #define Inficolor_3D_Emulator 0
		#endif 
	
		// This is for REST Add-On
		#if Inficolor_3D_Emulator || Reconstruction_Mode || Virtual_Reality_Mode || Anaglyph_Mode
		    #undef REST_UI_Mode
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
	// DoubleBuffer_Mode: if another output mode is on (2D+Depth, Anaglyph, Inficolor, Reconstruction,
	// Super3D), force DoubleBuffer_Mode off and let that mode win, so presets can keep it set.
	  #if DoubleBuffer_Mode
	        #if Use_2D_Plus_Depth || Anaglyph_Mode || Inficolor_3D_Emulator || Reconstruction_Mode || Super3D_Mode
	                #undef  DoubleBuffer_Mode
	                #define DoubleBuffer_Mode 0
	        #endif
	  #endif
	
	// EX_DLP_FS_Mode (Frame Sequential) is incompatible with Reconstruction_Mode: PS_calcLR's FA branch
// reads L/R, which the Reconstruction branch leaves uninitialized. Force Reconstruction off.
// Backstop: the mode setup above already forces it off.
  #if EX_DLP_FS_Mode && Reconstruction_Mode
        #undef  Reconstruction_Mode
        #define Reconstruction_Mode 0
  #endif

	//Fast Eye Buffer, DX10+, anaglyph only. AG_BUDGET is the buffer width in screens: 1.0 costs about what Side by Side
	//costs. Inficolor gained nothing at 90% per eye, and its light glasses would show anything narrower.
	//Inficolor: the same buffer with an even split and a resolution slider, 0 (Side by Side depth) to 1 (native, off).
	//AG_BUDGET 2.0 so both eyes fit at up to full width.
	#if Inficolor_3D_Emulator && !DX9_Toggle
		#define AG_EYES 1
		#define AG_INFICOLOR 1
		#define AG_BUDGET 2.0
	#elif Anaglyph_Mode && !DX9_Toggle
		#define AG_EYES 1
		#define AG_INFICOLOR 0
		#define AG_BUDGET 1.0
	#else
		#define AG_EYES 0
		#define AG_INFICOLOR 0
	#endif

	//Memory Infill internals. Memory_Infill itself is with the user options below.
	#if !DX9_Toggle && !Use_2D_Plus_Depth && defined(ADDON_DEPTH3D_MOTION)
		#define MEM_INFILL Memory_Infill
		#define MEM_DIV 2 //Memory resolution. 2 is half.
		#define MEM_MAX_AGE 8.0 //Seconds a covered background is trusted.
	#else
		#define MEM_INFILL 0
	#endif
	//Memory Infill: Show Infill Mask draws the blur's mask (red object side, green the gap's falloff), since the blur
	//itself is off there.
	#define MEM_SHOW (MEM_INFILL && Show_Infill_Mask)
	//VM0 is the old Normal in anaglyph and Inficolor: Structure is not fixed for those outputs yet.
	#define VM0_NORMAL (Anaglyph_Mode || Inficolor_3D_Emulator)
	//Inficolor's depth handling: Inficolor itself, or Focus_Depth_Mode on the other outputs. Not 2D+Depth (no stereo
	//pair) or VR (its perspective is the IPD).
	#define IC_DEPTH (Inficolor_3D_Emulator || (Focus_Depth_Mode && !Use_2D_Plus_Depth && !Virtual_Reality_Mode))
	//The VM0 structure field exists only where Structure can run: not DX9 (no field), not anaglyph or Inficolor (VM0 is
	//Normal there), not 2D+Depth (no View Mode, fixed to Alpha), not Memory Infill (VM0 is Adaptive there).
	#define VM0_FIELD (!DX9_Toggle && !VM0_NORMAL && !Use_2D_Plus_Depth && !MEM_INFILL)

	//Infill blur and the mask overlay in the post pass. Anaglyph, Inficolor, Reconstruction, VR and DoubleBuffer carry no
	//mask in alpha: the blur runs in pass there, and the overlay is painted in pass (DoubleBuffer has its own).
	#define POST_MASK_OK (!Anaglyph_Mode && !Inficolor_3D_Emulator && !Reconstruction_Mode && !Virtual_Reality_Mode)
	#if !Anaglyph_Mode && !Inficolor_3D_Emulator && !Virtual_Reality_Mode && !Reconstruction_Mode && !DoubleBuffer_Mode
		#define POST_INFILL_OK (View_Mode != 3)
	#else
		#define POST_INFILL_OK false
	#endif

#ifndef Enable_Deband_Mode
	    #define Enable_Deband_Mode 0
	#endif
	
	#ifndef HDR_Compatible_Mode
	    #define HDR_Compatible_Mode 0
	#endif

	//#ifndef Filter_Final_Image
	    #define Filter_Image 0
	//#endif
	
	#ifndef Anti_Jitter_Mode //TAA_Mode
	    #define Anti_Jitter_Mode AJM
	#endif

	#if DX9_Toggle	
		#ifndef Set_Custom_Sidebars
		    #define Set_Custom_Sidebars 1
		#endif
	#else
		#define Set_Custom_Sidebars 1
	#endif

	#ifndef Frame_Packed_Mode
	    #define Frame_Packed_Mode 0
	#endif	

	//Memory Infill, DX10+. Listed only while the Depth3D Motion add-on is loaded.
	#if !DX9_Toggle && !Use_2D_Plus_Depth && defined(ADDON_DEPTH3D_MOTION)
		#ifndef Memory_Infill
		    #define Memory_Infill 0
		#endif
	#endif

	//Handheld Stuff//	
	//2D+Depth: always on and hidden from the preprocessor list (no #ifndef, so ReShade does not offer it).
	#if Use_2D_Plus_Depth
		#undef Handheld_Mode
		#define Handheld_Mode 1
	#elif __VENDOR__ == 0x8086 //Intel
		#ifndef Handheld_Mode
			#define Handheld_Mode 1
		#endif		
	#else
		#ifndef Handheld_Mode
			#define Handheld_Mode 0
		#endif
	#endif

	#if Handheld_Mode
		#define Set_Depth_Res 2
	#else
		#define Set_Depth_Res 1
	#endif
	
	// Define aspect ratios as integers (multiply by 1000 for precision)
	#define ASPECT_16_9_INT  1778  // 1.778 * 1000
	#define ASPECT_16_10_INT 1600  // 1.6 * 1000
	#define AR_TOLERANCE_INT 10    // 0.01 * 1000
	
	// Calculate aspect ratio as integer
	#define ASPECT_SCREEN_RATIO_INT ((BUFFER_WIDTH * 1000) / BUFFER_HEIGHT)
	
	// Determine aspect ratio type
	#if ((ASPECT_SCREEN_RATIO_INT >= (ASPECT_16_9_INT - AR_TOLERANCE_INT)) && (ASPECT_SCREEN_RATIO_INT <= (ASPECT_16_9_INT + AR_TOLERANCE_INT)))
	    #define AR_Is 1  // 16:9
	#elif ((ASPECT_SCREEN_RATIO_INT >= (ASPECT_16_10_INT - AR_TOLERANCE_INT)) && (ASPECT_SCREEN_RATIO_INT <= (ASPECT_16_10_INT + AR_TOLERANCE_INT)))
	    #define AR_Is 2  // 16:10
	#else
	    #define AR_Is 0  // Widescreen or other
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
				"Check Aspect Ratio in Add-on: You should check it in the Depth/Add-ons tab above.\n"
				"\n"
				#endif
		
				#if EDW
				"Emulator Detected: Because emulated games are hard to detection you will need to share/make/use a profile for the game you are trying to make work.\n"
				"Extra options are enabled in this mode to allow better support for emulators.\n"
				"Good Luck.\n"
				"\n"
				#endif

				#if Profiler_Mode
				"Profiler Mode Enabled: This mode is to share/make/use a profile for the game you are trying to make work in this shader.\n"
				"Extra options are enabled in this mode to allow for better profiles to be made.\n"
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
				"Set Weapon: Means you need to manually set the Weapon Hand Profile below. To fix the Weapon Hand Issues in your game.\n"
				"\n"
				#endif
			
				#if NDW
				"Net Play: Means you are playing on a Online Game and you may need to use the Add-on Version of ReShade.\n"
				"\n"
				#endif
				
				#if FOV
				"Set FoV: If you set Field of View for a better experience.\n"
				"\n"
				#endif
				/*
				#if RHW
				"Read Help: Means you need to read the Help file for extra information to make the game more enjoyable. I hope to have a website for this some day.\n"
				"\n"
				#endif
				*/
				#if NPW
				"No Profile: The current game has no profile. This means you need to make one or ask for one to be made for you.\n"
				"\n"
				#endif
			
				#if NCW
				"Incompatible: The current game is incompatible. This may change with a game update or external modifications.\n"
				"\n"
				#endif
			
				#if NFM
				"Needs Mod: The Shader needs a external Mod and or Add-ons to work optimally or to work at all.\n"
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
				#if AR_Is == 1
				"                                  16:9\n"
				#elif AR_Is == 2
				"                                  16:10\n"
				#else
				"                               ?Widescreen?\n"
				#endif
				"\n"
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
		ui_tooltip = "This sets the profile for an application that has multiple games.";
		ui_category = "Game Selection";
	> = 0;	
	#endif
	//uniform float TEST < ui_type = "slider"; ui_min = 0; ui_max = 2.0; > = 0.00;
	//Divergence & Convergence//
	uniform float Depth_Adjustment < //Made shrimpler for users
		ui_type = "slider";
		ui_min = 0.0; ui_max = 100; ui_step = 0.5;
		ui_label =  "·Depth Adjustment·"; 
		ui_tooltip =  "Increases differences between the left and right images and allows you to experience depth.\n"
					  "The process of deriving binocular depth information is called stereopsis (or stereoscopic vision).\n"
					  "Default is 50% and Max is 100%.";
		ui_category = "Divergence & Separation";
	> = 50;

	static const float Separation_Adjust = DF_Y;//Now adjusted internally.
	
	#if MEM_INFILL
	static const float ZPD_OverShoot = 0.0;//Memory Infill: off, it moves the world behind the weapon hand.
	#else
	uniform float ZPD_OverShoot <
		ui_type = "slider";
		ui_min = 0.0; ui_max = 1.0;
		ui_label =  " Smart Convergence"; 
		ui_tooltip =  "ZPD OverShoot controls the focus distance for the screen Pop-out effect in the distance.\n"
					  "If you see this, do not adjust the base ZPD (Zero Parallax Distance) below.\n"
					  "Default for ZPD is 0.0 Off.";
		ui_category = "Divergence & Separation";
	> = DHH_W;
	#endif

	#if Virtual_Reality_Mode
		#if !Super3D_Mode
			uniform int IPD <
				ui_type = "drag";
				ui_min = 0; ui_max = 100;
				ui_label = " IPD";
				ui_tooltip = "Interpupillary Distance determines the distance between your eyes.\n"
							 "Not needed if you use VR software that calculates this.\n"
							 "Default is 0.";
				ui_category = "Divergence & Separation";
			> = 0;
		#else
			static const int Perspective = 0;
		#endif
	#else
	#if !Use_2D_Plus_Depth
		#if !IC_DEPTH
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
					  "Do not change this if the game has a modern profile.\n"
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
	
	//Workaround because of DX9
	#if OIL == 0
	    static const float4 OIL_Values_Vec = float4((float)OIF, 0, 0, 0);
	    static const float4 CutOff_Values_Vec = float4((float)DI_W, 0, 0, 0);
	#elif OIL == 1
	    static const float4 OIL_Values_Vec = float4(OIF, 0, 0);
	    static const float4 CutOff_Values_Vec = float4(DI_W, 0, 0);
	#elif OIL == 2
	    static const float4 OIL_Values_Vec = float4(OIF, 0);
	    static const float4 CutOff_Values_Vec = float4(DI_W, 0);
	#elif OIL == 3
	    static const float4 OIL_Values_Vec = OIF;
	    static const float4 CutOff_Values_Vec = DI_W;
	#else
	    static const float4 OIL_Values_Vec = OIF;
	    static const float4 CutOff_Values_Vec = DI_W;	    
	#endif
	
	uniform float2 ZPD_Boundary_n_Cutoff_A <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " ZPD Scaler² & Intrusion";
		ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Two.\n"
					 "Lets you adjust how far behind the screen it should detect an intrusion.\n"
					 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
		ui_category = "Zero Parallax Distance";
	> = float2(OIL_Values_Vec.x,CutOff_Values_Vec.x);	

	#if EDW || Profiler_Mode
	
		uniform float2 ZPD_Boundary_n_Cutoff_B <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 2.5;
			ui_label = " ZPD Scaler³ & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Three.\n"
						 "Lets you adjust how far behind the screen it should detect an intrusion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = float2(OIL_Values_Vec.y,CutOff_Values_Vec.y);	

		uniform float2 ZPD_Boundary_n_Cutoff_C <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 3.75;
			ui_label = " ZPD Scaler4 & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Four.\n"
						 "Lets you adjust how far behind the screen it should detect an intrusion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = float2(OIL_Values_Vec.z,CutOff_Values_Vec.z);	

		uniform float2 ZPD_Boundary_n_Cutoff_D <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 5.0;
			ui_label = " ZPD Scaler5 & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Five.\n"
						 "Lets you adjust how far behind the screen it should detect an intrusion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = float2(OIL_Values_Vec.w,CutOff_Values_Vec.w);

		uniform float2 ZPD_Boundary_n_Cutoff_End <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 5.0;
			ui_label = " ZPD Scaler6 & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Six.\n"
						 "Lets you adjust how far behind the screen it should detect an intrusion.\n"
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
		#if MEM_INFILL
		//Memory Infill keeps the View Modes it works with. VM0 here is Adaptive (VM5).
		#if DS_Z == 5
			#define DS_Z_MEM 0
		#elif DS_Z == 2
			#define DS_Z_MEM 2
		#else
			#define DS_Z_MEM 1
		#endif
		uniform int View_Mode_Mem <
			ui_type = "combo";
			ui_items = "VM0 Adaptive \0VM1 Alpha \0VM2 Reiteration \0";
			ui_label = "·View Mode·";
			ui_tooltip = "Changes the way the shader fills in the occluded sections in the image.\n"
						"Adaptive    | A scene adapting infilling that uses disruptive reiterative sampling.\n"
						"Alpha       | Stretched infilling with a bit more separation.\n"
						"Reiteration | Same thing as Stamped but with breakage points.\n"
						"\n"
						"Memory Infill is on, so only the View Modes it works with are listed.\n"
						"\n"
						"Default is Alpha.";
		ui_category = "Occlusion Masking";
		> = DS_Z_MEM;
		#define View_Mode (View_Mode_Mem == 0 ? 5 : View_Mode_Mem)
		#else
		uniform int View_Mode <
			ui_type = "combo";
			#if VM0_NORMAL
			ui_items = "VM0 Normal \0VM1 Alpha \0VM2 Reiteration \0VM3 Stamped \0VM4 Mixed \0VM5 Adaptive \0VM6 Frosted \0";
			#else
			ui_items = "VM0 Structure \0VM1 Alpha \0VM2 Reiteration \0VM3 Stamped \0VM4 Mixed \0VM5 Adaptive \0VM6 Frosted \0";
			#endif
			ui_label = "·View Mode·";
			ui_tooltip = "Changes the way the shader fills in the occluded sections in the image.\n"
						#if VM0_NORMAL
						"Normal      | Normal output used for most games with a stretched look. (Structure is not in anaglyph or Inficolor yet.)\n"
						#else
						"Structure   | Alpha's separation, and lines crossing a gap continue through it instead of stretching flat.\n"
						#endif
						"Alpha       | Stretched infilling with a bit more separation.\n"
						"Reiteration | Same thing as Stamped but with breakage points.\n"
						"Stamped     | Stamps out a transparent area where occlusion happens.\n"
						"Mixed       | Used when there are high amounts of semi-transparent objects like foliage in the image.\n"
						"Adaptive    | A scene adapting infilling that uses disruptive reiterative sampling.\n"
						"Frosted     | Stamped with filtered depth and a fine frosted grain: smooth edges, softer look.\n"
						"\n"
						"Warning: Also make sure Performance Mode is active before closing the ReShade menu.\n"
						"\n"
						"Default is Alpha.";
		ui_category = "Occlusion Masking";
		> = DS_Z;
		#endif
	#else
	static const int View_Mode = 1;	
	#endif
	#if !Use_2D_Plus_Depth && !MEM_INFILL //Not with Memory Infill, not worth its cost.
	uniform int Infill_Blur <
		ui_type = "combo";
		ui_items = "Off\0Blur\0Luma Guided\0Contrast Guided\0Mixed\0";
		ui_label = " Infill Blur";
		ui_tooltip = "Softens the stretched areas that 3D leaves beside objects.\nOff: no blur.\nBlur: plain blur, strongest next to the object.\nLuma Guided: blurs bright areas more, leaves dark areas mostly alone.\nContrast Guided: blurs patterns and edges more, leaves flat areas mostly alone.\nMixed: blurs patterns and bright areas, leaves flat areas alone.\nStamped View Mode is skipped. Reiteration and Mixed dither instead of blurring.\nDefault is Off.";
		ui_category = "Occlusion Masking";
	> = 0;
	#else
	static const int Infill_Blur = 0;
	#endif
	#if MEM_INFILL
	uniform float Memory_Strength <
		ui_type = "slider";
		ui_min = 0.5; ui_max = 1.0;
		ui_label = " Memory Strength";
		ui_tooltip = "How strongly Memory Infill shows the remembered background, in the gap's falloff.\n"
					 "Default is 0.9.";
		ui_category = "Occlusion Masking";
	> = 0.9;

	#else
	static const float Memory_Strength = 0.0;
	#endif

	uniform int Warping_Masking <
		ui_type = "combo";
		ui_items = "M0 Full \0M1 Masked \0M2 Half \0";
		#if !Use_2D_Plus_Depth
			ui_label = " Halo Priority";
		#else
		ui_label = "·Halo Priority·";
		#endif
		ui_tooltip = "This option creates a mask that prioritizes foreground objects and ignores distant objects.\n"
					"Full      | No masking and applies Halo Reduction to the entire Image.\n"
					"Masked    | This will allow things in the distance to look sharper.\n"
					"Half      | Same thing as Masked above but stronger and is closer to Full.\n"
					 "Default is Masked and Zero is Off.";
		ui_category = "Occlusion Masking";
	> = DAA_W;	

	//Internal: Halo Near Reduction, set by the profile only (HNR).
	static const int Weapon_Near_Halo_Reduction = HNR;

	uniform int View_Mode_Warping <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0; ui_max = 9;
		ui_label = " Halo Reduction";
		ui_tooltip = "This distorts the depth in some View Modes to hide or minimize the halo in most games.\n"
					 "With this active it should hide the Halo a little better depending on the View Mode it works on.\n"
					 "Default is 3 and Zero is Off.";
		ui_category = "Occlusion Masking";
	> = DM_X;
	#if !DX9_Toggle
	uniform int Custom_Sidebars <
		ui_type = "combo";
		ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
		ui_label = " Edge Handling";
		ui_tooltip = "Edges selection for screen output.\n"
		  			 "What type of filling to use on the empty spaces at the edges.";
		ui_category = "Occlusion Masking";
	> = 1;
	#endif

	/* //Slated for removal 
		uniform float Range_Blend <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		ui_label = " Range Smoothing";
		ui_tooltip = "This blends Two Depth Buffers at a distance to fill in missing information that is needed to complete a image.\n"
					 "With this active, it should help with trees and other foliage that needs to be reconstructed by Temporal Methods.\n"
					 "Default is Zero, Off.";
		ui_category = "Occlusion Masking";
	> = DJ_X;
	*/ 		
	#if !Use_2D_Plus_Depth
	uniform int Performance_Level <
		ui_type = "combo";
		ui_items = "Performant \0Normal \0High \0";
		ui_label = " Performance Level";
		ui_tooltip = "Performance Levels lowers or raises Occlusion Quality Processing so that the performance is adjusted accordingly.\n"
					 "Variable Rate Shading focuses the quality of the samples in lighter areas of the screen.\n"
					 "Please enable the 'Performance Mode' Checkbox, in ReShade's GUI.\n"
					 "It's located in the bottom right of ReShade's main window.\n"
					 "Default is Performant.";
		ui_category = "Occlusion Masking";
	> = PLS;
	#endif
	#if Reconstruction_Mode
	uniform bool Align_Dither <
		ui_label = " Align Dither";
		ui_tooltip = "Reconstruction Mode: each eye marches every other pixel, so the dither pattern was split between the\n"
		             "eyes and the reconstruction mixed two halves of it. On, both pixels of each pair take the same dither,\n"
		             "so each eye gets the whole pattern on its own pixels.\n"
		             "Default is Off.";
		ui_category = "Occlusion Masking";
	> = false;
	#else
	static const bool Align_Dither = false;
	#endif

	/* Will add this back when Eyetracking is a thing
	uniform bool Foveated_Mode <
			ui_label = "Foveated Rendering";
			ui_tooltip = "Foveated rendering lowers the quality of the infilling around the center of the image.\n"
						 "In the future when we have a method for eye tracking this should work a lot better.";
			ui_category = "Occlusion Masking";
	> = FRM;
	*/

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
					 "With this active it should work better in games with TAA, XeSS, FSR, and/or DLSS sometimes.\n"
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
		ui_tooltip = "Use this when the image does not match the depth buffer, causing artifacts.\n"
					 "Use this on fur, hair, and other things that can cause artifacts at a high cost.\n"
					 "I find a value of 0.5 is good enough in most cases.\n"
					 "Default is Zero and it's Off.";
		ui_category = "Compatibility Options";
	> = float2(DL_Y,DB_Y);	

	//Fixed at 1.5x. Old slider: 0 = 1.25x, 1 = 1.5x, 2 = 1.75x. Before 2026-10: 0 = 1x, 1 = 1.75x, 2 = 2x.
	//RSV stays in Overwatch for older builds.
	static const int Reconstruction_Size = 1;

	
	#else
	//Fixed at 1.5x. Old slider: 0 = 1.25x, 1 = 1.5x, 2 = 1.75x. Before 2026-10: 0 = 1x, 1 = 1.75x, 2 = 2x.
	//RSV stays in Overwatch for older builds.
	static const int Reconstruction_Size = 1;


	
	#endif	
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
	
	uniform float AR_Side_Shrink <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Side Scaler";
		ui_tooltip = "Shrinks the depth map in from the left & right sides.\n"
					 "Some games, like AC Black Flag, pull the image in from the sides in 16:10\n"
					 "while the depth buffer stays full screen. One is a quarter of the screen width.\n"
					 "0.4 is the exact fit for games that squeeze the whole 16:9 image sideways\n"
					 "by the 16:10 aspect difference (x0.9), like AC Black Flag.\n"
					 "Default and starts at 0 and is Off.";
		ui_category = "Scaling Corrections";
	> = 0.0;

	uniform float2 DLSS_FSR_Offset <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = -5.0; ui_max = 5.0;
		ui_label = " Upscaler Offset";
		ui_tooltip = "This Offset is for non-conforming ZBuffer Position which is normally 1 pixel wide.\n"
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
		ui_tooltip = "This lets you set an existing known value, and it automatically scales if a change is detected.\n"
					 "Set it to the Depth Buffer's starting resolution or maybe your native res.\n"
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
		#if LBC || LB_Correction || EDW || DB_Size_Position || Profiler_Mode || SPF
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
		ui_tooltip = "This allows you to adjust the depth map's near plane.\n"
					 "If a profile is active, ignore this.\n"
					 "Default is 7.5";
		ui_category = "Depth Map";
	> = DA_Y;
	
	uniform float2 Offset <
		ui_type = "drag";
		ui_min = -1.0; ui_max = 1.0;
		ui_label = " Linear Offset";
		ui_tooltip = "Depth Map Offset is for non-conforming ZBuffer.\n"
					 "You will rarely need this in any game.\n"
					 "Default and starts at Zero and it's Off.";
		ui_category = "Depth Map";
	> = float2(DA_Z,DII_W);
	
	uniform float Auto_Depth_Adjust <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.500;
		ui_label = " Auto Near Plane";
		ui_tooltip = "Automatically adjusts the Near Plane to prevent excessive pop-out effects.\n"
					 "Default is 0.1, Zero is off.";
		ui_category = "Depth Map";
	> = DB_Z;

	uniform float PopOut_Target <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Popout Target";
		ui_tooltip = "Popout Target: use this to adjust for distortions when objects come too far out of the screen, like Weapon Hands.\n"
					 "The point of this is to set a target that the shader will try to reach only when Popout is detected.\n"
					 "Default is Zero & it's off.";
		ui_category = "Depth Map";	
	> = WND;	
	/*
		uniform float Push_Depth < //Experimental Option
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.500;
		ui_label = " Push Depth";
		ui_tooltip = "This option moves the ZPD cutoff point for infilling in by extension it limits the pop-out effect.\n"
					 "Default is 0.0, Zero is off.";
		ui_category = "Depth Map";
	> = 0.0;
	*/
	static const int Push_Depth = 0.0;
	uniform int Range_Boost <
		ui_type = "combo";
		ui_items = "Off\0Offset Based\0Near Plane Based X1\0Near Plane Based X2\0Near Plane Based X3\0Near Plane Based X4\0";
		ui_label = " Boost Range";
		ui_tooltip = "Boost Range details in Depth without affecting the near plane too much.";
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
			ui_label = " Alignment View";
			ui_tooltip = "A Guide to help align the Depth Buffer to the Image.";
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
		             "Default is float4(X 0.0, Y 0.0, Z 0.0, W 0.0)";
		ui_category = "Weapon Hand Adjust";
	> = float4(0.0,0.0,0.0,0.0);

	uniform float4 WZPD_and_WND <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 0.5;
		ui_label = " Weapon Near, Min, Auto, & Trim";
		ui_tooltip = "Weapon Near: This only affects a weapon when it's way closer than anything else.\n"
					 "Weapon Min : is used to adjust min weapon hand of the weapon hand when looking at the world near you when the above fails.\n"
					 "Weapon Auto: is used to auto adjust trimming when looking around.\n"
					 "Weapon Trim: is used to cut out a location in the depth buffer so that Min and Auto scale off of.\n"
					 "Default is (Near X 0.0, Min Y 0.0, Auto Z 0.0, Trim W 0.250 ) & Zero is off.";
		ui_category = "Weapon Hand Adjust";	
	> = float4(WNR,DG_Z,DE_W,DI_Z);
	
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
			#if DoubleBuffer_Mode && !Virtual_Reality_Mode
			//Double Buffer only fills Side by Side, so the layout is fixed and the option hidden.
			static const int Stereoscopic_Mode = 0;
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
							ui_items = "Side by Side\0Top and Bottom\0";
							ui_label = " 3D Display Modes";
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
			#endif
			#if AG_INFICOLOR
			uniform float IF_Scale <
				ui_type = "slider";
				ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
				ui_label = " Inficolor Resolution";
				ui_tooltip = "Both eyes' depth is marched at a lower width, then stretched back. The image stays full resolution.\n"
				             "1 is native and the default. 0 is Side by Side depth resolution (each eye at half width).\n"
				             "Lower is faster.";
				ui_category = "Stereoscopic Options";
			> = 1.0;
			#define Anaglyph_Fast (IF_Scale < 0.999)
			#endif
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
					ui_tooltip = "Interlace Optimization is used to reduce aliasing in Line or Column interlaced images. This has the side effect of softening the image.\n"
								 "Default for Interlace Optimization is 0.5.";
					ui_category = "Stereoscopic Options";
				> = 0.5;
				static const float Anaglyph_Saturation = 0.5;
			#endif			
			#if Ven && !Inficolor_3D_Emulator && !Anaglyph_Mode
			uniform int Scaling_Support <
				ui_type = "combo";
				ui_items = "SR Native\0SR 2160p A\0SR 2160p B\0SR 1080p A\0SR 1080p B\0SR 1050p A\0SR 1050p B\0SR 720p A\0SR 720p B\0";
				ui_label = " Downscaling Support";
				ui_tooltip = "Dynamic Super Resolution scaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.\n"
							 "Set this to your native Screen Resolution A or B, DSR Smoothing must be set to 0%.\n"
							 "This does not work with hardware scaling done by VSR.\n"
							 "Default is SR Native.";
				ui_category = "Stereoscopic Options";
			> = 0;
			#else
			static const int Scaling_Support = 0;
			#endif

			#if Inficolor_3D_Emulator
		
			uniform float3 Inficolor_Reduce_RGB <
				ui_type = "drag";
				ui_min = 0.0; ui_max = 1.0;
				ui_label = " Inficolor Reduce Red, Green & Blue";
				ui_tooltip = "This option lets you reduce or isolate any color in the upper range in the game.\n"
							 "Default is set to 0.5.";
				ui_category = "Stereoscopic Options";
			> = 0.5;	
			#endif
			#if IC_DEPTH //Max Depth and Focus: Inficolor, or Focus_Depth_Mode.
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
				#if Inficolor_3D_Emulator
				ui_label = " Inficolor Max Depth";
				#else
				ui_label = " Max Depth";
				#endif
				ui_tooltip = "Max Depth lets you clamp the max depth range of your scene.\n"
							 "So it's not hard on your eyes looking off into the distance.\n"
							 "Default and starts at One and it's Off.";
				ui_category = "Stereoscopic Options";
			> = 1.0;
			
			uniform float Focus_Inficolor <
				ui_type = "drag";
				ui_min = 0.0; ui_max = 1.5;
				#if Inficolor_3D_Emulator
				ui_label = " Inficolor Focus";
				#else
				ui_label = " Focus";
				#endif
				ui_tooltip = "Adjust this until the image has as little Color Fringing as possible at the near and far range.\n"
							 "Default is set to 0.5.";
				ui_category = "Stereoscopic Options";
			> = 0.5;
			
			#else
				static const float Focus_Inficolor = 0.5;
				static const float Inficolor_Max_Depth = 1.0;
				//static const float Inficolor_OverShoot = 0.0;
			#endif
			
			#if IC_DEPTH //Inficolor, or Focus_Depth_Mode.
			static const int Perspective = 0;
			
			uniform bool Inficolor_Near_Reduction <
				#if Inficolor_3D_Emulator
				ui_label = " Inficolor 3D Near Reduction";
				#else
				ui_label = " 3D Near Reduction";
				#endif
				ui_tooltip = "Inficolor 3D Near Depth Reduction Toggle.";
				ui_category = "Stereoscopic Options";
			> = true;
			
			uniform bool Inficolor_Auto_Focus <
				#if Inficolor_3D_Emulator
				ui_label = " Inficolor Auto Focus";
				#else
				ui_label = " Auto Focus";
				#endif
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
				ui_tooltip = "This DLP mode adds the Color Code to a Stereo Image so that the DLP Projector's Auto-Mode can enable.\n"
							 "This is for 3-D Ready Second-generation DLP Projectors that can detect the solid color of the last active line.\n"
							 "Please Note: Frame Sync is not supported yet. If you think you can help with this, message me.\n"
							 "Default is Off.";
				ui_category = "Stereoscopic Options";
			> = 0;
	
			uniform bool FS_FA <
				ui_label = " Frame Alternation";
				ui_tooltip = "Frame Alternation switch used to swap from FS to FA.\n"
							 "Default is Off.";
				ui_category = "Stereoscopic Options";
			> = false;			
			#endif
		#endif			
			#if AG_EYES && !AG_INFICOLOR
			uniform bool Anaglyph_Fast <
				ui_label = " Fast Eye Buffer";
				ui_tooltip = "Both eyes are rendered into one Side by Side sized buffer, then stretched back. Faster, a little softer.\n"
				             "The eye that carries more of the brightness gets more of the buffer.";
				ui_category = "Stereoscopic Options";
			> = true;
			#endif
			#if DoubleBuffer_Mode
			uniform float DB_Scale <
				ui_type = "slider";
				ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
				ui_label = " Double Buffer Resolution";
				ui_tooltip = "Both eyes are marched at a lower width, then stretched back into the full Double Buffer.\n"
				             "1 is full resolution and the default. 0 is Side by Side resolution (each eye at half width).\n"
				             "Lower is faster and a little softer.";
				ui_category = "Stereoscopic Options";
			> = 1.0;
			//Each eye's share of its full width: 0.5 (Side by Side) at 0, 1.0 at 1.
			#define DB_Width (0.5 + 0.5 * DB_Scale)
			#endif
			uniform bool Eye_Swap <
				ui_label = " Swap Eyes";
				ui_tooltip = "L/R to R/L."; // E/D ou D/E
		
				ui_category = "Stereoscopic Options";
			> = false;
	#endif
	
	#if (!Frame_Packed_Mode && !Virtual_Reality_Mode && !Inficolor_3D_Emulator && !EX_DLP_FS_Mode && !Use_2D_Plus_Depth) || Anaglyph_Mode || Inficolor_3D_Emulator
		static const bool Frame_Packed = false;
	#else
		uniform bool Frame_Packed <
			ui_label = " Frame Packed 3D";
			ui_tooltip = "Frame Packed 3D only works when Top n Bottom format is used.\n"
						 "You must set the frame packed format yourself since it can't be done here.";

			ui_category = "Stereoscopic Options";
			#if EX_DLP_FS_Mode
			hidden = true;
			#endif
		> = false;
	#endif

	//Debug tint, behind INFILL_DEBUG.
	#if INFILL_DEBUG
		uniform bool Infill_Blur_Debug <
			ui_label = " Show Infill Blur";
			ui_tooltip = "GREEN is the gap itself, RED is the feather out in the background, BLUE is the bleed leg. Brighter means stronger. Use it to spot the blur reaching onto surfaces it should not.";
			ui_category = "Stereoscopic Options";
		> = false;
	#else
		static const bool Infill_Blur_Debug = false;
	#endif
	//Anaglyph and Inficolor paint it after the eyes are mixed, not in the post pass.
	uniform bool Show_Infill_Mask <
		ui_label = " Show Infill Mask";
		ui_tooltip = "Overlays the disocclusion infill mask in green on the 3D image.\n"
					 "In anaglyph and Inficolor, red is the left eye's mask and blue the right eye's.\n"
					 "Default is Off.";
		ui_category = "Stereoscopic Options";
	> = false;

	//Near/far wall, behind INFILL_DEBUG.
	#if INFILL_DEBUG
		uniform bool Show_Near_Far <
			ui_label = " Show Near Far";
			ui_tooltip = "RED is Near, BLUE is Far, GREEN is how much the two are mixed. Shrink Mask_Depth_Band until only the boundary is green.";
			ui_category = "Stereoscopic Options";
		> = false;
	#else
		static const bool Show_Near_Far = false;
	#endif

	uniform int Focus_Reduction_Type <
		ui_type = "combo";
		ui_items = "World\0Weapon\0Mix\0";
		ui_label = "·Focus Type·";
		ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
					"This may induce eye strain, so take this as a warning.";
		ui_category_closed = true;
		ui_category = "FPS Focus";
	> = FPS;
	
	uniform int FPSDFIO <
		ui_type = "combo";
		ui_items = "Off\0Press\0Hold\0Stencil\0Press & Stencil\0Hold & Stencil\0";
		ui_label = " Activation Type";
		ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
					"This may induce eye strain, so take this as a warning.";
		ui_category = "FPS Focus";
	> = DK_X;
	
	uniform int Eye_Fade_Selection <
		ui_type = "combo";
		ui_items = "Both\0Right Only\0Left Only\0";
		ui_min = 0; ui_max = 2;
		ui_label = " Eye Selection";
		ui_tooltip ="Eye Selection: One is Right Eye only, Two is Left Eye Only, and Zero is Both Eyes.\n"
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
		ui_tooltip ="X, World Reduction: Decreases the amount of world depth by a current percentage.\n"
					"Y, Fade Speed: Decreases or Increases how fast it changes.\n"
					"Default is X[ 0 ] Y[ 1 ].";
		ui_category = "FPS Focus";
	> = int2(DK_Z,DK_W);
	
	uniform bool Toggle_On_Boundary <
		ui_label = " On Boundary Activation";
		ui_tooltip = "Turns on when the first boundary hit is detected from the weapon profile above.";
		ui_category = "FPS Focus";
	> = WZD;
	
	/*
	uniform bool FPS_Focus_Smoothing <
		ui_label = " Auto FPS Smoothing";
		ui_tooltip = "Increases Halo Reduction to the max value of Five.\n"
					 "This can allow a slight improvement in aiming.\n"
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
		ui_tooltip = "This controls the Size & Color.\n"
								 "Defaults are ( X 1, Y 0, Z 0).";
		ui_category = "Cursor Adjustments";
	> = int3(1,0,0);

	uniform int Cursor_Lock_Button_Selection <
		ui_type = "combo";
		ui_items = "Use Cursor Lock\0Mouse 2\0Mouse 3\0Mouse 4\0";
		ui_label = " Cursor Lock Button Selection";
		ui_tooltip = "Choose which mouse button to use.\n"
								 "Default is Use Cursor Lock.";
		ui_category = "Cursor Adjustments";
	> = 0;

	uniform int Cursor_Toggle_Button_Selection <
		ui_type = "combo";
		ui_items = "Use Cursor Toggle\0Mouse 2\0Mouse 3\0Mouse 4\0";
		ui_label = " Cursor Toggle Button Selection";
		ui_tooltip = "Choose which mouse button to use.\n"
								 "Default is Use Toggle.";
		ui_category = "Cursor Adjustments";
	> = 0;
	#if REST_UI_Mode	
	uniform int Cursor_REST_Button_Selection <
		ui_type = "combo";
		ui_items = "Use Rest Toggle\0Mouse 2\0Mouse 3\0Mouse 4\0";
		ui_label = " Cursor REST Button Selection";
		ui_tooltip = "Choose which mouse button to use.\n"
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
		ui_tooltip = "Switches the Screen Cursor from one layer to another layer.";
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
					 "The 2nd option is the same as the first, but zoomed in as a tradeoff.\n"
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
							 "The 2nd option is the same as the first, but zoomed in as a tradeoff.\n"
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
		ui_tooltip = "Adjust this to clear up the image of the game, movie, picture, etc.\n"
					 "This is Smart Sharp Jr code based on the Main Smart Sharp shader.\n"
					 "It can be pushed more and looks better than the basic USM.";
		ui_category = "Image Effects";
	> = 0;

	uniform float Saturation <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;
		ui_label = " Saturation";
		ui_tooltip = "Lets you saturate the image, basically adds more color.";
		ui_category = "Image Effects";
	> = 0;

	#if AXAA_EXIST	
	uniform int USE_AA <
		ui_type = "combo";
		ui_items = "Off\0Adaptive approXimate Anti-Aliasing\0";					
		ui_label = " Anti-Aliasing";
		ui_tooltip = "Note: Set the Anti-Aliasing type to use on the last output of the 3D image.\n"
					 "      Adaptive approXimate Anti-Aliasing is based on LG's modifications to FXAA.\n"
					 "      Directional approXimate Anti-Aliasing is based on AXAA but faster.\n"
					 "Default is Off.";
		ui_category = "Image Effects";
	> = false;
	#else
		static const bool USE_AA = false;
	#endif
	
	#if Enable_Deband_Mode
	uniform bool Toggle_Deband <
		ui_label = " Deband Toggle";
		ui_tooltip = "Turns on automatic Depth Aware Deband. This is used to reduce or remove the color banding in the image.";
		ui_category = "Miscellaneous Options";
	> = true;
	#endif
	
	#if !Use_2D_Plus_Depth
	uniform bool Vert_3D_Pinball <
		ui_label = "Swap 3D Axis";	
		ui_tooltip = "Use this to swap the axis the Parallax is generated on.\n"
					 "Useful for 3D Pinball games. You may have to swap eyes.\n"
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
	
	static const int Alpha_Channel_UI = 0;
	static const int Isolate_UI = 0;
	static const int Alpha_UI_is_Narrow = 0;
	static const int Alpha_UI_Has_LB = 0;
	static const bool UI_LB_Flatten = 0;
	uniform float Alpha_Finer_Mip_Center <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;	
		ui_label = " UI Finer Center";
		ui_tooltip = "This is to give a finer center mip level.";
		ui_category = "Miscellaneous Options";
	> = UFC;	
	#else
	static const float UI_Seeking_Strength = DT_Z;
	static const float4 Alpha_XYZW = DMM_W;
	
	uniform bool Alpha_Channel_UI <
		ui_label = " Alpha UI";	
		ui_tooltip = "Check this to use the Alpha Channel for UI in Depth.\n"
					 "Useful for games that store UI elements in the Alpha Channel so we can use them.\n"
					 "Default is Off.";
		ui_category = "Miscellaneous Options";
	> = Alpha_XYZW.x;
	
	uniform int Alpha_Auto_UI <
		ui_label = " UI Mode";
		ui_type = "combo";
		ui_items = "Self-Adjusting UI (Vicinal-Depth)\0" //0
		           "Self-Adjusting UI (Local-Depth)\0"   //1
		           "Self-Adjusting UI (Avr-Depth)\0"     //2 
		           "Self-Adjusting UI (Guided-Depth)\0"  //3
		           "Self-Adjusting UI (FPS-Alpha)\0"     //4
		           "Self-Adjusting UI (3rd-Alpha)\0"     //5
		           "Self-Adjusting UI (Mix-Alpha)\0"     //6
		           "Self-Adjusting UI (FPTP-Alpha)\0"    //7
		           "Self-Adjusting UI (Min-Alpha)\0"     //8
		           "Self-Adjusting UI (FPSP-Alpha)\0"    //9
		           "Self-Adjusting UI (FPMP-Alpha)\0"    //10
		           "Self-Adjusting UI (FPSP2-Alpha)\0"    //11		           
		           "Self-Adjusting UI (Min-FPSP-Alpha)\0"  //12
		           "Self-Adjusting UI (Min-FPSP-Alpha2)\0";  //13
		ui_tooltip = "Choose how to handle UI masking via the alpha channel:\n\n"
		             "- Mostly Static UI: Best for games with UI that doesn't move or change frequently.\n"
		             "- Self-Adjusting UI (Depth-Based): Dynamically adjusts based on depth, useful for games\n"
		             "  where UI elements shift or overlap with 3D content.";
		ui_category = "Miscellaneous Options";
	> = Alpha_XYZW.y;

	uniform float Bound_UI <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;	
		ui_label = " UI Bound";
		ui_tooltip = "Only use if your UI pops out too much.";
		ui_category = "Miscellaneous Options";
	> = UIB;
	
	uniform float Alpha_UI_Has_LB <
		ui_type = "slider";
		ui_min = -1.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " UI LetterBox";
		ui_tooltip = "This gives the options to account for Letter Box.\n"
					"Negative values blend and positive values are a hard cutoff.\n"
					"Default is 0.0, off.";
		ui_category = "Miscellaneous Options";
	> = Alpha_XYZW.w;

	uniform float Alpha_Finer_Mip_Center <
		ui_type = "slider";
		ui_min = 0; ui_max = 1;	
		ui_label = " UI Finer Center";
		ui_tooltip = "This is to give a finer center mip level.";
		ui_category = "Miscellaneous Options";
	> = UFC;

	uniform bool Read_Controller_AUI <
		ui_label = " UI Read Controller";
		ui_tooltip = "Reads the Right Trigger of your controller 'Needs the Xinp Add-on'.";
		ui_category = "Miscellaneous Options";
	> = RCI;
	
	uniform bool Isolate_UI <
		ui_label = " UI Alpha Isolation";
		ui_tooltip = "Used to Isolate a narrow band of information in the Alpha Channel.";
		ui_category = "Miscellaneous Options";
	> = AIM;	
	//This last option will be reworked.
	uniform bool Alpha_UI_is_Narrow <
		ui_label = " UI Narrow";
		ui_tooltip = "Only use when the letterbox is narrow.";
		ui_category = "Miscellaneous Options";
	> = Alpha_XYZW.z;

	uniform bool Alpha_UI_FullScreen <
		ui_label = " UI FS Disabler";
		ui_tooltip = "This is for when some games overlay a full screen effect and the shader needs to disable the effect.";
		ui_category = "Miscellaneous Options";
	> = UIF;		

	uniform bool Alpha_UI_LetterBox <
		ui_label = " UI LB Disabler";
		ui_tooltip = "This is for when some games overlay a full screen effect when using letter box for some reason.";
		ui_category = "Miscellaneous Options";
	> = UIL;		

	uniform bool UI_LB_Flatten <
		ui_label = " UI LB Flatten";
		ui_tooltip = "Keeps the letter box as part of the UI but pins it to one flat depth.\n"
					 "The UI sits at a low res depth so it hovers over whatever is under it. A\n"
					 "letter box has nothing under it, so that depth varies across the bar and\n"
					 "shows as a halo along its edge. This pins it instead.\n"
					 "The extent comes from the live depth buffer mapping, so it rescales in real\n"
					 "time and follows an aspect change mid scene.\n"
					 "Needs the Generic Depth Mod add-on with Exact Depth Fit on. Default is off.";
		ui_category = "Miscellaneous Options";
	> = ULF;
	#endif	
	
	// BSD: fixed constants for UI LB Flatten, tuned in Silent Hill Townfall to cover BOTH bars.
	// EDGE grows the pinned area in Alpha UI stencil texels, so it holds across games, resolutions and Depth_Rez.
	// The stencil is dilated three times on the way (DepthMap 7 taps into texCN.y, the texCN downsample at Depth_Rez,
	// then Alpha_UI_Mask's min of mip 0 and mip 1). That adds up to about 3.5, but 5.0 is what covers both bars.
	// Do NOT trim it without retesting: 1.6 left the TOP bar short, 3.6 was still not enough.
	// DEPTH is where the bars sit. It is a preference and one value serves both bars.
	// To change it, edit it here or promote it to an Overwatch define beside DMM_W.
	static const float UI_LB_Depth = 0.875;
	static const float UI_LB_Edge  = 5.0;
	
	#if AR_Is == 1
	#elif AR_Is == 2
	uniform bool Disable_CO <
		ui_label = " Disable AR Scaling Options";
		ui_tooltip = "This disables 16:10 compatibility options.";
		ui_category = "16:10 Options";
	> = SBTDA;

	uniform bool Scale_FC_Mode <
		ui_label = " Switch AR Scaling Mode";
		ui_tooltip = "This is the alternate scaling mode for 16:10 Content.";
		ui_category = "16:10 Options";
	> = SMSBT;

	uniform bool Shift_Up_Mode <
		ui_label = " Shift Up Scaling Mode";
		ui_tooltip = "This is the alternate mode shifting content down for 16:10 Content.";
		ui_category = "16:10 Options";
	> = SMSUM;

	uniform bool Side_Scaling_Mode <
		ui_label = " Side Scaling Mode";
		ui_tooltip = "For 16:10 games that squeeze the whole 16:9 image in from the sides, like AC Black Flag.\n"
					 "Applies the exact x0.9 side scaling when the left & right bars are detected.";
		ui_category = "16:10 Options";
	> = false;
	#else	
	#endif	
/* //Slated for deletion and with a link to a Help Guide online	
	//Extra Information
uniform int Extra_Information <
	ui_text =   "Profiles Info:\n"
				"If the shader loads a profile, avoid using [ZPD] and [Depth Map] options. \n"
				"Since adjusting options like Near Plane Adjustment, Flip, ZPD, Offset, & Etc.\n"
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
				"Now move the camera until it something near the screen violates the Boundary Detection.\n"
				"Now adjust [ZPD Scaler¹] from 0.5-0.875 once that looks good move on to the option below.\n"
				"[ZPD Scaler²] & [Intrusion] Move the camera where it clip a little and adjust the 1st option\n"
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
				"[Performance + Depth v ]\n"
				"|Normal + Depth        |\n"
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
				"Reconstruction    | Is a different way to render the images out.\n"
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
	// Cancel Depth Key: sets the Cancel Depth toggle key by keycode.
	// Ex. Numpad Decimal "." is key code 110, so Cancel_Depth_Key 110.
	//	#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	//Extra Information
	uniform int Extra_Information <
	ui_text =   "Preprocessors:\n"
				//"Color Correcting  | Is the process of restoring the original colors in the scenes.\n"
				//"Deband            | Is used to correct for banding issues in the image.\n"
				//"HDR compatibility | Allows for HDR support in the shader when HDR is available.\n"
				//"Inficolor 3D      | Modify the shader to accommodate Inficolor glasses for 3D content.\n"
				//"Reconstruction    | Is a different way to render the images out.\n"
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

	//Infill Mask & Blur Tuning//
	//Internal.
	static const bool Infill_Falloff = true;
	
	//Infill mask tuning, sliders behind INFILL_DEBUG.
	#if INFILL_DEBUG
	uniform float Mask_Reach_Px <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 8.0; ui_step = 0.25;
		ui_label = " Object Probe Reach";
		ui_tooltip = "Detector tap separation in px, on top of the dilation term. Too small and the mask dies.\nDefault is 1.0.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 1.0;
	uniform float Mask_Reach_Scale <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.1; ui_max = 2.0; ui_step = 0.05;
		ui_label = " Object Probe Scale";
		ui_tooltip = "Scales the object side detector tap only.\nDefault is 1.0.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 1.0;
	uniform float Mask_Reach_Near <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 4.0; ui_step = 0.05;
		ui_label = " Object Probe Near";
		ui_tooltip = "How much the object probe grows or shrinks against near backgrounds, blended with Object Probe Far like Reach Near and Far.\nDefault is 1.0.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 1.0;
	uniform float Mask_Reach_Far <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 1.0; ui_max = 4.0; ui_step = 0.05;
		ui_label = " Object Probe Far";
		ui_tooltip = "How much the object probe grows against far backgrounds, blended like Reach Near and Far. Near stays at Object Probe Scale.\nDefault is 2.5.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 2.5;
	uniform float Mask_Extend_Near <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 64.0; ui_step = 1.0;
		ui_label = " Reach Near";
		ui_tooltip = "Mask reach in px toward the background, for near surfaces. One sided.\nDefault is 8.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 8.0;
	uniform float Mask_Extend_Far <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 64.0; ui_step = 1.0;
		ui_label = " Reach Far";
		ui_tooltip = "Mask reach in px toward the background, for far surfaces. One sided.\nDefault is 32.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 32.0;
	uniform float Mask_Extend_Fade_Near <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.005;
		ui_label = " Fade Near";
		ui_tooltip = "Fade of the extended part for near surfaces.\nDefault is 0.0.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 0.0;
	uniform float Mask_Extend_Fade_Far <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.005;
		ui_label = " Fade Far";
		ui_tooltip = "Fade of the extended part for far surfaces.\nDefault is 0.125.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 0.125;
	uniform float Mask_Depth_Pt <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Near Far Point";
		ui_tooltip = "Where near turns into far.\nDefault is 0.25. Original was 0.75.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 0.25;
	uniform float Mask_Depth_Band <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.01; ui_max = 0.5; ui_step = 0.01;
		ui_label = " Near Far Band";
		ui_tooltip = "Half width of the near to far blend.\nDefault is 0.25.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 0.25;
	uniform float Mask_Depth_Gain <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 1.0; ui_max = 128.0; ui_step = 1.0;
		ui_label = " Near Far Gain";
		ui_tooltip = "Low end expansion, the linearised buffer stacks the scene near zero.\nDefault is 6. Original was 32.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 6.0;
	uniform float3 Mask_Extend_Near_Guided <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 64.0; ui_step = 0.5;
		ui_label = " Reach Near Luma Contrast Mixed";
		ui_tooltip = "Reach Near for VM2, VM4 and VM6 with each guided Infill Blur: Luma, Contrast, Mixed.\nDefault is 4, 3, 2.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = float3(4.0, 3.0, 2.0);
	uniform float3 Mask_Depth_Gain_Guided <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 8.0; ui_step = 0.125;
		ui_label = " Near Far Gain Luma Contrast Mixed";
		ui_tooltip = "Near Far Gain for VM2, VM4 and VM6 with each guided Infill Blur: Luma, Contrast, Mixed. 0 counts everything as near.\nDefault is 0.25, 0.375, 0.5.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = float3(0.25, 0.375, 0.5);
	uniform float Dither_Reach_Px <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 16.0; ui_step = 0.5;
		ui_label = " Dither Reach";
		ui_tooltip = "VM2, VM4 and VM6 Infill Blur dither: the farthest a gap pixel takes its colour from, in px, at full mask.\nDefault is 6.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 6.0;
	uniform float Gap_Detect_Lo <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 5.0; ui_step = 0.05;
		ui_label = " Gap Size Low";
		ui_tooltip = "Gap size in px where the mask starts.\nDefault is 0.5.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 0.5;
	uniform float Gap_Detect_Hi <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 1.0; ui_max = 20.0; ui_step = 0.25;
		ui_label = " Gap Size High";
		ui_tooltip = "Gap size in px where the mask is full.\nDefault is 10.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 10.0;
	uniform float Infill_Mask_Cut <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 0.9; ui_step = 0.01;
		ui_label = " Mask Cut";
		ui_tooltip = "Ignores weak mask, keeps the blur off walls at a steep angle. 0 is much worse.\nDefault is 0.3.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 0.3;
	uniform float Infill_Feather <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.5; ui_max = 4.0; ui_step = 0.05;
		ui_label = " Feather";
		ui_tooltip = "Ease in curve. Higher is softer.\nDefault is 2.0.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 2.0;
	uniform float Mask_Edge_Px <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.5; ui_max = 3.0; ui_step = 0.25;
		ui_label = " Mask Edge Width";
		ui_tooltip = "How far out the mask edge AA looks, in pixels.\nDefault is 2.0.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 2.0;
	uniform float Mask_Edge_Soft <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
		ui_label = " Mask Edge Softness";
		ui_tooltip = "How strongly the mask edge takes its neighbours' average. 0 is off, the hard 4 step edge.\nIt only ever lowers the mask, so it cannot grow onto the object.\nDefault is 1.0.";
		ui_category = "Infill Mask Tuning";
		ui_category_closed = true;
	> = 1.0;
	uniform float Infill_Soft_Px <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 1.0; ui_max = 64.0; ui_step = 1.0;
		ui_label = " Blur Reach";
		ui_tooltip = "Mask profile reach in px in the post pass. Does not follow depth.\nDefault is 32.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 32.0;
	uniform float Post_Vert <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Vertical Blur";
		ui_tooltip = "Vertical blur in the post pass, crosses the sheeting.\nDefault is 0.6.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.6;
	uniform float Luma_Dark <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Luma Dark";
		ui_tooltip = "Luma Guided: below this luma the blur is left mostly alone.\nDefault is 0.15.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.15;
	uniform float Luma_Bright <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Luma Bright";
		ui_tooltip = "Luma Guided: at this luma and above the blur gets its full boost.\nDefault is 0.7.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.7;
	uniform float Luma_Floor <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Luma Floor";
		ui_tooltip = "Luma Guided: how much blur dark areas keep. Low leaves them mostly alone.\nDefault is 0.25.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.25;
	uniform float Luma_Boost <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
		ui_label = " Luma Boost";
		ui_tooltip = "Luma Guided: how much stronger the blur gets in bright areas. 0.5 is up to 1.5 times as strong.\nDefault is 0.5.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.5;
	uniform float Contrast_Lo <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Contrast Low";
		ui_tooltip = "Contrast Guided: contrast where the boost starts.\nDefault is 0.05.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.05;
	uniform float Contrast_Hi <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Contrast High";
		ui_tooltip = "Contrast Guided: contrast where the boost is full.\nDefault is 0.3.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.3;
	uniform float Contrast_Flat <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
		ui_label = " Contrast Flat";
		ui_tooltip = "Contrast Guided: how much blur flat stretches keep. Low leaves flat areas mostly alone.\nDefault is 0.25.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.25;
	uniform float Contrast_Boost <
		#if Compatibility
		ui_type = "drag";
		#else
		ui_type = "slider";
		#endif
		ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
		ui_label = " Contrast Boost";
		ui_tooltip = "Contrast Guided: how much stronger the blur gets on contrast, patterns and edges. 0 keeps patterns at plain blur strength.\nDefault is 0.0.";
		ui_category = "Infill Blur Tuning";
		ui_category_closed = true;
	> = 0.0;
	#else
		static const float Mask_Reach_Px = 1.0;//was 2.0
		static const float Mask_Reach_Scale = 1.0;
		static const float Mask_Reach_Near = 1.0;//was 0.75, then 0.5, then 0.0
		static const float Mask_Reach_Far = 2.5;
		static const float Mask_Extend_Near = 8.0;
		static const float Mask_Extend_Far = 32.0;
		static const float Mask_Extend_Fade_Near = 0.0;
		static const float Mask_Extend_Fade_Far = 0.125;
		static const float Mask_Depth_Pt = 0.25;//was 0.5
		static const float Mask_Depth_Band = 0.25;
		static const float Mask_Depth_Gain = 6.0;//was 10.0, originally 32.0
		static const float Gap_Detect_Lo = 0.5;
		static const float Gap_Detect_Hi = 10.0;
		static const float Infill_Mask_Cut = 0.3;
		static const float Infill_Feather = 2.0;
		static const float Infill_Soft_Px = 32.0;
		static const float Mask_Edge_Px = 2.0, Mask_Edge_Soft = 1.0;
		static const float Post_Vert = 0.6;
		static const float Luma_Dark = 0.15, Luma_Bright = 0.7, Luma_Floor = 0.25, Luma_Boost = 0.5;
		static const float Contrast_Lo = 0.05, Contrast_Hi = 0.3, Contrast_Boost = 0.0, Contrast_Flat = 0.25;
		// VM2 and VM4 and VM6 Dither Settings
		static const float Dither_Reach_Px = 6.0;//Dither reach in px, was 0.375 * 16
		//Luma Guided
		static const float Mask_Extend_Near_Luma = 4.0;
		static const float Mask_Depth_Gain_Luma = 0.25;
		//Contrast Guided
		static const float Mask_Extend_Near_Contrast = 2.0;
		static const float Mask_Depth_Gain_Contrast = 0.5;
		//Mixed
		static const float Mask_Extend_Near_Mixed = 1.0;
		static const float Mask_Depth_Gain_Mixed = 1.0;
		//x Luma, y Contrast, z Mixed.
		static const float3 Mask_Extend_Near_Guided = float3(Mask_Extend_Near_Luma, Mask_Extend_Near_Contrast, Mask_Extend_Near_Mixed);
		static const float3 Mask_Depth_Gain_Guided = float3(Mask_Depth_Gain_Luma, Mask_Depth_Gain_Contrast, Mask_Depth_Gain_Mixed);
	#endif
	//View Modes that dither the infill instead of blurring it.
	#define VM_Infill_Dither (View_Mode == 2 || View_Mode == 4)
	#define VM_Dither_Guided (VM_Infill_Dither && Infill_Blur >= 2)
	//Guided Infill Blur picks its own Reach Near and Near Far Gain.
	#define Guided_Pick(v) (Infill_Blur == 2 ? (v).x : Infill_Blur == 3 ? (v).y : (v).z)
	#define Mask_Bg_Near (VM_Dither_Guided ? Guided_Pick(Mask_Extend_Near_Guided) : Mask_Extend_Near)
	#define Mask_Gain (VM_Dither_Guided ? Guided_Pick(Mask_Depth_Gain_Guided) : Mask_Depth_Gain)
	#define Depth_Blend(d) smoothstep(saturate(Mask_Depth_Pt - Mask_Depth_Band), saturate(Mask_Depth_Pt + Mask_Depth_Band), 1.0 - exp2(-(d) * Mask_Gain))

	//Infill Blur strength by mode.
	float Infill_Guide(float3 C, float L_Min, float L_Max)
	{
	    float Luma = dot(saturate(C), float3(0.2126, 0.7152, 0.0722));
	    float TL = smoothstep(Luma_Dark, max(Luma_Bright, Luma_Dark + 0.001), Luma);
	    float TC = smoothstep(Contrast_Lo, max(Contrast_Hi, Contrast_Lo + 0.001), (L_Max - L_Min) * rcp(L_Max + 0.25));
	    float WL = lerp(Luma_Floor, 1.0 + Luma_Boost, TL);
	    float WC = lerp(Contrast_Flat, 1.0 + Contrast_Boost, TC);
	    //Mixed.
	    float WM = min(lerp(Contrast_Flat, 1.0, TC) * (1.0 + Luma_Boost * TL), 1.0);
	    return Infill_Blur == 2 ? WL : Infill_Blur == 3 ? WC : Infill_Blur == 4 ? WM : 1.0;
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; mode = "toggle";>;
	uniform bool Text_Info < source = "key"; keycode = Text_Info_Key; toggle = true; mode = "toggle";>;
	//Needs the Gamepad add-on. X is Toggle, Y is Raw.
	uniform float2 gamepad_toggle_raw[25]    < source = "gamepad_toggle_raw";>;
	
	uniform bool CLK_04 < source = "mousebutton"; keycode = Mouse_Key_Four; toggle = true; mode = "toggle";>;
	uniform bool CLK_03 < source = "mousebutton"; keycode = Mouse_Key_Three; toggle = true; mode = "toggle";>;
	uniform bool CLK_02 < source = "mousebutton"; keycode = Mouse_Key_Two; toggle = true; mode = "toggle";>;

	uniform bool Trigger_Fade_Toggle < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
	uniform bool Trigger_Fade_Hold < source = "mousebutton"; keycode = Fade_Key;>;
	
	uniform bool Menu_Open < source = "overlay_open"; >;
	uniform float2 Mousecoords < source = "mousepoint"; > ;
	uniform float frametime < source = "frametime";>;
	// Frame Alternation source: 0 = ReShade framecount (default), 1 = addon-driven (Frame Alternation addon).
	uniform bool Frame_Alternate < source = "addon"; > = false; // Addon controls via set_uniform_value("Alternate", ...) each frame.
	uniform bool Alternate < source = "framecount";>;     // Alternate even and odd frames

	uniform int Frames < source = "framecount";>;     // Alternate even and odd frames
	uniform float timer < source = "timer"; >;
	#define FLT_EPSILON  1.192092896e-07 // smallest such that Value + FLT_EPSILON != Value	
	#define M_Divergence 0.3
	
	float2 Divergence_Switch()
	{
		float2 Divergence = float2(100,Depth_Adjustment);
		#if IC_DEPTH
			return float2(Divergence.x,Divergence.y * 0.5) + FLT_EPSILON;
		#else
			return Divergence + FLT_EPSILON;		
		#endif
	}
	
	#if HDR_Compatible_Mode == 1
		#define BC_SPACE 1
	#else
		#define BC_SPACE 0
	#endif

	// Simulate Depth_Rez using integer math: 100 = 1.0, 75 = 0.75, 50 = 0.5
	#if Set_Depth_Res == 1
	    #define Depth_Rez_Mul 75
	    #define Depth_Rez 0.75
	#elif Set_Depth_Res == 2
	    #define Depth_Rez_Mul 50
	    #define Depth_Rez 0.5   
	#else
	    #define Depth_Rez_Mul 100
	    #define Depth_Rez 1.0
	#endif
		
	// Depth Size MAX
	#if BUFFER_WIDTH > BUFFER_HEIGHT
	    #define COMB_SIZE BUFFER_WIDTH
	#else
	    #define COMB_SIZE BUFFER_HEIGHT
	#endif

	#define DS_COMB_SIZE ((COMB_SIZE * Depth_Rez_Mul) / 100)

	// Mip selection
	#if DS_COMB_SIZE <= 3360
		#if DS_COMB_SIZE <= 1400
			#if Set_Depth_Res >= 2
				#define Max_Mips 8
			#else
				#define Max_Mips 9
			#endif
		#else
			#if Set_Depth_Res >= 2
				#define Max_Mips 10
			#else
				#define Max_Mips 11
			#endif
		#endif
	#else
		#if Set_Depth_Res >= 2
			#define Max_Mips 11
		#else
			#define Max_Mips 12
		#endif
	#endif
	///////////////////////////////////////////////////////////////3D Starts Here///////////////////////////////////////////////////////////
	texture DepthBufferTex : DEPTH;
	sampler DepthBuffer
	{
		Texture = DepthBufferTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		//Point filtering for games like AMID Evil that lack proper filtering.
		MagFilter = POINT;
		MinFilter = POINT;
		MipFilter = POINT;
	};

	#if GDM_WEAPON_DEPTH //Only allocated when the feature is on, to save a texture slot on slot-limited APIs (e.g. DX9).
	texture WeaponDepthBufferTex : WDEPTH;
	sampler WDepthBuffer
	{
		Texture = WeaponDepthBufferTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		//Point filtering for games like AMID Evil that lack proper filtering.
		MagFilter = POINT;
		MinFilter = POINT;
		MipFilter = POINT;
	};
	#endif
	
	texture BackBufferTex : COLOR;
	//Reads the live backbuffer for the InfillMask pass. Not redirected by Delay Frame Mode.
	sampler BB_Mask { Texture = BackBufferTex; };
	#if AXAA_EXIST
	//AXAA's final fetch in linear light. Only 8 bit SDR has an sRGB view.
	#if BUFFER_COLOR_BIT_DEPTH == 8 && !BC_SPACE
		sampler BB_Linear { Texture = BackBufferTex; SRGBTexture = true; };
		#define AXAA_F_Sampler BB_Linear
		#define AXAA_Linear true
	#else
		#define AXAA_F_Sampler Live_Sampler
		#define AXAA_Linear false
	#endif
	#endif
	
	#if BC_SPACE == 1
		#define Color_Format_B RGBA16
	#else
		#define Color_Format_B RGB10A2
	#endif
	
	#if D_Frame
		#if BC_SPACE == 1
			#define Color_Format_DF RGBA16F
		#elif BUFFER_COLOR_BIT_DEPTH == 10
			#define Color_Format_DF RGB10A2
		#else
			#define Color_Format_DF RGBA8
		#endif
		//This frame's image. Written by Current_Frame, copied into texDF by Delay_Frame on the next frame.
		texture texCF { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format_DF; };

		sampler SamplerCF
		{
			Texture = texCF;
		};

		//Last frame's image. Everything that reads the back buffer before StereoOut reads this instead.
		texture texDF { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format_DF; };

		//The live back buffer, for Current_Frame, BlendOut and every pass that runs after StereoOut.
		#define Live_Sampler BB_Mask
		
		#if DX9_Toggle
		sampler DF_BackBufferBMC
		{
			Texture = texDF;
			#if Set_Custom_Sidebars == 0
				AddressU = MIRROR;
				AddressV = MIRROR;
				AddressW = MIRROR;
			#elif Set_Custom_Sidebars == 1
				AddressU = BORDER;
				AddressV = BORDER;
				AddressW = BORDER;
			#elif Set_Custom_Sidebars == 2		
				AddressU = CLAMP;
				AddressV = CLAMP;
				AddressW = CLAMP;
			#else
				#warning "Set_Custom_Sidebars must be 0, 1, or 2. Defaulting to BORDER one."
				AddressU = BORDER;
				AddressV = BORDER;
				AddressW = BORDER;
			#endif			
		};
		#else		
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
		#endif
		
		#define BackBuffer_M DF_BackBufferMIRROR
		#define BackBuffer_B DF_BackBufferBORDER
		#define BackBuffer_C DF_BackBufferCLAMP
		
		#if DX9_Toggle
			#define Non_Point_Sampler DF_BackBufferBMC
		#else
			#define Non_Point_Sampler BackBuffer_C
		#endif
		
	#else
		#if DX9_Toggle
		sampler BackBufferBMC
		{
			Texture = BackBufferTex;
			#if Set_Custom_Sidebars == 0
				AddressU = MIRROR;
				AddressV = MIRROR;
				AddressW = MIRROR;
			#elif Set_Custom_Sidebars == 1
				AddressU = BORDER;
				AddressV = BORDER;
				AddressW = BORDER;
			#elif Set_Custom_Sidebars == 2		
				AddressU = CLAMP;
				AddressV = CLAMP;
				AddressW = CLAMP;
			#else
				#warning "Set_Custom_Sidebars must be 0, 1, or 2. Defaulting to BORDER one."
				AddressU = BORDER;
				AddressV = BORDER;
				AddressW = BORDER;
			#endif			
		};
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
		#endif
		

		#define BackBuffer_M BackBufferMIRROR
		#define BackBuffer_B BackBufferBORDER
		#define BackBuffer_C BackBufferCLAMP
		
		#if DX9_Toggle
			#define Non_Point_Sampler BackBufferBMC
		#else
			#define Non_Point_Sampler BackBuffer_C
		#endif
		#define Live_Sampler Non_Point_Sampler
	#endif
	
	texture texDMN { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; MipLevels = Max_Mips; }; //Mips Used
	
	sampler SamplerDMN
		{
			Texture = texDMN;
		};

	texture texCN { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG8; MipLevels = Max_Mips; }; //Mips Used
	
	sampler SamplerCN
		{
			Texture = texCN;
		};

	#if !DX9_Toggle //DX9 never reads this: its ZPD boundary grid calls PrepDepth() directly, so skip the RT and its pass.
	texture texMiniReconBuffer { Width = BUFFER_WIDTH * 0.125; Height = BUFFER_HEIGHT * 0.125; Format = R16F; }; //Only the ZPD boundary grid reads it.

	sampler SamplerMR
		{
			Texture = texMiniReconBuffer;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;	
		};
	#endif
	
	texture texzBufferN_P { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; };
	
	sampler SamplerzBufferN_P
		{
			Texture = texzBufferN_P;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
			
		};
	
	texture texzBufferN_L { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; MipLevels = 8; }; //Mips Used
	
	sampler SamplerzBufferN_L
		{
			Texture = texzBufferN_L;
		};
		
	#if Reconstruction_Mode || Virtual_Reality_Mode || Anaglyph_Mode
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
	
	#if IL_EYE_BUFFER && !(DX9_Toggle || Anaglyph_Mode || Inficolor_3D_Emulator || Use_2D_Plus_Depth || REST_UI_Mode || DoubleBuffer_Mode || Super3D_Mode)
		#define IL_EYES 1
		//Matches what it feeds, so the pixels come back unchanged.
		#if Reconstruction_Mode || Virtual_Reality_Mode
			#define Color_Format_IL Color_Format_B
		#elif BC_SPACE == 1
			#define Color_Format_IL RGBA16F
		#elif BUFFER_COLOR_BIT_DEPTH == 10
			#define Color_Format_IL RGB10A2
		#else
			#define Color_Format_IL RGBA8
		#endif
	texture texIL_Eyes { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = Color_Format_IL; };

	sampler Sampler_IL_Eyes
		{
			Texture = texIL_Eyes;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	#else
		#define IL_EYES 0
	#endif

	#if VM0_FIELD
	//VM0 structure field: brightness structure tensor (gx^2, gy^2, gx*gy) at half resolution, built once a frame so the
	//march reads one texel instead of measuring gradients per gap pixel. Read at mip 2, about a 4 px Gaussian, the
	//papers' tensor smoothing (rho about 4, Bornemann & Marz).
	//NOTE: the wobble near objects comes from this field's direction. Low mips are noisy, high mips jump as content
	//crosses their fixed screen blocks (mips 0 to 6 tested). We may need to blur the field (a smooth spatial blur, or
	//blending with last frame's field) so the direction eases instead of jumping.
	texture texSF { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA16F; MipLevels = 3; };
	sampler Sampler_SF { Texture = texSF; };
	#endif


	#if AG_EYES
	//Holds Parallax's sample offset from the pixel (xy), hole mask (z) and Memory Infill offset (w), not colour.
	texture texAG_Eyes { Width = BUFFER_WIDTH * AG_BUDGET; Height = BUFFER_HEIGHT; Format = RGBA16F; };

	sampler Sampler_AG_Eyes
		{
			Texture = texAG_Eyes;
		};
	//Hole mask, point sampled so narrow gaps are not averaged away.
	sampler Sampler_AG_Eyes_P
		{
			Texture = texAG_Eyes;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	#endif

	#if !DX9_Toggle
	//Auto Scaler.
	texture texShiftD { Width = 1; Height = 1; Format = R16F; };
	sampler Sampler_ShiftD { Texture = texShiftD; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	#endif

	#if DoubleBuffer_Mode
	texture DoubleTex { Width = BUFFER_WIDTH * 2; Height = BUFFER_HEIGHT; Format = Color_Format_B; };
	
	sampler SamplerDouble
	    {
	            Texture = DoubleTex;
	    };
	texture texDB_March { Width = BUFFER_WIDTH * 2; Height = BUFFER_HEIGHT; Format = RGBA16F; };

	sampler SamplerDB_March
	    {
	            Texture = texDB_March;
	    };
	//z and w are not blended: the mask stays crisp and the packed line data whole.
	sampler SamplerDB_March_P
	    {
	            Texture = texDB_March;
	            MagFilter = POINT;
	            MinFilter = POINT;
	            MipFilter = POINT;
	    };
	#endif
  
	#if DX9_Toggle
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = R16F; MipLevels = 6; }; // Needs RG16F if an external texture is given for downsampling, not if it is already downsampled.
	#else
		#if TMD
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = RG16F; MipLevels = 6; }; // Needs RG16F if an external texture is given for downsampling, not if it is already downsampled.
		#else
		texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = R16F; MipLevels = 6; }; // Needs RG16F if an external texture is given for downsampling, not if it is already downsampled.
		#endif	
	#endif
		sampler SamplerzBuffer_BlurN
		{
			Texture = texzBufferBlurN;
		};
	//Could be expanded to RG16F to pass more information to Avr Tex.	
	texture texzBufferBlurEx < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = RG16F;  };

	sampler SamplerzBuffer_BlurEx
	{
		Texture = texzBufferBlurEx;
	};
	#if !DX9_Toggle	
		#if Anti_Jitter_Mode
	texture texzBufferN_M { Width = BUFFER_WIDTH  * Depth_Rez; Height = BUFFER_HEIGHT  * Depth_Rez; Format = R16F; };
		#else
	texture texzBufferN_M { Width = BUFFER_WIDTH  * Depth_Rez; Height = BUFFER_HEIGHT  * Depth_Rez; Format = R16F; MipLevels = 3;};
		#endif

	sampler SamplerzBufferP_Mixed
		{
			Texture = texzBufferN_M;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};		
	#else
	texture texzBufferN_M { Width = BUFFER_WIDTH  * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = R16F; }; //Do not use mips in this buffer

	sampler SamplerzBufferB_Mixed
		{
			Texture = texzBufferN_M;
		};
		
	sampler SamplerzBufferP_Mixed
		{
			Texture = texzBufferN_M;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	#endif

	#if DX9_Toggle //DX9-only depth-smoothing buffer: anti-aliases the heavily-aliased DX9 depth. Written by pass DepthSmoothDX9, read by GetMixed.
	texture texSmooth { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = AA_Format; };
	sampler SamplerzBufferB_Smooth { Texture = texSmooth; };
	#endif

	#if !DX9_Toggle
		#if Anti_Jitter_Mode
		// TAA
		texture TAABuffer { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = R16F; };
	
		sampler SamplerzBufferP_TAA
			{
				Texture = TAABuffer;
				MagFilter = POINT;
				MinFilter = POINT;
				MipFilter = POINT;
			};
		#endif			
	// Reconstruction
	texture texReconBuffer { Width = BUFFER_WIDTH  * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = R16F; }; //Do not use mips in this buffer

	sampler SamplerzBufferB_Up
		{
			Texture = texReconBuffer;
		};

	sampler SamplerzBufferP_Up
		{
			Texture = texReconBuffer;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	texture texSmooth { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = AA_Format; };
	
	//No point sampler on texSmooth.
	sampler SamplerzBufferB_Smooth
	    {
	        Texture = texSmooth;
	    };

		#if Anti_Jitter_Mode
		// TAA
		texture AccBuffer { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; }; //Do not use mips in this buffer
		
		sampler SamplerzACC
			{
				Texture = AccBuffer;
			};
		#endif		
	#endif	

	texture Info_Tex { Width = 960; Height = 540; Format = RGBA8;};
	sampler SamplerInfo { Texture = Info_Tex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

	#define Scale_Buffer 160 / BUFFER_WIDTH
	////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////
	texture texAvrN { Width = BUFFER_WIDTH * Scale_Buffer; Height = BUFFER_HEIGHT * Scale_Buffer; Format = RGBA16F; MipLevels = 8;}; //Mips Used

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
		return saturate(tex2Dlod(SamplerAvrB_N,float4(texcoord,0,11)).y);//Average Depth Brightness Texture Sample
	}		
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	float2 rcp_Depth_Size()
	{
	    return 1.0 / tex2Dsize(DepthBuffer);
	}
	
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
	/*
	// Standard YCoCg conversion
	float3 RGBToYCoCg8Normalized(float3 rgb)
	{
	    float3 ycocg;
	    ycocg.x = 0.25 * rgb.r + 0.5 * rgb.g + 0.25 * rgb.b;       // Y (Luma)
	    ycocg.y = 0.5 * rgb.r - 0.5 * rgb.b + 0.5;                 // Co (Orange-Blue) + 0.5 for 8-bit storage
	    ycocg.z = -0.25 * rgb.r + 0.5 * rgb.g - 0.25 * rgb.b + 0.5; // Cg (Green-Magenta) + 0.5 for 8-bit storage
	    return ycocg;
	}
	
	float3 YCoCg8NormalizedToRGB(float3 ycocg)
	{
	    // Restore chrominance to signed range
	    float co = ycocg.y - 0.5;
	    float cg = ycocg.z - 0.5;
	    
	    // Inverse YCoCg transform
	    float3 rgb;
	    rgb.r = ycocg.x + co - cg;  // R
	    rgb.g = ycocg.x + cg;       // G
	    rgb.b = ycocg.x - co - cg;  // B
	    
	    return saturate(rgb); // Clamp to valid range
	}
	*/
	static const float Auto_Balance_Clamp = 0.5; //This clamps Auto Balance's max distance.
	#if GDM_WEAPON_DEPTH
		uniform bool WPresentCheck < source = "weapon_present"; >;
		uniform bool WDepthCheck < source = "bufready_wdepth"; >;
	#endif
	//GDM add-on depth fit data, every API. DX9 used to fail with "error X4509 maximum constant register index
	//exceeded" here (DB_Viewport_Size needs a whole free float4 register); since the 2026-10 trims it fits. If that
	//error comes back after adding uniforms, this float4 is the first thing to gate out of DX9.
	uniform float2 DB_Res_Info < source = "depth_resolution"; >;
	uniform float4 DB_Viewport_Size < source = "depth_viewport_size"; >;
	uniform bool DB_AutoFit < source = "depth_autofit"; >;
	uniform float2 DB_Render_Size < source = "depth_render_size"; >;
	#if Compatibility_00
		uniform bool DepthCheck < source = "bufready_depth"; >;
	#endif

	float3 RE_Set(float Auto_Switch)
	{
		#if EDW || Profiler_Mode // Set By SuperDepth3D
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
		//Padded with zeros, so a level past the last reads 0.
		int Scale_Auto_Switch = clamp((Auto_Switch * 5) - 1,0 , 3 );
		float Set_RE = OIL_Switch[Scale_Auto_Switch];

		int REF_Trigger = Set_RE > 0;
		
		//X is a bool to enable the extra levels.
		//Y is the Set_Level number from the auto switch.
		//Z is not used.
		return float3(REF_Trigger, Set_RE , Scale_Auto_Switch); 
	}
	
	float4 RE_Set_Adjustments()
	{
		#if EDW || Profiler_Mode// Set By SuperDepth3D
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
		#if EDW || Profiler_Mode
		return ZPD_Boundary_n_Cutoff_End.xy;
		#else
		return DKK_W;
		#endif
	}
	
	#if EDW || Profiler_Mode
    int ZPDBoundaryRank()
    {
    	float Rank;
        float A = ZPD_Boundary_n_Cutoff_A.x,
              B = ZPD_Boundary_n_Cutoff_B.x, 
              C = ZPD_Boundary_n_Cutoff_C.x, 
              D = ZPD_Boundary_n_Cutoff_D.x, 
              End = ZPD_Boundary_n_Cutoff_End.x;
        if (A > 0.0) Rank = 0;
        if (B > 0.0) Rank = 1;
        if (C > 0.0) Rank = 2;
        if (D > 0.0) Rank = 3;
        if (End > 0.0) Rank = 4;  

		return Rank; 
    }
	#endif
	
	float Scale(float val,float max,float min) //Scale to 0 - 1
	{
		return (val - min) / (max - min);
	}
	
	//Resolution Scaling because I can't tell your monitor size. Each level is 25 more than it should be.
	float CalculateMaxDivergence(uint x)
	{   //What is commented out below does not work for some reason, so I have to do this strange thing instead.
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
		float Min_Div = max(1.0, Diverge), D_Scale = min(1.0+saturate(M_Divergence),Scale(Min_Div,100.0,1.0));
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
		return float2(abs(Near_Plane_Popout),Near_Plane_Popout >= 0 ? 100.0 : 75.0); //Used to be 0 : 1. Now zero is 100.0 and one is 75.0. 
	}	

	float Perspective_Switch()
	{  
	    float Scale_Value_Cal =  Re_Scale_WN().y;
	    	  Scale_Value_Cal *= CalculateMaxDivergence(BUFFER_HEIGHT); 
		float Min_Div = max(1.0, Divergence_Switch().x), D_Scale = Scale(Min_Div,100.0,1.0); 

		#if Virtual_Reality_Mode && !Super3D_Mode
		float Pers = IPD;
		#else
		float IC_Diverge = Divergence_Switch().y;
		float I_3D_Divergence = Eye_Swap ? IC_Diverge * lerp(0.25,0.75,1-Focus_Inficolor) : -IC_Diverge * lerp(0.25,0.75,1-Focus_Inficolor) ;	    	 
  	  float Pers = IC_DEPTH ?  I_3D_Divergence : Perspective;
  	  #endif  	  
		float Perspective_Out = Pers, Push_Depth = (Re_Scale_WN().x*Scale_Value_Cal)*D_Scale;
		#if !Use_2D_Plus_Depth
			Perspective_Out = Eye_Swap ? Pers + Push_Depth : Pers - Push_Depth;
		#endif
		return Perspective_Out;	
	}

	#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	#define Per Vert_3D_Pinball ? float2( 0, (Perspective_Switch() * pix.x) ) : float2( (Perspective_Switch() * pix.x), 0) //Per is Perspective
	#define Res int2(BUFFER_WIDTH, BUFFER_HEIGHT)
	#define AI Interlace_Optimization * 0.5 //Optimization for the line interlaced adjustment.
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
		
		// Enshore red component consistency using dot product
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
	{	//Focus away from center
		TC *= (1.0 - TC.yx); 
	    float Vin = TC.x*TC.y * V_Power.x, Use_Depth = 1;// step(PrepDepth( texcoord.xy )[0][0] + 0.30, 0.375);
	    return 1-saturate(pow(abs(Vin),V_Power.y));	
	}

	float Interleaved_Gradient_Noise(float2 TC)
	{   //Magic Numbers
	    float3 MNums = float3(0.06711056, 0.00583715, 52.9829189);
	    return frac( MNums.z * frac(dot(TC,MNums.xy)) );
	}

	float3 Patterns(float2 TC)
	{
		float3 Pattern = float3( floor(TC.y*Res.y) + floor(TC.x*Res.x), floor(TC.x*Res.x), floor(TC.y*Res.y));
		return Pattern;
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
	#if Compatibility_00
		#define DispCycle 1250
	#else
		#define DispCycle 12500
	#endif
	
	bool Helper_Fuction()
	{
		return tex2D(SamplerInfo,float2(0.911,0.968)).x;
	}

	float Info_Fuction()
	{
		return timer <= DispCycle || Text_Info;
	}	

	float4 CSB(float2 texcoords)
	{ 
		float2 TC = -texcoords * texcoords*32 + texcoords*32;
		float Vin = Adjust_Vignette > 0 ? saturate(smoothstep(FLT_EPSILON,(FLT_EPSILON+Adjust_Vignette)*27.0f,TC.x * TC.y)) : 1;
		
		#if BC_SPACE == 1
			#if DX9_Toggle
			if(Depth_Map_View == 0)
				return NormalizeScRGB(tex2Dlod(Non_Point_Sampler,float4(texcoords,0,0)) *  Vin);
			else
				return NormalizeScRGB(tex2Dlod(SamplerzBufferN_P,float4(texcoords,0,0)).x);
			#else	
			if(Custom_Sidebars == 0 && Depth_Map_View == 0)
				return NormalizeScRGB(tex2Dlod(BackBuffer_M,float4(texcoords,0,0)) *  Vin);
			else if(Custom_Sidebars == 1 && Depth_Map_View == 0)
				return NormalizeScRGB(tex2Dlod(BackBuffer_B,float4(texcoords,0,0)) *  Vin);
			else if(Custom_Sidebars == 2 && Depth_Map_View == 0)
				return NormalizeScRGB(tex2Dlod(BackBuffer_C,float4(texcoords,0,0)) *  Vin);
			else
				return NormalizeScRGB(tex2Dlod(SamplerzBufferN_P,float4(texcoords,0,0)).x);
			#endif
		#else
			#if DX9_Toggle
			if(Depth_Map_View == 0)
				return tex2Dlod(Non_Point_Sampler,float4(texcoords,0,0)) *  Vin;
			else
				return tex2Dlod(SamplerzBufferN_P,float4(texcoords,0,0)).x;
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
		#endif

	}

	float SLLTresh(float2 TCLocations, float MipLevel)
	{ 
		return tex2Dlod(SamplerCN,float4(TCLocations,0, MipLevel)).x;
	}
	
	#if LBC || LBM || LB_Correction || LetterBox_Masking
	int LBSensitivity( float inVal )
	{
		#if LBS
			#if LBS == 2
			return inVal < 0.0225; //Least Sensitive
			#else
			return inVal < 0.005; //Less Sensitive
			#endif
		#else
			return inVal == 0; //Sensitive
		#endif
	}	
	
	int LBDetection() // Active RGB Detection
	{   
	    int Letter_Box_Center_Mips_Level_Senstivity = 7;   
	    float2 Letter_Box_Reposition = float2(0.1, 0.5);
	    
	    // Letter Box Reposition Settings
	    if (LBR == 1) 
	        Letter_Box_Reposition = float2(0.250, 0.875);
	    if (LBR == 2) 
	        Letter_Box_Reposition = float2(0.5, 0.625);
	    if (LBR == 3) 
	        Letter_Box_Reposition = float2(0.50, 0.5);
	    if (LBR == 4) 
	        Letter_Box_Reposition = float2(0.5, 0.92);
	    if (LBR == 5) 
	        Letter_Box_Reposition = float2(0.5, 0.100);
	    
	    // Letter Box Invert
	    if (LBI)
	        Letter_Box_Reposition.x = 1 - Letter_Box_Reposition.x;		
	    
	    // Letter Box Level Sensitivity Settings
	    if (LBL == 1)
	        Letter_Box_Center_Mips_Level_Senstivity = 8;
	    if (LBL == 2)
	        Letter_Box_Center_Mips_Level_Senstivity = 9;
	    if (LBL == 3)
	        Letter_Box_Center_Mips_Level_Senstivity = 10;
	    if (LBL >= 4)
	        Letter_Box_Center_Mips_Level_Senstivity = 11;
	    
	    //===========================================================================
	    // LETTER BOX DETECTION MAP - POSITION REFERENCE
	    //===========================================================================
	    
	    // CENTER POSITION:
	    // (0.5, 0.5)
	    
	    //===========================================================================
	    // DEFAULT (LBR == 0):
	    //   Top:    (0.1, 0.09)
	    //           LBE One = (0.1, 0.045)  
	    //           LBE Two = (0.1, 0.035)
	    //   Bottom: (0.5, 0.91)
	    //           LBE One = (0.5, 0.955)  
	    //           LBE Two = (0.5, 0.965)
	    //===========================================================================
	    
	    //===========================================================================
	    // LETTER BOX REPOSITION ONE (LBR == 1):
	    //   Top:    (0.250, 0.09)
	    //           LBE One = (0.250, 0.045)
	    //           LBE Two = (0.250, 0.035)
	    //   Bottom: (0.875, 0.91)
	    //           LBE One = (0.875, 0.955)
	    //           LBE Two = (0.875, 0.965)
	    //===========================================================================
	    
	    //===========================================================================
	    // LETTER BOX REPOSITION TWO (LBR == 2):
	    //   Top:    (0.5, 0.09)
	    //           LBE One = (0.5, 0.045)
	    //           LBE Two = (0.5, 0.035)
	    //   Bottom: (0.625, 0.91)
	    //           LBE One = (0.625, 0.955)
	    //           LBE Two = (0.625, 0.965)
	    //===========================================================================
	    
	    //===========================================================================
	    // LETTER BOX REPOSITION THREE (LBR == 3):
	    //   Top:    (0.50, 0.09)
	    //           LBE One = (0.50, 0.045)
	    //           LBE Two = (0.50, 0.035)
	    //   Bottom: (0.5, 0.91)
	    //           LBE One = (0.5, 0.955)
	    //           LBE Two = (0.5, 0.965)
	    //===========================================================================
	    
	    //===========================================================================
	    // LETTER BOX REPOSITION FOUR (LBR == 4):
	    //   Top:    (0.5, 0.09)
	    //           LBE One = (0.5, 0.045)
	    //           LBE Two = (0.5, 0.035)
	    //   Bottom: (0.92, 0.91)
	    //           LBE One = (0.92, 0.955)
	    //           LBE Two = (0.92, 0.965)
	    //===========================================================================
	    
	    //===========================================================================
	    // LETTER BOX REPOSITION FIVE (LBR == 5):
	    //   Top:    (0.5, 0.09)
	    //           LBE One = (0.5, 0.045)
	    //           LBE Two = (0.5, 0.035)
	    //   Bottom: (0.125, 0.91)
	    //           LBE One = (0.100, 0.955)
	    //           LBE Two = (0.100, 0.965)
	    //===========================================================================
	    
	    #if LB_Correction == 3 || LB_Correction == 4 || LBC == 3 || LBC == 4 || LetterBox_Masking == 3 || LBM == 3 || LetterBox_Masking == 4 || LBM == 4
	        //=======================================================================
	        // HORIZONTAL & VERTICAL MODE (5-Point Detection)
	        //=======================================================================
	        float MipLevel = 5;
	        
	        // Detection Points:
	        int Top_Left      = LBSensitivity(SLLTresh(float2(0.05, 0.015), MipLevel));  // Top Left Corner
	        int Top_Right     = LBSensitivity(SLLTresh(float2(0.95, 0.015), MipLevel));  // Top Right Corner
	        float Center      = SLLTresh(float2(0.5, 0.5), Letter_Box_Center_Mips_Level_Senstivity) > 0;  // Center
	        int Bottom_Left   = LBSensitivity(SLLTresh(float2(0.05, 0.985), MipLevel));  // Bottom Left Corner
	        int Bottom_Right  = LBSensitivity(SLLTresh(float2(0.95, 0.985), MipLevel));  // Bottom Right Corner
	        
	        return (Top_Left && Top_Right) && Center && (Bottom_Left && Bottom_Right);
	    #elif LB_Correction == 5 || LBC == 5 || LetterBox_Masking == 5 || LBM == 5 || LB_Correction == 6 || LBC == 6 || LetterBox_Masking == 6 || LBM == 6
	        //=======================================================================
	        // HORIZONTAL & VERTICAL MODE (4-Point Detection)
	        //=======================================================================
	        float MipLevel = 5;
	        
	        // Detection Points:
	        int Top_Left      = LBSensitivity(SLLTresh(float2(0.05, 0.015), MipLevel));  // Top Left Corner
	        int Top_Right     = LBSensitivity(SLLTresh(float2(0.95, 0.015), MipLevel));  // Top Right Corner
	        float Center      = SLLTresh(float2(0.5, 0.5), Letter_Box_Center_Mips_Level_Senstivity) > 0;  // Center	        
	        #if LB_Correction == 5 || LBC == 5 || LetterBox_Masking == 5 || LBM == 5
	        int Bottom_Left   = LBSensitivity(SLLTresh(float2(0.05, 0.985), MipLevel));  // Bottom Left Corner
	        	return (Top_Left && Top_Right) && Center && Bottom_Left;	
	        #endif    
	        #if LB_Correction == 6 || LBC == 6 || LetterBox_Masking == 6 || LBM == 6
	        int Bottom_Right  = LBSensitivity(SLLTresh(float2(0.95, 0.985), MipLevel));  // Bottom Right Corner
	        	return (Top_Left && Top_Right) && Center && Bottom_Right;	        
	        #endif
	    #else
	        //=======================================================================
	        // STANDARD MODE (3-Point Detection)
	        //=======================================================================
	        
	        // Letter Box Elevation Settings (Y-axis adjustment):
	        //   LBE == 0: (0.09, 0.91)   - Standard
	        //   LBE == 1: (0.045, 0.955) - Elevated
	        //   LBE == 2: (0.035, 0.965) - Maximum Elevation
	        float2 Letter_Box_Elevation = LBE ? (LBE == 2 ? float2(0.035, 0.965) : float2(0.045, 0.955)) : float2(0.09, 0.91);
	        
	        float MipLevel = 5;
	        float Center = SLLTresh(float2(0.5, 0.5), Letter_Box_Center_Mips_Level_Senstivity) > 0;

	        float Top_Pos_A = LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.x, Letter_Box_Elevation.x), MipLevel));
	        float Bottom_Pos_A = LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.y, Letter_Box_Elevation.y), MipLevel));

	        float Top_Pos_B = LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.x + 0.05, Letter_Box_Elevation.x), MipLevel));
	        float Bottom_Pos_B = LBSensitivity(SLLTresh(float2(Letter_Box_Reposition.y - 0.05, Letter_Box_Elevation.y), MipLevel));

	        if (LetterBox_Masking == 2 || LB_Correction == 2 || LBC == 2 || LBM == 2 || SMP == 2)
	        {
	            //===================================================================
	            // VERTICAL MODE (3-Point Detection)
	            //===================================================================
	            // Detection Points:
	            //   Left Center:   (0.100, 0.5)
	            //   Right Center:  (0.900, 0.5)
	            //   Center:        (0.5, 0.5)
	            return LBSensitivity(SLLTresh(float2(0.100, 0.5), MipLevel)) &&
	                   LBSensitivity(SLLTresh(float2(0.900, 0.5), MipLevel)) &&
	                   Center;
	        }
	        else
	        {
	            //===================================================================
	            // HORIZONTAL MODE (3-Point Detection)
	            //===================================================================
	            // Detection Points:
	            //   Top:    (Letter_Box_Reposition.x, Letter_Box_Elevation.x)
	            //   Bottom: (Letter_Box_Reposition.y, Letter_Box_Elevation.y)
	            //   Center: (0.5, 0.5)
	            return (Top_Pos_A && Top_Pos_B) &&
	                   (Bottom_Pos_A && Bottom_Pos_B) &&
				   Center;
	        }
	    #endif
	}
	#else
	int LBDetection()//Stand in, so it does not crash when not in use.
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
	{	
		#if AR_Is == 2  // 16:10
		    Pos_IN.y = 0.5 + (Pos_IN.y - 0.5) * 0.9;  // 9/10
		#endif
		float3 RGB_IN = C_Tresh(Pos_IN);
		return RN_Value(RGB_IN.r + RGB_IN.g + RGB_IN.b) == C_Value;
	}
	
		#if SDT || SD_Trigger	
		float SDT_Lock_Menu_Detection()//Active RGB Detection
		{ 
			float2 Pos_A = DKK_X.xy, Pos_B = DKK_X.zw, Pos_C = DKK_Y.xy;
			float4 ST_Values = DKK_Z;
	
			//Wild card, always on.
			float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
			float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
			
			float Menu_Detection = Menu_X &&                          //X & W are wild cards.
								   Check_Color(Pos_B, ST_Values.y) && //Y
								   Menu_Z;                            //Z & W are wild cards.
	
			return !(Menu_Detection > 0);
		}
		#endif
	
		#if LMD //Text Menu Detection One
		float Lock_Menu_Detection()//Active RGB Detection
		{ 
			float Menu_Detection_0, Menu_Detection_1;
			float2 Pos_A_0 = DCC_X.xy, Pos_B_0 = DCC_X.zw, Pos_C_0 = DCC_Y.xy;
			float4 ST_Values_0 = DCC_Z;
	
			//Wild card, always on.
			float Menu_X_0 = Check_Color(Pos_A_0, ST_Values_0.x) || Check_Color(Pos_A_0, ST_Values_0.w);
	
			float Menu_Z_0 = Check_Color(Pos_C_0, ST_Values_0.z) || Check_Color(Pos_C_0, ST_Values_0.w);
			
			Menu_Detection_0 = Menu_X_0 &&                          //X & W are wild cards.
							   Check_Color(Pos_B_0, ST_Values_0.y) && //Y
							   Menu_Z_0;                            //Z & W are wild cards.
								   
			#if LMD > 1 //Text Menu Detection Two
				float2 Pos_A_1 = DMM_X.xy, Pos_B_1 = DMM_X.zw, Pos_C_1 = DMM_Y.xy;
				float4 ST_Values_1 = DMM_Z;
		
				//Wild card, always on.
				float Menu_X_1 = Check_Color(Pos_A_1, ST_Values_1.x) || Check_Color(Pos_A_1, ST_Values_1.w);
		
				float Menu_Z_1 = Check_Color(Pos_C_1, ST_Values_1.z) || Check_Color(Pos_C_1, ST_Values_1.w);
				
				Menu_Detection_1 = Menu_X_1 &&                          //X & W are wild cards.
								   Check_Color(Pos_B_1, ST_Values_1.y) && //Y
								   Menu_Z_1;                            //Z & W are wild cards.
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
			//Wild card, always on.
			float Menu_X = Check_Color(Pos_A, MT_Values.x) || Check_Color(Pos_A, MT_Values.w); 
			float Menu_Z = Check_Color(Pos_C, MT_Values.z) || Check_Color(Pos_C, MT_Values.w);
			
			float Menu_Detection = Menu_X &&                                //X & W are wild cards.
				   				Check_Color(Pos_B, MT_Values.y) &&       //Y
				  				 Menu_Z,                                  //Z & W are wild cards.
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
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
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
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
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
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
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
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
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
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
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
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards. 
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
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
		
				//Wild card, always on.
				float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);

				float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
				
				float Menu_Detection = Menu_X &&                          //X & W are wild cards. 
									   Check_Color(Pos_B, ST_Values.y) && //Y
									   Menu_Z;                            //Z & W are wild cards.
		
				return (Menu_Detection > 0) && Lock_Menu_Detection();
			}
				#if SMD >= 2
				float Simple_Menu_B()//Active RGB Detection
				{ 
					float2 Pos_A = DT_X.xy, Pos_B = DT_X.zw, Pos_C = DT_Y.xy;
					float4 ST_Values = DW_W;
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards.
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
					return (Menu_Detection > 0) && Lock_Menu_Detection();
				}
				#endif

					#if SMD >= 3
					float Simple_Menu_C()//Active RGB Detection
					{ 
						float2 Pos_A = DAA_X.xy, Pos_B = DAA_X.zw, Pos_C = DAA_Y.xy;
						float4 ST_Values = DAA_Z;
				
						//Wild card, always on.
						float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
		
						float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
						
						float Menu_Detection = Menu_X &&                          //X & W are wild cards.
											   Check_Color(Pos_B, ST_Values.y) && //Y
											   Menu_Z;                            //Z & W are wild cards.
				
						return (Menu_Detection > 0) && Lock_Menu_Detection();
					}
					#endif
				
						#if SMD >= 4
						float Simple_Menu_D()//Active RGB Detection
						{ 
							float2 Pos_A = DBB_X.xy, Pos_B = DBB_X.zw, Pos_C = DBB_Y.xy;
							float4 ST_Values = DBB_Z;
					
							//Wild card, always on.
							float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
			
							float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
							
							float Menu_Detection = Menu_X &&                          //X & W are wild cards.
												   Check_Color(Pos_B, ST_Values.y) && //Y
												   Menu_Z;                            //Z & W are wild cards.
					
							return (Menu_Detection > 0) && Lock_Menu_Detection();
						}
						#endif
						
							#if SMD >= 5
							float Simple_Menu_E()//Active RGB Detection
							{ 
								float2 Pos_A = DHH_X.xy, Pos_B = DHH_X.zw, Pos_C = DHH_Y.xy;
								float4 ST_Values = DHH_Z;
						
								//Wild card, always on.
								float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
				
								float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
								
								float Menu_Detection = Menu_X &&                          //X & W are wild cards.
													   Check_Color(Pos_B, ST_Values.y) && //Y
													   Menu_Z;                            //Z & W are wild cards.
						
								return (Menu_Detection > 0) && Lock_Menu_Detection();
							}
							#endif
							
								#if SMD >= 6
								float Simple_Menu_F()//Active RGB Detection
								{ 
									float2 Pos_A = DII_X.xy, Pos_B = DII_X.zw, Pos_C = DII_Y.xy;
									float4 ST_Values = DII_Z;
							
									//Wild card, always on.
									float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
					
									float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
									
									float Menu_Detection = Menu_X &&                          //X & W are wild cards.
														   Check_Color(Pos_B, ST_Values.y) && //Y
														   Menu_Z;                            //Z & W are wild cards.
							
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
			
					//Wild card, always on.
					float Menu_X = Check_Color(Pos_A, ST_Values.x) || Check_Color(Pos_A, ST_Values.w);
	
					float Menu_Z = Check_Color(Pos_C, ST_Values.z) || Check_Color(Pos_C, ST_Values.w);
					
					float Menu_Detection = Menu_X &&                          //X & W are wild cards.
										   Check_Color(Pos_B, ST_Values.y) && //Y
										   Menu_Z;                            //Z & W are wild cards.
			
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

	float2 EdgeDetectionC(sampler Tex, float2 TC, float2 offset)
	{
	    float Left = tex2D(Tex, TC - float2(offset.x, 0)).w;
	    float Right = tex2D(Tex, TC + float2(offset.x, 0)).w;
	    float Up = tex2D(Tex, TC - float2(0, offset.y)).w;
	    float Down = tex2D(Tex, TC + float2(0, offset.y)).w;
	
	    return float2(Down - Up, Right - Left);
	}

	float2 EdgeDetectionD(sampler Tex, float2 TC, float2 offset)
	{
	    float value = tex2D(Tex, TC).x * 2 - 1;
	    #if Compatibility_02
	    float dx = ddx(value);
	    float dy = ddy(value);
	    #else
	    float dx = ddx_fine(value);
	    float dy = ddy_fine(value);
	    #endif
	    return float2(dy, dx);
	}
	/*
	float4 EdgeMask(float4 color, float2 texcoords, float Adjust_Value)
	{	
		float2 center = float2(0.5,texcoords.y); // Direction of effect.   
		float BaseVal = 1.0,
			  Dist  = distance( center, texcoords ) * 2.0, 
			  EdgeMask = clamp((BaseVal-Dist) / (BaseVal-Adjust_Value),0.125,1); 
	    return color * EdgeMask;    
	}
	*/
	float DepthEdge(float Mod_Depth, float Depth, float2 texcoords, float Adjust_Value )
	{
		Adjust_Value -= FLT_EPSILON;
		float2 center = float2(0.5,texcoords.y); // Direction of effect.   
		float BaseVal = 1.0,
			  Dist  = distance( center, texcoords ) * 2.0, 
			  EdgeMask = saturate((BaseVal-Dist) / (BaseVal-Adjust_Value)),
			  Set_Weapon_Scale_Near = -min(0.5,Weapon_Depth_Edge.y);//So it doesn't hang the game.
		float Scale_Depth = lerp(1+(Weapon_Depth_Edge.z*4),0,saturate(Depth * 2));
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
	{
		float2 BTC = abs(TC)-(size * 0.25);
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

	float3 regamma(float3 c)
	{
		return float3(pow(abs(c.r),1.0/2.2), pow(abs(c.g),1.0/2.2), pow(abs(c.b),1.0/2.2));
	}

	// Cursor Color Array //
	static const float3 CCArray[11] = {
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
	#if MEM_INFILL
	//Remembered background. A and B swap every frame, so no copy pass.
	//Mem: colour + depth. Age: seconds covered.
	texture texMemA { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = RGBA16F; };
	texture texMemB { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = RGBA16F; };
	texture texAgeA { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = R16F; };
	texture texAgeB { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = R16F; };
	sampler Sampler_MemA { Texture = texMemA; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	sampler Sampler_MemB { Texture = texMemB; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	sampler Sampler_MemAL { Texture = texMemA; };//Linear, for the colour read.
	sampler Sampler_MemBL { Texture = texMemB; };
	sampler Sampler_AgeA { Texture = texAgeA; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	sampler Sampler_AgeB { Texture = texAgeB; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	//The set written this frame. _L is filtered.
	float3 Mem_Now_L(float2 uv)
	{
		[branch]
		if(Frames % 2 == 0)
			return tex2Dlod(Sampler_MemAL, float4(uv, 0, 0)).rgb;
		return tex2Dlod(Sampler_MemBL, float4(uv, 0, 0)).rgb;
	}
	float4 Mem_Now(float2 uv)
	{
		[branch]
		if(Frames % 2 == 0)
			return tex2Dlod(Sampler_MemA, float4(uv, 0, 0));
		return tex2Dlod(Sampler_MemB, float4(uv, 0, 0));
	}
	float Age_Now(float2 uv)
	{
		[branch]
		if(Frames % 2 == 0)
			return tex2Dlod(Sampler_AgeA, float4(uv, 0, 0)).x;
		return tex2Dlod(Sampler_AgeB, float4(uv, 0, 0)).x;
	}
	//From the Depth3D Motion add-on: .xy = motion in UV (previous = uv - .xy).
	texture MotionVectorsTex : MOTIONVECTORS;
	sampler Sampler_MV { Texture = MotionVectorsTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	//The add-on's fitted camera (texel 3: state, share, model, focal).
	texture MotionCameraTex : MOTIONCAMERA;
	sampler Sampler_MCam { Texture = MotionCameraTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

	//Motion trust from the camera's state: 1 fresh, 0.5 held, 0 none.
	float Cam_Trust()
	{
		float S = tex2Dfetch(Sampler_MCam, int2(3, 0)).x;
		return S > 0.99 ? 1.0 : S > 0.5 ? 0.5 : 0.0;
	}
	//Camera motion for a point at depth D. Ok is false without a camera.
	float2 Cam_Motion_Depth(float2 uv, float D, out bool Ok)
	{
		float4 S = tex2Dfetch(Sampler_MCam, int2(3, 0));
		float4 A = tex2Dfetch(Sampler_MCam, int2(0, 0)), B = tex2Dfetch(Sampler_MCam, int2(1, 0)), C = tex2Dfetch(Sampler_MCam, int2(2, 0));
		float2 P = float2(uv.x * 2.0 - 1.0, (uv.y * 2.0 - 1.0) * BUFFER_HEIGHT * BUFFER_RCP_WIDTH);
		float  q = rcp(max(D, 0.005));
		float2 Mo = 0.0;
		Ok = S.x > 0.5;
		if(S.z > 8.0)
		{
			//Exact: prev = (H p + e q) / (H2 p + e2 q)
			float Den = B.z * P.x + B.w * P.y + 1.0 + C.z * q;
			Ok = Ok && abs(Den) > 1e-4;
			Mo = P - float2(A.x * P.x + A.y * P.y + A.z + C.x * q, A.w * P.x + B.x * P.y + B.y + C.y * q) / (Ok ? Den : 1.0);
		}
		else
		{
			//D3D9's small motion model, in focal units.
			float2 X = P / max(S.w, 1e-4);
			Mo = float2(X.x * X.y * A.x - (1.0 + X.x * X.x) * A.y + X.y * A.z + (-A.w + X.x * B.y) * q,
			            (1.0 + X.y * X.y) * A.x - X.x * X.y * A.y - X.x * A.z + (-B.x + X.y * B.y) * q) * S.w;
		}
		return Mo * float2(0.5, 0.5 * BUFFER_WIDTH * BUFFER_RCP_HEIGHT);
	}

	//YCoCg clamps reject stale colour more cleanly than RGB.
	float3 RGB_YCoCg(float3 c)
	{
		return float3(dot(c, float3(0.25, 0.5, 0.25)), dot(c, float3(0.5, 0.0, -0.5)), dot(c, float3(-0.25, 0.5, -0.25)));
	}
	float3 YCoCg_RGB(float3 c)
	{
		return float3(c.x + c.y - c.z, c.x + c.z, c.x - c.y - c.z);
	}
	//Clip toward the box centre (Playdead INSIDE TAA), so the hue holds.
	float3 Clip_Box(float3 q, float3 Centre, float3 Ext)
	{
		float3 v = q - Centre;
		float3 a = abs(v * rcp(max(Ext, 0.00001)));
		float  m = max(a.x, max(a.y, a.z));
		return m > 1.0 ? Centre + v * rcp(m) : q;
	}
	#endif

	//VM0_Pack: VM0's line shift and weight (1 or more), or the Memory Infill offset (under 0.1). 0 when none.
	float4 MouseCursorS(float3 texcoord , float VM0_Pack, float2 pos, int Switch,int UI_Mode )
	{ 
			//DX9 fails without tex2Dlod here.
			float4 Out = UI_Mode ? tex2Dlod(Live_Sampler,float4(texcoord.xy,0,0)) : CSB(texcoord.xy),Color, Exp_Darks, Exp_Brights; //UI_Mode runs after StereoOut (REST), so read the live back buffer.
			#if MEM_INFILL
			//Memory Infill: w under 0.1 is a memory offset.
			[branch]
			if(VM0_Pack != 0.0 && abs(VM0_Pack) < 0.1 && !UI_Mode)
			{
				float  Mem_Off = VM0_Pack;
				//The blur mask's green: the gap past Mask Cut, rising from the hole's outer edge to full Infill Soft Px in (the
				//offset to the hidden spot is that distance). Red is outside the mask, never touched.
				float  Gap  = saturate((saturate(texcoord.z) - Infill_Mask_Cut) * rcp(1.0 - Infill_Mask_Cut + 0.001));
				float  Fall = Gap * saturate(abs(Mem_Off) * rcp(Infill_Soft_Px * pix.x));
				float3 Mem  = Mem_Now_L(float2(texcoord.x + Mem_Off, texcoord.y));
				//The background side: the farther depth 10 px out.
				float  Bm = (tex2Dlod(SamplerzBufferN_P, float4(texcoord.x - 10.0 * pix.x, texcoord.y, 0, 0)).x >=
				             tex2Dlod(SamplerzBufferN_P, float4(texcoord.x + 10.0 * pix.x, texcoord.y, 0, 0)).x ? -1.0 : 1.0) * pix.x;
				//Clamp to the background beside the hole, like TAA history.
				float  Bg = Bm * BUFFER_WIDTH;//Same background side.
				float3 N0 = CSB(texcoord.xy + float2(0.0,  2.0 * pix.y)).rgb, N1 = CSB(texcoord.xy - float2(0.0, 2.0 * pix.y)).rgb;
				float3 N2 = CSB(texcoord.xy + float2(Bg * 2.0 * pix.x, 0.0)).rgb, N3 = CSB(texcoord.xy + float2(Bg * 4.0 * pix.x, 0.0)).rgb;
				float3 Y0 = RGB_YCoCg(N0), Y1 = RGB_YCoCg(N1), Y2 = RGB_YCoCg(N2), Y3 = RGB_YCoCg(N3), Yo = RGB_YCoCg(Out.rgb);
				float3 M1 = (Y0 + Y1 + Y2 + Y3 + Yo) * 0.2;
				float3 M2 = (Y0 * Y0 + Y1 * Y1 + Y2 * Y2 + Y3 * Y3 + Yo * Yo) * 0.2;
				float3 Sig = sqrt(max(M2 - M1 * M1, 0.0)) * 2.0;
				Mem = YCoCg_RGB(Clip_Box(RGB_YCoCg(Mem), M1, Sig));
				//Even strength: only the gap's falloff and Memory Strength.
				Fall = saturate(Fall * Memory_Strength);//Capped: past 1 the blend overshoots.
				Out.rgb = lerp(Out.rgb, Mem, Fall);
			}
			#endif

			//VM0 Structure.
			float VM0_Ln  = VM0_Pack;
			[branch]
			if(View_Mode == 0 && texcoord.z > 0 && VM0_Ln >= 1.0 && !UI_Mode)//Packed lines are 1 or more.
			{
				//Unpack Parallax's line shift (quarter pixels) and line weight (16 steps).
				float Pk_L       = floor(VM0_Ln * rcp(2048.0));
				float Line_Shift = (VM0_Ln - Pk_L * 2048.0 - 1024.0) * 0.25 * pix.y;
				float3 Sc = CSB(texcoord.xy - float2(0.0, Line_Shift)).rgb;
				//Colour check.
				float  Gd = dot(abs(Out.rgb - Sc) * rcp(abs(Sc) + 0.25), float3(0.3333, 0.3333, 0.3333));
				//Stricter one way.
				bool   Dk = dot(Out.rgb - Sc, float3(0.299, 0.587, 0.114)) < 0.0;
				float  Gw = Dk ? saturate((0.2 - Gd) * rcp(0.15)) : saturate(1.4 - 4.0 * Gd);
				Out.rgb = lerp(Sc, Out.rgb, saturate(texcoord.z * 10.0) * Pk_L * rcp(15.0) * Gw);
			}
			//texcoord.z is the gap flag from Parallax. Amt past 0.375 leaks the occluder.
			const float Blur_Amt = 0.4, Blur_Reach_Px = 16.0, Blur_Guard = 1.0;
			//Bleed zone. Bleed_Px 14 is the ceiling, wider reaches unrelated geometry.
			const float Bleed_Str = 0.45, Bleed_Px = 14.0, Bleed_Reach = 0.5, Edge_Dead = 0.02, Edge_Gain = 5.0;
			const float Slope_Tol = 1.6, Step_Gain = 8.0;
			[branch]
			//Stamped is left alone. Reiteration takes the dithered path below.
			if(Infill_Blur > 0 && View_Mode != 3 && !UI_Mode && (!POST_INFILL_OK || Infill_Blur_Debug) && (texcoord.z > 0 || !VM_Infill_Dither))
			{
			    float B = (texcoord.z > 0 ? texcoord.z : Bleed_Reach) * pix.x * Blur_Amt * Blur_Reach_Px;
			    //Interleaved Gradient Noise. The deband's hash clumps and reads as blotchy.
			    float Jit = Interleaved_Gradient_Noise(floor(pos)) * 2.0 - 1.0;
			    #if !Use_2D_Plus_Depth //View_Mode is a constant there.
			    [branch]
			    #endif
			    if(VM_Infill_Dither)
			    {
			        //Scatter, not average: one tap at a noise offset. Depth tested. Averaging smears the centre.
			        float2 Td_TC = texcoord.xy + float2(B * Jit, 0);
			        float  Dc = tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy, 0, 0)).x;
			        float  Dt = tex2Dlod(SamplerzBufferN_P, float4(Td_TC,       0, 0)).x;
			        const float Dither_Tol = 0.02;
			        //Colour guard on top of the depth test. A tap has to pass both.
			        float4 Td = CSB(Td_TC);
			        float  Wd = dot(abs(Td.rgb - Out.rgb) * rcp(abs(Out.rgb) + 0.25),
			                        float3(0.3333, 0.3333, 0.3333)) * Blur_Guard;
			        bool   Ok = Dt >= Dc - Dither_Tol && Wd < 1.0;
			        //VM4.
			        [branch]
			        if(View_Mode == 4 && !Ok)
			        {
			            float  Jit2 = Interleaved_Gradient_Noise(floor(pos) + 13.0) * 2.0 - 1.0;
			            float2 T2_TC = texcoord.xy + float2(B * Jit2, 0);
			            float4 T2 = CSB(T2_TC);
			            Ok = tex2Dlod(SamplerzBufferN_P, float4(T2_TC, 0, 0)).x >= Dc - Dither_Tol
			              && dot(abs(T2.rgb - Out.rgb) * rcp(abs(Out.rgb) + 0.25), float3(0.3333, 0.3333, 0.3333)) * Blur_Guard < 1.0;
			            Td = T2;
			        }
			        if(!POST_INFILL_OK)
			            Out = Ok ? Td : Out;
			    }
			    else
			    {
			        //Cut off then rescale, so a strong mask keeps full strength.
			        float Gap = saturate((saturate(texcoord.z) - Infill_Mask_Cut) * rcp(1.0 - Infill_Mask_Cut + 0.001));
			        float2 Bd = float2(Bleed_Px * pix.x, 0);
			        float Dc = tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy,      0, 0)).x;
			        float Dl = tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy - Bd, 0, 0)).x;
			        float Dr = tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy + Bd, 0, 0)).x;
			        //Which side of the edge we sit on. Far means background, the half that may bleed.
			        float Dw   = abs(Dr - Dl);
			        float Edge = saturate((Dw * rcp(min(Dr, Dl) + 0.01) - Edge_Dead) * Edge_Gain);
			        float E    = Edge * saturate(1.0 + (Dc - max(Dl, Dr)) * 100.0);
			        float En   = Edge * saturate((max(Dl, Dr) - Dc) * 100.0);
			        //Distance to that edge as a fraction of Bleed_Px. 1.0 means not found.
			        float DistF = 1.0, DistN = 1.0;
			        [branch]
			        if((Gap == 0 && E > 0.002) || (Gap > 0 && En > 0.002))
			        {
			            //The narrowest reach that still brackets the edge IS the distance.
			            SD_UNROLL
			            for(int k = 1; k <= 3; k++)
			            {
			                //Squared spacing, jittered, or three reaches read as three bands.
			                float  Fk = saturate((k + Jit * 0.5) * 0.25); Fk *= Fk;
			                float2 Bk = Bd * Fk;
			                float  Da = tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy - Bk, 0, 0)).x;
			                float  Db = tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy + Bk, 0, 0)).x;
			                //A step holds its size at any reach that straddles it, a surface shrinks.
			                float  Dif = abs(Db - Da);
			                float  Ek  = saturate((Dif * rcp(min(Da, Db) + 0.01) - Edge_Dead) * Edge_Gain)
			                           * saturate((Dif * rcp(Dw + 0.0001) - Fk * Slope_Tol) * Step_Gain);
			                DistF = min(DistF, lerp(1.0, Fk, Ek * saturate(1.0 + (Dc - max(Da, Db)) * 100.0)));
			                DistN = min(DistN, lerp(1.0, Fk, Ek * saturate((max(Da, Db) - Dc) * 100.0)));
			            }
			        }
			        //Both halves meet at Bleed_Str, so there is no step between them.
			        float Ramp = Gap > 0 ? lerp(Bleed_Str, 1.0, pow(min(smoothstep(0.0, 1.0, DistN), Gap), Infill_Feather)) * Gap
			                             : Bleed_Str * pow(smoothstep(0.0, 1.0, 1.0 - DistF), Infill_Feather);
			        //Alpha UI: the bleed zone has no gap mask, so check the UI here. No [branch]: Alpha_Channel_UI can be static.
			        if(Alpha_Channel_UI && Gap <= 0 && Ramp > 0.002)
			            Ramp *= tex2Dlod(SamplerCN, float4(texcoord.xy, 0, 2)).y > (Isolate_UI ? 0.41 : 0.999);
			        B = max(Ramp, Bleed_Reach) * pix.x * Blur_Amt * Blur_Reach_Px;
			        [branch]
			        if(Ramp > 0.002)
			        {
			            min16float3 RcpC = rcp(abs(Out.rgb) + 0.25);//Once, not per tap. Colour maths in half precision.
			            const min16float3 Third = min16float3(0.3333, 0.3333, 0.3333);
			            min16float4 Acc = Out;
			            min16float  Wsum = 1.0;
			            min16float  L_Min = dot(saturate(Out.rgb), float3(0.2126, 0.7152, 0.0722)), L_Max = L_Min;
			            SD_UNROLL
			            for(int b = 1; b <= 4; b++)
			            {
			                float2 O  = float2(B * (b * 0.25), 0);
			                min16float4 Ta = CSB(texcoord.xy + O);
			                min16float4 Tb = CSB(texcoord.xy - O);
			                min16float  Wf = 1.0 - b * 0.2;
			                min16float  Wa = Wf * saturate(1.0 - dot(abs(Ta.rgb - Out.rgb) * RcpC, Third) * Blur_Guard);
			                min16float  Wb = Wf * saturate(1.0 - dot(abs(Tb.rgb - Out.rgb) * RcpC, Third) * Blur_Guard);
			                //Depth gate.
			                Wa *= tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy + O, 0, 0)).x >= Dc - 0.02;
			                Wb *= tex2Dlod(SamplerzBufferN_P, float4(texcoord.xy - O, 0, 0)).x >= Dc - 0.02;
			                Acc  += Ta * Wa + Tb * Wb;
			                Wsum += Wa + Wb;
			                if(b <= 2)
			                {
			                    min16float2 Lab = min16float2(dot(saturate(Ta.rgb), float3(0.2126, 0.7152, 0.0722)), dot(saturate(Tb.rgb), float3(0.2126, 0.7152, 0.0722)));
			                    L_Min = min(L_Min, min(Lab.x, Lab.y)); L_Max = max(L_Max, max(Lab.x, Lab.y));
			                }
			            }
			            //Post pass modes get the marker only, the image is blurred there.
			            [branch]
			            if(!POST_INFILL_OK)
			            {
			                //Falloff off degrades half as much.
			                float Str = (Infill_Falloff || Gap <= 0) ? Ramp : lerp(Gap, Ramp, 0.5);
			                float Mix = saturate(Str * Infill_Guide(Out.rgb, L_Min, L_Max));
			                Out = lerp(Out, Acc * rcp(Wsum), Mix);
			            }
			            [branch]
			            if(Infill_Blur_Debug)
			                //Green is left to the post pass: drawing both here leaves flat green where they disagree.
			                Out.rgb = lerp(Out.rgb, Gap > 0 ? float3(0.0, 1.0, 0.0) : float3(0.0, 0.0, 1.0),
			                               Gap > 0 ? (POST_INFILL_OK ? 0.0 : Ramp)
			                                       : saturate(Ramp * rcp(Bleed_Str)));
			        }
			    }
			}
			//Near/far wall. Drawn here since texcoord.xy is the source coordinate, so it lines up.
			[branch]
			if(Show_Near_Far && !UI_Mode)
			{
				float  Nb   = Depth_Blend(smoothstep(0, 1, tex2Dlod(SamplerDMN, float4(texcoord.xy, 0, 0.0)).x));
				float3 Wall = lerp(float3(1.0, 0.1, 0.0), float3(0.0, 0.3, 1.0), Nb);
				//Green is the blend between the two, not a midpoint line.
				Out.rgb = lerp(lerp(Out.rgb, Wall, 0.85), float3(0.0, 1.0, 0.0), 4.0 * Nb * (1.0 - Nb));
			}
			float Cursor;
			if(Cursor_Type > 0 && Switch)
			{
				float CCScale = lerp(0.005,0.025,Scale(Cursor_SC.x,10,0));//Scaling
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
						Cursor = CCRetical( MousecoordsXY.xy, Scale_Cursor  * 0.75 ) > 0.0;
					else if (Cursor_Type == 2)
						Cursor = -CCCBox( MousecoordsXY.xy, CCScale * 0.375 ) > 0.0;
					else if (Cursor_Type == 3)
						Cursor = -CCBox( MousecoordsXY.xy, CCScale * 0.25 ) > 0.0;	
					else if (Cursor_Type == 4)
						Cursor = -CCCross( MousecoordsXY.xy, Scale_Cursor  * 0.75  ) > 0.0;			
					else if (Cursor_Type == 5)
						Cursor = -CCCursor( MousecoordsXY.xy, Scale_Cursor  * 0.5  ) > 0.0;
				}
	
					int CSTT = clamp(Cursor_SC.y,0,10);
				Color.rgb = CCArray[CSTT];
			}
		#if Enable_Deband_Mode
			if(Toggle_Deband)
			{
				//Code I asked Marty McFly | Pascal for, and he let me use.
				const float SEARCH_RADIUS = 1, Depth_Sample = tex2Dlod(SamplerzBufferN_P,float4(texcoord.xy,0,0)).x < 0.98;
				const float2 magicdot = float2(0.75487766624669276, 0.569840290998);
				const float3 magicadd = float3(0, 0.025, 0.0125) * dot(magicdot, 1);
				float3 dither = frac(dot(pos.xy, magicdot) + magicadd);
				
				//LinearSampleDepth
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
	float4 MouseCursor(float3 texcoord , float2 pos, int Switch,int UI_Mode )
	{
		return MouseCursorS(texcoord, 0.0, pos, Switch, UI_Mode);
	}
	
	#if AR_Is == 2
	int ARSensitivity( float inVal )
	{
		#if ARS
			#if ARS == 2
			return inVal < 0.0225; //Least Sensitive
			#else
			return inVal < 0.005; //Less Sensitive
			#endif
		#else
			return inVal == 0; //Sensitive
		#endif
	}	

	int ARDetection()//Active RGB Detection
	{   int Letter_Box_Center_Mips_Level_Senstivity = 7;   
		float2 AR_position = float2(0.5,0.125);
		float2 AR_Elevation =  float2(0.025,0.975);    
		
		float MipLevel = 4,Center = SLLTresh(float2(0.5,0.5), Letter_Box_Center_Mips_Level_Senstivity) > 0, 
			  Top_Pos = ARSensitivity(SLLTresh(float2(AR_position.x,AR_Elevation.x), MipLevel)),
			  Bottom_Pos = ARSensitivity(SLLTresh(float2(AR_position.y,AR_Elevation.y), MipLevel));

			return Top_Pos && Center && Bottom_Pos;
	}

	int SideBarDetection()//Left & Right Bar Detection for Side Scaling Mode
	{   int Side_Bar_Center_Mips_Level_Senstivity = 7;
		float2 SB_Position = float2(0.025,0.975);
		float3 SB_Elevation = float3(0.25,0.5,0.75);

		float MipLevel = 4, Center = SLLTresh(float2(0.5,0.5), Side_Bar_Center_Mips_Level_Senstivity) > 0,
			  Left_Pos  = ARSensitivity(SLLTresh(float2(SB_Position.x,SB_Elevation.x), MipLevel)) && ARSensitivity(SLLTresh(float2(SB_Position.x,SB_Elevation.y), MipLevel)) && ARSensitivity(SLLTresh(float2(SB_Position.x,SB_Elevation.z), MipLevel)),
			  Right_Pos = ARSensitivity(SLLTresh(float2(SB_Position.y,SB_Elevation.x), MipLevel)) && ARSensitivity(SLLTresh(float2(SB_Position.y,SB_Elevation.y), MipLevel)) && ARSensitivity(SLLTresh(float2(SB_Position.y,SB_Elevation.z), MipLevel));

			return Left_Pos && Center && Right_Pos;
	}

	float calculateAROffset(float screenHeight, float lossPercentage)
	{
	    float width16_10 = screenHeight * 16.0 / 10.0;
	    float height16_9 = width16_10 * 9.0 / 16.0;
	    float baseOffset = (screenHeight - height16_9) / 2.0;
	    
    	return round(baseOffset * (1.0 - lossPercentage / 100.0));
	}	

	float scaleFromCenter(float texCoordY, float screenHeight, float scalePercentage)
	{
	    float width16_10 = screenHeight * 16.0 / 10.0;
	    float height16_9 = width16_10 * 9.0 / 16.0;
	    float baseScale = height16_9 / screenHeight; 
	    // An assumption, since I don't have the hardware.
	    // Inverted: lower percentage = smaller scale
	    float scale = (100.0 - scalePercentage) / 100.0 + baseScale;
	    
	    return (texCoordY - 0.5) * scale + 0.5;
	}

	float2 AR_Correct_TC(float2 texcoord)
	{
		float2 Shift_TC = texcoord;
		float Pix_Offset = calculateAROffset(Res.y,3.0) * pix.y;//2.5-3.75

		if(ARDetection())
		{
			if(!Disable_CO && Depth_Map_View == 0)
			{
				if(Scale_FC_Mode)
					Shift_TC.y =  scaleFromCenter( Shift_TC.y, Res.y, 79);
				else
				{
		            if(Shift_Up_Mode)
		            {
		            	Pix_Offset *= 1.62; // Tuned by eye
		                if (Shift_TC.y + Pix_Offset < 1)
		                    Shift_TC.y = Shift_TC.y + Pix_Offset; // shift UP
		                else
		                    Shift_TC.y = 1;
		            }
		            else
		            {
		                if(Shift_TC.y > Pix_Offset)
		                    Shift_TC.y = Shift_TC.y - Pix_Offset; // shift DOWN
		                else
		                    Shift_TC.y = 1; //Look at later: top rows sent to the bottom, 0 may be meant.
		            }
				}
			}
		}
		return Shift_TC;
	}
	#endif
	//////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////

	float DMA() //Small list of internal multi game depth adjustments.
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
	    // Scaling factor: Current_Size / Starting_Size
 	   float2 scaleFactor_XY = Current_Size.xy / Starting_Size.xy;
	    return scaleFactor_XY;
	}
	
	//Nearest of 4 taps over the texel, so a smaller buffer cannot miss a thin object.
	float Near_Tap(float2 tc)
	{
	    float2 Tb = float2(rcp(BUFFER_WIDTH * Depth_Rez), rcp(BUFFER_HEIGHT * Depth_Rez));
	    //The centre read only where the 4 taps do not replace it.
	    float z;
	    [branch]
	    if(!any(rcp(tex2Dsize(DepthBuffer)) < Tb))
	        z = tex2Dlod(DepthBuffer, float4(tc, 0, 0)).x;
	    else
	    {
	        float2 o = 0.25 * Tb;
	        float4 q = float4(tex2Dlod(DepthBuffer, float4(tc + float2(-o.x, -o.y), 0, 0)).x,
	                          tex2Dlod(DepthBuffer, float4(tc + float2( o.x, -o.y), 0, 0)).x,
	                          tex2Dlod(DepthBuffer, float4(tc + float2(-o.x,  o.y), 0, 0)).x,
	                          tex2Dlod(DepthBuffer, float4(tc + float2( o.x,  o.y), 0, 0)).x);
	        //Reversed depth has near at one.
	        z = Depth_Map == 1 ? max(max(q.x, q.y), max(q.z, q.w)) : min(min(q.x, q.y), min(q.z, q.w));
	    }
	    return z;
	}

	float Depth(float2 texcoord)
	{   //May have to move this, but it seems good where it is.
		#if !Compatibility_01	
		//BSD: when the mod is active, TC_SP already maps this coord onto the rendered sub rect, so skip
		//the Starting Resolution rescale. Both would stack and double correct (e.g. a stale preset value).
		#if GDM_DEPTH_AUTOFIT
		if(!DB_AutoFit)
		#endif
		{
		float2 Current_Size = tex2Dsize(DepthBuffer);
		float2 Adjust_Size_XY = ScaleSize(Starting_Resolution, Current_Size); 
		
		if(Adjust_Size_XY.y != 0 && Starting_Resolution.y != 0)	
			texcoord.y = texcoord.y / Adjust_Size_XY.y;
			
		if(Adjust_Size_XY.x != 0 && Starting_Resolution.x != 0)	
			texcoord.x = texcoord.x / Adjust_Size_XY.x;
		}
		#endif
        //Conversions to linear space.
		float zBuffer = Near_Tap(texcoord);

		// RangeBoost from Range_Boost
		float RangeBoost = (Range_Boost == 3) ? 2.0 :
		                   (Range_Boost == 4) ? 3.0 :
		                   (Range_Boost == 5) ? 4.0 : 1.5;

		//Define near/far values with adjustments		                   
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
		//May add this later. Need to check emulators.
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
	{   float Threshold = 0.001;//Both this and the options below may need to be adjusted. A value lower than 7.5 will break this.
		if ( SD_Trigger == 1 || SDT == 1)//Top _ Left                             //Center_Left                             //Bottom_Left
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
		//Need to work on this later. So far it seems fine.
		float2 H_V_A, H_V_B, X_Y_A, X_Y_B, S_texcoord = texcoord;
		bool SDT_Bool = 1;
		
		//BSD: exact depth buffer fit from the add-on. DB_Fit maps the screen coord onto the rendered sub rect,
		//DB_Org is its origin (0,0 on Unreal, which pads from the top left). Identity when the add-on is absent,
		//off, or has nothing selected. WDEPTH uses the same fit: the add-on only accepts a weapon buffer
		//matching the world buffer's width, height and format.
		float2 DB_Fit = 1.0, DB_Org = 0.0;
		#if GDM_DEPTH_AUTOFIT
		bool DB_On = DB_AutoFit && DB_Res_Info.x > 0 && DB_Res_Info.y > 0 && DB_Viewport_Size.z > 0 && DB_Viewport_Size.w > 0;
		if(DB_On)
		{

			float2 DB_Ref = (DB_Render_Size.x > 0) ? DB_Render_Size : float2(BUFFER_WIDTH, BUFFER_HEIGHT);

			DB_Fit = DB_Viewport_Size.zw / DB_Res_Info;
			DB_Org = DB_Viewport_Size.xy / DB_Res_Info;

			if(abs(DB_Viewport_Size.z * DB_Ref.y - DB_Viewport_Size.w * DB_Ref.x) > DB_Ref.x * DB_Viewport_Size.w * 0.02)
			{
				DB_Fit = DB_Ref / DB_Res_Info;
				DB_Org = (DB_Viewport_Size.xy - (DB_Ref - DB_Viewport_Size.zw) * 0.5) / DB_Res_Info;
			}
			//Mod is active, so turn Letter Box Detection off.
			LBDetect = 0;
		}
		#endif
		
		#if SDT == 3 || SD_Trigger == 3
			SDT_Bool = SDTriggers();
		#endif
		
		#if DB_Size_Position || SPF || LBC || LB_Correction || GDM_DEPTH_AUTOFIT

			#if LBC || LB_Correction
				X_Y_A = Image_Position_Adjust + (LBDetect && SDT_Bool && LB_Correction_Switch ? Image_Pos_Offset : 0.0f ); //Error used here as a trigger.
			#else
				X_Y_A = float2(Image_Position_Adjust.x,Image_Position_Adjust.y);
			#endif

		texcoord.xy += float2(-X_Y_A.x,X_Y_A.y)*0.5;
		
			#if LBC || LB_Correction
				H_V_A = Horizontal_and_Vertical * (LBDetect && SDT_Bool && LB_Correction_Switch ? H_V_Offset : 1.0f );     //Error used here as a trigger.
				//H_V_B = Horizontal_and_Vertical * H_V_Offset;	
			#else
				H_V_A = Horizontal_and_Vertical;
			#endif
			
		float2 midHV_A = (H_V_A-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
		texcoord = float2((texcoord.x*H_V_A.x)-midHV_A.x,(texcoord.y*H_V_A.y)-midHV_A.y);
		//BSD: apply the exact fit at the same stage the old way scales depth, BEFORE the Flip Scale branch,
		//so the flip cannot invert the origin.
		texcoord = texcoord * DB_Fit + DB_Org;
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
		//Will do this someday.
		#if SDT || SD_Trigger		
			X_Y_B = Image_Position_Adjust + float2(DG_X,DG_Y);
			
			S_texcoord.xy += float2(-X_Y_B.x,X_Y_B.y)*0.5;
			//Will work on this later.
			//float2 midHV_B = (H_V_B-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
			//S_texcoord = float2((S_texcoord.x*H_V_B.x)-midHV_B.x,(S_texcoord.y*H_V_B.y)-midHV_B.y);
		#endif
		
		#if GDM_DEPTH_AUTOFIT
		S_texcoord = S_texcoord * DB_Fit + DB_Org;
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
	{   //Conversions to linear space.
		//float2 Shift_TC = texcoord;
	    #if GDM_WEAPON_DEPTH
	    	//#if AR_Is == 2
			//Shift_TC = AR_Correct_TC(texcoord);
	   	 //#endif
		float zBufferWH = tex2Dlod(WDepthBuffer, float4(texcoord,0,0)).x;
		#else
		float zBufferWH = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x;
		#endif

		float4 WA = WA_XYZW(); //Once.
		float Far = 1.0, Near = 0.125/(0.00000001 + WA.y);  //Near & Far Adjustment
	
		float2 Offsets = float2(1 + WA.z,1 - WA.z), Z = float2( zBufferWH, 1-zBufferWH );
	
		if (WA.z > 0)
		Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));
	
		[branch] if (Depth_Map == 0)//DM0. Normal
			zBufferWH = Far * Near / (Far + Z.x * (Near - Far));
		else if (Depth_Map == 1)//DM1. Reverse
			zBufferWH = Far * Near / (Far + Z.y * (Near - Far));

		return float2(saturate(zBufferWH), WA.x);
	}
	#define WPPP 1
	//3x2 and 2x3 are not emulated on older ReShade versions, so 3x3 is used. Old values for 3x2
	float3x3 PrepDepth(float2 texcoord)
	{
		int Flip_Depth = Flip_Opengl_Depth ? !Depth_Map_Flip : Depth_Map_Flip;
	
		if (Flip_Depth)
			texcoord.y =  1 - texcoord.y;
		
		//Texture Zoom & Aspect Ratio//
		//float X = TEST.x;
		//float Y = TEST.y * TEST.x * 2;
		//float midW = (X - 1)*(BUFFER_WIDTH*0.5)*pix.x;	
		//float midH = (Y - 1)*(BUFFER_HEIGHT*0.5)*pix.y;	
					
		//texcoord = float2((texcoord.x*X)-midW,(texcoord.y*Y)-midH);	
		//texcoord.xy *= TEST.x; //Need to do a best Guess algo for standard DLSS,FSR,and XeSS
		texcoord.xy -= DLSS_FSR_Offset.xy * pix;

		//Side Scaler: pulls the depth map in from the left & right, for games that shrink the image sideways
		//while depth stays full screen (AC Black Flag). 0-1 maps to 0-25% of width.
		float Side_Shrink = AR_Side_Shrink;
		#if AR_Is == 2
		//Side Scaling Mode.
		//aspect difference (x0.9), 0.4 on the Side Scaler.
		if(Side_Scaling_Mode && !Disable_CO && SideBarDetection())
			Side_Shrink = 0.4;
		#endif
		texcoord.x = (texcoord.x - 0.5) / (1.0 - Side_Shrink * 0.25) + 0.5;

	
		float2 TC_D = TC_SP(texcoord).xy;//Same coordinate for both reads.
		float4 DM = Depth(TC_D).xxxx;
		float2 WD_CoP = WeaponDepth(TC_D);
		float R, G, B, A, WD = WD_CoP.x, CoP = WD_CoP.y, CutOFFCal;
		#if GDM_WEAPON_DEPTH
			//Auto weapon hand cutout.
			CutOFFCal = WPresentCheck ? step(WD,0.999) : 0; //WDepthCheck = weapon present
		#else
			CutOFFCal = step(DM.x,(CoP/DMA()) * 0.5); //Legacy world-depth cutoff (shared DepthBuffer)
		#endif

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
		
		//HUD segregation.
		if (HUD_Adjust.x > 0)
			A = COC ? 0.5 : A;
		#endif
		
		return float3x3( saturate(float3(R, G, 0)),											  //[0][0] = R | [0][1] = G | [0][2] = B
						 saturate(float3(A, DM.w, DM.w)),			   //[1][0] = A | [1][1] = D | [1][2] = DM
								  float3(Weapon_Masker > saturate(smoothstep(0,2.5,DM.w)),0,0) );//[2][0] = 0 | [2][1] = 0 | [2][2] = 0
	}
	//////////////////////////////////////////////////////////////Depth HUD Alterations///////////////////////////////////////////////////////////////////////
	#if UI_MASK
	float HUD_Mask(float2 texcoord )
	{
		float Mask_Tex;
		    if (Mask_Cycle == 1)
		        Mask_Tex = tex2Dlod(SamplerMaskB,float4(texcoord.xy,0,0)).a;
		    else
		        Mask_Tex = tex2Dlod(SamplerMaskA,float4(texcoord.xy,0,0)).a;
	
		return saturate(Mask_Tex);
	}
	#endif
	/////////////////////////////////////////////////////////Fade In and Out Toggle/////////////////////////////////////////////////////////////////////
	float Fade_in_out()
	{
		float TCoRF[1], Trigger_Fade, AA = Fade_Time_Adjust, PStoredfade = tex2D(SamplerAvrP_N,float2(0,0.0625)).z;
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
			AA *= 1.7;
		if(World_n_Fade_Reduction_Power.y == 8)//instant
			AA *= 1.775;
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
			Trigger_Fade = Trigger_Fade_Toggle || gamepad_toggle_raw[4].x;
		else if(FPSDFIO == 2)
			Trigger_Fade = Trigger_Fade_Hold || gamepad_toggle_raw[4].y;
		else if(FPSDFIO == 3)
			Trigger_Fade = SnD_Toggle;
		else if(FPSDFIO == 4)
			Trigger_Fade = Trigger_Fade_Toggle || SnD_Toggle || gamepad_toggle_raw[4].x;			
		else if(FPSDFIO == 5)
			Trigger_Fade = Trigger_Fade_Hold || SnD_Toggle || gamepad_toggle_raw[4].y;
			
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
		//Weapon hand mask for the ZPD boundary condition.
		float2 Shape_TC = StoredTC;
		float Shape_Out, Shape_One, Shape_Two, Shape_Three, Shape_Four, SO_Switch = 0.75, ST_Switch = 0.45, FO_Switch = 0.8125, STT_Switch = 0.35, SF_Switch = 0.550, STTT_Switch = 0.45, SFB_Switch = 0.90, SFC_Switch = 0.3, M1_Adjust = 1.0;
		
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

		if(CWH == 11)
		{
			STT_Switch = 1.0;
			SO_Switch = 0.0;
			
			SF_Switch = 0.6;
			SFB_Switch = 1.0;
			SFC_Switch = 0.375;
			
			ST_Switch = 0.4;
			STTT_Switch = 0.375;	
		}

		if(CWH == 12)
		{
			M1_Adjust = 1.25;
			SO_Switch = 0.0;
			
			//SF_Switch = 0.6;
			//SFB_Switch = 1.0;
			SFC_Switch = 0.0;
			
			ST_Switch = 0.75;
			//STTT_Switch = 0.375;
		}
		
		// Conditions for Shape_One
		bool Shape_One_C1 = (Shape_TC.x / Shape_TC.y * SO_Switch) > 1;
		bool Shape_One_C2 = (((M1_Adjust - Shape_TC.x) / Shape_TC.y) * FO_Switch ) > 1;
		Shape_One = saturate(Shape_One_C1 || Shape_One_C2); 
		
		// Conditions for Shape_Two
		bool Shape_Two_C1 = (1 - Shape_TC.x < STTT_Switch && 1 - Shape_TC.y < ST_Switch);
		Shape_Two = saturate(1 - Shape_Two_C1); 
		
		// Conditions for Shape_Three
		float Shape_Three_C1 = (1 - Shape_TC.x - STT_Switch) / (1 - Shape_TC.y);
		Shape_Three = saturate(Shape_Three_C1 > 1); 
		
		// Conditions for Shape_Four
		float Shape_Four_C1 = Shape_TC.x < SFC_Switch  && 1-Shape_TC.x < SFB_Switch && Shape_TC.y > SF_Switch;
		Shape_Four = 1-Shape_Four_C1; 
		
		// Calculate Shape_Out
		Shape_Out = Shape_One + (1 - Shape_Three);
		Shape_Out *= Shape_One + Shape_Two;
		Shape_Out *= Shape_Four;

		if(CWH == 2 || CWH == 4 && CWH != 5)
		Shape_Out = Shape_TC.x < 0.5 ? 1 : Shape_Out;
		
		if(CWH == 7 || CWH == 9 || CWH == 10)
			Shape_Out = Shape_TC.x < 0.125 || Shape_TC.x > 0.875 || Shape_TC.y < 0.7 ? 1 : Shape_Out;

		float TriHeight = 0.5, TriWidth  = 0.625;
		float Shape_Triangle = saturate( Shape_TC.y >= TriHeight && abs(Shape_TC.x - 0.625) <= (Shape_TC.y - TriHeight) * ((TriWidth * 0.5) / (1.0 - TriHeight)) );	

		if(CWH == 12)
		Shape_Out = Shape_TC.x < 0.625 ? 1-Shape_Triangle : Shape_Out;		
		
		return Shape_Out;
	}				

	float2 Shift_Mask(float2 texcoord)
	{
		float4 Shift_XY = floor(texcoord.xxyy * Res.xxyy * pix.xxyy * float4(7,9,7,9));
		return float2(fmod(Shift_XY.x,2),fmod(ZPD_Boundary == 3 ? Shift_XY.w : Shift_XY.z,2));
	}


	#if !DX9_Toggle //DX9 never reads texMiniReconBuffer, see the texture declaration.
	float MiniReconstructionPS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		static const float2 offsets[9] = { float2(-1, -1), float2( 0, -1), float2( 1, -1),
									       float2(-1,  0), float2( 0,  0), float2( 1,  0),
									       float2(-1,  1), float2( 0,  1), float2( 1,  1) };
	    float minVal = 1e10;
	    SD_UNROLL
	    for (int i = 0; i < 9; i++)
	    {
	        float val = PrepDepth( texcoord + offsets[i] * rcp_Depth_Size() * 0.5 )[1][0];
	        minVal = min(minVal, val);
	    }
	    return minVal;
	}
	#endif
	
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
	//Note: float3x3 may have issues with OpenGL, so it may need to be converted to void.
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
	  
			//Screen space detector, a 7x6 grid between 0 and 1.
			float2 GridXY; int2 iXY = ( ZPD_Boundary == 3 ? int2( Detect_More_Mode ? 13 : 9, 4) : int2( 7, 5) );//Was 12/4 and 7/7. This reduction saves 0.1 ms and should show no difference to the user.
			[loop]                                                                     //I was thinking the lowest I can go would be 9/4 along with 7/5
			for( int iX = 0 ; iX < iXY.x; iX++ )                                         //7 * 7 = 49 | 13 * 4 = 52 | 7 * 6 = 42 | 9 * 4 = 36 | 7 * 5 = 35
			{   [loop] 
				for( int iY = 0 ; iY < iXY.y; iY++ )
				{
					if(ZPD_Boundary == 1 || ZPD_Boundary == 6)
						GridXY = float2( CDArray_X_A0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 2 || ZPD_Boundary == 5)
						GridXY = float2( CDArray_X_B0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 7)
						// BD7 FPS Mixed: narrow spacing everywhere except the two OUTERMOST columns, which take
						// the edge positions from A0, so they land on LB_Dir.x and LB_Dir.y. Y is unchanged, both
						// the edge and narrow branches already share CDArray_Y_A0, and 7 does not match the
						// Bottom_Edge_A test for 6, so the bottom row stays at the narrow 0.9 rather than 0.95.
						GridXY = float2( (iX == 0 || iX == iXY.x - 1) ? CDArray_X_A0[iX] : CDArray_X_B0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 3)
						GridXY = float2( Detect_More_Mode ? CDArray_X_C1[iX] : CDArray_X_C0[iX], CDArray_Y_C0[min(3,iY)]);
					else if(ZPD_Boundary == 4)
						GridXY = float2( CDArray_X_A0[iX], CDArray_Y_B0[iY]);
					//We shift the lower half here to have a better spread.
					if(texcoord.y > 0.6 && texcoord.y < 0.8)						
						GridXY.y += Shift_Mask(texcoord).x ? 0.0 : 0.05;

					float ZPD_I = Zero_Parallax_Distance;
					#if !DX9_Toggle
					float PDepth = tex2Dlod(SamplerMR,float4(GridXY,0,0)).x;
					#else				
					float PDepth = PrepDepth(GridXY)[1][0];
					#endif	
					if(ZPD_Boundary >= 4 && PDepth == 1)
							ZPD_I = 0;
					
					//Weapon Hand Consideration
					#if CWH
						bool WHC_Mask = tex2Dlod(SamplerInfo,float4(GridXY,0,0)).y;//CWH_Mask(GridXY);
						if (WHC_Mask == 1)
						    PDepth *= 1+WBA;
					#endif					
					// CDArrayZPD[i] reads across prepDepth.......
					CD = 1 - ZPD_I / PDepth;
					
					if( ZPD_Screen_Edge_Avoidance )
						CD *= tex2Dlod(SamplerInfo,float4(GridXY,0,0)).z;
						
					if ( CD < -ZPD_Scaler_One_Boundary )
						Detect = 1;
					//Used if Depth Buffer is way out of range or if you need granularity.
					if(RE_Set(0).x)
					{					
							if ( CD < -ZPD_Boundary_n_Cutoff_A.y && Detect_Out_of_Range <= 1)
								Detect_Out_of_Range = 1;	
					
						#if EDW || Profiler_Mode	

							if(ZPD_Boundary_n_Cutoff_B.x != 0)
							    if (CD < -ZPD_Boundary_n_Cutoff_B.y && Detect_Out_of_Range <= 2)
							        Detect_Out_of_Range = 2;
							
							if(ZPD_Boundary_n_Cutoff_C.x != 0)
							    if (CD < -ZPD_Boundary_n_Cutoff_C.y && Detect_Out_of_Range <= 3)
							        Detect_Out_of_Range = 3;
							
							if(ZPD_Boundary_n_Cutoff_D.x != 0)
							    if (CD < -ZPD_Boundary_n_Cutoff_D.y && Detect_Out_of_Range <= 4)
							        Detect_Out_of_Range = 4;
							
							if(ZPD_Boundary_n_Cutoff_End.x != 0)
							    if (CD < -RE_Extended().y && Detect_Out_of_Range <= 5)
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
	    float PStoredfade_A = tex2Dlod(SamplerAvrP_N, float4(float2(0, 0.1875), 0, 0)).z,//0 
			  PStoredfade_B = tex2Dlod(SamplerAvrP_N, float4(float2(0, 0.3125), 0, 0)).z,//1
			  PStoredfade_C = tex2Dlod(SamplerAvrP_N, float4(float2(1, 0.1875), 0, 0)).z,//2
			  PStoredfade_D = tex2Dlod(SamplerAvrP_N, float4(float2(1, 0.3125), 0, 0)).z,//3
			  PStoredfade_E = tex2Dlod(SamplerAvrP_N, float4(float2(1, 0.4375), 0, 0)).z,//4
			  PStoredfade_F = tex2Dlod(SamplerAvrP_N, float4(float2(1, 0.5625), 0, 0)).z;//5
	
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
		float  ExAd = (1-(FadeSpeed_AW * 2.0))*1000, Current =  min(0.75f,smoothstep(0,0.25f,PrepDepth(0.5f)[0][0])), Past = tex2Dlod(SamplerAvrP_N,float4(0,0.5625,0,0)).z;
		return Past + (Current - Past) * (1.0 - exp(-frametime/ExAd));
	}
	#define FadeSpeed_AF AFS //Overwatch controlled, AFS defaults to 0.4375. Lower is slower.

	// BSD: the A and B weapon detectors used to hand out a DISCRETE switch
	static const bool W_Smooth_A_B = ABWS;
	#define WZPD_RAMP 1.0 //how sharply the ramp reaches full strength past the limit. Lower is softer.
	float Weapon_ZPD_Fade(float Weapon_Con)
	{
		float  ExAd = (1-(FadeSpeed_AF * 2.0))*1000, Current =  Weapon_Con, Past = tex2Dlod(SamplerAvrP_N,float4(0,0.6875,0,0)).z;
		return Past + (Current - Past) * (1.0 - exp(-frametime/ExAd));
	}
	#define FadeSpeed_OS 0.75

	float OverShoot_Fade()
	{
		float Current, Past, Rate;
		#if ISOGL //One copy of PrepDepth for the GL compiler, same three reads.
		float3 PD_ABC;
		[loop]
		for(int p = 0; p < 3; p++)
			PD_ABC[p] = PrepDepth(float2(p == 0 ? 0.5 : p == 1 ? 0.75 : 0.25, 0.5))[0][0];
		#else
		float3 PD_ABC = float3(PrepDepth(0.5f)[0][0],PrepDepth(float2(0.75,0.5))[0][0],PrepDepth(float2(0.25,0.5))[0][0]);
		#endif
		float Min_Depth = Min3(PD_ABC.x, PD_ABC.y, PD_ABC.z);
		
		Past = tex2Dlod(SamplerAvrP_N,float4(1,0.9375,0,0)).z;
		Current = smoothstep(0,0.25,Min_Depth);
		#if MEM_INFILL
		//Memory Infill: no Smart Convergence while aiming (it is 0 in memory mode now, this is kept for if it comes back).
		//It widens the holes beside the gun as it zooms. Fades out and back in at the usual rate.
		//Aiming is the Fade Key (right mouse, or the gamepad), held unless Activation Type is Press (1 or 4).
		if(FPSDFIO == 1 || FPSDFIO == 4 ? Trigger_Fade_Toggle || gamepad_toggle_raw[4].x : Trigger_Fade_Hold || gamepad_toggle_raw[4].y)
			Current = 0.0;
		#endif
		
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
		float3x3 PD = PrepDepth(texcoord);
		float4 DM = float4(PD[0][0],PD[0][1],0,PD[1][1]);
		float R = DM.x, G = DM.y, B = DM.z, Auto_Scale = 1;
		float SP_Min = Set_Pop_Min().y, Select_Min_LvL_Trigger = 0;float3 Level_Control = DS_X;
		//Auto Scale
		if(WZPD_and_WND.z > 0)
			Auto_Scale = lerp(lerp(1.0,0.1,saturate(WZPD_and_WND.z * 2)),1.0,lerp(saturate(Auto_Scaler() * 2.5) , smoothstep(0,0.5,tex2D(SamplerAvrP_N,float2(0,0.5625)).z), 0.5));
		else if(WZPD_and_WND.z < 0)
			Auto_Scale = lerp(1.0,lerp(1.0,0.1,saturate(abs(WZPD_and_WND.z) * 2)),saturate(Auto_Scaler() * 2.5));
			
		//Fade Storage
		#if DX9_Toggle
		float3x3 Fade_Pass = float3x3(0,0,0, 0,0,0, 0,0,0);
		float2 Fade_C = pix * 3.0;//C_Size
		[branch]
		if((texcoord.x < Fade_C.x || 1-texcoord.x < Fade_C.x) && (texcoord.y < Fade_C.y || 1-texcoord.y < Fade_C.y))
			Fade_Pass = Fade(texcoord); //[0][0] = F | [0][1] = F | [0][2] = F
						 				//[1][0] = F | [1][1] = F | [1][2] = F
										//[2][0] = N | [2][1] = 0 | [2][2] = 0
		float2 Min_Trim = float2(SP_Min,WZPD_and_WND.w);
		#else
		//Every pixel needs [0][0] and [1][1].
		float3 Fade_Pass_A = float3( tex2Dlod(SamplerzBuffer_BlurN,float4(0,0.0625,0,0)).x, 0, 0);
		float3 Fade_Pass_B = float3( 0, tex2Dlod(SamplerzBuffer_BlurN,float4(0,0.5625,0,0)).x, 0);
																        
			float Scale_Auto_Switch = Level_Control.y == 0 ? Fade_Pass_A.x : Level_Control.z == 2 ? Fade_Pass_B.y * 4 >= Level_Control.y : Fade_Pass_B.y * 4 == Level_Control.y;
			
			if(Level_Control.z >= 1)
				Select_Min_LvL_Trigger = Scale_Auto_Switch;
				
			SP_Min = lerp(SP_Min,Level_Control.x, saturate(Select_Min_LvL_Trigger) );
			
			float2 Min_Trim = float2(SP_Min,WZPD_and_WND.w);
		#endif
						 
		if(IC_DEPTH && Inficolor_Near_Reduction)
			Min_Trim = float2((Min_Trim.x * 2.5 + Min_Trim.x) * 0.5, min( 0.3, (Min_Trim.y * 2.5 + Min_Trim.y) * 0.5) );
			
		float ScaleND = saturate(lerp(R,1.0f,smoothstep(min(-Min_Trim.x,0),1.0f,R)));
		float Edge_Adj = 0.5;
		
		if (Min_Trim.x > 0)
		{
			R = saturate(lerp(ScaleND,R,smoothstep(0,Min_Trim.y,ScaleND)));			
			R = lerp(DM.x,R,Auto_Scale);
		}
			//R = DepthEdge( R, DM.x, texcoord, 0.550, PrepDepth(texcoord)[2][0], tex2Dlod(SamplerzBuffer_BlurN,float4(texcoord,0,6)).y);	
		if ( Weapon_Depth_Edge.x > 0)//1.0 needs adjusting for far scaling
			R = lerp(DepthEdge(R, DM.x, texcoord, 1-Weapon_Depth_Edge.x),DM.x,smoothstep(0,1.0,DM.x));
		
		float C_Size = 3;
		
		if(   texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TL OG Fade
			R = Fade_in_out().x;
		#if DX9_Toggle
			if( 1-texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BR 0
				R = Fade_Pass[0][0];
			if(   texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BL 1
				R = Fade_Pass[0][1];
			if( 1-texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TR 2
				R = Fade_Pass[0][2];

			if( 1-texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TR 3
				G = Fade_Pass[1][0];
			if(   texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TL 4
				G = Fade_Pass[1][1];
			if( 1-texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BR 5
				G = Fade_Pass[1][2];
			if(   texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BL N
				G = Fade_Pass[2][0];
		#else
			if( 1-texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BR 0
				R = Fade_Pass_A.x;//[0][0]
			if(   texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BL 1
				R = tex2Dlod(SamplerzBuffer_BlurN,float4(0,0.1875,0,0)).x;//[0][1]
			if( 1-texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TR 2
				R = tex2Dlod(SamplerzBuffer_BlurN,float4(0,0.3125,0,0)).x;//[0][2]

			if( 1-texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TR 3
				G = tex2Dlod(SamplerzBuffer_BlurN,float4(0,0.4375,0,0)).x;//[1][0]
			if(   texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TL 4
				G = Fade_Pass_B.y;//[1][1]
			if( 1-texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BR 5
				G = tex2Dlod(SamplerzBuffer_BlurN,float4(0,0.6875,0,0)).x;//[1][2]
			if(   texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BL N
				G = tex2Dlod(SamplerzBuffer_BlurN,float4(0,0.9375,0,0)).x;//[2][0]
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
		
		float3 Color_UI_MAP = -4.0 * center + right + left + up + down; //Masked out later
		
		Color.y = max(Color_UI_MAP.r, max(Color_UI_MAP.g, Color_UI_MAP.b));
		#else
		if(Alpha_Channel_UI)
		{			
			float center = tex2D(Non_Point_Sampler, texcoord).w;
			
			// Offset gather to center it around texcoord
			float4 gathered = tex2DgatherA(Non_Point_Sampler, texcoord - 0.5 * pix);
			
			float Color_UI_MAP;
			
			if (true)
			{
			    // --- New method: 7 samples (center + 4 + left/right)
			    float left  = tex2D(Non_Point_Sampler, texcoord - float2(pix.x, 0.0)).w;
			    float right = tex2D(Non_Point_Sampler, texcoord + float2(pix.x, 0.0)).w;
			
			    float Alpha_Avr = Isolate_UI ? 6.0 : 7.0;
			    Color_UI_MAP = (center + gathered.x + gathered.y + gathered.z + gathered.w + left + right) * rcp(Alpha_Avr);
			}
			else
			{
			    // --- Old method: 5 samples (center + 4)
			    float Alpha_Avr = Isolate_UI ? 4.0 : 5.0;
			    Color_UI_MAP = (center + gathered.x + gathered.y + gathered.z + gathered.w) * rcp(Alpha_Avr);
			}
			
			Color.y = 1 - Color_UI_MAP;
		}
		else
			Color.y = tex2D(Non_Point_Sampler, texcoord).w;
		#endif
		
		DM_Out = saturate(float2(R,G));
		
		Color_Out = saturate(Color.xy);
	}

	float AutoDepthRange(float d, float2 texcoord )
	{
		float LumAdjust_ADR = smoothstep(-0.0175,min(0.5,Auto_Depth_Adjust),Avr_Mix(float2(0.5,0.5)).x);
	    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
	}
		
	float4 Conv(float2 MD_WHD,float2 texcoord,float2 abs_WZPDB)
	{   float WConverge = 0.030, D = MD_WHD.x, Z = Zero_Parallax_Distance, WZP = 0.5, ZP = 0.5, OS_Value = saturate(tex2Dlod(SamplerAvrP_N, float4(1, 0.9375, 0, 0)).z),
			  W_Convergence = Inficolor_Near_Reduction ? WConverge * 0.75 : WConverge, WZPDB, WZPD_Switch, 
			  Distance_From_Bottom = lerp(0.9,1.0,saturate(WFB)), ZPD_Boundary_Adjust = ZPD_Boundary_n_Fade.x, Store_WC,
			  Switch_Factor = 1.0, Fade_A = 0.0, Fade_B = 0.0;
	    //Screen Space Detector.
		if (abs_WZPDB.x > 0)
		{
			//Weapon sample row. WO is the window BOTH detectors scan when ABWS is off, A and B are the
			//ABWS on windows. The row is a search, so a tap a window gives up is a chance lost.
			//WO no longer matches the released row on purpose: first tap is 0.25, the release had 0.4.
			#if WBS			   
			float WArray[6] = { 0.1, 0.2, 0.3, 0.7, 0.8, 0.9};
			//All three windows cover the whole row, so ABWS changes nothing here.
			#define WO_FIRST 0
			#define WO_LAST  5
			#define WA_FIRST 0
			#define WA_LAST  5
			#define WB_FIRST 0
			#define WB_LAST  5
			#else
			float WArray[6] = { 0.25, 0.5, 0.6, 0.7, 0.8, 0.9};
			//  x pos   0.25 0.5  0.6  0.7  0.8  0.9
			//  WO       X    X    X    X    X    X     ABWS off, both detectors
			//  WA       X    X    X    X               ABWS on, drives DF_X.x
			//  WB            X    X    X    X    X     ABWS on, drives DF_X.y
			#define WO_FIRST 0//Start
			#define WO_LAST  5//Stop
			#define WA_FIRST 0//Start
			#define WA_LAST  3//Stop
			#define WB_FIRST 1//Start
			#define WB_LAST  5//Stop
			#endif
			SD_UNROLL //Krilly only need to check one point just above the center bottom and to the right.
			for( int i = 0 ; i < 6; i++ )
			{
				WZPDB  = 1 - WConverge / tex2Dlod(SamplerDMN, float4(float2(WArray[i],Distance_From_Bottom), 0, 0)).y;
				//ABWS off is the OLD behaviour exactly: both detectors scan WO, the shipped row.
				bool In_Old = i >= WO_FIRST && i <= WO_LAST;
				bool In_A = W_Smooth_A_B ? (i >= WA_FIRST && i <= WA_LAST) : In_Old;
				bool In_B = W_Smooth_A_B ? (i >= WB_FIRST && i <= WB_LAST) : In_Old;
				//How far past each limit this tap sits, 0 at the limit and 1 once well past. Strongest tip wins,
				//so a stage contributes once rather than once per tap.
				Fade_A = max(Fade_A, In_A ? saturate((-WZPDB - DJ_W) * WZPD_RAMP) : 0.0);
				Fade_B = max(Fade_B, In_B ? saturate((-WZPDB - DS_W) * WZPD_RAMP) : 0.0);
				if(Weapon_ZPD_Boundary.x >= 0)
				{	
					if ( In_A && WZPDB < -DJ_W ) // Default -0.1
					{
						W_Convergence *= 1.0-abs_WZPDB.x;
						WZPD_Switch = 1;
					}
					 //Used if Weapon Buffer is way out of range. The |y| > |x| test is the OLD rule, which
					 //locks B out whenever DF_X.y <= DF_X.x. ABWS on drops it, since B has its own window
					 //and its own depth limit there and does not need to outrank A to be allowed to fire.
					if (W_Smooth_A_B || abs_WZPDB.y > abs_WZPDB.x)
					{
						if ( In_B && WZPDB < -DS_W )
						{
							W_Convergence *= 1.0-abs_WZPDB.y;
							WZPD_Switch = 2;
						}
					}
				}
				else
				{
					if ( In_A && WZPDB < -DJ_W ) // Default -0.1
						WZPD_Switch = 1;
					 //Used if Weapon Buffer is way out of range. The |y| > |x| test is the OLD rule, which
					 //locks B out whenever DF_X.y <= DF_X.x. ABWS on drops it, since B has its own window
					 //and its own depth limit there and does not need to outrank A to be allowed to fire.
					if (W_Smooth_A_B || abs_WZPDB.y > abs_WZPDB.x)
					{
						if ( In_B && WZPDB < -DS_W )
							WZPD_Switch = 2;
					}
				}
			}
			#undef WO_FIRST
			#undef WO_LAST
			#undef WA_FIRST
			#undef WA_LAST
			#undef WB_FIRST
			#undef WB_LAST
		}
		//A and B compose here instead of one replacing the other, and each applies once.
		Switch_Factor = lerp(1.0, 1.0 - abs_WZPDB.x, Fade_A) * lerp(1.0, 1.0 - abs_WZPDB.y, Fade_B);
		//Store Weapon Convergence for Smoothing.
		Store_WC = W_Convergence;
		//MD_WHD.y is Weapon Hand Depth
		W_Convergence = 1 - tex2D(SamplerAvrP_N,float2(0,0.6875)).z / MD_WHD.y;// 1-W_Convergence/D
		float WD = MD_WHD.y; //Needed to separate the depth for the weapon hand. It was causing problems with Auto Depth Range below.
	
			if (Auto_Depth_Adjust > 0)
				D = AutoDepthRange(D,texcoord);
			//Used to scale Auto Balance. Here 0 means we are looking close at something.
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
			//N is the current ZPD value.	  															   
			float Detection_Switch_Amount = RE_Set(SetLvL).y;//Y = X																   

			if(RE_Set(0).x)
			{
				DOoR_B = lerp(ZPD_Boundary_Adjust, Set_Adjustments.x, DOoR_B);
				#if Profiler_Mode || EDW					
					if (ZPDBoundaryRank() == 0)
					{
					    DOoR_F = DOoR_B;
					}
					
					if (ZPDBoundaryRank() >= 1)
					{
					    DOoR_C = lerp(DOoR_B, Set_Adjustments.y, DOoR_C);
					    if (ZPDBoundaryRank() == 1)
					    {
					        DOoR_F = DOoR_C;
					    }
					}
					
					if (ZPDBoundaryRank() >= 2)
					{
					    DOoR_D = lerp(DOoR_C, Set_Adjustments.z, DOoR_D);
					    if (ZPDBoundaryRank() == 2)
					    {
					        DOoR_F = DOoR_D;
					    }
					}
					
					if (ZPDBoundaryRank() >= 3)
					{
					    DOoR_E = lerp(DOoR_D, Set_Adjustments.w, DOoR_E);
					    if (ZPDBoundaryRank() == 3)
					    {
					        DOoR_F = DOoR_E;
					    }
					}
					
					if (ZPDBoundaryRank() >= 4)
					{
					    DOoR_F = lerp(DOoR_E, RE_Extended().x, DOoR_F);
					}			
				#else
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
				#endif
			}
			else
			DOoR_F = lerp(ZPD_Boundary_Adjust, Detection_Switch_Amount.x, DOoR_B);
			
			//Want to add an Over Shoot value to ZPD.
			//I need to make shore that if it's near 
			//it is closer to the original value.
			if(ZPD_OverShoot > 0)
				Z = lerp(Z,Z * (1+min(0.75,0.75 * ZPD_OverShoot)),OS_Value);
			
			Z *= lerp( 1, DOoR_F, DOoR_A);
			
			float Convergence = 1 - Z / D;
			if (Zero_Parallax_Distance == 0)
				ZP = 1;
	
			ZP = min(ZP, Auto_Balance_Clamp);

		//* lerp(1,2,D) // place this after saturate(Convergence)
		float Mod_Depth = lerp(Convergence,lerp(D,Convergence,saturate(Convergence) ), ZP);
	#if IC_DEPTH
		Mod_Depth = lerp(Mod_Depth,min(saturate(Inficolor_Max_Depth),Mod_Depth),saturate(D * 0.5));
	#endif
	   //.w carries the continuous factor when smoothing is on, and the old switch number when it is off.
	   return float4( Mod_Depth, lerp(W_Convergence,WD,WZP), Store_WC, W_Smooth_A_B ? Switch_Factor : WZPD_Switch); //The last two are for the weapon hand.
	}

	float WeaponMask(float2 TC,float Mips)
	{
		if(WP == 0)
			return 1;
		else
			return tex2Dlod(SamplerDMN,float4(TC,0,Mips)).y == 0.5 ? 0 : 1;
	}
	
	float Alpha_UI_Mask(float2 texcoord, float Mip)
	{
		float Alpha_UI = tex2Dlod(SamplerCN,float4(texcoord,0,Mip)).y;

		if(Isolate_UI)
			Alpha_UI = Alpha_UI > 0.41;//smoothstep(0.0, 0.4,Alpha_UI);
	
		return Alpha_UI;	
	}	
	
	float4 DB_Comb(float2 texcoord)
	{
		float Auto_Adjust_Weapon_Depth = 1, Anti_Weapon_Z = abs(AWZ);
		float2 MD_W = tex2Dlod(SamplerDMN,float4(texcoord,0,0)).xy;
		//X = Mix Depth | Y = Weapon Mask | Z = Weapon Hand | W = Normal Depth
		float  PD_N = PrepDepth( texcoord )[1][1];//Also returned at the end, so it is read once.
		float4 DM = float4(MD_W.x,WeaponMask(texcoord,0),MD_W.y,PD_N);
		//FLT_EPSILON was added here to help prevent crashing.
		DM.x += FLT_EPSILON;//Needed on X.
		DM.z += FLT_EPSILON;//Needed on Z.
		DM.w += FLT_EPSILON;//Needed on W.
		float C_Size = 3;
		
		//Edge Reduction Stage One
		if(texcoord.x < pix.x * C_Size || 1-texcoord.x < pix.x * C_Size)
		{
			if(DM.y > 0.025)
				DM = lerp(0.04,0.4,tex2Dlod(SamplerDMN,float4(texcoord,0,8)).x);
		}							
			
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
			   
			   if(W_Smooth_A_B)
			   	HandleConvergence.y *= HandleConvergence.w;
			   else
			   {
			   	if(HandleConvergence.w == 1)
			   		HandleConvergence.y *= 1-WZPDB.x;
			   	if(HandleConvergence.w == 2)
			   		HandleConvergence.y *= 1-WZPDB.y;
			   }

		float FadeIO = Focus_Reduction_Type == 0 ? 1 : smoothstep(0, 1, 1 - tex2Dlod(SamplerAvrP_N, float4(0, 0.0625, 0, 0)).z/*stored Fade_in_out*/), FD_Adjust = 0.050;	
	
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
			float AAWD_Adjust = tex2Dlod(SamplerDMN,float4(float2(AWZ < 0 ? 0.55 : 0.50,0.525),0,7)).x;
			Auto_Adjust_Weapon_Depth = lerp(0.5,1.0,smoothstep(0,1,AAWD_Adjust * (Anti_Weapon_Z > 1 ? 12.5 : 7.5)));
		}
		
		DM.y = lerp( HandleConvergence.x, HandleConvergence.y * Auto_Adjust_Weapon_Depth, DM.y);

		#if Inficolor_3D_Emulator
			float UI_Detection_Mask = 0.5;
		#else
			float UI_Detection_Mask = 0.0625;
		#endif
	
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
		
		#if SMD //May do one or two more levels.	
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
		
		#if Cancel_Depth_Key > 5 //Anything > 5 is a keyboard key.
			if (Cancel_Depth)
				DM = UI_Detection_Mask;
		#else
			float Cancel_Depth_Controller = 0;
			#if Cancel_Depth_Key == 1
			Cancel_Depth_Controller = gamepad_toggle_raw[20].x; //Guide Button. May not work on some controllers.
			#elif Cancel_Depth_Key == 2
			Cancel_Depth_Controller = gamepad_toggle_raw[21].x; //Back + Left Trigger
			#elif Cancel_Depth_Key == 3
			Cancel_Depth_Controller = gamepad_toggle_raw[22].x; //Back + Left Bumper
			#elif Cancel_Depth_Key == 4
			Cancel_Depth_Controller = gamepad_toggle_raw[23].x; //Back + Right Trigger
			#elif Cancel_Depth_Key == 5
			Cancel_Depth_Controller = gamepad_toggle_raw[24].x; //Back + Right Bumper
			#endif
			if (Cancel_Depth_Controller)
				DM = UI_Detection_Mask;
		#endif	
		
		//Edge Reduction Stage Two
		#if M_Edge
		if(texcoord.x < 0.001 || 1-texcoord.x < 0.001)
		{
			DM = 0.1;
		}
		#else	
		float EdgeW = 1.0 - saturate(min(texcoord.x, 1.0 - texcoord.x) / 0.03);
		      EdgeW = EdgeW * EdgeW * (3.0 - 2.0 * EdgeW);
		//Outside the 3% band the weight is zero and DM is unchanged, so skip the read there.
		[branch]
		if(EdgeW > 0.0)
			DM = lerp(DM, lerp(0.04, 0.4, tex2Dlod(SamplerDMN, float4(texcoord, 0, 8)).x), EdgeW * 0.25);				
		#endif	
	
		//Weapon_Near
		bool WN_Switch = WZPD_and_WND.x < 0;
		float WN_Mask = WN_Switch ? smoothstep(-0.25, -0.5, DM.y) : smoothstep(-0.375, -0.625, DM.y);//Narrow range midpoint lies between A and B
		DM.y = lerp(DM.y, lerp(DM.y, DM.y * -2.0, WN_Mask), abs(WZPD_and_WND.x));
	
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
		
		//Could expand this to rescale depth around the weapon hand.
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
				DM.y = WeaponMask(texcoord,0) ? 0.0 : DM.y;//Not shore this is the best way to mask it.
				DM.y = lerp(DM.y, lerp(WeaponMask(texcoord,0) ? 0.5 : DM.y,0.025,saturate( Mask_A + Mask_B )) ,smoothstep(0,abs(  UI_Seeking_Strength  ),UI_MASK_A) );// * lerp(1-FD_Adjust,1,FadeIO));
			}		
		
		}
		#endif

		#if HUD_MODE || HMT //Check Weapon Near: if it is too low, it may need adjusting for pop out. 
		float HUDCutOFFCal = ((HUD_Adjust.x * 0.5)/DMA()) * 0.5, COC = step(PrepDepth(texcoord)[1][2],HUDCutOFFCal); //HUD Cutoff Calculation

		//HUD segregation.
		if (HUD_Adjust.x > 0)
			DM.y = COC ? 0.001 + lerp(-0.25,0.25,saturate(HUD_Adjust.y)) : DM.y ;
		#endif
	
		return float4(DM.y,PD_N,HandleConvergence.z,HandleConvergence.w);
	}
	#define Adapt_Adjust 0.7 //[0 - 1]
	////////////////////////////////////////////////////Depth & Special Depth Triggers//////////////////////////////////////////////////////////////////
	void Mod_Z(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Point_Out : SV_Target0 , out float2 Linear_Out : SV_Target1)
	{   //Temporal adaptation based on https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
		float ExAd = (1-Adapt_Adjust)*1250;
		bool  TL = texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2;
		//Temporal again, but for pop out.
					//Popout Detection
			//Color = tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w > 0; // Detect if there is pop out.
			//Color = smoothstep(0,0.1,tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w); //Scale Popout linearly 
		
		float4 Set_Depth = DB_Comb( texcoord.xy ).xyzw;
		
		//Only the top left pixel stores the adaptation and reads the inputs.
		[branch]
		if(TL)
		{
			float Current_A = tex2Dlod(SamplerCN,float4(texcoord,0,12)).x, Past_A = tex2Dlod(SamplerAvrP_N,float4(0,0.4375,0,0)).z;
			Set_Depth.y = Past_A + (Current_A - Past_A) * (1.0 - exp(-frametime/ExAd));
		}
		//Only the corner pixels take these.
		[branch]
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BR
			Set_Depth.y = AltWeapon_Fade();
		[branch]
		if(  texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BL
			Set_Depth.y = Weapon_ZPD_Fade(Set_Depth.z);
		if( 1-texcoord.x < pix.x * 2 &&   texcoord.y < pix.y * 2)//TR
			Set_Depth.y = Set_Depth.w;		
		//For High Frequency Information.
		float HF_Info = saturate(ddx(Set_Depth.x) * ddy(Set_Depth.x));
			
		[branch]
		if(TL)
		{
			float Current_B = smoothstep(0,0.1,tex2Dlod(SamplerAvrP_N,float4(0.5.xx,0,12)).w), Past_B = tex2Dlod(SamplerAvrP_N,float4(0,0.8125,0,0)).z;
			HF_Info = Past_B + (Current_B - Past_B) * (1.0 - exp(-frametime/ExAd));
		}
		if(1-texcoord.x < pix.x * 2 && 1-texcoord.y < pix.y * 2) //BR
			HF_Info = 0;
		[branch]
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
		#if DX9_Toggle
		//Only the right half reads it.
		float Invert_Depth_Mask = 0;
		[branch]
		if(StoredTC.x >= 0.5)
			Invert_Depth_Mask =  1-smoothstep(0.0,0.5,PrepDepth( StoredTC * float2(2.0, 1) - float2(1.0,0.0)  )[1][1]);
		#else
		//DX10+: only the right half reads it, so it is made in the Fade branch's else below.
		float Invert_Depth_Mask = 0;
		#endif
		float Text_Mask = 0;
		float Average_ZPD = PrepDepth( texcoord )[0][0];
		float Average_UI = tex2Dlod(SamplerCN,float4(texcoord,0,12)).y;
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
		//Fade Storage. Only the left half stores it, so the detector grid only runs there.
		float Stored_Fade = 0;
		[branch]
		if(StoredTC.x < 0.5)
		{
			float3x3 Fade_Pass = Fade(StoredTC); //[0][0] = F | [0][1] = F | [0][2] = F
							 					//[1][0] = F | [1][1] = F | [1][2] = F
												 //[2][0] = N | [2][1] = 0 | [2][2] = 0
			const int Num_of_Values = 8; //8 array values in total, mapped to the texture's width.
			float Storage_Array[Num_of_Values] = { Fade_Pass[0][0],
		                                		   Fade_Pass[0][1],
		                                		   Fade_Pass[0][2], 
		                                		   Fade_Pass[1][0],
												   Fade_Pass[1][1],
												   Fade_Pass[1][2],
												   0.0,
												   Fade_Pass[2][0] };
			//Set an average size for the number of lines needed in texture storage.
			float Grid = floor(StoredTC.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);							 
			Stored_Fade = Storage_Array[int(fmod(Grid,Num_of_Values))];
		}
		else
			Invert_Depth_Mask =  1-smoothstep(0.0,0.5,PrepDepth( StoredTC * float2(2.0, 1) - float2(1.0,0.0)  )[1][1]);
		Blur_Out = float2( StoredTC.x < 0.5 ? Stored_Fade : Invert_Depth_Mask, Text_Mask);
		#else
		Blur_Out = StoredTC.x < 0.5 ? Text_Mask : Invert_Depth_Mask;//R16F in DX9: only x is stored.
		#endif
		Info_Ex = float2(Average_ZPD,Average_UI);
	}
	
	#if SUI
		float Stencil_Masking(float2 TC, float2 Pos, float2 UI_Mask_Size, float UI_Mask_Inversion,int SSS)
		{
			#if AR_Is == 2  // 16:10
		        TC.y = 0.5 + (TC.y - 0.5) * 1.111111;
		        Pos.y = 0.5 + (Pos.y - 0.5) * 0.9;
		    #endif
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
	float2 Artifact_Adjust()
	{
		return float2(abs(De_Artifacting.x),De_Artifacting.y);
	}
	#endif
	float Depth_Seperation()
	{
		return min(0.25,Separation_Adjust);
	}
	
	//Depth is adjusted here, since Divergence no longer adjusts it.	
	float Smooth_Tune_Boost() 
	{
		//float RCP_Diverge = 100 * rcp(Divergence_Switch().x);
		float S_T_Adjust = min(1.0+saturate(M_Divergence),abs(Divergence_Switch().y) * 0.01);// * RCP_Diverge;
	    return abs(lerp(0.01f,1.0f,S_T_Adjust));
	}

	static const float VMW_Array[10] = { 0.0, 1.0, 2.0, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0 };

	float DilateH_Scan(sampler tex, float2 uv, float vmw)
	{
		const float tapMip = 2.0;
		float reach = pix.x * exp2(vmw) * 2.0;
		float m = tex2Dlod(tex, float4(uv, 0, 0)).x;
		SD_UNROLL
		for (int i = 1; i <= 6; ++i)
		{
			float t = (float)i / 6.0;
			float off = reach * t;
			m = min(m, tex2Dlod(tex, float4(uv + float2(off, 0), 0, tapMip)).x);
			m = min(m, tex2Dlod(tex, float4(uv - float2(off, 0), 0, tapMip)).x);
		}
		return m;
	}

	float DilateH(sampler tex, float2 uv, float vmw)
	{
		float Depth   = tex2Dlod(tex, float4(uv, 0, 0)).x;
		[branch]
		if(vmw <= 0.0)
			return Depth;
		float mipped  = tex2Dlod(tex, float4(uv, 0, vmw)).x;
		float dilated = DilateH_Scan(tex, uv, vmw);

		float mask = saturate((Depth - dilated) * 8.0);

		return lerp(mipped, Depth, 1-mask);
	}
	
	float GetDB(float2 texcoord)
	{
	    //UI Lift Masking (TMD)
	    #if TMD
	        float TMD_LvL = (TMD == 1) ? 60 : 600;
	        #if DX9_Toggle
	            float Basic_UI = tex2Dlod(SamplerzBuffer_BlurN, float4(texcoord * float2(0.5, 1.0), 0, 2.5)).x;
	        #else
	            float Basic_UI = tex2Dlod(SamplerzBuffer_BlurN, float4(texcoord, 0, 2.5)).y;
	        #endif
	        Basic_UI = saturate(Basic_UI * TMD_LvL);
	    #endif
	
	    //Vertical Pinball coordinate swap.
	    #if Reconstruction_Mode || Virtual_Reality_Mode
	        if (Vert_3D_Pinball)
	            texcoord.xy = texcoord.yx;
	    #else
	        if (Vert_3D_Pinball && Stereoscopic_Mode != 5)
	            texcoord.xy = texcoord.yx;
	    #endif
	
	    //Left/Right depth mask from the blurred SBS depth.
	    float LR_Depth_Mask = 1 - saturate(tex2Dlod(SamplerzBuffer_BlurN,
	        float4(texcoord * float2(0.5, 1) + float2(0.5, 0), 0, 2.5)).x * 5.0);
	
	    //Base depth fetches.
	    float  Base_Depth_Buffer  = tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, 0)).x;
	    float2 N_P0 = tex2Dlod(SamplerzBufferN_P, float4(texcoord, 0, 0)).xy;
	    float2 Base_Depth_Buffers = float2(Base_Depth_Buffer, N_P0.x);
	
	    //float Base_Depth_SubSampled = tex2Dlod(SamplerzBufferN_L, float4( texcoord, 0, lerp(0.0,4.0,Base_Depth_Buffers.x)) ).x;
	    float Base_Depth = Base_Depth_Buffers.x; ////lerp(Base_Depth_Buffers.x,Base_Depth_SubSampled,LR_Depth_Mask.x*Sat_Range);
	
	    //Pick the warp mip level (VMW).
	    uint VMW_Switch = View_Mode_Warping;
	    #if LBM || LetterBox_Masking
	        float LB_Detection = tex2D(SamplerAvrP_N, float2(1, 0.0625)).z;
	        if (LB_Detection)
	            VMW_Switch *= 0.5;
	    #endif
	    //float, not uint: the half levels (3.5, 4.5, 5.5) were truncated, so steps 4, 6 and 8 repeated 3, 4 and 5.
	    float VM_Mip_Cal = VMW_Array[clamp(VMW_Switch, 0, 9)];
	    uint ISV_Switch = 3;
	
	    float FadeIO = smoothstep(0, 1, tex2D(SamplerDMN, 0).x);
	    if (FPSDFIO > 0)
	        ISV_Switch = lerp(ISV_Switch, 6, FadeIO);
	
	    //Smoothing is unmasked, so distortion-prone areas smooth more than clam ones.
	    LR_Depth_Mask = smoothstep(Warping_Masking == 2 ? 0.75 : 1, 0,
	        tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, ISV_Switch)).x * (1 - LR_Depth_Mask));
	
	    float VMW = (Warping_Masking == 0) ? VM_Mip_Cal : lerp(VM_Mip_Cal, 0, LR_Depth_Mask.x);
	    #if TMD == 1
	        VMW = lerp(clamp(VMW, 0, 6.0), 6.0, Basic_UI);
	    #else
	        VMW = clamp(VMW, 0, 6.0);
	    #endif
	
	    if (Weapon_Near_Halo_Reduction)
	        VMW = lerp(VMW, 9, tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, 9)).x * 0.5);
	
		//Horizontal dilation normally, an isotropic mip read when Pinball mode has swapped the axes.
	    bool PinballSwap = false;
	    #if Reconstruction_Mode || Virtual_Reality_Mode
	        PinballSwap = Vert_3D_Pinball;
	    #else
	        PinballSwap = Vert_3D_Pinball && Stereoscopic_Mode != 5;
	    #endif
	    float Smoothed = PinballSwap
	        ? tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, VMW)).x
	        : DilateH(SamplerzBufferN_L, texcoord, VMW);
	    float Min_Blend = min(Smoothed, Base_Depth.x);
	
	    float2 DepthBuffer_LP = float2(Min_Blend, Base_Depth_Buffers.y);
	
	    //TMD text direction UI lift.
	    #if TMD
	        #if TMD == 1
	        #else
	            float Text_Direction = texcoord.x < DZ_W.z || texcoord.y < DZ_W.w;
	            #if (TMD == 3) // Reverse
	                Text_Direction  = 1 - texcoord.x < DZ_W.z || 1 - texcoord.y < DZ_W.w;
	            #elif (TMD == 4) // Mirror
	                Text_Direction += 1 - texcoord.x < DZ_W.z || 1 - texcoord.y < DZ_W.w;
	            #endif
	
	            if (DZ_W.x > 0 && Text_Menu_Detection())
	            {
	                if (Text_Direction)
	                    DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy,
	                        min(DepthBuffer_LP.xy,
	                            saturate(tex2Dlod(SamplerzBufferN_L,
	                                float4(texcoord, 0, (uint)lerp(0, 12, Basic_UI))).x * 0.01)),
	                        Basic_UI * saturate(DZ_W.x));
	            }
	        #endif
	    #endif
	
	    //Stencil UI masks (SUI A-F).
	    //Auto Depth 0.5 > needs more detection points. Will update later.
	    #if SUI
	        float2 UI_A_Mask_Pos   = 1 - DDD_Y.zw;
	        float  UI_A_Mask_Depth = (DDD_W.w < 0.5) ? DDD_W.w : Stencil_Sampler(float3(1 - UI_A_Mask_Pos, DDD_W.w));
	        float2 UI_A_Mask_Size  = DDD_W.xy;
	        if (Stencil_n_Detection_A())
	            DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy, UI_A_Mask_Depth,
	                Stencil_Masking(texcoord, UI_A_Mask_Pos, UI_A_Mask_Size, DDD_W.z, SSA));
	    #endif
	    #if SUI >= 2
	        float2 UI_B_Mask_Pos   = 1 - DEE_Y.zw;
	        float  UI_B_Mask_Depth = (DEE_W.w < 0.5) ? DEE_W.w : Stencil_Sampler(float3(1 - UI_B_Mask_Pos, DEE_W.w));
	        float2 UI_B_Mask_Size  = DEE_W.xy;
	        if (Stencil_n_Detection_B())
	            DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy, UI_B_Mask_Depth,
	                Stencil_Masking(texcoord, UI_B_Mask_Pos, UI_B_Mask_Size, DEE_W.z, SSB));
	    #endif
	    #if SUI >= 3
	        float2 UI_C_Mask_Pos   = 1 - DFF_Y.zw;
	        float  UI_C_Mask_Depth = (DFF_W.w < 0.5) ? DFF_W.w : Stencil_Sampler(float3(1 - UI_C_Mask_Pos, DFF_W.w));
	        float2 UI_C_Mask_Size  = DFF_W.xy;
	        if (Stencil_n_Detection_C())
	            DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy, UI_C_Mask_Depth,
	                Stencil_Masking(texcoord, UI_C_Mask_Pos, UI_C_Mask_Size, DFF_W.z, SSC));
	    #endif
	    #if SUI >= 4
	        float2 UI_D_Mask_Pos   = 1 - DGG_Y.zw;
	        float  UI_D_Mask_Depth = (DGG_W.w < 0.5) ? DGG_W.w : Stencil_Sampler(float3(1 - UI_D_Mask_Pos, DGG_W.w));
	        float2 UI_D_Mask_Size  = DGG_W.xy;
	        if (Stencil_n_Detection_D())
	            DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy, UI_D_Mask_Depth,
	                Stencil_Masking(texcoord, UI_D_Mask_Pos, UI_D_Mask_Size, DGG_W.z, SSD));
	    #endif
	    #if SUI >= 5
	        float2 UI_E_Mask_Pos   = 1 - DJJ_Y.zw;
	        float  UI_E_Mask_Depth = (DJJ_W.w < 0.5) ? DJJ_W.w : Stencil_Sampler(float3(1 - UI_E_Mask_Pos, DJJ_W.w));
	        float2 UI_E_Mask_Size  = DJJ_W.xy;
	        if (Stencil_n_Detection_E())
	            DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy, UI_E_Mask_Depth,
	                Stencil_Masking(texcoord, UI_E_Mask_Pos, UI_E_Mask_Size, DJJ_W.z, SSE));
	    #endif
	    #if SUI >= 6
	        float2 UI_F_Mask_Pos   = 1 - DLL_Y.zw;
	        float  UI_F_Mask_Depth = (DLL_W.w < 0.5) ? DLL_W.w : Stencil_Sampler(float3(1 - UI_F_Mask_Pos, DLL_W.w));
	        float2 UI_F_Mask_Size  = DLL_W.xy;
	        if (Stencil_n_Detection_F())
	            DepthBuffer_LP.xy = lerp(DepthBuffer_LP.xy, UI_F_Mask_Depth,
	                Stencil_Masking(texcoord, UI_F_Mask_Pos, UI_F_Mask_Size, DLL_W.z, SSF));
	    #endif
	
	    //2D+Depth path: collapse L to P.
	    #if !Use_2D_Plus_Depth
	        //Anaglyph and Inficolor: VM0 is the old Normal, which collapses the pair as Stamped does.
	        if (View_Mode == 3 || View_Mode == 6 || (VM0_NORMAL && View_Mode == 0))
	            DepthBuffer_LP.x = DepthBuffer_LP.y;
	    #endif
	
	    float Separation        = lerp(1.0, 5.0, Depth_Seperation());
	    float Boost_Range_Depth = DepthBuffer_LP.x;
	    float Pop_Adjust        = saturate(DI_Y);
	    float Max_Clamp         = (Pop_Adjust > 0) ? 5.0 : 2.5;
	
	    //Boost Mode (from 2018): nonlinear mid depth pop.
	    if (Pop_Adjust > 0)
	    {
	        float2 Clamp_Near     = max(0, float2(N_P0.y, DepthBuffer_LP.x));
	        float  Mid_Point      = (Clamp_Near.y > 0.5) ? Clamp_Near.x : Clamp_Near.y;
	        float  RCP_Diverge    = saturate(0.01 * Divergence_Switch().y);
	        float  Cal_Power_Blend = lerp(1.75, 1.25, RCP_Diverge);
	
	        Boost_Range_Depth = lerp(DepthBuffer_LP.x * 2 - 1, DepthBuffer_LP.x * 3 - 1.5, Mid_Point * 0.25 + 0.25);
	        Boost_Range_Depth = lerp(DepthBuffer_LP.x,         Boost_Range_Depth * 0.5 + 0.5, Clamp_Near.y);
	        Boost_Range_Depth = lerp(DepthBuffer_LP.x,         Boost_Range_Depth,             Clamp_Near.y * 0.5 + 0.5);
	        Boost_Range_Depth = lerp(DepthBuffer_LP.x,         Boost_Range_Depth,             Cal_Power_Blend * Pop_Adjust);
	    }
	
	    return clamp(Separation * Boost_Range_Depth * Smooth_Tune_Boost(), -1.5, Max_Clamp);
	}

	//The mix's scaling on the point depth, without the warp smoothing that smears thin objects.
	float Orig_Depth(float2 texcoord)
	{
	    float2 N_P0 = tex2Dlod(SamplerzBufferN_P, float4(texcoord, 0, 0)).xy;
	    float  D    = N_P0.x;
	    float Separation        = lerp(1.0, 5.0, Depth_Seperation());
	    float Boost_Range_Depth = D;
	    float Pop_Adjust        = saturate(DI_Y);
	    float Max_Clamp         = (Pop_Adjust > 0) ? 5.0 : 2.5;
	    if (Pop_Adjust > 0)
	    {
	        float2 Clamp_Near      = max(0, float2(N_P0.y, D));
	        float  Mid_Point       = (Clamp_Near.y > 0.5) ? Clamp_Near.x : Clamp_Near.y;
	        float  RCP_Diverge     = saturate(0.01 * Divergence_Switch().y);
	        float  Cal_Power_Blend = lerp(1.75, 1.25, RCP_Diverge);
	        Boost_Range_Depth = lerp(D * 2 - 1, D * 3 - 1.5, Mid_Point * 0.25 + 0.25);
	        Boost_Range_Depth = lerp(D, Boost_Range_Depth * 0.5 + 0.5, Clamp_Near.y);
	        Boost_Range_Depth = lerp(D, Boost_Range_Depth, Clamp_Near.y * 0.5 + 0.5);
	        Boost_Range_Depth = lerp(D, Boost_Range_Depth, Cal_Power_Blend * Pop_Adjust);
	    }
	    return clamp(Separation * Boost_Range_Depth * Smooth_Tune_Boost(), -1.5, Max_Clamp);
	}
	
	int3 Shift_Depth()
	{
		float If_Has_Depth = tex2Dlod(SamplerAvrB_N,float4(float2(0.5,0.5),0,12)).y < 1;
	
		#if ISOGL //One copy of PrepDepth for the GL compiler, same six reads.
		const float2 SD_Pos[6] = { float2(0.25,0.999), float2(0.75,0.999), float2(0.50,0.999),
		                                  float2(0.999,0.999), float2(0.999,0.5), float2(0.999,0.75) };
		float SD_V[6];
		[loop]
		for(int p = 0; p < 6; p++)
			SD_V[p] = PrepDepth(SD_Pos[p])[0][0];
		float Check_Depth_Pos_Bot_A = SD_V[0], Check_Depth_Pos_Bot_B = SD_V[1], Check_Depth_Pos_Bot_C = SD_V[2];
		float Check_Depth_Pos_Corner = SD_V[3], Check_Depth_Pos_Side_A = SD_V[4], Check_Depth_Pos_Side_B = SD_V[5];
		#else
		float Check_Depth_Pos_Bot_A = PrepDepth(float2(0.25,0.999))[0][0];
		float Check_Depth_Pos_Bot_B = PrepDepth(float2(0.75,0.999))[0][0];
		float Check_Depth_Pos_Bot_C = PrepDepth(float2(0.50,0.999))[0][0];
		
		float Check_Depth_Pos_Corner = PrepDepth(float2(0.999,0.999))[0][0];
	
		float Check_Depth_Pos_Side_A = PrepDepth(float2(0.999,0.5))[0][0];//Was 1.0, 0.5
		float Check_Depth_Pos_Side_B = PrepDepth(float2(0.999,0.75))[0][0];
		#endif
		
		int Check_Depth_Shift_A = Check_Depth_Pos_Bot_A * Check_Depth_Pos_Bot_B * Check_Depth_Pos_Side_A * Check_Depth_Pos_Corner;
		int Check_Depth_Shift_B = Check_Depth_Pos_Side_B * Check_Depth_Pos_Side_A * Check_Depth_Pos_Corner;
		int Check_Depth_Shift_C = Check_Depth_Pos_Bot_A * Check_Depth_Pos_Bot_B * Check_Depth_Pos_Bot_C  * Check_Depth_Pos_Corner;
		
		return int3(Check_Depth_Shift_A == 1, Check_Depth_Shift_B == 1, Check_Depth_Shift_C == 1 ) && If_Has_Depth;	    
	}	
	
	float Detect_LetterBox_UI()
	{
		float2 Narrow_Wide_LB = Alpha_UI_is_Narrow ? float2(0.05,0.95) : float2(0.1,0.9) ;	
		float2 Connect4[4] = { float2(0.01,Narrow_Wide_LB.x),
                               float2(0.99,Narrow_Wide_LB.x),
                               float2(0.01,Narrow_Wide_LB.y),
                               float2(0.99,Narrow_Wide_LB.y) };							 

		float Alpha_UI_0 = tex2Dlod(SamplerCN,float4(Connect4[0],0,0)).y < 1,
			  Alpha_UI_1 = tex2Dlod(SamplerCN,float4(Connect4[1],0,0)).y < 1,
			  Alpha_UI_2 = tex2Dlod(SamplerCN,float4(Connect4[2],0,0)).y < 1,
			  Alpha_UI_3 = tex2Dlod(SamplerCN,float4(Connect4[3],0,0)).y < 1;
	
		return Alpha_UI_0 && Alpha_UI_1 && Alpha_UI_2 && Alpha_UI_3;	  
	}
	
	float IM_Stencil(float2 tc, float Near, float Far, bool type)
	{
		float TCX_S = tc.x < 0.5 ? tc.x : 1-tc.x;
		float TCY_S = tc.y < 0.5 ? tc.y : 1-tc.y;
		float TCXY_S = (TCX_S + TCY_S) * 0.5;
		float IM_S = saturate( type ? smoothstep(Near,Far, lerp(1,TCXY_S,tc.y)) : smoothstep(Near,Far, TCXY_S ) ); 
		return IM_S;
	}
	
	float LetterBox_UI(float2 tc)
	{
		float Hard_or_Blend = abs(Alpha_UI_Has_LB);
		float Clip_Alpha_UI = Hard_or_Blend * 0.5, CAUI_Scale_A = Hard_or_Blend * 4;
		float Clip_UI_A = saturate((tc.y < 0.5 ? tc.y > Clip_Alpha_UI : 1-tc.y > Clip_Alpha_UI));
		float Clip_UI_B = smoothstep(0.15 * CAUI_Scale_A,0.03 * CAUI_Scale_A, tc.y < 0.5 ? tc.y : 1-tc.y );
		if(Detect_LetterBox_UI())
			return saturate(Alpha_UI_Has_LB > 0 ? Clip_UI_A : Clip_UI_B);
		else
			return 1;
	}
	
	float Vin_Alpha_UI(float2 texcoord, float Depth_Info, int Switch )
	{
		if(!Switch)
			texcoord.x = (texcoord.x - 0.5) * ARatio + 0.5;
			
		float V_Value_A = FLT_EPSILON + 1.0,V_Value_B = FLT_EPSILON + 0.5, V_Calibrate = lerp(0.55,0.54,Depth_Info);
		float2 Prep_TC = texcoord * 2.925, V_Adjust_A = float2(V_Value_A * 0.5,V_Value_A * V_Calibrate), V_Adjust_B = float2(V_Value_B * 0.5,V_Value_B);
		float2 TCV = -texcoord * Prep_TC + Prep_TC;
		float Vin = smoothstep(V_Adjust_A.x,V_Adjust_A.y,TCV.x * TCV.y) * 2;
		if(Switch)
			Vin = smoothstep(V_Adjust_B.x,V_Adjust_B.y,TCV.x * TCV.y);
		return saturate(Vin);
	}
	
	void Mix_Z(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float MixOut : SV_Target0)
	{	
		float2 Shift_TC = texcoord;

		#if AR_Is == 2
		Shift_TC = AR_Correct_TC(texcoord);
   	 #endif
   	 
		//Work on this
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
			float2 Depth_Size = rcp_Depth_Size();
			//float Depth_AR = Depth_Size.x/Depth_Size.y;
			//float modifiedAR = Depth_AR - floor(Depth_AR);
			
			
			[branch]
			if(Auto_Scaler_Adjust && AR_Is != 2)
			{
				float  SD = tex2Dlod(Sampler_ShiftD, float4(0.5, 0.5, 0, 0)).x;
				bool3  Shift = bool3(fmod(SD, 2.0) >= 1.0, fmod(floor(SD * 0.5), 2.0) >= 1.0, fmod(floor(SD * 0.25), 2.0) >= 1.0);
				#if LBC || LB_Correction || EDW || DB_Size_Position || Profiler_Mode || SPF
				bool   LB_On = SD >= 8.0;//Not LBD: some profiles #define LBD.
				int LBD_Switch = LBD_Switcher > 0 ? 1 : !LB_On;
				if(LB_On)
				{
					if(Shift.x && LBD_Switch && LBD_Switcher == 1)
						Shift_TC *= 1-Depth_Size * 2.5;
					else if(Shift.y && LBD_Switch && LBD_Switcher == 2)
						Shift_TC.x *= 1-Depth_Size.x * 3.0;
					else if(Shift.z && LBD_Switch && LBD_Switcher == 3)
						Shift_TC.y *= 1-Depth_Size.y*2.5;
				}
				else
				{
					if(Shift.x)
						Shift_TC *= 1-Depth_Size * 2.5;
					else if(Shift.y)
						Shift_TC.x *= 1-Depth_Size.x * 3.0;
					else if(Shift.z)
						Shift_TC.y *= 1-Depth_Size.y*2.5;
				}
				#else
				if(Shift.x)
					Shift_TC *= 1-Depth_Size * 2.5;
				else if(Shift.y)
					Shift_TC.x *= 1-Depth_Size.x * 3.0;
				else if(Shift.z)
					Shift_TC.y *= 1-Depth_Size.y*2.5;
				#endif
			}
		#endif	
	
		#if BD_Correction || BDF
		if(BD_Options == 0 || BD_Options == 2)
		{
			float3 K123 = Colors_K1_K2_K3 * 0.1;
			Shift_TC = D(Shift_TC.xy,K123.x,K123.y,K123.z);
		}
		#endif	
	
		MixOut = GetDB( Shift_TC );
		
		#if LBM || LetterBox_Masking
			float LB_Dir = LetterBox_Masking == 2 || LBM == 2 ? texcoord.x : texcoord.y;
			float2 Cal_LB_Mask = saturate(float2(DI_X,1-DI_X));
			float LB_Detection = tex2D(SamplerAvrP_N,float2(1,0.0625)).z,LB_Masked = LB_Dir > Cal_LB_Mask.y && LB_Dir < Cal_LB_Mask.x ? MixOut : 0.0125;
			
			if(LB_Detection)
				MixOut = LB_Masked;	
		#endif
		
		#if !WHM
		if(Alpha_Channel_UI)
		{        
		    float Store_MixOut = MixOut;
		    float2 FPS_Alpha_UI = 0, TRD_Alpha_UI = 0;
		    float Avg_UI = saturate(smoothstep(0.25, 1, tex2Dlod(SamplerzBuffer_BlurEx, float4(0.5, 0.5, 0, 12)).y) * 2);
		
		    float Game_Alpha_UI, Game_Alpha_UI_M;
		    float Alpha_UI = Alpha_UI_Mask(texcoord, 0);
		    	  Alpha_UI = min(Alpha_UI,Alpha_UI_Mask(texcoord, 1.0));
	
		    float Low_Rez_Depth    = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, 5 )).x;
		    float OA_Power         = saturate(abs(Divergence_Switch().y) * 0.01);
		    float Alpha_Letter_Box = Alpha_UI_Has_LB == 0 ? 1 : LetterBox_UI(texcoord);
		    float Alpha_UI_Depth   = ASU; // 0 - 1
		    float Controller_RT    = saturate(gamepad_toggle_raw[5].y * 2);
		
		    if(1 - Alpha_UI > 0.0)
		    {
		        //Common values.
		        float texcoord_x_mirror = texcoord.x < 0.5 ? texcoord.x : 1 - texcoord.x;
		        float texcoord_y_mirror = texcoord.y < 0.5 ? texcoord.y : 1 - texcoord.y;
		        float Avg_UI_doubled    = saturate(Avg_UI * 2);
		        float Avg_UI_halved     = Avg_UI * 0.5;
		
		        Game_Alpha_UI   = smoothstep(Alpha_UI_Depth, 1, Alpha_UI);
		        Game_Alpha_UI_M = smoothstep(Alpha_UI_Depth, 1, tex2Dlod(SamplerCN, float4(texcoord, 0, 4)).y);
		        float Min_Game_Alpha = min(Game_Alpha_UI, Game_Alpha_UI_M * 0.025);//0.025 should be adjustable in the future.
		
		        //Vicinal modes 0, 6, 8, 12, 13
		        if(Alpha_Auto_UI == 0 || Alpha_Auto_UI == 6 || Alpha_Auto_UI == 8 || Alpha_Auto_UI == 12 || Alpha_Auto_UI == 13)
		        {
		            float mipCoarse = 4.0, mipFine = 2.0, mipLarge = 5.0;
		
		            float Middel_Depth = smoothstep(0.0, 1.0, tex2Dlod(SamplerAvrB_N, float4(0.5, 0.5, 0, mipLarge)).x);
		            float CoarseCenter = smoothstep(-1.0, 2.0, tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipCoarse)).x);
		            float FineCenter   = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipFine)).x;
		            float LargeCenter  = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipLarge)).x;
		
		            float BlendOut = lerp(-0.5, 0.5, CoarseCenter);
		                  BlendOut = min(LargeCenter, BlendOut);
		                  BlendOut = lerp(BlendOut, 1.0, FineCenter);
		
		            float S_UI  = 1 - Alpha_UI > 0.0;
		            float AS_UI = lerp(0.0, S_UI, BlendOut);
		
		            if(Alpha_Auto_UI == 6 || Alpha_Auto_UI == 8 || Alpha_Auto_UI == 12 || Alpha_Auto_UI == 13)
		                TRD_Alpha_UI.x = lerp(0.5, Min_Game_Alpha + AS_UI, Middel_Depth);
		            else
		                MixOut = lerp(0.5, Min_Game_Alpha + AS_UI, Middel_Depth);
		        }
		
		        //Local modes 1, 4, 5, 7, 9, 10, 11, 12, 13
		        if(Alpha_Auto_UI == 1  || Alpha_Auto_UI == 4 || Alpha_Auto_UI == 5 ||
		           Alpha_Auto_UI == 7  || Alpha_Auto_UI == 9 || Alpha_Auto_UI == 10 || Alpha_Auto_UI == 11 || Alpha_Auto_UI == 12 || Alpha_Auto_UI == 13)
		        {
		            float mipCoarse        = 2.0;
		            float mipFine          = 4.0;
		            float Scale_FPS_Dist_A = 1.0;
		            float Scale_FPS_Dist_B = 0.55;
		
		            if(Alpha_Auto_UI == 4 || Alpha_Auto_UI == 7)
		            {
		                Scale_FPS_Dist_A = 1.075;
		                Scale_FPS_Dist_B = 0.5;
		                mipCoarse = lerp(4.0, mipCoarse, Avg_UI_doubled);
		                mipFine   = lerp(5.0, mipFine,   Avg_UI_doubled);
		            }
		            else if(Alpha_Auto_UI == 9 || Alpha_Auto_UI == 13)
		            {
		                Scale_FPS_Dist_A = 1.05;
		                Scale_FPS_Dist_B = 0.125;
		                mipCoarse = lerp(4.0, mipCoarse, Avg_UI_doubled);
		            }
		            else if(Alpha_Auto_UI == 5)
		            {
		                mipCoarse = lerp(4.0, mipCoarse, Avg_UI_doubled);
		                mipFine   = lerp(5.0, mipFine,   Avg_UI_doubled);
		            }
		            else if(Alpha_Auto_UI == 11)
		            {
		                Scale_FPS_Dist_A = 1.0;
		                Scale_FPS_Dist_B = 0.0;
		                mipCoarse = 5;
		                mipFine   = 6;
		            }
		            else
		            {
		                mipFine = lerp(mipFine, 2.0, Avg_UI_doubled);
		            }
		
		            float CoarseCenter = smoothstep(-1.0, 2.0, tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipCoarse)).x);
		            float FineCenter   = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipFine)).x;
		
		            float BlendOut = lerp(-0.325, Scale_FPS_Dist_B, CoarseCenter);
		                  BlendOut = lerp(BlendOut, Scale_FPS_Dist_A, FineCenter);
		
		            float S_UI = lerp(1.0, 0.875, Vin_Pattern(texcoord, float2(12, 2)));
		
		            if(Isolate_UI)
		                S_UI = 1 - Alpha_UI > 0.0 ? 0.875 : 1;
		
		            float AS_UI = lerp(0.0, S_UI, BlendOut);
		
		            if(Alpha_Auto_UI == 4 || Alpha_Auto_UI == 7 || Alpha_Auto_UI == 9 ||
		               Alpha_Auto_UI == 10 || Alpha_Auto_UI == 11 || Alpha_Auto_UI == 12 || Alpha_Auto_UI == 13)
		                FPS_Alpha_UI.x = Min_Game_Alpha + AS_UI;
		            else if(Alpha_Auto_UI == 5)
		                TRD_Alpha_UI.x = Min_Game_Alpha + AS_UI;
		            else
		                MixOut = Min_Game_Alpha + AS_UI;
		        }
		
		        //Average modes 2, 5, 7, 8, 9, 10, 11, 12, 13
		        if(Alpha_Auto_UI == 2  || Alpha_Auto_UI == 5 || Alpha_Auto_UI == 7 ||
		           Alpha_Auto_UI == 8  || Alpha_Auto_UI == 9 || Alpha_Auto_UI == 10 || Alpha_Auto_UI == 11 || Alpha_Auto_UI == 12 || Alpha_Auto_UI == 13)
		        {
		            float mipLevel_A = 7, mipLevel_B = 5.0;
		
		            float DCenter = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipLevel_A)).x;
		            float BCenter = (Alpha_Auto_UI == 10 || Alpha_Auto_UI == 12)
		                          ? smoothstep(0.0, 1.0, tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipLevel_B)).x)
		                          : tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipLevel_B)).x;
		
		            float DMix = min(DCenter, BCenter);
		
		            float2 Alpha_Five_Switch = Alpha_Auto_UI == 5 ? float2(-0.7, 1.5) :
		                                       (Alpha_Auto_UI == 9 || Alpha_Auto_UI == 13) ? float2(-0.25, 1.0) :
		                                                            float2(-0.5, 1.0);
		
		            float BlendOut = lerp(Alpha_Five_Switch.x, Alpha_Five_Switch.y, DMix);
		
		            float S_UI = lerp(1 - Alpha_UI > 0.0,
		                              texcoord.y < 0.5 ? texcoord.y + 0.25 : (1 - texcoord.y) + 0.25,
		                              0.25);
		
		            if(Isolate_UI)
		                S_UI = 1 - Alpha_UI > 0.0 ? 0.875 : 1;
		
		            float AS_UI = lerp(0.0, S_UI, BlendOut);
		
		            if(Alpha_Auto_UI == 5 || Alpha_Auto_UI == 7 || Alpha_Auto_UI == 8 ||
		               Alpha_Auto_UI == 9 || Alpha_Auto_UI == 10 || Alpha_Auto_UI == 11 || Alpha_Auto_UI == 12 || Alpha_Auto_UI == 13)
		                TRD_Alpha_UI.y = Min_Game_Alpha + AS_UI;
		            else
		                MixOut = Min_Game_Alpha + AS_UI;
		        }
		
		        //Guided modes 3, 4
		        if(Alpha_Auto_UI == 3 || Alpha_Auto_UI == 4)
		        {
		            float Set_Mip    = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, 4)).y;
		            float2 coordSize = float2(0.25, 0.0);
		            float mipLevel_A = 6.0;//lerp(4.0, 6.0, Set_Mip);
		            float mipLevel_B = 7.0;
		            float Scale_FPS_Dist_C = 0.1;
	
		            float DLeft   = tex2Dlod(SamplerAvrB_N, float4(texcoord - coordSize, 0, mipLevel_A)).y;
		            float DCenter = tex2Dlod(SamplerAvrB_N, float4(texcoord,              0, mipLevel_A)).y;
		            float DRight  = tex2Dlod(SamplerAvrB_N, float4(texcoord + coordSize, 0, mipLevel_A)).y;
		
		            float DMix   = min(DLeft, min(DCenter, DRight));
		            float Center = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipLevel_B)).x;
		                  DMix   = min(Center, DMix) * 0.5;
		
		            float2 Alpha_Five_Switch = Alpha_Auto_UI == 4
		                                     ? lerp(-Scale_FPS_Dist_C, Scale_FPS_Dist_C, Low_Rez_Depth)
		                                     : float2(lerp(-0.125, 0.125, Low_Rez_Depth), 1.0);
		
		            float Tuning_Value = Alpha_Auto_UI == 4 ? lerp(-0.05, 0.0, 1 - texcoord.y) : 0.0;
		            float BlendOut     = lerp(Alpha_Five_Switch.x, Alpha_Five_Switch.y, DMix);
		
		            float S_UI  = 1 - Alpha_UI > 0.0;
		            float AS_UI = lerp(0.0, S_UI, BlendOut + Tuning_Value);
		
		            if(Alpha_Auto_UI == 4)
		                FPS_Alpha_UI.y = Min_Game_Alpha + AS_UI;
		            else
		                MixOut = Min_Game_Alpha + AS_UI;
		        }
		
		        //Composite mode 4 FPS
		        if(Alpha_Auto_UI == 4)
		        {
		            float Guided = FPS_Alpha_UI.y * OA_Power;
		            float Local  = FPS_Alpha_UI.x * OA_Power;
		            float S_UI   = lerp(0.0, 0.5, Avg_UI);
		
		            float C_UI_Value_A = lerp(0.4, 0.5, Avg_UI);
		            float FPS_Area_S   = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, texcoord_x_mirror) *
		                                          smoothstep(0.875, 0.5, texcoord.y) * 2.0);
		
		            Local = lerp(Local, lerp(Local, Store_MixOut, S_UI), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		
		            MixOut = lerp(Guided, lerp(Guided, Local, FPS_Area_S), Avg_UI);
		        }
		
		        //Composite mode 5 Third Person
		        if(Alpha_Auto_UI == 5)
		        {
		            float Guided = TRD_Alpha_UI.y * OA_Power;
		            float Local  = TRD_Alpha_UI.x * OA_Power;
		            float S_UI   = lerp(0.0, 0.5, Avg_UI);
		
		            float C_UI_Value_A = lerp(0.25, 0.35, Avg_UI);
		            float FPS_Area_S   = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, texcoord_x_mirror) *
		                                          smoothstep(0.875, 0.5, texcoord.y) * 2.0);
		
		            Local = lerp(Local, lerp(Local, Store_MixOut, S_UI), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		
		            MixOut = lerp(Guided, lerp(Guided, Local, FPS_Area_S), Avg_UI);
		        }
		
		        //Composite mode 6 Third Person Stencil
		        if(Alpha_Auto_UI == 6)
		        {
		            float Local  = TRD_Alpha_UI.x * OA_Power;
		            float Guided = TRD_Alpha_UI.y * OA_Power;
		
		            float S_UI = smoothstep(0.375, 1.0, Avg_UI);
		
		            float2 C_RT_Scale = float2(0.25, 0.5);
		            float C_UI_Value_A = 0.4375;
		
		            float TRD_Area_S = smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, texcoord_x_mirror);
		                  TRD_Area_S = saturate(lerp(TRD_Area_S, 1, texcoord.y < 0.25) +
		                                        smoothstep(C_RT_Scale.x, C_RT_Scale.y, 1 - texcoord.y) * 2);
		                  TRD_Area_S = smoothstep(0.0, 1.0, TRD_Area_S);
		                  TRD_Area_S = lerp(TRD_Area_S, 1.0, IM_Stencil(texcoord, -0.5, 1.5, 1) * 0.4375 + 0.4375);
		
		            float LargeCenter = saturate(tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, 6)).x);
		
		            MixOut = lerp(Guided, Local, lerp(1.0, TRD_Area_S, LargeCenter));
		            MixOut = lerp(Local, MixOut, S_UI);
		        }
		
		        //Composite mode 7 Third and First Person Hybrid
		        if(Alpha_Auto_UI == 7)
		        {
		            float Guided = TRD_Alpha_UI.y * OA_Power;
		            float Local  = FPS_Alpha_UI.x * OA_Power;
		            float S_UI   = lerp(0.0, 0.5, Avg_UI);
		
		            float C_UI_Value_A = lerp(0.45, 0.55, Avg_UI);
		            float FPS_Area_S   = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, texcoord_x_mirror) *
		                                          smoothstep(0.75, 0.5, texcoord.y > 0.5 ? texcoord.y : 1 - texcoord.y) * 2);
		
		            Local = lerp(Local, lerp(Local, Store_MixOut, S_UI), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		
		            MixOut = lerp(Guided, lerp(Guided, Local, FPS_Area_S), Avg_UI);
		        }
		
		        //Composite mode 8 Third Person Center Weighted
		        if(Alpha_Auto_UI == 8)
		        {
		            float Guided = TRD_Alpha_UI.y * OA_Power;
		            float Local  = TRD_Alpha_UI.x * OA_Power;
		            float S_UI   = lerp(0.0, 0.5, Avg_UI);
		
		            float C_UI_Value_A  = 0.25;
		            float Center_Area_S = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, texcoord_x_mirror) *
		                                           smoothstep(0.8, 0.5, texcoord.y > 0.5 ? texcoord.y : 1 - texcoord.y) * 2);
		
		            Local = lerp(Local, lerp(Local, Store_MixOut, S_UI), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		
		            MixOut = lerp(Guided, Local, Center_Area_S * 0.9);
		            MixOut = lerp(Guided, MixOut, Avg_UI);
		        }
		
		        //Composite modes 9, 10, 11 Third and First Person Wide Mask
		        if(Alpha_Auto_UI == 9 || Alpha_Auto_UI == 10 || Alpha_Auto_UI == 11)
		        {
		            float Guided = TRD_Alpha_UI.y * OA_Power;
		            float Local  = FPS_Alpha_UI.x * OA_Power;
		            float S_UI   = lerp(0.0, 0.5, Avg_UI_halved);
		            float S_Mask = lerp(0, -0.7, Avg_UI_halved);
		            float C_UI_Value_A = lerp(1.0, 0.5, Avg_UI);
		
		            float FPS_Area_S = texcoord.x < 0.5 ? smoothstep(S_Mask, 0.5, texcoord.x)
		                                                 : smoothstep(S_Mask, 0.5, 1 - texcoord.x);
		                  FPS_Area_S = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, FPS_Area_S) *
		                                        smoothstep(0.75, 0.5, texcoord.y > 0.5
		                                            ? smoothstep(-0.5, 1.75, texcoord.y)
		                                            : smoothstep(0.125, 1.75, 1 - texcoord.y)));
		
		            Local = lerp(Local, lerp(Local, Store_MixOut, S_UI), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		
		            MixOut = lerp(Guided, lerp(Guided, Local, FPS_Area_S), Avg_UI);
		        }
		
		        //Composite mode 12 Min-FPSP (blend of mode 8 and mode 10)
		        if(Alpha_Auto_UI == 12)
		        {
		            float Guided  = TRD_Alpha_UI.y * OA_Power;
		            float Vicinal = TRD_Alpha_UI.x * OA_Power;
		            float Local   = FPS_Alpha_UI.x * OA_Power;
	
		            //Mode 8 side: center weighted.
		            float S_UI_8        = lerp(0.0, 0.5, Avg_UI);
		            float C_UI_Value_8  = 0.25;
		            float Center_Area_S = saturate(smoothstep(C_UI_Value_8 * 0.5, C_UI_Value_8, texcoord_x_mirror) *
		                                           smoothstep(0.8, 0.5, texcoord.y > 0.5 ? texcoord.y : 1 - texcoord.y) * 2);
	
		            float Local_8  = lerp(Vicinal, lerp(Vicinal, Store_MixOut, S_UI_8), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		            float MixOut_8 = lerp(Guided, Local_8, Center_Area_S * 0.9);
		                  MixOut_8 = lerp(Guided, MixOut_8, Avg_UI);
	
		            //Mode 10 side: wide mask.
		            float S_UI_10      = lerp(0.0, 0.5, Avg_UI_halved);
		            float S_Mask       = lerp(0, -0.7, Avg_UI_halved);
		            float C_UI_Value_A = lerp(1.0, 0.5, Avg_UI);
	
		            float FPS_Area_S = texcoord.x < 0.5 ? smoothstep(S_Mask, 0.5, texcoord.x)
		                                                 : smoothstep(S_Mask, 0.5, 1 - texcoord.x);
		                  FPS_Area_S = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, FPS_Area_S) *
		                                        smoothstep(0.75, 0.5, texcoord.y > 0.5
		                                            ? smoothstep(-0.5, 1.75, texcoord.y)
		                                            : smoothstep(0.125, 1.75, 1 - texcoord.y)));
	
		            float Local_10  = lerp(Local, lerp(Local, Store_MixOut, S_UI_10), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		            float MixOut_10 = lerp(Guided, lerp(Guided, Local_10, FPS_Area_S), Avg_UI);
	
					float EdgeCenter = lerp(0.0, 0.5, min(texcoord_x_mirror, texcoord_y_mirror) );
					MixOut = lerp(MixOut_8, MixOut_10, EdgeCenter);
		        }
		
		        //Composite mode 13 Min-FPSP (blend of mode 8 and mode 9)
		        if(Alpha_Auto_UI == 13)
		        {
		            float Guided  = TRD_Alpha_UI.y * OA_Power;
		            float Vicinal = TRD_Alpha_UI.x * OA_Power;
		            float Local   = FPS_Alpha_UI.x * OA_Power;
	
		            //Mode 8 side: center weighted.
		            float S_UI_8        = lerp(0.0, 0.5, Avg_UI);
		            float C_UI_Value_8  = 0.25;
		            float Center_Area_S = saturate(smoothstep(C_UI_Value_8 * 0.5, C_UI_Value_8, texcoord_x_mirror) *
		                                           smoothstep(0.8, 0.5, texcoord.y > 0.5 ? texcoord.y : 1 - texcoord.y) * 2);
	
		            float Local_8  = lerp(Vicinal, lerp(Vicinal, Store_MixOut, S_UI_8), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		            float MixOut_8 = lerp(Guided, Local_8, Center_Area_S * 0.9);
		                  MixOut_8 = lerp(Guided, MixOut_8, Avg_UI);
	
		            //Mode 9 side: wide mask.
		            float S_UI_9       = lerp(0.0, 0.5, Avg_UI_halved);
		            float S_Mask       = lerp(0, -0.7, Avg_UI_halved);
		            float C_UI_Value_A = lerp(1.0, 0.5, Avg_UI);
	
		            float FPS_Area_S = texcoord.x < 0.5 ? smoothstep(S_Mask, 0.5, texcoord.x)
		                                                 : smoothstep(S_Mask, 0.5, 1 - texcoord.x);
		                  FPS_Area_S = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, FPS_Area_S) *
		                                        smoothstep(0.75, 0.5, texcoord.y > 0.5
		                                            ? smoothstep(-0.5, 1.75, texcoord.y)
		                                            : smoothstep(0.125, 1.75, 1 - texcoord.y)));
	
		            float Local_9  = lerp(Local, lerp(Local, Store_MixOut, S_UI_9), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
		            float MixOut_9 = lerp(Guided, lerp(Guided, Local_9, FPS_Area_S), Avg_UI);
	
		            float EdgeCenter = lerp(0.0, 0.5, min(texcoord_x_mirror, texcoord_y_mirror));
		            MixOut = lerp(MixOut_8, MixOut_9, EdgeCenter);
		        }
		
		        //Post processing.
		        if(Bound_UI > 0)
		            MixOut = max(-(1 - Bound_UI), MixOut);
		
		        MixOut = lerp(Store_MixOut, MixOut, Alpha_Letter_Box);
		
		        if(Read_Controller_AUI)
		            Avg_UI = lerp(Avg_UI, 1.0, Controller_RT);
		
		        if(Alpha_Auto_UI <= 3)
		            MixOut *= OA_Power;
		
		        if(Alpha_UI_FullScreen)
		        {
		            if(Avg_UI == 0)
		            {
		                Avg_UI = 1.0;
		                MixOut = Store_MixOut;
		            }
		        }
		
		        if(Alpha_UI_LetterBox)
		        {
		            if(Avg_UI == 0 && LBDetection())
		            {
		                Avg_UI = 1.0;
		                MixOut = Store_MixOut;
		            }
		        }
		
		        if(!Isolate_UI)
		            MixOut = lerp(0.025, MixOut, Avg_UI);

		        #if !DX9_Toggle
		        if(UI_LB_Flatten && DB_AutoFit && DB_Res_Info.x > 0 && DB_Res_Info.y > 0 &&
		           DB_Viewport_Size.z > 0 && DB_Viewport_Size.w > 0)
		        {
		            float2 LB_Ref = (DB_Render_Size.x > 0) ? DB_Render_Size : float2(BUFFER_WIDTH, BUFFER_HEIGHT);
		            float2 LB_Fit = DB_Viewport_Size.zw / DB_Res_Info;
		            float2 LB_Org = DB_Viewport_Size.xy / DB_Res_Info;
		            if(abs(DB_Viewport_Size.z * LB_Ref.y - DB_Viewport_Size.w * LB_Ref.x) > LB_Ref.x * DB_Viewport_Size.w * 0.02)
		            {
		                LB_Fit = LB_Ref / DB_Res_Info;
		                LB_Org = (DB_Viewport_Size.xy - (LB_Ref - DB_Viewport_Size.zw) * 0.5) / DB_Res_Info;
		            }
		            //Invert the mapping: where the rendered sub rect starts and ends in screen space.
		            float2 LB_Start = (DB_Viewport_Size.xy / DB_Res_Info - LB_Org) / LB_Fit;
		            float2 LB_End   = ((DB_Viewport_Size.xy + DB_Viewport_Size.zw) / DB_Res_Info - LB_Org) / LB_Fit;
		            float2 LB_Has_Bar = float2(LB_Start.x > 0.002 || LB_End.x < 0.998,
		                                       LB_Start.y > 0.002 || LB_End.y < 0.998);
		            float2 LB_Trim = UI_LB_Edge * pix / Depth_Rez * LB_Has_Bar;
		            LB_Start += LB_Trim;
		            LB_End   -= LB_Trim;
		            //Strength follows Avg_UI like the rest of the block.
		            if(texcoord.y < LB_Start.y || texcoord.y > LB_End.y ||
		               texcoord.x < LB_Start.x || texcoord.x > LB_End.x)
		                MixOut = lerp(MixOut, UI_LB_Depth, Avg_UI);
		        }
		        #endif
		    }
		}
		#endif
	}

	//Up and down at any step, so tops and tips survive TAA jitter.
	static const bool Vert_Dilate = true;
	static const float DS_Side_Texels = 1.0, DS_Side_Tuned = 2.0;
	static const float Recon_Step_0 = 1.25, Recon_Step_1 = 1.5, Recon_Step_2 = 1.75;
	#define Recon_Step (Reconstruction_Size == 2 ? Recon_Step_2 : Reconstruction_Size == 1 ? Recon_Step_1 : Recon_Step_0)

	//AA runs on the raw depth, then DepthSmoothPS dilates it.
	#if DX9_Toggle
		#define AA_Src_P SamplerzBufferB_Smooth //Reads texel centres only.
		#define AA_Src_B SamplerzBufferB_Smooth
	#else
		#define AA_Src_P SamplerzBufferP_Up
		#define AA_Src_B SamplerzBufferB_Up
	#endif
	//DX9.
	#if DX9_Toggle
		#define DS_Src SamplerzBufferP_Mixed
	#else
		#define DS_Src SamplerzBufferP_Up
	#endif

	#if Set_Depth_Res == 1
	    #define Depth_Set_Size 1.75
	#elif Set_Depth_Res == 2
	    #define Depth_Set_Size 2.0   
	#else
	    #define Depth_Set_Size 1.0
	#endif
	
	//Depth AA.
	static const float Depth_AA = 1.0, AA_Radius = 1.0, AA_Scale = 0.125, AA_Skip = 0.02;
	//Depth is signed past ZPD, so the mask needs abs() and a floor.
	static const float AA_Floor = 0.05;
	//Tangent walk: the 9 tap sigma 2 Gaussian folded into 2 bilinear pairs per side.
	static const float2 AA_PO = float2(1.40733, 3.29423);
	static const float2 AA_PW = float2(1.48903, 0.45999);
	static const float AA_RW = 0.204163; //1 / (1 + 2*(1.48903 + 0.45999)), literal.
	//Straight edge test.
	static const float2 AA_Corner = float2(1.5, 2.2);
	static const float2 AA_Coh = float2(0.7, 0.9);
	
	//Sobel direction from 4 bilinear taps, same signs as the centre. Zero if flat.
	float2 Edge_Dir(sampler Tex, float2 tc, float2 Tx)
	{
	    float a = tex2Dlod(Tex, float4(saturate(tc + float2(-0.5, -0.5) * Tx), 0, 0)).x;
	    float b = tex2Dlod(Tex, float4(saturate(tc + float2( 0.5, -0.5) * Tx), 0, 0)).x;
	    float c = tex2Dlod(Tex, float4(saturate(tc + float2(-0.5,  0.5) * Tx), 0, 0)).x;
	    float d = tex2Dlod(Tex, float4(saturate(tc + float2( 0.5,  0.5) * Tx), 0, 0)).x;
	    float2 g = float2((a + c) - (b + d), (a + b) - (c + d));
	    float l = length(g);
	    return l > 0.000001 ? g / l : 0;
	}
	
	float Side_Window_Gauss(sampler Tex, float2 tc)
	{
	    float2 Tx = rcp_Depth_Size();
#if DX9_Toggle
	    float s2 = rcp(max(AA_Radius * AA_Radius, 0.01));
	    float Wp = exp(-0.5 * s2) + exp(-2.0 * s2);
	    float Op = (exp(-0.5 * s2) + 2.0 * exp(-2.0 * s2)) * rcp(Wp);
	    float3 O = float3(-Op, 0.0, Op), W = float3(Wp, 1.0, Wp);
	    float Bk[9];
	    SD_UNROLL
	    for(int j = 0; j < 3; j++)
	    {
	        SD_UNROLL
	        for(int i = 0; i < 3; i++)
	            Bk[j * 3 + i] = tex2Dlod(Tex, float4(saturate(tc + float2(O[i], O[j]) * Tx), 0, 0)).x * W[i] * W[j];
	    }
	    float C = Bk[4];
	    float Wa = Wp + 1.0, Wt = 2.0 * Wp + 1.0;
	    float4 MH = float4(Bk[0] + Bk[1] + Bk[3] + Bk[4] + Bk[6] + Bk[7],
	                       Bk[1] + Bk[2] + Bk[4] + Bk[5] + Bk[7] + Bk[8],
	                       Bk[0] + Bk[1] + Bk[2] + Bk[3] + Bk[4] + Bk[5],
	                       Bk[3] + Bk[4] + Bk[5] + Bk[6] + Bk[7] + Bk[8]) * rcp(Wa * Wt);
	    float4 MQ = float4(Bk[0] + Bk[1] + Bk[3] + Bk[4],
	                       Bk[1] + Bk[2] + Bk[4] + Bk[5],
	                       Bk[3] + Bk[4] + Bk[6] + Bk[7],
	                       Bk[4] + Bk[5] + Bk[7] + Bk[8]) * rcp(Wa * Wa);
#else
	    float S[25];
	    SD_UNROLL
	    for(int gy = 0; gy < 3; gy++)
	    {
	        SD_UNROLL
	        for(int gx = 0; gx < 3; gx++)
	        {
	            int i = gx * 2, j = gy * 2;
	            float4 G = tex2DgatherR(Tex, tc + (float2(i, j) - 1.5) * Tx);
	            S[j * 5 + i] = G.w;
	            if(i < 4)
	                S[j * 5 + i + 1] = G.z;
	            if(j < 4)
	                S[(j + 1) * 5 + i] = G.x;
	            if(i < 4 && j < 4)
	                S[(j + 1) * 5 + i + 1] = G.y;
	        }
	    }
	    float C = S[12];
	    float4 SumH = 0, WH = 0, SumQ = 0, WQ = 0;
	    SD_UNROLL
	    for(int y = -2; y <= 2; y++)
	    {
	        SD_UNROLL
	        for(int x = -2; x <= 2; x++)
	        {
	            float v = S[(y + 2) * 5 + x + 2];
	            float w = exp(-0.5 * (x * x + y * y) * rcp(max(AA_Radius * AA_Radius, 0.01)));
	            float l = x <= 0 ? 1.0 : 0.0, r = x >= 0 ? 1.0 : 0.0;
	            float u = y <= 0 ? 1.0 : 0.0, d = y >= 0 ? 1.0 : 0.0;
	            float4 mH = float4(l, r, u, d);
	            float4 mQ = float4(l * u, r * u, l * d, r * d);
	            SumH += v * w * mH;
	            WH   += w * mH;
	            SumQ += v * w * mQ;
	            WQ   += w * mQ;
	        }
	    }
	    float4 MH = SumH / WH, MQ = SumQ / WQ;
#endif
	    float4 DH = abs(MH - C), DQ = abs(MQ - C);
	    float Best = MH.x, Dev = DH.x;
	    SD_UNROLL
	    for(int k = 0; k < 4; k++)
	    {
	        if(DH[k] < Dev)
	        {
	            Dev = DH[k];
	            Best = MH[k];
	        }
	        if(DQ[k] < Dev)
	        {
	            Dev = DQ[k];
	            Best = MQ[k];
	        }
	    }
	    return Best;
	}

	#if !DX9_Toggle
	#define Current_Buffer SamplerzBufferP_Mixed
	
	#if Anti_Jitter_Mode
				
	//One real depth texel on screen.
	float2 Real_Texel()
	{
		float2 Fit_Size = tex2Dsize(DepthBuffer);
		#if GDM_DEPTH_AUTOFIT
		if(DB_AutoFit && DB_Res_Info.x > 0 && DB_Res_Info.y > 0 && DB_Viewport_Size.z > 0 && DB_Viewport_Size.w > 0)
		{
			float2 DB_Ref = (DB_Render_Size.x > 0) ? DB_Render_Size : float2(BUFFER_WIDTH, BUFFER_HEIGHT);
			Fit_Size = DB_Viewport_Size.zw;
			//Aspect mismatch: Mix_Z fits the reference size.
			if(abs(DB_Viewport_Size.z * DB_Ref.y - DB_Viewport_Size.w * DB_Ref.x) > DB_Ref.x * DB_Viewport_Size.w * 0.02)
				Fit_Size = DB_Ref;
		}
		#endif
		//Never finer than our own buffer.
		return max(rcp(Fit_Size), rcp(float2(BUFFER_WIDTH, BUFFER_HEIGHT) * Depth_Rez));
	}
	void TAA_Buffer(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float TAA_Out : SV_Target0)
	{
	    float Temporal;
	    //Sample the current frame.
	    float sceneDepth = tex2D(Current_Buffer, texcoord).x;
	    //x history frame, y single frame.
	    float2 Acc = tex2D(SamplerzACC, texcoord).xy;
	    float pastDepth = Acc.y, historyDepth = Acc.x;
	
	    //3x3 neighbourhood sampling (9 samples in total).
	    int2 offsets[9] =
	    {
	        int2(-1, -1), // top-left
	        int2( 0, -1), // top-center
	        int2( 1, -1), // top-right
	        int2(-1,  0), // middle-left
	        int2( 0,  0), // center (current pixel)
	        int2( 1,  0), // middle-right
	        int2(-1,  1), // bottom-left
	        int2( 0,  1), // bottom-center
	        int2( 1,  1)  // bottom-right
	    };
	
	    float2 texelSize = Real_Texel();
	    float Threshold = 0.01;
	    //Motion.
	    float Orig_C = Orig_Depth(texcoord), Orig_Min = Orig_C, Orig_Max = Orig_C;
	    SD_UNROLL
	    for (int j = 1; j < 9; j += 2)
	    {
	        float Orig_N = Orig_Depth(texcoord + offsets[j] * texelSize);
	        Orig_Min = min(Orig_Min, Orig_N);
	        Orig_Max = max(Orig_Max, Orig_N);
	    }
	    float Dist = max(0, max(Orig_Min - pastDepth, pastDepth - Orig_Max));
	    //Dynamic blend factor.
	    float motionLen = min(Dist, 1.0);
	    //Modes 2 to 4 lock when still. Full correction at a 0.04 change.
	    float motionFactor = saturate(sqrt(motionLen) * 5);
	
	    //Initialise with the centre pixel depth instead of extreme values.
	    float minDepth = sceneDepth;
	    float maxDepth = sceneDepth;
	    //Main clamp bounds from the 4 straight neighbours only.
	    float minC = sceneDepth, maxC = sceneDepth, minFbC = sceneDepth, maxFbC = sceneDepth;
	    int   vCountC = 0;
	
	    SD_UNROLL
	    for (int i = 0; i < 9; ++i)
	    {
	        float2 offsetUV = texcoord + offsets[i] * texelSize;
	        float neighborDepth = tex2Dlod(Current_Buffer, float4(offsetUV,0,0)).x;
	        //One sided: a nearer neighbour always agrees.
	        float neighborDiff = neighborDepth - sceneDepth;
	
	        //Skip the centre pixel (index 4) for the neighbourhood analysis.
	        if (i == 4) continue;

	        if (i == 1 || i == 3 || i == 5 || i == 7)
	        {
	            minFbC = min(minFbC, neighborDepth);
	            maxFbC = max(maxFbC, neighborDepth);
	            if (neighborDiff <= Threshold)
	            {
	                minC = min(minC, neighborDepth);
	                maxC = max(maxC, neighborDepth);
	                ++vCountC;
	            }
	        }
	    }
	    //Bounds from the 4 straight neighbours, fewer than 2 agreeing takes the fallback.
	    minDepth = vCountC < 2 ? minFbC : minC;
	    maxDepth = vCountC < 2 ? maxFbC : maxC;
	
	    //Clamp the history inside a depth aware soft AABB.
	    float clampedHistoryDepth = clamp(historyDepth, minDepth, maxDepth);
	
		//Final blend.
	    #if Anti_Jitter_Mode == 4
	    //Stable: locks when static, slight correction under motion.
	    float taaMix = lerp(0.0, 0.1, motionFactor);
	    Temporal = lerp(clampedHistoryDepth, sceneDepth, taaMix);
	    #elif Anti_Jitter_Mode == 3
	    //Balanced: locks like mode 1 when static, mild correction under motion.
	    float taaMix = lerp(0.0, 0.25, motionFactor);
	    Temporal = lerp(clampedHistoryDepth, sceneDepth, taaMix);
	    #elif Anti_Jitter_Mode == 2
	    //Weak: always blends toward the current frame.
	    float taaMix = lerp(0.05, 0.5, motionFactor);
	    Temporal = lerp(clampedHistoryDepth, sceneDepth, taaMix);
	    #else
	    //Strong: pure clamped history.
	    Temporal = clampedHistoryDepth;
	    #endif
	    TAA_Out = Temporal;
	}
	#endif
	
	#if Anti_Jitter_Mode
		#define R_Sampler SamplerzBufferP_TAA
	#else
		#define R_Sampler SamplerzBufferP_Mixed
	#endif

	//One depth tap.
	float R_Tap(sampler Tex, float2 uv)
	{
	    return tex2Dlod(Tex, float4(uv, 0, 0)).x;
	}

	//Plain: the smoothing walk (same reads as R_Tap).
	float Min3x3(sampler2D Tex, float2 TC, float2 Depth_Size, bool Plain, out float2 Grad, out float Range, out float Mid)
	{
	    static const float2 offsets[9] = { float2(-1, -1), float2( 0, -1), float2( 1, -1),
									       float2(-1,  0), float2( 0,  0), float2( 1,  0),
									       float2(-1,  1), float2( 0,  1), float2( 1,  1) };
	    float v[9];
	    float minVal = 1e10, maxVal = -1e10;
	    bool  Gathered = false;
	    #if !DX9_Toggle
	    //Gathered.
	    float2 Sz = tex2Dsize(Tex), Ofs = Depth_Size * Sz;
	    [branch]
	    //The walk too: the reads are the same.
	    if(all(Ofs > 0.53) && all(Ofs < 1.47))
	    {
	        float2 Ts = rcp(Sz);
	        float4 TL = tex2DgatherR(Tex, TC - 0.5 * Ts),               TR = tex2DgatherR(Tex, TC + float2( 0.5, -0.5) * Ts),
	               BL = tex2DgatherR(Tex, TC + float2(-0.5, 0.5) * Ts), BR = tex2DgatherR(Tex, TC + 0.5 * Ts);
	        //Gather order: w top left, z top right, x bottom left, y bottom right.
	        v[0] = TL.w; v[1] = TL.z; v[2] = TR.z;
	        v[3] = TL.x; v[4] = TL.y; v[5] = TR.y;
	        v[6] = BL.x; v[7] = BL.y; v[8] = BR.y;
	        Gathered = true;
	    }
	    #endif
	    [branch]
	    if(!Gathered)
	    {
	        SD_UNROLL
	        for (int i = 0; i < 9; i++)
	            v[i] = Plain ? tex2Dlod(Tex, float4(TC + offsets[i] * Depth_Size, 0, 0)).x : R_Tap(Tex, TC + offsets[i] * Depth_Size);
	    }
	    SD_UNROLL
	    for (int k = 0; k < 9; k++)
	    {
	        minVal = min(minVal, v[k]);
	        maxVal = max(maxVal, v[k]);
	    }
	    Range = maxVal - minVal;
	    Mid = v[4]; //The centre tap, offset 0.
	    //Local depth gradient from the same nine taps, no extra fetches. Drives the ramp tilt.
	    Grad = float2((v[2] + v[5] + v[8]) - (v[0] + v[3] + v[6]),
	                  (v[6] + v[7] + v[8]) - (v[0] + v[1] + v[2]));
	    return minVal;
	}

	//D_Min is the Min3x3 part, D_Ramp the ramp average. The result is min(D_Ramp, D_Min).
	float Disocclusion(sampler Tex, float2 texcoord, float2 DPix, bool Plain, out float D_Min, out float D_Ramp, out float Range, out float Own) // Non_Point_Sampler
	{
		float Recon_Size = Recon_Step;

	    float2 Grad;
	    float Depth = Min3x3(Tex, texcoord, DPix * Recon_Size, Plain, Grad, Range, Own), DM = 0.0f;
	    D_Min = Depth;
	    D_Ramp = Depth;

		const int N = 8;
		const float2 dir = float2(0.5f, 0.0f);
	    const float MS = abs(Divergence_Switch().y) * 0.0005, Disocclusion_Adjust = 5.5f, Div = rcp(N + 1);
		const float weight[N] = { 0.0125f,-0.0125f, 0.0175f,-0.0175f, 0.03f, -0.03f, 0.05f,-0.05f };
		//Structure following tilt: taps ride the silhouette slope so slanted edges stay coherent,
		//flat tops and clean verticals stay untouched.
		float Tilt = clamp(-Grad.x * Grad.y * rcp(Grad.y * Grad.y + 1e-4), -0.35f, 0.35f);
		if(View_Mode != 3 && View_Mode != 6)
		{
	        DM = Depth * Div;
	
	        float2 Ob = float2(dir.x, dir.x * Tilt) * (MS * Disocclusion_Adjust);
	        SD_UNROLL
	        for (int i = 0; i < N; i++)
	        #if Anti_Jitter_Mode
	            //A rebuilt thin object gets its ramp too. TAABuffer has no mips, so level 0 is the same.
	            DM += (Plain ? tex2Dlod(Tex, float4(texcoord + Ob * weight[i], 0, 0)).x : R_Tap(Tex, texcoord + Ob * weight[i])) * Div;
	        #else
	            DM += tex2Dlod(Tex, float4(texcoord + Ob * weight[i], 0, 1)).x * Div;//Mip 1 keeps thin objects.
	        #endif
	
	    	D_Ramp = DM;
	    	return min(DM, Depth);
	    }
	    else
	    	return Depth;
	}
	
	//The guided reconstruction at one spot.
	float Recon_Guided(float2 texcoord, out float Range, out float Ramp_Gap, out float Own)
	{
		float D_Min, D_Ramp;
		//Own is the Min3x3 centre tap (R_Tap at texcoord), shared with ReconstructionPS.
		float Recon = Disocclusion(R_Sampler, texcoord, rcp_Depth_Size(), false, D_Min, D_Ramp, Range, Own);
		//How much nearer the ramp pulls than the Min3x3.
		Ramp_Gap = D_Min - D_Ramp;
		//Colour guided Min3x3: a pulled pixel coloured like the background gets its own depth back, and an object depth
		//pixel coloured like the background takes the background's depth. The ramp is not guided, the infill needs it.
		//No [branch]: the condition is menu only, and in 2D+Depth (View Mode fixed) ReShade folds this if away and its
		//attribute landed on the inner if, a duplicate [branch] that failed the compile.
		if(View_Mode != 3 && View_Mode != 6)
		{
			bool Pulled = Own - Recon > 0.001;
			[branch]
			if(Pulled || Range > 0.002)
			{
				//The ramp's outer reach, at least one Min3x3 step. The nearer side is the object.
				float  Rch = max(abs(Divergence_Switch().y) * 0.0005 * 5.5 * 0.5 * 0.05,
				                 rcp_Depth_Size().x * Recon_Step);
				//Across the real edge, so tops and diagonals too. The nearer side is the object.
				float2 Rv  = float2(Rch, Rch * BUFFER_WIDTH * BUFFER_RCP_HEIGHT);
				float2 Gd  = float2(R_Tap(R_Sampler, texcoord + float2(Rv.x, 0)) - R_Tap(R_Sampler, texcoord - float2(Rv.x, 0)),
				                    R_Tap(R_Sampler, texcoord + float2(0, Rv.y)) - R_Tap(R_Sampler, texcoord - float2(0, Rv.y)));
				float2 Ob  = dot(Gd, Gd) > 1e-10 ? -normalize(Gd) * Rv : float2(-Rv.x, 0);
				float3 Cp  = tex2Dlod(Non_Point_Sampler, float4(texcoord, 0, 0)).rgb;
				float3 Co  = tex2Dlod(Non_Point_Sampler, float4(texcoord + Ob, 0, 0)).rgb;
				float3 Cb  = tex2Dlod(Non_Point_Sampler, float4(texcoord - Ob, 0, 0)).rgb;
				float  Dob = length(Co - Cb);
				float  Lt  = (length(Cp - Co) - length(Cp - Cb)) * rcp(Dob + 0.001);
				//Only clearly background pixels.
				float  W   = smoothstep(0.3, 0.8, Lt) * smoothstep(0.02, 0.08, Dob);
				//Not pulled: take the background's depth, only at a real edge (a thin object has background on both sides).
				float  Target = Own;
				bool   Edge_Ok = true;
				if(!Pulled)
				{
					Target  = R_Tap(R_Sampler, texcoord - Ob);
					Edge_Ok = Target > Own + 0.002 && R_Tap(R_Sampler, texcoord + Ob) < Own + 0.002;
					//All or nothing, or the edge goes soft.
					W = W > 0.5 ? 1.0 : 0.0;
				}
				//The ramp averages the Min3x3 depth in at one ninth, so it follows the guided value.
				if(Edge_Ok)
				{
					float Min_G = lerp(D_Min, Target, W);
					Recon = min(D_Ramp + (Min_G - D_Min) * rcp(9.0), Min_G);
				}
			}
		}
		return Recon;
	}

	//Smoothing walk taps.
	float Recon_Plain(float2 texcoord)
	{
		float D_Min, D_Ramp, Range, Own;
		return Disocclusion(R_Sampler, texcoord, rcp_Depth_Size(), true, D_Min, D_Ramp, Range, Own);
	}

	//Smooth edges.
	void ReconstructionPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float Recon : SV_Target0)
	{
		float Range, Ramp_Gap, Own;
		Recon = Recon_Guided(texcoord, Range, Ramp_Gap, Own);
		[branch]
		if(View_Mode == 3 || View_Mode == 6 || (Range <= 0.0005 && Ramp_Gap <= 0.0005))
			return;
		//Edge test two steps out, so the texels just outside the widening smooth too.
		float2 Tx = rcp_Depth_Size();
		float2 St = Tx * Recon_Step * 2.0;
		float  eL = tex2Dlod(R_Sampler, float4(texcoord - float2(St.x, 0), 0, 0)).x, eR = tex2Dlod(R_Sampler, float4(texcoord + float2(St.x, 0), 0, 0)).x;
		float  eU = tex2Dlod(R_Sampler, float4(texcoord - float2(0, St.y), 0, 0)).x, eD = tex2Dlod(R_Sampler, float4(texcoord + float2(0, St.y), 0, 0)).x;
		float  Rng = max(max(max(eL, eR), max(eU, eD)), Own) - min(min(min(eL, eR), min(eU, eD)), Own);
		float2 Eg  = float2(eR - eL, eD - eU);
		float  El  = length(Eg);
		//Thin features are not smoothed.
		bool   Ridge = Own < min(eL, eR) - 0.001 || Own < min(eU, eD) - 0.001;
		float  Edg = saturate(Rng * rcp(max(abs(Recon), AA_Floor) * AA_Scale));
		[branch]
		if(Rng > 0.0005 && El > 0.000001 && !Ridge && Edg > AA_Skip)
		{
			float2 Tn  = float2(-Eg.y, Eg.x) * rcp(El) * Tx * AA_PO.x;
			#if ISOGL //One copy of the plain reconstruction for the GL compiler.
			float  Rp = 0;
			[loop]
			for(int s = 0; s < 2; s++)
				Rp += Recon_Plain(texcoord + (s == 0 ? Tn : -Tn));
			float  Acc = Recon + Rp * AA_PW.x;
			#else
			float  Acc = Recon + (Recon_Plain(texcoord + Tn) + Recon_Plain(texcoord - Tn)) * AA_PW.x;
			#endif
			Recon = lerp(Recon, Acc * rcp(1.0 + 2.0 * AA_PW.x), Edg);
		}
	}

	void DepthSmoothPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float Smooth : SV_Target0)
	{
	    float Center = tex2Dlod(DS_Src, float4(texcoord, 0, 0)).x;
	    //Sideways exactly 1 texel, up and down half of Depth_Set_Size.
	    float2 DPix = rcp_Depth_Size() * float2(DS_Side_Texels, Depth_Set_Size * 0.5);
	
	    //Half a DS_Src texel, so the 2x2 block is the same at every Depth_Rez.
	    float4 Near = tex2DgatherR(DS_Src, texcoord - 0.5 * rcp(float2(BUFFER_WIDTH, BUFFER_HEIGHT) * Depth_Rez));
	    float MinNear = min(min(Near.x, Near.y), min(Near.z, Near.w));
	
	    float L = tex2Dlod(DS_Src, float4(texcoord - float2(DPix.x, 0), 0, 0)).x;
	    float R = tex2Dlod(DS_Src, float4(texcoord + float2(DPix.x, 0), 0, 0)).x;
	    float U = tex2Dlod(DS_Src, float4(texcoord - float2(0, DPix.y), 0, 0)).x;
	    float D = tex2Dlod(DS_Src, float4(texcoord + float2(0, DPix.y), 0, 0)).x;
	
	    float Smoothed;
	    
	    //Per axis, edge preserving. The wider alternative was behind Expand Depth.
	    {
	        float InvCenter = rcp(max(Center, 0.001));
	        float EdgeH = abs(R - L) * InvCenter;
	        float EdgeV = abs(D - U) * InvCenter;
	
	        float MinH = min(L, R);
	        float MinV = min(U, D);
	
	        float DepthRange = 0.05 * Center;
	        float RejectV    = step(abs(MinV    - Center), DepthRange);
	        float RejectNear = step(abs(MinNear - Center), DepthRange);
	
	        Smoothed = Center;
	        Smoothed = lerp(Smoothed, min(Smoothed, MinH),    saturate(EdgeH * 25.0));
	        Smoothed = lerp(Smoothed, min(Smoothed, MinV),    saturate(EdgeV * 25.0) * RejectV);
	        Smoothed = lerp(Smoothed, min(Smoothed, MinNear), saturate(EdgeH * EdgeV * 625.0) * RejectNear);
	        //No Vert_Dilate here: Reconstruction's Min3x3 covers up and down. DX9 keeps it.
	    }
	
	    Smooth = Smoothed;
	}
	#endif
	
	#if DX9_Toggle
	//Disocclusion() for DX9.
	void ReconstructionDX9PS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float Recon : SV_Target0)
	{
	    float2 T1 = rcp_Depth_Size();
	    float2 M3 = T1 * Recon_Step;
	    float v[9];
	    float Depth = 1e10;
	    SD_UNROLL
	    for(int k = 0; k < 9; k++)
	    {
	        v[k] = tex2Dlod(SamplerzBufferP_Mixed, float4(texcoord + float2(k % 3 - 1, k / 3 - 1) * M3, 0, 0)).x;
	        Depth = min(Depth, v[k]);
	    }
	    float2 Grad = float2((v[2] + v[5] + v[8]) - (v[0] + v[3] + v[6]),
	                         (v[6] + v[7] + v[8]) - (v[0] + v[1] + v[2]));
	    Recon = Depth;
	    #if !Use_2D_Plus_Depth //View_Mode is a constant there (see the DX10+ one).
	    [branch]
	    #endif
	    if(View_Mode != 3 && View_Mode != 6)
	    {
	        const int N = 6;
	        const float weight[N] = { 0.015f, -0.015f, 0.03f, -0.03f, 0.05f, -0.05f };
	        const float count[N]  = { 2.0, 2.0, 1.0, 1.0, 1.0, 1.0 };
	        const float MS = abs(Divergence_Switch().y) * 0.0005, Disocclusion_Adjust = 5.5f, Div = rcp(9.0);
	        float Tilt = clamp(-Grad.x * Grad.y * rcp(Grad.y * Grad.y + 1e-4), -0.35f, 0.35f);
	        float2 Ob = float2(0.5, 0.5 * Tilt) * (MS * Disocclusion_Adjust);
	        float DM = Depth * Div;
	        SD_UNROLL
	        for(int i = 0; i < N; i++)
	        {
	            float2 p = texcoord + Ob * weight[i];
	            //One bilinear read, a 2x2 average at the tap.
	            DM += tex2Dlod(SamplerzBufferB_Mixed, float4(p, 0, 0)).x * Div * count[i];
	        }
	        Recon = min(DM, Depth);
	    }
	}
	#endif

	#if DX9_Toggle //DX9 depth smoothing, point taps since SM3 has no gather.
	void DepthSmoothPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float Smooth : SV_Target0)
	{
	    float Center = tex2Dlod(DS_Src, float4(texcoord, 0, 0)).x;
	    float2 DPix = rcp_Depth_Size() * Depth_Set_Size;

	    //tex2DgatherR replacement.
	    float2 Dt = rcp(float2(BUFFER_WIDTH, BUFFER_HEIGHT) * Depth_Rez);
	    float N0 = tex2Dlod(DS_Src, float4(texcoord - Dt,              0, 0)).x;
	    float N1 = tex2Dlod(DS_Src, float4(texcoord - float2(0, Dt.y), 0, 0)).x;
	    float N2 = tex2Dlod(DS_Src, float4(texcoord - float2(Dt.x, 0), 0, 0)).x;
	    float N3 = tex2Dlod(DS_Src, float4(texcoord,                   0, 0)).x;
	    float MinNear = min(min(N0, N1), min(N2, N3));

	    float L = tex2Dlod(DS_Src, float4(texcoord - float2(DPix.x, 0), 0, 0)).x;
	    float R = tex2Dlod(DS_Src, float4(texcoord + float2(DPix.x, 0), 0, 0)).x;
	    float U = tex2Dlod(DS_Src, float4(texcoord - float2(0, DPix.y), 0, 0)).x;
	    float D = tex2Dlod(DS_Src, float4(texcoord + float2(0, DPix.y), 0, 0)).x;

	    float Smoothed;
	    //Per axis, edge preserving. The wider alternative was behind Expand Depth.
	    {
	        float InvCenter = rcp(max(Center, 0.001));
	        float EdgeH = abs(R - L) * InvCenter;
	        float EdgeV = abs(D - U) * InvCenter;
	        float MinH = min(L, R);
	        float MinV = min(U, D);
	        float DepthRange = 0.05 * Center;
	        float RejectV    = step(abs(MinV    - Center), DepthRange);
	        float RejectNear = step(abs(MinNear - Center), DepthRange);
	        Smoothed = Center;
	        Smoothed = lerp(Smoothed, min(Smoothed, MinH),    saturate(EdgeH * 25.0));
	        Smoothed = lerp(Smoothed, min(Smoothed, MinV),    saturate(EdgeV * 25.0) * RejectV);
	        Smoothed = lerp(Smoothed, min(Smoothed, MinNear), saturate(EdgeH * EdgeV * 625.0) * RejectNear);
	        if(Vert_Dilate)
	        {
	            //Read only when used, 2 fewer taps with Vert_Dilate off.
	            float U1 = tex2Dlod(DS_Src, float4(texcoord - float2(0, rcp(BUFFER_HEIGHT * Depth_Rez)), 0, 0)).x;
	            float D1 = tex2Dlod(DS_Src, float4(texcoord + float2(0, rcp(BUFFER_HEIGHT * Depth_Rez)), 0, 0)).x;
	            Smoothed = lerp(Smoothed, min(Smoothed, min(U1, D1)), saturate(abs(D1 - U1) * InvCenter * 25.0));
	        }
	    }

	    Smooth = Smoothed;
	}
	#endif

	//Depth AA pass: raw depth in, texSmooth out.
	void DepthAAPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out AA_Type Out : SV_Target0)
	{
	    float Center = tex2Dlod(AA_Src_P, float4(texcoord, 0, 0)).x;
	    float AA_Dbg = 0;
	    float2 Tx = rcp_Depth_Size();
#if DX9_Toggle
	    float tc = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(    0, -Tx.y)), 0, 0)).x;
	    float ml = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(-Tx.x,     0)), 0, 0)).x;
	    float mr = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2( Tx.x,     0)), 0, 0)).x;
	    float bc = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(    0,  Tx.y)), 0, 0)).x;
	    //No gather in DX9.
	    float Cr = 0.5 * AA_Skip * max(abs(Center), AA_Floor) * AA_Scale;
	    [branch]
	    if(Center >= min(min(tc, bc), min(ml, mr)) && Center <= max(max(tc, bc), max(ml, mr)) &&
	       abs(tc + bc - 2.0 * Center) <= 2.0 * Cr && abs(ml + mr - 2.0 * Center) <= 2.0 * Cr)
	    {
#if DEPTH_AA_PREVIEW
	        Out = float2(Center, 0);
#else
	        Out = Center;
#endif
	        return;
	    }
	    float tl = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(-Tx.x, -Tx.y)), 0, 0)).x;
	    float tr = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2( Tx.x, -Tx.y)), 0, 0)).x;
	    float bl = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(-Tx.x,  Tx.y)), 0, 0)).x;
	    float br = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2( Tx.x,  Tx.y)), 0, 0)).x;
#else
	    float4 Ga = tex2DgatherR(AA_Src_B, texcoord - 0.5 * Tx);
	    float4 Gb = tex2DgatherR(AA_Src_B, texcoord + 0.5 * Tx);
	    float tl = Ga.w, tc = Ga.z, ml = Ga.x;
	    float br = Gb.y, bc = Gb.x, mr = Gb.z;
	    float tr = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2( Tx.x, -Tx.y)), 0, 0)).x;
	    float bl = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(-Tx.x,  Tx.y)), 0, 0)).x;
#endif
	    float nMin = min(min(min(tl, tc), min(tr, ml)), min(min(mr, bl), min(bc, br)));
	    float nMax = max(max(max(tl, tc), max(tr, ml)), max(max(mr, bl), max(bc, br)));
	    //Despeckle first: a selection, so it removes outliers without inventing a depth.
	    float dsp  = clamp(Center, nMin, nMax);
	    float nAvg = (tl + tc + tr + ml + mr + bl + bc + br) * 0.125;
	    float curv = abs(dsp - nAvg);
	    float dx = ((tl + 2.0 * ml + bl) - (tr + 2.0 * mr + br)) * 0.25;
	    float dy = ((tl + 2.0 * tc + tr) - (bl + 2.0 * bc + br)) * 0.25;
	    float2 grd = float2(dx, dy);
	    float  slp = length(grd);
	    float2 dir = slp > 0.000001 ? grd / slp : float2(0.0, 1.0);
	    //abs and a real floor: depth is signed here, negative past the ZPD plane.
	    float edg = saturate(curv * rcp(max(abs(dsp), AA_Floor) * AA_Scale));
#if DEPTH_AA_PREVIEW == 1
	    AA_Dbg = edg;
#endif
	    //Flat areas skip the filter.
	    float res = dsp;
	    [branch]
	    if(edg > AA_Skip)
	    {
	        float2 tgt = float2(-dir.y, dir.x) * Tx * AA_Radius;
	        //Straight: same direction at both walk ends, and not a ridge.
	        float Str = smoothstep(AA_Corner.x * curv, AA_Corner.y * curv + 1e-6, slp);
	        //A ridge is already 0, so the direction check only runs where it can matter.
	        [branch]
	        if(Str > 0.0)
	        {
	            float Coh = min(dot(dir, Edge_Dir(AA_Src_B, texcoord + tgt * AA_PO.y, Tx)),
	                            dot(dir, Edge_Dir(AA_Src_B, texcoord - tgt * AA_PO.y, Tx)));
	            Str *= smoothstep(AA_Coh.x, AA_Coh.y, Coh);
	        }
#if DEPTH_AA_PREVIEW == 2
	        AA_Dbg = Str;
#endif
	        //Straight edges take the walk, corners and tips the side window.
	        float Walk = dsp, Side = dsp;
	        [branch]
	        if(Str > 0.0)
	        {
	            float acc = dsp;
	            acc += (tex2Dlod(AA_Src_B, float4(saturate(texcoord + tgt * AA_PO.x), 0, 0)).x + tex2Dlod(AA_Src_B, float4(saturate(texcoord - tgt * AA_PO.x), 0, 0)).x) * AA_PW.x;
	            acc += (tex2Dlod(AA_Src_B, float4(saturate(texcoord + tgt * AA_PO.y), 0, 0)).x + tex2Dlod(AA_Src_B, float4(saturate(texcoord - tgt * AA_PO.y), 0, 0)).x) * AA_PW.y;
	            Walk = acc * AA_RW;
	        }
	        [branch]
	        if(Str < 1.0)
	            Side = Side_Window_Gauss(AA_Src_B, texcoord);
	        res = lerp(dsp, lerp(Side, Walk, Str), edg);
	    }
	    res = lerp(Center, res, Depth_AA);
#if DEPTH_AA_PREVIEW
	    Out = float2(res, AA_Dbg);
#else
	    Out = res;
#endif
	}

	#if DX9_Toggle
		#define M_Sampler SamplerzBufferP_Mixed
	#else
		#define M_Sampler SamplerzBufferP_Up
	#endif
	
	float2 GetMixed(float2 texcoord, float Mips) //Sensitive Buffer.
	{
		//VM3 and VM4 read point style.
		if(View_Mode == 3 || View_Mode == 4)
		{
			float2 Sz = tex2Dsize(SamplerzBufferB_Smooth, 0);
			texcoord = (floor(texcoord * Sz) + 0.5) / Sz;
		}
		return tex2Dlod(SamplerzBufferB_Smooth,float4(texcoord,0,Mips)).x;
	}
	
	//Combines the original and artifact corrected depths.
	float2 GetMixed_Combined(float2 baseCoord, float2 shift)
	{
		//shift used to be the De_Art function
	    float G_Depth = GetMixed(baseCoord, 0).x;
	    float C_Depth = GetMixed(baseCoord - float2(shift.x, 0), 0).x;
	    return float2(G_Depth, C_Depth);
	}	
	#if !Use_2D_Plus_Depth	
	#if POM_MINH
	texture texMinH { Width = BUFFER_WIDTH * Depth_Rez / 16 + 1; Height = BUFFER_HEIGHT * Depth_Rez; Format = R16F; };
	sampler SamplerMinH
		{
			Texture = texMinH;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	void MinH_PS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float Out : SV_Target0)
	{
	    float2 Ts = rcp(tex2Dsize(SamplerzBufferB_Smooth));
	    float  X0 = (floor(position.x) * 16.0 + 0.5) * Ts.x;
	    float  Mn = 1e10;
	    #if !DX9_Toggle
	    //Gathered.
	    float4 G;
	    SD_UNROLL
	    for(int m = 0; m < 8; m++)
	    {
	        float X = X0 + (2.0 * m + 0.5) * Ts.x;
	        G  = tex2DgatherR(SamplerzBufferB_Smooth, float2(X, texcoord.y - 0.5 * Ts.y));
	        Mn = min(Mn, min(min(G.x, G.y), min(G.z, G.w)));
	        G  = tex2DgatherR(SamplerzBufferB_Smooth, float2(X, texcoord.y + 0.5 * Ts.y));
	        Mn = min(Mn, min(min(G.x, G.y), min(G.z, G.w)));
	    }
	    #else
	    SD_UNROLL
	    for(int j = -1; j <= 1; j++)
	    {
	        SD_UNROLL
	        for(int i = 0; i < 16; i++)
	            Mn = min(Mn, tex2Dlod(SamplerzBufferB_Smooth, float4(X0 + i * Ts.x, texcoord.y + j * Ts.y, 0, 0)).x);
	    }
	    #endif
	    Out = Mn;
	}
	//Nearest depth anywhere between two x positions no more than 16 depth texels apart.
	float MinH_Span(float xa, float xb, float y)
	{
	    float  Wd = tex2Dsize(SamplerzBufferB_Smooth).x, Tw = rcp(tex2Dsize(SamplerMinH).x);
	    float2 Rn = (floor(floor(float2(xa, xb) * Wd) / 16.0) + 0.5) * Tw;
	    return min(tex2Dlod(SamplerMinH, float4(Rn.x, y, 0, 0)).x, tex2Dlod(SamplerMinH, float4(Rn.y, y, 0, 0)).x);
	}
	#endif
	//Perf Level selection & Array access               X      Y      
	static const float2 Performance_LvL[3] = { float2( 0.625, 0.75),
											   float2( 0.75, 1.00),
											   float2( 1.0, 1.25)};
	#if !Handheld_Mode
	//Distance Field Skip per Perf level                X      Y
	static const float2 DF_Skip_LvL[3] = { float2( 2.0 , 1.25 ),
										   float2( 1.5 , 1.5 ),
										   float2( 1.0 , 2.0 )};
	#endif
	//VM0 structure field, read by Parallax.
	#if VM0_FIELD
	float4 SF_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		//Guidefill leaves foreground ("bystander") pixels out of the tensor.
		float4 Dn = tex2DgatherR(SamplerzBufferN_P, texcoord);
		float  W  = max(max(Dn.x, Dn.y), max(Dn.z, Dn.w)) - min(min(Dn.x, Dn.y), min(Dn.z, Dn.w)) < 0.02;
		//Pre-smoothed gradients, as coherence transport smooths the image before taking them.
		float  TL = dot(CSB(texcoord + float2(-pix.x, -pix.y)).rgb, float3(0.299, 0.587, 0.114));
		float  TR = dot(CSB(texcoord + float2( pix.x, -pix.y)).rgb, float3(0.299, 0.587, 0.114));
		float  BL = dot(CSB(texcoord + float2(-pix.x,  pix.y)).rgb, float3(0.299, 0.587, 0.114));
		float  BR = dot(CSB(texcoord + float2( pix.x,  pix.y)).rgb, float3(0.299, 0.587, 0.114));
		float  gx = 0.5 * ((TR + BR) - (TL + BL));
		float  gy = 0.5 * ((BL + BR) - (TL + TR));
		//w: this spot's depth, so a read can tell when its averaged area took in a nearer object.
		return float4(float3(gx * gx, gy * gy, gx * gy) * W, (Dn.x + Dn.y + Dn.z + Dn.w) * 0.25);
	}
	#endif

	//////////////////////////////////////////////////////////Parallax Generation///////////////////////////////////////////////////////////////////////
	//VM0.
	//S = sqrt((Jxx - Jyy)^2 + 4 Jxy^2). With no cross term (exactly flat or exactly vertical) it is 0, the plain stretch.
	float SF_Slope(float3 J, float S)
	{
		float Sr = abs(J.z) > 1e-12 ? (J.y - J.x - S) * rcp(2.0 * J.z) : 0.0;
		//Near horizontal snaps to flat (fading in from 0.05 to 0.15).
		return abs(Sr) < 1000.0 ? clamp(Sr, -2.0, 2.0) * smoothstep(0.05, 0.15, abs(Sr)) : 0.0;
	}
	#define GetMixed_P(TC, M) (VM4_Lin ? tex2Dlod(SamplerzBufferB_Smooth, float4(TC, 0, M)).xx : GetMixed(TC, M))
	#if MEM_INFILL
	//Last frame's set, handed in by each pass: a pass never names the set it writes.
	float4 Mem_Prev(float2 uv, sampler PM)
	{
		return tex2Dlod(PM, float4(uv, 0, 0));
	}
	float Age_Prev(float2 uv, sampler PA)
	{
		return tex2Dlod(PA, float4(uv, 0, 0)).x;
	}

	//Keep covered background (farther than what is visible now), else store what is visible.
	void Mem_Core(float2 texcoord, sampler PM, sampler PA, out float4 Mem, out float Age)
	{
		float  Dn = GetMixed(texcoord, 0).x;
		float2 Mo = tex2Dlod(Sampler_MV, float4(texcoord, 0, 0)).xy;
		float  Trust = Cam_Trust();
		float2 Tp = texcoord - Mo.xy;
		float4 Mp = Mem_Prev(Tp, PM);
		//Background motion, only next to an object or where the memory is farther.
		bool   Near_Edge = GetMixed(texcoord - float2(16.0 * pix.x, 0), 0).x > Dn + 0.01 || GetMixed(texcoord + float2(16.0 * pix.x, 0), 0).x > Dn + 0.01;
		[branch]
		if(Near_Edge || Mp.a > Dn + 0.01)
		{
			//Covered background moves like the visible background beside it: the farthest pixel within 128 px.
			const float Reach[10] = { -128.0, -64.0, -32.0, -16.0, -8.0, 8.0, 16.0, 32.0, 64.0, 128.0 };
			float  Db = Dn;
			float2 MVb = Mo;
			[unroll]
			for(int k = 0; k < 10; k++)
			{
				float2 o = float2(Reach[k] * pix.x, 0.0);
				float  d = GetMixed(texcoord + o, 0).x;
				if(d > Db)
				{
					Db = d;
					MVb = tex2Dlod(Sampler_MV, float4(texcoord + o, 0, 0)).xy;
				}
			}
			if(Db > Dn + 0.01)
			{
				Mo = MVb;
				Tp = texcoord - Mo.xy;
				Mp = Mem_Prev(Tp, PM);
			}
			//Exact: the add-on's camera at the remembered depth.
			[branch]
			if(Mp.a > Dn + 0.01)
			{
				bool   Cam_Ok;
				float2 Te = texcoord - Cam_Motion_Depth(texcoord, Mp.a, Cam_Ok);
				float4 Me = Mem_Prev(Te, PM);
				if(Cam_Ok && Me.a > Dn + 0.01 && abs(Me.a - Mp.a) < 0.05)
				{
					Tp = Te;
					Mp = Me;
				}
			}
		}
		float  Ap = Age_Prev(Tp, PA);
		bool   In = Trust > 0.25 && all(Tp > 0.0) && all(Tp < 1.0);
		//Ages only while the background moves, so a still view holds it. Never 0 when covered.
		float  Speed = saturate(length(Mo.xy * float2(BUFFER_WIDTH, BUFFER_HEIGHT)) * 0.25);
		[branch]
		if(In && Ap < MEM_MAX_AGE && Mp.a > Dn + 0.01)
		{
			Mem = Mp;
			Age = Ap + max(frametime, 0.1) * 0.001 * Speed + 0.0001;
			return;
		}
		//Visible: age 0. Steady: same depth and a similar colour builds up half and half, like TAA history.
		float3 Cn = CSB(texcoord).rgb;
		bool   Steady = In && Ap < 0.5 && abs(Mp.a - Dn) < 0.01 && dot(abs(Cn - Mp.rgb), float3(0.299, 0.587, 0.114)) < 0.1;
		Mem = float4(Steady ? lerp(Mp.rgb, Cn, 0.5) : Cn, Dn);
		Age = 0.0;
	}
	//Even frames write A and read B, odd frames write B and read A.
	void Mem_PS_A(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Mem : SV_Target0, out float Age : SV_Target1)
	{
		Mem_Core(texcoord, Sampler_MemB, Sampler_AgeB, Mem, Age);
	}
	void Mem_PS_B(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Mem : SV_Target0, out float Age : SV_Target1)
	{
		Mem_Core(texcoord, Sampler_MemA, Sampler_AgeA, Mem, Age);
	}
	#endif

	float4 Parallax(float Diverge, float2 Coordinates, float IO) //Horizontal parallax offset & hole filling effect.
	{
	    //Divergence to Pixel Space
	    float  MS = Diverge * pix.x;
	    //Frosted's grain is landing error, which cannot exceed a layer, so High's fine march would erase it. VM6 always
	    //marches at Normal: same look on every Performance Level.
	    uint Perf_LvL = View_Mode == 6 ? 1 : fmod(Performance_Level,3);
	    
	    //Starting Coordinates & Checkerboard Pattern
	    float2 ParallaxCoord = Coordinates;
	    float2 CBxy = floor( float2(Coordinates.x * BUFFER_WIDTH, Coordinates.y * BUFFER_HEIGHT));
	    //Align Dither (Reconstruction Mode): rows paired in all modes, columns too in CB and CI.
	    float2 Dxy = CBxy;
	    #if Reconstruction_Mode
	    if(Align_Dither)
	        Dxy = floor(CBxy * float2(Reconstruction_Type == 1 ? 1.0 : 0.5, 0.5));
	    #endif
	    //VM4 weave. 2x2 blocks in Checkerboard 3D.
	    #if Virtual_Reality_Mode
	    bool CB_Out = Stereoscopic_Mode == 2;
	    #elif Reconstruction_Mode
	    bool CB_Out = Reconstruction_Type == 0;
	    #elif Anaglyph_Mode || Inficolor_3D_Emulator
	    bool CB_Out = false;
	    #else
	    bool CB_Out = Stereoscopic_Mode == 4;
	    #endif
	    float Weave = CB_Out ? fmod(floor(CBxy.x * 0.5) + floor(CBxy.y * 0.5), 2.0) : fmod(CBxy.x + CBxy.y, 2.0);
	    float Mix_Pick = Weave;
	    //VM4: Reiteration base, Stamped woven in.
	    bool VM4_Lin = View_Mode == 4 && Mix_Pick;
	    
	    //Shared half screen tap. LR_Depth_Mask and Z read this same spot at different mips.
	    float2 LR_TC = Coordinates * float2(0.5,1) + float2(0.5,0);
	    
	    //Depth & Mask Sampling
	    float LR_Depth_Mask = saturate(tex2Dlod(SamplerzBuffer_BlurN, float4( LR_TC, 0, 3.0 ) ).x * 2.5);
	    float GetDepth = smoothstep(0,1, tex2Dlod(SamplerDMN, float4(Coordinates,0, 2.0) ).x);
	    //The Alpha UI tap is discarded unless the toggle is on, so skip the fetch there.
	    float Set_UI = 1;
	    if(Alpha_Channel_UI)
	        Set_UI = Alpha_UI_Mask(ParallaxCoord,2) > 0.999;
	    
	    //De-Artifacting uniforms, read once.
	    float2 AA = Artifact_Adjust();
	    
	    //Performance Level Selection
	    float Perf = Performance_LvL[Perf_LvL].x;//VM0 VM1
	    
	    if( View_Mode == 2)
	        Perf = Performance_LvL[Perf_LvL].y;
	    if( View_Mode == 4)
	        Perf = lerp( Mix_Pick ? 0.75f : 0.500f, 0.625f, saturate(GetDepth * 0.5 * rcp(max(LR_Depth_Mask, 0.001))) );
	    if( View_Mode == 5)
	        Perf = lerp(0.50f,0.625f,GetDepth);
	    
	    //Distance Field Skip Range: x = flat areas (high skip), y = edges (fine step)
	    #if Handheld_Mode
	        float2 DF_MaxSkip = float2(2.5, 1.5);
	    #else
	    float2 DF_MaxSkip = DF_Skip_LvL[Perf_LvL];
	    #endif
	    
	    //Foveated Calculations. Only two uniform paths read it, so skip the pow otherwise.
	    float Foveated_Mask = 0;
	    if(De_Artifacting.x < 0 || Compatibility_Power < 0)
	        Foveated_Mask = saturate( Vin_Pattern(Coordinates, float2(16.0,2.0)));
	    
	    //De-Artifacting Depth Scaling
	    float Mod_Depth = saturate(GetDepth * lerp(1,15,abs(AA.y)));
	    float Scale_With_Depth = AA.y == 0 ? 1 : (AA.y < 0 ? 1-Mod_Depth : Mod_Depth);
	    
	    //De-Artifacting Base Value
	    float AA_Value = AA.x;
	    
	    //De-Artifacting Foveated Switching
	    float AA_Switch = De_Artifacting.x < 0 ? lerp(0.3 * AA_Value, AA_Value ,smoothstep(0.0,1.0,Foveated_Mask)): AA_Value;
	    
	    //De-Artifacting Offset & Scale
	    float2 Artifacting_Adjust = float2(MS.x * lerp(0,0.125,clamp(AA_Switch * Scale_With_Depth,0,2)),
	                                       1.0 - (MS.x * lerp(0,0.25,clamp(AA_Value * Scale_With_Depth,0,2))));
	    
	    //De-Artifacting Toggle
	    bool AA_Toggle = AA.x != 0 && !((View_Mode >= 2 && View_Mode <= 4) || View_Mode == 6);
	    
	    //Step Count Calculations
	    int D = abs(Diverge);
	    int Cal_Steps = max(1, D * Perf); //At least one step, else rcp(0) under Divergence 2.
	    
	    //Layer & Offset Setup
	    float LayerDepth = rcp(Cal_Steps);
	    
	    //Ray March Starting Values
	    float deltaCoordinates = MS.x * LayerDepth;
	    //March start offset, a fraction of a layer, in two modes only.
	    float Dither = 0.0;
	    if(View_Mode == 3)
	        Dither = frac(Dxy.y * 0.618034) * 0.5;
	    else if(View_Mode == 6)
	        Dither = Interleaved_Gradient_Noise(Dxy + 31.0) * 0.75;
	    //VM2: Stamped's per row offset, only with Infill Blur on. VM4 uses Mix_Pick instead.
	    else if(View_Mode == 2 && Infill_Blur > 0)
	        Dither = frac(Dxy.y * 0.618034) * 0.5;
	    ParallaxCoord.x -= deltaCoordinates * Dither;
	    float Start_Depth = GetMixed_P(ParallaxCoord, 0).x;
	    float CurrentDepthMapValue = min(1, Start_Depth);
	    float Last_Depth = Start_Depth;
	    float CurrentLayerDepth = -Re_Scale_WN().x;
	    CurrentLayerDepth += LayerDepth * Dither;
	    
	    //March invariants hoisted out of both loops.
	    float Inv_LayerDepth = rcp(LayerDepth);
	    float Near_Band      = LayerDepth * 2.0;
	    float AA_Set         = AA_Switch * Set_UI;
	    
	    //Edge Detection Threshold
	    float Mask;
	    float threshold = 0.0005;
	    
	    #if POM_MINH
	    //Jump size for the nearest depth chain, in whole march steps.
	    float MH_W  = BUFFER_WIDTH * Depth_Rez;
	    float MH_A  = AA_Toggle ? Artifacting_Adjust.x : 0.0;
	    float MH_Dt = abs(deltaCoordinates) * MH_W;
	    float MH_S  = MH_Dt > 0.0 ? floor((14.0 - abs(MH_A) * MH_W) / MH_Dt) : 0.0;
	          MH_S  = MH_S >= 3.0 ? min(MH_S, 16.0) : 0.0;
	    float MH_E  = sign(deltaCoordinates) * rcp(MH_W);
	    #endif
	
	    ///////////////////////////////////////////////////////////Ray March///////////////////////////////////////////////////////////////////////////////
	    if(AA_Toggle)
	    {
	        //The centre tap is the texel the previous pass already read, so it is carried.
	        float G_Depth = Start_Depth;
	        float Back_Value = CurrentDepthMapValue, Back_G = G_Depth, Back_C = 0, Last_Skip = 1.0;
	        float C_Depth = GetMixed_P(ParallaxCoord - float2(Artifacting_Adjust.x, 0), 0).x;
	        
	        [loop] //Steep Parallax Mapping with De-Artifacting & Distance Field Skip.
	        while (CurrentDepthMapValue >= CurrentLayerDepth)
	        {
	            #if POM_MINH
	            [branch]
	            if(MH_S > 0.0 && CurrentDepthMapValue - CurrentLayerDepth >= MH_S * LayerDepth)
	            {
	                [branch]
	                if(MinH_Span(ParallaxCoord.x + MH_E, ParallaxCoord.x - MH_S * deltaCoordinates - MH_A - MH_E, ParallaxCoord.y) >= CurrentLayerDepth + MH_S * LayerDepth)
	                {
	                    ParallaxCoord.x     -= MH_S * deltaCoordinates;
	                    CurrentLayerDepth   += MH_S * LayerDepth;
	                    G_Depth = GetMixed_P(ParallaxCoord, 0).x;
	                    C_Depth = GetMixed_P(ParallaxCoord - float2(Artifacting_Adjust.x, 0), 0).x;
	                    CurrentDepthMapValue = G_Depth;
	                    continue;
	                }
	            }
	            #endif
	            float diff = abs(G_Depth - C_Depth);
	            
	            //Edge detection mask.
	            Mask = diff > threshold;//Already 0 or 1, no saturate needed.
	            float Final_Mask = AA_Set * Mask;
	            
	            //Distance Field: skip flat areas, step finely at edges.
	            float distToSurface = CurrentDepthMapValue - CurrentLayerDepth;
	            float DF_Limit = Mask ? DF_MaxSkip.y : DF_MaxSkip.x;//Binary, so select, not lerp.
	            float DF_Skip = clamp(distToSurface * Inv_LayerDepth, 1.0, DF_Limit);
	            
	            //Step scaling driven by the distance field.
	            float adjustedLayerDepth = LayerDepth * DF_Skip;
	            float adjustedDeltaCoord = deltaCoordinates * DF_Skip;
	            
	            //Advance position.
	            ParallaxCoord.x -= adjustedDeltaCoord;
	            
	            //State before the step, to redo a landing skip.
	            Back_Value = CurrentDepthMapValue; Back_G = G_Depth; Back_C = C_Depth; Last_Skip = DF_Skip;
	            float C_Prev = C_Depth;
	            G_Depth = GetMixed_P(ParallaxCoord, 0).x;
	            C_Depth = GetMixed_P(ParallaxCoord - float2(Artifacting_Adjust.x, 0), 0).x;
	            
	            //Blend depth using the edge mask.
	            CurrentDepthMapValue = lerp(G_Depth, min(G_Depth, C_Prev), Final_Mask);
	            
	            //Advance layer.
	            CurrentLayerDepth += adjustedLayerDepth;
	        }
	        //The interpolation wants a one layer last step, so redo a landing skip in single steps.
	        [branch]
	        if(Last_Skip > 1.0)
	        {
	            ParallaxCoord.x += deltaCoordinates * Last_Skip;
	            CurrentLayerDepth -= LayerDepth * Last_Skip;
	            CurrentDepthMapValue = Back_Value; G_Depth = Back_G; C_Depth = Back_C;
	            [loop]
	            for(int r = 0; r < 3 && CurrentDepthMapValue >= CurrentLayerDepth; r++)
	            {
	                float Final_Mask = AA_Set * (abs(G_Depth - C_Depth) > threshold);
	                ParallaxCoord.x -= deltaCoordinates;
	                float C_Prev = C_Depth;
	                G_Depth = GetMixed_P(ParallaxCoord, 0).x;
	                C_Depth = GetMixed_P(ParallaxCoord - float2(Artifacting_Adjust.x, 0), 0).x;
	                CurrentDepthMapValue = lerp(G_Depth, min(G_Depth, C_Prev), Final_Mask);
	                CurrentLayerDepth += LayerDepth;
	            }
	        }
	        Last_Depth = G_Depth;
	    }
	    else
	    {
	        float Back_Value = CurrentDepthMapValue, Last_Skip = 1.0;
	        [loop] //Steep Parallax Mapping Standard with Distance Field Skip.
	        while ( CurrentDepthMapValue >= CurrentLayerDepth )
	        {
	            #if POM_MINH
	            //Same jump as the de-artifacting march, without the offset tap.
	            [branch]
	            if(MH_S > 0.0 && CurrentDepthMapValue - CurrentLayerDepth >= MH_S * LayerDepth)
	            {
	                [branch]
	                if(MinH_Span(ParallaxCoord.x + MH_E, ParallaxCoord.x - MH_S * deltaCoordinates - MH_E, ParallaxCoord.y) >= CurrentLayerDepth + MH_S * LayerDepth)
	                {
	                    ParallaxCoord.x     -= MH_S * deltaCoordinates;
	                    CurrentLayerDepth   += MH_S * LayerDepth;
	                    CurrentDepthMapValue = GetMixed_P(ParallaxCoord, 0).x;
	                    Last_Depth           = CurrentDepthMapValue;
	                    continue;
	                }
	            }
	            #endif
	            //Distance Field: skip flat areas, step finely near the surface.
	            float distToSurface = CurrentDepthMapValue - CurrentLayerDepth;
	            float DF_Limit = distToSurface < Near_Band ? DF_MaxSkip.y : DF_MaxSkip.x;
	            float DF_Skip = clamp(distToSurface * Inv_LayerDepth, 1.0, DF_Limit);
	            
	            //Step scaling driven by the distance field.
	            float adjustedLayerDepth = LayerDepth * DF_Skip;
	            float adjustedDeltaCoord = deltaCoordinates * DF_Skip;
	            
	            //Advance position.
	            ParallaxCoord.x -= adjustedDeltaCoord;
	            
	            Back_Value = CurrentDepthMapValue; Last_Skip = DF_Skip;
	            //Update the depth value.
	            CurrentDepthMapValue = GetMixed_P(ParallaxCoord, 0).x;
	            Last_Depth = CurrentDepthMapValue;
	            
	            //Advance layer.
	            CurrentLayerDepth += adjustedLayerDepth;
	            #if POM_MINH
	            //VM4 Miss Guard.
	            [branch]
	            if(View_Mode == 4 && CurrentDepthMapValue >= CurrentLayerDepth &&
	               MinH_Span(ParallaxCoord.x + adjustedDeltaCoord + MH_E, ParallaxCoord.x - MH_E, ParallaxCoord.y) < CurrentLayerDepth)
	            {
	                ParallaxCoord.x   += adjustedDeltaCoord;
	                CurrentLayerDepth -= adjustedLayerDepth;
	                int   G_N = clamp(int(ceil(abs(adjustedDeltaCoord) * MH_W)), 2, 8);
	                float G_X = adjustedDeltaCoord * rcp(G_N), G_L = adjustedLayerDepth * rcp(G_N);
	                [loop]
	                for(int q = 0; q < G_N; q++)
	                {
	                    ParallaxCoord.x     -= G_X;
	                    CurrentLayerDepth   += G_L;
	                    CurrentDepthMapValue = GetMixed_P(ParallaxCoord, 0).x;
	                    if(CurrentDepthMapValue < CurrentLayerDepth)
	                        break;
	                }
	                Last_Depth = CurrentDepthMapValue;
	                Last_Skip  = 1.0;
	            }
	            #endif
	        }
	        //Redo a landing skip in single steps.
	        [branch]
	        if(Last_Skip > 1.0)
	        {
	            ParallaxCoord.x += deltaCoordinates * Last_Skip;
	            CurrentLayerDepth -= LayerDepth * Last_Skip;
	            CurrentDepthMapValue = Back_Value;
	            [loop]
	            for(int r = 0; r < 3 && CurrentDepthMapValue >= CurrentLayerDepth; r++)
	            {
	                ParallaxCoord.x -= deltaCoordinates;
	                CurrentDepthMapValue = GetMixed_P(ParallaxCoord, 0).x;
	                Last_Depth = CurrentDepthMapValue;
	                CurrentLayerDepth += LayerDepth;
	            }
	        }
	    }
	    
	    //VM4 infill half steps.
	    float Step_X = deltaCoordinates, Step_L = LayerDepth;
	    #if !DX9_Toggle
	    [branch]
	    if(View_Mode == 4)
	    {
	        float2 Pv = float2(ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y);
	        float  Jump = abs(GetMixed_P(Pv, 0).x - CurrentDepthMapValue);
	        float HS = Jump > 0.032;
	        [branch]
	        if(HS > 0.0)
	        {
	            float2 Pm = float2(ParallaxCoord.x + 0.5 * deltaCoordinates, ParallaxCoord.y);
	            float  Lm = CurrentLayerDepth - 0.5 * LayerDepth;
	            float  Dm = GetMixed_P(Pm, 0).x;
	            //Hit already at the half step.
	            if(Dm < Lm)
	            {
	                ParallaxCoord.x      = lerp(ParallaxCoord.x, Pm.x, HS);
	                CurrentLayerDepth    = lerp(CurrentLayerDepth, Lm, HS);
	                CurrentDepthMapValue = lerp(CurrentDepthMapValue, Dm, HS);
	                Last_Depth           = CurrentDepthMapValue;
	            }
	            Step_X = lerp(deltaCoordinates, 0.5 * deltaCoordinates, HS);
	            Step_L = lerp(LayerDepth, 0.5 * LayerDepth, HS);
	        }
	    }
	    #endif
	    
	    ///////////////////////////////////////////////////////////POM Interpolation///////////////////////////////////////////////////////////////////////
	    
	    //Previous Step Coordinate
	    float2 PrevParallaxCoord = float2( ParallaxCoord.x + Step_X, ParallaxCoord.y);
	    
	    //Anti-Weapon Hand Z-Fighting
	    //Both taps are discarded unless WP is on, so they stay behind that uniform test.
	    float Weapon_Mask = 0, ZFighting_Mask = 0;
	    if(WP > 0)
	    {
	        Weapon_Mask = WeaponMask(Coordinates,0);
	        //1.0-(1.0-A-B) is just A+B
	        ZFighting_Mask = (WeaponMask(Coordinates,5.5) + Weapon_Mask) * (1.0-Weapon_Mask);
	    }
	    
	    //POM Coordinate Selection by View Mode
	    float2 PCoord = float2(View_Mode <= 1 || View_Mode == 5 ? PrevParallaxCoord.x : ParallaxCoord.x, PrevParallaxCoord.y );
	    
	    //Depth at Previous Step with Weapon Z-Fight Correction
	    float Get_DB = Last_Depth;
	    [branch]
	    if(View_Mode <= 1 || View_Mode == 5)
	        Get_DB = GetMixed_P(PCoord, 0).x;
	    float Get_DB_ZDP = WP > 0 ? lerp(Get_DB, abs(Get_DB), ZFighting_Mask) : Get_DB;
	    
	    //POM Weight Calculation
	    float beforeDepthValue = Get_DB_ZDP;
	    float afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
	          beforeDepthValue += Step_L - CurrentLayerDepth;
	    
	    //Depth Difference for Gap Detection
	    float DepthDiffrence = afterDepthValue - beforeDepthValue;
	    float DD_Map = abs(DepthDiffrence);
	    float2 DD_Spread = float2(DD_Map > 0.032, DD_Map > lerp(0.128,0.064 ,LR_Depth_Mask ));
	    
		//Shared preconditions for refinement paths
		bool isHardMode = (View_Mode <= 1 || View_Mode == 5);
		bool needsRefinement = false; //Seek and binary refine off: SpatialLabs has no such block.
		
		if(needsRefinement)
		{
		    bool IsSharpGap = abs(beforeDepthValue) > 0.001 &&
		                      abs(afterDepthValue)  > 2.0 * abs(beforeDepthValue);
		
		    if(IsSharpGap)
		    {
		        //Classic sharp gap seek. Marches past the occluder and moves only on a hit.
		        float2 SeekCoord       = float2(ParallaxCoord.x - deltaCoordinates, ParallaxCoord.y);
		        float  SeekLayerDepth  = CurrentLayerDepth;
		        int    MaxSeekSteps    = clamp(D, 8, 25);

		        [loop]
		        for(int s = 0; s < MaxSeekSteps; s++)
		        {
		            SeekCoord.x    -= deltaCoordinates;
		            SeekLayerDepth += LayerDepth;
		            float SeekDepth = GetMixed_P(SeekCoord, 0).x;

		            if(SeekDepth >= SeekLayerDepth)
		            {
		                ParallaxCoord.x = SeekCoord.x;
		                break;
		            }
		        }
		    }
		    else
		    {
		        //Edge resolve. The classic binary search landing.
		        float xRange     = ParallaxCoord.x - PrevParallaxCoord.x;
		        float layerStart = CurrentLayerDepth - LayerDepth;
		        float t          = 0.5;
		        float step       = 0.25;

		        SD_UNROLL
		        for(int b = 0; b < 3; b++)
		        {
		            float midX     = PrevParallaxCoord.x + xRange * t;
		            float midLayer = layerStart + LayerDepth * t;
		            float midDepth = GetMixed_P(float2(midX, ParallaxCoord.y), 0).x;

		            t    += (midDepth >= midLayer) ? step : -step;
		            step *= 0.5;
		        }
		        ParallaxCoord.x = PrevParallaxCoord.x + xRange * t;
		    }
		}
		else
		{
		    //Weighted POM Interpolation
		    float weight = afterDepthValue * rcp(min(-0.0125, DepthDiffrence));
		    if(isHardMode) weight += 0.5 * smoothstep(0.032, 0.064, DD_Map);
		    ParallaxCoord.x = lerp(ParallaxCoord.x, PrevParallaxCoord.x, weight);
		}
    
	    //De-band the stretch. Position stable hash nudges flagged gap taps under a pixel.
	    if (DD_Spread.x)
	    {
	        const float2 magicdot = float2(0.75487766624669276, 0.569840290998);
	        float Jit = frac(dot(Dxy, magicdot));
	        ParallaxCoord.x += (Jit - 0.5) * pix.x * 0.75;
	    }

	    //Compatibility Power. The Z tap is only needed when the slider sits at zero.
	    float Auto_Compatibility_Power = abs(Compatibility_Power);
	    if(Auto_Compatibility_Power == 0)
	    {
	        float Z  = tex2Dlod(SamplerzBuffer_BlurN, float4( LR_TC, 0, 2 ) ).x;
	        float ZS = smoothstep(0.5,1.0,( Z - 0.5 ) * 2.0);//Was (Z - N)/(F - N) with N 0.5 F 1.0.
	        Auto_Compatibility_Power = lerp(-0.25,0.0, ZS );
	    }
	    if(Compatibility_Power < 0)
	        Auto_Compatibility_Power *= Foveated_Mask;
	    float TP = saturate(lerp(0.015, 0.0375,Auto_Compatibility_Power));
	    float D_Range = 37.5;
	    float US_Offset = Diverge < 0 ? -D_Range : D_Range;
	    float DB_Offset = US_Offset * TP * pix.x;
	    //Compatibility Offset for View Modes
	    ParallaxCoord.x += lerp(DB_Offset * 2.0, DB_Offset * 4.0, DD_Spread.y );
	    
	    ///////////////////////////////////////////////////////////Interlace Optimization//////////////////////////////////////////////////////////////////
	    
	    #if Reconstruction_Mode
	        if(Reconstruction_Type == 1 )
	            ParallaxCoord.y += IO * pix.y;
	        if(Reconstruction_Type == 2)
	            ParallaxCoord.x += IO * pix.x;
	    #else
	        if(Stereoscopic_Mode == 2)
	            ParallaxCoord.y += IO * pix.y;
	        else if(Stereoscopic_Mode == 3)
	            ParallaxCoord.x += IO * pix.x;
	    #endif
	    
	    //Hole flag.
	    float Hole_Px = DD_Map * D;
	    //Old Normal (VM0 in anaglyph and Inficolor) has no sweep. VM6 uses VM1's.
	    if(View_Mode == 1 || View_Mode == 6 || (View_Mode == 0 && !VM0_NORMAL))
	    {
	        const float Mask_Sweep_Lo = 0.50, Mask_Sweep_Hi = 0.625;
	        float Mask_Layer = rcp(max(1, int(D * lerp(Mask_Sweep_Lo, Mask_Sweep_Hi, GetDepth))));
	        Hole_Px = abs(DepthDiffrence + LayerDepth - Mask_Layer) * D;
	    }
	    float Edge_Px = 0;
	    float Hole_Side = 1.0;
	    if (Hole_Px > HOLE_TRIGGER_PX && (Infill_Blur != 0 || Show_Infill_Mask || Infill_Blur_Debug || MEM_INFILL))
	    {
	        //Clears the depth dilation.
	        float Recon_Eff  = floor(Recon_Step + 0.5);
	        float Mask_Reach = (Recon_Eff * rcp(Depth_Rez) + Mask_Reach_Px * DS_Side_Texels * rcp(DS_Side_Tuned)) * pix.x;
	        //One sided: only the background side extends, so it never reaches onto the object.
	        bool  Bg_Pos   = sign(Diverge) < 0;//Flipped: > 0 extended onto the object.
	        //Same value Show Near Far paints, so the wall and the reach cannot disagree.
	        float Bg_Probe = smoothstep(0, 1, tex2Dlod(SamplerDMN, float4(ParallaxCoord, 0, 0.0)).x);
	        //Grows with distance to clear the wider ramp against far backgrounds.
	        float Reach_Ob = Mask_Reach * Mask_Reach_Scale * lerp(Mask_Reach_Near, Mask_Reach_Far, Depth_Blend(Bg_Probe));
	        float Reach_Bg = lerp(Mask_Bg_Near, Mask_Extend_Far, Depth_Blend(Bg_Probe)) * pix.x;
	        float Reach_L  = Bg_Pos ? Reach_Ob : Reach_Bg;
	        float Reach_R  = Bg_Pos ? Reach_Bg : Reach_Ob;
	        #if M_Edge
	        const float ER_Band = 0.001;
	        #else
	        const float ER_Band = 0.03;
	        #endif
	        float Land_D = GetMixed_P(ParallaxCoord, 0).x;
	        float2 Tap_L = ParallaxCoord - float2(Reach_L, 0), Tap_R = ParallaxCoord + float2(Reach_R, 0);
	        float Hole_L = min(Tap_L.x, 1.0 - Tap_L.x) < ER_Band ? Land_D : GetMixed_P(Tap_L, 0).x;
	        float Hole_R = min(Tap_R.x, 1.0 - Tap_R.x) < ER_Band ? Land_D : GetMixed_P(Tap_R, 0).x;
	        //The long reach finds the object.
	        float Dir_Bg = Bg_Pos ? 1.0 : -1.0;
	        float Near_L = 1e4;
	        SD_UNROLL
	        for(int r = 1; r <= HOLE_REACH_TAPS; r++)
	        {
	            float2 Tap = ParallaxCoord + float2(Dir_Bg * (r / (HOLE_REACH_TAPS + 1.0)) * Reach_Bg, 0);
	            Near_L = min(Near_L, min(Tap.x, 1.0 - Tap.x) < ER_Band ? Land_D : GetMixed_P(Tap, 0).x);
	        }
	        if(Bg_Pos)
	            Hole_R = min(Hole_R, Near_L);
	        else
	            Hole_L = min(Hole_L, Near_L);
	        Edge_Px = abs(Hole_R - Hole_L) * D;
	        Hole_Side = saturate((Hole_R - Hole_L) * sign(Diverge) * 1000.0);
	    }
	    //Gap width ramp, or a local depth edge that is wide enough to be a real reveal.
	    float Hole_Mask = Hole_Side * max( smoothstep(Gap_Detect_Lo, max(Gap_Detect_Lo + 0.1, Gap_Detect_Hi), Hole_Px),
	                                       smoothstep(2.0, 6.0, Edge_Px) * smoothstep(0.5, 1.0, Hole_Px) );
	    //Under the trigger the side test never ran, so no mask there.
	    if(HOLE_TRIGGER_PX > 0.5)
	        Hole_Mask *= Hole_Px > HOLE_TRIGGER_PX;
	    //VM0 Structure (Guidefill, built on coherence transport).
	    float Line_Shift = 0.0, VM0_Lw = 0.0;
	    [branch]
	    //Only at a real gap (a depth jump at the landing).
	    if(View_Mode == 0 && !VM0_NORMAL && Hole_Mask > 0.0 && DD_Spread.x && !Vert_3D_Pinball)
	    {
	        float  Land_Z = GetMixed_P(ParallaxCoord, 0).x;
	        float  Hidden = Coordinates.x - MS * (Land_Z + Re_Scale_WN().x);
	        float  Bg_Dir = sign(Diverge) < 0 ? 1.0 : -1.0;
	        float  Dx     = clamp(ParallaxCoord.x - Hidden, -Hole_Px * pix.x, Hole_Px * pix.x);
	        //No shift, nothing to do: skip the tensor.
	        [branch]
	        if(abs(Dx) > 0.0)
	        {
	            //Read 2 px into the background, away from the object.
	            float2 Bc = ParallaxCoord + float2(Bg_Dir * 2.0 * pix.x, 0.0);
	            #if VM0_FIELD
	            //One read of the structure field, at mip 2 (the papers' tensor smoothing, rho about 4 px).
	            float4 F  = tex2Dlod(Sampler_SF, float4(Bc, 0, 2));
	            float3 J  = F.w >= Land_Z - 0.02 ? F.xyz : 0.0;
	            #else
	            //No field (DX9, or a build without it).
	            float3 J  = 0.0;
	            float  Lu = dot(CSB(Bc - float2(0, 5.0 * pix.y)).rgb, float3(0.299, 0.587, 0.114));
	            SD_UNROLL
	            for(int s = -2; s <= 2; s++)
	            {
	                float2 Pg = Bc + float2(0.0, s * 2.0 * pix.y);
	                float  Ld = dot(CSB(Pg + float2(0, pix.y)).rgb, float3(0.299, 0.587, 0.114));
	                float  gx = dot(CSB(Pg + float2(pix.x, 0)).rgb - CSB(Pg - float2(pix.x, 0)).rgb, float3(0.299, 0.587, 0.114));
	                float  gy = Ld - Lu;
	                Lu = Ld;
	                J += float3(gx * gx, gy * gy, gx * gy);
	            }
	            #endif
	            //Coherence.
	            float Tr  = J.x + J.y;
	            float Sq  = sqrt((J.x - J.y) * (J.x - J.y) + 4.0 * J.z * J.z);
	            //Guidefill's strength term, tanh((l1 - l2) / Lambda).
	            const float SF_Lambda = 0.0002, SF_Gate = 0.2;
	            float Coh = Tr > 0.000001 ? Sq * rcp(Tr) * tanh(Sq * rcp(SF_Lambda)) : 0.0;
	            //All or nothing, as in Guidefill.
	            [branch]
	            if(Coh > SF_Gate)
	            {
	                //Up to a 2:1 slope, in screen pixels.
	                float Slope = SF_Slope(J, Sq);
	                float2 Src  = float2(ParallaxCoord.x, ParallaxCoord.y + Dx * Slope * (pix.y * rcp(pix.x)));
	                #if VM0_FIELD
	                //Guidefill measures the direction where the line enters the edge, not on this pixel's row.
	                [branch]
	                if(abs(Src.y - ParallaxCoord.y) >= pix.y)
	                {
	                    float4 F2   = tex2Dlod(Sampler_SF, float4(Bc.x, Src.y, 0, 2));
	                    float3 J2   = F2.w >= Land_Z - 0.02 ? F2.xyz : 0.0;
	                    float  Tr2  = J2.x + J2.y;
	                    float  Sq2  = sqrt((J2.x - J2.y) * (J2.x - J2.y) + 4.0 * J2.z * J2.z);
	                    if(Tr2 > 0.000001 && Sq2 * rcp(Tr2) * tanh(Sq2 * rcp(SF_Lambda)) > SF_Gate)
	                    {
	                        Slope = SF_Slope(J2, Sq2);
	                        Src.y = ParallaxCoord.y + Dx * Slope * (pix.y * rcp(pix.x));
	                    }
	                }
	                #endif
	                if(GetMixed_P(Src, 0).x >= Land_Z - 0.02)
	                {
	                    Line_Shift    = Src.y - ParallaxCoord.y;
	                    VM0_Lw        = smoothstep(SF_Gate, SF_Gate + 0.3, Coh);
	                    ParallaxCoord = Src;
	                }
	            }
	        }
	    }
	    //Packed into w as one exact integer.
	    float VM0_Pack = VM0_Lw > 0.0 ? clamp(round(Line_Shift * rcp(pix.y) * 4.0), -1023.0, 1023.0) + 1024.0
	                                  + 2048.0 * round(VM0_Lw * 15.0) : 0.0;
	    #if MEM_INFILL
	    //Memory Infill: the hidden spot's offset in w, when the memory holds its background.
	    [branch]
	    if(Hole_Mask > 0.0 && !Vert_3D_Pinball)
	    {
	        float  Land_Z = GetMixed(ParallaxCoord, 0).x;
	        //Shifted like the march: MS * max(depth + WN, 0), popped out past -WN is not shifted.
	        float2 Guess = float2(Coordinates.x - MS * max(Land_Z + Re_Scale_WN().x, 0.0), ParallaxCoord.y);
	        //The remembered depth places the spot. The landing depth is still on the edge ramp.
	        float  Mem_Z = Mem_Now(Guess).a;
	        float2 Hidden = float2(Coordinates.x - MS * max(Mem_Z + Re_Scale_WN().x, 0.0), Guess.y);
	        //Must match the visible background 8 and 16 px out, or something farther (sky) gets used.
	        float  Bg_Dir = -sign(Hidden.x - ParallaxCoord.x) * pix.x;
	        float  Bg_Z = max(GetMixed(float2(ParallaxCoord.x + Bg_Dir * 8.0, ParallaxCoord.y), 0).x, GetMixed(float2(ParallaxCoord.x + Bg_Dir * 16.0, ParallaxCoord.y), 0).x);
	        //Only where it is covered now (an age).
	        float  Tol = 0.03 + 0.15 * Bg_Z;
	        bool   Found = Age_Now(Hidden) > 0.0 && abs(Mem_Now(Hidden).a - Mem_Z) < 0.03
	                    && abs(Mem_Z - Bg_Z) < Tol;
	        if(Found && abs(Hidden.x - ParallaxCoord.x) < 0.1)
	            VM0_Pack = Hidden.x - ParallaxCoord.x;
	    }
	    #endif
	    //Alpha UI: no gap mask on the UI.
	    return float4(ParallaxCoord, Hole_Mask * Set_UI, VM0_Pack);
	}
			
	///////////////////////////////////////////////////////////Stereo Conversions///////////////////////////////////////////////////////////////////////
	#if !Virtual_Reality_Mode
	uint4 Frame_Selector()
	{
		int FS_RM = Reconstruction_Mode ? 2 : 6;
		#if EX_DLP_FS_Mode
		float Swap_Frame = FS_FA ? Frame_Alternate : Alternate;
		#else
		float Swap_Frame = Alternate;
		#endif
		return uint4(fmod(Swap_Frame,2),fmod(Frames,4),0,FS_RM);
	}

	static const float Anaglyph_Array[10] = { 0,
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
	float Anaglyph_Selection(int Selection)
	{
		float Anaglyph = Anaglyph_Array[Selection].x;//Reconstruction_Mode ? Anaglyph_Array[Selection].y : Anaglyph_Array[Selection].x;
		return Anaglyph;
	}
	
	static const float2 GXYArray[9] = {
		float2(BUFFER_WIDTH, BUFFER_HEIGHT), //Native
		float2(3840.0, 2160.0),
		float2(3841.0, 2161.0),
		float2(1920.0, 1080.0),
		float2(1921.0, 1081.0),
		float2(1680.0, 1050.0),
		float2(1681.0, 1051.0),
		float2(1280.0, 720.0),
		float2(1281.0, 721.0)
	};
	#if BC_SPACE == 1 && (Inficolor_3D_Emulator || Anaglyph_Mode)
	//HDR.
	float3 HDR_To_Anaglyph(float3 N)
	{
		float3 Y = pow(max(mul(BT2020_To_BT709, N), 0.0), 0.1593017578125);
		return pow((0.8359375 + 18.8515625 * Y) / (1.0 + 18.6875 * Y), 78.84375);
	}

	float3 Anaglyph_To_HDR(float3 E)
	{
		float3 P = pow(saturate(E), 1.0 / 78.84375);
		return mul(BT709_To_BT2020, pow(max(P - 0.8359375, 0.0) / (18.8515625 - 18.6875 * P), 1.0 / 0.1593017578125));
	}
	#endif

	float4 Stereo_Convert(float2 texcoord, float4 cL, float4 cR)
	{
		float4 L = float4(cL.rgb,0),R = float4(cR.rgb,0);
		#if BC_SPACE == 1 && (Inficolor_3D_Emulator || Anaglyph_Mode)
		L.rgb = HDR_To_Anaglyph(L.rgb); R.rgb = HDR_To_Anaglyph(R.rgb);
		#endif
		float2 TC = texcoord; float4 color, accum, image = 1, color_saturation = lerp(0,2,Anaglyph_Saturation);
		float2 gridxy = floor(TC * GXYArray[Scaling_Support]);
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
			else //Max Deghosting
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
	
				//Pre-passes for the plain modes only (0 and 4).
				if( Stereoscopic_Mode == Anaglyph_Selection(0) ) 
				{
					//cA = (cA - 0.5) * Contrast.x + 0.5; cB = (cB - 0.5) * Contrast.y + 0.5;
					LOne = Contrast.x*0.45;
					ROne = Contrast.y;
					accum = saturate(cA*float4(LOne,(1.0-LOne)*0.5,(1.0-LOne)*0.5,1.0));
					cA.r = accum.r+accum.g+accum.b;
					
					accum = saturate(cB*float4(1.0-ROne,ROne,0.0,1.0));
					cB.g = pow(accum.r+accum.g+accum.b, 1.15);
					
					accum = saturate(cB*float4(1.0-ROne,0.0,ROne,1.0));
					cB.b = pow(accum.r+accum.g+accum.b, 1.15);
				}
		
				if( Stereoscopic_Mode == Anaglyph_Selection(4) ) 
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
		
					red = saturate(red);
		
					float green = -0.062 * cA.r -0.062 * cA.g -0.024 * cA.b + 0.377 * cB.r + 0.761 * cB.g + 0.009 * cB.b;
		
					green = saturate(green);
		
					float blue = -0.048 * cA.r - 0.050 * cA.g - 0.017 * cA.b -0.026 * cB.r -0.093 * cB.g + 1.234  * cB.b;
		
					blue = saturate(blue);
		
					color = float4(red, green, blue, 0);
				}
				else if (Stereoscopic_Mode == Anaglyph_Selection(2)) // Anaglyph 3D Deghosted Red/Cyan Code from http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
				{
					LOne = Contrast.x*0.45;
					ROne = Contrast.y;
					DeGhost *= 0.1;
		
					accum = saturate(cA*float4(LOne,(1.0-LOne)*0.5,(1.0-LOne)*0.5,1.0));
					image.r = accum.r+accum.g+accum.b;
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
		
					red = saturate(red);
		
					float green = 0.284 * cA.r + 0.668 * cA.g + 0.143 * cA.b - 0.016 * cB.r - 0.015 * cB.g + 0.065 * cB.b;
		
					green = saturate(green);
		
					float blue = -0.015 * cA.r -0.027 * cA.g + 0.021 * cA.b + 0.009 * cB.r + 0.075 * cB.g + 0.937  * cB.b;
		
					blue = saturate(blue);
		
					color = float4(red, green, blue, 0);
				}
				else if (Stereoscopic_Mode == Anaglyph_Selection(6))// Anaglyph 3D Deghosted Green/Magenta Code from http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
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
				else if (Stereoscopic_Mode == Anaglyph_Selection(7)) // Anaglyph 3D Blue/Amber Code from http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
				{
					LOne = Contrast.x*0.45;
					ROne = Contrast.y;
					float D[1];//The Chronicles of Riddick: Assault on Dark Athena fix. I don't know why it works.
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
				{   // Note to self: I need to revisit all modes http://www.flickr.com/photos/e_dubois/5230654930/
					
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
		#if BC_SPACE == 1 && (Inficolor_3D_Emulator || Anaglyph_Mode)
		color.rgb = Anaglyph_To_HDR(color.rgb);
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

	void Con_Values(in float2 texcoord, out float2 DLR, out float2 TCL, out float2 TCR, out float2 TCL_T, out float2 TCR_T, out float Pattern)
	{
		#if Virtual_Reality_Mode
		float D = !Eye_Swap ? -Min_Divergence().x : Min_Divergence().x;
		#else
		float D = Eye_Swap ? -Min_Divergence().x : Min_Divergence().x;
		#endif
		float FadeIO = Focus_Reduction_Type == 1 ? 1 : smoothstep(0, 1, 1 - tex2Dlod(SamplerAvrP_N, float4(0, 0.0625, 0, 0)).z/*stored Fade_in_out*/), FD = D, FD_Adjust = 0.2;
						
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
	
		DLR = float2(FD,FD);
		float2 Persp = Per;
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

		TCL = texcoord; TCR = texcoord; TCL_T = texcoord; TCR_T = texcoord;


		#if IC_DEPTH
		if(Inficolor_Auto_Focus)
			Persp *= lerp(0.75,1.0, saturate(smoothstep(-0.0175,min(0.5,0.13),Avr_Mix(float2(0.5,0.5)).x)) );
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
		
		//FoV Cal for left and right eye.
		if(Stereoscopic_Mode == 0)
		{
			TCL = FoVCal(TCL);
			TCR = FoVCal(TCR);
		}
		
		float3 PatternsXYZ = Patterns(texcoord.xy);
		Pattern = PatternsXYZ.x;//CB
		#if !Virtual_Reality_Mode
			#if Reconstruction_Mode	
				if(Reconstruction_Type == 1 )
					Pattern = PatternsXYZ.z; //LI
				if(Reconstruction_Type == 2 )
					Pattern = PatternsXYZ.y; //CI
			#else
					#if REST_UI_Mode
					if(Stereoscopic_Mode == 2 || Stereoscopic_Mode == 1)
						Pattern = PatternsXYZ.z; //LI
					if( Stereoscopic_Mode == 3 || Stereoscopic_Mode == 0)
						Pattern = PatternsXYZ.y ; //CI
					#else
					if(Stereoscopic_Mode == 0)
						Pattern = texcoord.x < 0.5; //SBS
					if( Stereoscopic_Mode == 1)
						Pattern = texcoord.y < 0.5; //TnB
					if(Stereoscopic_Mode == 2)
						Pattern = PatternsXYZ.z; //LI
					if( Stereoscopic_Mode == 3)
						Pattern = PatternsXYZ.y; //CI
					#endif
			#endif
		#endif						
	}

	#if Anaglyph_Mode || Inficolor_3D_Emulator
	//The channels each eye feeds.
	void AG_Channels(out float3 L, out float3 R)
	{
		L = float3(1.0, 0.0, 0.0); R = float3(0.0, 1.0, 1.0); //Red-Cyan
		#if Inficolor_3D_Emulator
		L = float3(1.0, 0.0, 1.0); R = float3(0.0, 1.0, 0.0);
		#else
		if(Stereoscopic_Mode == Anaglyph_Selection(4) || Stereoscopic_Mode == Anaglyph_Selection(5) || Stereoscopic_Mode == Anaglyph_Selection(6))
		{
			L = float3(0.0, 1.0, 0.0); R = float3(1.0, 0.0, 1.0); //Green-Magenta
		}
		else if(Stereoscopic_Mode == Anaglyph_Selection(7))
		{
			L = float3(1.0, 1.0, 0.0); R = float3(0.0, 0.0, 1.0); //Blue-Amber
		}
		else if(Stereoscopic_Mode == Anaglyph_Selection(8))
		{
			L = float3(1.0, 0.0, 0.0); R = float3(0.0, 0.0, 1.0); //Red-Blue
		}
		else if(Stereoscopic_Mode == Anaglyph_Selection(9))
		{
			L = float3(1.0, 0.0, 0.5); R = float3(0.0, 1.0, 0.5); //Magenta-Cyan, blue split
		}
		#endif
	}
	#endif
	#if AG_EYES
	#if AG_INFICOLOR
	//Inficolor.
	int AG_Dark()
	{
		return 1;
	}
	float3 AG_Region(int Eye)
	{
		float TW = floor(BUFFER_WIDTH * AG_BUDGET), BW = floor(BUFFER_WIDTH * (0.5 + 0.5 * IF_Scale));
		return Eye == 0 ? float3(0.0, BW, TW) : float3(BW, BW, TW);
	}
	#else
	float AG_Left_Share()
	{
		float3 L, R;
		AG_Channels(L, R);
		const float3 Luma = float3(0.299, 0.587, 0.114);
		float LS = dot(L, Luma);
		return LS * rcp(LS + dot(R, Luma));
	}
	//The eye that carries less of the brightness: 0 left, 1 right.
	int AG_Dark()
	{
		return AG_Left_Share() > 0.5 ? 1 : 0;
	}
	//Buffer layout.
	float3 AG_Region(int Eye)
	{
		float TW = floor(BUFFER_WIDTH * AG_BUDGET), S = AG_Left_Share();
		float BW = floor(TW * clamp(max(S, 1.0 - S), 0.5, 0.8));
		return Eye != AG_Dark() ? float3(0.0, BW, TW) : float3(BW, TW - BW, TW);
	}
	#endif
	//An eye from texAG_Eyes, stretched back to the screen.
	float4 AG_Read(float2 tc, int Eye)
	{
		float3 R = AG_Region(Eye);
		float bx = clamp(R.x + tc.x * R.y, R.x + 0.5, R.x + R.y - 0.5);
		float2 P = tex2Dlod(Sampler_AG_Eyes, float4(bx * rcp(R.z), tc.y, 0, 0)).xy;
		//Hole mask.
		float  C0 = clamp(floor(bx - 0.5), R.x, R.x + R.y - 1.0) + 0.5, C1 = min(C0 + 1.0, R.x + R.y - 0.5);
		float  Z  = max(tex2Dlod(Sampler_AG_Eyes_P, float4(C0 * rcp(R.z), tc.y, 0, 0)).z,
		                tex2Dlod(Sampler_AG_Eyes_P, float4(C1 * rcp(R.z), tc.y, 0, 0)).z);
		//Memory Infill offset, nearest texel so it is not blended with 0.
		float  W  = tex2Dlod(Sampler_AG_Eyes_P, float4((floor(bx) + 0.5) * rcp(R.z), tc.y, 0, 0)).w;
		return float4(P + (Vert_3D_Pinball ? tc.yx : tc), Z, W);
	}
	//One march per pixel, same calls as the anaglyph path.
	float4 AG_Eyes_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		float bx = floor(position.x);
		int Eye = 1 - AG_Dark();
		float3 R = AG_Region(Eye);
		if(bx >= R.x + R.y)
		{
			Eye = 1 - Eye;
			R = AG_Region(Eye);
		}
		float2 uv = float2((bx - R.x + 0.5) * rcp(R.y), texcoord.y);
		float2 DLR, TCL, TCR, TCL_T, TCR_T;
		float  Pattern;
		Con_Values(uv, DLR, TCL, TCR, TCL_T, TCR_T, Pattern);
		if(Vert_3D_Pinball)
		{
			TCL = TCL.yx;
			TCR = TCR.yx;
		}
		//if, not ?:, which would march both eyes.
		float4 C;
		[branch]
		if(Eye == 1)
			C = Parallax(DLR.y, TCR, -AI);
		else
			C = Parallax(-DLR.x, TCL, AI);
		//Stored as an offset from this pixel, so it stays exact when stretched. w: the Memory Infill offset only.
		return float4(C.xy - (Vert_3D_Pinball ? uv.yx : uv), C.z, abs(C.w) < 0.1 ? C.w : 0.0);
	}
	#endif

	float VM0_Pack_Half(float Pack)
	{
		float Ln = Pack, W = 0.0;
		if(Ln > 0.0)
		{
			float Lq = floor(Ln * rcp(2048.0));
			W += round(Lq * rcp(5.0)) * 256.0 + clamp(round((Ln - Lq * 2048.0 - 1024.0) * 0.25), -127.0, 127.0) + 128.0;
		}
		return W;
	}
	float VM0_Unpack_Half(float W)
	{
		float Ln = W, Pack = 0.0;
		if(Ln > 0.0)
		{
			float Lq = floor(Ln * rcp(256.0));
			Pack += ((Ln - Lq * 256.0) - 128.0) * 4.0 + 1024.0 + 2048.0 * round(Lq * 5.0);
		}
		return Pack;
	}
	#if DoubleBuffer_Mode
	//Double Buffer Resolution under 1.
	float4 DB_Fetch(float2 texcoord, float2 Base)
	{
		float  Eye = texcoord.x >= 0.5;
		float  W   = BUFFER_WIDTH * DB_Width;//One eye's width in texDB_March texels.
		//Clamped half a texel inside its own eye, so the eyes never blend.
		float  X   = (clamp(frac(texcoord.x * 2.0) * W, 0.5, W - 0.5) + Eye * W) * rcp(BUFFER_WIDTH * 2.0);
		float2 O   = tex2Dlod(SamplerDB_March,   float4(X, texcoord.y, 0, 0)).xy;
		float2 ZW  = tex2Dlod(SamplerDB_March_P, float4(X, texcoord.y, 0, 0)).zw;
		return float4(Base + O, ZW.x, VM0_Unpack_Half(ZW.y));
	}
	#endif

	#if Reconstruction_Mode || Virtual_Reality_Mode || Anaglyph_Mode
		#if Anaglyph_Mode
		void Anaglyph(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 LR_Out: SV_Target0)
		#else
		void CB_Reconstruction(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Left : SV_Target0, out float4 Right : SV_Target1)
		#endif
	#else
	float4 PS_calcLR(float2 texcoord, float2 position)
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
		
		float4 Shift_LR;
		float2 DLR, TCL, TCR, TCL_T, TCR_T, TexCoords = texcoord;
		float Pattern_Type;		
		Con_Values(texcoord,DLR, TCL, TCR, TCL_T, TCR_T, Pattern_Type);		
		float4 color, L = 0, R = 0, Left_Right = 0, Parallax_LR = 0, Parallax_L = 0, Parallax_R = 0, LR_De_Art;
		Pattern_Type = fmod(Pattern_Type,2);
		
		#if Virtual_Reality_Mode
				Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
				Parallax_LR = Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w);
				
				if(Vert_3D_Pinball)
					Parallax_LR.xyz = Parallax_LR.yxz;
							
					Left_Right = MouseCursorS(Parallax_LR.xyz, Parallax_LR.w, position.xy , Mouse_Toggle_Click, 0);					
		#else
			#if Reconstruction_Mode	
			Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
			Parallax_LR = Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w);
			
			if(Vert_3D_Pinball)
				Parallax_LR.xyz = Parallax_LR.yxz;
					
					Left_Right = MouseCursorS(Parallax_LR.xyz, Parallax_LR.w, position.xy , Mouse_Toggle_Click, 0);					
			#else
			Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) : Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
	
			if(Stereoscopic_Mode == 5)
				Shift_LR = TexCoords.y < 0.5 ? TexCoords.x < 0.5 ? float4(-DLR.x,TCL,AI) : float4(-DLR.x * 0.33333333,TCL_T,AI) : TexCoords.x < 0.5 ? float4(DLR.y * 0.33333333, TCR_T, -AI) : float4(DLR.y, TCR, -AI);
	
			#if EX_DLP_FS_Mode
			if( Inficolor_3D_Emulator || Anaglyph_Mode || Stereoscopic_Mode >= 6)
			#else
			if( Inficolor_3D_Emulator || Anaglyph_Mode )
			#endif
			{		
				if(Vert_3D_Pinball)
				{
					TCL = TCL.yx;
					TCR = TCR.yx;
				}
				
				#if AG_EYES
				//Fast Eye Buffer: both eyes come from texAG_Eyes.
				[branch]
				if(Anaglyph_Fast)
				{
					Parallax_L = AG_Read(TexCoords, 0);
					Parallax_R = AG_Read(TexCoords, 1);
				}
				else
				{
					Parallax_L = Parallax(-DLR.x,TCL, AI);
					Parallax_R = Parallax( DLR.y,TCR,-AI);
				}
				#else
				Parallax_L = Parallax(-DLR.x,TCL, AI);
				Parallax_R = Parallax( DLR.y,TCR,-AI);
				#endif
			
				if(Vert_3D_Pinball)
				{
					Parallax_L.xyz = Parallax_L.yxz;
					Parallax_R.xyz = Parallax_R.yxz;
				}

				L = MouseCursorS(Parallax_L.xyz, Parallax_L.w, position.xy , Mouse_Toggle_Click, 0);
				R = MouseCursorS(Parallax_R.xyz, Parallax_R.w, position.xy , Mouse_Toggle_Click, 0);
			}
			else	
			{
			
				#if DoubleBuffer_Mode
				//Reduced Double Buffer: the march was done at lower width, take its result.
				[branch]
				if(DB_Scale < 0.999)
					Parallax_LR = DB_Fetch(texcoord, Shift_LR.yz);
				else
				#endif
					Parallax_LR = Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w);
				
				if(Vert_3D_Pinball && Stereoscopic_Mode != 5)
					Parallax_LR.xyz = Parallax_LR.yxz;
						
				Left_Right = MouseCursorS(Parallax_LR.xyz, Parallax_LR.w, position.xy , Mouse_Toggle_Click, 0);	
			}
			#endif
		#endif
		//Debug Here
		//Left_Right.rgb = Left_Right.w;
		//Left_Right.rgb = LR_De_Art.x;//
		//Convert Stereo
		#if Reconstruction_Mode || Virtual_Reality_Mode
		color.rgb = Left_Right.rgb;
		#else
		color.rgb = Stereoscopic_Mode >= 6 || Inficolor_3D_Emulator || Anaglyph_Mode ? Stereo_Convert( TexCoords, L, R).rgb : Left_Right.rgb;
		#endif
		
		color = AdjustSaturation(color);
		#if Anaglyph_Mode || Inficolor_3D_Emulator
		//Show Infill Mask: each eye's mask after the mix. Red left, blue right.
		[branch]
		if(Show_Infill_Mask)
		{
			float3 Red = float3(1.0, 0.0, 0.0), Blue = float3(0.0, 0.0, 1.0);
			#if BC_SPACE == 1
			//Tints in the normalized HDR space.
			Red = NormalizeScRGB(float4(Red, 0)).rgb; Blue = NormalizeScRGB(float4(Blue, 0)).rgb;
			#endif
			color.rgb = lerp(color.rgb, Red,  smoothstep(0.5, 0.9, L.a));
			color.rgb = lerp(color.rgb, Blue, smoothstep(0.5, 0.9, R.a));
		}
		#endif
		
		if (Depth_Map_View == 2)
			color.rgb = tex2D(SamplerzBufferN_P,TexCoords).xxx;
				
		//Alignment view only: its depth reads used to run for every pixel in every mode.
		[branch]
		if(BD_Options == 2 || Alinement_View)
		{
			float DepthBlur = 0, Alinement_Depth = tex2Dlod(M_Sampler,float4(TexCoords,0,0)).x, Depth = Alinement_Depth;
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
			float2 dir = 0.5 - TexCoords; 
			[loop]
			for (int i = 0; i < Con; i++)
			{
				DepthBlur += tex2Dlod(M_Sampler,float4(TexCoords + dir * cardinalOffsets[i] * pix * DBPower,0,1) ).x;
			}
			
			Alinement_Depth = ( Alinement_Depth + DepthBlur ) * 0.1;
			color.rgb = dot(tex2Dlod(Non_Point_Sampler,float4(TexCoords,0,0)).rgb,0.333) * float3((Depth/Alinement_Depth> 0.998),1,(Depth/Alinement_Depth > 0.998));
		}
		if( Helper_Fuction() == 0 || timer <= 0)  
			color.rgb *= TexCoords.xyx;
		
	#if Reconstruction_Mode || Virtual_Reality_Mode
		//Show Infill Mask: paint this eye's mask before the split.
		[branch]
		if(Show_Infill_Mask)
		{
			float3 Green = float3(0.0, 1.0, 0.0);
			#if BC_SPACE == 1
			//Tint in the normalized HDR space.
			Green = NormalizeScRGB(float4(Green, 0)).rgb;
			#endif
			color.rgb = lerp(color.rgb, Green, smoothstep(0.5, 0.9, Left_Right.a));
		}
		Left.rgb = Pattern_Type ? 0 : color.rgb ;
		Right.rgb= Pattern_Type ? color.rgb  : 0;
		Left.w = 1.0; 
		Right.w= 1.0;
	#else
		#if Anaglyph_Mode
		LR_Out = color.rgba;
		#else
		//Alpha carries the infill mask for the passes after this one.
		float Hole_A = max(Left_Right.w, max(L.w, R.w));
		#if EX_DLP_FS_Mode && !Virtual_Reality_Mode
		if(Stereoscopic_Mode == Frame_Selector().w)
			Hole_A = Frame_Selector().x ? L.w : R.w;
		#endif
		return float4(color.rgb, Hole_A);
		#endif
	#endif
	}
	#endif
	#if IL_EYES
	//Which interleave the eye buffer serves: 0 none, 1 lines, 2 columns, 3 checkerboard.
	int IL_Layout()
	{
		#if Virtual_Reality_Mode
		return 3;
		#elif Reconstruction_Mode
		return Reconstruction_Type == 1 ? 1 : Reconstruction_Type == 2 ? 2 : 3;
		#else
		return Stereoscopic_Mode >= 2 && Stereoscopic_Mode <= 4 ? Stereoscopic_Mode - 1 : 0;
		#endif
	}
	//The screen pixel a texIL_Eyes pixel stands for.
	float2 IL_Screen_Pos(float2 position, int Lay)
	{
		float2 B = floor(position), P;
		float2 Half = floor(Res * 0.5);
		if(Lay == 1)
		{
			float L = B.y < Half.y;
			P = float2(B.x, 2.0 * (B.y - (L ? 0.0 : Half.y)) + L);
		}
		else
		{
			float L = B.x < Half.x, Row = Lay == 3 ? B.y : 0.0;
			P = float2(2.0 * (B.x - (L ? 0.0 : Half.x)) + fmod(Row + L, 2.0), B.y);
		}
		return P + 0.5;
	}
	//Where this screen pixel sits in texIL_Eyes.
	float2 IL_Eyes_TC(float2 position)
	{
		int Lay = IL_Layout();
		float2 P = floor(position), B = P;
		float2 Half = floor(Res * 0.5);
		if(Lay == 1)
			B.y = floor(P.y * 0.5) + (fmod(P.y, 2.0) ? 0.0 : Half.y);
		else
		{
			float Pat = Lay == 3 ? P.x + P.y : P.x;
			B.x = floor(P.x * 0.5) + (fmod(Pat, 2.0) ? 0.0 : Half.x);
		}
		return (B + 0.5) * pix;
	}
	float4 IL_Eyes_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		int Lay = IL_Layout();
		//Other modes do not read it, so skip the write too.
		[branch]
		if(Lay == 0)
			discard;
		float2 P = IL_Screen_Pos(position.xy, Lay);
		#if Reconstruction_Mode || Virtual_Reality_Mode
		float4 L, R;
		CB_Reconstruction(float4(P, 0.0, 1.0), P * pix, L, R);
		return float4(L.rgb + R.rgb, 1.0);
		#else
		return PS_calcLR(P * pix, P);
		#endif
	}
	#if Reconstruction_Mode || Virtual_Reality_Mode
	void CB_Recon_IL(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Left : SV_Target0, out float4 Right : SV_Target1)
	{
		int Lay = IL_Layout();
		float2 P = floor(position.xy);
		float3 C = tex2Dlod(Sampler_IL_Eyes, float4(IL_Eyes_TC(position.xy), 0, 0)).rgb;
		bool Pattern_Type = fmod(Lay == 1 ? P.y : Lay == 2 ? P.x : P.x + P.y, 2.0);
		Left  = float4(Pattern_Type ? float3(0.0, 0.0, 0.0) : C, 1.0);
		Right = float4(Pattern_Type ? C : float3(0.0, 0.0, 0.0), 1.0);
	}
	#endif
	#endif
	///////////////////////////////////////////////////////Average & Information Textures///////////////////////////////////////////////////////////////
	float Dilate3x3(sampler tex, float2 texcoords, float mipLevel)
	{
	    //The loop reads the centre too.
	    float m = 1e10;
		SD_UNROLL
	    for (int j = -1; j <= 1; ++j)
	    {
	    	SD_UNROLL 
	        for (int i = -1; i <= 1; ++i)
	        {
	            float2 XY = float2(i, j) * pix * (50.0 * lerp(1,0.5,saturate(Alpha_Finer_Mip_Center)));
	            float v = tex2Dlod(tex, float4(texcoords + XY, 0, mipLevel)).x;
	            m = min(m, v);
	        }
	    }
	    return m;
	}
	
	void Average_Info(float4 position : SV_Position, float2 texcoord : TEXCOORD, out  float4 Average : SV_Target0)
	{
		float Half_Buffer = texcoord.x < 0.5;
		float Average_ZPD = tex2Dlod(SamplerzBuffer_BlurEx,float4(texcoord,0,0)).x;
		float Average_D = Dilate3x3(SamplerzBufferN_L,texcoord, Alpha_Channel_UI ? 4.0f : 3.0f); //?: on the mip only. On the calls it ran both.
		float Detect_Popout = tex2Dlod(SamplerzBufferN_L,float4(texcoord,0,1)).x < 0;
	
		const int Num_of_Values = 8; //8 array values in total that map to the texture's width.
		float Storage_Array_A[Num_of_Values] = { tex2D(SamplerDMN,0).x,    			 //0.0625 //TL Fade in Out
	                                             tex2D(SamplerDMN,1).x,                 //0.1875 //BR Fade X Level 0
	                                             tex2D(SamplerDMN,int2(0,1)).x,         //0.3125 //BL Fade Y Level 1
	                                             tex2D(SamplerzBufferN_P,0).y,          //0.4375 //TL
								             	tex2D(SamplerzBufferN_P,1).y,          //0.5625 //BR AltWeapon_Fade
								             	tex2D(SamplerzBufferN_P,int2(0,1)).y,  //0.6875 //BL Weapon_ZPD_Fade
												 tex2D(SamplerzBufferN_L,0).y,          //0.8125 //TL Popout detection
												 1.0}; 			                     //0.9375								 
												 //LBDetection seems to be causing issues with TC_SP.xy.											 
		float Storage_Array_B[Num_of_Values] = { LBDetection(),                         //0.0625                     
	                                			 tex2D(SamplerDMN,int2(1,0)).x,         //0.1875 //TR Fade Z Level 2
	                               			  tex2D(SamplerDMN,int2(1,0)).y,         //0.3125 //TR Fade Z Level 3
	                                			 tex2D(SamplerDMN,0).y,                 //0.4375 //TL Fade Z Level 4
												 tex2D(SamplerDMN,1).y,                 //0.5625 //BR Fade Z Level 5
												 tex2D(SamplerzBufferN_P,int2(1,0)).y,  //0.6875 
												 tex2D(SamplerDMN,int2(0,1)).y,         //0.8125 //BL Fade W The Switch
												 tex2D(SamplerzBufferN_L,int2(0,1)).y}; //0.9375 //BL OverShoot_Fade()
		//Set an average size for the number of lines needed in texture storage.
		float Grid = floor(texcoord.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);
		#if WHM 
		float UI_MAP = texcoord.x < 0.5 ? WeaponMask(texcoord * float2(2,1),7.5) : WeaponMask(texcoord * float2(2,1) - float2(1,0),7.0);
			Average = float4(UI_MAP, Average_ZPD, Half_Buffer ? Storage_Array_A[int(fmod(Grid,Num_of_Values))] : Storage_Array_B[int(fmod(Grid,Num_of_Values))],Detect_Popout);
 	   #else
			Average = float4(Average_D, Average_ZPD, Half_Buffer ? Storage_Array_A[int(fmod(Grid,Num_of_Values))] : Storage_Array_B[int(fmod(Grid,Num_of_Values))],Detect_Popout);
		#endif 
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	float colorDiffBlend(float3 a, float3 b)
	{
	    float3 differential = a - b;
	    return rcp(length(differential) + 0.001);
	}

	#if Reconstruction_Mode || Virtual_Reality_Mode
	float4 Direction(float2 texcoord,float dx, float dy, int Switcher) //Load Pixel
	{
		texcoord += float2(dx, dy);
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

	#if IL_EYES && Reconstruction_Mode && !Virtual_Reality_Mode
	//Texel S of the old eye texture, read from texIL_Eyes. S must be an Eye texel.
	float3 IL_Fetch(float2 S, float Eye, int Lay)
	{
		float2 Half = floor(Res * 0.5),
		       B = Lay == 1 ? float2(S.x, floor(S.y * 0.5) + (Eye ? 0.0 : Half.y))
		                    : float2(floor(S.x * 0.5) + (Eye ? 0.0 : Half.x), S.y);
		return tex2Dlod(Sampler_IL_Eyes, float4((B + 0.5) * pix, 0, 0)).rgb;
	}
	float IL_Odd(float2 S, int Lay)
	{
		return fmod(Lay == 1 ? S.y : Lay == 2 ? S.x : S.x + S.y, 2.0);
	}
	float3 IL_Tap(float2 Q, float2 Pair, float Eye, int Lay, bool Flip)
	{
		float2 A = clamp(Q, 0.0, Res - 1.0), B = clamp(Q + Pair, 0.0, Res - 1.0);
		float Am = IL_Odd(A, Lay) == Eye, Bm = IL_Odd(B, Lay) == Eye;
		[branch]
		if(Flip)
			return 0.5 * (Am + Bm) * IL_Fetch(Am ? A : B, Eye, Lay);
		return 0.5 * (Am * IL_Fetch(A, Eye, Lay) + Bm * IL_Fetch(B, Eye, Lay));
	}
	//differentialBlend for the one eye this pixel shows, read straight from texIL_Eyes.
	float3 IL_Blend(float2 position, int Set_Direction)
	{
		int Lay = IL_Layout();
		float2 P = floor(position), Half = floor(Res * 0.5), Pair, Q;
		float Eye;
		if(Stereoscopic_Mode == 0)
		{
			Eye = P.x < Half.x;
			Pair = float2(1.0, 0.0);
			Q = float2(2.0 * (P.x - (Eye ? 0.0 : Half.x)), P.y);
		}
		else
		{
			Eye = P.y < Half.y;
			Pair = float2(0.0, 1.0);
			Q = float2(P.x, 2.0 * (P.y - (Eye ? 0.0 : Half.y)));
		}
		//Lines keep the parity along X, columns along Y. Checkerboard flips both ways.
		bool Flip = Stereoscopic_Mode == 0 ? Lay != 1 : Lay != 2;
		float3 Up     = IL_Tap(Q + float2( 0.0,-1.0), Pair, Eye, Lay, Flip),
		       Down   = IL_Tap(Q + float2( 0.0, 1.0), Pair, Eye, Lay, Flip),
		       Left   = IL_Tap(Q + float2(-1.0, 0.0), Pair, Eye, Lay, Flip),
		       Right  = IL_Tap(Q + float2( 1.0, 0.0), Pair, Eye, Lay, Flip),
		       Center = IL_Tap(Q, Pair, Eye, Lay, Flip);

		float verticalWeight = colorDiffBlend(Up, Down);
		float horizontalWeight = colorDiffBlend(Left, Right);
		float3 VertResult = (Up + Down) * verticalWeight;
		float3 HorzResult = (Left + Right) * horizontalWeight;

		if(Set_Direction == 1)
			return Center + VertResult * 0.5 * rcp(verticalWeight);
		else if(Set_Direction == 2)
			return Center + HorzResult * 0.5 * rcp(horizontalWeight);
		else
			return Center + (VertResult + HorzResult) * 0.5 * rcp(verticalWeight + horizontalWeight);
	}
	#endif

	#if Filter_Image
	float4 Dir(sampler Tex, float2 texcoord,float dx, float dy, int Set_Direction)
	{
		texcoord += float2(dx, dy);
			float3 Pattern = float3( floor(texcoord.y*Res.y) + floor(texcoord.x*Res.x), floor(texcoord.x*Res.x), floor(texcoord.y*Res.y));
			float Pattern_Type = fmod(Pattern.x,2); //CB
			if(Set_Direction)
				return Pattern_Type ? 0 : tex2D(Tex, texcoord ) ;
			else
				return Pattern_Type ? tex2D(Tex, texcoord ) : 0 ;
	}
	
	float4 CBBlend(sampler Tex,float2 texcoord,int Switcher )
	{    
		if ((texcoord.x > 1 || texcoord.x < 0) || (texcoord.y > 1 || texcoord.y < 0))
		    return 0;

		float4 Up     = Dir(Tex,texcoord, 0.0  ,-pix.y, Switcher),
		       Down   = Dir(Tex,texcoord, 0.0  , pix.y, Switcher),
		       Left   = Dir(Tex,texcoord,-pix.x, 0.0  , Switcher),
		       Right  = Dir(Tex,texcoord, pix.x, 0.0  , Switcher),
			   Center = Dir(Tex,texcoord, 0.0  , 0.0  , Switcher), 
               Result;
	
	    float verticalWeight = colorDiffBlend(Up.rgb, Down.rgb);
	    float horizontalWeight = colorDiffBlend(Left.rgb, Right.rgb);
		float4 VertResult = (Up + Down) * verticalWeight;
		float4 HorzResult = (Left + Right) * horizontalWeight;
	    
		Result = Center + (VertResult + HorzResult) * 0.5 * rcp(verticalWeight + horizontalWeight);
		
		//float Mask = length(EdgeDetection(Tex, texcoord, pix));
	
	    return lerp(tex2D(Tex,texcoord),Result,1);
	}

	float4 MixModeBlend(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{  
	    return ( CBBlend(Live_Sampler,texcoord,0) + CBBlend(Live_Sampler,texcoord,1) ) * 0.5; //Filters the live image before Current_Frame captures it.
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

	//Returns the status of a bit in a bitmap. Works on the value, so the float's exact representation does not matter.
	float getBit( float map, float index )
	{   // Ooh -index takes out that divide :)
	    return fmod( floor( map * exp2(-index) ), 2.0 );
	}
	
	float drawChar( float Char,inout float2 posXY, float2 charsize, float2 TC, float shift)
	{	
		posXY.x += shift;  
		// Subtract our position from TC to test if we are inside the bounding box.
	    TC -= posXY;
	    // Divide the screen space by the size, so our bounding box is 1x1.
	    TC /= charsize;
	    // Branchless bounding box check, stored in res.
	    float res = step(0.0,min(TC.x,TC.y)) - step(1.0,max(TC.x,TC.y));
	    // Scale TC by the bitmap size to work in bitmap space.
	    TC *= float2(4,5);//Map Size
	    // Get the appropriate bit and return it.
	    res*=getBit( Char, 4.0*floor(TC.y) + floor(TC.x) );
	    return saturate(res);
	}

	//Whether the post pass (USMOut) runs. When it is skipped StereoOut writes alpha = max(r, g, b) itself.
	bool Post_Runs()
	{
		#if REST_UI_Mode
		return true;
		#elif DoubleBuffer_Mode && !Virtual_Reality_Mode
		return false;//No post passes here.
		#else
		#if !Virtual_Reality_Mode
		bool Sharp_On = Sharpen_Power > 0 && Stereoscopic_Mode != 4;
		#else
		bool Sharp_On = Sharpen_Power > 0 && Stereoscopic_Mode != 2;
		#endif
		return (Infill_Blur != 0 && POST_INFILL_OK) || (Show_Infill_Mask && POST_MASK_OK) || Sharp_On;
		#endif
	}
	float4 Post_Alpha(float4 C)
	{
		if(!Post_Runs())
			C.a = max(C.r, max(C.g, C.b));
		return C;
	}
	#if DoubleBuffer_Mode && !Virtual_Reality_Mode && !DX9_Toggle
	//Double Buffer: the 3D goes out through DoubleTex to an add-on, and the screen stays flat, so a short note at the
	//top middle says what is needed. Not in DX9: 24 unrolled characters would not fit its instruction limit.
	float3 DB_Notice(float3 C, float2 texcoord)
	{
		const float2 Size = float2(.00875, .0125) * 1.1;
		const float  Step = 0.011, Top = 0.955;
		float2 TC = float2(texcoord.x, 1 - texcoord.y);
		[branch]
		if(TC.y < Top - 0.005 || TC.y > Top + Size.y + 0.005)
			return C;
		const float N = 24.0, Start = 0.5 - N * Step * 0.5;
		//NEEDS FULL FORMAT ADD-ON
		const float A[24] = { CH_N, CH_E, CH_E, CH_D, CH_S, CH_BLNK, CH_F, CH_U, CH_L, CH_L, CH_BLNK, CH_F, CH_O, CH_R, CH_M,
		                      CH_A, CH_T, CH_BLNK, CH_A, CH_D, CH_D, CH_HYPH, CH_O, CH_N };
		float2 Pos = float2(Start, Top);
		float  Txt = 0;
		SD_UNROLL
		for(int i = 0; i < 24; i++)
			Txt += drawChar(A[i], Pos, Size, TC, i == 0 ? 0.0 : Step);
		//A dark band behind the text so it reads on any image.
		if(TC.x > Start - 0.005 && TC.x < Start + N * Step + 0.005)
			C *= 0.35;
		return lerp(C, 1.0, saturate(Txt));
	}
	#endif
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
			float2 Va = p.xy*float2(C_A1,1.0f)-float2(C_A2,0.5f);
			float2 Vb = p.xy*float2(1.0f,C_B1)-float2(0.5f,C_B2);
			float2 Vc = p.xy*float2(C_C1,1.0f)-float2(C_C2,0.5f);
			if(dot(Va,Va) > 0.25f)
				p = 1000;//offscreen
			else if(dot(Vb,Vb) > 0.25f)
				p = 1000;//offscreen
			else if(dot(Vc,Vc) > 0.390625f)
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
		// Super3D: Stereo3D output that compresses the Left and Right images.
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
			{
				float4 Color;
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
					{
						#if DoubleBuffer_Mode
							// No Barrel Distortion or Circle here, by design.
							// DoubleTex (BUFFER_WIDTH*2 x BUFFER_HEIGHT) already holds the full res SBS image.
							//SBS matches it 1:1, hardware bilinear downsamples 2:1 horizontally.
							float2 db_uv = VR_Stereoscopic_Mode() == 0
								? texcoord
								: (texcoord.y < 0.5
									? float2(texcoord.x * 0.5,       texcoord.y * 2.0)
									: float2(texcoord.x * 0.5 + 0.5, texcoord.y * 2.0 - 1.0));
							Color.rgb = tex2D(SamplerDouble, db_uv).rgb;
						#else
							Color.rgb = TC ? Left_CB : Right_CB;
						#endif
					}
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
				//The pattern is inverted because the Unity app can only read integer values from ReShade.
				float2 ScreenPos = float2(1-texcoord.x,1-texcoord.y) * Res;
				float Debug_Y = 1.0;// Set higher to see it when debugging
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
				return Post_Alpha(Color.rgba);
			}
		#else
			#if Anaglyph_Mode
			static const float Blur_Blue_Offset[7] = { -1.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.5 };
			static const float Blur_Blue_Weight[7] = { 0.035, 0.100, 0.233, 0.264, 0.233, 0.100, 0.035 }; // Normalized Gaussian weights (σ ≈ 0.75)
			#endif
			float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
			{
				float4 Color;
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
					#if IL_EYES
				Color.rgb = IL_Blend(position.xy, Reconstruction_Type);
					#else
				Color.rgb = Stereo_Convert( texcoord, differentialBlend(TCL, 0, Reconstruction_Type), differentialBlend(TCR, 1, Reconstruction_Type) ).rgb;
					#endif	  	
				#else
				
					#if Anaglyph_Mode //Need to add blur here on the blue channel.	
						float Acc = 0.0, Blur_Blue = 0.0;
						float MS = abs(Divergence_Switch().y) * pix.x;
		
						if(Stereoscopic_Mode == Anaglyph_Selection(8))
						{
							Color.rg = tex2D(Sampler_SD_RL,texcoord).rg;
							float2 BO = 1.2 * pix * max(1.0, BUFFER_HEIGHT / 1080.0);
							SD_UNROLL
							for (int y = -1; y <= 1; ++y)
							{
								SD_UNROLL
								for (int x = -1; x <= 1; ++x)
								{
									float weight = (x == 0 ? 0.375 : 0.3125) * (y == 0 ? 0.375 : 0.3125);
									Blur_Blue += tex2Dlod(Sampler_SD_RL, float4(texcoord + float2(x, y) * BO, 0, 0)).b * weight;
								}
							}
							Color.b = Blur_Blue;
						}
						else
						{
							#if !DX9_Toggle
							//Only Red-Blue blurs from neighbours and needs texSD_RL. The rest are mixed right here.
							float4 AG;
							Anaglyph(position, texcoord, AG);
							Color.rgb = AG.rgb;
							#else
							Color.rgb = tex2D(Sampler_SD_RL,texcoord).rgb;
							#endif
							/*
							[loop]
							for (int i = 0; i < 7; ++i)
							{
							    float Num = Blur_Blue_Offset[i] * MS;
							    float weight = Blur_Blue_Weight[i];
							    Blur_Blue += tex2Dlod(Sampler_SD_RL, float4(float2(texcoord.x + Num * 0.6666666666666667, texcoord.y), 0, 1)).b * weight;
							    Acc += weight;
							}
							Color.b = Blur_Blue / Acc;
							*/
						}					
					#else
					float4 LR_Hole;
					#if DoubleBuffer_Mode
					//The 3D goes out through DoubleTex, so the screen shows the flat image.
					LR_Hole = float4(tex2D(BB_Mask, texcoord).rgb, 0);
					#if !DX9_Toggle
					LR_Hole.rgb = DB_Notice(LR_Hole.rgb, texcoord);
					#endif
					#elif IL_EYES
					[branch]
					if(Stereoscopic_Mode >= 2 && Stereoscopic_Mode <= 4)
						LR_Hole = tex2Dlod(Sampler_IL_Eyes, float4(IL_Eyes_TC(position.xy), 0, 0));
					else
						LR_Hole = PS_calcLR(texcoord, position.xy);
					#else
					LR_Hole = PS_calcLR(texcoord, position.xy);
					#endif
					Color.rgb = LR_Hole.rgb;
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
				//Color.rgb = PS_calcLR(texcoord, position.xy).rgb;
				//uniform float gamepad_toggle[20] < source = "gamepad_toggle"; >;
				//uniform float gamepad_raw[20]    < source = "gamepad_raw";    >;
				
				//Color.rgb = gamepad_toggle[4];
				//Color = Trigger_Fade_Hold;
				//Color = 1-tex2D(Non_Point_Sampler,texcoord).w;
				//Color = PrepDepth(texcoord)[2][0];
				//Color = Dilate3x3(SamplerzBufferN_L,texcoord, 4.0f);
				//
				//Color = TSAA( texcoord, rcp_Depth_Size());
				//Color = tex2D(SamplerzBufferP_Up , texcoord ).x;
				//Color = Res.x == tex2Dsize(DepthBuffer).x ? 1 : 0;
				/*				
				float2 depthSize = tex2Dsize(DepthBuffer);
				float2 screenSize = Res;
				
				// Calculate aspect ratios
				float aspectDRatio = depthSize.x / depthSize.y;
				float aspectSRatio = screenSize.x / screenSize.y;
				
				// Determine aspect ratio type
				float tolerance = 0.01;
				float AR = 0; // Default: widescreen or other
				
				if (abs(aspectSRatio - ASPECT_16_9) < tolerance)
				{
				    AR = 1; // 16:9
				}
				else if (abs(aspectSRatio - ASPECT_16_10) < tolerance)
				{
				    AR = 2; // 16:10
				}
				
				Color = AR == 2 ? 1 : 0;
				*/
				//0.025
				//0.975
				//Color = texcoord.y > 0.88 ? 1 : Color;
				//Color = ARDetection();
				//Color = tex2D(SamplerInfo,texcoord).y;
				//Color = tex2Dlod(WDepthBuffer, float4(texcoord,0,0)).x;
				//Color = WDepthCheck; //WDepthCheck = weapon present
				#if !Reconstruction_Mode && !Anaglyph_Mode
				//Alpha is confidence. 1 is clean reprojection, lower is infilled hole.
				Color.a = 1.0 - LR_Hole.a;
				#endif

				return Post_Alpha(Color.rgba);
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
				return Post_Alpha(MouseCursor(float3(texcoord.xy,0), position.xy , Mouse_Toggle_Click, 0));
			else
				return Post_Alpha(texcoord.x < 0.5 ?  MouseCursor(float3(texcoord.xy * float2(2,1),0), position.xy , Mouse_Toggle_Click, 0) : 1-GetMixed(texcoord * float2(2,1) - float2(1.0, 0.0), 0).x);
	}
	#endif
	#if DoubleBuffer_Mode
	//One Double Buffer pixel: texcoord spans both eyes (0 to 1 over the double width).
	float4 DB_Eye(float2 texcoord, float4 position)
	{
		#if !Virtual_Reality_Mode
		//Non VR.
		[branch]
		if(Stereoscopic_Mode != 0)
			return 0;
		float4 C = PS_calcLR(texcoord, position.xy);
		//Show Infill Mask.
		if(Show_Infill_Mask)
			C.rgb = lerp(C.rgb, float3(0.0, 1.0, 0.0), smoothstep(0.5, 0.9, C.a));
		return float4(C.rgb, 1.0);
		#else
		float2 DLR, TCL, TCR, TCL_T, TCR_T;
		float  Pattern_Type;
		//Con_Values skips the SBS doubling in VR, so remap to per eye UV here.
		float2 src_uv = texcoord.x < 0.5
			? float2(texcoord.x * 2.0,        texcoord.y)
			: float2(texcoord.x * 2.0 - 1.0, texcoord.y);
		Con_Values(src_uv, DLR, TCL, TCR, TCL_T, TCR_T, Pattern_Type);

		// Vert_3D_Pinball swap, same as PS_calcLR.
		if (Vert_3D_Pinball)
		{
			TCL = TCL.yx;
			TCR = TCR.yx;
		}

		// Direct per eye parallax, same calls as PS_calcLR.
		//if, not ?:, which would march both eyes.
		//VR's eyes are mirrored, as PS_calcLR's VR path.
		float4 eye;
		[branch]
		if(DB_Scale < 0.999)
			eye = DB_Fetch(texcoord, texcoord.x < 0.5 ? TCR : TCL);
		else if(texcoord.x < 0.5)
			eye = Parallax( DLR.y, TCR, -AI);
		else
			eye = Parallax(-DLR.x, TCL,  AI);

		// Vert_3D_Pinball post swap, same as PS_calcLR.
		if (Vert_3D_Pinball)
			eye.xyz = eye.yxz;

		// MouseCursor blend, same as PS_calcLR.
		float4 C = MouseCursorS(eye.xyz, eye.w, position.xy, 1, 0);
		//Show Infill Mask, as the non VR path above.
		if(Show_Infill_Mask)
			C.rgb = lerp(C.rgb, float3(0.0, 1.0, 0.0), smoothstep(0.5, 0.9, C.a));
		return float4(C.rgb, 1.0);
		#endif
	}
	//Reduced eyes.
	float4 DB_Low(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		float2 DLR, TCL, TCR, TCL_T, TCR_T;
		float  Pattern;
		#if !Virtual_Reality_Mode
		[branch]
		if(Stereoscopic_Mode != 0)
			return 0;
		Con_Values(texcoord, DLR, TCL, TCR, TCL_T, TCR_T, Pattern);
		Pattern = fmod(Pattern, 2);
		float4 Shift_LR = Vert_3D_Pinball ? Pattern ? float4(-DLR.x, TCL.yx, AI) : float4(DLR.y, TCR.yx, -AI)
		                                  : Pattern ? float4(-DLR.x, TCL,    AI) : float4(DLR.y, TCR,    -AI);
		float4 C = Parallax(Shift_LR.x, Shift_LR.yz, Shift_LR.w);
		return float4(C.xy - Shift_LR.yz, C.z, VM0_Pack_Half(C.w));
		#else
		float2 src_uv = texcoord.x < 0.5
			? float2(texcoord.x * 2.0,        texcoord.y)
			: float2(texcoord.x * 2.0 - 1.0, texcoord.y);
		Con_Values(src_uv, DLR, TCL, TCR, TCL_T, TCR_T, Pattern);
		if (Vert_3D_Pinball)
		{
			TCL = TCL.yx;
			TCR = TCR.yx;
		}
		//if, not ?:, which would march both eyes.
		float4 C;
		float2 Base;
		//Mirrored as DB_Eye's VR path: the left half is the TCR side.
		[branch]
		if(texcoord.x < 0.5)
		{
			C = Parallax( DLR.y, TCR, -AI);
			Base = TCR;
		}
		else
		{
			C = Parallax(-DLR.x, TCL,  AI);
			Base = TCL;
		}
		return float4(C.xy - Base, C.z, VM0_Pack_Half(C.w));
		#endif
	}
	//Full resolution.
	float4 DB_Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		return DB_Eye(texcoord, position);
	}
	#endif
	static const float ZDP_Array[9] = { 0.25, 0.50, 0.75, 1.000, 1.000, 1.000, 0.75, 0.50, 0.25 };
	float4 InfoOut(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		float3 Color;
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
		#if EDW
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
		//Disable CA/MB/DoF/Grain		
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


		//Set an average size for the number of lines needed in texture storage.
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
	    if (Sharp_This > 0 && Stereoscopic_Mode != 4) //Blocked in CB mode
	    #else
	    if (Sharp_This > 0 && Stereoscopic_Mode != 2) //Blocked in CB mode
	    #endif
	    {
			//Bilateral Filter//                                                Q1         Q2       Q3        Q4
			const int kSize = MSIZE * 0.5; // Default M-size is Quality 2 so [MSIZE 3] [MSIZE 5] [MSIZE 7] [MSIZE 9] / 2.
			
			float2 RPC_WS = pix * 1.5;
			float Z = 0, factor;
			final_color = 0;
			//CAS min and max over every tap.
			mn = LI(centerColor.rgb);
			mx = mn;
			
			[loop]
			for (int i=-kSize; i <= kSize; ++i)
			{
				for (int j=-kSize; j <= kSize; ++j)
				{
					nc = tex2Dlod(Tex, float4(texcoord.xy + float2(i,j) * RPC_WS * rcp(kSize * 2.0f),0,0)).rgb;
					factor = normpdf3(nc.rgb-centerColor.rgb, SIGMA);
					Z += factor;
					final_color += factor * nc;
					mn = min(mn, LI(nc.rgb));
					mx = max(mx, LI(nc.rgb));
				}
			}
			
			final_color = saturate(final_color/Z);
			
			mn = min(mn, LI(final_color.rgb));
			mx = max(mx, LI(final_color.rgb));
			
			// Smooth minimum distance to signal limit divided by smooth max.
			float rcpM = rcp(max(mx, 1e-5)), CAS_Mask;
			
			// Shape the sharpening amount with the mask
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

	float4 SmartSharpJr(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{  	//Runs after StereoOut, so it reads the live back buffer (the stereo image), never the delayed copy.
		#if BC_SPACE == 1
		float4 Color = Sharp(Live_Sampler, texcoord, 1.0);
		#else
		float4 Color = tex2Dlod(Live_Sampler,float4(texcoord,0,0));
	//Confidence from the infill mask in alpha. Holes skip sharpening so fabricated detail is not amplified.
	//Works with D_Frame too: the live back buffer carries the same mask in both modes.
	#if !Reconstruction_Mode && !Virtual_Reality_Mode && !Anaglyph_Mode && !Use_2D_Plus_Depth && !REST_UI_Mode
	float Conf = Color.a;
	#else
	float Conf = 1.0;
	#endif
		       Color.w = max(Color.r, max(Color.g, Color.b));	
		#endif
		 
		#if BC_SPACE == 1
	    return Color;
	    #else
	    return float4(lerp(Color.rgb, Sharp(Live_Sampler, texcoord, 1.0).rgb, Conf),Color.w);
	    #endif
	}
	//Mask from back buffer alpha, tuned on 2 bits.
	float Mask_A(float a)
	{
		#if DX9_Toggle
		a = round(a * 3.0) / 3.0;
		#endif
		return smoothstep(0.5, 0.9, 1.0 - a);
	}
	float Post_Mask(float2 tc)
	{
		return Mask_A(tex2Dlod(BB_Mask, float4(tc, 0, 0)).a);
	}
	void Post_Layout(float2 tc, out float4 Bnd, out float2 Stp, out float Eye)
	{
		float2 Px = floor(tc * Res);
		int Lay = Stereoscopic_Mode;
		#if REST_UI_Mode
		if(Stereoscopic_Mode == 0 || Stereoscopic_Mode == 3)
			Lay = 3;
		else if(Stereoscopic_Mode == 1 || Stereoscopic_Mode == 2)
			Lay = 2;
		else
			Lay = 4;
		#endif
		Bnd = float4(0.0, 1.0 - pix.x, 0.0, 1.0 - pix.y);
		Stp = 1.0;
		Eye = 1.0;
		if(Lay == 0)
		{
			Bnd.xy = tc.x < 0.5 ? float2(0.0, 0.5 - pix.x) : float2(0.5, 1.0 - pix.x);
			Eye = tc.x < 0.5 ? 1.0 : -1.0;
		}
		else if(Lay == 1)
		{
			Bnd.zw = tc.y < 0.5 ? float2(0.0, 0.5 - pix.y) : float2(0.5, 1.0 - pix.y);
			Eye = tc.y < 0.5 ? 1.0 : -1.0;
		}
		else if(Lay == 2)
		{
			Stp.y = 2.0;
			Eye = fmod(Px.y, 2.0) ? 1.0 : -1.0;
		}
		else if(Lay == 3)
		{
			Stp.x = 2.0;
			Eye = fmod(Px.x, 2.0) ? 1.0 : -1.0;
		}
		else if(Lay == 4)
		{
			Stp = 2.0;
			Eye = fmod(Px.x + Px.y, 2.0) ? 1.0 : -1.0;
		}
		else if(Lay == 5)
		{
			Bnd.xy = tc.x < 0.5 ? float2(0.0, 0.5 - pix.x) : float2(0.5, 1.0 - pix.x);
			Bnd.zw = tc.y < 0.5 ? float2(0.0, 0.5 - pix.y) : float2(0.5, 1.0 - pix.y);
			Eye = tc.y < 0.5 ? 1.0 : -1.0;
		}
		#if EX_DLP_FS_Mode && !Virtual_Reality_Mode
		else
			Eye = Frame_Selector().x ? 1.0 : -1.0;
		#endif
	}
	//A tap Off px away, kept on this eye.
	float2 Post_TC(float2 tc, float2 Off, float4 Bnd, float2 Stp)
	{
		Off = float2(Stp.x > 1.0 ? round(Off.x * 0.5) * 2.0 : Off.x, Stp.y > 1.0 ? round(Off.y * 0.5) * 2.0 : Off.y);
		float2 p = tc + Off * pix;
		return float2(clamp(p.x, Bnd.x, Bnd.y), clamp(p.y, Bnd.z, Bnd.w));
	}

	//Mask edge AA.
	float Mask_AA(float2 tc, float Ms, float4 Bnd, float2 Stp)
	{
		[branch]
		if(Ms <= 0.0)
			return Ms;
		float Mn = Post_Mask(Post_TC(tc, float2( Mask_Edge_Px, 0), Bnd, Stp)) + Post_Mask(Post_TC(tc, float2(-Mask_Edge_Px, 0), Bnd, Stp))
		         + Post_Mask(Post_TC(tc, float2( 0, Mask_Edge_Px), Bnd, Stp)) + Post_Mask(Post_TC(tc, float2( 0,-Mask_Edge_Px), Bnd, Stp));
		return min(Ms, lerp(Ms, Mn * 0.25, Mask_Edge_Soft));
	}
	float4 Infill_Blur_Post(float4 position, float2 texcoord)
	{
		float4 BB = tex2Dlod(BB_Mask, float4(texcoord, 0, 0));
		[branch]
		if((Infill_Blur == 0 && !MEM_SHOW) || !POST_INFILL_OK)
			return BB;
		//Kernel reach in px. Never scale Soft instead, that flattens the taper.
		const float Post_Px = 18.0, Post_Guard = 0.15;
		float Soft_Px = Infill_Soft_Px;
		float4 Bnd;
		float2 Stp;
		float  Eye;
		Post_Layout(texcoord, Bnd, Stp, Eye);
		//One sided toward the background. Bg_Flip -1.0 is the tested direction.
		const float Bg_Flip = -1.0;
		float dBg = sign(Divergence_Switch().x) * Eye * Bg_Flip;
		//Sharp mask, unpacked from BB which is already this tap. Also the object cut-out below.
		float Ms = Mask_A(BB.a);
		//Nothing to blur outside a gap. The debug RED readout below needs these pixels though.
		[branch]
		if(Ms <= 0.0 && !Infill_Blur_Debug && !MEM_SHOW)
			return BB;
		//Mask edge AA, see Mask_AA.
		Ms = Mask_AA(texcoord, Ms, Bnd, Stp);
		//At full softness a lone masked pixel averages to 0.
		[branch]
		if(Ms <= 0.0 && !Infill_Blur_Debug && !MEM_SHOW)
			return BB;
		//VM2 and VM4 dither: one tap at a noise offset, toward the object only while still gap.
		[branch]
		if(VM_Infill_Dither && Ms > 0.0 && !MEM_SHOW)
		{
			float Jd = Interleaved_Gradient_Noise(floor(position.xy));
			float Jk = Interleaved_Gradient_Noise(floor(position.xy) + 7.0);
			[branch]
			if(Jk >= Ms)
				return BB;
			float  o  = (Jd * 2.0 - 1.0) * Ms * Dither_Reach_Px * (Bnd.y - Bnd.x + pix.x);
			float4 Td = tex2Dlod(BB_Mask, float4(Post_TC(texcoord, float2(o, 0), Bnd, Stp), 0, 0));
			bool   Ok = o * dBg >= 0.0 || Mask_A(Td.a) > 0.0;
			float  Wd = dot(abs(Td.rgb - BB.rgb) * rcp(abs(BB.rgb) + 0.25), float3(0.3333, 0.3333, 0.3333));
			//VM4.
			[branch]
			if(View_Mode == 4 && !(Ok && Wd < 1.0))
			{
				float Jd2 = Interleaved_Gradient_Noise(floor(position.xy) + 13.0);
				float o2  = (Jd2 * 2.0 - 1.0) * Ms * Dither_Reach_Px * (Bnd.y - Bnd.x + pix.x);
				Td = tex2Dlod(BB_Mask, float4(Post_TC(texcoord, float2(o2, 0), Bnd, Stp), 0, 0));
				Ok = o2 * dBg >= 0.0 || Mask_A(Td.a) > 0.0;
				Wd = dot(abs(Td.rgb - BB.rgb) * rcp(abs(BB.rgb) + 0.25), float3(0.3333, 0.3333, 0.3333));
			}
			return (Ok && Wd < 1.0) ? float4(Td.rgb, BB.a) : BB;
		}
		//Gaussian weights exp(-2*(k/8)^2). Four taps stepped at a high Softness.
		const float GW[8] = { 0.9692, 0.8825, 0.7548, 0.6065, 0.4578, 0.3247, 0.2162, 0.1353 };
		float Msum = Ms, Wsum = 1.0;
		SD_UNROLL
		for(int k = 1; k <= 8; k++)
		{
			float w = GW[k - 1];
			Msum += Post_Mask(Post_TC(texcoord, float2(dBg * k * 0.125 * Soft_Px, 0), Bnd, Stp)) * w;
			Wsum += w;
		}
		//Remap the ends, never scale. The average bottoms out at 1/Wsum, not 0.
		float Prof = Msum * rcp(Wsum);
		float Pmin = rcp(Wsum);
		//The fade lives here, not in Parallax.
		float2 Src = (Post_TC(texcoord, float2(dBg * Soft_Px, 0), Bnd, Stp) - Bnd.xz) * rcp(Bnd.yw - Bnd.xz + pix);
		float  Nf  = Depth_Blend(smoothstep(0, 1, tex2Dlod(SamplerDMN, float4(Src, 0, 0)).x));
		float Post_Curve = lerp(0.55, 4.0, lerp(Mask_Extend_Fade_Near, Mask_Extend_Fade_Far, Nf));
		//The falloff, 1 at the object down to 0. Falloff off degrades half as much.
		float Fall = pow(saturate((Prof - Pmin) * rcp(1.0 - Pmin)), Post_Curve);
		float Soft = (Infill_Falloff ? Fall : (Fall > 0.0 ? lerp(1.0, Fall, 0.5) : 0.0)) * Ms;
		//Red marks the object side. Tinting by Prof lets the blue line through.
		[branch]
		if(Ms <= 0.0)
			return float4(lerp(BB.rgb, float3(1.0, 0.0, 0.0), saturate(Prof)), BB.a);
		[branch]
		if(Soft <= 0.002)
			return BB;
		min16float3 RcpC = rcp(abs(BB.rgb) + 0.25);//Colour maths in half precision.
		const min16float3 Third = min16float3(0.3333, 0.3333, 0.3333);
		min16float4 Acc = BB;
		min16float  Csum = 1.0;
		min16float  L_Min = dot(saturate(BB.rgb), float3(0.2126, 0.7152, 0.0722)), L_Max = L_Min;
		//Symmetric, object side clipped per tap. 20 Gaussian taps as 10 bilinear pairs.
		const float PO[10] = { 1.4963, 3.4913, 5.4863, 7.4813, 9.4759,
		                      11.4713, 13.4663, 15.4612, 17.4558, 19.4514 };
		const float PW[10] = { 1.9752, 1.8791, 1.7178, 1.5089, 1.2735,
		                       1.0328, 0.8049, 0.6027, 0.4337, 0.2998 };
		//Reach follows Soft only partly.
		float Step = Post_Px * 0.05 * lerp(0.45, 1.0, Soft);
		//Sub pixel jitter, half a step max. Breaks up leftover banding.
		float Jit = Interleaved_Gradient_Noise(floor(position.xy)) - 0.5;
		SD_UNROLL
		for(int b = 0; b < 10; b++)
		{
			float  o  = dBg * (PO[b] + Jit) * Step;
			min16float4 Ta = tex2Dlod(BB_Mask, float4(Post_TC(texcoord, float2( o, 0), Bnd, Stp), 0, 0));
			min16float4 Tb = tex2Dlod(BB_Mask, float4(Post_TC(texcoord, float2(-o, 0), Bnd, Stp), 0, 0));
			min16float  Wf = PW[b];
			min16float  Wa = Wf * saturate(1.0 - dot(abs(Ta.rgb - BB.rgb) * RcpC, Third) * Post_Guard);
			min16float  Wb = Wf * saturate(1.0 - dot(abs(Tb.rgb - BB.rgb) * RcpC, Third) * Post_Guard)
			               * Mask_A(Tb.a);
			Acc  += Ta * Wa + Tb * Wb;
			Csum += Wa + Wb;
			//Contrast from the 3 nearest pairs only.
			if(b < 3)
			{
				min16float2 Lab = min16float2(dot(saturate(Ta.rgb), float3(0.2126, 0.7152, 0.0722)), dot(saturate(Tb.rgb), float3(0.2126, 0.7152, 0.0722)));
				L_Min = min(L_Min, min(Lab.x, Lab.y)); L_Max = max(L_Max, max(Lab.x, Lab.y));
			}
		}
		//Sheeting runs along X, so these cross it. Symmetric, both sides mask clipped.
		[branch]
		if(Post_Vert > 0.0)
		{
			float Vstp = Post_Px * 0.05 * lerp(0.45, 1.0, Soft);
			SD_UNROLL
			for(int v = 0; v < 6; v++)
			{
				float  oy = (PO[v] + Jit) * Vstp;
				min16float4 Tu = tex2Dlod(BB_Mask, float4(Post_TC(texcoord, float2(0,  oy), Bnd, Stp), 0, 0));
				min16float4 Td = tex2Dlod(BB_Mask, float4(Post_TC(texcoord, float2(0, -oy), Bnd, Stp), 0, 0));
				min16float  Wv = PW[v] * Post_Vert;
				min16float  Wu = Wv * saturate(1.0 - dot(abs(Tu.rgb - BB.rgb) * RcpC, Third) * Post_Guard)
				              * Mask_A(Tu.a);
				min16float  Wd = Wv * saturate(1.0 - dot(abs(Td.rgb - BB.rgb) * RcpC, Third) * Post_Guard)
				              * Mask_A(Td.a);
				Acc  += Tu * Wu + Td * Wd;
				Csum += Wu + Wd;
			}
		}
		Soft = saturate(Soft * Infill_Guide(BB.rgb, L_Min, L_Max));
		//Alpha untouched, the overlay below still reads the mask from it.
		[branch]
		if(Infill_Blur_Debug || MEM_SHOW)
			return float4(lerp(BB.rgb, float3(0.0, 1.0, 0.0), Soft), BB.a);
		float3 Blurred = lerp(BB.rgb, (Acc * rcp(Csum)).rgb, Soft);
		return float4(Blurred, BB.a);
	}
	//The mask overlay rides on the post pass, one full screen pass fewer.
	float4 Infill_Blur_Post_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		float4 BB = Infill_Blur_Post(position, texcoord);
		if(Show_Infill_Mask && POST_MASK_OK && !MEM_INFILL)
		{
			//Alpha is only 2 bits on a 10 bit back buffer, so a clean pixel quantises to 0.67.
			float4 Bnd;
			float2 Stp;
			float  Eye;
			Post_Layout(texcoord, Bnd, Stp, Eye);
			BB.rgb = lerp(BB.rgb, float3(0.0,1.0,0.0), Mask_AA(texcoord, Mask_A(BB.a), Bnd, Stp));
		}
		return BB;
	}
	#if !REST_UI_Mode
	//Experimental.
	float4 Infill_USM_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		float4 BB  = Infill_Blur_Post_PS(position, texcoord);
		float4 Raw = tex2Dlod(Live_Sampler, float4(texcoord, 0, 0));
		float3 Det = Sharp(Live_Sampler, texcoord, 1.0).rgb - Raw.rgb;
		#if BC_SPACE == 1
		return float4(BB.rgb + Det, BB.a);
		#else
		#if !Reconstruction_Mode && !Virtual_Reality_Mode && !Anaglyph_Mode && !Use_2D_Plus_Depth
		float Conf = BB.a;
		#else
		float Conf = 1.0;
		#endif
		return float4(BB.rgb + Det * Conf, max(BB.r, max(BB.g, BB.b)));
		#endif
	}
	#endif
	#if AXAA_EXIST
	float4 SDAA_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		float4 Out;
		if(USE_AA == 1)
		{
			#if Anaglyph_Mode || Inficolor_3D_Emulator
			//One AXAA per eye on its own channels. Shared channels blend.
			float3 Lc, Rc;
			AG_Channels(Lc, Rc);
			float4 AL = AXAA_W(Live_Sampler, AXAA_F_Sampler, texcoord, BC_SPACE, Lc, AXAA_Linear),
			       AR = AXAA_W(Live_Sampler, AXAA_F_Sampler, texcoord, BC_SPACE, Rc, AXAA_Linear);
			Out = float4(lerp(AR.rgb, AL.rgb, Lc * rcp(max(Lc + Rc, 0.001))), max(AL.a, AR.a));
			#else
			Out = AXAA_W(Live_Sampler, AXAA_F_Sampler, texcoord, BC_SPACE, 1.0, AXAA_Linear);
			#endif
		}
		else
			Out = tex2Dlod(Live_Sampler,float4(texcoord,0,0));
		return Out;	
	}
	#endif
	#if Frame_Packed_Mode && !REST_UI_Mode
	float4 Framed_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{	
	    float gapNorm = 0.040816326;
	
	    float halfGap = gapNorm * 0.5;
	
	    float topEnd    = 0.5 - halfGap;
	    float bottomBeg = 0.5 + halfGap;
	    float2 srcUV = texcoord;
	    
		if(Stereoscopic_Mode == 1 )
		{
			if ( Frame_Packed )
			{
			    // Black middle bar
			    if (texcoord.y > topEnd && texcoord.y < bottomBeg)
			        return float4(0, 0, 0, 1);
			
			    if (texcoord.y <= topEnd)
			    {
			        // Top output area samples the original top half
			        srcUV.y = texcoord.y / topEnd * 0.5;
			    }
			    else
			    {
			        // Bottom output area samples the original bottom half
			        srcUV.y = 0.5 + ((texcoord.y - bottomBeg) / (1.0 - bottomBeg)) * 0.5;
			    }
			}
		}
	    return tex2D(Live_Sampler, srcUV);
	}
	#endif			
	#if REST_UI_Mode //Thank you Tjandra for this option. 
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
	{	//Must read the live back buffer. Non_Point_Sampler points at the delayed copy in this mode.
		return tex2Dlod(Live_Sampler,float4(texcoords,0,0));
	}
	
	float4 DelayFrame(in float4 position : SV_Position, in float2 texcoords : TEXCOORD) : SV_Target
	{
		return tex2Dlod(SamplerCF,float4(texcoords,0,0));
	}
	#endif
	
	#if !DX9_Toggle //Not needed in DX9
		#if Anti_Jitter_Mode	
		void Acc_Buffer(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Acc : SV_Target0)
		{   
			float Out = tex2Dlod(SamplerzBufferP_TAA,float4(texcoord,0,0)).x;
			
			//Do not do this in DX9
			//G is Orig_Depth.
			Acc = float2(Out,Orig_Depth(texcoord));
		}	
		#endif
	#endif	
	///////////////////////////////////////////////////////////////////ReShade.fxh//////////////////////////////////////////////////////////////////////
	void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{// Vertex shader generating a triangle covering the entire screen
		texcoord.x = (id == 2) ? 2.0 : 0.0;
		texcoord.y = (id == 1) ? 2.0 : 0.0;
		position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
	}
	#if MEM_INFILL
	//Not this pass's frame: draw nothing.
	void Mem_VS_A(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(Frames % 2 != 0)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	void Mem_VS_B(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(Frames % 2 == 0)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if VM0_FIELD
	//The structure field is only read in VM0.
	void SF_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(View_Mode != 0)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if IL_EYES
	//With no interleave the triangle collapses to nothing, so the pass draws no pixels.
	void IL_Eyes_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(IL_Layout() == 0)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if !DX9_Toggle
	float ShiftD_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		int3 S = Shift_Depth();
		return S.x + 2.0 * S.y + 4.0 * S.z + 8.0 * (LBDetection() != 0);
	}
	//Only Mix_Z's Auto Scaler reads it.
	void ShiftD_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(!(Auto_Scaler_Adjust && AR_Is != 2))
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if AG_EYES
	//A two triangle quad (6 vertices) over the used width only.
	void AG_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		texcoord = float2(id == 1 || id == 4 || id == 5 ? 1.0 : 0.0, id == 2 || id == 3 || id == 5 ? 1.0 : 0.0);
		#if AG_INFICOLOR
		float Used = 2.0 * floor(BUFFER_WIDTH * (0.5 + 0.5 * IF_Scale)) * rcp(floor(BUFFER_WIDTH * AG_BUDGET));
		#else
		float Used = 1.0;
		#endif
		position = float4(texcoord.x * 2.0 * Used - 1.0, 1.0 - texcoord.y * 2.0, 0.0, 1.0);
		if(!Anaglyph_Fast)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if DoubleBuffer_Mode
	void DB_Low_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		texcoord = float2(id == 1 || id == 4 || id == 5 ? 1.0 : 0.0, id == 2 || id == 3 || id == 5 ? 1.0 : 0.0);
		position = float4(texcoord.x * 2.0 * DB_Width - 1.0, 1.0 - texcoord.y * 2.0, 0.0, 1.0);
		if(DB_Scale >= 0.999)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if Anaglyph_Mode && !DX9_Toggle
	//Only Red-Blue reads texSD_RL, so the pass draws nothing for the other anaglyph modes.
	void Anaglyph_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(Stereoscopic_Mode != Anaglyph_Selection(8))
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if AXAA_EXIST
	//Anti-Aliasing Off would only copy the back buffer onto itself, so draw nothing.
	void SDAA_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(USE_AA == 0)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif
	#if !REST_UI_Mode
	//USMOut only runs for the infill blur, the mask overlay or sharpening.
	void USM_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(!Post_Runs())//Same test StereoOut uses for the alpha.
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif

	technique Information_SD
	< ui_label = "Information";
	//toggle = Text_Info_Key;
	 hidden = true;
	 enabled = true;
	 timeout = 1250;
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
	< ui_tooltip = "Suggestion: You can enable the 'Performance Mode' checkbox in the bottom right of ReShade's main UI.\n"
				   			 "Do this once you have set your 3D settings, of course."; >
	{	
		#if Filter_Image
			pass BlendOut
		{
			VertexShader = PostProcessVS;
			PixelShader = MixModeBlend;
		}
		#endif
	
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
		#if !DX9_Toggle //DX9 never reads texMiniReconBuffer, so the pass is skipped there.
			pass MiniReconstuction
		{
			VertexShader = PostProcessVS;
			PixelShader = MiniReconstructionPS;
			RenderTarget0 = texMiniReconBuffer;
		}
		#endif
			pass Modzbuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = Mod_Z;
			RenderTarget0 = texzBufferN_P;
			RenderTarget1 = texzBufferN_L;
		}
		
		#if !DX9_Toggle
			pass ShiftDepth
		{
			VertexShader = ShiftD_VS;
			PixelShader = ShiftD_PS;
			RenderTarget0 = texShiftD;
		}
		#endif
			pass MixDepth
		{
			VertexShader = PostProcessVS;
			PixelShader = Mix_Z;
			RenderTarget0 = texzBufferN_M;
		}

		#if DX9_Toggle //Same chain as the other paths, on the two DX9 buffers.
			pass ReconstructionDX9
		{
			VertexShader = PostProcessVS;
			PixelShader = ReconstructionDX9PS;
			RenderTarget0 = texSmooth;
		}
			pass DepthAADX9
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthAAPS;
			RenderTarget0 = texzBufferN_M;
		}
			pass DepthSmoothDX9
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthSmoothPS;
			RenderTarget0 = texSmooth;
		}
		#endif
				
		#if !DX9_Toggle		
			#if Anti_Jitter_Mode	
				pass TAA
		    {
		        VertexShader = PostProcessVS;
		        PixelShader = TAA_Buffer;
		        RenderTarget0 = TAABuffer;
		    }
		    #endif
		    
			pass Reconstruction 
		{
			VertexShader = PostProcessVS;
			PixelShader = ReconstructionPS;
			RenderTarget0 = texReconBuffer;
		}
		
		pass DepthSmooth
		{
		    VertexShader = PostProcessVS;
		    PixelShader = DepthSmoothPS;
		    RenderTarget0 = texSmooth;
		}
		
		#endif
		#if POM_MINH && !Use_2D_Plus_Depth
			pass Nearest_Depth_Chain
		{
			VertexShader = PostProcessVS;
			PixelShader = MinH_PS;
			RenderTarget0 = texMinH;
		}
		#endif
		#if VM0_FIELD
			pass Structure_Field
		{
			VertexShader = SF_VS;
			PixelShader = SF_PS;
			RenderTarget0 = texSF;
		}
		#endif
		
		#if MEM_INFILL
			pass Memory_Update_A //Even frames.
		{
			VertexShader = Mem_VS_A;
			PixelShader = Mem_PS_A;
			RenderTarget0 = texMemA;
			RenderTarget1 = texAgeA;
		}
			pass Memory_Update_B //Odd frames.
		{
			VertexShader = Mem_VS_B;
			PixelShader = Mem_PS_B;
			RenderTarget0 = texMemB;
			RenderTarget1 = texAgeB;
		}
		#endif
		#if AG_EYES
			pass Fast_Eyes
		{
			VertexCount = 6;
			VertexShader = AG_VS;
			PixelShader = AG_Eyes_PS;
			RenderTarget0 = texAG_Eyes;
		}
		#endif
		#if IL_EYES
			pass Interleaved_Eyes
		{
			VertexShader = IL_Eyes_VS;
			PixelShader = IL_Eyes_PS;
			RenderTarget0 = texIL_Eyes;
		}
		#endif
		#if (Reconstruction_Mode && !IL_EYES) || Virtual_Reality_Mode || Anaglyph_Mode //Reconstruction with the eye buffer reads it directly.
			pass Muti_Mode_Reconstruction
		{
			#if Anaglyph_Mode && !DX9_Toggle
			VertexShader = Anaglyph_VS;
			#else
			VertexShader = PostProcessVS;
			#endif
			#if Anaglyph_Mode
			PixelShader = Anaglyph;
			RenderTarget0 = texSD_RL;
			#elif IL_EYES
			PixelShader = CB_Recon_IL;
			RenderTarget0 = texSD_CB_L;
			RenderTarget1 = texSD_CB_R;
			#else
			PixelShader = CB_Reconstruction;
			RenderTarget0 = texSD_CB_L;
			RenderTarget1 = texSD_CB_R;
			#endif
		}
		#endif
		#if DoubleBuffer_Mode
			pass DoubleLow
		{
			VertexCount = 6;
			VertexShader = DB_Low_VS;
			PixelShader = DB_Low;
			RenderTarget0 = texDB_March;
		}
			pass DoubleOut
		{
			VertexShader = PostProcessVS;
			PixelShader = DB_Out;
			RenderTarget0 = DoubleTex;
		}
		#endif		
			pass StereoOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
		#if !(DoubleBuffer_Mode && !Virtual_Reality_Mode)
		#if REST_UI_Mode //Elsewhere the infill blur runs inside USMOut.
			pass InfillBlurPost
		{
			VertexShader = PostProcessVS;
			PixelShader = Infill_Blur_Post_PS;
		}
		#endif

		#if !REST_UI_Mode
				pass USMOut
			{
				VertexShader = USM_VS;
				PixelShader = Infill_USM_PS; //Infill blur and sharpening in one pass.
			}	
			#if AXAA_EXIST
				pass SDAA
			{
				VertexShader = SDAA_VS;
				PixelShader = SDAA_PS;
			}
			#endif
			
			#if Frame_Packed_Mode && !EX_DLP_FS_Mode
			pass Framed
			{
				VertexShader = PostProcessVS;
				PixelShader = Framed_PS;
			}
			#endif
	
		#endif
		#endif
		#if Anti_Jitter_Mode && !DX9_Toggle //Acc_Buffer and AccBuffer do not exist in DX9, same as the TAA pass above.
		    pass ACC //Accumulation Buffer //Past
	    {
	        VertexShader = PostProcessVS;
	        PixelShader = Acc_Buffer;
	        RenderTarget0 = AccBuffer;
	    }	
		#endif	
	}
	#if REST_UI_Mode
	technique REST_3D_UI	
	< ui_label = "REST 3D UI Separation";
	 hidden = true;
	 enabled = true;
	 ui_tooltip = "Make sure this is unchecked in REST."; >
	{
		pass REST_UI_Pass
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
			pass SDAA
		{
			VertexShader = SDAA_VS;
			PixelShader = SDAA_PS;
		}
		#endif
	}
	#endif		
}