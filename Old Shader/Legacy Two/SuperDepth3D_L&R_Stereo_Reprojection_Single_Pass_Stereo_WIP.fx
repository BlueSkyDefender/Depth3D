 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.0 L & R                      																										*//
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
 //* Code lifted from CryTech 3 Slide Show																																			*//
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
uniform int AltDepthMap <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent AltDepthMap.";
> = 0;

uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 25;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes.";
> = 25;

uniform int Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point.";
> = 0;

uniform int WA <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Warp Adjust";
	ui_tooltip = "Adjust the warp in both eyes.";
> = 0;

uniform bool DepthFlip <
	ui_label = "Depth Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

uniform bool DepthMap <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform int CustomDM <
	ui_type = "combo";
	ui_items = "Custom Off\0Custom One +\0Custom One -\0Custom Two +\0Custom Two -\0Custom Three +\0Custom Three -\0Custom Four +\0Custom Four -\0Custom Five +\0Custom Five -\0Custom Six +\0Custom Six -\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Adjust your own Custom Depth Map.";
> = 0;

uniform float Far <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
	ui_label = "Far";
	ui_tooltip = "Far Depth Map Adjustment.";
> = 1.5;
 
 uniform float Near <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
	ui_label = "Near";
	ui_tooltip = "Near Depth Map Adjustment.";
> = 1.5;

uniform bool BD <
	ui_label = "Barrel Distortion";
	ui_tooltip = "Barrel Distortion for HMD type Displays.";
> = false;

uniform float Hsquish <
	ui_type = "drag";
	ui_min = 1; ui_max = 2;
	ui_label = "Horizontal Squish";
	ui_tooltip = "Horizontal squish cubic distortion value. Default is 1.050.";
> = 1.050;

uniform float K <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Lens Distortion";
	ui_tooltip = "Lens distortion coefficient. Default is -0.15.";
> = -0.15;

uniform float KCube <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Cubic Distortion";
	ui_tooltip = "Cubic distortion value. Default is 0.5.";
> = 0.5;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

texture DepthBufferTex : DEPTH;
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex; 
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};

sampler DepthBuffer 
	{ 
		Texture = DepthBufferTex; 
	};

sampler2D SamplerCC
	{
		Texture = texCC;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};

//Depth Map Information	
float SbSdepthL (float2 texcoord) 	
{

	 float4 color = tex2D(SamplerCC, texcoord);

			if (DepthFlip)
			texcoord.y =  1 - texcoord.y;
	
	float DWA = WA;
	
	float4 depthM = tex2D(DepthBuffer, float2(texcoord.x*2-DWA*pix.x, texcoord.y));
		
		if (CustomDM == 0)
	{	
		//Alien Isolation
		if (AltDepthMap == 0)
		{
		float cF = 1000000000;
		float cN = 1;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Amnesia: The Dark Descent
		if (AltDepthMap == 1)
		{
		float cF = 1000;
		float cN = 1;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Among The Sleep	
		if (AltDepthMap == 2)
		{
		float cF = 10;
		float cN = 0.05;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Assassin Creed Unity
		if (AltDepthMap == 3)
		{
		float cF  = 0.0075;
		float cN = 1;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Batman Arkham Knight | Batman Arkham Origins | Batman: Arkham City | BorderLands 2
		if (AltDepthMap == 4)
		{
		float cF = 50;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
	}
	else
	{
		//Custom One
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Custom Two
		if (CustomDM == 2)
		{
		float cF  = Far;
		float cN = Near;
		depthM = (2.0 * cN) / (cF + cN - depthM * (cF - cN));
		}
		
		//Custom Three
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Custom Four
		if (CustomDM == 4)
		{
		float cF = Far;
		float cN = Near;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Custom Five
		if (CustomDM == 5)
		{
		float cF = Far;
		float cN = Near;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
	}

    float4 D = depthM;	

	color.r = texcoord.x < 0.5 ? D.r : 0;

	return color.r;	
	}

//Depth Map Information	
float SbSdepthR (float2 texcoord) 	
{

	 float4 color = tex2D(SamplerCC, texcoord);

			if (DepthFlip)
			texcoord.y =  1 - texcoord.y;
	
	float DWA = WA;
	
	float4 depthM = tex2D(DepthBuffer, float2(texcoord.x*2-1+DWA*pix.x, texcoord.y)) ;
		
		if (CustomDM == 0)
	{	
		//Alien Isolation
		if (AltDepthMap == 0)
		{
		float cF = 1000000000;
		float cN = 1;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Amnesia: The Dark Descent
		if (AltDepthMap == 1)
		{
		float cF = 1000;
		float cN = 1;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Among The Sleep	
		if (AltDepthMap == 2)
		{
		float cF = 10;
		float cN = 0.05;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Assassin Creed Unity
		if (AltDepthMap == 3)
		{
		float cF  = 0.0075;
		float cN = 1;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Batman Arkham Knight | Batman Arkham Origins | Batman: Arkham City | BorderLands 2
		if (AltDepthMap == 4)
		{
		float cF = 50;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
	}
	else
	{
		//Custom One
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Custom Two
		if (CustomDM == 2)
		{
		float cF  = Far;
		float cN = Near;
		depthM = (2.0 * cN) / (cF + cN - depthM * (cF - cN));
		}
		
		//Custom Three
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Custom Four
		if (CustomDM == 4)
		{
		float cF = Far;
		float cN = Near;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Custom Five
		if (CustomDM == 5)
		{
		float cF = Far;
		float cN = Near;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
	}

    float4 D = depthM;	

	color.r = texcoord.x > 0.5 ? D.r : 0;

	return color.r;	
	}
//////////////////////////////////////////////////////Barrle_Distortion/////////////////////////////////////////////////////
float3 BDL(float2 texcoord)

{
	float k = K;
	float kcube = KCube;
	float pos = Hsquish-1;
	float mid = pos*BUFFER_HEIGHT/2*pix.y;

	float r2 = (texcoord.x-0.5) * (texcoord.x-0.5) + (texcoord.y-0.5) * (texcoord.y-0.5);       
	float f = 0.0;

	f = 1 + r2 * (k + kcube * sqrt(r2));

	float x = f*(texcoord.x-0.5)+0.5;
	float y = f*(texcoord.y-0.5)+0.5;
	float3 BDListortion = tex2D(BackBuffer,float2(x*2 - Perspective* pix.x , ((y * Hsquish ) -mid))).rgb;

	return BDListortion.rgb;
}

float3 BDR(float2 texcoord)

{
	float k = K;
	float kcube = KCube;
	float pos = Hsquish-1;
	float mid = pos*BUFFER_HEIGHT/2*pix.y;
	
	float r2 = (texcoord.x-0.5) * (texcoord.x-0.5) + (texcoord.y-0.5) * (texcoord.y-0.5);       
	float f = 0.0;

	f = 1 + r2 * (k + kcube * sqrt(r2));

	float x = f*(texcoord.x-0.5)+0.5;
	float y = f*(texcoord.y-0.5)+0.5;
	float3 BDRistortion = tex2D(BackBuffer,float2(x*2-1 + Perspective* pix.x , ((y * Hsquish ) -mid))).rgb;

	return BDRistortion.rgb;
}

float3 LCal(float2 texcoord)

{
	float3 LCalculation= tex2D(BackBuffer,float2(texcoord.x*2 - Perspective* pix.x , texcoord.y )).rgb;

	return LCalculation.rgb;
}

float3 RCal(float2 texcoord)

{
	float3 RCalculation= tex2D(BackBuffer,float2(texcoord.x*2-1 + Perspective* pix.x , texcoord.y )).rgb;

	return RCalculation.rgb;
}


//////////////////////////////////////////Render Single Pass Left/Right//////////////////////////////////////////////////
void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
	const float samples[5] = {0.5, 0.66, 1, 0.25 , 0.75};
	float minDepthL = 1.0, minDepthR = 1.0;
	float2 uv = 0;
	float Parallax = 1;
	
	//Left Right Eyes
	[unroll]
	for (int j = 0; j < 5; ++j)
	{
		uv.x = samples[j] * Depth;
		minDepthL= min(minDepthL,SbSdepthL(float2(texcoord.x-uv.x*pix.x,texcoord.y-uv.y*pix.y)));
		minDepthR= min(minDepthR,SbSdepthR(float2(texcoord.x+uv.x*pix.x,texcoord.y+uv.y*pix.y)));

		float parallaxL = Depth * (1 - Parallax / minDepthL);
		float parallaxR = Depth * (1 - Parallax / minDepthR);
			
		if(BD)
		{
		color.rgb = texcoord.x < 0.5 ? BDL(float2(texcoord.xy + float2(parallaxL,0)*pix.xy)).rgb : BDR(float2(texcoord.xy - float2(parallaxR,0)*pix.xy)).rgb;
		}
		else
		{
		color.rgb = texcoord.x < 0.5 ? LCal(float2(texcoord.xy + float2(parallaxL,0)*pix.xy)).rgb : RCal(float2(texcoord.xy - float2(parallaxR,0)*pix.xy)).rgb;
		}
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

///////////////////////////////////////////////Depth Map View//////////////////////////////////////////////////////////////////////

//*Rendering pass*//

technique Super_Depth3D
	{
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderLR;
		}
		
	}
