////----------------------------------------//
///SuperDepth3D Overwatch Automation Shader///
//----------------------------------------////

//---------------------------------------OVERWATCH---------------------------------------//
// If you are reading this stop. Go away and never look back. From this point on if you  //
// still think it's is worth looking at this..... Then no one can save you or your soul. //
// You will be cursed with never enjoying any memes to their fullest potential.......... //
// Ya that's it.                                                                         //
// The name comes from this.                                                             //
// https://en.wikipedia.org/wiki/Overwatch_(military_tactic)                             //
// Since this File looks ahead and sends information the Main shader to prepair it self. //
//---------------------------------------------------------------------------------------//
//Special Thanks to CeeJay.dk for code simplification and guidance.                      // 
//You can contact him here https://github.com/CeeJayDK                                   //
//--------------------------------------Code Start---------------------------------------//
	
//SuperDepth3D Defaults
static const float ZPD_D = 0.025;
static const float Depth_Adjust_D = 7.5;
static const float Offset_D = 0.0;
static const int Depth_Linearization = 0;
static const int Depth_Flip = 0;
static const float Null_A = 0.0;
static const float Null_B = 0.0;
static const int Weapon_Hand = 0;
static const float HUDX = 0.0;
static const float HUDY = 0.5;
static const float Null_C = 0.0;
static const float Null_D = 0.0;
static const float HV_X = 1.0;
static const float HV_Y = 1.0;
static const float DepthPX = 0.0;
static const float DepthPY = 0.0;

//Hashes List//
//Game Hashes//
#define App __APPLICATION__ 
#if (App == 0xC753DADB)		//ES: Oblivion 
	#define DB_W 2
	#define HM 0 
#elif (App == 0x7B81CCAB)	//BorderLands 2
    #define DA_Y 20.0
    #define DB_W 4.0
	#define HM 0 
#elif (App == 0x2D950D30)	//Fallout 4
	#define DA_Y 6.25
	#define DB_W 6
	#define HM 0 
#elif (App == 0x3950D04E)	//Skyrim: SE
	#define DA_Y 6.25
	#define DB_W 7
	#define HM 0 
#elif (App == 0x142EDFD6 || App == 0x2A0ECCC9)	//DOOM 2016
	#define DA_Y 20.0
	#define DB_W 8
	#define HM 0 
#elif (App == 0x17232880 || App == 0x9D77A7C4 || App == 0x22EF526F )	//CoD:Black Ops | CoD:MW2 |CoD:MW3
	#define DA_Y 12.5
	#define DB_W 9
	#define HM 0 
#elif (App == 0xD691718C)	//CoD:Black Ops II #D691718C
	#define DA_Y 13.75
	#define DA_W 1
	#define DB_W 10
	#define HM 0 	
#elif (App == 0x7448721B)	//CoD:Ghost #7448721B
	#define DA_Y 13.75
	#define DA_W 1
	#define DB_W 11
	#define HM 0 
#elif (App == 0x23AB8876 || App == 0xBF4D4A41)	//CoD:AW | CoD:MW Re
	#define DA_Y 13.75
	#define DA_W 1
	#define DB_W 12
	#define HM 0 	
#elif (App == 0x1544075)	//CoD:IW
	#define DA_Y 13.75
	#define DA_W 1
	#define DB_W 13
	#define HM 0
#elif (App == 0x697CDA52)	//CoD:WaW
	#define DA_Y 12.5
	#define DB_W 14
	#define HM 0 	
#elif (App == 0x4383C12A || App == 0x239E5522 || App == 0x3591DE9C)	//CoD | CoD:UO | CoD:2
	#define DB_W 15
	#define HM 0
#elif (App == 0x73FA91DC)	//CoD: Black Ops IIII
	#define DA_Y 22.5
	#define DA_W 1
	#define DB_W 16
	#define HM 0 
#elif (App == 0x37BD797D)	//Quake DarkPlaces
	#define DA_Y 15.0
	#define DB_W 17
	#define HM 0 
#elif (App == 0x37BD797D)	//Quake 2 XP
	#define DB_W 18
	#define HM 0 	
#elif (App == 0xED7B83DE)	//Quake 4 #ED7B83DE
	#define DA_Y 15.0
	#define DB_W 19
	#define HM 0 	 
#elif (App == 0x886386A)	//Metro Redux Games
	#define DA_Y 12.5
	#define DB_W 21
	#define HM 0 	
#elif (App == 0xF5C7AA92 || App == 0x493B5C71)	//S.T.A.L.K.E.R: Games
	#define DA_Y 10.0
	#define DB_W 26
	#define HM 0 
#elif (App == 0xDE2F0F4D)	//Prey 2006
	#define DB_W 28
	#define HM 0 	 
#elif (App == 0x36976F6D)	//Prey 2017 High Settings and <
	#define DA_Y 18.7
	#define DB_W 29
	#define HM 0 	
#elif (App == 0xBF757E3A)	//Return to Castle Wolfenstine
	#define DA_Y 8.75
	#define DB_W 31
	#define HM 0 
#elif (App == 0xC770832 || App == 0x3E42619F )	//Wolfenstein: The New Order | The Old Blood
	#define DA_Y 25.0
	#define DA_Z 0.00125
	#define DB_W 33
	#define HM 0 		
#elif (App == 0x6FC1FF71 )	//Black Mesa
	#define DA_Y 8.75
	#define DB_W 35
	#define HM 0 	
#elif (App == 0x6D3CD99E )	//Blood 2
	#define DB_W 36
	#define HM 0 	
#elif (App == 0xF22A9C7D )	//SOMA
	#define DA_Y 10.0
	#define DB_W 38
	#define HM 0 	
#elif (App == 0x6FB6410B )	//Cryostasis
	#define DA_Y 13.75
	#define DB_W 39
	#define HM 0 
#elif (App == 0x16B8D61A )	//Unreal Gold with v227
	#define DA_Y 17.5
	#define DB_W 40
	#define DC_X 0.534
	#define HM 1 	
#elif (App == 0xEB9EEB74 || App == 0x8238E9CA )	//Serious Sam Revolution | Serious Sam 2
	#define DA_Z 0.1111
	#define DB_W 41
	#define HM 0 
#elif (App == 0x308AEBEA )	//TitanFall 2
	#define DB_W 44
	#define HM 0 	
#elif (App == 0x5FCFB1E5 )	//Project Warlock
	#define DA_Y 17.5
	#define DA_W 1
	#define DB_W 45
	#define HM 0 
#elif (App == 0x7DCCBBBD)	//Kingpin Life of Crime
	#define DA_Y 10.0
	#define DB_W 46
	#define HM 0 	
#elif (App == 0x9C5C946E)	//EuroTruckSim2
	#define DB_W 47
	#define HM 0 	
#elif (App == 0xB302EC7 || App == 0x91D9EBAF )	//F.E.A.R | F.E.A.R 2: Project Origin
	#define DA_Y 8.75
	#define DB_W 48
	#define HM 0 
#elif (App == 0x2C742D7C)	//Immortal Redneck CP alt 1.9375
	#define DA_Y 20.0
	#define DB_W 50
	#define HM 0 
#elif (App == 0x663E66FE )	//NecroVisioN & NecroVisioN: Lost Company
	#define DA_Y 10.0
	#define DB_W 52
	#define HM 0 
#elif (App == 0xAA6B948E )	//Rage64
	#define DA_Y 20.0
	#define DB_W 53
	#define HM 0 
#elif (App == 0x44BD41E1 )	//Bioshock Remastred
	#define DA_Z 0.001
	#define DB_W 55
	#define HM 0 
#elif (App == 0x7CF5A01 )	//Bioshock 2 Remastred
	#define DA_Z 0.001
	#define DB_W 56
	#define DC_X 0.5034
	#define HM 1
#elif (App == 0x22BA110F )	//Turok: DH 2017
	#define DA_X 0.002
	#define DA_Y 250.0
	#define HM 0  
#elif (App == 0x5F1DBD3B )	//Turok2: SoE 2017
	#define DA_X 0.002
	#define DA_Y 250.0
	#define HM 0  
//#else
	//#define HM 0 	
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
    #define DB_Y Null_A
#endif
#ifndef DB_Z
    #define DB_Z Null_B
#endif
#ifndef DB_W
    #define DB_W Weapon_Hand
#endif

#ifndef DC_X
    #define DC_X HUDX
#endif
#ifndef DC_Y
    #define DC_Y HUDY
#endif
#ifndef DC_Z
    #define DC_Z Null_C
#endif
#ifndef DC_W
    #define DC_W Null_D
#endif

#ifndef DD_X
    #define DD_X HV_X
#endif
#ifndef DD_Y
    #define DD_Y HV_Y
#endif
#ifndef DD_Z
    #define DD_Z DepthPX
#endif
#ifndef DD_W
    #define DD_W DepthPY
#endif
