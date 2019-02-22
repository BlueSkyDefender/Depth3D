 ////--------------------------//
 ///**SuperDepth3D_FlashBack**///
 //--------------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v2.0.0          																														*//
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
 //* Original work was based on Shader Based on forum user 04348 and be located here http://reshade.me/forum/shader-presentation/1594-3d-anaglyph-red-cyan-shader-wip#15236			*//
 //*																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//USER EDITABLE PREPROCESSOR FUNCTIONS START//
// Determines the resolution of the Depth Map. Too low of a resolution will remove too much information. This will effect performance.
#define Depth_Map_Resolution 1.0 //1.0 is 100% | 0.50 is 50%

// Zero Parallax Distance Balance Mode allows you to switch control from manual to automatic and vice versa. You need to turn this on to use UI Masking options.
#define Balance_Mode 0 //Default 0 is Automatic. One is Manual.

// RE Fix is used to fix the issue with Resident Evil's 2 Remake 1-Shot cutscenes.
#define RE_Fix 0 //Default 0 is Off. One is On.

// Alternet Depth Buffer Adjust Toggle Key. The Key Code for "o" is Number 79.
#define DB_TOGGLE 0 // You can use http://keycode.info/ to figure out what key is what.
#define Alt_Depth_Map_Adjust 0 // You can set this from 1.0 to 250.

// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key useing keycode info
// The Key Code for Decimal Point is Number 110. Ex. for "." Cancel_Depth_Key 110
#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.

// Use this to Disable or Enable Anti-Z-Fighting Modes for Weapon Hand.
#define WZF 0 //Default 0 is Off. One is On.

// Use Depth Tool to adjust the lower preprocessor definitions below.
// Horizontal & Vertical Depth Buffer Resize for non conforming BackBuffer.
// Ex. Resident Evil 7 Has this problem. So you want to adjust it too around float2(0.9575,0.9575).
#define Horizontal_and_Vertical float2(1.0, 1.0) // 1.0 is Default.

// Image Position Adjust is used to move the Z-Buffer around.
#define Image_Position_Adjust float2(0.0,0.0)

// Define Display aspect ratio for screen cursor. A 16:9 aspect ratio will equal (1.77:1)
#define DAR float2(1.76, 1.0)

//Byte Shift for Debanding depth buffer in final 3D image. Incraments of 128.
#define Byte_Shift 256 //Ranges from 128 to 1024. Default is 256 

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
				 "You can override this value. But, increasing this reduces performance.";
	ui_category = "Divergence & Convergence";
> = 35.0;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.250;
	ui_label = " Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect also known as Convergence.\n"
				"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
				"This is controled by Convergence Mode.\n"
				"Default is 0.010, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.010;
				 
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
//Occlusion Masking//
uniform float2 Disocclusion_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Disocclusion Adjust";
	ui_tooltip = "Automatic occlusion masking power & Mask Based culling adjustments.\n"
				 "Default is ( 0.250f, 0.250f)";
	ui_category = "Occlusion Masking";
> = float2( 0.250, 0.250 );

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = " Edge Handling";
	ui_tooltip = "Edges selection for your screen output.";
	ui_category = "Occlusion Masking";
> = 1;

uniform bool Enable_Mask <
	ui_label = " Mask Toggle";
	ui_tooltip = "This enables the mask used for Occlusion Masking Culling.";
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
//Weapon Hand Adjust//
uniform int WP <
	ui_type = "combo";
	ui_items = "Weapon Profile Off\0Custom WP\0WP 0\0WP 1\0WP 2\0WP 3\0WP 4\0WP 5\0WP 6\0WP 7\0WP 8\0WP 9\0WP 10\0WP 11\0WP 12\0WP 13\0WP 14\0WP 15\0WP 16\0WP 17\0WP 18\0WP 19\0WP 20\0WP 21\0WP 22\0WP 23\0WP 24\0WP 25\0WP 26\0WP 27\0WP 28\0WP 29\0WP 30\0WP 31\0WP 32\0WP 33\0WP 34\0WP 35\0WP 36\0WP 37\0WP 38\0WP 39\0WP 40\0WP 41\0WP 42\0WP 43\0WP 44\0WP 45\0WP 46\0WP 47\0WP 48\0WP 49\0WP 50\0";
	ui_label = "·Weapon Profiles·";
	ui_tooltip = "Pick Weapon Profile for your game or make your own.";
	ui_category = "Weapon Hand Adjust";
> = 0;

uniform int Weapon_Scale <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = -3; ui_max = 3;
	ui_label = " Weapon Scale";
	ui_tooltip = "Use this to set the proper weapon hand scale.";
	ui_category = "Weapon Hand Adjust";
> = 0;

uniform float2 Weapon_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 25.0;
	ui_label = " Weapon Hand Adjust";
	ui_tooltip = "Adjust Weapon depth map for your games.\n"
				 "X, CutOff Point used to set a diffrent scale for first person hand apart from world scale.\n"
				 "Y, Precision is used to adjust the first person hand in world scale.\n"
	             "Default is float2(X 0.0, Y 0.0)";
	ui_category = "Weapon Hand Adjust";
> = float2(0.0,0.0);

uniform float Weapon_Depth_Adjust <
	ui_type = "drag";
	ui_min = -50.0; ui_max = 50.0; ui_step = 0.25;
	ui_label = " Weapon Depth Adjustment";
	ui_tooltip = "Pushes or Pulls the FPS Hand in or out of the screen if a weapon profile is selected.\n"
				 "This also used to fine tune the Weapon Hand if creating a weapon profile.\n" 
				 "Default is Zero.";
	ui_category = "Weapon Hand Adjust";
> = 0;

#if WZF
uniform int Anti_Z_Fighting <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 4;
	ui_label = "·Weapon Anti Z-Fighting Target·";
	ui_tooltip = "Anti Z-Fighting is use help prevent weapon hand Z-Fighting.\n"
				 "0 -> The Lower Half of the Screen.\n"
				 "1 -> The Center of the Screen Small.\n"
				 "2 -> The Center of the Screen Long.\n"
				 "3 -> Lower L-Half of the Screen.\n"
				 "4 -> Lower R-Half of the Screen.\n"
				 "Default is Two.";
	ui_category = "Weapon Anti Z-Fighting";
> = 2;

uniform float WZF_Adjust <
	ui_type = "drag";
	ui_min = 0; ui_max = 0.125;
	ui_label = " Weapon Anti Z-Fighting Adjust";
	ui_tooltip = "Use this to adjust the auto adjuster.\n"
				 "Default is Zero.";
	ui_category = "Weapon Anti Z-Fighting";
> = 0;
#endif
#if Balance_Mode
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
	ui_tooltip = "This controlls the Size, Thickness, & Transparency.\n" 
				 "Defaults are ( X 0.125, Y 0.5, Z 0.75 ).";
	ui_category = "Cursor Adjustments";
> = float3(0.125,0.5,0.75);

uniform float3 Cursor_Color <
	ui_type = "color";
	ui_label = " Cursor Color";
	ui_category = "Cursor Adjustments";
> = float3(1.0,1.0,1.0);

uniform bool SCSC <
	ui_label = " Cursor Lock";
	ui_tooltip = "Screen Cursor to Screen Crosshair Lock.";
	ui_category = "Cursor Adjustments";
> = false;

uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; >;
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
	
texture texDMFB_A  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT * Depth_Map_Resolution; Format = RGBA16F;}; 

sampler SamplerDMFB_A
	{
		Texture = texDMFB_A;
	};

texture texDMFB_B  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT * Depth_Map_Resolution; Format = RGBA16F;}; 

sampler SamplerDMFB_B
	{
		Texture = texDMFB_B;
	};
	
texture texDisFB  { Width = BUFFER_WIDTH * Depth_Map_Resolution; Height = BUFFER_HEIGHT * Depth_Map_Resolution; Format = RGBA16F;};

sampler SamplerDisFB
	{
		Texture = texDisFB;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
texture texEncodeFB_A  { Width = BUFFER_WIDTH * 0.5; Height = BUFFER_HEIGHT * 0.5; Format = RGBA16F; };

sampler SamplerEncodeFBA
	{
		Texture = texEncodeFB_A;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
texture texEncodeFB_B  { Width = BUFFER_WIDTH * 0.5; Height = BUFFER_HEIGHT * 0.5; Format = RGBA16F; };

sampler SamplerEncodeFBB
	{
		Texture = texEncodeFB_B;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
#if UI_MASK
texture TexMaskA < source = "Mask_A.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler SamplerMaskA { Texture = TexMaskA;};

texture TexMaskB < source = "Mask_B.png"; > { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler SamplerMaskB { Texture = TexMaskB;};
#endif	

uniform float2 Mousecoords < source = "mousepoint"; > ;	
////////////////////////////////////////////////////////////////////////////////////Cross Cursor////////////////////////////////////////////////////////////////////////////////////	
float4 MouseCursor(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
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
	
	if(Cursor_Type == 1)
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
	
	return lerp( Cursor  ? float4(Cursor_Color.rgb, 1.0) : tex2D(BackBuffer, texcoord),tex2D(BackBuffer, texcoord),1-Cursor_STT.z);
}

/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLumFB {Width = 256 * 0.5; Height = 256 * 0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumFB																
	{
		Texture = texLumFB;
		MipLODBias = 8; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
texture texLumWeaponFB {Width = 256 * 0.5; Height = 256 * 0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256*0.5 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumWeaponFB																
	{
		Texture = texLumWeaponFB;
		MipLODBias = 8; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
float2 Lum(in float2 texcoord : TEXCOORD0)
	{
		float2 Luminance = tex2Dlod(SamplerLumFB,float4(texcoord,0,0)).xy; //Average Luminance Texture Sample 

		return Luminance;
	}
	
float LumWeapon(in float2 texcoord : TEXCOORD0)
	{
		float Luminance = tex2Dlod(SamplerLumWeaponFB,float4(texcoord,0,0)).r; //Average Luminance Texture Sample 

		return Luminance;
	}
	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////
float4 PackDepth(in float depth) 
{
    depth *= (256.0*256.0*256.0 - 1.0) / (256.0*256.0*256.0);
    float4 encode = frac( depth * float4(1.0, 256.0, 256.0*256.0, 256.0*256.0*256.0) );
    return float4( encode.xyz - encode.yzw / 256.0, encode.w ) + 1.0/512.0;
}

float UnpackDepth(in float4 pack ) 
{
    float depth = dot( pack, 1.0 / float4(1.0, 256.0, 256.0*256.0, 256.0*256.0*256.0) );
    return depth * (256.0*256.0*256.0) / (256.0*256.0*256.0 - 1.0);
}

float DMA()//Depth Map Adjustment
{
	float DMA = Depth_Map_Adjust;	
	if(Depth_Adjust)
		DMA = Alt_Depth_Map_Adjust;

	return DMA;
}

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
	float Far = 1.0, Near = 0.125/DMA(); //Division Depth Map Adjust - Near
	
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
		
	float zBufferWH = tex2D(DepthBuffer, texcoord).x, CutOff = Weapon_Adjust.x , Adjust = Weapon_Adjust.y, Tune = Weapon_Depth_Adjust, Scale = Weapon_Scale;
	
	float4 WA_XYZW;//Weapon Profiles Starts Here
	if (WP == 1)                                   // WA_XYZW.x | WA_XYZW.y | WA_XYZW.z | WA_XYZW.w 
		WA_XYZW = float4(CutOff,Adjust,Tune,Scale);// X Cutoff  | Y Adjust  | Z Tuneing | W Scaling 		
	else if(WP == 2) //WP 0
		WA_XYZW = float4(0,0,0,0);                 //Game		
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
		WA_XYZW = float4(0.2712,25.0,0,1);         //Prey 2017 Very High*
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
	zBufferWH = (zBufferWH - 0) /  (WA - 0);
	
	//Auto Anti Weapon Depth Map Z-Fighting is always on.
	float WeaponLumAdjust = saturate(abs(smoothstep(0,0.5,LumWeapon(texcoord)*2.5)));	
			
	//Anti Weapon Hand Z-Fighting code trigger
	//if (WP > 1)
	zBufferWH = saturate(lerp(0.025, zBufferWH, saturate(WeaponLumAdjust)));
				
	return float2(zBufferWH.x,WA_XYZW.x);	
}

//Combined Depth
void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 ColorA : SV_Target0, out float4 ColorB : SV_Target1)
{	
		float4 DM = Depth(texcoord).xxxx;
		
		float R, G, B, A, WD = WeaponDepth(texcoord).x, CoP = WeaponDepth(texcoord).y, CutOFFCal = (CoP/DMA())/2; //Weapon Cutoff Calculation
		
		CutOFFCal = step(DM.x,CutOFFCal);
					
		if (WP == 0)
			DM.x = DM.x;
		else
			DM.x = lerp(DM.x,WD,CutOFFCal);
		
		R = DM.x; //Mix Depth
		G = DM.y; //Weapon Average Luminance
		B = DM.z; //Average Luminance
		A = DM.w; //Normal Depth
		
	ColorA = saturate(float4(R,G,B,A));
	ColorB = PackDepth(saturate(R));
}

#if Balance_Mode
float4 HUD(float4 HUD, float2 texcoord ) 
{			
	float Mask_Tex, CutOFFCal = ((HUD_Adjust.x * 0.5)/DMA()) * 0.5, COC = step(Depth(texcoord).x,CutOFFCal); //HUD Cutoff Calculation
	
	//This code is for hud segregation.			
	if (HUD_Adjust.x > 0)
		HUD = COC > 0 ? tex2D(BackBuffer,texcoord) : HUD;	
		
#if UI_MASK
    if (Mask_Cycle == true) 
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
	float LumAdjust = smoothstep(-0.0175f,Auto_Depth_Range,Lum(texcoord).y);
    return min(1,( d - 0 ) / ( LumAdjust - 0));
}
#if RE_Fix
float AutoZPDRange(float ZPD, float2 texcoord )
{
	float LumAdjust = smoothstep(-0.0175f,0.125,Lum(texcoord).y); //Adjusted to only effect really intense differences.
    return saturate(LumAdjust * ZPD);
}
#endif
float Conv(float DM,float2 texcoord)
{
	float Z = ZPD, ZP = 0.54875f, ALC = abs(Lum(texcoord).x);
	#if RE_Fix	
		Z = AutoZPDRange(Z,texcoord);
	#endif					
		if (Auto_Depth_Range > 0)
			DM = AutoDepthRange(DM,texcoord);
	#if Balance_Mode
			ZP = saturate(ZPD_Balance);			
	#else
		if(Auto_Balance_Ex > 0 )
			ZP = saturate(ALC);
	#endif					
		float Convergence = 1 - Z / DM;				
		
		if (ZPD == 0)
			ZP = 1.0f;
		
    return lerp(Convergence,DM, ZP);
}

float zBuffer(in float2 texcoord : TEXCOORD0)
{	
	float DM =  UnpackDepth(tex2Dlod(SamplerDMFB_B,float4(texcoord,0,0)));
		
	if (Cancel_Depth)
		DM = 0.5f;
		
	return DM;
}

void Disocclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
	float DM, Adj, MS =  Divergence * pix.x, DR = 1, DL = 1, N = 9, Div = 1.0f / N, weight[9] = {0.0f,0.0125f,-0.0125f,0.025f,-0.025f,0.0375f,-0.0375f,0.05f,-0.05f};
	
	float MA = (Disocclusion_Adjust.y * 8.0f), M = distance(1.0f , tex2D(SamplerDMFB_A,texcoord).w), Mask = saturate(M * MA - 1.0f) > 0.0f;
	
	Adj += 5.5f; // Normal
	float2 dir = float2(0.5f,0.0f);
	MS *= Disocclusion_Adjust.x * 4;
		
	if (Disocclusion_Adjust.x > 0) 
	{		
		[loop]
		for (int i = 0; i < N; i++)
		{	
			DM += zBuffer(float2(texcoord + dir * (weight[i] * MS) * Adj)).x * Div;
			continue;
		}

		if ( Enable_Mask )
		DM = lerp(lerp(zBuffer(texcoord), DM, abs(Mask)), DM, 0.625f );
	}
	else
	{
		DM = zBuffer(texcoord).x;
	}

	color = PackDepth(min(1.0f,DM));	
}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
void Encode(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color_X : SV_Target0, out float4 color_Y : SV_Target1) //zBuffer Color Channel Encode
{
	float N = 3, samples[3] = {0.5f,0.75f,1.0f};
	
	float DepthR = 1.0f, DepthL = 1.0f, MS = (-Divergence * pix.x) * 0.1f, MSL = (Divergence * pix.x) * 0.3f;
	
	[loop]
	for ( int i = 0 ; i < N; i++ ) 
	{
		DepthL = min(DepthL, UnpackDepth(tex2Dlod(SamplerDisFB, float4((texcoord.x - MS) - (samples[i] * MSL), texcoord.y,0,0))));
		DepthR = min(DepthR, UnpackDepth(tex2Dlod(SamplerDisFB, float4((texcoord.x + MS) + (samples[i] * MSL), texcoord.y,0,0))));
		continue;
	}	
	
	color_X = PackDepth(DepthL);
	color_Y = PackDepth(DepthR);
}

float4 Decode(in float2 texcoord : TEXCOORD0)
{
	//Byte Shift for Debanding depth buffer in final 3D image & Disocclusion Decoding.
	float ByteN = Byte_Shift, MS = Divergence * pix.x, X = texcoord.x + MS * Conv(UnpackDepth(tex2Dlod(SamplerEncodeFBA,float4(texcoord,0,0))),texcoord), Y = (1 - texcoord.x) + MS * Conv(UnpackDepth(tex2Dlod(SamplerEncodeFBB,float4(texcoord,0,0))),texcoord), Z = Conv(UnpackDepth(tex2Dlod(SamplerDisFB,float4(texcoord,0,0))),texcoord);
	float A = dot(X.xxx, float3(1.0f, 1.0f / ByteN, 1.0f / (ByteN * ByteN)) ); //byte_to_float Left
	float B = dot(Y.xxx, float3(1.0f, 1.0f / ByteN, 1.0f / (ByteN * ByteN)) ); //byte_to_float Right
	float C = dot(Z.xxx, float3(1.0f, 1.0f / ByteN, 1.0f / (ByteN * ByteN)) ); //byte_to_float ZPD L & R
	return float4(A,B,C,1.0);
}


float4 PS_calcLR(float2 texcoord)
{
	float2 TCL, TCR, TexCoords = texcoord;
	float4 color, Left, Right;
	
	//P is Perspective Adjustment.
	float L, R, RDepth, LDepth, MS = (Divergence * 0.5) * pix.x, P = Perspective * pix.x;
	
	if(Eye_Swap)
	{
		if ( Stereoscopic_Mode == 0 )
		{
			TCL = float2((texcoord.x*2-1) - P,texcoord.y);
			TCR = float2((texcoord.x*2) + P,texcoord.y);
		}
		else if( Stereoscopic_Mode == 1 )
		{
			TCL = float2(texcoord.x - P,texcoord.y*2-1);
			TCR = float2(texcoord.x + P,texcoord.y*2);
		}
		else
		{
			TCL = float2(texcoord.x - P,texcoord.y);
			TCR = float2(texcoord.x + P,texcoord.y);
		}
	}	
	else
	{
		if (Stereoscopic_Mode == 0)
		{
			TCL = float2((texcoord.x*2) + P,texcoord.y);
			TCR = float2((texcoord.x*2-1) - P,texcoord.y);
		}
		else if(Stereoscopic_Mode == 1)
		{
			TCL = float2(texcoord.x + P,texcoord.y*2);
			TCR = float2(texcoord.x - P,texcoord.y*2-1);
		}
		else
		{
			TCL = float2(texcoord.x + P,texcoord.y);
			TCR = float2(texcoord.x - P,texcoord.y);
		}
	}
	
	//Optimization for line & column interlaced out.
	if (Stereoscopic_Mode == 2)
	{
		TCL.y = TCL.y + ((Interlace_Anaglyph.x * 0.5f) * pix.y);
		TCR.y = TCR.y - ((Interlace_Anaglyph.x * 0.5f) * pix.y);
	}
	else if (Stereoscopic_Mode == 3)
	{
		TCL.x = TCL.x + ((Interlace_Anaglyph.x * 0.5f) * pix.x);
		TCR.x = TCR.x - ((Interlace_Anaglyph.x * 0.5f) * pix.x);
	}
			
	float CCL = 1, CCR = 1,N = 3, samplesA[3] = {0.5,0.75,1.0};
	[loop]
	for ( int j = 0 ; j < N; j++ ) 
	{	
		float S = samplesA[j];//Adjustment for range scaling.		

		CCL = MS *  min(CCL, Decode(float2(TCL.x + S * MS, TCL.y)).z);
		CCR = MS *  min(CCR, Decode(float2(TCR.x - S * MS, TCR.y)).z);
		continue;
	}
			
		if(Custom_Sidebars == 0)
		{
			Left = tex2Dlod(BackBufferMIRROR, float4(TCL.x + CCL, TCL.y,0,0));
			Right = tex2Dlod(BackBufferMIRROR, float4(TCR.x - CCR, TCR.y,0,0));
		}
		else if(Custom_Sidebars == 1)
		{
			Left = tex2Dlod(BackBufferBORDER, float4(TCL.x + CCL, TCL.y,0,0));
			Right = tex2Dlod(BackBufferBORDER, float4(TCR.x - CCR, TCR.y,0,0));
		}
		else
		{
			Left = tex2Dlod(BackBufferCLAMP, float4(TCL.x + CCL, TCL.y,0,0));
			Right = tex2Dlod(BackBufferCLAMP, float4(TCR.x - CCR, TCR.y,0,0));
		}
		
		[loop]
		for (int i = 0; i < Divergence + 7.5; i++) 
		{				
			//L
			if( Decode(float2(TCL.x+i*pix.x,TCL.y)).y >= (1-TCL.x)-pix.x && Decode(float2(TCL.x+i*pix.x,TCL.y)).y <= (1-TCL.x)+pix.x * 10 )
				{
					if(Custom_Sidebars == 0)
					{
						Left = tex2Dlod(BackBufferMIRROR, float4(TCL.x + i*pix.x, TCL.y,0,0));
					}
					else if(Custom_Sidebars == 1)
					{
						Left = tex2Dlod(BackBufferBORDER, float4(TCL.x + i*pix.x, TCL.y,0,0));
					}
					else
					{
						Left = tex2Dlod(BackBufferCLAMP, float4(TCL.x + i*pix.x, TCL.y,0,0));
					}
				}
			//R
			if( Decode(float2(TCR.x-i*pix.x,TCR.y)).x >= TCR.x-pix.x && Decode(float2(TCR.x-i*pix.x,TCR.y)).x <= TCR.x+pix.x * 10 )
				{
					if(Custom_Sidebars == 0)
					{
						Right = tex2Dlod(BackBufferMIRROR, float4(TCR.x - i*pix.x, TCR.y,0,0));
					}
					else if(Custom_Sidebars == 1)
					{
						Right = tex2Dlod(BackBufferBORDER, float4(TCR.x - i*pix.x, TCR.y,0,0));
					}
					else
					{
						Right = tex2Dlod(BackBufferCLAMP, float4(TCR.x - i*pix.x, TCR.y,0,0));
					}
				}
		}
				
	float4 cL = Left,cR = Right; //Left Image & Right Image
			
	if (Eye_Swap)
	{
		cL = Right;
		cR = Left;	
	}
	#if Balance_Mode	
	float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25) * pix.x;
	cL = HUD(cL,float2(TCL.x - HUD_Adjustment,TCL.y));
	cR = HUD(cR,float2(TCR.x + HUD_Adjustment,TCR.y));
	#endif	
	if(!Depth_Map_View)
	{	
	float2 gridxy;

	if(Scaling_Support == 0)
		gridxy = floor(float2(TexCoords.x * BUFFER_WIDTH, TexCoords.y * BUFFER_HEIGHT)); //Native
	else if(Scaling_Support == 1)
		gridxy = floor(float2(TexCoords.x * 3840.0f, TexCoords.y * 2160.0f));	
	else if(Scaling_Support == 2)
		gridxy = floor(float2(TexCoords.x * 3841.0f, TexCoords.y * 2161.0f));
	else if(Scaling_Support == 3)
		gridxy = floor(float2(TexCoords.x * 1920.0f, TexCoords.y * 1080.0f));
	else if(Scaling_Support == 4)
		gridxy = floor(float2(TexCoords.x * 1921.0f, TexCoords.y * 1081.0f));
	else if(Scaling_Support == 5)
		gridxy = floor(float2(TexCoords.x * 1680.0f, TexCoords.y * 1050.0f));
	else if(Scaling_Support == 6)
		gridxy = floor(float2(TexCoords.x * 1681.0f, TexCoords.y * 1051.0f));
	else if(Scaling_Support == 7)
		gridxy = floor(float2(TexCoords.x * 1280.0f, TexCoords.y * 720.0f));
	else if(Scaling_Support == 8)
		gridxy = floor(float2(TexCoords.x * 1281.0f, TexCoords.y * 721.0f));
			
		if(Stereoscopic_Mode == 0)
		{	
			color = TexCoords.x < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 1)
		{	
			color = TexCoords.y < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 2)
		{
			color = fmod(gridxy.y,2.0) ? cR : cL;	
		}
		else if(Stereoscopic_Mode == 3)
		{
			color = fmod(gridxy.x,2.0) ? cR : cL;		
		}
		else if(Stereoscopic_Mode == 4)
		{
			color = fmod(gridxy.x+gridxy.y,2.0) ? cR : cL;
		}
		else if(Stereoscopic_Mode >= 5)
		{			
			float Contrast = 1.0f, Deghost = 0.06f, LOne, LTwo, ROne, RTwo;
			float3 HalfLA = dot(cL.rgb,float3(0.299f, 0.587f, 0.114f));
			float3 HalfRA = dot(cR.rgb,float3(0.299f, 0.587f, 0.114f));
			float3 LMA = lerp(HalfLA,cL.rgb,Interlace_Anaglyph.y);  
			float3 RMA = lerp(HalfRA,cR.rgb,Interlace_Anaglyph.y); 
			float4 image = 1, accumRC, accumGM, accumBA;

			float contrast = (Contrast * 0.5f) + 0.5f, deghost = Deghost;
				
			// Left/Right Image
			float4 cA = float4(LMA,1.0f);
			float4 cB = float4(RMA,1.0f);
	
			if (Stereoscopic_Mode == 5) // Anaglyph 3D Colors Red/Cyan
			{
				float4 LeftEyecolor = float4(1.0,0.0,0.0,1.0);
				float4 RightEyecolor = float4(0.0,1.0,1.0,1.0);
				
				color =  (cA*LeftEyecolor) + (cB*RightEyecolor);
			}
			else if (Stereoscopic_Mode == 6) // Anaglyph 3D Dubois Red/Cyan
			{
			float red = 0.437f * cA.r + 0.449f * cA.g + 0.164f * cA.b
						- 0.011f * cB.r - 0.032f * cB.g - 0.007f * cB.b;
				
				if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

				float green = -0.062f * cA.r -0.062f * cA.g -0.024f * cA.b 
							+ 0.377f * cB.r + 0.761f * cB.g + 0.009f * cB.b;
				
				if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

				float blue = -0.048f * cA.r - 0.050f * cA.g - 0.017f * cA.b 
							-0.026f * cB.r -0.093f * cB.g + 1.234f  * cB.b;
				
				if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }

				color = float4(red, green, blue, 1.0);
			}
			else if (Stereoscopic_Mode == 7) // Anaglyph 3D Deghosted Red/Cyan Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
			{
				LOne = contrast * 0.45f;
				LTwo = (1.0f - LOne) * 0.5f;
				ROne = contrast;
				RTwo = 1.0f - ROne;
				deghost = Deghost* 0.1f;

				accumRC = saturate(cA*float4(LOne,LTwo,LTwo, 1.0f));
				image.r = pow(accumRC.r+accumRC.g+accumRC.b, 1.0f);
				image.a = accumRC.a;

				accumRC = saturate(cB*float4(RTwo,ROne,0.0, 1.0f));
				image.g = pow(accumRC.r+accumRC.g+accumRC.b, 1.15f);
				image.a = image.a+accumRC.a;

				accumRC = saturate(cB*float4(RTwo,0.0,ROne, 1.0f));
				image.b = pow(accumRC.r+accumRC.g+accumRC.b, 1.15f);
				image.a = (image.a+accumRC.a) / 3.0f;

				accumRC = image;
				image.r = (accumRC.r+(accumRC.r*(deghost))+(accumRC.g*(deghost * -0.5f))+(accumRC.b*(deghost * -0.5f)));
				image.g = (accumRC.g+(accumRC.r*(deghost * -0.25f))+(accumRC.g*(deghost * 0.5f))+(accumRC.b*(deghost * -0.25f)));
				image.b = (accumRC.b+(accumRC.r*(deghost * -0.25f))+(accumRC.g*(deghost * -0.25f))+(accumRC.b*(deghost * 0.5f)));
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
								
				float red = -0.062f * cA.r -0.158f * cA.g -0.039f * cA.b
						+ 0.529f * cB.r + 0.705f * cB.g + 0.024f * cB.b;
				
				if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

				float green = 0.284f * cA.r + 0.668f * cA.g + 0.143f * cA.b 
							- 0.016f * cB.r - 0.015f * cB.g + 0.065f * cB.b;
				
				if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

				float blue = -0.015f * cA.r -0.027f * cA.g + 0.021f * cA.b 
							+ 0.009f * cB.r + 0.075f * cB.g + 0.937f  * cB.b;
				
				if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
						
				color = float4(red, green, blue, 1.0);
			}
			else if (Stereoscopic_Mode == 10)// Anaglyph 3D Deghosted Green/Magenta Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
			{
				LOne = contrast * 0.45f;
				LTwo = (1.0-LOne) * 0.5f;
				ROne = contrast * 0.8f;
				RTwo = 1.0-ROne;
				deghost = Deghost * 0.275f;

				accumGM = saturate(cB*float4(ROne,RTwo,0.0f, 1.0f));
				image.r = pow(accumGM.r+accumGM.g+accumGM.b, 1.15f);
				image.a = accumGM.a;

				accumGM = saturate(cA*float4(LTwo,LOne,LTwo,1.0));
				image.g = pow(accumGM.r+accumGM.g+accumGM.b, 1.05);
				image.a = image.a+accumGM.a;

				accumGM = saturate(cB*float4(0.0,RTwo,ROne, 1.0f));
				image.b = pow(accumGM.r+accumGM.g+accumGM.b, 1.15f);
				image.a = (image.a+accumGM.a) / 3.0f;

				accumGM = image;
				image.r = (accumGM.r+(accumGM.r*(deghost * 0.5f))+(accumGM.g*(deghost * -0.25f))+(accumGM.b*(deghost * -0.25f)));
				image.g = (accumGM.g+(accumGM.r*(deghost * -0.5f))+(accumGM.g*(deghost * 0.25f))+(accumGM.b*(deghost * -0.5f)));
				image.b = (accumGM.b+(accumGM.r*(deghost * -0.25f))+(accumGM.g*(deghost * -0.25f))+(accumGM.b*(deghost * 0.5f)));
				color = image;
			}
			else if (Stereoscopic_Mode == 11) // Anaglyph 3D Blue/Amber Code From http://iaian7.com/quartz/AnaglyphCompositing & vectorform.com by John Einselen
			{
				LOne = contrast * 0.45f;
				LTwo = ( 1.0f -LOne) * 0.5f;
				ROne = contrast;
				RTwo = 1.0f - ROne;
				deghost = Deghost * 0.275f;

				accumBA = saturate(cA*float4(ROne, 0.0f,RTwo, 1.0f));
				image.r = pow(accumBA.r+accumBA.g+accumBA.b, 1.05f);
				image.a = accumBA.a;

				accumBA = saturate(cA*float4(0.0f,ROne,RTwo, 1.0f));
				image.g = pow(accumBA.r+accumBA.g+accumBA.b, 1.10f);
				image.a = image.a+accumBA.a;

				accumBA = saturate(cB*float4(LTwo,LTwo,LOne, 1.0f));
				image.b = pow(accumBA.r+accumBA.g+accumBA.b, 1.0f);
				image.b = lerp(pow(image.b,(Deghost * 0.15f) + 1.0f),1.0f - pow(abs(1.0f - image.b),(Deghost * 0.15f) + 1.0f),image.b);
				image.a = (image.a+accumBA.a) / 3.0f;

				accumBA = image;
				image.r = (accumBA.r+(accumBA.r*(deghost * 1.5f))+(accumBA.g*(deghost * -0.75f))+(accumBA.b*(deghost * -0.75f)));
				image.g = (accumBA.g+(accumBA.r*(deghost * -0.75f))+(accumBA.g*(deghost * 1.5f))+(accumBA.b*(deghost * -0.75f)));
				image.b = (accumBA.b+(accumBA.r*(deghost * -1.5f))+(accumBA.g*(deghost * -1.5f))+(accumBA.b*(deghost * 3.0f)));
				color = saturate(image);
			}
		}
	}
		else
	{			
		float3 RGB = UnpackDepth(tex2Dlod(SamplerDisFB,float4(TexCoords.x, TexCoords.y,0,0))).xxx;

		color = float4(RGB.x,AutoDepthRange(RGB.y,TexCoords),RGB.z,1.0);
	}
		
	#if WZF		
	float WZF_A = WZF_Adjust, Average_Lum = (tex2D(SamplerDMFB_A,float2(TexCoords.x,TexCoords.y)).y - WZF_A) / ( 1 - WZF_A);
	#else
	float Average_Lum = tex2D(SamplerDMFB_A,float2(TexCoords.x,TexCoords.y)).y;
	#endif
	return float4(color.rgb,Average_Lum);
}

float4 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 ABE = float4(0.0,1.0,0.0, 0.750);//Upper Extra Wide
		
	if(Auto_Balance_Ex == 2)
		ABE = float4(0.0,1.0,0.0, 0.5);//Upper Wide
	else if(Auto_Balance_Ex == 3)
		ABE = float4(0.0,1.0, 0.15625, 0.46875);//Upper Short
	else if(Auto_Balance_Ex == 4)
		ABE = float4(0.375, 0.250, 0.4375, 0.125);//Center Small
	else if(Auto_Balance_Ex == 5)
		ABE = float4(0.375, 0.250, 0.0, 1.0);//Center Long
			
	float Average_Lum_ZPD = tex2D(SamplerDMFB_A,float2(ABE.x + texcoord.x * ABE.y, ABE.z + texcoord.y * ABE.w )).z;
	float Average_Lum_Full = tex2D(SamplerDMFB_A,float2(texcoord.x,texcoord.y )).z;
	return float4(Average_Lum_ZPD,Average_Lum_Full,0,1);
}

float4 Average_Luminance_Weapon(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 AZF = float4(0.500, 0.500,0.0,1.0);//Lower Half
	#if WZF
	if ( Anti_Z_Fighting == 1)
		AZF = float4(0.4375, 0.125,0.375,0.250);//Center Small
	else if ( Anti_Z_Fighting == 2)
		AZF = float4(0.0, 1.0, 0.375,0.250);//Center Long
	else if ( Anti_Z_Fighting == 3)
		AZF = float4(0.5, 0.5, 0.0, 0.5);//Lower Left
	else if ( Anti_Z_Fighting == 4)
		AZF = float4(0.5, 0.5, 0.5, 0.5);//Lower Right
	#endif
	float3 Average_Lum_Weapon = PS_calcLR(float2(AZF.z + texcoord.x * AZF.w,AZF.x + texcoord.y * AZF.y )).www;
	return float4(Average_Lum_Weapon,1);
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = float4(PS_calcLR(texcoord).rgb,1),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
	if(timer <= 10000)
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
	float4 OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.682));
	float4 TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.682));
	float4 ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
	P = (OneP-TwoP) + ThreeP;

	//T
	float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
	float4 OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
	float4 TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
	T = OneT+TwoT;
	
	//H
	float PosXH = -0.0071+PosX;
	float4 OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
	float4 TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
	float4 ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.003,0.009));
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
	}
	
	Website = D+E+P+T+H+Three+DD+Dot+I+N+F+O ? float4(1.0,1.0,1.0,1) : Color;
	
	if(timer >= 10000)
	{
		Done = Color;
	}
	else
	{
		Done = Website;
	}

	return Done;
}

///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////
// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0f : 0.0f;
	texcoord.y = (id == 1) ? 2.0f : 0.0f;
	position = float4(texcoord * float2(2.0f, -2.0f) + float2(-1.0f, 1.0f), 0.0f, 1.0f);
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

technique SuperDepth3D_FlashBack
{
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget0 = texDMFB_A;
		RenderTarget1 = texDMFB_B;
	}
		pass Disocclusion
	{
		VertexShader = PostProcessVS;
		PixelShader = Disocclusion;
		RenderTarget = texDisFB;
	}
		pass Encoding
	{
		VertexShader = PostProcessVS;
		PixelShader = Encode;
		RenderTarget0 = texEncodeFB_A;
		RenderTarget1 = texEncodeFB_B;
	}
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLumFB;
	}
		pass AverageLuminanceWeapon
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance_Weapon;
		RenderTarget = texLumWeaponFB;
	}
		pass StereoOut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
}