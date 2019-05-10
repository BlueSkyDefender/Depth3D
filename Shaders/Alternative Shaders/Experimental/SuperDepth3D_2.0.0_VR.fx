 ////-------------------//
 ///**SuperDepth3D_VR**///
 //-------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.0.0          																														*//
 //* For Reshade 3.0																																								*//
 //* --------------------------																																						*//
 //* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																								*//
 //* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																				*//
 //* I would also love to hear about a project you are using it with.																												*//
 //* https://creativecommons.org/licenses/by/3.0/us/																																*//
 //*																																												*//
 //* Jose Negrete AKA BlueSkyDefender																																				*//
 //*																																												*//
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				*//	
 //* ---------------------------------																																				*//
 //*																																												*//
 //* Original work was based on the shader code from																																*//
 //* CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology																				*//
 //* Also Fu-Bama a shader dev at the reshade forums https://reshade.me/forum/shader-presentation/5104-vr-universal-shader															*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//USER EDITABLE PREPROCESSOR FUNCTIONS START//

// Determines The resolution of the Depth Map. For 4k Use 0.75 or 0.5. For 1440p Use 0.75. For 1080p use 1. Too low of a resolution will remove too much detail.
#define Depth_Map_Division 1.0

//Weapon Zero Parallax Distance
#define WZPD 0.375 //WZPD controls the focus distance for the screen Pop-out effect also known as Convergence for the weapon hand. Zero is off.

// RE Fix is used to fix the issue with Resident Evil's 2 Remake 1-Shot cutscenes.
#define RE_Fix 0 //Default 0 is Off. One is On. 

//Depth Buffer Offset is for non conforming ZBuffer needed in some games.
#define Offset 0.0 // From 0 to 1 : Depth Map Offset is for non conforming ZBuffer.

// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key useing keycode info
// The Key Code for Decimal Point is Number 110. Ex. for "." Cancel_Depth_Key 110
#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.

// Use Depth Tool to adjust the lower preprocessor definitions below.
// Horizontal & Vertical Depth Buffer Resize for non conforming BackBuffer.
// Ex. Resident Evil 7 Has this problem. So you want to adjust it too around float2(0.9575,0.9575).
#define Horizontal_and_Vertical float2(1.0, 1.0) // 1.0 is Default.

// Image Position Adjust is used to move the Z-Buffer around.
#define Image_Position_Adjust float2(0.0,0.0)

// Define Display aspect ratio for screen cursor. A 16:9 aspect ratio will equal (1.77:1)
#define DAR float2(1.76, 1.0)

//USER EDITABLE PREPROCESSOR FUNCTIONS END//

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

uniform int IPD <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 100;
	ui_label = "Interpupillary Distance";
	ui_tooltip = "Determines the distance between your eyes.\n" 
				 "Default is 64.";
	ui_category = "Eye Focus Adjustment";
> = 64;

//Divergence & Convergence//
uniform float Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = 50; ui_step = 0.5;
	ui_label = "·Divergence Slider·";
	ui_tooltip = "Divergence increases differences between the left and right retinal images and allows you to experience depth.\n" 
				 "The process of deriving binocular depth information is called stereopsis.\n"
				 "You can override this value.";
	ui_category = "Divergence & Convergence";
> = 37.5;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.250;
	ui_label = " Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect also known as Convergence.\n"
				"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
				"This is controled by Convergence Mode.\n"
				"Default is 0.03, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.03;

//Occlusion Masking//
uniform int View_Mode <
	ui_type = "combo";
	ui_items = "View Mode Normal\0View Mode Alpha\0";
	ui_label = " View Mode";
	ui_tooltip = "Change the way the shader warps the output to the screen.\n"
				 "Default is Normal";
	ui_category = "Occlusion Masking";
> = 0;

uniform bool Performance_Mode <
	ui_label = "Performance Mode";
	ui_tooltip = "Occlusion Quality Processing.\n"
				 "Default is True.";
	ui_category = "Occlusion Masking";
> = true;

//Depth Map//
uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DM0 Normal\0DM1 Reversed\0";
	ui_label = "·Depth Map Selection·";
	ui_tooltip = "Linearization for the zBuffer also known as Depth Map.\n"
			     "DM0 is Z-Normal and DM1 is Z-Reversed.\n";
	ui_category = "Depth Map";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.0; ui_step = 0.125;
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "This allows for you to adjust the DM precision.\n"
				 "Adjust this to keep it as low as possible.\n"
				 "Default is 7.5";
	ui_category = "Depth Map";
> = 7.5;

uniform bool Depth_Map_View <
	ui_label = " Depth Map View";
	ui_tooltip = "Display the Depth Map.";
	ui_category = "Depth Map";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = " Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Map";
> = false;

//Weapon Hand Adjust//
uniform int WP <
	ui_type = "combo";
	ui_items = "Weapon Profile Off\0Pick Profiles Bellow\0WP 0\0WP 1\0WP 2\0WP 3\0WP 4\0WP 5\0WP 6\0WP 7\0WP 8\0WP 9\0WP 10\0WP 11\0WP 12\0WP 13\0WP 14\0WP 15\0WP 16\0WP 17\0WP 18\0WP 19\0WP 20\0WP 21\0WP 22\0WP 23\0WP 24\0WP 25\0WP 26\0WP 27\0WP 28\0WP 29\0WP 30\0WP 31\0WP 32\0WP 33\0WP 34\0WP 35\0WP 36\0WP 37\0WP 38\0WP 39\0WP 40\0WP 41\0WP 42\0WP 43\0WP 44\0WP 45\0WP 46\0WP 47\0WP 48\0WP 49\0WP 50\0";
	ui_label = "·Weapon Profiles·";
	ui_tooltip = "Pick Weapon Profile for your game or make your own.";
	ui_category = "Weapon Hand Adjust";
> = 0;

uniform float Weapon_Depth_Adjust <
	ui_type = "drag";
	ui_min = -100.0; ui_max = 100.0; ui_step = 0.25;
	ui_label = " Weapon Depth Adjustment";
	ui_tooltip = "Pushes or Pulls the FPS Hand in or out of the screen if a weapon profile is selected.\n"
				 "This also used to fine tune the Weapon Hand if creating a weapon profile.\n" 
				 "Default is Zero.";
	ui_category = "Weapon Hand Adjust";
> = 0;

uniform bool Theater_Mode <
	ui_label = " Theater Mode";
	ui_tooltip = "Sets the VR Shader in to Theater mode.";
	ui_category = "Image Adjustment";
> = false;

uniform float FoV <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 0.5;
	ui_label = "Field of View";
	ui_tooltip = "Lets you adjust the FoV of the Image.\n" 
				 "Default is 0.0.";
	ui_category = "Image Adjustment";
> = 0;

uniform bool Barrel_Distortion<
	ui_label = "Barrel Distortion";
	ui_tooltip = "Use this to dissable or enable Barrel Distortion.\n"
				 "Default is True.";
	ui_category = "Image Adjustment";
> = true;

uniform float3 Polynomial_Colors_K1 <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
	ui_tooltip = "Adjust the Polynomial Distortion K1_Red, K1_Green, & K1_Blue.\n"
				 "Default is (R 0.22, G 0.22, B 0.22)";
	ui_category = "Image Adjustment";
> = float3(0.22, 0.22, 0.22);

uniform float3 Polynomial_Colors_K2 <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
	ui_tooltip = "Adjust the Polynomial Distortion K2_Red, K2_Green, & K2_Blue.\n"
				 "Default is (R 0.24, G 0.24, B 0.24)";
	ui_label = "Polynomial Color Distortion K2";
	ui_category = "Image Adjustment";
> = float3(0.24, 0.24, 0.24);

uniform float Vignette <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 1;
	ui_label = "Vignette";
	ui_tooltip = "Soft edge effect around the image.";
	ui_category = "Image Effects";
> = 0.15;
	
uniform float Sharpen_Power <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "Sharpen Power";
	ui_tooltip = "Adjust this on clear up the image the game, movie piture & ect.";
	ui_category = "Image Effects";
> = 0;

uniform float Saturation <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 1;
	ui_label = "Saturation";
	ui_tooltip = "Lets you saturate image, Basicly add more color.";
	ui_category = "Image Effects";
> = 0;
//Cursor Adjustments//
uniform int Cursor_Type <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 6;
	ui_label = "·Cursor Selection·";
	ui_tooltip = "Choose the cursor type you like to use.\n" 
				 "Default is Zero.";
	ui_category = "Cursor Adjustments";
> = 0;

uniform float3 Cursor_STT <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = " Cursor Adjustments";
	ui_tooltip = "This controlls the Size, Thickness, & Color.\n" 
				 "Defaults are ( X 0.125, Y 0.5, Z 1.0).";
	ui_category = "Cursor Adjustments";
> = float3(0.125,0.5,1.0);

uniform bool SCSC <
	ui_label = " Cursor Lock";
	ui_tooltip = "Screen Cursor to Screen Crosshair Lock.";
	ui_category = "Cursor Adjustments";
> = false;
uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; >;
/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

float fmod(float a, float b) 
{
	float c = frac(abs(a / b)) * abs(b);
	return a < 0 ? -c : c;
}

texture DepthBufferTex : DEPTH;

sampler DepthBuffer 
	{ 
		Texture = DepthBufferTex; 
	};

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};

sampler BackBufferBORDER
	{ 
		Texture = BackBufferTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
texture texDMN  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT*Depth_Map_Division; Format = RGBA16F; }; 

sampler SamplerDMN
	{
		Texture = texDMN;
	};
	
texture LeftTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT*Depth_Map_Division; Format = RGBA8; }; 

sampler SamplerLeft
	{
		Texture = LeftTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;	
	};
	
texture RightTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT*Depth_Map_Division; Format = RGBA8; }; 

sampler SamplerRight
	{
		Texture = RightTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;	
	};	
					
uniform float2 Mousecoords < source = "mousepoint"; > ;	
////////////////////////////////////////////////////////////////////////////////////Cross Cursor////////////////////////////////////////////////////////////////////////////////////	
float4 MouseCursor(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	
	float4 Out = tex2D(BackBuffer, texcoord),Color; 
	float CCA = 0.1,CCB = 0.0025, CCC = 0.025, CCD = 0.05;
	float2 MousecoordsXY = Mousecoords * pix, center = texcoord, Screen_Ratio = float2(DAR.x,DAR.y), Size_Thickness = float2(Cursor_STT.x,Cursor_STT.y + 0.00000001);
	
	if (SCSC)
	MousecoordsXY = float2(0.5,0.5);
	
	float dist_fromHorizontal = abs(center.x - MousecoordsXY.x) * Screen_Ratio.x, Size_H = Size_Thickness.x * CCA, THICC_H = Size_Thickness.y * CCB;
	float dist_fromVertical = abs(center.y - MousecoordsXY.y) * Screen_Ratio.y , Size_V = Size_Thickness.x * CCA, THICC_V = Size_Thickness.y * CCB;	
	
	//Cross Cursor
	float B = min(max(THICC_H - dist_fromHorizontal,0)/THICC_H,max(Size_H-dist_fromVertical,0));
	float A = min(max(THICC_V - dist_fromVertical,0)/THICC_V,max(Size_V-dist_fromHorizontal,0));
	float CC = A+B; //Cross Cursor
	
	//Ring Cursor
	float dist_fromCenter = distance(texcoord * Screen_Ratio , MousecoordsXY * Screen_Ratio ), Size_Ring = Size_Thickness.x * CCA, THICC_Ring = Size_Thickness.y * CCB;
	float dist_fromIdeal = abs(dist_fromCenter - Size_Ring);
	float RC = max(THICC_Ring - dist_fromIdeal,0) / THICC_Ring; //Ring Cursor
	
	//Solid Square Cursor
	float Solid_Square_Size = Size_Thickness.x * CCC;
	float SSC = min(max(Solid_Square_Size - dist_fromHorizontal,0)/Solid_Square_Size,max(Solid_Square_Size-dist_fromVertical,0)); //Solid Square Cursor
	
	float Cursor;
	
	if(Cursor_Type == 1)
		Cursor = CC;
	else if(Cursor_Type == 2)
		Cursor = RC;
	else if(Cursor_Type == 3)
		Cursor = SSC;
	else if(Cursor_Type == 4)
		Cursor = SSC + CC;
	else if(Cursor_Type == 5)
		Cursor = SSC + RC;
	else if(Cursor_Type == 6)
		Cursor = CC + RC;
	else if(Cursor_Type == 7)
		Cursor = CC + RC + SSC;
	
	
	if (Cursor_STT.z == 1 )
		Color.rgb = float3(1,1,1);
	else if (Cursor_STT.z >= 0.9 )
		Color.rgb = float3(0,0,1);
	else if (Cursor_STT.z >= 0.8 )
		Color.rgb = float3(0,1,0);
	else if (Cursor_STT.z >= 0.7 )
		Color.rgb = float3(1,0,0);	
	else if (Cursor_STT.z >= 0.6 )
		Color.rgb = float3(0,1,1);
	else if (Cursor_STT.z >= 0.5 )
		Color.rgb = float3(1,0,1);
	else if (Cursor_STT.z >= 0.4 )
		Color.rgb = float3(1,1,0);
	else if (Cursor_STT.z >= 0.3 )
		Color.rgb = float3(1,0.4,0.7);
	else if (Cursor_STT.z >= 0.2 )
		Color.rgb = float3(1,0.64,0);
	else if (Cursor_STT.z >= 0.1 )
		Color.rgb = float3(0.5,0,0.5);
		
	if(Cursor_Type == 0)
	Out = tex2D(BackBuffer, texcoord); 
	else	
	Out = Cursor  ? Color : Out;
	
	return Out;
}

/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLumN {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumN																
	{
		Texture = texLumN;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
float Lum(in float2 texcoord : TEXCOORD0)
	{
		float Luminance = tex2Dlod(SamplerLumN,float4(texcoord,0,0)).x; //Average Luminance Texture Sample 

		return saturate(Luminance);
	}
		
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////
float Depth(in float2 texcoord : TEXCOORD0)
{	
	float2 texXY = texcoord + Image_Position_Adjust * pix;		
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
	
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBuffer = tex2D(DepthBuffer, texcoord).x; //Depth Buffer
	
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1.0, Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
	
	float2 Offsets = float2(1 + Offset,1 - Offset), Z = float2( zBuffer, 1-zBuffer );
	
	if (Offset > 0)
	Z = min( 1, float2( Z.x*Offsets.x , Z.y /  Offsets.y  ));

	if (Depth_Map == 0)//DM0. Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = Far * Near / (Far + Z.y * (Near - Far));		
		
	return zBuffer;
}

float2 WeaponDepth(in float2 texcoord : TEXCOORD0)
{
	float2 texXY = texcoord + Image_Position_Adjust * pix;		
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
		
		if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBufferWH = tex2D(DepthBuffer, texcoord).x, CutOff = 0 , Adjust = 0, Tune = 0, Scale = 0;
	
	float4 WA_XYZW;//Weapon Profiles Starts Here
	if (WP == 1)                                   // WA_XYZW.x | WA_XYZW.y | WA_XYZW.z | WA_XYZW.w 
		WA_XYZW = float4(CutOff,Adjust,Tune,Scale);// X Cutoff  | Y Adjust  | Z Tuneing | W Scaling 		
	else if(WP == 2) //WP 0
		WA_XYZW = float4(0.425,0.025,0,-2);        //ES: Oblivion		
	else if(WP == 3) //WP 1
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 4) //WP 2
		WA_XYZW = float4(0.625,1.250,3.75,0);      //BorderLands 2*	
	else if(WP == 5) //WP 3
		WA_XYZW = float4(0,0,0,0);                 //Game	
	else if(WP == 6) //WP 4
		WA_XYZW = float4(0.253,1.0,1.25,3);        //Fallout 4*			
	else if(WP == 7) //WP 5
		WA_XYZW = float4(0.276,0.6875,20.0,1);     //Skyrim: SE*
	else if(WP == 8) //WP 6
		WA_XYZW = float4(0.338,0.8125,-14.500,0);  //DOOM 2016*	
	else if(WP == 9) //WP 7
		WA_XYZW = float4(0.255,0.5625,-0.750,2);   //CoD: Black Ops*
	else if(WP == 10)//WP 8
		WA_XYZW = float4(0.254,25.0,-0.5,2);       //CoD:AW*	
	else if(WP == 11)//WP 9
		WA_XYZW = float4(0.450,0.0375,-37.813,2);  //Bioshock Remastred*
	else if(WP == 12)//WP 10
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 13)//WP 11
		WA_XYZW = float4(0.450,0.175,-43.75,1);    //Metro Redux Games*	
	else if(WP == 14)//WP 12
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 15)//WP 13
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 16)//WP 14
		WA_XYZW = float4(1.0,27.5,6.25,-1);        //Rage64*		
	else if(WP == 17)//WP 15
		WA_XYZW = float4(0.375,2.5,-44.75,0);      //Quake DarkPlaces*	
	else if(WP == 18)//WP 16
		WA_XYZW = float4(0.7,0.4,-30.0,-1);        //Quake 2 XP & Return to Castle Wolfenstine*
	else if(WP == 19)//WP 17
		WA_XYZW = float4(0.750,1.5,-1.250,-1);     //Quake 4*
	else if(WP == 20)//WP 18
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 21)//WP 19
		WA_XYZW = float4(0.255,0.01,22.5,2);       //S.T.A.L.K.E.R: Games*
	else if(WP == 22)//WP 20
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 23)//WP 21
		WA_XYZW = float4(1.0,1.0,7.5,-3);          //Turok: DH 2017*
	else if(WP == 24)//WP 22
		WA_XYZW = float4(0.570,2.0,0.0,-3);        //Turok2: SoE 2017*
	else if(WP == 25)//WP 23
		WA_XYZW = float4(0,0,0,0);                 //Turok 3: Shadow of Oblivion
	else if(WP == 26)//WP 24
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 27)//WP 25
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 28)//WP 26
		WA_XYZW = float4(0.750,3.4375,0,-1);       //Prey - 2006*
	else if(WP == 29)//WP 27
		WA_XYZW = float4(0.2832,20.0,0,0);         //Prey 2017 High Settings and <*
	else if(WP == 30)//WP 28
		WA_XYZW = float4(0.2712,25.0,0.325,1);     //Prey 2017 Very High*
	else if(WP == 31)//WP 29
		WA_XYZW = float4(0,0,0,0);                 //Game
	else if(WP == 32)//WP 30
		WA_XYZW = float4(0.490,5.0,0.5625,-1);     //Wolfenstine
	else if(WP == 33)//WP 31
		WA_XYZW = float4(1.0,13.75,6.4,-1);        //Wolfenstine: The New Order / The Old Blood
	else if(WP == 34)//WP 32
		WA_XYZW = float4(0,0,0,0);                 //Wolfenstein II: The New Colossus / Cyberpilot
	else if(WP == 35)//WP 33
		WA_XYZW = float4(0.278,2.0,-12.0,0);       //Black Mesa*
	else if(WP == 36)//WP 34
		WA_XYZW = float4(0.420,0.1,0.0,-1);        //Blood 2*
	else if(WP == 37)//WP 35
		WA_XYZW = float4(0.500,0.0625,18.75,-1);   //Blood 2 Alt*
	else if(WP == 38)//WP 36
		WA_XYZW = float4(0.785,0.0875,43.75,-2);   //SOMA*
	else if(WP == 39)//WP 37
		WA_XYZW = float4(0.445,0.500,0,-1);        //Cryostasis*
	else if(WP == 40)//WP 38
		WA_XYZW = float4(0.286,7.5,5.5,0);         //Unreal Gold with v227*	
	else if(WP == 41)//WP 39
		WA_XYZW = float4(0.280,1.125,-16.25,0);    //Serious Sam Revolution / Serious Sam HD: The First Encounter / The Second Encounter / Serious Sam 3: BFE?*
	else if(WP == 42)//WP 40
		WA_XYZW = float4(0.280,1.0,16.25,1);       //Serious Sam 2*
	else if(WP == 43)//WP 41
		WA_XYZW = float4(0,0,0,0);                 //Serious Sam 4: Planet Badass
	else if(WP == 44)//WP 42
		WA_XYZW = float4(0.277,0.875,-11.875,0);   //TitanFall 2*
	else if(WP == 45)//WP 43
		WA_XYZW = float4(0.7,0.250,0,-2);          //Project Warlock*
	else if(WP == 46)//WP 44
		WA_XYZW = float4(0.625,0.275,-25.0,-1);    //Kingpin Life of Crime*
	else if(WP == 47)//WP 45
		WA_XYZW = float4(0,0,0,0);                 //EuroTruckSim2
	else if(WP == 48)//WP 46
		WA_XYZW = float4(0.458,0.3375,0,-1);       //F.E.A.R & F.E.A.R. 2: Project Origin*
	else if(WP == 49)//WP 47
		WA_XYZW = float4(0,0,0,0);                 //Game	
	else if(WP == 50)//WP 48
		WA_XYZW = float4(1.9375,0.5,40.0,-1);      //Immortal Redneck
	else if(WP == 51)//WP 49
		WA_XYZW = float4(0,0,0,0);                 //NecroVisioN
	else if(WP == 52)//WP 50
		WA_XYZW = float4(0.489,3.75,0,-1);         //NecroVisioN: Lost Company*
	//End Weapon Profiles//
	
	// Code Adjustment Values.
	// WA_XYZW.x | WA_XYZW.y | WA_XYZW.z | WA_XYZW.w 
	// X Cutoff  | Y Adjust  | Z Tuneing | W Scaling 	
	
	// Hear on out is the Weapon Hand Adjustment code.		
	float Set_Scale , P = WA_XYZW.y;
	
	if (WA_XYZW.w == -3)
	{
		WA_XYZW.x *= 21.0f;
		P = (P + 0.00000001) * 100;
		Set_Scale = 0.5f;
	}			
	if (WA_XYZW.w == -2)
	{
		P = (P + 0.00000001) * 100;
		Set_Scale = 0.5f;
	}
	else if (WA_XYZW.w == -1)
	{
		Set_Scale = 0.332;
		P = (P + 0.00000001) * 100;
	}
	else if (WA_XYZW.w == 0)
	{
		Set_Scale = 0.105;
		P = (P + 0.00000001) * 100;
	}
	else if (WA_XYZW.w == 1)
	{
		Set_Scale = 0.07265625;
		P = (P + 0.00000001) * 100;
	}
	else if (WA_XYZW.w == 2)
	{
		Set_Scale = 0.0155;
		P = (P + 0.00000001) * 2000;
	}	
	else if (WA_XYZW.w == 3)
	{
		Set_Scale = 0.01;
		P = (P + 0.00000001) * 100;
	}
	//FPS Hand Depth Maps require more precision at smaller scales to look right.		 		
	float Far = (P * Set_Scale) * (1+(WA_XYZW.z * 0.01f)), Near = P;
	
	float2 Z = float2( zBufferWH, 1-zBufferWH );
			
	if ( Depth_Map == 0 )
		zBufferWH /= Far - Z.x * (Near - Far);
	else if ( Depth_Map == 1 )
		zBufferWH /= Far - Z.y * (Near - Far);
	
	zBufferWH = saturate(zBufferWH);	
	//This code is used to adjust the already set Weapon Hand Profile.
	float WA = 1 + (Weapon_Depth_Adjust * 0.015);
	if (WP > 1)
	zBufferWH = (zBufferWH - 0) / (WA - 0);
	//Wish I didn't have to do this.	
	if (WZPD > 0)
	zBufferWH = lerp(zBufferWH,0.75f,0.25f);
	else
	zBufferWH = smoothstep(-0.2,0.8,zBufferWH);
	
	return float2(zBufferWH.x,WA_XYZW.x);	
}

float4 DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0) : SV_Target
{
		float4 DM = Depth(texcoord).xxxx;
		
		float R, G, B, A, WD = WeaponDepth(texcoord).x, CoP = WeaponDepth(texcoord).y, CutOFFCal = (CoP/Depth_Map_Adjust) * 0.5f; //Weapon Cutoff Calculation
		CutOFFCal = step(DM.x,CutOFFCal);
					
		if (WP == 0)
		{
			DM.x = DM.x;
		}
		else
		{
			DM.x = lerp(DM.x,WD,CutOFFCal);
			DM.y = lerp(0.0,WD,CutOFFCal);
		}
		
		R = DM.x; //Mix Depth
		G = DM.z < DM.y; //Weapon Mask
		B = DM.z; //Average Luminance
		A = DM.w; //Normal Depth
		
	return saturate(float4(R,G,B,A));
}

float AutoDepthRange( float d, float2 texcoord )
{
	float LumAdjust_ADR = smoothstep(-0.0175f,0.1f,Lum(texcoord));
    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
}
#if RE_Fix
float AutoZPDRange(float ZPD, float2 texcoord )
{
	float LumAdjust_AZDPR = smoothstep(-0.0175f,0.125,Lum(texcoord)); //Adjusted to only effect really intense differences.
    return saturate(LumAdjust_AZDPR * ZPD);
}
#endif
float WHConv(float D,float2 texcoord)
{
	float Z = WZPD, ZP = 0.125,ALC = abs(Lum(texcoord)) ,Convergence = 1 - Z / (D * 2);
	
	if (Z <= 0)
		ZP = 1;
		
	if (ALC <= 0.025f)
		ZP = 1;

	 Convergence /= 1-(-Z);
	 
   return lerp(Convergence,D,ZP);
}

float Conv(float D,float2 texcoord)
{
	float Z = ZPD, ZP = 0.4375f;
	#if RE_Fix	
		Z = AutoZPDRange(Z,texcoord);
	#endif	

			D = AutoDepthRange(D,texcoord);	

		float Convergence = 1 - Z / D;
			
		if (ZPD == 0)
			ZP = 1.0;
					
    return lerp(Convergence,D, ZP);
}

float zBuffer(in float2 texcoord : TEXCOORD0)
{	
	float4 DM = tex2Dlod(SamplerDMN,float4(texcoord,0,0));

	DM.z = lerp(Conv(DM.z,texcoord), WHConv(DM.x,texcoord), DM.y);
		
	if (WZPD <= 0)
	DM.z = Conv(DM.x,texcoord);
	
	float ALC = abs(Lum(texcoord));
	
	if (ALC <= 0.025f)
		DM = 0;
		
	if (Cancel_Depth)
		DM = 0.0625f;

	return DM.z;
}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
// Horizontal parallax offset & Hole filling effect
float2 Parallax( float Diverg, float2 Coordinates)
{
	float Cal_Steps = (Divergence * 0.5) + (Divergence * 0.04);
	
	if(!Performance_Mode)
	Cal_Steps = Divergence + (Divergence * 0.04);
	
	//ParallaxSteps
	float Steps = clamp(Cal_Steps,0,255);
	
	// Offset per step progress & Limit
	float LayerDepth = 1.0 / Steps;

	//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
	float MS = Diverg * pix.x, deltaCoordinates = MS * LayerDepth;
	float2 ParallaxCoord = Coordinates,DB_Offset = float2((Diverg * 0.075f) * pix.x, 0), DB_OffsetA = float2((Diverg * 0.03f) * pix.x, 0);
	float CurrentDepthMapValue = zBuffer(ParallaxCoord), CurrentLayerDepth = 0, DepthDifference;

	[loop] //Steep parallax mapping
    for ( int i = 0 ; i < Steps; i++ )
    {
		// Doing it this way should stop crashes in older version of reshade, I hope.
        if (CurrentDepthMapValue <= CurrentLayerDepth)
			break; // Once we hit the limit Stop Exit Loop.
        // Get depth of next layer
        CurrentLayerDepth += LayerDepth;
        // Shift coordinates horizontally in linear fasion
        ParallaxCoord.x -= deltaCoordinates;
        // Get depth value at current coordinates
        if(View_Mode == 1)
        	CurrentDepthMapValue = zBuffer( ParallaxCoord - DB_OffsetA);
        else
        	CurrentDepthMapValue = zBuffer( ParallaxCoord - DB_Offset);
    }

	// Parallax Occlusion Mapping
	float2 PrevParallaxCoord = float2(ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y);
	float afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth, beforeDepthValue;
	
	if(View_Mode == 1)
		beforeDepthValue = zBuffer(PrevParallaxCoord - DB_OffsetA) - CurrentLayerDepth + LayerDepth;
	else
		beforeDepthValue = zBuffer(PrevParallaxCoord - DB_Offset) - CurrentLayerDepth + LayerDepth;
		
	// Interpolate coordinates
	float weight = afterDepthValue / (afterDepthValue - beforeDepthValue);
	ParallaxCoord = PrevParallaxCoord * max(0,weight) + ParallaxCoord * min(1,1.0f - weight);

	// Apply gap masking
	DepthDifference = (afterDepthValue-beforeDepthValue) * MS;
	if(View_Mode == 1)
		ParallaxCoord.x = lerp(ParallaxCoord.x - DepthDifference,ParallaxCoord.x,0.5f);
	
	return ParallaxCoord;
};

#define Interpupillary_Distance IPD * pix.x
float4 saturation(float4 C)
{
  float greyscale = dot(C.rgb, float3(0.2125, 0.7154, 0.0721)); 
   return lerp(greyscale.xxxx, C, (Saturation + 1.0));
}

void LR_Out(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 Left : SV_Target0, out float4 Right : SV_Target1)
{
	//Field of View
	float fov = FoV-(FoV*0.2), F = -fov + 1,HA = (F - 1)*(BUFFER_WIDTH*0.5)*pix.x;
	//Field of View Application
	float2 Z_A = float2(1.0,1.0); //Theater Mode
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
		
	//Left & Right Parallax for Stereo Vision	
	Left = saturation(tex2Dlod(BackBufferBORDER, float4(Parallax(-Divergence, TCL),0,0))); //Stereoscopic 3D using Reprojection Left
	Right = saturation(tex2Dlod(BackBufferBORDER, float4(Parallax( Divergence, TCR),0,0)));//Stereoscopic 3D using Reprojection Right
}

float4 Circle(float4 C, float2 TC)
{		
		float2 C_A = float2(1.0f,1.1375f), midHV = (C_A-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
		
		float2 uv = float2(TC.x,TC.y);
		
		uv = float2((TC.x*C_A.x)-midHV.x,(TC.y*C_A.y)-midHV.y);
		
		float borderA = 2.5; // 0.01
		float borderB = Vignette*0.1; // 0.01
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

float4 VigneteL(float2 texcoord)
{
	float2 TC = -texcoord * texcoord*32 + texcoord*32;
	float4 Left = tex2D(SamplerLeft,texcoord);
		Left.rgb *= smoothstep(0,Vignette*27.0f,TC.x * TC.y);
return Left;
}

float4 VigneteR(float2 texcoord)
{
	float2 TC = -texcoord * texcoord*32 + texcoord*32;
	float4 Left = tex2D(SamplerRight,texcoord);
		Left.rgb *= smoothstep(0,Vignette*27.0f,TC.x * TC.y);
return Left;
}
	

float2 D(float2 p, float k1, float k2) //Polynomial Lens + Radial lens undistortion filtering Left & Right
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

return p;
}

float4 PS_calcLR(float2 texcoord)
{
	float2 TCL = float2(texcoord.x * 2,texcoord.y), TCR = float2(texcoord.x * 2 - 1,texcoord.y), uv_redL, uv_greenL, uv_blueL, uv_redR, uv_greenR, uv_blueR;
	float4 color, Left, Right, color_redL, color_greenL, color_blueL, color_redR, color_greenR, color_blueR;
	float K1_Red = Polynomial_Colors_K1.x, K1_Green = Polynomial_Colors_K1.y, K1_Blue = Polynomial_Colors_K1.z;
	float K2_Red = Polynomial_Colors_K2.x, K2_Green = Polynomial_Colors_K2.y, K2_Blue = Polynomial_Colors_K2.z;
	if(Barrel_Distortion)
	{
		uv_redL = D(TCL.xy,K1_Red,K2_Red);
		uv_greenL = D(TCL.xy,K1_Green,K2_Green);
		uv_blueL = D(TCL.xy,K1_Blue,K2_Blue);
		
		uv_redR = D(TCR.xy,K1_Red,K2_Red);
		uv_greenR = D(TCR.xy,K1_Green,K2_Green);
		uv_blueR = D(TCR.xy,K1_Blue,K2_Blue);
		
		color_redL = VigneteL(uv_redL).r;
		color_greenL = VigneteL(uv_greenL).g;
		color_blueL = VigneteL(uv_blueL).b;
		
		color_redR = VigneteR(uv_redR).r;
		color_greenR = VigneteR(uv_greenR).g;
		color_blueR = VigneteR(uv_blueR).b;
	
		Left = float4(color_redL.x, color_greenL.y, color_blueL.z, 1.0);
		Right = float4(color_redR.x, color_greenR.y, color_blueR.z, 1.0);
	}
	else
	{
		Left = VigneteL(TCL);
		Right = VigneteR(TCR);
	}

	if(!Depth_Map_View)
	{	

		color = texcoord.x < 0.5 ? Circle(Left,float2(texcoord.x*2,texcoord.y)) : Circle(Right,float2(texcoord.x*2-1,texcoord.y));
		if(!Barrel_Distortion)
		color = texcoord.x < 0.5 ? Left : Right;
	
	}
	else
	{		
		float3 RGB = zBuffer(texcoord);

		color = float4(RGB.x,RGB.y,RGB.z,1.0);
	}
		
	float Average_Lum = tex2Dlod(SamplerDMN,float4(texcoord.x,texcoord.y, 0, 0)).y;
	
	return float4(color.rgb,Average_Lum);
}

float4 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return float4(tex2Dlod(SamplerDMN,float4(texcoord.x,texcoord.y, 0, 0)).z,0,0,1); //Average_Lum_Full
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >; //Please do not remove.
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y;	
	float4 Color = float4(PS_calcLR(texcoord).rgb,1.0),D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
	if(timer <= 12500)
	{
		//DEPTH
		//D
		float PosXD = -0.035+PosX, offsetD = 0.001;
		float4 OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float4 TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
		D = OneD-TwoD;
		
		//E
		float PosXE = -0.028+PosX, offsetE = 0.0005;
		float4 OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
		float4 TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float4 ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
		E = (OneE-TwoE)+ThreeE;
		
		//P
		float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
		float4 OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.775));
		float4 TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.680));
		float4 ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		P = (OneP-TwoP) + ThreeP;

		//T
		float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
		float4 OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
		float4 TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
		T = OneT+TwoT;
		
		//H
		float PosXH = -0.0072+PosX;
		float4 OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
		float4 TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
		float4 ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.00325,0.009));
		H = (OneH-TwoH)+ThreeH;
		
		//Three
		float offsetFive = 0.001, PosX3 = -0.001+PosX;
		float4 OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
		float4 TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
		float4 ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
		Three = (OneThree-TwoThree)+ThreeThree;
		
		//DD
		float PosXDD = 0.006+PosX, offsetDD = 0.001;	
		float4 OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float4 TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DD = OneDD-TwoDD;
		
		//Dot
		float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;		
		float4 OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
		Dot = OneDot;
		
		//INFO
		//I
		float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
		float4 OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
		float4 TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
		float4 ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
		I = OneI+TwoI+ThreeI;
		
		//N
		float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
		float4 OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
		float4 TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
		N = OneN-TwoN;
		
		//F
		float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
		float4 OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
		float4 TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
		float4 ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
		F = (OneF-TwoF)+ThreeF;
		
		//O
		float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
		float4 OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
		float4 TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
		O = OneO-TwoO;
		//Website
		return D+E+P+T+H+Three+DD+Dot+I+N+F+O ? 1-texcoord.y*50.0+48.35f : Color;
	}
	else
	{
		return Color;
	}
}

float4 USM(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
	float SP = Sharpen_Power;	
		
	float2 tex_offset = pix; // Gets texel offset
	float4 result =  tex2D(BackBuffer, float2(texcoord));
	if(Sharpen_Power > 0)
	{				   
		   result += tex2D(BackBuffer, float2(texcoord + float2( 1, 0) * tex_offset));
		   result += tex2D(BackBuffer, float2(texcoord + float2(-1, 0) * tex_offset));
		   result += tex2D(BackBuffer, float2(texcoord + float2( 0, 1) * tex_offset));
		   result += tex2D(BackBuffer, float2(texcoord + float2( 0,-1) * tex_offset));
		   tex_offset *= 0.75;		   
		   result += tex2D(BackBuffer, float2(texcoord + float2( 1, 1) * tex_offset));
		   result += tex2D(BackBuffer, float2(texcoord + float2(-1,-1) * tex_offset));
		   result += tex2D(BackBuffer, float2(texcoord + float2( 1,-1) * tex_offset));
		   result += tex2D(BackBuffer, float2(texcoord + float2(-1, 1) * tex_offset));
   		result /= 9;
   		
		result = tex2D(BackBuffer, texcoord) + ( tex2D(BackBuffer, texcoord) - result ) * SP;
	}
	
	return result;
}
///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////
// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

//*Rendering passes*//
technique SuperDepth3D_Next
{
		pass Cursor
	{
		VertexShader = PostProcessVS;
		PixelShader = MouseCursor;
	}	
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texDMN;
	}
		pass LRtoBD
	{
		VertexShader = PostProcessVS;
		PixelShader = LR_Out;
		RenderTarget0 = LeftTex;
		RenderTarget1 = RightTex;	
	}
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLumN;
	}
		pass StereoOut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
			pass UnSharpMask_Filter
	{
		VertexShader = PostProcessVS;
		PixelShader = USM;
	}
	
}