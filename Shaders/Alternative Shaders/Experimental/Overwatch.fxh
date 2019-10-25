////----------------------------------------//
///SuperDepth3D Overwatch Automation Shader///
//----------------------------------------////

//---------------------------------------OVERWATCH---------------------------------------//
// If you are reading this stop. Go away and never look back. From this point on if you  //
// still think it's is worth looking at this..... Then no one can save you or your soul. //
// You will be cursed with never enjoying any memes to their fullest potential.......... //
// Ya that's it. JK                                                                      //
// The name comes from this.                                                             //
// https://en.wikipedia.org/wiki/Overwatch_(military_tactic)                             //
// Since this File looks ahead and sends information the Main shader to prepair it self. //
//---------------------------------------------------------------------------------------//
//Special Thanks to CeeJay.dk for code simplification and guidance.                      //
//You can contact him here https://github.com/CeeJayDK                                   //
//----------------------------------------LICENSE----------------------------------------//
// ===================================================================================== //
// Overwatch is licenses under: Attribution-NoDerivatives 4.0 International              //
//                                                                                       //
// You are free to:                                                                      //
// Share - copy and redistribute the material in any medium or format                    //
// for any purpose, even commercially.                                                   //
// The licensor cannot revoke these freedoms as long as you follow the license terms.    //
// Under the following terms:                                                            //
// Attribution:                                                                          //
// You must give appropriate credit, provide a link to the license, and indicate if      //
// changes were made.                                                                    //
// You may do so in any reasonable manner, but not in any way that suggests the licensor //
// endorses you or your use.                                                             //
//                                                                                       //
// NoDerivatives:                                                                        //
// If you remix, transform, or build upon the material, you may not distribute the       //
// modified material.                                                                    //
//                                                                                       //
// No additional restrictions:                                                           //
// You may not apply legal terms or technological measures that legally restrict others  //
// from doing anything the license permits.                                              //
//                                                                                       //
// https://creativecommons.org/licenses/by-nd/4.0/                                       //
// ===================================================================================== //
//--------------------------------------Code Start---------------------------------------//

//SuperDepth3D Defaults
static const float ZPD_D = 0.025;         //ZPD
static const float Depth_Adjust_D = 7.5;  //Depth Adjust
static const float Offset_D = 0.0;        //Offset
static const int Depth_Linearization = 0; //Linearization
static const int Depth_Flip = 0;          //Depth Flip
static const int Auto_Balance = 0;        //Auto Balance
static const float Auto_Depth = 0.1;      //Auto Depth Range
static const int Weapon_Hand = 0;         //Weapon Profile
static const float HUDX = 0.0;            //Heads Up Display Cut Off Point
static const float BD_K1 = 0.0;           //Barrel Distortion K1
static const float BD_K2 = 0.0;           //Barrel Distortion K2
static const float BD_Zoom = 0.0;         //Barrel Distortion Zoom
static const float HVS_X = 1.0;           //Horizontal Size
static const float HVS_Y = 1.0;           //Vertical Size
static const int HVP_X = 0;               //Horizontal Position
static const int HVP_Y = 0;               //Vertical Position

//Special Toggles Defaults
static const int REF = 0;                 //Resident Evil Fix
static const int NCW = 0;                 //Not Compatible Warning
static const int FTW = 0;                 //Flashing Text Warning
static const int NPW = 0;                 //No Profile Warning
static const int IDF = 0;                 //Inverted Depth Fix
static const int SPF = 0;                 //Size & Position Fix
static const int IDF = 0;                 //Image Distortion Fix

//Special Handling
#if exists "LEGOBatman.exe" 							//Lego Batman
	#define sApp 0xA100000
#elif exists "LEGOBatman2.exe"							//LEGO Batman 2
	#define sApp 0xA100000
#elif exists "GameComponentsOzzy_Win32Steam_Release.dll"//Batman BlackGate
	#define sApp 0xA200000
#else
	#define sApp __APPLICATION__
#endif

//Check for ReShade Version for 64bit game Bug.
#if !defined(__RESHADE__) || __RESHADE__ < 43000
	#if exists "ACU.exe" 									//Assassin's Creed Unity
		#define App 0xA0762A98
	#elif exists "BatmanAK.exe" 							//Batman Arkham Knight
		#define App 0x4A2297E4
	#elif exists "DOOMx64.exe" 								//DOOM 2016
		#define App 0x142EDFD6
	#elif exists "RED-Win64-Shipping.exe"					//DragonBall Fighters Z
		#define App 0x31BF8AF6
	#elif exists "HellbladeGame-Win64-Shipping.exe" 		//Hellblade Senua's Sacrifice
		#define App 0xAAA18268
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
    #define DA_Y 20.0
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
#elif (App == 0x142EDFD6 || App == 0x2A0ECCC9 )	//DOOM 2016
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
#elif (App == 0xBF757E3A )	//Return to Castle Wolfenstine
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
#elif (App == 0x16B8D61A )	//Unreal Gold with v227
	#define DA_Y 17.5
	#define DB_Y 1
	#define DB_W 40
	#define DC_X 0.534
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
#elif (App == 0x44BD41E1 )	//Bioshock Remastred
	#define DA_Z 0.001
	#define DB_Y 3
	#define DB_W 55
#elif (App == 0x7CF5A01 )	//Bioshock 2 Remastred
	#define DA_Z 0.001
	#define DB_W 56
	#define DB_Y 3
	#define DC_X 0.5034
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
#elif (App == 0x61243AED )	//Shadow Warrior Classic source port
	#define DA_Y 10.0
	#define DA_X 0.05
	#define DA_Z 1.0
	#define DB_Y 4
#elif (App == 0x5AE8FA62 )	//Shadow Warrior Clasic Redux
	#define DA_Y 10.0
	#define DA_X 0.05
	#define DA_Z 1.0
	#define DB_Y 4
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
#elif (App == 0x86D33094 )	//Rise of the TombRaider
	#define DA_X 0.075
	#define DB_Y 3
	#define DA_Y 25.0
	#define DA_Z 0.02
#elif (App == 0x60F436C6 )	//RESIDENT EVIL 2  BIOHAZARD RE2
	#define DA_X 0.1375
	#define DB_Y 3
	#define DB_Z 0.015
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
	#define DB_Z 0.4
	#define DA_Y 75.0
	#define DA_Z 0.021
	#define RE 1
#elif (App == 0xAAA18268 )	//Hellblade
	#define DB_Y 1
	#define DA_Y 25.0
	#define DA_W 1
	#define DA_Z 0.0005
	#define DB_Z 0.25
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
	#define DB_Z 0.10
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
#elif (App == 0xBF49B12E )	//Vampyr
	#define DA_W 1
	#define DA_Y 23.0
	#define DA_X 0.05
	#define DB_Y 5
#elif (App == 0x85F0A0FF )	//LUST for Darkness
	#define DA_W 1
	#define DB_X 1
	#define DA_Y 13.75
	#define DA_Z 0.001
	#define DA_X 0.04
	#define DB_Y 4
	#define DB_Z 0.125
	#define TW 1
#else
	#define NP 1 //No Profile
#endif

//Change Output
//#ifndef checks whether the given token has been #defined earlier in the file or in an included file
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
    #define DA_W Depth_Linearization
#endif
#ifndef DB_X
    #define DB_X Depth_Flip
#endif
#ifndef DB_Y
    #define DB_Y Auto_Balance
#endif
#ifndef DB_Z
    #define DB_Z Auto_Depth
#endif
#ifndef DB_W
    #define DB_W Weapon_Hand
#endif
#ifndef DC_X
    #define DC_X HUDX
#endif
#ifndef DC_Y
    #define DC_Y BD_K1
#endif
#ifndef DC_Z
    #define DC_Z BD_K2
#endif
#ifndef DC_W
    #define DC_W BD_Zoom
#endif
#ifndef DD_X
    #define DD_X HVS_X
#endif
#ifndef DD_Y
    #define DD_Y HVS_Y
#endif
#ifndef DD_Z
    #define DD_Z HVP_X
#endif
#ifndef DD_W
    #define DD_W HVP_Y
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
    #define DC IDF //Image Distortion Fix
#endif
