////-------------------//
///**SuperDepth3D_VR**///
//-------------------////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* Depth Map Based 3D post-process shader v2.0.6          																														
//* For Reshade 3.0+																																								
//* --------------------------																																					
//* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																							
//* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																			
//* I would also love to hear about a project you are using it with.																											
//* https://creativecommons.org/licenses/by/3.0/us/																																
//*																																												
//* Jose Negrete AKA BlueSkyDefender																																				
//*																																												
//* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				
//* ---------------------------------																																			
//*																																												
//* Original work was based on the shader code from																																
//* CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology																				
//* Also Fu-Bama a shader dev at the reshade forums https://reshade.me/forum/shader-presentation/5104-vr-universal-shader															
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if exists "Overwatch.fxh"                                           //Overwatch Intercepter//	
	#include "Overwatch.fxh"
#else //DA_X ZPD | DA_Y Depth_Adjust | DA_Z Offset | DA_W Depth_Linearization | DB_X Depth_Flip | DB_Y Auto_Balance | DB_Z Auto_Depth | DB_W Weapon_Hand | DC_X HUDX | DC_Y Null_A | DC_Z Null_B | DC_W Null_C | DD_X HV_X | DD_Y HV_Y | DD_Z DepthPX | DD_W DepthPY
	static const float DA_X = 0.025, DA_Y = 7.5, DA_Z = 0.0, DA_W = 0.0, DB_X = 0, DB_Y = 0, DB_Z = 0.1, DB_W = 0.0, DC_X =0.0, DC_Y = 0, DC_Z = 0, DC_W = 0, DD_X = 1,DD_Y = 1, DD_Z = 0.0, DD_W = 0.0;
	#define RE 0
	#define NC 0
	#define TW 0
	#define NP 0	
#endif
//USER EDITABLE PREPROCESSOR FUNCTIONS START//
//This enables the older SuperDepth3D method of producing an 3D image. This is better for older systems that have an hard time running the new mode.
#define Legacy_Mode 0 //Zero is off and One is On.

//Weapon Zero Parallax Distance
#define WZPD 0.03 //WZPD controls the focus distance for the screen Pop-out effect also known as Convergence for the weapon hand. Zero is off.

// Zero Parallax Distance Balance Mode allows you to switch control from manual to automatic and vice versa.
#define Balance_Mode 0 //Default 0 is Automatic. One is Manual.

// RE Fix is used to fix the issue with Resident Evil's 2 Remake 1-Shot cutscenes.
#define RE_Fix 0 //Default 0 is Off. One is On. 

// Alternet Depth Buffer Adjust Toggle Key. The Key Code for "o" is Number 79.
#define DB_TOGGLE 0 // You can use http://keycode.info/ to figure out what key is what.
#define Alt_Depth_Map_Adjust 0 // You can set this from 1.0 to 250.

// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key useing keycode info
// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.

// Horizontal & Vertical Depth Buffer Resize for non conforming BackBuffer.
// Also used to enable Image Position Adjust is used to move the Z-Buffer around.
// Ex. Resident Evil 7 Has this problem. So you want to adjust it too around float2(0.9575,0.9575).
#define DB_Size_Postion 0 //Default 0 is Off. One is On. 

// Define Display aspect ratio for screen cursor. A 16:9 aspect ratio will equal (1.77:1)
#define DAR float2(1.76, 1.0)

// HUD Mode is for Extra UI MASK and Basic HUD Adjustments. This is usefull for UI elements that are drawn in the Depth Buffer.
// Such as the game Naruto Shippuden: Ultimate Ninja, TitanFall 2, and or Unreal Gold 277. That have this issue. This also allows for more advance users
// Too Make there Own UI MASK if need be.
// You need to turn this on to use UI Masking options Below.
#define HUD_MODE 0 // Set this to 1 if basic HUD items are drawn in the depth buffer to be adjustable.

// Turn UI Mask Off or On. This is used to set Two UI Masks for any game. Keep this in mind when you enable UI_MASK.
// You Will have to create Three PNG Textures named Mask_A.png and Mask_B.png with transparency for this option.
// They will also need to be the same resolution as what you have set for the game and the color black where the UI is.
#define UI_MASK 0 // Set this to 1 if you did the steps above.

// To cycle through the textures set a Key. The Key Code for "n" is Key Code Number 78.
#define Mask_Cycle_Key 0 // You can use http://keycode.info/ to figure out what key is what.
// Texture EX. Before |::::::::::| After |**********|
//                    |:::       |       |***       |
//                    |:::_______|       |***_______|
// So :::: are UI Elements in game. The *** is what the Mask needs to cover up.
// The game part needs to be trasparent and the UI part needs to be black.

// The Key Code for the mouse is 0-4 key 1 is right mouse button.
#define Fade_Key 1 // You can use http://keycode.info/ to figure out what key is what.
#define Fade_Time_Adjust 0.5625 // From 0 to 1 is the Fade Time adjust for this mode. Default is 0.5625;
#define Eye_Fade_Reduction 0 // From 0 to 2 Default is both eyes Depth reduction. One is Right Eye only Two is Left Eye Only
//USER EDITABLE PREPROCESSOR FUNCTIONS END//

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

#if DC_X > 0
	#define HM 1
#else
	#define HM 0
#endif

uniform int IPD <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 100;
	ui_label = "·Interpupillary Distance·";
	ui_tooltip = "Determines the distance between your eyes.\n" 
				 "Default is 64.";
	ui_category = "Eye Focus Adjustment";
> = 64;

//Divergence & Convergence//
uniform float Divergence <
	ui_type = "drag";
	ui_min = 5; ui_max = 50; ui_step = 0.5;
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
				"Default is 0.025, Zero is off.";
	ui_category = "Divergence & Convergence";
> = DA_X;

uniform float Auto_Depth_Range <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = " Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n" 
				 "Default is 0.1f, Zero is off.";
	ui_category = "Divergence & Convergence";
> = DB_Z;
#if Balance_Mode
uniform float ZPD_Balance <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " ZPD Balance";
	ui_tooltip = "Zero Parallax Distance balances between ZPD Depth and Scene Depth.\n"
				"Default is Zero is full Convergence and One is Full Depth.";
	ui_category = "Divergence & Convergence";
> = 0.5;

static const int Auto_Balance_Ex = 0;
#else
uniform int Auto_Balance_Ex <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 5;
	ui_label = " Auto Balance";
	ui_tooltip = "Automatically Balance between ZPD Depth and Scene Depth.\n" 
				 "Default is Off.";
	ui_category = "Divergence & Convergence";
> = DB_Y;
#endif
//Occlusion Masking//
uniform int View_Mode <
	ui_type = "combo";
	ui_items = "View Mode Normal\0View Mode Alpha\0";
	ui_label = "·View Mode·";
	ui_tooltip = "Change the way the shader warps the output to the screen.\n"
				 "Default is Normal";
	ui_category = "Occlusion Masking";
> = 0;
#if Legacy_Mode
uniform float2 Disocclusion_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Disocclusion Adjust";
	ui_tooltip = "Automatic occlusion masking power, & Depth Based culling adjustments.\n"
				"Default is ( 0.1f,0.25f)";
	ui_category = "Occlusion Masking";
> = float2( 0.1, 0.25);
#else
uniform bool Performance_Mode <
	ui_label = " Performance Mode";
	ui_tooltip = "Performance Mode Lowers Occlusion Quality Processing so that there is a small boost to FPS.\n"
				 "Please enable the 'Performance Mode Checkbox,' in ReShade's GUI.\n"
				 "It's located in the lower bottom right of the ReShade's Main UI.\n"
				 "Default is False.";
	ui_category = "Occlusion Masking";
> = false;
#endif
//Depth Map//
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
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "This allows for you to adjust the DM precision.\n"
				 "Adjust this to keep it as low as possible.\n"
				 "Default is 7.5";
	ui_category = "Depth Map";
> = DA_Y;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Depth Map Offset";
	ui_tooltip = "Depth Map Offset is for non conforming ZBuffer.\n"
				 "It,s rare if you need to use this in any game.\n"
				 "Use this to make adjustments to DM 0 or DM 1.\n"
				 "Default and starts at Zero and it's Off.";
	ui_category = "Depth Map";
> = DA_Z;

uniform float Menu_Detection <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 2.5; ui_step = 0.5;
	ui_label = " Menu Detection";
	ui_tooltip = "Use this to dissable/enable in game Menu Detection.";
	ui_category = "Depth Map";
> = 0.5;

uniform bool Depth_Map_View <
	ui_label = " Depth Map View";
	ui_tooltip = "Display the Depth Map.";
	ui_category = "Depth Map";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = " Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Map";
> = DB_X;
#if DB_Size_Postion 
uniform int2 Image_Position_Adjust<
	ui_type = "drag";
	ui_min = -4096.0; ui_max = 4096.0;
	ui_label = "Z Position Adjust";
	ui_tooltip = "Adjust the Image Postion if it's off by a bit. Default is Zero.";
	ui_category = "Depth Map";
> = int2(DD_Z,DD_W);
	
uniform float2 Horizontal_and_Vertical <
	ui_type = "drag";
	ui_min = 0.125; ui_max = 2;
	ui_label = "Z Horizontal & Vertical";
	ui_tooltip = "Adjust Horizontal and Vertical Resize. Default is 1.0.";
	ui_category = "Depth Map";
> = float2(DD_X,DD_Y);
#endif
//Weapon Hand Adjust//
uniform int WP <
	ui_type = "combo";
	ui_items = "Weapon Profile Off\0Custom WP\0WP 0\0WP 1\0WP 2\0WP 3\0WP 4\0WP 5\0WP 6\0WP 7\0WP 8\0WP 9\0WP 10\0WP 11\0WP 12\0WP 13\0WP 14\0WP 15\0WP 16\0WP 17\0WP 18\0WP 19\0WP 20\0WP 21\0WP 22\0WP 23\0WP 24\0WP 25\0WP 26\0WP 27\0WP 28\0WP 29\0WP 30\0WP 31\0WP 32\0WP 33\0WP 34\0WP 35\0WP 36\0WP 37\0WP 38\0WP 39\0WP 40\0WP 41\0WP 42\0WP 43\0WP 44\0WP 45\0WP 46\0WP 47\0WP 48\0WP 49\0WP 50\0WP 51\0WP 52\0WP 53\0WP 54\0WP 55\0WP 56\0WP 57\0WP 58\0WP 59\0WP 60\0";
	ui_label = "·Weapon Profiles·";
	ui_tooltip = "Pick Weapon Profile for your game or make your own.";
	ui_category = "Weapon Hand Adjust";
> = DB_W;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 250.0;
	ui_label = " Weapon Hand Adjust";
	ui_tooltip = "Adjust Weapon depth map for your games.\n"
				 "X, CutOff Point used to set a diffrent scale for first person hand apart from world scale.\n"
				 "Y, Precision is used to adjust the first person hand in world scale.\n"
	             "Default is float2(X 0.0, Y 0.0, Z 0.0)";
	ui_category = "Weapon Hand Adjust";
> = float3(0.0,0.0,0.0);

uniform int FPSDFIO <
	ui_type = "combo";
	ui_items = "Off\0Press\0Hold Down\0Press Adjust\0Hold Down Adjust\0";
	ui_label = " FPS Focus Depth";
	ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
				 "This may induce Eye Strain so take this as an Warning.";
	ui_category = "Weapon Hand Adjust";
> = 0;

uniform float FD_Adjust <
	ui_type = "drag";
	ui_min = 0.125; ui_max = 0.5;
	ui_label = " Focus Depth Adjust";
	ui_tooltip = "FPS Focus Depth Adjustment. Default is 0.25f.";
	ui_category = "Weapon Hand Adjust";
> = 0.25;
#if HUD_MODE || HM
//Heads-Up Display
uniform float2 HUD_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "·HUD Mode·";
	ui_tooltip = "Adjust HUD for your games.\n"
				 "X, CutOff Point used to set a seperation point bettwen world scale and the HUD also used to turn HUD MODE On or Off.\n"
				 "Y, Pushes or Pulls the HUD in or out of the screen if HUD MODE is on.\n"
				 "This is only for UI elements that show up in the Depth Buffer.\n"
	             "Default is float2(X 0.0, Y 0.5)";
	ui_category = "Heads-Up Display";
> = float2(DC_X,0.5);
#endif

uniform int Barrel_Distortion <
	ui_type = "combo";
	ui_items = "Off\0Blinders A\0Blinders B\0";
	ui_label = "·Barrel Distortion·";
	ui_tooltip = "Use this to dissable or enable Barrel Distortion A & B.\n"
				 "This also lets you select from two diffrent Blinders.\n"
			     "Default is Blinders A.\n";
	ui_category = "Image Adjustment";
> = 0;

uniform float FoV <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 0.5;
	ui_label = " Field of View";
	ui_tooltip = "Lets you adjust the FoV of the Image.\n" 
				 "Default is 0.0.";
	ui_category = "Image Adjustment";
> = 0;

uniform float3 Polynomial_Colors_K1 <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Polynomial Distortion K1";
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
	ui_label = " Polynomial Distortion K2";
	ui_tooltip = "Adjust the Polynomial Distortion K2_Red, K2_Green, & K2_Blue.\n"
				 "Default is (R 0.24, G 0.24, B 0.24)";
	ui_category = "Image Adjustment";
> = float3(0.24, 0.24, 0.24);

uniform bool Theater_Mode <
	ui_label = " Theater Mode";
	ui_tooltip = "Sets the VR Shader in to Theater mode.";
	ui_category = "Image Adjustment";
> = false;

uniform float Vignette <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 1;
	ui_label = "·Vignette·";
	ui_tooltip = "Soft edge effect around the image.";
	ui_category = "Image Effects";
> = 0.25;
	
uniform float Sharpen_Power <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 2.0;
	ui_label = " Sharpen Power";
	ui_tooltip = "Adjust this on clear up the image the game, movie piture & ect.\n"
				 "This has basic contrast awareness and it will try too\n"
				 "not shapren High Contrast areas in image.";
	ui_category = "Image Effects";
> = 0;

uniform float Saturation <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 1;
	ui_label = " Saturation";
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
	ui_min = 0; ui_max = 7;
	ui_label = "·Cursor Selection·";
	ui_tooltip = "Choose the cursor type you like to use.\n" 
		    	 "Default is Zero off.";
	ui_category = "Cursor Adjustments";
> = 0;

uniform float3 Cursor_STT <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = " Cursor Adjustments";
	ui_tooltip = "This controlls the Size, Thickness, & Color.\n" 
		  	   "Defaults are ( X 0.125, Y 0.5, Z 0.0).";
	ui_category = "Cursor Adjustments";
> = float3(0.125,0.5,0.0);

uniform bool SCSC <
	ui_label = " Cursor Lock";
	ui_tooltip = "Screen Cursor to Screen Crosshair Lock.";
	ui_category = "Cursor Adjustments";
> = false;

uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; mode = "toggle";>;
uniform bool Mask_Cycle < source = "key"; keycode = Mask_Cycle_Key; toggle = true; >;
uniform bool Depth_Adjust < source = "key"; keycode = DB_TOGGLE; toggle = true; >;
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
	
texture texDMVR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; }; 

sampler SamplerDMVR
	{
		Texture = texDMVR;
	};
#if Legacy_Mode
texture texzBufferVR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R16F; }; 

sampler SamplerzBufferVR
	{
		Texture = texzBufferVR;
	};
#endif	
texture LeftTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; }; 

sampler SamplerLeft
	{
		Texture = LeftTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;	
	};
	
texture RightTex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; }; 

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
	float B = min(max(THICC_H - dist_fromHorizontal,0)/THICC_H,max(Size_H-dist_fromVertical,0)), A = min(max(THICC_V - dist_fromVertical,0)/THICC_V,max(Size_V-dist_fromHorizontal,0));
	float CC = A+B; //Cross Cursor
	
	//Ring Cursor
	float dist_fromCenter = distance(texcoord * Screen_Ratio , MousecoordsXY * Screen_Ratio ), Size_Ring = Size_Thickness.x * CCA, THICC_Ring = Size_Thickness.y * CCB;
	float dist_fromIdeal = abs(dist_fromCenter - Size_Ring);
	float RC = max(THICC_Ring - dist_fromIdeal,0) / THICC_Ring; //Ring Cursor
	
	//Solid Square Cursor
	float Solid_Square_Size = Size_Thickness.x * CCC;
	float SSC = min(max(Solid_Square_Size - dist_fromHorizontal,0)/Solid_Square_Size,max(Solid_Square_Size-dist_fromVertical,0)); //Solid Square Cursor
	// Cursor Array //
	float Cursor, CArray[7] = {
		CC,			 //Cross Cursor
		RC, 	     //Ring Cursor		
		SSC,         //Solid Square Cursor
		SSC + CC,    //Solid Square Cursor / Cross Cursor
		SSC + RC,    //Solid Square Cursor / Ring Cursor		
		CC + RC,     //Cross Cursor / Ring Cursor
		CC + RC + SSC//Cross Cursor / Ring Cursor / Solid Square Cursor
	};
	Cursor =  CArray[clamp(Cursor_Type - 1,0,6)];
	// Cursor Color Array //
	float3 CCArray[10] = {
		float3(1,1,1),
		float3(0,0,1),	
		float3(0,1,0),
		float3(1,0,0),	
		float3(0,1,1),
		float3(1,0,1),
		float3(1,1,0),
		float3(1,0.4,0.7),
		float3(1,0.64,0),
		float3(0.5,0,0.5)
	};
	int CSTT = min(int(saturate(Cursor_STT.z) * 10),9);
	Color.rgb = CCArray[CSTT];
	if(Cursor_Type > 0)
	Out = Cursor ? Color : Out;
	
	return Out;
}
/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLumVR {Width = 256*0.5; Height = 256*0.5; Format = RGBA16F; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumVR																
	{
		Texture = texLumVR;
	};	
	
float2 Lum(in float2 texcoord : TEXCOORD0)
	{   //Luminance
		return saturate(tex2Dlod(SamplerLumVR,float4(texcoord,0,11)).xy); //Average Luminance Texture Sample 
	}
	
uniform float frametime < source = "frametime";>;
/////////////////////////////////////////////////////////////////////////////////Fade In and Out Toggle/////////////////////////////////////////////////////////////////////////////////	
uniform bool Trigger_Fade_A < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
uniform bool Trigger_Fade_B < source = "mousebutton"; keycode = Fade_Key;>;

float Fade_in_out(float2 texcoord : TEXCOORD)	
{
	float Trigger_Fade, AA = (1-Fade_Time_Adjust)*1000, PStoredfade = tex2D(SamplerLumVR,texcoord).z;
	//Fade in toggle. 
	if(FPSDFIO == 1 || FPSDFIO == 3)
		Trigger_Fade = Trigger_Fade_A;
	else if(FPSDFIO == 2 || FPSDFIO == 4)
		Trigger_Fade = Trigger_Fade_B;
	
	return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/AA)); ///exp2 would be even slower  	
}	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////
float Depth(in float2 texcoord : TEXCOORD0)
{	
	#if DB_Size_Postion
	float2 texXY = texcoord + Image_Position_Adjust * pix;		
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
	#endif
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
	//Conversions to linear space.....
	float zBuffer = tex2D(DepthBuffer, texcoord).x, Far = 1., Near = 0.125/Depth_Map_Adjust; //Near & Far Adjustment
	
	float2 Offsets = float2(1 + Offset,1 - Offset), Z = float2( zBuffer, 1-zBuffer );
	
	if (Offset > 0)
	Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));

	if (Depth_Map == 0)//DM0. Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = Far * Near / (Far + Z.y * (Near - Far));
	return zBuffer;
}

float2 WeaponDepth(float2 texcoord)
{
	#if DB_Size_Postion
	float2 texXY = texcoord + Image_Position_Adjust * pix;		
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
	#endif
	//Weapon Setting//
	float3 WA_XYZ = float3(Weapon_Adjust.x,Weapon_Adjust.y,Weapon_Adjust.z);
	if(WP == 2)                // X Cutoff | Y Adjust | Z Tuneing //
		WA_XYZ = float3(0.425,5.0,1.125); 	 //WP 0  | ES: Oblivion #C753DADB
	else if(WP == 3)	
		WA_XYZ = float3(0,0,0);                //WP 1  | Game
	else if(WP == 4)
		WA_XYZ = float3(0.625,37.5,7.25);      //WP 2  | BorderLands 2 #7B81CCAB
	else if(WP == 5)	
		WA_XYZ = float3(0,0,0);                //WP 3  | Game
	else if(WP == 6)
		WA_XYZ = float3(0.253,28.75,98.5);     //WP 4  | Fallout 4 #2D950D30
	else if(WP == 7)	
		WA_XYZ = float3(0.276,20.0,9.5625);    //WP 5  | Skyrim: SE #3950D04E
	else if(WP == 8)
		WA_XYZ = float3(0.338,20.0,9.25);      //WP 6  | DOOM 2016 #142EDFD6
	else if(WP == 9)	
		WA_XYZ = float3(0.255,177.5,63.025);   //WP 7  | CoD:Black Ops #17232880 CoD:MW2 #9D77A7C4 CoD:MW3 #22EF526F
	else if(WP == 10)
		WA_XYZ = float3(0.254,100.0,0.9843);   //WP 8  | CoD:Black Ops II #D691718C
	else if(WP == 11)	
		WA_XYZ = float3(0.254,203.125,0.98435);//WP 9  | CoD:Ghost #7448721B
	else if(WP == 12)
		WA_XYZ = float3(0.254,203.125,0.98433);//WP 10 | CoD:AW #23AB8876 CoD:MW Re #BF4D4A41
	else if(WP == 13)
		WA_XYZ = float3(0.254,125.0,0.9843);   //WP 11 | CoD:IW #1544075
	else if(WP == 14)
		WA_XYZ = float3(0.255,200.0,63.0);     //WP 12 | CoD:WaW #697CDA52
	else if(WP == 15)
		WA_XYZ = float3(0.510,162.5,3.975);    //WP 13 | CoD #4383C12A CoD:UO #239E5522 CoD:2 #3591DE9C
	else if(WP == 16)
		WA_XYZ = float3(0.254,23.75,0.98425);  //WP 14 | CoD: Black Ops IIII #73FA91DC
	else if(WP == 17)
		WA_XYZ = float3(0.375,60.0,15.15625);  //WP 15 | Quake DarkPlaces #37BD797D
	else if(WP == 18)
		WA_XYZ = float3(0.7,14.375,2.5);       //WP 16 | Quake 2 XP #34F4B6C
	else if(WP == 19)
		WA_XYZ = float3(0.750,30.0,1.050);     //WP 17 | Quake 4 #ED7B83DE
	else if(WP == 20)
		WA_XYZ = float3(0,0,0);                //WP 18 | Game
	else if(WP == 21)
		WA_XYZ = float3(0.450,12.0,23.75);     //WP 19 | Metro Redux Games #886386A
	else if(WP == 22)
		WA_XYZ = float3(0,0,0);                //WP 20 | Game
	else if(WP == 23)
		WA_XYZ = float3(0,0,0);                //WP 21 | Game
	else if(WP == 24)
		WA_XYZ = float3(0,0,0);                //WP 22 | Game
	else if(WP == 25)
		WA_XYZ = float3(0,0,0);                //WP 23 | Game
	else if(WP == 26)
		WA_XYZ = float3(0.255,6.375,53.75);    //WP 24 | S.T.A.L.K.E.R: Games #F5C7AA92 #493B5C71
	else if(WP == 27)
		 WA_XYZ = float3(0,0,0);                //WP 25 | Game
	else if(WP == 28)
		WA_XYZ = float3(0.750,30.0,1.025);     //WP 26 | Prey 2006 #DE2F0F4D
	else if(WP == 29)
		WA_XYZ = float3(0.2832,13.125,0.8725); //WP 27 | Prey 2017 High Settings and < #36976F6D
	else if(WP == 30)
		WA_XYZ = float3(0.2832,13.75,0.915625);//WP 28 | Prey 2017 Very High #36976F6D
	else if(WP == 31)
		WA_XYZ = float3(0.7,9.0,2.3625);       //WP 29 | Return to Castle Wolfenstine #BF757E3A
	else if(WP == 32)
		WA_XYZ = float3(0.4894,62.50,0.98875); //WP 30 | Wolfenstein #30030941
	else if(WP == 33)
		WA_XYZ = float3(1.0,93.75,0.81875);    //WP 31 | Wolfenstein: The New Order #C770832 / The Old Blood #3E42619F
	else if(WP == 34)
		WA_XYZ = float3(0,0,0);                //WP 32 | Wolfenstein II: The New Colossus / Cyberpilot
	else if(WP == 35)
		WA_XYZ = float3(0.278,37.50,9.1);      //WP 33 | Black Mesa #6FC1FF71
	else if(WP == 36)
		WA_XYZ = float3(0.420,4.75,1.0);       //WP 34 | Blood 2 #6D3CD99E
	else if(WP == 37)	
		WA_XYZ = float3(0.500,4.75,0.75);      //WP 35 | Blood 2 Alt #6D3CD99E
	else if(WP == 38)
		WA_XYZ = float3(0.785,21.25,0.3875);   //WP 36 | SOMA #F22A9C7D
	else if(WP == 39)
		WA_XYZ = float3(0.444,20.0,1.1875);    //WP 37 | Cryostasis #6FB6410B
	else if(WP == 40)
		WA_XYZ = float3(0.286,80.0,7.0);       //WP 38 | Unreal Gold with v227 #16B8D61A
	else if(WP == 41)
		WA_XYZ = float3(0.280,15.5,9.1);       //WP 39 | Serious Sam Revolution #EB9EEB74/Serious Sam HD: The First Encounter /The Second Encounter /Serious Sam 2 #8238E9CA/ Serious Sam 3: BFE* 
	else if(WP == 42)
		WA_XYZ = float3(0,0,0);                //WP 40 | Serious Sam 4: Planet Badass
	else if(WP == 43)
		WA_XYZ = float3(0,0,0);                //WP 41 | Game
	else if(WP == 44)
		WA_XYZ = float3(0.277,20.0,8.8);       //WP 42 | TitanFall 2 #308AEBEA
	else if(WP == 45)
		WA_XYZ = float3(0.7,16.250,0.300);     //WP 43 | Project Warlock #5FCFB1E5
	else if(WP == 46)
		WA_XYZ = float3(0.625,9.0,2.375);      //WP 44 | Kingpin Life of Crime #7DCCBBBD
	else if(WP == 47)
		WA_XYZ = float3(0.28,20.0,9.0);        //WP 45 | EuroTruckSim2 #9C5C946E
	else if(WP == 48)
		WA_XYZ = float3(0.458,10.5,1.105);     //WP 46 | F.E.A.R #B302EC7 & F.E.A.R 2: Project Origin #91D9EBAF
	else if(WP == 49)
		WA_XYZ = float3(0,0,0);                //WP 47 | Game
	else if(WP == 50)
		WA_XYZ = float3(2.0,16.25,0.09);       //WP 48 | Immortal Redneck CP alt 1.9375 #2C742D7C
	else if(WP == 51)
		WA_XYZ = float3(0,0,0);                //WP 49 | Game
	else if(WP == 52)
		WA_XYZ = float3(0.489,68.75,1.02);     //WP 50 | NecroVisioN & NecroVisioN: Lost Company #663E66FE 
	else if(WP == 53)
		WA_XYZ = float3(1.0,237.5,0.83625);    //WP 51 | Rage64 #AA6B948E
	else if(WP == 54)
		WA_XYZ = float3(0,0,0);                //WP 52 | Rage 2
	else if(WP == 55)
		WA_XYZ = float3(0.425,15.0,99.0);      //WP 53 | Bioshock Remastred #44BD41E1
	else if(WP == 56)
		WA_XYZ = float3(0.425,21.25,99.5);     //WP 54 | Bioshock 2 Remastred #7CF5A01
	else if(WP == 57)
		WA_XYZ = float3(0.425,5.25,1.0);       //WP 55 | No One Lives Forever
	else if(WP == 58)
		WA_XYZ = float3(0.519,31.25,8.875);    //WP 56 | No One Lives Forever 2
	else if(WP == 59)
		WA_XYZ = float3(0,0,0);                //WP 57 | Game
	else if(WP == 60)
		WA_XYZ = float3(0,0,0);                //WP 58 | Game
	else if(WP == 61)
		WA_XYZ = float3(0,0,0);                //WP 59 | Game
	else if(WP == 62)
		WA_XYZ = float3(0,0,0);                //WP 60 | Game
	//Weapon Profiles Ends Here//

	// Here on out is the Weapon Hand Adjustment code.	
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
	//Conversions to linear space.....
	float zBufferWH = tex2D(DepthBuffer, texcoord).x, Far = 1.0, Near = 0.125/WA_XYZ.y;  //Near & Far Adjustment
	float2 Offsets = float2(1 + WA_XYZ.z,1 - WA_XYZ.z), Z = float2( zBufferWH, 1-zBufferWH );
	
	if (WA_XYZ.z > 0)
	Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));

	[branch] if (Depth_Map == 0)//DM0. Normal
		zBufferWH = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBufferWH = Far * Near / (Far + Z.y * (Near - Far));	
	return float2(saturate(zBufferWH), WA_XYZ.x);
}

float3 DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0) : SV_Target
{
		float4 DM = Depth(texcoord).xxxx;
				
		float R, G, B, A, WD = WeaponDepth(texcoord).x, CoP = WeaponDepth(texcoord).y, CutOFFCal = (CoP/Depth_Map_Adjust) * 0.5; //Weapon Cutoff Calculation
		CutOFFCal = step(DM.x,CutOFFCal);
					
		[branch] if (WP == 0)
		{
			DM.x = DM.x;
		}
		else
		{	
			DM.x = lerp(DM.x,WD,CutOFFCal);
			DM.y = lerp(0.0,WD,CutOFFCal);
			DM.z = lerp(0.5,WD,CutOFFCal);
		}
		
		R = DM.x; //Mix Depth
		G = DM.y > smoothstep(0,2.5,DM.w); //Weapon Mask
		B = DM.z; //Weapon Hand
		//A = DM.w; //Normal Depth
		
	if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
		R = Fade_in_out(texcoord);
	//DX9 issues with passing information in alpha.	
	return saturate(float3(R,G,B));
}
#if HUD_MODE || HM
float3 HUD(float3 HUD, float2 texcoord ) 
{		
	float Mask_Tex, CutOFFCal = ((HUD_Adjust.x * 0.5)/Depth_Map_Adjust) * 0.5, COC = step(Depth(texcoord).x,CutOFFCal); //HUD Cutoff Calculation
	
	//This code is for hud segregation.			
	if (HUD_Adjust.x > 0)
		HUD = COC > 0 ? tex2D(BackBuffer,texcoord).rgb : HUD;	
		
#if UI_MASK	
    [branch] if (Mask_Cycle == true) 
        Mask_Tex = tex2D(SamplerMaskB,texcoord.xy).a;
    else
        Mask_Tex = tex2D(SamplerMaskA,texcoord.xy).a;

	float MAC = step(1.0-Mask_Tex,0.5); //Mask Adjustment Calculation
	//This code is for hud segregation.			
	HUD = MAC > 0 ? tex2D(BackBuffer,texcoord).rgb : HUD;
#endif		
	return HUD;	
}
#endif
float AutoDepthRange( float d, float2 texcoord )
{
	float LumAdjust_ADR = smoothstep(-0.0175,Auto_Depth_Range,Lum(texcoord).x);
    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
}
#if RE_Fix || RE
float AutoZPDRange(float ZPD, float2 texcoord )
{   //Adjusted to only effect really intense differences.
	float LumAdjust_AZDPR = smoothstep(-0.0175,0.1875,Lum(texcoord).y);
    if(RE_Fix == 2 || RE == 2)
		LumAdjust_AZDPR = smoothstep(0,0.075,Lum(texcoord).y);
    return saturate(LumAdjust_AZDPR * ZPD);
}
#endif
float2 Conv(float D,float2 texcoord)
{
	float Z = ZPD, WZP = 0.5, ZP = 0.5, ALC = abs(Lum(texcoord).x), WConvergence = 1 - WZPD / D;
	#if RE_Fix || RE
		Z = AutoZPDRange(Z,texcoord);
	#endif	
		if (Auto_Depth_Range > 0)
			D = AutoDepthRange(D,texcoord);
			
	#if Balance_Mode
			ZP = saturate(ZPD_Balance);			
	#else
		if(Auto_Balance_Ex > 0 )
			ZP = saturate(ALC);
	#endif			
		float Convergence = 1 - Z / D;
			
		if (ZPD == 0)
			ZP = 1;

		if (WZPD <= 0)
			WZP = 1;
		
		if (ALC <= 0.025)
			WZP = 1;		
			
    return float2(lerp(Convergence,D, ZP),lerp(WConvergence,D,WZP));
}
#define BlurSamples 6  //BlurSamples = # * 2
#if Legacy_Mode 
float zBuffer(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0) : SV_Target
{
#else
float zBuffer(float2 texcoord)
{
#endif
	float3 DM = tex2Dlod(SamplerDMVR,float4(texcoord,0,0)).xyz;	
	#if Legacy_Mode 
	    float total = BlurSamples, S = 5 * Disocclusion_Adjust.x;
	    float3 D = DM * BlurSamples;
	    for ( int j = -BlurSamples; j <= BlurSamples; ++j)
	    {
	        float W = BlurSamples;      
			D += tex2Dlod(SamplerDMVR,float4(texcoord + float2(pix.x * S,0) * j,0,0 ) ).xyz * W;
	        total += W;
	    }
	    
		DM = lerp(saturate(D / total),DM,step(Disocclusion_Adjust.y,DM));
	#endif
	
	if (WP == 0)
		DM.y = 0;

	DM.y = lerp(Conv(DM.x,texcoord).x, Conv(DM.z,texcoord).y, DM.y);	
			
	if (WZPD <= 0)
		DM.y = Conv(DM.x,texcoord).x;

	
	float ALC = abs(Lum(texcoord).x);
	
	if (Menu_Detection >= 1)
	{
		if (ALC <= (0.025 / Menu_Detection))
		DM = 0;
	}
		
	if (Cancel_Depth)
		DM = 0.0625;

	return DM.y;
}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
// Horizontal parallax offset & Hole filling effect
float2 Parallax( float Diverge, float2 Coordinates)
{   float2 ParallaxCoord = Coordinates;
	float DepthLR = 1, LRDepth, Perf = 1.0, MS = Diverge * pix.x, MSM, N = 5, S[5] = {0.5,0.625,0.75,0.875,1.0};
	#if Legacy_Mode	
	MS = -MS;
	[loop]
	for ( int i = 0 ; i < N; i++ ) 
	{	MSM = MS + 0.001;
				
		DepthLR = min(DepthLR, tex2Dlod(SamplerzBufferVR,float4(ParallaxCoord.x + S[i] * MS, ParallaxCoord.y,0,0)).x );
		if(View_Mode == 0)
		{					
			LRDepth = min(DepthLR,tex2Dlod(SamplerzBufferVR,float4(ParallaxCoord.x + S[i] * (MSM * 0.25), ParallaxCoord.y,0,0)).x );			

			DepthLR = lerp(LRDepth , DepthLR, 0.1875);
		}
		if(View_Mode == 1)
		{		
			LRDepth =  min(DepthLR,tex2Dlod(SamplerzBufferVR,float4(ParallaxCoord.x + S[i] * MSM, ParallaxCoord.y,0,0)).x );						
			LRDepth += min(DepthLR,tex2Dlod(SamplerzBufferVR,float4(ParallaxCoord.x + S[i] * (MSM * 0.25), ParallaxCoord.y,0,0)).x );			
			LRDepth += min(DepthLR,tex2Dlod(SamplerzBufferVR,float4(ParallaxCoord.x + S[i] * (MSM * 0.5), ParallaxCoord.y,0,0)).x );	
			DepthLR = lerp(LRDepth * rcp(3), DepthLR, 0.1875);
		}		
	}
	//Reprojection Left and Right
	ParallaxCoord = float2(Coordinates.x + (MS * DepthLR), Coordinates.y);
	#else
	if (Performance_Mode)
		Perf = 0.5;
	//ParallaxSteps Calculations
	float D = abs(length(Diverge)), Cal_Steps = (D * Perf) + (D * 0.04), Steps = clamp(Cal_Steps,0,255);
		
	// Offset per step progress & Limit
	float LayerDepth = rcp(Steps);

	//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
	float deltaCoordinates = MS * LayerDepth;
	float2 DB_Offset = float2((Diverge * 0.0625f) * pix.x, 0);
	float CurrentDepthMapValue = zBuffer(ParallaxCoord), CurrentLayerDepth = 0, DepthDifference;

	[loop] //Steep parallax mapping
    for ( int i = 0 ; i < Cal_Steps; i++ )
    {
		// Doing it this way should stop crashes in older version of reshade, I hope.
        if (CurrentDepthMapValue <= CurrentLayerDepth)
			break; // Once we hit the limit Stop Exit Loop.
        // Shift coordinates horizontally in linear fasion
        ParallaxCoord.x -= deltaCoordinates;
        // Get depth value at current coordinates
        if(View_Mode == 1)
        	CurrentDepthMapValue = zBuffer( ParallaxCoord );
        else
        	CurrentDepthMapValue = zBuffer( ParallaxCoord - DB_Offset);
        // Get depth of next layer
        CurrentLayerDepth += LayerDepth;
    }
   	
	// Parallax Occlusion Mapping
	float2 PrevParallaxCoord = float2(ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y);
	float afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
	float beforeDepthValue = zBuffer( ParallaxCoord ) - CurrentLayerDepth + LayerDepth;
		
	// Interpolate coordinates
	float weight = afterDepthValue / (afterDepthValue - beforeDepthValue);
	ParallaxCoord = PrevParallaxCoord * max(0,weight) + ParallaxCoord * min(1,1.0f - weight);

	// Apply gap masking
	DepthDifference = (afterDepthValue-beforeDepthValue) * MS;
	if(View_Mode == 1)
		ParallaxCoord.x = lerp(ParallaxCoord.x - DepthDifference,ParallaxCoord.x,0.5f);
	#endif
	return ParallaxCoord;
}

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
	
	float D = Divergence;
	float FadeIO = smoothstep(0,1,1-Fade_in_out(texcoord).x), FD = D;
	
	if (FPSDFIO == 1 || FPSDFIO == 2)
		FD = lerp(FD * 0.0625,FD,FadeIO);	
	else if (FPSDFIO == 3 || FPSDFIO == 4)
		FD = lerp(FD * FD_Adjust,FD,FadeIO);
		
	float2 DLR = float2(FD,FD);
	
	if( Eye_Fade_Reduction == 1)
			DLR = float2(D,FD);
	else if( Eye_Fade_Reduction == 2)
			DLR = float2(FD,D);
				
	//Left & Right Parallax for Stereo Vision	
	Left = saturation(tex2Dlod(BackBufferBORDER, float4(Parallax(-DLR.x, TCL),0,0))); //Stereoscopic 3D using Reprojection Left
	Right = saturation(tex2Dlod(BackBufferBORDER, float4(Parallax( DLR.y, TCR),0,0)));//Stereoscopic 3D using Reprojection Right
	
	#if HUD_MODE || HM	
	float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25.) * pix.x;
	Left.rgb = HUD(Left,float2(TCL.x - HUD_Adjustment,TCL.y));
	Right.rgb = HUD(Right,float2(TCR.x + HUD_Adjustment,TCR.y));
	#endif

}

float4 Circle(float4 C, float2 TC)
{		
	if(Barrel_Distortion == 2)
		discard;
		
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

float3 VigneteL(float2 texcoord)
{
	float2 TC = -texcoord * texcoord*32 + texcoord*32;
	float3 Left = tex2D(SamplerLeft,texcoord).rgb;
		Left *= smoothstep(0,Vignette*27.0f,TC.x * TC.y);
return Left;
}

float3 VigneteR(float2 texcoord)
{
	float2 TC = -texcoord * texcoord*32 + texcoord*32;
	float3 Left = tex2D(SamplerRight,texcoord).rgb;
		Left *= smoothstep(0,Vignette*27.0f,TC.x * TC.y);
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

float3 PS_calcLR(float2 texcoord)
{
	float2 TCL = float2(texcoord.x * 2,texcoord.y), TCR = float2(texcoord.x * 2 - 1,texcoord.y), uv_redL, uv_greenL, uv_blueL, uv_redR, uv_greenR, uv_blueR;
	float4 color, Left, Right, color_redL, color_greenL, color_blueL, color_redR, color_greenR, color_blueR;
	float K1_Red = Polynomial_Colors_K1.x, K1_Green = Polynomial_Colors_K1.y, K1_Blue = Polynomial_Colors_K1.z;
	float K2_Red = Polynomial_Colors_K2.x, K2_Green = Polynomial_Colors_K2.y, K2_Blue = Polynomial_Colors_K2.z;
	if(Barrel_Distortion == 1 || Barrel_Distortion == 2)
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
		Left = VigneteL(TCL).rgb;
		Right = VigneteR(TCR).rgb;
	}

	if(!Depth_Map_View)
	{	
		if(Barrel_Distortion == 0)
		color = texcoord.x < 0.5 ? Left : Right;
		else if(Barrel_Distortion == 1)
		color = texcoord.x < 0.5 ? Circle(Left,float2(texcoord.x*2,texcoord.y)) : Circle(Right,float2(texcoord.x*2-1,texcoord.y));
		else if(Barrel_Distortion == 2)
		color = texcoord.x < 0.5 ? Left : Right;
	}
	else		
		color.rgb = zBuffer(texcoord).xxx;

	return color.rgb;
}

float3 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{	   float4 ABEA, ABEArray[6] = {
		float4(0.0,1.0,0.0, 1.0),           //No Edit
		float4(0.0,1.0,0.0, 0.750),         //Upper Extra Wide
		float4(0.0,1.0,0.0, 0.5),           //Upper Wide
		float4(0.0,1.0, 0.15625, 0.46875),  //Upper Short
		float4(0.375, 0.250, 0.4375, 0.125),//Center Small
		float4(0.375, 0.250, 0.0, 1.0)      //Center Long
	};
	ABEA = ABEArray[Auto_Balance_Ex];

	float Average_Lum_ZPD = Depth(float2(ABEA.x + texcoord.x * ABEA.y, ABEA.z + texcoord.y * ABEA.w)), Average_Lum_Bottom = tex2D(SamplerDMVR,float2( 0.125 + texcoord.x * 0.750,0.95 + texcoord.y)).x;
	return float3(Average_Lum_ZPD,Average_Lum_Bottom,tex2D(SamplerDMVR,0).x);
}

uniform float timer < source = "timer"; >; //Please do not remove.
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float3 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y, Text_Timer = 12500, BT = smoothstep(0,1,sin(timer*(3.75/1000)));
	float D,E,P,T,H,Three,DD,Dot,I,N,F,O,R,EE,A,DDD,HH,EEE,L,PP,Help,NN,PPP,C,Not,No;	
	float3 Color = PS_calcLR(texcoord).rgb;
	
	if(TW || NC || NP)
		Text_Timer = 18750;
		
	[branch] if(timer <= Text_Timer)
	{
		//DEPTH
		//D
		float PosXD = -0.035+PosX, offsetD = 0.001;
		float OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
		D = OneD-TwoD;	
		//E
		float PosXE = -0.028+PosX, offsetE = 0.0005;
		float OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
		float TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
		E = (OneE-TwoE)+ThreeE;		
		//P
		float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
		float OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.775));
		float TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.680));
		float ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		P = (OneP-TwoP) + ThreeP;
		//T
		float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
		float OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
		float TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
		T = OneT+TwoT;	
		//H
		float PosXH = -0.0072+PosX;
		float OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
		float TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
		float ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.00325,0.009));
		H = (OneH-TwoH)+ThreeH;	
		//Three
		float offsetFive = 0.001, PosX3 = -0.001+PosX;
		float OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
		float TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
		float ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
		Three = (OneThree-TwoThree)+ThreeThree;	
		//DD
		float PosXDD = 0.006+PosX, offsetDD = 0.001;	
		float OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DD = OneDD-TwoDD;		
		//Dot
		float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;		
		float OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
		Dot = OneDot;	
		//INFO
		//I
		float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
		float OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
		float TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
		float ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
		I = OneI+TwoI+ThreeI;
		//N
		float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
		float OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
		float TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
		N = OneN-TwoN;	
		//F
		float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
		float OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
		float TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
		float ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
		F = (OneF-TwoF)+ThreeF;		
		//O
		float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
		float OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
		float TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
		O = OneO-TwoO;
		//Text Warnings
		PosY -= 0.953;
		//R
		float PosXR = -0.480+PosX, PosYR = -0.0025+PosY, offsetR = 0.001, offsetR1 = 0.002,offsetR2 = -0.002,offsetR3 = 0.007;
		float OneR = all( abs(float2( texcoord.x -PosXR, texcoord.y-PosYR)) < float2(0.0025,0.009*0.775));
		float TwoR = all( abs(float2( texcoord.x -PosXR-offsetR, texcoord.y-PosYR)) < float2(0.0025,0.007*0.680));
		float ThreeR = all( abs(float2( texcoord.x -PosXR+offsetR1, texcoord.y-PosY)) < float2(0.0005,0.009));
		float FourR = all( abs(float2( texcoord.x -PosXR+offsetR2, texcoord.y-PosY-offsetR3)) < float2(0.0005,0.0020));
		R = (OneR-TwoR) + ThreeR + FourR;
		//EE
		float PosXEE = -0.472+PosX, offsetEE = 0.0005;
		float OneEE = all( abs(float2( texcoord.x -PosXEE, texcoord.y-PosY)) < float2(0.003,0.009));
		float TwoEE = all( abs(float2( texcoord.x -PosXEE-offsetEE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float ThreeEE = all( abs(float2( texcoord.x -PosXEE, texcoord.y-PosY)) < float2(0.003,0.001));
		EE = (OneEE-TwoEE)+ThreeEE;		
		//A
		float PosXA = -0.465+PosX,PosYA = -0.008+PosY;
		float OneA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosY)) < float2(0.002,0.001));
		float TwoA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosY)) < float2(0.002,0.009));
		float ThreeA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosY)) < float2(0.00325,0.009));
		float FourA = all( abs(float2( texcoord.x -PosXA, texcoord.y-PosYA)) < float2(0.003,0.001));		
		A = (OneA-TwoA)+ThreeA+FourA;		
		//DDD
		float PosXDDD = -0.458+PosX, offsetDDD = 0.001;	
		float OneDDD = all( abs(float2( texcoord.x -PosXDDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoDDD = all( abs(float2( texcoord.x -PosXDDD-offsetDDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DDD = OneDDD-TwoDDD;	
		//HH
		float PosXHH = -0.445+PosX;
		float OneHH = all( abs(float2( texcoord.x -PosXHH, texcoord.y-PosY)) < float2(0.002,0.001));
		float TwoHH = all( abs(float2( texcoord.x -PosXHH, texcoord.y-PosY)) < float2(0.0015,0.009));
		float ThreeHH = all( abs(float2( texcoord.x -PosXHH, texcoord.y-PosY)) < float2(0.00325,0.009));
		HH = (OneHH-TwoHH)+ThreeHH;
		//EEE
		float PosXEEE = -0.437+PosX, offsetEEE = 0.0005;
		float OneEEE = all( abs(float2( texcoord.x -PosXEEE, texcoord.y-PosY)) < float2(0.003,0.009));
		float TwoEEE = all( abs(float2( texcoord.x -PosXEEE-offsetEEE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float ThreeEEE = all( abs(float2( texcoord.x -PosXEEE, texcoord.y-PosY)) < float2(0.003,0.001));
		EEE = (OneEEE-TwoEEE)+ThreeEEE;
		//L
		float PosXL = -0.429+PosX, PosYL = 0.008+PosY, OffsetL = -0.949+PosX,OffsetLA = -0.951+PosX;
		float OneL = all( abs(float2( texcoord.x -PosXL+OffsetLA, texcoord.y-PosYL)) < float2(0.0025,0.001));
		float TwoL = all( abs(float2( texcoord.x -PosXL+OffsetL, texcoord.y-PosY)) < float2(0.0008,0.009));
		L = OneL+TwoL;
		//PP
		float PosXPP = -0.425+PosX, PosYPP = -0.0025+PosY, offsetPP = 0.001, offsetPP1 = 0.002;
		float OnePP = all( abs(float2( texcoord.x -PosXPP, texcoord.y-PosYPP)) < float2(0.0025,0.009*0.775));
		float TwoPP = all( abs(float2( texcoord.x -PosXPP-offsetPP, texcoord.y-PosYPP)) < float2(0.0025,0.007*0.680));
		float ThreePP = all( abs(float2( texcoord.x -PosXPP+offsetPP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		PP = (OnePP-TwoPP) + ThreePP;
		//No Profile / Not Compatible
		PosY += 0.953;
		PosX -= 0.483;
		float PosXNN = -0.458+PosX, offsetNN = 0.0015;	
		float OneNN = all( abs(float2( texcoord.x -PosXNN, texcoord.y-PosY)) < float2(0.00325,0.009));
		float TwoNN = all( abs(float2( texcoord.x -PosXNN, texcoord.y-PosY-offsetNN)) < float2(0.002,0.008));
		NN = OneNN-TwoNN;
		//PPP
		float PosXPPP = -0.451+PosX, PosYPPP = -0.0025+PosY, offsetPPP = 0.001, offsetPPP1 = 0.002;
		float OnePPP = all( abs(float2( texcoord.x -PosXPPP, texcoord.y-PosYPPP)) < float2(0.0025,0.009*0.775));
		float TwoPPP = all( abs(float2( texcoord.x -PosXPPP-offsetPPP, texcoord.y-PosYPPP)) < float2(0.0025,0.007*0.680));
		float ThreePPP = all( abs(float2( texcoord.x -PosXPPP+offsetPPP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		PPP = (OnePPP-TwoPPP) + ThreePPP;
		//C
		float PosXC = -0.450+PosX, offsetC = 0.001;
		float OneC = all( abs(float2( texcoord.x -PosXC, texcoord.y-PosY)) < float2(0.0035,0.009));
		float TwoC = all( abs(float2( texcoord.x -PosXC-offsetC, texcoord.y-PosY)) < float2(0.0025,0.007));
		C = OneC-TwoC;
		if(NP)
		No = (NN + PPP) * BT; //Blinking Text
		if(NC)
		Not = (NN + C) * BT; //Blinking Text
		if(TW)
			Help = (R+EE+A+DDD+HH+EEE+L+PP) * BT; //Blinking Text
		//Website
		return D+E+P+T+H+Three+DD+Dot+I+N+F+O+Help+No+Not ? (1-texcoord.y*50.0+48.85)*texcoord.y-0.500: Color;
	}
	else
		return Color;
}

float3 USM(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
	float2 tex_offset = pix; // Gets texel offset
	float3 result = tex2D(BackBuffer, texcoord).rgb;
	if(Sharpen_Power > 0)
	{				   
		   result += tex2D(BackBuffer, float2(texcoord + float2( 1, 0) * tex_offset)).rgb;
		   result += tex2D(BackBuffer, float2(texcoord + float2(-1, 0) * tex_offset)).rgb;
		   result += tex2D(BackBuffer, float2(texcoord + float2( 0, 1) * tex_offset)).rgb;
		   result += tex2D(BackBuffer, float2(texcoord + float2( 0,-1) * tex_offset)).rgb;
		   tex_offset *= 0.75;		   
		   result += tex2D(BackBuffer, float2(texcoord + float2( 1, 1) * tex_offset)).rgb;
		   result += tex2D(BackBuffer, float2(texcoord + float2(-1,-1) * tex_offset)).rgb;
		   result += tex2D(BackBuffer, float2(texcoord + float2( 1,-1) * tex_offset)).rgb;
		   result += tex2D(BackBuffer, float2(texcoord + float2(-1, 1) * tex_offset)).rgb;
   		result *= rcp(9);
		//High Contrast Mask
		float CA = 0.375f * 25.0f, HCM = saturate(dot(( tex2D(BackBuffer, texcoord).rgb - result.rgb ) , float3(0.333, 0.333, 0.333) * CA) ); 		
		result = tex2D(BackBuffer, texcoord).rgb + ( tex2D(BackBuffer, texcoord).rgb - result ) * Sharpen_Power;
		//Contrast Aware
		result = lerp(result, tex2D(BackBuffer, texcoord).rgb, HCM);
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
technique SuperDepth3D_VR
< ui_tooltip = "Suggestion : Please enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
			   "             Do this once you set your 3D settings of course."; >
{
		pass Cursor
	{
		VertexShader = PostProcessVS;
		PixelShader = MouseCursor;
	}	
		pass DepthBuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texDMVR;
	}
	#if Legacy_Mode
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = zBuffer;
		RenderTarget = texzBufferVR;
	}
	#endif
		pass LRtoBD
	{
		VertexShader = PostProcessVS;
		PixelShader = LR_Out;
		RenderTarget0 = LeftTex;
		RenderTarget1 = RightTex;	
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
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLumVR;
	}
}