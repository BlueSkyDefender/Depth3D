 ////-----------------------------------------//
 ///**Polynomial Barrel Distortion for HMDs**///
 //-----------------------------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Barrel Distortion for HMD type Displays V2.0                  																													*//
 //* For Reshade 3.0+																																					    		*//
 //* --------------------------																																						*//
 //* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																								*//
 //* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																				*//
 //* I would also love to hear about a project you are using it with.																												*//
 //* https://creativecommons.org/licenses/by/3.0/us/																																*//
 //*																																												*//
 //* Have fun,																																										*//
 //* Jose Negrete AKA BlueSkyDefender																																				*//
 //*																																												*//
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				*//	
 //* ---------------------------------																																				*//
 //* Also thank you Zapal for your help with fixing a few things in this shader. 																									*//
 //* https://reshade.me/forum/shader-presentation/2128-3d-depth-map-based-stereoscopic-shader?start=900#21236																		*//
 //* 																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines Primary and Secondary Shader Toggle. This is used if you want pair this shader up with a other one of the same type.
// One = Primary;
// Zero = Secondary;
#define TOGGLE 1

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

uniform int Interpupillary_Distance <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = -100; ui_max = 100;
	ui_label = "Interpupillary Distance";
	ui_tooltip = "Determines the distance between your eyes.\n" 
				 "In Monoscopic mode it's x offset calibration.\n"
				 "Default is 0.";
	ui_category = "Eye Focus Adjustment";
> = 0;

uniform bool LD_IPD <
	ui_label = "Lens Dependent IPD";
	ui_tooltip = "Set Interpupillary Distance by Lens Postion instead of screen space postion.\n" 
				 "This is for HMD that can't move the internal Displays with the Lenses.";
	ui_category = "Eye Focus Adjustment";
> = false;

uniform int Stereoscopic_Mode_Convert <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0SbS to Alt-TnB\0TnB to Alt-TnB\0Monoscopic\0Checkerboard Reconstruction\0";
	ui_label = "3D Mode Conversions";
	ui_tooltip = "3D Mode Conversion for Head Mounted Displays.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform bool Checkerboard_Reconstruction_Compatibility <
	ui_label = "CBR Compatibility";
	ui_tooltip = "Use this to toggle Checkerboard Reconstruction Compatibility.\n"
				 "This can help with CBR issues.";
	ui_category = "Stereoscopic Options";
> = false;

uniform float3 Polynomial_Colors_K1 <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
	ui_tooltip = "Adjust the Polynomial Distortion K1_Red, K1_Green, & K1_Blue.\n"
				 "Default is (R 0.22, G 0.22, B 0.22)";
	ui_label = "Polynomial Color Distortion K1";
	ui_category = "Image Distortion Corrections";
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
	ui_category = "Image Distortion Corrections";
> = float3(0.24, 0.24, 0.24);

uniform bool Distortion_Aliment_Grid <
	ui_label = "Distortion Grid";
	ui_tooltip = "Use to this White & Black Grid for Distortion Correction.";
	ui_category = "Image Distortion Corrections";
> = false;


uniform float2 Zoom_Aspect_Ratio <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.5; ui_max = 2;
	ui_label = "Lens Zoom & Aspect Ratio";
	ui_tooltip = "Lens Zoom amd Aspect Ratio.\n" 
				 "Default is 1.0.";
	ui_category = "Image Adjustment";
> = float2(1.0,1.0);

uniform float Field_of_View <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 0.250;
	ui_label = "Field of View";
	ui_tooltip = "Lets you adjust the FoV of the Image.\n" 
				 "Default is 0.0.";
	ui_category = "Image Adjustment";
> = 0;

uniform float2 Degrees <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max =  360;
	ui_label = "Independent Rotation";
	ui_tooltip = "Left & Right Rotation Angle known as Degrees.\n"
				 "Default is Zero";
	ui_category = "Image Repositioning";
> = float2(0.0,0.0);

uniform int2 Independent_Vertical_Repositioning <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = -500; ui_max = 500;
	ui_label = "Independent Vertical Repositioning";
	ui_tooltip = "Please note if you have to use this, please aline and adjust your headset before you use this.\n"
				 "This tries to correct for Strabismus misalignment.\n"
				 "Determines the vertical L & R positioning.\n"
				 "Default is 0.";
	ui_category = "Image Repositioning";
> = int2(0,0);

uniform int2 Independent_Horizontal_Repositioning <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = -500; ui_max = 500;
	ui_label = "Independent Horizontal Repositioning";
	ui_tooltip = "Please note if you have to use this, please aline and adjust your headset before you use this.\n"
				 "This tries to correct for Strabismus misalignment.\n"
				 "Determines the vertical L & R positioning.\n"
				 "Default is 0.";
	ui_category = "Image Repositioning";
> = int2(0,0);

uniform bool Tied_H_V <
	ui_label = "Tied Horiz & Vert Repositioning";
	ui_tooltip = "Lets you control the Horizontal and Vertical with the first value only.\n"
				 "Default is On.";
	ui_category = "Image Repositioning";
> = true;

uniform int Vignette <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0; ui_max = 10;
	ui_label = "Vignette";
	ui_tooltip = "Soft edge effect around the image.";
	ui_category = "Image Effects";
> = false;

uniform int Blend_Mode <
	ui_type = "combo";
	ui_items = "None\0Lighten\0Darken\0";
	ui_label = "Sharpen Blending";
	ui_tooltip = "Blend Mode for UnSharp Mask Sharppening.";
	ui_category = "Image Effects";
> = 0;

uniform float Sharpen_Power <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Sharpen Power";
	ui_tooltip = "Adjust this on clear up the image the game, movie piture & ect.";
> = 0;

uniform bool Lens_Aliment_Marker <
	ui_label = "Lens Aliment Marker";
	ui_tooltip = "Use to this green Cross Marker for lens aliment.";
	ui_category = "Image Markers";
> = false;

uniform bool Image_Aliment_Marker <
	ui_label = "Image Aliment Marker";
	ui_tooltip = "Use to this green Cross Marker for image aliment.";
	ui_category = "Image Markers";
> = false;

uniform bool Diaspora <
	ui_label = "Diaspora Fix";
	ui_tooltip = "A small fix for the game Diaspora.";
	ui_category = "Internal Matix Correction.";
> = false;

//////////////////////////////////////////////////HMD Profiles//////////////////////////////////////////////////////////////////

uniform int HMD_Profiles <
	ui_type = "combo";
	ui_items = "Off\0Profile One\0Profile Two\0"; //Add your own Profile here.
	ui_label = "HMD Profiles";
	ui_tooltip = "Head Mounted Display Profiles.";
	ui_category = "Custom HMD Profiles.";
> = 0;

float4x4 HMDProfiles()
{
float Zoom = Zoom_Aspect_Ratio.x;
float Aspect_Ratio = Zoom_Aspect_Ratio.y;

float IPD = Interpupillary_Distance;
float FOV = Field_of_View;
float3 PC2 = Polynomial_Colors_K2;
float Z = Zoom;
float AR = Aspect_Ratio;
float3 PC1 = Polynomial_Colors_K1;
float2 D = Degrees;
float2 IVRPLR = Independent_Vertical_Repositioning;
float2 IHRPLR = Independent_Horizontal_Repositioning;
float4x4 Done;

	//Make your own Profile here.
	if (HMD_Profiles == 1)
	{
		IPD = 0.0;					//Interpupillary Distance. Default is 0
		FOV = 0.0;
		Z = 1.0;					//Zoom. Default is 1.0
		AR = 1.0;					//Aspect Ratio. Default is 1.0
		PC1 = float3(0.22,0.22,0.22);//Polynomial Colors K_1. Default is (Red 0.22, Green 0.22, Blue 0.22)
		PC2 = float3(0.24,0.24,0.24);//Polynomial Colors K_2. Default is (Red 0.24, Green 0.24, Blue 0.24)
		D = float2(0,0);			//Left & Right Rotation Angle known as Degrees.
		IVRPLR = float2(0,0);       //Independent Vertical Repositioning. Left & Right.
		IHRPLR = float2(0,0);       //Independent Horizontal Repositioning. Left & Right.
	}
	
	//Make your own Profile here.
	if (HMD_Profiles == 2)
	{
		IPD = 25.0;				//Interpupillary Distance.
		FOV = 0.0;
		Z = 1.0;					//Zoom. Default is 1.0
		AR = 0.925;					//Aspect Ratio. Default is 1.0
		PC1 = float3(0.22,0.22,0.22);//Polynomial Colors K_1. Default is (Red 0.22, Green 0.22, Blue 0.22)
		PC2 = float3(0.24,0.24,0.24);//Polynomial Colors K_2. Default is (Red 0.24, Green 0.24, Blue 0.24)
		D = float2(0,0);			//Left & Right Rotation Angle known as Degrees.
		IVRPLR = float2(0,0);       //Independent Vertical Repositioning. Left & Right.
		IHRPLR = float2(0,0);       //Independent Horizontal Repositioning. Left & Right.
	}

	//Rift Profile WIP
	if (HMD_Profiles == 3)
	{
		IPD = 27.25;				//Interpupillary Distance.
		FOV = 0.0;
		Z = 1.0;					//Zoom. Default is 1.0
		AR = 1.0;					//Aspect Ratio. Default is 1.0
		PC1 = float3(0.22,0.22,0.22);//Polynomial Colors K_1. Default is (Red 0.22, Green 0.22, Blue 0.22)
		PC2 = float3(0.24,0.24,0.24);//Polynomial Colors K_2. Default is (Red 0.24, Green 0.24, Blue 0.24)
		D = float2(0,0);			//Left & Right Rotation Angle known as Degrees.
		IVRPLR = float2(0,0);       //Independent Vertical Repositioning. Left & Right.
		IHRPLR = float2(0,0);       //Independent Horizontal Repositioning. Left & Right.
	}

	if(Diaspora)
	{
		Done = float4x4(float4(IPD,PC1.x,Z,IVRPLR.x),float4(PC2.x,PC1.y,AR,IVRPLR.y),float4(PC2.y,PC1.z,D.x,IHRPLR.x),float4(PC2.z,FOV,D.y,IHRPLR.y)); //Diaspora frak up 4x4 fix
	}
	else
	{
		Done = float4x4(float4(IPD,PC2.x,PC2.y,PC2.z),float4(PC1.x,PC1.y,PC1.z,FOV),float4(Z,AR,D.x,D.y),float4(IVRPLR.x,IVRPLR.y,IHRPLR.x,IHRPLR.y));
	}
	
return Done;
}

////////////////////////////////////////////////HMD Profiles End/////////////////////////////////////////////////////////////////

//Interpupillary Distance Section//
float IPDS()
{
	float IPDS = HMDProfiles()[0][0];
	return IPDS;
}

//Field of View//
float F_o_V()
{
	float F_o_V = HMDProfiles()[1][3];
	return F_o_V;
}

//Lens Zoom & Aspect Ratio Section//
float2 Z_A()
{
	float2 ZA = float2(HMDProfiles()[2][0],HMDProfiles()[2][1]);
	return ZA;
}

//Polynomial Colors Section//
float3 P_C_A()//K_1
{
	float3 PC = float3(HMDProfiles()[1][0],HMDProfiles()[1][1],HMDProfiles()[1][2]);
	return PC;
}

//Polynomial Colors Section//
float3 P_C_B()//K_2
{
	float3 PC = float3(HMDProfiles()[0][1],HMDProfiles()[0][2],HMDProfiles()[0][3]);
	return PC;
}

//Degrees Section//
float2 DEGREES()
{
	float2 Degrees = float2(HMDProfiles()[2][2],HMDProfiles()[2][3]);
	return Degrees;
}

//Independent Vertical Repositioning Section//
float2 IVRePosLR()
{
	float2 IVRePosLR = float2(HMDProfiles()[3][0],HMDProfiles()[3][1]);
	return IVRePosLR;
}

//Independent Horizontal Repositioning Section//
float2 IHRePosLR()
{
	float2 IHRePosLR = float2(HMDProfiles()[3][2],HMDProfiles()[3][3]);
	return IHRePosLR;
}

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define TextureSize float2(BUFFER_WIDTH, BUFFER_HEIGHT)

float fmod(float a, float b) 
{
	float c = frac(abs(a / b)) * abs(b);
	return a < 0 ? -c : c;
}

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
#if TOGGLE
texture texCLP  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture texCRP  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
#else
texture texCLS  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture texCRS  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
#endif
	
sampler SamplerCLBORDER
	{
		#if TOGGLE
		Texture = texCLP;
		#else
		Texture = texCLS;
		#endif
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
sampler SamplerCRBORDER
	{
		#if TOGGLE
		Texture = texCRP;
		#else
		Texture = texCRS;
		#endif
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
texture texCLR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; MipLevels = 2;}; 

sampler SamplerLR
	{
		Texture = texCLR;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};	
////////////////////////////////////////////////////Texture_Intercepter/////////////////////////////////////////////////////

float4 L(in float2 texcoord : TEXCOORD0)
{
	float2 gridxy = floor(float2(texcoord.x * BUFFER_WIDTH,texcoord.y * BUFFER_HEIGHT));
	return fmod(gridxy.x+gridxy.y,2.0) ? 0 : tex2D(BackBuffer, float2(texcoord.x,texcoord.y)) ;
}

float4 Bi_L(in float2 texcoord : TEXCOORD0)
{
	float4 tl = L(texcoord);
	float4 tr = L(texcoord +float2(pix.x, 0.0));
	float4 bl = L(texcoord +float2(0.0, pix.y));
	float4 br = L(texcoord +float2(pix.x, pix.y));
	float2 f = 0.5f;
	
	if(Checkerboard_Reconstruction_Compatibility)
		f = frac( texcoord * TextureSize);
   
	float4 tA = lerp( tl, tr, f.x );
	float4 tB = lerp( bl, br, f.x );
	return lerp( tA, tB, f.y ) * 2.0;//2.0 Gamma correction.
}

float4 R(in float2 texcoord : TEXCOORD0)
{
	float2 gridxy = floor(float2(texcoord.x * BUFFER_WIDTH,texcoord.y * BUFFER_HEIGHT));
	return fmod(gridxy.x+gridxy.y,2.0) ? tex2D(BackBuffer, float2(texcoord.x,texcoord.y)) : 0 ;
}

float4 Bi_R(in float2 texcoord : TEXCOORD0)
{
	float4 tl = R(texcoord);
	float4 tr = R(texcoord +float2(pix.x, 0.0));
	float4 bl = R(texcoord +float2(0.0, pix.y));
	float4 br = R(texcoord +float2(pix.x, pix.y));
	float2 f = 0.5f;
	
	if(Checkerboard_Reconstruction_Compatibility)
		f = frac( texcoord * TextureSize);
	
	float4 tA = lerp( tl, tr, f.x );
	float4 tB = lerp( bl, br, f.x );
	return lerp( tA, tB, f.y ) * 2.0;//2.0 Gamma correction.
}

float4 Grid_Lines(in float2 texcoords : TEXCOORD0)
{ 
    float4 Out;
    float2 UV = (texcoords - 0.5f) * 25.0f, xy = abs(frac(UV)); // adjust coords to visualize in a grid
    // Draw a black and white grid.
    Out = (xy.x > 0.9 || xy.y > 0.9) ? 1 : 0;

	return Out;	
}	

void LR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	
	float4 SBSL, SBSR;
	
	if(Stereoscopic_Mode_Convert == 0 || Stereoscopic_Mode_Convert == 2) //SbS
	{
		SBSL = tex2D(BackBuffer, float2(texcoord.x*0.5,texcoord.y));
		SBSR = tex2D(BackBuffer, float2(texcoord.x*0.5+0.5,texcoord.y));
	}
	else if(Stereoscopic_Mode_Convert == 1 || Stereoscopic_Mode_Convert == 3) //TnB
	{
		SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5));
		SBSR = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5+0.5));
	}
	else if(Stereoscopic_Mode_Convert == 4)
	{
		SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y)); //Monoscopic No stereo
	}
	else
	{	
		SBSL = Bi_L(texcoord);
		SBSR = Bi_R(texcoord);   
	}	

color = SBSL;
colorT = SBSR;
}

////////////////////////////////////////////////////Texture_Modifier/////////////////////////////////////////////////////
float4 Cross_Marker(in float2 texcoord : TEXCOORD0) //Cross Marker inside Left Image
{  
	// Compute anti-aliased world-space grid lines
	float2 grid = abs(frac(texcoord - 0.25) - 0.25) / fwidth(texcoord);
	float lines = min(grid.x, grid.y) * 0.5;
	float GLS = 1.0 - min(lines, 1.0);		
	return float4(GLS.xxx, 1.0);	
}	

float4 vignetteL(in float2 texcoord : TEXCOORD0)
{  
	float4 base;
	//Texture Rotation//
	//Converts the specified value from radians to degrees.
	float LD = radians(DEGREES().x);
	//Texture Position
	texcoord.y += IVRePosLR().x * pix.y;//Independent Vertical Repostion Left.
	texcoord.x += IHRePosLR().x * pix.x;//Independent Horizontal Repostion Left.		
	//Left
	float2 L_PivotPoint = float2(0.5,0.5);
    float2 L_Rotationtexcoord = texcoord;
    float L_sin_factor = sin(LD);
    float L_cos_factor = cos(LD);
    L_Rotationtexcoord = mul(L_Rotationtexcoord - L_PivotPoint, float2x2(float2(L_cos_factor, L_sin_factor), float2(-L_sin_factor, L_cos_factor)));
	L_Rotationtexcoord += L_PivotPoint;
	//Texture Zoom & Aspect Ratio//
	float X = Z_A().x;
	float Y = Z_A().y * Z_A().x * 2;
	float midW = (X - 1)*(BUFFER_WIDTH*0.5)*pix.x;	
	float midH = (Y - 1)*(BUFFER_HEIGHT*0.5)*pix.y;	
				
	texcoord = float2((L_Rotationtexcoord.x*X)-midW,(L_Rotationtexcoord.y*Y)-midH);	
	//Field of View
	float F = -F_o_V() + 1,HA = (F - 1)*(BUFFER_WIDTH*0.5)*pix.x;	
	
	texcoord.x = (texcoord.x*F)-HA;	
	//Normal HMDs IPD
	float IPDtexL = texcoord.x;	
	if (!LD_IPD) // https://developers.google.com/vr/jump/rendering-ods-content.pdf Page 10
		IPDtexL -= (IPDS()) * pix.x;// Left IPD
	//Texture Adjustment End//
	if (!Distortion_Aliment_Grid)
		base = tex2D(SamplerCLBORDER, float2(IPDtexL,texcoord.y));
	else
		base = Grid_Lines(float2(IPDtexL,texcoord.y));
	   	
	if( Image_Aliment_Marker )
	base = Cross_Marker(texcoord) ? float4(1.0,1.0,0.0,1) : base; //Yellow
	   
	texcoord = -texcoord * texcoord + texcoord;
	
	if( Vignette > 0)
	base.rgb *= saturate(texcoord.x * texcoord.y * pow(10-Vignette,3));
		
	return base;    
}

float4 vignetteR(in float2 texcoord : TEXCOORD0)
{  
float4 base;
	
	//Texture Rotation//
	//Converts the specified value from radians to degrees.
	float RD = radians(DEGREES().y), IVRR = IVRePosLR().y * pix.y, IHRR = IHRePosLR().y * pix.x;
	if (Tied_H_V) // only done on the right eye.
	{
		IVRR = IVRePosLR().x * pix.y;
		IHRR = IHRePosLR().x * pix.x;
		RD = radians(DEGREES().x);
	}
	//Texture Position	
	texcoord.y += IVRR;//Independent Vertical Repostion Right.
	texcoord.x += IHRR;//Independent Horizontal Repostion Right.
	//Right
	float2 R_PivotPoint = float2(0.5,0.5);
    float2 R_Rotationtexcoord = texcoord;
    float R_sin_factor = sin(RD);
    float R_cos_factor = cos(RD);
    R_Rotationtexcoord = mul(R_Rotationtexcoord - R_PivotPoint, float2x2(float2(R_cos_factor, R_sin_factor), float2(-R_sin_factor, R_cos_factor)));
	R_Rotationtexcoord += R_PivotPoint;
	//Texture Zoom & Aspect Ratio//
	float X = Z_A().x;
	float Y = Z_A().y * Z_A().x * 2;
	float midW = (X - 1)*(BUFFER_WIDTH*0.5)*pix.x;	
	float midH = (Y - 1)*(BUFFER_HEIGHT*0.5)*pix.y;	
				
	texcoord = float2((R_Rotationtexcoord.x*X)-midW,(R_Rotationtexcoord.y*Y)-midH);
	//Field of View
	float F = -F_o_V() + 1,HA = (F - 1)*(BUFFER_WIDTH*0.5)*pix.x;	
	
	texcoord.x = (texcoord.x*F)-HA;
	//Normal HMDs IPD
	float IPDtexR = texcoord.x;	
	if (!LD_IPD) // https://developers.google.com/vr/jump/rendering-ods-content.pdf Page 10
		IPDtexR += (IPDS()) * pix.x;// Left IPD
	//Texture Adjustment End//
	if (!Distortion_Aliment_Grid)
		base = tex2D(SamplerCRBORDER, float2(IPDtexR,texcoord.y));
	else
		base = Grid_Lines(float2(IPDtexR,texcoord.y));
	
	if( Image_Aliment_Marker )
	base = Cross_Marker(texcoord) ? float4(1.0,1.0,0.0,1) : base; //Yellow
	   
	texcoord = -texcoord * texcoord + texcoord;
	
	if( Vignette > 0)
	base.rgb *= saturate(texcoord.x * texcoord.y * pow(10-Vignette,3));

	return base;    
}

////////////////////////////////////////////////////Polynomial_Distortion/////////////////////////////////////////////////////

float2 D(float2 p, float k1, float k2) //Polynomial Lens Distortion Left & Right
{
	// https://github.com/sobotka/blender/blob/master/intern/libmv/libmv/simple_pipeline/distortion_models.h#L66
	float r2 = p.x * p.x + p.y * p.y;
	float r4 = r2 * r2;
	//use this if you want to add K3.
	//float r6 = r4 * r2;
	//float newRadius = (1.0 + k1*r2 + k2*r4 + k3*r6);
	float newRadius = (1.0 + k1*r2 + k2*r4);
	p.x = p.x * newRadius;
	p.y = p.y * newRadius;
	
	return p;
}

float4 PDL(float2 texcoord)		//Texture = texCL Left
{	
	float4 color;
	float2 uv_red, uv_green, uv_blue, sectorOrigin;
	float4 color_red, color_green, color_blue;
	float K1_Red = P_C_A().x, K1_Green = P_C_A().y, K1_Blue = P_C_A().z;
	float K2_Red = P_C_B().x, K2_Green = P_C_B().y, K2_Blue = P_C_B().z;
	// Radial distort around center
	sectorOrigin = 0.5;
	
	uv_red = D(texcoord.xy-sectorOrigin,K1_Red,K2_Red) + sectorOrigin;
	uv_green = D(texcoord.xy-sectorOrigin,K1_Green,K2_Green) + sectorOrigin;
	uv_blue = D(texcoord.xy-sectorOrigin,K1_Blue,K2_Blue) + sectorOrigin;
	
	color_red = vignetteL(uv_red).r;
	color_green = vignetteL(uv_green).g;
	color_blue = vignetteL(uv_blue).b;

	if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
	{
		color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
	}
	else
	{
		color = float4(0,0,0,1);
	}
		
	if( Lens_Aliment_Marker )
	color = Cross_Marker(texcoord) ? float4(0.0,1.0,0.0,1) : color; //Green
	
	return color;	
}
	
float4 PDR(float2 texcoord)		//Texture = texCR Right
{		
	float4 color;
	float2 uv_red, uv_green, uv_blue, sectorOrigin;
	float4 color_red, color_green, color_blue;
	float K1_Red = P_C_A().x, K1_Green = P_C_A().y, K1_Blue = P_C_A().z;
	float K2_Red = P_C_B().x, K2_Green = P_C_B().y, K2_Blue = P_C_B().z;

	// Radial distort around center
	sectorOrigin = 0.5;
	
	uv_red = D(texcoord.xy-sectorOrigin,K1_Red,K2_Red) + sectorOrigin;
	uv_green = D(texcoord.xy-sectorOrigin,K1_Green,K2_Green) + sectorOrigin;
	uv_blue = D(texcoord.xy-sectorOrigin,K1_Blue,K2_Blue) + sectorOrigin;

	color_red = vignetteR(uv_red).r;
	color_green = vignetteR(uv_green).g;
	color_blue = vignetteR(uv_blue).b;

	if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
	{
		color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
	}
	else
	{
		color = float4(0,0,0,1);
	}
	
	if( Lens_Aliment_Marker )
	color = Cross_Marker(texcoord) ? float4(0.0,1.0,0.0,1) : color; //Green
	
	return color;
		
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float4 PBD(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 Out;
	//For Cell HMDs
	float IPDtexL = texcoord.x, IPDtexR = texcoord.x;
 
	if (LD_IPD) // https://developers.google.com/vr/jump/rendering-ods-content.pdf Page 10
	{
		IPDtexL -= (IPDS() * 0.5) * pix.x;// Left IPD
		IPDtexR += (IPDS() * 0.5) * pix.x;// Right IPD
	}
		
	if( Stereoscopic_Mode_Convert == 0 || Stereoscopic_Mode_Convert == 1|| Stereoscopic_Mode_Convert == 5)
		Out = texcoord.x < 0.5 ? PDL(float2(IPDtexL*2,texcoord.y)) : PDR(float2(IPDtexR*2-1,texcoord.y));
	else if (Stereoscopic_Mode_Convert == 2 || Stereoscopic_Mode_Convert == 3 )
		Out = texcoord.y < 0.5 ? PDL(float2(IPDtexL,texcoord.y*2)) : PDR(float2(IPDtexR,texcoord.y*2-1));
	else if (Stereoscopic_Mode_Convert == 4 )
		Out = PDL(float2(IPDtexL ,texcoord.y));
	
	return Out;
}

float4 Combine(float4 a,float4 b)
{
	float4 COMB_OUT;
	if(Blend_Mode == 0)     // Pure	
		COMB_OUT = b;
	else if(Blend_Mode == 1)// Lighten
		COMB_OUT = max(a, b);
	else if(Blend_Mode == 2)// Darken
		COMB_OUT = min(a, b); 	
		
	return COMB_OUT;
}

float4 PBDOut(float2 texcoords : TEXCOORD0)
{	
	float4 result;
	if(Sharpen_Power)
	{
		result += tex2Dlod(SamplerLR, float4(texcoords + float2( 1, 0) * pix ,0,1));
		result += tex2Dlod(SamplerLR, float4(texcoords + float2(-1, 0) * pix ,0,1));
		result += tex2Dlod(SamplerLR, float4(texcoords + float2( 1, 1) * (pix * 0.75f) ,0,1));
		result += tex2Dlod(SamplerLR, float4(texcoords + float2(-1,-1) * (pix * 0.75f) ,0,1));
		result += tex2Dlod(SamplerLR, float4(texcoords + float2( 1,-1) * (pix * 0.75f) ,0,1));
		result += tex2Dlod(SamplerLR, float4(texcoords + float2(-1, 1) * (pix * 0.75f) ,0,1));
		result /= 6;
	}
	else
	{
		result = tex2Dlod(SamplerLR, float4(texcoords,0,0));
	}
	
	if(Sharpen_Power)
	{
		//UnsharpMask
		result = tex2Dlod(SamplerLR, float4(texcoords,0,0)) + (tex2Dlod(SamplerLR, float4(texcoords,0,0)) - result) * Sharpen_Power;
		//Blending
		result = Combine(tex2Dlod(SamplerLR, float4(texcoords,0,0)), result);
	}
	
	return result; 
}
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;

float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = PBDOut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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
#if TOGGLE
technique Polynomial_Barrel_Distortion_P
#else
technique Polynomial_Barrel_Distortion_S
#endif
{		
			pass StereoMonoPass
		{
			VertexShader = PostProcessVS;
			PixelShader = LR;
			#if TOGGLE
			RenderTarget0 = texCLP;
			RenderTarget1 = texCRP;
			#else
			RenderTarget0 = texCLS;
			RenderTarget1 = texCRS;
			#endif
		}
			pass Effects
		{
			VertexShader = PostProcessVS;
			PixelShader = PBD;
			RenderTarget = texCLR;

		}
			pass PBDout
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}