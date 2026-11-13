	////----------------//
	///**SuperDepth3D**///
	//----------------////
	#define SD3D "MeshWarp3D v6.0.0\n" //
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//* Depth Map Based 3D post-process shader
	//* For Reshade 5.0+
	//* ---------------------------------
	//*
	//* MeshWarp3D is based on the tessellation examples used to build 3D maps for external devices.
	//* It is tuned to work together with backward warping.
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
	//* Written by Jose Negrete AKA BlueSkyDefender <UntouchableBlueSky@gmail.com>, November 2026
	//*
	//* Please feel free to contact me if you want to use this in your project.
	//* https://github.com/BlueSkyDefender/Depth3D
	//* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader
	//* https://discord.gg/Q2n97Uj
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

namespace MeshWarp3D
{
	#define VEN 0
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
		// DJ_Y = [Menu Detection Type] DJ_Z = [Match Threshold] DJ_W = [Check Depth Limit Weapon]
		static const float DJ_Y = 0.0, DJ_Z = 0.0, DJ_W = -0.100;
		// DK_X = [FPS Focus Method] DK_Y = [Eye Eye Selection] DK_Z = [Eye Fade Selection] DK_W = [Eye Fade Speed Selection]	
		static const float DK_X = 0, DK_Y = 0.0, DK_Z = 0, DK_W = 1;
		// DL_Y = [De-Artifact] DL_Z = [Compatibility Power] DL_W = [Not Used Here]
		static const float DL_Y = 0.125, DL_Z = 0, DL_W = 0.05;		
		// DM_X = [HQ Tune] DM_Y = [HQ Depth] DM_Z = [HQ Smooth] DM_W = [HQ Trim]
		static const float DM_X = 3, DM_Y = 1, DM_Z = 1, DM_W = 0.0;
		// DN_X = [Position A & B] DN_Y = [Position C & D] DN_Z = [Position E & F] DN_W = [Menu Size Main]	
		static const float DN_X = 0.0, DN_Y = 0.0, DN_Z = 0.0, DN_W = 0.0;
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
		static const int SMSUM = 0, RSV = 0, AJM = 0, MED = 0, SBTDA = 0, SMSBT = 0, UIF = 0, UIL = 0, RCI = 0, AIM = 0, WMM = 0, SDD = 0, DMM = 0, LBD = 0, WSM = 0, ULF = 0, IBL = 0;
		static const int2 DOL = 0;
		//Triggers 
		static const float UFC = 0, UIB = 0, HNR = 0, THF = 0, EGB = 0,PLS = 0, MGA = 0, WZD = 0, KHM = 0, DAO = 0, LDT = 0, ALM = 0, SSF = 0, SNF = 0, SSE = 0, SNE = 0, EDU = 0, LBI = 0,ISD = 0, ASA = 1, IWS = 0, SUI = 0, SSA = 0, SNA = 0, SSB = 0, SNB = 0,SSC = 0, SNC = 0,SSD = 0, SND = 0, WBS = 0, TMD = 0, FRM = 0, AWZ = 0, CWH = 0, WBA = 0, WFB = 0, WND = 0, WNR = 0, ABWS = 0, AFS = 0.4375, WRP = 0, SMD = 0, WHM = 0, SDU = 0, ABE = 2, LBE = 0, HQT = 0, HMD = 0.5, MAC = 0, OIL = 0, FTM = 0, FMM = 0, SPO = 0, LBR = 0, AFD = 0, MDD = 0, FPS = 1, SMS = 1, OIF = 0, NCW = 0, RHW = 0, NPW = 0, SPF = 0, BDF = 0, HMT = 0, HMC = 0, NFM = 0, DSW = 0, LBC = 0, LBS = 0, LBM = 0, DAA = 0, NDW = 0, PEW = 0, WPW = 0, FOV = 0, EDW = 0, SDT = 0;
		//Overwatch.fxh State
		#define OSW 1
	#endif

	//////////////////////////////////////////////
	//USER EDITABLE PREPROCESSOR FUNCTIONS START//
	//////////////////////////////////////////////

	//////////////
	// Profiler //
	//////////////

	#define Profiler_Mode 0 //If you want to make your own profiles and submit them to BlueSkyDefender Aka Depth3D Main Dev

	///////////
	// Depth //
	///////////

	// Barrel Distortion Correction For SuperDepth3D for non conforming BackBuffer.
	#define BD_Correction      0 //Default 0 is Off. One is On.

	// Horizontal & Vertical Depth Buffer Resize for non conforming DepthBuffer.
	// Also used to enable Image Position Adjust is used to move the Z-Buffer around.
	#define DB_Size_Position   0 //Default 0 is Off. One is On.

	// Auto Letter Box Correction
	#define LB_Correction      0 //[Zero is Off] [One is Auto Hoz] [Two is Auto Vert]
	// Auto Letter Box Masking
	#define LetterBox_Masking  0 //[Zero is Off] [One is Auto Hoz] [Two is Auto Vert]

	// Specialized Depth Triggers
	#define SD_Trigger         0 //Default is off. One is Mode A other Modes not added yet.

	// This shift the detectors for ZPD Boundary Detection.
	#define Shift_Detectors_Up SDU //Default 0 is Off. One is On
	//To override or activate this SDU change your have to set it too 0 or 1.

	////////////////
	// 3D Outputs //
	////////////////

	// Experimental DLP mode for Side By Side and the lesser supported Top n Bottom
	#if !defined(EX_DLP_FS_Mode) //Not #ifndef, so it stays off the preprocessor list.
		#define EX_DLP_FS_Mode 0  //Default 0 is Off. One is On
	#endif
	//Please note this mode should run at your DLP native resolution at 720p or 1080p Native 120hz Auto Mode.
	//Keeping a stable 120hz in game is required. Not sure if this is something we can enforce for now.
	//Lot of issues with this mode that needs to be looked into. For now it's something to try out for fun.
	//Keep in mind this Frame Sequential only for testing and no usable unless the game can keep a steady frame rate of around 120.
	//It also has Debug options for advance users.

	// Double Buffer Mode makes a double wide SBS texture for capture add-ons like VRExport.
	#ifndef DoubleBuffer_Mode
		#define DoubleBuffer_Mode 0  //Default 0 is Off. One is On
	#endif

	// Focus Depth Mode uses Inficolor's depth handling on the other 3D outputs.
	#ifndef Focus_Depth_Mode
		#define Focus_Depth_Mode 0  //Default 0 is Off. One is On
	#endif

	/////////
	// HUD //
	/////////

	// HUD Mode is for Extra UI MASK and Basic HUD Adjustments. This is useful for UI elements that are drawn in the Depth Buffer.
	// Such as the game Naruto Shippuden: Ultimate Ninja, TitanFall 2, and or Unreal Gold 277. That have this issue. This also allows for more advance users
	// Too Make there Own UI MASK if need be.
	// You need to turn this on to use UI Masking options Below.
	#define HUD_MODE 0 // Set this to 1 if basic HUD items are drawn in the depth buffer to be adjustable.

	//////////
	// Keys //
	//////////

	// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key using keycode info
	// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
	#ifndef Cancel_Depth_Key
		#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	#endif

	// The Key Code for the mouse is 0-4 key 1 is right mouse button.
	#define Mouse_Key_Four   4 //Forward Mouse Button
	#define Mouse_Key_Three  3 //Back Mouse Button
	#define Mouse_Key_Two    2 //Middle Mouse Button

	#define Fade_Key         1 // Set default on mouse 1
	#define Fade_Time_Adjust 0.5625 // From 0 to 1 is the Fade Time adjust for this mode. Default is 0.5625;

	//Text Information Key Default Menu Key
	#define Text_Info_Key    93

	///////////////
	// Overwatch //
	///////////////

	//Fast Trigger Mode
	#define Fast_Trigger_Mode   FTM //To override or activate this set it to 0 or 1 This only works if Overwatch tells the shader to do it or not.

	////////////////////////////////////////////
	//USER EDITABLE PREPROCESSOR FUNCTIONS END//
	////////////////////////////////////////////

	/////////////////////
	//Internal Settings//
	/////////////////////

	/////////////
	// ReShade //
	/////////////

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

	//OpenGL drops the unroll hint so the driver compiles faster.
	#if ISOGL
		#define SD_UNROLL
	#else
		#define SD_UNROLL [unroll]
	#endif

	//The DX9 and DX10 path, for auto Convergence. Neither has compute shaders.
	#if __RENDERER__ < 0xb000
		#define DX9_DX10_Toggle 1
	#else
		#define DX9_DX10_Toggle 0
	#endif

	////////////
	// Screen //
	////////////

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

	//////////////////
	// Output Modes //
	//////////////////

	#ifndef Use_2D_Plus_Depth
		#define Use_2D_Plus_Depth 0
	#endif

	#if Use_2D_Plus_Depth
		#undef Virtual_Reality_Mode
		#define Virtual_Reality_Mode 0
		#undef Inficolor_3D_Emulator
		#define Inficolor_3D_Emulator 0
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

		#else
			#undef Anaglyph_Mode
			#define Anaglyph_Mode 0
			#undef Inficolor_3D_Emulator
			#define Inficolor_3D_Emulator 0
		#endif

		#if Virtual_Reality_Mode
			// This preprocessor is for Super3D Mode for close-to-full-res images using channel compression
			#ifndef Super3D_Mode
				#define Super3D_Mode 0
			#endif
		#endif
	#endif

	//DoubleBuffer is forced off when another output mode is on.
	#if DoubleBuffer_Mode
		#if Use_2D_Plus_Depth || Anaglyph_Mode || Inficolor_3D_Emulator || Super3D_Mode
			#undef  DoubleBuffer_Mode
			#define DoubleBuffer_Mode 0
		#endif
	#endif

	#ifndef HDR_Compatible_Mode
		#define HDR_Compatible_Mode 0
	#endif

	#if DX9_DX10_Toggle
		#ifndef Set_Custom_Sidebars
			#define Set_Custom_Sidebars 1
		#endif
	#else
		#define Set_Custom_Sidebars 1
	#endif

	//Inficolor's depth handling, also used by Focus Depth Mode
	#define IC_DEPTH         (Inficolor_3D_Emulator || (Focus_Depth_Mode && !Use_2D_Plus_Depth && !Virtual_Reality_Mode))

	//////////////
	// Handheld //
	//////////////

	//2D+Depth: always on.
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

	//////////////////
	// Edge and TAA //
	//////////////////

	#ifndef M_Edge
		#define M_Edge MED
	#endif

	#ifndef Anti_Jitter_Mode //TAA_Mode
		#define Anti_Jitter_Mode AJM
	#endif

	////////////////
	// GDM Add-on //
	////////////////

	#if !defined(GDM_DEPTH_AUTOFIT) //Not #ifndef, so it stays off the preprocessor list.
		#define GDM_DEPTH_AUTOFIT 0 //Exact depth fit from the GDM add-on. The add-on turns it on.
	#endif

	#if !defined(GDM_WEAPON_DEPTH) //Not #ifndef, so it stays off the preprocessor list.
		#define GDM_WEAPON_DEPTH 0 //One uses the GDM weapon hand buffer.
	#endif

	////////////
	// Infill //
	////////////

	//Infill debug views. [Zero is Off] [One is On]
	#define INFILL_DEBUG     0
	//Depth change in px that runs the hole taps
	#define HOLE_TRIGGER_PX  1.0
	//Background side taps in the hole check
	#define HOLE_REACH_TAPS  5

	//No infill debug sliders in DX9 and DX10
	#if DX9_DX10_Toggle && INFILL_DEBUG
		#undef INFILL_DEBUG
		#define INFILL_DEBUG 0
	#endif

	///////////////////
	// Memory Infill //
	///////////////////

	//DX11+. Listed only while the Depth3D Motion add-on is loaded.
	#if !DX9_DX10_Toggle && !Use_2D_Plus_Depth && defined(ADDON_DEPTH3D_MOTION)
		#ifndef Memory_Infill
			#define Memory_Infill 0
		#endif
	#endif

	#if !DX9_DX10_Toggle && !Use_2D_Plus_Depth && defined(ADDON_DEPTH3D_MOTION)
		//Memory resolution, 2 is half, and seconds a covered background is trusted
		#define MEM_INFILL       Memory_Infill
		#define MEM_DIV          2
		#define MEM_MAX_AGE      8.0
	#else
		#define MEM_INFILL       0
	#endif
	#define MEM_SHOW         (MEM_INFILL && Show_Infill_Mask)

	///////////////
	// Mesh Warp //
	///////////////

	//Mesh View debug: 1 the wire like the video card, 2 adds 8 px squares
	#if !defined(MW_MESH_VIEW) //Not #ifndef, so it stays off the preprocessor list.
		#define MW_MESH_VIEW 0
	#endif

	//Row Scan: DX11 and up, up to 3968 px wide
	#define MW_SCAN          1
	//Threads per row
	#define MW_SCAN_T        512
	//Packed March list size and groups of 64
	#define MW_PL_W          1024
	#define MW_PL_H          1024
	#define MW_PM_GROUPS     2048
	//March here, and this minus the slot is a Packed March
	#define MW_SCAN_NONE     1000000000.0
	#define MW_SCAN_PACK     -1000000.0

	////////////////
	// Eye Buffer //
	////////////////

	//Every output marches in a buffer pass. [Zero is Off] [One is On]
	#define IL_EYE_BUFFER    1
	#define AA_Format        RG16F
	#define AA_Type          float2

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
	////
	//Game Selection//
	#if MGA > 0
	uniform int Set_Game_Profile <
		ui_type = "combo";
		ui_items = MG_App;
		ui_label = "·Select Game·";
		ui_tooltip = "This sets the profile for an application that has multiple games.";
		ui_category = "Game Selection";
	> = 0;	
	#endif
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
	////
	//Zero Parallax Distance//
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
	
	//Workaround because of DX9 and DX10
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
	//OIL 5 gives DKK_W as a float4, its ZW is level 7. Below 5 it stays a float2, so old shaders still read it.
	#if OIL >= 5
		static const float4 DKK_W4 = DKK_W;
	#else
		static const float4 DKK_W4 = float4((float2)DKK_W, 0, 0);
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

		uniform float4 ZPD_Boundary_n_Cutoff_End <
			#if Compatibility
			ui_type = "drag";
			#else
			ui_type = "slider";
			#endif
			ui_min = 0.0; ui_max = 5.0;
			ui_label = " ZPD Scaler6 & Intrusion";
			ui_tooltip = "This selection gives extra boundary conditions to scale ZPD level Six, and level Seven on ZW.\n"
						 "Lets you adjust how far behind the screen it should detect an intrusion.\n"
						 "Only works when Boundary Detection is enabled & when scaler LvL one is set.";
			ui_category = "Zero Parallax Distance";
		> = DKK_W4;
	#endif
	
	uniform bool ZPD_Screen_Edge_Avoidance <
			ui_label = "ZPD Edge Guard";
			ui_tooltip = "ZPD Screen Edge Avoidance system called Edge Guard.\n"
						 "This allows more popout near the edge.";
			ui_category = "Zero Parallax Distance";
	> = EGB;
	////
	//Occlusion Masking//
	#if !Use_2D_Plus_Depth
		#if MEM_INFILL
		static const int View_Mode = 1;//Memory Infill runs Alpha.
		#else
		//Profiles keep their mode, Glass takes Stamped, the rest start on Alpha.
		#if DX9_DX10_Toggle && (DS_Z == 3 || DS_Z == 6)
			#define DS_Z_MW 1
		#elif DX9_DX10_Toggle
			#define DS_Z_MW 0
		#elif DS_Z == 6
			#define DS_Z_MW 3
		#else
			#define DS_Z_MW DS_Z
		#endif
		uniform int View_Mode <
			ui_type = "combo";
			#if DX9_DX10_Toggle
			ui_items = "VM1 Alpha \0VM2 Stamped \0VM3 Reiteration \0VM4 Mixed \0";
			#else
			ui_items = "VM0 Normal \0VM1 Alpha \0VM2 Reiteration \0VM3 Stamped \0VM4 Mixed \0VM5 Blend \0VM6 Glass \0";
			#endif
			ui_label = "·View Mode·";
			ui_tooltip = "Changes the way the shader fills in the occluded sections in the image.\n"
						#if !DX9_DX10_Toggle
						"Normal      | Alpha mixed with the mesh's rubber sheet, half near and a quarter far.\n"
						#endif
						"Alpha       | Reiteration with a refined landing.\n"
						"Reiteration | Same thing as Stamped but with breakage points.\n"
						#if DX9_DX10_Toggle
						"Stamped     | Stamps out a transparent area where occlusion happens.\n"
						#else
						"Stamped     | The mesh's rubber sheet stamped where occlusion happens, hard edge, Alpha everywhere else.\n"
						#endif
						"Mixed       | Used when there are high amounts of semi-transparent objects like foliage in the image.\n"
						#if !DX9_DX10_Toggle
						"Blend       | Glass near, Alpha far, blended softly between.\n"
						"Glass       | The mesh's rubber sheet in the fill, Alpha everywhere else.\n"
						#endif
						"\n"
						"Every mode adapts its steps to the scene: fewer where it is near.\n"
						"\n"
						"Warning: Also make sure Performance Mode is active before closing the ReShade menu.\n"
						"\n"
						"Default is Alpha.";
		ui_category = "Occlusion Masking";
		> = DS_Z_MW;
		#if DX9_DX10_Toggle
		#define View_Mode (View_Mode == 1 ? 3 : View_Mode == 2 ? 2 : View_Mode == 3 ? 4 : 1)//Stamped stays 1 for old presets.
		#else
		//VM6 Glass, VM3 Stamped, VM4 Mixed and VM5 Blend run as VM0 with their own mix, read before View_Mode is remapped.
		//VM3 is the rubber's stamp, VM4 dithers that stamp into Alpha, VM5 slides the Glass fill to Alpha's landing with distance.
		bool VM6_Glass() { return View_Mode == 6 || View_Mode == 3 || View_Mode == 4 || View_Mode == 5; }
		bool VM3_Rubber_Stamped() { return View_Mode == 3 || View_Mode == 4; }
		bool VM4_Mixed_Stamp() { return View_Mode == 4; }
		bool VM5_Glass_Blend() { return View_Mode == 5; }
		#define VM_Glass VM6_Glass()
		#define VM_Stamped_R VM3_Rubber_Stamped()
		#define VM_Mixed_R VM4_Mixed_Stamp()
		#define VM_Blend_R VM5_Glass_Blend()
		#define View_Mode (View_Mode == 6 || View_Mode == 3 || View_Mode == 4 || View_Mode == 5 ? 0 : View_Mode > 6 ? 3 : View_Mode)
		#endif
		#endif
	#else
	static const int View_Mode = 1;
	#endif

	//View Mode Settings
	//VM0 rubber: how far the background slides toward an object (0 to 1).
	//In VM0 the Halo Reduction slider + 1 sets how many tiles out it starts, and Halo Reduction itself stays at 3.
	static const float VM0_Rubber_Pull = 1.0;
	//VM5 Blend: x Blend Point, y Smooth
	static const float2 VM5_Blend_Point = float2(0.25, 0.25);
	//VM0 Normal: x Blend Point, y Smooth
	static const float2 VM0_Blend_Point = float2(0.0125, 0.125);
	//VM0 Normal: the rubber's share near and far, VM1 takes the rest
	static const float VM0_Near_Rubber = 0.5, VM0_Far_Rubber = 1.0;
	//VM6 Glass: the edge blend's reach in px (x near, y far), how far out the mirror reads times the hidden width,
	//and how many px the mirror's edge sits onto the background
	static const float2 VM6_Glass_Fade = float2(25.0, 75.0);
	static const float VM6_Mirror_Dist = 0.5, VM6_Edge_Offset = 2.0;
	//VM4 Mixed: how far its stamp reaches (0.5 is the real gap, 1.0 two gaps wide, 0 off),
	//and how much the stamp dithers into Reiteration (0 is the plain stamp)
	static const float VM4_Stamp_Reach = 0.5, VM4_Dither = 1.0;
	#ifndef VM_Glass
		#define VM_Glass false
	#endif
	#ifndef VM_Stamped_R
		#define VM_Stamped_R false
	#endif
	#ifndef VM_Mixed_R
		#define VM_Mixed_R false
	#endif
	#ifndef VM_Blend_R
		#define VM_Blend_R false
	#endif
	//VM6 Glass and VM5 Blend: the rubber's reach in tiles. Glass keeps depth step 1, Halo Reduction sets Blend's like VM1.
	static const int VM6_Rubber_Reach = 9, VM6_Depth_Step = 1;
	#define VM_Glass_Fill (VM_Glass && !VM_Stamped_R)
	//VM0 Normal: Alpha near, the rubber far, blended like Blend. DX9 and DX10 have no VM0.
	#if DX9_DX10_Toggle
		#define VM_Hybrid false
	#else
		#define VM_Hybrid (View_Mode == 0)
	#endif
	//VM0 and the rubber modes blur as VM1, VM2 and the old VM4 dither, VM1's blur fade reaches past the mask
	#define VM_Eff (View_Mode == 0 ? 1 : View_Mode)
	#define VM_Infill_Dither (VM_Eff == 2 || VM_Eff == 4)
	#define Blur_Grow_Px (VM_Eff == 1 ? 8.0 : 0.0)

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

	static const int Weapon_Near_Halo_Reduction = HNR; //Set by the profile.

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
					 "In VM0 Normal this sets how far the tuck in reaches instead.\n"
					 "Default is 3 and Zero is Off.";
		ui_category = "Occlusion Masking";
	> = DM_X;
	#if !DX9_DX10_Toggle
	uniform int Custom_Sidebars <
		ui_type = "combo";
		ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
		ui_label = " Edge Handling";
		ui_tooltip = "Edges selection for screen output.\n"
		  			 "What type of filling to use on the empty spaces at the edges.";
		ui_category = "Occlusion Masking";
	> = 1;
	#endif
	#if !Use_2D_Plus_Depth && !MEM_INFILL //Not with Memory Infill.
	uniform int Infill_Blur <
		ui_type = "combo";
		ui_items = "Off\0Blur\0Luma Guided\0Contrast Guided\0Blur Depth\0Luma Guided Depth\0Contrast Guided Depth\0";
		ui_label = " Infill Blur";
		ui_tooltip = "Softens the stretched areas that 3D leaves beside objects.\n"
					 "Off: no blur.\n"
					 "Blur: plain blur, strongest next to the object.\n"
					 "Luma Guided: blurs bright areas more, leaves dark areas mostly alone.\n"
					 "Contrast Guided: blurs patterns and edges more, leaves flat areas mostly alone.\n"
					 "Depth: the same, but a near background takes half the blur. A far background keeps it all.\n"
					 "Stamped is skipped. Reiteration and Mixed dither instead of blurring. Normal and Blend blur like Alpha.\n"
					 "Default is Off.";
		ui_category = "Occlusion Masking";
	> = IBL;
	#else
	static const int Infill_Blur = 0;
	#endif
	//Blur, Luma or Contrast, and if it follows depth.
	#define Infill_Blur_Type (Infill_Blur - (Infill_Blur > 3) * 3)
	#define Infill_Blur_Depth (Infill_Blur > 3)
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
	#if !Use_2D_Plus_Depth
	static const int Performance_Level = 0;//One level, the mesh sets the cost.
	#endif

	/* Will add this back when Eyetracking is a thing
	uniform bool Foveated_Mode <
			ui_label = "Foveated Rendering";
			ui_tooltip = "Foveated rendering lowers the quality of the infilling around the center of the image.\n"
						 "In the future when we have a method for eye tracking this should work a lot better.";
			ui_category = "Occlusion Masking";
	> = FRM;
	*/

	////
	//Compatibility Options//
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
	#endif

	static const int Reconstruction_Size = 1; //Fixed at 1.5x.

	////
	//Scaling Corrections//
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
	#if !DX9_DX10_Toggle && GDM_DEPTH_AUTOFIT
	//The GDM add-on fits the depth, so the scalers are not shown.
	static const int Auto_Scaler_Adjust = ASA;
		#if LBC || LB_Correction || EDW || DB_Size_Position || Profiler_Mode || SPF
		static const int LBD_Switcher = LBD;
		#endif
	#elif !DX9_DX10_Toggle
	uniform int Auto_Scaler_Adjust <
		ui_type = "combo";
			ui_items = "Off\0ON\0";
		ui_label = " Auto Scaler";
		ui_tooltip = "Shift the depth map if a slight misalignment is detected.\nNot used while the GDM add-on fits the depth.";
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
	
	////
	//Depth Map//
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
	uniform float ZPD_Balance <
		ui_type = "drag";
		ui_min = 0.0; ui_max = 1.0;
		ui_label = " Stereo Enhance";
		ui_tooltip = "Enhances the edges of objects and the 3D pop of the scene.\n" //***
					 "Flat areas like floors keep their normal depth.\n"
					 "Default is 0 for Off and 0.5 is a strong 3D pop.";
		ui_category = "Depth Map";
	> = DF_Z;
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
	////
	//Reposition Depth//
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
		static const int Anaglyph_Dubois_Light = 0;
		static const int Scaling_Support = 0;
		static const int Eye_Swap = 0;
		static const int Inficolor_Near_Reduction = 0;
		static const float Focus_Inficolor = 0.5;
		static const float Inficolor_Max_Depth = 1.0;
	#else
		#if Virtual_Reality_Mode
			static const int Reconstruction_Type = 0;
		#endif
		//Stereoscopic Options//
		#if Super3D_Mode && Virtual_Reality_Mode
		static const int Stereoscopic_Mode = 0;
		static const float Anaglyph_Saturation = 0.5;
		static const float Interlace_Optimization = 0.5;
		static const float2 Anaglyph_Eye_Contrast = 0.0;
		static const int Anaglyph_Dubois_Light = 0;
		static const int Scaling_Support = 0;

		static const int Inficolor_Near_Reduction = 0;
		static const float Focus_Inficolor = 0.5;
		static const float Inficolor_Max_Depth = 1.0;
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
							ui_items = "Anaglyph 3D Red-Cyan\0Anaglyph 3D Red-Cyan Dubois\0Anaglyph 3D Red-Cyan Deghosted\0Anaglyph 3D Red-Cyan LCD Optimized Anaglyph\0Anaglyph 3D Green-Magenta\0Anaglyph 3D Green-Magenta Dubois\0Anaglyph 3D Green-Magenta Deghosted\0Anaglyph 3D Amber-Blue ColorCode\0Anaglyph 3D Red-Blue Optimized\0Anaglyph 3D Magenta-Cyan\0Anaglyph 3D Amber-Blue Dubois\0";
							ui_label = " 3D Display Mode";
						#else
							ui_items = "TriOviz Inficolor 3D Emulation Alpha\0TriOviz Inficolor 3D Emulation Beta\0";
							ui_label = " 3D Display Mode";
						#endif
					#else
							#if EX_DLP_FS_Mode
								ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Quad Lightfield 2x2\0Frame Sequential\0";		
								ui_label = "·3D Display Modes·";
							#else
									ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Quad Lightfield 2x2\0Lenticular 3x3\0Holo Quilt 4x8\0Holo Quilt 5x9\0Holo Quilt 7x7\0Holo Quilt 8x6\0Holo Quilt 11x6\0";
								ui_label = "·3D Display Modes·";
							#endif
					#endif
				#endif
				ui_tooltip = "Stereoscopic 3D display output selection.\n"
							 "Lenticular 3x3 is 9 views for glasses free 3D screens.\n"
							 "Holo Quilt 4x8 is 32 views, 5x9 is 45, 7x7 is 49, 8x6 is 48 and 11x6 is 66.";
				ui_category = "Stereoscopic Options";
			> = 0;
			#endif
			#if Inficolor_3D_Emulator
			#if DX9_DX10_Toggle
			#define Anaglyph_Fast true //Both eyes in one shader are too big for DX9 and DX10.
			#else
			#define Anaglyph_Fast false
			#endif
			#endif
		//Interlace_Anaglyph_Calibrate
			#if Anaglyph_Mode || Inficolor_3D_Emulator
				uniform float Anaglyph_Saturation <
					ui_type = "drag";
					ui_min = 0.0; ui_max = 1.0;
					ui_label = " Anaglyph Saturation";
					ui_tooltip = "Anaglyph Desaturation allows for removing color from an anaglyph 3D image. Zero is Black & White, 0.5 is normal color, One is double color.\n"
								 "Default for Anaglyph Desaturation/Saturation is 0.5.";
					ui_category = "Stereoscopic Options";
				> = 0.5;
				static const float Interlace_Optimization = 0.5;
				
				uniform float2 Anaglyph_Eye_Contrast <
					ui_type = "drag";
					ui_min = 0.0; ui_max = 1.0;
					ui_label = " Anaglyph Contrast";
					ui_tooltip = "Per Eye mix for the Red-Cyan, Green-Magenta and ColorCode modes, Inficolor contrast.\n"
								 "Default is set to 0.5 Off.";
					ui_category = "Stereoscopic Options";
				> = float2(0.5,0.5);
				#if Anaglyph_Mode && !Inficolor_3D_Emulator
				uniform int Anaglyph_Dubois_Light <
					ui_type = "combo";
					ui_items = "Linear\0Gamma\0";
					ui_label = " Anaglyph Dubois Light";
					ui_tooltip = "How the Dubois modes mix the eyes. Linear is true light, Gamma is the old SD3D way.\n"
								 "Pick the one that ghosts less with your glasses. Default is Linear.";
					ui_category = "Stereoscopic Options";
				> = 0;
				#endif

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
			#if Anaglyph_Mode && !Inficolor_3D_Emulator && DX9_DX10_Toggle
			static const bool Anaglyph_Fast = true;//Both eyes in one shader are too big for DX9 and DX10.
			#elif Anaglyph_Mode && !Inficolor_3D_Emulator
			static const bool Anaglyph_Fast = false;
			#endif
			uniform bool Eye_Swap <
				ui_label = " Swap Eyes";
				ui_tooltip = "L/R to R/L."; // E/D ou D/E
		
				ui_category = "Stereoscopic Options";
			> = false;
	#endif

	#if Virtual_Reality_Mode
		uniform bool VR_Menu_Checkerboard <
			ui_label = " Menu Checkerboard";
			ui_tooltip = "Checkerboard while the ReShade menu is open.\n"
						 "Turn it off to keep your 3D Display Mode with the menu open.\n"
						 "Default is On.";
			ui_category = "Stereoscopic Options";
		> = true;
	#endif
	
	#if Virtual_Reality_Mode || Inficolor_3D_Emulator || Anaglyph_Mode || EX_DLP_FS_Mode || Use_2D_Plus_Depth || DoubleBuffer_Mode
		static const bool Frame_Packed = false;
	#else
		uniform bool Frame_Packed <
			ui_label = " Frame Packed 3D";
			ui_tooltip = "Frame Packed 3D only works when Top n Bottom format is used.\n"
						 "You must set the frame packed format yourself since it can't be done here.";

			ui_category = "Stereoscopic Options";
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
		ui_tooltip = "Overlays the infill blur mask in green on the 3D image, with its edge fade, even with Infill Blur off.\n"
					 "In anaglyph and Inficolor, red is the left eye's mask and blue the right eye's.\n"
					 "Default is Off.";
		ui_category = "Stereoscopic Options";
	> = false;

	////
	//FPS Focus//
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
	////
	//Distortion Corrections//
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
	////
	//Image Adjustment//
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
	////
	//Image Effects//
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
	
	////
	//Miscellaneous Options//
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
		           "Self-Adjusting UI (Min-FPSP-Alpha2)\0"  //13
		           "Self-Adjusting UI (Local-Depth2)\0"     //14
		           "Self-Adjusting UI (Guided-Depth2)\0";   //15
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
	
	//UI LB Flatten: the bars' depth, and how far the pinned area grows in Alpha UI stencil texels
	static const float UI_LB_Depth = 0.875;
	static const float UI_LB_Edge  = 5.0;

	
	////
	//16:10 Options//
	#if AR_Is == 2
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
	#endif

	//Depth3D Guidelines//
	// Cancel Depth Key: sets the Cancel Depth toggle key by keycode.
	// Ex. Numpad Decimal "." is key code 110, so Cancel_Depth_Key 110.
	//	#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.
	////
	//Extra Information
	uniform int Extra_Information <
	ui_text =   "Preprocessors:\n"
				//"Color Correcting  | Is the process of restoring the original colors in the scenes.\n"
				//"Deband            | Is used to correct for banding issues in the image.\n"
				//"HDR compatibility | Allows for HDR support in the shader when HDR is available.\n"
				//"Inficolor 3D      | Modify the shader to accommodate Inficolor glasses for 3D content.\n"
				//"Reconstruction    | Is a different way to render the images out.\n"
				"\n"
				"1. 3D Output\n"
				"______________________________________________\n"
				"   Anaglyph Mode     | Red/Cyan glasses.\n"
				"   Inficolor 3D      | Inficolor glasses.\n"
				"   Virtual Reality   | Direct VR headsets only.\n"
				"   2D Plus Depth     | 2D+Depth displays.\n"
				"   DoubleBuffer Mode | Capture add-ons.\n"
				"______________________________________________\n"
				"\n"
				"2. Depth\n"
				"______________________________________________\n"
				"   Anti Jitter Mode  | Steadies TAA depth.\n"
				"   Focus Depth Mode  | Inficolor's depth.\n"
				"   Handheld Mode     | Handhelds and iGPUs.\n"
				"______________________________________________\n"
				"\n"
				"3. Image\n"
				"______________________________________________\n"
				"   HDR Mode          | 0 Auto, 1 scRGB, 2 HDR10, 3 Off.\n"
				"______________________________________________\n"
				"\n"
				"4. Keys\n"
				"______________________________________________\n"
				"   Cancel Depth Key  | Key to turn off Depth.\n"
				"                     | Num Pad . is 110.\n"
				"                     | Keys: http://keycode.info/\n"
				"______________________________________________\n"
				"\n"
				"5. Controller (Xinp Add-on)\n"
				"______________________________________________\n"
				"   Cancel Depth Key  | 1 Guide\n"
				"                     | 2 Back + Left Trigger\n"
				"                     | 3 Back + Left Bumper\n"
				"                     | 4 Back + Right Trigger\n"
				"                     | 5 Back + Right Bumper\n"
				"   Left Trigger      | Aim, same as the Fade Key.\n"
				"   Right Trigger     | UI Read Controller.\n"
				"______________________________________________\n"
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
	
	//Infill Mask
	static const float Mask_Reach_Px = 1.0, Mask_Reach_Scale = 1.0, Mask_Reach_Near = 1.0, Mask_Reach_Far = 2.5;
	static const float Mask_Extend_Near = 8.0, Mask_Extend_Far = 32.0, Mask_Extend_Fade_Near = 0.0, Mask_Extend_Fade_Far = 0.125;
	static const float Mask_Depth_Pt = 0.25, Mask_Depth_Band = 0.25, Mask_Depth_Gain = 6.0;
	static const float Gap_Detect_Lo = 0.5, Gap_Detect_Hi = 10.0;
	static const float Infill_Mask_Cut = 0.3, Infill_Feather = 2.0, Infill_Soft_Px = 32.0;
	static const float Mask_Edge_Px = 2.0, Mask_Edge_Soft = 1.0;

	//Infill Blur
	static const float Post_Vert = 0.6;
	static const float Luma_Dark = 0.15, Luma_Bright = 0.7, Luma_Floor = 0.25, Luma_Boost = 0.5;
	static const float Contrast_Lo = 0.05, Contrast_Hi = 0.3, Contrast_Boost = 0.0, Contrast_Flat = 0.25;

	//VM2 and VM4 Dither reach in px
	static const float Dither_Reach_Px = 6.0;

	//Luma Guided and Contrast Guided, x Luma y Contrast
	static const float Mask_Extend_Near_Luma = 4.0, Mask_Depth_Gain_Luma = 0.25;
	static const float Mask_Extend_Near_Contrast = 2.0, Mask_Depth_Gain_Contrast = 0.5;
	static const float2 Mask_Extend_Near_Guided = float2(Mask_Extend_Near_Luma, Mask_Extend_Near_Contrast);
	static const float2 Mask_Depth_Gain_Guided = float2(Mask_Depth_Gain_Luma, Mask_Depth_Gain_Contrast);

	//VM2 Reiteration: march steps, pancake band, dither reach, near reach and near far gain
	static const float VM2_Steps = 0.75, VM2_Band = 2.0, VM2_Dither_Reach = 6.0, VM2_Reach_Near = 5.0, VM2_Gain = 0.25;

	//Guided Infill Blur picks its own Reach Near and Near Far Gain
	#define VM_Dither_Guided (VM_Infill_Dither && Infill_Blur_Type >= 2)
	#define Guided_Pick(v) (Infill_Blur_Type == 2 || View_Mode == 2 ? (v).x : (v).y)
	#define Mask_Bg_Near (VM_Eff == 4 ? 6.0 : View_Mode == 2 ? VM2_Reach_Near : VM_Dither_Guided ? Guided_Pick(Mask_Extend_Near_Guided) : Mask_Extend_Near)
	#define Mask_Gain (VM_Eff == 4 ? 0.5 : View_Mode == 2 ? VM2_Gain : VM_Dither_Guided ? Guided_Pick(Mask_Depth_Gain_Guided) : Mask_Depth_Gain)
	#define Depth_Blend(d) smoothstep(saturate(Mask_Depth_Pt - Mask_Depth_Band), saturate(Mask_Depth_Pt + Mask_Depth_Band), 1.0 - exp2(-(d) * Mask_Gain))

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; mode = "toggle";>;
	uniform bool Text_Info < source = "key"; keycode = Text_Info_Key; toggle = true; mode = "toggle";>;
	//Needs the Gamepad add-on. Two buttons per element: x Toggle, y Raw, then z and w for the next button.
	uniform float4 gamepad_toggle_raw[13]    < source = "gamepad_toggle_raw";>;
	#define Gamepad(B) ((B) % 2 ? gamepad_toggle_raw[(B) / 2].zw : gamepad_toggle_raw[(B) / 2].xy)
	
	uniform bool CLK_04 < source = "mousebutton"; keycode = Mouse_Key_Four; toggle = true; mode = "toggle";>;
	uniform bool CLK_03 < source = "mousebutton"; keycode = Mouse_Key_Three; toggle = true; mode = "toggle";>;
	uniform bool CLK_02 < source = "mousebutton"; keycode = Mouse_Key_Two; toggle = true; mode = "toggle";>;

	uniform bool Trigger_Fade_Toggle < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
	uniform bool Trigger_Fade_Hold < source = "mousebutton"; keycode = Fade_Key;>;
	
	uniform bool Menu_Open < source = "overlay_open"; >;
	uniform float2 Mousecoords < source = "mousepoint"; > ;
	uniform float frametime < source = "frametime";>;
	#if Anti_Jitter_Mode
	static const float MR_Hold_Ms = 50.0;//MiniRecon R hold time in ms.
	#endif
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
	
	//HDR: 0 Auto from the game's colour space, 1 scRGB, 2 HDR10, 3 Off
	#ifndef BUFFER_COLOR_SPACE
		#define BUFFER_COLOR_SPACE 0
	#endif
	#if HDR_Compatible_Mode == 1
		#define BC_SPACE 1
	#elif HDR_Compatible_Mode == 2
		#define BC_SPACE 2
	#elif HDR_Compatible_Mode == 3
		#define BC_SPACE 0
	#elif BUFFER_COLOR_SPACE == 2 || (BUFFER_COLOR_SPACE == 0 && BUFFER_COLOR_BIT_DEPTH == 16)
		#define BC_SPACE 1
	#elif BUFFER_COLOR_SPACE == 3
		#define BC_SPACE 2
	#else
		#define BC_SPACE 0
	#endif

	//UI white in HDR, 203 nits
	#define HDR_WHITE (BC_SPACE ? 0.0203 : 1.0)

	//Quad Lightfield, 3x3 and Quilts: one view per tile
	#define MULTI_VIEW (!(Inficolor_3D_Emulator || Anaglyph_Mode) && !Virtual_Reality_Mode && !Use_2D_Plus_Depth && (Stereoscopic_Mode == 5 || (Stereoscopic_Mode >= 6 && !EX_DLP_FS_Mode)))

	//Grid: columns, rows, 1 when view 0 is bottom left, outer view shift in eye shifts
	#define MV_GRID (Stereoscopic_Mode == 6 ? float4(3.0, 3.0, 0.0, 1.0) : \
					 Stereoscopic_Mode == 7 ? float4(4.0, 8.0, 1.0, 2.0) : \
					 Stereoscopic_Mode == 8 ? float4(5.0, 9.0, 1.0, 2.0) : \
					 Stereoscopic_Mode == 9 ? float4(7.0, 7.0, 1.0, 2.0) : \
					 Stereoscopic_Mode == 10 ? float4(8.0, 6.0, 1.0, 2.0) : float4(11.0, 6.0, 1.0, 2.0))

	//Mesh Warp: DX9 and DX10 the march only, DX11+ the Row Scan, VM0 the mesh
	#if MW_SCAN && !DX9_DX10_Toggle && !Use_2D_Plus_Depth && __RENDERER__ >= 0xb000 && __RESHADE__ >= 50000 && BUFFER_WIDTH <= 3968
		#define MW_SCAN_OK 1
	#else
		#define MW_SCAN_OK 0
	#endif
	#define MW_MESH_ON       (!DX9_DX10_Toggle)
	#define MW_MESH_RUN      (!MW_SCAN_OK || MW_VIEW_ON || View_Mode == 0)
	#define MW_VIEW_ON       (MW_MESH_VIEW && !DX9_DX10_Toggle && !Use_2D_Plus_Depth)

	//VM3 Stamped, old or rubber: no Infill Blur, like old Stamped
	#define VM3_ANY (View_Mode == 3 || (VM_Stamped_R && !VM_Mixed_R))

	//Anaglyph and Inficolor: each eye gets the post blur from the eye buffer
	#define AG_POST_BLUR_ON  ((Inficolor_3D_Emulator || Anaglyph_Mode) && !DX9_DX10_Toggle)
	#if AG_POST_BLUR_ON
		#define AG_POST_BLUR (Infill_Blur > 0 && !VM3_ANY)
		#define POST_UNROLL [loop]
	#else
		#define AG_POST_BLUR false
		#define POST_UNROLL SD_UNROLL
	#endif

	//Red-Blue blurs its blue in USMOut
	#define AG_RB_USM        (Anaglyph_Mode && !DX9_DX10_Toggle)

	//Infill blur and mask in the post pass
	#define POST_MASK_OK     (!Anaglyph_Mode && !Inficolor_3D_Emulator && !Virtual_Reality_Mode)
	#if !Anaglyph_Mode && !Inficolor_3D_Emulator && !Virtual_Reality_Mode && !DoubleBuffer_Mode
		#define POST_INFILL_OK (!VM3_ANY)
		#define POST_INFILL_BRANCH [branch]
		#define POST_VM3_SHOW (VM3_ANY && Show_Infill_Mask)
	#else
		#define POST_INFILL_OK false
		#define POST_INFILL_BRANCH //A constant, so no [branch].
		#define POST_VM3_SHOW false
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

	//texSmooth's size as a constant
	#define Smooth_Size int2(BUFFER_WIDTH * Depth_Rez, BUFFER_HEIGHT * Depth_Rez)
		
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

	#if GDM_WEAPON_DEPTH //Only made when it is on, the DX9 and DX10 path has few texture slots.
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
	#if !DX9_DX10_Toggle //DX9 and DX10 read it with BB_Clamp.
	//The live back buffer.
	sampler BB_Mask
		{
			Texture = BackBufferTex;
		};

	#define BB_Clamp(TC) tex2Dlod(BB_Mask, float4(TC, 0, 0))
	#endif

	#if AXAA_EXIST
	//AXAA's final fetch in linear light. Only 8 bit SDR has an sRGB view.
	#if BUFFER_COLOR_BIT_DEPTH == 8 && !BC_SPACE
		sampler BB_Linear
			{
				Texture = BackBufferTex;
				SRGBTexture = true;
			};
		#define AXAA_F_Sampler BB_Linear
		#define AXAA_Linear true
	#else
		#define AXAA_F_Sampler Live_Sampler
		#define AXAA_Linear false
	#endif
	#endif
	
	#if BC_SPACE
		#define Color_Format_B RGBA16F
	#else
		#define Color_Format_B RGB10A2
	#endif
	
	#if DX9_DX10_Toggle
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

	//BB_Mask's read: half a pixel in, so every edge mode reads like clamp.
	float4 BB_Clamp(float2 tc)
	{
		float2 Half_Px = 0.5 * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
		return tex2Dlod(BackBufferBMC, float4(clamp(tc, Half_Px, 1.0 - Half_Px), 0, 0));
	}
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
	
	#if DX9_DX10_Toggle
		#define Non_Point_Sampler BackBufferBMC
	#else
		#define Non_Point_Sampler BackBuffer_C
	#endif
	#define Live_Sampler Non_Point_Sampler
	
	//Highest DMN read is mip 8 (8.5 with KHM): 9 levels, 10 with KHM.
	#if Max_Mips <= 9 || (KHM && Max_Mips <= 10)
	texture texDMN { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; MipLevels = Max_Mips; }; //Mips Used
	#elif KHM
	texture texDMN { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; MipLevels = 10; }; //Mips Used
	#else
	texture texDMN { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; MipLevels = 9; }; //Mips Used
	#endif
	
	sampler SamplerDMN
		{
			Texture = texDMN;
		};

	texture texCN { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG8; MipLevels = Max_Mips; }; //Mips Used
	
	sampler SamplerCN
		{
			Texture = texCN;
		};

	#if !DX9_DX10_Toggle //DX9 and DX10 read PrepDepth() directly for their ZPD boundary grid.
	//R ZPD boundary grid, G ZPD Balance mask
	texture texMiniReconBuffer { Width = BUFFER_WIDTH * 0.125; Height = BUFFER_HEIGHT * 0.25; Format = RG16F; };

	sampler SamplerMR
		{
			Texture = texMiniReconBuffer;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	//Linear, for the Balance mask
	sampler SamplerMR_L
		{
			Texture = texMiniReconBuffer;
		};
		#if Anti_Jitter_Mode //Last frame's R.
		texture texMiniReconHold { Width = BUFFER_WIDTH * 0.125; Height = BUFFER_HEIGHT * 0.25; Format = R16F; };

		sampler SamplerMR_Hold
			{
				Texture = texMiniReconHold;
				MagFilter = POINT;
				MinFilter = POINT;
				MipFilter = POINT;
			};

			#if MW_SCAN_OK //MeshWarp_Tiles writes it, no MiniReconHold pass.
				storage StMR_Hold { Texture = texMiniReconHold; };
			#endif
		#endif
	#endif
	
	texture texzBufferN_L { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; MipLevels = 8; }; //Mips Used
	
	sampler SamplerzBufferN_L
		{
			Texture = texzBufferN_L;
		};

	//Point read from the Linear buffer, snapped to the texel centre.
	float Point_L(float2 texcoord)
	{
		float2 Size = tex2Dsize(SamplerzBufferN_L,0);
		return tex2Dlod(SamplerzBufferN_L,float4((floor(texcoord * Size) + 0.5) / Size,0,0)).x;
	}

	//A value stored in Linear's y, read at the texel under texcoord.
	float Corner_L(float2 texcoord)
	{
		float2 Size = tex2Dsize(SamplerzBufferN_L,0);
		return tex2Dlod(SamplerzBufferN_L,float4((min(floor(texcoord * Size),Size - 1) + 0.5) / Size,0,0)).y;
	}
		
	#if Virtual_Reality_Mode || Anaglyph_Mode
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
		#elif !AG_RB_USM
		texture texSD_RL { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT ; Format = Color_Format_B; MipLevels = 1;};
		
		sampler Sampler_SD_RL
			{
				Texture = texSD_RL;
			};		
		#endif
	#endif
	
	#if IL_EYE_BUFFER && !(DX9_DX10_Toggle || Anaglyph_Mode || Inficolor_3D_Emulator || Use_2D_Plus_Depth || DoubleBuffer_Mode || Super3D_Mode)
		#define IL_EYES 1
		//Matches what it feeds, so the pixels come back unchanged.
		#if Virtual_Reality_Mode
			#define Color_Format_IL Color_Format_B
		#elif BC_SPACE || BUFFER_COLOR_BIT_DEPTH == 16
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
	#if !DX9_DX10_Toggle && !Use_2D_Plus_Depth
	//1 where the mesh eye pass drew, the eye pass skips those px. Not the stencil, it hangs some DX12 games.
	texture texIL_Mask { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; };

	sampler Sampler_IL_Mask
		{
			Texture = texIL_Mask;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	#endif
	#else
		#define IL_EYES 0
	#endif

	#if Inficolor_3D_Emulator || Anaglyph_Mode
	//Eye buffer width in screens, Inficolor keeps both eyes
	#if Inficolor_3D_Emulator
		#define AG_BUDGET 2.0
	#else
		#define AG_BUDGET 1.0
	#endif

	//Holds Parallax's sample offset from the pixel (xy), hole mask (z) and Memory Infill offset (w), not colour.
	texture texAG_Eyes { Width = BUFFER_WIDTH * AG_BUDGET; Height = BUFFER_HEIGHT; Format = RGBA16F; };

	//Hole mask, point sampled so narrow gaps are not averaged away.
	sampler Sampler_AG_Eyes_P
		{
			Texture = texAG_Eyes;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
		#if AG_POST_BLUR_ON
		//Infill Blur's taps: each eye's colour (rgb) and gap alpha (a), side by side.
		#define AG_EYE_C 1
		texture texAG_EyeC { Width = BUFFER_WIDTH * 2; Height = BUFFER_HEIGHT; Format = RGBA16F; };

		sampler Sampler_AG_EyeC
			{
				Texture = texAG_EyeC;
			};

		#else
		#define AG_EYE_C 0
		#endif
	#else
		#define AG_EYE_C 0
	#endif

	#if DoubleBuffer_Mode
	texture DoubleTex { Width = BUFFER_WIDTH * 2; Height = BUFFER_HEIGHT; Format = Color_Format_B; };
	
	sampler SamplerDouble
		{
			Texture = DoubleTex;
		};
	#endif

	//x the blur, y Text_Mask (DX11+), zw the Info.
	//w stores 1 - Average_UI * 0.25 so the Statistics preview is never see-through, also when the game's alpha is 1. Avg_UI turns it back.
	texture texzBufferBlurN < pooled = true; > { Width = BUFFER_WIDTH / 4.0 ; Height = BUFFER_HEIGHT / 4.0; Format = RGBA16F; MipLevels = 4; };

		sampler SamplerzBuffer_BlurN
		{
			Texture = texzBufferBlurN;
		};

	//The blur and the Info reads
	#define Blur_N(UV, L) tex2Dlod(SamplerzBuffer_BlurN, float4(UV, 0, L)).xy
	#define Blur_Ex(UV)   tex2Dlod(SamplerzBuffer_BlurN, float4(UV, 0, 0)).zw

	#if !DX9_DX10_Toggle
		#if Anti_Jitter_Mode
	texture texzBufferN_M { Width = BUFFER_WIDTH  * Depth_Rez; Height = BUFFER_HEIGHT  * Depth_Rez; Format = R16F; };
		#else
	texture texzBufferN_M { Width = BUFFER_WIDTH  * Depth_Rez; Height = BUFFER_HEIGHT  * Depth_Rez; Format = R16F; MipLevels = 2;};
		#endif

	sampler SamplerzBufferP_Mixed
		{
			Texture = texzBufferN_M;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};		
	#else
	texture texzBufferN_M { Width = BUFFER_WIDTH  * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; }; //Do not use mips in this buffer

	sampler SamplerzBufferB_Mixed
		{
			Texture = texzBufferN_M;
		};

	//Point read on the linear sampler, at the texel centre.
	float4 Point_Mixed(float2 uv)
	{
		float2 Sz = tex2Dsize(SamplerzBufferB_Mixed, 0);
		return tex2Dlod(SamplerzBufferB_Mixed, float4((floor(uv * Sz) + 0.5) / Sz, 0, 0));
	}
	#endif

	#if DX9_DX10_Toggle //DX9 and DX10 depth smoothing, their depth is very aliased.
	texture texSmooth { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = AA_Format; };

	sampler SamplerzBufferB_Smooth
		{
			Texture = texSmooth;
		};
	#endif

	#if !DX9_DX10_Toggle
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

	//G: Stamped's edge AA depth.
	texture texSmooth { Width = BUFFER_WIDTH * Depth_Rez; Height = BUFFER_HEIGHT * Depth_Rez; Format = RG16F; };
	
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

	#if MEM_INFILL
	//Memory Infill: remembered background, A and B swap every frame so no copy pass
	//Mem colour + depth, Age seconds covered
	texture texMemA { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = RGBA16F; };
	texture texMemB { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = RGBA16F; };
	texture texAgeA { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = R16F; };
	texture texAgeB { Width = BUFFER_WIDTH / MEM_DIV; Height = BUFFER_HEIGHT / MEM_DIV; Format = R16F; };

	sampler Sampler_MemA
		{
			Texture = texMemA;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	sampler Sampler_MemB
		{
			Texture = texMemB;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	//Linear, for the colour read
	sampler Sampler_MemAL
		{
			Texture = texMemA;
		};

	sampler Sampler_MemBL
		{
			Texture = texMemB;
		};

	sampler Sampler_AgeA
		{
			Texture = texAgeA;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	sampler Sampler_AgeB
		{
			Texture = texAgeB;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	//Depth3D Motion add-on: xy motion in UV, previous = uv - xy
	texture MotionVectorsTex : MOTIONVECTORS;

	sampler Sampler_MV
		{
			Texture = MotionVectorsTex;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	//The add-on's fitted camera, texel 3: state, share, model, focal
	texture MotionCameraTex : MOTIONCAMERA;

	sampler Sampler_MCam
		{
			Texture = MotionCameraTex;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	#endif

	#if !Use_2D_Plus_Depth && !DX9_DX10_Toggle
	//MeshWarp tile size in px
	#ifndef MW_TILE
		#define MW_TILE 8
	#endif
	#define MW_TX (BUFFER_WIDTH / MW_TILE)
	#define MW_TY (BUFFER_HEIGHT / MW_TILE)

	//Squares per tile side, big tiles may bend once each way
	#if MW_TILE >= 16
		#define MW_SQ 2
	#else
		#define MW_SQ 1
	#endif

	//Rubber corner spacing in px, finer than the tiles for thin edges
	#if MW_SQ == 1
		#define MW_RTILE 4
	#else
		#define MW_RTILE MW_TILE
	#endif
	#define MW_RX (BUFFER_WIDTH / MW_RTILE)
	#define MW_RY (BUFFER_HEIGHT / MW_RTILE)

	//MeshWarp tiles: x how far off its plane the tile bends, yz its smallest and largest shift
	//w the mesh's corner shifts every MW_RTILE px, both eyes side by side
	#if MW_SQ == 1
		#define MW_TILE_W ((MW_RX + 1) * 2)
		#define MW_TILE_H (MW_RY + 1)
	#else
		#define MW_TILE_W MW_TX
		#define MW_TILE_H MW_TY
	#endif
	texture texMW_Tile { Width = MW_TILE_W; Height = MW_TILE_H; Format = RGBA16F; };

	#if MW_SCAN_OK
	storage2D StMW_Tile
		{
			Texture = texMW_Tile;
		};
	#endif

	sampler SamplerMW_Tile
		{
			Texture = texMW_Tile;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	//Mesh maps, both eyes side by side at half size: R source offset in px, G 1 where the mesh holds
	#if MW_MESH_ON
		#define MW_MAP_W BUFFER_WIDTH
		#define MW_MAP_H (BUFFER_HEIGHT / 2)
	#else
		#define MW_MAP_W 1
		#define MW_MAP_H 1
	#endif
	texture texMW_Map { Width = MW_MAP_W; Height = MW_MAP_H; Format = RG16F; };

	sampler SamplerMW_Map
		{
			Texture = texMW_Map;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	sampler SamplerMW_MapL
		{
			Texture = texMW_Map;
		};

	//VM0 nearest wins map: depth and offset in one float, nearer is larger so MAX blend keeps it
	texture texMW_MapN { Width = MW_MAP_W; Height = MW_MAP_H; Format = R32F; };

	sampler SamplerMW_MapN
		{
			Texture = texMW_MapN;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	#if MW_SCAN_OK && MW_SQ == 1 && !MW_VIEW_ON
	//DX11+ VM0: the Map Row pass writes both maps
	storage2D StMW_Map
		{
			Texture = texMW_Map;
		};

	storage2D StMW_MapN
		{
			Texture = texMW_MapN;
		};
	#endif

	#if MW_VIEW_ON
	//Mesh View: x on a square's side, y 1 where the mesh holds, w how much the triangle stretches
	texture texMW_Wire { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };

	sampler SamplerMW_Wire
		{
			Texture = texMW_Wire;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	#endif

	#if MW_SCAN_OK
	//Row Scan codes: 0 to 0xBFFF offset in 1/16 px (+ 32768), 0xC000 + n packed px n, 0xFFFF march here
	texture texMW_Scan { Width = BUFFER_WIDTH * 2; Height = BUFFER_HEIGHT; Format = R16; };

	sampler SamplerMW_Scan
		{
			Texture = texMW_Scan;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	storage2D StMW_Scan
		{
			Texture = texMW_Scan;
		};

	//Each row's first packed march slot
	texture texMW_ScanBase { Width = 1; Height = BUFFER_HEIGHT; Format = R32F; };

	sampler SamplerMW_ScanBase
		{
			Texture = texMW_ScanBase;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	storage2D StMW_ScanBase
		{
			Texture = texMW_ScanBase;
		};

	#define MW_CODE_PACK 49152.0 //0xC000
	#define MW_CODE_NONE 65535.0

	//Packed March list count
	texture texMW_PCount { Width = 1; Height = 1; Format = R32U; };

	storage2D<uint> StMW_PCount
		{
			Texture = texMW_PCount;
		};

	sampler2D<uint> SamplerMW_PCount
		{
			Texture = texMW_PCount;
		};

	//Packed March list, the px the scan leaves to the march
	texture texMW_PList { Width = MW_PL_W; Height = MW_PL_H; Format = R32U; };

	storage2D<uint> StMW_PList
		{
			Texture = texMW_PList;
		};

	sampler2D<uint> SamplerMW_PList
		{
			Texture = texMW_PList;
		};

	//Packed March result: x offset, hole mask, edge x offset, edge weight
	texture texMW_PRes { Width = MW_PL_W; Height = MW_PL_H; Format = RGBA32F; };

	storage2D StMW_PRes
		{
			Texture = texMW_PRes;
		};

	sampler SamplerMW_PRes
		{
			Texture = texMW_PRes;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	#if MEM_INFILL
	//Memory Infill's offset
	texture texMW_PEdge { Width = MW_PL_W; Height = MW_PL_H; Format = R32F; };

	storage2D StMW_PEdge
		{
			Texture = texMW_PEdge;
		};

	sampler SamplerMW_PEdge
		{
			Texture = texMW_PEdge;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};
	#endif

	//The infill mask needs the march
	#define MW_Scan_Mask (Infill_Blur != 0 || Show_Infill_Mask || Infill_Blur_Debug)
	//Need: only the columns the eyes read march
	#define MW_NEED_SCREEN (!(Inficolor_3D_Emulator || Anaglyph_Mode) && !Virtual_Reality_Mode && !DoubleBuffer_Mode && !Super3D_Mode)
	#define MW_NEED (Inficolor_3D_Emulator || Anaglyph_Mode || MW_NEED_SCREEN)
	//Need's threads in the Tiles pass
	#if Inficolor_3D_Emulator || Anaglyph_Mode
		#define MW_NEED_T (BUFFER_WIDTH * 2)
	#elif MW_NEED
		#define MW_NEED_T BUFFER_WIDTH
	#else
		#define MW_NEED_T 0
	#endif
	#if MW_NEED
	//Frame tag of the last read, so no clear pass. The scan takes a mark one frame apart.
	#define MW_Need_Tag ((Frames % 255 + 1) / 255.0)
	texture texMW_Need { Width = BUFFER_WIDTH * 2; Height = 1; Format = R8; };

	storage2D StMW_Need
		{
			Texture = texMW_Need;
		};

	sampler SamplerMW_Need
		{
			Texture = texMW_Need;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

		#if Inficolor_3D_Emulator || Anaglyph_Mode
		#define Need_On (AG_POST_BLUR && !Vert_3D_Pinball)
		#else
		#define Need_On (Stereoscopic_Mode <= 4 && !Vert_3D_Pinball)
		#endif
	#endif
	#endif
	#endif

	#define Scale_Buffer 160 / BUFFER_WIDTH
	////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////
	texture texAvrN { Width = BUFFER_WIDTH * Scale_Buffer; Height = BUFFER_HEIGHT * Scale_Buffer; Format = RGBA16F; MipLevels = 8;}; //Mips Used

	sampler SamplerAvrB_N
		{
			Texture = texAvrN;
		};

	#if DX9_DX10_Toggle
	//Point read on the linear sampler, at the texel centre.
	float4 Avr_P(float2 uv)
	{
		float2 Sz = tex2Dsize(SamplerAvrB_N, 0);
		return tex2Dlod(SamplerAvrB_N, float4((floor(uv * Sz) + 0.5) / Sz, 0, 0));
	}

	//The last mip (7), snapped to its own texels.
	float4 Avr_P_Top(float2 uv)
	{
		float2 Sz = max(1.0, floor(float2(BUFFER_WIDTH * Scale_Buffer, BUFFER_HEIGHT * Scale_Buffer) / 128.0));
		return tex2Dlod(SamplerAvrB_N, float4((floor(uv * Sz) + 0.5) / Sz, 0, 12));
	}
	#else
	sampler SamplerAvrP_N
		{
			Texture = texAvrN;
			MagFilter = POINT;
			MinFilter = POINT;
			MipFilter = POINT;
		};

	#define Avr_P(UV)     tex2Dlod(SamplerAvrP_N, float4(UV, 0, 0))
	#define Avr_P_Top(UV) tex2Dlod(SamplerAvrP_N, float4(UV, 0, 12))
	#endif

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

	//The back buffer to linear BT.2020 (1.0 is 10000 nits), from scRGB or HDR10
	float4 BB_To_N(float4 RGB)
	{
		#if BC_SPACE == 2
		float3 PQ_P = pow(max(RGB.rgb, 0.0), 1.0 / 78.84375);
		RGB.rgb = pow(max(PQ_P - 0.8359375, 0.0) / (18.8515625 - 18.6875 * PQ_P), 1.0 / 0.1593017578125);
		return RGB;
		#else
		return NormalizeScRGB(RGB);
		#endif
	}

	//And back to the back buffer
	float4 N_To_BB(float4 RGB)
	{
		#if BC_SPACE == 2
		float3 PQ_Y = pow(max(RGB.rgb, 0.0), 0.1593017578125);
		RGB.rgb = pow((0.8359375 + 18.8515625 * PQ_Y) / (1.0 + 18.6875 * PQ_Y), 78.84375);
		return RGB;
		#else
		return ExpandScRGB(RGB);
		#endif
	}

	//HDR colour as SDR sees it: paper white at 1, gamma shaped. N_Space for CSB colours, else the back buffer
	float3 HDR_Look(float3 C, bool N_Space)
	{
		#if BC_SPACE == 2
		return N_Space ? sqrt(max(C * rcp(HDR_WHITE), 0.0)) : C * rcp(0.58);
		#elif BC_SPACE == 1
		return sqrt(max(C * rcp(N_Space ? HDR_WHITE : 2.5375), 0.0));
		#else
		return C;
		#endif
	}

	//And back, for the back buffer
	float3 HDR_Back(float3 C)
	{
		#if BC_SPACE == 2
		return C * 0.58;
		#elif BC_SPACE == 1
		return C * C * 2.5375;
		#else
		return C;
		#endif
	}

	static const float Auto_Balance_Clamp = 0.5; //This clamps Auto Balance's max distance.
	#if GDM_WEAPON_DEPTH
		uniform bool WPresentCheck < source = "weapon_present"; >;
		uniform bool WDepthCheck < source = "bufready_wdepth"; >;
	#endif

	//GDM add-on depth fit data. If DX9 and DX10 give X4509 again, gate DB_Viewport_Size out of DX9 and DX10 first.
	uniform float2 DB_Res_Info < source = "depth_resolution"; >;
	uniform float4 DB_Viewport_Size < source = "depth_viewport_size"; >;
	uniform bool DB_AutoFit < source = "depth_autofit"; >;
	uniform float2 DB_Render_Size < source = "depth_render_size"; >;
	//Auto Scaler is off while GDM fits the depth.
	#if GDM_DEPTH_AUTOFIT
		#define ASA_On (Auto_Scaler_Adjust && !(DB_AutoFit && DB_Res_Info.x > 0 && DB_Res_Info.y > 0 && DB_Viewport_Size.z > 0 && DB_Viewport_Size.w > 0))
	#else
		#define ASA_On Auto_Scaler_Adjust
	#endif
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

	//XY level 6, ZW level 7.
	float4 RE_Extended()
	{
		#if EDW || Profiler_Mode
		return ZPD_Boundary_n_Cutoff_End;
		#else
		return DKK_W4;
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
		if (ZPD_Boundary_n_Cutoff_End.z > 0.0) Rank = 5;

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
	{
		float Value = PopOut_Target;
		float S_More = Corner_L(float2(3 * BUFFER_RCP_WIDTH, 0));
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

	float4 AdjustSaturation(float4 color)
	{ 
		float hueShift = 0.0;
		float saturation = 1+Saturation;

		// Hue adjustment
		float3 hueAdjust = 1.0 - min(abs(hueShift - float3(0.0, 2.0, 1.0)), 1.0);
		
		// Enshore red component consistency using dot product
		hueAdjust.x = 1.0 - (hueAdjust.y + hueAdjust.z);
		
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

	//Interleaved gradient noise, a 0 to 1 dither per pixel
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
		
		#if BC_SPACE
			#if DX9_DX10_Toggle
			if(Depth_Map_View == 0)
				return BB_To_N(tex2Dlod(Non_Point_Sampler,float4(texcoords,0,0)) *  Vin);
			else
				return Point_L(texcoords) * HDR_WHITE;
			#else
			//[branch]: one read per call, not all four.
			float4 Color = 0.0;
			[branch]
			if(Custom_Sidebars == 0 && Depth_Map_View == 0)
				Color = tex2Dlod(BackBuffer_M,float4(texcoords,0,0)) *  Vin;
			[branch]
			if(Custom_Sidebars == 1 && Depth_Map_View == 0)
				Color = tex2Dlod(BackBuffer_B,float4(texcoords,0,0)) *  Vin;
			[branch]
			if(Custom_Sidebars == 2 && Depth_Map_View == 0)
				Color = tex2Dlod(BackBuffer_C,float4(texcoords,0,0)) *  Vin;
			[branch]
			if(Depth_Map_View != 0 || Custom_Sidebars > 2)
				Color = Point_L(texcoords) * HDR_WHITE;
			return Depth_Map_View != 0 || Custom_Sidebars > 2 ? Color : BB_To_N(Color);
			#endif
		#else
			#if DX9_DX10_Toggle
			if(Depth_Map_View == 0)
				return tex2Dlod(Non_Point_Sampler,float4(texcoords,0,0)) *  Vin;
			else
				return Point_L(texcoords);
			#else
			//[branch]: one read per call, not all four.
			float4 Color = 0.0;
			[branch]
			if(Custom_Sidebars == 0 && Depth_Map_View == 0)
				Color = tex2Dlod(BackBuffer_M,float4(texcoords,0,0)) *  Vin;
			[branch]
			if(Custom_Sidebars == 1 && Depth_Map_View == 0)
				Color = tex2Dlod(BackBuffer_B,float4(texcoords,0,0)) *  Vin;
			[branch]
			if(Custom_Sidebars == 2 && Depth_Map_View == 0)
				Color = tex2Dlod(BackBuffer_C,float4(texcoords,0,0)) *  Vin;
			[branch]
			if(Depth_Map_View != 0 || Custom_Sidebars > 2)
				Color = Point_L(texcoords);
			return Color;
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
		//GDM fit is on: it already places the depth, so no letter box (LBM, warping, detectors, UI all follow this).
		#if GDM_DEPTH_AUTOFIT
		if(DB_AutoFit && DB_Res_Info.x > 0 && DB_Res_Info.y > 0 && DB_Viewport_Size.z > 0 && DB_Viewport_Size.w > 0)
			return 0;
		#endif
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

	#if MDD || SMD || TMD || SUI || SDT || SD_Trigger
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
	
	/////////////////////////////////////////////////////////////Cursor///////////////////////////////////////////////////////////////////////////

	float DepthEdge(float Mod_Depth, float Depth, float2 texcoords, float Adjust_Value )
	{
		Adjust_Value -= FLT_EPSILON;
		float2 center = float2(0.5,texcoords.y); // Direction of effect.   
		float BaseVal = 1.0,
			  Dist  = distance( center, texcoords ) * 2.0, 
			  EdgeMask = saturate((BaseVal-Dist) / (BaseVal-Adjust_Value)),
			  Set_Weapon_Scale_Near = -min(0.5,Weapon_Depth_Edge.y);//So it doesn't hang the game.
		float Scale_Depth = lerp(1+(Weapon_Depth_Edge.z*4),0,saturate(Depth * 2));
			  Mod_Depth = (Mod_Depth - Set_Weapon_Scale_Near) / (1.0 + Set_Weapon_Scale_Near);
		float Near_Mod_Depth =  Scale_Depth * Mod_Depth;
		float WDE_W = Weapon_Depth_Edge.w >= 0 ? Weapon_Depth_Edge.w : lerp(abs(Weapon_Depth_Edge.w) * 0.5,abs(Weapon_Depth_Edge.w),saturate(Corner_L(float2(3 * BUFFER_RCP_WIDTH, 0)) * 2));
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

	#if MW_VIEW_ON
	//Mesh View: the wire under the pixel being drawn, set by Parallax_Mode. x side, y mesh, w stretch (0.5 none).
	static float4 MW_Wire_Hit = float4(0.0, 1.0, 0.0, 0.5);
	static bool MW_Near_Hit = false, MW_Cell_Line = false;
	#endif
	//Infill Blur strength by mode
	float Infill_Guide(float3 C, float L_Min, float L_Max)
	{
		float Luma = dot(saturate(C), float3(0.2126, 0.7152, 0.0722));
		float TL = smoothstep(Luma_Dark, max(Luma_Bright, Luma_Dark + 0.001), Luma);
		float TC = smoothstep(Contrast_Lo, max(Contrast_Hi, Contrast_Lo + 0.001), (L_Max - L_Min) * rcp(L_Max + 0.25));

		float WL = lerp(Luma_Floor, 1.0 + Luma_Boost, TL);
		float WC = lerp(Contrast_Flat, 1.0 + Contrast_Boost, TC);
		return Infill_Blur_Type == 2 ? WL : Infill_Blur_Type == 3 ? WC : 1.0;
	}

	//VM0_Pack: the Memory Infill offset (under 0.1). 0 when none.
	float4 MouseCursorS(float3 texcoord , float VM0_Pack, float2 pos, int Switch,int UI_Mode, float2 Edge)
	{ 
			//DX9 and DX10 fail without tex2Dlod here.
			float4 Out = UI_Mode ? tex2Dlod(Live_Sampler,float4(texcoord.xy,0,0)) : CSB(texcoord.xy),Color, Exp_Darks, Exp_Brights; //UI_Mode runs after StereoOut, so read the live back buffer.
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
				float  Bm = (Point_L(float2(texcoord.x - 10.0 * pix.x, texcoord.y)) >=
				             Point_L(float2(texcoord.x + 10.0 * pix.x, texcoord.y)) ? -1.0 : 1.0) * pix.x;
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

			//Pinball warps along y: Edge.x is a y there.
			bool Pin = Vert_3D_Pinball && !MULTI_VIEW;
			float2 Edge_TC = Pin ? float2(texcoord.x, Edge.x) : float2(Edge.x, texcoord.y), Blur_Dir = Pin ? float2(0.0, BUFFER_WIDTH * pix.y) : float2(1.0, 0.0);
			//The edge blend goes under the in-pass blur, else after it.
			bool Edge_First = Infill_Blur > 0 && !VM3_ANY && !UI_Mode && !POST_INFILL_OK && !AG_POST_BLUR;
			[branch]
			if(Edge_First && Edge.y > 0.0)
				Out.rgb = lerp(Out.rgb, CSB(Edge_TC).rgb, Edge.y);

			//Anaglyph and Inficolor blur each eye later, so the in-pass blur is not built there.
			#if !AG_POST_BLUR_ON
			//texcoord.z is the gap flag from Parallax. Amt past 0.375 leaks the occluder.
			const float Blur_Amt = 0.4, Blur_Reach_Px = 16.0, Blur_Guard = 1.0;
			//Bleed zone. Bleed_Px 14 is the ceiling, wider reaches unrelated geometry.
			const float Bleed_Str = 0.45, Bleed_Px = 14.0, Bleed_Reach = 0.5, Edge_Dead = 0.02, Edge_Gain = 5.0;
			const float Slope_Tol = 1.6, Step_Gain = 8.0;
			[branch]
			//Stamped is left alone. Reiteration takes the dithered path below.
			if(Infill_Blur > 0 && !VM3_ANY && !UI_Mode && (!POST_INFILL_OK || Infill_Blur_Debug) && !AG_POST_BLUR && (texcoord.z > 0 || !VM_Infill_Dither))
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
					float2 Td_TC = texcoord.xy + Blur_Dir * (B * Jit);
					float  Dc = Point_L(texcoord.xy);
					float  Dt = Point_L(Td_TC);
					const float Dither_Tol = 0.02;
					//Colour guard on top of the depth test. A tap has to pass both.
					float4 Td = CSB(Td_TC);
					float  Wd = dot(abs(Td.rgb - Out.rgb) * rcp(abs(Out.rgb) + 0.25 * HDR_WHITE),
			                        float3(0.3333, 0.3333, 0.3333)) * Blur_Guard;
					bool   Ok = Dt >= Dc - Dither_Tol && Wd < 1.0;
					//VM4.
					[branch]
					if(VM_Eff == 4 && !Ok)
					{
						float  Jit2 = Interleaved_Gradient_Noise(floor(pos) + 13.0) * 2.0 - 1.0;
						float2 T2_TC = texcoord.xy + Blur_Dir * (B * Jit2);
						float4 T2 = CSB(T2_TC);
						Ok = Point_L(T2_TC) >= Dc - Dither_Tol
			              && dot(abs(T2.rgb - Out.rgb) * rcp(abs(Out.rgb) + 0.25 * HDR_WHITE), float3(0.3333, 0.3333, 0.3333)) * Blur_Guard < 1.0;
						Td = T2;
					}
					if(!POST_INFILL_OK)
						Out = Ok ? Td : Out;
				}
				else
				{
					//Cut off then rescale, so a strong mask keeps full strength.
					float Gap = saturate((saturate(texcoord.z) - Infill_Mask_Cut) * rcp(1.0 - Infill_Mask_Cut + 0.001));
					float2 Bd = Blur_Dir * (Bleed_Px * pix.x);
					float Dc = Point_L(texcoord.xy);
					float Dl = Point_L(texcoord.xy - Bd);
					float Dr = Point_L(texcoord.xy + Bd);
					//Which side of the edge we sit on. Far means background, the half that may bleed.
					float Dw   = abs(Dr - Dl);
					float Edge = saturate((Dw * rcp(max(min(Dr, Dl), 0.0) + 0.01) - Edge_Dead) * Edge_Gain);
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
							float  Da = Point_L(texcoord.xy - Bk);
							float  Db = Point_L(texcoord.xy + Bk);
							//A step holds its size at any reach that straddles it, a surface shrinks.
							float  Dif = abs(Db - Da);
							float  Ek  = saturate((Dif * rcp(max(min(Da, Db), 0.0) + 0.01) - Edge_Dead) * Edge_Gain)
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
					//Depth: a near background takes less blur.
					[branch]
					if(Infill_Blur_Depth && Ramp > 0.002)
						Ramp *= lerp(0.5, 1.0, Depth_Blend(smoothstep(0, 1, tex2Dlod(SamplerDMN, float4(texcoord.xy, 0, 0)).x)));
					B = max(Ramp, Bleed_Reach) * pix.x * Blur_Amt * Blur_Reach_Px;
					[branch]
					if(Ramp > 0.002)
					{
						min16float3 RcpC = rcp(abs(Out.rgb) + 0.25 * HDR_WHITE);//Once, not per tap. Colour maths in half precision.
						const min16float3 Third = min16float3(0.3333, 0.3333, 0.3333);
						min16float4 Acc = Out;
						min16float  Wsum = 1.0;
						min16float  L_Min = dot(saturate(HDR_Look(Out.rgb, true)), float3(0.2126, 0.7152, 0.0722)), L_Max = L_Min;
						SD_UNROLL
						for(int b = 1; b <= 4; b++)
						{
							float2 Tap_Ofs = Blur_Dir * (B * (b * 0.25));
							min16float4 Ta = CSB(texcoord.xy + Tap_Ofs);
							min16float4 Tb = CSB(texcoord.xy - Tap_Ofs);
							min16float  Wf = 1.0 - b * 0.2;
							min16float  Wa = Wf * saturate(1.0 - dot(abs(Ta.rgb - Out.rgb) * RcpC, Third) * Blur_Guard);
							min16float  Wb = Wf * saturate(1.0 - dot(abs(Tb.rgb - Out.rgb) * RcpC, Third) * Blur_Guard);
							//Depth gate.
							Wa *= Point_L(texcoord.xy + Tap_Ofs) >= Dc - 0.02;
							Wb *= Point_L(texcoord.xy - Tap_Ofs) >= Dc - 0.02;
							Acc  += Ta * Wa + Tb * Wb;
							Wsum += Wa + Wb;
							if(b <= 2)
							{
								min16float2 Lab = min16float2(dot(saturate(HDR_Look(Ta.rgb, true)), float3(0.2126, 0.7152, 0.0722)),
			                                 dot(saturate(HDR_Look(Tb.rgb, true)), float3(0.2126, 0.7152, 0.0722)));
								L_Min = min(L_Min, min(Lab.x, Lab.y)); L_Max = max(L_Max, max(Lab.x, Lab.y));
							}
						}
						//Post pass modes get the marker only, the image is blurred there.
						POST_INFILL_BRANCH
			            if(!POST_INFILL_OK)
						{
							//Falloff off degrades half as much.
							float Str = (Infill_Falloff || Gap <= 0) ? Ramp : lerp(Gap, Ramp, 0.5);
							float Mix = saturate(Str * Infill_Guide(HDR_Look(Out.rgb, true), L_Min, L_Max));
							Out = lerp(Out, Acc * rcp(Wsum), Mix);
						}
						[branch]
						if(Infill_Blur_Debug)
							//Green is left to the post pass: drawing both here leaves flat green where they disagree.
							Out.rgb = lerp(Out.rgb, (Gap > 0 ? float3(0.0, 1.0, 0.0) : float3(0.0, 0.0, 1.0)) * HDR_WHITE,
			                               Gap > 0 ? (POST_INFILL_OK ? 0.0 : Ramp)
			                                       : saturate(Ramp * rcp(Bleed_Str)));
					}
				}
			}
			#endif
			//Edge blend before the deband, the cursor and Inficolor's colour reduction.
			[branch]
			if(!Edge_First && Edge.y > 0.0)
				Out.rgb = lerp(Out.rgb, CSB(Edge_TC).rgb, Edge.y);
			float Cursor = 0.0;
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
				Color.rgb = CCArray[CSTT] * HDR_WHITE;
			}
			
			Out = Cursor ? Color.rgb : Out.rgb;
		#if Inficolor_3D_Emulator
			float3 ReGamma = regamma(Out.rgb * rcp(HDR_WHITE)), blend_RGB = float3(dot(ReGamma, float3(1,-1,-1)), dot(ReGamma, float3(-1,1,-1)),dot(ReGamma, float3(-1,-1,1))) ;
	    	Out.r *= lerp(1,lerp(1, 0.5, smoothstep(-0.250, 0.0, blend_RGB.r)),Inficolor_Reduce_RGB.x);
	    	Out.g *= lerp(1,lerp(1, 0.5, smoothstep(-0.375, 0.0, blend_RGB.g)),Inficolor_Reduce_RGB.y);
	    	Out.b *= lerp(1,lerp(1, 0.5, smoothstep(-0.500, 0.0, blend_RGB.b)),Inficolor_Reduce_RGB.z);
		#endif
			#if MW_VIEW_ON
			[branch]
			if(!UI_Mode)
			{
				//Square sizes by colour. y: 0.2 8 px (red), 0.4 16 px (green), 0.6 32 px (blue), 0.8 64 px (white).
				float3 Line_Col = float3(1.0, 0.15, 0.1);
				if(MW_Wire_Hit.y > 0.7)
					Line_Col = float3(1.0, 1.0, 1.0);
				else if(MW_Wire_Hit.y > 0.5)
					Line_Col = float3(0.2, 0.5, 1.0);
				else if(MW_Wire_Hit.y > 0.3)
					Line_Col = float3(0.1, 0.9, 0.2);
				//The per pixel march (y 0) and the VM0 fix cost the most: a dark grey fill (video card #2a2a30). View 1 adds white dots on it.
				bool Per_Pixel = MW_Wire_Hit.y < 0.15 || MW_Near_Hit;//0.1 is stretched infill. Plain dark grey, no dots.
				float3 March_Col = float3(0.165, 0.165, 0.188);
				//8 px squares: dark inside like the video card, so the red is only the outline.
				if(!Per_Pixel && MW_Wire_Hit.y < 0.3)
					Out.rgb = lerp(Out.rgb, float3(0.165, 0.165, 0.188) * HDR_WHITE, 0.6);
				//Red lines dim
				Out.rgb = lerp(Out.rgb, (Per_Pixel ? March_Col : Line_Col) * HDR_WHITE,
							   Per_Pixel ? (MW_MESH_VIEW == 2 && MW_Cell_Line ? 0.7 : 0.35) : MW_Wire_Hit.x * (MW_Wire_Hit.y < 0.3 ? 0.3 : 1.0));
			}
			#endif
			return float4(Out.rgb,texcoord.z);
	}

	float4 MouseCursor(float3 texcoord , float2 pos, int Switch,int UI_Mode )
	{
		return MouseCursorS(texcoord, 0.0, pos, Switch, UI_Mode, 0.0);
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

	float2 Depth_Rescale(float2 texcoord)
	{
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
		return texcoord;
	}

	float Depth(float2 texcoord)
	{   //May have to move this, but it seems good where it is.
		texcoord = Depth_Rescale(texcoord);
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

		float InputSwitch = Avr_P(float2(1, 0.8125)).z; //tex2D(SamplerzBuffer_BlurN,float2(0,0.9375)).x
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
		float LBDetect = Avr_P(float2(1, 0.0625)).z;
		//Need to work on this later. So far it seems fine.
		float2 H_V_A, H_V_B, X_Y_A, X_Y_B, S_texcoord = texcoord;
		bool SDT_Bool = 1;
		
		//BSD: exact depth buffer fit from the add-on, DB_Fit maps onto the rendered sub rect and DB_Org is its origin
		//Identity when the add-on is off, WDEPTH uses the same fit
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
	float2 WeaponDepth(float2 texcoord, bool Wide)
	{   //Conversions to linear space.
		#if GDM_WEAPON_DEPTH
	    	//#if AR_Is == 2
	   	 //#endif
		//Nearest of the 2x2, or the 3x3 for the depth the march uses, so the weapon covers its own edge.
		#if DX9_DX10_Toggle
		float zBufferWH = tex2Dlod(WDepthBuffer, float4(texcoord,0,0)).x;
		#else
		//Kept inside the buffer, its border reads as nearest.
		float2 WP_X = rcp(tex2Dsize(WDepthBuffer));
		float4 WD_N = tex2DgatherR(WDepthBuffer, clamp(texcoord, WP_X, 1.0 - WP_X));
		if(Wide)
		{
			float4 WD_B = tex2DgatherR(WDepthBuffer, clamp(texcoord - float2(WP_X.x, 0), WP_X, 1.0 - WP_X));
			float4 WD_C = tex2DgatherR(WDepthBuffer, clamp(texcoord - float2(0, WP_X.y), WP_X, 1.0 - WP_X));
			float4 WD_D = tex2DgatherR(WDepthBuffer, clamp(texcoord - WP_X, WP_X, 1.0 - WP_X));
			WD_N = Depth_Map == 1 ? max(max(WD_N, WD_B), max(WD_C, WD_D)) : min(min(WD_N, WD_B), min(WD_C, WD_D));
		}
		float zBufferWH = Depth_Map == 1 ? max(max(WD_N.x, WD_N.y), max(WD_N.z, WD_N.w)) : min(min(WD_N.x, WD_N.y), min(WD_N.z, WD_N.w));
		#endif
		#else
		//WEG: nearest read, matches the cutoff mask at the edge.
		#if DX9_DX10_Toggle || !WEG
		float zBufferWH = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x;
		#else
		float2 WP_X = rcp(tex2Dsize(DepthBuffer));
		float4 WD_N = tex2DgatherR(DepthBuffer, clamp(texcoord, WP_X, 1.0 - WP_X));
		if(Wide)
		{
			float4 WD_B = tex2DgatherR(DepthBuffer, clamp(texcoord - float2(WP_X.x, 0), WP_X, 1.0 - WP_X));
			float4 WD_C = tex2DgatherR(DepthBuffer, clamp(texcoord - float2(0, WP_X.y), WP_X, 1.0 - WP_X));
			float4 WD_D = tex2DgatherR(DepthBuffer, clamp(texcoord - WP_X, WP_X, 1.0 - WP_X));
			WD_N = Depth_Map == 1 ? max(max(WD_N, WD_B), max(WD_C, WD_D)) : min(min(WD_N, WD_B), min(WD_C, WD_D));
		}
		float zBufferWH = Depth_Map == 1 ? max(max(WD_N.x, WD_N.y), max(WD_N.z, WD_N.w)) : min(min(WD_N.x, WD_N.y), min(WD_N.z, WD_N.w));
		#endif
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

	//3x2 and 2x3 are not emulated on older ReShade versions, so 3x3 is used. Old values for 3x2
	//Screen to depth buffer coordinate: flip, upscaler offset, side scaler.
	void Depth_TC(inout float2 texcoord)
	{
		int Flip_Depth = Flip_Opengl_Depth ? !Depth_Map_Flip : Depth_Map_Flip;

		if (Flip_Depth)
			texcoord.y =  1 - texcoord.y;


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
	}

	float3x3 PrepDepth(float2 texcoord, bool Wide)
	{
		Depth_TC(texcoord);
		float2 TC_D = TC_SP(texcoord).xy;//Same coordinate for both reads.
		float4 DM = Depth(TC_D).xxxx;
		float R, G, B, A, Weapon_Masker = 0;
		//The weapon read only runs with a weapon profile. With WP 0 nothing used it, but it still cost a depth read.
		[branch]
		if (WP != 0)
		{
			float2 WD_CoP = WeaponDepth(TC_D, Wide);
			float WD = WD_CoP.x, CoP = WD_CoP.y, CutOFFCal;
			#if GDM_WEAPON_DEPTH
				//Auto weapon hand cutout.
				CutOFFCal = WPresentCheck ? step(WD,0.999) : 0; //WDepthCheck = weapon present
			#else
				CutOFFCal = step(DM.x,(CoP/DMA()) * 0.5); //Legacy world-depth cutoff (shared DepthBuffer)
			#endif

			if(WMM == 1)//Weapon Mix Mode added for Doom The Dark Ages
			{
				DM.y = WD * CutOFFCal;
				DM.z = lerp(0.5,WD,CutOFFCal);
				DM.x = lerp(lerp(DM.y,DM.x,0.5),DM.x,DM.x);
			}
			else
			{
				//DM.x = lerp(DM.x,WD,CutOFFCal); // Removed
				DM.y = WD * CutOFFCal;
				DM.z = lerp(0.5,WD,CutOFFCal);
			}
			Weapon_Masker = WD * CutOFFCal;
		}
	
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
	//NaN or Inf takes the fallback. Vulkan does not clear new textures.
	float NaN_Guard(float v, float fallback)
	{
		return isnan(v) || isinf(v) ? fallback : v;
	}

	/////////////////////////////////////////////////////////Fade In and Out Toggle/////////////////////////////////////////////////////////////////////
	float Fade_in_out()
	{
		//tex2Dlod: called inside the DepthMap corner branch. Fixed point reads, so the same value.
		float TCoRF[1], Trigger_Fade, AA = Fade_Time_Adjust, PStoredfade = Avr_P(float2(0, 0.0625)).z;
		if(World_n_Fade_Reduction_Power.y == 0)
			AA *= 0.75;
		if(World_n_Fade_Reduction_Power.y == 1)
			AA *= 1.0;
		if(World_n_Fade_Reduction_Power.y == 2)
			AA *= 1.125;
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
			Trigger_Fade = Trigger_Fade_Toggle || Gamepad(4).x;
		else if(FPSDFIO == 2)
			Trigger_Fade = Trigger_Fade_Hold || Gamepad(4).y;
		else if(FPSDFIO == 3)
			Trigger_Fade = SnD_Toggle;
		else if(FPSDFIO == 4)
			Trigger_Fade = Trigger_Fade_Toggle || SnD_Toggle || Gamepad(4).x;			
		else if(FPSDFIO == 5)
			Trigger_Fade = Trigger_Fade_Hold || SnD_Toggle || Gamepad(4).y;
			
		if(Toggle_On_Boundary)	
		{
			if( WP > 0)
			{
				//ABWS: 1 is no hit, under 1 a hit. Else the switch: 1 or 2 is a hit.
				float W_Hit = Avr_P(float2(1, 0.6875)).z;
				Trigger_Fade = (ABWS ? W_Hit < 0.999 : W_Hit >= 1) && Trigger_Fade;
			}
			else //tex2Dlod(SamplerAvrP_N,float4(1, 0.1875,0,0)).z = N
				Trigger_Fade = Avr_P(float2(0, 0.1875)).z > 0.125 && Trigger_Fade;
		}
		
		return NaN_Guard(PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/((1-AA)*1000))), Trigger_Fade); ///exp2 would be even slower
	}
	
	float Auto_Adjust_Cal(float Val)
	{
		return 1000.0 - Val * 2000.0;
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
			STTT_Switch = 0.4;
		}

		if(CWH == 8)
		{
			SF_Switch = 0.75;
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
			
			SFC_Switch = 0.0;
			
			ST_Switch = 0.75;
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


	//ZPD Balance mask: 1 keeps Balance, lower keeps the accurate depth on flat areas like floors
	//On a flat surface 1/depth is a straight line, so the centre is the average of its neighbours
	
	//1/depth at p.
	float Balance_Rd(float2 p, float Mp)
	{
		return rcp(max(tex2Dlod(SamplerDMN, float4(p, 0, Mp)).x, 0.001));
	}

	//One axis of the bend test. x = bend, y = change, z = 1 when tested.
	float3 Balance_Axis(float2 tc, float Mp, float2 D, float C)
	{
		bool InL = all(tc - D >= 0), InH = all(tc + D <= 1);
		float3 Out = 0;
		[branch]
		if(InL && InH)
		{
			float L = Balance_Rd(tc - D, Mp), R = Balance_Rd(tc + D, Mp);
			Out = float3(abs(L + R - 2.0 * C), abs(L - C) + abs(R - C) + 0.01 * C, 1);
		}
		else if(InL || InH)
		{
			float2 Sd = InL ? -D : D;
			float F = Balance_Rd(tc + Sd, Mp), H = Balance_Rd(tc + 0.5 * Sd, Mp);
			Out = float3(abs(F - 2.0 * H + C), abs(F - H) + abs(H - C) + 0.01 * C, 1);
		}
		return Out;
	}

	//Bend test in rings. 0 flat, 1 around objects.
	float Balance_Bend(float2 tc, float Mp, float2 O, int Rings, float2 Rg, float Step)
	{
		float C = Balance_Rd(tc, Mp);
		//The screen border, where a mip texel is filtered against the clamped edge.
		float2 Ed = min(tc, 1.0 - tc) * tex2Dsize(SamplerDMN, 0);
		float  Bd = smoothstep(4.0, 8.0, Ed.x) * smoothstep(4.0, 8.0, Ed.y);
		float  M = 0, Used = 0;
		[loop]
		for(int r = 1; r <= Rings; r++)
		{
			float2 Or = O * r / Rings;
			float3 X = Balance_Axis(tc, Mp, float2(Or.x, 0), C), Y = Balance_Axis(tc, Mp, float2(0, Or.y), C);
			//Step > 0: against the depth, else the largest change.
			float  B  = max(X.x, Y.x) * rcp(Step > 0 ? C * Step : max(max(X.y, Y.y), 0.0001)) * Bd;
			float  Ok = max(X.z, Y.z);
			M    += saturate(smoothstep(Rg.x, Rg.y, B) * 2.0 - 0.5) * Ok;
			Used += Ok;
		}
		return Used > 0 ? M / Used : 0;
	}

	//Fill reach follows perspective.
	float2 Balance_Fill_Reach(float2 tc)
	{
		float Dp = tex2Dlod(SamplerDMN, float4(tc, 0, 3)).x;
		return 64.0 * clamp(pow(0.075 * rcp(max(Dp, 0.001)), 1.125), 0.25, 16.0) * pix;
	}

	//ZPD Balance mask at tc: the white lines, then the fill from mip 3
	float Balance_Mask_At(float2 tc)
	{
		float  Dp  = tex2Dlod(SamplerDMN, float4(tc, 0, 1)).x;
		//White lines.
		float  Far = smoothstep(0.1, 0.3, Dp);
		float  M   = Balance_Bend(tc, 1, 16.0 * lerp(1.0, 0.35, Far) * pix, 4, float2(0.25, 0.5), 0) * lerp(1.0, 0.75, Far);
		//Fill from mip 3.
		M = max(M, Balance_Bend(tc, 3, Balance_Fill_Reach(tc), 4, float2(0.25, 0.5), 0.1) * 0.5 * lerp(1.0, 0.75, Far));
		return lerp(1.0, M, 0.5);
	}

	#if !DX9_DX10_Toggle //DX9 and DX10 never read texMiniReconBuffer, see the texture declaration.
	float2 MiniReconstructionPS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		static const float2 offsets[9] = { float2(-1, -1), float2( 0, -1), float2( 1, -1),
									       float2(-1,  0), float2( 0,  0), float2( 1,  0),
									       float2(-1,  1), float2( 0,  1), float2( 1,  1) };
		float minVal = 1e10;
		SD_UNROLL
		for (int i = 0; i < 9; i++)
		{
			float val = PrepDepth( texcoord + offsets[i] * (DMM == 2 ? pix * float2(12.0, 6.0) : rcp_Depth_Size() * 0.5), false)[1][0];
			minVal = min(minVal, val);
		}
		#if Anti_Jitter_Mode
		float Prev = tex2Dlod(SamplerMR_Hold, float4(texcoord,0,0)).x;//R eases in, G stays instant.
		minVal = lerp(NaN_Guard(Prev, minVal), minVal, saturate(1.0 - exp(-frametime / MR_Hold_Ms)));
		#endif
		//ZPD Balance mask at 1/8 size.
		float BM = 1;
		[branch]
		if(ZPD_Balance > 0)
			BM = Balance_Mask_At(texcoord);
		return float2(minVal, BM);
	}

	#if Anti_Jitter_Mode && !MW_SCAN_OK
	//This frame's R for the next frame.
	float MiniReconHoldPS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		return tex2Dlod(SamplerMR, float4(texcoord,0,0)).x;
	}
	#endif
	//The small Balance mask, blurred 1 2 1 sideways, then up and down.
	float Balance_Mask_Low(float2 tc)
	{
		float2 Ox = float2(1.5 * rcp(tex2Dsize(SamplerMR_L, 0).x), 0);
		float H = (tex2Dlod(SamplerMR_L, float4(tc - Ox, 0, 0)).y + 2.0 * tex2Dlod(SamplerMR_L, float4(tc, 0, 0)).y + tex2Dlod(SamplerMR_L, float4(tc + Ox, 0, 0)).y) * 0.25;
		float2 Oy = float2(0, 1.5 * rcp(tex2Dsize(SamplerMR_L, 0).y));
		return (tex2Dlod(SamplerMR_L, float4(tc - Oy, 0, 0)).y + 2.0 * H + tex2Dlod(SamplerMR_L, float4(tc + Oy, 0, 0)).y) * 0.25;
	}
	#endif

	//DMM 2: nearest depth across a ZPD detector's cell, 8 spots across, 3 rows. DX9 and DX10 read one depth per spot.
	float Detector_Depth(float2 Cell)
	{
		float Nearest = 1e4;
		[loop]
		for(int y = -1; y <= 1; y++)
		{
			[loop]
			for(int x = 0; x < 8; x++)
			{
				float2 Spot = saturate(Cell + float2((x - 3.5) * 0.015625, y * 0.03125));
				#if DX9_DX10_Toggle
					Nearest = min(Nearest, PrepDepth(Spot, false)[1][0]);
				#else
					float4 Quad = tex2DgatherR(SamplerMR, Spot);
					Nearest = min(Nearest, min(min(Quad.x, Quad.y), min(Quad.z, Quad.w)));
				#endif
			}
		}
		return Nearest;
	}
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
						// BD7 FPS Mixed: narrow spacing except the two outermost columns, which take the edge positions from A0
						// Y is unchanged, so the bottom row stays at the narrow 0.9
						GridXY = float2( (iX == 0 || iX == iXY.x - 1) ? CDArray_X_A0[iX] : CDArray_X_B0[iX], CDArray_Y_A0[iY]);
					else if(ZPD_Boundary == 3)
						GridXY = float2( Detect_More_Mode ? CDArray_X_C1[iX] : CDArray_X_C0[iX], CDArray_Y_C0[min(3,iY)]);
					else if(ZPD_Boundary == 4)
						GridXY = float2( CDArray_X_A0[iX], CDArray_Y_B0[iY]);
					//We shift the lower half here to have a better spread.
					if(texcoord.y > 0.6 && texcoord.y < 0.8)						
						GridXY.y += Shift_Mask(texcoord).x ? 0.0 : 0.05;

					float ZPD_I = Zero_Parallax_Distance;
					#if !DX9_DX10_Toggle
					float PDepth = DMM == 2 ? Detector_Depth(GridXY) : tex2Dlod(SamplerMR,float4(GridXY,0,0)).x;
					#else				
					float PDepth = DMM == 2 ? Detector_Depth(GridXY) : PrepDepth(GridXY, false)[1][0];
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

							if(ZPD_Boundary_n_Cutoff_End.z != 0)
								if (CD < -RE_Extended().w && Detect_Out_of_Range <= 6)
									Detect_Out_of_Range = 6;
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
							#if OIL >= 5
							if ( CD < -RE_Extended().w && Detect_Out_of_Range <= 6)
								Detect_Out_of_Range = 6;
							#endif
					
						#endif							
					}
				}
			}
		}
		uint Sat_D_O_R = Detect_Out_of_Range == Fast_Trigger_Mode;
		float ZPD_BnF = Auto_Adjust_Cal(Sat_D_O_R ? 0.5 - FLT_EPSILON : ZPD_Boundary_n_Fade.y);
		float PStoredfade_A = Avr_P(float2(0, 0.1875)).z,//0 
			  PStoredfade_B = Avr_P(float2(0, 0.3125)).z,//1
			  PStoredfade_C = Avr_P(float2(1, 0.1875)).z,//2
			  PStoredfade_D = Avr_P(float2(1, 0.3125)).z,//3
			  PStoredfade_E = Avr_P(float2(1, 0.4375)).z,//4
			  PStoredfade_F = Avr_P(float2(1, 0.5625)).z,//5
			  PStoredfade_G = Avr_P(float2(0, 0.9375)).z;//6, only Mod_Z stores it
	
		// Fade in toggle.
		float CallFT = 1.0 - exp(-frametime / ZPD_BnF); // exp2 would be even slower
		return float3x3(float3(NaN_Guard(PStoredfade_A + (Detect - PStoredfade_A) * CallFT, Detect),
	                           NaN_Guard(PStoredfade_B + ((Detect_Out_of_Range >= 1) - PStoredfade_B) * CallFT, Detect_Out_of_Range >= 1),
	                           NaN_Guard(PStoredfade_C + ((Detect_Out_of_Range >= 2) - PStoredfade_C) * CallFT, Detect_Out_of_Range >= 2)),
	                    float3(NaN_Guard(PStoredfade_D + ((Detect_Out_of_Range >= 3) - PStoredfade_D) * CallFT, Detect_Out_of_Range >= 3),
	                           NaN_Guard(PStoredfade_E + ((Detect_Out_of_Range >= 4) - PStoredfade_E) * CallFT, Detect_Out_of_Range >= 4),
	                           NaN_Guard(PStoredfade_F + ((Detect_Out_of_Range >= 5) - PStoredfade_F) * CallFT, Detect_Out_of_Range >= 5)),
	                    float3(saturate(Detect_Out_of_Range * 0.2),
	                           NaN_Guard(PStoredfade_G + ((Detect_Out_of_Range >= 6) - PStoredfade_G) * CallFT, Detect_Out_of_Range >= 6), 0));
						 
	}

	#define FadeSpeed_AW 0.375
	float AltWeapon_Fade()
	{
		float  ExAd = (1-(FadeSpeed_AW * 2.0))*1000, Current =  min(0.75f,smoothstep(0,0.25f,PrepDepth(0.5f, false)[0][0])), Past = Avr_P(float2(0, 0.5625)).z;
		return NaN_Guard(Past + (Current - Past) * (1.0 - exp(-frametime/ExAd)), Current);
	}

	#define FadeSpeed_AF AFS //Overwatch controlled, AFS defaults to 0.4375. Lower is slower.

	// BSD: the A and B weapon detectors used to hand out a DISCRETE switch
	static const bool W_Smooth_A_B = ABWS;
	#define WZPD_RAMP 1.0 //how sharply the ramp reaches full strength past the limit. Lower is softer.
	float Weapon_ZPD_Fade(float Weapon_Con)
	{
		float  ExAd = (1-(FadeSpeed_AF * 2.0))*1000, Current =  Weapon_Con, Past = Avr_P(float2(0, 0.6875)).z;
		return NaN_Guard(Past + (Current - Past) * (1.0 - exp(-frametime/ExAd)), Current);
	}

	#define FadeSpeed_OS 0.75

	float OverShoot_Fade()
	{
		float Current, Past, Rate;
		#if ISOGL //One copy of PrepDepth for the GL compiler, same three reads.
		float3 PD_ABC;
		[loop]
		for(int p = 0; p < 3; p++)
			PD_ABC[p] = PrepDepth(float2(p == 0 ? 0.5 : p == 1 ? 0.75 : 0.25, 0.5), false)[0][0];
		#else
		float3 PD_ABC = float3(PrepDepth(0.5f, false)[0][0],PrepDepth(float2(0.75,0.5), false)[0][0],PrepDepth(float2(0.25,0.5), false)[0][0]);
		#endif
		float Min_Depth = Min3(PD_ABC.x, PD_ABC.y, PD_ABC.z);
		
		Past = Avr_P(float2(1, 0.9375)).z;
		Current = smoothstep(0,0.25,Min_Depth);
		#if MEM_INFILL
		//Memory Infill: no Smart Convergence while aiming, it widens the holes beside the gun as it zooms
		//Aiming is the Fade Key, held unless Activation Type is Press (1 or 4)
		if(FPSDFIO == 1 || FPSDFIO == 4 ? Trigger_Fade_Toggle || Gamepad(4).x : Trigger_Fade_Hold || Gamepad(4).y)
			Current = 0.0;
		#endif
		
		Rate = FadeSpeed_OS; //0-1
		
		return NaN_Guard(lerp(Past, Current, Rate * frametime/1000), Current);
	}
	
	//////////////////////////////////////////////////////////Depth Map Alterations/////////////////////////////////////////////////////////////////////
	float Auto_Scaler() // Look into merging this with Auto Balance
	{    	
		return saturate(lerp( Depth( float2(0.5,0.5) ) * 2 , Avr_Mix(float2(0.5,0.5)).x , 0.25) ) ;
	}
	
	void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD
	#if !DX9_DX10_Toggle
	, in nointerpolation float4 DM_F : TEXCOORD1
	#endif
	, out float2 DM_Out : SV_Target0 , out float2 Color_Out : SV_Target1)
	{
		float3x3 PD = PrepDepth(texcoord, true);
		float4 DM = float4(PD[0][0],PD[0][1],0,PD[1][1]);
		float R = DM.x, G = DM.y, B = DM.z, Auto_Scale = 1;
		float SP_Min = Set_Pop_Min().y, Select_Min_LvL_Trigger = 0;float3 Level_Control = DS_X;

		//Fade Storage
		#if DX9_DX10_Toggle
		float3x3 Fade_Pass = float3x3(0,0,0, 0,0,0, 0,0,0);
		float2 Fade_C = pix * 3.0;//C_Size
		[branch]
		if((texcoord.x < Fade_C.x || 1-texcoord.x < Fade_C.x) && (texcoord.y < Fade_C.y || 1-texcoord.y < Fade_C.y))
			Fade_Pass = Fade(texcoord); //[0][0] = 0 | [0][1] = 1 | [0][2] = 2
						 				//[1][0] = 3 | [1][1] = 4 | [1][2] = 5
										//[2][0] = N | [2][1] = 6, Mod_Z stores it | [2][2] = 0
		float2 Min_Trim = float2(SP_Min,WZPD_and_WND.w);
		#else
		//Every pixel needs [0][0] and [1][1].
		float3 Fade_Pass_A = float3( DM_F.x, 0, 0);//Made in DepthMap_VS.
		float3 Fade_Pass_B = float3( 0, DM_F.y, 0);
																        
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
			//Auto Scale. Only used here, so its full depth lookup only runs here.
			float Auto_A = abs(WZPD_and_WND.z), Auto_Floor = lerp(1.0,0.1,saturate(Auto_A * 2)) - 0.1 * saturate(Auto_A * 2 - 1);//0.5 = 10%, 0.75 = 5%, 1.0 = 0%
			#if DX9_DX10_Toggle
			if(WZPD_and_WND.z > 0)
				Auto_Scale = lerp(Auto_Floor,1.0,lerp(saturate(Auto_Scaler() * 2.5) , smoothstep(0,0.5,Avr_P(float2(0, 0.5625)).z), 0.5));
			else if(WZPD_and_WND.z < 0)
				Auto_Scale = lerp(1.0,Auto_Floor,saturate(Auto_Scaler() * 2.5));
			#else
			if(WZPD_and_WND.z > 0)
				Auto_Scale = lerp(Auto_Floor,1.0,lerp(saturate(DM_F.z * 2.5) , smoothstep(0,0.5,DM_F.w), 0.5));
			else if(WZPD_and_WND.z < 0)
				Auto_Scale = lerp(1.0,Auto_Floor,saturate(DM_F.z * 2.5));
			#endif
			R = saturate(lerp(ScaleND,R,smoothstep(0,Min_Trim.y,ScaleND)));
			R = lerp(DM.x,R,Auto_Scale);
		}
		if ( Weapon_Depth_Edge.x > 0)//1.0 needs adjusting for far scaling
			R = lerp(DepthEdge(R, DM.x, texcoord, 1-Weapon_Depth_Edge.x),DM.x,smoothstep(0,1.0,DM.x));
		
		float C_Size = 3;

		//Corner storage. Only the 3 px corners, so the reads below run there only.
		[branch]
		if(min(texcoord.x, 1 - texcoord.x) < pix.x * C_Size && min(texcoord.y, 1 - texcoord.y) < pix.y * C_Size)
		{
		if(   texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TL OG Fade
			R = Fade_in_out().x;
		#if DX9_DX10_Toggle
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
				R = Blur_N(float2(0,0.1875), 0).x;//[0][1]
			if( 1-texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TR 2
				R = Blur_N(float2(0,0.3125), 0).x;//[0][2]

			if( 1-texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TR 3
				G = Blur_N(float2(0,0.4375), 0).x;//[1][0]
			if(   texcoord.x < pix.x * C_Size &&   texcoord.y < pix.y * C_Size)//TL 4
				G = Fade_Pass_B.y;//[1][1]
			if( 1-texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BR 5
				G = Blur_N(float2(0,0.6875), 0).x;//[1][2]
			if(   texcoord.x < pix.x * C_Size && 1-texcoord.y < pix.y * C_Size)//BL N
				G = Blur_N(float2(0,0.9375), 0).x;//[2][0]
		#endif
		}
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

			//7 samples: center, the 4 gathered, left and right.
			float left  = tex2D(Non_Point_Sampler, texcoord - float2(pix.x, 0.0)).w;
			float right = tex2D(Non_Point_Sampler, texcoord + float2(pix.x, 0.0)).w;

			float Alpha_Avr = Isolate_UI ? 6.0 : 7.0;
			float Color_UI_MAP = (center + gathered.x + gathered.y + gathered.z + gathered.w + left + right) * rcp(Alpha_Avr);

			Color.y = 1 - Color_UI_MAP;
		}
		else
			Color.y = tex2D(Non_Point_Sampler, texcoord).w;
		#endif
		
		DM_Out = saturate(float2(R,G));
		
		Color_Out = saturate(Color.xy);
	}

	#if GDM_DEPTH_AUTOFIT
	//GDM fit: the depth box's size on screen, same math as TC_SP. 1.0 means no bars.
	float2 GDM_Box()
	{
		float2 Box = 1.0;
		if(DB_AutoFit && DB_Res_Info.x > 0 && DB_Res_Info.y > 0 && DB_Viewport_Size.z > 0 && DB_Viewport_Size.w > 0)
		{
			float2 DB_Ref = (DB_Render_Size.x > 0) ? DB_Render_Size : float2(BUFFER_WIDTH, BUFFER_HEIGHT);
			if(abs(DB_Viewport_Size.z * DB_Ref.y - DB_Viewport_Size.w * DB_Ref.x) > DB_Ref.x * DB_Viewport_Size.w * 0.02)
				Box = saturate(DB_Viewport_Size.zw / DB_Ref);
		}
		return Box;
	}
	#endif

	float AutoDepthRange(float d, float2 texcoord, float Avr )
	{
		float LumAdjust_ADR = smoothstep(-0.0175,min(0.5,Auto_Depth_Adjust),Avr);
		return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
	}
		
	//Mod_Z's fixed reads, the same texels for every pixel.
	void ModZ_Fixed_Reads(out float4 FR_0, out float4 FR_1, out float4 FR_2, out float4 FR_3, out float2 FR_W)
	{
		FR_0 = float4(Avr_P(float2(1, 0.9375)).z, Avr_P(float2(0, 0.6875)).z, 0, 0);
		if(Auto_Depth_Adjust > 0)
		{
			FR_0.z = Avr_Mix(float2(0.5,0.5)).x;
			#if GDM_DEPTH_AUTOFIT
			//GDM fit leaves white bars (depth 1) outside the depth box. Take them out of the average, F is the box's share.
			float2 Box = GDM_Box();
			float F = max(Box.x * Box.y, 0.01);
			FR_0.z = saturate((FR_0.z - (1 - F)) / F);
			#endif
		}
		if(Focus_Reduction_Type != 0)
			FR_0.w = Avr_P(float2(0, 0.0625)).z;
		FR_1 = float4(Avr_P(float2(0, 0.1875)).z, Avr_P(float2(0, 0.3125)).z,
		              Avr_P(float2(1, 0.1875)).z, Avr_P(float2(1, 0.3125)).z);
		FR_2 = float4(Avr_P(float2(1, 0.4375)).z, Avr_P(float2(1, 0.5625)).z,
		              Avr_P(float2(1, 0.8125)).z, 0);
		if(abs(AWZ) > 0)
			FR_2.w = tex2Dlod(SamplerDMN,float4(float2(AWZ < 0 ? 0.55 : 0.50,0.525),0,7)).x;
		FR_3 = 0;
		FR_W = 0;
		if(abs(Weapon_ZPD_Boundary.x) > 0)
		{
			#if WBS
			float WArray[6] = { 0.1, 0.2, 0.3, 0.7, 0.8, 0.9};
			#else
			float WArray[6] = { 0.25, 0.5, 0.6, 0.7, 0.8, 0.9};
			#endif
			float Distance_From_Bottom = lerp(0.9,1.0,saturate(WFB)), WTap[6];
			SD_UNROLL
			for(int i = 0; i < 6; i++)
				WTap[i] = tex2Dlod(SamplerDMN, float4(float2(WArray[i],Distance_From_Bottom), 0, 0)).y;
			FR_3 = float4(WTap[0], WTap[1], WTap[2], WTap[3]);
			FR_W = float2(WTap[4], WTap[5]);
		}
	}

	float4 Conv(float2 MD_WHD,float2 texcoord,float2 abs_WZPDB,float4x4 FR,float2 FR_W)
	{   float WConverge = 0.030, D = MD_WHD.x, Z = Zero_Parallax_Distance, WZP = 0.5, ZP = 0.5, OS_Value = saturate(FR[0].x),
			  W_Convergence = Inficolor_Near_Reduction ? WConverge * 0.75 : WConverge, WZPDB, WZPD_Switch, 
			  Distance_From_Bottom = lerp(0.9,1.0,saturate(WFB)), ZPD_Boundary_Adjust = ZPD_Boundary_n_Fade.x, Store_WC,
			  Switch_Factor = 1.0, Fade_A = 0.0, Fade_B = 0.0;
		//Screen Space Detector.
		if (abs_WZPDB.x > 0)
		{
			//Weapon sample row: WO is the window both detectors scan when ABWS is off, A and B are the ABWS on windows
			#if WBS			   
			//All three windows cover the whole row, so ABWS changes nothing here.
			#define WO_FIRST 0
			#define WO_LAST  5
			#define WA_FIRST 0
			#define WA_LAST  5
			#define WB_FIRST 0
			#define WB_LAST  5
			#else
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
			float WTap[6] = { FR[3].x, FR[3].y, FR[3].z, FR[3].w, FR_W.x, FR_W.y };//The row reads, made in ModZ_Fixed_Reads.
			SD_UNROLL //Krilly only need to check one point just above the center bottom and to the right.
			for( int i = 0 ; i < 6; i++ )
			{
				WZPDB  = 1 - WConverge / WTap[i];
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
					 //Used if Weapon Buffer is way out of range. ABWS on drops the |y| > |x| test,
					 //since B has its own window and depth limit there
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
					 //Used if Weapon Buffer is way out of range. ABWS on drops the |y| > |x| test,
					 //since B has its own window and depth limit there
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
		W_Convergence = 1 - FR[0].y / MD_WHD.y;// 1-W_Convergence/D
		float WD = MD_WHD.y; //Needed to separate the depth for the weapon hand. It was causing problems with Auto Depth Range below.
	
			if (Auto_Depth_Adjust > 0)
				D = AutoDepthRange(D,texcoord,FR[0].z);
			//Used to scale Auto Balance. Here 0 means we are looking close at something.
			if(ZPD_Balance >= 0)
				ZP = saturate( abs(ZPD_Balance) * (OS_Value * OS_Value));// * MD_WHD.x);

			float4 Set_Adjustments = RE_Set_Adjustments();float2 SC_Adjutment = DT_W;
			float DOoR_A = smoothstep(0,1,FR[1].x), //ZPD_Boundary    0
				  DOoR_B = smoothstep(0,1,FR[1].y),   //Set_Adjustments 1
				  DOoR_C = smoothstep(0,1,FR[1].z),     //Set_Adjustments 2
				  DOoR_D = smoothstep(0,1,FR[1].w),       //Set_Adjustments 3
				  DOoR_E = smoothstep(0,1,FR[2].x),         //Set_Adjustments 4 
				  DOoR_F = smoothstep(0,1,FR[2].y),		   //Set_Adjustments 5
				  SetLvL = smoothstep(0,1,FR[2].z); //Set_Level N
			
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

					if (ZPDBoundaryRank() >= 5)
					{
						DOoR_F = lerp(DOoR_F, RE_Extended().z, smoothstep(0,1,Avr_P(float2(0, 0.9375)).z));
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

					#if OIL >= 5
						DOoR_F = lerp(DOoR_F, RE_Extended().z, smoothstep(0,1,Avr_P(float2(0, 0.9375)).z));
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
			//Skipped when there is no Balance to mask.
			[branch]
			if(Zero_Parallax_Distance > 0 && ZP > 0)
				#if DX9_DX10_Toggle
				ZP *= Balance_Mask_At(texcoord);
				#else
				ZP *= Balance_Mask_Low(texcoord);
				#endif

		//* lerp(1,2,D) // place this after saturate(Convergence)
		float Mod_Depth = lerp(Convergence,lerp(D,Convergence,saturate(Convergence) ), ZP);
		//Behind the screen the blend is C + ZP * (Z - C + C * C). ZPD_Balance_Curve 2 or 3 moves its floor bend
		//into the distance, same ZPD and same near and far. 1.0 is the original and skips this.
		const float ZPD_Balance_Curve = 1.0;
		if(ZPD_Balance_Curve != 1.0 && Convergence >= 0 && Z > 0)
			Mod_Depth = Convergence + ZP * (Z - Convergence + 2.0 * pow(Convergence, ZPD_Balance_Curve + 1.0) / (ZPD_Balance_Curve + 1.0));
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
	
	float4 DB_Comb(float2 texcoord, float4x4 FR, float2 FR_W)
	{
		float Auto_Adjust_Weapon_Depth = 1, Anti_Weapon_Z = abs(AWZ);
		float2 MD_W = tex2Dlod(SamplerDMN,float4(texcoord,0,0)).xy;
		//X = Mix Depth | Y = Weapon Mask | Z = Weapon Hand | W = Normal Depth
		float  PD_N = PrepDepth( texcoord, true )[1][1];//Also returned at the end, so it is read once.
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
			
		if (WP == 0)
			DM.y = 0;	
	
		//Handle Convergence Here
		float2 WZPDB = abs(Weapon_ZPD_Boundary);
		float4 HandleConvergence = Conv(DM.xz,texcoord,WZPDB,FR,FR_W).xyzw;
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

		float FadeIO = Focus_Reduction_Type == 0 ? 1 : smoothstep(0, 1, 1 - FR[0].w/*stored Fade_in_out*/), FD_Adjust = 0.050;	
	
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
			float AAWD_Adjust = FR[2].w;
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
			Cancel_Depth_Controller = Gamepad(20).x; //Guide Button. May not work on some controllers.
			#elif Cancel_Depth_Key == 2
			Cancel_Depth_Controller = Gamepad(21).x; //Back + Left Trigger
			#elif Cancel_Depth_Key == 3
			Cancel_Depth_Controller = Gamepad(22).x; //Back + Left Bumper
			#elif Cancel_Depth_Key == 4
			Cancel_Depth_Controller = Gamepad(23).x; //Back + Right Trigger
			#elif Cancel_Depth_Key == 5
			Cancel_Depth_Controller = Gamepad(24).x; //Back + Right Bumper
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
			float Cal_Depth = saturate(Conv(tex2Dlod(SamplerDMN,float4(texcoord,0,8.5)).x,texcoord,0.0,FR,FR_W).x);
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
		float HUDCutOFFCal = ((HUD_Adjust.x * 0.5)/DMA()) * 0.5, COC = step(PrepDepth(texcoord, false)[1][2],HUDCutOFFCal); //HUD Cutoff Calculation

		//HUD segregation.
		if (HUD_Adjust.x > 0)
			DM.y = COC ? 0.001 + lerp(-0.25,0.25,saturate(HUD_Adjust.y)) : DM.y ;
		#endif
	
		return float4(DM.y,PD_N,HandleConvergence.z,HandleConvergence.w);
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
			SD_V[p] = PrepDepth(SD_Pos[p], false)[0][0];
		float Check_Depth_Pos_Bot_A = SD_V[0], Check_Depth_Pos_Bot_B = SD_V[1], Check_Depth_Pos_Bot_C = SD_V[2];
		float Check_Depth_Pos_Corner = SD_V[3], Check_Depth_Pos_Side_A = SD_V[4], Check_Depth_Pos_Side_B = SD_V[5];
		#else
		float Check_Depth_Pos_Bot_A = PrepDepth(float2(0.25,0.999), false)[0][0];
		float Check_Depth_Pos_Bot_B = PrepDepth(float2(0.75,0.999), false)[0][0];
		float Check_Depth_Pos_Bot_C = PrepDepth(float2(0.50,0.999), false)[0][0];
		
		float Check_Depth_Pos_Corner = PrepDepth(float2(0.999,0.999), false)[0][0];
	
		float Check_Depth_Pos_Side_A = PrepDepth(float2(0.999,0.5), false)[0][0];//Was 1.0, 0.5
		float Check_Depth_Pos_Side_B = PrepDepth(float2(0.999,0.75), false)[0][0];
		#endif
		
		int Check_Depth_Shift_A = Check_Depth_Pos_Bot_A * Check_Depth_Pos_Bot_B * Check_Depth_Pos_Side_A * Check_Depth_Pos_Corner;
		int Check_Depth_Shift_B = Check_Depth_Pos_Side_B * Check_Depth_Pos_Side_A * Check_Depth_Pos_Corner;
		int Check_Depth_Shift_C = Check_Depth_Pos_Bot_A * Check_Depth_Pos_Bot_B * Check_Depth_Pos_Bot_C  * Check_Depth_Pos_Corner;
		
		return int3(Check_Depth_Shift_A == 1, Check_Depth_Shift_B == 1, Check_Depth_Shift_C == 1 ) && If_Has_Depth;
	}

	#define Adapt_Adjust 0.7 //[0 - 1]
	////////////////////////////////////////////////////Depth & Special Depth Triggers//////////////////////////////////////////////////////////////////
	void Mod_Z(in float4 position : SV_Position, in float2 texcoord : TEXCOORD
	#if !DX9_DX10_Toggle
	, in nointerpolation float4 FR_0 : TEXCOORD1, in nointerpolation float4 FR_1 : TEXCOORD2, in nointerpolation float4 FR_2 : TEXCOORD3, in nointerpolation float4 FR_3 : TEXCOORD4, in nointerpolation float2 FR_W : TEXCOORD5
	#endif
	, out float2 Linear_Out : SV_Target0)
	{   //Temporal adaptation based on https://knarkowicz.wordpress.com/2016/01/09/automatic-exposure/
		float ExAd = (1-Adapt_Adjust)*1250;
		bool  TL = texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2;
		//Temporal again, but for pop out.
					//Popout Detection
			//Color = tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w > 0; // Detect if there is pop out.
			//Color = smoothstep(0,0.1,tex2Dlod(SamplerAvrP_N,float4(texcoord,0,12)).w); //Scale Popout linearly 
		
		#if DX9_DX10_Toggle
		float4 FR_0, FR_1, FR_2, FR_3; float2 FR_W;
		ModZ_Fixed_Reads(FR_0, FR_1, FR_2, FR_3, FR_W);
		#endif
		float4 Set_Depth = DB_Comb( texcoord.xy, float4x4(FR_0, FR_1, FR_2, FR_3), FR_W ).xyzw;
		
		//Only the top left pixel stores the adaptation and reads the inputs.
		[branch]
		if(TL)
		{
			float Current_A = tex2Dlod(SamplerCN,float4(texcoord,0,12)).x, Past_A = Avr_P(float2(0, 0.4375)).z;
			Set_Depth.y = NaN_Guard(Past_A + (Current_A - Past_A) * (1.0 - exp(-frametime/ExAd)), Current_A);
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
		//Normal depth, with Popout and OverShoot stored next to TL and BL.
		float Linear_Y = Set_Depth.y;
		bool Next_To_Corner = texcoord.x >= pix.x * 2 && texcoord.x < pix.x * 4;
		[branch]
		if(Next_To_Corner && texcoord.y < pix.y * 2) //TL
		{
			float Current_B = smoothstep(0,0.1,Avr_P_Top(0.5.xx).w), Past_B = Avr_P(float2(0, 0.8125)).z;
			Linear_Y = NaN_Guard(Past_B + (Current_B - Past_B) * (1.0 - exp(-frametime/ExAd)), Current_B);
		}
		[branch]
		if(Next_To_Corner && 1-texcoord.y < pix.y * 2) //BL
			Linear_Y = OverShoot_Fade();
		#if OIL >= 5 || EDW || Profiler_Mode
		//ZPD level 7 fade, stored next to TR. Its detector runs on these px only.
		[branch]
		if(1-texcoord.x >= pix.x * 2 && 1-texcoord.x < pix.x * 4 && texcoord.y < pix.y * 2)
			Linear_Y = Fade(texcoord)[2][1];
		#endif

		Linear_Out = float2(Set_Depth.x,Linear_Y);
	}
	
	void zBuffer_Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD
	#if !DX9_DX10_Toggle
	, in nointerpolation float4 Fade_A : TEXCOORD1, in nointerpolation float4 Fade_B : TEXCOORD2
	#endif
	, out float4 Blur_Out : SV_Target0)
	{   
		float2 StoredTC = texcoord;
		#if DX9_DX10_Toggle
		//Only the right half reads it.
		float Invert_Depth_Mask = 0;
		[branch]
		if(StoredTC.x >= 0.5)
			Invert_Depth_Mask =  1-smoothstep(0.0,0.5,PrepDepth( StoredTC * float2(2.0, 1) - float2(1.0,0.0), false)[1][1]);
		#else
		//DX10+: only the right half reads it, so it is made in the Fade branch's else below.
		float Invert_Depth_Mask = 0;
		#endif
		float Text_Mask = 0;
		float Average_ZPD = PrepDepth( texcoord, false)[0][0];
		float Average_UI = tex2Dlod(SamplerCN,float4(texcoord,0,12)).y;
		#if TMD
				#if DX9_DX10_Toggle
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
		
		#if !DX9_DX10_Toggle
		//Fade Storage. Only the left half stores it, so the detector grid only runs there.
		float Stored_Fade = 0;
		[branch]
		if(StoredTC.x < 0.5)
		{
			//Made in Blur_VS. Fade shifts the lower grid on these rows and columns, so they take the shifted pair.
			bool Shift = StoredTC.y > 0.6 && StoredTC.y < 0.8 && !Shift_Mask(StoredTC).x;
			const int Num_of_Values = 8; //8 array values in total, mapped to the texture's width.
			float Storage_Array[Num_of_Values] = { Fade_A.x,                             //0.0625 //Fade Level 0
			                                       Fade_A.y,                             //0.1875 //Fade Level 1
			                                       Fade_A.z,                             //0.3125 //Fade Level 2
			                                       Fade_A.w,                             //0.4375 //Fade Level 3
			                                       Shift ? Fade_B.w : Fade_B.x,          //0.5625 //Fade Level 4, the shifted rows take their own
			                                       Fade_B.y,                             //0.6875 //Fade Level 5, same grid as the other levels and DX9 and DX10
			                                       0.0,                                  //0.8125 //Free, the Auto Scaler's depth shift goes here below
			                                       Fade_B.z };                           //0.9375 //Fade Level N
			//Set an average size for the number of lines needed in texture storage.
			float Grid = floor(StoredTC.y * BUFFER_HEIGHT * BUFFER_RCP_HEIGHT * Num_of_Values);							 
			Stored_Fade = Storage_Array[int(fmod(Grid,Num_of_Values))];
			//The Auto Scaler's depth shift goes in the free slot (0.8125). Only the column Mix_Z reads works it out.
			[branch]
			if(int(fmod(Grid,Num_of_Values)) == 6 && position.x < 1 && ASA_On && AR_Is != 2)
			{
				int3 Edge_Shift = Shift_Depth();
				Stored_Fade = Edge_Shift.x + 2.0 * Edge_Shift.y + 4.0 * Edge_Shift.z + 8.0 * (LBDetection() != 0);
			}
		}
		else
			Invert_Depth_Mask =  1-smoothstep(0.0,0.5,PrepDepth( StoredTC * float2(2.0, 1) - float2(1.0,0.0), false)[1][1]);
		Blur_Out = float4( StoredTC.x < 0.5 ? Stored_Fade : Invert_Depth_Mask, Text_Mask, Average_ZPD, 1 - Average_UI * 0.25);
		#else
		Blur_Out = float4(StoredTC.x < 0.5 ? Text_Mask : Invert_Depth_Mask, 0, Average_ZPD, 1 - Average_UI * 0.25);
		#endif
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
		float S_T_Adjust = min(1.0+saturate(M_Divergence),abs(Divergence_Switch().y) * 0.01);// * RCP_Diverge;
		return abs(lerp(0.01f,1.0f,S_T_Adjust));
	}

	static const float VMW_Array[10] = { 0.0, 1.0, 2.0, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0 };

	//Sideways nearest depth over a mip based reach
	float DilateH_Scan(sampler tex, float2 uv, float vmw)
	{
		const float tapMip = 2.0;
		float reach = pix.x * exp2(vmw) * 2.0;
		float m = tex2Dlod(tex, float4(uv, 0, 0)).x;
		//3 taps each side.
		SD_UNROLL
		for (int i = 1; i <= 3; ++i)
		{
			float off = reach * i / 3.0;
			m = min(m, tex2Dlod(tex, float4(uv + float2(off, 0), 0, tapMip)).x);
			m = min(m, tex2Dlod(tex, float4(uv - float2(off, 0), 0, tapMip)).x);
		}
		return m;
	}

	float DilateH(sampler tex, float2 uv, float vmw)
	{
		float Depth   = tex2Dlod(tex, float4(uv, 0, 0)).x, Dilated_Out = Depth;
		[branch]
		if(vmw > 0.0)
		{
			//Row only: the mip read's width sideways, two levels down so a quarter of the rows. Horizontal edges do not bend.
			float Row_Lvl = max(vmw - 2.0, 0.0), Row_W = exp2(vmw) * pix.x / Depth_Rez, Row_A = Row_W * 0.2165, Row_B = Row_W * 0.65;
			float mipped  = (tex2Dlod(tex, float4(saturate(uv.x + Row_A), uv.y, 0, Row_Lvl)).x + tex2Dlod(tex, float4(saturate(uv.x - Row_A), uv.y, 0, Row_Lvl)).x +
			                 tex2Dlod(tex, float4(saturate(uv.x + Row_B), uv.y, 0, Row_Lvl)).x + tex2Dlod(tex, float4(saturate(uv.x - Row_B), uv.y, 0, Row_Lvl)).x) * 0.25;
			//Near takes the mip read, far the row read, linear in depth
			mipped = lerp(tex2Dlod(tex, float4(uv, 0, vmw)).x, mipped, saturate(Depth));
			//GetDB takes min(this, Depth). A mip that is not nearer gives Depth, so skip the scan.
			[branch]
			if(mipped < Depth)
			{
				float dilated = DilateH_Scan(tex, uv, vmw);
				float mask = saturate((Depth - dilated) * 8.0);
				Dilated_Out = lerp(mipped, Depth, 1-mask);
			}
		}
		return Dilated_Out;
	}

	//VM5 Blend
	float VM5_Near(float2 texcoord)
	{
		float Band = max(VM5_Blend_Point.y,0.001);
		float D = smoothstep(0,1,tex2Dlod(SamplerDMN,float4(texcoord,0,2.0)).x);
		return 1.0 - smoothstep(VM5_Blend_Point.x,VM5_Blend_Point.x + Band,D);
	}

	//VM0 Normal, same rule as Blend with its own point
	float VM0_Near(float2 texcoord)
	{
		float Band = max(VM0_Blend_Point.y,0.001);
		float D = smoothstep(0,1,tex2Dlod(SamplerDMN,float4(texcoord,0,2.0)).x);
		return 1.0 - smoothstep(VM0_Blend_Point.x,VM0_Blend_Point.x + Band,D);
	}

	float GetDB(float2 texcoord)
	{
		//UI Lift Masking (TMD)
		#if TMD
			float TMD_LvL = (TMD == 1) ? 60 : 600;
			#if DX9_DX10_Toggle
				float Basic_UI = Blur_N(texcoord * float2(0.5, 1.0), 2.5).x;
			#else
				float Basic_UI = Blur_N(texcoord, 2.5).y;
			#endif
			Basic_UI = saturate(Basic_UI * TMD_LvL);
		#endif
	
		//Vertical Pinball coordinate swap.
		if(Vert_3D_Pinball && !MULTI_VIEW)
			texcoord.xy = texcoord.yx;
	
		float N_P0 = Corner_L(texcoord);

		//VM3 uses the point depth, the rest the smoothed depth.
		#if !Use_2D_Plus_Depth
			bool Use_Point  = View_Mode == 3;
			bool Use_Smooth = View_Mode != 3;
		#else
			bool Use_Point  = false;
			bool Use_Smooth = true;
		#endif

		float Point_Depth = 0;
		[branch]
		if(Use_Point)
			Point_Depth = Point_L(texcoord);

		float Min_Blend = 0;
		[branch]
		if(Use_Smooth)
		{
			float Base_Depth = tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, 0)).x;
	
			//Pick the warp mip level (VMW).
			uint VMW_Switch = View_Mode == 0 && !VM_Blend_R ? VM_Glass_Fill ? VM6_Depth_Step : 3 : View_Mode_Warping;
			#if LBM || LetterBox_Masking
				float LB_Detection = Avr_P(float2(1, 0.0625)).z;
				if(LB_Detection)
					VMW_Switch *= 0.5;
			#endif
			//float, not uint: the half levels (3.5, 4.5, 5.5) were truncated, so steps 4, 6 and 8 repeated 3, 4 and 5.
			float VM_Mip_Cal = VMW_Array[clamp(VMW_Switch, 0, 9)];
			//M0 Full uses the plain level, so the mask reads only run for M1 and M2.
			float VMW = VM_Mip_Cal;
			[branch]
			if(Warping_Masking != 0)
			{
				//Left/Right depth mask from the blurred SBS depth.
				float LR_Depth_Mask = 1 - saturate(Blur_N(texcoord * float2(0.5, 1) + float2(0.5, 0), 2.5).x * 5.0);
				uint ISV_Switch = 3;

				float FadeIO = smoothstep(0, 1, tex2Dlod(SamplerDMN, float4(0, 0, 0, 0)).x);
				if(FPSDFIO > 0)
					ISV_Switch = lerp(ISV_Switch, 6, FadeIO);

				//Smoothing is unmasked, so distortion-prone areas smooth more than calm ones.
				LR_Depth_Mask = smoothstep(Warping_Masking == 2 ? 0.75 : 1, 0,
					tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, ISV_Switch)).x * (1 - LR_Depth_Mask));

				VMW = lerp(VM_Mip_Cal, 0, LR_Depth_Mask.x);
			}
			#if TMD == 1
				VMW = lerp(clamp(VMW, 0, 6.0), 6.0, Basic_UI);
			#else
				VMW = clamp(VMW, 0, 6.0);
			#endif
	
			if(Weapon_Near_Halo_Reduction)
				VMW = lerp(VMW, 9, tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, 9)).x * 0.5);
	
			//Horizontal dilation normally, an isotropic mip read when Pinball mode has swapped the axes.
			bool PinballSwap = Vert_3D_Pinball && !MULTI_VIEW;
			//if, not ?:, which would run both reads.
			float Smoothed;
			[branch]
			if(PinballSwap)
				Smoothed = tex2Dlod(SamplerzBufferN_L, float4(texcoord, 0, VMW)).x;
			else
				Smoothed = DilateH(SamplerzBufferN_L, texcoord, VMW);
			Min_Blend = min(Smoothed, Base_Depth);
		}

		float DepthBuffer_LP = Min_Blend;
		#if !Use_2D_Plus_Depth
			if(View_Mode == 3)
				DepthBuffer_LP = Point_Depth;
		#endif
	
		//TMD text direction UI lift.
		#if TMD
			#if TMD == 1
			#else
				float Text_Direction = texcoord.x < DZ_W.z || texcoord.y < DZ_W.w;
				#if(TMD == 3) // Reverse
					Text_Direction  = 1 - texcoord.x < DZ_W.z || 1 - texcoord.y < DZ_W.w;
				#elif (TMD == 4) // Mirror
					Text_Direction += 1 - texcoord.x < DZ_W.z || 1 - texcoord.y < DZ_W.w;
				#endif
	
				if(DZ_W.x > 0 && Text_Menu_Detection())
				{
					if(Text_Direction)
						DepthBuffer_LP = lerp(DepthBuffer_LP,
							min(DepthBuffer_LP,
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
			if(Stencil_n_Detection_A())
				DepthBuffer_LP = lerp(DepthBuffer_LP, UI_A_Mask_Depth,
					Stencil_Masking(texcoord, UI_A_Mask_Pos, UI_A_Mask_Size, DDD_W.z, SSA));
		#endif
		#if SUI >= 2
			float2 UI_B_Mask_Pos   = 1 - DEE_Y.zw;
			float  UI_B_Mask_Depth = (DEE_W.w < 0.5) ? DEE_W.w : Stencil_Sampler(float3(1 - UI_B_Mask_Pos, DEE_W.w));
			float2 UI_B_Mask_Size  = DEE_W.xy;
			if(Stencil_n_Detection_B())
				DepthBuffer_LP = lerp(DepthBuffer_LP, UI_B_Mask_Depth,
					Stencil_Masking(texcoord, UI_B_Mask_Pos, UI_B_Mask_Size, DEE_W.z, SSB));
		#endif
		#if SUI >= 3
			float2 UI_C_Mask_Pos   = 1 - DFF_Y.zw;
			float  UI_C_Mask_Depth = (DFF_W.w < 0.5) ? DFF_W.w : Stencil_Sampler(float3(1 - UI_C_Mask_Pos, DFF_W.w));
			float2 UI_C_Mask_Size  = DFF_W.xy;
			if(Stencil_n_Detection_C())
				DepthBuffer_LP = lerp(DepthBuffer_LP, UI_C_Mask_Depth,
					Stencil_Masking(texcoord, UI_C_Mask_Pos, UI_C_Mask_Size, DFF_W.z, SSC));
		#endif
		#if SUI >= 4
			float2 UI_D_Mask_Pos   = 1 - DGG_Y.zw;
			float  UI_D_Mask_Depth = (DGG_W.w < 0.5) ? DGG_W.w : Stencil_Sampler(float3(1 - UI_D_Mask_Pos, DGG_W.w));
			float2 UI_D_Mask_Size  = DGG_W.xy;
			if(Stencil_n_Detection_D())
				DepthBuffer_LP = lerp(DepthBuffer_LP, UI_D_Mask_Depth,
					Stencil_Masking(texcoord, UI_D_Mask_Pos, UI_D_Mask_Size, DGG_W.z, SSD));
		#endif
		#if SUI >= 5
			float2 UI_E_Mask_Pos   = 1 - DJJ_Y.zw;
			float  UI_E_Mask_Depth = (DJJ_W.w < 0.5) ? DJJ_W.w : Stencil_Sampler(float3(1 - UI_E_Mask_Pos, DJJ_W.w));
			float2 UI_E_Mask_Size  = DJJ_W.xy;
			if(Stencil_n_Detection_E())
				DepthBuffer_LP = lerp(DepthBuffer_LP, UI_E_Mask_Depth,
					Stencil_Masking(texcoord, UI_E_Mask_Pos, UI_E_Mask_Size, DJJ_W.z, SSE));
		#endif
		#if SUI >= 6
			float2 UI_F_Mask_Pos   = 1 - DLL_Y.zw;
			float  UI_F_Mask_Depth = (DLL_W.w < 0.5) ? DLL_W.w : Stencil_Sampler(float3(1 - UI_F_Mask_Pos, DLL_W.w));
			float2 UI_F_Mask_Size  = DLL_W.xy;
			if(Stencil_n_Detection_F())
				DepthBuffer_LP = lerp(DepthBuffer_LP, UI_F_Mask_Depth,
					Stencil_Masking(texcoord, UI_F_Mask_Pos, UI_F_Mask_Size, DLL_W.z, SSF));
		#endif
	
		float Separation        = lerp(1.0, 5.0, Depth_Seperation());
		float Boost_Range_Depth = DepthBuffer_LP;
		float Pop_Adjust        = saturate(DI_Y);
		float Max_Clamp         = (Pop_Adjust > 0) ? 5.0 : 2.5;
	
		//Boost Mode (from 2018): nonlinear mid depth pop.
		if(Pop_Adjust > 0)
		{
			float2 Clamp_Near     = max(0, float2(N_P0, DepthBuffer_LP));
			float  Mid_Point      = (Clamp_Near.y > 0.5) ? Clamp_Near.x : Clamp_Near.y;
			float  RCP_Diverge    = saturate(0.01 * Divergence_Switch().y);
			float  Cal_Power_Blend = lerp(1.75, 1.25, RCP_Diverge);
	
			Boost_Range_Depth = lerp(DepthBuffer_LP * 2 - 1, DepthBuffer_LP * 3 - 1.5, Mid_Point * 0.25 + 0.25);
			Boost_Range_Depth = lerp(DepthBuffer_LP,         Boost_Range_Depth * 0.5 + 0.5, Clamp_Near.y);
			Boost_Range_Depth = lerp(DepthBuffer_LP,         Boost_Range_Depth,             Clamp_Near.y * 0.5 + 0.5);
			Boost_Range_Depth = lerp(DepthBuffer_LP,         Boost_Range_Depth,             Cal_Power_Blend * Pop_Adjust);
		}
	
		return clamp(Separation * Boost_Range_Depth * Smooth_Tune_Boost(), -1.5, Max_Clamp);
	}

	//The mix's scaling on the point depth, without the warp smoothing that smears thin objects.
	//Linear_X is Linear's x, N_P0 its y, at one texel.
	float Orig_Depth_DN(float Linear_X, float N_P0)
	{
		float Separation        = lerp(1.0, 5.0, Depth_Seperation());
		float Boost_Range_Depth = Linear_X;
		float Pop_Adjust        = saturate(DI_Y);
		float Max_Clamp         = (Pop_Adjust > 0) ? 5.0 : 2.5;
		if(Pop_Adjust > 0)
		{
			float2 Clamp_Near      = max(0, float2(N_P0, Linear_X));
			float  Mid_Point       = (Clamp_Near.y > 0.5) ? Clamp_Near.x : Clamp_Near.y;
			float  RCP_Diverge     = saturate(0.01 * Divergence_Switch().y);
			float  Cal_Power_Blend = lerp(1.75, 1.25, RCP_Diverge);
			Boost_Range_Depth = lerp(Linear_X * 2 - 1, Linear_X * 3 - 1.5, Mid_Point * 0.25 + 0.25);
			Boost_Range_Depth = lerp(Linear_X, Boost_Range_Depth * 0.5 + 0.5, Clamp_Near.y);
			Boost_Range_Depth = lerp(Linear_X, Boost_Range_Depth, Clamp_Near.y * 0.5 + 0.5);
			Boost_Range_Depth = lerp(Linear_X, Boost_Range_Depth, Cal_Power_Blend * Pop_Adjust);
		}
		return clamp(Separation * Boost_Range_Depth * Smooth_Tune_Boost(), -1.5, Max_Clamp);
	}

	//The original depth at this texel
	float Orig_Depth(float2 texcoord)
	{
		return Orig_Depth_DN(Point_L(texcoord), Corner_L(texcoord));
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
		float TCX_S = min(tc.x, 1 - tc.x);
		float TCY_S = min(tc.y, 1 - tc.y);
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
		#if !DX9_DX10_Toggle
			float2 Depth_Size = rcp_Depth_Size();
			
			
			[branch]
			if(ASA_On && AR_Is != 2)
			{
				float  SD = Blur_N(float2(0, 0.8125), 0).x;//The Blur pass's free slot.
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
			float LB_Detection = Avr_P(float2(1,0.0625)).z,LB_Masked = LB_Dir > Cal_LB_Mask.y && LB_Dir < Cal_LB_Mask.x ? MixOut : 0.0125;
			
			if(LB_Detection)
				MixOut = LB_Masked;
		#endif
		
		#if !WHM
		if(Alpha_Channel_UI)
		{        
			float Store_MixOut = MixOut;
			float2 FPS_Alpha_UI = 0, TRD_Alpha_UI = 0;
			float Avg_UI = saturate(smoothstep(0.25, 1, (1 - Blur_Ex(float2(0.5, 0.5)).y) * 4) * 2);
		
			float Game_Alpha_UI, Game_Alpha_UI_M;
			float Alpha_UI = Alpha_UI_Mask(texcoord, 0);
		    	  Alpha_UI = min(Alpha_UI,Alpha_UI_Mask(texcoord, 1.0));
	
			float Low_Rez_Depth    = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, 5 )).x;
			float OA_Power         = saturate(abs(Divergence_Switch().y) * 0.01);
			float Alpha_Letter_Box = Alpha_UI_Has_LB == 0 ? 1 : LetterBox_UI(texcoord);
			float Alpha_UI_Depth   = ASU; // 0 - 1
			float Controller_RT    = saturate(Gamepad(5).y * 2);
		
			if(1 - Alpha_UI > 0.0)
			{
				//Common values.
				float texcoord_x_mirror = min(texcoord.x, 1 - texcoord.x);
				float texcoord_y_mirror = min(texcoord.y, 1 - texcoord.y);
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
		
				//Local modes 1, 4, 5, 7, 9, 10, 11, 12, 13, 14
				if(Alpha_Auto_UI == 1  || Alpha_Auto_UI == 4 || Alpha_Auto_UI == 5 ||
		           Alpha_Auto_UI == 7  || Alpha_Auto_UI == 9 || Alpha_Auto_UI == 10 || Alpha_Auto_UI == 11 || Alpha_Auto_UI == 12 || Alpha_Auto_UI == 13 ||
		           Alpha_Auto_UI == 14)
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
					else if(Alpha_Auto_UI == 14)//Local-Depth2, Local-Depth with a lower coarse level and a deeper near floor
					{
						Scale_FPS_Dist_B = 0.5;
						mipFine = lerp(mipFine, 2.0, Avg_UI_doubled);
					}
					else
					{
						mipFine = lerp(mipFine, 2.0, Avg_UI_doubled);
					}
		
					float CoarseCenter = smoothstep(-1.0, 2.0, tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipCoarse)).x);
					float FineCenter   = tex2Dlod(SamplerAvrB_N, float4(texcoord, 0, mipFine)).x;
		
					float BlendOut = lerp(Alpha_Auto_UI == 14 ? -0.5 : -0.325, Scale_FPS_Dist_B, CoarseCenter);
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
		
				//Guided modes 3, 4, 15
				if(Alpha_Auto_UI == 3 || Alpha_Auto_UI == 4 || Alpha_Auto_UI == 15)
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
		                                     : float2(Alpha_Auto_UI == 15 ? lerp(-0.25, 0.75, Low_Rez_Depth) : lerp(-0.125, 0.125, Low_Rez_Depth), 1.0);//Guided-Depth2 has lower near and higher far floors
		
					float Tuning_Value = Alpha_Auto_UI == 4 ? -0.05 * texcoord.y : 0.0;
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
		                                          smoothstep(0.75, 0.5, max(texcoord.y, 1 - texcoord.y)) * 2);
		
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
		
					float FPS_Area_S = smoothstep(S_Mask, 0.5, min(texcoord.x, 1 - texcoord.x));
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
	
					float FPS_Area_S = smoothstep(S_Mask, 0.5, min(texcoord.x, 1 - texcoord.x));
		                  FPS_Area_S = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, FPS_Area_S) *
		                                        smoothstep(0.75, 0.5, texcoord.y > 0.5
		                                            ? smoothstep(-0.5, 1.75, texcoord.y)
		                                            : smoothstep(0.125, 1.75, 1 - texcoord.y)));
	
					float Local_10  = lerp(Local, lerp(Local, Store_MixOut, S_UI_10), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
					float MixOut_10 = lerp(Guided, lerp(Guided, Local_10, FPS_Area_S), Avg_UI);
	
					float EdgeCenter = 0.5 * min(texcoord_x_mirror, texcoord_y_mirror);
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
	
					float FPS_Area_S = smoothstep(S_Mask, 0.5, min(texcoord.x, 1 - texcoord.x));
		                  FPS_Area_S = saturate(smoothstep(C_UI_Value_A * 0.5, C_UI_Value_A, FPS_Area_S) *
		                                        smoothstep(0.75, 0.5, texcoord.y > 0.5
		                                            ? smoothstep(-0.5, 1.75, texcoord.y)
		                                            : smoothstep(0.125, 1.75, 1 - texcoord.y)));
	
					float Local_9  = lerp(Local, lerp(Local, Store_MixOut, S_UI_9), Vin_Alpha_UI(texcoord, Low_Rez_Depth, 0));
					float MixOut_9 = lerp(Guided, lerp(Guided, Local_9, FPS_Area_S), Avg_UI);
	
					float EdgeCenter = 0.5 * min(texcoord_x_mirror, texcoord_y_mirror);
					MixOut = lerp(MixOut_8, MixOut_9, EdgeCenter);
				}
		
				//Post processing.
				if(Bound_UI > 0)
					MixOut = max(-(1 - Bound_UI), MixOut);
		
				MixOut = lerp(Store_MixOut, MixOut, Alpha_Letter_Box);
		
				if(Read_Controller_AUI)
					Avg_UI = lerp(Avg_UI, 1.0, Controller_RT);
		
				if(Alpha_Auto_UI <= 3 || Alpha_Auto_UI >= 14)
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

				#if !DX9_DX10_Toggle
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
		#if GDM_DEPTH_AUTOFIT
		//GDM fit: fill the empty bars outside the depth box with 0.0625, after Alpha UI. The box grows 2 depth px.
		float2 Box = GDM_Box(), Box_Half = Box * 0.5 + 2.0 * pix / Depth_Rez * (Box < 0.996);
		if(any(abs(texcoord - 0.5) > Box_Half))
			MixOut = 0.0625;
		#endif
	}

	//Up and down at any step, so tops and tips survive TAA jitter.
	static const bool Vert_Dilate = true;
	static const float DS_Side_Texels = 1.0, DS_Side_Tuned = 2.0;
	static const float Recon_Step_0 = 1.25, Recon_Step_1 = 1.5, Recon_Step_2 = 1.75;
	#define Recon_Step (Reconstruction_Size == 2 ? Recon_Step_2 : Reconstruction_Size == 1 ? Recon_Step_1 : Recon_Step_0)

	//AA runs on the raw depth, then DepthSmoothPS dilates it.
	#if DX9_DX10_Toggle
		#define AA_Src_P SamplerzBufferB_Smooth //Reads texel centres only.
		#define AA_Src_B SamplerzBufferB_Smooth
	#else
		#define AA_Src_P SamplerzBufferP_Up
		#define AA_Src_B SamplerzBufferB_Up
	#endif
	//DX9 and DX10 read it with Point_Mixed.
	#if !DX9_DX10_Toggle
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
	
	//Side window Gaussian of the depth for Depth AA
	float Side_Window_Gauss(sampler Tex, float2 tc)
	{
		float2 Tx = rcp_Depth_Size();
#if DX9_DX10_Toggle
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

	#if !DX9_DX10_Toggle
	#define Current_Buffer SamplerzBufferP_Mixed

	//Edge line. Thr is on depth*0.5+0.5.
	static const int Line_Walk_Max = 32;
	static const float Line_Thr = 0.02;

	//Gather around tc + O texels.
	float4 Line_G(sampler Tex, float2 tc, float2 Tb, float2 O)
	{
		return tex2DgatherR(Tex, clamp(tc + O * Tb, Tb, 1 - Tb));
	}

	//Gather order: w top left, z top right, x bottom left, y bottom right.
	float Line_Pick(float4 G, float2 o)
	{
		return o.y < 0 ? (o.x < 0 ? G.w : G.z) : (o.x < 0 ? G.x : G.y);
	}

	//Depth at P, the min with the texels left and right.
	float Line_W(sampler Tex, float2 P, float2 Tb)
	{
		float2 E = float2(Tb.x, 0);
		float C = tex2Dlod(Tex, float4(clamp(P, Tb, 1 - Tb), 0, 0)).x;
		float L = tex2Dlod(Tex, float4(clamp(P - E, Tb, 1 - Tb), 0, 0)).x, R = tex2Dlod(Tex, float4(clamp(P + E, Tb, 1 - Tb), 0, 0)).x;
		return min(min(L, C), R);
	}

	//The other side of the edge.
	bool Line_Other(float T, float Mid, bool Far)
	{
		return Far ? T < Mid : T > Mid;
	}

	//Column j, rows k and k+1 toward the other side.
	float2 Line_Pair(sampler Tex, float2 tc, float2 Tb, float2 Al, float2 Ac, float j, float k)
	{
		float2 R;
		[branch]
		if(Al.x != 0)
		{
			//Widening along the edge.
			float4 A = Line_G(Tex, tc, Tb, Al * (j - 0.5) + Ac * (k + 0.5)), B = Line_G(Tex, tc, Tb, Al * (j + 0.5) + Ac * (k + 0.5));
			R.x = min(min(Line_Pick(A, -0.5 * Al - 0.5 * Ac), Line_Pick(A, 0.5 * Al - 0.5 * Ac)), Line_Pick(B, 0.5 * Al - 0.5 * Ac));
			R.y = min(min(Line_Pick(A, -0.5 * Al + 0.5 * Ac), Line_Pick(A, 0.5 * Al + 0.5 * Ac)), Line_Pick(B, 0.5 * Al + 0.5 * Ac));
		}
		else
		{
			//Widening across the edge.
			float4 A = Line_G(Tex, tc, Tb, Al * (j + 0.5) + Ac * (k - 0.5)), B = Line_G(Tex, tc, Tb, Al * (j + 0.5) + Ac * (k + 1.5));
			float Lo = Line_Pick(A, -0.5 * Al - 0.5 * Ac), Hi = Line_Pick(A, -0.5 * Al + 0.5 * Ac);
			float K1 = Line_Pick(B, -0.5 * Al - 0.5 * Ac), K2 = Line_Pick(B, -0.5 * Al + 0.5 * Ac);
			R = float2(min(min(Lo, Hi), K1), min(min(Hi, K1), K2));
		}
		return R;
	}

	//The run goes on at step j.
	bool Line_Run(sampler Tex, float2 tc, float2 Tb, float2 Al, float2 Ac, float Mid, bool Far, float j)
	{
		float2 R = Line_Pair(Tex, tc, Tb, Al, Ac, j, 0);
		return !Line_Other(R.x, Mid, Far) && Line_Other(R.y, Mid, Far);
	}

	//Walks to the run's end. x = length, y = end: 0 none, 1 in, 2 away, 3 corner.
	float2 Line_Walk(sampler Tex, float2 tc, float2 Tb, float2 Al, float2 Ac, float Mid, bool Far)
	{
		float J = 0;
		[loop]
		for(int j = 4; j <= Line_Walk_Max; j += 4)
		{
			if(!Line_Run(Tex, tc, Tb, Al, Ac, Mid, Far, j))
			{
				J = j;
				break;
			}
		}
		float2 Walk = float2(Line_Walk_Max, 0);
		if(J != 0)
		{
			[loop]
			for(int r = 3; r > 0; r--)
			{
				if(!Line_Run(Tex, tc, Tb, Al, Ac, Mid, Far, J - r))
				{
					J -= r;
					break;
				}
			}
			//A stair steps 1 or 2 texels, a corner keeps going.
			float2 E = tc + Al * J * Tb;
			bool In = Line_Other(Line_W(Tex, E, Tb), Mid, Far);
			float2 Back = In ? -Ac : 2 * Ac;
			bool S1 = Line_Other(Line_W(Tex, E + Back * Tb, Tb), Mid, Far), S2 = Line_Other(Line_W(Tex, E + (Back + (In ? -Ac : Ac)) * Tb, Tb), Mid, Far);
			bool Stair = In ? (!S1 || !S2) : (S1 || S2);
			Walk = float2(J - 1, Stair ? (In ? 1 : 2) : 3);
		}
		return Walk;
	}

	//Long steps: the run between two small steps gives the line.
	float Line_Long(sampler Tex, float2 tc, float2 Tb, float2 Al, float2 Ac, float Mid, bool Far)
	{
		float2 Rt = Line_Walk(Tex, tc, Tb, Al, Ac, Mid, Far);
		float Cov = 0;
		[branch]
		if(Rt.y == 1 || Rt.y == 2)
		{
			float2 Lt = Line_Walk(Tex, tc, Tb, -Al, Ac, Mid, Far);
			float D_In = Rt.y == 1 ? Rt.x : Lt.x;
			if(Lt.y == 3 - Rt.y)
				Cov = saturate(0.5 - (D_In + 0.5) * rcp(Rt.x + Lt.x + 1));
		}
		return Cov;
	}

	//Blends depth stairs to a line through their middles. Background fills, objects thin.
	float Line_Blend(sampler Tex, float2 tc, float C, float4 TL)
	{
		float Out = C;
		float2 Tb = rcp(tex2Dsize(Tex, 0));
		float4 BR = Line_G(Tex, tc, Tb, 0.5), TR = Line_G(Tex, tc, Tb, float2(0.5, -0.5)), BL = Line_G(Tex, tc, Tb, float2(-0.5, 0.5));
		//Rows or columns, as FXAA picks it.
		float Hz = abs(0.25 * TL.w - 0.5 * TL.x + 0.25 * BL.x) + abs(0.5 * TL.z - TL.y + 0.5 * BR.x) + abs(0.25 * TR.z - 0.5 * BR.z + 0.25 * BR.y);
		float Vt = abs(0.25 * TL.w - 0.5 * TL.z + 0.25 * TR.z) + abs(0.5 * TL.x - TL.y + 0.5 * BR.z) + abs(0.25 * BL.x - 0.5 * BR.x + 0.25 * BR.y);
		//The widened neighbours.
		float L2 = tex2Dlod(Tex, float4(clamp(tc - float2(2 * Tb.x, 0), Tb, 1 - Tb), 0, 0)).x, R2 = tex2Dlod(Tex, float4(clamp(tc + float2(2 * Tb.x, 0), Tb, 1 - Tb), 0, 0)).x;
		float4 Around = float4(min(min(TL.w, TL.z), TR.z), min(min(BL.x, BL.y), BR.y), min(min(L2, TL.x), TL.y), min(min(TL.y, TR.y), R2));
		bool H = Hz >= Vt;
		float2 Al = H ? float2(1, 0) : float2(0, 1), A2 = H ? Around.xy : Around.zw;
		//The side with the bigger jump.
		bool First = abs(C - A2.x) >= abs(C - A2.y);
		float A = First ? A2.x : A2.y;
		float2 Ac = (First ? -1 : 1) * Al.yx;
		float Dn = 0.5 * rcp(max(abs(min(C, A) * 0.5 + 0.5), AA_Floor));
		[branch]
		if(abs(C - A) * Dn > Line_Thr)
		{
			bool Far = C > A;
			float V = lerp(C, A, Line_Long(Tex, tc, Tb, Al, Ac, (C + A) * 0.5, Far));
			Out = Far ? min(C, V) : max(C, V);
		}
		return Out;
	}

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
		//Vulkan: new textures are not cleared, NaN history.
		Acc = float2(NaN_Guard(Acc.x, sceneDepth), NaN_Guard(Acc.y, sceneDepth));
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
		//Up, left, right, down. One real texel is one buffer texel here, so gathers hold them.
		float2 T_Sz = tex2Dsize(Current_Buffer, 0), T_Tx = rcp(T_Sz);
		float4 Cross, Orig_X;
		float Orig_C;
		[branch]
		if(all(abs(texelSize * T_Sz - 1.0) < 0.01))
		{
			float4 Gath_A = tex2DgatherR(Current_Buffer, texcoord - 0.5 * T_Tx), Gath_B = tex2DgatherR(Current_Buffer, texcoord + 0.5 * T_Tx);
			float4 Lin_A = tex2DgatherR(SamplerzBufferN_L, texcoord - 0.5 * T_Tx), Lin_B = tex2DgatherR(SamplerzBufferN_L, texcoord + 0.5 * T_Tx),
	               NP_A = tex2DgatherG(SamplerzBufferN_L, texcoord - 0.5 * T_Tx), NP_B = tex2DgatherG(SamplerzBufferN_L, texcoord + 0.5 * T_Tx);
			Cross  = float4(Gath_A.z, Gath_A.x, Gath_B.z, Gath_B.x);
			Orig_C = Orig_Depth_DN(Lin_A.y, NP_A.y);
			Orig_X = float4(Orig_Depth_DN(Lin_A.z, NP_A.z), Orig_Depth_DN(Lin_A.x, NP_A.x), Orig_Depth_DN(Lin_B.z, NP_B.z), Orig_Depth_DN(Lin_B.x, NP_B.x));
		}
		else
		{
			SD_UNROLL
			for (int c = 0; c < 4; c++)
			{
				float2 Ofs = offsets[c * 2 + 1] * texelSize;
				Cross[c]  = tex2Dlod(Current_Buffer, float4(texcoord + Ofs, 0, 0)).x;
				Orig_X[c] = Orig_Depth(texcoord + Ofs);
			}
			Orig_C = Orig_Depth(texcoord);
		}
		//Motion.
		float Orig_Min = min(Orig_C, min(min(Orig_X.x, Orig_X.y), min(Orig_X.z, Orig_X.w))),
	          Orig_Max = max(Orig_C, max(max(Orig_X.x, Orig_X.y), max(Orig_X.z, Orig_X.w)));
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
		for (int i = 0; i < 4; ++i)
		{
			float neighborDepth = Cross[i];
			//One sided: a nearer neighbour always agrees.
			float neighborDiff = neighborDepth - sceneDepth;
			minFbC = min(minFbC, neighborDepth);
			maxFbC = max(maxFbC, neighborDepth);
			if (neighborDiff <= Threshold)
			{
				minC = min(minC, neighborDepth);
				maxC = max(maxC, neighborDepth);
	            ++vCountC;
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

	float Min3x3(sampler2D Tex, float2 TC, float2 Depth_Size, out float2 Grad, out float Range, out float Mid)
	{
		//Round, the corners sit as far out as the sides
		static const float2 offsets[9] = { float2(-0.70710678, -0.70710678), float2( 0, -1), float2( 0.70710678, -0.70710678),
										   float2(-1,  0), float2( 0,  0), float2( 1,  0),
										   float2(-0.70710678,  0.70710678), float2( 0,  1), float2( 0.70710678,  0.70710678) };
		float v[9];
		float minVal = 1e10, maxVal = -1e10;
		SD_UNROLL
		for (int i = 0; i < 9; i++)
		{
			v[i] = tex2Dlod(Tex, float4(TC + offsets[i] * Depth_Size, 0, 0)).x;
			minVal = min(minVal, v[i]);
			maxVal = max(maxVal, v[i]);
		}
		Range = maxVal - minVal;
		Mid = v[4];

		//Slope for the ramp's tilt
		Grad = float2((v[2] + v[5] + v[8]) - (v[0] + v[3] + v[6]),
					  (v[6] + v[7] + v[8]) - (v[0] + v[1] + v[2]));
		return minVal;
	}

	float Disocclusion(sampler Tex, float2 texcoord, float2 DPix, out float D_Min, out float D_Ramp, out float Range, out float Own) // Non_Point_Sampler
	{
		float Recon_Size = Recon_Step;

		float2 Grad;
		float Depth = Min3x3(Tex, texcoord, DPix * Recon_Size, Grad, Range, Own), DM = 0.0f;
		D_Min = Depth;
		D_Ramp = Depth;

		const int N = 8;
		const float2 dir = float2(0.5f, 0.0f);
		const float MS = abs(Divergence_Switch().y) * 0.0005, Disocclusion_Adjust = 5.5f, Div = rcp(N + 1);
		const float weight[N] = { 0.0125f,-0.0125f, 0.0175f,-0.0175f, 0.03f, -0.03f, 0.05f,-0.05f };
		//Tilt follows slanted edges
		float Tilt = clamp(-Grad.x * Grad.y * rcp(Grad.y * Grad.y + 1e-4), -0.35f, 0.35f);
		if(View_Mode != 3)
		{
			DM = Depth * Div;

			float2 Ob = float2(dir.x, dir.x * Tilt) * (MS * Disocclusion_Adjust);
			SD_UNROLL
			for (int i = 0; i < N; i++)
				DM += tex2Dlod(Tex, float4(texcoord + Ob * weight[i], 0, 1)).x * Div;//Mip 1 keeps thin objects.

			D_Ramp = DM;
			return min(DM, Depth);
		}
		else
			return Depth;
	}

	void ReconstructionPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float Recon : SV_Target0)
	{
		//Widening and ramp
		float D_Min, D_Ramp, Range, Own;
		Recon = Disocclusion(R_Sampler, texcoord, rcp_Depth_Size(), D_Min, D_Ramp, Range, Own);
		float Ramp_Gap = D_Min - D_Ramp;

		//Smooth edges, the texels just outside the widening too
		[branch]
		if(View_Mode != 3 && (Range > 0.0005 || Ramp_Gap > 0.0005))
		{
			float2 Tx = rcp_Depth_Size();
			float2 St = Tx * Recon_Step * 2.0;
			float  eL = tex2Dlod(R_Sampler, float4(texcoord - float2(St.x, 0), 0, 0)).x, eR = tex2Dlod(R_Sampler, float4(texcoord + float2(St.x, 0), 0, 0)).x;
			float  eU = tex2Dlod(R_Sampler, float4(texcoord - float2(0, St.y), 0, 0)).x, eD = tex2Dlod(R_Sampler, float4(texcoord + float2(0, St.y), 0, 0)).x;
			float  Rng = max(max(max(eL, eR), max(eU, eD)), Own) - min(min(min(eL, eR), min(eU, eD)), Own);
			float2 Eg  = float2(eR - eL, eD - eU);
			float  El  = length(Eg);
			//Thin features are not smoothed
			bool   Ridge = Own < min(eL, eR) - 0.001 || Own < min(eU, eD) - 0.001;
			float  Edg = saturate(Rng * rcp(max(abs(Recon), AA_Floor) * AA_Scale));
			[branch]
			if(Rng > 0.0005 && El > 0.000001 && !Ridge && Edg > AA_Skip)
			{
				//Two more along the edge, a cross min each with the centre's ramp.
				float2 Tn = float2(-Eg.y, Eg.x) * rcp(El) * Tx * AA_PO.x, Step_UV = Tx * Recon_Step;
				float  Rp = 0;
				#if ISOGL
				[loop]
				#else
				[unroll]
				#endif
				for(int s = 0; s < 2; s++)
				{
					float2 Side_UV = texcoord + (s == 0 ? Tn : -Tn);
					float  Tap_C = tex2Dlod(R_Sampler, float4(Side_UV, 0, 0)).x,
						   Tap_L = tex2Dlod(R_Sampler, float4(Side_UV - float2(Step_UV.x, 0), 0, 0)).x, Tap_R = tex2Dlod(R_Sampler, float4(Side_UV + float2(Step_UV.x, 0), 0, 0)).x,
						   Tap_U = tex2Dlod(R_Sampler, float4(Side_UV - float2(0, Step_UV.y), 0, 0)).x, Tap_D = tex2Dlod(R_Sampler, float4(Side_UV + float2(0, Step_UV.y), 0, 0)).x;
					Rp += min(min(min(Tap_C, min(Tap_L, Tap_R)), min(Tap_U, Tap_D)), D_Ramp);
				}
				Recon = lerp(Recon, (Recon + Rp * AA_PW.x) * rcp(1.0 + 2.0 * AA_PW.x), Edg);
			}
		}
	}

	void DepthSmoothPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Smooth : SV_Target0
	#if Anti_Jitter_Mode
	, out float2 Acc : SV_Target1
	#endif
	)
	{
		#if Anti_Jitter_Mode
		//TAA's history for the next frame. TAA has read the old one by now, so it is written here, not in a pass of its own.
		//G is Orig_Depth. Mode 1 never reads it.
		float TAA_Now = tex2Dlod(SamplerzBufferP_TAA, float4(texcoord, 0, 0)).x;
		#if Anti_Jitter_Mode == 1
		Acc = float2(TAA_Now, 0);
		#else
		Acc = float2(TAA_Now, Orig_Depth(texcoord));
		#endif
		#endif
		//Sideways exactly 1 texel, up and down half of Depth_Set_Size.
		float2 DPix = rcp_Depth_Size() * float2(DS_Side_Texels, Depth_Set_Size * 0.5);

		//Half a DS_Src texel, so the 2x2 block is the same at every Depth_Rez.
		float4 Near = tex2DgatherR(DS_Src, texcoord - 0.5 * rcp(float2(BUFFER_WIDTH, BUFFER_HEIGHT) * Depth_Rez));
		//The block's bottom right texel is this pixel's own, so no separate read.
		float Center = Near.y;
		float MinNear = min(min(Near.x, Near.y), min(Near.z, Near.w));

		float L, R, U, D;
		//The taps land on the next texels: Near has left and up, one more gather has right and down.
		float2 DS_Sz = tex2Dsize(DS_Src, 0), DS_Ofs = DPix * DS_Sz;
		[branch]
		if(all(DS_Ofs > 0.53) && all(DS_Ofs < 1.47))
		{
			float4 Far = tex2DgatherR(DS_Src, texcoord + 0.5 * rcp(DS_Sz));
			L = Near.x; U = Near.z; R = Far.z; D = Far.x;
		}
		else
		{
			L = tex2Dlod(DS_Src, float4(texcoord - float2(DPix.x, 0), 0, 0)).x;
			R = tex2Dlod(DS_Src, float4(texcoord + float2(DPix.x, 0), 0, 0)).x;
			U = tex2Dlod(DS_Src, float4(texcoord - float2(0, DPix.y), 0, 0)).x;
			D = tex2Dlod(DS_Src, float4(texcoord + float2(0, DPix.y), 0, 0)).x;
		}
	
		float Smoothed;
	    
		//Per axis, edge preserving.
		{
			float InvCenter = rcp(max(abs(Center), 0.001));
			float EdgeH = abs(R - L) * InvCenter;
			float EdgeV = abs(D - U) * InvCenter;
	
			float MinH = min(L, R);
			float MinV = min(U, D);
	
			float DepthRange = 0.05 * abs(Center);
			float RejectV    = step(abs(MinV    - Center), DepthRange);
			float RejectNear = step(abs(MinNear - Center), DepthRange);
	
			Smoothed = Center;
			Smoothed = lerp(Smoothed, min(Smoothed, MinH),    saturate(EdgeH * 25.0));
			Smoothed = lerp(Smoothed, min(Smoothed, MinV),    saturate(EdgeV * 25.0) * RejectV);
			Smoothed = lerp(Smoothed, min(Smoothed, MinNear), saturate(EdgeH * EdgeV * 625.0) * RejectNear);
			//No Vert_Dilate here: Reconstruction's Min3x3 covers up and down. DX9 and DX10 keep it.
		}

		//Edge line on the widening's shape.
		float Aa = Line_Blend(DS_Src, texcoord, Smoothed, Near);
		//Stamped: hard depth in R, edge AA in G.
		Smooth = View_Mode == 3 ? float2(Smoothed, Aa) : Aa.xx;
	}
	#endif
	
	#if DX9_DX10_Toggle
	//Disocclusion() for DX9 and DX10.
	void ReconstructionDX9_DX10PS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float Recon : SV_Target0)
	{
		float2 T1 = rcp_Depth_Size();
		float2 M3 = T1 * Recon_Step;
		float v[9];
		float Depth = 1e10;
		SD_UNROLL
		for(int k = 0; k < 9; k++)
		{
			//Round: the corners sit as far out as the sides
			v[k] = Point_Mixed(texcoord + float2(k % 3 - 1, k / 3 - 1) * (k % 2 == 0 && k != 4 ? 0.70710678 : 1.0) * M3).x;
			Depth = min(Depth, v[k]);
		}
		float2 Grad = float2((v[2] + v[5] + v[8]) - (v[0] + v[3] + v[6]),
	                         (v[6] + v[7] + v[8]) - (v[0] + v[1] + v[2]));
		Recon = Depth;
		#if !Use_2D_Plus_Depth //View_Mode is a constant there (see the DX10+ one).
		[branch]
		#endif
		if(View_Mode != 3)
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

	#if DX9_DX10_Toggle //DX9 and DX10 depth smoothing, point taps since SM3 has no gather.
	//R hard depth, G edge AA depth (the same outside Stamped). The weights come from G.
	void DepthSmoothPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float2 Smooth : SV_Target0)
	{
		float2 Center = tex2Dlod(SamplerzBufferB_Mixed, float4(texcoord, 0, 0)).xy;
		float2 DPix = rcp_Depth_Size() * Depth_Set_Size;

		//tex2DgatherR replacement, on texel centres.
		float2 Dt = rcp(float2(BUFFER_WIDTH, BUFFER_HEIGHT) * Depth_Rez);
		float2 N0 = tex2Dlod(SamplerzBufferB_Mixed, float4(texcoord - Dt, 0, 0)).xy;
		float2 N1 = tex2Dlod(SamplerzBufferB_Mixed, float4(texcoord - float2(0, Dt.y), 0, 0)).xy;
		float2 N2 = tex2Dlod(SamplerzBufferB_Mixed, float4(texcoord - float2(Dt.x, 0), 0, 0)).xy;
		float2 N3 = tex2Dlod(SamplerzBufferB_Mixed, float4(texcoord, 0, 0)).xy;
		float2 MinNear = min(min(N0, N1), min(N2, N3));

		float2 L = Point_Mixed(texcoord - float2(DPix.x, 0)).xy;
		float2 R = Point_Mixed(texcoord + float2(DPix.x, 0)).xy;
		float2 U = Point_Mixed(texcoord - float2(0, DPix.y)).xy;
		float2 D = Point_Mixed(texcoord + float2(0, DPix.y)).xy;

		float2 Smoothed;
		//Per axis, edge preserving.
		{
			float InvCenter = rcp(max(abs(Center.y), 0.001));
			float EdgeH = abs(R.y - L.y) * InvCenter;
			float EdgeV = abs(D.y - U.y) * InvCenter;
			float2 MinH = min(L, R);
			float2 MinV = min(U, D);
			float DepthRange = 0.05 * abs(Center.y);
			float RejectV    = step(abs(MinV.y    - Center.y), DepthRange);
			float RejectNear = step(abs(MinNear.y - Center.y), DepthRange);
			Smoothed = Center;
			Smoothed = lerp(Smoothed, min(Smoothed, MinH),    saturate(EdgeH * 25.0));
			Smoothed = lerp(Smoothed, min(Smoothed, MinV),    saturate(EdgeV * 25.0) * RejectV);
			Smoothed = lerp(Smoothed, min(Smoothed, MinNear), saturate(EdgeH * EdgeV * 625.0) * RejectNear);
			if(Vert_Dilate)
			{
				//Read only when used, 2 fewer taps with Vert_Dilate off.
				float2 U1 = tex2Dlod(SamplerzBufferB_Mixed, float4(texcoord - float2(0, rcp(BUFFER_HEIGHT * Depth_Rez)), 0, 0)).xy;
				float2 D1 = tex2Dlod(SamplerzBufferB_Mixed, float4(texcoord + float2(0, rcp(BUFFER_HEIGHT * Depth_Rez)), 0, 0)).xy;
				Smoothed = lerp(Smoothed, min(Smoothed, min(U1, D1)), saturate(abs(D1.y - U1.y) * InvCenter * 25.0));
			}
		}

		Smooth = Smoothed;
	}
	#endif

	//Depth AA pass: raw depth in, texSmooth out.
	void DepthAAPS(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out AA_Type Out : SV_Target0)
	{
		float Center = tex2Dlod(AA_Src_P, float4(texcoord, 0, 0)).x;
		float2 Tx = rcp_Depth_Size();
#if DX9_DX10_Toggle
		float tc = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(    0, -Tx.y)), 0, 0)).x;
		float ml = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(-Tx.x,     0)), 0, 0)).x;
		float mr = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2( Tx.x,     0)), 0, 0)).x;
		float bc = tex2Dlod(AA_Src_B, float4(saturate(texcoord + float2(    0,  Tx.y)), 0, 0)).x;
		//No gather here in DX9 and DX10.
		float Cr = 0.5 * AA_Skip * max(abs(Center), AA_Floor) * AA_Scale;
		[branch]
		if(Center >= min(min(tc, bc), min(ml, mr)) && Center <= max(max(tc, bc), max(ml, mr)) &&
		   abs(tc + bc - 2.0 * Center) <= 2.0 * Cr && abs(ml + mr - 2.0 * Center) <= 2.0 * Cr)
		{
			Out = Center;
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
		//Stamped: hard depth in R for the march, edge AA in G.
		Out = float2(View_Mode == 3 ? Center : res, res);
	}

	#if DX9_DX10_Toggle
		#define M_Read(UV, L) Point_Mixed(UV)
	#else
		#define M_Read(UV, L) tex2Dlod(SamplerzBufferP_Up, float4(UV, 0, L))
	#endif
	
	float2 GetMixed(float2 texcoord, float Mips) //Sensitive Buffer.
	{
		float D;
		bool Snap = View_Mode == 3 || View_Mode == 4;//VM3 and VM4 read point style.
		//Snapped: a Load of the same texel, clamped like the sampler.
		if(Snap && Mips == 0)
		{
			int2 Sz = Smooth_Size;
			D = tex2Dfetch(SamplerzBufferB_Smooth, clamp(int2(texcoord * Sz + 1.0) - 1, 0, Sz - 1)).x;
		}
		else
		{
			if(Snap)
			{
				float2 Sz = Smooth_Size;
				texcoord = (floor(texcoord * Sz) + 0.5) / Sz;
			}
			D = tex2Dlod(SamplerzBufferB_Smooth,float4(texcoord,0,Mips)).x;
		}
		return D;
	}

	#if !Use_2D_Plus_Depth	
	//////////////////////////////////////////////////////////Parallax Generation///////////////////////////////////////////////////////////////////////
	float2 GetMixed_Sel(float2 texcoord, float Mips, bool Snap)
	{
		float D;
		//Snapped: a Load of the same texel, clamped like the sampler.
		if(Snap && Mips == 0)
		{
			int2 Sz = Smooth_Size;
			float2 S = tex2Dfetch(SamplerzBufferB_Smooth, clamp(int2(texcoord * Sz + 1.0) - 1, 0, Sz - 1)).xy;
			D = S.x;
		}
		else
		{
			if(Snap)
			{
				float2 Sz = Smooth_Size;
				texcoord = (floor(texcoord * Sz) + 0.5) / Sz;
			}
			D = tex2Dlod(SamplerzBufferB_Smooth,float4(texcoord,0,Mips)).x;
		}
		return D;
	}

	#define GetMixed_P(TC, M) GetMixed_Sel(TC, M, VM_Snap)
	//Hard depth and edge AA depth of the texel under tc.
	float2 Stamp_RG(float2 tc)
	{
		int2 Sz = Smooth_Size;
		float2 S = tex2Dfetch(SamplerzBufferB_Smooth, clamp(int2(tc * Sz + 1.0) - 1, 0, Sz - 1)).xy;
		return S;
	}
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
		bool   Steady = In && Ap < 0.5 && abs(Mp.a - Dn) < 0.01 && dot(abs(Cn - Mp.rgb), float3(0.299, 0.587, 0.114)) < 0.1 * HDR_WHITE;
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
	//FPS Focus: each eye's divergence after the fade, shared by Con_Values and the scan.
	void Focus_Fade(float D, out float2 DLR, out float FD_Adjust, out float FadeIO)
	{
		FadeIO = Focus_Reduction_Type == 1 ? 1 : smoothstep(0, 1, 1 - Avr_P(float2(0, 0.0625)).z/*stored Fade_in_out*/);
		float FD = D;
		FD_Adjust = 0.2;
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
		DLR = Eye_Fade_Selection == 1 ? float2(D,FD) : Eye_Fade_Selection == 2 ? float2(FD,D) : float2(FD,FD);
	}

	#if !DX9_DX10_Toggle
	//MeshWarp: flat tiles are drawn as moved quads per eye, edges go to the march

	//Mesh draw part, 1 is mesh only and march px are dropped
	static int MW_Part = 0;
	static bool MW_Drop = false;
	//VM5 Blend: where the object that makes a Glass fill sits, its nearness sets the fill's share
	static float MW_Fill_Obj_X = 0.0;

	//Off the tile's plane by more than this in px and the march takes it, 0.5 marches more grass, 1.0 less
	static const float MW_Flat[3] = { 0.875, 0.35, 0.2 };

	//Shift, below zero is pop out like the march
	float MW_Shift(float2 uv)
	{
		return tex2Dlod(SamplerzBufferB_Smooth, float4(uv, 0, 0)).x + Re_Scale_WN().x;
	}

	//Each eye's divergence after the fade, Quad's thirds scale it in Parallax_Mode
	float2 MW_Divergence()
	{
		float D = Eye_Swap ? -Min_Divergence().x : Min_Divergence().x;
		float2 DLR;
		float FD_Adjust, FadeIO;
		Focus_Fade(D, DLR, FD_Adjust, FadeIO);
		return float2(-DLR.x, DLR.y);
	}

	//The tile's 3x3 points, half a tile apart
	float3 MW_Row(float2 Tile_Px, float j)
	{
		const float Half = MW_TILE * 0.5;
		return float3(MW_Shift((Tile_Px + float2(0, j * Half)) * pix),
					  MW_Shift((Tile_Px + float2(Half, j * Half)) * pix),
					  MW_Shift((Tile_Px + float2(2 * Half, j * Half)) * pix));
	}

	//Tiles: how far off its plane each tile bends, and its smallest and largest shift
	float4 MW_Tile_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		float2 Tile_Px = floor(position.xy) * MW_TILE;

		//Without the mesh only the march's jump reads the tile, so just the smallest shift
		[branch]
		if(!MW_MESH_RUN)
		{
			float2 Size_N = Smooth_Size, Scale_N = Size_N * pix;
			int2 First_N = int2(floor((Tile_Px - 1.0) * Scale_N)), End_N = int2(ceil((Tile_Px + MW_TILE + 1.0) * Scale_N));
			//Last gather each way
			int2 Last_N = First_N + 2 * ((End_N - First_N - 1) / 2);
			float Min_N = 1e4;
			[loop]
			for(int y = First_N.y; y < End_N.y; y += 2)
			{
				//Rows of 5 gathers
				[branch]
				if(Last_N.x - First_N.x <= 8)
				{
					[unroll]
					for(int i = 0; i < 5; i++)
					{
						float4 Gath = tex2DgatherR(SamplerzBufferB_Smooth, (float2(min(First_N.x + 2 * i, Last_N.x), y) + 1.0) / Size_N);
						Min_N = min(Min_N, min(min(Gath.x, Gath.y), min(Gath.z, Gath.w)));
					}
				}
				else
				{
					[loop]
					for(int x = First_N.x; x < End_N.x; x += 2)
					{
						float4 Gath = tex2DgatherR(SamplerzBufferB_Smooth, (float2(x, y) + 1.0) / Size_N);
						Min_N = min(Min_N, min(min(Gath.x, Gath.y), min(Gath.z, Gath.w)));
					}
				}
			}
			Min_N += Re_Scale_WN().x;
			return float4(0.0, Min_N, Min_N, 1.0);
		}

		#if MW_TILE >= 16
		float3 Row_0 = MW_Row(Tile_Px, 0), Row_1 = MW_Row(Tile_Px, 1), Row_2 = MW_Row(Tile_Px, 2);
		float Dev = 0.0, Min_Sh = min(min(min(Row_0.x, Row_0.y), min(Row_0.z, Row_1.x)), min(min(Row_1.y, Row_1.z), min(min(Row_2.x, Row_2.y), Row_2.z))),
			  Max_Sh = max(max(max(Row_0.x, Row_0.y), max(Row_0.z, Row_1.x)), max(max(Row_1.y, Row_1.z), max(max(Row_2.x, Row_2.y), Row_2.z))),
		#else
		//Only the plane's 4 corners, the gathers below hold every texel they blend so they find the smallest and largest
		float3 Row_0 = MW_Row(Tile_Px, 0), Row_2 = MW_Row(Tile_Px, 2);
		float Dev = 0.0, Min_Sh = 1e4, Max_Sh = -1e4,
		#endif
			  Near_Sh = Re_Scale_WN().x;

		//Depth texels over the tile and a 1 px border, 4 at a time
		float2 Size = Smooth_Size, Scale = Size * pix;
		int2 First = int2(floor((Tile_Px - 1.0) * Scale)), End = int2(ceil((Tile_Px + MW_TILE + 1.0) * Scale));
		const float2 Gather_Ofs[4] = { float2(0, 1), float2(1, 1), float2(1, 0), float2(0, 0) };
		[loop]
		for(int y = First.y; y < End.y; y += 2)
		{
			[loop]
			for(int x = First.x; x < End.x; x += 2)
			{
				float4 Quad = tex2DgatherR(SamplerzBufferB_Smooth, (float2(x, y) + 1.0) / Size) + Near_Sh;
				[unroll]
				for(int q = 0; q < 4; q++)
				{
					//Which square, and where in it
					float2 Pos = (float2(x, y) + Gather_Ofs[q] + 0.5) / Scale - Tile_Px;
					#if MW_TILE >= 16
					float2 Half_Of = Pos >= MW_TILE * 0.5, Weight = saturate((Pos - Half_Of * MW_TILE * 0.5) / (MW_TILE * 0.5));
					float3 Row_Top = Half_Of.y ? Row_1 : Row_0, Row_Bot = Half_Of.y ? Row_2 : Row_1;
					float2 Top = Half_Of.x ? Row_Top.yz : Row_Top.xy, Bot = Half_Of.x ? Row_Bot.yz : Row_Bot.xy;
					#else
					float2 Weight = saturate(Pos / MW_TILE), Top = Row_0.xz, Bot = Row_2.xz;
					#endif

					//Off the plane, smallest and largest
					float Plane = lerp(lerp(Top.x, Top.y, Weight.x), lerp(Bot.x, Bot.y, Weight.x), Weight.y);
					Dev = max(Dev, abs(Quad[q] - Plane));
					Min_Sh = min(Min_Sh, Quad[q]);
					Max_Sh = max(Max_Sh, Quad[q]);
				}
			}
		}
		return float4(Dev, Min_Sh, Max_Sh, 1.0);
	}

	//VM0: nearest depth of the row around a corner (left, centre, right), objects grow 1 texel sideways.
	float MW_Shift_Near(float2 uv)
	{
		float Texel_X = rcp(Smooth_Size.x);
		return min(MW_Shift(uv), min(MW_Shift(uv - float2(Texel_X, 0)), MW_Shift(uv + float2(Texel_X, 0))));
	}

	//VM0 ramp: far edges with a tiny gap (2 px or less) get no pull, 6 px and up the full reach
	float MW_Gap_W(float Depth_Gap, float Div_Px)
	{
		return saturate((Depth_Gap * Div_Px - 2.0) * 0.25);
	}

	//The ramp's pull k tiles out. VM3 Stamped: full inside the gap the object leaves (its width in px from the depth
	//step, at most 10 tiles) and none outside, so a post past the gap never moves. The other modes keep Halo Reduction + 1.
	float MW_Reach_W(float k, float Reach, float Gap_Px)
	{
		float Reach_Tiles = VM_Stamped_R ? min(Gap_Px / MW_TILE, 10.0) + 0.5 : Reach;
		return k <= Reach_Tiles ? (VM_Stamped_R ? 1.0 : 1.0 - (k - 1.0) / max(Reach_Tiles, 1.0)) : 0.0;
	}

	//The shift a mesh corner takes, VM0 uses the rubber's nearer and pulled corner
	float MW_Corner_Sh(float2 Corner_UV, float Div_UV)
	{
		float Shift = MW_Shift(Corner_UV);
		[branch]
		if(View_Mode == 0)
		{
			Shift = MW_Shift_Near(Corner_UV);
			//Ramp: a nearer corner up to Halo Reduction + 1 tiles toward the hole's side pulls this one, less the farther it is,
			//so the stretch spreads over the reach.
			//VM3 Stamped: up to 10 tiles, MW_Reach_W keeps it inside the gap
			float Own_Shift = Shift, Tile_Step = (Div_UV >= 0.0 ? -1.0 : 1.0) * MW_TILE * pix.x, Div_Px = abs(Div_UV) / pix.x;
			int   Reach = VM_Stamped_R ? 10 : VM_Glass ? VM6_Rubber_Reach : View_Mode_Warping + 1;
			[loop]
			for(int k = 1; k <= Reach; k++)
			{
				float Near = MW_Shift_Near(Corner_UV + float2(Tile_Step * k, 0));
				Shift = min(Shift, lerp(Own_Shift, Near, VM0_Rubber_Pull * MW_Reach_W(k, Reach, (Own_Shift - Near) * Div_Px) * MW_Gap_W(Own_Shift - Near, Div_Px)));
			}
		}
		return Shift;
	}

	#if MW_SQ == 1
	//The shift at each mesh corner, both eyes side by side
	float MW_Corner_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		uint2 Corner_ID = uint2(position.xy);
		uint  Eye = Corner_ID.x > MW_RX ? 1 : 0;
		Corner_ID.x -= Eye * (MW_RX + 1);
		float Div = Eye ? MW_Divergence().y : MW_Divergence().x;
		return MW_Corner_Sh(float2(Corner_ID) * MW_RTILE * pix, Div * pix.x);
	}

	//Tiles in xyz and the mesh corners in w, only the mesh reads the corners
	float4 MW_TC_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		float4 Out = position.x < MW_TX && position.y < MW_TY ? MW_Tile_PS(position, texcoord) : 0.0;
		Out.w = MW_MESH_RUN ? MW_Corner_PS(position, texcoord) : 0.0;
		return Out;
	}
	#endif

	//At the screen's sides a corner reaches the side, so no strip is left for the march
	float MW_Side_Reach(float S_X, float Dest)
	{
		float Reach = Dest;
		if(S_X < 0.5 * pix.x)
			Reach = min(Dest, 0.0);
		else if(S_X > 1.0 - 0.5 * pix.x)
			Reach = max(Dest, 1.0);
		return Reach;
	}

	//Mesh corners, Near 1 draws only VM0's squash tiles for the nearest wins map
	void MW_VS_Core(uint id, bool Near, out float4 position, out float3 Map, out float4 Info)
	{
		Info = 0.0;
		Map = 0.0;
		position = float4(-2.0, -2.0, 0.0, 1.0);

		//The Row Scan does the other View Modes
		if(!MW_MESH_RUN)
			return;

		//Each tile is MW_SQ x MW_SQ squares of 6 points
		const float2 Corner_Ofs[6] ={ float2(0, 0), float2(1, 0), float2(0, 1), float2(1, 0), float2(1, 1), float2(0, 1) };
		uint Per_Tile = 6 * MW_SQ * MW_SQ, Per_Eye = MW_TX * MW_TY * Per_Tile, Eye = id >= Per_Eye ? 1 : 0,
			 Vert = id - Eye * Per_Eye, Cell = Vert / Per_Tile, Square = (Vert % Per_Tile) / 6, Corner = Vert % 6;
		float Div = Eye ? MW_Divergence().y : MW_Divergence().x, Div_UV = Div * pix.x;

		//Columns drawn so the nearer source lands last, right to left for a shift to the left
		uint Col = Cell / MW_TY, Row = Cell % MW_TY;
		if(Div_UV < 0.0)
		{
			Col = MW_TX - 1 - Col;
			Square = MW_SQ == 2 ? Square ^ 1 : Square;
		}

		float4 Tile = tex2Dfetch(SamplerMW_Tile, int2(Col, Row));
		float2 Square_Pos = (float2(Square % MW_SQ, Square / MW_SQ) + Corner_Ofs[Corner]) / MW_SQ, Corner_UV = (float2(Col, Row) + Square_Pos) * MW_TILE * pix;
		float Dest, Flat_Lim = MW_Flat[uint(fmod(Performance_Level, 3))];
		bool Flat = Tile.x * abs(Div) <= Flat_Lim;

		//VM0: a flat tile beside an edge tile counts as an edge tile, so the nearest wins map covers the outline
		[branch]
		if(Flat && View_Mode == 0)
		{
			[unroll]
			for(int n = 0; n < 9; n++)
			{
				int2 Next_Tile = clamp(int2(Col, Row) + int2(n % 3 - 1, n / 3 - 1), 0, int2(MW_TX - 1, MW_TY - 1));
				Flat = Flat && tex2Dfetch(SamplerMW_Tile, Next_Tile).x * abs(Div) <= Flat_Lim;
			}
		}

		[branch]
		if(Near)
		{
			//A tile squashes when its right side shifts less than its left, any of 3 rows
			float2 Tile_UV = float2(Col, Row) * MW_TILE * pix;
			bool Squash = false;
			[branch]
			if(View_Mode == 0 && !Flat)
			{
				[unroll]
				for(int r = 0; r < 3; r++)
				{
					float2 Row_UV = Tile_UV + float2(0, (r * 0.5 * (MW_TILE - 1.0) + 0.5) * pix.y);
					Squash = Squash || Div_UV * (MW_Shift(Row_UV + float2((MW_TILE - 1.0) * pix.x, 0)) - MW_Shift(Row_UV)) < -0.5 * pix.x;
				}
			}
			if(!Squash)
			{
				position = float4(-2.0, -2.0, 0.0, 1.0);
				Map = 0.0;
				return;
			}

			//Its whole landing span
			float Low = min(Div_UV * Tile.y, Div_UV * Tile.z) - 2.0 * pix.x, High = max(Div_UV * Tile.y, Div_UV * Tile.z) + 2.0 * pix.x;
			Dest = Corner_UV.x + (Corner_Ofs[Corner].x > 0.5 ? High : Low);
			Map = float3(0.0, 0.0, Dest);
			Info = float4(Div_UV, Tile_UV.x, Tile.y, Tile.z);
			position = float4((Dest + Eye) - 1.0, 1.0 - Corner_UV.y * 2.0, 0.0, 1.0);
			return;
		}

		//VM0: every tile is a quad, the mesh draws it all and nothing marches
		bool Mesh_All = View_Mode == 0;
		[branch]
		if(Flat || Mesh_All)
		{
			#if MW_SQ == 1
			uint2 Corner_ID = (uint2(Col, Row) + uint2(Corner_Ofs[Corner])) * (MW_TILE / MW_RTILE);
			float Shift = tex2Dfetch(SamplerMW_Tile, int2(Corner_ID.x + Eye * (MW_RX + 1), Corner_ID.y)).w;
			#else
			float Shift = MW_Corner_Sh(Corner_UV, Div_UV);
			#endif
			Dest = Corner_UV.x + Div_UV * Shift;
			Map = float3((Corner_UV.x - Dest) * BUFFER_WIDTH, 1.0, MW_Side_Reach(Corner_UV.x, Dest));
			Dest = Map.z;
		}
		else
		{
			//Everywhere this tile could land, and half a texel more each side
			float Low = min(Div_UV * Tile.y, Div_UV * Tile.z) - 2.0 * pix.x, High = max(Div_UV * Tile.y, Div_UV * Tile.z) + 2.0 * pix.x;
			Dest = Corner_UV.x + (Corner_Ofs[Corner].x > 0.5 ? High : Low);
			Map = float3(0.0, 0.0, Dest);
		}

		position = float4((Dest + Eye) - 1.0, 1.0 - Corner_UV.y * 2.0, 0.0, 1.0);
	}

	void MW_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float3 Map : TEXCOORD0
	#if MW_VIEW_ON
	, out float2 Square_UV : TEXCOORD1
	#endif
	)
	{
		float4 Info;
		MW_VS_Core(id, false, position, Map, Info);
		#if MW_VIEW_ON
		//Where this point sits in its square, so the sides are known and not the diagonal
		const float2 Corner_Ofs[6] = { float2(0, 0), float2(1, 0), float2(0, 1), float2(1, 0), float2(1, 1), float2(0, 1) };
		Square_UV = Corner_Ofs[id % 6];
		#endif
	}

	//VM0 nearest wins: pack and unpack depth and offset
	float MW_Pack(float Shift, float Off)
	{
		float Depth_Code = 1023.0 - round(saturate((Shift + 1.0) * 0.5) * 1022.0);
		return Depth_Code * 16384.0 + round(clamp(Off, -511.0, 511.0) * 16.0) + 8192.0;
	}

	//The offset in px back out of a packed nearest wins code
	float MW_Unpack(float Code)
	{
		return (Code - floor(Code / 16384.0) * 16384.0 - 8192.0) / 16.0;
	}

	#if MW_SCAN_OK
	//Row Scan group memory: the row, the march marks and the list count
	groupshared uint MW_Scan_Row[BUFFER_WIDTH * 2];
	groupshared uint MW_Scan_Fold[(BUFFER_WIDTH * 2 + 31) / 32];
	groupshared uint MW_Scan_Count[2];
	static const float MW_Scan_Fold_Px = 2.0;

	//Row Scan: one group per row, both eyes
	void MW_Scan_CS(uint3 id : SV_DispatchThreadID, uint3 tid : SV_GroupThreadID, uint3 gid : SV_GroupID)
	{
		uint Row_Y = gid.y, Lane = tid.x;

		//Clear this row
		for(uint i = Lane; i < BUFFER_WIDTH * 2; i += MW_SCAN_T)
			MW_Scan_Row[i] = 0xFFFFFFFF;
		for(uint b = Lane; b < (BUFFER_WIDTH * 2 + 31) / 32; b += MW_SCAN_T)
			MW_Scan_Fold[b] = 0;
		if(Lane == 0)
			MW_Scan_Count[0] = 0;

		float Row_V = (Row_Y + 0.5) * pix.y;
		barrier();

		//The infill mask reach
		float2 Div = MW_Divergence();
		float Mask_Reach = MW_Scan_Mask ? max(Mask_Bg_Near, Mask_Extend_Far) : 0.0;

		//Warp the row
		for(uint s = Lane; s < BUFFER_WIDTH; s += MW_SCAN_T)
		{
			//Shift here, next px and 4 px ahead
			float Src_C = min(s + 4.5, BUFFER_WIDTH - 0.5);
			float Sh_A = MW_Shift(float2((s + 0.5) * pix.x, Row_V)),
			      Sh_B = MW_Shift(float2((s + 1.5) * pix.x, Row_V)),
		      Sh_C = MW_Shift(float2(Src_C * pix.x, Row_V));

			[unroll]
			for(int e = 0; e < 2; e++)
			{
				float Div_Eye = e ? Div.y : Div.x;

				//Where the two px land
				float Dst_A = s + 0.5 + Div_Eye * Sh_A, Dst_B = s + 1.5 + Div_Eye * Sh_B,
				      Span = Dst_B - Dst_A, Dst_C = Src_C + Div_Eye * Sh_C;

				//Depth jump, the gap takes the background side whole
				bool Jump = abs(Sh_B - Sh_A) * abs(Div_Eye) > 1.0;
				float Slope_Px = abs(Sh_C - Sh_A) * abs(Div_Eye);
				bool Wide = Slope_Px > HOLE_TRIGGER_PX;
				float Bg_Src = Sh_B > Sh_A ? s + 1.5 : s + 0.5, Bg_Sh = max(Sh_A, Sh_B),
				      Grow = Jump ? 0.5 : 0.0;
				int Px_First = int(ceil(min(Dst_A, Dst_B) - Grow - 0.5)),
				    Px_Last = int(ceil(max(Dst_A, Dst_B) + Grow - 0.5)) - 1;

				//Mark px for the march around every depth jump and wide slope
				[branch]
				if(Wide || Jump)
				{
					//The mask's reach only on the background side, the object side keeps the fold reach
					bool Bg_High = (Sh_B > Sh_A ? Dst_B : Dst_A) >= (Sh_B > Sh_A ? Dst_A : Dst_B);
					float Reach_Lo = MW_Scan_Fold_Px + (Bg_High ? 0.0 : Mask_Reach),
					      Reach_Hi = MW_Scan_Fold_Px + (Bg_High ? Mask_Reach : 0.0);
					float Low = min(Dst_A, Dst_B), High = max(Dst_A, Dst_B);
					if(Wide)
					{
						Low = min(Low, min(Dst_A, Dst_C));
						High = max(High, max(Dst_A, Dst_C));
					}

					int Fold_First = max(int(ceil(Low - Reach_Lo - 0.5)), 0),
					    Fold_Last = min(int(floor(High + Reach_Hi - 0.5)), BUFFER_WIDTH - 1);
					[branch]
					if(Fold_First <= Fold_Last)
					{
						//One write per 32 px word
						uint Bit_First = uint(Fold_First + e * BUFFER_WIDTH), Bit_Last = uint(Fold_Last + e * BUFFER_WIDTH);
						[loop]
						for(uint Word = Bit_First >> 5; Word <= (Bit_Last >> 5); Word++)
						{
							uint Lo_Bit = Word == (Bit_First >> 5) ? (Bit_First & 31u) : 0u,
							     Hi_Bit = Word == (Bit_Last >> 5) ? (Bit_Last & 31u) : 31u;
							atomicOr(MW_Scan_Fold[Word], (0xFFFFFFFFu >> (31u - Hi_Bit)) & (0xFFFFFFFFu << Lo_Bit));
						}
					}
				}

				if(Px_Last < Px_First)
					Px_First = Px_Last = int(floor(Dst_A));
				Px_First = max(Px_First, 0);
				Px_Last = min(Px_Last, BUFFER_WIDTH - 1);

				//Stretch the gap, nearest wins
				[loop]
				for(int p = Px_First; p <= Px_Last; p++)
				{
					float Px_C = p + 0.5, Along = saturate((Px_C - Dst_A) / (abs(Span) > 0.0001 ? Span : 1.0));
					float Src = s + 0.5 + Along, Px_Shift = lerp(Sh_A, Sh_B, Along);
					[branch]
					if(Jump)
					{
						bool Own_A = abs(Px_C - Dst_A) <= 0.5, Own_B = abs(Px_C - Dst_B) <= 0.5;
						Own_A = Own_A && (!Own_B || Sh_A <= Sh_B);
						Own_B = Own_B && !Own_A;
						Src = Own_A ? s + 0.5 : Own_B ? s + 1.5 : Bg_Src;
						Px_Shift = Own_A ? Sh_A : Own_B ? Sh_B : Bg_Sh;
					}

					uint Key = (uint(saturate((Px_Shift + 1.0) * 0.5) * 65535.0) << 16) |
					           uint(clamp(round((Src - Px_C) * 16.0) + 32768.0, 0.0, 65535.0));
					atomicMin(MW_Scan_Row[p + e * BUFFER_WIDTH], Key);
				}
			}
		}
		barrier();

		//Number the marked px and the px nothing landed on, so the pixel shader never marches them.
		for(uint n = Lane; n < BUFFER_WIDTH * 2; n += MW_SCAN_T)
		{
			bool Fold_N = (MW_Scan_Fold[n >> 5] >> (n & 31u)) & 1u, List_N = Fold_N || MW_Scan_Row[n] == 0xFFFFFFFF;
			#if MW_NEED
			//No eye reads it, drop it, only listed px read Need
			[branch]
			if(List_N && Need_On)
			{
				//This frame's mark or the one before, either way round the 255 tag wheel
				float Tag_Apart = abs(tex2Dfetch(SamplerMW_Need, int2(n, 0)).x - MW_Need_Tag) * 255.0;
				[branch]
				if(min(Tag_Apart, 255.0 - Tag_Apart) > 1.5)
				{
					atomicAnd(MW_Scan_Fold[n >> 5], ~(1u << (n & 31u)));
					Fold_N = false;
					List_N = false;
				}
			}
			#endif
			[branch]
			if(List_N)
			{
				//A px nothing landed on takes the mark, so the codes below list it
				if(!Fold_N)
					atomicOr(MW_Scan_Fold[n >> 5], 1u << (n & 31u));
				MW_Scan_Row[n] = atomicAdd(MW_Scan_Count[0], 1u);
			}
		}
		barrier();

		//This row's first list slot
		if(Lane == 0)
		{
			MW_Scan_Count[1] = atomicAdd(StMW_PCount, int2(0, 0), MW_Scan_Count[0]);
			tex2Dstore(StMW_ScanBase, int2(0, Row_Y), float4(MW_Scan_Count[1], 0, 0, 0));
		}
		barrier();

		//Write the codes, offsets stop at 0xBFFF
		for(uint o = Lane; o < BUFFER_WIDTH * 2; o += MW_SCAN_T)
		{
			uint Key = MW_Scan_Row[o];
			bool Fold = (MW_Scan_Fold[o >> 5] >> (o & 31u)) & 1u;
			float Code = MW_CODE_NONE;

			if(!Fold && Key != 0xFFFFFFFF)
				Code = min(Key & 0xFFFF, 0xBFFF);
			else if(Fold && Key != 0xFFFFFFFF)
			{
				uint Slot = MW_Scan_Count[1] + Key;
				if(Slot < MW_PL_W * MW_PL_H)
				{
					tex2Dstore(StMW_PList, int2(Slot % MW_PL_W, Slot / MW_PL_W), o | (Row_Y << 13));
					Code = MW_CODE_PACK + Key;
				}
			}

			tex2Dstore(StMW_Scan, int2(o, Row_Y), float4(Code / 65535.0, 0, 0, 0));
		}
	}
	#endif

	//VM0 nearest wins draw
	void MW_VSN(in uint id : SV_VertexID, out float4 position : SV_Position, out float3 Map : TEXCOORD0, out float4 Info : TEXCOORD1)
	{
		MW_VS_Core(id, true, position, Map, Info);
	}

	//VM0 nearest wins: the packed code of the source landing at Out_X, 0 for none
	float MW_Near_Best(float Out_X, float Out_Y, float4 Info)
	{
		//The source in this tile or the ones beside it that lands here, from 4 starting shifts
		float Left_X = Info.y - MW_TILE * pix.x, Right_X = Info.y + 2.0 * MW_TILE * pix.x, Best = 0.0;
		float4 Starts = float4(Info.z, Info.w, (Info.z + Info.w) * 0.5, MW_Shift(float2(Out_X, Out_Y)));
		[unroll]
		for(int c = 0; c < 4; c++)
		{
			float Src_X = Out_X - Info.x * Starts[c];
			[unroll]
			for(int k = 0; k < 6; k++)
				Src_X = Out_X - Info.x * MW_Shift(float2(Src_X, Out_Y));

			float Shift = MW_Shift(float2(Src_X, Out_Y));
			if(abs(Src_X + Info.x * Shift - Out_X) < 0.75 * pix.x && Src_X >= Left_X - pix.x && Src_X <= Right_X + pix.x)
				Best = max(Best, MW_Pack(Shift, (Src_X - Out_X) * BUFFER_WIDTH));
		}
		return Best;
	}

	float MW_PSN(float4 position : SV_Position, float3 Map : TEXCOORD0, float4 Info : TEXCOORD1) : SV_Target
	{
		if(Map.z < 0.0 || Map.z > 1.0)
			discard;

		float Best = MW_Near_Best(Map.z, position.y / (BUFFER_HEIGHT / 2), Info);
		if(Best <= 0.0)
			discard;
		return Best;
	}

	//Mesh map
	void MW_PS(float4 position : SV_Position, float3 Map : TEXCOORD0
	#if MW_VIEW_ON
	, float2 Square_UV : TEXCOORD1
	#endif
	, out float4 Map_Out : SV_Target0
	#if MW_VIEW_ON
	, out float4 Wire : SV_Target1
	#endif
	)
	{
		Map_Out = float4(Map.xy, 0.0, 1.0);
		#if MW_VIEW_ON
		Wire = 0.0;
		#endif

		//Kept inside its own eye's half
		if(Map.z < 0.0 || Map.z > 1.0)
			discard;

		#if MW_VIEW_ON
		//Distance to the square's sides in map texels
		float2 Side_Px = min(Square_UV, 1.0 - Square_UV) * rcp(max(fwidth(Square_UV), 0.0001));
		float Side = saturate(1.5 - min(Side_Px.x, Side_Px.y));

		//Source px per screen px: 1 unchanged, under 1 stretched, over 1 squashed
		float Src_Per_Px = 1.0 + ddx(Map.x) * 0.5;

		//Wire colour by square size, a stretched or squashed square is infill
		float Square_W = rcp(max(fwidth(Square_UV.x), 0.0001));
		bool  Holds = abs(Src_Per_Px - 1.0) <= 0.05;
		float Kind = Holds ? 0.2 : 0.1;
		if(Map.y < 0.5)
			Kind = 0.0;
		else if(Holds && Square_W > 24.0)
			Kind = 0.8;
		else if(Holds && Square_W > 12.0)
			Kind = 0.6;
		else if(Holds && Square_W > 6.0)
			Kind = 0.4;

		//8 px: left and top side only, so two squares do not double the line
		if(Kind == 0.2)
		{
			float2 Low_Px = Square_UV * rcp(max(fwidth(Square_UV), 0.0001));
			Side = saturate(1.5 - min(Low_Px.x, Low_Px.y));
		}
		Wire = float4(Side, Kind, 0.0, saturate(0.5 + (Src_Per_Px - 1.0) * 0.25));
		#endif
	}

	#if !MW_VIEW_ON
	//Both maps in one draw: the rubber, then VM0's nearest wins quads, each target with its own blend
	//One interpolant: the rubber's Map in xyz, a nearest wins quad its Tile yz in xw, its column + eye code over 1.5 in y and Map.z in z
	void MW_VSB(in uint id : SV_VertexID, out float4 position : SV_Position, out float4 Map : TEXCOORD0)
	{
		uint Per_Draw = MW_TX * MW_TY * 12 * MW_SQ * MW_SQ, N_Id = id >= Per_Draw ? id - Per_Draw : id;
		bool Near = id >= Per_Draw;
		float3 Map_C;
		float4 Info;
		MW_VS_Core(N_Id, Near, position, Map_C, Info);
		float Eye = N_Id >= Per_Draw / 2 ? 1.0 : 0.0;
		Map = Near ? float4(Info.z, 2.0 + round(Info.y / (MW_TILE * pix.x)) + Eye * 4096.0, Map_C.z, Info.w) : float4(Map_C, 0.0);
	}

	#if MW_SCAN_OK && MW_SQ == 1
	//Map Row: one group per map row and eye, the rubber's spans and the nearest wins quads without the raster
	#define MW_MAP_EW (BUFFER_WIDTH - BUFFER_WIDTH / 2)
	#define MW_MAP_NI 1024
	groupshared uint MW_Map_Win[MW_MAP_EW], MW_Map_Near[MW_MAP_EW], MW_Map_Item[MW_MAP_NI], MW_Map_NCount;
	groupshared float2 MW_Map_D[MW_RX + 1];

	//A rubber square cut by this row: x left side, diagonal, right side, y the offsets in px there
	void MW_Map_Cut(uint C, float T, out float3 Cut_X, out float3 Cut_A)
	{
		float2 D_L = MW_Map_D[C], D_R = MW_Map_D[C + 1];
		float S_L = C * MW_RTILE * pix.x, S_R = (C + 1) * MW_RTILE * pix.x;
		//The strip's split: top right to bottom left, the sides reach the screen edge like the draw
		Cut_X = float3(lerp(MW_Side_Reach(S_L, D_L.x), MW_Side_Reach(S_L, D_L.y), T),
					   lerp(MW_Side_Reach(S_R, D_R.x), MW_Side_Reach(S_L, D_L.y), T),
					   lerp(MW_Side_Reach(S_R, D_R.x), MW_Side_Reach(S_R, D_R.y), T));
		Cut_A = float3(S_L - lerp(D_L.x, D_L.y, T), lerp(S_R, S_L, T) - lerp(D_R.x, D_L.y, T), S_R - lerp(D_R.x, D_R.y, T)) * BUFFER_WIDTH;
	}

	//First and last map px whose centre is in [Lo, Hi) of this eye, like the raster's fill rule
	int2 MW_Map_Px(float Lo, float Hi, uint Eye, int X0, int N)
	{
		return int2(max(int(ceil((Lo + Eye) * BUFFER_WIDTH * 0.5 - 0.5)) - X0, 0), min(int(ceil((Hi + Eye) * BUFFER_WIDTH * 0.5 - 0.5)) - 1 - X0, N - 1));
	}

	//VM0 nearest wins quad of a tile, the same test as MW_VS_Core, false when it does not squash
	bool MW_Near_Tile(int2 Tile_ID, float Div, out float4 Info, out float2 Span)
	{
		float4 Tile = tex2Dfetch(SamplerMW_Tile, Tile_ID);
		float Div_UV = Div * pix.x, Flat_Lim = MW_Flat[uint(fmod(Performance_Level, 3))];
		float2 Tile_UV = float2(Tile_ID) * MW_TILE * pix;
		bool Flat = Tile.x * abs(Div) <= Flat_Lim, Squash = false;
		Info = float4(Div_UV, Tile_UV.x, Tile.y, Tile.z);
		Span = 0.0;

		//A flat tile beside an edge tile counts as an edge tile
		[branch]
		if(Flat)
		{
			[unroll]
			for(int n = 0; n < 9; n++)
			{
				int2 Next_Tile = clamp(Tile_ID + int2(n % 3 - 1, n / 3 - 1), 0, int2(MW_TX - 1, MW_TY - 1));
				Flat = Flat && tex2Dfetch(SamplerMW_Tile, Next_Tile).x * abs(Div) <= Flat_Lim;
			}
		}

		//Squashes when its right side shifts less than its left, any of 3 rows
		[branch]
		if(!Flat)
		{
			[unroll]
			for(int r = 0; r < 3; r++)
			{
				float2 Row_UV = Tile_UV + float2(0, (r * 0.5 * (MW_TILE - 1.0) + 0.5) * pix.y);
				Squash = Squash || Div_UV * (MW_Shift(Row_UV + float2((MW_TILE - 1.0) * pix.x, 0)) - MW_Shift(Row_UV)) < -0.5 * pix.x;
			}
		}

		//Its whole landing span
		Span = float2(Tile_UV.x + min(Div_UV * Tile.y, Div_UV * Tile.z) - 2.0 * pix.x, (Tile_ID.x + 1) * MW_TILE * pix.x + max(Div_UV * Tile.y, Div_UV * Tile.z) + 2.0 * pix.x);
		return Squash;
	}

	void MW_Map_CS(uint3 tid : SV_GroupThreadID, uint3 gid : SV_GroupID)
	{
		//Only VM0 reads the maps
		if(View_Mode != 0)
			return;

		uint Lane = tid.x, Eye = gid.x, Row_Y = gid.y;
		int X0 = Eye ? BUFFER_WIDTH / 2 : 0, N = Eye ? MW_MAP_EW : BUFFER_WIDTH / 2;
		float Div = Eye ? MW_Divergence().y : MW_Divergence().x, Div_UV = Div * pix.x, Out_Y = (Row_Y + 0.5) / MW_MAP_H,
			  Band_F = Out_Y * BUFFER_HEIGHT / MW_RTILE, T = frac(Band_F);
		uint Band = uint(Band_F), Tile_Row = uint(Out_Y * BUFFER_HEIGHT / MW_TILE);
		bool Rubber_Row = Band < MW_RY, Near_Row = Tile_Row < MW_TY;

		//Clear the row, this band's corners where they land
		for(int i = Lane; i < N; i += 256)
		{
			MW_Map_Win[i] = 0;
			MW_Map_Near[i] = 0;
		}
		if(Lane == 0)
			MW_Map_NCount = 0;
		[branch]
		if(Rubber_Row)
		{
			for(uint c = Lane; c <= MW_RX; c += 256)
			{
				float S_X = c * MW_RTILE * pix.x;
				MW_Map_D[c] = S_X + Div_UV * float2(tex2Dfetch(SamplerMW_Tile, int2(c + Eye * (MW_RX + 1), Band)).w,
													 tex2Dfetch(SamplerMW_Tile, int2(c + Eye * (MW_RX + 1), Band + 1)).w);
			}
		}
		barrier();

		//Rubber: each square's two triangles, the draw's order kept as the winner's number
		for(uint s = Lane; s < MW_RX + MW_TX; s += 256)
		{
			[branch]
			if(s < MW_RX)
			{
				[branch]
				if(Rubber_Row)
				{
					float3 Cut_X, Cut_A;
					MW_Map_Cut(s, T, Cut_X, Cut_A);
					uint Order = (Div_UV < 0.0 ? MW_RX - 1 - s : s) * 2;
					[unroll]
					for(int t = 0; t < 2; t++)
					{
						int2 Px = MW_Map_Px(min(Cut_X[t], Cut_X[t + 1]), max(Cut_X[t], Cut_X[t + 1]), Eye, X0, N);
						[loop]
						for(int p = Px.x; p <= Px.y; p++)
							atomicMax(MW_Map_Win[p], Order + t + 1);
					}
				}
			}
			else if(Near_Row)
			{
				//Nearest wins quads: their px go on the list, past the list's end they run here
				float4 Info;
				float2 Span;
				int2 Tile_ID = int2(s - MW_RX, Tile_Row);
				[branch]
				if(MW_Near_Tile(Tile_ID, Div, Info, Span))
				{
					int2 Px = MW_Map_Px(Span.x, Span.y, Eye, X0, N);
					[branch]
					if(Px.x <= Px.y)
					{
						uint Slot = atomicAdd(MW_Map_NCount, uint(Px.y - Px.x + 1));
						[loop]
						for(int p = Px.x; p <= Px.y; p++, Slot++)
						{
							[branch]
							if(Slot < MW_MAP_NI)
								MW_Map_Item[Slot] = uint(Tile_ID.x) << 16 | uint(p);
							else
								atomicMax(MW_Map_Near[p], uint(MW_Near_Best((X0 + p + 0.5) * 2.0 / BUFFER_WIDTH - Eye, Out_Y, Info)));
						}
					}
				}
			}
		}
		barrier();

		//The listed nearest wins px
		uint Items = min(MW_Map_NCount, MW_MAP_NI);
		for(uint k = Lane; k < Items; k += 256)
		{
			uint Item = MW_Map_Item[k], Col = Item >> 16, p = Item & 0xFFFF;
			float4 Tile = tex2Dfetch(SamplerMW_Tile, int2(Col, Tile_Row));
			float4 Info = float4(Div_UV, Col * MW_TILE * pix.x, Tile.y, Tile.z);
			atomicMax(MW_Map_Near[p], uint(MW_Near_Best((X0 + p + 0.5) * 2.0 / BUFFER_WIDTH - Eye, Out_Y, Info)));
		}

		//The rubber map: the last triangle drawn here, its offset where this px sits on it
		for(int o = Lane; o < N; o += 256)
		{
			uint Win = MW_Map_Win[o];
			float2 Out = 0.0;
			[branch]
			if(Win > 0)
			{
				uint Order = (Win - 1) / 2, t = (Win - 1) & 1u;
				float3 Cut_X, Cut_A;
				MW_Map_Cut(Div_UV < 0.0 ? MW_RX - 1 - Order : Order, T, Cut_X, Cut_A);
				float U = (X0 + o + 0.5) * 2.0 / BUFFER_WIDTH - Eye, Side = Cut_X[t + 1] - Cut_X[t];
				Out = float2(lerp(Cut_A[t], Cut_A[t + 1], abs(Side) > 0.0 ? saturate((U - Cut_X[t]) / Side) : 0.0), 1.0);
			}
			tex2Dstore(StMW_Map, int2(X0 + o, Row_Y), float4(Out, 0, 0));
		}
		barrier();

		for(int q = Lane; q < N; q += 256)
			tex2Dstore(StMW_MapN, int2(X0 + q, Row_Y), float4(MW_Map_Near[q], 0, 0, 0));
	}
	#endif

	void MW_PSB(float4 position : SV_Position, float4 Map : TEXCOORD0, out float4 Map_Out : SV_Target0, out float Near_Out : SV_Target1)
	{
		Map_Out = 0.0;
		Near_Out = 0.0;
		[branch]
		if(Map.y > 1.5)
		{
			//Nearest wins quad: its Info back out of the one interpolant
			float Code = round(Map.y) - 2.0, Eye = Code >= 4096.0 ? 1.0 : 0.0;
			float4 Info = float4((Eye > 0.5 ? MW_Divergence().y : MW_Divergence().x) * pix.x, (Code - Eye * 4096.0) * MW_TILE * pix.x, Map.x, Map.w);
			Near_Out = MW_PSN(position, Map.xyz, Info);
		}
		else
			MW_PS(position, Map.xyz, Map_Out);
	}
	#endif
	#endif

	//Line and column interlaced read their own eye's row or column
	float2 IO_Shift(float2 Coord, float IO)
	{
		if(Stereoscopic_Mode == 2 && !Virtual_Reality_Mode)
			Coord.y += IO * pix.y;
		else if(Stereoscopic_Mode == 3)
			Coord.x += IO * pix.x;
		return Coord;
	}

	//SD3D's march, for the tiles the mesh cannot hold
	float4 Parallax_March(float Diverge, float2 Coordinates, float IO, int VMode, out float2 Edge) // Horizontal parallax offset & Hole filling effect
	{
		Edge = 0.0;

		float  MS = Diverge * pix.x;
		float2 ParallaxCoord = Coordinates,
			   Pixel_XY = floor(float2(Coordinates.x * BUFFER_WIDTH, Coordinates.y * BUFFER_HEIGHT));

		//VM4 Weave, the infill's noise picks half the px for each march
		float Mix_Pick = Interleaved_Gradient_Noise(Pixel_XY) >= 0.5;
		bool VM4_Lin = VMode == 4 && Mix_Pick,
			 VM_Snap = (VMode == 3 || VMode == 4) && !VM4_Lin;//GetMixed_P reads VM_Snap.

		float Set_UI = 1;
		if(Alpha_Channel_UI)
			Set_UI = Alpha_UI_Mask(ParallaxCoord,2) > 0.999;

		float2 AA = Artifact_Adjust();

		float LR_Depth_Mask = 0.0;
		[branch]
		if(VMode == 4)
			LR_Depth_Mask = saturate(Blur_N(Coordinates * float2(0.5,1) + float2(0.5,0), 3.0).x * 2.5);
		float GetDepth = smoothstep(0,1, tex2Dlod(SamplerDMN, float4(Coordinates,0, 2.0) ).x);

		//Steps. VM1 and VM2 take more.
		float Perf = (VMode == 1 || VMode == 2 ? VM2_Steps : 0.625) * lerp(0.8f, 1.0f, GetDepth);
		if( VMode == 4)
			Perf = lerp( Mix_Pick ? 0.75f : 0.500f, 0.625f, saturate(GetDepth * 0.5 * rcp(max(LR_Depth_Mask, 0.001))) );

		//Distance Field Skip x = flat areas y = edges
		#if Handheld_Mode
			float2 DF_MaxSkip = float2(2.5, 1.5);
		#else
		float2 DF_MaxSkip = float2(2.0, 1.25);
		#endif

		//Foveated Calculations
		float Foveated_Mask = 0;
		if(De_Artifacting.x < 0 || Compatibility_Power < 0)
			Foveated_Mask = saturate( Vin_Pattern(Coordinates, float2(16.0,2.0)));

		//De-Artifacting.
		float Mod_Depth = saturate(GetDepth * lerp(1,15,abs(AA.y))),
			  Scale_With_Depth = AA.y == 0 ? 1 : (AA.y < 0 ? 1-Mod_Depth : Mod_Depth);
		float AA_Value = AA.x,
			  AA_Switch = De_Artifacting.x < 0 ? lerp(0.3 * AA_Value, AA_Value ,smoothstep(0.0,1.0,Foveated_Mask)): AA_Value;
		float2 Artifacting_Adjust = float2(MS * lerp(0,0.125,clamp(AA_Switch * Scale_With_Depth,0,2)),
										   1.0 - (MS * lerp(0,0.25,clamp(AA_Value * Scale_With_Depth,0,2))));
		bool AA_Toggle = AA.x != 0 && !(VMode >= 2 && VMode <= 4);

		//ParallaxSteps Calculations, 3x3 and Quilt tiles are narrow so they step like Side by Side's half
		#if !EX_DLP_FS_Mode
		if(MULTI_VIEW && Stereoscopic_Mode >= 6)
			Perf *= 2.0 / MV_GRID.x;
		#endif
		int Div_Px = abs(Diverge), Cal_Steps = max(1, Div_Px * Perf);
		float LayerDepth = rcp(Cal_Steps), deltaCoordinates = MS * LayerDepth;

		//Dither the start in VM3, and in VM1 and VM2 when the infill dithers
		float Dither = 0.0;
		if(VMode == 3)
			Dither = frac(dot(Pixel_XY, float2(0.75487766624669276, 0.569840290998))) * 0.5;
		else if((VMode == 1 || VMode == 2) && VM_Infill_Dither && Infill_Blur > 0)
			Dither = frac(Pixel_XY.y * 0.618034) * 0.5;
		ParallaxCoord.x -= deltaCoordinates * Dither;

		float Start_Depth = GetMixed_P(ParallaxCoord, 0).x, CurrentDepthMapValue = min(1, Start_Depth),
			  Last_Depth = Start_Depth, CurrentLayerDepth = -Re_Scale_WN().x;
		CurrentLayerDepth += LayerDepth * Dither;
		bool Popped = CurrentDepthMapValue < CurrentLayerDepth;//Popped out past the march start.

		float Inv_LayerDepth = rcp(LayerDepth), Near_Band = LayerDepth * 2.0, AA_Set = AA_Switch * Set_UI;
		const float threshold = 0.0005;

		//Farthest depth passed, depth one sample back, the last step's size
		float Path_Max = -1e4;
		float Prev_D = Start_Depth;
		float AA_Last = 1.0;
		float Jump_Depth = Start_Depth;

		#if !DX9_DX10_Toggle
		//Tile jump: no hit can come before the smallest shift on the tiles the march crosses
		int Tile_Y = int(floor(Coordinates.y * BUFFER_HEIGHT / MW_TILE));
		[branch]
		if(!Popped && Tile_Y < MW_TY && abs(Diverge) >= 1.0)
		{
			float Shift_Px = abs(Diverge), Start_Px = ParallaxCoord.x * BUFFER_WIDTH, Min_Shift = 1e4, Reach_Px = 0.0,
				  Extra_Px = (AA_Toggle ? abs(Artifacting_Adjust.x) * BUFFER_WIDTH : 0.0) + abs(deltaCoordinates) * BUFFER_WIDTH;
			int March_Dir = MS > 0.0 ? -1 : 1, Start_Tile = int(floor(Start_Px / MW_TILE));
			bool Tile_Done = false;
			[loop]
			for(int Tile_Step = 0; Tile_Step < 16 && !Tile_Done; Tile_Step += 4)
			{
				//4 tiles read at once, then checked in order
				float4 Tile_Min;
				[unroll]
				for(int k = 0; k < 4; k++)
					Tile_Min[k] = tex2Dfetch(SamplerMW_Tile, int2(clamp(Start_Tile + March_Dir * (Tile_Step + k), 0, MW_TX - 1), Tile_Y)).y;

				[unroll]
				for(int k = 0; k < 4; k++)
				{
					int Tile_X = Start_Tile + March_Dir * (Tile_Step + k);
					[flatten]
					if(!Tile_Done)
					{
						//Off the tiles, depth could be anything down to zero
						if(Tile_X < 0 || Tile_X >= MW_TX)
						{
							Min_Shift = min(Min_Shift, Re_Scale_WN().x);
							Tile_Done = true;
						}
						else
						{
							Min_Shift = min(Min_Shift, Tile_Min[k]);
							Reach_Px = March_Dir < 0 ? Start_Px - Tile_X * MW_TILE : (Tile_X + 1) * MW_TILE - Start_Px;
							Tile_Done = Reach_Px >= Min_Shift * Shift_Px + Extra_Px;
						}
					}
				}
			}

			//Jump
			float Skip_Depth = min(Min_Shift, (Reach_Px - Extra_Px) / Shift_Px) - 0.032;
			int Skip_Steps = int(floor(Skip_Depth * Cal_Steps)) - 1;
			if(Skip_Steps >= 1)
			{
				ParallaxCoord.x -= deltaCoordinates * Skip_Steps;
				CurrentLayerDepth += LayerDepth * Skip_Steps;
				Path_Max = Start_Depth;
				Jump_Depth = GetMixed_P(ParallaxCoord, 0).x;
				CurrentDepthMapValue = min(1, Jump_Depth);
				Last_Depth = Prev_D = Jump_Depth;
			}
		}
		#endif

		if(AA_Toggle)
		{
			bool VM_Snap = false;//VM3 and VM4 never march here. GetMixed_P reads it.
			float G_Depth = Jump_Depth;
			float Back_Value = CurrentDepthMapValue, Back_G = G_Depth, Back_C = 0, Last_Skip = 1.0;
			float C_Depth = GetMixed_P(ParallaxCoord - float2(Artifacting_Adjust.x, 0), 0).x;
			[loop] //Steep parallax mapping Ray Marcher with De-Artifacting
			while (CurrentDepthMapValue >= CurrentLayerDepth)
			{
				float adjustedLayerDepth = 0.0;
				Path_Max = max(Path_Max, CurrentDepthMapValue);
				float diff = abs(G_Depth - C_Depth);
				// Sensitivity threshold
				float Mask = diff > threshold;

				//Distance Field Skip, half steps near the surface
				float distToSurface = CurrentDepthMapValue - CurrentLayerDepth;
				float DF_Limit = Mask ? DF_MaxSkip.y : DF_MaxSkip.x;
				float DF_Floor = distToSurface < Near_Band ? 0.5 : 1.0;
				float DF_Skip = clamp(distToSurface * Inv_LayerDepth, DF_Floor, DF_Limit);

				//Quarter steps near the surface where the look-ahead sees an edge, so the infill does not band
				if(Mask && distToSurface < Near_Band)
					DF_Skip = 0.25;
				float adjustedDeltaCoord = deltaCoordinates * DF_Skip;
				adjustedLayerDepth = LayerDepth * DF_Skip;

				// Shift coordinates horizontally in linear fashion
				ParallaxCoord.x -= adjustedDeltaCoord;
				Back_Value = CurrentDepthMapValue;
				Back_G = G_Depth;
				Back_C = C_Depth;
				Last_Skip = DF_Skip;
				Prev_D = CurrentDepthMapValue;

				//The look-ahead and its mask from this step
				G_Depth = GetMixed_P(ParallaxCoord, 0).x;
				C_Depth = GetMixed_P(ParallaxCoord - float2(Artifacting_Adjust.x, 0), 0).x;
				CurrentDepthMapValue = lerp(G_Depth, min(G_Depth, C_Depth), AA_Set * (abs(G_Depth - C_Depth) > threshold));
				// Update depth step
				CurrentLayerDepth += adjustedLayerDepth;
			}

			//Redo a landing skip in single steps
			[branch]
			if(Last_Skip > 1.0)
			{
				ParallaxCoord.x += deltaCoordinates * Last_Skip;
				CurrentLayerDepth -= LayerDepth * Last_Skip;
				CurrentDepthMapValue = Back_Value;
				G_Depth = Back_G;
				C_Depth = Back_C;
				[loop]
				for(int r = 0; r < 3 && CurrentDepthMapValue >= CurrentLayerDepth; r++)
				{
					Path_Max = max(Path_Max, CurrentDepthMapValue);
					ParallaxCoord.x -= deltaCoordinates;
					Prev_D = CurrentDepthMapValue;
					G_Depth = GetMixed_P(ParallaxCoord, 0).x;
					C_Depth = GetMixed_P(ParallaxCoord - float2(Artifacting_Adjust.x, 0), 0).x;
					CurrentDepthMapValue = lerp(G_Depth, min(G_Depth, C_Depth), AA_Set * (abs(G_Depth - C_Depth) > threshold));
					CurrentLayerDepth += LayerDepth;
				}
			}
			Last_Depth = CurrentDepthMapValue;//VM1 Refined lands on the depth it marched
			AA_Last = min(Last_Skip, 1.0);
		}
		else
		{
			float Back_Value = CurrentDepthMapValue, Last_Skip = 1.0;
			[loop] //Steep parallax mapping Ray Marcher
			while ( CurrentDepthMapValue >= CurrentLayerDepth )
			{
				Path_Max = max(Path_Max, CurrentDepthMapValue);

				//Distance Field Skip, half steps near the surface
				float distToSurface = CurrentDepthMapValue - CurrentLayerDepth;
				float DF_Limit = distToSurface < Near_Band ? DF_MaxSkip.y : DF_MaxSkip.x;
				float DF_Floor = distToSurface < Near_Band ? 0.5 : 1.0;
				float DF_Skip = clamp(distToSurface * Inv_LayerDepth, DF_Floor, DF_Limit);
				float adjustedLayerDepth = LayerDepth * DF_Skip, adjustedDeltaCoord = deltaCoordinates * DF_Skip;

				// Shift coordinates horizontally in linear fashion
				ParallaxCoord.x -= adjustedDeltaCoord;
				Back_Value = CurrentDepthMapValue;
				Last_Skip = DF_Skip;

				// Update current depth values
				Prev_D = CurrentDepthMapValue;
				CurrentDepthMapValue = GetMixed_P(ParallaxCoord, 0).x;
				Last_Depth = CurrentDepthMapValue;
				CurrentLayerDepth += adjustedLayerDepth;
			}

			//Redo a landing skip in single steps
			[branch]
			if(Last_Skip > 1.0)
			{
				ParallaxCoord.x += deltaCoordinates * Last_Skip;
				CurrentLayerDepth -= LayerDepth * Last_Skip;
				CurrentDepthMapValue = Back_Value;
				[loop]
				for(int r = 0; r < 3 && CurrentDepthMapValue >= CurrentLayerDepth; r++)
				{
					Path_Max = max(Path_Max, CurrentDepthMapValue);
					ParallaxCoord.x -= deltaCoordinates;
					Prev_D = CurrentDepthMapValue;
					CurrentDepthMapValue = GetMixed_P(ParallaxCoord, 0).x;
					Last_Depth = CurrentDepthMapValue;
					CurrentLayerDepth += LayerDepth;
				}
			}
			AA_Last = min(Last_Skip, 1.0);
		}

		//VM4 infill half steps
		float Step_X = deltaCoordinates * AA_Last, Step_L = LayerDepth * AA_Last;
		[branch]
		if(VMode == 4)
		{
			float2 Probe_Coord = float2(ParallaxCoord.x + Step_X, ParallaxCoord.y);
			float  Jump = abs(GetMixed_P(Probe_Coord, 0).x - CurrentDepthMapValue);
			float Half_Step = Jump > 0.032;
			[branch]
			if(Half_Step > 0.0)
			{
				float2 Half_Coord = float2(ParallaxCoord.x + 0.5 * Step_X, ParallaxCoord.y);
				float  Half_Layer = CurrentLayerDepth - 0.5 * Step_L, Half_Depth = GetMixed_P(Half_Coord, 0).x;

				//Hit already at the half step
				if(Half_Depth < Half_Layer)
				{
					ParallaxCoord.x      = lerp(ParallaxCoord.x, Half_Coord.x, Half_Step);
					CurrentLayerDepth    = lerp(CurrentLayerDepth, Half_Layer, Half_Step);
					CurrentDepthMapValue = lerp(CurrentDepthMapValue, Half_Depth, Half_Step);
					Last_Depth           = CurrentDepthMapValue;
				}
				Step_X = lerp(Step_X, 0.5 * Step_X, Half_Step);
				Step_L = lerp(Step_L, 0.5 * Step_L, Half_Step);
			}
		}

		float2 PrevParallaxCoord = float2( ParallaxCoord.x + Step_X, ParallaxCoord.y);

		//Anti-Weapon Hand Fighting
		float Weapon_Mask = 0, ZFighting_Mask = 0;
		if(WP > 0)
		{
			Weapon_Mask = WeaponMask(Coordinates,0);
			ZFighting_Mask = (WeaponMask(Coordinates,5.5) + Weapon_Mask) * (1.0-Weapon_Mask);
		}
		float Get_DB = Last_Depth;
		float Get_DB_ZDP = WP > 0 ? lerp(Get_DB, abs(Get_DB + Re_Scale_WN().x) - Re_Scale_WN().x, ZFighting_Mask) : Get_DB;

		// Parallax Occlusion Mapping
		float beforeDepthValue = Get_DB_ZDP, afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
			  beforeDepthValue += Step_L - CurrentLayerDepth;
		// Depth Diffrence for Gap masking
		float DepthDiffrence = afterDepthValue - beforeDepthValue;
		bool  Front = max(CurrentDepthMapValue, Get_DB) < 0.0;//In front of the screen a gap is a change in the step.
		float DD_Gap = DepthDiffrence;

		//VM1 and VM2 gap from the depth one sample back
		if(VMode == 1 || VMode == 2)
			DD_Gap = CurrentDepthMapValue - Prev_D - Step_L;
		bool  Mask_Used = Infill_Blur != 0 || Show_Infill_Mask || Infill_Blur_Debug || MEM_INFILL || VMode == 2;

		//The gap from the change in the step, in front of the screen and for Stamped's mask
		float Step_Gap = 0.0;
		[branch]
		if((Front || (VMode == 3 && Mask_Used)) && !Popped)
		{
			float Back_Depth_A = GetMixed_P(PrevParallaxCoord, 0).x;
			float Back_Depth_B = GetMixed_P(float2(PrevParallaxCoord.x + Step_X, PrevParallaxCoord.y), 0).x;
			float Slope_A = CurrentDepthMapValue - Back_Depth_A, Slope_B = Back_Depth_A - Back_Depth_B;
			Step_Gap = (Slope_A - Slope_B) * smoothstep(0.4, 0.6, abs(Slope_A - Slope_B) * rcp(max(max(abs(Slope_A), abs(Slope_B)), 0.00001)));
			//Stamped: an edge split over the ramp is still a gap
			if(VMode == 3 && Slope_A * Slope_B > 0.0 && min(abs(Slope_A), abs(Slope_B)) > 0.032)
				Step_Gap = max(abs(Step_Gap), abs(Slope_A + Slope_B));
		}
		if(Front && !Popped)
			DD_Gap = Step_Gap;
		float DD_Map = Popped ? 0.0 : abs(DD_Gap);

		//Stamped measures its gap the in front way, for its mask only
		float VM3_Map = DD_Map;
		if(VMode == 3 && Mask_Used && !Front && !Popped)
			VM3_Map = abs(Step_Gap);
		float2 DD_Spread = float2(DD_Map > 0.032, DD_Map > lerp(0.128,0.064 ,LR_Depth_Mask ));
		bool isHardMode = VMode == 1;//VM1 Refined: secant refine from the depth one step back
		float Edge_A = ParallaxCoord.x, Hit_X = Edge_A;

		float weight = afterDepthValue * rcp(min(-0.0125, DepthDiffrence));
		if(Popped)
			weight = -afterDepthValue * rcp(Step_L);

		//Secant refine of the landing
		[branch]
		if(isHardMode && !DD_Spread.x && !Popped)
		{
			float Ref_Weight = saturate(weight);
			float Ref_Gap = GetMixed_P(float2(lerp(ParallaxCoord.x, PrevParallaxCoord.x, Ref_Weight), ParallaxCoord.y), 0).x - (CurrentLayerDepth - Step_L * Ref_Weight);
			float Ref_Before = GetMixed_P(PrevParallaxCoord, 0).x + Step_L - CurrentLayerDepth;
			float Ref_Near = Ref_Gap < 0.0 ? Ref_Gap : afterDepthValue, Ref_Far = Ref_Gap < 0.0 ? Ref_Before : Ref_Gap;
			float Ref_Frac = saturate(Ref_Near * rcp(min(-0.0001, Ref_Near - Ref_Far)));
			weight = Ref_Gap < 0.0 ? lerp(Ref_Weight, 1.0, Ref_Frac) : Ref_Weight * Ref_Frac;
		}

		//VM2 pancake bands, back from the hit
		bool Band = VMode == 2 && DD_Spread.x && !Popped;
		float Start_X = Coordinates.x - deltaCoordinates * Dither, Band_Step = deltaCoordinates * VM2_Band,
			  Band_X = Start_X - floor((Start_X - ParallaxCoord.x) * rcp(Band_Step) + 0.001) * Band_Step;

		//Hole bisection
		[branch]
		if(DD_Spread.x && VMode != 3 && !Popped)
		{
			float Lo = PrevParallaxCoord.x, Hi = ParallaxCoord.x, Hi_Layer = CurrentLayerDepth, Bisect_Layer = Step_L;
			SD_UNROLL
			for(int b = 0; b < 2; b++)
			{
				float Mid = (Lo + Hi) * 0.5;
				Bisect_Layer *= 0.5;
				if(GetMixed_P(float2(Mid, ParallaxCoord.y), 0).x < Hi_Layer - Bisect_Layer)
				{
					Hi = Mid;
					Hi_Layer -= Bisect_Layer;
				}
				else
					Lo = Mid;
			}

			//VM1 Refined: one more half, thinner bands
			[branch]
			if(VMode == 1)
			{
				float Mid = (Lo + Hi) * 0.5;
				if(GetMixed_P(float2(Mid, ParallaxCoord.y), 0).x < Hi_Layer - Bisect_Layer * 0.5)
					Hi = Mid;
				else
					Lo = Mid;
			}
			ParallaxCoord.x = Hi;
			PrevParallaxCoord.x = Lo;
			Edge_A = Hi;
		}
		ParallaxCoord.x = lerp(ParallaxCoord.x, PrevParallaxCoord.x, weight);
		float Pre_Lens = ParallaxCoord.x;

		//Stamped edge AA: the march reads hard depth (R), G sets the edge colour mix
		float Cov_W = 0.0, Cov_Off = 0.0;
		[branch]
		if(VMode == 3 && !Popped && Set_UI && !Vert_3D_Pinball)
		{
			float Texel_Dx = sign(deltaCoordinates) * rcp(Smooth_Size.x);
			float2 Hit_RG = Stamp_RG(float2(Edge_A, ParallaxCoord.y)),
				   Next_RG = Stamp_RG(float2(Edge_A + Texel_Dx, ParallaxCoord.y));
			float Span = Next_RG.x - Hit_RG.x, Edge_R = smoothstep(0.016, 0.048, Span) * (1 - smoothstep(1, 1.5, weight));
			float Hit_Cover = saturate((Next_RG.x - Hit_RG.y) * rcp(max(Span, 0.0001))),
				  Next_Cover = saturate((Next_RG.x - Next_RG.y) * rcp(max(Span, 0.0001))) * Edge_R;
			float Bg_Weight = smoothstep(0, 0.25, 1 - Hit_Cover) * Edge_R;
			[branch]
			if(Bg_Weight > 0.0)
			{
				//Background landing past the hit texel
				int Cov_Width = Smooth_Size.x, Hit_Index = int(Edge_A * Cov_Width);
				float Cov_X = Edge_A, Cov_Layer = CurrentLayerDepth + (Hit_X - Edge_A) * LayerDepth * rcp(deltaCoordinates),
					  Cov_Depth = Next_RG.x, Cov_Prev = Next_RG.x;
				Cov_W = (1.0 - Hit_Cover) * Bg_Weight;
				[loop]
				for(int c = 0; c < 24; c++)
				{
					Cov_X -= deltaCoordinates;
					Cov_Layer += LayerDepth;
					if(int(Cov_X * Cov_Width) == Hit_Index)
						continue;
					Cov_Prev = Cov_Depth;
					Cov_Depth = GetMixed_P(float2(Cov_X, ParallaxCoord.y), 0).x;
					if(Cov_Depth < Cov_Layer)
						break;
				}
				float Cov_After = Cov_Depth - Cov_Layer, Cov_Before = Cov_Prev - (Cov_Layer - LayerDepth);
				Cov_X = lerp(Cov_X, Cov_X + deltaCoordinates, saturate(Cov_After * rcp(min(Cov_After - Cov_Before, -0.00001))));
				Cov_Off = Cov_X - ParallaxCoord.x;
			}
			else if(Next_Cover > 0.0)
			{
				Cov_W = Next_Cover;
				Cov_Off = Edge_A + Texel_Dx - ParallaxCoord.x;
			}
		}

		//De-band the stretch
		float Edge_W = weight, Edge_M = ParallaxCoord.x;
		if(DD_Spread.x)
		{
			const float2 magicdot = float2(0.75487766624669276, 0.569840290998);
			float Jit = frac(dot(Pixel_XY, magicdot));
			ParallaxCoord.x += (Jit - 0.5) * pix.x * (VMode == 1 ? 1.0 : 0.75);
		}

		//Compatibility Power
		float Auto_Compatibility_Power = abs(Compatibility_Power);
		if(Auto_Compatibility_Power == 0)
		{
			float Far_Z  = Blur_N(Coordinates * float2(0.5,1) + float2(0.5,0), 2).x;
			float Far_Fade = smoothstep(0.75, 1.0, Far_Z);
			Auto_Compatibility_Power = lerp(-0.25,0.0, Far_Fade );
		}
		if(Compatibility_Power < 0)
			Auto_Compatibility_Power *= Foveated_Mask;
		float Tune_Power = 0.015 + 0.0225 * Auto_Compatibility_Power, D_Range = 37.5,
			  US_Offset = Diverge < 0 ? -D_Range : D_Range, DB_Offset = US_Offset * Tune_Power * pix.x;
		//This is to limit artifacts.
		ParallaxCoord.x += DB_Offset;

		//Gap Mask, never under one full step in VM1, VM2 and VM4
		float Hole_Px = (VMode == 3 ? VM3_Map : DD_Map) * Div_Px;
		if(VMode != 3)
			Hole_Px = max(Hole_Px, LayerDepth * Div_Px);

		//Side test: which side of the edge is the reveal
		float Edge_Px = 0.0, Hole_Side = 1.0, Bg_X = ParallaxCoord.x;
		bool  Bg_Mv = false;
		if(Hole_Px > HOLE_TRIGGER_PX && VMode != 3 && Mask_Used)
		{
			bool  Bg_Pos = sign(Diverge) < 0;
			float Dir_Bg = Bg_Pos ? 1.0 : -1.0;

			//Reach: short on the object side, long on the background side
			float Bg_Probe = Depth_Blend(smoothstep(0, 1, tex2Dlod(SamplerDMN, float4(ParallaxCoord, 0, 0.0)).x));
			float Dilate   = floor(Recon_Step + 0.5) * rcp(Depth_Rez) + Mask_Reach_Px * DS_Side_Texels * rcp(DS_Side_Tuned);
			float Reach_Ob = Dilate * pix.x * Mask_Reach_Scale * lerp(Mask_Reach_Near, Mask_Reach_Far, Bg_Probe);
			float Reach_Bg = lerp(Mask_Bg_Near, Mask_Extend_Far, Bg_Probe) * pix.x;
			#if M_Edge
			const float ER_Band = 0.001;
			#else
			const float ER_Band = 0.03;
			#endif
			float  Land_D = GetMixed_P(ParallaxCoord, 0).x;
			float2 Tap_L  = ParallaxCoord - float2(Bg_Pos ? Reach_Ob : Reach_Bg, 0);
			float2 Tap_R  = ParallaxCoord + float2(Bg_Pos ? Reach_Bg : Reach_Ob, 0);
			float  Hole_L = min(Tap_L.x, 1.0 - Tap_L.x) < ER_Band ? Land_D : GetMixed_P(Tap_L, 0).x;
			float  Hole_R = min(Tap_R.x, 1.0 - Tap_R.x) < ER_Band ? Land_D : GetMixed_P(Tap_R, 0).x;

			//Background Infill pick
			const float Bg_T = 0.064;
			float Hole_B = Bg_Pos ? Hole_L : Hole_R, Pk_D = Land_D, Near_C = Hole_B;
			if(Hole_B > Land_D + Bg_T)
			{
				Pk_D = Hole_B;
				Bg_X = Bg_Pos ? Tap_L.x : Tap_R.x;
			}
			float Near_L = 1e4;
			SD_UNROLL
			for(int r = 1; r <= HOLE_REACH_TAPS; r++)
			{
				float2 Tap = ParallaxCoord + float2(Dir_Bg * (r / (HOLE_REACH_TAPS + 1.0)) * Reach_Bg, 0);
				float  Tap_D  = min(Tap.x, 1.0 - Tap.x) < ER_Band ? Land_D : GetMixed_P(Tap, 0).x;
				Near_L = min(Near_L, Tap_D);
				if(r == 1)
					Near_C = min(Near_C, Tap_D);
				if(r <= 2 && Pk_D <= Land_D + Bg_T && Tap_D > Land_D + Bg_T)
				{
					Pk_D = Tap_D;
					Bg_X = Tap.x;
				}
			}
			Bg_Mv = Pk_D > Land_D + Bg_T && Near_C < Land_D - Bg_T;
			if(Bg_Pos)
				Hole_R = min(Hole_R, Near_L);
			else
				Hole_L = min(Hole_L, Near_L);
			Edge_Px   = abs(Hole_R - Hole_L) * Div_Px;
			Hole_Side = saturate((Hole_R - Hole_L) * sign(Diverge) * 1000.0);
		}
		float Gap_Ramp  = smoothstep(Gap_Detect_Lo, max(Gap_Detect_Lo + 0.1, Gap_Detect_Hi), Hole_Px);
		float Edge_Ramp = smoothstep(2.0, 6.0, Edge_Px) * smoothstep(0.5, 1.0, Hole_Px);
		float Hole_Mask = Hole_Side * max(Gap_Ramp, Edge_Ramp);
		if(HOLE_TRIGGER_PX > 0.5)
			Hole_Mask *= Hole_Px > HOLE_TRIGGER_PX;

		//Background Infill, VM2 bands only on blur mask px with no seam fade
		bool Band_On = Band && Hole_Mask > 0.0;
		if(Band_On)
			ParallaxCoord.x = lerp(ParallaxCoord.x, Band_X + DB_Offset, saturate(Hole_Mask * 2.0));
		else if(Hole_Mask > 0.0 && Bg_Mv)
			ParallaxCoord.x = Bg_X;

		//Memory Infill offset in w
		float VM0_Pack = 0.0;
		#if MEM_INFILL
		[branch]
		if(Hole_Mask > 0.0 && !Vert_3D_Pinball)
		{
			float  WN     = Re_Scale_WN().x;
			float  Land_Z = GetMixed(ParallaxCoord, 0).x;
			float2 Guess  = float2(Coordinates.x - MS * max(Land_Z + WN, 0.0), ParallaxCoord.y);
			float  Mem_Z  = Mem_Now(Guess).a;
			float2 Hidden = float2(Coordinates.x - MS * max(Mem_Z + WN, 0.0), Guess.y);

			//Must match the background 8 and 16 px out
			float  Bg_Dir = -sign(Hidden.x - ParallaxCoord.x) * pix.x;
			float  Bg_8   = GetMixed(float2(ParallaxCoord.x + Bg_Dir *  8.0, ParallaxCoord.y), 0).x;
			float  Bg_16  = GetMixed(float2(ParallaxCoord.x + Bg_Dir * 16.0, ParallaxCoord.y), 0).x;
			float  Bg_Z   = max(Bg_8, Bg_16);
			float  Tol    = 0.03 + 0.15 * Bg_Z;
			bool   Found  = Age_Now(Hidden) > 0.0 && abs(Mem_Now(Hidden).a - Mem_Z) < 0.03 && abs(Mem_Z - Bg_Z) < Tol;
			if(Found && abs(Hidden.x - ParallaxCoord.x) < 0.1)
				VM0_Pack = Hidden.x - ParallaxCoord.x;
		}
		#endif

		//Silhouette blend
		float Post_Off = ParallaxCoord.x - Edge_M;
		[branch]
		if(DD_Spread.x && Hole_Mask < 0.01 && Set_UI && !Vert_3D_Pinball)
		{
			float Off = ParallaxCoord.x - Pre_Lens;
			Edge = float2(PrevParallaxCoord.x + Off, saturate(Edge_W));
			ParallaxCoord.x = Edge_A + Off;
		}

		//Edge blend in holes, faded by how far in the px sits
		bool Seam_All = VMode != 3 && DD_Spread.x && !Band_On;
		[branch]
		if(Seam_All && !Popped && Set_UI && !Vert_3D_Pinball && Path_Max - CurrentDepthMapValue > 0.032)
		{
			float Edge_In = max(Path_Max - CurrentLayerDepth, 0.0) * Div_Px;
			float Cross_W = 1.0 - saturate(Edge_In / lerp(50.0, 75.0, saturate(Path_Max - CurrentDepthMapValue)));
			float Lo = PrevParallaxCoord.x, Hi = Edge_A, Mid_T = (CurrentDepthMapValue + Path_Max) * 0.5;
			SD_UNROLL
			for(int h = 0; h < 2; h++)
			{
				float Mid = (Lo + Hi) * 0.5;
				if(GetMixed_P(float2(Mid, ParallaxCoord.y), 0).x < Mid_T)
					Hi = Mid;
				else
					Lo = Mid;
			}
			float Edge_X = (Lo + Hi) * 0.5;

			//The background 1 px out
			float Bg_Land = Edge_X + sign(Lo - Hi) * pix.x + DB_Offset;
			if(Cross_W > 0.0)
				Edge = float2(Bg_Land, Cross_W);
		}

		if(Cov_W > Edge.y)
			Edge = float2(Edge_M + Post_Off + Cov_Off, Cov_W);
		return float4(IO_Shift(ParallaxCoord, IO), Hole_Mask * Set_UI, VM0_Pack);
	}

	#if MW_SCAN_OK
	//DX11+ Row Scan read: x the offset in px, y 1 for a hit, Pack_Hit when the Packed March holds this px
	float2 MW_Scan_Read(float Diverge, float2 Coordinates, float Eye, float Div_Map, int VMode, out bool Pack_Hit, out float Pack_Slot)
	{
		//The 16 bit code and its row's first packed slot
		float Code = round(tex2Dlod(SamplerMW_Scan, float4((Coordinates.x + Eye) * 0.5, Coordinates.y, 0, 0)).x * 65535.0),
			  Base = tex2Dlod(SamplerMW_ScanBase, float4(0.5, Coordinates.y, 0, 0)).x,
			  Scan_V = Code >= MW_CODE_NONE ? MW_SCAN_NONE :
					   Code >= MW_CODE_PACK ? MW_SCAN_PACK - (Base + Code - MW_CODE_PACK) : (Code - 32768.0) / 16.0;

		//Past the screen edge the read would land in the other eye's half, so those px march
		if(Coordinates.x < 0.0 || Coordinates.x >= 1.0)
			Scan_V = MW_SCAN_NONE;
		bool Scan_Hit = abs(Scan_V) < 8192.0;

		//The Packed March ran at the map's own strength and this View Mode only
		Pack_Hit = Scan_V <= MW_SCAN_PACK && abs(Diverge - Div_Map) < 0.01 && VMode == max(View_Mode, 1);
		Pack_Slot = MW_SCAN_PACK - Scan_V;
		return float2(Scan_V, Scan_Hit ? 1.0 : 0.0);
	}

	//DX11+ Packed March result for its slot
	float4 MW_Pack_Read(float Pack_Slot, float2 Coordinates, float IO, inout float2 Edge)
	{
		int2 Slot = int2(fmod(Pack_Slot, MW_PL_W), floor(Pack_Slot / MW_PL_W));
		float4 Packed = tex2Dfetch(SamplerMW_PRes, Slot);
		#if MEM_INFILL
		float Packed_Edge = tex2Dfetch(SamplerMW_PEdge, Slot).x;
		#else
		float Packed_Edge = 0.0;
		#endif
		float4 Result = float4(IO_Shift(float2(Coordinates.x + Packed.x, Coordinates.y), IO), Packed.y, Packed_Edge);
		if(Packed.w > 0.0)
			Edge = float2(Coordinates.x + Packed.z, Packed.w);
		return Result;
	}
	#endif

	#if MW_MESH_ON
	#if MW_VIEW_ON
	//Mesh View: the wire and grid at this px
	void MW_View_Read(float2 Coordinates, float Eye)
	{
		MW_Wire_Hit = tex2Dlod(SamplerMW_Wire, float4((saturate(Coordinates.x) + Eye) * 0.5, Coordinates.y, 0, 0));
		MW_Near_Hit = false;

		//View 1: the 8 px grid, 2 px thick like the mesh's wire
		float2 Cell_Px = frac(Coordinates * float2(BUFFER_WIDTH, BUFFER_HEIGHT) / MW_TILE) * MW_TILE;
		MW_Cell_Line = any(Cell_Px < 2.0);
	}
	#endif

	//DX11+ mesh map read (VM0 and Mesh View): x the offset in px, y 1 for a hit
	float2 MW_Mesh_Read(float2 Coordinates, float Eye, float Div_Map)
	{
		//Blended where all its neighbours are mesh, kept half a map texel inside its own eye
		float2 Mesh_Map = tex2Dlod(SamplerMW_MapL, float4((clamp(Coordinates.x, pix.x, 1.0 - pix.x) + Eye) * 0.5, Coordinates.y, 0, 0)).xy;
		//VM3 Stamped keeps the blended read at the mesh's edge too, the empty texels weighed out
		[branch]
		if(VM_Stamped_R && Mesh_Map.y > 0.5)
			Mesh_Map = float2(Mesh_Map.x / Mesh_Map.y, 1.0);
		else if(Mesh_Map.y < 0.999)
			Mesh_Map = tex2Dlod(SamplerMW_Map, float4((saturate(Coordinates.x) + Eye) * 0.5, Coordinates.y, 0, 0)).xy;

		//VM0: on the tuck in side the nearest wins answer, refined for this px since the map is half height
		[branch]
		if(View_Mode == 0)
		{
			float Near_Code = tex2Dlod(SamplerMW_MapN, float4((saturate(Coordinates.x) + Eye) * 0.5, Coordinates.y, 0, 0)).x;
			[branch]
			if(Near_Code > 0.5)
			{
				float Map_Shift = Div_Map * pix.x, Out_X = Coordinates.x, Out_Y = Coordinates.y;

				//The rubber stays where it stretches and inside the object
				float2 Rubber_Side = float2(tex2Dlod(SamplerMW_MapL, float4((saturate(Out_X - 2.0 * pix.x) + Eye) * 0.5, Out_Y, 0, 0)).x,
											tex2Dlod(SamplerMW_MapL, float4((saturate(Out_X + 2.0 * pix.x) + Eye) * 0.5, Out_Y, 0, 0)).x);
				float Rubber_Src = Out_X + Mesh_Map.x * pix.x, Rubber_Depth = MW_Shift(float2(Rubber_Src, Out_Y));
				bool Rubber_Keep = abs(Rubber_Side.y - Rubber_Side.x) < 0.5
								&& abs(MW_Shift(float2(Rubber_Src + 2.0 * pix.x, Out_Y)) - MW_Shift(float2(Rubber_Src - 2.0 * pix.x, Out_Y))) < 0.006;
				[branch]
				if(Rubber_Side.y - Rubber_Side.x >= -0.5 && !Rubber_Keep)
				{
					float Near_Src = Out_X + MW_Unpack(Near_Code) * pix.x;
					[unroll]
					for(int k = 0; k < 3; k++)
						Near_Src = Out_X - Map_Shift * MW_Shift(float2(Near_Src, Out_Y));
					float Near_Depth = MW_Shift(float2(Near_Src, Out_Y));

					//Lands here, not on a depth ramp, and never much farther than the rubber
					bool Ramp = abs(MW_Shift(float2(Near_Src + pix.x, Out_Y)) - MW_Shift(float2(Near_Src - pix.x, Out_Y))) > 0.006;
					if(!Ramp && abs(Near_Src + Map_Shift * Near_Depth - Out_X) < 0.75 * pix.x && Near_Depth < Rubber_Depth + 0.01)
					{
						Mesh_Map = float2((Near_Src - Out_X) / pix.x, 1.0);
						#if MW_VIEW_ON
						MW_Near_Hit = true;
						#endif
					}
				}
			}
		}
		return Mesh_Map;
	}
	#endif

	float4 Parallax_Mode(float Diverge, float2 Coordinates, float IO, int VMode, out float2 Edge) // Horizontal parallax offset & Hole filling effect
	{
		#if DX9_DX10_Toggle
		//DX9 and DX10: the march only
		return Parallax_March(Diverge, Coordinates, IO, VMode, Edge);
		#else
		//The eye whose shift points the same way, other strengths like Quad's thirds march from the depth
		float2 Div = MW_Divergence(), Mesh_Map = 0.0;
		float Eye = (Diverge > 0.0) == (Div.y > 0.0) ? 1.0 : 0.0, Div_Map = Eye ? Div.y : Div.x, Pack_Slot = 0.0;
		bool Pack_Hit = false, Map_Str = abs(Diverge - Div_Map) < 0.01;

		//Row Scan
		#if MW_SCAN_OK
		[branch]
		if(Map_Str)
			Mesh_Map = MW_Scan_Read(Diverge, Coordinates, Eye, Div_Map, VMode, Pack_Hit, Pack_Slot);
		#endif

		//Mesh
		#if MW_MESH_ON
		#if MW_VIEW_ON
		MW_View_Read(Coordinates, Eye);
		#endif
		[branch]
		if((!MW_SCAN_OK || MW_VIEW_ON) && Mesh_Map.y < 0.5 && !Pack_Hit && Map_Str && VMode != 1)
			Mesh_Map = MW_Mesh_Read(Coordinates, Eye, Div_Map);
		#endif

		//Packed March, mesh or march
		Edge = 0.0;
		float4 Result = 0.0;
		#if MW_SCAN_OK
		[branch]
		if(Pack_Hit)
			Result = MW_Pack_Read(Pack_Slot, Coordinates, IO, Edge);
		else
		#endif
		[branch]
		if(Mesh_Map.y > 0.5)
		{
			float Scale = abs(Div_Map) > 0.001 ? Diverge / Div_Map : 0.0;
			Result = float4(IO_Shift(float2(Coordinates.x + Mesh_Map.x * pix.x * Scale, Coordinates.y), IO), 0.0, 0.0);
		}
		else if(MW_Part == 1)//The mesh draw leaves this pixel to the march draw.
			MW_Drop = true;
		else
			Result = Parallax_March(Diverge, Coordinates, IO, VMode, Edge);
		return Result;
		#endif
	}

	#if MW_SCAN_OK
	//Packed March: one thread per listed px, a fixed number of groups walks the list
	void MW_PMarch_CS(uint3 id : SV_DispatchThreadID)
	{
		uint Count = min(tex2Dfetch(SamplerMW_PCount, int2(0, 0)), uint(MW_PL_W * MW_PL_H));
		[loop]
		for(uint Px_I = id.x; Px_I < Count; Px_I += MW_PM_GROUPS * 64)
		{
			//This px and its eye
			int2 Slot = int2(Px_I % MW_PL_W, Px_I / MW_PL_W);
			uint Code = tex2Dfetch(SamplerMW_PList, Slot), Out_X = Code & 8191u, Out_Y = Code >> 13;
			uint Eye = Out_X >= BUFFER_WIDTH ? 1 : 0;
			float2 Coordinates = (float2(Out_X - Eye * BUFFER_WIDTH, Out_Y) + 0.5) * pix, Div = MW_Divergence(), Edge;

			//March it and store the result
			float4 March = Parallax_March(Eye ? Div.y : Div.x, Coordinates, 0.0, max(View_Mode, 1), Edge);
			tex2Dstore(StMW_PRes, Slot, float4(March.x - Coordinates.x, March.z, Edge.y > 0.0 ? Edge.x - Coordinates.x : 0.0, Edge.y));
			#if MEM_INFILL
			tex2Dstore(StMW_PEdge, Slot, float4(March.w, 0, 0, 0));
			#endif
		}
	}
	#endif

	#if MW_MESH_ON
	//VM0's far part, the rubber alone. Hit when the mesh landed. Its mask comes from the Alpha run, like Blend.
	float4 MW_Rubber_Part(float Diverge, float2 Coordinates, float IO, out bool Hit, out float2 Edge)
	{
		float2 Div = MW_Divergence(), Mesh_Map = 0.0;
		float Eye = (Diverge > 0.0) == (Div.y > 0.0) ? 1.0 : 0.0, Div_Map = Eye ? Div.y : Div.x,
			  Scale = abs(Div_Map) > 0.001 ? Diverge / Div_Map : 0.0;
		[branch]
		if(abs(Diverge - Div_Map) < 0.01)
			Mesh_Map = MW_Mesh_Read(Coordinates, Eye, Div_Map);
		Hit = Mesh_Map.y > 0.5;

		//VM6 Glass and VM3 Stamped: the rubber moved this px when its read spot lands elsewhere
		Edge = 0.0;
		[branch]
		if(VM_Glass && Hit)
		{
			float Map_Shift = Div_Map * pix.x, Src = Coordinates.x + Mesh_Map.x * pix.x, Y = Coordinates.y, Src_Depth = MW_Shift(float2(Src, Y)),
				  //The background side is set by the eye's shift, the same for the whole fill
				  Bg_Dir = sign(Map_Shift) * pix.x;
			bool Moved = abs(Src + Map_Shift * Src_Depth - Coordinates.x) > pix.x;

			[branch]
			if(VM_Stamped_R)
			{
				//VM3 Stamped: every px the rubber moved takes the nearest shift the map holds toward the object, 6 taps out to
				//the full shift. A tap counts only inside that object's gap, and a px read off the image is never a stamp.
				Hit = false;
				[branch]
				if(Moved && abs(Div_Map) > 0.001 && saturate(Src) == Src)
				{
					float Copy_Depth = -Mesh_Map.x / Div_Map, Copy_Offset = Mesh_Map.x, Tap_Step = max(4.0, abs(Div_Map) / 6.0);
					[loop]
					for(int t = 1; t <= 6; t++)
					{
						//Kept half a map texel inside its own eye, like MW_Mesh_Read
						float2 Tap_Map = tex2Dlod(SamplerMW_MapL, float4((clamp(Coordinates.x - t * Tap_Step * Bg_Dir, pix.x, 1.0 - pix.x) + Eye) * 0.5, Y, 0, 0)).xy;
						float Tap_Depth = -Tap_Map.x / Div_Map;
						if(Tap_Map.y > 0.999 && Tap_Depth < Copy_Depth && t * Tap_Step <= (Src_Depth - Tap_Depth) * abs(Div_Map) + Tap_Step)
						{
							Copy_Depth = Tap_Depth;
							Copy_Offset = Tap_Map.x;
						}
					}

					//A stamp when its shift is nearer than what it shows: the background moves with the object
					//FUTURE: the stamp warps inward at the top of an object, the mesh blends its shift up and down.
					[branch]
					if(Copy_Depth < Src_Depth - 0.032)
					{
						//Only inside the real gap: the spot this background comes from is hidden by the object.
						//VM4 Mixed: each px gets its own shorter reach, so the stamp thins out toward its outer edge.
						float Reach_Noise = frac(dot(floor(Coordinates * float2(BUFFER_WIDTH, BUFFER_HEIGHT)), float2(0.569840290998, 0.75487766624669276))),
							  Reach = VM_Mixed_R ? VM4_Stamp_Reach * (1.0 - VM4_Dither * Reach_Noise) : 0.5,
							  Reach_Spot = Coordinates.x - Map_Shift * (Src_Depth + (2.0 * Reach - 1.0) * (Src_Depth - Copy_Depth)),
							  Reach_Depth = VM_Mixed_R ? (Src_Depth + Copy_Depth) * 0.5 : Src_Depth - 0.032;
						Hit = Reach > 0.0 && MW_Shift(float2(Reach_Spot, Y)) < Reach_Depth;
						if(Hit)
							Mesh_Map.x = Copy_Offset;
					}
				}
			}
			else
			{
				//VM6 Glass: one test picks the fill px (Hit), the edge and the mirror blend, so the blend is full where the fill ends.
				//The background's depth is the farthest of 3 reads, so the tuck in and smooth depth can not hide the gap.
				float Bg_Depth= max(Src_Depth, max(MW_Shift(float2(Src + 2.0 * Bg_Dir, Y)), MW_Shift(float2(Src + 8.0 * Bg_Dir, Y)))),
					  Hidden = Coordinates.x - Map_Shift * Bg_Depth,
					  //The object's depth at the hidden spot, one read so the fill's end and the edge below use the same test
					  Obj_Depth = MW_Shift(float2(Hidden, Y));

				//Fill px: the rubber is stretched here and the object hides the background behind it
				Hit = Moved && Bg_Depth- Obj_Depth > 0.032;
				MW_Fill_Obj_X = Hidden;
				[branch]
				if(Hit)
				{
					//The object's edge from depth, halvings between the hidden spot and the landing
					//The edge is where the depth passes the fill test (Bg_Depth- 0.032), so Edge_In is 0 right where the fill ends
					float Lo = Hidden - 2.0 * Bg_Dir, Hi = Src, Mid_T = Bg_Depth- 0.032;
					[unroll]
					for(int h = 0; h < 7; h++)//7 halvings: under 0.5 px across a 60 px gap
					{
						float Mid = (Lo + Hi) * 0.5;
						if(MW_Shift(float2(Mid, Y)) > Mid_T)
							Hi = Mid;
						else
							Lo = Mid;
					}

					//Edge_In: the hidden spot's distance from the edge, 0 where the fill ends. Mirrored to the background side.
					float Edge_X = (Lo + Hi) * 0.5, Edge_In = abs(Edge_X - Hidden),
						  //Edge Offset px further onto the background, so the fill's end meets the VM1 side
						  Mirror = Edge_X + VM6_Edge_Offset * Bg_Dir + sign(Bg_Dir) * Edge_In * VM6_Mirror_Dist,
						  //Full where the fill ends, faded over the Glass Fade reach (px) by the gap's depth
						  Cross_W = (1.0 - saturate(Edge_In * BUFFER_WIDTH / max(lerp(VM6_Glass_Fade.x, VM6_Glass_Fade.y, saturate(Bg_Depth- Obj_Depth)), 0.001))) *
									(1.0 - smoothstep(0.0, 0.048, Bg_Depth- MW_Shift(float2(Mirror, Y))));
					if(Cross_W > 0.0)
						Edge = float2(IO_Shift(float2(Mirror, Y), IO).x, Cross_W);
				}
			}
		}

		//The mesh draw leaves a miss to the march draw. Glass and Stamped: a px outside the fill is Alpha's, not a miss.
		if(MW_Part == 1 && !Hit && !VM_Glass)
			MW_Drop = true;

		return float4(IO_Shift(float2(Coordinates.x + Mesh_Map.x * pix.x * Scale, Coordinates.y), IO), 0.0, 0.0);
	}
	#endif

	float4 Parallax(float Diverge, float2 Coordinates, float IO, out float2 Edge)
	{
		float4 Acc = 0.0, Alpha_R = 0.0;
		float Edge_X = 0.0, Edge_W = 0.0, Edge_Best = 0.0, Glass_W = 0.0;
		float2 Alpha_E = 0.0;
		bool Mask_A = VM_Hybrid;

		#if DX9_DX10_Toggle //DX9 and DX10 have no VM0.
		Acc = Parallax_Mode(Diverge,Coordinates,IO,View_Mode,Alpha_E);
		Edge_W = Alpha_E.y;
		Edge_X = Edge_W > 0.0 ? Alpha_E.x : 0.0;
		#else
		//VM0: Alpha near, the rubber far. The other modes are the Alpha part alone, in their own mode.
		bool Hybrid = VM_Hybrid;
		float Near_W = 0.0;
		[branch]
		if(Hybrid && !VM_Glass)
			Near_W = VM0_Near(Coordinates);
		//The rubber's share. Glass, Stamped, Mixed and Blend: none here, their fill takes the rubber below.
		float Part_W = Hybrid && !VM_Glass ? lerp(VM0_Far_Rubber, VM0_Near_Rubber, Near_W) : 0.0;
		bool Glass_On = Part_W > 0.0, Two = Glass_On && Part_W < 1.0;
		bool Rubber_Hit = true;
		[branch]
		if(Glass_On)
		{
			Glass_W = Two ? Part_W : 1.0;
			float2 Glass_E = 0.0;
			float4 Glass_R = MW_Rubber_Part(Diverge, Coordinates, IO, Rubber_Hit, Glass_E);
			//No landing: Alpha takes the whole px
			if(!Rubber_Hit)
				Glass_W = 0.0;
			Acc += Glass_R * Glass_W;
			Edge_W = Glass_E.y * Glass_W;
			Edge_Best = max(Edge_W, 0.0);
			Edge_X = Edge_W > 0.0 ? Glass_E.x : 0.0;
		}

		[branch]
		if(!Glass_On || Two || Mask_A || !Rubber_Hit)
		{
			Alpha_R = Parallax_Mode(Diverge,Coordinates,IO,Hybrid ? 1 : View_Mode,Alpha_E);
			//VM6 Glass and VM3 Stamped: the rubber in the fill px its own test picks, Alpha everywhere else.
			//VM4 Mixed: a stamp px reads a scattered spot between Alpha's landing and the stamp's, the stamp alone picks the px.
			bool Glass_Fill = false;
			[branch]
			if(VM_Glass)
			{
				bool Fill_Hit;
				float2 Fill_E;
				float4 Fill_R = MW_Rubber_Part(Diverge, Coordinates, IO, Fill_Hit, Fill_E);
				//VM3 Stamped: where Alpha lands off the image (the black edge) the stamp stays out
				bool On_Image = !(VM_Stamped_R && saturate(Alpha_R.x) != Alpha_R.x);
				//VM5 Blend: the fill's Glass share by its object's nearness, none of it leaves the px to Alpha
				float Fill_Pull = 1.0;
				[branch]
				if(VM_Blend_R && Fill_Hit)
					Fill_Pull = saturate(VM5_Near(float2(MW_Fill_Obj_X, Coordinates.y)));
				if(Fill_Hit && On_Image && Fill_Pull > 0.0)
				{
					Acc = Fill_R;
					if(VM_Blend_R)
						Acc.xy = lerp(Alpha_R.xy, Fill_R.xy, Fill_Pull);
					Edge_W = VM_Stamped_R ? 0.0 : Fill_E.y * Fill_Pull;
					Edge_X = Fill_E.x;
					Glass_Fill = true;
				}
				float Mixed_Noise = frac(dot(floor(Coordinates * float2(BUFFER_WIDTH, BUFFER_HEIGHT)), float2(0.75487766624669276, 0.569840290998)));
				if(VM_Mixed_R && Fill_Hit && On_Image)
					Acc.xy = lerp(Fill_R.xy, Alpha_R.xy, VM4_Dither * Mixed_Noise);
			}
			if((!Glass_On || Two || !Rubber_Hit) && !Glass_Fill)
			{
				float Weight = Glass_On ? 1.0 - Glass_W : 1.0;
				Acc += Alpha_R * Weight;
				if(Alpha_E.y * Weight > Edge_Best)
				{
					Edge_Best = Alpha_E.y * Weight;
					Edge_X = Alpha_E.x;
				}
				Edge_W += Alpha_E.y * Weight;
			}
		}

		#endif

		//VM0 and the rubber modes: the infill mask always comes from the Alpha run, like VM1
		if(Mask_A)
			Acc.z = Alpha_R.z;
		Edge = float2(Edge_X,Edge_W);
		return Acc;
	}

	///////////////////////////////////////////////////////////Stereo Conversions///////////////////////////////////////////////////////////////////////
	#if !Virtual_Reality_Mode
	uint4 Frame_Selector()
	{
		int FS_RM = 6;
		#if EX_DLP_FS_Mode
		float Swap_Frame = FS_FA ? Frame_Alternate : Alternate;
		#else
		float Swap_Frame = Alternate;
		#endif
		return uint4(fmod(Swap_Frame,2),fmod(Frames,4),0,FS_RM);
	}

	float Anaglyph_Selection(int Selection)
	{
		return Selection;
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

	#if BC_SPACE && (Inficolor_3D_Emulator || Anaglyph_Mode)
	//HDR
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

	#if Anaglyph_Mode && !Inficolor_3D_Emulator
	//One output channel: the eye's colour weighted, summed and shaped
	float AG_Mix(float3 Eye_Color, float3 Weights, float Power)
	{
		return pow(dot(saturate(Eye_Color * Weights), float3(1.0, 1.0, 1.0)), Power);
	}

	//Dubois: both eyes through their matrix, in linear light
	float3 AG_Dubois(float3 L, float3 R, float3x3 ML, float3x3 MR)
	{
		#if BC_SPACE
		return saturate(mul(ML, L) + mul(MR, R));
		#else
		//Gamma: the matrix on the game's colour, like the old SD3D
		[branch] if(Anaglyph_Dubois_Light)
			return saturate(mul(ML, L) + mul(MR, R));
		//sRGB decode, matrix, sRGB encode
		L = L * (L * (L * 0.305306011 + 0.682171111) + 0.012522878);
		R = R * (R * (R * 0.305306011 + 0.682171111) + 0.012522878);
		float3 Lin = saturate(mul(ML, L) + mul(MR, R));
		return max(1.055 * pow(Lin, 0.41666666) - 0.055, 0.0);
		#endif
	}
	#endif

	float4 Stereo_Convert(float2 texcoord, float4 cL, float4 cR)
	{
		float4 L = float4(cL.rgb,0),R = float4(cR.rgb,0);
		#if BC_SPACE && (Inficolor_3D_Emulator || Anaglyph_Mode)
		L.rgb = HDR_To_Anaglyph(L.rgb); R.rgb = HDR_To_Anaglyph(R.rgb);
		#endif
		float2 TC = texcoord; float4 color, color_saturation = lerp(0,2,Anaglyph_Saturation);
		float2 gridxy = floor(TC * GXYArray[Scaling_Support]);
		if (Stereoscopic_Mode == Frame_Selector().w && EX_DLP_FS_Mode)
		{
			color = Frame_Selector().x ? L : R;
		}

		#if Inficolor_3D_Emulator || Anaglyph_Mode
		//Saturation, 0.5 is the original colour
		float3 HalfLA = dot(L.rgb,float3(0.299, 0.587, 0.114)), HalfRA = dot(R.rgb,float3(0.299, 0.587, 0.114));
		float3 cA = saturate(lerp(HalfLA,L.rgb,color_saturation.xxx)), cB = saturate(lerp(HalfRA,R.rgb,color_saturation.xxx));

		#if !Anaglyph_Mode || Inficolor_3D_Emulator
		//Inficolor contrast per eye
		float2 Contrast = lerp(0.875,1.125,Anaglyph_Eye_Contrast);
		cA = (cA - 0.5) * Contrast.x + 0.5;
		cB = (cB - 0.5) * Contrast.y + 0.5;

		//Alpha: left magenta, right green. Beta: left red and blue, right luma in green
		if(Stereoscopic_Mode == 0)
			color.rgb = cA * float3(1.0,0.0,1.0) + cB * float3(0.0,1.0,0.0);
		else
			color.rgb = float3(cA.r, dot(cB,float3(0.299, 0.587, 0.114)), cA.b);
		#else
		//Per eye mix for the Red-Cyan, Green-Magenta and ColorCode modes
		float2 Contrast = lerp(0,2,Anaglyph_Eye_Contrast);
		int Mode = Stereoscopic_Mode;

		//Red-Cyan, iaian7 deghost in mode 2 (http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen)
		if(Mode == 0 || Mode == 2)
		{
			float LOne = Contrast.x * 0.45, ROne = Contrast.y;
			color.rgb = float3(AG_Mix(cA, float3(LOne, (1.0 - LOne) * 0.5, (1.0 - LOne) * 0.5), 1.0),
							   AG_Mix(cB, float3(1.0 - ROne, ROne, 0.0), 1.15),
							   AG_Mix(cB, float3(1.0 - ROne, 0.0, ROne), 1.15));
			if(Mode == 2)
				color.rgb += 0.006 * mul(float3x3(1.0, -0.5, -0.5, -0.25, 0.5, -0.25, -0.25, -0.25, 0.5), color.rgb);
		}
		//Red-Cyan Dubois
		else if(Mode == 1)
			color.rgb = AG_Dubois(cA, cB, float3x3( 0.437,  0.449,  0.164, -0.062, -0.062, -0.024, -0.048, -0.050, -0.017),
										  float3x3(-0.011, -0.032, -0.007,  0.377,  0.761,  0.009, -0.026, -0.093,  1.234));
		//Red-Cyan LCD Optimized by Andres Hernandez AKA cybereality (https://cybereality.com/rendepth-red-cyan-anaglyph-filter-optimized-for-stereoscopic-3d-on-lcd-monitors/)
		//Each eye is clamped, so the left gives only red and the right only green and blue
		else if(Mode == 3)
		{
			color.rgb = float3(dot(cA, float3( 0.4561,     0.500484,  0.176381)),
							   dot(cB, float3( 0.378476,   0.73364,  -0.0184503)),
							   dot(cB, float3(-0.0721527, -0.112961,  1.2264)));
			color.rgb = pow(saturate(color.rgb), rcp(float3(1.6, 0.8, 1.0)));
		}
		//Green-Magenta, iaian7 deghost in mode 6
		else if(Mode == 4 || Mode == 6)
		{
			float LOne = Mode == 6 ? Contrast.x * 0.45 : Contrast.x, ROne = Contrast.y * 0.8;
			color.rgb = float3(AG_Mix(cB, float3(ROne, 1.0 - ROne, 0.0), 1.15),
							   AG_Mix(cA, float3((1.0 - LOne) * 0.5, LOne, (1.0 - LOne) * 0.5), 1.05),
							   AG_Mix(cB, float3(0.0, 1.0 - ROne, ROne), 1.15));
			if(Mode == 6)
				color.rgb += 0.0165 * mul(float3x3(0.5, -0.25, -0.25, -0.5, 0.25, -0.5, -0.25, -0.25, 0.5), color.rgb);
		}
		//Green-Magenta Dubois
		else if(Mode == 5)
			color.rgb = AG_Dubois(cA, cB, float3x3(-0.062, -0.158, -0.039,  0.284,  0.668,  0.143, -0.015, -0.027,  0.021),
										  float3x3( 0.529,  0.705,  0.024, -0.016, -0.015, -0.065,  0.009,  0.075,  0.937));
		//Amber-Blue ColorCode, iaian7 deghost
		else if(Mode == 7)
		{
			float LOne = Contrast.x, ROne = Contrast.y * 0.45;
			float D[1];//The Chronicles of Riddick: Assault on Dark Athena fix. I don't know why it works.
			color.rgb = float3(AG_Mix(cA, float3(LOne, 0.0, 1.0 - LOne), 1.05),
							   AG_Mix(cA, float3(0.0, LOne, 1.0 - LOne), 1.10),
							   AG_Mix(cB, float3((1.0 - ROne) * 0.5, (1.0 - ROne) * 0.5, ROne), 1.0));
			color.rgb += 0.0165 * mul(float3x3(1.5, -0.75, -0.75, -0.75, 1.5, -0.75, -1.5, -1.5, 3.0), color.rgb);
		}
		//Red-Blue, luma per eye (https://stereo.jpn.org/eng/stphmkr/help/stereo_13.htm)
		else if(Mode == 8)
			color.rgb = float3(dot(cA, float3(0.299, 0.587, 0.114)), 0.0, dot(cB, float3(0.299, 0.587, 0.114)));
		//Magenta-Cyan, red and green screen blended so highlights stay, blue shared
		else if(Mode == 9)
			color.rgb = float3(cA.r + cA.b - cA.r * cA.b, cB.g + cB.b - cB.g * cB.b,
							   (dot(cB, float3(0.299, 0.587, 0.114)) + dot(cA, float3(0.299, 0.587, 0.114))) * 0.5);
		//Amber-Blue Dubois
		else
			color.rgb = AG_Dubois(cA, cB, float3x3( 1.062, -0.205,  0.299, -0.026,  0.908,  0.068, -0.038, -0.173,  0.022),
										  float3x3(-0.016, -0.123, -0.017,  0.006,  0.062, -0.017,  0.094,  0.185,  0.911));
		#endif
		color = float4(saturate(color.rgb), 0.0);
		#endif

		#if BC_SPACE && (Inficolor_3D_Emulator || Anaglyph_Mode)
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
		float D = Eye_Swap ? -Min_Divergence().x : Min_Divergence().x;
		float FadeIO, FD_Adjust;
		Focus_Fade(D, DLR, FD_Adjust, FadeIO);
		float2 Persp = Per, Fade_LR = 1.0;
		float Per_Fade = lerp(FD_Adjust,1.0,FadeIO);

		if( Eye_Fade_Selection == 0)
			Persp *= Per_Fade;
		if( Eye_Fade_Selection == 1)
			Fade_LR = float2(1,Per_Fade);
		else if( Eye_Fade_Selection == 2)
			Fade_LR = float2(Per_Fade,1);

		#if !Virtual_Reality_Mode
		if(Stereoscopic_Mode == 0 && !Inficolor_3D_Emulator && !Anaglyph_Mode)
			Persp *= 0.5f;//SBS doubles the eye's coordinates below, VR does not.
		#endif

		TCL = texcoord; TCR = texcoord; TCL_T = texcoord; TCR_T = texcoord;


		#if IC_DEPTH
		if(Inficolor_Auto_Focus)
			Persp *= lerp(0.75,1.0, saturate(smoothstep(-0.0175,min(0.5,0.13),Avr_Mix(float2(0.5,0.5)).x)) );
		#endif

		TCL += Persp * Fade_LR.x; TCR -= Persp * Fade_LR.y; TCL_T += Persp * Fade_LR.x; TCR_T -= Persp * Fade_LR.y;
		#if !Virtual_Reality_Mode
				#if !Inficolor_3D_Emulator
					#if !Anaglyph_Mode
						#if DoubleBuffer_Mode
						if (Stereoscopic_Mode == 0 )//A constant here, so no [branch].
						#else
						[branch] if (Stereoscopic_Mode == 0 )
						#endif
						{
							TCL.x = TCL.x*2;
							TCR.x = TCR.x*2-1;
						}
						else if(Stereoscopic_Mode == 1 )
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
		
		//FoV Cal for left and right eye.
		if(Stereoscopic_Mode == 0)
		{
			TCL = FoVCal(TCL);
			TCR = FoVCal(TCR);
		}
		
		float3 PatternsXYZ = Patterns(texcoord.xy);
		Pattern = PatternsXYZ.x;//CB
		#if !Virtual_Reality_Mode
					if(Stereoscopic_Mode == 0)
						Pattern = texcoord.x < 0.5; //SBS
					if( Stereoscopic_Mode == 1)
						Pattern = texcoord.y < 0.5; //TnB
					if(Stereoscopic_Mode == 2)
						Pattern = PatternsXYZ.z; //LI
					if( Stereoscopic_Mode == 3)
						Pattern = PatternsXYZ.y; //CI
		#endif						
	}

	#if Anaglyph_Mode || Inficolor_3D_Emulator
	//The channels each eye feeds
	void AG_Channels(out float3 L, out float3 R)
	{
		//Red-Cyan
		L = float3(1.0, 0.0, 0.0);
		R = float3(0.0, 1.0, 1.0);
		#if Inficolor_3D_Emulator
		L = float3(1.0, 0.0, 1.0);
		R = float3(0.0, 1.0, 0.0);
		#else
		if(Stereoscopic_Mode == Anaglyph_Selection(4) || Stereoscopic_Mode == Anaglyph_Selection(5) || Stereoscopic_Mode == Anaglyph_Selection(6))
		{
			//Green-Magenta
			L = float3(0.0, 1.0, 0.0);
			R = float3(1.0, 0.0, 1.0);
		}
		else if(Stereoscopic_Mode == Anaglyph_Selection(7) || Stereoscopic_Mode == Anaglyph_Selection(10))
		{
			//Blue-Amber
			L = float3(1.0, 1.0, 0.0);
			R = float3(0.0, 0.0, 1.0);
		}
		else if(Stereoscopic_Mode == Anaglyph_Selection(8))
		{
			//Red-Blue
			L = float3(1.0, 0.0, 0.0);
			R = float3(0.0, 0.0, 1.0);
		}
		else if(Stereoscopic_Mode == Anaglyph_Selection(9))
		{
			//Magenta-Cyan, blue split
			L = float3(1.0, 0.0, 0.5);
			R = float3(0.0, 1.0, 0.5);
		}
		#endif
	}
	#endif

	#if Inficolor_3D_Emulator || Anaglyph_Mode
	#if Inficolor_3D_Emulator
	//Inficolor
	int AG_Dark()
	{
		return 1;
	}

	float3 AG_Region(int Eye)
	{
		float TW = floor(BUFFER_WIDTH * AG_BUDGET), BW = BUFFER_WIDTH;
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

	//The eye that carries less of the brightness, 0 left and 1 right
	int AG_Dark()
	{
		return AG_Left_Share() > 0.5 ? 1 : 0;
	}

	//Eye buffer layout
	float3 AG_Region(int Eye)
	{
		float TW = floor(BUFFER_WIDTH * AG_BUDGET), S = AG_Left_Share();
		float BW = floor(TW * clamp(max(S, 1.0 - S), 0.5, 0.8));
		return Eye != AG_Dark() ? float3(0.0, BW, TW) : float3(BW, TW - BW, TW);
	}
	#endif

	//An eye from texAG_Eyes stretched back to the screen, DX9 and DX10 always, DX11+ while Infill Blur fills the buffer
	float4 AG_Read(float2 tc, int Eye, out float2 Edge)
	{
		Edge = 0.0;
		float3 Region = AG_Region(Eye);
		float Buf_X = clamp(Region.x + tc.x * Region.y, Region.x + 0.5, Region.x + Region.y - 0.5);
		float  Col_0 = clamp(floor(Buf_X - 0.5), Region.x, Region.x + Region.y - 1.0) + 0.5, Col_1 = min(Col_0 + 1.0, Region.x + Region.y - 0.5);
		float4 Tap_0 = tex2Dlod(Sampler_AG_Eyes_P, float4(Col_0 * rcp(Region.z), tc.y, 0, 0)),
			   Tap_1 = tex2Dlod(Sampler_AG_Eyes_P, float4(Col_1 * rcp(Region.z), tc.y, 0, 0));
		float  Frac = saturate(Buf_X - Col_0);
		float2 Shift_XY = lerp(Tap_0.xy, Tap_1.xy, Frac);
		float  Hole = max(Tap_0.z, Tap_1.z);
		//Memory Infill offset, nearest texel
		float  Mem_Ofs = Frac < 0.5 ? Tap_0.w : Tap_1.w;

		//At an edge, the shift that lands on its own surface wins
		[branch]
		if(!Vert_3D_Pinball && abs(Tap_1.x - Tap_0.x) > 0.5 * pix.x)
		{
			float U_0 = (Col_0 - Region.x) * rcp(Region.y), U_1 = (Col_1 - Region.x) * rcp(Region.y);
			float Depth_0 = GetMixed(float2(U_0 + Tap_0.x, tc.y), 0).x, Depth_1 = GetMixed(float2(U_1 + Tap_1.x, tc.y), 0).x;
			float Off_0 = abs(GetMixed(float2(tc.x + Tap_0.x, tc.y), 0).x - Depth_0), Off_1 = abs(GetMixed(float2(tc.x + Tap_1.x, tc.y), 0).x - Depth_1);
			bool Same = Off_0 < 0.01 && Off_1 < 0.01 && abs(Depth_1 - Depth_0) < 0.01;//Same surface keeps the blend.
			if(!Same)
				Shift_XY = (Off_0 < 0.01 && Off_1 < 0.01 ? Depth_1 < Depth_0 : Off_1 < Off_0) ? Tap_1.xy : Tap_0.xy;
		}

		//Edge blend in y and w
		float4 Tap_Near = Frac < 0.5 ? Tap_0 : Tap_1;
		[branch]
		if(!Vert_3D_Pinball && max(Tap_0.w, Tap_1.w) > 0.5)
		{
			float4 Tap_Edge = Tap_Near.w > 0.5 ? Tap_Near : (Tap_0.w > 0.5 ? Tap_0 : Tap_1);
			Edge = float2(tc.x + Tap_Edge.y, Tap_Edge.w - 1.0);
			Shift_XY.y = 0.0;
			Mem_Ofs = 0.0;
		}
		return float4(Shift_XY + (Vert_3D_Pinball ? tc.yx : tc), Hole, Mem_Ofs);
	}

	//Fast Eye Buffer
	float4 AG_Eyes_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		//This column's eye
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

		//Stored as an offset from this px
		bool   Right_Eye = Eye == 1;
		float2 E;
		float4 C = Parallax(Right_Eye ? DLR.y : -DLR.x, Right_Eye ? TCR : TCL, Right_Eye ? -AI : AI, E);
		float2 O = C.xy - (Vert_3D_Pinball ? uv.yx : uv);
		float  Wm = abs(C.w) < 0.1 ? C.w : 0.0;

		//Edge blend in y and w, over 0.5 is an edge and the memory offset stays under 0.1
		if(E.y > 0.0 && !Vert_3D_Pinball && abs(O.y) < 0.5 * pix.y)
		{
			O.y = E.x - uv.x;
			Wm = 1.0 + E.y;
		}
		return float4(O, C.z, Wm);
	}
	#endif

	#if MW_SCAN_OK && MW_NEED
	//Need: marks the scan texel Parallax_Mode reads for this eye, with this frame's tag
	void MW_Need_Mark(bool Right_Eye, float2 DLR, float2 TCL, float2 TCR)
	{
		float Diverge = Right_Eye ? DLR.y : -DLR.x, X = Right_Eye ? TCR.x : TCL.x;
		float Scan_Eye = (Diverge > 0.0) == (MW_Divergence().y > 0.0) ? 1.0 : 0.0;
		//Both texels near the read, it can land on the line between two (SBS doubles the coordinate)
		if(X >= 0.0 && X < 1.0)
		{
			float Px = (X + Scan_Eye) * BUFFER_WIDTH, Eye_Lo = Scan_Eye * BUFFER_WIDTH, Eye_Hi = Eye_Lo + BUFFER_WIDTH - 1;
			tex2Dstore(StMW_Need, int2(clamp(floor(Px - 0.25), Eye_Lo, Eye_Hi), 0), float4(MW_Need_Tag, 0, 0, 0));
			tex2Dstore(StMW_Need, int2(clamp(floor(Px + 0.25), Eye_Lo, Eye_Hi), 0), float4(MW_Need_Tag, 0, 0, 0));
		}
	}

	//One column: marks what the eyes read there, x does not depend on y so a few rows are enough
	void MW_Need_Col(float bx)
	{
		float2 DLR, TCL, TCR, TCL_T, TCR_T;
		float  Pattern;
		#if Inficolor_3D_Emulator || Anaglyph_Mode
		[branch]
		if(Need_On && bx < floor(BUFFER_WIDTH * AG_BUDGET))
		{
			//The same steps as AG_Eyes_PS, one eye buffer column
			int Eye = 1 - AG_Dark();
			float3 Region = AG_Region(Eye);
			if(bx >= Region.x + Region.y)
			{
				Eye = 1 - Eye;
				Region = AG_Region(Eye);
			}
			Con_Values(float2((bx - Region.x + 0.5) * rcp(Region.y), 0.5), DLR, TCL, TCR, TCL_T, TCR_T, Pattern);
			MW_Need_Mark(Eye == 1, DLR, TCL, TCR);
		}
		#else
		[branch]
		if(Need_On && bx < BUFFER_WIDTH)
		{
			//One screen column, one eye per px, TnB LI and CB change eye by row so two rows in each half
			const float Rows[4] = { 0.25, 0.25, 0.75, 0.75 };
			[loop]
			for(int r = 0; r < 4; r++)
			{
				float2 uv = float2(bx + 0.5, floor(Rows[r] * BUFFER_HEIGHT) + (r % 2) + 0.5) * pix;
				Con_Values(uv, DLR, TCL, TCR, TCL_T, TCR_T, Pattern);
				MW_Need_Mark(fmod(Pattern, 2) == 0, DLR, TCL, TCR);
			}
		}
		#endif
	}
	#endif

	#if MW_SCAN_OK
	#if MW_SQ == 1
	//VM0 ramp: corners per tile, the group's corners and the farthest reach each side
	#define MW_NEAR_STEP (MW_TILE / MW_RTILE)
	#define MW_NEAR_H (10 * MW_NEAR_STEP)
	groupshared float MW_Near_Row[64 + 2 * MW_NEAR_H];
	#endif
	#define MW_TILES_GROUPS ((MW_NEED_T + MW_TILE_W * MW_TILE_H + 63) / 64)

	//Tiles and Need in one pass: the first threads mark Need's columns, the rest make the tiles
	void MW_TileNeed_CS(uint3 id : SV_DispatchThreadID, uint3 tid : SV_GroupThreadID)
	{
		//Also clears the Packed March count
		if(id.x == 0)
			tex2Dstore(StMW_PCount, int2(0, 0), 0u);

		#if Anti_Jitter_Mode
		//Also keeps this frame's MiniRecon R for the next frame, after MiniRecon read the last one
		uint2 Hold_Size = tex2Dsize(SamplerMR, 0);
		[loop]
		for(uint Hold_I = id.x; Hold_I < Hold_Size.x * Hold_Size.y; Hold_I += MW_TILES_GROUPS * 64)
		{
			int2 Hold_TC = int2(Hold_I % Hold_Size.x, Hold_I / Hold_Size.x);
			tex2Dstore(StMR_Hold, Hold_TC, float4(tex2Dfetch(SamplerMR, Hold_TC).x, 0, 0, 0));
		}
		#endif

		#if MW_SQ == 1
		//VM0: each corner's nearest row once, the ramp reads its neighbours from here
		bool Near_Share = View_Mode == 0 && MW_TILE % MW_RTILE == 0;
		int Reach = VM_Stamped_R ? 10 : VM_Glass ? VM6_Rubber_Reach : View_Mode_Warping + 1, Halo = min(Reach * MW_NEAR_STEP, MW_NEAR_H), Lane = int(tid.x);
		[branch]
		if(Near_Share)
		{
			int Base = int(id.x - tid.x) - MW_NEED_T;
			[loop]
			for(int j = 0; j < 2; j++)
			{
				//Own corner first, then the first lanes fill both sides
				int Slot = j == 0 ? MW_NEAR_H + Lane : (Lane < Halo ? MW_NEAR_H - Halo + Lane : MW_NEAR_H + 64 + Lane - Halo), L = Base + Slot - MW_NEAR_H;
				[branch]
				if(j == 0 || Lane < 2 * Halo)
				{
					float Near = 0.0;
					[branch]
					if(L >= 0 && L < MW_TILE_W * MW_TILE_H)
					{
						uint2 C = uint2(uint(L) % MW_TILE_W, uint(L) / MW_TILE_W);
						C.x -= C.x > MW_RX ? MW_RX + 1 : 0;
						Near = MW_Shift_Near(float2(C) * MW_RTILE * pix);
					}
					MW_Near_Row[Slot] = Near;
				}
			}
		}
		barrier();
		#endif

		[branch]
		if(id.x < MW_NEED_T)
		{
			#if MW_NEED
			MW_Need_Col(id.x);
			#endif
		}
		else
		{
			uint Tile_I = id.x - MW_NEED_T;
			int2 Texel = int2(Tile_I % MW_TILE_W, Tile_I / MW_TILE_W);
			//Outside VM0 only the march's tiles are read
			[branch]
			if(Texel.y < MW_TILE_H && (MW_MESH_RUN || (Texel.x < MW_TX && Texel.y < MW_TY)))
			{
				float4 Pos = float4(Texel + 0.5, 0.0, 1.0);
				float2 TC = (Texel + 0.5) / float2(MW_TILE_W, MW_TILE_H);
				#if MW_SQ == 1
				//MW_TC_PS, VM0's corner ramp reads the shared rows
				float4 Out = Pos.x < MW_TX && Pos.y < MW_TY ? MW_Tile_PS(Pos, TC) : 0.0;
				[branch]
				if(Near_Share)
				{
					uint Eye = Texel.x > MW_RX ? 1 : 0;
					int Corner_X = Texel.x - Eye * (MW_RX + 1), Dir = 1;
					float Div_UV = (Eye ? MW_Divergence().y : MW_Divergence().x) * pix.x, Own_Shift = MW_Near_Row[MW_NEAR_H + Lane], Shift = Own_Shift,
						  Tile_Step = (Div_UV >= 0.0 ? -1.0 : 1.0) * MW_TILE * pix.x, Div_Px = abs(Div_UV) / pix.x;
					float2 Corner_UV = float2(Corner_X, Texel.y) * MW_RTILE * pix;
					Dir = Div_UV >= 0.0 ? -1 : 1;
					[loop]
					for(int k = 1; k <= Reach; k++)
					{
						//Off this eye's corners or past the shared rows it reads the depth
						int Next_X = Corner_X + Dir * k * MW_NEAR_STEP;
						float Near;
						[branch]
						if(Next_X >= 0 && Next_X <= MW_RX && k * MW_NEAR_STEP <= Halo)
							Near = MW_Near_Row[MW_NEAR_H + Lane + Dir * k * MW_NEAR_STEP];
						else
							Near = MW_Shift_Near(Corner_UV + float2(Tile_Step * k, 0));
						Shift = min(Shift, lerp(Own_Shift, Near, VM0_Rubber_Pull * MW_Reach_W(k, Reach, (Own_Shift - Near) * Div_Px) * MW_Gap_W(Own_Shift - Near, Div_Px)));
					}
					Out.w = Shift;
				}
				else
					Out.w = MW_MESH_RUN ? MW_Corner_PS(Pos, TC) : 0.0;
				tex2Dstore(StMW_Tile, Texel, Out);
				#else
				tex2Dstore(StMW_Tile, Texel, MW_Tile_PS(Pos, TC));
				#endif
			}
		}
	}
	#endif

	#endif
	//////////////////////////////////////////////////////////Infill Blur Post///////////////////////////////////////////////////////////////////////
	float Mask_A(float a)
	{
		#if DX9_DX10_Toggle
		a = round(a * 3.0) / 3.0;
		#endif
		return smoothstep(0.5, 0.9, 1.0 - a);
	}

	#if Inficolor_3D_Emulator || Anaglyph_Mode
	//The nearest eye buffer texel
	float4 Post_Eye(float2 tc, int Pt)
	{
		float3 R = AG_Region(Pt - 1);
		float  bx = clamp(R.x + tc.x * R.y, R.x + 0.5, R.x + R.y - 0.5);
		return tex2Dlod(Sampler_AG_Eyes_P, float4((floor(bx) + 0.5) * rcp(R.z), tc.y, 0, 0));
	}

	//An eye's colour rebuilt from the Fast Eye Buffer
	float4 Post_Rebuild(float2 tc, int Pt)
	{
		//Edge blend from y and w
		float4 Eye_Info = Post_Eye(tc, Pt), Color;
		float2 Pos_A = Eye_Info.xy + (Vert_3D_Pinball ? tc.yx : tc), Pos_B = Pos_A;
		float  Wt = 0.0;
		if(!Vert_3D_Pinball && Eye_Info.w > 0.5)
		{
			Pos_A = float2(tc.x + Eye_Info.x, tc.y);
			Pos_B = float2(tc.x + Eye_Info.y, tc.y);
			Wt = Eye_Info.w - 1.0;
		}

		Color = float4(0.0, 0.0, 0.0, 1.0 - Eye_Info.z);
		[loop]
		for(int c = 0; c < 2; c++)
		{
			float3 Cc = CSB(c ? Pos_B : Vert_3D_Pinball ? Pos_A.yx : Pos_A).rgb;
			Color.rgb = c ? lerp(Color.rgb, Cc, Wt) : Cc;
			[branch]
			if(Wt <= 0.0)
				break;
		}
		return Color;
	}
	#endif

	//A post tap: 0 the stereo image, 1 and 2 an eye rebuilt from the Fast Eye Buffer
	float4 Post_Tap(float2 tc, int Pt, bool Eyes)
	{
		float4 T;
		#if Inficolor_3D_Emulator || Anaglyph_Mode
		[branch]
		if(Eyes)
		{
			#if AG_EYE_C
			//The eye's colour made once, half a texel in so its filter stays on this eye
			T = tex2Dlod(Sampler_AG_EyeC, float4((clamp(tc.x, 0.5 * pix.x, 1.0 - 0.5 * pix.x) + (Pt - 1)) * 0.5, tc.y, 0, 0));
			#else
			T = Post_Rebuild(tc, Pt);
			#endif
		}
		else
		#endif
			T = BB_Clamp(tc);
		return T;
	}

	#if AG_EYE_C
	//Infill Blur's eye colours: left eye in the left half, right eye in the right half, each at screen size
	float4 AG_EyeC_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		float Px = floor(position.x), Right = Px >= BUFFER_WIDTH ? 1.0 : 0.0;
		return Post_Rebuild(float2((Px - Right * BUFFER_WIDTH + 0.5) * pix.x, texcoord.y), 1 + int(Right));
	}
	#endif

	//Infill mask at tc, from the eye buffer or the back buffer's alpha
	float Post_Mask(float2 tc, int Pt, bool Eyes)
	{
		float a;
		#if Inficolor_3D_Emulator || Anaglyph_Mode
		[branch]
		if(Eyes)
			a = 1.0 - Post_Eye(tc, Pt).z;
		else
		#endif
			a = BB_Clamp(tc).a;
		return Mask_A(a);
	}

	//Each eye's part of the screen, its pixel step and which eye it is
	void Post_Layout(float2 tc, out float4 Bnd, out float2 Stp, out float Eye)
	{
		float2 Px = floor(tc * Res);
		int Lay = Stereoscopic_Mode;
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
			Eye = frac(Px.y * 0.5) > 0.0 ? 1.0 : -1.0;
		}
		else if(Lay == 3)
		{
			Stp.x = 2.0;
			Eye = frac(Px.x * 0.5) > 0.0 ? 1.0 : -1.0;
		}
		else if(Lay == 4)
		{
			Stp = 2.0;
			Eye = frac((Px.x + Px.y) * 0.5) > 0.0 ? 1.0 : -1.0;
		}
		else if(Lay == 5)
		{
			Bnd.xy = tc.x < 0.5 ? float2(0.0, 0.5 - pix.x) : float2(0.5, 1.0 - pix.x);
			Bnd.zw = tc.y < 0.5 ? float2(0.0, 0.5 - pix.y) : float2(0.5, 1.0 - pix.y);
			Eye = tc.y < 0.5 ? 1.0 : -1.0;
		}
		#if !EX_DLP_FS_Mode && !(Inficolor_3D_Emulator || Anaglyph_Mode) && !Virtual_Reality_Mode
		//3x3 and Quilts: this view's tile, the first half of the views are on the left
		else if(Lay >= 6)
		{
			float4 Grid = MV_GRID;
			float2 Cell = floor(tc * Grid.xy);
			float Row = Grid.z ? Grid.y - 1.0 - Cell.y : Cell.y;
			Bnd = float4(Cell.x / Grid.x, (Cell.x + 1.0) / Grid.x - pix.x, Cell.y / Grid.y, (Cell.y + 1.0) / Grid.y - pix.y);
			Eye = (Row * Grid.x + Cell.x) * 2.0 < Grid.x * Grid.y - 1.0 ? 1.0 : -1.0;
		}
		#endif
		#if EX_DLP_FS_Mode && !Virtual_Reality_Mode
		else
			Eye = Frame_Selector().x ? 1.0 : -1.0;
		#endif
	}

	//A tap Off px away, kept on this eye
	float2 Post_TC(float2 tc, float2 Off, float4 Bnd, float2 Stp)
	{
		Off = float2(Stp.x > 1.0 ? round(Off.x * 0.5) * 2.0 : Off.x, Stp.y > 1.0 ? round(Off.y * 0.5) * 2.0 : Off.y);
		float2 p = tc + Off * pix;
		return float2(clamp(p.x, Bnd.x, Bnd.y), clamp(p.y, Bnd.z, Bnd.w));
	}

	//Mask edge AA
	float Mask_AA(float2 tc, float Ms, float4 Bnd, float2 Stp, int Pt, bool Eyes)
	{
		[branch]
		if(Ms > 0.0)
		{
			float Mn = 0.0;
			POST_UNROLL
			for(int a = 0; a < 4; a++)
			{
				float Mp = a == 1 || a == 3 ? -Mask_Edge_Px : Mask_Edge_Px;
				Mn += Post_Mask(Post_TC(tc, a < 2 ? float2(Mp, 0) : float2(0, Mp), Bnd, Stp), Pt, Eyes);
			}
			Ms = min(Ms, lerp(Ms, Mn * 0.25, Mask_Edge_Soft));
		}
		return Ms;
	}

	//Infill blur, the mask views and the Memory Infill tint in the post pass
	float4 Infill_Blur_Post(float4 position, float2 texcoord, int Pt, bool Eyes, float4 BB)
	{
		//Each check below skips the rest of the work, one return at the end
		float4 Post_Out = BB;
		[branch]
		if(!((Infill_Blur == 0 && !MEM_SHOW && !Show_Infill_Mask && !POST_VM3_SHOW) || (!Eyes && !(POST_INFILL_OK || POST_VM3_SHOW)) || (Eyes && VM3_ANY)))
		{
			//Kernel reach in px, and the colour guard's white (the eyes are in N space)
			const float Post_Px = 18.0, Post_Guard = 0.15;
			float Post_White = Eyes ? HDR_WHITE : BC_SPACE == 1 ? 2.5375 : BC_SPACE == 2 ? 0.58 : 1.0;
			float4 Bnd;
			float2 Stp;
			float  Eye;
			Post_Layout(texcoord, Bnd, Stp, Eye);

			//An eye from the Fast Eye Buffer fills the screen
			if(Pt > 0)
			{
				Bnd = float4(0.0, 1.0 - pix.x, 0.0, 1.0 - pix.y);
				Stp = 1.0;
				Eye = Pt == 1 ? 1.0 : -1.0;
			}

			//One sided toward the background, Swap Eyes flips it
			const float Bg_Flip = -1.0;
			float dBg = sign(Divergence_Switch().x) * Eye * Bg_Flip * (Eye_Swap ? -1.0 : 1.0);

			//Sharp mask, and the blur grow measured from Grow px toward the object
			float Ms = Mask_A(BB.a);
			float Gs = Blur_Grow_Px > 0.0 ? Post_Mask(Post_TC(texcoord, float2(-dBg * Blur_Grow_Px, 0), Bnd, Stp), Pt, Eyes) : 0.0;
			bool Any_Debug = Infill_Blur_Debug || Show_Infill_Mask || MEM_SHOW;

			//Nothing to blur outside a gap
			[branch]
			if(max(Ms, Gs) > 0.0 || Any_Debug)
			{
				float Ms_Gap = Ms;//The sharp mask, before the soft edge reaches onto the object
				Ms = max(Mask_AA(texcoord, Ms, Bnd, Stp, Pt, Eyes), Gs);
				[branch]
				if(Ms > 0.0 || Any_Debug)
				{
					//VM2 and VM4 dither
					[branch]
					if(VM_Infill_Dither && Ms > 0.0 && !MEM_SHOW && !Show_Infill_Mask)
					{
						float Jk = Interleaved_Gradient_Noise(floor(position.xy) + 7.0);
						bool Dither_Px = Jk < Ms;
						//VM2 scatters every px of the sharp gap mask and leaves its first 3 px against the object, bends too, for a clean edge
						[branch]
						if(View_Mode == 2)
							Dither_Px = Ms_Gap > 0.0 && min(Post_Mask(Post_TC(texcoord, float2(-dBg * 3.0, 0), Bnd, Stp), Pt, Eyes),
							                           min(Post_Mask(Post_TC(texcoord, float2(-dBg * 3.0, -3.0), Bnd, Stp), Pt, Eyes),
							                               Post_Mask(Post_TC(texcoord, float2(-dBg * 3.0, 3.0), Bnd, Stp), Pt, Eyes))) > 0.0;
						[branch]
						if(Dither_Px)
						{
							float4 Td = BB;
							bool   Ok = false;
							float  Wd = 1.0;
							//VM4 takes a second tap
							[loop]
							for(int t = 0; t < 2; t++)
							{
								float Dither_Ofs = (Interleaved_Gradient_Noise(floor(position.xy) + (t ? 13.0 : 0.0)) * 2.0 - 1.0) * Ms *
											(View_Mode == 2 ? VM2_Dither_Reach : Dither_Reach_Px) * (Bnd.y - Bnd.x + pix.x);
								//VM2 and VM4 only reach toward the background, the object side can hold the foreground
								if(VM_Infill_Dither)
									Dither_Ofs = abs(Dither_Ofs) * dBg;
								Td = Post_Tap(Post_TC(texcoord, float2(Dither_Ofs, 0), Bnd, Stp), Pt, Eyes);
								//VM4 takes only clean background past the gap, like the blur's feather, never the gap's own px.
								//VM2 takes every tap, the gap's own px too, so the whole fill scatters.
								Ok = View_Mode == 2 || (VM_Infill_Dither ? Mask_A(Td.a) <= 0.0 : (Dither_Ofs * dBg >= 0.0 || Mask_A(Td.a) > 0.0));
								Wd = View_Mode == 2 ? 0.0 : dot(abs(Td.rgb - BB.rgb) * rcp(abs(BB.rgb) + 0.25 * Post_White), float3(0.3333, 0.3333, 0.3333));
								[branch]
								if(VM_Eff != 4 || (Ok && Wd < 1.0))
									break;
							}
							Post_Out = (Ok && Wd < 1.0) ? float4(Td.rgb, BB.a) : BB;
						}
					}
					else
					{
						//Gaussian weights, 4 taps each with the weights of 2
						const float GW[8] = { 0.9692, 0.8825, 0.7548, 0.6065, 0.4578, 0.3247, 0.2162, 0.1353 };
						float Msum = Ms, Wsum = 1.0;
						POST_UNROLL
						for(int k = 2; k <= 8; k += 2)
						{
							float w = GW[k - 1] + GW[k - 2];
							Msum += Post_Mask(Post_TC(texcoord, float2(dBg * (k * 0.125 * Infill_Soft_Px - Blur_Grow_Px), 0), Bnd, Stp), Pt, Eyes) * w;
							Wsum += w;
						}

						//Falloff, a near background takes less blur in Depth
						float Prof = Msum * rcp(Wsum), Pmin = rcp(Wsum);
						float2 Src = (Post_TC(texcoord, float2(dBg * Infill_Soft_Px, 0), Bnd, Stp) - Bnd.xz) * rcp(Bnd.yw - Bnd.xz + pix);
						float  Nf  = Depth_Blend(smoothstep(0, 1, tex2Dlod(SamplerDMN, float4(Src, 0, 0)).x));
						float Post_Curve = lerp(0.55, 4.0, lerp(Mask_Extend_Fade_Near, Mask_Extend_Fade_Far, Nf));
						float Fall = pow(saturate((Prof - Pmin) * rcp(1.0 - Pmin)), Post_Curve);
						float Soft = (Infill_Falloff ? Fall : (Fall > 0.0 ? lerp(1.0, Fall, 0.5) : 0.0)) * Ms;
						Soft *= Infill_Blur_Depth ? lerp(0.5, 1.0, Nf) : 1.0;

						//Red marks the object side in the blur debug
						[branch]
						if(Ms <= 0.0)
							Post_Out = (Infill_Blur_Debug || MEM_SHOW) ? float4(lerp(BB.rgb, float3(1.0, 0.0, 0.0) * Post_White, saturate(Prof)), BB.a) : BB;
						else if(Soft > 0.002)
						{
							min16float3 RcpC = rcp(abs(BB.rgb) + 0.25 * Post_White);//Colour maths in half precision.
							const min16float3 Third = min16float3(0.3333, 0.3333, 0.3333);
							min16float4 Acc = BB;
							min16float  Csum = 1.0;
							min16float  L_Min = dot(saturate(HDR_Look(BB.rgb, Eyes)), float3(0.2126, 0.7152, 0.0722)), L_Max = L_Min;

							//20 Gaussian taps as 10 bilinear pairs, sub pixel jitter
							const float PO[10] = { 1.4963, 3.4913, 5.4863, 7.4813, 9.4759,
												   11.4713, 13.4663, 15.4612, 17.4558, 19.4514 };
							const float PW[10] = { 1.9752, 1.8791, 1.7178, 1.5089, 1.2735,
												   1.0328, 0.8049, 0.6027, 0.4337, 0.2998 };
							float Step = Post_Px * 0.05 * lerp(0.45, 1.0, Soft);
							float Jit = Interleaved_Gradient_Noise(floor(position.xy)) - 0.5;

							//20 across, then 6 vertical as 3 pairs with the weights of 2
							POST_UNROLL
							for(int i = 0; i < 26; i++)
							{
								float h  = i * 0.5;
								bool  Vt = i >= 20, Bk = frac(h) > 0.0;
								[branch]
								if(!Vt || Post_Vert > 0.0)
								{
									int    b  = Vt ? (int)(h - 10.0) * 2 + 1 : (int)h, b2 = Vt ? b - 1 : b;
									float  o  = (Bk ? -1.0 : 1.0) * (PO[b] + Jit) * Step;
									min16float4 Ta = Post_Tap(Post_TC(texcoord, Vt ? float2(0, o) : float2(o * dBg, 0), Bnd, Stp), Pt, Eyes);
									min16float  Wa = (Vt ? (PW[b] + PW[b2]) * Post_Vert : PW[b]) * saturate(1.0 - dot(abs(Ta.rgb - BB.rgb) * RcpC, Third) * Post_Guard)
													 * (Bk || Vt ? Mask_A(Ta.a) : 1.0);
									Acc  += Ta * Wa;
									Csum += Wa;

									//Contrast from the 3 nearest pairs only
									if(b < 3 && !Vt)
									{
										min16float La = dot(saturate(HDR_Look(Ta.rgb, Eyes)), float3(0.2126, 0.7152, 0.0722));
										L_Min = min(L_Min, La);
										L_Max = max(L_Max, La);
									}
								}
							}

							Soft = saturate(Soft * Infill_Guide(HDR_Look(BB.rgb, Eyes), L_Min, L_Max));
							[branch]
							if(Any_Debug)
								Post_Out = float4(lerp(BB.rgb, float3(0.0, 1.0, 0.0) * Post_White, Soft), BB.a);
							else
								Post_Out = float4(lerp(BB.rgb, (Acc * rcp(Csum)).rgb, Soft), BB.a);
						}
					}
				}
			}
		}
		return Post_Out;
	}

	#if !Use_2D_Plus_Depth
	#if Virtual_Reality_Mode || Anaglyph_Mode
		#if Anaglyph_Mode
		void Anaglyph(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 LR_Out: SV_Target0)
		#else
		void CB_Reconstruction(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Left : SV_Target0, out float4 Right : SV_Target1)
		#endif
	#else
	float4 PS_calcLR(float2 texcoord, float2 position)
	#endif
	{
		float Mouse_Toggle_Click = 1;

		float4 Shift_LR;
		float2 DLR, TCL, TCR, TCL_T, TCR_T, TexCoords = texcoord;
		float Pattern_Type;
		Con_Values(texcoord,DLR, TCL, TCR, TCL_T, TCR_T, Pattern_Type);
		float4 color, L = 0, R = 0, Left_Right = 0, Parallax_LR = 0, Parallax_L = 0, Parallax_R = 0, LR_De_Art;
		float2 E_LR = 0, E_L = 0, E_R = 0;
		Pattern_Type = fmod(Pattern_Type,2);

		#if Virtual_Reality_Mode
			Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) :
										 Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);
			Parallax_LR = Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w, E_LR);

			if(Vert_3D_Pinball)
				Parallax_LR.xyz = Parallax_LR.yxz;

			Left_Right = MouseCursorS(Parallax_LR.xyz, Parallax_LR.w, position.xy , Mouse_Toggle_Click, 0, E_LR);
		#else
			Shift_LR = Vert_3D_Pinball ? Pattern_Type ? float4(-DLR.x,TCL.yx,AI) : float4(DLR.y, TCR.yx, -AI) :
										 Pattern_Type ? float4(-DLR.x,TCL,AI) : float4(DLR.y, TCR, -AI);

			//Quad Lightfield 2x2: views left to right in reading order, inner views at a third
			if(Stereoscopic_Mode == 5)
				Shift_LR = TexCoords.y < 0.5 ? TexCoords.x < 0.5 ? float4(-DLR.x,TCL,AI) : float4(-DLR.x * 0.33333333,TCL_T,AI) :
										   TexCoords.x < 0.5 ? float4(DLR.y * 0.33333333, TCR_T, -AI) : float4(DLR.y, TCR, -AI);
			#if !EX_DLP_FS_Mode
			//3x3 and Quilts: view 0 is the leftmost, 3x3 in reading order, Quilt rows go up from the bottom left
			else if(Stereoscopic_Mode >= 6)
			{
				float4 Grid = MV_GRID;
				float2 Cell = floor(TexCoords * Grid.xy);
				float Row = Grid.z ? Grid.y - 1.0 - Cell.y : Cell.y,
					  T = (Row * Grid.x + Cell.x) / (Grid.x * Grid.y - 1.0) * 2.0 - 1.0;
				float2 Persp_T = (T < 0.0 ? TCL - TexCoords : TCR - TexCoords) * abs(T) * Grid.w;
				Shift_LR = float4(T * Grid.w * (T < 0.0 ? DLR.x : DLR.y), frac(TexCoords * Grid.xy) + Persp_T, T < 0.0 ? AI : -AI);
			}
			#endif

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

				//One eye per loop, so the code is built once. DX9 and DX10 unroll it to fit their registers.
				#if DX9_DX10_Toggle
				[unroll]
				#else
				[loop]
				#endif
				for(int e = 0; e < 2; e++)
				{
					#if EX_DLP_FS_Mode && !Anaglyph_Mode && !Inficolor_3D_Emulator
					//Frame Sequential shows one eye per frame (L when x is 1), the other is not made
					[branch]
					if(Stereoscopic_Mode == Frame_Selector().w && e == (Frame_Selector().x ? 1 : 0))
						continue;
					#endif
					float2 E_e = 0;
					float4 P_e;
					#if (Inficolor_3D_Emulator || Anaglyph_Mode) && DX9_DX10_Toggle
					//DX9 and DX10: both eyes come from texAG_Eyes, both in one shader are too big
					P_e = AG_Read(TexCoords, e, E_e);
					#else
					#if Inficolor_3D_Emulator || Anaglyph_Mode
					//Infill Blur already filled texAG_Eyes, so the eyes are read from it
					[branch]
					if(AG_POST_BLUR)
						P_e = AG_Read(TexCoords, e, E_e);
					else
					#endif
					{
						//Parallax, not a run-time mode loop
						P_e = Parallax(e ? DLR.y : -DLR.x, e ? TCR : TCL, e ? -AI : AI, E_e);
					}
					#endif
					if(Vert_3D_Pinball)
						P_e.xyz = P_e.yxz;

					float4 C_e = MouseCursorS(P_e.xyz, P_e.w, position.xy , Mouse_Toggle_Click, 0, E_e);
					if(e == 0)
					{
						L = C_e;
						Parallax_L = P_e;
					}
					else
					{
						R = C_e;
						Parallax_R = P_e;
					}
				}

				#if AG_POST_BLUR_ON
				//Each eye gets the post blur from the eye buffer, the edge blend under it, before the colours mix
				[branch]
				if(AG_POST_BLUR)
				{
					[loop]
					for(int b = 1; b <= 2; b++)
					{
						float4 Cn = b == 1 ? float4(L.rgb, 1.0 - Parallax_L.z) : float4(R.rgb, 1.0 - Parallax_R.z);
						float3 Cb = Infill_Blur_Post(float4(position.xy, 0, 0), TexCoords, b, true, Cn).rgb;
						if(b == 1)
							L.rgb = Cb;
						else
							R.rgb = Cb;
					}
				}
				#endif
			}
			else
			{
				Parallax_LR = Parallax(Shift_LR.x,Shift_LR.yz,Shift_LR.w, E_LR);

				//Quad and Quilt keep their tiles
				if(Vert_3D_Pinball && Stereoscopic_Mode < 5)
					Parallax_LR.xyz = Parallax_LR.yxz;

				Left_Right = MouseCursorS(Parallax_LR.xyz, Parallax_LR.w, position.xy , Mouse_Toggle_Click, 0, E_LR);
			}
		#endif
		//Debug Here
		//Left_Right.rgb = Left_Right.w;
		//Left_Right.rgb = LR_De_Art.x;//
		//Convert Stereo
		#if Virtual_Reality_Mode
		color.rgb = Left_Right.rgb;
		#else
		color.rgb = (EX_DLP_FS_Mode && Stereoscopic_Mode >= 6) || Inficolor_3D_Emulator || Anaglyph_Mode ? Stereo_Convert( TexCoords, L, R).rgb : Left_Right.rgb;
		#endif

		color = AdjustSaturation(color);
		#if Anaglyph_Mode || Inficolor_3D_Emulator
		//Show Infill Mask: each eye's mask after the mix, red left and blue right
		[branch]
		if(Show_Infill_Mask)
		{
			float3 Red = float3(1.0, 0.0, 0.0), Blue = float3(0.0, 0.0, 1.0);
			#if BC_SPACE
			//Tints in the normalized HDR space
			Red = NormalizeScRGB(float4(Red, 0)).rgb;
			Blue = NormalizeScRGB(float4(Blue, 0)).rgb;
			#endif
			color.rgb = lerp(color.rgb, Red,  smoothstep(0.5, 0.9, L.a));
			color.rgb = lerp(color.rgb, Blue, smoothstep(0.5, 0.9, R.a));
		}
		#endif

		//tex2Dlod: no mips on this texture, so the same value, and it can sit in a real branch
		[branch]
		if (Depth_Map_View == 2)
			color.rgb = Point_L(TexCoords).xxx * HDR_WHITE;

		//Alignment view only: its depth reads used to run for every pixel in every mode
		[branch]
		if(BD_Options == 2 || Alinement_View)
		{
			float DepthBlur = 0, Alinement_Depth = M_Read(TexCoords, 0).x, Depth = Alinement_Depth;
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
				DepthBlur += M_Read(TexCoords + dir * cardinalOffsets[i] * pix * DBPower, 1).x;
			}

			Alinement_Depth = ( Alinement_Depth + DepthBlur ) * 0.1;

			//The image in grey, HDR in the normalized space
			float4 Ali_C = tex2Dlod(Non_Point_Sampler,float4(TexCoords,0,0));
			#if BC_SPACE
			Ali_C = BB_To_N(Ali_C);
			#endif
			color.rgb = dot(Ali_C.rgb,0.333) * float3((Depth/Alinement_Depth> 0.998),1,(Depth/Alinement_Depth > 0.998));
		}
		if( Helper_Fuction() == 0 || timer <= 0)
			color.rgb *= TexCoords.xyx;

	#if Virtual_Reality_Mode
		//Show Infill Mask: paint this eye's mask before the split
		[branch]
		if(Show_Infill_Mask)
		{
			float3 Green = float3(0.0, 1.0, 0.0);
			#if BC_SPACE
			//Tint in the normalized HDR space
			Green = NormalizeScRGB(float4(Green, 0)).rgb;
			#endif
			color.rgb = lerp(color.rgb, Green, smoothstep(0.5, 0.9, Left_Right.a));
		}
		Left.rgb = Pattern_Type ? color.rgb : 0;
		Right.rgb = Pattern_Type ? 0 : color.rgb;
		Left.w = 1.0;
		Right.w= 1.0;
	#else
		#if Anaglyph_Mode
		LR_Out = color.rgba;
		#else
		//Alpha carries the infill mask for the passes after this one
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
	//Which interleave the eye buffer serves: 1 lines, 2 columns, 3 checkerboard, 4 the screen as it is.
	int IL_Layout()
	{
		#if Virtual_Reality_Mode
		return 3;
		#else
		return Stereoscopic_Mode >= 2 && Stereoscopic_Mode <= 4 ? Stereoscopic_Mode - 1 : 4;
		#endif
	}

	//The screen pixel a texIL_Eyes pixel stands for.
	float2 IL_Screen_Pos(float2 position, int Lay)
	{
		float2 B = floor(position), P;
		float2 Half = floor(Res * 0.5);
		if(Lay == 4)
			P = B;
		else if(Lay == 1)
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
		else if(Lay != 4)
		{
			float Pat = Lay == 3 ? P.x + P.y : P.x;
			B.x = floor(P.x * 0.5) + (fmod(Pat, 2.0) ? 0.0 : Half.x);
		}
		return (B + 0.5) * pix;
	}

	//Interleaved eyes: the eye pixel for this buffer texel
	float4 IL_Eyes_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		int Lay = IL_Layout();
		float2 P = IL_Screen_Pos(position.xy, Lay);
		#if Virtual_Reality_Mode
		float4 L, R;
		CB_Reconstruction(float4(P, 0.0, 1.0), P * pix, L, R);
		return float4(L.rgb + R.rgb, 1.0);
		#else
		return PS_calcLR(P * pix, P);
		#endif
	}

	#if !DX9_DX10_Toggle && !Use_2D_Plus_Depth
	//The same eye pixel, mesh only. Any march in it drops the pixel, a drawn one marks the mask.
	void IL_Eyes_Mesh_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0, out float Mask : SV_Target1)
	{
		MW_Part = 1;
		Color = IL_Eyes_PS(position, texcoord);
		if(MW_Drop)
			discard;
		Mask = 1.0;
	}

	//The eye pixel for the px the mesh left, the march
	float4 IL_Eyes_Rest_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
		[branch]
		if(tex2Dfetch(Sampler_IL_Mask, int2(position.xy)).x > 0.5)
			discard;
		return IL_Eyes_PS(position, texcoord);
	}
	#endif
	#if Virtual_Reality_Mode
	void CB_Recon_IL(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 Left : SV_Target0, out float4 Right : SV_Target1)
	{
		int Lay = IL_Layout();
		float2 P = floor(position.xy);
		float3 C = tex2Dlod(Sampler_IL_Eyes, float4(IL_Eyes_TC(position.xy), 0, 0)).rgb;
		bool Pattern_Type = fmod(Lay == 1 ? P.y : Lay == 2 ? P.x : P.x + P.y, 2.0);
		Left  = float4(Pattern_Type ? C : float3(0.0, 0.0, 0.0), 1.0);
		Right = float4(Pattern_Type ? float3(0.0, 0.0, 0.0) : C, 1.0);
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
		float Average_ZPD = Blur_Ex(texcoord).x;
		float Average_D = Dilate3x3(SamplerzBufferN_L,texcoord, Alpha_Channel_UI ? 4.0f : 3.0f); //?: on the mip only. On the calls it ran both.
		float Detect_Popout = tex2Dlod(SamplerzBufferN_L,float4(texcoord,0,1)).x < 0;
	
		const int Num_of_Values = 8; //8 array values in total that map to the texture's width. Will be forced to expand if I need more
		float Storage_Array_A[Num_of_Values] = { tex2D(SamplerDMN,0).x,                               //0.0625 //TL DM Fade_in_out
		                                         tex2D(SamplerDMN,1).x,                               //0.1875 //BR DM Fade Level 0
		                                         tex2D(SamplerDMN,int2(0,1)).x,                       //0.3125 //BL DM Fade Level 1
		                                         Corner_L(0),                                         //0.4375 //TL L  Luma Adaptation
		                                         Corner_L(1),                                         //0.5625 //BR L  AltWeapon_Fade
		                                         Corner_L(float2(0,1)),                               //0.6875 //BL L  Weapon_ZPD_Fade
		                                         Corner_L(float2(3 * BUFFER_RCP_WIDTH, 0)),           //0.8125 //TL L  next to it, Popout Detection
		                                         Corner_L(float2(1 - 3 * BUFFER_RCP_WIDTH, 0))};      //0.9375 //TR L  next to it, Fade Level 6 (ZPD Scaler7)
		//LBDetection seems to be causing issues with TC_SP.xy.
		float Storage_Array_B[Num_of_Values] = { LBDetection(),                                       //0.0625 //No corner, LBDetection
		                                         tex2D(SamplerDMN,int2(1,0)).x,                       //0.1875 //TR DM Fade Level 2
		                                         tex2D(SamplerDMN,int2(1,0)).y,                       //0.3125 //TR DM Fade Level 3
		                                         tex2D(SamplerDMN,0).y,                               //0.4375 //TL DM Fade Level 4
		                                         tex2D(SamplerDMN,1).y,                               //0.5625 //BR DM Fade Level 5
		                                         Corner_L(float2(1,0)),                               //0.6875 //TR L  Weapon Hit, the Switch for ABWS
		                                         tex2D(SamplerDMN,int2(0,1)).y,                       //0.8125 //BL DM Fade Level N
		                                         Corner_L(float2(3 * BUFFER_RCP_WIDTH, 1))};          //0.9375 //BL L  next to it, OverShoot_Fade
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

	#if Virtual_Reality_Mode
	float4 Direction(float2 texcoord,float dx, float dy, int Switcher) //Load Pixel
	{
		float4 TC = float4(texcoord + float2(dx, dy), 0, 0);
		return Switcher == 1 ? tex2Dlod(Sampler_SD_CB_R, TC) : tex2Dlod(Sampler_SD_CB_L, TC);
	}
	
	//Rebuilds the eye's missing checkerboard pixels: 1 from up and down, 2 from left and right, 0 both, weighted by how alike they are
	float4 differentialBlend(float2 texcoord, int Switcher, int Set_Direction)
	{    
		if ((texcoord.x > 1 || texcoord.x < 0) || (texcoord.y > 1 || texcoord.y < 0))
			return 0;

		float4 Center = Direction(texcoord, 0.0, 0.0, Switcher), Vert = 0.0, Horz = 0.0;
		float Vert_W = 0.0, Horz_W = 0.0;
		[branch]
		if(Set_Direction != 2)
		{
			float4 Up = Direction(texcoord, 0.0, -pix.y, Switcher), Down = Direction(texcoord, 0.0, pix.y, Switcher);
			Vert = (Up + Down) * 0.5;
			Vert_W = colorDiffBlend(Up.rgb, Down.rgb);
		}
		[branch]
		if(Set_Direction != 1)
		{
			float4 Left = Direction(texcoord, -pix.x, 0.0, Switcher), Right = Direction(texcoord, pix.x, 0.0, Switcher);
			Horz = (Left + Right) * 0.5;
			Horz_W = colorDiffBlend(Left.rgb, Right.rgb);
		}

		return Center + (Set_Direction == 1 ? Vert : Set_Direction == 2 ? Horz : (Vert * Vert_W + Horz * Horz_W) * rcp(Vert_W + Horz_W));
	}
	#endif

	////////////////////////////////////////////////////////////////////Logo////////////////////////////////////////////////////////////////////////////
	//On screen text: each character is a 4x5 bitmap in one number. _SP is a space, the rest name the character.
	static const float _A = 0x69f99, _B = 0x79797, _C = 0xe111e, _D = 0x79997, _E = 0xf171f, _F = 0xf1711, _G = 0xe1d96,
	                   _H = 0x99f99, _I = 0xf444f, _J = 0x88996, _K = 0x95359, _L = 0x1111f, _M = 0x9fb99, _N = 0x9bd99,
	                   _O = 0x69996, _P = 0x79711, _Q = 0x69b5a, _R = 0x79759, _S = 0xe1687, _T = 0xf4444, _U = 0x99996,
	                   _V = 0x999a4, _W = 0x999f9, _X = 0x99699, _Y = 0x99e8e, _Z = 0xf843f, _0 = 0x6bd96, _1 = 0x46444,
	                   _2 = 0x6942f, _3 = 0x69496, _4 = 0x99f88, _5 = 0xf1687, _6 = 0x61796, _7 = 0xf8421, _8 = 0x69696,
	                   _9 = 0x69e84, _AP = 0x66400, _PI = 0x0faa9, _US = 0x0000f, _HY = 0x00600, _TI = 0x0a500, _PL = 0x02720,
	                   _EQ = 0x0f0f0, _SL = 0x08421, _EX = 0x33303, _QU = 0x69404, _CM = 0x00032, _FS = 0x00002, _QT = 0x55000,
	                   _SP = 0x00000, _CO = 0x00202, _LP = 0x42224, _RP = 0x24442;

	//One character: steps Pos by Shift, then 1 where its bitmap is lit at TC.
	float drawChar(float Char, inout float2 posXY, float2 charsize, float2 TC, float shift)
	{
		posXY.x += shift;
		float2 Cell = (TC - posXY) / charsize, Px = floor(Cell * float2(4, 5));
		float Bit = fmod(floor(Char * exp2(-(4.0 * Px.y + Px.x))), 2.0);
		return all(Cell >= 0.0) && all(Cell < 1.0) ? Bit : 0.0;
	}

	//Warning and logo text, one array per line.
	static const float T_DSW[50] = { _C,_H,_E,_C,_K,_SP,_D,_E,_P,_T,_H,_SL,_A,_D,_D,_US,_O,_N,_SP,_O,_P,_T,_I,_O,_N,_S,_CO,_SP,_C,_O,_P,_Y,_SP,_D,
	                                 _E,_P,_T,_H,_SP,_C,_L,_E,_A,_R,_SL,_F,_R,_A,_M,_E }; //CHECK DEPTH/ADD_ON OPTIONS: COPY DEPTH CLEAR/FRAME
	static const float T_ARW[28] = { _C,_H,_E,_C,_K,_SP,_A,_S,_P,_E,_C,_T,_SP,_R,_A,_T,_I,_O,_SP,_I,_N,_SP,_A,_D,_D,_US,_O,_N }; //CHECK ASPECT RATIO IN ADD_ON
	static const float T_EDW[17] = { _E,_M,_U,_L,_A,_T,_O,_R,_SP,_D,_E,_T,_E,_C,_T,_E,_D }; //EMULATOR DETECTED
	static const float T_PEW[23] = { _D,_I,_S,_A,_B,_L,_E,_SP,_C,_A,_SL,_M,_B,_SL,_D,_O,_F,_SL,_G,_R,_A,_I,_N }; //DISABLE CA/MB/DOF/GRAIN
	static const float T_DAA[28] = { _C,_H,_E,_C,_K,_SP,_T,_A,_A,_SL,_M,_S,_A,_A,_SL,_D,_L,_S,_S,_SL,_F,_S,_R,_SL,_X,_E,_S,_S }; //CHECK TAA/MSAA/DLSS/FSR/XESS
	static const float T_DRS[34] = { _D,_I,_S,_A,_B,_L,_E,_SP,_D,_Y,_N,_A,_M,_I,_C,_SP,_R,_E,_S,_O,_L,_U,_T,_I,_O,_N,_SP,_S,_C,_A,_L,_I,_N,_G }; //DISABLE DYNAMIC RESOLUTION SCALING
	static const float T_WPW[10] = { _S,_E,_T,_SP,_W,_E,_A,_P,_O,_N }; //SET WEAPON
	static const float T_NDW[8] = { _N,_E,_T,_SP,_P,_L,_A,_Y }; //NET PLAY
	static const float T_FOV[7] = { _S,_E,_T,_SP,_F,_O,_V }; //SET FOV
	static const float T_RHW[9] = { _R,_E,_A,_D,_SP,_H,_E,_L,_P }; //READ HELP
	static const float T_NPW[10] = { _N,_O,_SP,_P,_R,_O,_F,_I,_L,_E }; //NO PROFILE
	static const float T_NCW[12] = { _I,_N,_C,_O,_M,_P,_A,_T,_I,_B,_L,_E }; //INCOMPATIBLE
	static const float T_NFM[9] = { _N,_E,_E,_D,_S,_SP,_M,_O,_D }; //NEEDS MOD
	static const float T_NVK[10] = { _N,_E,_E,_D,_S,_SP,_D,_X,_V,_K }; //NEEDS DXVK
	static const float T_NDG[15] = { _N,_E,_E,_D,_S,_SP,_D,_G,_V,_O,_O,_D,_O,_O,_2 }; //NEEDS DGVOODOO2
	static const float T_OSW[21] = { _O,_V,_E,_R,_W,_A,_T,_C,_H,_FS,_F,_X,_H,_SP,_M,_I,_S,_S,_I,_N,_G }; //OVERWATCH.FXH MISSING
	static const float T_LOGO_A[8] = { _D,_E,_P,_T,_H,_3,_D,_FS }; //DEPTH3D.
	static const float T_LOGO_B[4] = { _I,_N,_F,_O }; //INFO
	static const float T_DBN[24] = { _N,_E,_E,_D,_S,_SP,_F,_U,_L,_L,_SP,_F,_O,_R,_M,_A,_T,_SP,_A,_D,_D,_HY,_O,_N }; //NEEDS FULL FORMAT ADD-ON

	//One line of text into Txt. Steps by Sx, by Se from character Ei on. Rows the line does not cover skip it.
	#define TEXT_LINE(Str, Len, Pos, CSize, Sx, Se, Ei) \
		[branch] if(TC.y >= (Pos).y && TC.y < (Pos).y + (CSize).y) \
		{ \
			float2 Char_Pos = Pos; \
			SD_UNROLL for(int c = 0; c < Len; c++) \
				Txt += drawChar(Str[c], Char_Pos, CSize, TC, c == 0 ? 0 : c >= Ei ? Se : Sx); \
		}
	//A warning line, InfoOut's size and step.
	#define TEXT_ROW(Str, Len, Pos) TEXT_LINE(Str, Len, Pos, Size, Step.x, Step.x, Len)

	//Whether the post pass (USMOut) runs. When it is skipped StereoOut writes alpha = max(r, g, b) itself.
	bool Post_Runs()
	{
		#if DoubleBuffer_Mode && !Virtual_Reality_Mode
		return false;//No post passes here.
		#else
		#if !Virtual_Reality_Mode
		bool Sharp_On = Sharpen_Power > 0 && (Anaglyph_Mode || Stereoscopic_Mode != 4);
		#else
		bool Sharp_On = Sharpen_Power > 0 && Stereoscopic_Mode != 2 && !(Menu_Open && (VR_Menu_Checkerboard || Super3D_Mode));
		#endif
		return (Infill_Blur != 0 && POST_INFILL_OK) || (Show_Infill_Mask && POST_MASK_OK) || POST_VM3_SHOW || Sharp_On;
		#endif
	}

	//Frame Packed: only the last pass that draws squeezes each half to its spot, with a black bar between them.
	bool FP_Bar(inout float4 position, inout float2 texcoord, bool Last)
	{
		const float Top_End = 0.5 - 0.020408163, Bot_Beg = 0.5 + 0.020408163;
		bool Bar = false;
		[branch]
		if(Frame_Packed && Stereoscopic_Mode == 1 && Last)
		{
			Bar = texcoord.y > Top_End && texcoord.y < Bot_Beg;
			texcoord.y = texcoord.y <= Top_End ? texcoord.y / Top_End * 0.5 : 0.5 + (texcoord.y - Bot_Beg) / (1.0 - Bot_Beg) * 0.5;
			position.y = floor(texcoord.y * BUFFER_HEIGHT) + 0.5;
		}
		return Bar;
	}
	//With no post pass, alpha carries the colour's brightest channel
	float4 Post_Alpha(float4 C)
	{
		if(!Post_Runs())
			C.a = max(C.r, max(C.g, C.b));
		return C;
	}

	#if DoubleBuffer_Mode && !Virtual_Reality_Mode
	//Double Buffer: the 3D goes out through DoubleTex to an add-on, and the screen stays flat, so a short note at the
	//top middle says what is needed.
	float3 DB_Notice(float3 C, float2 texcoord)
	{
		const float2 Size = float2(.00875, .0125) * 1.1, Pos = float2(0.5 - 24 * 0.011 * 0.5, 0.955);
		float2 TC = float2(texcoord.x, 1 - texcoord.y);
		float Txt = 0;

		[branch]
		if(TC.y >= Pos.y - 0.005 && TC.y <= Pos.y + Size.y + 0.005)
		{
			TEXT_LINE(T_DBN, 24, Pos, Size, 0.011, 0.011, 24)
			//A dark band behind the text so it reads on any image.
			if(TC.x > Pos.x - 0.005 && TC.x < Pos.x + 24 * 0.011 + 0.005)
				C *= 0.35;
			C = lerp(C, HDR_WHITE, saturate(Txt));
		}
		return C;
	}
	#endif
	#if !Use_2D_Plus_Depth
		#if Virtual_Reality_Mode	
		///////////////////////////////////////////////////////////Barrel Distortion///////////////////////////////////////////////////////////////////////
		int VR_Stereoscopic_Mode()
		{
			return Menu_Open && (VR_Menu_Checkerboard || Super3D_Mode) ? 3 : Stereoscopic_Mode;
		}
		
		float4 Circle(float4 C, float2 TC)
		{
			float2 C_A = float2(1.0f,1.1375f), midHV = (C_A-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;
		
			float2 uv = float2((TC.x*C_A.x)-midHV.x,(TC.y*C_A.y)-midHV.y);
		
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
			p = 2.0f * p - 1.0f;
			// Calculate Zoom
			p *= Theater_Mode ? 0.8 : 0.83;
			// Calculate l2 norm
			float r2 = p.x*p.x + p.y*p.y;
			float r4 = r2 * r2;
			// Forward transform
			p *= 1.0 + k1 * r2 + k2 * r4;
			// De-normalize to the original range
			p = (p + 1.0) * 0.5;
		
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
				float2 TCL = texcoord, TCR = texcoord, TC = 1;
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
					Color = tex2D(SamplerInfo, TC ? TCL : TCR).x;//One read: point, no mips.
					
					//Only this half's eye is read, Barrel Distortion bends each colour on its own
					float2 TCE = TC ? TCL : TCR;
					if(VR_Stereoscopic_Mode() == 0 || VR_Stereoscopic_Mode() == 1)
					{
						#if DoubleBuffer_Mode
							// No Barrel Distortion or Circle here, by design.
							// DoubleTex already holds the full res SBS image, SBS matches it 1:1
							float2 db_uv = VR_Stereoscopic_Mode() == 0
								? texcoord
								: (texcoord.y < 0.5
									? float2(texcoord.x * 0.5,       texcoord.y * 2.0)
									: float2(texcoord.x * 0.5 + 0.5, texcoord.y * 2.0 - 1.0));
							Color.rgb = tex2D(SamplerDouble, db_uv).rgb;
						#else
							//Same K for every colour bends once
							bool One_K = all(Polynomial_Colors_K1 == Polynomial_Colors_K1.x) && all(Polynomial_Colors_K2 == Polynomial_Colors_K2.x);
							[branch]
							if(Barrel_Distortion >= 1 && One_K)
							{
								float2 UV = BD(TCE, Polynomial_Colors_K1.x, Polynomial_Colors_K2.x);
								[branch]
								if(TC.x)
									Color.rgb = L(UV);
								else
									Color.rgb = R(UV);
								if(Barrel_Distortion == 2)
									Color.rgb = Circle(float4(Color.rgb, 1.0), TCE).rgb;
							}
							else if(Barrel_Distortion >= 1)
							{
								float2 UV_R = BD(TCE, Polynomial_Colors_K1.x, Polynomial_Colors_K2.x),
									   UV_G = BD(TCE, Polynomial_Colors_K1.y, Polynomial_Colors_K2.y),
									   UV_B = BD(TCE, Polynomial_Colors_K1.z, Polynomial_Colors_K2.z);
								[branch]
								if(TC.x)
									Color.rgb = float3(L(UV_R).r, L(UV_G).g, L(UV_B).b);
								else
									Color.rgb = float3(R(UV_R).r, R(UV_G).g, R(UV_B).b);
								if(Barrel_Distortion == 2)
									Color.rgb = Circle(float4(Color.rgb, 1.0), TCE).rgb;
							}
							else
							{
								[branch]
								if(TC.x)
									Color.rgb = L(TCE);
								else
									Color.rgb = R(TCE);
							}
						#endif
					}
					else
						Color.rgb = L(texcoord) + R(texcoord);
				#else // Super3D Mode
					float Y_Left = YCbCrLeft(texcoord).x;
					float Y_Right = YCbCrRight(texcoord).x;

					//Each quarter holds one eye's Cb or Cr at half size: top the left eye, bottom the right, Cb on the left, Cr on the right
					float2 Quad_UV = frac(texcoord * 2);
					float3 Quad_C;
					[branch]
					if(texcoord.y < 0.5)
						Quad_C = YCbCrLeft(Quad_UV);
					else
						Quad_C = YCbCrRight(Quad_UV);
					float CbCr = texcoord.x < 0.5 ? Quad_C.y : Quad_C.z;
					Color.rgb = Menu_Open ? L(texcoord) + R(texcoord) : float3(Y_Left,Y_Right,CbCr);
				#endif
				
				Color = Text_Helper ? Color.rgba + Color.w * HDR_WHITE : Color; //Blend Color
				
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
				
				#if BC_SPACE
				Color = N_To_BB(Color);
				#else
				Color = Color;
				#endif
				return Post_Alpha(Color.rgba);
			}
		#else
			float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
			{
				if(FP_Bar(position, texcoord, !Post_Runs() && USE_AA == 0))
					return float4(0, 0, 0, 1);
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
				Color = 0;
				[branch]
				if(Text_Helper || Post_Runs())//Only the text and the post alpha use it.
					Color = tex2Dlod(SamplerInfo, float4(TC ? TCL : TCR, 0, 0)).x;
				
				
					#if Anaglyph_Mode //Need to add blur here on the blue channel.	
						#if AG_RB_USM
						float4 AG;
						Anaglyph(position, texcoord, AG);
						Color.rgb = AG.rgb;
						#else
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
							#if !DX9_DX10_Toggle
							//Only Red-Blue blurs from neighbours and needs texSD_RL. The rest are mixed right here.
							float4 AG;
							Anaglyph(position, texcoord, AG);
							Color.rgb = AG.rgb;
							#else
							Color.rgb = tex2D(Sampler_SD_RL,texcoord).rgb;
							#endif
						}
						#endif
					#else
					float4 LR_Hole;
					#if DoubleBuffer_Mode
					//The 3D goes out through DoubleTex, so the screen shows the flat image.
					#if DX9_DX10_Toggle
				LR_Hole = float4(BB_Clamp(texcoord).rgb, 0);
				#else
				LR_Hole = float4(tex2D(BB_Mask, texcoord).rgb, 0);
				#endif
				#if BC_SPACE
				LR_Hole = BB_To_N(LR_Hole);
				#endif
					LR_Hole.rgb = DB_Notice(LR_Hole.rgb, texcoord);
					#elif IL_EYES
					//Old way: Out marched SbS, TnB and the rest itself, only interlaced read texIL_Eyes.
					//Now IL_Eyes_PS marches every mode and Out only reads it. IL_EYE_BUFFER 0 gives the old way.
					LR_Hole = tex2Dlod(Sampler_IL_Eyes, float4(IL_Eyes_TC(position.xy), 0, 0));
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
			
				Color = Text_Helper ? Color.rgba + Color.w * HDR_WHITE : Color; //Blend Color
				#if BC_SPACE
				Color = N_To_BB(Color);
				#else
				Color = Color;
				#endif
				
				#if !Anaglyph_Mode
				//Alpha is confidence. 1 is clean reprojection, lower is infilled hole.
				Color.a = 1.0 - LR_Hole.a;
				#endif

				return Post_Alpha(Color.rgba);
			}
		#endif
	#else
	float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
	{
			float Mouse_Toggle_Click = 1;
		
			float4 Out_C;
			if (Depth_Map_View == 2)
				Out_C = MouseCursor(float3(texcoord.xy,0), position.xy , Mouse_Toggle_Click, 0);
			else
				Out_C = texcoord.x < 0.5 ?  MouseCursor(float3(texcoord.xy * float2(2,1),0), position.xy , Mouse_Toggle_Click, 0) :
						(1-GetMixed(texcoord * float2(2,1) - float2(1.0, 0.0), 0).x) * HDR_WHITE;
			#if BC_SPACE
			Out_C = N_To_BB(Out_C);
			#endif
			return Post_Alpha(Out_C);
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
			C.rgb = lerp(C.rgb, float3(0.0, 1.0, 0.0) * HDR_WHITE, smoothstep(0.5, 0.9, C.a));
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
		bool   Left_Half = texcoord.x < 0.5;
		float4 eye;
		float2 E_E = 0;
		eye = Parallax(Left_Half ? -DLR.x : DLR.y, Left_Half ? TCL : TCR, Left_Half ? AI : -AI, E_E);

		// Vert_3D_Pinball post swap, same as PS_calcLR.
		if (Vert_3D_Pinball)
			eye.xyz = eye.yxz;

		// MouseCursor blend, same as PS_calcLR.
		float4 C = MouseCursorS(eye.xyz, eye.w, position.xy, 1, 0, E_E);
		//Show Infill Mask, as the non VR path above.
		if(Show_Infill_Mask)
			C.rgb = lerp(C.rgb, float3(0.0, 1.0, 0.0) * HDR_WHITE, smoothstep(0.5, 0.9, C.a));
		return float4(C.rgb, 1.0);
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
		float2 TC = float2(texcoord.x, 1 - texcoord.y);
		float Txt = 0;
		//Warnings, a line each from the top left, and one at the bottom left
		const float2 Size = float2(.00875, .0125) * 1.1, Step = float2(0.01, 0.009) * 1.1;
		#if DSW //Check Depth/Add-on Options: Copy Depth Clear/Frame
		TEXT_ROW(T_DSW, 50, float2(0.009, 0.9725))
		#endif
		#if ARW //Check Aspect Ratio In Add_on
		TEXT_ROW(T_ARW, 28, float2(0.009, 0.955))
		#endif
		#if EDW //Emulator Detected
		TEXT_ROW(T_EDW, 17, float2(0.009, 0.9375))
		#endif
		#if PEW //Disable CA/MB/DoF/Grain
		TEXT_ROW(T_PEW, 23, float2(0.009, 0.920))
		#endif
		#if DAA //Check TAA/MSAA/DLSS/FSR/XeSS
		TEXT_ROW(T_DAA, 28, float2(0.009, 0.9025))
		#endif
		#if DRS //Disable Dynamic Resolution Scaling
		TEXT_ROW(T_DRS, 34, float2(0.009, 0.885))
		#endif
		#if WPW //Set Weapon
		TEXT_ROW(T_WPW, 10, float2(0.009, 0.8675))
		#endif
		#if NDW //Net Play
		TEXT_ROW(T_NDW, 8, float2(0.009, 0.850))
		#endif
		#if FOV //Set FoV
		TEXT_ROW(T_FOV, 7, float2(0.009, 0.8325))
		#endif
		#if RHW //Read Help
		TEXT_ROW(T_RHW, 9, float2(0.894, 0.9725))
		#endif
		#if NPW //No Profile
		TEXT_ROW(T_NPW, 10, float2(0.009, 0.018))
		#endif
		#if NCW //Incompatible
		TEXT_ROW(T_NCW, 12, float2(0.009, 0.018))
		#endif
		#if NFM //Needs Mod
		TEXT_LINE(T_NFM, 9, float2(0.009, 0.018), Size, Step.x, Step.y, 8)
		#endif
		#if NVK && !ISVK //Need DXVK
		TEXT_ROW(T_NVK, 10, float2(0.009, 0.018))
		#endif
		#if NDG && !ISDX //Use DGVOODOO2
		TEXT_ROW(T_NDG, 15, float2(0.009, 0.018))
		#endif
		#if OSW //Overwatch.fxh Missing
		TEXT_ROW(T_OSW, 21, float2(0.009, 0.018))
		#endif
		//Depth3D.Info logo, bottom right
		TEXT_LINE(T_LOGO_A, 8, float2(0.862, 0.018), float2(.00875, .0125) * 1.375, 0.01 * 1.375, 0.008 * 1.375, 6)
		TEXT_LINE(T_LOGO_B, 4, float2(0.960, 0.018), float2(.00875, .0125) * 0.75, 0.01 * 0.75, 0.01 * 0.75, 4)
		float4 Out = Txt ? (1-texcoord.y*50.0+48.85)*texcoord.y-0.500: 0;

		const int Num_of_Values = 9; 


		//Set an average size for the number of lines needed in texture storage.
		float Grid = floor(texcoord.x * BUFFER_WIDTH * BUFFER_RCP_WIDTH * Num_of_Values);
		
		Grid = ZDP_Array[int(fmod(Grid,Num_of_Values))];
		
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
		#if BC_SPACE
		float3 Raw_C = centerColor.rgb;
		bool Ran = false;
		//HDR sharpens in the SDR look
		centerColor.rgb = HDR_Look(centerColor.rgb, false);
		#endif

		#if !Virtual_Reality_Mode
		if (Sharp_This > 0 && (Anaglyph_Mode || Stereoscopic_Mode != 4)) //Blocked in CB mode
		#else
		if (Sharp_This > 0 && Stereoscopic_Mode != 2 && !(Menu_Open && (VR_Menu_Checkerboard || Super3D_Mode))) //Blocked in CB mode
		#endif
		{
			#if BC_SPACE
			Ran = true;
			#endif
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
					#if BC_SPACE
					nc.rgb = HDR_Look(nc.rgb, false);
					#endif
					factor = normpdf3(nc.rgb-centerColor.rgb, SIGMA);
					Z += factor;
					final_color += factor * nc;
					mn = min(mn, LI(nc.rgb));
					mx = max(mx, LI(nc.rgb));
				}
			}
			
			#if BC_SPACE
			final_color = max(final_color/Z, 0.0);
			#else
			final_color = saturate(final_color/Z);
			#endif
			
			mn = min(mn, LI(final_color.rgb));
			mx = max(mx, LI(final_color.rgb));
			
			// Smooth minimum distance to signal limit divided by smooth max.
			float rcpM = rcp(max(mx, 1e-5)), CAS_Mask;
			
			// Shape the sharpening amount with the mask
			CAS_Mask = saturate(min(mn, 2.0 - mx) * rcpM);
			
			float Mask_Two = 1-LI(centerColor.rgb);
			#if BC_SPACE
			Mask_Two = saturate(Mask_Two);
			#endif
			
			float3 Sharp_Out = centerColor.rgb + (centerColor.rgb - final_color.rgb) * Sharp_This;
			#if !Virtual_Reality_Mode
	        	centerColor.rgb = lerp(centerColor.rgb,Sharp_Out,CAS_Mask * Mask_Two);
			#else
	        	//Consideration for Super3D mode
				centerColor.rgb = Super3D_Mode ? lerp(centerColor.rgb,float3(Sharp_Out.rg,centerColor.b),CAS_Mask) : lerp(centerColor.rgb,Sharp_Out,CAS_Mask);
			#endif	        
		}
		#if BC_SPACE
		//Only the sharpen change goes back, so values outside 0 to 1 stay
		centerColor.rgb = Ran ? Raw_C + HDR_Back(max(centerColor.rgb, 0.0)) - HDR_Back(HDR_Look(Raw_C, false)) : Raw_C;
		#endif
		return centerColor;
	}	

	//Mask from back buffer alpha, tuned on 2 bits.
	float4 Infill_Blur_Post_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		float4 BB = Infill_Blur_Post(position, texcoord, 0, false, BB_Clamp(texcoord));
		//Mask overlay where the blur did not draw it.
		if(Show_Infill_Mask && POST_MASK_OK && !MEM_INFILL && !(POST_INFILL_OK || POST_VM3_SHOW))
		{
			float4 Bnd;
			float2 Stp;
			float  Eye;
			Post_Layout(texcoord, Bnd, Stp, Eye);
			BB.rgb = lerp(BB.rgb, HDR_Back(float3(0.0,1.0,0.0)), Mask_AA(texcoord, Mask_A(BB.a), Bnd, Stp, 0, false));
		}
		return BB;
	}

	//Experimental.
	float4 Infill_USM_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		if(FP_Bar(position, texcoord, USE_AA == 0))
			return float4(0, 0, 0, 1);
		float4 BB  = Infill_Blur_Post_PS(position, texcoord);
		float4 Raw = tex2Dlod(Live_Sampler, float4(texcoord, 0, 0));
		float3 Det = Sharp(Live_Sampler, texcoord, 1.0).rgb - Raw.rgb;
		#if AG_RB_USM
		//Red-Blue: blue blurred from its neighbours, not sharpened.
		[branch]
		if(Stereoscopic_Mode == Anaglyph_Selection(8))
		{
			float3 Blur_RB = 0.0;
			float2 BO = 1.2 * pix * max(1.0, BUFFER_HEIGHT / 1080.0);
			SD_UNROLL
			for (int y = -1; y <= 1; ++y)
			{
				SD_UNROLL
				for (int x = -1; x <= 1; ++x)
				{
					float weight = (x == 0 ? 0.375 : 0.3125) * (y == 0 ? 0.375 : 0.3125);
					Blur_RB += tex2Dlod(BB_Mask, float4(texcoord + float2(x, y) * BO, 0, 0)).rgb * weight;
				}
			}
			BB.b = Blur_RB.b;
			Det.b = 0.0;
		}
		#endif
		#if BC_SPACE
		return float4(BB.rgb + Det, BB.a);
		#else
		#if !Virtual_Reality_Mode && !Anaglyph_Mode && !Use_2D_Plus_Depth
		float Conf = BB.a;
		#else
		float Conf = 1.0;
		#endif
		return float4(BB.rgb + Det * Conf, max(BB.r, max(BB.g, BB.b)));
		#endif
	}

	#if AXAA_EXIST
	float4 SDAA_PS(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
	{
		if(FP_Bar(position, texcoord, true))
			return float4(0, 0, 0, 1);
		float4 Out;
		if(USE_AA == 1)
		{
			#if Anaglyph_Mode || Inficolor_3D_Emulator
			//One AXAA per eye on its own channels. Shared channels blend.
			float3 Lc, Rc;
			AG_Channels(Lc, Rc);
			float4 AL = AXAA_W(Live_Sampler, AXAA_F_Sampler, texcoord, BC_SPACE == 1, Lc, AXAA_Linear),
			       AR = AXAA_W(Live_Sampler, AXAA_F_Sampler, texcoord, BC_SPACE == 1, Rc, AXAA_Linear);
			Out = float4(lerp(AR.rgb, AL.rgb, Lc * rcp(max(Lc + Rc, 0.001))), max(AL.a, AR.a));
			#else
			Out = AXAA_W(Live_Sampler, AXAA_F_Sampler, texcoord, BC_SPACE == 1, 1.0, AXAA_Linear);
			#endif
		}
		else
			Out = tex2Dlod(Live_Sampler,float4(texcoord,0,0));
		return Out;	
	}
	#endif
	
	///////////////////////////////////////////////////////////////////Vertex Shaders///////////////////////////////////////////////////////////////////
	void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{// Vertex shader generating a triangle covering the entire screen
		texcoord.x = (id == 2) ? 2.0 : 0.0;
		texcoord.y = (id == 1) ? 2.0 : 0.0;
		position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
	}

	#if MEM_INFILL
	//Memory Infill: each pass draws on its own frame only
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

	#if !DX9_DX10_Toggle
	//Fade only changes with the shifted band and the column parity, so the 3 vertices make it once
	void Blur_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0,
				 out nointerpolation float4 Fade_A : TEXCOORD1, out nointerpolation float4 Fade_B : TEXCOORD2)
	{
		PostProcessVS(id, position, texcoord);
		//Outside the band, and in the band on an even column where the lower rows shift
		float3x3 F = Fade(0.0);
		float3x3 S = Fade(float2(0.0, 0.7));
		Fade_A = float4(F[0][0], F[0][1], F[0][2], F[1][0]);
		Fade_B = float4(F[1][1], F[1][2], F[2][0], S[1][1]);
	}

	//Mod_Z's fixed reads, once per vertex instead of once per pixel
	void ModZ_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0,
				 out nointerpolation float4 FR_0 : TEXCOORD1, out nointerpolation float4 FR_1 : TEXCOORD2,
				 out nointerpolation float4 FR_2 : TEXCOORD3, out nointerpolation float4 FR_3 : TEXCOORD4,
				 out nointerpolation float2 FR_W : TEXCOORD5)
	{
		PostProcessVS(id, position, texcoord);
		ModZ_Fixed_Reads(FR_0, FR_1, FR_2, FR_3, FR_W);
	}

	//DepthMap's fixed reads, once per vertex instead of once per pixel
	void DepthMap_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0,
					 out nointerpolation float4 DM_F : TEXCOORD1)
	{
		PostProcessVS(id, position, texcoord);
		DM_F = float4(Blur_N(float2(0,0.0625), 0).x, Blur_N(float2(0,0.5625), 0).x,
					  Auto_Scaler(), Avr_P(float2(0, 0.5625)).z);
	}
	#endif

	#if Inficolor_3D_Emulator || Anaglyph_Mode
	//A two triangle quad, 6 vertices
	void AG_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		texcoord = float2(id == 1 || id == 4 || id == 5 ? 1.0 : 0.0, id == 2 || id == 3 || id == 5 ? 1.0 : 0.0);
		position = float4(texcoord.x * 2.0 - 1.0, 1.0 - texcoord.y * 2.0, 0.0, 1.0);
		if(!Anaglyph_Fast && !AG_POST_BLUR)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif

	#if AG_EYE_C
	//The eye colours are only drawn while Infill Blur runs
	void AG_EyeC_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(!AG_POST_BLUR)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif

	#if AXAA_EXIST
	//Anti-Aliasing Off would only copy the back buffer onto itself, so draw nothing
	void SDAA_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		if(USE_AA == 0)
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}
	#endif

	//USMOut only runs for the infill blur, the mask overlay, sharpening or the Red-Blue blue blur
	void USM_VS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD0)
	{
		PostProcessVS(id, position, texcoord);
		#if AG_RB_USM
		if(!Post_Runs() && Stereoscopic_Mode != Anaglyph_Selection(8))
		#else
		if(!Post_Runs())//Same test StereoOut uses for the alpha.
		#endif
			position = float4(-2.0, -2.0, 0.0, 1.0);
	}

	technique Information_MW3D
	< 
	 ui_label = "Information";
	 hidden = true;
	 enabled = true;
	 timeout = 1500;
	 ui_tooltip = "Help Technique."; 
	>
	{
		pass Help
		{
			VertexShader = PostProcessVS;
			PixelShader = InfoOut;
			RenderTarget = Info_Tex;
		}
	}

	technique MeshWarp3D
	<
	 ui_label = "SuperDepth3D"; 
	 ui_tooltip = "Suggestion: You can enable the 'Performance Mode' checkbox in the bottom right of ReShade's main UI.\n"
								"Do this once you have set your 3D settings, of course."; 
	>
	{
		pass Average_Information
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Info;
			RenderTarget0 = texAvrN;
		}
		pass Blur_DepthBuffer
		{
			#if DX9_DX10_Toggle
			VertexShader = PostProcessVS;
			#else
			VertexShader = Blur_VS;
			#endif
			PixelShader = zBuffer_Blur;
			RenderTarget0 = texzBufferBlurN;
		}
		pass DepthBuffer
		{
			#if DX9_DX10_Toggle
			VertexShader = PostProcessVS;
			#else
			VertexShader = DepthMap_VS;
			#endif
			PixelShader = DepthMap;
			RenderTarget0 = texDMN;
			RenderTarget1 = texCN;
		}
		#if !DX9_DX10_Toggle //DX9 and DX10 never read texMiniReconBuffer, so the pass is skipped there.
		pass MiniReconstuction
		{
			VertexShader = PostProcessVS;
			PixelShader = MiniReconstructionPS;
			RenderTarget0 = texMiniReconBuffer;
		}
			#if Anti_Jitter_Mode && !MW_SCAN_OK //With the scan, MeshWarp_Tiles keeps it.
		pass MiniReconHold
		{
			VertexShader = PostProcessVS;
			PixelShader = MiniReconHoldPS;
			RenderTarget0 = texMiniReconHold;
		}
			#endif
		#endif
		pass Modzbuffer
		{
			#if DX9_DX10_Toggle
			VertexShader = PostProcessVS;
			#else
			VertexShader = ModZ_VS;
			#endif
			PixelShader = Mod_Z;
			RenderTarget0 = texzBufferN_L;
		}
		pass MixDepth
		{
			VertexShader = PostProcessVS;
			PixelShader = Mix_Z;
			RenderTarget0 = texzBufferN_M;
		}

		#if DX9_DX10_Toggle //Same chain as the other paths, on the two DX9 and DX10 buffers.
		pass ReconstructionDX9_DX10
		{
			VertexShader = PostProcessVS;
			PixelShader = ReconstructionDX9_DX10PS;
			RenderTarget0 = texSmooth;
		}
		pass DepthAADX9_DX10
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthAAPS;
			RenderTarget0 = texzBufferN_M;
		}
		pass DepthSmoothDX9_DX10
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthSmoothPS;
			RenderTarget0 = texSmooth;
		}
		#endif

		#if !DX9_DX10_Toggle
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
			#if Anti_Jitter_Mode
			RenderTarget1 = AccBuffer;//TAA's history.
			#endif
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
		#if !Use_2D_Plus_Depth && !DX9_DX10_Toggle
		#if MW_SCAN_OK
		pass MeshWarp_Tiles //The tiles (mesh corners in w), Need's columns and the march count clear.
		{
			ComputeShader = MW_TileNeed_CS<64, 1>;
			DispatchSizeX = MW_TILES_GROUPS;
			DispatchSizeY = 1;
		}
		#else
		pass MeshWarp_Tiles //With the mesh's 8 px tiles, also its corners (w).
		{
			VertexShader = PostProcessVS;
			#if MW_SQ == 1
			PixelShader = MW_TC_PS;
			#else
			PixelShader = MW_Tile_PS;
			#endif
			RenderTarget0 = texMW_Tile;
		}
		#endif
		//The compute passes first, then the mesh draw.
		#if MW_SCAN_OK
		pass MeshWarp_Scan
		{
			ComputeShader = MW_Scan_CS<MW_SCAN_T, 1>;
			DispatchSizeX = 1;
			DispatchSizeY = BUFFER_HEIGHT;
		}
		pass MeshWarp_Packed_March
		{
			ComputeShader = MW_PMarch_CS<64, 1>;
			DispatchSizeX = MW_PM_GROUPS;
			DispatchSizeY = 1;
		}
		#endif
		#if MW_MESH_ON
		#if !MW_VIEW_ON
		pass MeshWarp_Map //And VM0's nearest wins map, in the same draw.
		{
			#if MW_SCAN_OK && MW_SQ == 1
			ComputeShader = MW_Map_CS<256, 1>;//Map Row: per row and eye, no raster.
			DispatchSizeX = 2;
			DispatchSizeY = MW_MAP_H;
			#else
			VertexCount = MW_TX * MW_TY * 24 * MW_SQ * MW_SQ;
			VertexShader = MW_VSB;
			PixelShader = MW_PSB;
			RenderTarget0 = texMW_Map;
			RenderTarget1 = texMW_MapN;
			ClearRenderTargets = true;
			BlendEnable0 = true;
			BlendOp0 = ADD;
			SrcBlend0 = SRCALPHA;
			DestBlend0 = INVSRCALPHA;
			BlendEnable1 = true;
			BlendOp1 = MAX;
			SrcBlend1 = ONE;
			DestBlend1 = ONE;
			#endif
		}
		#else
		pass MeshWarp_Map
		{
			VertexCount = MW_TX * MW_TY * 12 * MW_SQ * MW_SQ;
			VertexShader = MW_VS;
			PixelShader = MW_PS;
			RenderTarget0 = texMW_Map;
			RenderTarget1 = texMW_Wire;
			ClearRenderTargets = true;
		}
		pass MeshWarp_Map_Near //VM0 only.
		{
			VertexCount = MW_TX * MW_TY * 12 * MW_SQ * MW_SQ;
			VertexShader = MW_VSN;
			PixelShader = MW_PSN;
			RenderTarget0 = texMW_MapN;
			ClearRenderTargets = true;
			BlendEnable = true;
			BlendOp = MAX;
			SrcBlend = ONE;
			DestBlend = ONE;
		}
		#endif
		#endif
		#endif
		#if Inficolor_3D_Emulator || Anaglyph_Mode
		pass Fast_Eyes
		{
			VertexCount = 6;
			VertexShader = AG_VS;
			PixelShader = AG_Eyes_PS;
			RenderTarget0 = texAG_Eyes;
		}
		#if AG_EYE_C
		pass Eye_Colors
		{
			VertexShader = AG_EyeC_VS;
			PixelShader = AG_EyeC_PS;
			RenderTarget0 = texAG_EyeC;
		}
		#endif
		#endif
		#if IL_EYES
		#if !DX9_DX10_Toggle && !Use_2D_Plus_Depth
			//Mesh pass marks its px in texIL_Mask (cleared each frame), the eye pass skips them.
			//WARNING: never use the stencil here. It hung Banishers on DX12 (DEVICE_HUNG), counted or with a fixed ref.
		pass Interleaved_Eyes_Mesh
		{
			VertexShader = PostProcessVS;
			PixelShader = IL_Eyes_Mesh_PS;
			RenderTarget0 = texIL_Eyes;
			RenderTarget1 = texIL_Mask;
			ClearRenderTargets = true;
		}
		#endif
		pass Interleaved_Eyes
		{
			VertexShader = PostProcessVS;
			#if !DX9_DX10_Toggle && !Use_2D_Plus_Depth
			PixelShader = IL_Eyes_Rest_PS;
			#else
			PixelShader = IL_Eyes_PS;
			#endif
			RenderTarget0 = texIL_Eyes;
		}
		#endif
		#if Virtual_Reality_Mode || (Anaglyph_Mode && !AG_RB_USM) //Reconstruction with the eye buffer reads it directly.
		pass Muti_Mode_Reconstruction
		{
			VertexShader = PostProcessVS;
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


		#endif
	}
}
