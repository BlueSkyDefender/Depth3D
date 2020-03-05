////----------------------------------------//
///SuperDepth3D Overwatch Automation Shader///
//----------------------------------------////
// Version 1.2
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

//Weapon Setting are at the bottom of this file.

//SuperDepth3D Defaults
static const float ZPD_D = 0.025;                       //ZPD
static const float Depth_Adjust_D = 7.5;                //Depth Adjust
static const float Offset_D = 0.0;                      //Offset
static const int Depth_Linearization_D = 0;             //Linearization
static const int Depth_Flip_D = 0;                      //Depth Flip
static const int Auto_Balance_D = 0;                    //Auto Balance
static const float Auto_Depth_D = 0.1;                  //Auto Depth Range
static const int Weapon_Hand_D = 0;                     //Weapon Profile
static const float HUDX_D = 0.0;                        //Heads Up Display Cut Off Point
static const float BD_K1_D = 0.0;                       //Barrel Distortion K1
static const float BD_K2_D = 0.0;                       //Barrel Distortion K2
static const float BD_Zoom_D = 0.0;                     //Barrel Distortion Zoom
static const float HVS_X_D = 1.0;                       //Horizontal Size
static const float HVS_Y_D = 1.0;                       //Vertical Size
static const int HVP_X_D = 0;                           //Horizontal Position
static const int HVP_Y_D = 0;                           //Vertical Position
static const int ZPD_Boundary_Type_D = 0;               //ZPD Boundary Type
static const float ZPD_Boundary_Scaling_D = 0.5;        //ZPD Boundary Scaling
static const float ZPD_Boundary_Fade_Time_D = 0.25;     //ZPD Boundary Fade Time
static const float Weapon_Near_Depth_D = 0.0;           //Weapon Near Depth
static const float ZPD_Weapon_Boundary_Adjust = 0.0;    //ZPD Weapon Boundary Adjust
static const float NULL_A = 0.0;
static const float NULL_B = 0.0;
static const float NULL_C = 0.0;

//Special Toggles Defaults
static const int REF = 0;                               //Resident Evil Fix
static const int NCW = 0;                               //Not Compatible Warning
static const int FTW = 0;                               //Flashing Text Warning
static const int NPW = 0;                               //No Profile Warning
static const int IDF = 0;                               //Inverted Depth Fix
static const int SPF = 0;                               //Size & Position Fix
static const int BDF = 0;                               //Barrel Distortion Fix
static const int HMT = 0;                               //HUD Mode Trigger

//Special Handling
#if exists "LEGOBatman.exe"                             //Lego Batman
	#define sApp 0xA100000
#elif exists "LEGOBatman2.exe"                          //LEGO Batman 2
	#define sApp 0xA100000
#elif exists "GameComponentsOzzy_Win32Steam_Release.dll"//Batman BlackGate
	#define sApp 0xA200000
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
#if (App == 0xC753DADB )	//ES: Oblivion
	#define DB_W 2
	#define DB_Y 3
#elif (App == 0x7B81CCAB )	//BorderLands 2
    #define DA_Y 25.0
	#define DB_Y 2
    #define DB_W 4.0
#elif (App == 0x2D950D30 )	//Fallout 4
	#define DA_Y 6.25
	#define DB_Y 2
	#define DB_W 6
#elif (App == 0x3950D04E )	//Skyrim: SE
	#define DA_Y 6.25
	#define DB_Y 2
	#define DB_W 7
#elif (App == 0x142EDFD6 || App == 0x2A0ECCC9 || App == 0x8B0C2031 )	//DOOM 2016
	#define DA_Y 20.0
	#define DB_Y 3
	#define DB_W 8
#elif (App == 0x17232880 || App == 0x9D77A7C4 || App == 0x22EF526F )	//CoD:Black Ops | CoD:MW2 |CoD:MW3
	#define DA_Y 12.5
	#define DB_Y 3
	#define DB_W 9
#elif (App == 0xD691718C )	//CoD:Black Ops II
	#define DA_Y 13.75
	#define DA_W 1
	#define DB_W 10
#elif (App == 0x7448721B )	//CoD:Ghost
	#define DA_Y 13.75
	#define DB_Y 2
	#define DA_W 1
	#define DB_W 11
#elif (App == 0x23AB8876 || App == 0xBF4D4A41 )	//CoD:AW | CoD:MW Re
	#define DA_Y 13.75
	#define DB_Y 2
	#define DA_W 1
	#define DB_W 12
#elif (App == 0x1544075 )	//CoD:IW
	#define DA_Y 13.75
	#define DB_Y 2
	#define DA_W 1
	#define DB_W 13
#elif (App == 0x697CDA52 )	//CoD:WaW
	#define DA_Y 12.5
	#define DB_Y 3
	#define DB_W 14
#elif (App == 0x4383C12A || App == 0x239E5522 || App == 0x3591DE9C )	//CoD | CoD:UO | CoD:2
	#define DB_W 15
	#define TW 1
#elif (App == 0x73FA91DC )	//CoD: Black Ops IIII
	#define DA_Y 22.5
	#define DA_W 1
	#define DB_W 16
#elif (App == 0x37BD797D )	//Quake DarkPlaces
	#define DA_Y 15.0
	#define DB_Y 2
	#define DB_W 17
#elif (App == 0x37BD797D )	//Quake 2 XP
	#define DB_Y 2
	#define DB_W 18
#elif (App == 0xED7B83DE )	//Quake 4 #ED7B83DE
	#define DA_Y 15.0
	#define DB_W 19
#elif (App == 0x886386A )	//Metro Redux Games
	#define DA_Y 12.5
	#define DB_Y 2
	#define DB_W 21
#elif (App == 0xF5C7AA92 || App == 0x493B5C71 )	//S.T.A.L.K.E.R: Games
	#define DA_Y 10.0
	#define DB_Y 4
	#define DB_W 26
#elif (App == 0xDE2F0F4D )	//Prey 2006
	#define DB_W 28
	#define DB_Y 3
#elif (App == 0x36976F6D )	//Prey 2017 High Settings and <
	#define DA_Y 18.7
	#define DB_W 29
	#define DB_Y 2
	#define TW 1
#elif (App == 0xBF757E3A )	//Return to Castle Wolfenstein
	#define DA_Y 8.75
	#define DB_Y 2
	#define DB_W 31
#elif (App == 0xC770832 || App == 0x3E42619F )	//Wolfenstein: The New Order | The Old Blood
	#define DA_Y 25.0
	#define DB_Y 5
	#define DA_Z 0.00125
	#define DB_W 33
#elif (App == 0x6FC1FF71 )	//Black Mesa
	#define DA_Y 8.75
	#define DB_Y 1
	#define DB_W 35
#elif (App == 0x6D3CD99E )	//Blood 2
	#define DB_W 36
	#define DB_Y 3
	#define TW 1
#elif (App == 0xF22A9C7D )	//SOMA
	#define DA_Y 10.0
	#define DB_Y 5
	#define DB_W 38
#elif (App == 0x6FB6410B )	//Cryostasis
	#define DA_Y 13.75
	#define DB_Y 3
	#define DB_W 39
#elif (App == 0x16B8D61A)	//Unreal Gold with v227
	#define DA_Y 17.5
	#define DB_Y 1
	#define DB_W 40
	#define DC_X 0.534
	#define HM 1
#elif (App == 0xEB9EEB74 || App == 0x8238E9CA )	//Serious Sam Revolution | Serious Sam 2
	#define DA_Z 0.1111
	#define DB_W 41
#elif (App == 0x308AEBEA )	//TitanFall 2
	#define DB_Y 4
	#define DB_W 44
#elif (App == 0x5FCFB1E5 )	//Project Warlock
	#define DA_Y 17.5
	#define DB_Y 2
	#define DA_W 1
	#define DB_W 45
#elif (App == 0x7DCCBBBD )	//Kingpin Life of Crime
	#define DA_Y 10.0
	#define DB_Y 4
	#define DB_W 46
	#define TW 1
#elif (App == 0x9C5C946E )	//EuroTruckSim2
	#define DB_W 47
#elif (App == 0xB302EC7 || App == 0x91D9EBAF )	//F.E.A.R | F.E.A.R 2: Project Origin
	#define DA_Y 8.75
	#define DB_Y 3
	#define DB_W 48
#elif (App == 0x2C742D7C )	//Immortal Redneck CP alt 1.9375
	#define DA_Y 20.0
	#define DB_Y 5
	#define DB_W 50
#elif (App == 0x663E66FE )	//NecroVisioN & NecroVisioN: Lost Company
	#define DA_Y 10.0
	#define DB_Y 2
	#define DB_W 52
#elif (App == 0xAA6B948E )	//Rage64
	#define DA_Y 20.0
	#define DB_Y 2
	#define DB_W 53
#elif (App == 0x44BD41E1 )	//Bioshock Remaster
	#define DA_Z 0.001
	#define DB_Y 3
	#define DB_W 55
#elif (App == 0x7CF5A01 )	//Bioshock 2 Remaster
	#define DA_Z 0.001
	#define DB_W 56
	#define DB_Y 3
	#define DC_X 0.5034
	#define HM 1
#elif (App == 0x22BA110F )	//Turok: DH 2017
	#define DA_X 0.002
	#define DA_Y 250.0
#elif (App == 0x5F1DBD3B )	//Turok2: SoE 2017
	#define DA_X 0.002
	#define DA_Y 250.0
#elif (App == 0x3FDD232A )	//FEZ
	#define DA_X 0
	#define DA_Z 0.9625
#elif (App == 0x619964A3 )	//What Remains of Edith Finch
	#define DA_Y 50.0
	#define DA_Z 0.000025
	#define DA_W 1
	#define DB_Y 2
#elif (App == 0x941D8A46 )	//Tomb Raider Anniversary :)
	#define DA_Y 75.0
	#define DA_Z 0.0206
	#define DB_Y 2
#elif (App == 0xF0100C34 )	//Two Worlds Epic Edition
	#define DA_Y 43.75
	#define DA_Z 0.07575
#elif (App == 0xA4C82737 )	//Silent Hill: Homecoming
	#define DA_Y 25.0
	#define DA_X 0.0375
	#define DA_Z 0.11625
	#define DB_Y 4
	#define DC_X 0.5
	#define HM 1
#elif (App == 0x61243AED )	//Shadow Warrior Classic source port
	#define DA_Y 10.0
	#define DA_X 0.05
	#define DA_Z 1.0
	#define DB_Y 5
#elif (App == 0x5AE8FA62 )	//Shadow Warrior Classic Redux
	#define DA_Y 10.0
	#define DA_X 0.05
	#define DA_Z 1.0
	#define DB_Y 5
#elif (App == 0xFE54BF56 )	//No One Lives Forever and 2
	#define DA_X 0.0375
	#define TW 1
#elif (App == 0x9E7AA0C4 )	//Shadow Tactics: Blades of the Shogun
	#define DA_Y 7.0
	#define DA_Z 0.001
	#define DA_X 0.150
	#define DB_Y 5
	#define DB_Z 0.305
	#define DB_X 1
	#define TW 1
#elif (App == 0xE63BF4A4 )	//World of Warcraft DX12
	#define DA_Y 7.5
	#define DA_W 1
	#define DB_Y 3
	#define DB_Z 0.1375
	#define TW 1
#elif (App == 0x5961D1CC )	//Requiem: Avenging Angel
	#define DA_Y 37.5
	#define DA_X 0.0375
	#define DA_Z 0.8
	#define DC_X 0.501
	#define HM 1
#elif (App == 0x86D33094 )	//Rise of the TombRaider
	#define DA_X 0.075
	#define DB_Y 3
	#define DA_Y 25.0
	#define DA_Z 0.02
#elif (App == 0x60F436C6 )	//RESIDENT EVIL 2  BIOHAZARD RE2
	#define DA_X 0.1375
	#define DB_Y 3
	#define DB_Z 0.015 //Under Review
	#define DA_Y 51.25
	#define DA_W 1
	#define DA_Z 0.00015
	#define RE 1
#elif (App == 0xF0D4DB3D )	//Never Alone
	#define DA_X 0.1375
	#define DB_Y 2
	#define DA_Y 31.25
	#define DA_Z 0.004
#elif (App == 0x3EB1D73A )	//Magica 2
	#define DA_X 0.2
	#define DB_Y 5
	#define DA_Y 27.5
	#define DA_Z 0.007
#elif (App == 0x6D35D4BE )	//Lara Croft and the Temple of Osiris
	#define DA_X 0.15
	#define DB_Y 4
	#define DB_Z 0.4 //Under Review
	#define DA_Y 75.0
	#define DA_Z 0.021
	#define RE 1
#elif (App == 0xAAA18268 )	//Hellblade
	#define DB_Y 1
	#define DA_Y 25.0
	#define DA_W 1
	#define DA_Z 0.0005
	#define DB_Z 0.25 //Under Review
#elif (App == 0x287BBA4C || App == 0x59BFE7AC )	//Grim Dawn 64bit/32bit
	#define DB_Y 2
	#define DA_Y 125.0
	#define DA_Z 0.003
#elif (App == 0x8EAF7114 )	//Firewatch
	#define DB_Y 3
	#define DA_Y 5.0
	#define DA_X 0.0375
	#define DB_X 1
	#define DA_W 1
#elif (App == 0x6BDF0098 )	//Dungeons 2
	#define DA_X 0.100
	#define DB_Y 3
	#define DA_Z 0.005
	#define DB_X 1
#elif (App == 0x56E482C9 )	//DreamFall Chapters
	#define DA_Y 10.0
	#define DA_X 0.0375
	#define DB_Y 2
	#define DA_Z 0.001
	#define DB_X 1
#elif (App == 0x31BF8AF6 )	//DragonBall Fighters Z
	#define DA_Y 10.0
	#define DA_W 1
	#define DA_X 0.130
	#define DB_Y 3
	#define DB_Z 0.625 //I know, I know........
#elif (App == 0x3F017CF )	//Call of Cthulhu
	#define DA_W 1
	#define DA_X 0.0375
	#define DB_Y 3
#elif (App == 0x874318FE || App == 0x7CBA2E8C || App == 0x69277DAF )	//Batman Arkham Asylum / City / Origins
	#define DA_Y 18.75
	#define DA_X 0.0375
	#define DA_Z 0.00025
	#define DB_Y 4
	#define DB_Z 0.15
	#define TW 1
#elif (App == 0xA100000 )	//Lego Batman 1 & 2
	#define DA_Y 27.5
	#define DA_X 0.125
	#define DA_Z 0.001
	#define DB_Y 2
	#define DB_Z 0.025
	#define RE 1
#elif (App == 0x5F2CA572 )	//Lego Batman 3
	#define DA_X 0.03
	#define DA_Z 0.001
	#define DB_Y 4
	#define TW 1
#elif (App == 0xA200000 )	//Batman BlackGate
	#define DA_Y 12.5
	#define DA_X 0.0375
	#define DA_Z 0.00025
	#define DB_Y 3
#elif (App == 0xCB1CCDC )	//BATMAN TTS
	#define NC 1 //Not Compatible
#elif (App == 0x4A2297E4 )	//Batman Arkham Knight
	#define DA_Y 22.500
	#define DA_X 0.04375
	#define DB_Y 4
#elif (App == 0xE9A02687 )	//BattleTech
	#define DA_W 1
	#define DB_X 1
	#define DA_Y 75.0
	#define DA_X 0.250
	#define DB_Y 1
	#define RE 1
	#define TW 1
#elif (App == 0x1335BAB8 )	//BattleField 1
	#define DA_W 1
	#define DA_Y 8.125
	#define DA_X 0.04
	#define DB_Y 5
	#define RE 2
#elif (App == 0xA0762A98 )	//Assassin's Creed Unity
	#define DA_W 1
	#define DA_Y 20.0
	#define DA_Z 0.00025
	#define DA_X 0.04375
	#define DB_Z 0.2
#elif (App == 0xBF222C03 )	//Among The Sleep
	#define DA_X 0.05
	#define DA_Y 15.0
	#define DA_Z 0.0005
	#define DB_Y 4
	#define DB_X 1
	#define ID 1
#elif (App == 0xB75F3C89 )	//Amnesia: The Dark Descent
	#define DA_X 0.05
	#define DA_Y 45.0
	#define DA_Z 0.0005
	#define DB_Y 3
#elif (App == 0x91FF5778 )	//Amnesia: Machine for Pigs
	#define DA_X 0.05
	#define DA_Y 45.0
	#define DA_Z 0.0005
	#define DB_Y 3
#elif (App == 0x8B0F15E7 )	//Alan Wake
	#define DA_X 0.03
	#define DA_Y 32.5
	#define DB_Y 1
	#define TW 1
#elif (App == 0xCFE885A2 )	//Alan Wake's American Nightmare
	#define DA_X 0.03
	#define DA_Y 32.5
	#define DB_Y 1
	#define TW 1
#elif (App == 0x56D8243B )	//Agony Unrated
	#define DA_W 1
	#define DA_X 0.04375
	#define DA_Y 43.75
	#define DB_Y 5
	#define TW 1
#elif (App == 0x23D5135F )	//Alien Isolation
	#define DA_X 0.040
	#define DA_Y 18.00
	#define DA_Z 0.0005
	#define DB_Y 4
	#define DC 1
	#define DC_Y -0.22
	#define DC_Z 0.1
	#define DC_W 0.022
	#define TW 1
#elif (App == 0x5839915F )	//35MM
	#define DA_Y 35.00
	#define DB_X 1
	#define DB_Y 2
	#define TW 1
#elif (App == 0x578862 )	//Condemned Criminal Origins
	#define DA_Y 162.5
	#define DA_Z 0.00025
	#define DA_X 0.040
	#define DB_Y 4
	#define DB_W 49
	#define TW 1
#elif (App == 0xA67FA4BC )	//Outlast
	#define DA_Y 30.0
	#define DA_Z 0.0004
	#define DA_X 0.043750
	#define DB_Y 5
	#define TW 1
#elif (App == 0xDCC7F877 )	//Outlast II
	#define DA_W 1
	#define DA_Y 50.0
	#define DA_Z 0.0004
	#define DA_X 0.056250
	#define DB_Y 4
	#define TW 1
#elif (App == 0x60F43F45 )	//Resident Evil 7
	#define DA_W 1
	#define DA_Y 31.25
	#define DA_Z 0.0002
	#define DA_X 0.0375
	#define DB_Y 3
	#define DC 1
	#define DC_Y -0.24
	#define DC_W 0.05
	#define TW 1
#elif (App == 0x1B8B9F54 )	//TheEvilWithin
	#define DA_Y 40.0
	#define DA_Z 0.0001
	#define DA_X 0.1
	#define DB_Y 4
#elif (App == 0x7D9B7A37 )	//TheEvilWithin II
	#define DA_Y 30.0
	#define DA_Z 0.0001
	#define DA_X 0.04
	#define DB_Y 5
#elif (App == 0xBF49B12E )//Vampyr
	#define DA_W 1
	#define DA_Y 23.0
	#define DA_X 0.05
	#define DB_Y 5
#elif (App == 0x85F0A0FF ) //LUST for Darkness
	#define DA_W 1
	#define DB_X 1
	#define DA_Y 13.75
	#define DA_Z 0.001
	#define DA_X 0.04
	#define DB_Y 4
	#define DB_Z 0.125
	#define TW 1
#elif (App == 0x706C8618 ) //Layer of Fear
	#define DB_X 1
	#define DA_Y 17.50
	#define DA_X 0.035
	#define DB_Y 5
	#define TW 1
#elif (App == 0x2F0BD376 ) //Minecraft
	#define DA_Y 17.50
	#define DA_X 0.0625
	#define DB_W 25
	#define DB_Y 3
	#define TW 1
#elif (App == 0x84D341E3 ) //Little Nightmares
	#define DA_W 1
	#define DA_Y 33.75
	#define DA_X 0.25
	#define DA_Z 0.0015
	#define DB_Y 5
#elif (App == 0xC0AC5174 ) //Observer
	#define DA_W 1
	#define DA_Y 21.5
	#define DA_X 0.0375
	#define DB_Y 4
	#define TW 1
#elif (App == 0xABAA2255 ) //The Forest
	#define DA_W 1
	#define DB_X 1
	#define DA_Y 7.5
	#define DA_X 0.04375
	#define DB_Y 3
	#define TW 1
#elif (App == 0x67A4A23A ) //Crash Bandicoot N.Saine Trilogy
	#define DA_Y 7.5
	#define DA_Z 0.250
	#define DA_X 0.1
	#define DB_Y 4
	#define DC_X 0.580
	#define HM 1
#elif (App == 0xE160AE14 ) //Spyro Reignited Trilogy
	#define DA_W 1
	#define DA_Y 12.5
	#define DA_Z 0.0001
	#define DA_X 0.05625
	#define DB_Y 3
#elif (App == 0x5833F81C ) //Dying Light
	#define DA_W 1
	#define DA_Y 21.25
	#define DA_X 0.065
	#define DB_Y 4
	#define DB_W 62
#elif (App == 0x42C1A2B )	//CoD: WWII
	#define DA_X 0.04
	#define DA_W 1
	#define DB_Y 4
	#define DB_W 12
#elif (App == 0x86562CC2 ) //STARWARS Jedi Fallen Order
	#define DA_X 0.140
	#define DA_W 1
	#define DA_Y 13.75
	#define DA_Z 0.00025
	#define DB_Y 5
	#define DE_X 1
	#define DE_Y 0.1875
	#define DE_Z 0.475
	#define DB_Z 0.375
	#define TW 1
#elif (App == 0x88004DC9 || App == 0x1DDA9341) //Strange Brigade DX12 & Vulkan
	#define DA_X 0.0625
	#define DA_Y 20.0
	#define DA_Z 0.0005
	#define DB_Y 5
	#define DE_X 2
	#define DE_Y 0.3
	#define DE_Z 0.475
	#define TW 1
#elif (App == 0xC0052CC4) //Halo The Master Chief Collection
	#define DA_X 0.0375
	#define DA_W 1
	#define DA_Y 75.0
	#define DB_Y 5
	#define DE_X 3
	#define DE_Y 0.375
	#define DE_Z 0.375
	#define WSM 2
	#define OW_Weapon_Profiles "Read Help & Change Me\0Custom WP\0Halo: Reach\0Halo: CE Anniversary\0Halo 2: Anniversary\0Halo 3\0Halo 3: ODST\0Halo 4\0"
	#define TW 1
#elif (App == 0x2AB9ECF9) //System ReShock
	#define DA_X 0.05
	#define DA_W 1
	#define DA_Y 11.25
	#define DA_Z 0.00125
	#define DB_Y 4
	#define DE_X 4
	#define DE_Y 0.4375
	#define DE_Z 0.375
	#define DE_W 0.055
#elif (App == 0xC50993EC) //COD: Modern Warfare 2019
	#define DA_X 0.0375
	#define DA_W 1
	#define DA_Y 37.5
	#define DA_Z 0.000125
	#define DB_Y 5
	#define DB_W 12
	#define TW 1
#elif (App == 0xA640659C) //MegaMan 2.5D in 3D
	#define DA_X 0.150
	#define DA_Y 8.75
	#define DA_Z 1005.0
	#define DE_X 1
	#define DE_Y 0.275
	#define DE_Z 0.375
	#define TW 1
#elif (App == 0x49654776) //Paratopic
	#define DA_X 0.05
	#define DA_W 1
	#define DA_Y 8.75
	#define DA_Z 0.000250
	#define DB_Y 3
	#define DB_X 1
	#define TW 1
#elif (App == 0xF7590C95) //Yume Nikki -Dream Diary-
	#define DA_X 0.0625
	#define DA_W 1
	#define DA_Y 20.0
	#define DA_Z 0.002
	#define DB_X 1
	#define DB_Y 1
	#define DE_X 1
	#define DE_Y 0.35
	#define DE_Z 0.25
	#define TW 1
#elif (App == 0x65F37CDF) //American Truck Simulator
	#define DA_X 0.05375
	#define DA_Y 15.0
	#define DA_Z 0.005
	#define DB_X 1
	#define DB_Y 2
	#define DB_W 47
#elif (App == 0xB5789234) //The Park
	#define DA_X 0.05625
	#define DA_W 1
	#define DA_Y 12.5
	#define DB_Y 1
	#define TW 1
#elif (App == 0xB7C22840) //Strife
	#define DA_X 0.1
	#define DA_Y 250.0
	#define DB_W 59
	#define TW 1
#elif (App == 0x21DC397E || App == 0x653AF1E1) //Gold Source
	#define DA_X 0.045
	#define DA_Y 21.25
	#define DA_Z 0.0003
	#define DB_Y 3
	#define DB_W 60
#elif (App == 0xC2E621A5) //No Man Sky
	#define DA_X 0.04375
	#define DA_W 1
	#define DA_Y 72.5
	#define DB_Y 5
  #define DB_Z 0.0
  #define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.4
	#define TW 1
#elif (App == 0x1E9DCD00) //Witch it
	#define DA_X 0.0475
	#define DA_W 1
	#define DA_Y 47.5
	#define DB_Y 5
  #define DE_W 0.325
#elif (App == 0x6B58D180) //Outlaws
	#define DA_X 0.14375
	#define DA_Y 30
	#define DB_Y 5
	#define DB_Z 0.225
#elif (App == 0x5AC0F7E3) //SoF
	#define DA_X 0.04375
	#define DA_Y 17.5
	#define DB_Y 5
	#define DB_W 22
	#define DF_X 0.5
#elif (App == 0xEA8E05B6) //Only If
	#define DA_X 0.100
	#define DB_Y 1
	#define DE_X 1
#elif (App == 0xFDE0387 ) //Stranger Odd Worlds
	#define DA_X 0.100
	#define DA_Y 7.5
	#define DB_X 1
	#define DB_Y 1
	#define DE_X 2
	#define DC_X 0.5
	#define HM 1
#elif (App == 0x242D82C4 ) //Okami HD
	#define DA_X 0.200
	#define DA_W 1
	#define DA_Z 0.001
	#define DB_Y 1
	#define DE_X 2
  #define DE_Y 0.125
  #define DE_Z 0.375
	#define DC_X 0.5
	#define HM 1
#elif (App == 0x75B36B20 ) //Eldritch
	#define DA_Y 125.0
	#define DA_X 0.05
	#define DB_Y 4
	#define DE_X 1
	#define DB_Z 0.05
#elif (App == 0x97CBF34C ) //Dementium 2
	#define DA_Y 18.75
	#define DA_X 0.04125
	#define DB_Y 5
	#define DB_W 51
	#define DB_X 1
	#define TW 1
#elif (App == 0x5925FCC8 ) //Dusk
	#define DA_Y 25.0
	#define DA_X 0.05
	#define DB_Y 5
	#define DA_W 1
	#define DB_X 1
	#define DE_X 3
	#define DE_Z 0.375
#elif (App == 0xDDA80A38 ) //Deus Ex Rev DX9
	#define DA_X 0.04375
	#define DA_Y 20
	#define DB_Y 3
	#define DB_W 23
	#define DC_X 0.534
	#define HM 1
	#define DF_X 0.025
#elif (App == 0x1714C977) //Deus Ex DX9
	#define DA_X 0.05
	#define DA_Y 125.0
	#define DB_Y 3
	#define DB_W 24
	#define DC_X 1.0
	#define HM 1
	#define DF_X 0.05
#elif (App == 0x92583CDD ) //Legend of Dungeon
	#define DA_Y 12.5
	#define DA_Z 0.185
	#define DA_X 0.075
	#define DB_Y 4
	#define DB_X 1
#elif (App == 0xDB3A28BD ) //Monster Hunter World
	#define DA_Y 17.5
	#define DA_X 0.075
	#define DA_W 1
	#define DB_Y 5
	#define DE_X 1
	#define DE_Y 0.300
	#define DE_Z 0.4375
#elif (App == 0xC073C2BB ) //StreetFighter V
	#define DA_Y 14.0
	#define DA_X 0.250
	#define DA_W 1
	#define DB_Y 4
	#define DB_Z 0.550
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.375
#elif (App == 0xCFB8DD02 ) //DIRT RALLY 2.0
	#define DA_Y 11.25
	#define DA_X 0.040
	#define DE_W 0.350
#elif (App == 0x2F55D5A3 || App == 0x4A5220AF ) //ShadowWarrior 2013 DX11 & DX9
	#define DA_X 0.035
	#define DB_Y 4
	#define DE_X 4
	#define DE_Z 0.375
#elif (App == 0x56301DED ) //ShadowWarrior 2
	#define DA_X 0.035
	#define DA_W 1
	#define DB_Y 4
	#define DE_X 4
	#define DE_Z 0.375
#elif (App == 0x892CA092 ) //Farcry
	#define DA_Y 7.0
	#define DA_Z 0.000375
	#define DB_Z 0.105
	#define DA_X 0.055
	#define DB_Y 4
	#define DB_W 63
	#define DF_X 0.13875
#elif (App == 0x9140DBE0 ) //Farcry 2
	#define DA_X 0.05
	#define DB_Y 4
	#define DB_W 64
	#define DE_X 4
	#define DE_Z 0.375
	#define TW 1
#elif (App == 0xA4B66433 ) //Farcry 3
	#define DA_X 0.05
	#define DB_Y 4
	#define DE_X 4
	#define DE_Z 0.375
	#define DE_W 0.350
	#define TW 1
#elif (App == 0xC150B652 ) //Farcry 4
	#define DA_Y 8.75
	#define DA_W 1
	#define DA_X 0.0375
	#define DB_Y 4
	#define DE_X 4
	#define DE_Z 0.375
	#define DE_W 0.360
#elif (App == 0x2EB82B07 ) //Farcry Primal
	#define DA_Y 8.75
	#define DA_W 1
	#define DA_X 0.0375
	#define DB_Y 4
	#define DE_X 4
	#define DE_Z 0.375
	#define DE_W 0.360
#elif (App == 0xC150B805 ) //Farcry 5
	#define DA_Y 8.75
	#define DA_W 1
	#define DA_X 0.0375
	#define DB_Y 4
	#define DE_X 4
	#define DE_Z 0.375
	#define DE_W 0.360
	#define TW 1
#elif (App == 0xE3AD2F05 ) //Sauervaraten
	#define DA_Y 25.0
	#define DA_X 0.05
	#define DB_Y 5
	#define DB_W 43
	#define DF_X 0.150
#elif (App == 0xF0F2CF6A ) //Dragon Ball Z: Kakarot
	#define DA_W 1
	#define DA_Y 24.0
	#define DA_X 0.250
	#define DB_Y 3
	#define DE_X 1
	#define DE_Y 0.375
	#define DE_Z 0.400
	#define DB_Z 0.500 //Yay I know
#elif (App == 0xFA2C0106 ) //Hat in Time
	#define DA_X 0.125
	#define DB_Y 4
	#define DE_X 2
	#define DE_Y 0.162
	#define DE_Z 0.4375
	#define TW 1
#elif (App == 0xCD0E316F ) //Sonic Adventure DX Modded with BetterSADX
	#define DA_Y 8.75
	#define DA_X 0.1125
	#define DB_Y 3
	#define DE_X 2
	#define DE_Y 0.375
	#define DE_Z 0.4375
	#define DB_Z 0.250
	#define TW 1
#elif (App == 0xF9B1845A ) //Rime
	#define DA_W 1
	#define DA_Y 15.0
	#define DA_X 0.145
	#define DB_Y 4
	#define DE_X 1
	#define DE_Y 0.299
	#define DE_Z 0.400
#elif (App == 0x71170B42 ) //Blood: Fresh Suppy
	#define DA_Y 250.0
	#define DA_X 0.075
	#define DB_Y 4
#elif (App == 0x8F615A99 ) //Frostpunk
	#define DA_Y 9.375
	#define DA_X 0.250
	#define DB_Y 4
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.400
#elif (App == 0x29B47A0A ) //KingMaker
    #define DB_X 1
    #define DA_W 1
	#define DA_Y 18.75
    #define DA_Z 0.0075
	#define DA_X 0.150
	#define DB_Y 5
	#define DE_X 1
	#define DE_Y 0.5
	#define DE_Z 0.300
#elif (App == 0xBF70711C ) //Singularity
	#define DA_Y 15.0
	#define DA_X 0.0375
	#define DB_W 66
	#define DE_X 1
	#define DE_Z 0.375
	#define DF_X 0.175
	#define TW 1
#elif (App == 0x905631F2 ) //Crysis DX10 64bit
	#define DA_X 0.0375
	#define DB_Y 5
	#define DB_W 44
	#define DE_X 3
	#define DE_Z 0.375
	#define DF_X -0.175
#elif (App == 0x6061750E ) //Mirror's Edge
	#define DA_Y 12.0
  #define DA_Z 0.001
	#define DA_X 0.03
	#define DB_Y 4
	#define DB_W 70
#else
	#define NP 1 //No Profile
#endif
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
// X = [Depth Flip] Y = [Auto Balance] Z = [Auto Depth] W = [Weapon Hand]
#ifndef DB_X
    #define DB_X Depth_Flip_D
#endif
#ifndef DB_Y
    #define DB_Y Auto_Balance_D
#endif
#ifndef DB_Z
    #define DB_Z Auto_Depth_D
#endif
#ifndef DB_W
    #define DB_W Weapon_Hand_D
#endif
// X = [HUD] Y = [Barrel Distortion K1] Z = [Barrel Distortion K2] W = [Barrel Distortion Zoom]
#ifndef DC_X
    #define DC_X HUDX_D
#endif
#ifndef DC_Y
    #define DC_Y BD_K1_D
#endif
#ifndef DC_Z
    #define DC_Z BD_K2_D
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
// X = [ZPD Boundary Type] Y = [ZPD Boundary Scaling] Z = [ZPD Boundary Fade Time] W = [Weapon NearDepth]
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
    #define DE_W Weapon_Near_Depth_D
#endif
// X = [ZPD Weapon Boundary] Y = [NULL_A] Z = [NULL_B] W = [NULL_C]
#ifndef DF_X
    #define DF_X ZPD_Weapon_Boundary_Adjust
#endif
#ifndef DF_Y
    #define DF_Y NULL_A
#endif
#ifndef DF_Z
    #define DF_Z NULL_B
#endif
#ifndef DF_W
    #define DF_W NULL_C
#endif

//Special Toggles
#ifndef RE
    #define RE REF //Resident Evil Fix
#endif
#ifndef NC
    #define NC NCW //Not Compatible Warning
#endif
#ifndef TW
    #define TW FTW //Flashing Text Warning
#endif
#ifndef NP
    #define NP NPW //No Profile Warning
#endif
#ifndef ID
    #define NI IDF //Inverted Depth Fix
#endif
#ifndef SP
    #define SP SPF //Size & Position Fix
#endif
#ifndef DC
    #define DC BDF //Barrel Distortion Fix
#endif
#ifndef HM
    #define HM HMT //HUD Mode Trigger
#endif

//Weapon Settings
#ifndef OW_Weapon_Profiles
    #define OW_Weapon_Profiles "WP Off\0Custom WP\0WP 0\0WP 1\0WP 2\0WP 3\0WP 4\0WP 5\0WP 6\0WP 7\0WP 8\0WP 9\0WP 10\0WP 11\0WP 12\0WP 13\0WP 14\0WP 15\0WP 16\0WP 17\0WP 18\0WP 19\0WP 20\0WP 21\0WP 22\0WP 23\0WP 24\0WP 25\0WP 26\0WP 27\0WP 28\0WP 29\0WP 30\0WP 31\0WP 32\0WP 33\0WP 34\0WP 35\0WP 36\0WP 37\0WP 38\0WP 39\0WP 40\0WP 41\0WP 42\0WP 43\0WP 44\0WP 45\0WP 46\0WP 47\0WP 48\0WP 49\0WP 50\0WP 51\0WP 52\0WP 53\0WP 54\0WP 55\0WP 56\0WP 57\0WP 58\0WP 59\0WP 60\0WP 61\0WP 62\0WP 63\0WP 64\0WP 65\0WP 66\0WP 67\0WP 68\0WP 69\0WP 70\0"
#endif
#ifndef WSM //One is Normal | Two is MCC | Three is Prey | Four is Blood 2
    #define WSM 1 //Weapon Setting Mode
#endif

#if WSM == 1
float3 Weapon_Profiles(float WP ,float3 Weapon_Adjust) //Tried Switch But, can't compile in some older versions of ReShade.
{   if(WP == 2)
        return float3(0.425,5.0,1.125);      //WP 0  | ES: Oblivion #C753DADB
    else if(WP == 3)
        return float3(0,0,0);                //WP 1  | Game
    else if(WP == 4)
        return float3(0.625,37.5,7.25);      //WP 2  | BorderLands 2 #7B81CCAB
    else if(WP == 5)
        return float3(0,0,0);                //WP 3  | Game
    else if(WP == 6)
        return float3(0.253,28.75,98.5);     //WP 4  | Fallout 4 #2D950D30
    else if(WP == 7)
        return float3(0.276,20.0,9.5625);    //WP 5  | Skyrim: SE #3950D04E
    else if(WP == 8)
        return float3(0.338,20.0,9.20);      //WP 6  | DOOM 2016 #142EDFD6
    else if(WP == 9)
        return float3(0.255,177.5,63.025);   //WP 7  | CoD:Black Ops #17232880 CoD:MW2 #9D77A7C4 CoD:MW3 #22EF526F
    else if(WP == 10)
        return float3(0.254,100.0,0.9843);   //WP 8  | CoD:Black Ops II #D691718C
    else if(WP == 11)
        return float3(0.254,203.125,0.98435);//WP 9  | CoD:Ghost #7448721B
    else if(WP == 12)
        return float3(0.254,203.125,0.98433);//WP 10 | CoD:AW #23AB8876 CoD:MW Re #BF4D4A4e
    else if(WP == 13)
        return float3(0.254,125.0,0.9843);   //WP 11 | CoD:IW #1544075
    else if(WP == 14)
        return float3(0.255,200.0,63.0);     //WP 12 | CoD:WaW #697CDA52
    else if(WP == 15)
        return float3(0.510,162.5,3.975);    //WP 13 | CoD #4383C12A CoD:UO #239E5522 CoD:2 #3591DE9C
    else if(WP == 16)
        return float3(0.254,23.75,0.98425);  //WP 14 | CoD: Black Ops IIII #73FA91DC
    else if(WP == 17)
        return float3(0.375,60.0,15.15625);  //WP 15 | Quake DarkPlaces #37BD797D
    else if(WP == 18)
        return float3(0.7,14.375,2.5);       //WP 16 | Quake 2 XP #34F4B6C
    else if(WP == 19)
        return float3(0.750,30.0,1.050);     //WP 17 | Quake 4 #ED7B83DE
    else if(WP == 20)
        return float3(0,0,0);                //WP 18 | Game
    else if(WP == 21)
        return float3(0.450,12.0,23.75);     //WP 19 | Metro Redux Games #886386A
    else if(WP == 22)
        return float3(0.350,12.5,2.0);       //WP 20 | Soldier of Fortune
    else if(WP == 23)
        return float3(0.286,1500.0,7.0);     //WP 21 | Deus Ex rev
    else if(WP == 24)
        return float3(35.0,250.0,0);         //WP 21 | Deus Ex
    else if(WP == 25)
        return float3(0.625,350.0,0.785);    //WP 23 | Minecraft
    else if(WP == 26)
        return float3(0.255,6.375,53.75);    //WP 24 | S.T.A.L.K.E.R: Games #F5C7AA92 #493B5C71
    else if(WP == 27)
        return float3(0,0,0);                //WP 25 | Game
    else if(WP == 28)
        return float3(0.750,30.0,1.025);     //WP 26 | Prey 2006 #DE2F0F4D
    else if(WP == 29)
        return float3(0.2832,13.125,0.8725); //WP 27 | Prey 2017 High Settings and < #36976F6D
    else if(WP == 30)
        return float3(0.2832,13.75,0.915625);//WP 28 | Prey 2017 Very High #36976F6D
    else if(WP == 31)
        return float3(0.7,9.0,2.3625);       //WP 29 | Return to Castle Wolfenstine #BF757E3A
    else if(WP == 32)
        return float3(0.4894,62.50,0.98875); //WP 30 | Wolfenstein #30030941
    else if(WP == 33)
        return float3(1.0,93.75,0.81875);    //WP 31 | Wolfenstein: The New Order #C770832 / The Old Blood #3E42619F
    else if(WP == 34)
        return float3(0,0,0);                //WP 32 | Wolfenstein II: The New Colossus / Cyberpilot
    else if(WP == 35)
        return float3(0.278,37.50,9.1);      //WP 33 | Black Mesa #6FC1FF71
    else if(WP == 36)
        return float3(0.420,4.75,1.0);       //WP 34 | Blood 2 #6D3CD99E
    else if(WP == 37)
        return float3(0.500,4.75,0.75);      //WP 35 | Blood 2 Alt #6D3CD99E
    else if(WP == 38)
        return float3(0.785,21.25,0.3875);   //WP 36 | SOMA #F22A9C7D
    else if(WP == 39)
        return float3(0.444,20.0,1.1875);    //WP 37 | Cryostasis #6FB6410B
    else if(WP == 40)
        return float3(0.286,80.0,7.0);       //WP 38 | Unreal Gold with v227 #16B8D61A
    else if(WP == 41)
        return float3(0.280,15.5,9.1);       //WP 39 | Serious Sam Revolution #EB9EEB74/Serious Sam HD: The First Encounter /The Second Encounter /Serious Sam 2 #8238E9CA/ Serious Sam 3: BFE*
    else if(WP == 42)
        return float3(0,0,0);                //WP 40 | Serious Sam 4: Planet Badass
    else if(WP == 43)
        return float3(0.800,15.0,0.3);       //WP 41 | Sauerbraten 2
    else if(WP == 44)
        return float3(0.277,20.0,8.8);       //WP 42 | TitanFall 2 #308AEBEA
    else if(WP == 45)
        return float3(0.7,16.250,0.300);     //WP 43 | Project Warlock #5FCFB1E5
    else if(WP == 46)
        return float3(0.625,9.0,2.375);      //WP 44 | Kingpin Life of Crime #7DCCBBBD
    else if(WP == 47)
        return float3(0.28,20.0,9.0);        //WP 45 | EuroTruckSim2 #9C5C946E
    else if(WP == 48)
        return float3(0.458,10.5,1.105);     //WP 46 | F.E.A.R #B302EC7 & F.E.A.R 2: Project Origin #91D9EBAF
    else if(WP == 49)
        return float3(1.5,37.5,0.99875);     //WP 47 | Condemned Criminal Origins
    else if(WP == 50)
        return float3(2.0,16.25,0.09);       //WP 48 | Immortal Redneck CP alt 1.9375 #2C742D7C
    else if(WP == 51)
        return float3(0.485,62.5,0.9625);    //WP 49 | Dementium 2
    else if(WP == 52)
        return float3(0.489,68.75,1.02);     //WP 50 | NecroVisioN & NecroVisioN: Lost Company #663E66FE
    else if(WP == 53)
        return float3(1.0,237.5,0.83625);    //WP 51 | Rage64 #AA6B948E
    else if(WP == 54)
        return float3(0,0,0);                //WP 52 | Rage 2
    else if(WP == 55)
        return float3(0.425,15.0,99.0);      //WP 53 | Bioshock Remastred #44BD41E1
    else if(WP == 56)
        return float3(0.425,21.25,99.5);     //WP 54 | Bioshock 2 Remastred #7CF5A01
    else if(WP == 57)
        return float3(0.425,5.25,1.0);       //WP 55 | No One Lives Forever
    else if(WP == 58)
        return float3(0.519,31.25,8.875);    //WP 56 | No One Lives Forever 2
    else if(WP == 59)
        return float3(0.5,8.0,0);            //WP 57 | Strife
    else if(WP == 60)
        return float3(0.350,9.0,1.8);        //WP 58 | Gold Source
    else if(WP == 61)
        return float3(1.825,13.75,0);        //WP 59 | No Man Sky FPS Mode
    else if(WP == 62)
        return float3(1.962,5.5,0);          //WP 60 | Dying Light
    else if(WP == 63)
        return float3(0.287,180.0,9.0);      //WP 61 | Farcry
    else if(WP == 64)
        return float3(0.2503,55.0,1000.0);   //WP 62 | Farcry 2
    else if(WP == 65)
        return float3(0,0,0);                //WP 65 | Game
    else if(WP == 66)
        return float3(0.2503,52.5,987.5);    //WP 64 | Singularity
    else if(WP == 67)
        return float3(0,0,0);                //WP 65 | Game
		else if(WP == 68)
		    return float3(0,0,0);                //WP 66 | Game
		else if(WP == 69)
				return float3(0,0,0);                //WP 67 | Game
		else if(WP == 70)
				return float3(0.251,5.6875,950.0);   //WP 68 | Mirror Edge
		else if(WP == 71)
				return float3(0,0,0);                //WP 69 | Game
		else if(WP == 72)
				return float3(0,0,0);                //WP 70 | Game
    else
        return Weapon_Adjust;
}
#elif WSM == 2
float3 Weapon_Profiles(float WP ,float3 Weapon_Adjust) // MCC
{   if(WP == 2)
        return float3(0,0,0);                //WP 0  | Halo: Reach
    else if(WP == 3)
        return float3(1.5,26.25,0.2);        //WP 1  | Halo: CE Anniversary
    else if(WP == 4)
        return float3(0,0,0);                //WP 2  | Halo 2: Anniversary
    else if(WP == 5)
        return float3(0,0,0);                //WP 3  | Halo 3
    else if(WP == 6)
        return float3(0,0,0);                //WP 4  | Halo 3: ODST
    else if(WP == 7)
        return float3(0,0,0);                //WP 5  | Halo 4
		else
		    return Weapon_Adjust;
}
#endif
