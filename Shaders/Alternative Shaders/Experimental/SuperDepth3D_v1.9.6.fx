 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.6  																																*//
 //* For Reshade 3.0																																								*//
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
 //*																																												*//
 //* Original work was based on the shader code of a CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology								*//
 //* 																																												*//
 //* AO Work was based on the shader code of a Devmaster Dev																														*//
 //* code was take from http://forum.devmaster.net/t/disk-to-disk-ssao/17414																										*//
 //* arkano22 Disk to Disk AO GLSL code adapted to be used to add more detail to the Depth Map.																						*//
 //* http://forum.devmaster.net/users/arkano22/																																		*//
 //*																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The size of the Depth Map. For 4k Use 2 or 2.5. For 1440p Use 1.5 or 2. For 1080p use 1.
#define Depth_Map_Division 1.0

//uniform float2 TEST <
	//ui_type = "drag";
	//ui_min = -2; ui_max = 2;
	//ui_label = "TEST";
	//ui_tooltip = "Determines the TEST. Default is X 0 and Y 1.250";
//> = float2(0,1);

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 50.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map for your games.";
> = 7.5;

uniform int Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = 35;
	ui_label = "Divergence Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.";
> = 15;
uniform int Near_Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 3;
	ui_label = "Near Depth Adjustment";
	ui_tooltip = "Determines the amount of depth near the cam, zero is off. Default is 1.";
> = 1;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0;

uniform bool Dis_Occlusion <
	ui_label = "Disocclusion Mask";
	ui_tooltip = "Automatic occlusion masking switch.";
> = 0;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map.";
> = false;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset";
> = 0.5;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform int Weapon_Depth_Map <
	ui_type = "combo";
	ui_items = "Weapon DM Off\0Custom WDM One\0Custom WDM Two\0Weapon DM 1\0Weapon DM 2\0Weapon DM 3\0Weapon DM 4\0Weapon DM 5\0Weapon DM 6\0";
	ui_label = "Weapon Depth Map";
	ui_tooltip = "Pick your weapon depth map for games.";
> = 0;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = -10.0; ui_max = 10.0;
	ui_label = "Weapon Adjust Depth Map";
	ui_tooltip = "Adjust weapon depth map. Default is (Y 0, X 0.010, Z 1.001)";
> = float3(0.010,1.00,1.00);

uniform float Weapon_Cutoff <
	ui_type = "drag";
	ui_min = -1; ui_max = 1;
	ui_label = "Weapon Cutoff Point";
	ui_tooltip = "For adjusting the cutoff of the weapon Depth Map.";
> = 0.10;

uniform bool Weapon_Auto_Adjust <
	ui_label = "Weapon Auto Adjust";
	ui_tooltip = "Turn on to combat weapon Z-Fighting. May not work 100% of the time.";
> = false;

uniform bool Weapon_Depth_Map_Invert <
	ui_label = "Invert Weapon Depth Map";
	ui_tooltip = "To invert the Weapon Depth Map if it is reverse.";
> = false;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Edges selection for your screen output.";
> = 1;

uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Checkerboard 3D\0Anaglyph\0";
	ui_label = "3D Display Mode";
	ui_tooltip = "Stereoscopic 3D display output selection.";
> = 0;

uniform int Downscaling_Support <
	ui_type = "combo";
	ui_items = "Native\0Option One\0Option Two\0";
	ui_label = "Downscaling Support";
	ui_tooltip = "Dynamic Super Resolution & Virtual Super Resolution downscaling support for Line Interlaced & Checkerboard 3D displays.";
> = 0;

uniform int Anaglyph_Colors <
	ui_type = "combo";
	ui_items = "Red/Cyan\0Dubois Red/Cyan\0Green/Magenta\0Dubois Green/Magenta\0";
	ui_label = "Anaglyph Color Mode";
	ui_tooltip = "Select colors for your 3D anaglyph glasses.";
> = 0;

uniform float Anaglyph_Desaturation <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Anaglyph Desaturation";
	ui_tooltip = "Adjust anaglyph desaturation, Zero is Black & White, One is full color.";
> = 1.0;

uniform bool Eye_Swap <
	ui_label = "Swap Eyes";
	ui_tooltip = "L/R to R/L.";
> = false;

uniform bool AO <
	ui_label = "3D AO Mode";
	ui_tooltip = "3D ambient occlusion mode switch. Default is On.";
> = 1;

uniform float Power <
	ui_type = "drag";
	ui_min = 0.25; ui_max = 1.25;
	ui_label = "AO Power";
	ui_tooltip = "Ambient occlusion power on the depth map. Default is 0.75";
> = 0.75;

uniform float Falloff <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2.5;
	ui_label = "AO Falloff";
	ui_tooltip = "Ambient occlusion falloff. Default is 1.5";
> = 1.5;

uniform float AO_Shift <
	ui_type = "drag";
	ui_min = 0; ui_max = 0.750;
	ui_label = "AO Shift";
	ui_tooltip = "Determines the Shift from White to Black. Default is 0.250";
> = 0.250;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

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
	
texture texDM  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F;}; 

sampler SamplerDM
	{
		Texture = texDM;
	};
	
texture texDis  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F;}; 

sampler SamplerDis
	{
		Texture = texDis;
	};
	
texture texAO  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA32F;}; 

sampler SamplerAO
	{
		Texture = texAO;
	};

uniform float frametime < source = "frametime"; >;
/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLum  {Width = 256/2; Height = 256/2; Format = RGBA8; MipLevels = 8;};//Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				//if there is a better way of doing this please tell
sampler SamplerLum																//256 / 2^8 = 1
	{
		Texture = texLum;
		MipLODBias = 8.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};

float AL()
{
float AdjustScale = 2;
    
    //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
	float4 Luminance = tex2Dlod(SamplerLum,float4(0.5,0.5,0,0));//Average
    
    //Frametime Perceptual Effects 
    float FPE  = (Luminance) * (AdjustScale - exp(-frametime));
    
    return saturate(FPE);
}

/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0)
{
	 float4 color;

			if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
	float4 depthM = tex2D(DepthBuffer, texcoord);
	float4 MDepth;
	float4 WDepth = tex2D(DepthBuffer, texcoord);
	float4 WDM;
	float4 WDone;
	
		//Conversions to linear space.....
		//Near & Far Adjustment
		float DDA = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float DA = Depth_Map_Adjust*2; //Depth Map Adjust - Near
		//All 1.0f are Far Adjustment
		
		//0. DirectX Custom Constant Far
		float DirectX = 2.0 * DDA * 1.0f / (1.0f + DDA - depthM.r * (1.0f - DDA));
		
		//1. DirectX Alternative
		float DirectXAlt = pow(abs(depthM.r - 1.0),DA);
		
		//2. OpenGL
		float OpenGL = 2.0 * DDA * 1.0f / (1.0f + DDA - (2.0 * depthM.r - 1.0) * (1.0f - DDA));
		
		//3. OpenGL Reverse
		float OpenGLRev = 2.0 * 1.0f * DDA / (DDA + 1.0f - (2.0 * depthM.r - 1.0) * (DDA - 1.0f));
		
		//4. Raw Buffer
		float Raw = pow(abs(depthM.r),DA);
		
		//5. Special Depth Map
		float Special = pow(abs(exp(depthM.r)*Offset),(DA*25));
		
		if (Depth_Map == 0)
		{
		depthM = DirectX;
		}
		
		else if (Depth_Map == 1)
		{
		depthM = DirectXAlt;
		}

		else if (Depth_Map == 2)
		{
		depthM = OpenGL;
		}
		
		else if (Depth_Map == 3)
		{
		depthM = OpenGLRev;
		}
		
		else if (Depth_Map == 4)
		{
		depthM = lerp(DirectXAlt,OpenGLRev,0.5);
		}
		
		else if (Depth_Map == 5)
		{
		depthM = lerp(Raw,DirectX,0.5);
		}

		else if (Depth_Map == 6)
		{
		depthM = Raw;
		}
		
		else if (Depth_Map == 7)
		{
		depthM = lerp(DirectX,OpenGL,0.5);
		}
		
		else if (Depth_Map == 8)
		{
		depthM = lerp(Raw,OpenGL,0.5);
		}		
		
		else if (Depth_Map == 9)
		{
		//depthM = SpecialTwo;
		}
		
		else if (Depth_Map == 10)
		{
		depthM = Special;
		}
		
		MDepth = depthM;		
		
		//Weapon Depth Map
		
		if(Weapon_Depth_Map == 1 || Weapon_Depth_Map == 3 || Weapon_Depth_Map == 5 || Weapon_Depth_Map == 7 || Weapon_Depth_Map == 8)
		{
		float constantF = 1.0;	
		float constantN = 0.01;
		WDM = 2.0 * constantN * constantF / (constantF + constantN - (2.0 * WDepth.r - 1.0) * (constantF - constantN));
		}
		if(Weapon_Depth_Map == 2 || Weapon_Depth_Map == 4 || Weapon_Depth_Map == 6 )
		{
		WDM = pow(abs(WDepth.r - 1.0),10);
 		}
 		
		//Set Weapon Depth Map settings for the section below.//
		float cWF;
		float cWN;
		float cWP;
		
		if (Weapon_Depth_Map == 1)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		if (Weapon_Depth_Map == 2)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		//Game: Borderlands 2 
		//Weapon Depth Map One
		if (Weapon_Depth_Map == 3)
		{
		cWF = 0.010;
		cWN = -7.500;
		cWP = 0.875;
		}
		
		//Game: Call of Duty: Black Ops 
		//Weapon Depth Map Two
		if (Weapon_Depth_Map == 4)
		{
		cWF = 0.853;
		cWN = 1.500;
		cWP = 1.0003;
		}
		
		//Game: Call of Duty: Games 
		//Weapon Depth Map Three
		if (Weapon_Depth_Map == 5)
		{
		cWF = 0.390;
		cWN = 5;
		cWP = 1.002;
		}
		
		if (Weapon_Depth_Map == 6)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		if (Weapon_Depth_Map == 7)
		{
		cWF = 0.015;
		cWN = -87.500;
		cWP = 0.750;
		}
		
		if (Weapon_Depth_Map == 8)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.900;
		}
		//SWDMS Done//
 		
		//Scaled Section z-Buffer
		float Adj;
		if (Weapon_Depth_Map >= 1)
		{
		cWN /= 1000;
		WDone = (cWN * WDM) / ((cWP*WDM)-(cWF));
		}
		
		if(Weapon_Auto_Adjust == 1)
		WDone = WDone*AL();
		
		WDone = smoothstep(0.0,1.250,WDone);
		
		if (Weapon_Depth_Map_Invert)
			WDone = 1 - WDone;	
			
		Adj = 1.0;//Replaced with Weapon_Cutoff Still used as a base.
			
		float NearDepth = step(WDM.r,Adj);
		float4 D;
		
		float Cutoff = step(MDepth.r,Weapon_Cutoff);
		float4 DM;
			
		if (Weapon_Depth_Map <= 0)
		{
		DM = MDepth;
		}
		else
		{
		D = lerp(depthM,WDone,NearDepth);
		DM = lerp(MDepth,D,Cutoff);
		}
			
		//Weapon Depth Map end//
    
	color.rgb = saturate(DM.rrr); //clamped
	
	Color = color;	
}

/////////////////////////////////////////////////////AO/////////////////////////////////////////////////////////////

float3 GetPosition(float2 coords)
{
	return float3(coords.xy*2.5-1.0,10.0)*tex2D(SamplerDM,coords.xy).rgb;
}

float3 GetRandom(float2 co)
{
	float random = frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453 * 1);
	return float3(random,random,random);
}

float3 normal_from_depth(float2 texcoords) 
{
	float depth;
	const float2 offset1 = float2(-10,10);
	const float2 offset2 = float2(10,10);
	  
	float depth1 = tex2D(SamplerDM, texcoords + offset1).r;
	float depth2 = tex2D(SamplerDM, texcoords + offset2).r;
	  
	float3 p1 = float3(offset1, depth1 - depth);
	float3 p2 = float3(offset2, depth2 - depth);
	  
	float3 normal = cross(p1, p2);
	normal.z = -normal.z;
	  
	return normalize(normal);
}

//Ambient Occlusion form factor
float aoFF(in float3 ddiff,in float3 cnorm, in float c1, in float c2)
{
	float S = 1-AO_Shift;
	float3 vv = normalize(ddiff);
	float rd = length(ddiff);
	return (S-clamp(dot(normal_from_depth(float2(c1,c2)),-vv),-1,1.0)) * clamp(dot( cnorm,vv ),1.075,1.0)* (1.0 - 1.0/sqrt(-0.001/(rd*rd) + 1000));
}

float4 GetAO( float2 texcoord )
{ 
    //current normal , position and random static texture.
    float3 normal = normal_from_depth(texcoord);
    float3 position = GetPosition(texcoord);
	float2 random = GetRandom(texcoord).xy;
    
    //initialize variables:
    float F = Falloff;
	float iter = 2.5*pix.x;
    float ao;
    float incx = F*pix.x;
    float incy = F*pix.y;
    float width = incx;
    float height = incy;
    float num;
    
    //Depth Map
    float depthM = tex2D(SamplerDM, texcoord).r;
    
		
	//Depth Map linearization
	float constantF = 1.0;	
	float constantN = 0.250;
	depthM = saturate(2.0 * constantN * constantF / (constantF + constantN - (2.0 * depthM.r - 1.0) * (constantF - constantN)));
    
	//2 iterations 
    for(float i=0.0; i<2; ++i) 
    {
       float npw = (width+iter*random.x)/depthM;
       float nph = (height+iter*random.y)/depthM;
       
		if(AO == 1)
		{
			float3 ddiff = GetPosition(texcoord.xy+float2(npw,nph))-position;
			float3 ddiff2 = GetPosition(texcoord.xy+float2(npw,-nph))-position;
			float3 ddiff3 = GetPosition(texcoord.xy+float2(-npw,nph))-position;
			float3 ddiff4 = GetPosition(texcoord.xy+float2(-npw,-nph))-position;

			ao+=  aoFF(ddiff,normal,npw,nph);
			ao+=  aoFF(ddiff2,normal,npw,-nph);
			ao+=  aoFF(ddiff3,normal,-npw,nph);
			ao+=  aoFF(ddiff4,normal,-npw,-nph);
			num = 8;
		}
		
		//increase sampling area
		   width += incx;  
		   height += incy;		    
    } 
    ao/=num;

	//Luminance adjust used for overbright correction.
	float4 Done = min(1.0,ao);
	float3 lumcoeff = float3(0.299,0.587,0.114);
	float lum = dot(Done.rgb, lumcoeff);
	float3 luminance = float3(lum, lum, lum);
  
    return float4(luminance,1);
}

void AO_in(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	color = GetAO(texcoord);
}

void  Disocclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0, out float4 Ave : SV_Target1)
{
//bilateral blur\/
float4 Done;
float4 sum;
float P = Power/10;

float blursize = 2.0*pix.x;

sum += tex2D(SamplerAO, float2(texcoord.x - 4.0*blursize, texcoord.y)) * 0.05;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y - 3.0*blursize)) * 0.09;
sum += tex2D(SamplerAO, float2(texcoord.x - 2.0*blursize, texcoord.y)) * 0.12;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y - blursize)) * 0.15;
sum += tex2D(SamplerAO, float2(texcoord.x + blursize, texcoord.y)) * 0.15;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y + 2.0*blursize)) * 0.12;
sum += tex2D(SamplerAO, float2(texcoord.x + 3.0*blursize, texcoord.y)) * 0.09;
sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y + 4.0*blursize)) * 0.05;

Done = 1-sum;
//bilateral blur/\

float DP =  Divergence;
	
 float Disocclusion_Power = DP/350;
 float4 DM;                                                                                                                                                                                                                                                                                               	
 float2 dir;
 float B;
 int Con = 10;
	
	if(Dis_Occlusion == 1) 
	{
	
	const float weight[10] = { 0.01,-0.01,0.02,-0.02,0.03,-0.03,0.04,-0.04,0.05,-0.05};

	dir = float2(0.5,0);
	B = Disocclusion_Power;

	
	dir = normalize( dir ); 
	 
	[loop]
	for (int i = 0; i < Con; i++)
	{
		if(Dis_Occlusion == 1) 
		{
		DM += tex2D(SamplerDM,texcoord + dir * weight[i] * B)/Con;
		}
	}
	
	}
	else
	{
	DM = tex2D(SamplerDM,texcoord);
	}		                          

	color = lerp(DM,Done,P);
	Ave = DM;
}

void Average_Luminance(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	color = tex2D(SamplerDM,texcoord);
}
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////

void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	float samples[4] = {0.50, 0.66, 0.85, 1.0};
	float DepthL = 1, DepthR = 1, MS , P, S, MaxTP, CalNear;
	float2 uv = 0;
	
	if(!Eye_Swap)
		{	
			P = Perspective * pix.x;
			MS = Divergence * pix.x;
		}
		else
		{
			P = -Perspective * pix.x;
			MS = -Divergence * pix.x;
		}
	
	[loop]
	for (int j = 0; j < 4; ++j) 
	{	
		uv.x = samples[j] * MS;
		
		if(Stereoscopic_Mode == 0)
		{	
			DepthL =  min(DepthL,tex2D(SamplerDis,float2((texcoord.x*2 + P)+uv.x, texcoord.y)).r);
			DepthR =  min(DepthR,tex2D(SamplerDis,float2((texcoord.x*2-1 - P)-uv.x, texcoord.y)).r);
		}
		else if(Stereoscopic_Mode == 1)
		{
			DepthL =  min(DepthL,tex2D(SamplerDis,float2((texcoord.x + P)+uv.x, texcoord.y*2)).r);
			DepthR =  min(DepthR,tex2D(SamplerDis,float2((texcoord.x - P)-uv.x, texcoord.y*2-1)).r);
		}
		else
		{
			DepthL =  min(DepthL,tex2D(SamplerDis,float2((texcoord.x + P)+uv.x, texcoord.y)).r);
			DepthR =  min(DepthR,tex2D(SamplerDis,float2((texcoord.x - P)-uv.x, texcoord.y)).r);
		}
	}
	
	if(Near_Depth == 1)
	{
	CalNear = 3.5/Divergence;//Near Depth auto Cal.
	}
	else if(Near_Depth == 2)
	{
	CalNear = 5.25/Divergence;//Near Depth auto x1.5 Cal.
	}
	else if(Near_Depth == 3)
	{
	CalNear = 7.0/Divergence;//Near Depth auto x2 Cal.
	}
	else
	{
	CalNear = 0;//Near Depth Off.
	}
	
	MaxTP = Divergence * 0.03;//Max 3% of Divergence.
	float PL = saturate(1-(MaxTP *(1-0.350/DepthL)));//ZPD is hard set 0.350 for now.
	float PR = saturate(1-(MaxTP *(1-0.350/DepthR)));//ZPD is hard set 0.350 for now.
	float ReprojectionLeft = lerp(DepthL * MS, PL * MS,-CalNear);
	float ReprojectionRight = lerp(DepthR * MS,PR * MS,-CalNear);
	
	if(!Depth_Map_View)
	{
		if(Stereoscopic_Mode == 0)
		{
			if(Custom_Sidebars == 0)
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x*2 + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferMIRROR, float2((texcoord.x*2-1 - P) - ReprojectionRight, texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x*2 + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x*2-1 - P) - ReprojectionRight, texcoord.y));
			}
			else
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x*2 + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x*2-1 - P) - ReprojectionRight, texcoord.y));
			}
		}
		else if(Stereoscopic_Mode == 1)
		{	
			if(Custom_Sidebars == 0)
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y*2)) : tex2D(BackBufferMIRROR, float2((texcoord.x - P) - ReprojectionRight, texcoord.y*2-1));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y*2)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - ReprojectionRight, texcoord.y*2-1));
			}
			else
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y*2)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - ReprojectionRight, texcoord.y*2-1));
			}
		}
		else if(Stereoscopic_Mode == 2)
		{
			float gridL;
			
			if(Downscaling_Support == 0)
			{
			gridL = frac(texcoord.y*(BUFFER_HEIGHT/2));
			}
			else if(Downscaling_Support == 1)
			{
			gridL = frac(texcoord.y*(1080.0/2));
			}
			else
			{
			gridL = frac(texcoord.y*(1081.0/2));
			}
			
			if(Custom_Sidebars == 0)
			{
			color = gridL > 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) :  tex2D(BackBufferMIRROR, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = gridL > 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else
			{
			color = gridL > 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
		}
		else if(Stereoscopic_Mode == 3)
		{
			float gridy;
			float gridx;
			
			if(Downscaling_Support == 0)
			{
			gridy = floor(texcoord.y*(BUFFER_HEIGHT));
			gridx = floor(texcoord.x*(BUFFER_WIDTH));
			}
			else if(Downscaling_Support == 1)
			{
			gridy = floor(texcoord.y*(1080.0));
			gridx = floor(texcoord.x*(1080.0));
			}
			else
			{
			gridy = floor(texcoord.y*(1081.0));
			gridx = floor(texcoord.x*(1081.0));
			}
			
			if(Custom_Sidebars == 0)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) :  tex2D(BackBufferMIRROR, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
		}
		else
		{
													
				float3 HalfLM = dot(tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 HalfRM = dot(tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 LM = lerp(HalfLM,tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,Anaglyph_Desaturation);  
				float3 RM = lerp(HalfRM,tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)).rgb,Anaglyph_Desaturation); 
				
				float3 HalfLB = dot(tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 HalfRB = dot(tex2D(BackBufferBORDER,float2((texcoord.x - P ) - ReprojectionRight,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 LB = lerp(HalfLB,tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,Anaglyph_Desaturation);  
				float3 RB = lerp(HalfRB,tex2D(BackBufferBORDER,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)).rgb,Anaglyph_Desaturation); 
				
				float4 C;
				float4 CT;
				
				if(Custom_Sidebars == 0)
				{
				C = float4(LM,1);
				CT = float4(RM,1);
				}
				else
				{
				C = float4(LB,1);
				CT = float4(RB,1);
				}

				
			if (Anaglyph_Colors == 0)
			{
				float4 LeftEyecolor = float4(1.0,0.0,0.0,1.0);
				float4 RightEyecolor = float4(0.0,1.0,1.0,1.0);
				

				color =  (C*LeftEyecolor) + (CT*RightEyecolor);

			}
			else if (Anaglyph_Colors == 1)
			{
			float red = 0.437 * C.r + 0.449 * C.g + 0.164 * C.b
					- 0.011 * CT.r - 0.032 * CT.g - 0.007 * CT.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = -0.062 * C.r -0.062 * C.g -0.024 * C.b 
						+ 0.377 * CT.r + 0.761 * CT.g + 0.009 * CT.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.048 * C.r - 0.050 * C.g - 0.017 * C.b 
						-0.026 * CT.r -0.093 * CT.g + 1.234  * CT.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }


			color = float4(red, green, blue, 0);
			}
			else if (Anaglyph_Colors == 2)
			{
				float4 LeftEyecolor = float4(0.0,1.0,0.0,1.0);
				float4 RightEyecolor = float4(1.0,0.0,1.0,1.0);
				
				color =  (C*LeftEyecolor) + (CT*RightEyecolor);
				
			}
			else
			{
				
				
			float red = -0.062 * C.r -0.158 * C.g -0.039 * C.b
					+ 0.529 * CT.r + 0.705 * CT.g + 0.024 * CT.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = 0.284 * C.r + 0.668 * C.g + 0.143 * C.b 
						- 0.016 * CT.r - 0.015 * CT.g + 0.065 * CT.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.015 * C.r -0.027 * C.g + 0.021 * C.b 
						+ 0.009 * CT.r + 0.075 * CT.g + 0.937  * CT.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
					
			color = float4(red, green, blue, 0);
			}
		}	
	}
		else
	{
			float4 DMV = texcoord.x < 0.5 ? GetAO(float2(texcoord.x*2 , texcoord.y*2)) : tex2D(SamplerDM,float2(texcoord.x*2-1 , texcoord.y*2));
			color = texcoord.y < 0.5 ? DMV : tex2D(SamplerDis,float2(texcoord.x,texcoord.y*2-1));
			//tex2Dlod(SamplerLum,float4(texcoord.x,texcoord.y*2-1,0,0))
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

technique SuperDepth3D
{					
			pass DepthMap
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget = texDM;
		}
			pass AO
		{
			VertexShader = PostProcessVS;
			PixelShader = AO_in;
			RenderTarget = texAO;
		}	
			pass Disocclusion
		{
			VertexShader = PostProcessVS;
			PixelShader = Disocclusion;
			RenderTarget = texDis;
		}
			pass Luminance
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Luminance;
			RenderTarget = texLum;
		}
			pass Stereo
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderLR;
		}
}
