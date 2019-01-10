 ////------------- --//
 ///**SuperDepth3D**///
 //----------------////

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
 //* Original work was based on the shader code of a CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology								*//
 //*																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//USER EDITABLE PREPROCESSOR FUNCTIONS START//

// Determines The resolution of the Depth Map. For 4k Use 1.75 or 1.5. For 1440p Use 1.5 or 1.25. For 1080p use 1. Too low of a resolution will remove too much.
#define Depth_Map_Division 1.0

// Determines the Max Depth amount, in ReShades GUI.
#define Depth_Max 50

// Alternet Depth Buffer Adjust Toggle Key. The key "o" is Key Code 79. Ex. Key 79 is the code for o.
#define DB_TOGGLE 0 // You can use http://keycode.info/ to figure out what key is what.
#define Alt_Depth_Map_Adjust 0 // You can set this from 1.0 to 250.

// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key useing keycode info
// key "." is Key Code 110. Ex. Key 110 is the code for Decimal Point.
#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.

// 3D AO Toggle enable this if you want better 3D seperation between objects. 
// There will be a performance loss when enabled.
#define AO_TOGGLE 0 //Default 0 is Off. One is On.

// Use this to Disable or Enable Anti-Z-Fighting Modes for Weapon Hand.
#define WZF 0 //Default 0 is Off. One is On.

// Use Depth Tool to adjust the lower preprocessor definitions below.
// Horizontal & Vertical Depth Buffer Resize for non conforming BackBuffer.
// Ex. Resident Evil 7 Has this problem. So you want to adjust it too around float2(0.9575,0.9575).
#define Horizontal_and_Vertical float2(1.0, 1.0) // 1.0 is Default.

// Image Position Adjust is used to move the Z-Buffer around.
#define Image_Position_Adjust float2(0.0,0.0)

//Define Display aspect ratio for screen cursor. A 16:9 aspect ratio will equal (1.77:1)
#define DAR float2(1.76, 1.0)

//Screen Cursor to Screen Crosshair Lock
#define SCSC 0

//USER EDITABLE PREPROCESSOR FUNCTIONS END//

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

//Divergence & Convergence//
uniform float Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = Depth_Max; ui_step = 0.5;
	ui_label = "·Divergence Slider·";
	ui_tooltip = "Divergence increases differences between the left and right retinal images and allows you to experience depth.\n" 
				 "The process of deriving binocular depth information is called stereopsis.\n"
				 "You can override this value.";
	ui_category = "Divergence & Convergence";
> = 35.0;

uniform int Convergence_Mode <
	ui_type = "combo";
	ui_items = "ZPD Tied\0ZPD Locked\0";
	ui_label = " Convergence Mode";
	ui_tooltip = "Select your Convergence Mode for ZPD calculations.\n" 
				 "ZPD Locked mode is locked to divergence & dissables ZPD control below.\n" 
				 "ZPD Tied is controlled by ZPD. Works in tandam with Divergence.\n" 
				 "For FPS with no custom weapon profile use Tied.\n" 
				 "Default is ZPD Tied.";
	ui_category = "Divergence & Convergence";
> = 0;

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

uniform float Auto_Depth_Range <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.625;
	ui_label = " Auto Depth Range";
	ui_tooltip = "The Map Automaticly scales to outdoor and indoor areas.\n" 
				 "Default is 0.1f, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.1;
	
//Occlusion Masking//
uniform int Disocclusion_Selection <
	ui_type = "combo";
	ui_items = "Off\0Normal\0Radial\0Radial & Normal\0";
	ui_label = "·Disocclusion Selection·";
	ui_tooltip = "This is to select the z-Buffer blurring option for low level occlusion masking.\n"
				"Default is Off.";
	ui_category = "Occlusion Masking";
> = 0;

uniform float2 Disocclusion_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Disocclusion Adjust";
	ui_tooltip = "Automatic occlusion masking power & Mask Based culling adjustments.\n"
				 "Default is ( 0.250f, 0.250f)";
	ui_category = "Occlusion Masking";
> = float2( 0.250, 0.250 );

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "View Mode Normal\0View Mode Alpha\0View Mode Beta\0View Mode Gamma\0";
	ui_label = " View Mode";
	ui_tooltip = "Change the way the shader warps the output to the screen.\n"
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
//Heads-Up Display
uniform float2 HUD_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "·HUD Mode·";
	ui_tooltip = "Adjust HUD for your games.\n"
				 "X, CutOff Point used to set a seperation point bettwen world scale and the HUD also used to turn HUD MODE On or Off.\n"
				 "Y, Pushes or Pulls the HUD in or out of the screen if HUD MODE is on.\n"
	             "Default is float2(X 0.0, Y 0.5)";
	ui_category = "Heads-Up Display";
> = float2(0.0,0.5);

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

//3D Ambient Occlusion//
#if AO_TOGGLE
uniform bool AO <
	ui_label = "·3D AO Switch·";
	ui_tooltip = "3D Ambient occlusion mode switch.\n"
				 "Performance loss when enabled.\n"
				 "Default is On.";
	ui_category = "3D Ambient Occlusion";
> = 1;

uniform float AO_Control <
	ui_type = "drag";
	ui_min = 0.001; ui_max = 1.25;
	ui_label = " 3D AO Control";
	ui_tooltip = "Control the spread of the 3D AO.\n" 
				 "Default is 0.5625.";
	ui_category = "3D Ambient Occlusion";
> = 0.5625;

uniform float AO_Power <
	ui_type = "drag";
	ui_min = 0.001; ui_max = 0.100;
	ui_label = " 3D AO Power";
	ui_tooltip = "Adjust the power 3D AO.\n" 
				 "Default is 0.05.";
	ui_category = "3D Ambient Occlusion";
> = 0.05;
#endif
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

uniform bool Cancel_Depth < source = "key"; keycode = Cancel_Depth_Key; toggle = true; >;
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
	
texture texDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA16F; }; 

sampler SamplerDM
	{
		Texture = texDM;
	};
	
texture texDis  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA16F; MipLevels = 1;}; 

sampler SamplerDis
	{
		Texture = texDis;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
#if AO_TOGGLE	
texture texAO  { Width = BUFFER_WIDTH*0.5; Height = BUFFER_HEIGHT*0.5; Format = RGBA8; MipLevels = 1;}; 

sampler SamplerAO
	{
		Texture = texAO;
		MipLODBias = 1.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
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
texture texLum {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLum																
	{
		Texture = texLum;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
texture texLumWeapon {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256*0.5 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLumWeapon																
	{
		Texture = texLumWeapon;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
float2 Lum(in float2 texcoord : TEXCOORD0)
	{
		float2 Luminance = tex2Dlod(SamplerLum,float4(texcoord,0,0)).xy; //Average Luminance Texture Sample 

		return Luminance;
	}
	
float LumWeapon(in float2 texcoord : TEXCOORD0)
	{
		float Luminance = tex2Dlod(SamplerLumWeapon,float4(texcoord,0,0)).x; //Average Luminance Texture Sample 

		return Luminance;
	}
	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////
float Depth(in float2 texcoord : TEXCOORD0)
{	
	float2 texXY = texcoord + Image_Position_Adjust * pix;		
	float2 midHV = (Horizontal_and_Vertical-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
	texcoord = float2((texXY.x*Horizontal_and_Vertical.x)-midHV.x,(texXY.y*Horizontal_and_Vertical.y)-midHV.y);	
	
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBuffer = tex2D(DepthBuffer, texcoord).x, DMA = Depth_Map_Adjust; //Depth Buffer
	
	if(Depth_Adjust)
	DMA = Alt_Depth_Map_Adjust;
	
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1.0, Near = 0.125/DMA; //Division Depth Map Adjust - Near
	
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
		WA_XYZW = float4(0,0,0,0);                 //Game
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

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target)
{
		float4 DM = Depth(texcoord).xxxx;
		
		float DMA = Depth_Map_Adjust;
		
		if(Depth_Adjust)
		DMA = Alt_Depth_Map_Adjust;
		
		float R, G, B, A, WD = WeaponDepth(texcoord).x, CoP = WeaponDepth(texcoord).y, CutOFFCal = (CoP/DMA)/2; //Weapon Cutoff Calculation
		
		CutOFFCal = step(DM.x,CutOFFCal);
					
		if (WP == 0)
		{
			DM.x = DM.x;
		}
		else
		{
			DM.x = lerp(DM.x,WD,CutOFFCal);
		}
		
		R = DM.x; //Mix Depth
		G = DM.y; //Weapon Average Luminance
		B = DM.z; //Average Luminance
		A = DM.w; //Normal Depth
				
	Color = saturate(float4(R,G,B,A));
}

#if AO_TOGGLE
//3D AO START//
float AO_Depth(float2 coords)
{
	float DM = tex2Dlod(SamplerDM,float4(coords.xy,0,0)).x;
	return ( DM - 0 ) / ( AO_Control - 0);
}

float3 GetPosition(float2 coords)
{
	float3 DM = -AO_Depth(coords).xxx;
	return float3(coords.xy*2.0-1.0,1.0)*DM;
}

float2 GetRandom(float2 co)
{
	float random = frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453 );
	return float2(random,random);
}

float3 normal_from_depth(float2 texcoords) 
{
	float depth;
	const float2 offset1 = float2(10,pix.y);
	const float2 offset2 = float2(pix.x,10);
	  
	float depth1 = AO_Depth(texcoords + offset1).x;
	float depth2 = AO_Depth(texcoords + offset2).x;
	  
	float3 p1 = float3(offset1, depth1 - depth);
	float3 p2 = float3(offset2, depth2 - depth);
	  
	float3 normal = cross(p1, p2);
	normal.z = -normal.z;
	  
	return normalize(normal);
}

//Ambient Occlusion form factor
float aoFF(in float3 ddiff,in float3 cnorm, in float c1, in float c2)
{
	float3 vv = normalize(ddiff);
	float rd = length(ddiff);
	return (clamp(dot(normal_from_depth(float2(c1,c2)),-vv),-1,1.0)) * (1.0 - 1.0/sqrt(-0.001/(rd*rd) + 1000));
}

float4 GetAO( float2 texcoord )
{ 
    //current normal , position and random static texture.
    float3 normal = normal_from_depth(texcoord);
    float3 position = GetPosition(texcoord);
	float2 random = GetRandom(texcoord).xy;
    
    //initialize variables:
    float F = 0.750;
	float iter = 2.5*pix.x;
    float aout, num = 8;
    float incx = F*pix.x;
    float incy = F*pix.y;
    float width = incx;
    float height = incy;
    
    //Depth Map
    float depthM = AO_Depth(texcoord).x;
    	
	//2 iterations
	[loop]
    for(int i = 0; i<2; ++i) 
    {
       float npw = (width+iter*random.x)/depthM;
       float nph = (height+iter*random.y)/depthM;
       
		if(AO == 1)
		{
			float3 ddiff = GetPosition(texcoord.xy+float2(npw,nph))-position;
			float3 ddiff2 = GetPosition(texcoord.xy+float2(npw,-nph))-position;
			float3 ddiff3 = GetPosition(texcoord.xy+float2(-npw,nph))-position;
			float3 ddiff4 = GetPosition(texcoord.xy+float2(-npw,-nph))-position;

			aout += aoFF(ddiff,normal,npw,nph);
			aout += aoFF(ddiff2,normal,npw,-nph);
			aout += aoFF(ddiff3,normal,-npw,nph);
			aout += aoFF(ddiff4,normal,-npw,-nph);
		}
		
		//increase sampling area
		   width += incx;  
		   height += incy;	    
    } 
    aout/=num;

	//Luminance adjust used for overbright correction.
	float4 Done = min(1.0,aout);
	float OBC =  dot(Done.rgb,float3(0.2627, 0.6780, 0.0593)* 2);
	return smoothstep(0,1,float4(OBC,OBC,OBC,1));
}

void AO_in(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	color = GetAO(texcoord);
}

//AO END//
#endif

float4 HUD(float4 HUD, float2 texcoord ) 
{	
	float DMA = Depth_Map_Adjust;
		
	if(Depth_Adjust)
		DMA = Alt_Depth_Map_Adjust;
	
	float CutOFFCal = ((HUD_Adjust.x * 0.5)/DMA) * 0.5, COC = step(Depth(texcoord).x,CutOFFCal); //HUD Cutoff Calculation
	
	//This code is for hud segregation.			
	if (HUD_Adjust.x > 0)
		HUD = COC > 0 ? tex2D(BackBuffer,texcoord) : HUD;
					
	return HUD;	
}

float AutoDepthRange( float d, float2 texcoord )
{
	float LumAdjust = smoothstep(-0.0175f,Auto_Depth_Range,Lum(texcoord).y);
    return min(1,( d - 0 ) / ( LumAdjust - 0));
}

float Conv(float D,float2 texcoord)
{
	float Z = ZPD, ZP = 0.5f, Divergence_Locked = Divergence*0.001, MS = Divergence * pix.x, ALC = abs(Lum(texcoord).x);
		
		if (ZPD == 0)
			ZP = 1.0;
		
		if (Auto_Depth_Range > 0)
			D = AutoDepthRange(D,texcoord);
		
		if(Convergence_Mode)
			Z = Divergence_Locked;
				
		if(Auto_Balance_Ex > 0 )
			ZP = clamp(ALC,0.0f,1.0f);
				
		float Convergence = 1 - Z / D;
		
    return lerp(MS * Convergence, MS * D, ZP);
}

float zBuffer(in float2 texcoord : TEXCOORD0)
{	
	float DM = tex2Dlod(SamplerDM,float4(texcoord,0,0)).x;
	
	#if AO_TOGGLE
	float blursize = 2.0*pix.x,sum;
	if(AO == 1)
		{
			sum += tex2Dlod(SamplerAO, float4(texcoord.x - 4.0*blursize, texcoord.y,0,1)).x;
			sum += tex2Dlod(SamplerAO, float4(texcoord.x, texcoord.y - 3.0*blursize,0,1)).x;
			sum += tex2Dlod(SamplerAO, float4(texcoord.x - 2.0*blursize, texcoord.y,0,1)).x;
			sum += tex2Dlod(SamplerAO, float4(texcoord.x, texcoord.y - blursize,0,1)).x;
			sum += tex2Dlod(SamplerAO, float4(texcoord.x + blursize, texcoord.y,0,1)).x;
			sum += tex2Dlod(SamplerAO, float4(texcoord.x, texcoord.y + 2.0*blursize,0,1)).x;
			sum += tex2Dlod(SamplerAO, float4(texcoord.x + 3.0*blursize, texcoord.y,0,1)).x;
			sum += tex2Dlod(SamplerAO, float4(texcoord.x, texcoord.y + 4.0*blursize,0,1)).x;
			sum /= 8.0;
		}
	#endif
	
	#if AO_TOGGLE
	if(AO == 1)
		DM = lerp(DM, (DM+sum) * 0.5,AO_Power);
	#endif
	
	if (Cancel_Depth)
		DM = 0.5f;
		
	return DM;
}

void  Disocclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
	float DM, DMA, DMB, A, B, S, MS =  Divergence * pix.x, Div = 1.0f / 11.0f, DR = 1, DL = 1, N = 5, samples[5] = {0.5,0.625,0.75,0.875,1.0};
	float2 dirA, dirB;
	
	if ( Enable_Mask )
	{
		[loop]
		for ( int j = 0 ; j < N; j++ ) 
		{	
			DL = min(DL, tex2Dlod(SamplerDM,float4(texcoord.x + samples[j] * (MS * 0.5f), texcoord.y,0,0)).w );
			DR = min(DR, tex2Dlod(SamplerDM,float4(texcoord.x - samples[j] * (MS * 0.5f), texcoord.y,0,0)).w );
		}
	}
	
	float MA = (Disocclusion_Adjust.y * 25.0f), M = distance((DL+DR) * 0.5f, tex2Dlod(SamplerDM,float4(texcoord,0,0)).z), Mask = saturate(M * MA - 1.0f) > 0.0f;
	
	MS *= Disocclusion_Adjust.x * 2.0f;
		
	if ( Disocclusion_Selection == 1 ) // Normal    
	{
		A += 5.5; // Normal
		dirA = float2(0.5,0.0);
	}
	else if ( Disocclusion_Selection == 2 ) // Radial  
	{
		A += 16.0; // Radial
		dirA = 0.5 - texcoord;
	}
	else if ( Disocclusion_Selection == 3 ) // Radial & Normal  
	{
		A += 16.0; // Radial
		B += 5.5; // Normal
		dirA = 0.5 - texcoord;
		dirB = float2(0.5,0.0);
	}
		
	const float weight[11] = {0.0,0.010,-0.010,0.020,-0.020,0.030,-0.030,0.040,-0.040,0.050,-0.050}; //By 11
				
	if ( Disocclusion_Selection >= 1 && Disocclusion_Adjust.x > 0)
	{		
		[loop]
		for (int i = 0; i < 11; i++)
		{	
			S = weight[i] * MS;
			DMA += zBuffer(texcoord + dirA * S * A)*Div;
			
			if(Disocclusion_Selection == 3)
			{
				DMB += zBuffer(texcoord + dirB * S * B)*Div;
			}
			continue;
		}
				
		if ( Disocclusion_Selection == 3  )
		{	
			DM = lerp(DMA,DMB,0.1875f);
		}
		else
		{
			DM = DMA;
		}	
		
		if ( Enable_Mask && View_Mode == 0 )
			DM = lerp(lerp(zBuffer(texcoord), DM, abs(Mask)), DM, 0.625f );
		if ( Enable_Mask && View_Mode == 3 )
			DM = lerp(lerp(zBuffer(texcoord), DM, abs(Mask)), DM, 0.375f );
		if ( Enable_Mask && (View_Mode == 1 || View_Mode == 2) )
			DM = lerp(zBuffer(texcoord), DM, abs(Mask));	
	}
	else
	{
		DM = zBuffer(texcoord);
	}
	
	color = float4(DM,0.0,0.0,1.0);
}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
float Encode(in float2 texcoord : TEXCOORD0)
{
	return tex2Dlod(SamplerDis,float4(texcoord.x, texcoord.y,0,0)).x;
}

float4 PS_calcLR(float2 texcoord)
{
	float4 color, Right, Left, R, L;
	float2 TCL, TCR, TexCoords = texcoord;
	float DepthR = 1, DepthL = 1, LDepth, RDepth, DL, DR, N = 9, samplesA[9] = {0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1.0}, Adjust_A = 1 / N;;
							
	if(Eye_Swap)
	{
		if ( Stereoscopic_Mode == 0 )
		{
			TCL = float2(texcoord.x*2-1,texcoord.y);
			TCR = float2(texcoord.x*2,texcoord.y);
		}
		else if( Stereoscopic_Mode == 1)
		{
			TCL = float2(texcoord.x,texcoord.y*2-1);
			TCR = float2(texcoord.x,texcoord.y*2);
		}
		else
		{
			TCL = float2(texcoord.x,texcoord.y);
			TCR = float2(texcoord.x,texcoord.y);
		}
	}	
	else
	{
		if (Stereoscopic_Mode == 0)
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
	}
	
	//MS is Max Separation P is Perspective Adjustment
	float MS = Divergence * pix.x, P = Perspective * pix.x;
	
	TCL.x += P;
	TCR.x -= P;
	
	//Optimization for line & column interlaced out.
	if (Stereoscopic_Mode == 2)
	{
		TCL.y += (Interlace_Anaglyph.x*0.5) * pix.y;
		TCR.y -= (Interlace_Anaglyph.x*0.5) * pix.y;
	}
	else if (Stereoscopic_Mode == 3)
	{
		TCL.x += (Interlace_Anaglyph.x*0.5) * pix.x;
		TCR.x -= (Interlace_Anaglyph.x*0.5) * pix.x;
	}
							
	[loop]
	for ( int i = 0 ; i < N; i++ ) 
	{	
		float S = samplesA[i], MSM = MS + (Divergence * 0.0001);//Adjustment for range scaling.		
				
		if (View_Mode == 0)
		{
			DepthL = min(DepthL, Encode(float2(TCL.x + S * MSM, TCL.y)) );
			DepthR = min(DepthR, Encode(float2(TCR.x - S * MSM, TCR.y)) );
			continue;
		}
		else if (View_Mode == 1)
		{	
			LDepth = min(DepthL, Encode(float2(TCL.x + S * MSM, TCL.y)) );
			RDepth = min(DepthR, Encode(float2(TCR.x - S * MSM, TCR.y)) );
			
			DL = LDepth;
			DR = RDepth;
									
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.75f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.75f), TCR.y)) );
						
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.500f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.500f), TCR.y)) );
					
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.250f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.250f), TCR.y)) );
			
			DepthL = min(DepthL,LDepth / 4.0f);
			DepthR = min(DepthR,RDepth / 4.0f);
					
			DepthL = lerp(DepthL, DL, 0.1875f);
			DepthR = lerp(DepthR, DR, 0.1875f);			
			continue;
		}
		else if (View_Mode == 2)
		{			
			LDepth = min(DepthL, Encode(float2(TCL.x + S * MSM, TCL.y)) );
			RDepth = min(DepthR, Encode(float2(TCR.x - S * MSM, TCR.y)) );
			
			DL = LDepth;
			DR = RDepth;
						
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.9375f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.9375f), TCR.y)) );
						
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.6875f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.6875f), TCR.y)) );
			
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.500f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.500f), TCR.y)) );
		
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.4375f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.4375f), TCR.y)) );
			
			LDepth += min(DepthL, Encode(float2(TCL.x + S * (MSM * 0.1875f), TCL.y)) );
			RDepth += min(DepthR, Encode(float2(TCR.x - S * (MSM * 0.1875f), TCR.y)) );
								
			DepthL = min(DepthL,LDepth / 6.0f);
			DepthR = min(DepthR,RDepth / 6.0f);
			
			DepthL = lerp(DepthL, DL, 0.1875f);
			DepthR = lerp(DepthR, DR, 0.1875f);		
			continue;
		}
		else if (View_Mode == 3)
		{			
			LDepth += Encode(float2(TCL.x + S * (MSM * 1.2f), TCL.y))*Adjust_A;
			RDepth += Encode(float2(TCR.x - S * (MSM * 1.2f), TCR.y))*Adjust_A;
			DepthL = min(1,LDepth);
			DepthR = min(1,RDepth);	
			continue;
		}
	}
			
	float ReprojectionLeft = Conv(DepthL,TexCoords);//Zero Parallax Distance Pass Left
	float ReprojectionRight = Conv(DepthR,TexCoords);//Zero Parallax Distance Pass Right
	
	if(Custom_Sidebars == 0)
	{
		Left = tex2Dlod(BackBufferMIRROR, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
		Right = tex2Dlod(BackBufferMIRROR, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
	}
	else if(Custom_Sidebars == 1)
	{
		Left = tex2Dlod(BackBufferBORDER, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
		Right = tex2Dlod(BackBufferBORDER, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
	}
	else
	{
		Left = tex2Dlod(BackBufferCLAMP, float4(TCL.x + ReprojectionLeft, TCL.y,0,0));
		Right = tex2Dlod(BackBufferCLAMP, float4(TCR.x - ReprojectionRight, TCR.y,0,0));
	}
	
	L = Left; //Used for Eye Swap
	R = Right;//Used for Eye Swap
		
	if ( Eye_Swap ) //Is Eye Swap
	{
		Left = R;
		Right = L;
	}
	
	float HUD_Adjustment = ((0.5 - HUD_Adjust.y)*25) * pix.x;
	Left = HUD(Left,float2(TCL.x - HUD_Adjustment,TCL.y));
	Right = HUD(Right,float2(TCR.x + HUD_Adjustment,TCR.y));
			
	if(!Depth_Map_View)
	{
	float2 gridxy;

	if(Scaling_Support == 0)
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
			
		if(Stereoscopic_Mode == 0)
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
		float3 RGB = tex2Dlod(SamplerDis,float4(TexCoords.x, TexCoords.y,0,0)).xxx;

		color = float4(RGB.x,AutoDepthRange(RGB.y,TexCoords),RGB.z,1.0);
	}
		
	#if WZF		
	float WZF_A = WZF_Adjust, Average_Lum = (tex2D(SamplerDM,float2(TexCoords.x,TexCoords.y)).y - WZF_A) / ( 1 - WZF_A);
	#else
	float Average_Lum = tex2D(SamplerDM,float2(TexCoords.x,TexCoords.y)).y;
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
			
	float Average_Lum_ZPD = tex2D(SamplerDM,float2(ABE.x + texcoord.x * ABE.y, ABE.z + texcoord.y * ABE.w )).z;
	float Average_Lum_Full = tex2D(SamplerDM,float2(texcoord.x,texcoord.y )).z;
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
uniform float timer < source = "timer"; >; //Please do not remove.
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
{
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texDM;
	}
	#if AO_TOGGLE
		pass AmbientOcclusion
	{
		VertexShader = PostProcessVS;
		PixelShader = AO_in;
		RenderTarget = texAO;
	}
	#endif
		pass Disocclusion
	{
		VertexShader = PostProcessVS;
		PixelShader = Disocclusion;
		RenderTarget = texDis;
	}
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texLum;
	}
		pass AverageLuminanceWeapon
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance_Weapon;
		RenderTarget = texLumWeapon;
	}
		pass StereoOut
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
}