////----------------------------------------//
///SuperDepth3D Overwatch Automation Shader///
//----------------------------------------////

//---------------------------------------OVERWATCH---------------------------------------//
// If you are reading this stop. Go away and never look back. From this point on if you  //
// still think it's is worth looking at this..... Then no one can save you or your soul. //
// You will be cursed with never enjoying any memes to their fullest potential.......... //
// Ya that's it.                                                                         //
//---------------------------------------------------------------------------------------//

//--------------------------------------Code Start--------------------------------------//
//SuperDepth3D Defaults
static const float4 DA = float4(0.025,7.5,0.0,0);	// float4(ZPD,Depth_Adjust,Offset,Depth_Linearization)
static const float4 DB = float4(0,0.0,0.0,0);		// float4(Depth_Flip,Null,Null,Weapon_Hand)
static const float4 DC = float4(0.0,0.5,0.0,0.0);	// float4(HUDX,HUDY,Null,Null) 
static const float4 DD = float4(1.0,1.0,0.0,0.0);	// float4(HV_X,HV_Y,DepthPX,DepthPY)

//Hashes List//
//  SD3DOAS  //
//Game Hashes//

#define App __APPLICATION__ 
#if (App == 0xC753DADB)		//ES: Oblivion 
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,2), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x7B81CCAB)	//BorderLands 2
	static const float4x4 SD3D_D = float4x4( float4(DA.x,20.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,4), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x2D950D30)	//Fallout 4
	static const float4x4 SD3D_D = float4x4( float4(DA.x,6.25,DA.z,DA.w), float4(DB.x,DB.y,DB.z,6), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x3950D04E)	//Skyrim: SE
	static const float4x4 SD3D_D = float4x4( float4(DA.x,6.25,DA.z,DA.w), float4(DB.x,DB.y,DB.z,7), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x142EDFD6)	//DOOM 2016
	static const float4x4 SD3D_D = float4x4( float4(DA.x,20.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,8), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x17232880 || App == 0x9D77A7C4 || App == 0x22EF526F )	//CoD:Black Ops | CoD:MW2 |CoD:MW3
	static const float4x4 SD3D_D = float4x4( float4(DA.x,12.5,DA.z,DA.w), float4(DB.x,DB.y,DB.z,9), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0xD691718C)	//CoD:Black Ops II #D691718C
	static const float4x4 SD3D_D = float4x4( float4(DA.x,13.75,DA.z,1), float4(DB.x,DB.y,DB.z,10), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0x7448721B)	//CoD:Ghost #7448721B
	static const float4x4 SD3D_D = float4x4( float4(DA.x,13.75,DA.z,1), float4(DB.x,DB.y,DB.z,11), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x23AB8876 || App == 0xBF4D4A41)	//CoD:AW | CoD:MW Re
	static const float4x4 SD3D_D = float4x4( float4(DA.x,13.75,DA.z,1), float4(DB.x,DB.y,DB.z,12), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0x1544075)	//CoD:IW
	static const float4x4 SD3D_D = float4x4( float4(DA.x,13.75,DA.z,1), float4(DB.x,DB.y,DB.z,13), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0
#elif (App == 0x697CDA52)	//CoD:WaW
	static const float4x4 SD3D_D = float4x4( float4(DA.x,12.5,DA.z,DA.w), float4(DB.x,DB.y,DB.z,14), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0x4383C12A || App == 0x239E5522 || App == 0x3591DE9C)	//CoD | CoD:UO | CoD:2
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,15), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0
#elif (App == 0x37BD797D)	//Quake DarkPlaces
	static const float4x4 SD3D_D = float4x4( float4(DA.x,15.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,17), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x37BD797D)	//Quake 2 XP
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,18), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0xED7B83DE)	//Quake 4 #ED7B83DE
	static const float4x4 SD3D_D = float4x4( float4(DA.x,15.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,19), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	 
#elif (App == 0x886386A)	//Metro Redux Games
	static const float4x4 SD3D_D = float4x4( float4(DA.x,12.5,DA.z,DA.w), float4(DB.x,DB.y,DB.z,21), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0xF5C7AA92 || App == 0x493B5C71)	//S.T.A.L.K.E.R: Games
	static const float4x4 SD3D_D = float4x4( float4(DA.x,10.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,26), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0xDE2F0F4D)	//Prey 2006
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,28), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	 
#elif (App == 0x36976F6D)	//Prey 2017 High Settings and <
	static const float4x4 SD3D_D = float4x4( float4(DA.x,18.7,DA.z,DA.w), float4(DB.x,DB.y,DB.z,29), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0xBF757E3A)	//Return to Castle Wolfenstine
	static const float4x4 SD3D_D = float4x4( float4(DA.x,8.75,DA.z,DA.w), float4(DB.x,DB.y,DB.z,31), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0xC770832 || App == 0x3E42619F )	//Wolfenstein: The New Order | The Old Blood
	static const float4x4 SD3D_D = float4x4( float4(DA.x,25.0,0.00125,DA.w), float4(DB.x,DB.y,DB.z,33), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 		
#elif (App == 0x6FC1FF71 )	//Black Mesa
	static const float4x4 SD3D_D = float4x4( float4(DA.x,8.75,DA.z,DA.w), float4(DB.x,DB.y,DB.z,35), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0x6D3CD99E )	//Blood 2
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,36), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0xF22A9C7D )	//SOMA
	static const float4x4 SD3D_D = float4x4( float4(DA.x,10.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,38), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0x6FB6410B )	//Cryostasis
	static const float4x4 SD3D_D = float4x4( float4(DA.x,13.75,DA.z,DA.w), float4(DB.x,DB.y,DB.z,39), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x16B8D61A )	//Unreal Gold with v227
	static const float4x4 SD3D_D = float4x4( float4(DA.x,17.5,DA.z,DA.w), float4(DB.x,DB.y,DB.z,40), float4(0.534,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 1 	
#elif (App == 0xEB9EEB74 || App == 0x8238E9CA )	//Serious Sam Revolution | Serious Sam 2
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,0.1111,DA.w), float4(DB.x,DB.y,DB.z,41), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x308AEBEA )	//TitanFall 2
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,44), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0x5FCFB1E5 )	//Project Warlock
	static const float4x4 SD3D_D = float4x4( float4(DA.x,17.5,DA.z,1), float4(DB.x,DB.y,DB.z,45), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x7DCCBBBD)	//Kingpin Life of Crime
	static const float4x4 SD3D_D = float4x4( float4(DA.x,10.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,46), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0x9C5C946E)	//EuroTruckSim2
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,47), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#elif (App == 0xB302EC7 || App == 0x91D9EBAF )	//F.E.A.R | F.E.A.R 2: Project Origin
	static const float4x4 SD3D_D = float4x4( float4(DA.x,8.75,DA.z,DA.w), float4(DB.x,DB.y,DB.z,48), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x2C742D7C)	//Immortal Redneck CP alt 1.9375
	static const float4x4 SD3D_D = float4x4( float4(DA.x,20.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,50), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x663E66FE )	//NecroVisioN & NecroVisioN: Lost Company
	static const float4x4 SD3D_D = float4x4( float4(DA.x,10.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,52), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0xAA6B948E )	//Rage64
	static const float4x4 SD3D_D = float4x4( float4(DA.x,20.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,53), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x44BD41E1 )	//Bioshock Remastred
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,0.001,DA.w), float4(DB.x,DB.y,DB.z,55), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 
#elif (App == 0x7CF5A01 )	//Bioshock 2 Remastred
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,0.001,DA.w), float4(DB.x,DB.y,DB.z,56), float4(0.5034,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 1
#elif (App == 0x22BA110F )	//Turok: DH 2017
	static const float4x4 SD3D_D = float4x4( float4(0.002,250.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,55), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0  
#elif (App == 0x5F1DBD3B )	//Turok2: SoE 2017
	static const float4x4 SD3D_D = float4x4( float4(0.002,250.0,DA.z,DA.w), float4(DB.x,DB.y,DB.z,55), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0  
#else
	static const float4x4 SD3D_D = float4x4( float4(DA.x,DA.y,DA.z,DA.w), float4(DB.x,DB.y,DB.z,DB.w), float4(DC.x,DC.y,DC.z,DC.w), float4(DD.x,DD.y,DD.z,DD.w) );
	#define HM 0 	
#endif	
