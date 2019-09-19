////----------------//
///**SuperDepth3D**///
//----------------////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* Depth Map Based 3D post-process shader v2.0.5          																														
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
#else //DA_X ZPD | DA_Y Depth_Adjust | DA_Z Offset | DA_W Depth_Linearization | DB_X Depth_Flip | DB_Y Auto_Balance | DB_Z Auto_Depth | DB_W Weapon_Hand | DC_X HUDX | DC_Y HUDY | DC_Z Null | DC_W Text Warning | DD_X HV_X | DD_Y HV_Y | DD_Z DepthPX | DD_W DepthPY
	static const float DA_X = 0.025, DA_Y = 7.5, DA_Z = 0.0, DA_W = 0.0, DB_X = 0, DB_Y = 0, DB_Z = 0.1, DB_W = 0.0, DC_X =0.0, DC_Y = 0.5, DC_Z = 0, DC_W = 0, DD_X = 1,DD_Y = 1, DD_Z = 0.0, DD_W = 0.0;
	#define HM 0		
#endif
//USER EDITABLE PREPROCESSOR FUNCTIONS START//
//This enables the older SuperDepth3D method of producing an 3D image. This is better for older systems that have an hard time running the new mode.
#define Legacy_Mode 0 //Zero is off and One is On.

// Zero Parallax Distance Balance Mode allows you to switch control from manual to automatic and vice versa.
#define Balance_Mode 0 //Default 0 is Automatic. One is Manual.

// RE Fix is used to fix the issue with Resident Evil's 2 Remake 1-Shot cutscenes.
#define RE_Fix 0 //Default 0 is Off. One is On. 

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

#if __VENDOR__ == 0x10DE //AMD = 0x1002 //Nv = 0x10DE //Intel = ???
	#define Ven 1
#else
	#define Ven 0
#endif

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
				"Default is 0.025, Zero is off.";
	ui_category = "Divergence & Convergence";
> = DA_X;
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
uniform float Auto_Depth_Range <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = " Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n" 
				 "Default is 0.1f, Zero is off.";
	ui_category = "Divergence & Convergence";
> = DB_Z;

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "View Mode Normal\0View Mode Alpha\0";
	ui_label = " View Mode";
	ui_tooltip = "Change the way the shader warps the output to the screen.\n"
					 "For High Foliage games Use Alpha.\n"
				 "Default is Normal";
	ui_category = "Occlusion Masking";
> = 0;
uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = " Edge Handling";
	ui_tooltip = "Edges selection for your screen output.";
	ui_category = "Occlusion Masking";
> = 1;
#if !Legacy_Mode
uniform bool Performance_Mode <
	ui_label = " Performance Mode";
	ui_tooltip = "Performance Mode Lowers Occlusion Quality Processing so that there is a small boost to FPS.\n"
				 "Please enable the 'Performance Mode Checkbox,' in ReShade's GUI.\n"
				 "It's located in the lower bottom right of the ReShade's Main UI.\n"
				 "Default is False.";
	ui_category = "Occlusion Masking";
> = false;
#endif
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

uniform int Depth_Map_View <
	ui_type = "combo";
	ui_items = "Off\0Stero Depth View\0Normal Depth View\0";
	ui_label = " Depth Map View";
	ui_tooltip = "Display the Depth Map";
	ui_category = "Depth Map";
> = 0;

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
	ui_items = "Weapon Profile Off\0Custom WP\0WP 0\0WP 1\0WP 2\0WP 3\0WP 4\0WP 5\0WP 6\0WP 7\0WP 8\0WP 9\0WP 10\0WP 11\0WP 12\0WP 13\0WP 14\0WP 15\0WP 16\0WP 17\0WP 18\0WP 19\0WP 20\0WP 21\0WP 22\0WP 23\0WP 24\0WP 25\0WP 26\0WP 27\0WP 28\0WP 29\0WP 30\0WP 31\0WP 32\0WP 33\0WP 34\0WP 35\0WP 36\0WP 37\0WP 38\0WP 39\0WP 40\0WP 41\0WP 42\0WP 43\0WP 44\0WP 45\0WP 46\0WP 47\0WP 48\0WP 49\0WP 50\0WP 51\0WP 52\0WP 53\0WP 54\0WP 55\0WP 56\0WP 57\0WP 58\0WP 59\0";
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

uniform float WZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.5;
	ui_label = " Weapon Zero Parallax Distance";
	ui_tooltip = "WZPD controls the focus distance for the screen Pop-out effect also known as Convergence for the weapon hand.\n"
				"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
				"This is controled by Convergence Mode.\n"
				"Default is 0.03f & Zero is off.";
	ui_category = "Weapon Hand Adjust";
> = 0.03;

uniform int FPSDFIO <
	ui_type = "combo";
	ui_items = "Off\0Press\0Hold Down\0";
	ui_label = " FPS Focus Depth";
	ui_tooltip = "This lets the shader handle real time depth reduction for aiming down your sights.\n"
				 "This may induce Eye Strain so take this as an Warning.";
	ui_category = "Weapon Hand Adjust";
> = 0;
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
> = float2(DC_X,DC_Y);
#endif
//Stereoscopic Options//
uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Anaglyph 3D Red/Cyan\0Anaglyph 3D Red/Cyan Dubois\0Anaglyph 3D Red/Cyan Anachrome\0Anaglyph 3D Green/Magenta\0Anaglyph 3D Green/Magenta Dubois\0Anaglyph 3D Green/Magenta Triochrome\0Anaglyph 3D Blue/Amber ColorCode\0";
	ui_label = "·3D Display Modes·";
	ui_tooltip = "Stereoscopic 3D display output selection.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform float2 Interlace_Anaglyph <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Interlace & Anaglyph";
	ui_tooltip = "Interlace Optimization is used to reduce alisesing in a Line or Column interlaced image. This has the side effect of softening the image.\n"
	             "Anaglyph Desaturation allows for removing color from an anaglyph 3D image. Zero is Black & White, One is full color.\n"
	             "Default for Interlace Optimization is 0.5 and for Anaglyph Desaturation is One.";
	ui_category = "Stereoscopic Options";
> = float2(0.5,1.0);
#if Ven
uniform int Scaling_Support <
	ui_type = "combo";
	ui_items = "SR Native\0SR 2160p A\0SR 2160p B\0SR 1080p A\0SR 1080p B\0SR 1050p A\0SR 1050p B\0SR 720p A\0SR 720p B\0";
	ui_label = " Scaling Support";
	ui_tooltip = "Dynamic Super Resolution scaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.\n"
				 "Set this to your native Screen Resolution A or B, DSR Smoothing must be set to 0%.\n"
				 "This does not work with a hardware ware scaling done by VSR.\n"
				 "Default is SR Native.";
	ui_category = "Stereoscopic Options";
> = 0;
#else
static const int Scaling_Support = 0;
#endif
uniform int Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = " Perspective Slider";
	ui_tooltip = "Determines the perspective point of the two images this shader produces.\n"
				 "For an HMD, use Polynomial Barrel Distortion shader to adjust for IPD.\n" 
				 "Do not use this perspective adjustment slider to adjust for IPD.\n"
				 "Default is Zero.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform bool Eye_Swap <
	ui_label = " Swap Eyes";
	ui_tooltip = "L/R to R/L.";
	ui_category = "Stereoscopic Options";
> = false;
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
				 "Defaults are ( X 0.125, Y 0.5, Z 0.0).";
	ui_category = "Cursor Adjustments";
> = float3(0.125,0.5,0.0);

uniform bool SCSC <
	ui_label = " Cursor Lock";
	ui_tooltip = "Screen Cursor to Screen Crosshair Lock.";
	ui_category = "Cursor Adjustments";
> = false;

uniform float2 Adjust <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = -1; ui_max = 1; ui_step = 0.001;
	ui_label = "·Adjust·";
	ui_tooltip = "Adjust.";
	ui_category = "Adjust";
> = float2(0,0);

uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; mode = "toggle";>;
uniform bool Mask_Cycle < source = "key"; keycode = Mask_Cycle_Key; toggle = true; >;
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
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};

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
	
texture texDMN  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; }; 

sampler SamplerDMN
	{
		Texture = texDMN;
	};
			
#if UI_MASK
texture TexMaskA < source = "Mask_A.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler SamplerMaskA { Texture = TexMaskA;};

texture TexMaskB < source = "Mask_B.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler SamplerMaskB { Texture = TexMaskB;};
#endif
		
uniform float2 Mousecoords < source = "mousepoint"; > ;	
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
	Cursor =  CArray[Cursor_Type];
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
	int CSTT = int(Cursor_STT.z * 10);
	Color.rgb = CCArray[CSTT];

	Out = Cursor ? Color : Out;
	
	return Out;
}

/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLumN {Width = 256*0.5; Height = 256*0.5; Format = RGBA16F; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumN																
	{
		Texture = texLumN;
	};	
	
float2 Lum(float2 texcoord)
	{   //Luminance
		return saturate(tex2Dlod(SamplerLumN,float4(texcoord,0,11)).xy);//Average Luminance Texture Sample 
	}
	
uniform float frametime < source = "frametime";>;
/////////////////////////////////////////////////////////////////////////////////Fade In and Out Toggle/////////////////////////////////////////////////////////////////////////////////	
uniform bool Trigger_Fade_A < source = "mousebutton"; keycode = Fade_Key; toggle = true; mode = "toggle";>;
uniform bool Trigger_Fade_B < source = "mousebutton"; keycode = Fade_Key;>;

float Fade_in_out(float2 texcoord)	
{
	float Trigger_Fade, AA = (1-Fade_Time_Adjust)*1000, PStoredfade = tex2D(SamplerLumN,texcoord).z;
	//Fade in toggle. 
	if(FPSDFIO == 1)
		Trigger_Fade = Trigger_Fade_A;
	else if(FPSDFIO == 2)
		Trigger_Fade = Trigger_Fade_B;
	
	return PStoredfade + (Trigger_Fade - PStoredfade) * (1.0 - exp(-frametime/AA)); ///exp2 would be even slower  	
}
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////
float Depth(float2 texcoord)
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

	if (Depth_Map == 0) //DM0 Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1) //DM1 Reverse
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

float4 DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0) : SV_Target
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
		A = DM.w; //Normal Depth
		
	if(texcoord.x < pix.x * 2 && texcoord.y < pix.y * 2)
		A = Fade_in_out(texcoord);
		
	return saturate(float4(R,G,B,A));
}
#if HUD_MODE || HM
float4 HUD(float4 HUD, float2 texcoord ) 
{		
	float Mask_Tex, CutOFFCal = ((HUD_Adjust.x * 0.5)/Depth_Map_Adjust) * 0.5, COC = step(Depth(texcoord).x,CutOFFCal); //HUD Cutoff Calculation
	
	//This code is for hud segregation.			
	if (HUD_Adjust.x > 0)
		HUD = COC > 0 ? tex2D(BackBuffer,texcoord) : HUD;	
		
#if UI_MASK	
    [branch] if (Mask_Cycle == true) 
        Mask_Tex = tex2D(SamplerMaskB,texcoord.xy).a;
    else
        Mask_Tex = tex2D(SamplerMaskA,texcoord.xy).a;

	float MAC = step(1.0-Mask_Tex,0.5); //Mask Adjustment Calculation
	//This code is for hud segregation.			
	HUD = MAC > 0 ? tex2D(BackBuffer,texcoord) : HUD;
#endif		
	return HUD;	
}
#endif
float AutoDepthRange(float d, float2 texcoord )
{
	float LumAdjust_ADR = smoothstep(-0.0175,Auto_Depth_Range,Lum(texcoord).y);
    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
}
#if RE_Fix
float AutoZPDRange(float ZPD, float2 texcoord )
{
	float LumAdjust_AZDPR = smoothstep(-0.0175,0.125,Lum(texcoord).y); //Adjusted to only effect really intense differences.
    return saturate(LumAdjust_AZDPR * ZPD);
}
#endif
float2 Conv(float D,float2 texcoord)
{
	float Z = ZPD, WZP = 0.5, ZP = 0.5, ALC = abs(Lum(texcoord).x), WConvergence = 1 - WZPD / D;
	#if RE_Fix	
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

float zBuffer(float2 texcoord)
{	
	float4 DM = tex2Dlod(SamplerDMN,float4(texcoord,0,0));
	
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
float2 Parallax(float Diverge, float2 Coordinates) // Horizontal parallax offset & Hole filling effect
{   float2 ParallaxCoord = Coordinates;
	float DepthLR = 1, LRDepth, Perf = 1, Z, MS = Diverge * pix.x, MSM, N = 9, S[9] = {0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1.0};
	#if Legacy_Mode	
	MS = -MS;
	[loop]
	for ( int i = 0 ; i < N; i++ ) 
	{	MSM = MS + 0.001;
				
		DepthLR = min(DepthLR, zBuffer(float2(ParallaxCoord.x + S[i] * MS, ParallaxCoord.y)) );
		if(View_Mode == 1)
		{
			LRDepth =  min(DepthLR,zBuffer(float2(ParallaxCoord.x + S[i] * MSM, ParallaxCoord.y)) );						
			LRDepth += min(DepthLR,zBuffer(float2(ParallaxCoord.x + S[i] * (MSM * 0.9375), ParallaxCoord.y)) );			
			LRDepth += min(DepthLR,zBuffer(float2(ParallaxCoord.x + S[i] * (MSM * 0.875), ParallaxCoord.y)) );	
			LRDepth += min(DepthLR,zBuffer(float2(ParallaxCoord.x + S[i] * (MSM * 0.6875), ParallaxCoord.y)) );			
			LRDepth += min(DepthLR,zBuffer(float2(ParallaxCoord.x + S[i] * (MSM * 0.500), ParallaxCoord.y)) );	
			
			DepthLR = lerp(LRDepth * rcp(5), DepthLR, 0.1875);
		}		
	}
	//Reprojection Left and Right
	ParallaxCoord = float2(Coordinates.x + (MS * DepthLR), Coordinates.y);
	#else
	if(Performance_Mode)
	Perf = .5;
	//ParallaxSteps Calculations
	float D = abs(length(Diverge)), Cal_Steps = (D * Perf) + (D * 0.04), Steps = clamp(Cal_Steps,0,255);

	// Offset per step progress & Limit
	float LayerDepth = rcp(Steps);

	//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
	float deltaCoordinates = MS * LayerDepth;
	float2 DB_Offset = float2((Diverge * 0.0375) * pix.x, 0);
	float CurrentDepthMapValue = zBuffer(ParallaxCoord), CurrentLayerDepth = 0, DepthDifference;

	[loop] //Steep parallax mapping
    for ( int i = 0; i < Steps; i++ )
    {	// Doing it this way should stop crashes in older version of reshade, I hope.
        if (CurrentDepthMapValue <= CurrentLayerDepth)
			break; // Once we hit the limit Stop Exit Loop.
        // Shift coordinates horizontally in linear fasion
        ParallaxCoord.x -= deltaCoordinates;
        // Get depth value at current coordinates
    	[branch] if(View_Mode == 1)
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
	
	if(View_Mode == 0)
	ParallaxCoord += DB_Offset;
	
	// Apply gap masking
	DepthDifference = (afterDepthValue-beforeDepthValue) * MS;
	if(View_Mode == 1)
		ParallaxCoord.x = ParallaxCoord.x - DepthDifference;
	#endif
	return ParallaxCoord;
}
//Per is Perspective & Optimization for line interlaced Adjustment. 
#define Per float2( (Perspective * pix.x) * 0.5, 0)
#define AI Interlace_Anaglyph.x * 0.5	
float4 CSB(float2 texcoords)
{
	if(Custom_Sidebars == 0 && Depth_Map_View == 0)
		return tex2Dlod(BackBufferMIRROR,float4(texcoords,0,0));
	else if(Custom_Sidebars == 1 && Depth_Map_View == 0)
		return tex2Dlod(BackBufferBORDER,float4(texcoords,0,0));
	else if(Custom_Sidebars == 2 && Depth_Map_View == 0)
		return tex2Dlod(BackBufferCLAMP,float4(texcoords,0,0));
	else
		return zBuffer(texcoords).xxxx;
}
	
float4 PS_calcLR(float2 texcoord)
{
	float2 TCL, TCR, TexCoords = texcoord;

	[branch] if (Stereoscopic_Mode == 0)
	{
		TCL = float2(texcoord.x*2,texcoord.y);
		TCR = float2(texcoord.x*2-1,texcoord.y);
	}
	else if(Stereoscopic_Mode == 1)
	{
		TCL = float2(texcoord.x,texcoord.y*2);
		TCR = float2(texcoord.x,texcoord.y*2-1);
	}
	else
	{
		TCL = float2(texcoord.x,texcoord.y);
		TCR = float2(texcoord.x,texcoord.y);
	}

	TCL += Per;
	TCR -= Per;
	
	float D = Divergence;
	if (Eye_Swap)
		D = -Divergence;
		
	[branch] if(Stereoscopic_Mode == 2)
	{
		TCL.y += AI * pix.y; //Optimization for line interlaced.
		TCR.y -= AI * pix.y; //Optimization for line interlaced.						
	}
	else if(Stereoscopic_Mode == 3)
	{
		TCL.x += AI * pix.x; //Optimization for column interlaced.
		TCR.x -= AI * pix.x; //Optimization for column interlaced.					
	}	

	float FadeIO = smoothstep(0,1,1-Fade_in_out(texcoord).x), FD = D;
	
	if (FPSDFIO == 1 || FPSDFIO == 2)
		FD = lerp(FD * 0.0625,FD,FadeIO);
		
	float2 DLR = float2(FD,FD);
	
	if( Eye_Fade_Reduction == 1)
			DLR = float2(D,FD);
	else if( Eye_Fade_Reduction == 2)
			DLR = float2(FD,D);

	float4 color, Left = CSB(Parallax(-DLR.x, TCL)), Right = CSB(Parallax(DLR.y, TCR));		

	#if HUD_MODE || HM	
	float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25.) * pix.x;
	Left = HUD(Left,float2(TCL.x - HUD_Adjustment,TCL.y));
	Right = HUD(Right,float2(TCR.x + HUD_Adjustment,TCR.y));
	#endif
		
	float2 gridxy, GXYArray[9] = {
		float2(TexCoords.x * BUFFER_WIDTH, TexCoords.y * BUFFER_HEIGHT), //Native
		float2(TexCoords.x * 3840.0, TexCoords.y * 2160.0),
		float2(TexCoords.x * 3841.0, TexCoords.y * 2161.0),
		float2(TexCoords.x * 1920.0, TexCoords.y * 1080.0),
		float2(TexCoords.x * 1921.0, TexCoords.y * 1081.0),
		float2(TexCoords.x * 1680.0, TexCoords.y * 1050.0),
		float2(TexCoords.x * 1681.0, TexCoords.y * 1051.0),
		float2(TexCoords.x * 1280.0, TexCoords.y * 720.0),
		float2(TexCoords.x * 1281.0, TexCoords.y * 721.0)
	};
	gridxy = floor(GXYArray[Scaling_Support]);
			
	[branch] if(Stereoscopic_Mode == 0)
	{	
		color = TexCoords.x < 0.5 ? Left : Right;
	}
	else if(Stereoscopic_Mode == 1)
	{	
		color = TexCoords.y < 0.5 ? Left : Right;
	}
	else if(Stereoscopic_Mode == 2)
	{
		color = fmod(gridxy.y,2.0) ? Right : Left;	
	}
	else if(Stereoscopic_Mode == 3)
	{
		color = fmod(gridxy.x,2.0) ? Right : Left;		
	}
	else if(Stereoscopic_Mode == 4)
	{
		color = fmod(gridxy.x+gridxy.y,2.0) ? Right : Left;
	}
	else if(Stereoscopic_Mode >= 5)
	{			
		float Contrast = 1.0, Deghost = 0.06, LOne, LTwo, ROne, RTwo;
		float3 HalfLA = dot(Left.rgb,float3(0.299, 0.587, 0.114));
		float3 HalfRA = dot(Right.rgb,float3(0.299, 0.587, 0.114));
		float3 LMA = lerp(HalfLA,Left.rgb,Interlace_Anaglyph.y);  
		float3 RMA = lerp(HalfRA,Right.rgb,Interlace_Anaglyph.y); 
		float4 image = 1, accumRC, accumGM, accumBA;

		float contrast = (Contrast*0.5)+0.5, deghost = Deghost;
			
		// Left/Right Image
		float4 cA = float4(LMA,1);
		float4 cB = float4(RMA,1);

		if (Stereoscopic_Mode == 5) // Anaglyph 3D Colors Red/Cyan
		{
			float4 LeftEyecolor = float4(1.0,0.0,0.0,1.0);
			float4 RightEyecolor = float4(0.0,1.0,1.0,1.0);
			
			color =  (cA*LeftEyecolor) + (cB*RightEyecolor);
		}
		else if (Stereoscopic_Mode == 6) // Anaglyph 3D Dubois Red/Cyan
		{
		float red = 0.437 * cA.r + 0.449 * cA.g + 0.164 * cA.b
					- 0.011 * cB.r - 0.032 * cB.g - 0.007 * cB.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = -0.062 * cA.r -0.062 * cA.g -0.024 * cA.b 
						+ 0.377 * cB.r + 0.761 * cB.g + 0.009 * cB.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.048 * cA.r - 0.050 * cA.g - 0.017 * cA.b 
						-0.026 * cB.r -0.093 * cB.g + 1.234  * cB.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }

			color = float4(red, green, blue, 0);
		}
		else if (Stereoscopic_Mode == 7) // Anaglyph 3D Deghosted Red/Cyan Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
		{
			LOne = contrast*0.45;
			LTwo = (1.0-LOne)*0.5;
			ROne = contrast;
			RTwo = 1.0-ROne;
			deghost = Deghost*0.1;

			accumRC = saturate(cA*float4(LOne,LTwo,LTwo,1.0));
			image.r = pow(accumRC.r+accumRC.g+accumRC.b, 1.00);
			image.a = accumRC.a;

			accumRC = saturate(cB*float4(RTwo,ROne,0.0,1.0));
			image.g = pow(accumRC.r+accumRC.g+accumRC.b, 1.15);
			image.a = image.a+accumRC.a;

			accumRC = saturate(cB*float4(RTwo,0.0,ROne,1.0));
			image.b = pow(accumRC.r+accumRC.g+accumRC.b, 1.15);
			image.a = (image.a+accumRC.a)/3.0;

			accumRC = image;
			image.r = (accumRC.r+(accumRC.r*(deghost))+(accumRC.g*(deghost*-0.5))+(accumRC.b*(deghost*-0.5)));
			image.g = (accumRC.g+(accumRC.r*(deghost*-0.25))+(accumRC.g*(deghost*0.5))+(accumRC.b*(deghost*-0.25)));
			image.b = (accumRC.b+(accumRC.r*(deghost*-0.25))+(accumRC.g*(deghost*-0.25))+(accumRC.b*(deghost*0.5)));
			color = image;
		}
		else if (Stereoscopic_Mode == 8) // Anaglyph 3D Green/Magenta
		{
			float4 LeftEyecolor = float4(0.0,1.0,0.0,1.0);
			float4 RightEyecolor = float4(1.0,0.0,1.0,1.0);
			
			color =  (cA*LeftEyecolor) + (cB*RightEyecolor);			
		}
		else if (Stereoscopic_Mode == 9) // Anaglyph 3D Dubois Green/Magenta
		{
							
			float red = -0.062 * cA.r -0.158 * cA.g -0.039 * cA.b
					+ 0.529 * cB.r + 0.705 * cB.g + 0.024 * cB.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = 0.284 * cA.r + 0.668 * cA.g + 0.143 * cA.b 
						- 0.016 * cB.r - 0.015 * cB.g + 0.065 * cB.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.015 * cA.r -0.027 * cA.g + 0.021 * cA.b 
						+ 0.009 * cB.r + 0.075 * cB.g + 0.937  * cB.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
					
			color = float4(red, green, blue, 0);
		}
		else if (Stereoscopic_Mode == 10)// Anaglyph 3D Deghosted Green/Magenta Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
		{
			LOne = contrast*0.45;
			LTwo = (1.0-LOne)*0.5;
			ROne = contrast*0.8;
			RTwo = 1.0-ROne;
			deghost = Deghost*0.275;

			accumGM = saturate(cB*float4(ROne,RTwo,0.0,1.0));
			image.r = pow(accumGM.r+accumGM.g+accumGM.b, 1.15);
			image.a = accumGM.a;

			accumGM = saturate(cA*float4(LTwo,LOne,LTwo,1.0));
			image.g = pow(accumGM.r+accumGM.g+accumGM.b, 1.05);
			image.a = image.a+accumGM.a;

			accumGM = saturate(cB*float4(0.0,RTwo,ROne,1.0));
			image.b = pow(accumGM.r+accumGM.g+accumGM.b, 1.15);
			image.a = (image.a+accumGM.a)/3.0;

			accumGM = image;
			image.r = (accumGM.r+(accumGM.r*(deghost*0.5))+(accumGM.g*(deghost*-0.25))+(accumGM.b*(deghost*-0.25)));
			image.g = (accumGM.g+(accumGM.r*(deghost*-0.5))+(accumGM.g*(deghost*0.25))+(accumGM.b*(deghost*-0.5)));
			image.b = (accumGM.b+(accumGM.r*(deghost*-0.25))+(accumGM.g*(deghost*-0.25))+(accumGM.b*(deghost*0.5)));
			color = image;
		}
		else if (Stereoscopic_Mode == 11) // Anaglyph 3D Blue/Amber Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
		{
			LOne = contrast*0.45;
			LTwo = (1.0-LOne)*0.5;
			ROne = contrast;
			RTwo = 1.0-ROne;
			deghost = Deghost*0.275;

			accumBA = saturate(cA*float4(ROne,0.0,RTwo,1.0));
			image.r = pow(accumBA.r+accumBA.g+accumBA.b, 1.05);
			image.a = accumBA.a;

			accumBA = saturate(cA*float4(0.0,ROne,RTwo,1.0));
			image.g = pow(accumBA.r+accumBA.g+accumBA.b, 1.10);
			image.a = image.a+accumBA.a;

			accumBA = saturate(cB*float4(LTwo,LTwo,LOne,1.0));
			image.b = pow(accumBA.r+accumBA.g+accumBA.b, 1.0);
			image.b = lerp(pow(image.b,(Deghost*0.15)+1.0),1.0-pow(abs(1.0-image.b),(Deghost*0.15)+1.0),image.b);
			image.a = (image.a+accumBA.a)/3.0;

			accumBA = image;
			image.r = (accumBA.r+(accumBA.r*(deghost*1.5))+(accumBA.g*(deghost*-0.75))+(accumBA.b*(deghost*-0.75)));
			image.g = (accumBA.g+(accumBA.r*(deghost*-0.75))+(accumBA.g*(deghost*1.5))+(accumBA.b*(deghost*-0.75)));
			image.b = (accumBA.b+(accumBA.r*(deghost*-1.5))+(accumBA.g*(deghost*-1.5))+(accumBA.b*(deghost*3.0)));
			color = saturate(image);
		}
	}
	
	if	(Depth_Map_View == 2)
		color = zBuffer(TexCoords).xxxx;
		
	return color;
}

float4 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{

	float4 ABEA, ABEArray[6] = {
		float4(0.0,1.0,0.0, 1.0),           //No Edit
		float4(0.0,1.0,0.0, 0.750),         //Upper Extra Wide
		float4(0.0,1.0,0.0, 0.5),           //Upper Wide
		float4(0.0,1.0, 0.15625, 0.46875),  //Upper Short
		float4(0.375, 0.250, 0.4375, 0.125),//Center Small
		float4(0.375, 0.250, 0.0, 1.0)      //Center Long
	};
	ABEA = ABEArray[Auto_Balance_Ex];
			
	float Average_Lum_ZPD = tex2Dlod(SamplerDMN,float4(ABEA.x + texcoord.x * ABEA.y, ABEA.z + texcoord.y * ABEA.w, 0, 0)).w;
	float Average_Lum_Full = tex2Dlod(SamplerDMN,float4(texcoord.x,texcoord.y, 0, 0)).w;
	return float4(Average_Lum_ZPD,Average_Lum_Full,tex2Dlod(SamplerDMN,float4(0,0, 0, 0)).w,1);
}
uniform float timer < source = "timer"; >; //Please do not remove.
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y, Text_Timer = 12500;
	float D,E,P,T,H,Three,DD,Dot,I,N,F,O,R,EE,A,DDD,HH,EEE,L,PP, Help;	
	float3 Color = PS_calcLR(texcoord).rgb;
	
	if(DC_W == 1)
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
		float FourR = all( abs(float2( texcoord.x -PosXR+offsetR2, texcoord.y-PosY-offsetR3)) < float2(0.0005,0.0025));
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
		if(DC_W == 1)
			Help = R+EE+A+DDD+HH+EEE+L+PP;
		//Website
		return D+E+P+T+H+Three+DD+Dot+I+N+F+O+Help ? (1-texcoord.y*50.0+48.85)*texcoord.y-0.500: float4(Color,1.);
	}
	else
		return float4(Color,1.);
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

technique Cross_Cursor
{			
		pass Cursor
	{
		VertexShader = PostProcessVS;
		PixelShader = MouseCursor;
	}	
}

technique SuperDepth3D
< ui_tooltip = "Suggestion : You Can Enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
			   "             Do this once you set your 3D settings of course."; >
{
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texDMN;
	}
		pass StereoOut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLumN;
	}
}