////----------------------------------------//
///SuperDepth3D Overwatch Automation Header///
//----------------------------------------////
#define OVERWATCH "Overwatch v3.5.4\n"
//---------------------------------------OVERWATCH---------------------------------------//
// If you are reading this stop. Go away and never look back. From this point on if you  //
// still think it's is worth looking at this..... Then no one can save you or your soul. //
// You will be cursed with never enjoying any memes to their fullest potential.......... //
// Ya that's it. JK                                                                      //
// The name comes from this.                                                             //
// https://en.wikipedia.org/wiki/Overwatch_(military_tactic)                             //
// Since this File looks ahead and sends information the Main shader to prepare it self. //
//---------------------------------------------------------------------------------------//
// Special Thanks to CeeJay.dk for code simplification and guidance.                     //
// You can contact him here https://github.com/CeeJayDK                                  //
//----------------------------------------LICENSE----------------------------------------//
// ===================================================================================== //
// Overwatch is licenses under: Copyright (C) Depth3D - All Rights Reserved              //
//                                                                                       //
// Unauthorized copying of this file, via any medium is strictly prohibited              //
// Proprietary and confidential.                                                         //
//                                                                                       //
// You are allowed to obviously download this and use this for your personal use.        //
// Just don't redistribute this file unless I authorize it.                              //
//                                                                                       //
// Written by Jose Negrete <UntouchableBlueSky@gmail.com>, December 2019                 //
// ===================================================================================== //
//--------------------------------------Code Start---------------------------------------//

//Setup If Default_View_Mode is missing from shader.
#if exists "SuperDepth3D.fx" || exists "SuperDepth3D_VR+.fx"
	#define View_Value 1 
#else
	#define View_Value 6
#endif
//If it's Defined use the Defined Value.
#ifndef D_ViewMode 
    #define D_ViewMode View_Value  
#endif
//Check API
 //Vulkan: 0x20000
#if __RENDERER__ >= 0x20000 //Is Vulkan
	#define IS_VK 1
#else
	#define IS_VK 0
#endif

#if __RENDERER__ >= 0xc000 //Is DX12
	#define IS_DX12 1
#else
	#define IS_DX12 0
#endif

//SuperDepth3D Defaults                                 [Names]                                         [Key]
static const float ZPD_D = 0.025;                       //ZPD                                           | DA_X
static const float Depth_Adjust_D = 7.5;                //Depth Adjust                                  | DA_Y
static const int Depth_Linearization_D = 0;             //Linearization                                 | DA_W
static const int Depth_Flip_D = 0;                      //Depth Flip                                    | DB_X
static const float Auto_Depth_D = 0.1;                  //Auto Depth Range                              | DB_Z
static const int Weapon_Hand_D = 0;                     //Weapon Profile                                | DB_W

//Depth Offset
static const int Depth_Range_D = 0;                     //Depth Range Boost                             | DS_Y
static const float Offset_D = 0.0;                      //Offset                                        | DA_Z

//Barrel Distortion Fix
static const int Barrel_Distortion_Fix_D = 0;           // 0 | 1 : Off | On                             | BDF
static const float BD_K1_D = 0.0;                       //Barrel Distortion K1                          | DC_X
static const float BD_K2_D = 0.0;                       //Barrel Distortion K2                          | DC_Y
static const float BD_K3_D = 0.0;                       //Barrel Distortion K3                          | DC_Z
static const float BD_Zoom_D = 0.0;                     //Barrel Distortion Zoom                        | DC_W

//Size & Position Fix
static const int Size_Position_Fix_D = 0;               // 0 | 1 : Off | On                             | SPF
static const float HVS_X_D = 1.0;                       //Horizontal Size                               | DD_X
static const float HVS_Y_D = 1.0;                       //Vertical Size                                 | DD_Y
static const float HVP_X_D = 0;                         //Horizontal Position                           | DD_Z
static const float HVP_Y_D = 0;                         //Vertical Position                             | DD_W

//ZPD Boundary Adjustment
static const int ZPD_Boundary_Type_D = 0;               //ZPD Boundary Type                             | DE_X
static const float ZPD_Boundary_Scaling_D = 0.5;        //ZPD Boundary Scaling                          | DE_Y 
static const float ZPD_Boundary_Fade_Time_D = 0.25;     //ZPD Boundary Fade Time                        | DE_Z

//Balance Mode Toggle
static const int Balance_Mode_Toggle_D = 0;             // 0 | 1 : Off | On                             | BMT
static const float2 ZPD_Weapon_Boundary_Adjust_D = 0.0; //ZPD Weapon Boundary Adjust X Y                | DF_X
static const float Separation_D = 0.0;                  //ZPD Separation                                | DF_Y
static const float Manual_ZPD_Balance_D = 0.15;         //Manual Balance Mode Adjustment                | DF_Z

//Specialized Depth Trigger
static const int Specialized_Depth_Trigger_D = 0;       // 0 | 1                                        | SDT
static const float SDC_Offset_X_D = 0.0;                //Special Depth Correction Offset X             | DG_X
static const float SDC_Offset_Y_D = 0.0;                //Special Depth Correction Offset Y             | DG_Y
static const float Check_Depth_Limit_D = 0.0;           //Check Depth Limit                             | DG_W

//Auto Letter Box Correction
static const int Auto_Letter_Box_Correction_D = 0;      // 0 | 1 | 2 : Off | Hoz | Vert                 | LBC
static const float LB_Depth_Size_Offset_X_D = 1.0;      //Letter Box Depth Size Correction Offset X     | DH_X
static const float LB_Depth_Size_Offset_Y_D = 1.0;      //Letter Box Depth Size Correction Offset Y     | DH_Y
static const float LB_Depth_Pos_Offset_X_D = 0.0;       //Letter Box Depth Position Correction Offset X | DH_Z
static const float LB_Depth_Pos_Offset_Y_D = 0.0;       //Letter Box Depth Position Correction Offset Y | DH_W

//Letter Box Sensitivity
static const int LB_Sensitivity_D = 0;                  // 0 | 1 : Off / On                             | LBS 

//Auto Letter Box Masking
static const int Auto_Letter_Box_Masking_D = 0;         // 0 | 1 | 2 : Off | Hoz | Vert                 | LBM 

//Letter Box Reposition 
static const int Letter_Box_Reposition_D = 0;           // 0 | 1 : Default | Alt                        | LBR                                                                              
static const int Letter_Box_Elevation_D = 0;            // 0 | 1 | 2 : Default | low | Med              | LBE   
static const float LB_Masking_Offset_X_D = 1.0;         //LetterBox Masking Offset X                    | DI_X
static const float LB_Masking_Offset_Y_D = 1.0;         //LetterBox Masking Offset Y                    | DI_Y

//Weapon / World Near Depth Adjustments
static const float Weapon_Near_Depth_Push_D = 0.0;      //Weapon Near                           Near    | WND
static const float Weapon_Near_Depth_Max_D = 0.0;       //Weapon Near Depth                     Max     | DE_W
static const float4 Weapon_Edge_Correction_D = 0.0;     //Weapon Edge Correction & Weapon Near  Scale   | DF_W
static const float Weapon_Near_Depth_Min_D = 0.0;       //Weapon Near Depth                     Min     | DG_Z
static const float Weapon_Near_Depth_Trim_D = 0.25;     //Weapon Near Depth                     Trim    | DI_Z
static const float3 OIL_Weapon_Near_Depth_Min_D = 0.0;  //Weapon Near Depth                     Min LvL | DS_X

//Leftover Values
static const int Alternate_Frame_Detection_ZPD_D = 0;   //Alternate Frame Detection ZPD 0 | 1 : Off / On| AFD
static const float Range_Smoothing_D = 0;               //Range Smoothing                               | DJ_X
static const float Check_Weapon_Depth_Limit_A_D = 0.10; //Check Weapon Depth Limit Primary              | DJ_W

//FPS Focus
static const int FPS_Focus_Type_D = 0;                  //FPS Focus Type: World | Weapon | Mix          | FPS
static const int FPS_Focus_Method_D = 0;                //FPS Focus Method: Off | Switch | Hold         | DK_X
static const int EFO_Eye_Selection_D = 0;               //R/L Eye Selection: Both | Right Eye | Left Eye| DK_Y
static const int FPS_Weapon_Reduction_D = 0;            //FPS Weapon Depth: 15% | 20% | 25% | 30% | 35% | WRP
static const int EFO_Fade_Selection_D = 0;              //FPS World Depth: 10% | 20% | 30% | 40%| 50%   | DK_Z
static const int EFO_Fade_Speed_Selection_D = 1;        //Eye Fade Speed: 0% | 50% | 100% | 150% | 175% | DK_W
static const float Weapon_Distance_From_Bottom_D = 0.0; //Weapon Distance From Bottom [0 - 1]           | WFB

//SM Values
static const int SM_Toggle_Sparation_D = 1;             // 0 | 1 | 2 | 3                                | SMS
static const float SM_Tune_D = 0.75;                    //SM Tune                                       | DL_X
static const float De_Artifact_D = 0;                   //De-Artifact                                   | DL_Y
static const float De_Artifact_Scale_D = 0;             //De-Artifact Scale                             | DB_Y
static const float Compatibility_Power_D = 0.0;         //Compatibility Power                           | DL_Z
static const float SM_Perspective_D  = 0.05;            //SM Perspective                                | DL_W

//SM HQ Values
static const int SM_PillarBox_Detection_D = 0;          // 0 | 1 | 2                                    | SMP //To be Removed after a few Gens
static const int HQ_Mode_Toggle_D = 0;                  // 0 | 1 |                                      | HQT
static const int HQ_Tune_D = 4;                         //HQ Tune                                       | DM_X
static const int HQ_VRS_D = 1;                          //HQ Variable Rate Shading Off|Auto|High|Med|Low| DM_Y
static const int HQ_Smooth_D = 1;                       //HQ Smooth 0 - 6                               | DM_Z
static const float HQ_Trim_D = 0.0;                     //HQ Trim 0.0 - 0.5                             | DM_W

//Menu Detection
static const int Menu_Detection_Direction_D = 0;        // Off 0 | 1 | 2 | 3 | 4                        | MDD
static const int Menu_A_C_To_C_Only_D = 0;              // Off 0 | 1                                    | MAC
static const float4 Pos_XY_XY_A_B_D = 0;                //Position A XY B XY                            | DN_X
static const float4 Pos_XY_XY_C_D_D = 0;                //Position C XY D XY                            | DN_Y
static const float4 Pos_XY_XY_E_F_D = 0;                //Position E XY F XY                            | DN_Z
static const float4 Menu_Size_Adjust_D = 0;             //Menu Size Main ABC | D | E | F                | DN_W
static const float4 Menu_Detection_Type_D = 1000.0;     //Menu Detection Type                           | DJ_Y
static const float3 Match_Threshold_D = 1000.0;         //Match Threshold                               | DJ_Z

//Multi Menu Detection
static const int Multi_Menu_Detection_D = 0;            // Off 0 | 1 | 2 | 3 | 4                        | MMD
static const int Multi_Menu_Selection_D = 0;            // Set from 0-1 to 29-30                        | MMS
static const int Multi_Menu_Leniency_D = 0;             // Off 0 | 1 | 2 | 3 | 4                        | MML
//Sub Block 1
static const float4 Pos_XY_XY_AA_D = 0;                 //Position A XY A XY                            | DO_X
static const float4 Pos_XY_XY_AB_D = 0;                 //Position A XY B XY                            | DO_Y
static const float4 Pos_XY_XY_BB_D = 0;                 //Position B XY B XY                            | DO_Z
static const float4 Simple_Menu_Tresh_AB_D = 1000;      //Simple Manu Tresh For A & B                   | DO_W

static const float4 Pos_XY_XY_CC_D = 0;                 //Position C XY C XY                            | DP_X
static const float4 Pos_XY_XY_CD_D = 0;                 //Position C XY D XY                            | DP_Y
static const float4 Pos_XY_XY_DD_D = 0;                 //Position D XY D XY                            | DP_Z
static const float4 Simple_Menu_Tresh_CD_D = 1000;      //Simple Manu Tresh For C & D                   | DP_W
//Sub Block 2
static const float4 Pos_XY_XY_EE_D = 0;                 //Position E XY E XY                            | DQ_X
static const float4 Pos_XY_XY_EF_D = 0;                 //Position E XY F XY                            | DQ_Y
static const float4 Pos_XY_XY_FF_D = 0;                 //Position F XY F XY                            | DQ_Z
static const float4 Simple_Menu_Tresh_EF_D = 1000;      //Simple Manu Tresh For E & F                   | DQ_W

static const float4 Pos_XY_XY_GG_D = 0;                 //Position G XY G XY                            | DR_X
static const float4 Pos_XY_XY_GH_D = 0;                 //Position G XY H XY                            | DR_Y
static const float4 Pos_XY_XY_HH_D = 0;                 //Position H XY H XY                            | DR_Z
static const float4 Simple_Menu_Tresh_GH_D = 1000;      //Simple Manu Tresh For G & H                   | DR_W
//Sub Block 3
static const float4 Pos_XY_XY_II_D = 0;                 //Position I XY I XY                            | DU_X
static const float4 Pos_XY_XY_IJ_D = 0;                 //Position I XY J XY                            | DU_Y
static const float4 Pos_XY_XY_JJ_D = 0;                 //Position J XY J XY                            | DU_Z
static const float4 Simple_Menu_Tresh_IJ_D = 1000;      //Simple Manu Tresh For I & J                   | DU_W

static const float4 Pos_XY_XY_KK_D = 0;                 //Position K XY K XY                            | DV_X
static const float4 Pos_XY_XY_KL_D = 0;                 //Position K XY L XY                            | DV_Y
static const float4 Pos_XY_XY_LL_D = 0;                 //Position L XY L XY                            | DV_Z
static const float4 Simple_Menu_Tresh_KL_D = 1000;      //Simple Manu Tresh For K & L                   | DV_W
//Sub Block 4
static const float4 Pos_XY_XY_MM_D = 0;                 //Position M XY M XY                            | DX_X
static const float4 Pos_XY_XY_MN_D = 0;                 //Position M XY N XY                            | DX_Y
static const float4 Pos_XY_XY_NN_D = 0;                 //Position N XY N XY                            | DX_Z
static const float4 Simple_Menu_Tresh_MN_D = 1000;      //Simple Manu Tresh For M & N                   | DX_W

static const float4 Pos_XY_XY_OO_D = 0;                 //Position O XY O XY                            | DY_X
static const float4 Pos_XY_XY_OP_D = 0;                 //Position O XY P XY                            | DY_Y
static const float4 Pos_XY_XY_PP_D = 0;                 //Position P XY P XY                            | DY_Z
static const float4 Simple_Menu_Tresh_OP_D = 1000;      //Simple Manu Tresh For O & P                   | DY_W
//Simple Menu Detection A & B
static const int Simple_Menu_Detection_D = 0;           // Off 0 | 1 | 2                                | SMD
static const float4 A_SPos_XY_XY_A_B_D = 0;             //0 Position A XY B XY                          | DW_X
static const float2 A_SPos_XY_C_D = 0;                  //0 Position C XY                               | DW_Y
static const float4 A_Menu_Tresh_n_WC_D = 1000;         //0 Simple Manu Tresh For A,B,C & D             | DW_Z

static const float4 B_SPos_XY_XY_A_B_D = 0;             //1 Position A XY B XY                          | DT_X
static const float2 B_SPos_XY_C_D = 0;                  //1 Position C XY                               | DT_Y
static const float4 B_Menu_Tresh_n_WC_D = 1000;         //1 Simple Manu Tresh For A,B,C & D             | DW_W
//New Settings
static const int View_Mode_State_D = D_ViewMode;        //View Mode State [Do not Use 6]                | DS_Z
static const float Check_Weapon_Depth_Limit_B_D = 1.0;  //Check Weapon Depth Limit Secondary            | DS_W

static const float WH_Masking_Adjust_D = 0;             //Weapon Hand Masking Adjust      Needs WHM     | DT_Z
static const float2 Rescale_WH_Near_D = 0;              //Rescale amount & Cuttoff                      | DT_W

static const float Null_X_D = 0;                        //Null X                                        | DZ_X
static const float Null_Y_D = 0;                        //Null Y                                        | DZ_Y
static const float Null_Z_D = 0;                        //Null Z                                        | DZ_Z
static const float Null_W_D = 0;                        //Null W                                        | DZ_W

//Special Toggles 
static const int Resident_Evil_Fix_D = 0;               //Resident Evil Fix [Getting Phased Out]        | REF [Getting Phased Out]
static const int Over_Intrusion_Level_D = 0;            //Over Intrusion Level 0 | 1 | 2 | 3            | OIL
static const float4 Over_Intrusion_Fix_D = 0.0;         //Over Intrusion Fix                            | OIF
static const int Fast_Trigger_Mode_D = 0;               //Fast Trigger Mode for OIF                     | FTM
static const float4 OIF_Check_Depth_Limit_D = float4(0.5,0.0,0.0,0.0);//Over Intrusion Check Depth Limit| DI_W
static const float Filter_Mode_Modifire01_D = 0.0;      //Filter Mode Modifier                          | FMM
static const int Shift_Detectors_Up_D = 0;              //Shift Detectors Up                            | SDU

static const int HUD_Mode_Trigger_D = 0;                //HUD Mode Trigger                              | HMT
static const float HUDX_D = 0.0;                        //Heads Up Display Cut Off Point                | HMC
static const float HUDY_D = 0.5;                        //Heads Up Display Distance                     | HMD

//Special Toggles Defaults
static const int Auto_Balance_Ex_LvL_D = 2;             //Auto Balance Ex Level                         | ABE 
static const int Delay_Frame_Workaround_D = 0;          //Delay Frame Workaround                        | DFW
static const int Set_PopOut_D = 0;                      //Set Popout & Weapon Min                       | SPO
static const int WH_Masking_D = 0;                      //Set Weapon Hand Masking Power                 | WHM
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Special Toggles Warnings
static const int No_Profile_Warning_D = 0;              //No Profile Warning                            | NPW
static const int Needs_Fix_Mod_D = 0;                   //Needs Fix/Mod                                 | NFM
static const int Depth_Selection_Warning_D = 0;         //Depth Selection Warning                       | DSW
static const int Disable_Anti_Aliasing_D = 0;           //Disable Anti-Aliasing                         | DAA
static const int Network_Warning_D = 0;                 //Network Warning                               | NDW
static const int Disable_Post_Effects_Warning_D = 0;    //Disable Post Effects Warning                  | PEW
static const int Weapon_Profile_Warning_D = 0;          //Weapon Profile Warning                        | WPW
static const int Set_Game_FoV_D = 0;                    //Set Game FoV                                  | FOV 
static const int Needs_DXVK_D = 0;                      //Needs DXVK Wrapper                            | NVK
static const int Needs_DGVoodoo_Two_D = 0;              //Needs DGVooDoo2 DX12 Wrapper                  | NDG
static const int Aspect_Ratio_Warning_D = 0;            //Aspect Ratio Warning                          | ARW
static const int DRS_Warning_D = 0;                     //Dynamic Resolution Scaling Warning            | DRS
//Special Toggles Generic
static const int Read_Help_Warning_D = 0;               //Read Help Warning                             | RHW
static const int Emulator_Detected_Warning_D = 0;       //Emulator Detected Warning                     | EDW
static const int Not_Compatible_Warning_D = 0;          //Not Compatible Warning                        | NCW

//Weapon Setting are at the bottom of this file.

//Special Handling
#if exists "LEGOBatman.exe"                             //Lego Batman
	#define sApp 0xA100000
#elif exists "LEGOBatman2.exe"                          //LEGO Batman 2
	#define sApp 0xA100000
#elif exists "GameComponentsOzzy_Win32Steam_Release.dll"//Batman BlackGate
	#define sApp 0xA200000
#elif exists "AVP2.exe"                                 //Aliens VS Predator 2
	#define sApp 0xA300000
#elif exists "PrimalHunt.exe"                           //Aliens VS Predator 2 - Primal Hunt
	#define sApp 0xA400000
#else
	#define sApp __APPLICATION__
#endif

//Check for ReShade Version for 64bit game Bug.
#if !defined(__RESHADE__) || __RESHADE__ < 43000
	#if exists "ACU.exe"                                //Assassin's Creed Unity
		#define App 0xA0762A98
	#elif exists "BatmanAK.exe"                         //Batman Arkham Knight
		#define App 0x4A2297E4
	#elif exists "DOOMx64.exe"                          //DOOM 2016
		#define App 0x142EDFD6
	#elif exists "RED-Win64-Shipping.exe"               //DragonBall Fighters Z
		#define App 0x31BF8AF6
	#elif exists "HellbladeGame-Win64-Shipping.exe"     //Hellblade Senua's Sacrifice
		#define App 0xAAA18268
	#elif exists "TheForest.exe"                        //The Forest
		#define App 0xABAA2255
	#elif exists "MonsterHunterWorld.exe"               //Monster Hunter World
		#define App 0xDB3A28BD
	#elif exists "FarCry5.exe"                          //Farcry 5
		#define App 0xC150B805
	#else
		#define App sApp
	#endif
#else
	#define App sApp
#endif

//Game Hashes//
#if (App == 0xC19572DDF || App == 0xFBEE8027 || App == 0x2A19A7FA|| App == 0xCBFC0440 ) //PCSX2 | CEMU | Yuzu | Ryujinx
	#define RHW 1
	#define SPF 2
	#define HMT 1
	#define DSW 1
	#define EDW 1
#elif (App == 0xC753DADB )	//ES: Oblivion
    #define DA_X 0.0605
    #define DF_Y 0.025
    #define DA_Y 12.50
    //#define DE_X 1
    //#define DE_Y 0.8125
    //#define DE_Z 0.375	
	#define BMT 1    
	#define DF_Z 0.125 
	#define DG_Z 0.130//Min
    #define DI_Z 0.250//0.160//Trim
	#define FOV 1
#elif (App == 0x7B81CCAB || App == 0xFB9A99AB )	//BorderLands 2 & Pre-Sequel
	#define DA_Y 24.0
	//#define DA_Z 0.00025
	#define DA_X 0.035
	#define DF_Y 0.005
	#define DB_W 4
	#define DE_X 5
	#define DE_Y 0.625
	#define DE_Z 0.300
	#define DF_X float2(0.300,0.0)
	#define BMT 1
	#define DF_Z 0.175
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.575 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
	#define NDW 1
#elif (App == 0x697CDA52 )	//CoD:WaW
	#define DA_Y 12.5
	#define DB_W 14
#elif (App == 0x4383C12A || App == 0x239E5522 || App == 0x3591DE9C )	//CoD | CoD:UO | CoD:2
	#define DB_W 15
	#define RHW 1
#elif (App == 0x37BD797D )	//Quake DarkPlaces
	#define DA_Y 15.0
	#define WSM 4
	#define DB_W 17
#elif (App == 0x34F4B6C )	//Quake 2 XP *
	#define DB_W 18
#elif (App == 0xED7B83DE )	//Quake 4 #ED7B83DE
	#define DA_Y 15.0
	#define DB_W 19
#elif (App == 0x886386A )	//Metro Redux Games ****
	#define DA_Y 10.50 //11.0 // 12.5
	#define DA_X 0.05
    #define DF_Y 0.05 //0.03
    #define DB_Z 0.125
	#define DE_X 4
	//#define DE_Y 0.5
	#define DE_Z 0.375
	#define BMT 1    
	#define DF_Z 0.150 
	#define DG_Z 0.0125 //Min
    #define DI_Z 0.1000 //Trim	
	#define DB_W 21
    #define DF_X 0.250 
	#define DJ_W 0.250
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.550 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define FOV 1
#elif (App == 0xF5C7AA92 || App == 0x493B5C71 )	//S.T.A.L.K.E.R: Games
	#define DA_Y 10.0
	#define DB_W 26
#elif (App == 0xDE2F0F4D )	//Prey 2006 ****
	#define WSM 5
	#define DB_W 2
#elif (App == 0x36976F6D )	//Prey 2017
	#define DA_W 1
	#define DA_X 0.04625
	#define DA_Y 21.25
	#define DE_X 4
	#define DE_Y 0.5
	#define DE_Z 0.300
    #define DF_Y 0.05
	#define WSM 8
	#define OW_WP "Read Help & Change Me\0Custom WP\0Prey High Settings and <\0Prey 2017 Very High\0"
	#define RHW 1
	#define PEW 1
	#define WPW 1
#elif (App == 0xBF757E3A )	//Return to Castle Wolfenstein ****
	#define DA_Y 8.75
	#define WSM 5
	#define DB_W 5
#elif (App == 0x6D3CD99E ) //Blood 2 ****
	#define DA_X 0.105
	 
	#define DE_X 4
	//#define DE_Y 0.50
	#define DE_Z 0.475
	#define WSM 9
	#define DB_W 8
	#define OW_WP "Read Help & Change Me\0Custom WP\0Blood 2 All Weapons\0Blood 2 Bonus Weapons\0Blood 2 Former\0"
	#define WPW 1
	#define NFM 1
	#define RHW 1
#elif (App == 0xF22A9C7D || App == 0x5416A79D ) //SOMA
	#define DA_Y 56.0 //30.0 //25.5
	#define DA_X 0.0375
    #define DF_Y 0.050
	 
	#define DB_Z 0.075
	//#define DG_W 0.000 //Pop
	#define BMT 1
	#define DF_Z 0.05
	#define DA_Z -0.000125
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	//#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
	#define WSM 5
	#define DB_W 12
	#define DG_Z 0.250 //0.130
	#define DI_Z 0.155
	#define DE_X 4
	//#define DE_Y 0.375
	#define DE_Z 0.375
	#define DF_X float2(0.300,0.0)
	#define DJ_W 0.40 //TEMP
	#define FOV 1
	#define RHW 1
#elif (App == 0x6FB6410B ) //Cryostasis ****
	#define DA_Y 13.75
	#define WSM 5
	#define DB_W 13
#elif (App == 0x16B8D61A) //Unreal Gold with v227 ****
	#define DA_Y 17.5
	#define WSM 5
	#define DB_W 14
	#define HMC 0.534
	#define HMT 1
#elif (App == 0x5FCFB1E5 ) //Project Warlock
	#define DA_W 1
	#define DA_X 0.0475
    #define DF_Y 0.02375
	#define DA_Y 50.0
    #define DB_X 1
	 
	#define DE_X 4
	//#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W 0.125
	#define WSM 5
	#define DB_W 19
	#define DSW 1
#elif (App == 0x7DCCBBBD ) //Kingpin Life of Crime ****
	#define DA_Y 10.0
	 
	#define WSM 5
	#define DB_W 20
	#define RHW 1
#elif (App == 0x9C5C946E ) //EuroTruckSim2
    #define DB_X 1
	#define DA_X 0.06
    #define DF_Y 0.05
	#define DA_Y 7.0
	#define DA_Z -0.007
	#define WSM 5
	#define DB_W 21
	  //1 or 5
#elif (App == 0xB302EC7 || App == 0x91D9EBAF ) //F.E.A.R | F.E.A.R 2: Project Origin
	#define DA_X 0.110
	#define DA_Y 12.0
	#define DA_Z 0.00025
	 
	#define DE_X 4
	//#define DE_Y 0.625
	#define DE_Z 0.375
	//#define DG_W 0.25
	#define WSM 5
	#define DB_W 22
	//#define DF_X 0.225
	#define DSW 1 //?
	#define FOV 1
	#define RHW 1
#elif (App == 0x2C742D7C ) //Immortal Redneck CP alt 1.9375
	#define DA_Y 20.0
	 
	#define WSM 5
	#define DB_W 24
#elif (App == 0x663E66FE ) //NecroVisioN & NecroVisioN: Lost Company
	#define DA_Y 10.0
	 
	#define WSM 5
	#define DB_W 26
#elif (App == 0xAA6B948E ) //Rage64
	#define DA_Y 20.0
	 
	#define WSM 3
	#define DB_W 2
#elif (App == 0x22BA110F ) //Turok: DH 2017
	#define DA_X 0.002
	#define DA_Y 250.0
#elif (App == 0x5F1DBD3B ) //Turok2: SoE 2017
	#define DA_X 0.002
	#define DA_Y 250.0
#elif (App == 0x3FDD232A ) //FEZ
	#define DA_X 0.2125
	 
	#define DA_Z -0.901
#elif (App == 0x941D8A46 ) //Tomb Raider Anniversary :)
	#define DA_Y 75.0
	#define DA_Z 0.0206
	 
#elif (App == 0xF0100C34 ) //Two Worlds Epic Edition
	#define DA_Y 43.75
	#define DA_Z 0.07575
#elif (App == 0xA4C82737 ) //Silent Hill: Homecoming
	#define DA_Y 25.0
	#define DA_X 0.0375
	#define DA_Z 0.11625
	 
	#define HMC 0.5
	#define HMT 1
#elif (App == 0x61243AED ) //Shadow Warrior Classic source port
	#define DA_Y 10.0
	#define DA_X 0.05
	#define DA_Z 1.0
	 
#elif (App == 0x5AE8FA62 ) //Shadow Warrior Classic Redux
	#define DA_Y 10.0
	#define DA_X 0.05
	#define DA_Z 1.0
#elif (App == 0x9E7AA0C4 ) //Shadow Tactics: Blades of the Shogun
	#define DA_X 0.150
	#define DF_Y 0.050
	#define DA_Y 7.0
	#define DA_Z 0.0005
	 
	#define DB_Z 0.305
	#define DB_X 1
	#define BMT 1
	#define DF_Z 0.125 //0.1875
    //#define DG_W 0.100 //Pop
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 32    //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define RHW 1
#elif (App == 0xE63BF4A4 ) //World of Warcraft DX12
	#define DA_Y 7.5
	#define DA_W 1
	 
	#define DB_Z 0.1375
	#define NDW 1
	#define RHW 1
#elif (App == 0x5961D1CC ) //Requiem: Avenging Angel
	#define DA_Y 37.5
	#define DA_X 0.0375
	#define DA_Z 0.8
	#define HMC 0.501
	#define HMT 1
#elif (App == 0x86D33094 || App == 0x19019D10 ) //Rise of the TombRaider | TombRaider 2013
	#define DA_X 0.0725
	 
	#define DA_Y 25.0
	#define DA_Z 0.0200375
	#define DE_X 2
	#define DE_Y 0.375
	#define DE_Z 0.375
#elif (App == 0x60F436C6 ) //RESIDENT EVIL 2  BIOHAZARD RE2
	#define DA_X 0.1375
	#define DF_Y 0.025
	 
	#define DB_Z 0.015
	#define DA_Y 50
    #define DA_Z -0.625
	#define DA_W 1
	#define DE_X 1 //REF only works now with this. Since this system works in tandom.
	#define DE_Y 0.300
	#define DE_Z 0.4375
	#define OIF 0.025 //Fix enables if Value is > 0.0
	#define DI_W 3.75 //Adjustment for REF
    //#define DG_W 0.375//Pop
    #define PEW 1
    #define DAA 1    
#elif (App == 0xF0D4DB3D ) //Never Alone
	#define DA_X 0.1375
	 
	#define DA_Y 31.25
	#define DA_Z 0.004
#elif (App == 0x3EB1D73A ) //Magica 2
	#define DA_X 0.2
	 
	#define DA_Y 27.5
	#define DA_Z 0.007
#elif (App == 0x6D35D4BE ) //Lara Croft and the Temple of Osiris
	#define DA_X 0.15
	 
	#define DB_Z 0.4
	#define DA_Y 75.0
	#define DA_Z 0.021
	#define OIF 0.0125 //Fix enables if Value is > 0.0
#elif (App == 0x287BBA4C || App == 0x59BFE7AC ) //Grim Dawn 64bit/32bit
	 
	#define DA_Y 125.0
	#define DA_Z 0.003
#elif (App == 0x8EAF7114 ) //Firewatch
	 
	#define DA_Y 5.5
	#define DA_X 0.0375
	#define DB_X 1
	#define DA_W 1
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define BMT 1
	#define DF_Z 0.15
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.925 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact
#elif (App == 0x6BDF0098 ) //Dungeons 2
	#define DA_X 0.100
	 
	#define DA_Z 0.005
	#define DB_X 1
#elif (App == 0x31BF8AF6 ) //DragonBall Fighters Z
	#define DA_Y 10.0
	#define DA_W 1
	#define DA_X 0.130
	 
	#define DB_Z 0.625 //I know, I know........
#elif (App == 0x3F017CF ) //Call of Cthulhu
	#define DA_W 1
	#define DA_X 0.0375
#elif (App == 0xA100000 ) //Lego Batman 1 & 2
	#define DA_Y 27.5
	#define DA_X 0.125
	#define DA_Z 0.001
	 
	#define DB_Z 0.025
	#define OIF 0.0125 //Fix enables if Value is > 0.0
#elif (App == 0x5F2CA572 ) //Lego Batman 3
	#define DA_X 0.03
	#define DA_Z 0.001
	 
	#define RHW 1
#elif (App == 0xA200000 ) //Batman BlackGate
	#define DA_Y 12.5
	#define DA_X 0.0375
	#define DA_Z 0.00025
	 
#elif (App == 0xCB1CCDC ) //BATMAN TTS
	#define NCW 1 //Not Compatible
#elif (App == 0x4A2297E4 ) //Batman Arkham Knight
	#define DA_X 0.045
	#define DF_Y 0.0075
	#define DA_Y 22.5
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    //#define DG_W -0.30 //Neg-Pop
    //#define DG_Z 0.150 //Min
    //#define DI_Z 0.200 //Trim
	#define BMT 1
	#define DF_Z 0.150
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define PEW 1	
#elif (App == 0xE9A02687 ) //BattleTech
	#define DA_W 1
	#define DB_X 1
	#define DA_Y 75.0
	#define DA_X 0.250
	 
	#define OIF 0.0125 //Fix enables if Value is > 0.0
	#define RHW 1
#elif (App == 0x1335BAB8 ) //BattleField 1
	#define DA_W 1
	#define DA_Y 8.125
	#define DA_X 0.04
	 
	#define OIF 0.025 //Fix enables if Value is > 0.0
#elif (App == 0xC990B77C ) //Assassin's Origins
	#define DA_W 1
	#define DA_Y 50.0
	#define DA_X 0.050
	 
	#define DE_X 2
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DB_Z 0.1
	#define DF_Y 0.005  
	#define BMT 1    
	#define DF_Z 0.130
	#define DG_Z 0.07  
	#define DI_Z 0.120
#elif (App == 0x8B0F15E7 || App == 0xCFE885A2 || App == 0xCADE8051 ) //Alan Wake | Alan Wake's American Nightmare | Alan Wake Remaster
	#define DA_X 0.04375
	#define DF_Y 0.01	
	#define DA_Y 25.0
   //#define DA_Z 0.00025 //-1.0
	 
	#define DE_X 1
	//#define DE_Y 0.325
	#define DE_Z 0.375
	#define BMT 1
	#define DF_Z 0.125
    //#define DG_W 0.100 //Pop
    #define DG_Z 0.002 //Min
	#define RHW 1
	#define PEW 1
	#define DAA 1
#elif (App == 0x56D8243B ) //Agony Unrated
	#define DA_W 1
	#define DA_X 0.04375
	#define DA_Y 43.75
	 
	#define RHW 1
#elif (App == 0x23D5135F ) //Alien Isolation
	#define DA_X 0.07
    #define DF_Y 0.0125
	#define DA_Y 22.5 // or 23.0
	#define DA_Z 0.0005
	  
	#define DE_X 2
	#define DE_Y 0.7
	#define DE_Z 0.375
	#define DG_Z 0.0325
	#define DE_W 0.1
	#define BDF 1
	#define DC_X 0.22
	#define DC_Y -0.1
	#define DC_W -0.022
	#define RHW 1
	#define PEW 1
#elif (App == 0x5839915F ) //35MM
	#define DA_Y 35.00
	#define DB_X 1
	 
	#define RHW 1
#elif (App == 0xA67FA4BC ) //Outlast
	#define DA_Y 30.0
	#define DA_Z 0.0004
	#define DA_X 0.043750
	 
	#define RHW 1
#elif (App == 0xDCC7F877 ) //Outlast II
	#define DA_W 1
	#define DA_Y 50.0
	#define DA_Z 0.0004
	#define DA_X 0.056250
	 
	#define RHW 1
#elif (App == 0x85F0A0FF ) //LUST for Darkness
	#define DA_W 1
	#define DB_X 1
	#define DA_Y 13.75
	#define DA_Z 0.001
	#define DA_X 0.04
	 
	#define DB_Z 0.125
	#define RHW 1
#elif (App == 0x706C8618 ) //Layer of Fear
	#define DB_X 1
	#define DA_Y 17.50
	#define DA_X 0.035
	 
	#define RHW 1
#elif (App == 0x84D341E3 || App == 0x15A08799) //Little Nightmares & Little Nightmares II
	#define DA_W 1
	#define DA_Y 32.5
	#define DA_X 0.225
	#define DF_Y 0.125
	//#define DA_Z 0.0015
	  		//ZPD Boundary Scaling
	#define DB_Z 0.325	//Auto Depth Adjust
	#define BMT 1 // Had to use this mode since Auto Mode was not cutting it.
	#define DF_Z 0.225
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define PEW 1
#elif (App == 0xC282C520 ) //Observer System Redux
	#define DA_W 1
	#define DA_Y 13.5
	#define DA_X 0.05
	#define DF_Y 0.2250
	#define DA_Z -0.005
	#define DB_Z 0.0325
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W 0.100 // Slight adjustment to the ZPD Boundary
	#define BMT 1 // Had to use this mode since Auto Mode was not cutting it.
	#define DF_Z 0.1625
    #define DG_Z 0.05 //Min
    #define DI_Z 0.07 //Trim
	#define RHW 1
	#define PEW 1
#elif (App == 0xC0AC5174 ) //Observer
	#define DA_W 1
	#define DA_Y 13.5
	#define DA_X 0.05
	#define DF_Y 0.180
	#define DA_Z -0.005
	#define DB_Z 0.0325
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W 0.100 // Slight adjustment to the ZPD Boundary
	#define BMT 1 // Had to use this mode since Auto Mode was not cutting it.
	#define DF_Z 0.1625
    #define DG_Z 0.05 //Min
    #define DI_Z 0.07 //Trim
	#define RHW 1
	#define PEW 1
#elif (App == 0xABAA2255 ) //The Forest
	#define DA_W 1
	#define DB_X 1
	#define DA_X 0.038//0.0525//0.0525//0.04 //0.040 //0.038 //0.04375
    #define DF_Y 0.0075
	#define DA_Y 17.5 //10.5  //10.5  //15.5 //17.5  //20.5  //7.5 
    #define DA_Z 0.00075
	 
    #define DG_Z 0.091 //Min
    #define DI_Z 0.1625 //0.200 //Trim
	#define BMT 1
	#define DF_Z 0.1375
	//#define DB_W 62
	#define RHW 1
#elif (App == 0x67A4A23A ) //Crash Bandicoot N.Saine Trilogy
	#define DA_Y 7.5
    #define DF_Y 0.0625
	#define DA_Z -0.250
	#define DA_X 0.1
	 
	#define HMC 0.580
	#define HMT 1
#elif (App == 0xE160AE14 ) //Spyro Reignited Trilogy****
    #define DA_W 1
    #define DA_Y 12.5
    #define DA_Z -0.25
    #define DA_X 0.100
    #define DF_Y 0.040
     
    #define DE_X 2
    #define DE_Y 0.500
    #define DE_Z 0.375
    #define DG_Z 0.150 //0.050 //0.100 //Min
    #define DI_Z 0.150 //0.125 //0.250 //Trim
    #define BMT 1
	#define DF_Z 0.300
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.625 //SM Tune
	#define DL_W 0.100 //SM Perspective
#elif (App == 0x5833F81C ) //Dying Light
	#define DA_W 1
	#define DA_X 0.040 //0.0375//0.036
	#define DF_Y 0.0375//0.050 //0.0525	
	#define DA_Y 11.00 //10.0//12.5
	//#define DA_Z -0.175//-0.200 //-0.375 //-0.05
	 
	#define DE_X 2
	#define DE_Y 0.7000
	#define DE_Z 0.3000
	#define NDW 1
	#define PEW 1
    #define FOV 1
    #define DG_Z 0.090 //0.0875//0.080 //Min
    #define DE_W 0.105 //Max
    #define DI_Z 0.200 //Trim
	#define BMT 1
	#define DF_Z 0.1375
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.650 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define WSM 3 //Weapon Settings Mode
	//#define DB_W 6
#elif (App == 0x86562CC2 ) //STARWARS Jedi Fallen Order
	#define DA_X 0.140
	#define DA_W 1
	#define DA_Y 13.75
	#define DA_Z 0.00025
	 
	#define DE_X 1
	#define DE_Y 0.1875
	#define DE_Z 0.475
	#define DB_Z 0.375
	#define BMT 1
	#define DF_Z 0.125
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.650 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3    //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define RHW 1
	#define NFM 1
#elif (App == 0x88004DC9 || App == 0x1DDA9341) //Strange Brigade DX12 & Vulkan
	#define DA_X 0.0625
	#define DF_Y 0.02
	#define DA_Y 20.0
	#define DA_Z 0.0001
	 
	#define DE_X 2
	#define DE_Y 0.3
	#define DE_Z 0.475
	#define RHW 1
#elif (App == 0xC0052CC4) //Halo The Master Chief Collection
	#define DA_X 0.0375
	#define DF_Y 0.030
	#define DA_W 1
	#define DA_Y 70.0 //65.0 //75.0
//	#define DB_Z 0.150
//	 
	#define DE_X 4
	#define DE_Y 0.500 //0.375
	#define DE_Z 0.400
    #define DG_Z 0.125 //Min
    //#define DE_W 0.105 //Max
    #define DI_Z 0.1375//Trim
    #define DG_W 2.500 //Pop
    #define HMT 1
	#define HMC 0.5
	#define BMT 1
	#define DF_Z 0.100
	#define WSM 7
	#define SPO 1
	#define OW_WP "Read Help & Change Me\0Custom WP\0Halo: Reach\0Halo: CE Anniversary\0Halo 2: Anniversary\0Halo 3 & Halo 3: ODST\0Halo 3 & Halo 3: ODST Alternet\0Halo 4\0Halo 4 Alternet\0"
	#define RHW 1
	#define WPW 1
#elif (App == 0xC50993EC) //COD: Modern Warfare 2019
	#define DA_X 0.0375
	#define DA_W 1
	#define DA_Y 37.5
	#define DA_Z 0.000125
	 
	#define DB_W 12
	#define RHW 1
#elif (App == 0xA640659C) //MegaMan 2.5D in 3D
	#define DA_X 0.150
	#define DA_Y 8.75
	#define DA_Z -1005.0
	#define DE_X 1
	#define DE_Y 0.275
	#define DE_Z 0.375
	#define RHW 1
#elif (App == 0x49654776) //Paratopic
	#define DA_X 0.05
	#define DA_W 1
	#define DA_Y 8.75
	#define DA_Z 0.000250
	 
	#define DB_X 1
	#define RHW 1
#elif (App == 0xF7590C95) //Yume Nikki -Dream Diary-
	#define DA_X 0.0625
	#define DA_W 1
	#define DA_Y 20.0
	#define DA_Z 0.002
	#define DB_X 1
	 
	#define DE_X 1
	#define DE_Y 0.35
	#define DE_Z 0.25
	#define NCW 1
	#define RHW 1
#elif (App == 0x65F37CDF) //American Truck Simulator
	#define DA_X 0.05375
	#define DA_Y 15.0
	#define DA_Z 0.005
	#define DB_X 1
	 
	#define DB_W 47
#elif (App == 0xB5789234) //The Park
	#define DA_X 0.05625
	#define DA_W 1
	#define DA_Y 12.5
	 
	#define RHW 1
#elif (App == 0xB7C22840) //Strife
	#define DA_X 0.1
	#define DA_Y 250.0
	#define WSM 3
	#define DB_W 8
	#define RHW 1
#elif (App == 0x1E9DCD00) //Witch it
	#define DA_X 0.0475
	#define DA_W 1
	#define DA_Y 47.5
	 
	#define DE_W 0.325
#elif (App == 0x6B58D180) //Outlaws
	#define DA_X 0.14375
	#define DA_Y 30
	 
	#define DB_Z 0.225
#elif (App == 0x5AC0F7E3) //SoF
	#define DA_X 0.04375
	#define DA_Y 17.5
	 
	#define DB_W 22
	#define DF_X float2(0.5,0.0)
#elif (App == 0xEA8E05B6) //Only If
	#define DA_X 0.100
	 
	#define DE_X 1
#elif (App == 0xFDE0387 ) //Stranger Odd Worlds
	#define DA_X 0.100
	#define DA_Y 7.5
	#define DB_X 1
	 
	#define DE_X 2
	#define HMC 0.5
	#define HMT 1
#elif (App == 0x242D82C4 ) //Okami HD
	#define DA_X 0.200
	#define DA_W 1
	#define DA_Z 0.001
	 
	#define DE_X 2
	#define DE_Y 0.125
	#define DE_Z 0.375
	#define HMC 0.5
	#define HMT 1
#elif (App == 0x75B36B20 ) //Eldritch
	#define DA_Y 125.0
	#define DA_X 0.05
	 
	#define DE_X 1
	#define DB_Z 0.05
#elif (App == 0x97CBF34C ) //Dementium 2
	#define DA_Y 18.75
	#define DA_X 0.04125
	 
	#define WSM 5
	#define DB_W 25
	#define DB_X 1
	#define RHW 1
#elif (App == 0x5925FCC8 ) //Dusk
	#define DA_Y 25.0
	#define DA_X 0.05
	 
	#define DA_W 1
	#define DB_X 1
	#define DE_X 4
	#define DE_Z 0.375
#elif (App == 0xDDA80A38 ) //Deus Ex Rev DX9
	#define DA_X 0.04375
	#define DA_Y 20
	 
	#define DB_W 23
	#define HMC 0.534
	#define HMT 1
	#define DF_X float2(0.025,0.0)
#elif (App == 0x1714C977) //Deus Ex DX9
	#define DA_X 0.05
	#define DA_Y 125.0
	 
	#define DB_W 24
	#define HMC 1.0
	#define HMT 1
	#define DF_X float2(0.05,0.0)
#elif (App == 0x92583CDD ) //Legend of Dungeon
	#define DA_Y 12.5
	#define DA_Z 0.185
	#define DA_X 0.075
	 
	#define DB_X 1
#elif (App == 0xDB3A28BD ) //Monster Hunter World
	#define DA_Y 17.5
	#define DA_X 0.075
	#define DF_Y 0.010
	#define DA_W 1
	 
	#define DE_X 1
	#define DE_Y 0.300
	#define DE_Z 0.4375
	#define BMT 1
	#define DF_Z 0.130
    #define SMS 2     //SM Toggle Separation
	#define DL_X 0.550 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
	#define PEW 1
	#define DAA 1
	#define NDW 1
#elif (App == 0xC073C2BB ) //StreetFighter V
	#define DA_Y 14.0
	#define DA_X 0.250
	#define DA_W 1
	 
	#define DB_Z 0.550
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
#elif (App == 0xCFB8DD02 ) //DIRT RALLY 2.0
	#define DA_X 0.025
	#define DF_Y 0.025
	#define DA_Y 15.0
	#define DE_X 1
	#define DE_Y 0.725
	#define DE_Z 0.375
    //#define DG_W 0.125 //Pop
	#define DG_Z 0.0225 //Min
    #define DI_Z 0.0625//Trim
	#define BMT 1
	#define DF_Z 0.060
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.625 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    #define MMD 1 //Set Multi Menu Detection                 //Off / On
    #define DO_X float4( 0.069 , 0.085 ,  0.887  , 0.9185  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.0734, 0.066 ,  0.069  , 0.085   ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.8855, 0.921 ,  0.0734 , 0.066   ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 13.0  , 13.0  ,  13.0   , 13.0    ) //Tresh Hold for Color A1 & A3 and Color B1 & B3 
    #define PEW 1
	#define DAA 1
#elif (App == 0x2F55D5A3 || App == 0x4A5220AF ) //ShadowWarrior 2013 DX11 & DX9
	#define DA_X 0.035
	 
	#define DE_X 5
	#define DE_Z 0.375
#elif (App == 0x56301DED ) //ShadowWarrior 2
	#define DA_W 1
	#define DA_X 0.045
    #define DF_Y 0.025
	#define DA_Y 12.5
	#define DE_X 2
	#define DE_Y 0.375
	#define DE_Z 0.4375
	#define DG_W 0.6 //Pop out
	#define BMT 1    
	#define DF_Z 0.1
	#define DG_Z 0.09  
	#define DI_Z 0.170
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.610 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DSW 1
	#define NDW 1
#elif (App == 0x892CA092 ) //Farcry
	#define DA_Y 7.0
	#define DA_Z 0.000375
	#define DB_Z 0.105
	#define DA_X 0.055
	 
	#define WSM 3
	#define DB_W 12
	#define DF_X float2(0.13875,0.0)
#elif (App == 0x9140DBE0 ) //Farcry 2
	#define DA_X 0.05
	 
	#define DE_X 5
	#define DE_Z 0.375
	#define WSM 3
	#define DB_W 13
	#define RHW 1
#elif (App == 0xE3AD2F05 ) //Sauerbraten
	#define DA_Y 25.0
	#define DA_X 0.05
	 
	#define DF_X float2(0.150,0.0)
	#define WSM 3
	#define DB_W 22
#elif (App == 0xF0F2CF6A ) //Dragon Ball Z: Kakarot
	#define DA_W 1
	#define DA_Y 55.0
	#define DA_X 0.09
	#define DF_Y 0.03
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DB_Z 0.200 //Yay I know
    //#define DG_W -0.85 //Pop out
	#define OIF 0.09375     //Fix enables if Value is > 0.0
	#define DI_W 3     //Adjustment for REF
	#define DG_Z 0.060 //Min
	#define DI_Z 0.060 //Trim
	#define BMT 1
	#define DF_Z 0.130
    #define SMS 2     //SM Toggle Separation
	#define DL_X 0.525 //SM Tune
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3    //HQ Tune
	#define DM_Z 2     //HQ Smooth
#elif (App == 0xFA2C0106 ) //Hat in Time
	#define DA_X 0.250
	 
	#define DE_X 1
	#define DE_Z 0.4375
    #define DF_Y 0.045
    #define DG_Z 0.075
	#define RHW 1
	#define DSW 1
#elif (App == 0xCD0E316F ) //Sonic Adventure DX Modded with BetterSADX
	#define DA_Y 8.75
	#define DA_X 0.1125
	 
	#define DE_X 2
	#define DE_Y 0.375
	#define DE_Z 0.4375
	#define DB_Z 0.250
	#define RHW 1
#elif (App == 0x71170B42 ) //Blood: Fresh Suppy
	#define DA_Y 212.5
	#define DA_X 0.175
	#define BMT 1
	#define DF_Z 0.275
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DG_W 0.25
	#define DSW 1
#elif (App == 0x8F615A99 ) //Frostpunk
	#define DA_Y 9.375
	#define DA_X 0.250
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.400
#elif (App == 0x29B47A0A ) //KingMaker
	#define DB_X 1
	#define DA_W 1
	#define DA_Y 18.75
	#define DA_Z 0.0075
	#define DA_X 0.150
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.300
#elif (App == 0xBF70711C ) //Singularity
	#define DA_Y 15.0
	#define DA_X 0.0375
	#define DE_X 1
	#define DE_Z 0.375
	#define DF_X float2(0.175,0.0)
	#define WSM 3
	#define DB_W 15
	#define RHW 1
#elif (App == 0x905631F2 || App == 0x76F4DCB0 ) //Crysis DX10 32bit / 64bit
    #define DA_X 0.0375
    #define DF_Y 0.120
    #define DA_Y 7.0
    //#define DA_Z -0.0005
    #define DE_X 4
    #define DE_Y 0.500
    #define DE_Z 0.375
	//#fine DG_W 0.325 //Pop out
    #define BMT 1    
    #define DF_Z 0.110
	#define WSM 5
	#define DB_W 11
	#define DF_X float2(0.3625,0.0)
	#define PEW 1
	//#define DSW 1
#elif (App == 0x6061750E ) //Mirror's Edge
	#define DA_Y 12.25
	#define DF_Y 0.020
	#define DA_X 0.040
	 
    #define DB_Z 0.01
	#define DE_X 1
	#define DE_Y 0.50
	#define DE_Z 0.375
	#define WSM 3
	#define DB_W 19
	#define DSW 1
#elif (App == 0xC3AF1228 || App == 0x95A994C8 ) //Spellforce
	#define DA_Y 145.0
	#define DA_Z 0.001
	#define DB_Z 0.05
	#define DA_X 0.05
	 
	#define DE_X 1
	#define DE_Y 0.235
	#define DE_Z 0.375
	#define HMT 1
	#define HMC 0.5
#elif (App == 0xD372612E ) //Raft
	#define DA_W 1
	#define DB_X 1
	#define DA_X 0.04375
	 
	#define NDW 1
#elif (App == 0x7FC671B6 ) //Doom Eternal ****
	#define DA_Y 50.0
	#define DA_Z 0.00009375
	#define DA_W 1
	 
	#define DE_X 5
	#define DE_Y 0.550
	#define DE_Z 0.333
	//#define DG_Z 0.080 //Min
	#define DA_X 0.03125
	#define DF_Y 0.03125
	//#define DA_X 0.0375 //Alternet settings Not used.
	#define WSM 3
	#define DB_W 17
	#define PEW 1
#elif (App == 0x21CB998 ) //.Hack//G.U.
	#define DA_Y 22.5
	#define DA_X 0.125
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.3
	#define RHW 1
	#define NFM 1
#elif (App == 0x9CC5C8E0 ) //GTA V
	#define DA_Y 18.75
	#define DA_W 1
	#define DA_X 0.0475
	 
	#define DE_X 1
	#define DE_Y 0.325
	#define DE_Z 0.375
	#define DB_Z 0.05
	#define RHW 1
	#define PEW 1
	#define NFM 1
#elif (App == 0x8CD23575 ) //Dark Souls: Remastered
	#define DA_Y 68.0
	#define DA_Z -0.001
	#define DA_X 0.072
	#define DF_Y 0.1
	 
	#define DE_X 2
	#define DE_Y 0.350
	#define DE_Z 0.375
	#define DG_W 0.0625
	#define DG_Z 0.075  
	#define DI_Z 0.100
	#define BMT 1    
	#define DF_Z 0.125
	#define PEW 1
	#define FOV 1
#elif (App == 0x9E071BC0 ) //Dark Souls III
	#define DA_Y 25.0
	#define DA_Z 0.000125
	#define DA_X 0.1
	#define DF_Y 0.05625
	 
	#define DE_X 2
	#define DE_Y 0.5000
	#define DE_Z 0.4375
	#define DG_Z 0.1125 //Min
	#define PEW 1
	#define FOV 1
#elif (App == 0x5D4939C9 ) //Dark Souls II
	#define DA_Y 22.5
	#define DA_Z 0.00025
	#define DA_X 0.110
	 
	#define DE_X 2
	#define DE_Y 0.50
	#define DE_Z 0.40
	#define DE_W 0.1
#elif (App == 0xFB111509 ) //Dark Souls II Scholar of the First Sin
	#define DA_Y 46.5
	#define DA_X 0.045
	#define DF_Y 0.0425
	 
	#define DE_X 1
	#define DE_Y 0.550
	#define DE_Z 0.350
	#define DG_W 0.127 //Pop out
	#define DG_Z 0.050 //Min
	#define DI_Z 0.100 //Trim
	#define DAA 1
	#define PEW 1
	#define FOV 1
#elif (App == 0xCE5313C2 ) //BorderLands Enhanced
	#define DA_Y 18.75
	#define DA_Z 0.0005
	#define DA_X 0.055
	#define DF_Y 0.02
	#define DB_Z 0.075
	 
	#define DB_W 3
	#define DE_X 4
	#define DE_Y 0.425
	#define DE_Z 0.375
	#define DG_Z 0.3975
	#define DF_X float2(0.225,0.0)
	#define NDW 1
#elif (App == 0x2ECAAF29 || App == 0xE19E4830 || App == 0xE19E4830  ) //Half-Life 2 | Left 4 Dead 2
	#define DA_Y 15.0
	#define DA_X 0.040
    #define DF_Y 0.020
	#define DB_Z 0.050
	 
	#define DB_W 20
	#define DE_X 7
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DF_X float2(0.150,0.25)
	#define DJ_W 0.175	      // Weapon Depth Limit Location 1
	#define DS_W 0.75	      // Weapon Depth Limit Location 2
	#define WFB 0.0          // ZPD Weapon Elevaton for 1 and 2 scales from [0 - 1]
	#define BMT 1
	#define DF_Z 0.100
	#define DSW 1
	#define RHW 1
#elif (App == 0xEACB4D0D ) //Final Fantasy XV Windows Edition
	#define DA_X 0.0375
	#define DA_Y 30.0
	 
	#define DE_X 2
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define RHW 1
#elif (App == 0xAC4DF2C4 ) //Mafia II Definitive Edition
	#define DA_X 0.05
	#define DA_Y 37.5
	#define DA_Z 0.0007
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DFW 1
	#define RHW 1
#elif (App == 0xEA75DEDE ) //Lost Planet Colonies
	#define DA_X 0.05
	#define DA_Y 37.5
	 
	#define DE_X 2
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define RHW 1
#elif (App == 0xEFC486AF ) //Lost Planet 2 DX11
	#define DA_X 0.04375
	#define DA_Y 37.5
	#define DA_Z 0.001
	 
	#define DE_X 2
	#define DE_Y 0.5
	#define DE_Z 0.375
#elif (App == 0x97937D77 ) //Lost Planet 3 Dx9
	#define DA_X 0.05
	#define DA_Y 20.0
	#define DA_Z 0.001
	 
	#define DE_X 2
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define RHW 1
#elif (App == 0x9896B9F5 ) //Old City: Leviathan
	#define DA_X 0.030
	#define DA_Y 82.5
	#define DA_Z 0.0015
	 
	#define DE_X 1
	//#define DE_Y 0.250
	#define DE_Z 0.375
	#define DB_Z 0.075
	//#define DG_Z 0.5
	#define DSW 1
#elif (App == 0xE4F6014F ) //Shovel Knight
	#define DB_X 1
	#define DA_X 0.035
	#define DA_Y 22.5
	#define DA_Z 0.483
	#define RHW 1
#elif (App == 0x94EFD213 ) //Chex Quest HD
	#define DA_W 1
	#define DA_X 0.1
	#define DA_Y 112.5
	#define DA_Z 0.0000125
	 
	#define DE_X 4
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DB_Z 0.125
	#define WSM 3
	#define DB_W 23
#elif (App == 0xB05C57BC ) //HellBound
	#define DA_W 1
	#define DA_X 0.0325
	#define DA_Y 25.0
	 
	#define DE_W 0.025
#elif (App == 0x9FC060AE ) //STRIFE: Gold Edition
	#define DA_X 0.0375
	#define DA_Y 23.75
	#define DA_Z 0.00025
	#define DB_X 1
	 
	#define NCW 1
#elif (App == 0x38ED56AE ) //Heavy Rain
	#define DA_X 0.0325
	#define DA_Y 50.0
	//#define DA_Z 0.001
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DB_Z 0.0675
	#define NCW 1
#elif (App == 0x9DA6C947 ) //Beyond Two Souls
	#define DA_X 0.0625
    #define DF_Y 0.0275
	#define DA_Y 20.00
	 
	#define DE_X 1
	//#define DE_Y 0.5
	#define DE_Z 0.375
	#define DG_W 0.175
	//#define BMT 1
	//#define DF_Z 0.1375
	#define DSW 1
	#define LBC 1 //Letter Box Correction With X & Y
    #define DH_X 1.0
    #define DH_Y 1.315
#elif (App == 0x89351FC4 ) //3DSen Games
	#define DA_W 1
	#define DB_X 1
	#define DA_X 0.1
	#define DA_Y 375.0
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.250
	#define DFW 1
#elif (App == 0xF55F26A1 ) //Tekken 7
	#define DA_W 1
    #define DF_Y 0.025
	#define DA_Y 100.0
	#define DA_Z 0.0001
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DE_W 0.440
	#define DAA 1
#elif (App == 0x9BD7A4FD ) //Starwars Battle Front II
	#define DA_W 1
	#define DA_X 0.05
	#define DA_Y 10.0
	 
	#define DE_X 2
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DE_W 0.075
#elif (App == 0x14E41902 ) //jsHexen II
	#define RHW 1
	#define NFM 1
	#define DA_X 0.06
	#define DA_Y 17.5
	#define DA_Z 0.0003
	 
	#define DB_W 22
#elif (App == 0x12C96DB0 ) //Hexen 2 Hammer of Thyrion
	#define RHW 1
	#define NFM 1
	#define DA_X 0.06
	#define DA_Y 17.5
	#define DA_Z 0.0003
	 
	#define DB_W 22
#elif (App == 0x54A39BDC ) //Hexen 2 FTEQW 64
	#define DA_X 0.06
	#define DA_Y 30.0
	#define DA_Z 0.0003
	 
	#define WSM 3
	#define DB_W 24 //???
#elif (App == 0x6281C1AC ) //DarkSiders Warmastered Edition
	#define DA_X 0.05
	#define DA_Y 30.0
	 
	#define DE_X 2
	#define DE_Y 0.5
	#define DE_Z 0.375
#elif (App == 0x763E5FA5 ) //DarkSiders 2 Depthinitve Edition
	#define DA_X 0.05
	#define DA_Y 15.0
	 
	#define DE_X 1
	#define DE_Y 0.65
	#define DE_Z 0.375
	#define DB_Z 0.025
#elif (App == 0x7F1A5568 ) //DarkSiders III
	#define DA_W 1
	#define DA_X 0.0625
	#define DA_Y 50.0
	#define DA_Z 0.0001
	 
	#define DE_X 1
	#define DE_Y 0.250
	#define DE_Z 0.4
	#define DG_W 0.125
    #define BMT 1    
    #define DF_Z 0.125
	#define DG_Z 0.450 //Min
    #define DI_Z 0.250 //Trim
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.5125//SM Tune
	#define DL_W 0.0   //SM Perspective
#elif (App == 0xB4C116F7 ) //Nioh
	#define DA_W 1
	#define DA_X 0.100 // 0.050//0.0375
    #define DF_Y 0.080
	#define DA_Y 170.0 //245.0
	//#define DA_Z 0.000125
	#define DB_Z 0.100
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.4
	#define DG_W 0.25 //Pop out
    #define BMT 1    
    #define DF_Z 0.1125
	#define OIF 0.225      //Fix enables if Value is > 0.0
	#define DI_W 2.5   //Adjustment for REF
	#define DG_Z 0.025 //Min
    #define DI_Z 0.050 //Trim
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.05  //SM Perspective
	#define DM_Z 5     //HQ Smooth
#elif (App == 0x2419B0BF ) //Nioh 2
	#define DA_W 1
	#define DA_X 0.075
    #define DF_Y 0.075
	#define DA_Y 17.5
	//#define DA_Z 0.000125
	#define DB_Z 0.100
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.4
	#define DG_W 0.25 //Pop out
    #define BMT 1    
    #define DF_Z 0.1125
	#define OIF 0.225      //Fix enables if Value is > 0.0
	#define DI_W 2.5   //Adjustment for REF
	#define DG_Z 0.100 //Min
    #define DI_Z 0.1625//Trim
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.650 //SM Tune
	#define DL_W 0.100 //SM Perspective
	#define DM_Z 1     //HQ Smooth
#elif (App == 0xD30783B6 ) //X-Com
	#define DA_X 0.03
	#define DA_Y 200.0
	#define DA_Z 0.000125
	#define DB_Z 0.050
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DE_W 0.025
	#define DSW 1
#elif (App == 0xBF53A67A ) //The Bureau: XCOM Declassified
	#define DA_X 0.04375
	#define DA_Y 29.0
	#define DA_Z 0.0003
	 
	#define DE_X 2
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DSW 1
#elif (App == 0x1764D88A || App == 0x18D54C6A ) //X-Com 2
	#define DA_X 0.20
	#define DF_Y 0.102
	#define DA_Y 28.0
	#define DB_Z 0.130
	 
	#define DE_X 2
	#define DE_Y 0.3
	#define DE_Z 0.375
	#define DG_Z 0.070
    #define DI_Z 0.125
#elif (App == 0xC60A845F || App == 0xEDFDB1AF) //My Friend Pedro **** //Steam // Windows Store
    #define DB_X 1
    #define DA_W 1
    #define DA_X 0.075
    #define DF_Y 0.030
    #define DA_Y 50.0
    #define DA_Z 0.000375
    #define DB_Z 0.13
    #define BMT 1
    #define DF_Z 0.10
#elif (App == 0xD45ACB4B ) //Murdered Soul Suspect
	#define DA_X 0.05
	#define DA_Y 37.5
	#define DA_Z 0.001
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DSW 1
#elif (App == 0xD0AA19 ) //The Bards Tale 4
	#define DA_W 1
	#define DA_X 0.0375
	#define DA_Y 20.0
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DAA 1
	#define PEW 1
	#define RHW 1
#elif (App == 0x54D4EAFA) //Sekiro Shadows Die Twice
	#define DA_W 1
    #define DF_Y 0.025
	#define DA_X 0.10
	#define DA_Y 31.25
	#define DA_Z -0.0525
	#define DG_W 0.25 //Pop out
	//#define DB_Z 0.125
	 
	#define DE_X 2
	#define DE_Y 0.275
	#define DE_Z 0.375
   // #define DF_Z -0.125
	#define DAA 1
	#define PEW 1
#elif (App == 0x36ECE27F || App == 0x33D49788 ) //Supraland & Six Inches Under
	#define DA_W 1
	#define DA_X 0.0375
	#define DF_Y 0.005
	#define DA_Y 15.0
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    //#define DG_W -0.30 //Neg-Pop
    #define DG_Z 0.0625 //Min
    #define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.150
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define PEW 1
	#define DAA 1
#elif (App == 0x3604DCE6 || App == 0xE58986E ) //Remnant: From the Ashes //Steam //Windows Store
	#define DA_W 1
	#define DA_X 0.060
	#define DF_Y 0.05
	#define DA_Y 19.375
	 
	#define DE_X 2
	//#define DE_Y 0.450
	#define DE_Z 0.375
	#define DA_Z 0.000125 //-0.0375 //-0.050
	//#define DG_W 0.25
	//#define DF_Z -0.125
	#define DG_Z 0.0175  //Added to fix super close to cam issues.
	#define DI_Z 0.125  //and cutoff for cam
	#define BMT 1
	#define DF_Z 0.1375
	#define LBC 2  //Letter Box Correction Offsets With X & Y
	#define DH_Z 0.256
	#define DH_W 0.0
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.450 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define NDW 1
	#define PEW 1
#elif (App == 0x621202BC ) //Vanquish DGVoodoo2 ***
	#define DA_X 0.05
	#define DA_Y 15.0
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define RHW 1
	#define NFM 1
	#define PEW 1
#elif (App == 0xA1214CD1 ) //Life is Strange
	#define DA_X 0.125
	#define DA_Y 8.0
	#define DA_Z 0.0005
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define PEW 1
	#define DSW 1
	#define DAA 1
#elif (App == 0xEB5CDE17 ) //Man Of Medan
	#define DA_W 1
	#define DA_X 0.04375
	#define DA_Y 20.0
	#define DB_Z 0.3
	#define DF_Y 0.010
	 
	#define DE_X 1
	#define DE_Y 0.300
	#define DE_Z 0.300
	#define RHW 1
	#define NDW 1
	#define SPF 1
	#define DD_W -0.240
	#define LBM 1
	#define DI_X 0.879
	#define DI_Y 0.120
#elif (App == 0xB5AE6CBA ) //Rage 2
	#define DA_W 1
	#define DA_X 0.04
	#define DA_Y 125.0
	 
	#define DE_W 0.06
	#define PEW 1
	#define DAA 1
#elif (App == 0x8CEACA5C ) //Dead Island
	#define DA_X 0.0475
	#define DA_Y 8.75
	 
	#define DF_Y 0.0875
#elif (App == 0xBE9001DC ) //Dead Island DE
  #define DA_W 1
	#define DA_X 0.0475
	#define DA_Y 8.75
	 
	#define DF_Y 0.0875
#elif (App == 0x7C0F0E77 ) //Soulcaliber VI
	#define DA_W 1
	#define DA_X 0.070
	#define DA_Y 70.0
	 
	#define DE_X 1
	#define DE_Y 0.300
	#define DE_Z 0.375
	#define PEW 1
	#define NDW 1
#elif (App == 0x424052D0 || App == 0xF23A4A0B ) //Talos Principle
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.065
	#define DA_Y 22.5
	#define DA_Z 0.100
	#define DB_Z 0.075
	 
	#define DE_X 4
	#define DE_Y 0.5
	#define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.125
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.800 //SM Tune
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 0     //HQ Smooth
	#define WSM 3
	#define DB_W 14
    #define HMT 1
	#define HMC 0.506
	#define DAA 1
#elif (App == 0x9C5C8E4D ) //INSIDE
	#define DA_X 0.050
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define BDF 1
	#define DC_X 0.6
	#define DC_Y -0.4
	#define DC_Z 0.087
	#define DC_W -0.03
	#define DB_X 1
#elif (App == 0xABADF9C2 ) //Sonic Robo Blast 2
	#define DA_X 0.1
	#define DA_Y 27.5
	#define DB_Z 0.155
	 
	#define DF_Y 0.1
#elif (App == 0x3867F04A ) //Castle of Illusion
	#define DA_X 0.1
	#define DA_Y 40.0
	#define DA_Z 0.0005
	 
	#define DF_Y 0.01
	#define DAA 1
#elif (App == 0x76CD4369 ) //Resident Evil
	#define DA_X 0.06875
	#define DA_Y 24.0
	#define DA_Z 0.00025
	 
	#define DE_X 2
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DF_Y 0.024
	#define DAA 1
	#define SPF 1
	#define DD_X 1.333
	#define DD_Y 0.933
	#define DSW 1
	#define RHW 1
	#define LBM 1
	#define DI_X 0.879
	#define DI_Y 0.125
#elif (App == 0x1AB66F8F ) //Dawn Of War III
	#define DA_X 0.125
	#define DA_Y 25.0
	#define DB_Z 0.125
	#define DA_Z 0.002
	 
	#define DE_X 2
	#define DE_Y 0.200
	#define DE_Z 0.375
	#define DF_Y 0.250
	#define DAA 1
#elif (App == 0xD86799B9 ) //Devil May Cry 5
	#define DA_W 1
	#define DA_X 0.0625
	#define DF_Y 0.020
	#define DA_Y 20.00
 //   #define DA_Z -0.375
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DG_W 0.125
	#define BMT 1    
	#define DF_Z 0.1111 //0.100 //0.125 
	#define DG_Z 0.0325//0.0275//Min
    #define DI_Z 0.0625//Trim
	#define SMS 0      //SM Toggle Separation
	#define DL_X 0.500 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define BDF 1
	#define DC_X 0.025
	#define DC_Y 0.025
	#define DC_W -0.012
	#define PEW 1
	#define DSW 1
	#define RHW 1
#elif (App == 0x5BC45541 ) //Contrast
	#define DA_X 0.075
	#define DA_Y 20.0
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DF_Y 0.051
#elif (App == 0xEA61D579 || App == 0xCFCF902B ) //The Citadel
	#define DA_W 1
	#define DA_X 0.035
	#define DA_Y 18.6
	 
	#define DF_Y 0.05625
	#define SPF 1
	//#define DD_Y 0.675
	//#define DD_W -0.4815
	#define DD_Y 0.9
	#define DD_W -0.111
	#define WSM 3
	#define DB_W 21
	#define DSW 1
#elif (App == 0xB2B11A3C ) //Catherine with a K
	#define DA_X 0.05
	#define DF_Y 0.0125
	#define DA_Y 50.0
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.4375
	#define PEW 1
	#define DAA 1
#elif (App == 0x7ABE98F0 ) //Samurai Jack
	#define DA_W 1
	#define DA_X 0.1375
	#define DF_Y 0.0125
	#define DA_Y 20.0
	 
	#define DE_X 2
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DAA 1
#elif (App == 0xC4B4435F ) //Night Cry
	#define DA_X 0.06  //ZPD
	#define DF_Y 0.025 //Separation
	#define DA_Y 50.0  //Depth
	#define DB_X 1
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
#elif (App == 0x49F7B9C0 ) //Control DX12
	#define DA_X 0.05
	#define DF_Y 0.025
	#define DA_Y 17.5
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.1  //Pop out allowed
    #define OIF 0.250 //Fix enables if Value is > 0.0
	#define DI_W 1.0 //Adjustment for REF
    #define DG_Z 0.025 //Min
    #define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
	#define DL_Y 0.45
	#define PEW 1
	#define DAA 1
#elif (App == 0x5A7B540A ) //We Where Here Too
	#define DA_W 1
	#define DB_X 1
	#define DA_X 0.05625
	#define DA_Y 42.5
	 
	#define NDW 1
#elif (App == 0x6AB553A ) //We Where here Together
	#define DA_W 1
	#define DB_X 1
	#define DF_Y 0.05625
	#define DA_X 0.05625
	#define DA_Y 56.25
	 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define WSM 5
	#define DB_W 4
	#define FOV 1
	#define DAA 1
	#define NDW 1
#elif (App == 0x75930301 ) //Void Bastards
	#define DA_W 1
	#define DB_X 1
	#define DF_Y 0.02625
	#define DA_X 0.0875
	#define DA_Y 56.25
	 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.375
	#define DSW 1
	#define RHW 1
#elif (App == 0xDF3F2AB6 ) //Cloud Punk
	#define DA_W 1
	#define DB_X 1
	#define DF_Y 0.1
	#define DA_X 0.0325
	#define DA_Y 72.5
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DSW 1
	#define RHW 1
	#define NFM 1
#elif (App == 0x4551A746 ) //The Swapper
	//#define DB_X 1
	#define DF_Y 0.0125
	#define DA_X 0.05
	#define DA_Y 99.0
	#define DA_Z -0.010
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DF_Z 1.0
	//#define DD_X 0.800
	//#define DD_Y 0.705
	//#define DD_Z 0.250
	//#define DD_W 0.4125
	//#define SPF 1
	#define DSW 1
	#define RHW 1
#elif ( App == 0xE0B7AF16 || App == 0xB84E12B6 ) //Horizon Chase Turbo
	#define DA_W 1
	#define DA_Y 12.5
	#define DA_X 0.175
	#define DF_Y 0.0625
	 
	#define DA_Z -0.125
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DSW 1
#elif (App == 0xCF0046B7 ) //SpecOps The Line
	#define DA_Y 15.0
	#define DA_X 0.05
	#define DF_Y 0.01
	 
	#define DA_Z -0.00125
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DSW 1
	#define PEW 1
	#define FOV 1
#elif (App == 0x6C433D70 ) //Q.U.B.E 2
	#define DA_W 1
	#define DA_Y 75.0
	#define DA_X 0.05625
	#define DF_Y 0.01
	 
	#define DB_Z 0.05625
	#define DA_Z 0.00025
	#define DE_X 4
	#define DE_Y 0.450
	#define DE_Z 0.375
	#define PEW 1
	#define FOV 1
	#define WSM 3
	#define DB_W 18
#elif (App == 0xD87951C4 ) //Horizon Zero Dawn
	//#define DA_W 1
	#define DA_Y 12.5
	#define DA_X 0.05
	//#define DF_Y 0.01
	 
	#define DB_Z 0.05
	#define DA_Z 0.0005
	#define DE_X 2
	#define DE_Y 0.3
	#define DE_Z 0.375
	#define PEW 1
	#define FOV 1
#elif (App == 0xF1BFCA91 ) //ELEX
	//#define DA_W 1
	//#define DA_Y 12.5
	#define DA_X 0.1
	//#define DF_Y 0.1
	 
	//#define DB_Z 0.1
	//#define DA_Z 0.0005
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.300
	#define BMT 1
	#define DF_Z 0.100
	#define PEW 1
	#define DSW 1
#elif (App == 0x2E63D83A ) //Kingdom Come Diliverance
	#define DA_W 1
	#define DA_Y 25.0
	#define DA_X 0.060
	//#define DF_Y 0.1
	 
	//#define DB_Z 0.1
	//#define DA_Z 0.0005
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.300
	#define PEW 1
	#define FOV 1
#elif (App == 0xF9341C1 ) //Valheim
	#define DA_W 1
    #define DB_X 1
	#define DA_Y 10.0
	#define DA_X 0.05125
	#define DF_Y 0.005
	 
	//#define DB_Z 0.125
	#define DA_Z 0.001
	#define DE_X 2
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.15
	#define PEW 1
	#define DAA 1
#elif (App == 0xA05A15C4 ) //Spooky's House of Jump Scares
	//#define DA_W 1
    //#define DB_X 1
	//#define DA_Y 12.5
	#define DA_X 0.150
	//#define DF_Y 0.1
	 
	//#define DB_Z 0.125
	//#define DA_Z 0.0005
	#define DE_X 1
	//#define DE_Y 0.500
	//#define DE_Z 0.300
	#define DSW 1
	#define RHW 1
	#define NFM 1
	#define SPF 1
	#define DD_X 0.625
	#define DD_Y 0.700
	#define DD_Z 0.600
	#define DD_W -0.425
#elif (App == 0x483A8BD9 ) //Song of Horror
	#define DA_W 1
    //#define DB_X 1
	#define DA_Y 112.5
	#define DA_X 0.1125
	#define DF_Y 0.1
	 
	//#define DB_Z 0.125
	//#define DA_Z 0.0005
	#define DE_X 2
	//#define DE_Y 0.500
	//#define DE_Z 0.300
	#define PEW 1
	#define FOV 1
    #define DAA 1
	//#define DSW 1
	//#define RHW 1
	//#define NFM 1
	//#define SPF 1
	//#define DD_X 0.625
	//#define DD_Y 0.700
	//#define DD_Z 0.600
	//#define DD_W -0.425
#elif (App == 0xB43B3B36 ) //Bendy and the Ink Machine
	#define DA_W 1
    #define DB_X 1
	#define DA_Y 12.5
	#define DA_X 0.120
	#define DF_Y 0.025
	 
	//#define DB_Z 0.125
	//#define DA_Z 0.0005
	#define DE_X 1
	//#define DE_Y 0.500
	#define DE_Z 0.300
	#define PEW 1
	#define FOV 1
    //#define DAA 1
	#define DSW 1
	//#define RHW 1
	//#define NFM 1
	//#define SPF 1
	//#define DD_X 0.625
	//#define DD_Y 0.700
	//#define DD_Z 0.600
	//#define DD_W -0.425
#elif (App == 0x2EFA1BAF ) //Betrayer
	//#define DA_W 1
	#define DA_Y 15
	#define DA_X 0.0475
	#define DA_Z 0.001
	//#define DF_Y 0.01
	 
	//#define DB_Z 0.05625
	//#define DA_Z 0.00025
	#define DE_X 7
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.125//PoP
    #define OIF 0.25 //Fix enables if Value is > 0.0
	#define DI_W 1.25	
	#define PEW 1
	#define FOV 1
	#define WSM 3
	#define DB_W 16
#elif (App == 0x75CE6926 ) //Chronicle of Riddick Assault on Dark Athena
	//#define DA_W 1
	//#define DA_Y 15.0
	//#define DA_X 0.1325
	#define DA_X 0.0666
	//#define DF_Y 0.01
	 
	//#define DB_Z 0.05625
	//#define DA_Z 0.00025
	#define DE_X 2
	//#define DE_Y 0.450
	//#define DE_Z 0.375
	#define PEW 1
	#define DSW 1
	#define RHW 1
#elif (App == 0xAA5644F9 || App == 0x1981FECC ) //Need For Speed: Heat | Payback
	#define DA_W 1
	#define DA_Y 10.0
	#define DA_X 0.1
	#define DF_Y 0.1
	 
	//#define DB_Z 0.1
	//#define DA_Z 0.00025
	//#define DE_X 2
	//#define DE_Y 0.450
	//#define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.125
	//#define DG_Z 0.100 //Min
    //#define DI_Z 0.150 //Trim
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define PEW 1
	#define DAA 1
#elif (App == 0xBD8B2F39 ) //Assassin's Creed Odyssey
	#define DA_W 1
	#define DA_Y 30.0
	#define DA_X 0.05
	#define DF_Y 0.025
	 
	//#define DB_Z 0.125
	#define DA_Z -0.3
	#define DE_X 2
	#define DE_Y 0.250
	#define DE_Z 0.375
	#define DG_W 0.4 //Pop out allowed
	#define PEW 1
	#define FOV 1
#elif (App == 0x3D00A2BC ) //SM64 us f3dx2e
	#define DA_Y 12.5
	#define DA_X 0.050
	 
	#define DE_X 2
#elif (App == 0x892FCE80 ) //Star Trek EliteForce II
	#define DA_Y 30.0
	#define DA_X 0.100
	#define DB_Z 0.250
	 
	#define DE_X 4
	#define DE_Z 0.375
	#define WSM 3
	#define DB_W 25
#elif (App == 0xC54A173B ) //Dead or Alive 6
	#define DA_W 1
	#define DA_Y 60.0
	#define DA_X 0.06
	 
	#define RHW 1
	#define NDW 1
	#define NFM 1
#elif (App == 0x934DC835 || App == 0xD063D305 || App == 0xE29F2D4 ) //Dead Rising | Dead Rising 2 | Dead Rising 2 Off The Record
	#define DA_X 0.050
	#define DF_Y 0.025
	#define DA_Y 12.5
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.3875
	#define DG_W -0.05//disallowed popout
	#define OIF 0.1    //Fix enables if Value is > 0.0
	#define DI_W 1.5  //Adjustment for REF
    #define DG_Z 0.050 //Min
    #define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
	#define PEW 1
	#define NDW 1
#elif (App == 0xF28EC9C2 || App == 0xF28EC143 ) //Dead Rising 3 | Dead Rising 4
	#define DA_Y 20.0
	#define DA_X 0.1
	 
	#define DE_X 2
	#define DE_Z 0.375
	#define RHW 1
	#define NDW 1
	#define NFM 1
#elif (App == 0xC402F6B8 ) //Iron Harvest
	#define DA_W 1
	#define DA_Y 125.0
	#define DA_Z 0.0015
	#define DA_X 0.250
	 
	#define DE_X 1
	#define DE_Y 0.1
	#define DE_Z 0.4
	#define PEW 1
	#define NDW 1
	#define DAA 1
#elif (App == 0xB3729F40 ) //Rocket League Steam
	#define DA_Y 50.0
	#define DA_X 0.100
	 
	#define DSW 1
	#define NDW 1
	#define PEW 1
#elif (App == 0xFBC55DDE || App == 0x836AD72D ) //Tormented Shouls & Demo 
	#define DA_W 1
	#define DA_Y 15.0
	#define DA_Z 0.00125
	#define DA_X 0.06125
	#define DB_X 1
	 
	#define DE_X 2
//#define DG_Z 0.288 // This works. But, may be a bit overboard. Use this if users complain about edge pop out issues. I don't think it's needed.
	#define PEW 1
#elif (App == 0x6B2D15D6 ) //Rec Room Non VR
	#define DA_W 1
	#define DA_Y 11.25
	//#define DA_Z 0.00125
	#define DA_X 0.100
	#define DF_Y 0.108
	#define DB_X 1
	 
	#define DE_X 1
	#define DE_Y 0.6
	#define DE_Z 0.375
	#define DG_Z 0.075
	#define NDW 1
	#define DSW 1
#elif (App == 0xD0F69E54 ) //Yooka-Laylee
	#define DA_Y 12.50
	#define DA_Z 0.001
	#define DA_X 0.091
	#define DF_Y 0.005
	#define DB_X 1
	 
	#define DE_X 2
	#define DE_Y 0.325
    #define BMT 1    
    #define DF_Z 0.150
	#define DG_W 0.15 //allowed popout
	//#define DE_Z 0.375
#elif (App == 0x755C7E43 ) //Yooka-Laylee and the Impossible Lair
	#define DA_W 1
	#define DA_Y 80.0
	#define DA_Z 0.00025
	#define DA_X 0.0725
	#define DF_Y 0.010
	#define DB_X 1
	 
	#define DE_X 2
	#define DE_Y 0.225
	#define DG_Z 0.41125
	#define DF_X float2(0.20,0.0)
	//#define DG_W 0.08
	#define BMT 1
	#define DF_Z 0.04
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.725  //SM Tune
	#define DL_W 0.00 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
	#define PEW 1
#elif (App == 0x87AC1510 ) //Ghostrunner
	#define DA_W 1
	#define DA_Y 245.0
	#define DA_Z 0.0000025 // Magic
	#define DA_X 0.050
	#define DF_Y 0.025
	#define DB_Z 0.0625
	 
	#define BMT 1
	#define DF_Z 0.05
	#define DE_X 4
	#define DE_Y 0.650
	#define DE_Z 0.400
	#define WSM 5
	#define DB_W 17
	#define DF_X float2(0.1,0.0)
	#define DG_Z 0.100 //Min
    #define DI_Z 0.100 //Trim
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.810 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define PEW 1
	#define DAA 1
#elif (App == 0x11E6C55E ) //The Suicide of Rachel Foster
	#define DA_W 1
	#define DA_X 0.0125
	#define DF_Y 0.045
	#define DA_Y 35.0//6.50
	#define DA_Z -0.250//-1.75
	#define DB_Z 0.025
 
	#define DE_X 2
	#define DE_Y 0.750
	#define DE_Z 0.425
    #define DG_Z 0.060 //Min
    #define DI_Z 0.045 //Trim
	//#define DG_W 0.125 //Allow much popout "Please don't abuse this."
    #define BMT 1    
    #define DF_Z 0.130 //This had to be adjusted
    //#define AFD 1
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.925 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth  
	#define PEW 1
	#define DAA 1
	#define RHW 1
	#define FOV 1
	//#define WSM 2
	//#define DB_W 2
#elif (App == 0xFC960068 ) //Devolverland Expo
	#define DA_W 1
	#define DA_Y 30.0
	#define DA_X 0.050
	#define DB_Z 0.050
	 
	#define DE_X 4
	#define DE_Y 0.50
	#define DE_Z 0.375
	#define WSM 2
	#define DB_W 3
	#define PEW 1
	#define DAA 1
#elif (App == 0x59DA13F1 ) //Conarium
	#define DA_W 1
	#define DA_Y 18.75
	#define DA_X 0.0875
	#define DF_Y 0.0328125
	#define DB_Z 0.075
	 
	#define DE_X 4
	#define DE_Y 0.525
	#define DE_Z 0.400
	#define DG_Z 0.305
	#define DG_W 0.0875 //Allow much popout "Please don't abuse this."
	#define PEW 1
	#define DAA 1
	#define RHW 1
	#define WSM 2
	#define DB_W 4
	#define DF_X float2(0.150,0.0)
#elif (App == 0xCE21A723 ) //Bully Scholarship Edition
	#define DA_Y 13.0
	#define DA_X 0.070
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DG_Z 0.360
	#define BMT 1
	#define DF_Z 0.1375
	#define DSW 1
	#define FOV 1
#elif (App == 0xBCCAD1AE || App == 0x3D2B24D7 ) //Project Cars | Project Cars 2
	#define DA_Y 7.0
	//#define DA_Z 0.000075
	#define DA_X 0.16875
	//#define DF_Y 0.01
 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.400
	#define DG_Z 0.125 //0.125//0.3125
	#define DE_W 0.275//0.275//0.35625
	#define DG_W 0.20 // Needed for old car.
	#define BMT 1
	#define DF_Z 0.165
	#define PEW 1
	#define DAA 1
	#define DSW 1
	#define NDW 1
#elif (App == 0x98C69E31 || App == 0xA8778B7D ) // F1 2019 | F1 2020 DX12
	#define DA_W 1
	#define DG_W 0.25
	#define DA_Y 14.5
	#define DA_X 0.07
	 
	#define DE_X 2
	#define DE_Z 0.400
	#define DG_Z 0.400
	#define PEW 1
	#define NDW 1
#elif (App == 0x164EF6B5 ) //Grid 2019
	#define DA_W 1
	#define DA_Y 11.5
	#define DA_X 0.15875
	#define DE_X 1
	//#define DE_Y 0.50
	#define DE_Z 0.400
	//#define DG_Z 0.125
	#define DG_W 0.25
	#define BMT 1
	#define DF_Z 0.1625
	#define PEW 1
	#define DAA 1
	//#define DSW 1
	#define NDW 1
#elif (App == 0x54568EA ) //Assetto Corsa
	#define DA_X 0.05
	 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W 0.2
	#define PEW 1
	#define DAA 1
	#define NDW 1
	#define FOV 1
#elif (App == 0x7658447E ) //Dagon*
	#define DA_W 1
	#define DB_X 1
	#define DA_X 0.0625
	#define DA_Y 11.5
	#define DA_Z 0.00025
	 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.375
	#define DB_Z 0
	#define DG_W 0.25
	#define DSW 1
	#define PEW 1
#elif (App == 0xC57720A6 ) //Crysis 2 DX11 1.9
	#define DA_X 0.07
	//#define DA_Y 11.5
	#define DA_Z 0.00025
	 
	#define DE_X 4
	//#define DE_Y 0.625
	//#define DE_Z 0.375
	//#define DG_W 0.25
	#define WSM 2
	#define DB_W 7
	#define DF_X float2(0.225,0.0)
	#define DSW 1 //?
	#define PEW 1
	#define RHW 1
#elif (App == 0x194A6354 ) //The Medium
    #define DA_W 1
	#define DA_X 0.125
    #define DF_Y 0.0225
	#define DA_Y 55.0
	#define DA_Z -0.025 // This can be still adjusted.
    #define DB_Z 0.145
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DG_W 0.6125
	#define PEW 1	
#elif (App == 0xD829EFC1 ) //Ride 4
	#define DA_W 1
	#define DA_Y 16.25
	#define DA_X 0.13
	#define DE_X 2
	#define DE_Y 0.16875
	#define DE_Z 0.4875
	//#define DG_Z 0.125 //Near
	#define DG_W 0.7
	#define BMT 1
	#define DF_Z 0.165
	#define PEW 1
	#define NDW 1
#elif (App == 0x19D0F410 ) //Zombie Army Trilogy
	#define DA_Y 12.5
	#define DA_X 0.155
	#define DA_Z -0.00025
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DG_W 0.7
	//#define BMT 1
	//#define DF_Z 0.165
	#define PEW 1
	#define NDW 1
#elif (App == 0x8842D13 ) //Genshin Impact
	#define DA_W 1
    #define DB_X 1
	#define DA_Y 9.375
	#define DA_X 0.1
	#define DA_Z -0.01
	 
	#define DE_X 1
	//#define DE_Y 0.4375
	#define DE_Z 0.375
	#define DF_Y 0.01
	#define DG_W 0.1
	#define NDW 1
#elif (App == 0xEEAF4DE ) //Guardians of the galaxy ****
    #define DA_W 1
	#define DA_Y 26.00 //31.25//52
	#define DA_X 0.050
	#define DF_Y 0.0375
	#define DB_Z 0.110
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.420
	#define DG_W 0.300 //0.25 //0.1625//Pop
	#define DG_Z 0.025 //0.040
	#define DI_Z 0.030
	#define BMT 1
	#define DF_Z 0.155
	#define OIF 0.125    //Fix enables if Value is > 0.0
	#define DI_W 2.75 //3.25 //Adjustment for REF
	#define SMS 0 //SM Toggle Separation
	#define DL_X 0.500 //0.325 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DAA 1
	#define PEW 1
#elif (App == 0x88C50B03 ) //League of Legends
	#define DA_X 0.2
	#define DF_Y 0.2
	#define DA_Y 12.5
    #define DA_Z 0.004
	#define DB_Z 0.175
	 
	#define DE_X 1
	#define DE_Y 0.60
	#define DE_Z 0.375
	#define DG_W 0.1 //Allow some popout
	#define PEW 1
	#define DAA 1
#elif (App == 0x1551DBDA || App == 0x969C124A) //The Forgotten City //Steam //Windows Store
	#define DA_W 1
	#define DA_X 0.05//0.09
	#define DF_Y 0.015//0.0425
	#define DA_Z 0.000375
	#define DA_Y 16.25 //8.75
	#define DB_Z 0.2
	 
	#define DE_X 1
	#define DE_Y 0.315
	#define DE_Z 0.375
	#define DG_W 0.875 //0.9 if 0.1 zdp
	#define DG_Z 0.015
	#define PEW 1
	#define FOV 1
#elif (App == 0xD698BDD3 ) //Call of Juarez Gunslinger ****
	#define DA_X 0.045
	#define DF_Y 0.025
	#define DA_Y 12.5
	 
	#define DB_Z 0.175 
	//#define DA_Z -0.000125
	//#define BDF  1 //This didn't seem needed anymore for the steam version.
	//#define DC_X 0.22
	//#define DC_Y -0.37
	//#define DC_Z 0.16
	#define SPF 1 //This offset is still the same. Wonder what changed here.
	//#define DD_X 1
	#define DD_Y 1.067
	#define DG_Z 0.09375 //Min
	#define PEW 1
	//#define FOV 1
#elif (App == 0xA4F3EEC3 ) //Godfall ****
	#define DA_W 1
	#define DA_X 0.050
	#define DA_Z -0.025
	#define DA_Y 35.0
	 
	#define DE_X 1
	//#define DE_Y 0.5
	#define DE_Z 0.375
	#define PEW 1
	#define NDW 1    
#elif (App == 0x2B22A265 ) //Immortals Fenyx Rising
	#define DA_W 1
	#define DA_X 0.175
	#define DF_Y 0.0375
	//#define DA_Z -0.15
	#define DA_Y 15.0
	 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.375
	#define DB_Z 0.125
	//#define DG_W -0.125//Disallow Pop
    #define DG_Z 0.075 //Min
    #define DI_Z 0.225 //Trim
	#define BMT 1
	#define DF_Z 0.05
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 0     //HQ Smooth
	#define DSW 1
	#define PEW 1
	#define NDW 1
#elif (App == 0xBCF34171 ) // Raji: an Ancient Epic EE
	#define DA_W 1
	#define DA_X 0.175
	#define DF_Y 0.05    
	//#define DA_Z -0.1
	#define DA_Y 32.5
 
	#define DE_X 2
	#define DE_Y 0.300
	#define DE_Z 0.375
	//#define DB_Z 0.250
	#define DG_W -0.125//0.15 //Disallow Pop
	#define OIF 0.0125    //Fix enables if Value is > 0.0
	#define DI_W 2.0 //1.75 //Adjustment for REF
    #define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8025, 0.610,  0.501, 0.0925) //Pos A = XY White & B = ZW Dark 
    #define DN_Y float4( 0.1975, 0.610,  0.0  , 0.0  ) //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.0  , 0.0  ,  0.0  , 0.0  ) //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0  , 0.0  ,  0.0  , 0.0  ) //Size = Menu [ABC] D E F
    #define DJ_Y float4( 21., 21., 21., 1000.0);              //Menu Detection Type   
    #define DJ_Z float3( 1000, 1000, 1000);           //Set Match Tresh 1000 is off
	#define BMT 1
	#define DF_Z 0.1
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.550 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 6     //HQ Smooth
	#define PEW 1
#elif (App == 0x921BC951 ) //SpongeBob SquarePants: Battle for Bikini Bottom - Rehydrated
	#define DA_W 1
	#define DA_X 0.120
	#define DF_Y 0.05
	#define DA_Y 22.0
	#define DA_Z 0.000120  
	 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.375
	#define DG_W 0.120
	#define DG_Z 0.35
	#define NDW 1
#elif (App == 0xEDC64E2B ) //The Patheless ****
	#define DA_W 1
	#define DA_Y 75.0
	#define DA_X 0.025
	#define DF_Y 0.025
	 
	#define DE_X 1
	#define DE_Y 0.300
	#define DE_Z 0.375
	#define PEW 1
#elif (App == 0xA34503F1 || App == 0xE0CAB4F3 ) //[Gothic 1.08k_mod - Gothic 2: Night of the Raven] with Kirides GD3D11 Mod
	#define DA_Y 25.0
	#define DA_X 0.05
	#define DF_Y 0.0125
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DG_Z 0.411
	#define NDW 1
	#define RHW 1
	#define NFM 1
#elif (App == 0x509F5AD3 ) //Mortal Shell
	#define DA_W 1
	#define DA_X 0.225
	//#define DF_Y 0.025
	#define DA_Y 15.0
	//#define DA_Z -0.5
	#define DB_Z 0.320
	 
	#define DE_X 1
	#define DE_Y 0.45
	#define DE_Z 0.375
	#define DG_Z 0.375
	//#define NDW 1
	#define PEW 1
	#define DAA 1
	#define LBC 2  //Letter Box Correction Offsets With X & Y
	#define DH_Z 0.255
	#define DH_W 0.0
#elif (App == 0x3C982FAC ) //Forza Horizon 4  
	#define DA_W 1
	#define DA_X 0.1
	//#define DF_Y 0.05
	#define DA_Y 7.5
	#define DB_Z 0.250
	//#define DA_Z -0.00025  
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.375 //Allow popout
    //#define DG_Z 0.025
	#define BMT 1    
	#define DF_Z 0.125
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define NDW 1
	#define PEW 1
	#define DAA 1
#elif (App == 0x3C98315F ) //Forza Horizon 5  
	#define DA_W 1
	#define DA_X 0.175 //0.2 // 0.150
	//#define DF_Y 0.05
	#define DA_Y 12.0  //11.0 // 15.0
	#define DB_Z 0.225
	//#define DA_Z -0.00025  
	 
	#define DE_X 1
	#define DE_Y 0.250
	#define DE_Z 0.475
	//#define DG_W 0.375 //Allow popout
	#define DG_Z 0.150 //0.025 //Min
    #define DI_Z 0.125 //0.250 //Trim
	#define BMT 1    
	#define DF_Z 0.111
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.800 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    #define HMT 1
	#define HMC 0.625
	#define NDW 1
	#define PEW 1
	#define DAA 1
#elif (App == 0x3303C19A ) //Mafia Definitive Edition
	#define DA_W 1
	#define DA_X 0.175
	#define DF_Y 0.025
	#define DA_Y 10.0
	#define DB_Z 0.125
	#define DA_Z -0.125  
	 
	#define DE_X 1
	#define DE_Y 0.325
	#define DE_Z 0.375
	#define DG_W 0.125
	#define DG_Z 0.06
	#define PEW 1
#elif (App == 0x19237E38 ) //The Witness
	#define DA_W 1
	#define DA_X 0.2
	#define DF_Y 0.02
	#define DA_Y 15.0
	//#define DB_Z 0.100
	//#define DA_Z -0.125  
	 
	#define DE_X 1
	//#define DE_Y 0.5
	#define DE_Z 0.375
	#define DG_W 0.3
	//#define DG_Z 0.06
	#define DAA 1
#elif (App == 0x4F255CDB ) //Mortal Kombat 11 DX11**** Note needs dx12
	#define DA_W 1
	#define DA_Y 22.5  //adjusted
	//#define DA_Z 0.004 //This was the issue
	  //adjusted
	#define DA_X 0.125 //adjusted
	#define DF_Y 0.140 //adjusted
	#define DE_X 1
	#define DE_Y 0.300 //adjusted
	#define DE_Z 0.400
	#define DG_W 0.300 //Added as a buffer to allow little bit of popout.
	#define DB_Z 0.300 //Added To counteract issues with close to cam animations.
	#define PEW 1 
#elif (App == 0xA80D9183 ) //LEGO Marvel Super Heros
	#define DA_X 0.175
	#define DF_Y 0.025
	#define DE_X 5
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define PEW 1
	#define DSW 1  
#elif (App == 0xC7A1F6B8 ) //NieR Replicant ver.1.22474487139
	#define DA_X 0.1375
	#define DF_Y 0.012
	#define DA_Y 25.0    
	//#define DB_Z 0.125
	 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.375
	#define DG_Z 0.01
	#define DI_Z 0.225
	#define BMT 1
	#define DF_Z 0.2125
	#define DG_W 0.1375
	#define DAA 1  
#elif (App == 0xDE4C92BB ) //Halo Infinite ****
	#define DA_W 1
	#define DA_X 0.07 //0.06 //0.075
	#define DF_Y 0.02 //0.018
	#define DA_Y 80.0 //90.0  
	//#define DB_Z 0.125
	 
	#define DE_X 4
	#define DE_Y 0.475
	#define DE_Z 0.4
	//#define DG_Z 0.01
	//#define DI_Z 0.225
	#define BMT 1
	#define DF_Z 0.110
	#define DG_W -0.075
	#define WSM 2 //Weapon Settings Mode
	#define DB_W 19//Weapon Selection
	#define DF_X float2(0.13,0.0)
	#define DJ_W 0.7 //1.0
	#define DG_Z 0.06
	#define DI_Z 0.070
	#define SMS 0      //SM Toggle Separation
	#define DL_X 0.640 //SM Tune
	#define DL_W 0.100   //SM Perspective
	#define NDW 1  
#elif (App == 0x98746774 ) //God of War
	#define DA_W 1
	#define DA_X 0.14
	#define DF_Y 0.070
	 
	#define DE_X 1
	#define DE_Y 0.450
	#define DE_Z 0.300
	#define DG_W -0.150
	#define DG_Z 0.0375  
	#define DI_Z 0.10
	#define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.0 //Adjustment for REF    
	#define BMT 1    
	#define DF_Z 0.140
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.500 //SM Tune
	#define DL_W 0.05  //SM Perspective
	#define DM_X 32    //HQ Tune
	#define DM_Z 5     //HQ Smooth
	#define DJ_X 0.242  //Range Smoothing
	#define PEW 1
#elif (App == 0x1A2B216E ) //Crysis Remastered
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.01
	#define DA_Y 11.25
	//#define DB_Z 0.100
 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.300
	#define BMT 1    
	#define DF_Z 0.125
	#define WSM 2 //Weapon Settings Mode
	#define DB_W 12
    #define DF_X 0.350 
	#define DJ_W 0.330
	#define PEW 1
#elif (App == 0x130E0740 ) //Crysis 2 Remastered
	#define DA_X 0.050
	#define DF_Y 0.005
	#define DA_Y 13.75
	//#define DB_Z 0.100
 
	#define DE_X 4
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define BMT 1    
	#define DF_Z 0.1375
	#define WSM 2 //Weapon Settings Mode
	#define DB_W 13
    #define DF_X 0.300 
	#define DJ_W 0.330
	#define PEW 1 
	#define DAA 1
#elif (App == 0x2EFB1B0B ) //Crysis 3 Remastered
	#define DA_X 0.025
	#define DF_Y 0.004
	#define DA_Y 24.0
	//#define DB_Z 0.100
 
	#define DE_X 4
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define BMT 1    
	#define DF_Z 0.180
	#define WSM 2 //Weapon Settings Mode
	#define DB_W 14
    #define DF_X 0.200 
	#define DJ_W 0.300
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.875 //SM Tune
	#define DL_W 0.05  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 6     //HQ Smooth
	#define FPS 2
    #define DK_X 2 //FPS Focus
    #define DK_Y 0
    #define DK_Z 0
    #define DK_W 2 //Set speed
	#define PEW 1 
	#define DAA 1 
#elif (App == 0x16848B0F ) // HITMAN 3****
    #define DA_W 1
    #define DA_X 0.140
    #define DF_Y 0.21    
     
    #define DE_X 1
    #define DE_Y 0.4375
    #define DE_Z 0.300
	#define PEW 1
#elif (App == 0xB5F52BDD ) // Abzu
    #define DA_W 1
    #define DA_X 0.075
    #define DF_Y 0.010
	#define DA_Y 20.00    
     
    #define DE_X 1
    //#define DE_Y 0.500
    #define DE_Z 0.300
	#define BMT 1    
	#define DF_Z 0.150 
	#define DG_Z 0.100//Min
    #define DI_Z 0.125 //Trim  
#elif (App == 0x2ECE874 ) //Roblox Games
    #define DA_W 1
    #define DA_X 0.050//0.044//0.071
    #define DF_Y 0.025
    #define DA_Y 57.5 //70.0 //35.0 //37.5
    #define DE_X 1
    #define DE_Y 0.500
    #define DE_Z 0.4375
    #define DG_W 1.5
	#define BMT 1    
	#define DF_Z 0.180 
	#define DG_Z 0.075 //0.0625 //Min
    #define DI_Z 0.200 //0.180 //0.175 //0.2125
    //#define DK_X 2 //FPS Focus Method
    #define DK_Y 0 //Eye Eye Selection
    #define DK_Z 2 //Eye Fade Selection
    #define DK_W 1 //Eye Fade Speed Selection
#elif (App == 0x4698602A ) // It takes two* WIP
    #define DA_W 1
    #define DA_Y 36.25 //Needs to be stronger since we zoom out a lot
    #define DA_X 0.060
    #define DF_Y 0.130//This was set too high. I noticed in you profiles you like to use this a lot. Try to keep it lower then what you set it too. Eye Strain can be caused by this.   
    //   //This option getting phased out and replaced with BMT: Balance Mode for 3D profile creation in most instances.
    #define DE_X 1
    #define DE_Y 0.250
    #define DE_Z 0.4375
    #define DG_W 0.350 //Allow popout   
	#define BMT 1     //BMT 1 needs DF_Z set to a value from 0.0-0.250
	#define DF_Z 0.120 
	#define DG_Z 0.060//Min
    #define DI_Z 0.200//Trim
    #define LBC 1     //Letter Box Correction
	#define DH_Z 0.0  //Pos offset X    
	#define DH_W -0.25//Pos offset Y
	#define NDW 1  
	#define DAA 1
#elif (App == 0x3B03D773 ) //HardReset Redux
    #define DA_X 0.0625
    #define DF_Y 0.0425
    #define DA_Y 11.0
    #define HMT 1
	#define HMC 0.5
	#define BMT 1    
	#define DF_Z 0.075 
	#define DG_Z 0.075 //Min
    #define DI_Z 0.225 //Trim
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.550 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
#elif (App == 0x51C8FDAA ) //Assassin's Valhalla
	#define DA_W 1
	#define DA_Y 45.0
    #define DA_Z -0.045
	#define DA_X 0.045
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DB_Z 0.1
	#define DF_Y 0.015
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF 
    //#define DG_W -0.100 //Disallow popout  
	#define BMT 1    
	#define DF_Z 0.05
	#define DG_Z 0.04  
	#define DI_Z 0.125
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.725 //SM Tune
	//#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 5     //HQ Smooth
	#define DJ_X 0.142   //Range Smoothing
    #define PEW 1 
#elif (App == 0x548BD6AD ) //Lost Ark
    #define DA_X 0.075
    #define DF_Y 0.225
	#define DA_Y 55
    //#define DA_Z 0.0015
	#define DE_X 1
	#define DE_Y 0.4
	#define DE_Z 0.4
	#define BMT 1    
	#define DF_Z 0.100
	#define DG_Z 0.070//Min
    #define DI_Z 0.070 //Trim
//    #define SPF 1
//    #define DD_Z 0.007 
#elif (App == 0xD360643 ) //BeamNG.drive
	#define DA_W 1
    #define DA_X 0.150 //0.2
    #define DF_Y 0.014
	#define DA_Y 12.5 //8.75
    //#define DA_Z 0.0015
    #define DE_X 1
	#define DE_Y 0.3
	#define DE_Z 0.4
	#define BMT 1    
	#define DF_Z 0.10
	#define DG_Z 0.050//Min
//	#define DE_W 0.160 //Max
    #define DI_Z 0.100 //Trim
//    #define DD_Z 0.007
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.8125 //SM Tune
	//#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.010, 0.017,  0.011, 0.980)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.960, 0.024,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 30.0, 28.0, 29.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
//    #define MMD 1 //Set Multi Menu Detection             //Off / On
//    #define DO_X float4( 0.040 , 0.0325, 0.995 , 0.005  ) //Pos A1 = XY Color & A2 = ZW Black 
//    #define DO_Y float4( 0.030 , 0.090 , 0.294 , 0.365  ) //Pos A3 = XY Color & B1 = ZW Color
//    #define DO_Z float4( 0.5 , 0.5 , 0.704 , 0.365  )     //Pos B2 = XY Black & B3 = ZW Color
//	#define DO_W float4( 30.0  , 30.0  , 30.0  , 30.0  ) //Tresh Hold for Color A & B and Color
//	#define DP_X float4( 0.45 , 0.45 ,  0.625  , 0.250) //Pos C1 = XY Color & C2 = ZW Black 
//    #define DP_Y float4( 0.550 , 0.485 ,  0.0  , 0.0) //Pos C3 = XY Color & D1 = ZW Color
//    #define DP_Z float4( 0.625 , 0.250 ,  0.0  , 0.0) //Pos D2 = XY Black & D3 = ZW Color
//	#define DP_W float4( 30.0  , 30.0  ,  1000.0   , 1000.0) //Tresh Hold for Color A1 & A3 and Color

#elif (App == 0x28900EB9 ) //Planet Zoo
	#define DA_W 1
    #define DA_X 0.1
    #define DF_Y 0.025
	#define DA_Y 77.5
    //#define DA_Z 0.0001
    #define DB_Z 0.250
    #define DE_X 1
	#define DE_Y 0.325
	#define DE_Z 0.350
	#define BMT 1    
	#define DF_Z 0.130
	#define DG_Z 0.100//Min
//	#define DE_W 0.0 //Max
    #define DI_Z 0.100 //Trim
#elif (App == 0x6EA7BBB ) //Tales from Borderlands
    #define DA_X 0.075
    #define DF_Y 0.005
	#define DA_Y 25.0
    #define DA_Z 0.0005
    //#define DB_Z 0.250
    #define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.375
	#define BMT 1    
	#define DF_Z 0.1
	#define DG_Z 0.100//Min
//	#define DE_W 0.0 //Max
    #define DI_Z 0.125 //Trim
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.0   //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
#elif (App == 0x8FDE4FCF ) //Ni No Kuni II: Revenant Kingdom****
    #define DA_X 0.075
    #define DF_Y 0.050
    #define DA_Y 12.50
    //#define DA_Z 0.0005
     
    #define DE_X 1
    #define DE_Y 0.375
    #define DE_Z 0.400
	#define BMT 1    
	#define DF_Z 0.125
	#define SMS 0      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.000 //SM Perspective
    #define PEW 1
#elif (App == 0xFA6649D4 ) //Shadow Warrior 3 ****
	#define DA_W 1
    #define DA_X 0.070
    #define DF_Y 0.0075
	#define DA_Y 40.0
    #define DA_Z 0.0001
    //#define DB_Z 0.250
	#define BMT 1    
	#define DF_Z 0.135
	#define DG_Z 0.170 //Min
//	#define DE_W 0.0 //Max
    #define DI_Z 0.3375//Trim
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.675 //SM Tune
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    #define FOV 1
    #define PEW 1
#elif (App == 0x45C250C6 ) //Dying Light 2
	#define DA_W 1
	#define DA_X 0.025
	#define DF_Y 0.051	
	#define DA_Y 30.0//10.0
	#define DA_Z -0.125
	 
	#define DE_X 2
	#define DE_Y 0.825
	//#define DE_Z 0.25
    //#define DG_W 0.100 //Pop
    #define DG_Z 0.090 //Min
    #define DE_W 0.105 //Max
    #define DI_Z 0.090 //0.090//0.100 //0.150 //Trim
	#define BMT 1
	#define DF_Z 0.060
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
	#define WSM 3 //Weapon Settings Mode
	//#define DB_W 7
	#define BDF 0    //Barrel Distortion Fix k1 k2 k3 and Zoom
	#define DC_X 0.00
	#define DC_Y 0.150
	#define DC_Z -0.030
	#define DC_W -0.0200
	#define NDW 1
	#define PEW 1
    #define FOV 1
	//#define RHW 1
    //#define NFM 1
#elif (App == 0xC150B2EC ) //FarCry 6 
	#define DA_W 1
	#define DA_X 0.045
	#define DF_Y 0.050	
	#define DA_Y 16.0
    //#define DA_Z 0.0002
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.400
    #define DG_Z 0.077 //Min
    #define DI_Z 0.175 //Trim
	#define BMT 1
	#define DF_Z 0.130
    #define DG_W 0.550 //Pop
	#define OIF 0.04375 //Fix enables if Value is > 0.0
	#define DI_W 2.5 //Adjustment for REF    
	#define DK_X 2 //FPS Hold 
	#define DK_Y 0 //FPS Both Eyes
	#define DK_Z 2 //FPS 0.3%
	#define DK_W 2 //FPS Speed 100%
	#define PEW 1
	#define NDW 1
#elif (App == 0xF844D5C3 ) //Tony Hawk's Pro Skater 1+2 
    #define DA_W 1
    #define DA_X 0.1125
    #define DF_Y 0.0125 
    #define DA_Y 150.0
    #define DE_X 1
    #define DE_Y 0.500
    #define DE_Z 0.400
    #define BMT 1    
    #define DF_Z 0.125 //Try to keep this in the lower end. The profile is really Good!!!!!
    #define FOV 1
#elif (App == 0x42BC6574 ) //Sleeping Doggs: Definitinve Edition****
    #define DA_X 0.075
    #define DF_Y 0.0025 
    #define DA_Y 7.25
    #define DE_X 1
    #define DE_Y 0.500
    #define DE_Z 0.400
    #define BMT 1    
    #define DF_Z 0.138 //This had to be adjusted
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.0   //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define LBC 2  //Letter Box Correction Offsets With X & Y
	#define DH_X 1.345
	#define PEW 1
#elif (App == 0x72632818 ) //Matrix Demo UE 5
    #define DA_W 1
    #define DA_X 0.025
    #define DF_Y 0.005 
    #define DA_Y 47.5
    #define BMT 1    
    #define DF_Z 0.030
	#define PEW 1
#elif (App == 0xCBE94135 ) //Anno: Mutationem
    #define DA_W 1
    #define DB_X 1
    #define DA_X 0.025
    #define DF_Y 0.010
    #define DA_Y 35
    //#define DA_Z -0.025
    #define DE_X 2
    #define DE_Y 0.375
    #define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.100
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.875 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3    //HQ Tune
	#define DM_Z 8     //HQ Smooth	
	#define PEW 1
#elif (App == 0x98E46BDC ) //Forgive Me Father
    #define DA_W 1
    #define DA_X 0.1875
    #define DF_Y 0.0125
    #define DA_Y 250.0
    #define DA_Z -1.0
    #define DE_X 1
    #define DE_Y 0.750
    #define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.125
	#define PEW 1
#elif (App == 0xAB93A702 ) //Nightmare Reaper
    #define DA_W 1
    #define DA_X 0.050
    #define DF_Y 0.025
    #define DA_Y 24.0
    #define DB_Z 0.075
    #define DE_X 4
    #define DE_Y 0.500
    #define DE_Z 0.375
    #define DG_W -0.1 //Pop
    #define BMT 1    
    #define DF_Z 0.125
    #define DG_Z 0.0300//Min
    #define DI_Z 0.0525//Trim
    #define SMS 3      //SM Toggle Separation
    #define DL_X 0.900 //SM Tune
    #define DL_W 0.000 //SM Perspective
    #define DM_X 3     //HQ Tune
    #define DM_Z 1     //HQ Smooth
    #define MMD 1 //Set Multi Menu Detection              //Off / On
    #define DO_X float4( 0.24  , 0.0375,  0.5   , 0.74   ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.76  , 0.775 ,  0.0   , 0.0    ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.0   , 0.0   ,  0.0   , 0.0    ) //Pos B2 = XY Black & B3 = ZW Color
    #define DO_W float4( 28.0  , 28.0  ,  1000.0, 1000.0 ) //Tresh Hold for Color A1 & A3 and Color B1 & B3 
    #define AFD 1
    #define WSM 4
    #define DB_W 3
    #define PEW 1
#elif (App == 0xBE557C30 ) //Golden Light
    #define DA_W 1
    #define DB_X 1
    #define DA_X 0.100
    #define DF_Y 0.0125
    #define DA_Y 187.5
    #define DB_Z 0.200
    //#define DA_Z 0.0
    #define DE_X 1
    #define DE_Y 0.500
    #define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.125
    #define DG_W 0.125 //Pop
	#define PEW 1
#elif (App == 0x70858D6 ) //PowerSlave Exhumed ****
    #define DA_X 0.250
    #define DF_Y 0.0125
    #define DA_Y 300.0
    #define BMT 1    
    #define DF_Z 0.500
    #define WSM 4
    #define DB_W 4
#elif (App == 0x3E2F4D65 ) //Inscryption
    #define DA_W 1
    #define DB_X 1
    #define DA_X 0.045
    #define DF_Y 0.0425
    #define DA_Y 17.0
    //#define DA_Z 0.0
    //#define DE_X 4
    //#define DE_Y 0.500
    //#define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.110
	//#define DG_Z 0.110//Min
    //#define DI_Z 0.160 //Trim
	#define PEW 1
	#define DSW 1
#elif ( App == 0x4F4E231E ) //Hob
	#define DA_Y 20.0
	#define DA_X 0.040
	#define DF_Y 0.040
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.125 //Pop out
	#define BMT 1    
	#define DF_Z 0.100
	#define DG_Z 0.050 //Min
	#define DI_Z 0.070 //Trim
	#define DAA 1
	#define SMS 0      //SM Toggle Separation
	#define DL_X 0.625 //SM Tune
	#define DL_W 0.050 //SM Perspective	
#elif ( App == 0x1C2203BC || App == 0x835B2D42) //TUNIC //Steam //Windows Store
    #define DA_W 1
    #define DB_X 1
	#define DA_Y 2.5
	#define DA_X 0.055
	#define DF_Y 0.150
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.125 //Pop out
	#define BMT 1    
	#define DF_Z 0.100
	#define DSW 1
	#define PEW 1
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	#define DL_W 0.0   //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 7     //HQ Smooth
#elif ( App == 0x42F66404 ) //Bayonetta
	#define DA_Y 41.0
	#define DA_X 0.037
	#define DF_Y 0.0125
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.2500 //Pop out
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.5 //Adjustment for REF
	#define BMT 1    
	#define DF_Z 0.1275
	#define PEW 1
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.775 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
#elif ( App == 0x8CF29E7A || App == 0xB212F82A ) //Maneater //Steam //Windows Store
    #define DA_W 1
	#define DA_Y 75.0
	#define DA_X 0.05
	#define DF_Y 0.02
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define BMT 1    
	#define DF_Z 0.500
	#define PEW 1
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.050 //SM Perspective
    #define LBC 1      //Letter Box Correction
	#define DH_Z 0.0   //Pos offset X    
	#define DH_W -0.236//Pos offset Y
#elif (App == 0xF14D1D3B ) //SniperElite 4 
    #define DA_X 0.05
    #define DF_Y 0.04
    #define DA_Y 20.0
    #define DE_X 1
    #define DE_Y 0.450
    #define DE_Z 0.450
    #define BMT 1    
    #define DF_Z 0.1
	#define DG_Z 0.03//Min
    #define DI_Z 0.06 //Trim
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.150, 0.240,  0.250, 0.925)  //Pos A = XY White & B = ZW Black 
    #define DN_Y float4( 0.296, 0.865,  0.0, 0.0)      //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)          //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.297, 0.0 , 0.0, 0.0 )         //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 2.0, 29.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	#define PEW 1
#elif (App == 0xE44B25B ) //Injustice 2
    #define DA_X 0.100
    #define DF_Y 0.0125
    #define DA_Y 15.00
    #define DE_X 1
    #define DE_Y 0.500
    #define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.125
	//#define DG_Z 0.100 //Min
    //#define DI_Z 0.150 //Trim
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define PEW 1
#elif (App == 0xE1D149FD ) //Max Payne 3 ****
	//#define DA_W 1
	#define DA_X 0.115
	#define DF_Y 0.050	
	#define DA_Y 25.0 //15
    //#define DA_Z 0.00025 //-1.0
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    //#define DG_Z 0.002 //Min
    //#define DI_Z 0.200 //Trim
	#define BMT 1
	#define DF_Z 0.130
    //#define DG_W 0.100 //Pop
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
	#define PEW 1
	#define DAA 1
#elif (App == 0x1CF7A476 ) //Sable
	#define DA_W 1
	#define DA_X 0.045
	#define DF_Y 0.045	
	#define DA_Y 25.0 //15
    //#define DA_Z 0.00025 //-1.0
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    #define DG_Z 0.001 //Min
    #define DI_Z 0.250 //Trim
	#define BMT 1
	#define DF_Z 0.12
    //#define DG_W 0.100 //Pop
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 30    //HQ Tune
	#define DM_Z 3     //HQ Smooth
	#define PEW 1
#elif (App == 0xC72BE846 ) //We Happy Few
	#define DA_W 1
	#define DA_X 0.125 //0.140 //0.150 //0.175
	#define DF_Y 0.045	
	#define DA_Y 7.5 //38.75
    //#define DA_Z -0.05 //-0.075 //0.00025
	#define DE_X 1
	#define DE_Y 0.520//0.520
	#define DE_Z 0.375
    #define DG_Z 0.100//0.175 //Min
    #define DI_Z 0.1625 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define DG_W 0.100 //Pop
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3    //HQ Tune
	#define DM_Z 2     //HQ Smooth
	#define PEW 1
#elif (App == 0x8F36286E ) //Deliver Us The Moon
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.035 //0.075	
	#define DA_Y 70.0
    //#define DA_Z -0.05 
	#define DE_X 2
	#define DE_Y 0.50
	#define DE_Z 0.375
    #define DG_Z 0.200//0.175 //Min
    #define DI_Z 0.200 //Trim
	#define BMT 1
	#define DF_Z 0.14
    //#define DG_W 0.100 //Pop
	//#define SMS 3      //SM Toggle Separation
	//#define DL_X 0.900 //SM Tune
	//#define DL_W 0.000 //SM Perspective
	//#define DM_X 3    //HQ Tune
	//#define DM_Z 2     //HQ Smooth
	#define DAA 1
	#define PEW 1
#elif (App == 0x3A1E37B8 ) //Breathedge
	#define DA_W 1
	#define DA_X 0.060
	#define DF_Y 0.035	
	#define DA_Y 13.0
    //#define DA_Z -0.05 //-0.075 //0.00025
	#define DE_X 2
	#define DE_Y 0.500//0.375
	#define DE_Z 0.375
    #define DG_Z 0.080//0.175 //Min
    #define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.130
    #define DG_W 0.100 //Pop
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 32    //HQ Tune
	#define DM_Z 6     //HQ Smooth
	#define PEW 1
#elif (App == 0x837F12C9 ) //QuantumBreak DX11
	#define DA_X 0.0425
	#define DF_Y 0.0425
	#define DA_Y 12.5
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 2     //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 32    //HQ Tune
	#define DM_Z 2     //HQ Smooth
	#define PEW 1
	#define DAA 1
#elif (App == 0xBB2E4EFB ) //MassEffect
	#define DA_X 0.050
	#define DF_Y 0.0375
	#define DA_Y 14.0
	 
	#define DE_X 1
	#define DE_Y 0.4400
	#define DE_Z 0.4375
    //#define DG_W 0.100 //Pop
    #define OIF 0.20 //Fix enables if Value is > 0.0
	#define DI_W 1.25 //Adjustment for REF
	#define BMT 1
	#define DF_Z 0.1375
    #define SMS 1     //SM Toggle Separation
	#define DL_X 0.800 //SM Tune
	//#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
	#define PEW 1
    #define DSW 1
    #define FOV 1
#elif (App == 0xBB2E50AE ) //MassEffect 2
	#define DA_X 0.050
	#define DF_Y 0.0375
	#define DA_Y 12.5
	 
	#define DE_X 1
	#define DE_Y 0.475
	#define DE_Z 0.400
    //#define DG_W 0.100 //Pop
    #define OIF 0.20 //Fix enables if Value is > 0.0
	#define DI_W 1.25 //Adjustment for REF
	#define BMT 1
	#define DF_Z 0.1375
    #define SMS 1     //SM Toggle Separation
	#define DL_X 0.800 //SM Tune
	//#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
	#define PEW 1
    #define DSW 1
    #define FOV 1
#elif (App == 0xBB2E5261 ) //MassEffect 3
	#define DA_X 0.050
	#define DF_Y 0.0375
	#define DA_Y 13.0
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    //#define DG_W 0.100 //Pop
    #define OIF 0.20 //Fix enables if Value is > 0.0
	#define DI_W 1.25 //Adjustment for REF
	#define BMT 1
	#define DF_Z 0.1375
    #define SMS 1     //SM Toggle Separation
	#define DL_X 0.75 //SM Tune
	//#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
	#define PEW 1
    #define DSW 1
    #define FOV 1
#elif (App == 0xDA130F0B ) //Poppy PlayTime Ch. 1
	#define DA_W 1
	#define DA_X 0.051
	#define DF_Y 0.031
	#define DA_Y 125.0
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.250
    //#define DG_W -0.500 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.75 //Adjustment for REF
	#define BMT 1
	#define DF_Z 0.065
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.775 //SM Tune
	//#define DL_W 0.00 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 6     //HQ Smooth
	#define PEW 1
    #define FOV 1
    #define WSM 2
    #define DB_W 16
    #define AFD 1
    #define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.050, 0.900,  0.2150, 0.8888) //Pos A = XY White & B = ZW Black 
    #define DN_Y float4( 0.133, 0.240,  0.3725, 0.0400) //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.545, 0.533,  0.405, 0.3620) //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.267, 0.375, 0.554, 0.542 ) //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30., 0.0, 30., 1000.0);                    //Menu Detection Type   
    #define DJ_Z float3( 26.0, 30.0, 30.0);              //Set Match Tresh   
#elif (App == 0xFD4C916D ) //Poppy PlayTime Ch. 2
	#define DA_W 1
	#define DA_X 0.051
	#define DF_Y 0.031
	#define DA_Y 125.0
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.250
    //#define DG_W -0.500 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.75 //Adjustment for REF
	#define BMT 1
	#define DF_Z 0.065
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.775 //SM Tune
	//#define DL_W 0.00 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 6     //HQ Smooth
	#define PEW 1
    #define FOV 1
    #define WSM 2
    #define DB_W 16
    #define AFD 1
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.0230, 0.0650,  0.114, 0.201) //Pos A = XY Black & B = ZW Other 
    #define DN_Y float4( 0.2000, 0.8888,  0.545, 0.533) //Pos C = XY Black & D = ZW Match
    #define DN_Z float4( 0.5160, 0.0430,  0.0, 0.0)     //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.266, 0.571, 0.542, 0.0 )    //Size = Menu [ABC] D E F
    #define DJ_Y float4( 0, 18.0, 0, 1000);                   //Menu Detection Type   
    #define DJ_Z float3( 30., 23., 1000);                //Set Match Tresh 
#elif (App == 0x2E105B97 ) //Chorus
	#define DA_W 1
	#define DA_X 0.0125//0.025//0.050
	#define DF_Y 0.020
	#define DA_Y 60.00//30.0  //Changed because it's a space game and having 3D pop more in the distance is a good thing.
	#define DB_Z 0.050
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.4375
    //#define DG_W 0.100 //Pop
	#define BMT 1
	#define DF_Z 0.150
    #define SMS 1     //SM Toggle Separation
	#define DL_X 0.700//SM Tune
	//#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 5     //HQ Smooth
    #define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.500, 0.995,  0.052, 0.919) //Pos A = XY Black & B = ZW Other 
    #define DN_Y float4( 0.084, 0.9652,  0.0, 0.0)     //Pos C = XY Black & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)         //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.999, 0.0, 0.0, 0.0 )         //Size = Menu [ABC] D E F
    #define DJ_Y float4( 0.0, 15.0, 0.0, 1000.0);              //Menu Detection Type   
    #define DJ_Z float3( 1000, 1000, 1000);           //Set Match Tresh 
	#define PEW 1
	#define DAA 1
#elif (App == 0x54BD1D74 ) //Biomutant
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.010
	#define DA_Y 17.5
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    #define DG_W -0.30 //Neg-Pop
    #define DG_Z 0.025 //Min
    #define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.130
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	//#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DL_Y 0.500    //De-Artifact Works well here because of the Fur	
	#define PEW 1	
#elif (App == 0x49B4730A ) //Dead or Alive  Xtream Venus Vacation
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.030
	#define DA_Y 12.5
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    #define DG_W 0.125 //Pop
    //#define DG_Z 0.150 //Min
    //#define DI_Z 0.200 //Trim
	#define BMT 1
	#define DF_Z 0.125
	#define PEW 1
#elif (App == 0xB59C0B0A ) //GreenHell
	#define DA_W 1
	#define DA_X 0.0375
	#define DF_Y 0.005
	#define DA_Y 55.0
	 
	#define DE_X 1
	#define DE_Y 0.350
	#define DE_Z 0.375
    #define DG_W 0.100 //Neg-Pop
    #define DG_Z 0.0125 //Min
    #define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.14375
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define PEW 1	
#elif (App == 0x8B814438 ) //The Ascent
	#define DA_W 1
	#define DA_X 0.075
	#define DF_Y 0.050
	#define DA_Y 70.0 //75.00 //42.5
    #define DA_Z -0.1875 //-0.250//-1.0
//	 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.375
    #define DG_W -0.150 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 0.5 //Adjustment for REF //Lowest I seen it. Default Low is 1.0
    #define DG_Z 0.125 //Min
    #define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.0375//0.05
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4    //HQ Smooth
    #define LBC 1     //Letter Box Correction
    #define LBS 1     //Letter Box Sensitvity
    #define LBR 1     //Letter Box Reposition    
	#define DH_Z 0.0  //Pos offset X    
	#define DH_W -0.244//Pos offset Y
    //#define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    //#define DN_X float4( 0.331, 0.705,  0.333, 0.800) //Pos A = XY Yellow & B = ZW Dark 
    //#define DN_Y float4( 0.669, 0.800,  0.0  , 0.0  ) //Pos C = XY Yellow & D = ZW Match
    //#define DN_Z float4( 0.0  , 0.0  ,  0.0  , 0.0  ) //Pos E = XY Match & F = ZW Match
	//#define DN_W float4( 1.0  , 0.0  ,  0.0  , 0.0  ) //Size = Menu [ABC] D E F
    //#define DJ_Y float4( 16.0, 0.0, 16.0, 1000.);              //Menu Detection Type   
    //#define DJ_Z float3( 1000, 1000, 1000);           //Set Match Tresh 
	#define PEW 1	
#elif (App == 0xE26CF45E ) //Daemon X Machina
	#define DA_W 1
	#define DA_X 0.060
	#define DF_Y 0.060
	#define DA_Y 20.0
    #define DB_Z 0.1125 
//	 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.375
    //#define DG_W -0.25 //Pop
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
	#define PEW 1
#elif (App == 0x46C3D9F8 ) //Sherlock Holmes Chapter One
	#define DA_W 1
	#define DA_X 0.025
	#define DF_Y 0.015
	#define DA_Y 30.0
    #define DA_Z -0.075
	#define DE_X 1
	#define DE_Y 0.4500
	#define DE_Z 0.375
	//#define DG_W 2.5 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
    //#define DG_Z 0.0875 //Min
    //#define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.650 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DL_Y 0.125 //De-Artifact
    #define MMD 1 //Set Multi Menu Detection              //Off / On
    #define DO_X float4( 0.157 , 0.088 ,  0.90555, 0.9295  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.841 , 0.072 ,  0.0    , 0.0     ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.0   , 0.0   ,  0.0    , 0.0     ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 29.0  , 28.0  ,  10000  , 1000    ) //Tresh Hold for Color A1 & A3 and Color B1 & B3 
	#define PEW 1
#elif (App == 0xF110883F ) //Yakuza Like a Dragon
	#define DA_W 1
	#define DA_X 0.1125
	#define DF_Y 0.0125
	#define DA_Y 15.25
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -.25 //Less Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.75 //Adjustment for REF
    #define DG_Z 0.030 //Min
    #define DI_Z 0.250 //Trim
	#define BMT 1
	#define DF_Z 0.000
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	#define DL_W 0.1 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 5     //HQ Smooth
    #define MMD 2 //Set Multi Menu Detection              //Off / On
    #define DO_X float4( 0.190 , 0.031 ,  0.388  , 0.947   ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.0275, 0.036 ,  0.752  , 0.025   ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.880 , 0.947 ,  0.9351 , 0.050   ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 29.0  ,  29.0   , 30.0    ) //Tresh Hold for Color A1 & A3 and Color 
	#define DP_X float4( 0.759 , 0.028 ,  0.938  , 0.097   ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.9411, 0.0456,  0.9346 , 0.0485  ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.924 , 0.092 ,  0.752  , 0.025   ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 29.0  , 30.0  ,  30.0   , 29.0    ) //Tresh Hold for Color A1 & A3 and Color 
	#define DAA 1
	#define PEW 1
#elif (App == 0x6A2A62D5 ) //Days Gone
	#define DA_W 1
	#define DA_X 0.075
	#define DF_Y 0.00
	#define DA_Y 15.5
	//#define DB_Z 0.050
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.150 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 2.0 //Adjustment for REF
    //#define DG_Z 0.07 //Min
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.150
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	#define DL_W 0.00  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
	//#define DM_Y 1     //HQ VRS Off|Auto|High|Med|Low|Lower
#elif (App == 0xF44ABA48 ) //Blacksad
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.015
	#define DA_Y 12.5
	//#define DB_Z 0.050
	#define DE_X 1
	#define DE_Y 0.4375
	#define DE_Z 0.375
	#define DG_W -0.10 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0, 0.0125, 0.025, 0.0375, 0.04375, 0.05, 0.0625, 0.075, 0.0875, 0.09375, 0.1, 0.125, 0.150, 0.175, 0.20, 0.225, 0.250
	#define DI_W 2.0 //Adjustment for REF
    #define DG_Z 0.025 //Min
    #define DI_Z 0.080//Trim
	#define BMT 1
	#define DF_Z 0.1
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	#define DL_W 0.00 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 5     //HQ Smooth
	/*
    #define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.200, 0.095,  0.500, 0.1375) //Pos A = XY White & B = ZW Dark 
    #define DN_Y float4( 0.799, 0.097,  0.0  , 0.0   ) //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.0  , 0.0  ,  0.0  , 0.0   ) //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0  , 0.0  ,  0.0  , 0.0   ) //Size = Menu [ABC] D E F
    #define DJ_Y float4( 19.0 , 5.0, 19.0, 30.0);           //Menu Detection Type   
    #define DJ_Z float3( 1000, 1000, 1000);           //Set Match Tresh 1000 is off
	*/
    #define MMD 2 //Set Multi Menu Detection              //Off / On
    #define DO_X float4( 0.402 , 0.069 ,  0.500  , 0.125   ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.598 , 0.081 ,  0.424  , 0.069   ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.125 ,  0.577  , 0.094   ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 18.0  , 18.0  ,  18.0   , 18.0    ) //Tresh Hold for Color A1 & A3 and Color 
	#define DP_X float4( 0.462 , 0.069 ,  0.500  , 0.125   ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.5365, 0.094 ,  0.439  , 0.069   ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.125 ,  0.560  , 0.094   ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 18.0  , 18.0  ,  18.0   ,  18.0   ) //Tresh Hold for Color A1 & A3 and Color 
	#define DM_Y 5     //HQ VRS Off|Auto|High|Med|Low|Lower
	#define PEW 1
#elif (App == 0x86E2D98B ) //Mordhau
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.0025
	#define DA_Y 25.0
	//#define DB_Z 0.050
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.250 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 2.0 //Adjustment for REF
    #define DG_Z 0.045 //Min
    #define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.150
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.75 //SM Tune
	#define DL_W 0.00 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.193, 0.041,  0.580, 0.042 ) //Pos A = XY White & B = ZW Dark 
    #define DN_Y float4( 0.964, 0.019,  0.0  , 0.0   ) //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.0  , 0.0  ,  0.0  , 0.0   ) //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0  , 0.0  ,  0.0  , 0.0   ) //Size = Menu [ABC] D E F
    #define DJ_Y float4( 20.0 , 2.0, 20.0, 18.0);    //Menu Detection Type W is based on Pos A as a Extra Just incase value
    #define DJ_Z float3( 1000, 1000, 1000);            //Set Match Tresh 1000 is off
	#define DM_Y 3     //HQ VRS Off|Auto|High|Med|Low|Lower
#elif (App == 0xF9B1845A ) //RiME
	#define DA_W 1
	#define DA_Y 15.0
	#define DA_X 0.145
	#define DF_Y 0.015
	#define DE_X 2
	#define DE_Y 0.350
	#define DE_Z 0.375
    #define OIF 0.1 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
    #define DG_Z 0.150 //Min
    #define DI_Z 0.400 //Trim
	#define BMT 1
	#define DF_Z 0.150
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	#define DL_W 0.00  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 5     //HQ Smooth
#elif (App == 0x1FEFF4DD ) //Someday Youll Return
	#define DA_W 1
	#define DA_Y 475.0//650.0
	#define DA_X 0.1000
	#define DF_Y 0.1175
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.325
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 0.75 //Adjustment for REF
    #define DG_Z 0.075 //Min
    #define DI_Z 0.200//0.175 //Trim
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.875 //SM Tune
	#define DL_W 0.00  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.664 , 0.110 ,  0.5  , 0.2215) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.452 , 0.1685,  0.5111, 0.0261)//Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.893 , 0.870 ,  0.888, 0.861 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0  , 30.0  ,  25.0 , 30.0  ) //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.2775, 0.030 ,  0.500, 0.10  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.193 , 0.240 ,  0.4873, 0.0266)//Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.893 , 0.870 ,  0.888, 0.861 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 27.0  ,  25.0 , 30.0  ) //Tresh Hold for Color C & D and Color 
	#define DQ_X float4( 0.4942, 0.0164,  0.893, 0.870 ) //Pos E1 = XY Color & E2 = ZW Black 
    #define DQ_Y float4( 0.888 , 0.861 ,  0.4942, 0.017) //Pos E3 = XY Color & F1 = ZW Color
    #define DQ_Z float4( 0.893, 0.870  ,  0.888 , 0.861) //Pos F2 = XY Black & F3 = ZW Color
	#define DQ_W float4( 25.0  , 30.0  ,  25.0  , 30.0 ) //Tresh Hold for Color E & F and Color
	#define DR_X float4( 0.493 , 0.0164,  0.1   , 0.5  ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.039 , 0.862 ,  0.5337, 0.018)//Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.1   , 0.5   ,  0.039 , 0.862 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 25.0  , 30.0  ,  25.0  , 30.0  ) //Tresh Hold for Color G & H and Color 
	#define PEW 1
#elif (App == 0xD1006CAF ) //Dirt 5  
	#define DA_W 1
	#define DA_X 0.2125
	#define DF_Y 0.0125
	#define DA_Y 7.5
	#define DB_Z 0.225
	//#define DA_Z -0.00025  
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.475
	//#define DG_W 0.375 //Allow popout
    #define OIF 0.175 //Fix enables if Value is > 0.0
	#define DI_W 0.75 //Adjustment for REF
    #define DG_Z 0.025 //Min
    #define DI_Z 0.125 //Trim
	#define BMT 1    
	#define DF_Z 0.150
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define NDW 1
	#define PEW 1
	#define DAA 1
#elif (App == 0x5663B8FC ) //Stray
	#define DA_W 1
	#define DA_X 0.110
	#define DF_Y 0.015
	#define DA_Y 100.0
	#define DB_Z 0.25
 
	#define DE_X 3
	#define DE_Y 0.450
	#define DE_Z 0.375
	#define DG_W 0.100 //Pop
	#define BMT 1
	#define DF_Z 0.0375
    #define OIF 0.1 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
    #define DG_Z 0.030 //Min
    #define DI_Z 0.100 //Trim
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.9   //SM Tune
	#define DL_W 0.0   //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.133 , 0.290 , 0.800 , 0.290  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.704 , 0.290 , 0.0  , 0.0  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.0  , 0.0  , 0.0  , 0.0  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0 , 1000.0  ) //Tresh Hold for Color A & B and Color
	//#define SPF 1	
    #define LBC 1     //Letter Box Correction
	#define DH_Z 0.0  //Pos offset X    
	#define DH_W -0.2595//Pos offset Y
	#define SDT 2 //Spcial Depth Trigger With X & Y Offsets
    //#define DG_X 0.0
    //#define DG_Y 0.0 
	#define PEW 1
	#define DAA 1
#elif (App == 0x308AEBEA ) //TitanFall 2 ****
	//#define DA_W 1
	#define DA_X 0.040
	//#define DF_Y 0.015
	#define DA_Y 10.0
	#define DB_Z 0.100
 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.4375
	//#define DG_W 0.100 //Pop
    #define DG_Z 0.03 //Min
    #define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.075
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	#define DL_W 0.0   //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 0     //HQ Smooth
	 
	#define WSM 5
	#define DB_W 18
    #define DF_X 0.35
	#define DJ_W 0.25
	#define FPS  2
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 0
	#define DK_W 2
	#define PEW 1
	#define DAA 1
	#define FOV 1
#elif (App == 0x2871B10B ) //DMC: Devil May Cry
	//#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.005
	#define DA_Y 25.0
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.100 //Pop
    #define OIF 0.20 //Fix enables if Value is > 0.0
	#define DI_W 1.5 //Adjustment for REF
    //#define DG_Z 0.03 //Min
    //#define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.06
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.0   //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define PEW 1
#elif (App == 0xDC9A4971 ) //Furi
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.005
	#define DA_Y 250.0
	#define DB_Z 0.100
    #define DB_X 1
 
	#define DE_X 1
	#define DE_Y 0.4375
	#define DE_Z 0.4375
//	#define DG_W -0.100 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.25 //Adjustment for REF
    //#define DG_Z 0.03 //Min
    //#define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.0   //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth	
	#define PEW 1
#elif (App == 0xE1A4C79C ) //Generation Zero
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.005
	#define DA_Y 52.5
	#define DB_Z 0.100
	 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.100 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 1.25 //Adjustment for REF
    #define DG_Z 0.050 //Min
    #define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.175
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 0     //HQ Smooth
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 2
	#define DK_W 3
	#define PEW 1
	#define FOV 1
#elif (App == 0x32481ADC ) //Deep Rock Galactic
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.040
	#define DF_Y 0.025
	#define DA_Y 18.75
	#define DB_Z 0.100
 
	//#define DE_X 1
	//#define DE_Y 0.500
	//#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 1.25 //Adjustment for REF
    #define DG_Z 0.075 //Min
    #define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.120
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.100 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 0     //HQ Smooth
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.0805, 0.051 , 0.900 , 0.051  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.408 , 0.051 , 0.0  , 0.0  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.0  , 0.0  , 0.0  , 0.0  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0 , 1000.0  ) //Tresh Hold for Color A & B and Color
	#define PEW 1
	#define FOV 1
#elif (App == 0x78DF0627 ) //The Sinking City
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.026
	#define DA_Y 15.00
    #define DA_Z -0.10
	//#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.25 //Adjustment for REF
    //#define DG_Z 0.100 //Min
    //#define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.15
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.8     //De-Artifact
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.190 , 0.061 , 0.190 , 0.050  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.810 , 0.061 , 0.190 , 0.061  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.183 , 0.050 , 0.810 , 0.061  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0  , 30.0  ) //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.433 , 0.347 ,  0.500  , 0.20 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.567 , 0.347 ,  0.464  , 0.243) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.310 ,  0.540  , 0.243) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   ,  30.0) //Tresh Hold for Color A1 & A3 and Color 
	#define DQ_X float4( 0.428 , 0.240 ,  0.500  , 0.310) //Pos E1 = XY Color & E2 = ZW Black 
    #define DQ_Y float4( 0.564 , 0.240 ,  0.437  , 0.235) //Pos E3 = XY Color & F1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.310 ,  0.555  , 0.235) //Pos F2 = XY Black & F3 = ZW Color
	#define DQ_W float4( 30.0  , 30.0  , 30.0    , 30.0 ) //Tresh Hold for Color E & F and Color
	#define PEW 1
#elif (App == 0x293886C5 ) //The Last Camp fire
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.040
	#define DF_Y 0.030
	#define DA_Y 37.50
    //#define DA_Z -0.10
	#define DB_Z 0.050
 
	#define DE_X 3
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DG_W -0.100 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.0 //Adjustment for REF
    #define DG_Z 0.055 //Min
    #define DI_Z 0.075 //Trim
	#define BMT 1
	#define DF_Z 0.10
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.725 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.040 , 0.0325, 0.995 , 0.005  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.030 , 0.090 , 0.294 , 0.365  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.5 , 0.5 , 0.704 , 0.365  )     //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0  , 30.0  ) //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.45 , 0.45 ,  0.625  , 0.250) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.550 , 0.485 ,  0.0  , 0.0) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.625 , 0.250 ,  0.0  , 0.0) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  1000.0   , 1000.0) //Tresh Hold for Color A1 & A3 and Color
    #define DSW 1
#elif (App == 0xF82EA3E3 ) //In Sound Mind
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.020
	#define DF_Y 0.0375
	#define DA_Y 225.5
    #define DA_Z -0.175
	#define DB_Z 0.050
 
	#define DE_X 2
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //Adjustment for REF
    #define DG_Z 0.070 //Min
    #define DI_Z 0.060 //Trim
	#define BMT 1
	#define DF_Z 0.1
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.7375 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact
#elif (App == 0x3F20AE01 ) //The Mortuary Assistant
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.01625
	#define DA_Y 237.5
    #define DA_Z -0.025 //-0.100
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.4375
	#define DG_W 0.300 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 4.5 //Adjustment for REF
    #define DG_Z 0.105 //Min
    #define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.150
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.1345, 0.448,  0.128, 0.0375)  //Pos A = XY Light & B = ZW Other 
    #define DN_Y float4( 0.118 , 0.784,  0.435, 0.262)   //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.264, 1.0 , 0.0, 0.0 )         //Size = Menu [ABC] D E F
    #define DJ_Y float4( 22, 11.0, 22, 1000);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 30., 1000., 1000);              //Set Match Tresh 
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.400 , 0.620 , 0.808 , 0.335  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.960 , 0.047 , 0.656 , 0.205  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.027 , 0.873 , 0.507 , 0.924  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 13.0  , 26.0  , 28.0  , 30.0   ) //Tresh Hold for Color A & B and Color
	//
	#define DP_X float4( 0.091 , 0.070 ,  0.069 , 0.540 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.410 , 0.140 ,  0.5   , 0.2215) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.1065, 0.285 ,  0.507 , 0.924 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 17.0  , 30.0  ,  30.0  , 30.0  ) //Tresh Hold for Color A1 & A3 and Color
	//
	#define DQ_X float4( 0.500 , 0.354 ,  0.500  , 0.655) //Pos E1 = XY Color & E2 = ZW Black 
    #define DQ_Y float4( 0.500 , 0.936 ,  0.0  , 0.0) //Pos E3 = XY Color & F1 = ZW Color
    #define DQ_Z float4( 0.0 , 0.0 ,  0.0  , 0.0) //Pos F2 = XY Black & F3 = ZW Color
	#define DQ_W float4( 28.0  , 30.0  , 1000.0  , 1000.0 ) //Tresh Hold for Color E & F and Color
    //#define AFD 2
    #define SMS 2      //SM Toggle Separation
	#define DL_X 1.0   //SM Tune
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact
	#define FOV 1
	#define PEW 1
#elif (App == 0x22B98797 ) //The Cult of Lamb
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.015
	#define DA_Y 625.0
    #define DA_Z -0.25
	#define DB_Z 0.1666
 
	//#define DE_X 2
	//#define DE_Y 0.500
	//#define DE_Z 0.4375
	//#define DG_W 0.250 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //Adjustment for REF
    //#define DG_Z 0.100 //Min
    //#define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.050
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.1245, 0.800 , 0.125 , 0.241  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.964 , 0.752 , 0.220 , 0.165  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.090 , 0.471 , 0.085  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 27.0, 28.0 ) //Tresh Hold for Color A & B and Color
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.75  //SM Tune
	#define DL_W 0.05 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact 0.1245
	#define PEW 1
#elif (App == 0xC1D068CF ) //Chernobylite
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.0125
	#define DA_Y 170.0
    //#define DA_Z -0.25
	#define DB_Z 0.100
 
	#define DE_X 6//4
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.250 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0,
	//#define DI_W 1.0 //Adjustment for REF
    #define DG_Z 0.025 //Min
    #define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.100
	#define WSM 2
	#define DB_W 10
	#define DF_X float2(0.3,0.0)
	#define DJ_W 0.150
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 4
	#define DK_W 2
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.90  //SM Tune
	#define DL_W 0.05  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 4     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact 0.1245
	#define DJ_X 0.25     //Range Smoothing
	#define PEW 1
#elif (App == 0x3C4B9E1A ) //Hot Wheels Unleashed
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0375
	#define DF_Y 0.0
	#define DA_Y 126.25
    //#define DA_Z -0.25
	#define DB_Z 0.100
 
	#define DE_X 1//4
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define DG_W 0.250 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //Adjustment for REF
    //#define DG_Z 0.025 //Min
    //#define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.1125
//	#define WSM 2
//	#define DB_W 10
//	#define DF_X float2( 0.3, 0.0)	
//	#define DJ_W 0.150
//	#define FPS  0
//	#define DK_X 2
//	#define DK_Y 0
//	#define DK_Z 4
//	#define DK_W 2
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.90  //SM Tune
	#define DL_W 0.00  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact 0.1245
/*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.928, 0.890,  0.9525, 0.881)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.938, 0.938,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 30.0, 24.0, 17.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
*/
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.184 , 0.616 , 1.000 , 1.000  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.9525, 0.881 , 0.184 , 0.616  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 1.000 , 0.877 , 0.9525, 0.881  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define PEW 1
	#define DSW 1
#elif (App == 0x2EA57CA ) //KHOLAT
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.175
	#define DF_Y 0.0
	#define DA_Y 10.00
    #define DA_Z -0.10
	#define DB_Z 0.150
 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.250 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.5 //Adjustment for REF
    //#define DG_Z 0.025 //Min
    //#define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.110
	#define WSM 2
	#define DB_W 27
//	#define DF_X float2(0.3,0.0)	
//	#define DJ_W 0.150
//	#define FPS  0
//	#define DK_X 2
//	#define DK_Y 0
//	#define DK_Z 4
//	#define DK_W 2
    #define SMS 0      //SM Toggle Separation
	#define DL_X 1.00  //SM Tune
	#define DL_W 0.00  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact 0.1245
#elif (App == 0x245071FD ) //Fasion Police Squad
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.0375
	#define DF_Y 0.0375
	#define DA_Y 22.25
    #define DA_Z -0.0375
	#define DB_Z 0.0375
 
	#define DE_X 3
	#define DE_Y 0.400
	#define DE_Z 0.375
	#define BMT 1
	#define DF_Z 0.04375
    #define NCW 1
    #define DSW 1
#elif (App == 0x595C738E ) //Layers of Fear 2
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.035
	#define DF_Y 0.045
	#define DA_Y 25.0
    //#define DA_Z -0.025
	#define DB_Z 0.030
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.250 //Pop
    #define OIF 0.150 //Fix enables if Value is > 0.0
	#define DI_W 1.5 //Adjustment for REF
    #define DG_Z 0.025 //Min
    #define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.025
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 0     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1     //De-Artifact 0.1245
    #define AFD 0
    #define PEW 1
#elif (App == 0x8B76620B || App == 0xBA505034 ) //Saints Row: Gat out of Hell | Saints Row The Third 
	//#define DA_W 0
    //#define DB_X 0
	#define DA_X 0.025
	#define DF_Y 0.025
	#define DA_Y 52.5
    //#define DA_Z -0.025
	#define DB_Z 0.1
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.250 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.5 //Adjustment for REF
    #define DG_Z 0.025 //Min
    #define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.875 //SM Tune
	//#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define PEW 1
#elif (App == 0xD7199355 ) //Scathe
	#define DA_W 1
    //#define DB_X 0
	#define DA_X 0.025
	#define DF_Y 0.015
	#define DA_Y 250.0
    #define DA_Z -0.025
	#define DB_Z 0.035
 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W -0.05 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 1.25 //Adjustment for REF
    //#define DG_Z 0.025 //Min
    //#define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.05 //0.025
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95 //SM Tune
	//#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.100 , 0.150 , 0.055 , 0.375  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.745 , 0.681 , 0.143 , 0.367  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.975 , 0.975 , 0.1375, 0.807  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	#define WSM 4
	#define DB_W 2
    #define PEW 1
    #define DSW 1
#elif (App == 0x6A327F2C ) //Snake Pass
	#define DA_W 1
    //#define DB_X 0
	#define DA_X 0.025
	#define DF_Y 0.010
	#define DA_Y 250.0
    #define DA_Z -0.0125
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.250 //Pop
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
    #define DG_Z 0.035 //Min
    #define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.95 //SM Tune
	//#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define PEW 1
#elif (App == 0x533A4888 ) //MotherGunShip
	#define DA_W 1
    //#define DB_X 0
	#define DA_X 0.0375
	#define DF_Y 0.0375
	#define DA_Y 32.5
    //#define DA_Z -0.025
	//#define DB_Z 0.1
 
	//#define DE_X 4
	//#define DE_Y 0.500
	//#define DE_Z 0.400
	//#define DG_W -0.250 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 2.0 //Adjustment for REF
    #define DG_Z 0.150 //Min
    #define DI_Z 0.150 //Trim
	#define BMT 1
	#define DF_Z 0.05
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.875 //SM Tune
	#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.666 , 0.010 , 0.800 , 0.825  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.720 , 0.875 , 0.666 , 0.010  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.800 , 0.825 , 0.720 , 0.875  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 28.0  , 29.0  , 27.0, 29.0 )   //Tresh Hold for Color A & B and Color
    #define PEW 1
#elif (App == 0xE4A6218 ) //Everyone Gone to Rapture
	//#define DA_W 0
    //#define DB_X 0
	#define DA_X 0.025
	#define DF_Y 0.025
	#define DA_Y 15.0
    //#define DA_Z -0.025
	#define DB_Z 0.050
 
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define DG_W -0.10 //Pop
    //#define OIF 0.250 //Fix enables if Value is > 0.0
	//#define DI_W 0.75 //Adjustment for REF
    #define DG_Z 0.045 //Min
    #define DI_Z 0.035 //Trim
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.925 //SM Tune
	#define DL_W 0.050  //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
        #define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.295 , 0.270 , 0.513 , 0.302  ) //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.595 , 0.115 , 0.000 , 0.000  ) //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.000 , 0.000 , 0.000 , 0.000  ) //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )            //Size = Menu [ABC] D E F
    #define DJ_Y float4( 16.0, 6.0, 4.0, 1000.0);         //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);             //Set Match Tresh    
    #define MMD 2 //Set Multi Menu Detection              //Off / On
    #define DO_X float4( 0.500 , 0.500 , 0.655 , 0.460  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.272 , 0.6655, 0.500 , 0.500  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.700 , 0.460 , 0.272 , 0.6655 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.00 , 16.00 , 27.00 , 16.00  ) //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.401 , 0.200 , 0.790 , 0.465  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.600 , 0.470 , 0.500 , 0.010  ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.990 , 0.670 , 0.440  ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 27.00 , 29.0,  0.0, 26.0) //Tresh Hold for Color A1 & A3 and Color
    #define PEW 1
#elif (App == 0x4DE39E70 ) //Industria
	#define DA_W 1
    //#define DB_X 0
	#define DA_X 0.025
	#define DF_Y 0.010
	#define DA_Y 48.75
    //#define DA_Z -0.025
	#define DB_Z 0.025
 
	#define DE_X 4
	#define DE_Y 0.375
	#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 2.0 //Adjustment for REF
    //#define DG_Z 0.025 //Min
    //#define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.0375
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.195, 0.195,  0.956, 0.8945)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.485, 0.890,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26, 26.0, 26.0, 13.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
    /*
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.100 , 0.150 , 0.055 , 0.375  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.745 , 0.681 , 0.143 , 0.367  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.975 , 0.975 , 0.1375, 0.807  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define WSM 2
	#define DB_W 26
	#define FPS  2
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 1
	#define DK_W 2
    #define PEW 1
#elif (App == 0xD1B82FBF ) //Descenders
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.010
	#define DA_Y 37.5
    //#define DA_Z -0.025
	#define DB_Z 0.100
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 2.0 //Adjustment for REF
    //#define DG_Z 0.025 //Min
    //#define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.123, 0.086,  0.0333, 0.893 )  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.479, 0.120,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 10.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh     
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.519 , 0.340 , 0.500 , 0.010  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.520 , 0.880 , 0.452 , 0.378  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.010 , 0.520 , 0.880  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 26.0  , 7.00  , 28.0, 5.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.320 , 0.526 ,  0.255  , 0.490) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.490 , 0.666 ,  0.380  , 0.400) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.064 , 0.774 ,  0.5689 , 0.400) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 19.0  ,  24.0   , 24.0 ) //Tresh Hold for Color A1 & A3 and Color
	#define DQ_X float4( 0.356 , 0.632 ,  1.0  , 1.0) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.500 , 0.829 ,  0.000  , 0.000) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 ,  0.000  , 0.000) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0  , 30.0  , 1000.0  , 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define WSM 2
	#define DB_W 26
	#define FPS  2
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 1
	#define DK_W 2
    #define PEW 1
#elif (App == 0xCC08DA8C ) //The Vanishing of Ethan Carter Redux
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.125 //0.135
	#define DF_Y 0.005
	#define DA_Y 10.0//11.25
    //#define DA_Z -0.025
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.375
	#define DG_W 0.125 //Pop
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
    //#define DG_Z 0.001 //Min
    //#define DI_Z 0.045 //Trim
	#define BMT 1
	#define DF_Z 0.0325
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.5625 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define PEW 1
#elif (App == 0xCF5B15B ) //The Vanishing of Ethan Carter
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.125
	#define DF_Y 0.010
	#define DA_Y 10.0//11.25
    //#define DA_Z -0.025
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.375
	#define DG_W 0.125 //Pop
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
    //#define DG_Z 0.001 //Min
    //#define DI_Z 0.045 //Trim
	#define BMT 1
	#define DF_Z 0.030
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.725 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.195, 0.195,  0.956, 0.8945)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.485, 0.890,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26, 26.0, 26.0, 13.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    /*
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.100 , 0.150 , 0.055 , 0.375  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.745 , 0.681 , 0.143 , 0.367  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.975 , 0.975 , 0.1375, 0.807  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define PEW 1
    #define DAA 1
    #define DSW 1
#elif (App == 0x7780FC1C ) //Metal Hellsinger
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.0125
	#define DA_Y 150 //200.0
    //#define DA_Z -0.025
	#define DB_Z 0.100
 
	#define DE_X 2
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.75 //Pop
    //#define OIF 0.25 //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //Adjustment for REF
    #define DG_Z 0.1400 //0.1325 //Min
    #define DI_Z 0.1425 //0.160 //0.170 //Trim
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.725 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.195, 0.195,  0.956, 0.8945)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.485, 0.890,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26, 26.0, 26.0, 13.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    /*
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.100 , 0.150 , 0.055 , 0.375  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.745 , 0.681 , 0.143 , 0.367  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.975 , 0.975 , 0.1375, 0.807  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define WSM 2
	//#define DB_W 25
	//#define DF_X 0.25	
	//#define DJ_W 0.150
    #define PEW 1
    #define DAA 1
#elif (App == 0x5F1E44D || App == 0x2784E9D ) //SniperElite 5 
	#define DA_W 1
    #define DA_X 0.05 //0.075
    #define DF_Y 0.0375
    #define DA_Y 25.0 //30.0 //20.0
    #define DE_X 1
    #define DE_Y 0.450
    #define DE_Z 0.450
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 1.0 //Adjustment for REF
    #define BMT 1    
    #define DF_Z 0.025
	#define DG_Z 0.03//Min
    #define DI_Z 0.06 //Trim
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.725 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DL_Y 0.25    //De-Artifact
	/*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.150, 0.240,  0.250, 0.925)  //Pos A = XY White & B = ZW Black 
    #define DN_Y float4( 0.296, 0.865,  0.0, 0.0)      //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)          //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.297, 0.0 , 0.0, 0.0 )         //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 2.0, 29.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	#define PEW 1
#elif (App == 0x607F1CE3 ) //Prodeus
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.0375
	#define DA_Y 22.5
    #define DA_Z -0.05
	#define DB_Z 0.050
 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.400
	//#define DG_W 0.75 //Pop
    //#define OIF 0.25 //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //Adjustment for REF
    //#define DG_Z 0.1400 //Min
    //#define DI_Z 0.1425 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 1      //SM Toggle Separation
	//#define DL_X 0.725 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	//#define DM_X 3     //HQ Tune
	//#define DM_Z 2     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.195, 0.195,  0.956, 0.8945)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.485, 0.890,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26, 26.0, 26.0, 13.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    /*
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.100 , 0.150 , 0.055 , 0.375  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.745 , 0.681 , 0.143 , 0.367  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.975 , 0.975 , 0.1375, 0.807  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define WSM 2
	#define DB_W 18
	#define RHW 1
    #define PEW 1
    #define DSW 1
  #elif (App == 0x22D233C3 ) //Going Under
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.025
	#define DA_Y 35.0  //45.0
    #define DA_Z -0.001
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.600
	#define DE_Z 0.400
	////#define DG_W 0.200 //Pop
    #define OIF 0.225 //Fix enables if Value is > 0.0
	#define DI_W 0.75 //Adjustment for REF
    //#define DG_Z 0.1400 //Min
    //#define DI_Z 0.1425 //Trim
	#define BMT 1
	#define DF_Z 0.05
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	////#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /////*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	//*/
	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.400 , 0.275 , 0.544  , 0.6799  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.600 , 0.722 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
/*
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define HMT 1
    #define HMC 0.505
    #define PEW 1
#elif (App == 0xB1DA26D3 ) //Sea of Thieves
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.015
	#define DF_Y 0.0375
	#define DA_Y 112.5
    //#define DA_Z -0.001
	#define DB_Z 0.0125
 
	#define DE_X 2
	#define DE_Y 0.725
	#define DE_Z 0.375
	#define DG_W 0.175 //Pop
    //#define OIF 0.3 //0.35 //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //Adjustment for REF
    #define DG_Z 0.075 //Min
    #define DI_Z 0.050 //Trim
	#define DE_W 0.275 //Auto
	#define BMT 1
	#define DF_Z 0.05
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.195, 0.195,  0.956, 0.8945)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.485, 0.890,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26, 26.0, 26.0, 13.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.064 , 0.155 , 0.035 , 0.065  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.625 , 0.156 , 0.064 , 0.155  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.035 , 0.065 , 0.625 , 0.156  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 29.0  , 30.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.0225, 0.055 ,  0.037  , 0.055) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.681 , 0.054 ,  0.0225 , 0.055) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.037 , 0.055 ,  0.681  , 0.054) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 29.0  ,  30.0   , 30.0) //Tresh Hold for Color A1 & A3 and Color
	#define DQ_X float4( 0.055 , 0.055 ,  0.037  , 0.055) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.0645, 0.955 ,  0.055  , 0.055 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.037 , 0.055 ,  0.060  , 0.955) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 26.0  , 30.0  ,  26.0 , 30.0) //Tresh Hold for Color A1 & A3 and Color
    #define PEW 1
#elif (App == 0x2F1ABF4A ) //Detroit Become Human
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.030
	#define DF_Y 0.035
	#define DA_Y 52.5 //55.0 //60.0//50.0
    //#define DA_Z -0.001
	#define DB_Z 0.03
	 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.4
	#define DG_W -0.1 //Pop
    #define OIF 0.200 //0.35 //Fix enables if Value is > 0.0
	#define DI_W 1.25 //Adjustment for REF
	#define BMT 1
	#define DF_Z 0.075
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.800 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.25   //De-Artifact
    #define PEW 1
    #define RHW 1
  #elif (App == 0x64ED1C8A ) //Visage
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.050
	#define DA_Y 26.5 //27.0
    #define DA_Z 0.001
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	////#define DG_W 0.200 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 0.75 //Adjustment for REF
    #define DG_Z 0//0.05 //Min
    #define DE_W 0.275 //Auto
    #define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.025
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	////#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	/*
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define PEW 1
    #define RHW 1
#elif (App == 0x578862 ) //Condemned Criminal Origins
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.03
	#define DF_Y 0.0125
	#define DA_Y 200.0 //162.5
	//#define DA_Z -0.00015
	#define DB_Z 0.050
 
	#define DE_X 7
	#define DE_Y 0.500
	#define DE_Z 0.375
	////#define DG_W 0.200 //Pop
    #define OIF 0.15 //Fix enables if Value is > 0.0
	#define DI_W 1.5 //Adjustment for REF
   // #define DG_Z 0//0.05 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.05
	#define WSM 5
	#define DB_W 23
	#define DSW 1
	#define RHW 1
	#define FOV 1
	#define PEW 1
	#define NFM 1
  #elif (App == 0x7EF1B86E ) //Marvel's Avengers
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0025
	#define DA_Y 150.00 //27.0
    #define DA_Z 0.000125
	//#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.100 //NegPop
    #define OIF 0.300 //Fix enables if Value is > 0.0
	#define DI_W 1.00 //Adjustment for REF
    //#define DG_Z 0 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.15
    //#define SMS 3      //SM Toggle Separation
	//#define DL_X 0.950 //SM Tune
	////#define DL_W 0.050 //SM Perspective
	//#define DM_X 3     //HQ Tune
	//#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define PEW 1
  #elif (App == 0xDF6C99A6 ) //TrackMania 2020
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0255
	//#define DF_Y 0.0025
	#define DA_Y 250.00 //27.0
    //#define DA_Z 0.000125
	//#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.100 //NegPop
    #define OIF 0.0625 //Fix enables if Value is > 0.0
	#define DI_W 10.00 //Adjustment for REF
	#define FTM 1
    //#define DG_Z 0 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.11875
    //#define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define NDW 1
   #elif (App == 0xC6A81FC5 ) //Dead Space 2008
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.015
	#define DA_Y 45.0
	//#define DA_Z -0.0005
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.450
	#define DE_Z 0.375
	#define DG_W -0.100 //Pop
    #define OIF 0.175 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
   // #define DG_Z 0//0.05 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.075
	#define DSW 1
	#define RHW 1
	#define FOV 1
	#define PEW 1
	#define NVK 1
   #elif ( App == 0x620316A3 ) //Dead Space 2
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0125
	#define DA_Y 45.0
	//#define DA_Z -0.0005
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.450
	#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    #define OIF 0.175 //Fix enables if Value is > 0.0
	#define DI_W 2.0 //Adjustment for REF
   // #define DG_Z 0//0.05 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.075
	#define DSW 1
	#define RHW 1
	#define FOV 1
	#define PEW 1
	#define NVK 1
	#define NDW 1
   #elif ( App == 0x61031510 ) //Dead Space 3
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.005
	#define DA_Y 45.0
	#define DA_Z 0.001
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.450
	#define DE_Z 0.375
	//#define DG_W 0.100 //Pop
    #define OIF 0.175 //Fix enables if Value is > 0.0
	#define DI_W 1.00 //Adjustment for REF
   // #define DG_Z 0//0.05 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.05
	#define DSW 1
	#define RHW 1
	#define FOV 1
	#define PEW 1
	#define NVK 1
	#define NDW 1
#elif (App == 0xA0762A98 ) //Assassin's Creed Unity
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.04375
	//#define DF_Y 0.0025
	#define DA_Y 25.00 
    #define DA_Z 0.00025
	//#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.100 //NegPop
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 2.00 //Adjustment for REF
	//#define FTM 1
    //#define DG_Z 0 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.15
    //#define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define NDW 1
    #define PEW 1
#elif (App == 0xB82BC012 ) //Splinter Cell Blacklist
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.0025
	#define DA_Y 125.00 
    //#define DA_Z 0.00025
	//#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.100 //NegPop
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 1.50 //Adjustment for REF
	//#define FTM 1
    //#define DG_Z 0 //Min
    //#define DE_W 0.275 //Auto
    //#define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.0375
    //#define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 1     //HQ Tune
	#define DM_Z 0     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define NDW 1
    #define PEW 1
#elif (App == 0xC174C775 || App == 0x770EDAC8 || App == 0x8B88341D || App == 0x86882C3E || App == 0x8585EC14 || App == 0x8285E75B || App == 0xF78D5B4F || App == 0x6C4A332E || App == 0x9D49A4D6 || App == 0x31447DA4 || App == 0x93D2EEC8 ) //Jedi Knight Remastered: Star Wars Jedi Knight: Dark Forces II | 
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.020 //0.0150
	#define DF_Y 0.005
	#define DA_Y 27.5//30.5
    #define DA_Z -1.0
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.850
	#define DE_Z 0.375
	//#define DG_W 2.0 //PoP
    //#define OIF 0.250 //Fix enables if Value is > 0.0
	//#define DI_W 2.5
	//#define FTM 1
    #define DG_Z 0.030//0.050//0.050//Min
    //#define DE_W 0.25 //Auto
    #define DI_Z 0.030//0.055//0.075//Trim
    #define DF_W float4(0.250,0.008,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.050
    #define FOV 1
    #define DSW 1
    #define RHW 1
    #define NFM 1
#elif (App == 0xA07634CA ) //Assassin's Creed Syndicate
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 50.0 //225.00 
    //#define DA_Z 0.0001
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.400
	#define DG_W -0.125 //Neg PoP
    #define OIF 0.450 //Fix enables if Value is > 0.0
	#define DI_W 0.375
	//#define FTM 1
    //#define DG_Z 0.045//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.055//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 3      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.500    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define PEW 1
#elif (App == 0x6367B705 ) //Transference
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.026
	#define DF_Y 0.013
	#define DA_Y 255.5 //275.0 
    #define DA_Z 0.000125
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.750//0.850
	#define DE_Z 0.375
	//#define DG_W -0.125 //Neg PoP
    //#define OIF 0.600 //Fix enables if Value is > 0.0
	//#define DI_W 1.00
	//#define FTM 1
    //#define DG_Z 0.045//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.055//0.050//0.090 //Trim
    #define DF_W float4(0.001,0.006,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.025
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1.000    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define PEW 1
    #define FOV 1
#elif (App == 0x5A1F3C90 ) //STEEP
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 350.0
    //#define DA_Z 0.000
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500//0.850
	#define DE_Z 0.375
	#define DG_W -0.125 //Neg PoP
    #define OIF 0.250 //Fix enables if Value is > 0.0
	#define DI_W 1.00
	//#define FTM 1
    //#define DG_Z 0.045//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.055//0.050//0.090 //Trim

	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 3      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	//#define DL_W 0.100 //SM Perspective
	#define DM_X 4     //HQ Tune
	#define DM_Z 5     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 1.000    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define PEW 1
    #define FOV 1
    #define NCW 1
#elif (App == 0x19A45039 ) //Far Cry 3
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 21.0
    //#define DA_Z 0.000
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.550//0.850
	#define DE_Z 0.375
	#define DG_W 0.5 //Neg PoP
    //#define OIF 0.250 //Fix enables if Value is > 0.0
	//#define DI_W 1.00
	//#define FTM 1
    #define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125//0.050//0.090 //Trim
    #define DF_W float4(0.005,0.0075,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.100       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 1.000       //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 0
	#define DK_W 4
    #define DSW 1
    #define PEW 1
    #define FOV 1
#elif (App == 0xC150B652 ) //Far Cry 4
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 21.0
    //#define DA_Z 0.000
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.550//0.850
	#define DE_Z 0.375
	#define DG_W 0.5 //Neg PoP
    //#define OIF 0.250 //Fix enables if Value is > 0.0
	//#define DI_W 1.00
	//#define FTM 1
    #define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125//0.050//0.090 //Trim
    #define DF_W float4(0.005,0.0075,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.100       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 1.000       //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 0
	#define DK_W 4
    #define DSW 1
    #define PEW 1
    #define FOV 1
#elif (App == 0xC150B805 ) //Far Cry 5
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.001
	#define DA_Y 27.5
    #define DA_Z 0.001
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.550//0.850
	#define DE_Z 0.400
	#define DG_W 0.5 //Neg PoP
    //#define OIF 0.250 //Fix enables if Value is > 0.0
	//#define DI_W 1.00
	//#define FTM 1
    #define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125//0.050//0.090 //Trim
    #define DF_W float4(0.005,0.00875,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.050       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 4           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 1.000       //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 3
	#define DK_W 4
    #define DAA 1
    #define DSW 1
    #define PEW 1
    #define FOV 1
#elif (App == 0x2EB82B07 ) //Farcry Primal
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 21.5
    //#define DA_Z 0.000
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.550//0.850
	#define DE_Z 0.375
	#define DG_W 0.5 //Neg PoP
    //#define OIF 0.250 //Fix enables if Value is > 0.0
	//#define DI_W 1.00
	//#define FTM 1
    #define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125//0.050//0.090 //Trim
    #define DF_W float4(0.005,0.0075,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.100       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 1.000       //De-Artifact
    //#define DL_Z 0.125       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 4
	#define DK_W 4
    #define DSW 1
    #define PEW 1
    #define FOV 1
#elif (App == 0x2E724DCE ) //Far Cry New Dawn
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.001
	#define DA_Y 27.5
    #define DA_Z 0.001
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.550//0.850
	#define DE_Z 0.400
	#define DG_W 0.5 //Neg PoP
    //#define OIF 0.250 //Fix enables if Value is > 0.0
	//#define DI_W 1.00
	//#define FTM 1
    #define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125//0.050//0.090 //Trim
    #define DF_W float4(0.005,0.00875,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.050       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 4           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 1.000       //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 3
	#define DK_W 4
    #define DAA 1
    #define DSW 1
    #define PEW 1
    #define FOV 1
 #elif (App == 0xDA684D19 ) //Beyond Good & Evil
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0125
	#define DA_Y 170.0 //180.0
    //#define DA_Z 0.0005
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.4375
	#define DG_W 0.125//PoP
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 2.50
	//#define FTM 1
    //#define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.125//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.125
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 1.0     //De-Artifact
    //#define DL_Z 0.0       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define DSW 1
    #define PEW 1
    #define FOV 1
    #define NDG 1
	//#define LBM 1
	//#define DI_X 0.879
	//#define DI_Y 0.120
 #elif (App == 0x7A2AB618 ) //Riders Republic
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 100.0
    //#define DA_Z 0.0005
	//#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.4375
	#define DE_Z 0.3750
	//#define DG_W 0.125//PoP
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 2.50
	//#define FTM 1
    //#define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.125//0.050//0.090 //Trim
    #define DF_W float4(0.001,0.00125,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.050
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.250    //De-Artifact
    //#define DL_Z 0.0       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define DSW 1
    #define PEW 1
#elif (App == 0x82E531A5 ) //Watch Dogs Leagon
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0125
	#define DF_Y 0.0100
	#define DA_Y 45.0 //50.0 //37.5
    #define DA_Z 0.001
	#define DB_Z 0.026
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W -0.20//PoP
    #define OIF 0.250 //Fix enables if Value is > 0.0
	#define DI_W 1.5
	//#define FTM 1
    //#define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.125//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.0475
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.250    //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
		
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.374 , 0.0888, 0.250 , 0.940  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.587 , 0.0888, 0.500 , 0.1485 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.84  , 0.810 , 0.500 , 0.870  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 30.0  , 30.0   )   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.0495, 0.057 , 0.500 , 0.057  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.930 , 0.960 , 0.688 , 0.320  ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.057 , 0.930 , 0.960  ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 23.0  , 30.0  , 30.0  , 30.0  )   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.1025, 0.058 , 0.500 , 0.057  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.930 , 0.960 , 0.000  , 0.00 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000  , 0.00 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 29.0  , 30.0  , 1000.0  , 1000.0 ) //Tresh Hold for Color A1 & A3 and Color
    #define PEW 1
    #define FOV 1
#elif (App == 0x6EC76A83 ) //Watch Dogs 2
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.0025
	#define DA_Y 32.0 //50.0 //37.5
    //#define DA_Z 0.001
	#define DB_Z 0.050
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W -0.20//PoP
    #define OIF 0.250 //Fix enables if Value is > 0.0
	#define DI_W 1.5
	//#define FTM 1
    //#define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.125//0.050//0.090 //Trim
    #define DF_W float4(0.001,0.00125,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.0375
    #define SMS 1            //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.0    //De-Artifact
    //#define DL_Z 0.75       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.500 , 0.0165, 0.972 , 0.0165 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.500 , 0.9750, 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 29.0  , 29.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
    /*
    #define DP_X float4( 0.0495, 0.057 , 0.500 , 0.057  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.930 , 0.960 , 0.688 , 0.320  ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.057 , 0.930 , 0.960  ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 23.0  , 30.0  , 30.0  , 30.0  )   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.1025, 0.058 , 0.500 , 0.057  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.930 , 0.960 , 0.000  , 0.00 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000  , 0.00 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 29.0  , 30.0  , 1000.0  , 1000.0 ) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define PEW 1
    #define FOV 1
    #define DAA 1
#elif (App == 0xDF0CD13E ) //Watch Dogs
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.0025
	#define DA_Y 25.0 //17.5
    //#define DA_Z 0.001
	#define DB_Z 0.050
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W -0.20//PoP
    #define OIF 0.250 //Fix enables if Value is > 0.0
	#define DI_W 1.5
	//#define FTM 1
    //#define DG_Z 0.00125//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.125//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.030
    #define SMS 1            //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.75    //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.501 , 0.109 , 0.150 , 0.880  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.220 , 0.907 , 0.501 , 0.109  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.150 , 0.880 , 0.145 , 0.8845  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 29.0  , 30.0, 29.0 )   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.588 , 0.152 , 0.150 , 0.880  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.220 , 0.907 , 0.4955, 0.098  ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.150 , 0.880 , 0.143 , 0.8925  ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 29.0  , 29.0  , 30.0  , 28.0  )   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.4955, 0.098 , 0.150 , 0.880  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.125 , 0.908 , 0.473 , 0.088 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.150 , 0.880 , 0.115 , 0.892 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0  , 29.0  , 30.0  , 28.0 ) //Tresh Hold for Color A1 & A3 and Color

    #define PEW 1
    #define FOV 1
    #define DAA 1
 #elif (App == 0x978D64F6 || App == 0x8C605518) //Vermintide 2
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.0025
	#define DA_Y 13.5 //12.5
    //#define DA_Z 0.001
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.725
	#define DE_Z 0.375
	//#define DG_W 0.2//PoP
    #define OIF 0.375 //Fix enables if Value is > 0.0
	#define DI_W 0.375
	//#define FTM 1
    #define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.075

    #define PEW 1
    #define FOV 1
    #define DAA 1
    #define NDW 1
 #elif (App == 0x7180D9FF ) //Shadow of the Tombraider
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.035
	//#define DF_Y 0.0025
	#define DA_Y 37.5
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.2//PoP
    //#define OIF 0.375 //Fix enables if Value is > 0.0
	//#define DI_W 0.375
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.100 //0.05-0.100
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.500    //De-Artifact
    //#define DL_Z 0.250       //Compat Power

    #define PEW 1
    #define FOV 1
    #define DAA 1
    #define NDW 1
 #elif (App == 0xEE08F4D7 || App == 0x541182E5 ) //Grow Up | Grow Home
	//#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.0025
	#define DA_Y 27.5
    //#define DA_Z 0.001
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.2//PoP
    //#define OIF 0.375 //Fix enables if Value is > 0.0
	//#define DI_W 0.375
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.9125      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.500    //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    #define PEW 1
    #define FOV 1
    #define DSW 1
#elif (App == 0x9FAEA815 ) //Amnesia Rebirth
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.075 //0.100
	#define DF_Y 0.0025
	#define DA_Y 25.0 //15.0
    #define DA_Z 0.0002
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.400 //PoP
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 2.0
	//#define FTM 1
    #define DG_Z 0.075 //Min
    #define DE_W 0.375 //Auto
    #define DI_Z 0.250 //Trim
	#define BMT 1
	#define DF_Z 0.150
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.500    //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 2 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.803 , 0.757 , 0.3216, 0.476 ) //Pos A1 = XY Color & A2 = ZW White 
    #define DO_Y float4( 0.803 , 0.817 , 0.803 , 0.757 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.3216, 0.500 , 0.803 , 0.817 ) //Pos B2 = XY White & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.803 , 0.757 , 0.3216, 0.555 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.803 , 0.817 , 0.803 , 0.757 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.660, 0.837 , 0.803 , 0.817 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.803 , 0.757 , 0.3216 , 0.577  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.803 , 0.817 , 0.803 , 0.757 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.3216, 0.574 , 0.803 , 0.817 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.803 , 0.757 , 0.3216, 0.460) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.803 , 0.817 , 0.803 , 0.757 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.3216 , 0.505 , 0.803 , 0.817 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color G & H and Color 

    #define PEW 1
    #define FOV 1
#elif (App == 0x8BBF7823 ) //DEATHLOOP    
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.10
	//#define DF_Y 0.0025
	#define DA_Y 55.0
    //#define DA_Z 0.001
	#define DB_Z 0.10
 
	#define DE_X 7
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.25 //Neg PoP
    #define OIF 0.500 //Fix enables if Value is > 0.0
	#define DI_W 0.125
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.150
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.250    //De-Artifact
    //#define DL_Z 0.125       //Compat Power
	#define DJ_X 0.035       //Range Smoothing
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.360 , 0.080 , 0.325 , 0.080 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.640 , 0.080 , 0.265 , 0.750 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.325 , 0.080 , 0.051 , 0.949 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 24.0, 24.0, 24.0, 24.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.051 , 0.949 , 0.325 , 0.080 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.120 , 0.275 , 0.790 , 0.275 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.325 , 0.080 , 0.861 , 0.957 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 24.0, 24.0, 24.0, 24.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.500 , 0.950 , 0.500 , 0.555 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.502 , 0.589 , 0.500 , 0.950 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.555 , 0.498 , 0.589 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 24.0, 15.0, 24.0, 15.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.500 , 0.950 , 0.500 , 0.555 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.499 , 0.589 , 0.500 , 0.969 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.499 , 0.140 , 0.400 , 0.140 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 24.0, 15.0, 24.0, 16.0) //Tresh Hold for Color G & H and Color 

	#define WSM 2
	#define DB_W 17
	#define DF_X float2(0.150,0.350)	
	//#define DJ_W 0.150
	#define DS_W 2.0
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 1
	#define DK_W 4  
    #define PEW 1
    #define FOV 1
    #define DAA 1
#elif (App == 0xAEF361B5 ) //Tell Me Why
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0125
	//#define DF_Y 0.0025
	#define DA_Y 82.5
    //#define DA_Z 0.001
	#define DB_Z 0.0125
 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.400
	//#define DG_W 0.100//PoP
    #define OIF 0.375 //Fix enables if Value is > 0.0
	#define DI_W 0.75
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
    #define DF_W float4(0.001,0.00125,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.89375      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.250    //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    #define PEW 1
#elif (App == 0x1061AEB6 ) //Just Cause 4
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.100
	//#define DF_Y 0.0025
	#define DA_Y 120.0
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.100//PoP
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 1.5
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -1.0    //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 1 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.090 , 0.175 , 0.525 , 0.175 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.779 , 0.9015, 0.080 , 0.137 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.360 , 0.137 , 0.779 , 0.9015) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 29.0, 29.0, 29.0, 29.0)   //Tresh Hold for Color A & B and Color

    #define PEW 1
#elif (App == 0xF14EB8C4 ) //Maid of Sker
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.0875
	//#define DF_Y 0.0025
	#define DA_Y 62.5
    //#define DA_Z 0.001
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.400
	//#define DG_W 0.100//PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.50,0.25,0.125,0.070) //Fix enables if Value is > 0.0
	#define DI_W float4(1.0,2.0,4.0,6.0)
	//#define FTM 1
    #define DG_Z 0.025 //Min
    #define DE_W 0.500 //Auto
    #define DI_Z 0.150 //0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.850    //De-Artifact
    //#define DL_Z 0.250       //Compat Power
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.145 , 0.146 , 0.145 , 0.900 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.145 , 0.700 , 0.188 , 0.146 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.750 , 0.750 , 0.4325, 0.925 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.188 , 0.146 , 0.750 , 0.750 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.4256, 0.925 , 0.188 , 0.146 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.750 , 0.750 , 0.4675, 0.925 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.188 , 0.146 , 0.750 , 0.750 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.4881, 0.925 , 0.101 , 0.146 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.750 , 0.750 , 0.4939, 0.925 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color
	
	#define DR_X float4( 0.101 , 0.146 , 0.750 , 0.750 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.485 , 0.925 , 0.101 , 0.146 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.750 , 0.750 , 0.473 , 0.925 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color G & H and Color 

    #define PEW 1
#elif (App == 0x94A862F2 ) //Pumkin Jack
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.030
	//#define DF_Y 0.0025
	#define DA_Y 100.0
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.125//PoP
    #define OIL 0 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.130 //Fix enables if Value is > 0.0
	#define DI_W 2.0
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 1.0    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	#define DJ_X 0.142       //Range Smoothing
    #define PEW 1
    //#define NDW 1
#elif (App == 0xED560119 ) //DarkSiders Genisis
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.075
	#define DF_Y 0.025
	#define DA_Y 155.0
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.375
    #define AFD 1
	//#define DG_W -0.125//PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.265 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.225  //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.055 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.075 //Trim
	#define BMT 1
	#define DF_Z 0.075
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.025       //SM Perspective
	#define DM_X 5           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.7    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
    #define PEW 1
	#define NDW 1
#elif (App == 0x1B8B9F54 ) //The Evil Within
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0625
	#define DF_Y 0.0625//0.0750
	#define DA_Y 75.0
    //#define DA_Z -0.000125
	#define DB_Z 0.1
 
	#define DE_X 3
	#define DE_Y 0.5 //0.375
	#define DE_Z 0.375
	//#define DG_W 0.1 //Pop
    #define OIF 0.15 //0.35 //Fix enables if Value is > 0.0
	#define DI_W 1.5 //Adjustment for REF
    #define DG_Z 0.050 //Min
    #define DI_Z 0.075 //Trim
	#define BMT 1
	#define DF_Z 0.075
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.5    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.195, 0.195,  0.956, 0.8945)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.485, 0.890,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26, 26.0, 26.0, 13.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.072 , 0.086 , 0.500 , 0.100  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.968 , 0.928 , 0.072 , 0.086  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.968 , 0.928  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0  , 30.0  , 29.0, 30.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.0081, 0.113 , 0.500 , 0.100  ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.968 , 0.928 , 0.8245, 0.297  ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.100 , 0.968 , 0.928   ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 23.0  , 30.0  , 30.0, 30.0 ) //Tresh Hold for Color A1 & A3 and Color
	
    #define PEW 1
	#define RHW 1
	#define LBM 1
	#define LBR 0
	#define DI_X 0.860
	#define DI_Y 0.140
#elif (App == 0x7D9B7A37 ) //The Evil Within II
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.040
	#define DF_Y 0.0025
	#define DA_Y 30.0
    #define DA_Z 0.00075
	#define DB_Z 0.075
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    //#define AFD 1
	#define DG_W -0.25//PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.250 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.0 //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.055 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.075 //Trim
	#define BMT 1
	#define DF_Z 0.050
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.875      //SM Tune
	//#define DL_W 0.025       //SM Perspective
	#define DM_X 5           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.800      //De-Artifact
    //#define DL_Z 0.100       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.7275, 0.175 , 0.900 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.920 , 0.940 , 0.6795, 0.175 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.900 , 0.100 , 0.920 , 0.940 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.1005, 0.075 , 0.900 , 0.100 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.920 , 0.940 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
    #define PEW 1
#elif (App == 0x9255C26F || App == 0x59939D69 ) //Crash Bandicoot 4 It's About Time
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.125
	#define DF_Y 0.0625
	#define DA_Y 32.5
    //#define DA_Z -0.050
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
    #define AFD 1
	#define DG_W 0.100//PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.275 //Fix enables if Value is > 0.0
	#define DI_W 1.250	
	//#define FTM 1
    //#define DG_Z 0.055 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.075 //Trim
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 1            //SM Toggle Separation
	#define DL_X 0.525      //SM Tune
	//#define DL_W 0.025       //SM Perspective
	#define DM_X 5           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.800      //De-Artifact
    //#define DL_Z 0.100       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.170 , 0.920 , 0.500 , 0.025 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.320 , 0.920 , 0.126 , 0.929 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.025 , 0.223 , 0.929 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 26.0, 26.0, 26.0, 26.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.170 , 0.920 , 0.500 , 0.025 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.297 , 0.920 , 0.126 , 0.929 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.025 , 0.235 , 0.929 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 26.0, 26.0, 26.0, 26.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.070 , 0.914 , 0.500 , 0.025 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.175 , 0.920 , 0.085 , 0.930 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.025 , 0.123 , 0.910 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 26.0, 26.0, 26.0, 23.0) //Tresh Hold for Color A1 & A3 and Color
	/*
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	
	#define HMC 0.580
	#define HMT 1
	#define PEW 1
#elif (App == 0x5C0EBBE9 ) //A Plague Tale Innocence
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.025
	#define DA_Y 33.0
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 2
	#define DE_Y 0.500
	#define DE_Z 0.375
    //#define AFD 1
	//#define DG_W -0.300 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.500 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.0  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.055 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.075 //Trim
	#define BMT 1
	#define DF_Z 0.1125
    #define SMS 1            //SM Toggle Separation
	#define DL_X 0.500     //SM Tune
	//#define DL_W 0.025       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -1.0    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 2
	//#define DB_W 20
	#define PEW 1
	#define RHW 1
	#define NFM 1
	#define DSW 1
#elif (App == 0x3950D04E )	//Skyrim: SE
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0480
	#define DF_Y 0.0525
	#define DA_Y 13.75
	#define DA_Z -0.000375
	#define DB_Z 0.100 //0.1125
 
	#define DE_X 6
	#define DE_Y 0.375
	#define DE_Z 0.4375
    //#define AFD 1
	//#define DG_W -0.300 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.500 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.0  //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.025 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.025 //Trim
	#define BMT 1
	#define DF_Z 0.075 //0.100//0.130
    #define SMS 1            //SM Toggle Separation
	#define DL_X 0.575     //SM Tune
	//#define DL_W 0.025       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -1.0    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 2
	//#define DB_W 20
	#define PEW 1
	#define DB_W 7
#elif (App == 0x7D66C321 ) //Lego Starwars Skywalker Saga
	#define DA_W 0
	#define DA_X 0.0375
	#define DF_Y 0.0375
	#define DA_Y 12.5
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.400
	#define DG_W -.350 //Less Pop
    //#define DG_Z 0.0875 //Min
    //#define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.123
    //#define AFD 1
	//#define DG_W -0.300 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.500 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.375  //float2(1.5,7.0)
	//#define FTM 1
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    //#define DL_Y -0.5    //De-Artifact
    #define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.307 , 0.167,  0.304, 0.835 ) //Pos A = XY White & B = ZW Dark 
    #define DN_Y float4( 0.7525, 0.125,  0.0  , 0.0   ) //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.0   , 0.0  ,  0.0  , 0.0   ) //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0   , 0.0  ,  0.0  , 0.0   ) //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0  , 28.0  , 30.0, 1000.0);              //Menu Detection Type   
    #define DJ_Z float3( 1000  , 1000 , 1000);
	//#define LBR 1
	#define BDF 1    //Barrel Distortion Fix k1 k2 k3 and Zoom
	#define DC_X 0.375
	#define DC_Y 0.0
	#define DC_Z 0.0
	#define DC_W -0.058
	#define PEW 1
#elif (App == 0xBCFD90CA ) //FFVII Remake Intergrade 
	#define DA_W 1
	#define DA_X 0.090
	#define DF_Y 0.050	
	#define DA_Y 21.5 //15
    //#define DA_Z 0.00025 //-1.0
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.400
    #define DG_Z 0.002 //Min
    #define DI_Z 0.200 //Trim
     //#define AFD 1
	#define DG_W -0.250 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.325 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.0  //float2(1.5,7.0)
	//#define FTM 1
	#define BMT 1
	#define DF_Z 0.1125 //0.1875
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.550 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3    //HQ Tune
	#define DM_Z 2     //HQ Smooth
	#define DL_Y -0.5    //De-Artifact
	#define PEW 1
	#define RHW 1
    #define DRS 1
#elif (App == 0x24C85A7A ) //Evil West
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.100
	//#define DF_Y 0.0025
	#define DA_Y 10.0
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.150//PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.250 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.0  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.825      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	#define DJ_X 0.142       //Range Smoothing
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.053 , 0.083 , 0.075 , 0.325 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.930 , 0.927 , 0.053 , 0.083 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.025 , 0.025 , 0.931 , 0.927 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 23.0, 25.0, 23.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
    #define PEW 1
    //#define NDW 1
#elif (App == 0xE5BE7432 ) //Dreamscaper
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.100
	//#define DF_Y 0.0025
	#define DA_Y 25.0
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 3
	#define DE_Y 0.550
	#define DE_Z 0.375
	#define DG_W -0.125//PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.250 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.625  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.050
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.75    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
    #define PEW 1
    //#define NDW 1
#elif (App == 0xCD52FFF9 ) //The Entropy Center
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0325
	//#define DF_Y 0.0025
	#define DA_Y 75.0
    //#define DA_Z 0.001
	#define DB_Z 0.0625
 
	#define DE_X 6
	#define DE_Y 0.550
	#define DE_Z 0.375
	#define DG_W -0.250 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.250 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.625  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.050
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.75    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	#define WSM 3
	#define DB_W 26
	#define DF_X float2(0.050,0.0)	
    #define PEW 1
    //#define NDW 1
#elif (App == 0xEB5CDE17 ) //The Dark Pictures Anthology: Man Of Medan
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.04375
	#define DF_Y 0.010
	#define DA_Y 20.0
    //#define DA_Z 0.001
	#define DB_Z 0.20
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.100 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.3125 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.450  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.75    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	#define RHW 1
	#define NDW 1
	#define SPF 1
	#define DD_W -0.240
	#define LBM 1
	#define DI_X 0.879
	#define DI_Y 0.120
#elif (App == 0x8E58FFE7 ) //The Dark Pictures Anthology: Little Hope
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.04375
	#define DF_Y 0.010
	#define DA_Y 20.0
    //#define DA_Z 0.001
	#define DB_Z 0.20
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.100 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.3125 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.450  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.75    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	#define RHW 1
	#define NDW 1
	#define SPF 1
	#define DD_W -0.240
	#define LBM 1
	#define DI_X 0.879
	#define DI_Y 0.120
#elif (App == 0xB928FC0C ) //The Dark Pictures Anthology: House Of Ashes
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.04375
	#define DF_Y 0.010
	#define DA_Y 20.0
    //#define DA_Z 0.001
	#define DB_Z 0.20
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.100 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.3125 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.450  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.75    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	#define RHW 1
	#define NDW 1
	#define SPF 1
	#define DD_W -0.240
	#define LBM 1
	#define DI_X 0.879
	#define DI_Y 0.120
#elif (App == 0x1983851A ) //Human FallFlat
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.00
	#define DA_Y 87.5
    //#define DA_Z 0.001
	#define DB_Z 0.1
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.400
	//#define DG_W -0.100 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.375 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.500  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.025
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.50    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	#define DJ_X 0.071       //Range Smoothing
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	#define DSW 1
	#define NDW 1
#elif (App == 0xFA52C2BA ) //SuperLucky's Tale
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.00
	#define DA_Y 32.5
    //#define DA_Z 0.001
	#define DB_Z 0.1
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W -0.200 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.200 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.200  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.150
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.50    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	#define DSW 1
#elif (App == 0xC2E621A5) //No Man Sky
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.045
	#define DF_Y 0.010
	#define DA_Y 70.0
    //#define DA_Z 0.001
	#define DB_Z 0.0375
 
	#define DE_X 2
	#define DE_Y 0.500//0.850
	#define DE_Z 0.375
	#define DG_W 1.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.500 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	//#define DI_W 1.200  //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.100 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125 //Trim
    #define DF_W float4(0.001,0.0025,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.650      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.50    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1    
	//#define WSM 3
	//#define DB_W 10
	#define RHW 1
#elif (App == 0xB9F94F65 ) //The Callisto Protocol
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.00
	#define DA_Y 75.0
    //#define DA_Z 0.001
	#define DB_Z 0.030
 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.400
	#define DG_W -0.125 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.375,0.2) //Fix enables if Value is > 0.0
	#define DI_W float2(0.5,2.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.50    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
#elif (App == 0x5EB9CBE2 ) //Brothers - A tale of two sons
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.075
	#define DF_Y 0.00
	#define DA_Y 7.5
    //#define DA_Z 0.001
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.300 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.250 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	//#define DI_W 1.00 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.120
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.825      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 5           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.50    //De-Artifact
    //#define DL_Z -1.0       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define DSW 1
#elif (App == 0x808ABB25 || App == 0x87871191 ) //BioShock Infinite //Steam //Epic
	#define DA_X 0.01
    #define DF_Y 0.005
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DA_Y 100.0//52.5 //12.50
    #define DA_Z -0.00125
    #define DB_Z 0.025
    #define BMT 1
	#define DF_Z 0.375
    //#define DG_Z 0.045//0.500 //0.030 //0.050//0.070//Min
    //#define DI_Z 0.045//0.2775 //0.150 //0.100 //0.090 //Trim
    #define DF_W float4(0.0001,0.004,0.0,0.0125) //Edge & Scale
    #define ABE 0
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
	#define DSW 1
    #define FOV 1
#elif (App == 0x9113C0D ) //Necromunda Hired Gun
	#define DA_W 1
	#define DA_X 0.020
	#define DF_Y 0.005
	#define DA_Y 42.5
	#define DB_Z 0.015
    //#define DB_X 1
 
	#define DE_X 6
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.350 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.400 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.300 //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.065 //Min
    //#define DI_Z 0.050 //Trim
    #define DF_W float4(0.001,0.0025,0.0,0.0) //Edge & Scale
	#define BMT 1
	#define DF_Z 0.0825
    #define SMS 1      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DL_Y -0.50    //De-Artifact
	#define WSM 3
	#define DB_W 11
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 1
	#define DK_W 3
	#define PEW 1
#elif (App == 0x50027232 ) //Yakuza0
	#define DA_X 0.100
	#define DF_Y 0.025
	#define DA_Y 11.0
	 
	#define DE_X 1
	#define DE_Y 0.4125
	#define DE_Z 0.400
	#define DG_W -0.125 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.200 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.10 //float2(1.5,7.0)
	#define BMT 1
	#define DF_Z 0.0625//0.100
    #define SMS 3     //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 5     //HQ Smooth
    //#define DL_Y 0.625    //De-Artifact
	#define PEW 1
	#define NDW 1
#elif (App == 0xEC457EA9 ) //Draugen
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	#define DF_Y 0.0025
	#define DA_Y 15.5
    //#define DA_Z 0.001
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.650
	#define DE_Z 0.375
	#define DG_W -0.20 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.350 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.20 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.1125
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.850      //SM Tune
	#define DL_W 0.5       //SM Perspective
	//#define DM_X 4           //HQ Tune
	//#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.50    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define DSW 1
#elif (App == 0x1B35716 ) //Gears 5
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0255
	#define DF_Y 0.000
	#define DA_Y 27.5
    //#define DA_Z 0.001
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.800
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.400 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.125 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.005//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.080
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	#define DL_W 0.5       //SM Perspective
	//#define DM_X 4           //HQ Tune
	//#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.500    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define DSW 1
#elif (App == 0x44BD41E1 ) //Bioshock Remaster
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 25.0
    #define DA_Z 0.0005
	#define DB_Z 0.050
 
	#define DE_X 6
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.375 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.0 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.004 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.08 //Trim
	#define BMT 1
	#define DF_Z 0.0525
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.500    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	#define WSM 3
	#define DB_W 4
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define DSW 1
#elif (App == 0x7CF5A01 ) //Bioshock 2 Remaster
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 25.0
    #define DA_Z 0.0005
	#define DB_Z 0.050
 
	#define DE_X 6
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.375 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.0 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.004 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.08 //Trim
	#define BMT 1
	#define DF_Z 0.0525
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.500    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	#define WSM 3
	#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define DSW 1
	#define HMC 0.5034
	#define HMT 1
#elif (App == 0xF812A363 || App == 0x973D94D) //High on Life //Windows Store // Steam
	#define DA_W 1
    //#define DB_X 1
	//#define DA_X 0.030 //0.034//0.030
	#define DF_Y 0.0075
	#define DA_Y 65.0//65.0 //62.5//75.0
    //#define DA_Z -0.05
	#define DB_Z 0.0375
 
	#define DE_X 0
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.375 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.0625//0.075//0.250 //0.245 //0.255 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.0575//0.140//0.1325 //Trim
    #define DF_W float4(0.0001,0.00525,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.040
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.5    //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define RHW 1
	#define HMC 1.0
	#define HMT 1
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 3
	#define DK_W 2
#elif (App == 0x8C8F544C ) //Witcher 3 DX12
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.080//0.060
	#define DF_Y 0.0125
	#define DA_Y 7.5//11.0
    //#define DA_Z -0.0005
	#define DB_Z 0.019
 
	#define DE_X 3
	#define DE_Y 0.450
	#define DE_Z 0.400
	#define DG_W -0.20 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.225 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.7 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.225 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.050
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.700 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.650    //De-Artifact
    //#define DL_Z 0.1       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	#define PEW 1
	#define DAA 1
#elif (App == 0x619964A3 ) //What Remains of Edith Finch
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.020
	//#define DF_Y 0.0125
	#define DA_Y 125
    //#define DA_Z 0.000025
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W 0.375 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.50 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 1.20 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.035 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.123
	//#define SMS 3      //SM Toggle Separation
	#define DL_X 0.800 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 2     //HQ Tune
	#define DM_Z 2     //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.650    //De-Artifact
    //#define DL_Z 0.1       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	#define PEW 1
	#define HMC 2.5
	#define HMT 1
#elif (App == 0x67297592 ) //Blair Witch
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050 //0.055
	#define DF_Y 0.01
	#define DA_Y 25.0 //17.5
    #define DA_Z 0.0005
	#define DB_Z 0.1
 
	#define DE_X 1
	#define DE_Y 0.450
	#define DE_Z 0.375
	#define DG_W 0.125 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.375 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.05 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.035
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.5    //De-Artifact
    //#define DL_Z 0.05       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define DSW 1
#elif (App == 0x703B7BB6 ) //BulletStorme: FullClip 
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025 //0.055
	#define DF_Y 0.010
	#define DA_Y 25.0 //17.5
    //#define DA_Z 0.0005
	#define DB_Z 0.1
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W 0.5 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.375 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	//#define DI_W 1.0 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.05 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.120 //Trim
    #define DF_W float4(0.0001,0.004,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.050
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.5    //De-Artifact
    //#define DL_Z 0.05       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    #define DSW 1
#elif (App == 0xD9691F81 ) //Destroy All Humans! || Destroy All Humans! 2 - Reprobed
	#define DA_W 1
	#define DA_X 0.075
	#define DF_Y 0.015
	#define DA_Y 30
    //#define DA_Z -0.075
	 
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define DG_W -0.1125  //Pop out allowed
    #define BMT 1    
    #define DF_Z 0.0750 //0.100 // 0.125 
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune // 0.550
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DL_Y 0.375 //De-Artifact Performance hit too large here.
    //#define DL_Z 0.125       //Compat Power
	#define OIF 0.0375 //Fix enables if Value is > 0.0
	#define DI_W 2.5   //Adjustment for REF
	//#define NFM 1
	#define PEW 1
	#define RHW 1
#elif (App == 0x84DC9F37 ) //Close to the Sun
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.100
	//#define DF_Y 0.010
	#define DA_Y 75.0
    //#define DA_Z 0.0005
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.400
	//#define DG_W 0.5 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.400 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.50 //float2(1.5,7.0)
	//#define FTM 1
    #define DG_Z 0.025 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.05 //Trim
    #define DF_W float4(0.0001,0.0025,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.025
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.5    //De-Artifact
    //#define DL_Z 0.05       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    //#define DSW 1
#elif (App == 0x2FEDE211 ) //DreadOut 2
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	//#define DF_Y 0.010
	#define DA_Y 125.0
    //#define DA_Z 0.0005
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DG_W -0.125 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.250,0.060) //Fix enables if Value is > 0.0
	#define DI_W float2(0.75,12.5)
	//#define FTM 1
    #define DG_Z 0.025 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.175//Trim
    #define DF_W float4(0.0001,0.00125,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.0375
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.05       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 4 //Set Multi Menu Detection             //Off / On 
    #define MMS 1 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2 One is for the first 4 and Two is for the last 4
    #define DO_X float4( 0.009 , 0.035 , 0.1425 , 0.190 ) //Pos A1 = XY Color & A2 = ZW White 
    #define DO_Y float4( 0.277 , 0.030 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY White & B3 = ZW Color
	#define DO_W float4( 16.0, 16.0, 1000.0, 1000.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW White 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY White & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.435 , 0.120 , 0.709 , 0.232 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.559 , 0.110 , 0.546 , 0.798 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.175 , 0.437 , 0.796 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 24.0, 24.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.720 , 0.600 , 0.500 , 0.175 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.720 , 0.400 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 

	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1
    //#define DSW 1
#elif (App == 0x913AD2D ) //SpaceHulk DeathWing Enhanced Edition	
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.04
	#define DF_Y 0.05
	#define DA_Y 12.5
    //#define DA_Z 0.0005
	#define DB_Z 0.05
 
	#define DE_X 0
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.5 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.400 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.50 //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.060 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.20 //Trim
    #define DF_W float4(0.0001,0.025,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.025
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -1.0    //De-Artifact
    //#define DL_Z 0.05       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	#define HMT 1
	#define HMC 0.503
	#define PEW 1
	#define NDW 1
#elif (App == 0xCFFBDDE6 ) //Call of the Sea
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0375
	#define DF_Y 0.020
	#define DA_Y 25
    //#define DA_Z -0.125
	#define DB_Z 0.050
 
	//#define DE_X 3
	//#define DE_Y 0.500
	//#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 1.25 //Adjustment for REF
    #define DG_Z 0.05 //Min
    #define DI_Z 0.100 //Trim
    #define DF_W float4(0.001,0.0075,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.1375
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 0     //HQ Smooth
	#define PEW 1
    #define DSW 1
#elif (App == 0x22CA259A ) //Kena Bridge of Spirits
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.10
	#define DF_Y 0.01
	#define DA_Y 17.0 //17.5
    //#define DA_Z 0.0005
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.550
	#define DE_Z 0.375
	#define DG_W -0.125 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.325,0.125) //Fix enables if Value is > 0.0
	#define DI_W float2(0.50,5.0)
	//#define FTM 1
    //#define DG_Z 0.060 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.20 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 0            //SM Toggle Separation
	#define DL_X 0.875      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    #define DM_Y 0           //HQ VRS
    #define HQT 1
    //#define DL_Y 0.0    //De-Artifact
    //#define DL_Z -1.0       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	#define LBR 1
	#define LBC 1 //Letter Box Correction With X & Y
	//#define DH_X 1.0
	#define DH_Y 1.0
    //#define DH_Z 0.0
    #define DH_W 0.0
    //Needs to be done if DLSS is used.
	/*
	#define SPF 1
	#define DD_X 1.0
	#define DD_Y 0.994
	#define DD_Z 0.0
	#define DD_W -0.0025
	*/
	#define PEW 1
	#define DSW 1
	#define DAA 1
#elif (App == 0x8F32C735 ) //Sessions Skate Sim
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.035
	#define DF_Y 0.00
	#define DA_Y 50.0
    //#define DA_Z 0.0005
	#define DB_Z 0.1
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.125 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.25,0.10) //Fix enables if Value is > 0.0
	#define DI_W float2(0.5,4.0)
	//#define FTM 1
    //#define DG_Z 0.060 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.20 //Trim
	#define BMT 1
	#define DF_Z 0.050
    //#define SMS 0            //SM Toggle Separation
	#define DL_X 0.875      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.0    //De-Artifact
    //#define DL_Z -1.0       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.727 , 0.597 , 0.975 , 0.175 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.973 , 0.840 , 0.136 , 0.899 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.950 , 0.863 , 0.898 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1 //Letter Box Correction With X & Y
    //#define DH_Z 0.0
    //#define DH_W -0.05
	//#define LBR 1
	#define PEW 1
	//#define NDW 1
#elif (App == 0xBF49B12E ) //Vampyr
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05
	#define DF_Y 0.05
	#define DA_Y 23.0
    //#define DA_Z 0.0005
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.600
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.200 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.50 //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.060 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.20 //Trim
	#define BMT 1
	#define DF_Z 0.015
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.850      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 4           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -1.0    //De-Artifact
    //#define DL_Z 0.05       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	#define PEW 1
#elif (App == 0x8CC8A7BD ) //Duke Nukem 3D: 20th Anniversary World Tour
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0125
	#define DA_Y 130.0
    //#define DA_Z 0.0005
	#define DB_Z 0.0125
 
	#define DE_X 3
	#define DE_Y 0.700
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.45,0.25,0.2,0.175) //Fix enables if Value is > 0.0
	#define DI_W float4(0.5,1.75,3.25,17.5)
	//#define FTM 1
    #define DG_Z 0.05 //Min
    #define DE_W 0.000 //Auto
    #define DI_Z 0.015 //Trim
    #define DF_W float4(0.0001,0.00075,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.050
    #define SMS 2            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.25    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	#define PEW 1
	#define NDW 1
	#define DSW 1
#elif (App == 0xE2F6CE28 ) //Remember Me
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05
	#define DF_Y 0.00
	#define DA_Y 25.0
    //#define DA_Z 0.0005
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.25 //Fix enables if Value is > 0.0
	#define DI_W 1.25
	//#define FTM 1
    //#define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.015 //Trim
	#define BMT 1
	#define DF_Z 0.025
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.159 , 0.575 , 0.887 , 0.928 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.181 , 0.321 , 0.202 , 0.440 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.887 , 0.928 , 0.224 , 0.265 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 15.0, 30.0, 15.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.179 , 0.501 , 0.887 , 0.928 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.202 , 0.360 , 0.134 , 0.235 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.887 , 0.928 , 0.150 , 0.115 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 15.0, 30.0, 15.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.1295, 0.213 , 0.887 , 0.928 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.1295, 0.520 , 0.105 , 0.447 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.887 , 0.928 , 0.130 , 0.265 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 15.0, 15.0, 30.0, 15.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.118 , 0.200 , 0.887 , 0.928 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.138 , 0.056 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 15.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	#define PEW 1
	#define DSW 1
#elif (App == 0xDC3A655A ) //SuperKiwi64
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0125
	#define DA_Y 25.0
    //#define DA_Z 0.0005
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.25 //Fix enables if Value is > 0.0
	#define DI_W 2.0
	//#define FTM 1
    //#define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.015 //Trim
	#define BMT 1
	#define DF_Z 0.064
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	//#define DM_X 4           //HQ Tune
	//#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	#define PEW 1
	#define ARW 1
#elif (App == 0x2A98C423 ) //Somerville
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.0500
	//#define DF_Y 0.00
	#define DA_Y 50.0
    //#define DA_Z 0.0005
	//#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.575
	#define DE_Z 0.400
	//#define DG_W -0.20 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.25,0.055)  //Fix enables if Value is > 0.0
	#define DI_W float2(1.0,4.0)
	//#define FTM 1
    //#define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.015 //Trim
	#define BMT 1
	#define DF_Z 0.025
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 1.000      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	#define DH_W -0.237
	#define PEW 1
	#define NFM 1
#elif (App == 0xB2D70667 ) //Babbdi
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.100
	//#define DF_Y 0.00
	#define DA_Y 100.0
    //#define DA_Z 0.0005
	//#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.700
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.50 //float2(0.25,0.055)  //Fix enables if Value is > 0.0
	#define DI_W 0.25 //float2(1.0,4.0)
	//#define FTM 1
    #define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.20 //Trim
    #define DF_W float4(0.0001,0.005,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.025
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 1.000      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	#define PEW 1
	#define NFM 1
#elif (App == 0x77737774 ) //Resident Evil 0
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.020
	//#define DF_Y 0.00
	#define DA_Y 32.5
    //#define DA_Z 0.0005
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.600
	#define DE_Z 0.375
	//#define DG_W -0.1 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.250 //float2(0.25,0.055)  //Fix enables if Value is > 0.0
	//#define DI_W 0.25 //float2(1.0,4.0)
	//#define FTM 1
    //#define DG_Z 0.020 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.100 //Trim
    #define DF_W float4(0.0001,0.0025,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.025
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 1.000      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503

	#define SPF 1  //Letter Box Correction Offsets With X & Y
	#define DD_X 1.067
	#define DD_Y 0.937
	#define DD_Z 0.187
	#define DD_W -0.066
	#define LBM 2
	#define DI_X 0.875
	#define DI_Y 0.125

	#define PEW 1
	#define ARW 1
#elif (App == 0x68EF1B4E || App == 0xC103D998 || App == 0xFAB47970 || App == 0x539E792B ) //Serious Sam Fusion | Serious Sam 4: Planet Badass | Serious Sam Siberian Mayhem/Unrestricted
	#define DA_W 1
	#define DA_X 0.0875
	//#define DF_Y 0.0125
	#define DA_Y 10.0
	#define DA_Z 0.1
	 
	#define WSM 5
	#define DB_W 16
    #define DF_X 0.25
    #define DJ_W 0.6
	#define DE_X 4
	#define DE_Y 0.625
	#define DE_Z 0.400
	#define DB_Z 0.050
	#define DG_W -0.125 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.375,0.25)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.25,0.5,2.5)
	#define DG_Z 0.075 //Min
    #define DI_Z 0.125//Trim
    //#define SMS 3      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune // 0.550
	//#define DL_W 0.025 //SM Perspective
	//#define DM_X 4     //HQ Tune
	//#define DM_Z 4     //HQ Smooth
	#define NDW 1
	#define RHW 1
	#define PEW 1
	#define LBC 2  //Letter Box Correction Offsets With X & Y
	#define DH_Z 0.256
	#define DH_W 0.0
#elif (App == 0x5FADA0E2 ) //Choo Choo Charlies
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	//#define DF_Y 0.00
	#define DA_Y 25.0
    //#define DA_Z 0.0005
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.25 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.375,0.250)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.0,0.5,2.0)
	//#define FTM 1
    //#define DG_Z 0.020 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.1375
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.030 , 0.090 , 0.120 , 0.500 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.230 , 0.190 , 0.565 , 0.043 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.075 , 0.238 , 0.459 , 0.136 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.348 , 0.450 , 0.052 , 0.410 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.657 , 0.472 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503

	#define LBC 1 //Letter Box Correction With X & Y
	#define LBS 1
    #define DH_Z 0.0
    #define DH_W -0.227
	#define PEW 1
	#define ARW 1
#elif (App == 0x4FF5CF63 ) //Lords of the Fallen
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	//#define DF_Y 0.00
	#define DA_Y 57.5
    //#define DA_Z 0.0005
	//#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.625
	#define DE_Z 0.375
	//#define DG_W -0.25 //PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.5,0.3,0.25,0.10)  //Fix enables if Value is > 0.0
	#define DI_W float4(0.5,1.5,2.0,4.5)
	//#define AFD 1
	//#define FTM 1
    //#define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.015 //Trim
    #define DF_W float4(0.0001,0.001,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.065
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.500 , 0.040 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.3035, 0.060 , 0.500 , 0.040 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.499 , 0.060 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 30.0, 27.0, 30.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.500 , 0.040 , 0.500 , 0.100 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.657 , 0.060 , 0.500 , 0.0423) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.100 , 0.499 , 0.065 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 25.0, 30.0, 21.0, 28.0)   //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.500 , 0.0423, 0.500 , 0.100 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.5005, 0.065 , 0.500 , 0.0423) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.100 , 0.4975, 0.065 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 21.0, 28.0, 21.0, 28.0) //Tresh Hold for Color A1 & A3 and Color
	/*
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//define DH_W -0.237
	#define PEW 1
#elif (App == 0x8A369DA7 ) //Sonic Frontiers
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.123
	//#define DF_Y 0.00
	#define DA_Y 20.0
    //#define DA_Z 0.0005
	//#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.400
	#define DG_W -0.25 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.35,0.25)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.125,1.0,2.0)
	//#define FTM 1
    #define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.20 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
	#define DAA 1
#elif (App == 0x7A38C65F ) //The Council
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0625
	#define DF_Y 0.025
	#define DA_Y 16.25
    //#define DA_Z 0.0005
	#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.400
	#define DG_W -0.125 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.375,0.225)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.0,1.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.20 //Trim
	#define BMT 1
	#define DF_Z 0.055
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
	//#define DAA 1
#elif (App == 0x1061B3CF ) //Just Cause 3
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.03//0.025
	//#define DF_Y 0.0025
	#define DA_Y 60.0
    //#define DA_Z 0.001
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W 0.100//PoP
    #define OIF 0.125 //Fix enables if Value is > 0.0
	#define DI_W 1.5
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.05
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 3           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.375   //De-Artifact
    //#define DL_Z -0.125       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.150 , 0.150 , 0.500 , 0.070 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.850 , 0.780 , 0.150 , 0.180 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.070 , 0.850 , 0.800 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 25.0, 25.0, 25.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.150 , 0.150 , 0.500 , 0.070 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.850 , 0.780 , 0.150 , 0.180 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.070 , 0.850 , 0.800 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 26.0, 25.0, 26.0, 26.0)   //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
    #define PEW 1
#elif (App == 0x6DDCD106 ) //The Town of Light
	//#define DA_W 1
    #define DB_X 1
	#define DA_X 0.0875
	#define DF_Y 0.000
	#define DA_Y 7.25
    //#define DA_Z 0.0005
	#define DB_Z 0.050
 
	#define DE_X 3
	#define DE_Y 0.875
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.125 //PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.60,0.50,0.300,0.1) //float3(0.5,0.375,0.225)  //Fix enables if Value is > 0.0
	#define DI_W float4(0.0,0.50,0.750,2.5) //float3(0.0,1.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.05 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.20 //Trim
	#define BMT 1
	#define DF_Z 0.0325
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 2           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.1025, 0.085 , 0.910 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.101 , 0.145 , 0.1025, 0.085 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.910 , 0.100 , 0.102 , 0.145 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 29.0, 30.0, 29.0, 29.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
#elif (App == 0xF5FC8B92 ) //The Light Remake
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 20.0
    //#define DA_Z 0.0005
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W 1.5 //PoP
    //#define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float4(0.5,0.300,0.160,0.100) //float3(0.5,0.375,0.225)  //Fix enables if Value is > 0.0
	//#define DI_W float4(0.5,1.0,2.5,4.0) //float3(0.0,1.0,2.5)
	//#define FTM 1
    #define DG_Z 0.040 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.040 //Trim
    #define DF_W float4(0.001,0.0075,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.03
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z -0.25       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
#elif (App == 0xF4901178 ) //The Surge 2 ****
    #define DA_W 1 
    #define DA_X 0.125
    #define DF_Y 0.0225
    #define DA_Y 35.00
    #define DE_X 1
    #define DE_Y 0.375
    #define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.125 //0.125 //0.150
	#define DG_Z 0.100 //Min
    #define DI_Z 0.150 //Trim
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.600 //SM Tune
	#define DL_W 0.100 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
	#define PEW 1
#elif (App == 0x2CB33C9A ) //The Surge
	//#define DA_W 1
    //#define DB_X 1
	//#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 25.0
    //#define DA_Z 0.0005
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 1.5 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.350,0.225)//float4(0.5,0.300,0.160,0.100) //float3(0.5,0.375,0.225)  //Fix enables if Value is > 0.0
	#define DI_W float2(1.00,2.5)//float4(0.5,1.0,2.5,4.0) //float3(0.0,1.0,2.5)
	//#define FTM 1
    #define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.125 //Trim
    #define DF_W float4(0.001,0.001,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.075
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define FOV 1
	#define PEW 1
#elif (App == 0xCDD5E6CF ) //Legend of Grimrock
	#define DA_X 0.120
	#define DF_Y 0.135
	#define DA_Y 12.5
	 
#elif (App == 0x4BAA047 ) //Legend of Grimrock 2
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.155
	#define DF_Y 0.001
	#define DA_Y 7.5
    //#define DA_Z 0.001
	#define DB_Z 0.05
 
	//#define DE_X 1
	//#define DE_Y 0.500
	//#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 1.5 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.350,0.225)//float4(0.5,0.300,0.160,0.100) //float3(0.5,0.375,0.225)  //Fix enables if Value is > 0.0
	//#define DI_W float2(1.00,2.5)//float4(0.5,1.0,2.5,4.0) //float3(0.0,1.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.0375
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
#elif (App == 0x72Da7135 ) //Bugnaxs
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.050
	//#define DF_Y 0.001
	#define DA_Y 50.0
    //#define DA_Z 0.001
	#define DB_Z 0.1
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W 0.125 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.350  //Fix enables if Value is > 0.0
	#define DI_W 1.25
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.075
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.750      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 8           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	#define HMT 1
	#define HMC 2.5
    #define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
#elif (App == 0xB264618F ) //V Rising
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.1
	#define DF_Y 0.01
	#define DA_Y 50
    #define DA_Z 0.000
	#define DB_Z 0.150
 
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.5 //PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.625,0.45,0.275,0.125)  //Fix enables if Value is > 0.0
	#define DI_W float4(-0.25,0.0,0.875,2.5)
	//#define FTM 1
    #define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.025
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0x45BE97B7 ) //Sackboy A Big Adventure
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.03
	#define DF_Y 0.01
	#define DA_Y 75.0
    //#define DA_Z 0.001
	#define DB_Z 0.014
 
	#define DE_X 3
	#define DE_Y 0.700
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W -0.125 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.20,0.125)//float4(0.5,0.300,0.160,0.100) //float3(0.5,0.375,0.225)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.25,1.00,2.75)//float4(0.5,1.0,2.5,4.0) //float3(0.0,1.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.125 //Trim
	#define BMT 1
	#define DF_Z 0.10
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
    //#define MAC 1
    #define MDD 4 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.200, 0.900 , 0.826 , 0.940)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.800, 0.900 , 0.000 , 0.000)//Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)         //Pos E = XY Match & F = ZW Match
	#define DN_W float4( .89, 0.0 , 0.0, 0.0 )        //Size = Menu [ABC] D E F
    #define DJ_Y float4( 25.0, 30.0, 25.0, 0.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.420 , 0.125 , 0.045 , 0.400 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.580 , 0.125 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 1000.0, 1000.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	#define FMM 1
	#define PEW 1
#elif (App == 0x1E28FCCC ) //Paradise Lost
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.115//0.075
	//#define DF_Y 0.001
	#define DA_Y 250//400.0
    //#define DA_Z 0.001
	#define DB_Z 0.075
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 0.125 //PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.350  //Fix enables if Value is > 0.0
	//#define DI_W 1.25
	//#define FTM 1
    #define DG_Z 0.100 //0.170 //0.210 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.200 //0.175 //0.200//Trim
    #define DF_W float4(0.001,0.005,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.15
    //#define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y 0.75   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.500 , 0.180 , 0.495 , 0.120)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.5025, 0.600 , 0.0   , 0.0  )//Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)          //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )         //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 2.0, 30.0, 0.0);        //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.434 , 0.120 , 0.495 , 0.175 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.566 , 0.120 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 1000.0, 1000.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
	#define FOV 1
#elif (App == 0x55FAB221 ) //Marvels Spider-Man
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.030
	//#define DF_Y 0.030
	#define DA_Y 27.5 //30.00
    #define DA_Z -0.1875
	#define DB_Z 0.100
 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define DG_W -0.100 //Pop
    //#define OIF 0.225 //Fix enables if Value is > 0.0
	//#define DI_W 1.25 //Adjustment for REF
    #define DG_Z 0.025 //Min
    #define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.8625//SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define PEW 1
	#define DAA 1
    #define DSW 1
    #define DRS 1
#elif (App == 0xB976D288 ) //Marvels Spider-Man Miles Morales
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.075//0.030
	//#define DF_Y 0.030
	#define DA_Y 27.5 //30.00
    //#define DA_Z -0.1875
	#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.625
	#define DE_Z 0.400
	#define DG_W -0.125 //Pop
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.5,0.40,0.2625,0.1875)  //Fix enables if Value is > 0.0
	#define DI_W float4(0.0,1.0,1.75,3.0)
    #define DG_Z 0.025 //Min
    #define DI_Z 0.050 //Trim
    #define DF_W float4(0.001,0.00125,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 4     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DL_Z 0.5       //Compat Power
    //#define DL_Y -0.375   //De-Artifact
	#define DJ_X 0.085       //Range Smoothing
	#define PEW 1
	#define DAA 1
    #define DSW 1
    #define DRS 1
#elif (App == 0xAE9BDA5E ) //Ghost of Tale
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.0525
	//#define DF_Y 0.01
	#define DA_Y 50
    //#define DA_Z 0.000
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.55
	#define DE_Z 0.4
	//#define AFD 1
	//#define DG_W 2.25 //PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.3,0.2,0.1,0.0375)  //Fix enables if Value is > 0.0
	#define DI_W float4(1.0,2.0,3.0,5.0)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.90      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power

    //#define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.287 , 0.209 , 0.239 , 0.195)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.710 , 0.209 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 0.0, 30.0, 18.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	


    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
	//Books
    #define DO_X float4( 0.4862, 0.909 , 0.500 , 0.925 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.512 , 0.909 , 0.497 , 0.909 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.925 , 0.5225, 0.909 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
	//Chest Stuff
    #define DP_X float4( 0.486 , 0.745 , 0.500 , 0.100 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.5119, 0.745 , 0.598 , 0.745 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.900 , 0.624 , 0.745 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.491 , 0.407 , 0.500 , 0.120 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.518 , 0.902 , 0.222 , 0.6636) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.100 , 0.500 , 0.6589) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 25.0) //Tresh Hold for Color A1 & A3 and Color
	
	#define DR_X float4( 0.222 , 0.6636 , 0.500 , 0.900 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.500 , 0.6589 , 0.5575, 0.443 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.500 , 0.5000 , 0.467 , 0.295 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 29.0, 24.0, 30.0, 30.0) //Tresh Hold for Color G & H and Color 
	
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	#define PEW 1	
#elif (App == 0xE71E75AD ) //Hi-Fi RUSH
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.040
	//#define DF_Y 0.01
	#define DA_Y 100
    //#define DA_Z 0.000
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.600
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 0.125 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.250,0.150)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.5,1.5,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.875      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 1           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/


    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.045 , 0.660 , 0.250 , 0.175 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.425 , 0.745 , 0.117 , 0.695 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.250 , 0.175 , 0.427 , 0.618 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 26.0, 30.0, 26.0, 30.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.112 , 0.092 , 0.1096, 0.165 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.931 , 0.941 , 0.112 , 0.092 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.133 , 0.067 , 0.919 , 0.938 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 30.0, 28.0, 30.0)   //Tresh Hold for Color C & D and Color


	#define DQ_X float4( 0.112 , 0.092 , 0.250 , 0.175 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.919 , 0.938 , 0.089 , 0.154 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.250 , 0.189 , 0.154 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 28.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.075 , 0.206 , 0.500 , 0.021 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.479 , 0.887 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 28.0, 28.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 

	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0x4C5965E5 ) //Dead Space 2023
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05//0.075
	//#define DF_Y 0.01
	#define DA_Y 38.75//25
    //#define DA_Z 0.000
	//#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.25 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.05,0.325,0.225)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.25,0.75,1.25)//float4(-0.25,0.0,0.875,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.050
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.95      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define RHW 1
	#define DAA 1
	#define PEW 1
#elif (App == 0xB78730C7 ) //Hogwarts Lagacy
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0275
	//#define DF_Y 0.01
	#define DA_Y 62.5 //77.5
    //#define DA_Z 0.000
	#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.7
	#define DE_Z 0.35
	//#define AFD 1
	#define DG_W 0.0
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.6,0.4,0.25,0.075)  //Fix enables if Value is > 0.0
	#define DI_W float4(0.25,0.5,1.0,3.0)//float4(-0.25,0.0,0.875,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 4           //HQ Smooth
    //#define DM_Y 3           //HQ VRS   
	#define DL_Y -1.0   //De-Artifact
    
    //#define DL_Z 0.5       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.482 , 0.785 , 0.964 , 0.945 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.526 , 0.785 , 0.482 , 0.785 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.875 , 0.945 , 0.526 , 0.785 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define RHW 1
	#define DAA 1
	#define PEW 1

#elif (App == 0xA88CDB8 )	// Returnal
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.125
	//#define DF_Y 0.01
	#define DA_Y 12.25
    //#define DA_Z 0.000
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.350
	//#define AFD 1
	//#define DG_W -0.25 //Neg PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.500,0.375,0.25,0.125) //Fix enables if Value is > 0.0
	#define DI_W float4(0.5,2.5,5.0,7.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.25   //De-Artifact
    //#define DL_Z 0.125       //Compat Power

	//#define WSM 3
	//#define DB_W 12
	//#define DF_X float2(0.150,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0xF6F06BA0 || App == 0x5899A89A) //Minecraft Dungeons Steam | Windows Store
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.250
	//#define DF_Y 0.00
	#define DA_Y 50.0
    #define DA_Z -0.250
	#define DB_Z 0.05
 
	#define DE_X 3
	#define DE_Y 0.860
	#define DE_Z 0.375
	#define DG_W -0.125 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.4, 0.325,0.250)//float3(0.5,0.375,0.250)  //Fix enables if Value is > 0.0
	#define DI_W float3(1.0,1.5,2.0)//float3(0.0,0.5,2.0)
	//#define FTM 1
    //#define DG_Z 0.020 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.100 //Trim
	#define BMT 1
	#define DF_Z 0.00
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/

    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.958 , 0.075 , 0.940 , 0.929 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.9165, 0.836 , 0.0335, 0.965 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.940 , 0.876 , 0.9165, 0.783 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0,30.0,30.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.052 , 0.061 , 0.370 , 0.793 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.121 , 0.063 , 0.445 , 0.966 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.940 , 0.876 , 0.9165 , 0.783 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 24.0, 30.0, 30.0)   //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.3845, 0.146 , 0.601 , 0.947 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.3145, 0.905 , 0.3845, 0.146 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.601 , 0.947 , 0.3145, 0.905 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 10.0, 13.0, 10.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.3765, 0.147 , 0.060 , 0.959 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.606 , 0.147 , 0.133 , 0.178 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.145 , 0.0755, 0.140 , 0.190 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 30.0, 15.0) //Tresh Hold for Color G & H and Color 

	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503

	//#define LBC 1 //Letter Box Correction With X & Y
	//#define LBS 1
    //#define DH_Z 0.0
    //#define DH_W -0.227
	#define PEW 1
#elif (App == 0xCB7B0316 || App == 0x262B39FE) //Atomic Heart Steam | Windows Store
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.060//0.0625
	//#define DF_Y 0.00
	#define DA_Y 27.5
    //#define DA_Z 0.0005
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.400
	#define DG_W 5.0 //PoP
    //#define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float3(0.5,0.375,0.250)  //Fix enables if Value is > 0.0
	//#define DI_W float3(0.0,0.5,2.0)
	//#define FTM 1
    #define DG_Z 0.095 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.195 //Trim
    #define DF_W float4(0.0001,0.015,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.160
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	//#define DB_W 5
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503

	#define LBC 1 //Letter Box Correction With X & Y
	#define LBS 1
    #define DH_Z 0.0
    #define DH_W -0.227
	#define PEW 1
	//#define ARW 1
#elif (App == 0x23AB8876 || App == 0xBF4D4A41 )	//CoD:AW | CoD:MW Re
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05
	//#define DF_Y 0.01
	#define DA_Y 13.5
    //#define DA_Z 0.000
	#define DB_Z 0.085
 
	#define DE_X 6
	#define DE_Y 0.625
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W -0.25 //Neg PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.475,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.10
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5   //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	#define DB_W 12
	#define DF_X float2(0.150,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1	
#elif (App == 0x7448721B )	// CoD:Ghost
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05
	//#define DF_Y 0.01
	#define DA_Y 13.5
    //#define DA_Z 0.000
	#define DB_Z 0.085
 
	#define DE_X 6
	#define DE_Y 0.625
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W -0.25 //Neg PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.475,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.25   //De-Artifact
    //#define DL_Z 0.25       //Compat Power

	//#define WSM 3
	#define DB_W 12
	#define DF_X float2(0.150,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0x15440705 )	//CoD:IW
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0275
	//#define DF_Y 0.01
	#define DA_Y 16.25 //15.0
    //#define DA_Z 0.000
	#define DB_Z 0.05
 
	#define DE_X 6
	#define DE_Y 0.725
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W -0.45 //Neg PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.05
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.25   //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	#define DB_W 13
	#define DF_X float2(0.150,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0x42C1A2B ) //CoD: WWII
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05
	//#define DF_Y 0.01
	#define DA_Y 13.5
    //#define DA_Z 0.000
	#define DB_Z 0.05
 
	#define DE_X 6
	#define DE_Y 0.625
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W -0.25 //Neg PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.475,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.030
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.25   //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	//#define WSM 3
	#define DB_W 12
	#define DF_X float2(0.150,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	#elif (App == 0x339B15DA) //Bendy and the Dark Revival
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.1125
	//#define DF_Y 0.00
	#define DA_Y 250.0
    //#define DA_Z 0.0005
	#define DB_Z 0.0625
 
	#define DE_X 6
	#define DE_Y 0.625
	#define DE_Z 0.450
	//#define DG_W -0.4375 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.375,0.250)  //Fix enables if Value is > 0.0
	#define DI_W float3(0.5,1.0,1.75)
	//#define FTM 1
    #define DG_Z 0.0125 //Min
    //#define DE_W 0.000 //Auto
    #define DI_Z 0.1125 //Trim
    #define DF_W float4(0.0001,0.00125,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.075
    //#define SMS 2            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.20       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.103 , 0.100 , 0.500 , 0.200 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.171 , 0.100 , 0.194 , 0.100 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.200 , 0.261 , 0.100 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 21.0, 21.0, 21.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.2855, 0.100 , 0.500 , 0.200 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.352 , 0.100 , 0.3765, 0.100 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.200 , 0.4435, 0.100 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 21.0, 21.0, 21.0, 21.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.468 , 0.100 , 0.500 , 0.200 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.535 , 0.100 , 0.559 , 0.100 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.200 , 0.6255, 0.100 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 21.0, 21.0, 21.0, 21.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.650 , 0.100 , 0.500 , 0.200 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.717 , 0.100 , 0.741 , 0.100 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.500 , 0.200 , 0.808 , 0.100 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 21.0, 21.0, 21.0, 21.0) //Tresh Hold for Color G & H and Color   
	
	#define WSM 4
	#define DB_W 6
	//#define DF_X float2(0.050,0.0)	
	//#define HMT 1
	//#define HMC 0.503

	//#define LBC 1 //Letter Box Correction With X & Y
	//#define LBS 1
    //#define DH_Z 0.0
    //#define DH_W -0.227
	#define PEW 1
	#define DSW 1
	#define FOV 1
#elif (App == 0x6DCAE83C ) //SnowRunner
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05
	//#define DF_Y 0.01
	#define DA_Y 20.0
    #define DA_Z -0.1
	#define DB_Z 0.100
 
	#define DE_X 3
	#define DE_Y 0.666
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W -0.25 //Neg PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.566,0.466,0.366) //Fix enables if Value is > 0.0
	#define DI_W float3(0.25,0.5,0.75)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.030
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.25   //De-Artifact
    //#define DL_Z 0.25       //Compat Power
	/*
    //#define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.500 , 0.705 , 0.040 , 0.860  )//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.5085, 0.738 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 0.0, 30.0, 18.0, 26.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.4475, 0.745 , 0.500 , 0.500 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.514 , 0.769 , 0.4475, 0.745 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.500 , 0.514 , 0.769 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 18.0, 18.0, 26.0, 26.0)   //Tresh Hold for Color A & B and Color
	//Welcome  to  Michigan!
    #define DP_X float4( 0.045 , 0.870 , 0.500 , 0.500 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.5085, 0.855 , 0.045 , 0.870 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.500 , 0.5085, 0.855 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 18.0, 30.0, 26.0)   //Tresh Hold for Color C & D and Color
	//Reading  Terrain  /  Watchtower Discovered  /  Repairing  the  Bridge
	#define DQ_X float4( 0.750 , 0.749 , 0.250 , 0.705 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.5085, 0.738 , 0.750 , 0.749 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.705 , 0.5085, 0.738 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 0.0, 18.0, 0.0, 26.0) //Tresh Hold for Color A1 & A3 and Color
	//Settings
	#define DR_X float4( 0.543 , 0.160 , 0.260 , 0.160 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.041 , 0.160 , 0.543 , 0.160 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.260 , 0.160 , 0.041 , 0.160 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 26.0, 26.0, 18.0, 18.0) //Tresh Hold for Color G & H and Color 

	//#define WSM 3
	//#define DB_W 12
	//#define DF_X float2(0.150,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0x967BB1CC ) //HROT
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.150
	#define DF_Y 0.015
	#define DA_Y 150.0
    //#define DA_Z 0.000
	#define DB_Z 0.075
 
	#define DE_X 6
	#define DE_Y 0.500
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W -0.125 //Neg PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.475,0.25) //Fix enables if Value is > 0.0
	//#define DI_W float2(0.0,2.5)
	//#define FTM 1
    //#define DG_Z 0.025 //0.0125 //Min
    //#define DE_W 0.000 //Auto
    //#define DI_Z 0.030 //Trim
	#define BMT 1
	#define DF_Z 0.040
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.25   //De-Artifact
    //#define DL_Z 0.25       //Compat Power

	#define WSM 2 //Weapon Settings Mode
	#define DB_W 11
	#define DF_X float2(0.075,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0x2BAF6411 ) //Sons of the Forest
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.05
	#define DF_Y 0.0
	#define DA_Y 45.0
    #define DA_Z 0.0 //0.000125
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.425
	//#define AFD 1
	#define DG_W 0.25 //Neg PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.550,0.3) //Fix enables if Value is > 0.0
	#define DI_W float2(0.75,2.5)
	//#define FTM 1
    #define DG_Z 0.025 //Min
    #define DE_W 0.250 //Auto
    #define DI_Z 0.060 //Trim
    #define DF_W float4(0.001,0.007,0.0,0.0) //Edge & Scale
	#define BMT 1
	#define DF_Z 0.100
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.275   //De-Artifact
    //#define DL_Z 0.500       //Compat Power
	//#define WSM 2 //Weapon Settings Mode
	//#define DB_W 11
	//#define DF_X float2(0.075,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
    #define DSW 1
    #define FOV 1
    #define NCW 1
#elif (App == 0x62454263 ) //Red Dead Redemption 2
	#define DA_W 1
	#define DA_X 0.05
	#define DF_Y 0.0375 //0.05 //0.10
	#define DA_Y 35.5
	 
	#define DE_X 1
	#define DE_Y 0.75
	#define DE_Z 0.4
	#define DG_W -0.5 //Neg PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.625,0.5,0.375,0.25) //Fix enables if Value is > 0.0
	#define DI_W float4(-0.25,0.0,0.5,1.0)
	#define BMT 1
	#define DF_Z 0.150
	#define DG_Z 0.030 //Min
    #define DI_Z 0.070 //Trim
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.375   //De-Artifact
    //#define DL_Z 0.125       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/


    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.867 , 0.9295, 0.397 , 0.085 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.927 , 0.9295, 0.867 , 0.9295) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.397 , 0.085 , 0.926 , 0.931 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.460 , 0.1179, 0.500 , 0.612 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.539 , 0.135 , 0.926 , 0.931 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.397 , 0.085 , 0.867 , 0.9295 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 27.0, 27.0, 30.0, 12.0)   //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.935 , 0.926 , 0.938 , 0.934 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.779 , 0.925 , 0.927 , 0.925 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.921 , 0.9285, 0.779 , 0.925 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.9375, 0.928 , 0.397 , 0.085 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.839 , 0.928 , 0.931 , 0.939 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.111 , 0.100 , 0.938 , 0.928 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color G & H and Color 

	//#define WSM 2 //Weapon Settings Mode
	//#define DB_W 11
	//#define DF_X float2(0.075,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define PEW 1
	#define DAA 1
	#define LBM 1
	#define DI_X 0.879
	#define DI_Y 0.120
#elif (App == 0x25B6C5BF ) //TinyKin
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0
	#define DA_Y 125.0
    //#define DA_Z 0.0 //0.000125
	#define DB_Z 0.1
 
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.400
	//#define AFD 1
	#define DG_W 0.25 //Neg PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.625,0.5,0.375) //Fix enables if Value is > 0.0
	#define DI_W float3(0.0,0.5,1.0)
	//#define FTM 1
    //#define DG_Z 0.025 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.060 //Trim
	#define BMT 1
	#define DF_Z 0.125 // 0.100
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	///* //This seems safe.....
    #define MAC 0
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.135, 0.113, 0.500 , 0.9065)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.865, 0.113 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26.0, 20.0, 26.0, 1000.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	//*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	#define DU_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color I & J and Color 
	*/
	//#define WSM 2 //Weapon Settings Mode
	//#define DB_W 11
	//#define DF_X float2(0.075,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
#elif (App == 0x357C7716 ) //Xash3D RT HL
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0165 //0.025 //0.05
	#define DF_Y 0.0125
	#define DA_Y 30.0 //27.5
    #define DA_Z 0.001 
	#define DB_Z 0.03
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.425
	//#define AFD 1
	#define DG_W 1.125 //0.75 //Neg PoP
    //#define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.50 //Fix enables if Value is > 0.0
	//#define DI_W 2.0
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
    #define DF_W float4(0.125,0.006,0.0,0.0) //Edge & Scale
	#define BMT 1
	#define DF_Z 0.05 // 0.100
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	//#define WSM 2 //Weapon Settings Mode
	//#define DB_W 11
	//#define DF_X float2(0.075,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	#define NFM 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xF6F3C763 ) //WRATH: Aeon of Ruin
	//#define DA_W 1
    #define DB_X 1
	#define DA_X 0.065
	#define DF_Y 0.0125
	#define DA_Y 75.0
    #define DA_Z 0.00005 
	#define DB_Z 0.090
 
	#define DE_X 4
	#define DE_Y 0.525
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 1.125 //0.75 //Neg PoP
    //#define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF 0.50 //Fix enables if Value is > 0.0
	//#define DI_W 2.0
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.1125
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	#define WSM 5
	#define DB_W 3
	#define DF_X float2(0.1,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
	//#define NFM 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.750      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x3D8A9B78 ) //Thief
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.100
	#define DF_Y 0.000
	#define DA_Y 17.5
    //#define DA_Z 0.00005 
	#define DB_Z 0.025
 
	#define DE_X 4
	#define DE_Y 0.875
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.25 //0.75 //Neg PoP
    //#define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.50 //Fix enables if Value is > 0.0
	#define DI_W 0.25
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	#define WSM 4
	#define DB_W 8
	//#define DF_X float2(0.1,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
	//#define NFM 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x60F43A2C ) //Resident Evil 4 Remake
    #define DS_Z 2
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0375
	#define DF_Y 0.0
	#define DA_Y 250.0
    //#define DA_Z 0.00005 
	#define DB_Z 0.0625
 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.425
	//#define AFD 1
	//#define DG_W -0.25 //0.75 //Neg PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.5,0.325,0.020,0.0175) //Fix enables if Value is > 0.0
	#define DI_W float4(0.75, 1.25,25.0,50.0)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define DL_Y -0.50   //De-Artifact
    #define DL_Z 0.50       //Compat Power
	#define DJ_X 0.214       //Range Smoothing
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/
	#define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.410 , 0.114 , 0.034 , 0.102 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.415 , 0.114 , 0.410 , 0.114 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.934 , 0.902 , 0.415 , 0.114 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
	
    #define DP_X float4( 0.541 , 0.114 , 0.034 , 0.102 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.546 , 0.114 , 0.541 , 0.114 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.934 , 0.902 , 0.546 , 0.114 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 8
	//#define DF_X float2(0.1,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	#define NFM 1
	#define RHW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xC4773871 ) //Octopath Traveler II
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.100
	#define DF_Y 0.010
	#define DA_Y 250.0
    #define DA_Z -0.000375
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 0.1 //0.75 //Neg PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4( 0.4,0.375,0.25,0.2) //Fix enables if Value is > 0.0
	#define DI_W float4(0.5,1.5,2.0,3.0)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 8
	//#define DF_X float2(0.1,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
	//#define NFM 1
	#define RHW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x47F294E9 ) //Octopath Traveler ****
	#define DA_Y 250.0
	#define DA_Z 0.000375
	#define DA_X 0.1175
	#define DA_W 1
	 
	#define DE_X 1
	#define DE_Y 0.5625
	#define DE_Z 0.325
	#define DG_W 0.2125
	#define RHW 1
#elif (App == 0xFC94D8E3 ) //Triangle Strategy
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.100
	#define DF_Y 0.000
	#define DA_Y 250.0
    #define DA_Z 0.000125
	#define DB_Z 0.025
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 0.1 //0.75 //Neg PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3( 0.625, 0.5, 0.0125)//float4( 0.4,0.375,0.25,0.2) //Fix enables if Value is > 0.0
	#define DI_W float3(0.5, 1.0, 3.5)//float4(0.5,1.5,2.0,3.0)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.100
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	
    #define MAC 1                //0.0212
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.0455, 0.887 , 0.035, 0.0905)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.0455, 0.0285,  0.0, 0.0)    //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 5.0, 20.0, 5.0, 4.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	//0.0425 , 0.890 18
	//0.0415 , 0.891 14
	//0.0455 , 0.8965 19
	//0.0455 , 0.885 20 27
	//0.0455 , 0.887 5 28
	//0.04462, 0.020 5
    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 1 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.310 , 0.272 , 0.500 , 0.296 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.690 , 0.389 , 0.303 , 0.311 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.372 , 0.575 , 0.697 , 0.689 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 18.0, 18.0)   //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.303 , 0.311 , 0.372 , 0.638 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.697 , 0.689 , 0.1625, 0.651 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.651 , 0.8375, 0.651 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 18.0, 18.0, 29.0, 29.0)   //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.268 , 0.122 , 0.745 , 0.500 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.7315, 0.878 , 0.035 , 0.0905 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.275 , 0.04462, 0.020 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 18.0, 18.0, 20.0, 18.0) //Tresh Hold for Color A1 & A3 and Color
	/*							
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 8
	//#define DF_X float2(0.1,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
	//#define NFM 1
	#define RHW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x399E2A74 ) //Blacktail
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.02625
	#define DF_Y 0.001
	#define DA_Y 21.0
    //#define DA_Z -0.000375
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W 2.5 //Neg PoP
    //#define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float4( 0.4,0.375,0.25,0.2) //Fix enables if Value is > 0.0
	//#define DI_W float4(0.5,1.5,2.0,3.0)
	//#define FTM 1
    #define DG_Z 0.05 //Min
    //#define DE_W 0.250 //Auto
    #define DI_Z 0.100//Trim
    #define DF_W float4(0.0001,0.002,0.0,0.0) //Edge & Scale
	#define BMT 1
	#define DF_Z 0.15
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.4975 , 0.9636, 0.525 , 0.032)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.3084, 0.949 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 1.0, 2.0, 17.0, 18.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/


    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.500 , 0.021 , 0.045 , 0.441 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.510 , 0.920 , 0.500 , 0.103 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.856 , 0.500 , 0.8874 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 6.0, 6.0, 6.0, 13.0)   //Tresh Hold for Color A & B and Color
	
    #define DP_X float4( 0.500 , 0.103 , 0.500 , 0.856 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.500 , 0.8874, 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 6.0, 12.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 8
	//#define DF_X float2(0.1,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	#define PEW 1
	//#define NFM 1
	//#define RHW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x289ABD5C ) //World Rally Championship 10
	#define DA_W 1
	#define DA_Y 20.5
	//#define DA_Z 0.000075
	#define DA_X 0.1375
	#define DF_Y 0.03
	 
	#define DE_X 1
	#define DE_Y 0.055
	#define DE_Z 0.4875
	#define WSM 2
	#define DB_W 5
	#define DF_X float2(0.125,0.0)
	#define PEW 1
	#define DAA 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x6CF6FBAE ) //WRC Generations
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.1375
	#define DF_Y 0.010
	#define DA_Y 20.5
    //#define DA_Z -0.000375
	#define DB_Z 0.100
 
	#define DE_X 4
	#define DE_Y 0.5
	#define DE_Z 0.475
	//#define AFD 1
	//#define DG_W 2.0 //Neg PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.055,0.05) //Fix enables if Value is > 0.0
	#define DI_W float2(1.0,2.0)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.0375
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	///*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.310 , 0.422 , 0.920 , 0.880)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.699 , 0.546 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 30.0, 1000.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	//*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.187 , 0.125 , 0.500 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.276 , 0.335 , 0.115 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.100 , 0.260 , 0.087 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	#define WSM 2
	#define DB_W 5
	#define DF_X float2(0.050,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	#define NFM 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x17232880 || App == 0x9D77A7C4 || App == 0x22EF526F )	//CoD:Black Ops | CoD:MW2 |CoD:MW3
    //#define DS_Z 0
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.045
	#define DF_Y 0.00
	#define DA_Y 12.5
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 4
	#define DE_Y 0.75
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.25 //Neg PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.5 //Fix enables if Value is > 0.0
	#define DI_W 0.0
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.1375
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	//#define WSM 2
	#define DB_W 9
	#define DF_X float2(0.150,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	//#define NFM 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xD691718C )	//CoD:Black Ops II
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.05
	#define DF_Y 0.00
	#define DA_Y 12.5
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.325
	//#define AFD 1
	#define DG_W -0.30 //Neg PoP
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.350 //Fix enables if Value is > 0.0
	#define DI_W 0.75
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.150
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	//#define WSM 2
	#define DB_W 10
	#define DF_X float2(0.175,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	//#define NFM 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x73FA91DC || App == 0xDE69E9A9 )	//CoD: Black Ops IIII
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.10
	#define DF_Y 0.00
	#define DA_Y 22.5
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 4
	#define DE_Y 0.600
	#define DE_Z 0.350
	//#define AFD 1
	#define DG_W -0.25 //Neg PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.350,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.5,2.0)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.150
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	//#define WSM 2
	#define DB_W 16
	#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	//#define NFM 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xA0A387D1 )	//Sonic the Hedgehog 2006 Fan Remake
    //#define DS_Z 0
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.00
	#define DA_Y 50.0
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.500
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 1.5 //Neg PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.375,0.25,0.125) //Fix enables if Value is > 0.0
	#define DI_W float3(0.75,1.5,2.25)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.1
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
    #define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.9       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x147C5D2A )	//Steelrising
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0625
	#define DF_Y 0.00
	#define DA_Y 25.0
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.550
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 1.5 //Neg PoP
    //#define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float3(0.375,0.25,0.125) //Fix enables if Value is > 0.0
	//#define DI_W float3(0.75,1.5,2.25)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.1
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	///*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.0850, 0.8781, 0.342 , 0.470)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.350 , 0.5205,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.37, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 27.0, 2.0, 27.0, 1000.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	//*/

    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.0475, 0.500 , 0.485 , 0.961 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.0420, 0.600 , 0.0475, 0.500 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.470 , 0.961 , 0.0420, 0.600 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 21.0, 25.0, 21.0) //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.499 , 0.5035, 0.500 , 0.025 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.500 , 0.4050, 0.0475, 0.499 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.507 , 0.961 , 0.0475, 0.440 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 25.0, 22.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.500 , 0.531 , 0.500 , 0.030 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.500 , 0.595 , 0.500 , 0.026 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.489 , 0.961 , 0.450 , 0.026 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 28.0, 25.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.500 , 0.026 , 0.550 , 0.961 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.450 , 0.026 , 0.500 , 0.026 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.747 , 0.980 , 0.450 , 0.026 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 28.0, 25.0, 28.0, 25.0) //Tresh Hold for Color G & H and Color 
	//#define WSM 2
	//#define DB_W 16
	//#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	#define DAA 1
	#define PEW 1
	//#define NFM 1
    //#define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.9       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xB630F51B )	//Deliver Us Mars
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.030
	#define DF_Y 0.005
	#define DA_Y 75.0
    //#define DA_Z -0.000375
	#define DB_Z 0.050
 
	//#define DE_X 1
	//#define DE_Y 0.500
	//#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 1.5 //Neg PoP
    //#define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float3(0.375,0.25,0.125) //Fix enables if Value is > 0.0
	//#define DI_W float3(0.75,1.5,2.25)
	//#define FTM 1
    #define DG_Z 0.0625//0.1 //Min
    //#define DE_W 0.250 //Auto
    #define DI_Z 0.1//Trim
    #define DF_W float4(0.001,0.0025,0.0,0.0) //Edge & Scale
	#define BMT 1
	#define DF_Z 0.130
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.380 , 0.175 , 0.500 , 0.975 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.9605, 0.176 , 0.599 , 0.068 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.975 , 0.057 , 0.168 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0, 30.0, 27.0, 29.0) //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 2
	//#define DB_W 16
	//#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	#define PEW 1
	//#define NFM 1
    //#define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x16129A48 )	//Narvle's Midnight Suns
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0375
	#define DF_Y 0.005
	#define DA_Y 30.0
    //#define DA_Z -0.000375
	#define DB_Z 0.10
 
	#define DE_X 1
	#define DE_Y 0.7
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W 1.0 //Neg PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.6,0.5,0.375,0.25) //Fix enables if Value is > 0.0
	#define DI_W float4(0.5,0.75,1.25,2.5)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	//#define FMM 1
	///*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.467, 0.086 , 0.500 , 0.03)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.536 , 0.086 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 25.0, 0.0, 25.0,100.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	//*/
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //English / German
    #define DO_X float4( 0.280 , 0.0165, 0.015 , 0.025 ) //Pos A1 = XY Color & A2 = ZW Black
    #define DO_Y float4( 0.7115, 0.0165, 0.265 , 0.021 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.985 , 0.025 , 0.7165, 0.016 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 23.0, 23.0, 23.0, 23.0) //Tresh Hold for Color A & B and Color
    //Spanish
    #define DP_X float4( 0.280 , 0.0165, 0.015 , 0.025 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.7205, 0.0165, 0.286 , 0.016 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.985 , 0.025 , 0.718 , 0.0165) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 23.0, 23.0, 23.0, 23.0) //Tresh Hold for Color C & D and Color
	//Chinese Simple & Korean
	#define DQ_X float4( 0.2925, 0.0155, 0.985 , 0.025 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.7225, 0.0165, 0.2835, 0.0165 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.985 , 0.025 , 0.7085, 0.0165) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 23.0, 23.0, 23.0, 23.0) //Tresh Hold for Color A1 & A3 and Color
	//Japaniese / Korean / German
	#define DR_X float4( 0.293 , 0.0175, 0.015 , 0.025 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.7235, 0.0175, 0.2885, 0.0165) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.985 , 0.025 , 0.7255, 0.0175) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 23.0, 23.0, 23.0, 23.0) //Tresh Hold for Color G & H and Color 
	//#define WSM 2
	//#define DB_W 16
	//#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
	//#define NFM 1
    //#define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x42EE662D )	//Gotham Knights
    //#define DS_Z 0
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.071
	#define DF_Y 0.005
	#define DA_Y 25.0
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.700
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.05 //Neg PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.55,0.35,0.25,0.075) //Fix enables if Value is > 0.0
	#define DI_W float4(0.375,0.5,1.5,2.5)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.025
    #define DL_Y -0.300   //De-Artifact
    #define DL_Z 0.25       //Compat Power
	///* //Should work on all Languages.
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.490 , 0.325 , 0.650 , 0.175)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.832 , 0.325 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 30.0, 1000.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	//*/
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    // English | French | Spanish Spain | German | Italian | Spanish Mexico | Brazil Portu    
	// Polski | Chinese A | Chinese B | Korean 
    #define DO_X float4( 0.087 , 0.097 , 0.057 , 0.185 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.188 , 0.130 , 0.089 , 0.098 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.057 , 0.185 , 0.1435, 0.1355) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	// Japanese
	#define DP_X float4( 0.087 , 0.103 , 0.057 , 0.185 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.225 , 0.133 , 0.0, 0.0 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.0, 0.0,  0.0, 0.0 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	// Tutorial Pop Up All are close and Isolated I am worried it will Trigger.
	#define DQ_X float4( 0.200 , 0.100 , 0.200, 0.075 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.211 , 0.090,  0.0, 0.0 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.0, 0.0,  0.0, 0.0 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 17.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	// Social | English | French | Spanish Spain | German | Italian | Spanish Mexico | Brazil Portu | Polski
	// Social | Chinese A | Chinese B | Korean | Japanese
	#define DR_X float4( 0.087 , 0.090 , 0.057 , 0.171 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.155 , 0.117 , 0.092 , 0.096 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.057 , 0.171 , 0.133 , 0.101 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color G & H and Color 
	
	//#define WSM 2
	//#define DB_W 16
	//#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
	//#define NFM 1
    #define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.9       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xB097DD6F )	//The Last of Us Part 1
    #define DS_Z 2
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.06
	#define DF_Y 0.00
	#define DA_Y 8.0
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.375
	//#define AFD 1
	#define DG_W -0.25
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.25,1.5)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.125
    //#define DL_Y -0.50   //De-Artifact
    #define DL_Z 0.500       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 2
	//#define DB_W 16
	//#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
    #define RHW 1
	#define NFM 1
    #define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.9       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x446E2223 )	//Uncharted: Legacy of Thieves Collection; Uncharted: The Lost Legacy / Steam | 
    //#define DS_Z 2
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.06
	#define DF_Y 0.00
	#define DA_Y 7.0
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.550
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W -0.25
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	//#define DI_W float2(0.25,1.5)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.05
    //#define DL_Y -0.50   //De-Artifact
    #define DL_Z 1.00       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 2
	//#define DB_W 16
	//#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	#define BDF 1    //Barrel Distortion Fix k1 k2 k3 and Zoom
	#define DC_X 0.00
	#define DC_Y 0.115
	#define DC_Z 0.000
	#define DC_W -0.035
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
    #define RHW 1
	#define NFM 1
    #define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.9       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
	#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xB5674D0C )	//Uncharted: Legacy of Thieves Collection; Uncharted 4 / Steam | 
    //#define DS_Z 2
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.06
	#define DF_Y 0.00
	#define DA_Y 7.0
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 1
	#define DE_Y 0.550
	#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W -0.25
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	//#define DI_W float2(0.25,1.5)
	//#define FTM 1
    //#define DG_Z 0.03 //Min
    //#define DE_W 0.250 //Auto
    //#define DI_Z 0.05//Trim
	#define BMT 1
	#define DF_Z 0.05
    //#define DL_Y -0.50   //De-Artifact
    #define DL_Z 0.750       //Compat Power
	/*
    #define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954)//Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0);     //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	*/

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 2
	//#define DB_W 16
	//#define DF_X float2(0.1375,0.0)
	//#define DJ_W 0	
	//#define HMT 1
	//#define HMC 2.5
    //#define HMD 0.350
	//#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define DH_Z 0.0
	//#define DH_W -0.237
	//#define BDF 1    //Barrel Distortion Fix k1 k2 k3 and Zoom
	//#define DC_X 0.00
	//#define DC_Y 0.115
	//#define DC_Z 0.000
	//#define DC_W -0.035
	//#define FMM 1
	//#define DAA 1
	//#define PEW 1
    #define RHW 1
	#define NFM 1
    #define DSW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.9       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x1BDC0C4C || App == 0x85D2106D  || App == 0x29B72DA0 || App == 0xD9E005D8 ) //Quake Enhanced Edition //Steam //Epic //Windows Games Store //GOG
	#define DA_X 0.05//0.075
    #define DF_Y 0.035
	#define DA_Y 20.0 //12.5
    #define DA_Z-0.0010
	#define DB_Z 0.0625
 
	#define DE_X 6
	#define DE_Y 0.750 //0.500
	#define DE_Z 0.400
	#define DG_W -0.125 //disallowed popout
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.500 //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W 0.25 //float2(1.5,7.0)
	#define BMT 1
	#define DF_Z 0.066
	#define NDW 1
	#define PEW 1
	#define DF_X float2(0.1625,0.0)
	#define DJ_W 0.0
	#define WSM 3
	#define DB_W 20
	//Smooth Mode Setting
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
#elif (App == 0x60F440F8 ) //Resident Evil Village
	#define DA_W 1
	//#define DA_Z 0.0004 //-0.65
	#define DA_X 0.0625 //0.075 //0.050
    #define DF_Y 0.075
	#define DA_Y 65.0 //50.0 //85.0	
	 
	#define DE_X 3
	#define DE_Y 0.500
	#define DE_Z 0.400
	#define DG_W 0.425 //0.725 //Only Detect stuff past the screen.
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.375,0.125) //Fix enables if Value is > 0.0
	#define DI_W float2(1.0,3.0)        
	//#define FTM 1
	#define BMT 1    
	#define DF_Z 0.120
    #define DG_Z 0.025//0.040 //Min
    #define DI_Z 0.125 //0.1375 //Trim
    #define DF_W float4(0.001,0.0015,0.0,0.0)  //Edge & Scale
    //#define DL_Y 0.375    //De-Artifact
    //#define DL_Z 0.125       //Compat Power
	#define DJ_X 0.178       //Range Smoothing
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.404, 0.346,  0.000, 0.575)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.5491, 0.4225,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 27.0, 1.0, 22.0,1000.0);            //Menu Detection Type for A, B, & C. The Last Value is ???   
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	#define RHW 1
	#define PEW 1
	#define DAA 1
	//Smooth Mode Setting
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.925 //SM Tune
	//#define DL_W 0.050  //SM Perspective
	#define DM_X 2     //HQ Tune
    //#define DM_Y 3     //HQ VRS
 #elif (App == 0xB52D823E ) //ThymeSia
    #define DS_Z 2
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.07//0.05
	//#define DF_Y 0.0025
	#define DA_Y 26.0//37.0 //40.0 //35.0
    //#define DA_Z -0.030
	#define DB_Z 0.100
 
	#define DE_X 1
	#define DE_Y 0.400
	#define DE_Z 0.400
	//#define DG_W 0.2//PoP
    #define OIF 0.200 //Fix enables if Value is > 0.0
	#define DI_W 1.5
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
	#define BMT 1
	#define DF_Z 0.025//0.050 //0.125
    //#define DL_Y 0.400       //De-Artifact
    #define DL_Z 0.125       //Compat Power
	#define DJ_X 0.071       //Range Smoothing
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.451 , 0.0975, 0.500 , 0.120 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.891 , 0.048 , 0.470 , 0.0975 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.120 , 0.891 , 0.048 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.488 , 0.0975, 0.500 , 0.120 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.891 , 0.048 , 0.507 , 0.0975) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.120 , 0.109 , 0.048 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.526 , 0.0975, 0.500 , 0.120 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.109 , 0.048 , 0.545 , 0.0975) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.120 , 0.109 , 0.048 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.049 , 0.113 , 0.020 , 0.030 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.117 , 0.090 , 0.046 , 0.084 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.500 , 0.084 , 0.080 , 0.239 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 29.0, 29.0, 29.0, 30.0) //Tresh Hold for Color G & H and Color 
	#define FMM 1 // Anti Flicker
    #define PEW 1
    #define FOV 1
	//Smooth Mode Setting
	//#define SMS 1            //SM Toggle Separation
	#define DL_X 0.875       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 2           //HQ Tune
    #define DM_Y 0           //HQ VRS
#elif (App == 0x920D5D88 ) //Graven
    //#define DS_Z 2
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0625
	#define DF_Y 0.00
	#define DA_Y 110.0
	#define DA_Z 0.00005
	#define DB_Z 0.075
 
	//#define DE_X 1
	//#define DE_Y 0.550
	//#define DE_Z 0.375
	//#define AFD 1
	//#define DG_W -0.25
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	//#define DI_W float2(0.25,1.5)
	//#define FTM 1
    #define DG_Z 0.175//0.200 //Min
    //#define DE_W 0.125 //Auto
    #define DI_Z 0.225//0.225//Trim
    #define DF_W float4(0.125,0.0005,0.0,0.0) //Edge & Scale
	#define BMT 1
	#define DF_Z 0.0375
    //#define DL_Y -0.50   //De-Artifact
    //#define DL_Z 0.750       //Compat Power
	#define WSM 3
	#define DAA 1
	#define PEW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
	//#define DM_Z 0           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0x57D5CF77 )	//Demonologist
    //#define DS_Z 2
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.01625
	#define DF_Y 0.0125
	#define DA_Y 30.0
    //#define DA_Z -0.000375
	#define DB_Z 0.05
 
	#define DE_X 2
	#define DE_Y 0.700
	#define DE_Z 0.375
	#define DG_W 0.250
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	//#define DI_W float2(0.25,1.5)
	//#define FTM 1
    #define DG_Z 0.100 //0.0375//Min
    //#define DE_W 0.250 //Auto
    #define DI_Z 0.04375//0.0375//Trim
    #define DF_W float4(0.001,0.001,0.0,0.0) //Edge & Scale
	#define BMT 1
	#define DF_Z 0.125
	#define DAA 1
    #define NDW 1
	#define PEW 1
    #define RHW 1
	//Smooth Mode Setting
    //#define SMS 3           //SM Toggle Separation
	#define DL_X 0.9125       //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 0           //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0xB53B8500 ) //DEATH STRANDING
	#define DA_W 1
	#define DA_Y 17.5
	#define DA_Z 0.000375
	#define DA_X 0.05
	//#define DB_Z 0.125
	#define DF_Y 0.01
	#define DE_X 1
	#define DE_Y 0.550
	#define DE_Z 0.375
	//#define DG_W 0.250
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.350,0.250) //Fix enables if Value is > 0.0
	#define DI_W float2(1.0,2.5)
	#define BMT 1
	#define DF_Z 0.100
    #define DL_Y -0.375   //De-Artifact
    #define DL_Z 0.50     //Compat Power
	#define PEW 1
	#define DAA 1
	//Smooth Mode Setting
    //#define SMS 3
	#define DL_X 0.90
	//#define DL_W 0.5
	#define DM_X 2
    //#define DM_Y 3	
#elif (App == 0xC5A76A71 ) //The Turing Test
	#define DA_W 1
    #define DA_X 0.0246
    #define DF_Y 0.0475
	#define DA_Y 37.5
    #define DA_Z 0.001
	#define DB_Z 0.025
	#define DE_X 1
	#define DE_Y 0.925
	#define DE_Z 0.250
	#define DG_W 2.25//PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.8875,0.85) //Fix enables if Value is > 0.0
	#define DI_W float2(2.5,3.0)
	#define BMT 1    
	#define DF_Z 0.025//0.110
	#define DG_Z 0.045//0.0875//Min
	#define DE_W 0.30//0.160 //Max
    #define DI_Z 0.07//0.150 //Trim
    #define DF_W float4(0.0001,0.0075,0.0,0.0) //Edge & Scale
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	#define DL_W 0.5       //SM Perspective
	#define DM_X 1           //HQ Tune
	#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS
	#define PEW 1           
	#define FOV 1
#elif (App == 0x982FFA35 ) //Ghostwire: Tokyo
	#define DA_W 1
	#define DA_X 0.0246
	#define DF_Y 0.025
	#define DA_Y 63.75
    #define DB_Z 0.025
//	 
	#define DE_X 4
	#define DE_Y 0.925
	#define DE_Z 0.375
    #define DG_W 0.5 //Pop
	#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.875,0.75) //Fix enables if Value is > 0.0
	#define DI_W float2(1.0,1.5)
    #define DF_W float4(0.0001,0.005,0.0,0.0) //Edge & Scale
    #define DG_Z 0.03//0.040 //Min
	#define DE_W 0.250 //Max
    #define DI_Z 0.075//0.055 //Trim
	#define BMT 1
	#define DF_Z 0.025
  //In Game Tool Tip 0.629 , 0.428 | 0.590 , 0.500 |  0.629 , 0.9435
    #define MDD 2 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.629 , 0.428 , 0.590 , 0.500) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.629 , 0.9435,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.5825, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 1.0, 30.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 3 //Set Multi Menu Detection             //Off / On 1 - 4
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //In Game Main Menu / Options menu
    #define DO_X float4( 0.900 , 0.066 , 0.010 , 0.810 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.010 , 0.970 , 0.0465, 0.875 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.047 , 0.125 , 0.050 , 0.093 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 17.0, 30.0, 17.0) //Tresh Hold for Color A & B and Color
	//Missions Map Database / Main Menu
    #define DP_X float4( 0.0633, 0.094 , 0.275 , 0.080 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.265 , 0.094 , 0.663 , 0.490 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.500 , 0.935 , 0.490 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color C & D and Color
	//Load Game / Missions Map Skills Database 
	#define DQ_X float4( 0.4705, 0.927 , 0.485 , 0.940 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.5312, 0.952 , 0.0633, 0.094 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.339 , 0.080 ,0.329 , 0.094) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color
	//????
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 

	#define WSM 3
	#define DB_W 27
	#define PEW 1
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.825       //SM Tune
	#define DL_W 0.05       //SM Perspective
	#define DM_X 1           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS
	#define DAA 1           
	#define PEW 1
#elif (App == 0x3C8DE8E8 ) //Metro Exodus
	#define DA_W 1                   
	#define DA_X 0.021//0.025   
	#define DF_Y 0.010       
	#define DA_Y 22.5 //12.5     
    #define DA_Z 0.00005    
	#define DB_Z 0.025      
	#define DE_X 2          
	#define DE_Y 0.875      
	#define DE_Z 0.375      
	#define DG_W 2.5      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 0           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF 0.5         // Fix enables if Value is > 0.0 
	//#define DI_W 0.5        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0         
    #define DG_Z 0.050      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    #define DI_Z 0.125      // Trim
    #define DF_W float4(0.0001,0.005,0.0,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.045      // Set the Balance  
    #define DL_Y -0.5      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power
	#define DJ_X 0.178      // Range Smoothing
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.459 , 0.275 , 0.0825, 0.150 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.459 , 0.725 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
*/
	//#define WSM 5           // Weapon Setting Mode 
	//#define DB_W 8         // Weapon Profile
	//#define DF_X float2(0.150,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.2	        // Weapon Depth Limit Location
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	#define DL_W 0.125       //SM Perspective
	#define DM_X 3           //HQ Tune
	//#define HQT 1           //HQ Trigger
    #define DM_Y 0     //HQ VRS
	#define DAA 1           
	#define PEW 1
	#define FOV 1
#elif (App == 0x312862CF ) //Aliens: Fireteam Elite
	#define DA_W 1
	#define DA_X 0.050
	#define DF_Y 0.01
	#define DA_Y 25.00
	//#define DA_Z -0.0125
	#define DE_X 1
	#define DE_Y 0.625
	#define DE_Z 0.375 //adjusted to make it react faster.
	//#define DG_W 0.250
    #define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.375,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float2(1.5,2.5)        // Like Shift Boundary DG_W But 0 to inf
	//#define DG_Z 0.07  //Added to fix super close to cam issues.
	//#define DI_Z 0.10  //The cutoff for above value.
	#define BMT 1      //Added to override auto depth
	#define DF_Z 0.0125 //Locked adjusted value.
	#define NDW 1
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	#define DL_W 0.100       //SM Perspective
	#define DM_X 3           //HQ Tune
	//#define HQT 1           //HQ Trigger
    #define DM_Y 0     //HQ VRS           
	#define PEW 1
#elif (App == 0xFE7D9E7E ) //Scorn
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0125//0.015
	#define DF_Y 0.025 //0.0375
	#define DA_Y 300.0 //200.0
    #define DA_Z 0.0001
	#define DB_Z 0.010
	#define DE_X 1
	#define DE_Y 0.875
	#define DE_Z 0.400
	#define DG_W 1.75 //PoP
    #define OIF 0.250 //Fix enables if Value is > 0.0
	#define DI_W 5.0
	//#define FTM 1
    #define DG_Z 0.01875//0.02//0.015 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.025//0.02//0.050 //Trim
    #define DF_W float4(0.001,0.0055,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.07
    //#define DL_Y 0.375    //De-Artifact 0.1245
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define DO_X float4( 0.415 , 0.882 , 0.250  , 0.882  ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.55  , 0.882 , 0.000 , 0.000  ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000, 0.000  ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0  , 30.0  , 1000.0, 1000.0 )   //Tresh Hold for Color A & B and Color
	#define DP_X float4( 0.075 , 0.150 ,  0.235  , 0.840) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.350 , 0.241 ,  0.736  , 0.575) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.060 , 0.380 ,  0.286  , 0.195) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0  , 30.0  ,  30.0   , 14.0) //Tresh Hold for Color A1 & A3 and Color
	*/
    #define FOV 1
    #define PEW 1
    #define RHW 1
	//Smooth Mode Setting
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.777 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
    //#define DM_Y 3     //HQ VRS
#elif (App == 0x13BD25A9 ) //Star Wars Jedi: Survivor 
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.010
	#define DA_Y 50.0
    //#define DA_Z 0.001
	#define DB_Z 0.1
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define DG_W -0.100 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.325,0.10) //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W float3(0.5,1.5,7.5)  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
    #define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.118 , 0.080 , 0.500 , 0.720 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.069 , 0.412 , 0.234 , 0.080 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.155 , 0.379 , 0.064 , 0.195 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 25.0, 25.0, 25.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	//#define RHW 1
	//#define NDW 1
	//#define SPF 1
	//#define DD_W -0.240
	//#define LBM 1
	//#define DI_X 0.879
	//#define DI_Y 0.120
	#define LBC 1  //Letter Box Correction Offsets With X & Y
	//#define LBR 0
	#define LBE 1
	//#define DH_Z 0.0
	#define DH_W -0.2375
	#define BMT 1
	#define DF_Z 0.0125
	//Smooth Mode Setting
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.900      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
    #define DM_Y 0           //HQ VRS
#elif (App == 0xFF64489D ) //Five Night's At Freddy's: Security Breach
	#define DA_W 1
	#define DA_X 0.03//0.025
	#define DF_Y 0.010
	#define DA_Y 27.5//40.0
	#define DB_Z 0.020
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.400
	//#define DG_W 0.500 //Pop
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.625,0.5,0.375,0.3)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,1.5,2.0)        // Like Shift Boundary DG_W But 0 to inf
	
   // #define DG_Z 0.07 //Min
   // #define DI_Z 0.05 //Trim
	#define BMT 1
	#define DF_Z 0.025 //0.2506 0.0954 0.420 0.0951-0.09515
	//Tab for Watch in game menu | All Languages at 4K
    #define MDD 1 //Set Menu Detection & Direction    //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.2506, 0.0954,  0.500 , 0.1375) //Pos A = XY White & B = ZW Dark 
    #define DN_Y float4( 0.420 , 0.09515,  0.0   , 0.0   ) //Pos C = XY White & D = ZW Match
    #define DN_Z float4( 0.0   , 0.0   ,  0.0   , 0.0   ) //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0   , 0.0   ,  0.0   , 0.0   ) //Size = Menu [ABC] D E F
    #define DJ_Y float4( 19.0 , 5.0, 19.0, 30.0);           //Menu Detection Type   
    #define DJ_Z float3( 1000, 1000, 1000);           //Set Match Tresh 1000 is off
	#define WSM 2
	#define DB_W 15
    #define MMD 4 //Set Multi Menu Detection              //Off / On
	//In-game Options Menu | English | French | Portuges | Russian
    #define DO_X float4( 0.125 , 0.348 ,  0.100  , 0.125   ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.233 , 0.390 ,  0.000  , 0.000   ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 ,  0.000  , 0.000   ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 19.0  , 30.0  ,  1000.0 , 1000.0  ) //Tresh Hold for Color A1 & A3 and Color 
	//In-Game Video | English | French | German | Italian | Portuges | Spanish
	//In-Game Pause | English | French | German | Italian | Portuges | Russian | Spanish
    #define DP_X float4( 0.140 , 0.049 , 0.500 , 0.200 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.221 , 0.092 , 0.400 , 0.227 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.200 , 0.500 , 0.310 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 19.0, 30.0, 19.0, 30.0) //Tresh Hold for Color C & D and Color
	//In-Game Inventory A | English | French
	//In-Game Inventory B | German | Italian | Portuges | Russian | Spanish 
	#define DQ_X float4( 0.200 , 0.051 , 0.500 , 0.150 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.210 , 0.094 , 0.200 , 0.051 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.150 , 0.215 , 0.095 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 19.0, 30.0, 19.0, 30.0) //Tresh Hold for Color A1 & A3 and Color
	//In-Game Inventory C | Asian Languages
	#define DR_X float4( 0.200 , 0.051 , 0.500 , 0.150 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.235 , 0.095 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	
    //#define AFD 1
	//Smooth Mode Setting    
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.875 //0.775 //SM Tune
	//#define DL_W 0.05 //SM Perspective
	#define DM_X 4     //HQ Tune
#elif (App == 0xBE672B63 ) //Grounded
	#define DA_W 1
	#define DA_X 0.025
	#define DF_Y 0.020
	#define DA_Y 40.0 //37.5 //50.0
    #define DB_Z 0.025 
	#define DE_X 2
	#define DE_Y 0.900
	#define DE_Z 0.375
	#define DG_W 0.625 //Pop
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.80,0.75,0.60) // Fix enables if Value is > 0.0 
	#define DI_W float3(0.75,1.0,1.25) // Like Shift Boundary DG_W But 0 to inf
    #define DG_Z 0.04//0.024//0.080 //Min
    #define DI_Z 0.06//0.100 //Trim
	#define BMT 1
	#define DF_Z 0.100
	// Only for Night and Day
    //#define MAC 1
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.1625, 0.313 , 0.188 , 0.491)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.1625, 0.6685,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.205, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 20.0, 0.0, 20.0, 15.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	//Since in Game has OS Skins I had to prioritize the defaults// If you find one in game Well good luck setting it here. 
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
	// Multi Lingo Options  / Classic | Night | High Contrast | LCD for Display
    #define DO_X float4( 0.0575, 0.061 , 0.500 , 0.043 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.343 , 0.156 , 0.0575, 0.061 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.043 , 0.343 , 0.156 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 14.0, 23.0, 19.0) //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.0575, 0.061 , 0.500 , 0.043 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.343 , 0.156 , 0.0575, 0.061 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.043 , 0.343 , 0.156 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 29.0, 17.0, 24.0, 15.0) //Tresh Hold for Color C & D and Color
	//In game Invetory Status Craft Map Quest Data OS //  Lay out Default / Night | Day | High Contrast | LCD
	#define DQ_X float4( 0.7935, 0.050 , 0.718 , 0.080 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.8635, 0.050 , 0.7935, 0.050 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.718 , 0.080 , 0.8635, 0.050 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 12.0, 16.0, 17.0, 18.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.7935, 0.050 , 0.718 , 0.080 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.8635, 0.050 , 0.7935, 0.050 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.718 , 0.080 , 0.8635, 0.050 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 15.0, 21.0, 12.0, 23.0) //Tresh Hold for Color G & H and Color 
	#define PEW 1
	#define NDW 1
	//Smooth Mode Setting  
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.925 //SM Tune
	#define DL_W 0.025 //SM Perspective
	#define DM_X 3     //HQ Tune
#elif (App == 0xC06FE818 ) //BorderLands 3
    #define DS_Z 2          // Set View Mode
	#define DA_W 1
	#define DA_Y 15.0
	#define DA_X 0.030//0.036
	#define DF_Y 0.041
	#define DB_Z 0.05
    #define DS_Y 1
	#define DA_Z -1.0 

	#define DE_X 5
	#define DE_Y 0.75
	#define DE_Z 0.300
	#define DG_W 1.25   //Pop out

	#define BMT 1    
	#define DF_Z 0.0125
	#define DG_Z 0.070 //Min
	#define DE_W 0.500 //Auto
	#define DI_Z 0.100 //Trim
    #define DF_W float4(0.0001,0.0025,0.0,0.0)// Edge & Scale	
	#define DB_W 5
	#define DF_X float2(0.085,0.0)
	#define NDW 1
	#define DAA 1
	//Smooth Mode Setting  
	#define SMS 2 //SM Toggle Separation
	#define DL_X 0.75 //SM Tune
	#define DL_W 0.0 //SM Perspective
	#define DM_X 4     //HQ Tune
#elif (App == 0x2D1A3028 ) //Bright Memory: Infinite
    #define DA_W 1
    #define DA_X 0.105 
    #define DF_Y 0.100
    #define DA_Y 55.0 //52.5//53.00
    #define DB_Z 0.100
    //#define DE_X 2
    //#define DE_Y 0.750 //.0500 
    //#define DE_Z 0.375
    //#define DG_W 3.0 //popout
	#define BMT 1    
	#define DF_Z 0.125
    //#define DL_Y -0.75      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 1.00       // Compat Power
	//#define WSM 2 //Weapon Settings Mode
	//#define DB_W 24//Weapon Selection
    #define DG_Z 0.200 //Min
    #define DE_W 0.500 //Auto
    #define DI_Z 0.500 //Trim
	//Smooth Mode Setting
    #define SMS 2            //SM Toggle Separation
	#define DL_X 0.750      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
    #define DM_Y 0           //HQ VRS
#elif (App == 0xAAA18268 ) //Hellblade
    #define DA_W 1
    #define DA_Y 17.5 //was made to reduce artifacts
    #define DA_X 0.050
    #define DF_Y 0.050
    #define DE_X 1 
    #define DE_Y 0.375
    #define DE_Z 0.300
    #define DG_W 0.375 //Detection was moved back.
    //#define DG_Z 0.050 //Min  New system from RE7 was used
    //#define DI_Z 0.0625//Trim New system from RE7 was used
    #define BMT 1      //Disables Auto ZPD
	#define DF_Z 0.060 //Sets Manual Mode power.
    #define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.10       // Compat Power
	#define PEW 1
	#define DAA 1
	//Smooth Mode Setting
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.750 //SM Tune
	#define DL_W 0.050 //SM Perspective
#elif (App == 0xBAC3D546 ) //Wolfenstine New Colossus II 
    #define DA_X 0.030//0.040
    #define DF_Y 0.05 //0.116
    #define DA_Y 25.0//15.5
    //#define DA_Z -0.0005
    //#define DE_X 2
    //#define DE_Y 0.500
    //#define DE_Z 0.375
	//#define DG_W 0.325 //Pop out
    #define BMT 1    
    #define DF_Z 0.125
	#define DG_Z 0.060 //Min
    #define DI_Z 0.200 //Trim
    #define DF_W float4(0.0001,0.007,0.0,0.0)// Edge & Scale
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 3
	#define DK_W 3
	//Smooth Mode Setting	
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.800 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	//#define DM_X 3     //HQ Tune
	//#define DM_Z 3     //HQ Smooth
	#define PEW 1
#elif (App == 0x132AB11B ) //Wolfenstine Youngblood 
    #define DA_X 0.040
    #define DF_Y 0.116
    #define DA_Y 15.5
    //#define DA_Z -0.0005
    #define DE_X 2
    #define DE_Y 0.500
    #define DE_Z 0.375
	//#fine DG_W 0.325 //Pop out
    #define BMT 1    
    #define DF_Z 0.116
	#define DG_Z 0.070 //Min
    #define DI_Z 0.225 //Trim
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.75 //SM Tune
	#define DL_W 0.050 //SM Perspective
	//#define DM_X 3     //HQ Tune
	#define DM_Z 3     //HQ Smooth
    #define LBC 1      //Letter Box Correction
    #define LBS 1      //Letter Box Sensitivity
	#define DH_Z 0.0   //Pos offset X    
	#define DH_W -0.240//Pos offset Y
	#define FPS  0
	#define DK_X 2
	#define DK_Y 0
	#define DK_Z 3
	#define DK_W 1
	#define PEW 1
	#define NDW 1
	#define DAA 1
#elif (App == 0x7E3EA11D ) //EastShade
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.010
	#define DA_Y 17.5
    //#define DA_Z -0.025
	#define DB_Z 0.025
 
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.125 //nEGPop
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.625,0.5,0.275) // Fix enables if Value is > 0.0 
	#define DI_W float3(0.25,1.0,1.5) // Like Shift Boundary DG_W But 0 to inf
    //#define DG_Z 0.025 //Min
    //#define DI_Z 0.045 //Trim
	#define BMT 1
	#define DF_Z 0.25
	
	#define MAC 1
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.195 , 0.500 , 0.805 , 0.500) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.512 , 0.938 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 26.0, 26.0, 24.0, 1.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

	
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.378 , 0.168 , 0.293 , 0.055 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.700 , 0.762 , 0.213 , 0.091 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.781 , 0.897 , 0.7875, 0.909 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 21.0, 21.0, 21.0) //Tresh Hold for Color A & B and Color
	//English German Russian French
	//Chinese
    #define DP_X float4( 0.292 , 0.943 , 0.4907, 0.9035) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.686 , 0.500 , 0.292 , 0.943 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.493 , 0.901 , 0.686 , 0.500 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 18.0, 22.0, 18.0, 22.0) //Tresh Hold for Color C & D and Color
	//English German Russian French
	//Chinese
	#define DQ_X float4( 0.240 , 0.943, 0.5135, 0.9035) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.745 , 0.900 , 0.240 , 0.943 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.4975 , 0.901 , 0.745 , 0.900 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 18.0, 22.0, 18.0, 22.0) //Tresh Hold for Color A1 & A3 and Color
	//Option menus
	//Contoller painting
	#define DR_X float4( 0.2185, 0.137 , 0.775 , 0.150 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.7815, 0.862 , 0.161 , 0.518 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.1915, 0.575 , 0.840 , 0.518 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 18.0, 18.0, 26.0, 26.0) //Tresh Hold for Color G & H and Color 
    #define PEW 1
	#define DSW 1
	//Smooth Mode Setting	
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.850 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
	#define DJ_X 0.042     //Range Smoothing
#elif (App == 0x142EDFD6 || App == 0x2A0ECCC9 || App == 0x8B0C2031 )	//DOOM 2016 ****
	#define DA_Y 23.0
	//#define DA_Z -0.00010
	#define DA_X 0.07
	#define DB_Z 0.050
	#define DF_Y 0.0125
	#define DE_X 4
	#define DE_Y 0.800
	#define DE_Z 0.400
	#define DG_W -0.375 //nEGPop
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.175,0.100) // Fix enables if Value is > 0.0 
	#define DI_W float4(-0.125,0.5,1.75,6.0) // Like Shift Boundary DG_W But 0 to inf

	#define DB_W 8
    //#define DG_Z 0.001
	#define BMT 1
	#define DF_Z 0.250
	//Smooth Mode Setting	
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	//#define DM_X 3     //HQ Tune
	//#define DM_Z 3     //HQ Smooth
	#define PEW 1
#elif (App == 0xA1D04FDC ) //Dishonored
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.005
	#define DA_Y 70.0
    //#define DA_Z 0.001
	#define DB_Z 0.05
 
	#define DE_X 4
	#define DE_Y 0.750
	#define DE_Z 0.375
    //#define AFD 1
	#define DG_W -0.25 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.50,0.375) //Fix enables if Value is > 0.0
	#define DI_W float2(0.0,1.0)
	//#define FTM 1
    //#define DG_Z 0.055 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.075 //Trim
    //#define DL_Y 0.7    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
	#define WSM 2
	#define DB_W 20
    #define PEW 1
    #define NFM
    //
	#define BMT 1
	#define DF_Z 0.100
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.025       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xDB778A3B ) //Portal 2 ****
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.000
	#define DA_Y 25.0
    #define DA_Z 0.001
	#define DB_Z 0.050
 
	#define DE_X 4
	#define DE_Y 0.7
	#define DE_Z 0.375
	#define DG_W -0.125 //nEGPop
    //#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.45 // Fix enables if Value is > 0.0 
	#define DI_W 0.25 // Like Shift Boundary DG_W But 0 to inf
    //#define DG_Z 0.025 //Min
    //#define DI_Z 0.045 //Trim
	#define BMT 1
	#define DF_Z 0.25
	#define WSM 5
	#define DB_W 10
	#define DSW 1
	#define PEW 1
#elif (App == 0x2D950D30 )	//Fallout 4
	#define DA_X 0.025
	#define DF_Y 0.012
    //#define DA_Z 0.001
	#define DA_Y 15.0
	#define DE_X 5
	#define DE_Y 0.75
	#define DE_Z 0.375
	//#define DG_W -0.125 //Neg Pop out
    //#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.5 // Fix enables if Value is > 0.0 
	#define DI_W 0.5 // Like Shift Boundary DG_W But 0 to inf
	#define BMT 1    
	#define DF_Z 0.15
    //#define DL_Y -0.75      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.00       // Compat Power
	#define DB_W 6
	#define FOV 1
	#define RHW 1
	#define DSW 1
	//Smooth Mode Setting	
	#define SMS 3      //SM Toggle Separation
	#define DL_X 0.9 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
#elif (App == 0xC4F2128F ) //Golf With Your Firends
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.010
	#define DA_Y 125.0
    //#define DA_Z 0.001
	#define DB_Z 0.025
	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.375
	//#define DG_W -0.100 //PoP
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.5,0.375,0.125,0.0625) //float2(0.265,0.001) //Fix enables if Value is > 0.0
	#define DI_W float4(0.625,2.5,5.0,10.0)  //float2(1.5,7.0)
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.118 , 0.080 , 0.500 , 0.720 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.069 , 0.412 , 0.234 , 0.080 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.155 , 0.379 , 0.064 , 0.195 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 25.0, 25.0, 25.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 3
	//#define DB_W 30
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	//#define RHW 1
	//#define NDW 1
	//#define SPF 1
	//#define DD_W -0.240
	//#define LBM 1
	//#define DI_X 0.879
	//#define DI_Y 0.120
	#define BMT 1
	#define DF_Z 0.05
	//Smooth Mode Setting
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
    #define DM_Y 0           //HQ VRS
#elif (App == 0x9CB2064D ) //GTFO
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.015
	#define DA_Y 460.0
    #define DA_Z -0.1    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025
	#define DE_X 4
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.5 //PoP
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.375,0.25) //Fix enables if Value is > 0.0
	#define DI_W float3(0.0,0.5,1.0)  
	//#define FTM 1
    //#define DG_Z 0.001//0.050//0.075 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.05//0.050//0.090 //Trim
    //#define DL_Y -0.5    //De-Artifact
    //#define DL_Z 0.50       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.118 , 0.080 , 0.500 , 0.720 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.069 , 0.412 , 0.234 , 0.080 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.155 , 0.379 , 0.064 , 0.195 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 25.0, 25.0, 25.0)   //Tresh Hold for Color A & B and Color
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	#define WSM 2
	#define DB_W 8
	#define DF_X float2(0.175,0.0)	
    #define PEW 1
	#define ARW 1
	//#define RHW 1
	//#define NDW 1
	//#define SPF 1
	//#define DD_W -0.240
	//#define LBM 1
	//#define DI_X 0.879
	//#define DI_Y 0.120
	#define BMT 1
	#define DF_Z 0.2
	//Smooth Mode Setting
    //#define SMS 1            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
    #define DM_Y 0           //HQ VRS
#elif (App == 0x9CD42ABF ) //The Beast Inside
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.0195
	#define DF_Y 0.015
	#define DA_Y 52.5
    #define DA_Z 0.001
	#define DB_Z 0.05
	#define DE_X 2
	#define DE_Y 0.875
	#define DE_Z 0.375
	//#define DG_W -0.5 //PoP
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.75,0.5) //Fix enables if Value is > 0.0
	#define DI_W float2(0.5,1.5)
	//#define FTM 1
    #define DG_Z 0.095 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.045 //Trim
    #define DF_W float4(0.001,0.0025,0.0,0.0)  //Edge & Scale
    #define DL_Y -0.5    //De-Artifact
    #define DL_Z 0.50       //Compat Power
    /*
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.275, 0.600 , 0.722)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.4822, 0.312,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 6.0, 5.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C. 
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.013 , 0.078 , 0.010 , 0.500 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.121 , 0.094 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 1000.0, 1000.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 2
	//#define DB_W 8
	//#define DF_X float2(0.050,0.0)	
    #define PEW 1	
	//#define RHW 1
	//#define NDW 1
	//#define SPF 1
	//#define DD_W -0.240
	//#define LBM 1
	//#define DI_X 0.879
	//#define DI_Y 0.120
    #define SDU 1
	#define BMT 1
	#define DF_Z 0.15
	//Smooth Mode Setting
    #define SMS 3            //SM Toggle Separation
	#define DL_X 0.950      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 3           //HQ Tune
    //#define DM_Y 0           //HQ VRS
#elif (App == 0x56E482C9 ) //DreamFall Chapters
	//#define DA_W 1
    #define DB_X 1
	#define DA_X 0.0375
	#define DF_Y 0.0375
	#define DA_Y 12.5
    #define DA_Z -0.001
	#define DB_Z 0.050
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.25 //Pop
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.5,0.375) //Fix enables if Value is > 0.0
	#define DI_W float2(0.0,1.0)

    //#define DG_Z 0.1400 //Min
    //#define DI_Z 0.1425 //Trim
	#define BMT 1
	#define DF_Z 0.100

    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
//    #define DN_X float4( 0.125, 0.105 ,  0.940 , 0.922)  //Pos A = XY White & B = ZW White 
//    #define DN_Y float4( 0.125, 0.43825,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_X float4( 0.095, 0.322 ,  0.9425, 0.152)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.095, 0.575 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
//    #define DJ_Y float4( 29, 30.0, 29.0, 15.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Y float4( 30, 30.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.500 , 0.093 , 0.500 , 0.090 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.940 , 0.9145, 0.650 , 0.093 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.090 , 0.940 , 0.9145 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 18.0, 30.0, 18.0, 30.0)   //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0)   //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
    #define DS_Y 1
    #define SDU 1
    #define PEW 1
	//Smooth Mode Setting  
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.900 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
#elif (App == 0x95BD2B21 ) //Shadow of a Doubt 
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.040
	#define DA_Y 100.0
    //#define DA_Z -0.001
	#define DB_Z 0.050
 
	//#define DE_X 1
	//#define DE_Y 0.750
	//#define DE_Z 0.375
	//#define DG_W -0.25 //Pop
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.5,0.375) //Fix enables if Value is > 0.0
	//#define DI_W float2(0.0,1.0)

	//#define FTM 1
    #define DG_Z 0.040 //Min
    //#define DE_W 0.75 //Auto
    #define DI_Z 0.050 //Trim
    #define DF_W float4(0.001,0.0045,0.0,0.0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.100

    //#define DM_Y 3     //HQ VRS
    //#define DL_Y 0.375    //De-Artifact 0.1245
	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.095, 0.322 ,  0.9425, 0.152)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.095, 0.575 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 30.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.140 , 0.0425, 0.620 , 0.929 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.620 , 0.109 , 0.140 , 0.0425 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.190 , 0.929 , 0.620 , 0.109 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0, 28.0, 27.0, 28.0 ) //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
	//Smooth Mode Setting  
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
#elif (App == 0x47C6537E ) //Warhammer 40000 Boltgun
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.070
	#define DF_Y 0.000
	#define DA_Y 250.0
    #define DA_Z -0.25    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05
 
	#define DE_X 4
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W -0.25 //Pop
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.625,0.5) //Fix enables if Value is > 0.0
	#define DI_W float2(0.0,0.25)

	//#define FTM 1
    //#define DG_Z 0.040 //Min
    //#define DE_W 0.75 //Auto
    //#define DI_Z 0.050 //Trim
	#define BMT 1
	#define DF_Z 0.2

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 1.00       // Compat Power
	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.095, 0.322 ,  0.9425, 0.152)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.095, 0.575 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 30.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.140 , 0.0425, 0.620 , 0.929 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.620 , 0.109 , 0.140 , 0.0425 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.190 , 0.929 , 0.620 , 0.109 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0, 28.0, 27.0, 28.0 ) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	#define WSM 4
	#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    #define RHW 1
	//Smooth Mode Setting  
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 2     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0x2AB9ECF9) //System ReShock Updated
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.020
	#define DA_Y 250.0
    #define DA_Z -0.5    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.04
	//#define ABE 0
	#define DE_X 1
	#define DE_Y 0.700
	#define DE_Z 0.375
	#define DG_W 2.0 //Pop
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.5 //Fix enables if Value is > 0.0
	#define DI_W 4.5

	//#define FTM 1
    #define DG_Z 0.045 //Min
    #define DE_W 0.45 //Auto
    #define DI_Z 0.050 //Trim
    #define DF_W float4(0.0001,0.003,0.0,0.035)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.15

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power
	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.095, 0.322 ,  0.9425, 0.152)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.095, 0.575 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 30.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.140 , 0.0425, 0.620 , 0.929 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.620 , 0.109 , 0.140 , 0.0425 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.190 , 0.929 , 0.620 , 0.109 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0, 28.0, 27.0, 28.0 ) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    #define DSW 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0xFE54BF56 ) //No One Lives Forever and 2
	#define DA_X 0.0375
	#define WSM 10
	#define OW_WP "Read Help & Change Me\0Custom WP\0No One Lives Forever\0No One Lives Forever 2\0"
	#define WPW 1
	#define RHW 1
#elif (App == 0xA300000 || App == 0xA400000 ) //Alien VS Preditor 2 & Primal Hunt
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.035
	#define DF_Y 0.020
	#define DA_Y 26.0
    //#define DA_Z -0.001
	#define DB_Z 0.1
 
	#define DE_X 4
	#define DE_Y 0.500
	#define DE_Z 0.375
	#define DG_W 0.0 //Pop
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    //#define OIF float2(0.7,0.5) //Fix enables if Value is > 0.0
	//#define DI_W float2(2.0,4.5)

	//#define FTM 1
    //#define DG_Z 0.035 //Min
    //#define DE_W 0.00 //Auto
    //#define DI_Z 0.06 //Trim
    //#define DF_W float3(0.0001,0.0025,0.275)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.25
	#define WSM 11
	#define OW_WP "Read Help & Change Me\0Custom WP\0Aliens VS Predator 2\0Aliens VS Predator 2 WIP\0"
	#define WPW 1
    #define NDG 1
	#define RHW 1
#elif (App == 0x7281105 || App == 0x8C01E44B ) //Amnesia Bunker
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.015
	#define DF_Y 0.025
	#define DA_Y 105.0
    #define DA_Z 0.00025
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05 
	#define DE_X 2
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W 0.5 //Pop
    //#define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF 0.625 //Fix enables if Value is > 0.0
	#define DI_W 1.0

	//#define FTM 1
    #define DG_Z 0.020 //Min
    //#define DE_W 0.00 //Auto
    #define DI_Z 0.100 //Trim
    #define DF_W float4(0.0001,0.000,0.400,0.005)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.25

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power
	
//    #define MAC 0   
//    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
//    #define DN_X float4( 0.081, 0.508 ,  0.055, 0.500)  //Pos A = XY White & B = ZW White 
//    #define DN_Y float4( 0.0806,0.597 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
//    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
//	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
//    #define DJ_Y float4( 15.0, 0.0, 15.0, 23.0);     //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
//    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.4055,0.2664 ,  0.405, 0.510)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.3983, 0.880 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 20.0, 0.0, 29.0, 21.0);     //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.3983, 0.880 , 0.405 , 0.510 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.4055, 0.2664 , 0.3983, 0.880 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.405 , 0.510 , 0.4055, 0.2664 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 28.0, 15.0, 28.0, 16.0 ) //Tresh Hold for Color A & B and Color

//    #define DP_X float4( 0.0764 , 0.345 , 0.055, 0.500 ) //Pos C1 = XY Color & C2 = ZW Black 
//    #define DP_Y float4( 0.0564 , 0.9426 , 0.0764 , 0.345 ) //Pos C3 = XY Color & D1 = ZW Color
//    #define DP_Z float4( 0.055, 0.500 , 0.040923, 0.933 ) //Pos D2 = XY Black & D3 = ZW Color
//	#define DP_W float4( 23.0, 23.0, 23.0, 30.0) //Tresh Hold for Color C & D and Color

    #define DP_X float4( 0.3983, 0.880 , 0.405 , 0.510 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.4055, 0.2664 , 0.3983, 0.880 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.405 , 0.510 , 0.4055, 0.2664 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 19.0, 29.0, 19.0) //Tresh Hold for Color C & D and Color

	
//	#define DQ_X float4( 0.07723 , 0.125 , 0.055 , 0.500 ) //Pos C1 = XY Color & C2 = ZW Black 
//    #define DQ_Y float4( 0.0564, 0.9426, 0.07723 , 0.125 ) //Pos C3 = XY Color & D1 = ZW Color
//    #define DQ_Z float4( 0.055 , 0.500 , 0.040923,0.933) //Pos D2 = XY Black & D3 = ZW Color
//	#define DQ_W float4( 23.0, 23.0, 23.0, 30.0) //Tresh Hold for Color A1 & A3 and Color

	#define DQ_X float4( 0.3983, 0.880 , 0.405 , 0.510 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.4055, 0.2664 , 0.3983, 0.880 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.405 , 0.510 , 0.4055, 0.2664 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 28.0, 18.0, 29.0, 18.0) //Tresh Hold for Color A1 & A3 and Color
			
	#define DR_X float4( 0.3983, 0.880 , 0.405 , 0.510 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.4055, 0.2664 , 0.3983, 0.880  ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.405 , 0.510 , 0.4055, 0.2664 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 28.0, 17.0, 29.0, 17.0) //Tresh Hold for Color G & H and Color 
	
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define FPS 2     // FPS Focus Settings 
    #define DK_X 2 
    #define DK_Y 0 
    #define DK_Z 3
    #define DK_W 3 //Set speed
    #define PEW 1
    #define DSW 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0x99D666E ) //Layers of Fear 2023 dx12
    //#define DS_Z 2        
	#define DA_W 1          
    //#define DB_X 1         
	#define DA_X 0.015 // 0.025    
	#define DF_Y 0.02       
	#define DA_Y 4700.0 //2750.0     
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.001       
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.125      // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W 1.5        // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.05,0.02,0.01,0.005)         // Fix enables if Value is > 0.0 
	#define DI_W float4(10.00,15.0,50.0,75.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 4           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly and 4 is the largest number.
    #define DG_Z 0.0375      // Min Weapon Hands That are apart of world with Auto and Trim
    #define DS_X float3(0.0,0,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250      // Auto
    #define DI_Z 0.0375      // Trim
    #define DF_W float4(0.0001,0.0,0.25,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.100      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
    #define PEW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0x29315181 ) //Smushi Come Home
    //#define DS_Z 2        
	#define DA_W 1          
    #define DB_X 1         
	#define DA_X 0.025    
	#define DF_Y 0.00       
	#define DA_Y 200.0     
    //#define DA_Z -0.0001    // Linerzation Offset
    //#define DS_Y 0          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025      
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.500        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400     // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.250,0.125,0.05,0.025)   // Fix enables if Value is > 0.0 
	#define DI_W float4(1.00,1.75,2.5,12.5)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.0375      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 1.00       // Compat Power
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
    #define PEW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS    
#elif (App == 0x8946F94D ) //Star Rail
    //#define DS_Z 2        
	#define DA_W 1          
    #define DB_X 1         
	#define DA_X 0.025    
	#define DF_Y 0.005      
	#define DA_Y 120.0     
    //#define DA_Z -0.0001    // Linerzation Offset
    //#define DS_Y 0          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100       
	#define DE_X 2          // ZPD Boundary 
	#define DE_Y 0.700        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.4375     // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250     // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.4,0.3,0.2,0.125)   // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.5,3.500,5.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.0375      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.10      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 1.00       // Compat Power
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
    #define PEW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS  
#elif (App == 0x33EC163B) //Diablo IV
    #define DS_Z 3  
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.1
	#define DA_Y 200.0
    #define DA_Z 0.0005// 0.005
	#define DB_Z 0.025
 
	#define DE_X 4
	#define DE_Y 0.5
	#define DE_Z 0.375
	#define DG_W -0.25 //Pop
    #define OIL 3 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float4(0.6,0.3125,0.25,0.175) //Fix enables if Value is > 0.0
	#define DI_W float4(0.25,1.5,2.0,4.0)

	//#define FTM 1
    //#define DG_Z 0.035 //Min
    //#define DE_W 0.00 //Auto
    //#define DI_Z 0.06 //Trim
    //#define DF_W float3(0.0001,0.0025,0.275)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.2

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.375       // Compat Power
	///*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.500, 0.111 ,  0.528, 0.063 )  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.913, 0.072 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 5.0, 0.0, 27.0, 6.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	//*/
	
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.333 , 0.884 , 0.661 , 0.067 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.665 , 0.356 , 0.333 , 0.884 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.661 , 0.067 , 0.665 , 0.356 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 24.0, 19.0, 25.0, 20.0 ) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.333 , 0.884 , 0.661 , 0.067 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.633 , 0.500 , 0.333 , 0.884 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.661 , 0.067 , 0.633 , 0.500 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 24.0, 21.0, 25.0, 22.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.095 , 0.779 , 0.661 , 0.067 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.665 , 0.356 , 0.095 , 0.779 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.661 , 0.067 , 0.665 , 0.356 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 24.0, 19.0, 25.0, 20.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.333 , 0.884 , 0.661 , 0.067 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.633 , 0.500 , 0.095 , 0.779 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.661 , 0.067 , 0.633 , 0.500 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 24.0, 21.0, 25.0, 22.0) //Tresh Hold for Color G & H and Color 

	#define WSM 4
	#define DB_W 11
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define WHM 1 //Weapon Hand Masking lets you use DT_Z 
	#define DT_Z 0.1 //Masking Power
    #define PEW 1
    #define DSW 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS      
#elif (App == 0xD4CDCAAF ) //Daikatana
    //#define DS_Z 2        
	//#define DA_W 1          
    #define DB_X 1         
	#define DA_X 0.025    
	#define DF_Y 0.000      
	#define DA_Y 50.0     
    //#define DA_Z -0.0001    // Linerzation Offset
    //#define DS_Y 0          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05       
	#define DE_X 4          // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375     // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250     // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.5,0.375,0.250)   // Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,1.0,1.5)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.0375      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.250      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power

	#define WSM 4           // Weapon Setting Mode 
	#define DB_W 5         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
    #define RHW 1
    #define DSW 1    
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS  
#elif (App == 0x822AF64D ) //The Outer Worlds
    #define DA_W 1
    #define DA_X 0.050

    #define DS_Y 1          // Linerzation Offset Effects only distance if true  
    #define DA_Y 52.5
    #define DB_Z 0.075
    
    #define DE_X 6
     
    //#define DK_X 2
    #define BMT 1     //BMT 1 needs DF_Z set to a value from 0.0-0.250

	#define DG_Z 0.0125//Min
    #define DE_W 0.170
    #define DI_Z 0.070//Trim
	#define DJ_W 0.125
    #define DL_Z 0.25       // Compat Power
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	#define DL_W 0.050 //SM Perspective
	#define DM_X 4    //HQ Tune
	#define DM_Z 4     //HQ Smooth	
	#define WSM 12
	#define OW_WP "Read Help & Change Me\0Custom WP\0The Outer Worlds\0The Outer Worlds Spacer Ed\0"
	#if IS_DX12
    	#define DB_W 3
		
		#define DE_Y 0.75        // Set ZPD Boundary Level Zero 
		#define DE_Z 0.375     // Speed that Boundary is Enforced
		//#define AFD 1         // Alternate Frame Detection - May be phased out
		#define DG_W -0.25     // Shift Boundary Out of screen 0.5 and or In screen -0.5
		#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
		#define OIF float4(0.6,0.5,0.375,0.250)   // Fix enables if Value is > 0.0 
		#define DI_W float4(0.0,0.5,1.25,2.5)        // Like Shift Boundary DG_W But 0 to inf
	
		#define DF_Y 0.065
		#define DF_Z 0.15
   	#define DA_Z -0.75
	#else
		#define DB_W 2

		#define DE_Y 0.625        // Set ZPD Boundary Level Zero 
		#define DE_Z 0.375     // Speed that Boundary is Enforced
		//#define AFD 1         // Alternate Frame Detection - May be phased out
		#define DG_W -0.125     // Shift Boundary Out of screen 0.5 and or In screen -0.5
		#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
		#define OIF float3(0.5,0.375,0.250)   // Fix enables if Value is > 0.0 
		#define DI_W float3(0.5,1.25,2.5)        // Like Shift Boundary DG_W But 0 to inf

		#define DF_Y 0.07
		#define DF_Z 0.125
		#define DA_Z -1.0
    #endif
    #define DF_X 0.250 
    #define FPS 2
    #define DK_X 2 //FPS Focus
    #define DK_Y 0
    #define DK_Z 1
    #define DK_W 2 //Set speed
    #define PEW 1  
    #define FOV 1
    #define DAA 1
#elif (App == 0x894347CF) //MassEffect Andromeda 
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.025
	#define DA_Y 62.5
    //#define DA_Z -0.001
	#define DB_Z 0.09
 
	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375
	#define DG_W 0.0 //Pop
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.5,1.0)

	//#define FTM 1
    //#define DG_Z 0.035 //Min
    //#define DE_W 0.00 //Auto
    //#define DI_Z 0.06 //Trim
    //#define DF_W float3(0.0001,0.0025,0.275)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.25

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power

	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.095, 0.322 ,  0.9425, 0.152)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.095, 0.575 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 30.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.140 , 0.0425, 0.620 , 0.929 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.620 , 0.109 , 0.140 , 0.0425 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.190 , 0.929 , 0.620 , 0.109 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0, 28.0, 27.0, 28.0 ) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    #define DSW 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0xCA34D9EB) //Inside the Backrooms
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0275
	#define DA_Y 22.5
    //#define DA_Z -0.001
	#define DB_Z 0.05

	#define DE_X 2
	#define DE_Y 0.750
	#define DE_Z 0.375
 /*
	#define DG_W 0.0 //Pop
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.5,0.25) //Fix enables if Value is > 0.0
	#define DI_W float2(0.5,1.0)
*/
	//#define FTM 1
    #define DG_Z 0.025 //Min
    //#define DE_W 0.00 //Auto
    #define DI_Z 0.125 //Trim
    #define DF_W float4(0.0001,0.0025,0.05,0)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.5

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power

    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.349, 0.195 ,  0.3741, 0.1785)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.376, 0.848 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 2.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 

	/*	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.140 , 0.0425, 0.620 , 0.929 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.620 , 0.109 , 0.140 , 0.0425 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.190 , 0.929 , 0.620 , 0.109 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 27.0, 28.0, 27.0, 28.0 ) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    //#define DSW 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0xD4D6C603) //Alice Madness Returns
	//#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0125
	#define DA_Y 75.0
    //#define DA_Z -0.001
	#define DB_Z 0.05

	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375

	#define DG_W 0.0 //Pop
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.3,0.25) //Fix enables if Value is > 0.0
	#define DI_W float3(0.75,1.5,2.5)

	//#define FTM 1
    //#define DG_Z 0.025 //Min
    //#define DE_W 0.00 //Auto
    //#define DI_Z 0.125 //Trim
    //#define DF_W float3(0.0001,0.0025,0.05)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.2

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power
	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.349, 0.195 ,  0.3741, 0.1785)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.376, 0.848 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 2.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
		
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.325 , 0.100 , 0.4759, 0.659 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.783 , 0.948 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 26.0, 23.0, 1000.0, 1000.0 ) //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    #define DSW 1
    #define DAA 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.8 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0x99E35C9B) //Outlast Trials
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.0
	#define DA_Y 100.0
    //#define DA_Z -0.001
	#define DB_Z 0.05

	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.375

	#define DG_W 0.0 //Pop
    #define OIL 1 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float2(0.375,0.250) //Fix enables if Value is > 0.0
	#define DI_W float2(1.0,1.5) 

	//#define FTM 1
    //#define DG_Z 0.025 //Min
    //#define DE_W 0.00 //Auto
    //#define DI_Z 0.125 //Trim
    //#define DF_W float3(0.0001,0.0025,0.05)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.25

    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power

	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.349, 0.195 ,  0.3741, 0.1785)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.376, 0.848 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 2.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
		
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.305 , 0.116 , 0.500 , 0.025 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.066 , 0.177 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 1000.0, 1000.0 ) //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
        
	#define LBC 1
	#define LBE 2
	#define LBR 1
	#define DH_Z 0.053
	#define DH_W -0.084

    #define PEW 1
    //#define DSW 1
    //#define DAA 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0x6A00404B) //A Plague Tale Requiem
	#define DA_W 1
    //#define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.01
	#define DA_Y 45.0//43.75
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05

	#define DE_X 1
	#define DE_Y 0.750
	#define DE_Z 0.375

	#define DG_W -0.250 //Pop
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.625,0.5,0.25) //Fix enables if Value is > 0.0
	#define DI_W float3(0.25,0.5,1.5)

	//#define FTM 1
    //#define DG_Z 0.025 //Min
    //#define DE_W 0.00 //Auto
    //#define DI_Z 0.125 //Trim
    //#define DF_W float3(0.0001,0.0025,0.05)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.200

    #define DL_Y 0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DB_Y 1.0        // De-Artifact Scale
    #define DL_Z 0.0       // Compat Power
	#define DJ_X 0.071      // Range Smoothing
	//Title Screen
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.261, 0.220 ,  0.240 , 0.194 )  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.804, 0.260 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 2.0, 30.0, 29.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
		
	//Select A Slot
    #define MMD 5 //Set Multi Menu Detection             //Off / On
    #define MMS 1 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.500 , 0.259 , 0.500 , 0.252 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.500 , 0.882 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 17.0, 17.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
	//Generic Loading screen
    #define DP_X float4( 0.300 , 0.500 , 0.500 , 0.975 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.700 , 0.500 , 0.250 , 0.500 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.975 , 0.750 , 0.500 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 5.0, 5.0, 5.0, 5.0) //Tresh Hold for Color C & D and Color
	//Main Menu Settings and Loading Screen 7
	#define DQ_X float4( 0.500 , 0.291 , 0.500 , 0.862 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.500 , 0.050 , 0.100 , 0.925 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.484 , 0.500 , 0.900 , 0.925 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color
	//2nd Main Menu KB & Controller
	#define DR_X float4( 0.841 , 0.903 , 0.854 , 0.935 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.869 , 0.930 , 0.706 , 0.900 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.706 , 0.905 , 0.856 , 0.933 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 26.0, 26.0, 30.0, 30.0) //Tresh Hold for Color G & H and Color 
	//Loading Screen 1/3/6 and last
	#define DU_X float4( 0.100 , 0.925 , 0.4355, 0.500 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.900 , 0.925 , 0.100 , 0.925 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.415 , 0.500 , 0.900 , 0.925 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color I & J and Color
	//Loading Screen 2/5 and 4	
	#define DV_X float4( 0.100 , 0.925 , 0.459 , 0.500 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.900 , 0.925 , 0.100 , 0.925 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.439 , 0.500 , 0.900 , 0.925 ) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color K & L and Color	

	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    #define DSW 1
    #define DAA 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.875 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VRS
#elif (App == 0x85C3019A) //Road 96
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.01
	#define DA_Y 35.0
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025

	#define DE_X 3
	#define DE_Y 0.750
	#define DE_Z 0.375

	#define DG_W 0.1 //Pop
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.5,0.375,0.256) //Fix enables if Value is > 0.0
	#define DI_W float3(0.250,1.0,2.0)

	//#define FTM 1
    #define DG_Z 0.0125 //Min
    //#define DE_W 0.00 //Auto
    #define DI_Z 0.25 //Trim
    //#define DF_W float3(0.0001,0.0025,0.05)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.375

    #define DL_Y -1.0      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 1.00       // Compat Power

	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.349, 0.195 ,  0.3741, 0.1785)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.376, 0.848 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 2.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
		
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.163 , 0.166 , 0.500 , 0.185 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.837 , 0.166 , 0.100 , 0.750 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.250 , 0.800 , 0.900 , 0.750 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0 ) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.163 , 0.162 , 0.500 , 0.185 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.837 , 0.162 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    //#define DSW 1
    //#define DAA 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.90 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x76BA20DE) //Road 96 Mile 0 
	#define DA_W 1
    #define DB_X 1
	#define DA_X 0.025
	#define DF_Y 0.005
	#define DA_Y 100.0
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025

	#define DE_X 3
	#define DE_Y 0.75
	#define DE_Z 0.375

	#define DG_W 0.125 //Pop
    #define OIL 2 //Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3
    #define OIF float3(0.625,0.5,0.4) //Fix enables if Value is > 0.0
	#define DI_W float3(0.25,0.75,1.0)

	//#define FTM 1
    //#define DG_Z 0.0125 //Min
    //#define DE_W 0.00 //Auto
    //#define DI_Z 0.25 //Trim
    //#define DF_W float3(0.0001,0.0025,0.05)  //Edge & Scale
	#define BMT 1
	#define DF_Z 0.15

    #define DL_Y -0.25      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z -0.25       // Compat Power

	/*
    #define MAC 0   
    #define MDD 1 //Set Menu Detection & Direction     //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.349, 0.195 ,  0.3741, 0.1785)  //Pos A = XY White & B = ZW White 
    #define DN_Y float4( 0.376, 0.848 ,  0.0, 0.0)       //Pos C = XY Light & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)            //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30, 2.0, 30.0, 1000.0);            //Menu Detection Type for A, B, & C. The Last Value is a Shift amount for C.  
    #define DJ_Z float3( 1000., 1000., 1000);                //Set Match Tresh 
	*/
		
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.168 , 0.195 , 0.500 , 0.229 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.833 , 0.195 , 0.168 , 0.189 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.229 , 0.833 , 0.189 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0 ) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.0395, 0.859 , 0.500 , 0.768 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.976 , 0.936 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define WSM 4
	//#define DB_W 9
	//#define DF_X float2(0.050,0.0)	
    //#define DS_Y 1
    //#define SDU 1
    #define PEW 1
    //#define DSW 1
    //#define DAA 1
    //#define RHW 1
	//Smooth Mode Setting  
    #define SMS 0      //SM Toggle Separation
	#define DL_X 0.95 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 2     //HQ Tune
    //#define DM_Y 3     //HQ VR      
#elif (App == 0xA5132CD6 )	//Guilty Gear 
    #define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.050      // ZPD
	//#define DF_Y 0.00       // Seperation
	#define DA_Y 37.5       // Near Plane Adjustment
    //#define DA_Z -0.0001    // Linerzation Offset
    //#define DS_Y 0          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.1        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.500      // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W 0.250      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 0           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.250         // Fix enables if Value is > 0.0 
	#define DI_W 1.0        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power
	#define DJ_X 0.142      // Range Smoothing
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color

	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.8 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0xC6EDDBB2 )	//Sifu 
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	//#define DF_Y 0.00       // Seperation
	#define DA_Y 37.5       // Near Plane Adjustment
    //#define DA_Z -0.0001    // Linerzation Offset
    //#define DS_Y 0          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.1        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.800      // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W 0.250      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.70,0.5)         // Fix enables if Value is > 0.0 
	#define DI_W float2(0.250,1.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 1.00       // Compat Power
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location

    #define MAC 3
    #define MDD 1 //Set Menu Detection & Direction      //Off 0 | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.685 , 0.486 , 0.915 , 0.912) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.948 , 0.525 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 6.0, 30.0, 100.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 1 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.307 , 0.078 , 0.920 , 0.912 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.693 , 0.078 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
	
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	
	#define DQ_X float4( 0.923 , 0.084 , 0.500 , 0.120 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.915 , 0.912 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color    
	#define DQ_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	/*
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	#define DAA 1           
	#define PEW 1
    #define DSW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x29CB30F6 )	//Gripper
    //#define DS_Z 0          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	//#define DF_Y 0.00       // Seperation
	#define DA_Y 250.0       // Near Plane Adjustment
    #define DA_Z -0.375    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.50     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.4375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.3,0.2,0.1,0.0375)         // Fix enables if Value is > 0.0 
	#define DI_W float4(2.0,3.5,5.0,15.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.500      // Set the Balance  
    #define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.5       // Compat Power
	#define DJ_X 0.214      // Range Smoothing
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0x7312C43E )	//Dredge
    //#define DS_Z 0          // Set View Mode
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 185.0//110.0 // Near Plane Adjustment
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.500     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.250,0.125,0.0625)         // Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,3.75,10.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power
	
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
    #define MAC 0
    #define MDD 1 //Set Menu Detection & Direction      // Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.308 , 0.829 , 0.500 , 0.986) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.690 , 0.977 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 0.0, 0.0, 0.0, 30.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.325 , 0.234 , 0.977 , 0.972 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.670 , 0.1375, 0.143 , 0.249 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.137 , 0.856 , 0.249 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.338 , 0.165 , 0.500 , 0.225 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.495 , 0.221 , 0.855 , 0.045 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.828 , 0.038 , 0.140 , 0.9025) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.670 , 0.1375, 0.692 , 0.986 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.990 , 0.138 , 0.484 , 0.480 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.064 , 0.532 , 0.480 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.202 , 0.206 , 0.500 , 0.180 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.828 , 0.794 , 0.670 , 0.1375) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.140, 0.175 , 0.990 , 0.138 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color G & H and Color 
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.90 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0x8CBAC111 )	//Crab Champions
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 125.0       // Near Plane Adjustment
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.1        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.75     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.5,0.25)         // Fix enables if Value is > 0.0 
	#define DI_W float2(0.0,1.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.025      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 2     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x59811BC1 )	//Lost in Random
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 130.0       // Near Plane Adjustment
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.35,0.175,0.075)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.5,2.0,5.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.5       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.775  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR   
#elif (App == 0xB59EAF54 )	//Fe
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 100.0       // Near Plane Adjustment
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.500     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.25,0.125,0.05)         // Fix enables if Value is > 0.0 
	#define DI_W float3(1.0,5.0,10.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.10      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR  
#elif (App == 0x2BB67AC1 )	//EverSpace 2
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.030      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 1000.0       // Near Plane Adjustment
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.500     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.25,0.04375)         // Fix enables if Value is > 0.0 
	#define DI_W float2(1.0,15.0)        // Like Shift Boundary DG_W But 0 to inf
	#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z -1.0       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 16         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.825  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 5     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0xFE7A4C2E )	//The Alien Cube
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 10.0       // Near Plane Adjustment
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.0325        // Auto Depth Protection
	#define DE_X 4          // ZPD Boundary 
	#define DE_Y 0.875     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.2      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.750,0.5)         // Fix enables if Value is > 0.0 
	#define DI_W float2(0.15,0.4)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.043      // Trim
    //#define DF_W float3(0,0,0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	#define WSM 4           // Weapon Setting Mode 
	#define DB_W 19         // Weapon Profile
	#define DF_X float2(0.250,0.404)// ZPD Weapon Boundarys Level 1 and Level 2
	#define DJ_W 0.025	        // Weapon Depth Limit Location 1
	#define DS_W 20.0	        // Weapon Depth Limit Location 2
	#define DT_W float2(0.010,0.022)
	#define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.060 , 0.139 , 0.149 , 0.069) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.236 , 0.158 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 30.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.058 , 0.139 , 0.149 , 0.067 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.000 , 0.0.0 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0x49C2BE08 )	//CARNAL
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.02      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 60       // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	//#define DE_X 1          // ZPD Boundary 
	//#define DE_Y 0.875     // Set ZPD Boundary Level Zero 
	//#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.2      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float2(0.750,0.5)         // Fix enables if Value is > 0.0 
	//#define DI_W float2(0.2,0.4)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.05      // Min Weapon Hands That are apart of world with Auto and Trim
    #define DE_W 0.250      // Auto
    #define DI_Z 0.03      // Trim
    #define DF_W float4(0.001,0.001,0.1,0.04)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.200      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 19         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0x19B7E127 )	//Bloodhound
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 50.0       // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 4          // ZPD Boundary 
	#define DE_Y 0.700     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	#define DI_W float3(0.0,0.5,1.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.05      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DE_W 0.250      // Auto
    //#define DI_Z 0.03      // Trim
    //#define DF_W float4(0.001,0.001,0.1,0.04)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	#define WSM 4           // Weapon Setting Mode 
	#define DB_W 20         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0xB85640E9 )	//Finding the Soul Orb
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.015      // ZPD
	#define DF_Y 0.001       // Seperation
	#define DA_Y 75.0       // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 1.0     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W 1.0      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.75,0.5)         // Fix enables if Value is > 0.0 
	#define DI_W float2(2.0,2.5)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.0      // Min Weapon Hands That are apart of world with Auto and Trim
    #define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.50      // Auto
    #define DI_Z 0.125      // Trim
    #define DF_W float4(0.001,0.005,0.0,0.005)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.2       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power
	#define DJ_X 0.107      // Range Smoothing
	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 20         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xB7097475 ) //God Damn The Garden
    #define DA_W 1
    #define DB_X 1
    #define DA_X 0.04
    #define DF_Y 0.045
    #define DA_Y 40.0
	#define DB_Z 0.05        // Auto Depth Protection
    //#define DA_Z 0.0
    //#define DE_X 4
    //#define DE_Y 0.500
    //#define DE_Z 0.375
    #define BMT 1    
    #define DF_Z 0.1375
	#define DG_Z 0.05//Min
    #define DI_Z 0.750 //Trim
    #define DF_W float4(0.001,0.005,0.0,0.005)// Edge & Scale
	#define PEW 1
	#define DSW 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xBF222C03 ) //Among The Sleep
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.015      // ZPD
	#define DF_Y 0.06       // Seperation
	#define DA_Y 150.0//125.0       // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.625     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,1.25,2.5)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.0      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.125      // Trim
    //#define DF_W float4(0.001,0.005,0.0,0.005)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 20         // Weapon Profile
	//#define DF_X float2(0,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xB75F3C89 || App == 0xF188276F ) //Amnesia: The Dark Descent
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.015      // ZPD
	#define DF_Y 0.020       // Seperation
	#define DA_Y 275.0       // Near Plane Adjustment
    #define DA_Z 0.0005    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.02        // Auto Depth Protection
	//#define DE_X 1          // ZPD Boundary 
	//#define DE_Y 0.6875     // Set ZPD Boundary Level Zero 
	//#define DE_Z 0.35      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float3(0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	//#define DI_W float3(0.5,1.0,2.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.00      // Auto
    #define DI_Z 0.0525      // Trim
    #define DF_W float4(0.125,0.000,0.500,0.000)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.5       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	#define WSM 4           // Weapon Setting Mode 
	#define DB_W 25         // Weapon Profile
	#define DF_X float2(0.386,0)// ZPD Weapon Boundarys Level 1 and Level 2
	#define DJ_W 10.0	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR	
#elif (App == 0x91FF5778 || App == 0x6DD82022 ) //Amnesia: Machine for Pigs
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.015      // ZPD
	#define DF_Y 0.020       // Seperation
	#define DA_Y 275.0       // Near Plane Adjustment
    #define DA_Z 0.0005    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.02        // Auto Depth Protection
	//#define DE_X 1          // ZPD Boundary 
	//#define DE_Y 0.6875     // Set ZPD Boundary Level Zero 
	//#define DE_Z 0.35      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float3(0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	//#define DI_W float3(0.5,1.0,2.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.100      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.00      // Auto
    #define DI_Z 0.0525      // Trim
    #define DF_W float4(0.125,0.000,0.400,0.000)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.5       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	#define WSM 4           // Weapon Setting Mode 
	#define DB_W 25         // Weapon Profile
	#define DF_X float2(0.386,0)// ZPD Weapon Boundarys Level 1 and Level 2
	#define DJ_W 10.0	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR	
#elif (App == 0x73C5395D ) //Outward DE
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.037      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 13.5       // Near Plane Adjustment
    #define DA_Z -1.000    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.50     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.250         // Fix enables if Value is > 0.0 
	#define DI_W 2.0        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.098      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.050      // Trim
    //#define DF_W float4(0.0001,0.000,0.0,0.025)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.1       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power
	#define DJ_X 0.071      // Range Smoothing
	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 25         // Weapon Profile
	//#define DF_X float2(0.386,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.91  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 5     //HQ Tune
    //#define DM_Y 3     //HQ VR 
#elif (App == 0x95523E9F ) //Styx: Shards of Darkness
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 50.0       // Near Plane Adjustment
    #define DA_Z -0.250    // Linerzation Offsett
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05        // Auto Depth Protection
	#define DE_X 2          // ZPD Boundary 
	#define DE_Y 0.750     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.250,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(1.0,2.0,2.5,5.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.098      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.050      // Trim
    //#define DF_W float4(0.0001,0.000,0.0,0.025)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.1       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power
	#define DJ_X 0.107      // Range Smoothing
	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 25         // Weapon Profile
	//#define DF_X float2(0.386,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.925  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x32CA1739 ) //Styx: Master of Shadows
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 39.0       // Near Plane Adjustment
    //#define DA_Z -1.000    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750     // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,2.0,3.0,4.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.098      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.050      // Trim
    //#define DF_W float4(0.0001,0.000,0.0,0.025)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.1       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 25         // Weapon Profile
	//#define DF_X float2(0.386,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.925  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xBD472CFE ) //Pseudoregalia
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 100.0       // Near Plane Adjustment
    //#define DA_Z -1.000    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.500    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,1.5,2.5)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.098      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.050      // Trim
    //#define DF_W float4(0.0001,0.000,0.0,0.025)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power

	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 25         // Weapon Profile
	//#define DF_X float2(0.386,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
/* //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only C has a wiled card. Not the A and C.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000)           //Set Match Tresh 
*/
    //Simple Menu Detection May add one more later
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.332 , 0.227 , 0.613 , 0.791)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.684 , 0.227 )                 //Pos C = XY 
    #define DW_Z float4( 30.0, 30.0, 30.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
	
	//Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 1 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 0 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Main Menu
    #define DO_X float4( 0.240 , 0.325 , 0.500 , 0.387 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.753 , 0.325 , 0.250 , 0.325 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.387 , 0.745 , 0.325 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.501 , 0.325 , 0.499 , 0.297 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.335 , 0.786 , 0.242, 0.132 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.065 , 0.033 , 0.750 , 0.116 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 26.0, 25.0) //Tresh Hold for Color C & D and Color

	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
    #define RHW 1
#elif (App == 0x4ED550E1 ) //Lunacid
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.0075       // Seperation
	#define DA_Y 25.0       // Near Plane Adjustment
    #define DA_Z -1.000    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	//#define DE_X 1          // ZPD Boundary 
	//#define DE_Y 0.500    // Set ZPD Boundary Level Zero 
	//#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float3(0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	//#define DI_W float3(0.5,1.5,2.5)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.025      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.5      // Auto
    #define DI_Z 0.0375      // Trim
    #define DF_W float4(0.0001,0.0025,0.125,0.025)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.5       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.25       // Compat Power

	//#define WSM 4           // Weapon Setting Mode 
	//#define DB_W 25         // Weapon Profile
	//#define DF_X float2(0.386,0)// ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0	        // Weapon Depth Limit Location
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x2F0BD376 ) //Minecraft / BuildGDX / Delver
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 27.5       // Near Plane Adjustment
    //#define DA_Z -1.000    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 5          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W 0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.5         // Fix enables if Value is > 0.0 
	#define DI_W 1.0        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.0125      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    #define DI_Z 0.05      // Trim
    #define DF_W float4(0.0001,0.00125,0.0,0.0125)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.300       // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.25       // Compat Power

	//#define WSM 4           // Weapon Setting Mode 
	#define DB_W 25         // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	#define DT_W float2(0.015,0.025)//WH scale and cutoff
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x9E9A6000 ) //Grand Theft Auto San Andreas [GTA SA] 
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 90.0       // Near Plane Adjustment
    //#define DA_Z -1.000    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.02        // Auto Depth Protection
	#define DE_X 2          // ZPD Boundary 
	#define DE_Y 0.700    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.3125      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.4,0.20,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.25,0.75,1.5,3.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0125      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.05      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.1       // Set the Balance  
    #define DL_Y 0.25      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.125       // Compat Power

	#define WSM 2           // Weapon Setting Mode 
	#define DB_W 23         // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define WHM 1 //Weapon Hand Masking lets you use DT_Z 
	//#define DT_Z 0.375 //Masking Power
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.950  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xFC113D8A || App == 0x75A38BDA ) //PsychoNauts 2 **** //Steam //Windows Store
	#define DA_W 1
	#define DA_Y 52.5
	#define DB_Z 0.075         // Auto Depth Protection
	#define DA_X 0.05
	#define DF_Y 0.05
    #define DA_Z 0.00075    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DE_X 3
	#define DE_Y 0.85    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.3      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W 0.0      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.625,0.45,0.3,0.1)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.25,0.75,1.25,3.75)        // Like Shift Boundary DG_W But 0 to inf
	#define BMT 1    
	#define DF_Z 0.025
	#define DG_Z 0.015//Min
    #define DI_Z 0.050 //Trim

    //#define DL_Y 0.5    //De-Artifact
    //#define DL_Z 0.05       //Compat Power

	//Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 0 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.278 , 0.704 , 0.025 , 0.050) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.730 , 0.704 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 23.0, 1.0, 23.0, 27.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.196 , 0.121 , 0.500 , 0.165 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.399 , 0.084 , 0.283 , 0.051 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.165 , 0.867 , 0.639 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 27.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.278 , 0.060 , 0.500 , 0.165 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.865 , 0.685 , 0.338 , 0.107 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.025 , 0.050 , 0.856 , 0.825 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 27.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.283 , 0.051 , 0.500 , 0.165 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.867 , 0.639 , 0.338 , 0.107 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.025 , 0.050 , 0.856 , 0.825 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 28.0, 30.0, 28.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.278 , 0.060 , 0.500 , 0.165 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.865 , 0.685 , 0.060 , 0.130 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.596 , 0.060 , 0.573 , 0.625 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 29.0, 30.0, 29.0, 18.0) //Tresh Hold for Color G & H and Color 

	#define LBC 2  //Letter Box Correction Offsets With X & Y
	#define DH_Z 0.255
	#define DH_W 0.0
	#define PEW 1
	#define DAA 1
	//Smooth Mode Setting  
    #define SMS 2            //SM Toggle Separation
	#define DL_X 0.85      //SM Tune
	//#define DL_W 0.5       //SM Perspective
	#define DM_X 4           //HQ Tune
	#define DM_Z 1           //HQ Smooth
    //#define DM_Y 3           //HQ VRS
#elif (App == 0xFD3DA5A0 ) //Remnant 2
    #define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025//0.0275      // ZPD
	#define DF_Y 0.000       // Seperation
	#define DA_Y 42.0//40.0       // Near Plane Adjustment
    //#define DA_Z 0.0005    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05        // Auto Depth Protection
	#define DE_X 3          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.25,2.5,5.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0125      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.05      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.3       // Set the Balance  
    //#define DL_Y 0.25      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.125       // Compat Power
	#define DJ_X 0.028      // Range Smoothing
	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 23         // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	
    #define MAC 0 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.500 , 0.050 , 0.177 , 0.621) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.943 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 0.0, 22.0, 0.0, 0.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	

	#define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.060 , 0.345 , 0.500 , 0.050 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.500 , 0.943 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 0.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
	/*	
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	#define RHW 1
	#define NFM 1
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.825  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x31192 ) //Quake 2
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025//0.0375//0.050      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 90.0 //60.0//44.5       // Near Plane Adjustment
    //#define DA_Z 0.00025    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 4          // ZPD Boundary 
	#define DE_Y 0.800    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.6//float2(0.5,0.2)         // Fix enables if Value is > 0.0 
	#define DI_W 0.5//float2(0.5,3.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0125      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.05      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.1       // Set the Balance  
    //#define DL_Y 0.25      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.125       // Compat Power

	#define WSM 2           // Weapon Setting Mode 
	#define DB_W 9         // Weapon Profile
	#define DF_X float2(0.1125,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	#define DS_W 5.0	        // Weapon Depth Limit Location 2

	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x912AD70F ) //DeadLink
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025//0.0375//0.050      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 75.0       // Near Plane Adjustment
    #define DA_Z -1.000    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.0375        // Auto Depth Protection
	#define DE_X 4          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.625,0.5)         // Fix enables if Value is > 0.0 
	#define DI_W float2(0.0,0.25)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0125      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.05      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    #define DL_Y 0.5      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.0       // Compat Power

	#define WSM 2           // Weapon Setting Mode 
	#define DB_W 22         // Weapon Profile
	//#define DF_X float2(0.100,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 5.0	        // Weapon Depth Limit Location 2
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x7D37D662 ) //Vampire Hunters
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.025//0.0375//0.050      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 250.0       // Near Plane Adjustment
    #define DA_Z -1.000    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05        // Auto Depth Protection
	//#define DE_X 4          // ZPD Boundary 
	//#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	//#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float2(0.625,0.5)         // Fix enables if Value is > 0.0 
	//#define DI_W float2(0.0,0.25)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    #define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.5       // Set the Balance  
    //#define DL_Y 0.25      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z -1.0       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 22         // Weapon Profile
	//#define DF_X float2(0.100,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 5.0	        // Weapon Depth Limit Location 2
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/

    #define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //Main Menu Slot One and Slot 2 Options
    #define DO_X float4( 0.050 , 0.935 , 0.785 , 0.070 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.045 , 0.100 , 0.150 , 0.109 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.785 , 0.070 , 0.150 , 0.941 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 19.0, 15.0, 15.0) //Tresh Hold for Color A & B and Color
	//2nd is the in game update menu
    #define DP_X float4( 0.150 , 0.109 , 0.785 , 0.070 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.056 , 0.140 , 0.5335 , 0.858 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.700 , 0.719 , 0.042 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 15.0, 13.0, 30.0, 19.0) //Tresh Hold for Color C & D and Color
	//
	#define DQ_X float4( 0.045 , 0.100 , 0.500 , 0.125 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.084 , 0.942 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 19.0, 15.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	/*
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xA64A26C2 ) //The Door in the Basement
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025//0.0375//0.050      // ZPD
	#define DF_Y 0.00       // Seperation
	#define DA_Y 62.5       // Near Plane Adjustment
    //#define DA_Z -1.000    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 2          // ZPD Boundary 
	#define DE_Y 0.5125    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.250         // Fix enables if Value is > 0.0 
	#define DI_W 1.5        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0125      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.05      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125       // Set the Balance  
    #define DL_Y 0.5      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.0       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 22         // Weapon Profile
	//#define DF_X float2(0.100,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 5.0	        // Weapon Depth Limit Location 2
	/*
    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.646 , 0.051 , 0.307 , 0.069 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.777 , 0.069 , 0.278 , 0.246 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.760 , 0.265 , 0.322 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 21.0, 22.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xE4D2A12C ) //Scars Above *** Watch for App ID diffrence
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.0025       // Seperation
	#define DA_Y 100.0       // Near Plane Adjustment
    //#define DA_Z -1.000    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.625,0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.25,0.5,1.0,5.0)        // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125       // Set the Balance  
    #define DL_Y -0.375      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z -1.0       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 22         // Weapon Profile
	//#define DF_X float2(0.100,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 5.0	        // Weapon Depth Limit Location 2

    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.889, 0.951 , 0.500 , 0.059) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.627, 0.045 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 0.0, 24.0, 12.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.627 , 0.045 , 0.500 , 0.059 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.932 , 0.956 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 17.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xBBBECC14 ) //Need For Speed Unbound
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	//#define DF_Y 0.0025       // Seperation
	#define DA_Y 100.0       // Near Plane Adjustment
    //#define DA_Z -1.000    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05        // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.500    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.25         // Fix enables if Value is > 0.0 
	#define DI_W 1.0         // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    //#define DL_Y -0.375      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z -1.0       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 22         // Weapon Profile
	//#define DF_X float2(0.100,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 5.0	        // Weapon Depth Limit Location 2
	
    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.053, 0.124 , 0.875 , 0.120) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.075, 0.953 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 29.0, 5.0, 30.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //Map and Settings in phase one
    #define DO_X float4( 0.130 , 0.050 , 0.0235, 0.960 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.075 , 0.953 , 0.190 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.0235, 0.960 , 0.062 , 0.944 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 28.0, 27.0, 28.0, 30.0) //Tresh Hold for Color A & B and Color
	//Settings phase two
    #define DP_X float4( 0.215 , 0.050 , 0.0235, 0.960 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.062 , 0.944 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	/*
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xDB675D07 ) //Shadow of Mordor
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.02625      // ZPD
	//#define DF_Y 0.0025       // Seperation
	#define DA_Y 36.25       // Near Plane Adjustment
    #define DA_Z -0.5    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.0375       // Auto Depth Protection
	#define DE_X 3          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.1875,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,2.5,5.0)         // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.25       // Set the Balance  
    //#define DL_Y -0.375      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z -1.0       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 22         // Weapon Profile
	//#define DF_X float2(0.100,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 5.0	        // Weapon Depth Limit Location 2

	/*	
    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.053, 0.124 , 0.875 , 0.120) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.075, 0.953 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 29.0, 5.0, 30.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //Map and Settings in phase one
    #define DO_X float4( 0.130 , 0.050 , 0.0235, 0.960 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.075 , 0.953 , 0.190 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.0235, 0.960 , 0.062 , 0.944 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 28.0, 27.0, 28.0, 30.0) //Tresh Hold for Color A & B and Color
	//Settings phase two
    #define DP_X float4( 0.215 , 0.050 , 0.0235, 0.960 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.062 , 0.944 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.90  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xFF3A6B3E ) //Shadow of War
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.0125       // Seperation
	#define DA_Y 150       // Near Plane Adjustment
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05       // Auto Depth Protection
	#define DE_X 3          // ZPD Boundary 
	#define DE_Y 0.625    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,2.0,4.5)         // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    //#define DL_Y -0.375      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z -1.0       // Compat Power

	//#define WSM 2           // Weapon Setting Mode 
	//#define DB_W 22         // Weapon Profile
	//#define DF_X float2(0.100,0.185)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 5.0	        // Weapon Depth Limit Location 2

	/*	
    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.053, 0.124 , 0.875 , 0.120) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.075, 0.953 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 29.0, 5.0, 30.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	
    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //Map and Settings in phase one
    #define DO_X float4( 0.130 , 0.050 , 0.0235, 0.960 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.075 , 0.953 , 0.190 , 0.050 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.0235, 0.960 , 0.062 , 0.944 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 28.0, 27.0, 28.0, 30.0) //Tresh Hold for Color A & B and Color
	//Settings phase two
    #define DP_X float4( 0.215 , 0.050 , 0.0235, 0.960 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.062 , 0.944 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.90  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x6FC1FF71 ) //Black Mesa ****
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.040      // ZPD
	#define DF_Y 0.0125       // Seperation
	#define DA_Y 10.0       // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 2          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.075       // Auto Depth Protection
	#define DE_X 5          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.5         // Fix enables if Value is > 0.0 
	#define DI_W 0.0     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.055       // Set the Balance  
    //#define DL_Y -0.375      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z 0.125       // Compat Power

	#define WSM 5
	#define DB_W 9
	#define DF_X float2(0.1375,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	#define DS_W 1.0	        // Weapon Depth Limit Location 2
	#define FPS 1     // FPS Focus Settings 
    #define DK_X 2 //Trigger Type
    #define DK_Y 0 //Eye Selection
    #define WRP 7  //Weapon Reduction Power
    #define DK_Z 8 //World Reduction Power
    #define DK_W 3 //Set Shift Speed
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 2      //SM Toggle Separation
	#define DL_X 0.80  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0x874318FE ) //Batman Arkham Asylum
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.0375      // ZPD
	#define DF_Y 0.01       // Seperation
	#define DA_Y 25.0       // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05     // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.5         // Fix enables if Value is > 0.0 
	#define DI_W 0.5     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.175       // Set the Balance  
    #define DL_Y 0.275      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DB_Y 1.0
    #define DL_Z 0.0       // Compat Power

	//#define WSM 5
	//#define DB_W 9
	//#define DF_X float2(0.1375,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 2     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 0 //Set Shift Speed
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9375  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
	#define RHW 1
	#define DSW 1
#elif (App == 0x7CBA2E8C || App == 0x69277DAF ) // City / Origins
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025//0.0375      // ZPD
	#define DF_Y 0.0075       // Seperation
	#define DA_Y 40.5//27.5      // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05     // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.5,0.375,0.275)         // Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,1.0,1.5)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    #define DL_Y 0.25      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DB_Y 1.0
    #define DL_Z 0.0       // Compat Power

	//#define WSM 5
	//#define DB_W 9
	//#define DF_X float2(0.1375,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 2     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 0 //Set Shift Speed
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.90  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
	#define RHW 1
#elif (App == 0x83FC5C9A ) // Kingdoms of Amalur: Re-Reckoning
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.0375      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 25.0      // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.01     // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.4,0.3,0.2)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,1.5,2.5)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.075       // Set the Balance  
    #define DL_Y 0.5      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DB_Y 1.0
    //#define DL_Z 0.375       // Compat Power

	//#define WSM 5
	//#define DB_W 9
	//#define DF_X float2(0.1375,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 2     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 0 //Set Shift Speed

	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
#elif (App == 0xAC2FD3B ) // Starfield
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.005       // Seperation
	#define DA_Y 37.5//62.5      // Near Plane Adjustment
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025     // Auto Depth Protection
	#define DE_X 7          // ZPD Boundary 
	#define DE_Y 0.900    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.75,0.6,0.375,0.25)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.25,0.5,1.25,2.0)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.02      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.075      // Trim
    //#define DF_W float4(0.0001,0.0,0.75,0.0)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.250       // Set the Balance  
    //#define DL_Y 0.375      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DB_Y 1.0
    //#define DL_Z 0.375       // Compat Power

	#define WSM 4
	#define DB_W 22
	#define DF_X float2(0.125,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	#define DS_W 0.65	        // Weapon Depth Limit Location 2
	#define FPS 0     // FPS Focus Settings 
    #define DK_X 2 //Trigger Type
    #define DK_Y 0 //Eye Selection
    #define DK_Z 4 //Reduction Power
    #define DK_W 1 //Set Shift Speed
    

	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR
	#define DAA 1           
	#define PEW 1
    #define RHW 1
	#define NFM 1
    #define DSW 1    
	#define FOV 1
#elif (App == 0x6F3CE890 ) // Sinned
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    #define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.025       // Seperation
	#define DA_Y 250.0      // Near Plane Adjustment
    #define DA_Z -1.0    // Linerzation Offset
    #define DS_Y 2          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025     // Auto Depth Protection
	//#define DE_X 4          // ZPD Boundary 
	//#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	//#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float3(0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	//#define DI_W float3(0.5,1.0,2.0)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define WND 0.5
    #define DG_Z 0.05      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    #define DI_Z 0.05      // Trim
    #define DF_W float4(0.0001,0.001,0.025,0.001)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.25       // Set the Balance  
    #define DL_Y 1.0      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DB_Y 1.0
    #define DL_Z -1.0       // Compat Power

	//#define WSM 4
	//#define DB_W 22
	//#define DF_X float2(0.125,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 0     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 1 //Set Shift Speed
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR          
	#define PEW 1
    #define DSW 1
#elif (App == 0xA5FD535F )	//Escape From Tarkov
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.01         // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 255.0        // Near Plane Adjustment
    #define DA_Z -0.250       // Linerzation Offset
   // #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.0          // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.9        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 1.75          // Shift Boundary Out of screen 0.5 and or In screen -0.5
    //#define OIL 0             // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.70           // Fix enables if Value is > 0.0 
	#define DI_W 3.5          // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.020        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.500        // Auto
    #define DI_Z 0.125        // Trim
    #define DF_W float4(0.0001,0.0015,0.25,0.015)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.250        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

#elif (App == 0xB1BB8A1F )	//Taboo Trial
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.025         // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 112.5        // Near Plane Adjustment
    #define DA_Z -1.0       // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025        // Auto Depth Protection
	#define DE_X 3            // ZPD Boundary 
	#define DE_Y 0.750       // Set ZPD Boundary Level Zero 
	#define DE_Z 0.350        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W -0.250          // Shift Boundary Out of screen 0.5 and or In screen -0.5
    #define OIL 3             // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.35,0.2,0.1)           // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,0.75,1.5,5.0)          // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.020        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.500        // Auto
    //#define DI_Z 0.125        // Trim
    //#define DF_W float4(0.0001,0.0015,0.25,0.015)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.100        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	#define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.100 , 0.275 , 0.405 , 0.805 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.031 , 0.961 , 0.100 , 0.275 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.405 , 0.805 , 0.0265, 0.955 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 19.0, 21.0, 19.0, 19.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.205 , 0.012 , 0.500 , 0.975 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.627 , 0.944 , 0.206 , 0.043 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.975 , 0.688 , 0.933 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 15.0, 21.0, 24.0, 15.0) //Tresh Hold for Color C & D and Color
	
	#define DQ_X float4( 0.206 , 0.051 , 0.500 , 0.05 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.415 , 0.051 , 0.206 , 0.051 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.500 , 0.05 , 0.415 , 0.051 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 12.0, 12.0, 13.0, 13.0) //Tresh Hold for Color A1 & A3 and Color
	/*
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 5     //HQ Tune
    //#define DM_Y 3     //HQ VR          
	#define PEW 1
#elif (App == 0xF7FC15AD ) // GYLT
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.070      // Seperation
	#define DA_Y 40.0      // Near Plane Adjustment
    //#define DA_Z -1.0    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100     // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.625,0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.25,0.5,1.0,2.5)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.4375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.24875      // Trim
    //#define DF_W float4(0.0001,0.0007,0.0,0.001)// Edge & Scale
    
 //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only C has a wiled card. Not the A and C.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.095, 0.224 , 0.824 , 0.927) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.866 , 0.222 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 18.0, 18.0, 18.0, 1000.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000)           //Set Match Tresh 


    //Simple Menu Detection May add one more later
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.099 , 0.224 , 0.841 , 0.918)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.836 , 0.222 )                 //Pos C = XY 
    #define DW_Z float4( 18.0, 18.0, 18.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 


	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    //#define DL_Y 1.0      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DB_Y 1.0
    //#define DL_Z -1.0       // Compat Power

	//#define WSM 4
	//#define DB_W 22
	//#define DF_X float2(0.125,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 0     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 1 //Set Shift Speed
    

	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR          
	#define PEW 1
    #define DSW 1
#elif (App == 0x1820BE77 ) // Severed Steel
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.001      // Seperation
	#define DA_Y 175.0      // Near Plane Adjustment
    #define DA_Z -0.5    // Linerzation Offset
    #define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025     // Auto Depth Protection
	#define DE_X 4          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.5,0.375,0.250)         // Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,0.75,1.0)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.4375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.24875      // Trim
    //#define DF_W float4(0.0001,0.0007,0.0,0.001)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.17       // Set the Balance  
    #define DL_Y 0.3      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DB_Y 1.0
    //#define DL_Z -1.0       // Compat Power

	#define WSM 4
	#define DB_W 26
	//#define DF_X float2(0.125,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 0     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 1 //Set Shift Speed
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR          
	#define PEW 1
    #define DSW 1
#elif (App == 0x4249D707 || App == 0xc2762327 ) // Mafia Known as "game" WTF....
    //#define DS_Z 3          // Set View Mode
	//#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.00      // Seperation
	#define DA_Y 225.0      // Near Plane Adjustment
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.0     // Auto Depth Protection
	#define DE_X 5         // ZPD Boundary 
	#define DE_Y 0.625    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.300      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W 0.5      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
	#define OIF float4(0.5,0.250,0.125,0.075)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.5,4.0,8.0)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.4375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.24875      // Trim
    //#define DF_W float4(0.0001,0.0007,0.0,0.001)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15       // Set the Balance  
    //#define DL_Y 1.0      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DB_Y 1.0
    //#define DL_Z -1.0       // Compat Power

	#define WSM 4
	#define DB_W 27
	//#define DF_X float2(0.125,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 0     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 1 //Set Shift Speed
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.9  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 4     //HQ Tune
    //#define DM_Y 3     //HQ VR          
	#define PEW 1
    #define DSW 1
#elif (App == 0x853F522D ) // After Us
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.001      // Seperation
	#define DA_Y 125.0      // Near Plane Adjustment
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100     // Auto Depth Protection
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.50    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float3(2.5,5.0,10)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.4375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.24875      // Trim
    //#define DF_W float4(0.0001,0.0007,0.0,0.001)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.25       // Set the Balance  
    #define DL_Y 1.0      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DB_Y 1.0
    //#define DL_Z -1.0       // Compat Power
	#define DJ_X 0.085      // Range Smoothing
	//#define WSM 4
	//#define DB_W 26
	//#define DF_X float2(0.125,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 0     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 1 //Set Shift Speed
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR          
	#define PEW 1
    #define DSW 1
#elif (App == 0xEBA32DC2 ) // Oceanhorn 2: Knights of the Lost Realm 
    //#define DS_Z 3          // Set View Mode
	#define DA_W 1          // Set Linerzation
    //#define DB_X 1          // Flip
	#define DA_X 0.025      // ZPD
	//#define DF_Y 0.001      // Seperation
	#define DA_Y 75.0//68.75      // Near Plane Adjustment
    //#define DA_Z -0.5    // Linerzation Offset
    //#define DS_Y 1          // Linerzation Offset Effects only distance if true
	#define DB_Z 0.050    // Auto Depth Protection
	#define DE_X 2          // ZPD Boundary 
	#define DE_Y 0.625    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,2.5,5.0)     // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 2           // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.4375      // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.50      // Auto
    //#define DI_Z 0.24875      // Trim
    //#define DF_W float4(0.0001,0.0007,0.0,0.001)// Edge & Scale
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.10       // Set the Balance  
    //#define DL_Y 1.0      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DB_Y 1.0
    //#define DL_Z -1.0       // Compat Power
	//#define WSM 4
	//#define DB_W 26
	//#define DF_X float2(0.125,0.25)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.75	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//#define FPS 0     // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define DK_Z 4 //Reduction Power
    //#define DK_W 1 //Set Shift Speed
    
    //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.102 , 0.938 , 0.050 , 0.096) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.898 , 0.938 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 25.0, 25.0, 25.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
    
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
	//Smooth Mode Setting  
    #define SMS 3      //SM Toggle Separation
	#define DL_X 0.95  //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
    //#define DM_Y 3     //HQ VR          
	#define PEW 1
    #define DSW 1
#elif (App == 0x491EA19E ) //Cyberpunk 2077
	#define DA_W 1                   
	#define DA_X 0.025//0.030   
	#define DF_Y 0.01875//0.025       
	#define DA_Y 112.5//95.0//80.0      
    //#define DA_Z -0.0001    
	#define DB_Z 0.050      
	#define DE_X 7          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.5,0.375)         // Fix enables if Value is > 0.0 
	#define DI_W float2(0.5,1.0)     // Like Shift Boundary DG_W But 0 to inf
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.045      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power

    #define MMD 1 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.913 , 0.935 , 0.100 , 0.580 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.266 , 0.0325, 0.913 , 0.935 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.100 , 0.580 , 0.266 , 0.0325 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 23.0, 23.0, 23.0, 22.0) //Tresh Hold for Color A & B and Color
	/*
    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
	*/
	#define WSM 5           // Weapon Setting Mode 
	#define DB_W 8         // Weapon Profile
	#define DF_X float2(0.150,0)// ZPD Weapon Boundarys Level 1 and Level 2
	#define DJ_W 0.2	        // Weapon Depth Limit Location
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.85       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 2           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS
	#define DAA 1           
	#define PEW 1
#elif (App == 0x6B0CAD4C ) //Omno
	#define DA_W 1                   
	#define DA_X 0.025   
	#define DF_Y 0.002      
	#define DA_Y 90     
    //#define DA_Z -0.0001    
	#define DB_Z 0.050      
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.75,1.5,2.5,4.0)     // Like Shift Boundary DG_W But 0 to inf
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125      // Set the Balance  
    //#define DL_Y -0.50      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 1.00       // Compat Power

    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.062, 0.605 , 0.150 , 0.710) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.237, 0.605,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.275, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 30.0, 10000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
    
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.875       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 3           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
#elif (App == 0x64317982 || App == 0x1332A12F )	//Baldur's Gate 3
    #define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.0275      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 100.0         // Near Plane Adjustment
    #define DA_Z -0.75      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.6875        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.475,0.375,0.25,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.5,2.0,4.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    ///#define DG_Z 0.500        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    ///#define DI_Z 0.310        // Trim
    //#define DF_W float4(0,0,0,0)// Edge & Scale
	//Controller Map
    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.375 , 0.940 , 0.4675 , 0.933) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.699 , 0.964  ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 30.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

	#define MMD 3 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //First one is Dice Roll and Map Keyboard
    #define DO_X float4( 0.5115, 0.1015 , 0.5565 , 0.353 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.415 , 0.458 , 0.617 , 0.051 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.980 , 0.034 , 0.981 , 0.027 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 17.0, 16.0, 27.0, 25.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.617 , 0.051 , 0.980 , 0.034 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.981 , 0.027 , 0.300 , 0.050 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.640 , 0.060 , 0.640 , 0.050 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 27.0, 27.0, 30.0, 30.0) //Tresh Hold for Color C & D and Color
	
	#define DQ_X float4( 0.250 , 0.050 , 0.630 , 0.025 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.750 , 0.050 , 0.460 , 0.085 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.515 , 0.055 , 0.5755 , 0.881 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 16.0, 17.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.475 , 0.768 , 0.517 , 0.184 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.666 , 0.717 , 0.710 , 0.118 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.287 , 0.705 , 0.709 , 0.125 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 30.0, 17.0, 26.0) //Tresh Hold for Color G & H and Color 
	
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125         // Set the Balance  
    #define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	#define DB_Y 1.0
    #define DL_Z 0.25         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
    #define NDW 1
#elif (App == 0xBCD4C2DD )	//The Crew 2
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 22.5         // Near Plane Adjustment
    #define DA_Z -0.5      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.625        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.125        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.5,0.375,0.200)// Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,1.0,2.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    ///#define DG_Z 0.500        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    ///#define DI_Z 0.310        // Trim
    //#define DF_W float4(0,0,0,0)// Edge & Scale
	
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.100         // Set the Balance  
    //#define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0
    //#define DL_Z 0.25         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
    #define NDW 1
#elif (App == 0xCE96161 )	//Trine 4
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 25         // Near Plane Adjustment
    //#define DA_Z -0.5      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.800        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W -0.2        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.55,0.3)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    ///#define DG_Z 0.500        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    ///#define DI_Z 0.310        // Trim
    //#define DF_W float4(0,0,0,0)// Edge & Scale 
    //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.4065, 0.300 , 0.596 , 0.280) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.594 , 0.300 , 0.0   , 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 20.0, 1.0, 21.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
    
    #define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //Options Menu 1 and Collect 2
    #define DO_X float4( 0.643 , 0.297 , 0.459 , 0.8326) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.6435, 0.768 , 0.570 , 0.268 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.459 , 0.8326, 0.5705, 0.766 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 20.0, 20.0, 20.0, 20.0) //Tresh Hold for Color A & B and Color
    //Collect 1 and Mult Menu
    #define DP_X float4( 0.570 , 0.391 , 0.12669, 0.500) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.5705, 0.766 , 0.409 , 0.753 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.499 , 0.782 , 0.594 , 0.500 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 20.0, 20.0, 20.0, 19.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.145 , 0.321, 0.459 , 0.8326) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.857 , 0.321, 0.128 , 0.822 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.089 , 0.622 , 0.494 , 0.8655) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 19.0, 19.0, 28.0, 25.0) //Tresh Hold for Color A1 & A3 and Color
	//Main Menu and Map
	#define DR_X float4( 0.281 , 0.082 , 0.499 , 0.934 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.612 , 0.084 , 0.485 , 0.846 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.856 , 0.045 , 0.904 , 0.790 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 29.0, 30.0, 28.0, 18.0) //Tresh Hold for Color G & H and Color 
	
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.200        // Set the Balance  
    #define DL_Y 0.25        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0
    #define DL_Z 0.125         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.8       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
    #define NDW 1
	#define DAA 1
#elif (App == 0xC614B005 )	//Wo Long
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.039//0.025      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 50.0//80.0         // Near Plane Adjustment
    //#define DA_Z -0.5      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.625        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.125        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.250,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.25,2.5,5.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    ///#define DG_Z 0.500        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    ///#define DI_Z 0.310        // Trim
    //#define DF_W float4(0,0,0,0)// Edge & Scale

 //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.4295, 0.968 , 0.021 , 0.991) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.535 , 0.968 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 27.0, 1.0, 27.0, 1000.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 5 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.045 , 0.025 , 0.041 , 0.068 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.150 , 0.099 , 0.090 , 0.025 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.090 , 0.065 , 0.150 , 0.099 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 28.0, 18.0, 28.0, 18.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.129 , 0.025 , 0.129 , 0.066 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.150 , 0.099 , 0.172 , 0.025 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.168 , 0.070 , 0.150 , 0.099 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 18.0, 28.0, 18.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.213 , 0.025 , 0.215 , 0.060 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.150 , 0.099 , 0.297 , 0.025 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.299 , 0.068 , 0.150 , 0.099 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 28.0, 18.0, 28.0, 18.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.512 , 0.968 , 0.021 , 0.991 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.468 , 0.968 , 0.572 , 0.968 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.021 , 0.991 , 0.468 , 0.968 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 26.0, 27.0, 27.0, 26.0) //Tresh Hold for Color G & H and Color

	#define DU_X float4( 0.052 , 0.306 , 0.975 , 0.500 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.052 , 0.375 , 0.457 , 0.967 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.245 , 0.0025, 0.516 , 0.967 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 24.0, 24.0, 27.0, 27.0) //Tresh Hold for Color I & J and Color
	//AHHHHHH To many menus
	#define DV_X float4( 0.052 , 0.306 , 0.975 , 0.500 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.052 , 0.460 , 0.230 , 0.809 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.500 , 0.050 , 0.752 , 0.237 ) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 24.0, 24.0, 20.0, 23.0) //Tresh Hold for Color K & L and Color
	
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.0         // Set the Balance  
    #define DL_Y -0.500        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0
    //#define DL_Z 0.25         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.875       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 3           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
    #define NDW 1
	#define DAA 1
#elif (App == 0x72D62946 )	//Death in the Water 2
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 125.0         // Near Plane Adjustment
    //#define DA_Z -0.5      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.625        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.5        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float3(0.5,0.375,0.200)// Fix enables if Value is > 0.0 
	//#define DI_W float3(0.5,1.0,2.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    ///#define DG_Z 0.500        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    ///#define DI_Z 0.310        // Trim
    #define DF_W float4(0.001,0.0025,0.250,0.025)// Edge & Scale
	
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.250         // Set the Balance  
    //#define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0
    //#define DL_Z 0.25         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	#define BDF 1    //Barrel Distortion Fix k1 k2 k3 and Zoom
	#define DC_X -0.45
	#define DC_Y 0.045
	//#define DC_Z 0.000
	#define DC_W 0.045
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.90       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define NFM 1
#elif (App == 0x484F434A )	//My Friendly Neighborhood
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.030      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 200.0         // Near Plane Adjustment
    //#define DA_Z -0.5      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.75        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.5        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.55,0.4375)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    ///#define DG_Z 0.500        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    ///#define DI_Z 0.310        // Trim
    //#define DF_W float4(0.001,0.0025,0.250,0.025)// Edge & Scale
	
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.200         // Set the Balance  
    //#define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0
    //#define DL_Z 0.25         // Compat Power
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//#define BDF 1    //Barrel Distortion Fix k1 k2 k3 and Zoom
	//#define DC_X -0.45
	//#define DC_Y 0.045
	//#define DC_Z 0.000
	//#define DC_W 0.045
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DSW 1
	#define DAA 1
#elif (App == 0x7B662DE3 )	//77p egg: EggWife
    #define DS_Z 3            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.026      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 250.0         // Near Plane Adjustment
    #define DA_Z -0.25      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.1         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.5        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.5        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float2(0.55,0.4375)// Fix enables if Value is > 0.0 
	//#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    ///#define DG_Z 0.500        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    ///#define DI_Z 0.310        // Trim
    #define DF_W float4(0.001,0.000,0.250,0.0125)// Edge & Scale
	
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.277         // Set the Balance  
    //#define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0
    //#define DL_Z 0.25         // Compat Power
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//#define BDF 1    //Barrel Distortion Fix k1 k2 k3 and Zoom
	//#define DC_X -0.45
	//#define DC_Y 0.045
	//#define DC_Z 0.000
	//#define DC_W 0.045
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.90       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
#elif (App == 0xCF0D8C10 )	//Viewfinder
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.025        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 225.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    //#define DS_Y 0            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.0375        // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,2.5,5.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.043        // Trim
    //#define DF_W float4(0,0,0,0)// Edge & Scale
    
    //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 0 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.410 , 0.300 , 0.646 , 0.065) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.411 , 0.540 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match //0.535
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 0.0, 30.0, 22.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.165 , 0.296 , 0.287 , 0.180 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.932 , 0.880 , 0.111 , 0.166 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.075 , 0.728 , 0.166 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color 

    #define DP_X float4( 0.117 , 0.163 , 0.500 , 0.075 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.7315, 0.165 , 0.750 , 0.133 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.438 , 0.500 , 0.521 , 0.855 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 22.0, 22.0) //Tresh Hold for Color C & D and Color

	#define DQ_X float4( 0.242 , 0.505 , 0.500 , 0.500 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.758 , 0.505 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
/*
	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
*/
   
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.90       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DAA 1
#elif (App == 0x85512E6A )	//Dishonored 2
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.020        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 500.0         // Near Plane Adjustment
    #define DA_Z -0.5      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 3            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 5.0        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.625// Fix enables if Value is > 0.0 
	#define DI_W 7.5 // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0125        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.125        // Trim
    #define DF_W float4(0.0001,0,0,0.08625)// Edge & Scale
     
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.100        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DAA 1
#elif (App == 0x887100FB )	//Trek to Yomi // Ronin
    #define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 100.0         // Near Plane Adjustment
    //#define DA_Z -0.5      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 5.0        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.5,0.375)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.025        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    #define DI_Z 0.025        // Trim
    //#define DF_W float4(0.0001,0,0,0.08625)// Edge & Scale
     
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.175        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power

	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	#define LBC 1     //Letter Box Correction Offsets With X & Y
	//#define LBR 0
	//#define LBE 1
	//#define DH_Z 0.0
	#define DH_W -0.256
	#define LBM 1
	#define DI_X 0.875
	#define DI_Y 0.125
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DAA 1
#elif (App == 0x6C93390A )	//Lords of the Fallen
    #define DS_Z 3            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 500.0         // Near Plane Adjustment
    //#define DA_Z -0.5      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.75        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 5.0        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.250,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(1.0,2.5,3.75,6.25) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.025//0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    #define DI_Z 0.050        // Trim
    //#define DF_W float4(0.0001,0,0,0.08625)// Edge & Scale
    //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 0 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 4 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.136, 0.296 , 0.500 , 0.935) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.303, 0.295 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.91, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 29.0, 0.0, 29.0, 28.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 
	// Main menu 
    #define MMD 5 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
	// Main menus Game Setings 1080p 1440p
    #define DO_X float4( 0.038 , 0.960 , 0.500 , 0.935 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.072 , 0.0235, 0.038 , 0.960 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.935 , 0.072 , 0.0235 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 26.0, 25.0, 26.0, 26.0) //Tresh Hold for Color A & B and Color
    //Equipment Inventory Character Journal Settings and Quit menu
    #define DP_X float4( 0.0788, 0.0338, 0.500 , 0.935 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.9639, 0.0310, 0.0788, 0.0338 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.935 , 0.964 , 0.030 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 25.0, 29.0, 27.0) //Tresh Hold for Color C & D and Color
	//Help Pop Ups
	#define DQ_X float4( 0.7873 , 0.874, 0.831 , 0.896 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.936, 0.9225, 0.7873 , 0.874 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.831 , 0.896 , 0.936, 0.9225) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 19.0, 20.0, 18.0, 20.0) //Tresh Hold for Color A1 & A3 and Color
	//Level UP menu // Main menus Game Setings
	#define DR_X float4( 0.027 , 0.589 , 0.500 , 0.935 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.197 , 0.125 , 0.038 , 0.960 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.500 , 0.935 , 0.072 , 0.0235 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 21.0, 26.0, 29.0, 26.0) //Tresh Hold for Color G & H and Color 
   //Equipment Inventory Character Journal Settings and Quit menu
	#define DU_X float4( 0.0788, 0.0338, 0.500 , 0.935 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.991 , 0.0359 , 0.0788, 0.0338 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.500 , 0.935 , 0.991 , 0.035 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 30.0, 15.0, 27.0, 15.0) //Tresh Hold for Color I & J and Color
	//Help Pop Ups
	#define DV_X float4( 0.7872, 0.875 , 0.831 , 0.896 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.9362 , 0.9235 , 0.7872, 0.875 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.831 , 0.896 , 0.936, 0.9225 ) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 18.0, 20.0, 18.0, 20.0) //Tresh Hold for Color K & L and Color	

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 0.375         // Compat Power
	#define DJ_X 0.057        // Range Smoothing
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	#define LBC 1     //Letter Box Correction Offsets With X & Y
	//#define LBR 0
	//#define LBE 1
	//#define DH_Z 0.0
	#define DH_W -0.251
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.75       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DAA 1
	#define NFM 1
	#define RHW 1
#elif (App == 0x97CF825C )	//Bleak Faith: Forsaken
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.050        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 37.5         // Near Plane Adjustment
    //#define DA_Z -0.125      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.75        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 5.0        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,3.0,7.5) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.030//0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.070        // Trim
    //#define DF_W float4(0.0001,0,0,0.08625)// Edge & Scale

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.075        // Set the Balance  
    #define DL_Y 0.250        // De-Artifact Only works on some View Modes and causes performance degredation
	#define DB_Y 0.5          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//#define LBC 1     //Letter Box Correction Offsets With X & Y
	//#define LBR 0
	//#define LBE 1
	//#define DH_Z 0.0
	//#define DH_W -0.257
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.75       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DAA 1
#elif (App == 0xC2B6A79E )	//Daydream: Forgotte Sorrow
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.0255        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 193.75         // Near Plane Adjustment
    //#define DA_Z -0.125      // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.75        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 5.0        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.5,0.375)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.030//0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.070        // Trim
    //#define DF_W float4(0.0001,0,0,0.08625)// Edge & Scale

	//Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 0 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.107, 0.548 , 0.685 , 0.653) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.189 , 0.613 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 30.0, 23.0);       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000);           //Set Match Tresh 

    #define MMD 2 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.021 , 0.936 , 0.500 , 0.750 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.056 , 0.928 , 0.021 , 0.936 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.980 , 0.056 , 0.928 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color


	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.05        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//#define LBC 1     //Letter Box Correction Offsets With X & Y
	//#define LBR 0
	//#define LBE 1
	//#define DH_Z 0.0
	//#define DH_W -0.257
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.9       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DAA 1
#elif (App == 0xF297227E )	//The Quarry
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 25.0         // Near Plane Adjustment
    #define DA_Z -0.5      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 3            // ZPD Boundary 
	#define DE_Y 0.500        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.375,0.25,0.2)// Fix enables if Value is > 0.0 
	#define DI_W float3(1.0,2.0,3.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.375//0.025//0.050        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.500        // Auto
    #define DI_Z 0.0625//0.05//0.100        // Trim
    //#define DF_W float4(0.0001,0,0,0.08625)// Edge & Scale

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	#define DJ_X 0.142        // Range Smoothing
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	#define LBC 1     //Letter Box Correction Offsets With X & Y
	#define LBR 2
	#define LBE 1
	//#define DH_Z 0.0
	#define DH_W -0.259
	#define LBM 1
	#define DI_X 0.875
	#define DI_Y 0.125
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.8       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define DAA 1
#elif (App == 0x303CF2B7 )	//Bramble
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.0525        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 275.0         // Near Plane Adjustment
    #define DA_Z -0.5      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W -0.25        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.25,1.25,2.5,5.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.375//0.025//0.050        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float2(0.0025,2)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.500        // Auto
    //#define DI_Z 0.0625//0.05//0.100        // Trim
    //#define DF_W float4(0.0001,0,0,0.08625)// Edge & Scale

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.1875        // Set the Balance  
    //#define DL_Y 1.0        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	#define DJ_X 0.107        // Range Smoothing
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//#define LBC 1     //Letter Box Correction Offsets With X & Y
	//#define LBR 2
	//#define LBE 1
	//#define DH_Z 0.0
	//#define DH_W -0.259
	//#define LBM 1
	//#define DI_X 0.875
	//#define DI_Y 0.125
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 3           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1
	#define RHW 1
#elif (App == 0xE377D8F1 ) //Forza Motorsports
	#define DA_W 1
	#define DA_X 0.170
	//#define DF_Y 0.05
	#define DA_Y 19.375

	#define DA_Z -0.25  
    #define DS_Y 1            // Linerzation Offset Effects only distance if true	 
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.50        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.40        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.375        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.250,0.1625,0.100)// Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,2.5,5.0) // Like Shift Boundary DG_W But 0 to inf
	#define DG_Z 0.125 //Min
    #define DI_Z 0.050 //Trim
    //#define DF_W float4(0.0001,0.001,0.0,0.01)// Edge & Scale

	//Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 0 //Set to one only C has a wiled card. Not the A and C.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.072 , 0.061 , 0.080 , 0.087) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.207 , 0.546 , 0.500, 0.233)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 0.23, 1.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 30.0, 30.0, 16.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 0.0, 1000.0, 10000)           //Set Match Tresh 

  //Simple Menu Detection May add one more later
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.207, 0.321 , 0.076 , 0.0965)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.207 , 0.546 )                 //Pos C = XY 
    #define DW_Z float4( 30.0, 30.0, 30.0, 16.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 

    //Multi Menu Detection
    #define MMD 4 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 3 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4
    //Driver [Body and Suit] 
    #define DO_X float4( 0.071 , 0.069 , 0.477 , 0.120 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.477 , 0.164 , 0.071 , 0.069 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.525 , 0.120 , 0.525 , 0.164 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 16.0, 30.0, 16.0) //Tresh Hold for Color A & B and Color
	//Featured Multiplayer 
    #define DP_X float4( 0.076 , 0.071 , 0.325 , 0.074 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.0689 , 0.139 , 0.076 , 0.071 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.325 , 0.074 , 0.931 , 0.139 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 19.0, 30.0, 19.0) //Tresh Hold for Color C & D and Color
	//1Select Car & Quick Event
	#define DQ_X float4( 0.069 , 0.075 , 0.650 , 0.056 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.933 , 0.073 , 0.076 , 0.083 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.932 , 0.063 , 0.839 , 0.225 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 30.0, 26.0, 30.0, 26.0) //Tresh Hold for Color A1 & A3 and Color
	//Rivals [Open Time Attack | Featured]
	#define DR_X float4( 0.076 , 0.059 , 0.442 , 0.120 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.442 , 0.164 , 0.076 , 0.059 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.539 , 0.120 , 0.539 , 0.164 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 30.0, 16.0, 30.0, 16.0) //Tresh Hold for Color G & H and Color 
	//Rivals [VIP] and Fetured
	#define DU_X float4( 0.076 , 0.059 , 0.597 , 0.120 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.597 , 0.164 , 0.076 , 0.059 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.500 , 0.238 , 0.076 , 0.0925 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 30.0, 16.0 , 30.0, 30.0) //Tresh Hold for Color I & J and Color

	#define DV_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color K & L and Color
	//Welcome Center [may change over time] and Race
	#define DX_X float4( 0.083 , 0.0695 , 0.725 , 0.852 ) //Pos M1 = XY Color & M2 = ZW Black 
    #define DX_Y float4( 0.0735 , 0.098 , 0.076 , 0.070 ) //Pos M3 = XY Color & N1 = ZW Color
    #define DX_Z float4( 0.088 , 0.321 , 0.053 , 0.321 ) //Pos N2 = XY Black & N3 = ZW Color
	#define DX_W float4( 30.0, 30.0, 30.0, 16.0) //Tresh Hold for Color M & N and Color
	//Cars and Media
	#define DY_X float4( 0.069 , 0.0845 , 0.088 , 0.395 ) //Pos O1 = XY Color & O2 = ZW Black 
    #define DY_Y float4( 0.053 , 0.395 , 0.074 , 0.080 ) //Pos O3 = XY Color & P1 = ZW Color
    #define DY_Z float4( 0.088 , 0.543 , 0.053 , 0.543 ) //Pos P2 = XY Black & P3 = ZW Color
	#define DY_W float4( 30.0, 16.0, 30.0, 16.0) //Tresh Hold for Color O & P and Color
	
	#define BMT 1    
	#define DF_Z 0.111
	#define SMS 1      //SM Toggle Separation
	#define DL_X 0.875 //SM Tune
	#define DL_W 0.000 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 1     //HQ Smooth
	#define SDU 1
    #define HMT 1
	#define HMC 0.625
	#define NDW 1
	#define PEW 1
	#define DAA 1
#elif (App == 0xB4403655 ) //Elden Ring
    //#define DS_Z 4            // Set View Mode
	#define DA_W 1
    #define DA_X 0.060//0.121
    #define DF_Y 0.0//0.025
	#define DA_Y 62.0 //30.00
    #define DA_Z -0.125
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DE_X 1
	#define DE_Y 0.700
	#define DE_Z 0.375
    #define DG_W -0.125 //popout  
    #define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.6,0.5,0.375,0.25)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,0.75,1.25,2.5)        // Like Shift Boundary DG_W But 0 to inf

	#define BMT 1    
	#define DF_Z 0.05 //0.100 //0.125
    #define DL_Y 0.50      // De-Artifact Only works on some View Modes and causes performance degredation
	#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    #define DL_Z -0.5       // Compat Power
	//#define DJ_X 0.250      // Range Smoothing
    #define LBC 2     //Letter Box Correction
    #define DH_X 1.340
	//Map and Equipment
	#define MMD 4 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    #define DO_X float4( 0.051, 0.068,  0.050 , 0.955 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.935 , 0.0915,  0.040, 0.060 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.072 , 0.954 ,  0.752 , 0.112 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 20.0 , 5.0 ,  19.0  , 18.0 ) //Tresh Hold for Color A & B and Color
	// Item Crafting and Inventory
    #define DP_X float4( 0.033 , 0.046,  0.0725 , 0.954 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.345 , 0.180,  0.039 , 0.052 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.0725, 0.954 ,  0.345 , 0.180 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 20.0  , 4.0 ,  20.0  , 4.0) //Tresh Hold for Color C & D and Color
	// Status and Messages
	#define DQ_X float4( 0.042 , 0.037 , 0.0725 , 0.954 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.065 , 0.420 , 0.041 , 0.055 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.207 , 0.954 , 0.203 , 0.180 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 18.0, 19.0, 20.0, 4.0) //Tresh Hold for Color A1 & A3 and Color
	//Multi Player and System
	#define DR_X float4( 0.038 , 0.035 , 0.0725 , 0.954 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.792, 0.4145 , 0.037 , 0.058 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.207 , 0.954 , 0.611 , 0.180 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 19.0, 19.0, 16.0, 4.0) //Tresh Hold for Color G & H and Color 
/*
	#define DU_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color I & J and Color
	
	#define DV_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color K & L and Color	
*/
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.7375       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS        
    #define PEW 1 
    #define DAA 1
    #define DSW 1
#elif (App == 0x49D2CF5E ) //Lies of P
	#define DA_W 1                   
	#define DA_X 0.025   
	#define DF_Y 0.005       
	#define DA_Y 75.0     
    //#define DA_Z -0.0001    
	#define DB_Z 0.050      
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.250,0.09)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.5,2.5,3.75)     // Like Shift Boundary DG_W But 0 to inf
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125      // Set the Balance  
    #define DL_Y 0.5      // De-Artifact Only works on some View Modes and causes performance degredation
    //#define DL_Z 0.5       // Compat Power
	
	//Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 0 //Set to one only the 3rd value has a wiled card. Not the 1st and 3rd.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.062, 0.0884, 0.904 , 0.062) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.919, 0.996 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)          //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )         //Size = Menu [ABC] D E F
    #define DJ_Y float4( 20.0, 3.0, 7.0, 21.0)         //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000)           //Set Match Tresh 
	
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.891, 0.062 , 0.904 , 0.062)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.919, 0.996 )                 //Pos C = XY 
    #define DW_Z float4( 23.0,  3.0, 7.0, 1000.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 

	#define MMD 6 //Set Multi Menu Detection             //Off / On
    #define MMS 0 //Set Multi Menu Selection from 0-1 to 29-30 and Off 0 | 1 | 2
    //Character Info and Level Up
    #define DO_X float4( 0.621 , 0.056 , 0.670 , 0.400 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.760 , 0.070 , 0.082 , 0.158 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.650 , 0.7504 , 0.082 , 0.5565 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 16.0, 12.0, 25.0, 25.0) //Tresh Hold for Color A & B and Color
	// Level Up
    #define DP_X float4( 0.082 , 0.158 , 0.6431, 0.7515 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.082 , 0.5565 , 0.082 , 0.158 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.083 , 0.3413, 0.082 , 0.5565 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 25.0, 25.0, 25.0, 25.0) //Tresh Hold for Color C & D and Color
	// Select Combat Style Pop up
	#define DQ_X float4( 0.254 , 0.616 , 0.530 , 0.625 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.666 , 0.612 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 21.0, 22.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color
	//Mini Info Pop ups cards and Loading
	#define DR_X float4( 0.430 , 0.195 , 0.743 , 0.320 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.409 , 0.798 , 0.097 , 0.892 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.750 , 0.020 , 0.500 , 0.650 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 19.0, 16.0, 10.0, 20.0) //Tresh Hold for Color G & H and Color 
	//Storage 4k, 1440p & 1080p
	#define DU_X float4( 0.057, 0.141 , 0.944 , 0.0725 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.853 , 0.072 , 0.057, 0.141 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.944 , 0.07265 , 0.853 , 0.072 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 14.0, 13.0, 14.0, 13.0) //Tresh Hold for Color I & J and Color
    //Teleport Stargazer
	#define DV_X float4( 0.102 , 0.080 , 0.759 , 0.814 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.125 , 0.72665 , 0.1415 , 0.080 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.759 , 0.814 , 0.125 , 0.72665) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 23.0, 10.0, 23.0, 10.0) //Tresh Hold for Color K & L and Color	


	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.85       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 2           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS
	#define DAA 1           
	#define PEW 1
#elif (App == 0x503B2674 ) //Ratchet and Clank  Rift Apart
	#define DA_W 1                   
	#define DA_X 0.037   
	#define DF_Y 0.000       
	#define DA_Y 72.5     
    //#define DA_Z -0.0001    
	#define DB_Z 0.025      
	#define DE_X 1          // ZPD Boundary 
	#define DE_Y 0.750    // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375      // Speed that Boundary is Enforced
	//#define AFD 1         // Alternate Frame Detection - May be phased out
	//#define DG_W -0.125      // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.250,0.09)         // Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,2.5,5.0)     // Like Shift Boundary DG_W But 0 to inf
	#define BMT 1           // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125      // Set the Balance  
    //#define DL_Y 1.0      // De-Artifact Only works on some View Modes and causes performance degredation
    #define DL_Z -0.75       // Compat Power
   //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only C has a wiled card. Not the A and C.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.357, 0.034 , 0.761 , 0.160) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.418 , 0.118 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 30.0, 2.0, 28.0, 1000.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000)           //Set Match Tresh 

  //Simple Menu Detection May add one more later
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.0405, 0.9165 , 0.072 , 0.955)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.060 , 0.050 )                 //Pos C = XY 
    #define DW_Z float4( 20.0, 3.0, 12.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 

    //Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 2 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 0 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Block One
    #define DO_X float4( 0.336 , 0.859 , 0.390 , 0.065 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.858 , 0.818 , 0.888 , 0.820 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.390 , 0.065 , 0.083 , 0.868 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 29.0, 29.0, 28.0, 28.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.470 , 0.459 , 0.390 , 0.065 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.750 , 0.137 , 0.612 , 0.710 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.390 , 0.065 , 0.858 , 0.191 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 25.0, 29.0, 28.0) //Tresh Hold for Color C & D and Color
    //Block Two
	#define DQ_X float4( 0.234 , 0.117 , 0.390 , 0.065 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.850 , 0.519 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 29.0, 28.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.800       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS
	#define DAA 1           
	#define PEW 1	
#elif (App == 0xA867FE21 ) //Senran Kagura Peach Ball // Spcial Depth Trigger Needs to be reworked.To also account for DLSS Offsets if Detected.
	#define DA_Y 72.5
	#define DA_Z -0.0011
	#define DA_X 0.200
	#define DF_Y 0.200
	 
	#define DE_X 2
	#define DE_Y 0.075
	#define DE_Z 0.375
	#define HMT 1
	#define HMC 0.5
	#define SDT 1 //Spcial Depth Trigger With X & Y Offsets
    #define DG_X -0.190
    #define DG_Y 0.0 
#elif (App == 0xE6A36579 )	//The Outer Wilds 
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.015        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 101.0         // Near Plane Adjustment
    #define DA_Z -1.0         // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.830        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W -0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float2(0.5,0.375)// Fix enables if Value is > 0.0 
	//#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.0525        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    #define DI_Z 0.1875        // Trim
    //#define DF_W float4(0.0001,0.000375,0,0)// Edge & Scale

//Simple Menu Detection May add one more later
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.250, 0.007 , 0.500 , 0.085)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.750 , 0.046 )                 //Pos C = XY 
    #define DW_Z float4( 17.0, 17.0, 17.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 


	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS           
	#define PEW 1	
#elif (App == 0x6C54F60B )	//Sonic Superstars
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.26        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 10.0         // Near Plane Adjustment
    //#define DA_Z -1.0         // Linerzation Offset
    //#define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.1         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 1.0        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W -0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.005// Fix enables if Value is > 0.0 
	#define DI_W 4.5 // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.0525        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.1875        // Trim
    //#define DF_W float4(0.0001,0.000375,0,0)// Edge & Scale
  //Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 1 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 0 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Emraled Finish & Start Menu
    #define DO_X float4( 0.111 , 0.349 , 0.500 , 0.442 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.872 , 0.134 , 0.922 , 0.147 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.735 , 0.546 , 0.762 , 0.546 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 17.0, 18.0, 17.0, 18.0) //Tresh Hold for Color A & B and Color
	//Acts 4K
    #define DP_X float4( 0.376 , 0.812 , 0.900 , 0.685 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.698 , 0.832 , 0.111 , 0.349 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.500 , 0.442 , 0.872 , 0.103 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 18.0, 17.0, 18.0) //Tresh Hold for Color C & D and Color

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS
	#define DAA 1           
	#define PEW 1
    #define DSW 1
#elif (App == 0x987064F4 )	//Dead Island 2
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.020//0.0125//0.025      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 32.5//33.0//50.5//25.0         // Near Plane Adjustment
    #define DA_Z -1.0      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.035        // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.875        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.75        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.750         // Fix enables if Value is > 0.0 
	#define DI_W 1.0          // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.050        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.500        // Auto
    #define DI_Z 0.050        // Trim
    #define DF_W float4(0.0001,0.0,0.125,0.0025)// Edge & Scale
    
    //Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 2 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 0 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Menus and Death 25
    #define DO_X float4( 0.100 , 0.075 , 0.063 , 0.030 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.059 , 0.960 , 0.8125, 0.463 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.500 , 0.500 , 0.8125, 0.638 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 11.0, 30.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color
	//Main Menu and Extras
    #define DP_X float4( 0.731 , 0.325 , 0.050 , 0.950 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.9585 , 0.150 , 0.100 , 0.075 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.050 , 0.950 , 0.059 , 0.960 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 11.0, 30.0) //Tresh Hold for Color C & D and Color
    //Skills & Upgrades
	#define DQ_X float4( 0.100 , 0.075 , 0.063 , 0.030 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.834 , 0.046 , 0.100 , 0.075 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.064 , 0.031 , 0.834 , 0.046 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 11.0, 30.0, 11.0, 30.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color  
    
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.35        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//#define WSM 2             // Weapon Setting Mode 
	//#define DB_W 16           // Weapon Profile
	//#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.7625       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 2           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS          
	#define PEW 1
#elif (App == 0x20721071 )	//RoboCop 
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.0375//0.025//0.050      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 265//410.0//200.0         // Near Plane Adjustment
    #define DA_Z -0.375      // Linerzation Offset
    #define DS_Y 1            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 4            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W -0.25        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.5,0.375)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.043        // Trim
    #define DF_W float4(0,0,0,0)// Edge & Scale
     //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 0 //Set to one only C has a wiled card. Not the A and C.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.086, 0.085 , 0.500 , 0.025) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.527 , 0.085 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 18.0, 1.0, 18.0, 21.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000)           //Set Match Tresh 

   //Simple Menu Detection May add one more later
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.086, 0.085 , 0.500 , 0.025)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.527 , 0.085 )                 //Pos C = XY 
    #define DW_Z float4( 20.0, 1.0, 20.0, 19.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
   
    //Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 1 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 0 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Block One
    #define DO_X float4( 0.662 , 0.244 , 0.832 , 0.443 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.725 , 0.605 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 23.0, 10.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
    
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15        // Set the Balance  
    #define DL_Y 0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	#define DB_Y 0.5          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	#define WSM 4             // Weapon Setting Mode 
	#define DB_W 13           // Weapon Profile
	#define DF_X float2(0.125,0.250)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	//#define DS_W 1.0	        // Weapon Depth Limit Location 2


    #define FPS 2     // FPS Focus Settings 
    #define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    #define DK_Z 2 //Reduction Power
    #define DK_W 4 //Set Shift Speed
    
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.90       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS  
	#define DAA 1           
	#define PEW 1
	#define NFM 1
    #define DSW 1
#elif (App == 0x612857BB )	//Borderlands OG
    //#define DB_X 1            // Flip
	#define DA_X 0.025        // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 35.0        // Near Plane Adjustment
    //#define DA_Z -0.375      // Linerzation Offset
    #define DS_Y 3            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.6        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.4375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 1.0        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float3(0.75,0.625,0.5)// Fix enables if Value is > 0.0 
	//#define DI_W float3(1.0,1.5,2.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.025        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    #define DI_Z 0.100        // Trim
    #define DF_W float4(0.0001,0.0,0.0,0.01875)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.5        // Set the Balance  
    #define DL_Y 0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 0.5          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	#define WSM 4             // Weapon Setting Mode 
	//#define DB_W 18           // Weapon Profile
	//#define DF_X float2(0.0001,0.5)  // ZPD Weapon Boundarys Level 1 and Level 2
	//#define DJ_W 0.1	        // Weapon Depth Limit Location 1
	#define DS_W 0.5	        // Weapon Depth Limit Location 2

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.90       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS  
	#define DAA 1           
	#define PEW 1
    #define DSW 1
#elif (App == 0xC0738C5B )	//Street Fighter 6 
    #define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.250      // ZPD
	//#define DF_Y 0.00         // Seperation
	#define DA_Y 100.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    //#define DS_Y 0            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100         // Auto Depth Protection
	//#define DE_X 2            // ZPD Boundary 
	//#define DE_Y 0.700        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float2(0.5,0.375)// Fix enables if Value is > 0.0 
	//#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.043        // Trim
    //#define DF_W float4(0,0,0,0)// Edge & Scale
    
    //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only C has a wiled card. Not the A and C.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.400 , 0.122 , 0.041 , 0.971) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.600 , 0.122 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 27.0, 3.0, 27.0, 1000.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000)           //Set Match Tresh 
    
    //Simple Menu Detection May add one more later
    #define SMD 1 //If It's set to 2 it enables the  Wiled Card for A and C
    #define DW_X float4( 0.400 , 0.115 , 0.041 , 0.971)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.600 , 0.115 )                 //Pos C = XY 
    #define DW_Z float4( 27.0, 3.0, 27.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    
    //Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 2 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 1 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Stage Select 4k KB & Controller
    #define DO_X float4( 0.500 , 0.200 , 0.745 , 0.188 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.500 , 0.60925 , 0.500 , 0.200 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.745 , 0.185 , 0.500 , 0.60925 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	//Settings Menu 4k KB & Controller
    #define DP_X float4( 0.400 , 0.099 , 0.081 , 0.083 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.600 , 0.099 , 0.400 , 0.099 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.081 , 0.080 , 0.600 , 0.099 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 27.0, 27.0, 27.0, 27.0) //Tresh Hold for Color C & D and Color
    //Options Menu 4k KB & Controller
	#define DQ_X float4( 0.0295, 0.060 , 0.040 , 0.0995) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.970 , 0.106 , 0.0295, 0.060 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.040 , 0.1025, 0.970 , 0.106 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 21.0, 23.0, 21.0, 23.0) //Tresh Hold for Color A1 & A3 and Color
	//Command List Menu 4k KB & Controller
	#define DR_X float4( 0.0665, 0.191 , 0.935 , 0.203 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.900 , 0.207 , 0.0665, 0.191 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.935 , 0.200 , 0.900 , 0.207 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 22.0, 13.0, 22.0, 13.0) //Tresh Hold for Color G & H and Color 
    //Block Three

    
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.0125        // Set the Balance  
    #define DL_Y 0.125        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.75       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS  
	#define DAA 1           
	#define PEW 1
	#define NFM 1
#elif (App == 0x845698D8 )	//Armor Core 6
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 50.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    //#define DS_Y 0            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.500        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF 0.250 // Fix enables if Value is > 0.0 
	#define DI_W 1.0 // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.15        // Set the Balance  
    #define DL_Y 0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.75       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 2           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS  
	#define DAA 1           
	#define PEW 1
#elif (App == 0x29958522 )	// MGS 2 SoL
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 250.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    //#define DS_Y 0            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 6            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,2.5,25.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    //#define DG_Z 0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.043        // Trim
    //#define DF_W float4(0,0,0,0)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	#define WSM 4             // Weapon Setting Mode 
	#define DB_W 14           // Weapon Profile
	#define DF_X float2(0.001,0.270)  // ZPD Weapon Boundarys Level 1 and Level 2	
#elif (App == 0x299586D5 )	// MGS 3 SE
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 125.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    //#define DS_Y 0            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 1            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.5,0.375,0.25,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.0,2.5,7.5) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    #define DG_Z 0.0125        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.125        // Auto
    #define DI_Z 0.025        // Trim
    #define DF_W float4(0.001,0,0,0.005)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150        // Set the Balance  
    //#define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//#define WSM 4             // Weapon Setting Mode 
	//#define DB_W 15           // Weapon Profile
	//#define DF_X float2(0.125,0.250)  // ZPD Weapon Boundarys Level 1 and Level 2	
#elif ( App == 0xDA05BA00 ) //Tiny Tina's wonderlands
     //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 30.0         // Near Plane Adjustment
    #define DA_Z -0.250      // Linerzation Offset
    #define DS_Y 3            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 5            // ZPD Boundary 
	#define DE_Y 0.7        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 3.5        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float4(0.5,0.375,0.25,0.125)// Fix enables if Value is > 0.0 
	//#define DI_W float4(0.5,1.0,2.5,25.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
	#define WND 0.175         //Weapon Near Pushes depth in and adjust perspective to match.
    #define DG_Z 0.025        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.50        // Auto
    #define DI_Z 0.075//0.100        // Trim
    #define DF_W float4(0.0001,0.001,0.2,0.05)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.175        // Set the Balance  
    #define DL_Y 0.125        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    #define DL_Z -0.5         // Compat Power
	//#define WSM 4             // Weapon Setting Mode 
	#define DB_W 5           // Weapon Profile
	//#define DF_X float2(0.001,0.270)  // ZPD Weapon Boundarys Level 1 and Level 2

	//Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 3 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML -2 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Inventory & Skills S
    #define DO_X float4( 0.786 , 0.800 , 0.875 , 0.8085) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.715 , 0.850 , 0.634 , 0.920 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.732 , 0.856 , 0.446 , 0.137) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 25.0, 25.0, 25.0, 25.0) //Tresh Hold for Color A & B and Color
	//Class Select &  Customize Character S
    #define DP_X float4( 0.200 , 0.255 , 0.085 , 0.135 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.432 , 0.255 , 0.978 , 0.074 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.085 , 0.135 , 0.053 , 0.150 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 28.0, 30.0, 23.0) //Tresh Hold for Color C & D and Color
    //Hero Stats S
	#define DQ_X float4( 0.636 , 0.535 , 0.704 , 0.856 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.919 , 0.828 , 0.636 , 0.720 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.704 , 0.856 , 0.919 , 0.828 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 25.0, 24.0, 25.0, 24.0) //Tresh Hold for Color A1 & A3 and Color
	// Myth Rank WIP S 
	#define DR_X float4( 0.712 , 0.071 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
    //Journal Hero & Journal World Buffs
	#define DU_X float4( 0.396 , 0.893 , 0.0625, 0.500 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.1905, 0.204 , 0.396 , 0.893 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.0625, 0.500 , 0.235 , 0.197 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 24.0, 27.0, 24.0, 27.0) //Tresh Hold for Color I & J and Color
	// Journal Scrolls
	#define DV_X float4( 0.396 , 0.893 , 0.0625, 0.500 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.271 , 0.194 , 0.000 , 0.000 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 24.0, 27.0, 1000.0, 1000.0) //Tresh Hold for Color K & L and Color

	#define LBC 1     //Letter Box Correction Offsets With X & Y
	//#define LBR 0
	//#define LBE 1
	//#define DH_Z 0.0
	#define DH_W -0.237	
	
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS  
	#define DAA 1           
	#define PEW 1
    #define NDW 1
#elif (App == 0xEFB2EF28 ) //Remothered: Tormented Fathers
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.125      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 100.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    //#define DS_Y 2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.100         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.500        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.375,0.250)// Fix enables if Value is > 0.0 
	#define DI_W float2(1.25,2.5) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    // DG_Z 0.045        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.100        // Trim
    //#define DF_W float4(0.0001,0.001,0.125,0.055)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150        // Set the Balance  
    //#define DL_Y 0.125        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//#define WSM 4             // Weapon Setting Mode 
	//#define DB_W 5           // Weapon Profile
	//#define DF_X float2(0.001,0.270)  // ZPD Weapon Boundarys Level 1 and Level 2
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.75       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 	
	#define PEW 1
	#define FOV 1
	#define DAA 1
#elif (App == 0xD116F332 ) //Remothered: Broken Porcelain
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.030      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 100.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    //#define DS_Y 2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.050         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.5,0.250,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float3(0.5,1.25,2.5) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    // DG_Z 0.045        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.100        // Trim
    //#define DF_W float4(0.0001,0.001,0.125,0.055)// Edge & Scale
    //Simple Menu Detection May add one more later
    #define SMD 2 
    //Loading Screen One
    #define DW_X float4( 0.005, 0.8825, 0.125 , 0.125)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.080 , 0.940 )                 //Pos C = XY 
    #define DW_Z float4( 26.0, 0.0, 30.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
	//Loading Screen Two
    #define DT_X float4( 0.005, 0.8825, 0.125 , 0.125)  //Pos A = XY Any & B = ZW Lock 
    #define DT_Y float2( 0.995, 0.8825 )                 //Pos C = XY 
    #define DW_W float4( 26.0, 0.0, 26.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z.     
    //Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 1 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 1 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Video & Controls
    #define DO_X float4( 0.261 , 0.117 , 0.261 , 0.100 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.9245, 0.934 , 0.419 , 0.117 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.419 , 0.100 , 0.9245, 0.934 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color A & B and Color
	//Audio & Language
    #define DP_X float4( 0.577 , 0.117 , 0.577 , 0.100 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.9245, 0.934 , 0.730 , 0.117 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.730 , 0.100 , 0.9245, 0.934 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 30.0, 30.0, 30.0, 30.0) //Tresh Hold for Color C & D and Color 
   
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.250        // Set the Balance  
    #define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 0.5          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    #define DL_Z -0.5         // Compat Power
	
	//#define WSM 4             // Weapon Setting Mode 
	//#define DB_W 5           // Weapon Profile
	//#define DF_X float2(0.001,0.270)  // ZPD Weapon Boundarys Level 1 and Level 2
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.95       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 	
	#define PEW 1
	#define FOV 1
	#define DAA 1
#elif (App == 0x1BB6E62A ) //AMID EVIL RTX
	#define DA_W 1
	#define DA_X 0.050
    #define DF_Y 0.015
	#define DA_Y 14.5
	//#define DA_Z 0.000125
	#define DB_Z 0.050         // Auto Depth Protection
	 
	#define DE_X 4
	#define DE_Y 0.500        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.375,0.250)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.5,1.25) // Like Shift Boundary DG_W But 0 to inf

	#define BMT 1    
	#define DF_Z 0.030
	#define SMS 2      //SM Toggle Separation
	#define DL_X 0.825 //SM Tune
	//#define DL_W 0.050 //SM Perspective
	#define DM_X 3     //HQ Tune
	#define DM_Z 2     //HQ Smooth
	#define FMM 1
	#define PEW 1
	#define DAA 1
	#define DB_W 27
#elif (App == 0x11763BB7 ) //FATAL Frame Maiden of the Black Water.... Too Damn spooky....
    //#define DS_Z 2            // Set View Mode
	//#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.125      // ZPD
	#define DF_Y 0.018         // Seperation
	#define DA_Y 10.0 //12.5         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    #define DS_Y 2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.075         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.500,0.375,0.250,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.25,2.5,5.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    // DG_Z 0.045        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.100        // Trim
    //#define DF_W float4(0.0001,0.001,0.125,0.055)// Edge & Scale

    //Simple Menu Detection May add one more later
    #define SMD 1 //Off 0 | 1 | 2 
    //Book Pop Up
    #define DW_X float4( 0.613 , 0.869 , 0.500 , 0.850)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.698 , 0.869 )                 //Pos C = XY 
    #define DW_Z float4( 22.0, 0.0, 22.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    //Item Pop Up
    //#define DT_X float4( 0.689 , 0.835 , 0.768 , 0.857)  //Pos A = XY Any & B = ZW Lock 
    //#define DT_Y float2( 0.768 , 0.862 )                 //Pos C = XY 
    //#define DW_W float4( 16.0, 1.0, 22.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    
    //Multi Menu Detection                                 //4 Blocks total and 2 sub blocks per one block.
    #define MMD 1 //Set Multi Menu Detection               //Off 0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection 0-1 to 29-30  //Off 0 | 1 | 2 | 3 | 4
    #define MML 0 //Set Multi Menu Leniency  0-2 and 28-30 //Off 0 | 1 | 2 | 3 | 4    
	//Pause Menu & Options
    #define DO_X float4( 0.075 , 0.131 , 0.756 , 0.680 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.907 , 0.129 , 0.075 , 0.131 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.842 , 0.918 , 0.842 , 0.924 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 28.0, 30.0, 28.0, 22.0) //Tresh Hold for Color A & B and Color
	//Map
    #define DP_X float4( 0.075 , 0.131 , 0.875 , 0.918 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.875 , 0.924 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 28.0, 22.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
    
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150        // Set the Balance  
    #define DL_Y 0.25        // De-Artifact Only works on some View Modes and causes performance degredation
	#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	#define DJ_X 0.035        // Range Smoothing
	//#define WSM 4             // Weapon Setting Mode 
	//#define DB_W 5           // Weapon Profile
	//#define DF_X float2(0.001,0.270)  // ZPD Weapon Boundarys Level 1 and Level 2
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.875       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 	
	#define FOV 1
	#define PEW 1
	#define DAA 1
#elif (App == 0xAF6A1BF0 ) //FATAL Frame Mask ofthe Lunar
    //#define DS_Z 2            // Set View Mode
	//#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.1325      // ZPD
	#define DF_Y 0.0125         // Seperation
	#define DA_Y 12.5         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    #define DS_Y 2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.075         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.125        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 3           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float4(0.500,0.375,0.250,0.125)// Fix enables if Value is > 0.0 
	#define DI_W float4(0.5,1.25,2.5,5.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    // DG_Z 0.045        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.100        // Trim
    //#define DF_W float4(0.0001,0.001,0.125,0.055)// Edge & Scale

    //Simple Menu Detection May add one more later
    #define SMD 2 //Off 0 | 1 | 2 
    #define DW_X float4( 0.382, 0.202 , 0.701 , 0.865)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.617 , 0.279 )                 //Pos C = XY 
    #define DW_Z float4( 21.0, 0.0, 21.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    
    #define DT_X float4( 0.058, 0.143 , 0.898 , 0.933)  //Pos A = XY Any & B = ZW Lock 
    #define DT_Y float2( 0.162 , 0.044 )                 //Pos C = XY 
    #define DW_W float4( 22.0, 0.0, 22.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 

  //Multi Menu Detection                      //4 Blocks total and 2 sub blocks per one block.
    #define MMD 1 //Set Multi Menu Detection  // Off  0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection  // Off  0 | 1 | 2 | 3 | 4                       //0-2 check to 28-30 check Depnding on the option MML
    #define MML -1 //Set Multi Menu Leniency   // -4 |-3 |-2 |-1 | Off | 1 | 2 | 3 | 4         //Negitive [0 & 30] No Leniency | Zero [0-1 & 29-30] Some Leniency | Positive [0-2 & 28-30] Most Leniency  
	//Block One
    #define DO_X float4( 0.058 , 0.144 , 0.875 , 0.933 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.162 , 0.044 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 22.0, 22.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color

    
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.150        // Set the Balance  
    #define DL_Y 0.25        // De-Artifact Only works on some View Modes and causes performance degredation
	#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	#define DJ_X 0.035        // Range Smoothing
	//#define WSM 4             // Weapon Setting Mode 
	//#define DB_W 5           // Weapon Profile
	//#define DF_X float2(0.001,0.270)  // ZPD Weapon Boundarys Level 1 and Level 2
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.875       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 	
	#define FOV 1
	#define PEW 1
	#define DAA 1
#elif (App == 0xC770832 || App == 0x3E42619F )	//Wolfenstein: The New Order | The Old Blood
    //#define DS_Z 2            // Set View Mode
	//#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.050//0.040//0.035//0.050      // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 30.0//32.0//36.0//25.0         // Near Plane Adjustment
    #define DA_Z 0.001      // Linerzation Offset
    #define DS_Y 2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 5            // ZPD Boundary 
	#define DE_Y 0.550        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W -0.125        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 2           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float3(0.450,0.350,0.250)// Fix enables if Value is > 0.0 
	#define DI_W float3(0.25,0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    // DG_Z 0.045        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.100        // Trim
    //#define DF_W float4(0.0001,0.001,0.125,0.055)// Edge & Scale

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.250        // Set the Balance  
    #define DL_Y 0.125        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    #define DL_Z 0.125         // Compat Power
	//#define DJ_X 0.02        // Range Smoothing
	#define WSM 5
	#define DB_W 7
	#define DF_X float2(0.275,0.300)  // ZPD Weapon Boundarys Level 1 and Level 2
	#define DJ_W 0.5	        // Weapon Depth Limit Location 1
	#define DS_W 2.5	        // Weapon Depth Limit Location 2
	#define WFB 0.5          // ZPD Weapon Elevaton for 1 and 2
	//#define WHM 1               //Weapon Hand Masking lets you use DT_Z 
	//#define DT_Z 3.75            //WH Masking Power

    #define FPS 2  // FPS Focus Settings 
    #define DK_X 2 //Trigger Type
    #define DK_Y 0 //Eye Selection
    #define WRP 6  //Weapon Reduction Power
    #define DK_Z 8 //World Reduction Power
    #define DK_W 3 //Set Shift Speed	
	
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.900       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 	
	#define FOV 1
	#define PEW 1
#elif (App == 0x60F43F45 ) //Resident Evil 7
   //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.050         // ZPD
	#define DF_Y 0.075         // Seperation
	#define DA_Y 20.0         // Near Plane Adjustment
    #define DA_Z -0.250 //0.0004      // Linerzation Offset
    #define DS_Y 1 //2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.500        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.600        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.375,0.250)// Fix enables if Value is > 0.0 
	#define DI_W float2(1.25,2.5) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    // DG_Z 0.045        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.100        // Trim
    #define DF_W float4(0.0001,0.001,0.0,0.100)// Edge & Scale

    //Multi Menu Detection                    //4 Blocks total and 2 sub blocks per one block.
    #define MMD 2 //Set Multi Menu Detection  // Off  0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection  // Off  0 | 1 | 2 | 3 | 4                       //0-2 check to 28-30 check Depnding on the option MML
    #define MML -2 //Set Multi Menu Leniency   // -4 |-3 |-2 |-1 | Off | 1 | 2 | 3 | 4         //Negitive [0 & 30] No Leniency | Zero [0-1 & 29-30] Some Leniency | Positive [0-2 & 28-30] Most Leniency    
	//Pause Menu & Options
    #define DO_X float4( 0.7605, 0.2175, 0.500 , 0.330 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.2395, 0.680 , 0.079 , 0.518 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.392 , 0.500 , 0.339 , 0.184 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 18.0, 18.0, 18.0, 18.0) //Tresh Hold for Color A & B and Color
	//Controls / Display / Display / Audio / Language / Graphics
    #define DP_X float4( 0.4015, 0.184, 0.392 , 0.500 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.9225, 0.740 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 18.0, 18.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
    //Files & Map 
	#define DQ_X float4( 0.6305, 0.0645, 0.472 , 0.500 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.161 , 0.815 , 0.6305, 0.0645) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.369 , 0.500 , 0.3765, 0.753 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 18.0, 18.0, 18.0, 18.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.50        // Set the Balance  
    #define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    //#define DL_Z 1.00         // Compat Power
	//#define DJ_X 0.02        // Range Smoothing

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.950       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 

	#define BDF 1
	#define DC_X 0.25
	#define DC_Y 0.1
	#define DC_Z -0.0625
	#define DC_W -0.049
	#define RHW 1
	#define PEW 1
	#define DAA 1
#elif (App == 0x21DC397E || App == 0x653AF1E1) //Gold Source AKA HL
    //#define DS_Z 2            // Set View Mode
	//#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025         // ZPD
	#define DF_Y 0.100         // Seperation
	#define DA_Y 25.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    #define DS_Y 2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.025         // Auto Depth Protection
	#define DE_X 7            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.400        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.100        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.500,0.250)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.50,2.5) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
    // DG_Z 0.045        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    //#define DI_Z 0.100        // Trim
    //#define DF_W float4(0.0001,0.001,0.125,0.055)// Edge & Scale

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.050        // Set the Balance  
    #define DL_Y 0.25        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    #define DL_Z 0.25         // Compat Power
	//#define DJ_X 0.02        // Range Smoothing
	#define WSM 3
	#define DB_W 9	
	
	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 	
	#define FOV 1
#elif (App == 0x4D177616) //Immortals of Aveum Demo
    //#define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    //#define DB_X 1            // Flip
	#define DA_X 0.025         // ZPD
	#define DF_Y 0.000         // Seperation
	#define DA_Y 75.0         // Near Plane Adjustment
    //#define DA_Z -0.0001      // Linerzation Offset
    #define DS_Y 2            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	//#define DE_X 7            // ZPD Boundary 
	#define DE_Y 0.750        // Set ZPD Boundary Level Zero 
	//#define DE_Z 0.400        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	//#define DG_W 0.100        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    #define OIF float2(0.500,0.250)// Fix enables if Value is > 0.0 
	#define DI_W float2(0.50,2.5) // Like Shift Boundary DG_W But 0 to inf
	//#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
	#define DG_Z 0.050        // Min Weapon Hands That are apart of world with Auto and Trim
    //#define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    //#define DE_W 0.250        // Auto
    #define DI_Z 0.050        // Trim
    #define DF_W float4(0.0001,0.0,0.0,0.050)// Edge & Scale

	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.100        // Set the Balance  
    #define DL_Y 0.5        // De-Artifact Only works on some View Modes and causes performance degredation
	//#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    #define DL_Z -1.0         // Compat Power
	//#define DJ_X 0.02        // Range Smoothing

	//Smooth Mode Setting
    #define SMS 3           //SM Toggle Separation
	#define DL_X 0.925       //SM Tune
	//#define DL_W 0.05       //SM Perspective
	#define DM_X 4           //HQ Tune
	//#define HQT 1           //HQ Trigger
    //#define DM_Y 3     //HQ VRS 	
	#define FOV 1
	#define NFM 1
	#define DAA 1 
    #define DSW 1
#else
	#define NPW 1 //No Profile
#endif

/* //Template Start
#elif (App == 0x77777777 )	//Game Name 
    #define DS_Z 2            // Set View Mode
	#define DA_W 1            // Set Linerzation
    #define DB_X 1            // Flip
	#define DA_X 0.01625      // ZPD
	#define DF_Y 0.00         // Seperation
	#define DA_Y 30.0         // Near Plane Adjustment
    #define DA_Z -0.0001      // Linerzation Offset
    #define DS_Y 0            // Linerzation Offset Effects only distance if true
	#define DB_Z 0.05         // Auto Depth Protection
	#define DE_X 2            // ZPD Boundary 
	#define DE_Y 0.700        // Set ZPD Boundary Level Zero 
	#define DE_Z 0.375        // Speed that Boundary is Enforced
	//#define AFD 1           // Alternate Frame Detection - May be phased out
	#define DG_W 0.250        // Shift Boundary Out of screen 0.5 and or In screen -0.5
	//#define OIL 1           // Set How many Levels We use for RE_Fix 0 | 1 | 2 | 3 if 1 then it's float2(0,0) for OIF and DI_W
    //#define OIF float2(0.5,0.375)// Fix enables if Value is > 0.0 
	//#define DI_W float2(0.5,1.0) // Like Shift Boundary DG_W But 0 to inf
	#define FTM 0             // Fast Trigger Mode If this enabled then Level 1 and > switches instantly.
	#define WND 0.175         //Weapon Near Pushes depth in and adjust perspective to match.
    #define DG_Z 0.100        // Min Weapon Hands That are apart of world with Auto and Trim
    #define DS_X float3(0.025,0,1)// Min Weapon bit only triggers when a OIL Level is set and set here on .y
    #define DE_W 0.250        // Auto
    #define DI_Z 0.043        // Trim
    #define DF_W float4(0,0,0,0)// Edge & Scale
	#define BMT 1             // ZPD and World Scale Balance // I need to phase this out.
	#define DF_Z 0.125        // Set the Balance  
    #define DL_Y -0.50        // De-Artifact Only works on some View Modes and causes performance degredation
	#define DB_Y 1.0          // Effects De-Artifacts -1 to 1 Most of the time leave this at 0 and if you set 1 it takes depth into account 
    #define DL_Z 1.00         // Compat Power
	#define DJ_X 0.250        // Range Smoothing
	#define WSM 2             // Weapon Setting Mode 
	#define DB_W 16           // Weapon Profile
	#define DF_X float2(0,0)  // ZPD Weapon Boundarys Level 1 and Level 2
	#define DJ_W 0.1	      // Weapon Depth Limit Location 1
	#define DS_W 1.0	      // Weapon Depth Limit Location 2
	#define WFB 0.0          // ZPD Weapon Elevaton for 1 and 2 scales from [0 - 1]
	#define DT_W float2(0.015,0.03)//WH scale and cutoff
	#define WHM 1               //Weapon Hand Masking lets you use DT_Z 
	#define DT_Z 0.1            //WH Masking Power
*/ 
/* // Warnings
	#define DAA 1           
    #define NDW 1
	#define PEW 1
    #define RHW 1
	#define NFM 1
    #define DSW 1
*/

/* //Menu Detection Templates -  Needs a Specail Shader to adjust
    #define MAC 1 //Set to one only C has a wiled card. Not the A and C.
    #define MDD 1 //Set Menu Detection & Direction      //Off | 1 | 2 | 3 | 4      
    #define DN_X float4( 0.8835, 0.956 , 0.982 , 0.954) //Pos A = XY Any & B = ZW Lock 
    #define DN_Y float4( 0.500 , 0.004 ,  0.0, 0.0)     //Pos C = XY Any & D = ZW Match
    #define DN_Z float4( 0.0, 0.0,  0.0, 0.0)           //Pos E = XY Match & F = ZW Match
	#define DN_W float4( 1.0, 0.0 , 0.0, 0.0 )          //Size = Menu [ABC] D E F
    #define DJ_Y float4( 28.0, 28.0, 20.0, 14.0)       //Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    #define DJ_Z float3( 1000., 1000., 1000)           //Set Match Tresh 
*/
/*  //Simple Menu Detection May add one more later
    #define SMD 0 //Off 0 | 1 | 2 
    #define DW_X float4( 0.8835, 0.956 , 0.982 , 0.954)  //Pos A = XY Any & B = ZW Lock 
    #define DW_Y float2( 0.500 , 0.004 )                 //Pos C = XY 
    #define DW_Z float4( 1000.0, 1000.0, 1000.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
    
    #define DT_X float4( 0.8835, 0.956 , 0.982 , 0.954)  //Pos A = XY Any & B = ZW Lock 
    #define DT_Y float2( 0.500 , 0.004 )                 //Pos C = XY 
    #define DW_W float4( 1000.0, 1000.0, 1000.0, 1000.0)//Menu Detection Type for A = X, B = Y, & C = Z. The Last Value is a Wild Card amount W is for X and Z. 
*/
/*  //Multi Menu Detection                    //4 Blocks total and 2 sub blocks per one block.
    #define MMD 1 //Set Multi Menu Detection  // Off  0 | 1 | 2 | 3 | 4
    #define MMS 0 //Set Multi Menu Selection  // Off  0 | 1 | 2 | 3 | 4                       //0-2 check to 28-30 check Depnding on the option MML
    #define MML 0 //Set Multi Menu Leniency   // -4 |-3 |-2 |-1 | Off | 1 | 2 | 3 | 4         //Negitive [0 & 30] No Leniency | Zero [0-1 & 29-30] Some Leniency | Positive [0-2 & 28-30] Most Leniency    
	//Block One
    #define DO_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A1 = XY Color & A2 = ZW Black 
    #define DO_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos A3 = XY Color & B1 = ZW Color
    #define DO_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos B2 = XY Black & B3 = ZW Color
	#define DO_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A & B and Color

    #define DP_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DP_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DP_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DP_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color C & D and Color
    //Block Two
	#define DQ_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C1 = XY Color & C2 = ZW Black 
    #define DQ_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos C3 = XY Color & D1 = ZW Color
    #define DQ_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos D2 = XY Black & D3 = ZW Color
	#define DQ_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color A1 & A3 and Color

	#define DR_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G1 = XY Color & G2 = ZW Black 
    #define DR_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos G3 = XY Color & H1 = ZW Color
    #define DR_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos H2 = XY Black & H3 = ZW Color
	#define DR_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color G & H and Color 
    //Block Three
	#define DU_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos I1 = XY Color & I2 = ZW Black 
    #define DU_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos I3 = XY Color & J1 = ZW Color
    #define DU_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos J2 = XY Black & J3 = ZW Color
	#define DU_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color I & J and Color
	
	#define DV_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos K1 = XY Color & K2 = ZW Black 
    #define DV_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos K3 = XY Color & L1 = ZW Color
    #define DV_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos L2 = XY Black & L3 = ZW Color
	#define DV_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color K & L and Color
	//Block Four
	#define DX_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos M1 = XY Color & M2 = ZW Black 
    #define DX_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos M3 = XY Color & N1 = ZW Color
    #define DX_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos N2 = XY Black & N3 = ZW Color
	#define DX_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color M & N and Color
	
	#define DY_X float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos O1 = XY Color & O2 = ZW Black 
    #define DY_Y float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos O3 = XY Color & P1 = ZW Color
    #define DY_Z float4( 0.000 , 0.000 , 0.000 , 0.000 ) //Pos P2 = XY Black & P3 = ZW Color
	#define DY_W float4( 1000.0, 1000.0, 1000.0, 1000.0) //Tresh Hold for Color O & P and Color	
*/
/* Miscellaneous Depth Buffer Corrections
	//#define HMT 1     //HUD Mode Trigger
	//#define HMC 2.5
    //#define HMD 0.350
    
	//#define LBC 1     //Letter Box Correction Offsets With X & Y
	//#define LBR 0
	//#define LBE 1
	//#define DH_Z 0.0
	//#define DH_W -0.237
	
	//#define LBM 1 //Letter Box Masking With size Adust for Top and Bottom
	//#define DI_X 0.875
	//#define DI_Y 0.125
	
    //#define FPS 2  // FPS Focus Settings 
    //#define DK_X 2 //Trigger Type
    //#define DK_Y 0 //Eye Selection
    //#define WRP 3  //Weapon Reduction Power
    //#define DK_Z 3 //World Reduction Power
    //#define DK_W 3 //Set Shift Speed
    
	//#define BDF 1    //Barrel Distortion Fix k1 k2 k3 and Zoom
	//#define DC_X 0.00
	//#define DC_Y 0.115
	//#define DC_Z 0.000
	//#define DC_W -0.035
*/
/* //Smooth Mode [ Do Not Use ]
    //#define SMS 3         //SM Separation Limit
	//#define DL_X 0.9125   //SM Tune Limit
	//#define DL_W 0.5      //SM Perspective Limit
	//#define DM_X 0        //SM HQ Tune Power
    //#define DM_Y 3        //SM HQ VRS Limit
	//#define HQT 1         //SM HQ Trigger
	//#define FMM 1         //Filter Mode
*/
//Change Output
//#ifndef checks whether the given token has been #defined earlier in the file or in an included file
// X = [ZPD] Y = [Depth Adjust] Z = [Offset] W = [Depth Linearization]
#ifndef DA_X
    #define DA_X ZPD_D
#endif
#ifndef DA_Y
    #define DA_Y Depth_Adjust_D
#endif
#ifndef DA_Z
    #define DA_Z Offset_D
#endif
#ifndef DA_W
    #define DA_W Depth_Linearization_D
#endif

// X = [Depth Flip] Y = [De-Artifact Scale] Z = [Auto Depth] W = [Weapon Hand]
#ifndef DB_X
    #define DB_X Depth_Flip_D
#endif
#ifndef DB_Y
    #define DB_Y De_Artifact_Scale_D
#endif
#ifndef DB_Z
    #define DB_Z Auto_Depth_D
#endif
#ifndef DB_W
    #define DB_W Weapon_Hand_D
#endif

// X = [HUD] Y = [Barrel Distortion K1] Z = [Barrel Distortion K2] W = [Barrel Distortion Zoom]
#ifndef DC_X
    #define DC_X BD_K1_D
#endif
#ifndef DC_Y
    #define DC_Y BD_K2_D
#endif
#ifndef DC_Z
    #define DC_Z BD_K3_D
#endif
#ifndef DC_W
    #define DC_W BD_Zoom_D
#endif

// X = [Horizontal Size] Y = [Vertical Size] Z = [Horizontal Position] W = [Vertical Position]
#ifndef DD_X
    #define DD_X HVS_X_D
#endif
#ifndef DD_Y
    #define DD_Y HVS_Y_D
#endif
#ifndef DD_Z
    #define DD_Z HVP_X_D
#endif
#ifndef DD_W
    #define DD_W HVP_Y_D
#endif

// X = [ZPD Boundary Type] Y = [ZPD Boundary Scaling] Z = [ZPD Boundary Fade Time] W = [Weapon NearDepth Max]
#ifndef DE_X
    #define DE_X ZPD_Boundary_Type_D
#endif
#ifndef DE_Y
    #define DE_Y ZPD_Boundary_Scaling_D
#endif
#ifndef DE_Z
    #define DE_Z ZPD_Boundary_Fade_Time_D
#endif
#ifndef DE_W
    #define DE_W Weapon_Near_Depth_Max_D          //Max
#endif

// X = [ZPD Weapon Boundary] Y = [Separation] Z = [ZPD Balance] W = [Weapon Edge Correction]
#ifndef DF_X
    #define DF_X ZPD_Weapon_Boundary_Adjust_D
#endif
#ifndef DF_Y
    #define DF_Y Separation_D
#endif
#ifndef DF_Z
    #define DF_Z Manual_ZPD_Balance_D
#endif
#ifndef DF_W
    #define DF_W Weapon_Edge_Correction_D
#endif

// X = [Special Depth Correction X] Y = [Special Depth Correction Y] Z = [Weapon NearDepth Min] W = [Check Depth Limit]
#ifndef DG_X
    #define DG_X SDC_Offset_X_D
#endif
#ifndef DG_Y
    #define DG_Y SDC_Offset_Y_D
#endif
#ifndef DG_Z
    #define DG_Z Weapon_Near_Depth_Min_D         //Min
#endif
#ifndef DG_W
	#define DG_W Check_Depth_Limit_D
#endif

// X = [LBD Size Correction Offset X] Y = [LBD Size Correction Offset Y] Z = [LBD Pos Correction Offset X] W = [LBD Pos Correction Offset Y]
#ifndef DH_X
    #define DH_X LB_Depth_Size_Offset_X_D
#endif
#ifndef DH_Y
    #define DH_Y LB_Depth_Size_Offset_Y_D
#endif
#ifndef DH_Z
    #define DH_Z LB_Depth_Pos_Offset_X_D
#endif
#ifndef DH_W
	#define DH_W LB_Depth_Pos_Offset_Y_D
#endif

// X = [LBM Offset X] Y = [LBM Offset Y] Z = [Weapon Near Depth Trim] W = [OIF Check Depth Limit]
#ifndef DI_X
    #define DI_X LB_Masking_Offset_X_D
#endif
#ifndef DI_Y
    #define DI_Y LB_Masking_Offset_Y_D
#endif
#ifndef DI_Z
    #define DI_Z Weapon_Near_Depth_Trim_D       //Trim
#endif 
#ifndef DI_W
	#define DI_W OIF_Check_Depth_Limit_D
#endif

// X = [Range Smoothing X] Y = [Menu Detection Type] Z = [Match Threshold] W = [Check Depth Limit Weapon Primary]
#ifndef DJ_X
    #define DJ_X Range_Smoothing_D
#endif
#ifndef DJ_Y
    #define DJ_Y Menu_Detection_Type_D
#endif
#ifndef DJ_Z
    #define DJ_Z Match_Threshold_D
#endif 
#ifndef DJ_W
	#define DJ_W Check_Weapon_Depth_Limit_A_D
#endif

// X = [FPS Focus Method] Y = [Eye Eye Selection] Z = [Eye Fade Selection] W = [Eye Fade Speed Selection]
#ifndef DK_X
    #define DK_X FPS_Focus_Method_D
#endif
#ifndef DK_Y
    #define DK_Y EFO_Eye_Selection_D
#endif
#ifndef DK_Z
    #define DK_Z EFO_Fade_Selection_D
#endif 
#ifndef DK_W
	#define DK_W EFO_Fade_Speed_Selection_D
#endif
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// X = [SM Tune] Y = [De-Artifact] Z = [Compatibility Power] W = [SM Perspective]
#ifndef DL_X
    #define DL_X SM_Tune_D
#endif
#ifndef DL_Y
    #define DL_Y De_Artifact_D
#endif
#ifndef DL_Z
    #define DL_Z Compatibility_Power_D
#endif 
#ifndef DL_W
	#define DL_W SM_Perspective_D
#endif

// X = [HQ Tune] Y = [HQ VRS] Z = [HQ Smooth] W = [HQ Trim]
#ifndef DM_X
    #define DM_X HQ_Tune_D
#endif
#ifndef DM_Y
    #define DM_Y HQ_VRS_D
#endif
#ifndef DM_Z
    #define DM_Z HQ_Smooth_D
#endif 
#ifndef DM_W
	#define DM_W HQ_Trim_D 
#endif
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// X = [Position A & B] Y = [Position C & D] Z = [Position E & F] W = [Menu Size Main]
#ifndef DN_X
    #define DN_X Pos_XY_XY_A_B_D
#endif
#ifndef DN_Y
    #define DN_Y Pos_XY_XY_C_D_D
#endif
#ifndef DN_Z
    #define DN_Z Pos_XY_XY_E_F_D
#endif 
#ifndef DN_W
	#define DN_W Menu_Size_Adjust_D 
#endif

// X = [Position A & A] Y = [Position A & B] Z = [Position B & B] W = [AB Menu Tresholds]
#ifndef DO_X
    #define DO_X Pos_XY_XY_AA_D
#endif
#ifndef DO_Y
    #define DO_Y Pos_XY_XY_AB_D
#endif
#ifndef DO_Z
    #define DO_Z Pos_XY_XY_BB_D
#endif 
#ifndef DO_W
	#define DO_W Simple_Menu_Tresh_AB_D
#endif

// X = [Position C & C] Y = [Position C & D] Z = [Position D & D] W = [CD Menu Tresholds]
#ifndef DP_X
    #define DP_X Pos_XY_XY_CC_D
#endif
#ifndef DP_Y
    #define DP_Y Pos_XY_XY_CD_D
#endif
#ifndef DP_Z
    #define DP_Z Pos_XY_XY_DD_D
#endif 
#ifndef DP_W
	#define DP_W Simple_Menu_Tresh_CD_D
#endif

// X = [Position E & E] Y = [Position E & F] Z = [Position F & F] W = [EF Menu Tresholds]
#ifndef DQ_X
    #define DQ_X Pos_XY_XY_EE_D
#endif
#ifndef DQ_Y
    #define DQ_Y Pos_XY_XY_EF_D
#endif
#ifndef DQ_Z
    #define DQ_Z Pos_XY_XY_FF_D
#endif 
#ifndef DQ_W
	#define DQ_W Simple_Menu_Tresh_EF_D
#endif

// X = [Position G & G] Y = [Position G & H] Z = [Position H & H] W = [GH Menu Tresholds]
#ifndef DR_X
    #define DR_X Pos_XY_XY_GG_D
#endif
#ifndef DR_Y
    #define DR_Y Pos_XY_XY_GH_D
#endif
#ifndef DR_Z
    #define DR_Z Pos_XY_XY_HH_D
#endif 
#ifndef DR_W
	#define DR_W Simple_Menu_Tresh_GH_D
#endif

// X = [Weapon NearDepth Min OIL] Y = [Depth Range Boost] Z = [View Mode State] W = [Check Depth Limit Weapon Secondary]
#ifndef DS_X
    #define DS_X OIL_Weapon_Near_Depth_Min_D
#endif
#ifndef DS_Y
    #define DS_Y Depth_Range_D
#endif
#ifndef DS_Z
    #define DS_Z View_Mode_State_D
#endif 
#ifndef DS_W
	#define DS_W Check_Weapon_Depth_Limit_B_D
#endif

// X = [NULL X] Y = [NULL Y] Z = [Weapon Hand Masking Adjust] W = [Rescale Weapon Hand Near]
#ifndef DT_X
    #define DT_X B_SPos_XY_XY_A_B_D
#endif
#ifndef DT_Y
    #define DT_Y B_SPos_XY_C_D
#endif
#ifndef DT_Z
    #define DT_Z WH_Masking_Adjust_D
#endif 
#ifndef DT_W
	#define DT_W Rescale_WH_Near_D
#endif

// X = [Position I & I] Y = [Position I & J] Z = [Position J & J] W = [IJ Menu Tresholds]
#ifndef DU_X
    #define DU_X Pos_XY_XY_II_D
#endif
#ifndef DU_Y
    #define DU_Y Pos_XY_XY_IJ_D
#endif
#ifndef DU_Z
    #define DU_Z Pos_XY_XY_JJ_D
#endif 
#ifndef DU_W
	#define DU_W Simple_Menu_Tresh_IJ_D
#endif

// X = [Position K & K] Y = [Position K & L] Z = [Position L & L] W = [KL Menu Tresholds]
#ifndef DV_X
    #define DV_X Pos_XY_XY_KK_D
#endif
#ifndef DV_Y
    #define DV_Y Pos_XY_XY_KL_D
#endif
#ifndef DV_Z
    #define DV_Z Pos_XY_XY_LL_D
#endif 
#ifndef DV_W
	#define DV_W Simple_Menu_Tresh_KL_D
#endif

// X = [Position A & B] Y = [Position C] Z = [ABCW Menu Tresholds] W = [NULL W]
#ifndef DW_X
    #define DW_X A_SPos_XY_XY_A_B_D
#endif
#ifndef DW_Y
    #define DW_Y A_SPos_XY_C_D
#endif
#ifndef DW_Z
    #define DW_Z A_Menu_Tresh_n_WC_D
#endif 
#ifndef DW_W
	#define DW_W B_Menu_Tresh_n_WC_D
#endif

// X = [Position M & M] Y = [Position M & N] Z = [Position N & N] W = [MN Menu Tresholds]
#ifndef DX_X
    #define DX_X Pos_XY_XY_MM_D
#endif
#ifndef DX_Y
    #define DX_Y Pos_XY_XY_MN_D
#endif
#ifndef DX_Z
    #define DX_Z Pos_XY_XY_NN_D
#endif 
#ifndef DX_W
	#define DX_W Simple_Menu_Tresh_MN_D
#endif

// X = [Position O & O] Y = [Position O & P] Z = [Position P & P] W = [OP Menu Tresholds]
#ifndef DY_X
    #define DY_X Pos_XY_XY_OO_D
#endif
#ifndef DY_Y
    #define DY_Y Pos_XY_XY_OP_D
#endif
#ifndef DY_Z
    #define DY_Z Pos_XY_XY_PP_D
#endif 
#ifndef DY_W
	#define DY_W Simple_Menu_Tresh_OP_D
#endif

// X = [Null X] Y = [Null Y] Z = [Null Z] W = [Null W]
#ifndef DZ_X
    #define DZ_X Null_X_D
#endif
#ifndef DZ_Y
    #define DZ_Y Null_Y_D
#endif
#ifndef DZ_Z
    #define DZ_Z Null_Z_D
#endif 
#ifndef DZ_W
	#define DZ_W Null_W_D
#endif

//Special Settings
#ifndef OIL
    #define OIL Over_Intrusion_Level_D         //Over Intrusion Level
#endif
#ifndef OIF
    #define OIF Over_Intrusion_Fix_D           //Over Intrusion Fix  
#endif
#ifndef FTM
    #define FTM Fast_Trigger_Mode_D            //Fast Trigger Mode  
#endif
#ifndef REF
    #define REF Resident_Evil_Fix_D            //Resident Evil Fix
#endif
#ifndef ABE
    #define ABE Auto_Balance_Ex_LvL_D          //Inverted Depth Fix
#endif
#ifndef SPF
    #define SPF Size_Position_Fix_D            //Size & Position Fix
#endif
#ifndef BDF
    #define BDF Barrel_Distortion_Fix_D        //Barrel Distortion Fix
#endif
#ifndef HMT
    #define HMT HUD_Mode_Trigger_D             //HUD Mode Trigger
#endif
#ifndef HMC
    #define HMC HUDX_D                         //HUD Mode Cut-Off 
#endif
#ifndef HMD
    #define HMD HUDY_D                         //HUD Mode Distance
#endif
#ifndef DFW
    #define DFW Delay_Frame_Workaround_D       //Delay Frame Workaround
#endif
#ifndef LBC
    #define LBC Auto_Letter_Box_Correction_D   //Auto Letter Box Correction
#endif
#ifndef LBS
    #define LBS LB_Sensitivity_D               //Letter Box Sensitivity
#endif
#ifndef LBM
    #define LBM Auto_Letter_Box_Masking_D      //Auto Letter Box Depth Masking
#endif
#ifndef SDT
    #define SDT Specialized_Depth_Trigger_D    //Specialized Depth Trigger
#endif
#ifndef BMT
    #define BMT Balance_Mode_Toggle_D          //Balance Mode Toggle
#endif
#ifndef FPS
    #define FPS FPS_Focus_Type_D               //FPS Focus Type
#endif
#ifndef SMS
    #define SMS SM_Toggle_Sparation_D          //Smooth Mode Toggle Sparation
#endif
#ifndef MDD
    #define MDD Menu_Detection_Direction_D     //Menu Detection & Direction
#endif
#ifndef AFD
    #define AFD Alternate_Frame_Detection_ZPD_D//Alternate Frame Detection for ZPD
#endif
#ifndef HQT
    #define HQT HQ_Mode_Toggle_D               //High Quality Mode Toggle
#endif
#ifndef LBR
    #define LBR Letter_Box_Reposition_D        //Letter Box Reposition
#endif
#ifndef LBE
    #define LBE Letter_Box_Elevation_D         //Letter Box Elevation
#endif  
#ifndef SMP
    #define SMP SM_PillarBox_Detection_D       //PillarBox Detection & Smoothing
#endif 
#ifndef SPO
    #define SPO Set_PopOut_D                   //Set Popout & Weapon Min
#endif 
#ifndef FMM
    #define FMM Filter_Mode_Modifire_D         //Filter Mode Modifier N
#endif 
#ifndef MAC
    #define MAC Menu_A_C_To_C_Only_D           //Menu A/C to only C WildCard
#endif 
#ifndef SDU
    #define SDU Shift_Detectors_Up_D           //Shift Detectors Up
#endif
#ifndef WHM
    #define WHM WH_Masking_D                   //Set Weapon Hand Masking Power
#endif 
#ifndef SMD
    #define SMD Simple_Menu_Detection_D        //Simple Menu Detection
#endif
#ifndef MMD
    #define MMD Multi_Menu_Detection_D         //Multi Menu Detection
#endif
#ifndef MMS
    #define MMS Multi_Menu_Selection_D         //Multi Menu Selection
#endif  
#ifndef MML
    #define MML Multi_Menu_Leniency_D          //Multi Menu Leniency
#endif 
#ifndef WRP
    #define WRP FPS_Weapon_Reduction_D         //Weapon Reduction Power
#endif 
#ifndef WND
    #define WND Weapon_Near_Depth_Push_D       //Weapon Near
#endif 
#ifndef WFB
    #define WFB Weapon_Distance_From_Bottom_D  //Weapon Distance From Bottom
#endif 

//SuperDepth3D Warning System
#ifndef NPW
    #define NPW No_Profile_Warning_D           //No Profile Warning
#endif
#ifndef NFM
    #define NFM Needs_Fix_Mod_D                //Needs Fix and/or Modding
#endif
#ifndef DSW
    #define DSW Depth_Selection_Warning_D      //Depth Selection Warning
#endif
#ifndef DAA
    #define DAA Disable_Anti_Aliasing_D        //Disable Anti-Aliasing
#endif
#ifndef NDW
    #define NDW Network_Warning_D              //Network Detection Warning
#endif
#ifndef PEW
    #define PEW Disable_Post_Effects_Warning_D //Disable Post Effect Warning
#endif
#ifndef WPW
    #define WPW Weapon_Profile_Warning_D       //Weapon Profile Warning
#endif
#ifndef FOV
    #define FOV Set_Game_FoV_D                 //Set Game FoV Warning 
#endif
#ifndef NVK
    #define NVK Needs_DXVK_D                   //Needs DirectX Vulkan-based translation layer Warning 
#endif
#ifndef NDG
    #define NDG Needs_DGVoodoo_Two_D           //Needs DGVooDoo2 Warning 
#endif
#ifndef ARW
    #define ARW Aspect_Ratio_Warning_D         //Aspect Ratio Warning 
#endif
#ifndef DRS
    #define DRS DRS_Warning_D                  //Dynamic Resolution Scaling Warning 
#endif
#ifndef RHW
    #define RHW Read_Help_Warning_D            //Read Help Warning
#endif
#ifndef EDW
    #define EDW Emulator_Detected_Warning_D    //Emulator Detected Warning
#endif
#ifndef NCW
    #define NCW Not_Compatible_Warning_D       //Not Compatible Warning
#endif
//Weapon Settings "Use #define WSM | 2 | 3 | 4 | 5 | 6 One is default"
//Expanded Settings "Use #define WSM 6+ if Games have Multi Weapon Profiles."
#ifndef OW_WP     //This is used if OW_WP is not called in the Above Profile
    #define OW_WP "WP Off\0Custom WP\0WP 0\0WP 1\0WP 2\0WP 3\0WP 4\0WP 5\0WP 6\0WP 7\0WP 8\0WP 9\0WP 10\0WP 11\0WP 12\0WP 13\0WP 14\0WP 15\0WP 16\0WP 17\0WP 18\0WP 19\0WP 20\0WP 21\0WP 22\0WP 23\0WP 24\0WP 25\0"
#endif
#ifndef WSM //Profiles List One | Profiles List Two | Profiles List Three | Profiles List Four | Profiles List Five| Profiles List Six | Seven is MCC | Eight is Prey | Nine is Blood 2 | Ten No One Lives Forever |
    #define WSM 1 //Weapon Setting Mode
#endif

#if WSM == 1
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) //Tried Switch But, can't compile in some older versions of ReShade.
{   if (WP == 2)
        Weapon_Adjust = float4(0.425,5.0,1.125,0.0);      //WP 0  | ES: Oblivion
    if (WP == 3)
        Weapon_Adjust = float4(0.276,16.25,9.15,0.0);     //WP 1  | BorderLands Enhanced
    if (WP == 4)
        Weapon_Adjust = float4(0.5,32.5,7.15,0.0);        //WP 2  | BorderLands 2
    if (WP == 5)
        Weapon_Adjust = float4(0.284,10.5,0.8725,0.0);    //WP 3  | BorderLands 3
    if (WP == 6)
        Weapon_Adjust = float4(0.253,39.0,97.5,0.0);      //WP 4  | Fallout 4
    if (WP == 7)
        Weapon_Adjust = float4(0.276,22.0,9.50,0.200);    //WP 5  | Skyrim: SE
    if (WP == 8)
        Weapon_Adjust = float4(0.338,20.5,9.1375,0.0);    //WP 6  | DOOM 2016
    if (WP == 9)//float4(0.255,177.5,63.025,0.0);
        Weapon_Adjust = float4(0.255,287.5,63.0,0.050);   //WP 7  | CoD:Black Ops | CoD:MW2 | CoD:MW3
    if (WP == 10)//float4(0.254,100.0,0.9843,0.0);
        Weapon_Adjust = float4(0.254,175.0,0.98435,0.0);  //WP 8  | CoD:Black Ops II
    if (WP == 11)
        Weapon_Adjust = float4(0.254,203.25,0.98435,0.0); //WP 9  | CoD:Ghost
    if (WP == 12)
        Weapon_Adjust = float4(0.254,203.25,0.984325,0.0);//WP 10 | CoD:AW | CoD:MW Re | CoD: WWII
    if (WP == 13)
        Weapon_Adjust = float4(0.254,156.25,0.984315,0.0);//WP 11 | CoD:IW
    if (WP == 14)
        Weapon_Adjust = float4(0.255,200.0,63.0,0.05);    //WP 12 | CoD:WaW
    if (WP == 15)
        Weapon_Adjust = float4(0.510,162.5,3.975,0.0);    //WP 13 | CoD | CoD:UO | CoD:2
    if (WP == 16)
        Weapon_Adjust = float4(0.254,23.75,0.98425,0.05); //WP 14 | CoD: Black Ops III
    if (WP == 17)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 15 | Game
    if (WP == 18)
        Weapon_Adjust = float4(0.7,14.375,2.5,0.0);       //WP 16 | Quake 2 XP
    if (WP == 19)
        Weapon_Adjust = float4(0.750,30.0,1.050,0.0);     //WP 17 | Quake 4
    if (WP == 20)
        Weapon_Adjust = float4(0.278,90.0,9.1,0.050);     //WP 18 | Half-Life 2
    if (WP == 21)
        Weapon_Adjust = float4(0.400,11.0,23.750,0.025);  //WP 19 | Metro Redux Games
    if (WP == 22)
        Weapon_Adjust = float4(0.350,12.5,2.0,0.0);       //WP 20 | Soldier of Fortune
    if (WP == 23)
        Weapon_Adjust = float4(0.286,1500.0,7.0,0.0);     //WP 21 | Deus Ex rev
    if (WP == 24)
        Weapon_Adjust = float4(35.0,250.0,0,0.0);         //WP 21 | Deus Ex
    if (WP == 25)
        Weapon_Adjust = float4(0.625,350.0,0.785,0.0);    //WP 23 | Minecraft
    if (WP == 26)
        Weapon_Adjust = float4(0.255,6.375,53.75,0.0);    //WP 24 | S.T.A.L.K.E.R: Games
    if (WP == 27)
        Weapon_Adjust = float4(0.403,6.250,0.0,0.0);      //WP 25 | AMID EVIL RTX
	//Do Not Add more Profiles
	//61 Profiles is Unity's Limit if using else if
	//76 Profiles reaches DX 9's Temp Registers Limit 
	//Will be cliping it off at 52 so 50 Profiles will be the limit so that I have more room to grow and faster compile time.
	//Reduced to Half Since 25 Profiles Spread across 6 Slots should speed up compile time in DX9 games.
		return Weapon_Adjust;
}
#elif WSM == 2
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) //Could reduce from 76 to 57 to save on compiling time.
{   if (WP == 2)
        Weapon_Adjust = float4(0.600,6.5,0.0,0.0);        //WP 0  | The Suicide of Rachel Foster
    if (WP == 3)
        Weapon_Adjust = float4(1.653,17.5,0.0,0.0);       //WP 1  | Devolverland Expo
    if (WP == 4)
        Weapon_Adjust = float4(1.489,16.875,0.0,0.0);     //WP 2  | Conarium
    if (WP == 5)
        Weapon_Adjust = float4(0.270,20.0,0.9515,0.0);    //WP 3  | WRC 10
    if (WP == 6)
        Weapon_Adjust = float4(0.850,32.5,0.99901,0.150); //WP 4  | The Outer Worlds
    if (WP == 7)
        Weapon_Adjust = float4(0.275,11.0,10.0,0.0);      //WP 5  | Crysis 2 DX11 1.9
    if (WP == 8)
        Weapon_Adjust = float4(5.200,20.0,0.0,0.225);     //WP 6  | GTFO
    if (WP == 9)
        Weapon_Adjust = float4(0.351,30.0,2.125,0.0);     //WP 7  | Quake 2 Remake
    if (WP == 10)
        Weapon_Adjust = float4(6.450,25.0,0.0,0.125);     //WP 8  | Chernobylite
    if (WP == 11)
        Weapon_Adjust = float4(14.100,93.75,0.0,0.0);     //WP 9  | HROT
    if (WP == 12)
        Weapon_Adjust = float4(0.284,25.0,0.8745,0.0);    //WP 10 | Crysis Remastered
    if (WP == 13)
        Weapon_Adjust = float4(0.284,15.0,7.200,0.0);     //WP 11 | Crysis 2 Remastered
    if (WP == 14)
        Weapon_Adjust = float4(0.284,25.0,11.45,0.125);   //WP 12 | Crysis 3 Remastered
    if (WP == 15)
        Weapon_Adjust = float4(0.300,4.25,0.825,0.0);     //WP 13 | Five Night's At Freddy's: Security Breach
    if (WP == 16)
        Weapon_Adjust = float4(0.750,10.250,0.1125,0.0);  //WP 14 | Poppy Playtime
    if (WP == 17)
        Weapon_Adjust = float4(5.0,22.5,0.0125,0.00);     //WP 15 | DEATHLOOP //float4(7.4,25.0,0.025,0.025);
    if (WP == 18)
        Weapon_Adjust = float4(0.279,4.0,0.0,0.0);        //WP 16 | Prodeus
    if (WP == 19)
        Weapon_Adjust = float4(1.550,100.0,0.130,0.130);  //WP 17 | Halo Infinite //float4(1.550,117.5,0.125,0.125);
    if (WP == 20) //0.650 25 10000
        Weapon_Adjust = float4(0.251,25.0,1000.0,0.0);    //WP 18 | Dishonored
    if (WP == 21)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 19 | Game
    if (WP == 22)
        Weapon_Adjust = float4(0.6,5.2,0.250,0.0);        //WP 20 | Deadlink
    if (WP == 23)
        Weapon_Adjust = float4(0.250,1.0,0.0,0.0);        //WP 21 | Grand Theft Auto San Andreas [GTA SA]
    if (WP == 24)
        Weapon_Adjust = float4(15.500,60.0,0.0,0.075);    //WP 22 | Bright Memory: infinite
    if (WP == 25)
        Weapon_Adjust = float4(15.025,100.0,0.0,0.0);     //WP 23 | Metal
    if (WP == 26)
        Weapon_Adjust = float4(0.725,5.0,0.3,0.050);      //WP 24 | Industria
    if (WP == 27)
        Weapon_Adjust = float4(1.325,10.0,0.0,0.0);       //WP 25 | KHOLAT
	//Do Not Add more Profiles
	//61 Profiles is Unity's Limit if using else if
	//76 Profiles reaches DX 9's Temp Registers Limit 
	//Will be cliping it off at 52 so 50 Profiles will be the limit so that I have more room to grow and faster compile time.
	//Reduced to Half Since 25 Profiles Spread across 6 Slots should speed up compile time in DX9 games.
		return Weapon_Adjust;
}
#elif WSM == 3
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust)
{   if (WP == 2)
        Weapon_Adjust = float4(1.0,237.5,0.83625,0.0);    //WP 0 | Rage64
    if (WP == 3)
        Weapon_Adjust = float4(13.870,50.0,0.0,0.0);      //WP 1 | Graven
    if (WP == 4)
        Weapon_Adjust = float4(0.425,20.0,99.0,0.0);      //WP 2 | Bioshock Remastred
    if (WP == 5)
        Weapon_Adjust = float4(0.425,20.0,99.5,0.0);      //WP 3 | Bioshock 2 Remastred
    if (WP == 6)
        Weapon_Adjust = float4(1.960,5.25,0,0.0);         //WP 4 | Dying Light
    if (WP == 7)
        Weapon_Adjust = float4(2.196,1.750,0.0,0.0);      //WP 5 | Dying Light 2
    if (WP == 8)
        Weapon_Adjust = float4(0.5,8.0,0,0.0);            //WP 6 | Strife
    if (WP == 9)
        Weapon_Adjust = float4(0.350,7.5,2.0,0.0);      //WP 7 | Gold Source
    if (WP == 10) 
        Weapon_Adjust = float4(2.15,25.0,0.0,0.0);        //WP 8 | No Man Sky FPS Mode //float4(1.825,13.75,0.0,0.0);
    if (WP == 11)
        Weapon_Adjust = float4(0.6475,7.5,0.280,0.0);     //WP 9 | Necromunda Hired Gun
    if (WP == 12)
        Weapon_Adjust = float4(0.287,180.0,9.0,0.0);      //WP 10 | Farcry
    if (WP == 13)
        Weapon_Adjust = float4(0.2503,55.0,1000.0,0.0);   //WP 11 | Farcry 2
    if (WP == 14)
        Weapon_Adjust = float4(0.279,100.0,0.905,0.0);    //WP 12 | Talos Principle
    if (WP == 15)
        Weapon_Adjust = float4(0.2503,52.5,987.5,0.0);    //WP 13 | Singularity
    if (WP == 16)
        Weapon_Adjust = float4(0.251,12.5,925.0,0.0);     //WP 14 | Betrayer
    if (WP == 17)
        Weapon_Adjust = float4(1.035,16.0,0.185,0.0);     //WP 15 | Doom Eternal
    if (WP == 18)
        Weapon_Adjust = float4(1.553,16.875,0.0,0.0);     //WP 16 | Q.U.B.E 2
    if (WP == 19)
        Weapon_Adjust = float4(0.251,5.6875,950.0,0.0);   //WP 17 | Mirror Edge
    if (WP == 20)
        Weapon_Adjust = float4(0.345,10.25,1.800,0.0);    //WP 18 | Quake Enhanced Edition
    if (WP == 21)
        Weapon_Adjust = float4(0.430,6.250,0.100,0.0);    //WP 19 | The Citadel 186
    if (WP == 22)
        Weapon_Adjust = float4(0.800,15.0,0.3,0.0);       //WP 20 | Sauerbraten 2
    if (WP == 23)
        Weapon_Adjust = float4(13.3,62.5,0.0,0.0);        //WP 21 | Chex Quest HD
    if (WP == 24)
        Weapon_Adjust = float4(0.75,112.5,0.5,0.0);       //WP 22 | Hexen 2
    if (WP == 25)
        Weapon_Adjust = float4(0.350,17.5,2.050,0.0);     //WP 23 | Star Trek EliteForce II
    if (WP == 26)
        Weapon_Adjust = float4(3.5,17.0,0.0,0.0);         //WP 24 | The Entropy Center
    if (WP == 27)
        Weapon_Adjust = float4(0.71,8.75,0.25,0.0);         //WP 25 | Ghostwire: Tokyo
	//Do Not Add more Profiles
	//61 Profiles is Unity's Limit if using else if
	//76 Profiles reaches DX 9's Temp Registers Limit 
	//Will be cliping it off at 52 so 50 Profiles will be the limit so that I have more room to grow and faster compile time.
	//Reduced to Half Since 25 Profiles Spread across 6 Slots should speed up compile time in DX9 games.
		return Weapon_Adjust;
}
#elif WSM == 4
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust)
{   if (WP == 2)
        Weapon_Adjust = float4(1.7,12.25,0.0,0.0);        //WP 0  | Scathe
    if (WP == 3)
        Weapon_Adjust = float4(1.025,7.75,0.0,0.0);       //WP 1  | Nightmare Reaper
    if (WP == 4)
        Weapon_Adjust = float4(0.5,7.0,0.0,0.0);          //WP 2  | Powerslave Exhumed
    if (WP == 5)
        Weapon_Adjust = float4(0.325,7.5,1.875,0.0);      //WP 3  | DaiKatana
    if (WP == 6)
        Weapon_Adjust = float4(6.75,62.5,0.0,0.0);        //WP 4  | Bendy and the Dark Revival
    if (WP == 7)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 5  | Game
    if (WP == 8)
        Weapon_Adjust = float4(1.250,25.0,0.99,0.125);    //WP 6  | Thief
    if (WP == 9)
        Weapon_Adjust = float4(4.6,60.0,0.0,0.0);         //WP 7  | Warhammer 40K Boltgun
    if (WP == 10)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 8  | Game
    if (WP == 11)
        Weapon_Adjust = float4(0.25,0.0,0.0,0.0);         //WP 9  | Diablo IV
    if (WP == 12)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 10 | Game
    if (WP == 13)
        Weapon_Adjust = float4(4.75,20.0,0.0,0.0);        //WP 11 | RoboCop
    if (WP == 14)
        Weapon_Adjust = float4(3.40,30.0,0.0,0.300);      //WP 12 | MGS 2 SoL
    if (WP == 15)
        Weapon_Adjust = float4(2.25,25.0,0.0,0.300);      //WP 12 | MGS 3 SE
    if (WP == 16)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 14 | Game
    if (WP == 17)
        Weapon_Adjust = float4(0.375,60.0,15.15625,0.0);  //WP 15 | Quake DarkPlaces
    if (WP == 18)
        Weapon_Adjust = float4(2.9375,20.0,0.05,0.0);     //WP 16  | BorderLands
    if (WP == 19)
        Weapon_Adjust = float4(0.2825,100.0,0.882,0.1);   //WP 17 | Alien Cube
    if (WP == 20)
        Weapon_Adjust = float4(1.0,5.0,0.1,0.0);          //WP 18 | Bloodhound
    if (WP == 21)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 19 | Game
    if (WP == 22)
        Weapon_Adjust = float4(0.265,30.0,0.990,0.0);     //WP 20 | Starfield
    if (WP == 23)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 21 | Game
    if (WP == 24)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 22 | Game
    if (WP == 25)
        Weapon_Adjust = float4(6.25,75.0,0.0,0.1);        //WP 23 | Amnesia: Games
    if (WP == 26)
        Weapon_Adjust = float4(3.6,12.5,0.0625,0.0);      //WP 24 | Severed Steel
    if (WP == 27)
        Weapon_Adjust = float4(0.55,0.0,0.0,0.0);         //WP 25 | game / Mafia
	//Do Not Add more Profiles
	//61 Profiles is Unity's Limit if using else if
	//76 Profiles reaches DX 9's Temp Registers Limit 
	//Will be cliping it off at 52 so 50 Profiles will be the limit so that I have more room to grow and faster compile time.
	//Reduced to Half Since 25 Profiles Spread across 6 Slots should speed up compile time in DX9 games.  
		return Weapon_Adjust;
}
#elif WSM == 5
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust)
{   if (WP == 2)
        Weapon_Adjust = float4(0.750,30.0,1.025,0.0);     //WP 0  | Prey 2006
    if (WP == 3)
        Weapon_Adjust = float4(0.266,26.25,14.0,0.125);   //WP 1  | Wrath
    if (WP == 4)
        Weapon_Adjust = float4(3.625,20.0,0,0.0);         //WP 2  | We Where Here Together
    if (WP == 5)
        Weapon_Adjust = float4(0.7,9.0,2.3625,0.0);       //WP 3  | Return to Castle Wolfenstine
    if (WP == 6)
        Weapon_Adjust = float4(0.4894,62.50,0.98875,0.0); //WP 4  | Wolfenstein
    if (WP == 7)
        Weapon_Adjust = float4(0.850,93.75,0.81875,0.025);//WP 5  | Wolfenstein: The New Order #C770832 / The Old Blood #3E42619F
    if (WP == 8) //float4(1.150,55.0,0.9,0.0);//float4(1.150,32.5,0.9,0.0);
        Weapon_Adjust = float4(1.150,40.0,0.9,0.0);       //WP 6  | Cyberpunk 2077
    if (WP == 9)
        Weapon_Adjust = float4(0.278,50.0,9.0,0.0);       //WP 7  | Black Mesa
    if (WP == 10)//float4(0.277,105.0,8.8625,0.0)
        Weapon_Adjust = float4(0.277,90.0,9.0,0.0);       //WP 8  | Portal 2
    if (WP == 11)
        Weapon_Adjust = float4(0.277,15.0,8.8,0.0);       //WP 9 | Crysis Mod
    if (WP == 12)
        Weapon_Adjust = float4(1.00,22.5,0.180,0.0);      //WP 10 | SOMA
    if (WP == 13)
        Weapon_Adjust = float4(0.444,20.0,1.1875,0.0);    //WP 11 | Cryostasis
    if (WP == 14)
        Weapon_Adjust = float4(0.286,80.0,7.0,0.0);       //WP 12 | Unreal Gold with v227
    if (WP == 15)
        Weapon_Adjust = float4(0.280,18.75,9.03,0.0);     //WP 13 | Serious Sam Revolution #EB9EEB74/Serious Sam HD: The First Encounter /The Second Encounter /Serious Sam 2 #8238E9CA/ Serious Sam 3: BFE*
    if (WP == 16)
        Weapon_Adjust = float4(0.3,12.5,0.900,0.0);       //WP 14 | Serious Sam Fusion
    if (WP == 17)
        Weapon_Adjust = float4(1.2,12.5,0.3,0.05);        //WP 15 | GhostRunner DX12
    if (WP == 18)
        Weapon_Adjust = float4(0.278,20.0,8.8,0.0);       //WP 16 | TitanFall 2
    if (WP == 19)
        Weapon_Adjust = float4(1.300,17.50,0.0,0.0);      //WP 17 | Project Warlock
    if (WP == 20)
        Weapon_Adjust = float4(0.625,9.0,2.375,0.0);      //WP 18 | Kingpin Life of Crime
    if (WP == 21)
        Weapon_Adjust = float4(0.28,20.0,9.0,0.0);        //WP 19 | EuroTruckSim2
    if (WP == 22)
        Weapon_Adjust = float4(0.460,12.5,1.0,0.0);       //WP 20 | F.E.A.R #B302EC7 & F.E.A.R 2: Project Origin #91D9EBAF
    if (WP == 23)
        Weapon_Adjust = float4(1.5,30.0,0.950,0.050);     //WP 21 | Condemned Criminal Origins //float4(1.5,37.5,0.99875,0.0); 
    if (WP == 24)
        Weapon_Adjust = float4(2.0,16.25,0.09,0.0);       //WP 22 | Immortal Redneck CP alt 1.9375
    if (WP == 25)
        Weapon_Adjust = float4(0.485,62.5,0.9625,0.25);   //WP 23 | Dementium 2
    if (WP == 26)
        Weapon_Adjust = float4(0.489,68.75,1.02,0.0);     //WP 24 | NecroVisioN & NecroVisioN: Lost Company #663E66FE
    if (WP == 27)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 25 | Game
	//Do Not Add more Profiles
	//61 Profiles is Unity's Limit if using else if
	//76 Profiles reaches DX 9's Temp Registers Limit 
	//Will be cliping it off at 52 so 50 Profiles will be the limit so that I have more room to grow and faster compile time. \
	//Reduced to Half Since 25 Profiles Spread across 6 Slots should speed up compile time in DX9 games. 
		return Weapon_Adjust;
}
#elif WSM == 6
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust)
{   if (WP == 2)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 0  | Game
    if (WP == 3)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 1  | Game
    if (WP == 4)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 2  | Game
    if (WP == 5)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 3  | Game
    if (WP == 6)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 4  | Game
    if (WP == 7)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 5  | Game
    if (WP == 8)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 6  | Game
    if (WP == 9)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 7  | Game
    if (WP == 10)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 8  | Game
    if (WP == 11)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 9  | Game
    if (WP == 12)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 10 | Game
    if (WP == 13)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 11 | Game
    if (WP == 14)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 12 | Game
    if (WP == 15)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 13 | Game
    if (WP == 16)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 14 | Game
    if (WP == 17)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 15 | Game
    if (WP == 18)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 16 | Game
    if (WP == 19)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 17 | Game
    if (WP == 20)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 18 | Game
    if (WP == 21)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 19 | Game
    if (WP == 22)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 20 | Game
    if (WP == 23)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 21 | Game
    if (WP == 24)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 22 | Game
    if (WP == 25)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 23 | Game
    if (WP == 26)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 24 | Game
    if (WP == 27)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 25 | Game
	//Do Not Add more Profiles
	//61 Profiles is Unity's Limit if using else if
	//76 Profiles reaches DX 9's Temp Registers Limit 
	//Will be cliping it off at 52 so 50 Profiles will be the limit so that I have more room to grow and faster compile time.
	//Reduced to Half Since 25 Profiles Spread across 6 Slots should speed up compile time in DX9 games. 
		return Weapon_Adjust;
}
#elif WSM == 7
float DMA_Overwatch(float WP, float DMA_Adjust) // MCC
{
	if( WP == 4) // Change on weapon selection.
		DMA_Adjust *= 0.325;
	if( WP == 5 ||  WP == 6 ||  WP == 7)
		DMA_Adjust *= 1.25;
	return DMA_Adjust;
}
	#if SPO
	float2 Set_Popout(float WP, float Adjust_Value_Pop, int Set_Weapon_Min ) // MCC
	{
		float2 Set_Values = float2(Adjust_Value_Pop, Set_Weapon_Min );
		if ( WP == 2 || WP == 5 )
	        Set_Values *= float2(1.0,1.0);      //Halo: Reach | Halo 3 & ODST
	    if ( WP == 3 || WP == 4 || WP == 6 || WP == 7 || WP == 8 )
	        Set_Values *= float2(-0.05,0.0);      //Halo: CE Anniversary | Halo 2: Anniversary | Alt Halo 3 & ODST | Halo 4 & Alt	        
		return Set_Values;
	}
	#endif
	
float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) // MCC
{
	if (WP == 2)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 0  | Halo: Reach
    if (WP == 3)
        Weapon_Adjust = float4(1.5,26.25,0.2,0.0);        //WP 1  | Halo: CE Anniversary
    if (WP == 4)
        Weapon_Adjust = float4(0.615,10.0,0.3925,0.05);   //WP 2  | Halo 2: Anniversary
    if (WP == 5)
        Weapon_Adjust = float4(0.0,0.0,0.0,0.0);          //WP 3  | Halo 3 & ODST
    if (WP == 6)
        Weapon_Adjust = float4(7.540,17.5,0,0.010);       //WP 4  | Alt Halo 3 & ODST
    if (WP == 7)
        Weapon_Adjust = float4(1.535,17.5,0.125,0.0);     //WP 5  | Halo 4
    if (WP == 8)
        Weapon_Adjust = float4(1.535,25.0,0.1425,0.0);    //WP 5  | Alt Halo 4

		return Weapon_Adjust;
}
#elif WSM == 8
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) // Prey 2017
{
	if (WP == 2)
		Weapon_Adjust = float4(0.2832,31.25,0.8775,0.0);   //WP 0 | Prey 2017 High Settings and <
	if (WP == 3)
		Weapon_Adjust = float4(0.2832,31.25,0.91875,0.0);  //WP 1 | Prey 2017 Very High

	return Weapon_Adjust;
}
#elif WSM == 9
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) // Blood 2
{
    if (WP == 2)
        Weapon_Adjust = float4(0.4213,5.0,0.5,0.0);        //WP 0 | Blood 2 All Weapons
    if (WP == 3)
        Weapon_Adjust = float4(0.484,5.0,0.5,0.0);         //WP 1 | Blood 2 Bonus weapons
    if (WP == 4)
        Weapon_Adjust = float4(0.4213,5.0,0.8,0.0);        //WP 2 | Blood 2 Former

	return Weapon_Adjust;
}
#elif WSM == 10
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) // No One Lives Forever
{
    if (WP == 2)
        Weapon_Adjust = float4(0.425,5.25,1.0,0.0);       //WP 2 | No One Lives Forever
    if (WP == 3)
        Weapon_Adjust = float4(0.519,31.25,8.875,0.0);    //WP 3 | No One Lives Forever 2

	return Weapon_Adjust;
}
#elif WSM == 11
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) // Aliens VS Predator 2
{
    if (WP == 2)
        Weapon_Adjust = float4(0.500,6.500,1.0,0.0);      //WP 2 | Aliens VS Predator 2
    if (WP == 3)
        Weapon_Adjust = float4(0.519,31.25,8.875,0.0);    //WP 3 | Aliens VS Predator 2 WIP

	return Weapon_Adjust;
}
#elif WSM == 12
float DMA_Overwatch(float WP, float DMA_Adjust)
{
	return DMA_Adjust;
}

float4 Weapon_Profiles(float WP ,float4 Weapon_Adjust) // Aliens VS Predator 2
{
    if (WP == 2)
        Weapon_Adjust = float4(0.850,32.5,0.99901,0.150); //WP 2  | The Outer Worlds
    if (WP == 3)
        Weapon_Adjust = float4(0.9755,10.5,0.175,0.125);  //WP 3  | The Outer Worlds Spacer Ed

	return Weapon_Adjust;
}
//Can expand here for games with multi weapon profiles.
#endif
