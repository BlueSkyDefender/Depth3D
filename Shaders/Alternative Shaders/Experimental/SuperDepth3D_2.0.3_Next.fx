 ////---------------------//
 ///**SuperDepth3D_Next**///
 //---------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v2.0.3          																														*//
 //* For Reshade 3.0+																																								*//
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
// Such as the game Naruto Shippuden: Ultimate Ninja and or Unreal Gold 277. That have this issue. This also allows for more advance users
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

//USER EDITABLE PREPROCESSOR FUNCTIONS END//

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
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
> = 0.025;

#if Balance_Mode
uniform float ZPD_Balance <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " ZPD Balance";
	ui_tooltip = "Zero Parallax Distance balances between ZPD Depth and Scene Depth.\n"
				"Default is Zero is full Convergence and One is Full Depth.";
	ui_category = "Divergence & Convergence";
> = 0.5;
#define Auto_Balance_Ex 0
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
> = 0;
#endif

uniform float Auto_Depth_Range <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = " Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n" 
				 "Default is 0.1f, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.1;


uniform int View_Mode <
	ui_type = "combo";
	ui_items = "View Mode Normal\0View Mode Alpha\0";
	ui_label = " View Mode";
	ui_tooltip = "Change the way the shader warps the output to the screen.\n"
				 "Default is Normal";
	ui_category = "Occlusion Masking";
> = 0;

uniform bool Side_Bars <
	ui_label = " Side Bars";
	ui_tooltip = "Adds Side Bar to the Left and Right Edges";
	ui_category = "Occlusion Masking";
> = false;
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

uniform float Offset <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Depth Map Offset";
	ui_tooltip = "Depth Map Offset is for non conforming ZBuffer.\n"
				 "It,s rare if you need to use this in any game.\n"
				 "Use this to make adjustments to DM 0 or DM 1.\n"
				 "Default and starts at Zero and it's Off.";
	ui_category = "Depth Map";
> = 0.0;

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

uniform bool Menu_Detection <
	ui_label = " Menu Detection";
	ui_tooltip = "Use this to dissable/enable in game Menu Detection.";
	ui_category = "Depth Map";
> = false;
#if DB_Size_Postion 
uniform int2 Image_Position_Adjust<
	ui_type = "drag";
	ui_min = -4096.0; ui_max = 4096.0;
	ui_label = "Z Position Adjust";
	ui_tooltip = "Adjust the Image Postion if it's off by a bit. Default is Zero.";
	ui_category = "Depth Map";
> = int2(0.0,0.0);
	
uniform float2 Horizontal_and_Vertical <
	ui_type = "drag";
	ui_min = 0.125; ui_max = 2;
	ui_label = "Z Horizontal & Vertical";
	ui_tooltip = "Adjust Horizontal and Vertical Resize. Default is 1.0.";
	ui_category = "Depth Map";
> = float2(1.0,1.0);
#endif
//Weapon Hand Adjust//
uniform int WP <
	ui_type = "combo";
	ui_items = "Weapon Profile Off\0Custom WP\0WP 0\0WP 1\0WP 2\0WP 3\0WP 4\0WP 5\0WP 6\0WP 7\0WP 8\0WP 9\0WP 10\0WP 11\0WP 12\0WP 13\0WP 14\0WP 15\0WP 16\0WP 17\0WP 18\0WP 19\0WP 20\0WP 21\0WP 22\0WP 23\0WP 24\0WP 25\0WP 26\0WP 27\0WP 28\0WP 29\0WP 30\0WP 31\0WP 32\0WP 33\0WP 34\0WP 35\0WP 36\0WP 37\0WP 38\0WP 39\0WP 40\0WP 41\0WP 42\0WP 43\0WP 44\0WP 45\0WP 46\0WP 47\0WP 48\0WP 49\0WP 50\0";
	ui_label = "·Weapon Profiles·";
	ui_tooltip = "Pick Weapon Profile for your game or make your own.";
	ui_category = "Weapon Hand Adjust";
> = 0;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 25.0;
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
#if HUD_MODE
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
> = float2(0.0,0.5);
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
				 "Defaults are ( X 0.125, Y 0.5, Z 1.0).";
	ui_category = "Cursor Adjustments";
> = float3(0.125,0.5,1.0);

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
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
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
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
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
	
	float Cursor = CC;
	
	[branch] if(Cursor_Type == 1)
		Cursor = RC;
	else if(Cursor_Type == 2)
		Cursor = SSC;
	else if(Cursor_Type == 3)
		Cursor = SSC + CC;
	else if(Cursor_Type == 4)
		Cursor = SSC + RC;
	else if(Cursor_Type == 5)
		Cursor = CC + RC;
	else if(Cursor_Type == 6)
		Cursor = CC + RC + SSC;
	
	[branch]if (Cursor_STT.z == 1 )
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
	
float2 Lum(in float2 texcoord : TEXCOORD0)
	{
		float2 Luminance = tex2Dlod(SamplerLumN,float4(texcoord,0,0)).xy; //Average Luminance Texture Sample 

		return saturate(Luminance);
	}
		
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////
float DMA()//Depth Map Adjustment
{
	float DMA = Depth_Map_Adjust;	
	if(Depth_Adjust)
		DMA = Alt_Depth_Map_Adjust;

	return DMA;
}

float Depth(in float2 texcoord : TEXCOORD0)
{	
	#if DB_Size_Postion
	float2 texXY = texcoord + Image_Position_Adjust * pix;		
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
	#endif
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBuffer = tex2D(DepthBuffer, texcoord).x; //Depth Buffer
	
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1.0, Near = 0.125/DMA();  //Division Depth Map Adjust - Near
	
	float2 Offsets = float2(1 + Offset,1 - Offset), Z = float2( zBuffer, 1-zBuffer );
	
	if (Offset > 0)
	Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));

	[branch] if (Depth_Map == 0)//DM0. Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = Far * Near / (Far + Z.y * (Near - Far));
		
	return zBuffer;
}

float2 WeaponDepth(in float2 texcoord : TEXCOORD0)
{
	#if DB_Size_Postion
	float2 texXY = texcoord + Image_Position_Adjust * pix;		
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
	#endif	
	
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;

	float zBufferWH = tex2D(DepthBuffer, texcoord).x, CutOff = Weapon_Adjust.x , Adjust = Weapon_Adjust.y, Tune = Weapon_Adjust.z;
	
	float3 WA_XYZ;//Weapon Profiles Starts Here
	[branch] if (WP == 1)                   // WA_XYZ.x | WA_XYZ.y | WA_XYZ.z 
		WA_XYZ = float3(CutOff,Adjust,Tune);// X Cutoff | Y Adjust | Z Tuneing 		
	else if(WP == 2) //WP 0
		WA_XYZ = float3(0.425,0.025,0);        //ES: Oblivion		
	else if(WP == 3) //WP 1
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 4) //WP 2
		WA_XYZ = float3(0.625,37.5,7.25);      //BorderLands 2*	
	else if(WP == 5) //WP 3
		WA_XYZ = float3(0,0,0);                //Game	
	else if(WP == 6) //WP 4
		WA_XYZ = float3(0.253,40.0,97.5);      //Fallout 4*			
	else if(WP == 7) //WP 5
		WA_XYZ = float3(0.276,0.6875,20.0);    //Skyrim: SE
	else if(WP == 8) //WP 6
		WA_XYZ = float3(0.338,25.0,9.0);       //DOOM 2016*	
	else if(WP == 9) //WP 7
		WA_XYZ = float3(0.255,0.5625,-0.750);  //CoD: Black Ops
	else if(WP == 10)//WP 8
		WA_XYZ = float3(0.254,300.0,0.9843);   //CoD:AW*	
	else if(WP == 11)//WP 9
		WA_XYZ = float3(0.425,25.0,100.0);     //Bioshock Remastred*
	else if(WP == 12)//WP 10
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 13)//WP 11
		WA_XYZ = float3(0.450,12.0,23.75);     //Metro Redux Games*	
	else if(WP == 14)//WP 12
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 15)//WP 13
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 16)//WP 14
		WA_XYZ = float3(1.0,27.5,6.25);        //Rage64		
	else if(WP == 17)//WP 15
		WA_XYZ = float3(0.375,2.5,-44.75);     //Quake DarkPlaces	
	else if(WP == 18)//WP 16
		WA_XYZ = float3(0.7,0.4,-30.0);        //Quake 2 XP & Return to Castle Wolfenstine
	else if(WP == 19)//WP 17
		WA_XYZ = float3(0.750,1.5,-1.250);     //Quake 4
	else if(WP == 20)//WP 18
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 21)//WP 19
		WA_XYZ = float3(0.255,0.01,22.5);      //S.T.A.L.K.E.R: Games
	else if(WP == 22)//WP 20
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 23)//WP 21
		WA_XYZ = float3(1.0,1.0,7.5);          //Turok: DH 2017
	else if(WP == 24)//WP 22
		WA_XYZ = float3(0.570,2.0,0.0);        //Turok2: SoE 2017
	else if(WP == 25)//WP 23
		WA_XYZ = float3(0,0,0);                //Turok 3: Shadow of Oblivion
	else if(WP == 26)//WP 24
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 27)//WP 25
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 28)//WP 26
		WA_XYZ = float3(0.750,3.4375,0);       //Prey - 2006
	else if(WP == 29)//WP 27
		WA_XYZ = float3(0.2832,30.0,0.8775);   //Prey 2017 High Settings and <*
	else if(WP == 30)//WP 28
		WA_XYZ = float3(0.2832,35,0.91875);    //Prey 2017 Very High*
	else if(WP == 31)//WP 29
		WA_XYZ = float3(0,0,0);                //Game
	else if(WP == 32)//WP 30
		WA_XYZ = float3(0.4894,75.0,1.00375);  //Wolfenstein*
	else if(WP == 33)//WP 31
		WA_XYZ = float3(1.0,13.75,6.4);        //Wolfenstein: The New Order / The Old Blood
	else if(WP == 34)//WP 32
		WA_XYZ = float3(0,0,0);                //Wolfenstein II: The New Colossus / Cyberpilot
	else if(WP == 35)//WP 33
		WA_XYZ = float3(0.278,2.0,-12.0);      //Black Mesa
	else if(WP == 36)//WP 34
		WA_XYZ = float3(0.420,0.1,0.0);        //Blood 2
	else if(WP == 37)//WP 35
		WA_XYZ = float3(0.500,0.0625,18.75);   //Blood 2 Alt
	else if(WP == 38)//WP 36
		WA_XYZ = float3(0.785,0.0875,43.75);   //SOMA
	else if(WP == 39)//WP 37
		WA_XYZ = float3(0.445,0.500,0);        //Cryostasis
	else if(WP == 40)//WP 38
		WA_XYZ = float3(0.286,80.0,7.0);       //Unreal Gold with v227*	
	else if(WP == 41)//WP 39
		WA_XYZ = float3(0.280,1.125,-16.25);   //Serious Sam Revolution / Serious Sam HD: The First Encounter / The Second Encounter / Serious Sam 3: BFE?*
	else if(WP == 42)//WP 40
		WA_XYZ = float3(0.280,1.0,16.25);      //Serious Sam 2
	else if(WP == 43)//WP 41
		WA_XYZ = float3(0,0,0);                //Serious Sam 4: Planet Badass
	else if(WP == 44)//WP 42
		WA_XYZ = float3(0.277,0.875,-11.875);  //TitanFall 2
	else if(WP == 45)//WP 43
		WA_XYZ = float3(0.7,0.250,0);          //Project Warlock
	else if(WP == 46)//WP 44
		WA_XYZ = float3(0.625,0.275,-25.0);    //Kingpin Life of Crime
	else if(WP == 47)//WP 45
		WA_XYZ = float3(0,0,0);                //EuroTruckSim2
	else if(WP == 48)//WP 46
		WA_XYZ = float3(0.458,0.3375,0);       //F.E.A.R & F.E.A.R. 2: Project Origin
	else if(WP == 49)//WP 47
		WA_XYZ = float3(0,0,0);                //Game	
	else if(WP == 50)//WP 48
		WA_XYZ = float3(1.9375,0.5,40.0);      //Immortal Redneck
	else if(WP == 51)//WP 49
		WA_XYZ = float3(0,0,0);                //NecroVisioN
	else if(WP == 52)//WP 50
		WA_XYZ = float3(0.489,3.75,0);         //NecroVisioN: Lost Company
	//End Weapon Profiles//
	
	// Here on out is the Weapon Hand Adjustment code.		
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1.0, Near = 0.125/WA_XYZ.y;  //Division Depth Map Adjust - Near	
	float2 Offsets = float2(1 + WA_XYZ.z,1 - WA_XYZ.z), Z = float2( zBufferWH, 1-zBufferWH );
	
	if (WA_XYZ.z > 0)
	Z = min( 1, float2( Z.x * Offsets.x , Z.y / Offsets.y  ));

	[branch] if (Depth_Map == 0)//DM0. Normal
		zBufferWH = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBufferWH = Far * Near / (Far + Z.y * (Near - Far));	
	
	return float2(saturate(zBufferWH.x),WA_XYZ.x);	
}

float4 DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0) : SV_Target
{
		float4 DM = Depth(texcoord).xxxx;
		
		float R, G, B, A, WD = WeaponDepth(texcoord).x, CoP = WeaponDepth(texcoord).y, CutOFFCal = (CoP/DMA()) * 0.5f; //Weapon Cutoff Calculation
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
		
	return saturate(float4(R,G,B,A));
}
#if HUD_MODE
float4 HUD(float4 HUD, float2 texcoord ) 
{		
	float Mask_Tex, CutOFFCal = ((HUD_Adjust.x * 0.5)/DMA()) * 0.5, COC = step(Depth(texcoord).x,CutOFFCal); //HUD Cutoff Calculation
	
	//This code is for hud segregation.			
	if (HUD_Adjust.x > 0)
		HUD = COC > 0 ? tex2D(BackBuffer,texcoord) : HUD;	
		
#if UI_MASK	
    [branch] if (Mask_Cycle == true) 
        Mask_Tex = tex2D(SamplerMaskB,texcoord.xy).a;
    else
        Mask_Tex = tex2D(SamplerMaskA,texcoord.xy).a;

	float MAC = step(1.0f-Mask_Tex,0.5f); //Mask Adjustment Calculation
	//This code is for hud segregation.			
	HUD = MAC > 0 ? tex2D(BackBuffer,texcoord) : HUD;
#endif		
	return HUD;	
}
#endif
float AutoDepthRange( float d, float2 texcoord )
{
	float LumAdjust_ADR = smoothstep(-0.0175f,Auto_Depth_Range,Lum(texcoord).y);
    return min(1,( d - 0 ) / ( LumAdjust_ADR - 0));
}
#if RE_Fix
float AutoZPDRange(float ZPD, float2 texcoord )
{
	float LumAdjust_AZDPR = smoothstep(-0.0175f,0.125,Lum(texcoord).y); //Adjusted to only effect really intense differences.
    return saturate(LumAdjust_AZDPR * ZPD);
}
#endif
float WHConv(float D,float2 texcoord)
{
	float Z = WZPD, ZP = 0.5f,ALC = abs(Lum(texcoord).x) ,Convergence = 1 - Z / D;
	
	if (Z <= 0)
		ZP = 1;
		
	if (ALC <= 0.025f)
		ZP = 1;
	 
   return lerp(Convergence,D,ZP);
}

float Conv(float D,float2 texcoord)
{
	float Z = ZPD, ZP = 0.5f, ALC = abs(Lum(texcoord).x);
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
			ZP = 1.0;
					
    return lerp(Convergence,D, ZP);
}

float zBuffer(in float2 texcoord : TEXCOORD0)
{	
	float4 DM = tex2Dlod(SamplerDMN,float4(texcoord,0,0));
	
	if (WP == 0)
		DM.y = 0;
	
	DM.y = lerp(Conv(DM.x,texcoord), WHConv(DM.z,texcoord), DM.y);
		
	if (WZPD <= 0)
	DM.y = Conv(DM.x,texcoord);
	
	float ALC = abs(Lum(texcoord).x);
	
	if (Menu_Detection)
	{
		if (ALC <= 0.025f)
		DM = 0;
	}
		
	if (Cancel_Depth)
		DM = 0.0625f;

	return DM.y;
}
/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
// Horizontal parallax offset & Hole filling effect
float2 Parallax( float Diverge, float2 Coordinates)
{
	float Cal_Steps = Divergence + (Divergence * 0.04);
	
	//ParallaxSteps
	float Steps = clamp(Cal_Steps,0,255);
	
	// Offset per step progress & Limit
	float LayerDepth = 1.0 / Steps;

	//Offsets listed here Max Seperation is 3% - 8% of screen space with Depth Offsets & Netto layer offset change based on MS.
	float MS = Diverge * pix.x, deltaCoordinates = MS * LayerDepth;
	float2 ParallaxCoord = Coordinates,DB_Offset = float2((Diverge * 0.075f) * pix.x, 0);
	float CurrentDepthMapValue = zBuffer(ParallaxCoord), CurrentLayerDepth = 0, DepthDifference;

	[loop] //Steep parallax mapping
    for ( int i = 0; i < Steps; i++ )
    {	// Doing it this way should stop crashes in older version of reshade, I hope.
        if (CurrentDepthMapValue <= CurrentLayerDepth)
			break; // Once we hit the limit Stop Exit Loop.
        // Shift coordinates horizontally in linear fasion
        ParallaxCoord.x -= deltaCoordinates;
        // Get depth value at current coordinates
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
	
	return ParallaxCoord;
}
//Per is Perspective & Optimization for line interlaced Adjustment. 
#define Per float2( (Perspective * pix.x) * 0.5f, 0)
#define AI Interlace_Anaglyph.x * 0.5f

float4 EdgeMask( float Diverge, float4 Image, float2 texcoords)
{
	float Side_A = 0, Side_B = -1;
	
	if(Diverge > 0)
		{
			Side_A = -1;	 
			Side_B = 0;
		}
		
	float PA = Side_A+(BUFFER_WIDTH*pix.x), PB = Side_B+(BUFFER_WIDTH*pix.x), Y = BUFFER_HEIGHT*pix.y;
	float4 Bar_A = all( abs(float2( texcoords.x-PA, texcoords.y-Y)) < float2(Divergence * pix.x,1.0f));
	float4 Bar_B = all( abs(float2( texcoords.x-PB, texcoords.y-Y)) < float2(Divergence * pix.x,1.0f));
		
	return Bar_A + Bar_B ? float4(0,0,0,1) : Image;
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
	
	float4 color, Left = tex2Dlod(BackBufferBORDER, float4(Parallax(-D, TCL),0,0)), Right = tex2Dlod(BackBufferBORDER, float4(Parallax(D, TCR),0,0));
		
	if (Side_Bars)
	{
		Left = EdgeMask(-Divergence,Left,TCL);
		Right = EdgeMask(Divergence,Right,TCR);
	}
	#if HUD_MODE	
	float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25) * pix.x;
	Left = HUD(Left,float2(TCL.x - HUD_Adjustment,TCL.y));
	Right = HUD(Right,float2(TCR.x + HUD_Adjustment,TCR.y));
	#endif
	if(!Depth_Map_View)
	{
	float2 gridxy;

	[branch] if(Scaling_Support == 0)
		gridxy = floor(float2(TexCoords.x * BUFFER_WIDTH, TexCoords.y * BUFFER_HEIGHT)); //Native
	else if(Scaling_Support == 1)
		gridxy = floor(float2(TexCoords.x * 3840.0, TexCoords.y * 2160.0));	
	else if(Scaling_Support == 2)
		gridxy = floor(float2(TexCoords.x * 3841.0, TexCoords.y * 2161.0));
	else if(Scaling_Support == 3)
		gridxy = floor(float2(TexCoords.x * 1920.0, TexCoords.y * 1080.0));
	else if(Scaling_Support == 4)
		gridxy = floor(float2(TexCoords.x * 1921.0, TexCoords.y * 1081.0));
	else if(Scaling_Support == 5)
		gridxy = floor(float2(TexCoords.x * 1680.0, TexCoords.y * 1050.0));
	else if(Scaling_Support == 6)
		gridxy = floor(float2(TexCoords.x * 1681.0, TexCoords.y * 1051.0));
	else if(Scaling_Support == 7)
		gridxy = floor(float2(TexCoords.x * 1280.0, TexCoords.y * 720.0));
	else if(Scaling_Support == 8)
		gridxy = floor(float2(TexCoords.x * 1281.0, TexCoords.y * 721.0));
			
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
	}
	else
	{		
		color = float4(zBuffer(TexCoords).x,zBuffer(TexCoords).x,zBuffer(TexCoords).x,1.0);
	}
		
	float Average_Lum = tex2Dlod(SamplerDMN,float4(TexCoords.x,TexCoords.y, 0, 0)).w;
	
	return float4(color.rgb,Average_Lum);
}

float4 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 ABE = float4(0.0,1.0,0.0, 0.750);//Upper Extra Wide
		
	[branch] if(Auto_Balance_Ex == 2)
		ABE = float4(0.0,1.0,0.0, 0.5);//Upper Wide
	else if(Auto_Balance_Ex == 3)
		ABE = float4(0.0,1.0, 0.15625, 0.46875);//Upper Short
	else if(Auto_Balance_Ex == 4)
		ABE = float4(0.375, 0.250, 0.4375, 0.125);//Center Small
	else if(Auto_Balance_Ex == 5)
		ABE = float4(0.375, 0.250, 0.0, 1.0);//Center Long
			
	float Average_Lum_ZPD = tex2Dlod(SamplerDMN,float4(ABE.x + texcoord.x * ABE.y, ABE.z + texcoord.y * ABE.w, 0, 0)).w;
	float Average_Lum_Full = tex2Dlod(SamplerDMN,float4(texcoord.x,texcoord.y, 0, 0)).w;
	return float4(Average_Lum_ZPD,Average_Lum_Full,0,1);
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >; //Please do not remove.
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y;	
	float4 Color = float4(PS_calcLR(texcoord).rgb,1.0),D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
	[branch] if(timer <= 12500)
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

///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////
// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

//*Rendering passes*//

technique Cross_Cursor_Next
{			
			pass Cursor
		{
			VertexShader = PostProcessVS;
			PixelShader = MouseCursor;
		}	
}

technique SuperDepth3D_Next
{
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texDMN;
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
}