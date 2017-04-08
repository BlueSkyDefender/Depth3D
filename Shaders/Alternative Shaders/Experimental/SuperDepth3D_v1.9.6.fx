 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.6 AO																																*//
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

#define Depth_Map_Division 2.0


uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 25;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.";
> = 15;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0;

uniform int Dis_Occlusion <
	ui_type = "combo";
	ui_items = "Off\0Normal Mask\0Radial Mask\0";
	ui_label = "Disocclusion Mask";
	ui_tooltip = "Automatic occlusion masking options.";
> = 1;

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DirectX\0DirectX Alternative\0OpenGL\0OpenGL Alternative\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float2 Near_Far <
	ui_type = "drag";
	ui_min = 0; ui_max = 100;
	ui_label = "Near & Far Adjustment";
	ui_tooltip = "Defaults for Near is 0.01-1.0 & for Far is 1.0. Alternative defaults for Near is 0.01-1.0 & for Far is 25.";
> = float2(0.01,1.0);

uniform bool Depth_Map_Invert <
	ui_label = "Invert Depth Map";
	ui_tooltip = "To invert the Depth Map if it is reverse.";
> = false;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map.";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform int Weapon_Depth_Map <
	ui_type = "combo";
	ui_items = "Weapon Depth Map Off\0Custom Weapon Depth Map One\0Custom Weapon Depth Map Two\0";
	ui_label = "Weapon Depth Map";
	ui_tooltip = "Weapon depth map for games. Read the ReadMeDepth3d.txt, for setting.";
> = 0;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.500;
	ui_label = "Weapon Adjust Depth Map";
	ui_tooltip = "Adjust weapon depth map. Default is (Y 0, X 0.250, Z 1.001)";
> = float3(0.0,0.250,1.001);

uniform float Weapon_Distance_Correction <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.0;
	ui_label = "Weapon Distance Correction";
	ui_tooltip = "For adjusting the distance of the weapon in the depth map. Default is 0";
> = 0.0;

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

uniform int AO <
	ui_type = "combo";
	ui_items = "Off\0ON\0";
	ui_label = "3D AO Mode";
	ui_tooltip = "3D ambient occlusion mode switch. Default is On.";
> = 1;

uniform float Power <
	ui_type = "drag";
	ui_min = 0.375; ui_max = 0.625;
	ui_label = "AO Power";
	ui_tooltip = "Ambient occlusion power on the depth map. Default is 0.500";
> = 0.500;

uniform float Spread <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2.5;
	ui_label = "AO Falloff";
	ui_tooltip = "Ambient occlusion falloff. Default is 1.5";
> = 1.5;

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
	
texture texDone  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F;}; 

sampler SamplerDone
	{
		Texture = texDone;
	};
	
texture texSSAO  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA32F;}; 

sampler SamplerSSAO
	{
		Texture = texSSAO;
	};

/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0 )
{
	 float4 color;

			if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
	float4 depthM = tex2D(DepthBuffer, float2(texcoord.x, texcoord.y));
	float4 WDM;
	float4 WDone;
	
		//Conversions to linear space.....
		float cF = Near_Far.y;//Far
		float cN = Near_Far.x;//Near
		float constantF = 1.0;	
		float constantN = 0.01;
		
		//Flow control switch statement incompatible with dx9...

		//DirectX Custom
		if (Depth_Map == 0)
		{
		depthM = 2.0 * cN * cF / (cF + cN - depthM.r * (cF - cN));
		}
		//DirectX Alternative Custom
		if (Depth_Map == 1)
		{
		depthM = pow(abs(cN-depthM.r),cF);
		}

		//OpenGL Custom
		if (Depth_Map == 2)
		{
		depthM = 2.0 * cN * cF / (cF + cN - (2.0 * depthM.r - 1.0) * (cF - cN));
		}
		
		//OpenGL Alternative Custom
		if (Depth_Map == 3)
		{
		depthM = pow(abs(2.0 * depthM.r - cN),cF);
		}
		
		float Adj;
		float4 D;
		
		//DirectX Weapon Depth Map
		if (Depth_Map == 0 || 1)
		{
		WDM = 2.0 * constantN * constantF / (constantF + constantN - depthM.r * (constantF - constantN));
		}
		
		//OpenGL Weapon Depth Map
		else if (Depth_Map == 2 || 3)
		{
		WDM = 2.0 * constantN * constantF / (constantF + constantN - (2.0 * depthM.r - 1.0) * (constantF - constantN));
		}
		
		if (Depth_Map_Invert)
			depthM = 1.0 - depthM;
				
		//Scaled Section z-Buffer Needs more Work!
		//Custom Weapon Depth Profile One	
		if (Weapon_Depth_Map == 1)
		{
		Adj = Weapon_Adjust.x;//0
		float cWF = Weapon_Adjust.y;//0.250
		float cWN = Weapon_Adjust.z;//1.001
		WDone = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Custom Weapon Depth Profile Two	
		if (Weapon_Depth_Map == 2)
		{
		Adj = Weapon_Adjust.x;//0
		float cWF = Weapon_Adjust.y;//-0.05
		float cWN = Weapon_Adjust.z;//0.500
		WDone = 1 - (log(cWN * WDM)/ 1 - log(cWF+WDM));
		}
			
		if (Weapon_Depth_Map_Invert)
			WDone = 1 - WDone;
			
	float NearDepth;
	
	if (Weapon_Depth_Map == 27 || Weapon_Depth_Map == 23 || Weapon_Depth_Map == 20 || Weapon_Depth_Map == 19 || Weapon_Depth_Map == 13 || Weapon_Depth_Map == 8)
	{
	NearDepth = step(WDM.r,Adj/100000);
	NearDepth = NearDepth-NearDepth*Weapon_Distance_Correction;
	}
	else
	{
	NearDepth = step(WDM.r,Adj);
	NearDepth = NearDepth-NearDepth*Weapon_Distance_Correction;
	}
	
		if (Weapon_Depth_Map <= 0)
		{
		D = depthM;
		}
		else
		{
		D = lerp(depthM,WDone,NearDepth);
		}
    
	color.rgb = clamp(D.rrr,0,1.0);
	
	Color = color;	

}

/////////////////////////////////////////////////////AO/////////////////////////////////////////////////////////////

float3 GetPosition(float2 coords)
{
	return float3(coords.xy*2.0-1.0,10.0)*tex2D(SamplerDM,coords.xy).rgb;
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
	float3 vv = normalize(ddiff);
	float rd = length(ddiff);
	return (1.0-clamp(dot(normal_from_depth(float2(c1,c2)),-vv),-1,1.0)) * clamp(dot( cnorm,vv ),1.0,1.0)* (1.0 - 1.0/sqrt(1.0/(rd*rd) + 1000));
}

float4 GetAO( float2 texcoord )
{ 
    //current normal , position and random static texture.
    float3 normal = normal_from_depth(texcoord);
    float3 position = GetPosition(texcoord);
	float2 random = GetRandom(texcoord).xy;
    
    //initialize variables:
    float S = Spread;
	float iter = 2.5*pix.x;
    float ao;
    float incx = S*pix.x;
    float incy = S*pix.y;
    float width = incx;
    float height = incy;
    float num;
    
    //Depth Map
    float depthM = tex2D(SamplerDM, texcoord).r;
    
    	float cF = -1.0;
		float cN = 1000;
		
	//Depth Map linearization
    depthM = saturate(pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),-0.200));
    
	//2 iterations 
    [loop]
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

void  DisOcclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
//bilateral blur\/
float4 Done;
float4 sum;

float blursize = 2.0*pix.x;

sum += tex2D(SamplerSSAO, float2(texcoord.x - 4.0*blursize, texcoord.y)) * 0.05;
sum += tex2D(SamplerSSAO, float2(texcoord.x, texcoord.y - 3.0*blursize)) * 0.09;
sum += tex2D(SamplerSSAO, float2(texcoord.x - 2.0*blursize, texcoord.y)) * 0.12;
sum += tex2D(SamplerSSAO, float2(texcoord.x, texcoord.y - blursize)) * 0.15;
sum += tex2D(SamplerSSAO, float2(texcoord.x + blursize, texcoord.y)) * 0.15;
sum += tex2D(SamplerSSAO, float2(texcoord.x, texcoord.y + 2.0*blursize)) * 0.12;
sum += tex2D(SamplerSSAO, float2(texcoord.x + 3.0*blursize, texcoord.y)) * 0.09;
sum += tex2D(SamplerSSAO, float2(texcoord.x, texcoord.y + 4.0*blursize)) * 0.05;

Done = sum;
//bilateral blur/\

float DP =  Depth;
	
 float Disocclusion_Power = DP/375;
 float4 DM;                                                                                                                                                                                                                                                                                               	
 float2 dir;
 float B , W;
 int Con = 10;
	
	if(Dis_Occlusion > 0) 
	{
	
	const float weight[10] = { 0.01,-0.01,0.02,-0.02,0.03,-0.03,0.04,-0.04,0.05,-0.05};

	if(Dis_Occlusion == 1)
	{
	dir = float2(0.5,0);
	B = Disocclusion_Power;
	}
	
	if(Dis_Occlusion == 2)
	{
	dir = 0.5 - texcoord;
	B = Disocclusion_Power*2;
	}
	
	dir = normalize( dir ); 
	 
	[loop]
	for (int i = 0; i < Con; i++)
	{
		if(Dis_Occlusion > 0) 
		{
		DM += tex2D(SamplerDM,texcoord + dir * weight[i] * B)/Con;
		}
	}
	
	}
	else
	{
	DM = tex2D(SamplerDM,texcoord);
	}		                          
	
	DM = DM;
	
	float4 Mix = pow(1-(Done*(1-DM)),0.25);
	
	color = saturate(pow(lerp(DM,Mix,Power),3));
}

////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////

void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	float samples[4] = {0.50, 0.66, 0.85, 1.0,};
	float DepthL = 1, DepthR = 1 , D , P;
	float2 uv = 0;
		
	if(!Eye_Swap)
		{	
			P = Perspective * pix.x;
			D = Depth * pix.x;
		}
		else
		{
			P = -Perspective * pix.x;
			D = -Depth * pix.x;
		}
	
	[loop]
	for (int j = 0; j < 4; ++j) 
	{	
		uv.x = samples[j] * D;
		
		if(Stereoscopic_Mode == 0)
		{	
			DepthL =  min(DepthL,tex2D(SamplerDone,float2((texcoord.x*2 + P)+uv.x, texcoord.y)).r);
			DepthR =  min(DepthR,tex2D(SamplerDone,float2((texcoord.x*2-1 - P)-uv.x, texcoord.y)).r);
		}
		else if(Stereoscopic_Mode == 1)
		{
			DepthL =  min(DepthL,tex2D(SamplerDone,float2((texcoord.x + P)+uv.x, texcoord.y*2)).r);
			DepthR =  min(DepthR,tex2D(SamplerDone,float2((texcoord.x - P)-uv.x, texcoord.y*2-1)).r);
		}
		else
		{
			DepthL =  min(DepthL,tex2D(SamplerDone,float2((texcoord.x + P)+uv.x, texcoord.y)).r);
			DepthR =  min(DepthR,tex2D(SamplerDone,float2((texcoord.x - P)-uv.x, texcoord.y)).r);
		}
	}
	
	if(!Depth_Map_View)
	{
		if(Stereoscopic_Mode == 0)
		{
			if(Custom_Sidebars == 0)
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x*2 + P) + DepthL * D, texcoord.y)) : tex2D(BackBufferMIRROR, float2((texcoord.x*2-1 - P) - DepthR * D , texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x*2 + P) + DepthL * D , texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x*2-1 - P) - DepthR * D , texcoord.y));
			}
			else
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x*2 + P) + DepthL * D , texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x*2-1 - P) - DepthR * D , texcoord.y));
			}
		}
		else if(Stereoscopic_Mode == 1)
		{	
			if(Custom_Sidebars == 0)
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + DepthL * D , texcoord.y*2)) : tex2D(BackBufferMIRROR, float2((texcoord.x - P) - DepthR * D , texcoord.y*2-1));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + DepthL * D , texcoord.y*2)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - DepthR * D , texcoord.y*2-1));
			}
			else
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + DepthL * D , texcoord.y*2)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - DepthR * D , texcoord.y*2-1));
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
			color = gridL > 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + DepthL * D , texcoord.y)) :  tex2D(BackBufferMIRROR, float2((texcoord.x - P) - DepthR * D , texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = gridL > 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + DepthL * D , texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - DepthR * D , texcoord.y));
			}
			else
			{
			color = gridL > 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + DepthL * D , texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - DepthR * D , texcoord.y));
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
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + DepthL * D , texcoord.y)) :  tex2D(BackBufferMIRROR, float2((texcoord.x - P) - DepthR * D , texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + DepthL * D , texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - DepthR * D , texcoord.y));
			}
			else
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + DepthL * D , texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - DepthR * D , texcoord.y));
			}
		}
		else
		{
													
				float3 HalfLM = dot(tex2D(BackBufferMIRROR,float2((texcoord.x + P) + DepthL * D ,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 HalfRM = dot(tex2D(BackBufferMIRROR,float2((texcoord.x - P) - DepthR * D ,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 LM = lerp(HalfLM,tex2D(BackBufferMIRROR,float2((texcoord.x + P) + DepthL * D ,texcoord.y)).rgb,Anaglyph_Desaturation);  
				float3 RM = lerp(HalfRM,tex2D(BackBufferMIRROR,float2((texcoord.x - P) - DepthR * D ,texcoord.y)).rgb,Anaglyph_Desaturation); 
				
				float3 HalfLB = dot(tex2D(BackBufferBORDER,float2((texcoord.x + P) + DepthL * D ,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 HalfRB = dot(tex2D(BackBufferBORDER,float2((texcoord.x - P ) - DepthR * D ,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 LB = lerp(HalfLB,tex2D(BackBufferBORDER,float2((texcoord.x + P) + DepthL * D ,texcoord.y)).rgb,Anaglyph_Desaturation);  
				float3 RB = lerp(HalfRB,tex2D(BackBufferBORDER,float2((texcoord.x - P) - DepthR * D ,texcoord.y)).rgb,Anaglyph_Desaturation); 
				
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
			color = texcoord.y < 0.5 ? DMV : tex2D(SamplerDone,float2(texcoord.x , texcoord.y*2-1));
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
			pass SSAOcal
		{
			VertexShader = PostProcessVS;
			PixelShader = AO_in;
			RenderTarget = texSSAO;
		}	
			pass DisOcclusion
		{
			VertexShader = PostProcessVS;
			PixelShader = DisOcclusion;
			RenderTarget = texDone;
		}
			pass Stereo
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderLR;
		}
}
