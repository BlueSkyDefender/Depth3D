 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.7.1 L & R Eye																															*//
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
 //* Original work was based on Shader Based on forum user 04348 and be located here http://reshade.me/forum/shader-presentation/1594-3d-anaglyph-red-cyan-shader-wip#15236			*//
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform bool AltRender <
	ui_label = "Alternate Render";
	ui_tooltip = "Alternate Render Mode is a different way of warping the screen.";
> = true; 
 
uniform int AltDepthMap <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0Depth Map 11\0Depth Map 12\0Depth Map 13\0Depth Map 14\0Depth Map 15\0Depth Map 16\0Depth Map 17\0Depth Map 18\0Depth Map 19\0Depth Map 20\0Depth Map 21\0Depth Map 22\0Depth Map 23\0Depth Map 24\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent AltDepthMap.";
> = 0;

uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 25;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes.";
> = 10;

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

uniform int CustomDM <
	ui_type = "combo";
	ui_items = "Custom Off\0Custom One +\0Custom One -\0Custom Two +\0Custom Two -\0Custom Three +\0Custom Three -\0Custom Four +\0Custom Four -\0Custom Five +\0Custom Five -\0Custom Six +\0Custom Six -\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Adjust your own Custom Depth Map.";
> = 0;

uniform bool DepthMap <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

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
	ui_min = 1; ui_max = 1.5;
	ui_label = "Horizontal Squish";
	ui_tooltip = "Horizontal squish cubic distortion value. Default is 1.";
> = 1;

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

uniform bool EyeSwap <
	ui_label = "Eye Swap";
	ui_tooltip = "Swap Left/Right to Right/Left and ViceVersa.";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#include "ReShade.fxh"

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerCL
	{
		Texture = texCL;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
sampler SamplerCR
	{
		Texture = texCR;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
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
	
//Left Eye Depth Map Information
float SbSdepthL (float2 texcoord) 
	
	{

	 float4 color = tex2D(SamplerCC, texcoord);

			if (DepthFlip)
			texcoord.y =  1 - texcoord.y;


	float4 depthL = ReShade::GetLinearizedDepth(float2(texcoord.x, texcoord.y));

	if (CustomDM == 0)
	{		
		//Naruto
		if (AltDepthMap == 0)
		{
		depthL = (pow(abs(depthL),0.75));
		}
		
		//Batman Games
		if (AltDepthMap == 1)
		{
		float cF = 2;
		float cN = 1;
		depthL = (-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Quake 2 XP
		if (AltDepthMap == 2)
		{
		float cF = 2.5;
		float cN = 0;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
		
		//The Evil Within
		if (AltDepthMap == 3)
		{
		float cF = 8;
		float cN = 0;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
		
		//Sleeping Dogs:  DE
		if (AltDepthMap == 4)
		{
		float zF = 1.0;
		float zN = 0.025;
		depthL = 1 - (zF * zN / (zN + depthL * (zF - zN)) + pow(abs(depthL*depthL),1.0));
		}
		
		//COD:AW
		if (AltDepthMap == 5)
		{
		float cF = 0.0015;
		float cN = 0;
		depthL = (cF) / (cF - depthL * ((1 - cN) / (cF - cN * depthL)) * (cF - 1));
		}
		
		//Lords of the Fallen
		if (AltDepthMap == 6)
		{
		float cF = 8;
		float cN = 1.5;
		depthL = (-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Shadow Warrior
		if (AltDepthMap == 7)
		{
		float cF = 1.5;
		float cN = 1;
		depthL = (-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Rage
		if (AltDepthMap == 8)
		{
		float LinLog = 0.005;
		depthL = (1 - (LinLog) / (LinLog - depthL * 1.5 * (LinLog -  0.05)))+(pow(abs(depthL*depthL),3.5));
		}	
		
		//Assassin's Creed Unity
		if (AltDepthMap == 9)
		{
		float cF = 150;
		float cN = 0.4;
		depthL = 1-(-0+(pow(abs(depthL),cN))*cF);
		}

		// Skyrim | Deadly Premonition: The Directors's Cut
		if (AltDepthMap == 10)
		{
		float cF = 0.005;
		float cN = 0.5;
		depthL = log(depthL/cF)/log(cN/cF);
		}
		
		//Dying Light
		if (AltDepthMap == 11)
		{
		float zF = 1.0;
		float zN = 0.000025;
		float vF = 0.05;		
		depthL = (zF * zN / (zN + depthL * 1 * (zF - zN)))-(pow(abs(depthL*depthL),vF));
		}

		//Witcher 3
		if (AltDepthMap == 12)
		{
		float zF = 1.0;
		float zN = 0.00005;
		float vF = 0.110;		
		depthL = (zF * zN / (zN + depthL * 1 * (zF - zN)))-(pow(abs(depthL*depthL),vF));
		}
		
		//Fallout 4
		if (AltDepthMap == 13)
		{
		float cN = -0.025;
		float cF  = 1.025;
		depthL = 1 - (1 - cF) / (cN - cF * depthL); 
		}
		
		//Magicka 2
		if (AltDepthMap == 14)
		{
		float cF = 0.001;
		float cM = 0;
		float cN = 0.250;
		depthL = (1 * cF / (cF + depthL * (depthL+cM) * (1 - cF))) / (pow(abs(depthL),cN));
		}
				
		//Dragon Dogma
		if (AltDepthMap == 15)
		{
		float cN = -0.02;
		float cF  = 1.025;
		depthL = 1 - (1 - cF) / (cN - cF * depthL); 
		}
		
		//Among The Sleep
		if (AltDepthMap == 16)
		{
		float cF = 10;
		float cN = 0;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
		
		//Return to Castle Wolfensitne
		if (AltDepthMap == 17)
		{
		float cF = 0.1;
		float cM = 1.0;
		float cN = 0;
		depthL = 1 - (1 * cF / (cF + depthL * (depthL+cM) * (1 - cF))) / (pow(abs(depthL),cN));
		}
		
		//Dreamfall Chapters
		if (AltDepthMap == 18)
		{
		float cF = 0.25;
		float cM = 15.0;
		float cN = 0.01;
		depthL = 1 - (1 * cF / (cF + depthL * (depthL+cM) * (1 - cF))) / (pow(abs(depthL),cN));
		}		
		
		//CoD: Ghost
		if (AltDepthMap == 19)
		{
		float cF = 0.002;
		float cN = 0;
		depthL = (cF) / (cF - depthL * ((1 - cN) / (cF - cN * depthL)) * (cF - 1));
		}
		
		//Metro Redux Games | Borderlands 2
		if (AltDepthMap == 20)
		{
		float cN = 0;
		float cF = 0.250;
		depthL = 1 - (cF) / (cF - depthL * ((1 - cN) / (cF - cN * depthL)) * (cF - 1));
		}
		
		//Souls Game
		if (AltDepthMap == 21)
		{
		float cF = 7.5;
		float cN = -0.200;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
		
		//Amnesia: The Dark Descent
		if (AltDepthMap == 22)
		{
		float cF = 1.5;
		float cN = 1.5;
		depthL = (-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Alien Isolation
		if (AltDepthMap == 23)
		{
		float cF = 4;
		float cN = 0;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
		
		//Dragon Ball Xeno
		if (AltDepthMap == 24)
		{
		float cF = 1.125;
		float cN = 0;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
	}
	else
	{
		//Custom One +
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthL = (-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Custom One -
		if (CustomDM == 2)
		{
		float cF = Far;
		float cN = Near;
		depthL = 1-(-0+(pow(abs(depthL),cN))*cF);
		}
		
		//Custom Two +
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthL = (1 - cF) / (cN - cF * depthL); 
		}
		
		//Custom Two -
		if (CustomDM == 4)
		{
		float cF  = Far;
		float cN = Near;
		depthL = 1 - (1 - cF) / (cN - cF * depthL); 
		}
		
		//Custom Three +
		if (CustomDM == 5)
		{
		float cF  = Far;
		float cN = Near;
		depthL = (cF * 1/depthL + cN);
		}
		
		//Custom Three -
		if (CustomDM == 6)
		{
		float cF  = Far;
		float cN = Near;
		depthL = 1 - (cF * 1/depthL + cN);
		}
		
		//Custom Four +
		if (CustomDM == 7)
		{
		float cF = Far;
		float cN = Near;
		depthL = log(depthL/cF)/log(cN/cF);
		}
		
		//Custom Four -
		if (CustomDM == 8)
		{
		float cF = Far;
		float cN = Near;		
		depthL = 1 - log(depthL/cF)/log(cN/cF);
		}
		
		//Custom Five +
		if (CustomDM == 9)
		{
		float cF = Far;
		float cN = Near;
		depthL = (cF) / (cF - depthL * ((1 - cN) / (cF - cN * depthL)) * (cF - 1));
		}
		
		//Custom Five -
		if (CustomDM == 10)
		{
		float cF = Far;
		float cN = Near;
		depthL = 1 - (cF) / (cF - depthL * ((1 - cN) / (cF - cN * depthL)) * (cF - 1));
		}
		
		//Custom Six +
		if (CustomDM == 11)
		{
		float cF = Far;
		float cN = Near;
		depthL = (cN - depthL * cN) + (depthL*cF);
		}
		
		//Custom Six -
		if (CustomDM == 12)
		{
		float cF = Far;
		float cN = Near;
		depthL = 1 - (cN - depthL * cN) + (depthL*cF);
		}
	}

    float4 DL =  depthL;

	if(!AltRender)
	{
		if (EyeSwap)
		{
		color.r = 1 - DL.r;
		}
		else
		{
		color.r = DL.r;
		}
	}
	else
	{
		if (EyeSwap)
		{
		color.r = DL.r;
		}
		else
		{
		color.r = 1 - DL.r;
		}
	}
	return color.r;	
	}

//Right Eye Depth Map Information	
float SbSdepthR (float2 texcoord) 	
{

	 float4 color = tex2D(SamplerCC, texcoord);

			if (DepthFlip)
			texcoord.y =  1 - texcoord.y;
	
	float4 depthR = ReShade::GetLinearizedDepth(float2(texcoord.x, texcoord.y));
		
	if (CustomDM == 0)
	{		
		//Naruto
		if (AltDepthMap == 0)
		{
		depthR = (pow(abs(depthR),0.75));
		}
		
		//Batman Games
		if (AltDepthMap == 1)
		{
		float cF = 5;
		float cN = 0;
		depthR = (cN - depthR * cN) + (depthR*cF);
		}
		
		//Quake 2 XP
		if (AltDepthMap == 2)
		{
		float cF  = 0.01;
		float cN = 0;
		depthR = 1 - (cF * 1/depthR + cN);
		}
		
		//The Evil Within
		if (AltDepthMap == 3)
		{
		float cF = 1.5;
		float cN = 0;
		depthR = (cN - depthR * cN) + (depthR*cF);
		}
		
		//Sleeping Dogs:  DE
		if (AltDepthMap == 4)
		{
		float zF = 1.0;
		float zN = 0.025;
		depthR = 1 - (zF * zN / (zN + depthR * (zF - zN)) + pow(abs(depthR*depthR),1.0));
		}
		
		//COD:AW
		if (AltDepthMap == 5)
		{
		float cF  = 0.00001;
		float cN = 0;
		depthR = (cF * 1/depthR + cN);
		}
		
		//Lords of the Fallen
		if (AltDepthMap == 6)
		{
		float cF  = 1.027;
		float cN = 0;
		depthR = 1 - (1 - cF) / (cN - cF * depthR); 
		}
		
		//Shadow Warrior
		if (AltDepthMap == 7)
		{
		float cF = 10;
		float cN = 0;
		depthR = (cN - depthR * cN) + (depthR*cF);
		}
		
		//Rage
		if (AltDepthMap == 8)
		{
		float LinLog = 0.005;
		depthR = (1 - (LinLog) / (LinLog - depthR * 1.5 * (LinLog -  0.05)))+(pow(abs(depthR*depthR),3.5));
		}	
		
		//Assassin's Creed Unity
		if (AltDepthMap == 9)
		{
		float cF = 25000;
		float cN = 1;
		depthR = 1-(-0+(pow(abs(depthR),cN))*cF);
		}

		// Skyrim | Deadly Premonition: The Directors's Cut
		if (AltDepthMap == 10)
		{
		float cF = 0.2;
		float cN = 0;
		depthR = 1 - (cF) / (cF - depthR * ((1 - cN) / (cF - cN * depthR)) * (cF - 1));
		}
		
		//Dying Light
		if (AltDepthMap == 11)
		{
		float zF = 1.0;
		float zN = 0.000025;
		float vF = 0.05;		
		depthR = (zF * zN / (zN + depthR * 1 * (zF - zN)))-(pow(abs(depthR*depthR),vF));
		}

		//Witcher 3
		if (AltDepthMap == 12)
		{
		float zF = 1.0;
		float zN = 0.00005;
		float vF = 0.110;		
		depthR = (zF * zN / (zN + depthR * 1 * (zF - zN)))-(pow(abs(depthR*depthR),vF));
		}
		
		//Fallout 4
		if (AltDepthMap == 13)
		{
		float cF = 25;
		float cN = 1;
		depthR = (-0+(pow(abs(depthR),cN))*cF);
		}
		
		//Magicka 2
		if (AltDepthMap == 14)
		{
		float cF = 0.001;
		float cM = 0;
		float cN = 0.250;
		depthR = (1 * cF / (cF + depthR * (depthR+cM) * (1 - cF))) / (pow(abs(depthR),cN));
		}
		
		//Dragon Dogma
		if (AltDepthMap == 15)
		{
		float cN = -0.02;
		float cF  = 1.025;
		depthR = 1 - (1 - cF) / (cN - cF * depthR); 
		}

		//Among The Sleep
		if (AltDepthMap == 16)
		{
		float cF = 1.0;
		float cN = 0.010;
		depthR = 1 - log(depthR/cF)/log(cN/cF);
		}
		
		//Return to Castle Wolfensitne
		if (AltDepthMap == 17)
		{
		float cF = 0.1;
		float cM = 1.0;
		float cN = 0;
		depthR = 1 - (1 * cF / (cF + depthR * (depthR+cM) * (1 - cF))) / (pow(abs(depthR),cN));
		}
		
		//Dreamfall Chapters
		if (AltDepthMap == 18)
		{
		float cF = 0.25;
		float cM = 15.0;
		float cN = 0.01;
		depthR = 1 - (1 * cF / (cF + depthR * (depthR+cM) * (1 - cF))) / (pow(abs(depthR),cN));
		}		
		
		//CoD: Ghost
		if (AltDepthMap == 19)
		{
		float cF  = 0.00001;
		float cN = 0;
		depthR = (cF * 1/depthR + cN);
		}
		
		//Metro Redux Games | Borderlands 2
		if (AltDepthMap == 20)
		{
		float LinLog = 0.002;
		depthR = 1 - (LinLog) / (LinLog - depthR * depthR * (LinLog - 1));
		}
		
		//Souls Game
		if (AltDepthMap == 21)
		{
		float cF = 4.55;
		float cN = 2.0;
		depthR = 1 - (cN - depthR * cN) + (depthR*cF);
		}
		
		//Amnesia: The Dark Descent
		if (AltDepthMap == 22)
		{
		float cF  = 1.050;
		float cN = 0;
		depthR = 1 - (1 - cF) / (cN - cF * depthR); 
		}
		
		//Alien Isolation
		if (AltDepthMap == 23)
		{
		float cF = 20;
		float cN = 0;
		depthR = (cN - depthR * cN) + (depthR*cF);
		}
		
		//Dragon Ball Xeno
		if (AltDepthMap == 24)
		{
		float cF = 0.350;
		float cN = 0;
		depthR = 1 - (cF) / (cF - depthR * ((1 - cN) / (cF - cN * depthR)) * (cF - 1));
		}
	}
	else
	{
		//Custom One +
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthR = (-0+(pow(abs(depthR),cN))*cF);
		}
		
		//Custom One -
		if (CustomDM == 2)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1-(-0+(pow(abs(depthR),cN))*cF);
		}
		
		//Custom Two +
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthR = (1 - cF) / (cN - cF * depthR); 
		}
		
		//Custom Two -
		if (CustomDM == 4)
		{
		float cF  = Far;
		float cN = Near;
		depthR = 1 - (1 - cF) / (cN - cF * depthR); 
		}
		
		//Custom Three +
		if (CustomDM == 5)
		{
		float cF  = Far;
		float cN = Near;
		depthR = (cF * 1/depthR + cN);
		}
		
		//Custom Three -
		if (CustomDM == 6)
		{
		float cF  = Far;
		float cN = Near;
		depthR = 1 - (cF * 1/depthR + cN);
		}
		
		//Custom Four +
		if (CustomDM == 7)
		{
		float cF = Far;
		float cN = Near;	
		depthR = log(depthR/cF)/log(cN/cF);
		}
		
		//Custom Four -
		if (CustomDM == 8)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1 - log(depthR/cF)/log(cN/cF);
		}
		
		//Custom Five +
		if (CustomDM == 9)
		{
		float cF = Far;
		float cN = Near;
		depthR = (cF) / (cF - depthR * ((1 - cN) / (cF - cN * depthR)) * (cF - 1));
		}
		
		//Custom Five -
		if (CustomDM == 10)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1 - (cF) / (cF - depthR * ((1 - cN) / (cF - cN * depthR)) * (cF - 1));
		}
		
		//Custom Six +
		if (CustomDM == 11)
		{
		float cF = Far;
		float cN = Near;
		depthR = (cN - depthR * cN) + (depthR*cF);
		}
		
		//Custom Six -
		if (CustomDM == 12)
		{
		float cF = Far;
		float cN = Near;
		depthR = 1 - (cN - depthR * cN) + (depthR*cF);
		}
	}

    float4 DR = depthR;	

	if(!AltRender)
	{
		if (EyeSwap)
		{
		color.r = 1 - DR.r;
		}
		else
		{
		color.r = DR.r;
		}
	}
	else
	{
		if (EyeSwap)
		{
		color.r = DR.r;
		}
		else
		{
		color.r = 1 - DR.r;
		}
	}
	return color.r;	
	}
	
/////////////////////////////////////////L/R/DepthMap Pos//////////////////////////////////////////////////////////
	void  PS_calcLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
	{
		if(!AltRender)
	{
	float NegDepth = -Depth;
	float LeftDepth = Depth/2+WA;
	float RightDepth = Depth/2+WA;
	color.r =  texcoord.x-NegDepth*pix.x*SbSdepthR(float2(texcoord.x+RightDepth*pix.x,texcoord.y));
	color.gb =  texcoord.x-Depth*pix.x*SbSdepthL(float2(texcoord.x-LeftDepth*pix.x,texcoord.y));
	}
	else
	{
	float NegDepth = -Depth;
	float LeftDepth = Depth/2+WA;
	float RightDepth = Depth/2+WA;
	color.r =  texcoord.x-NegDepth*pix.x*SbSdepthL(float2(texcoord.x+RightDepth*pix.x,texcoord.y));
	color.gb =  texcoord.x-Depth*pix.x*SbSdepthR(float2(texcoord.x-LeftDepth*pix.x,texcoord.y));
	}
	}

////////////////////////////////////////////////Left Eye////////////////////////////////////////////////////////
void PS_renderL(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
		if(!AltRender)
		{
		color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y)).rgb;

		//Left
		int x = 20 % 1023;
		[loop]
		for (int j = 0; j <= x; j++) 
		{
			if (tex2D(SamplerCC, float2(texcoord.x-j*pix.x,texcoord.y)).b <= texcoord.x-pix.x && tex2D(SamplerCC, float2(texcoord.x+j*pix.x,texcoord.y)).b <= texcoord.x+pix.x ) 
			{	
				color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x+j*pix.x,texcoord.y)).rgb;
			}
		}
	}
	else
	{
			color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y)).rgb;
			
		//AltRight
		int x = 20 % 1023;
		[loop]
		for (int j = 0; j <= x; j++) 
		{
			if (tex2D(SamplerCC, float2(texcoord.x-j*pix.x,texcoord.y)).b <= texcoord.x+pix.x && tex2D(SamplerCC, float2(texcoord.x+j*pix.x,texcoord.y)).b <= texcoord.x+pix.x) 
			{
				color.rgb =  tex2D(ReShade::BackBuffer, float2(texcoord.x+j*pix.x,texcoord.y)).rgb;
			}
		}
	}
}


//////////////////////////////////////////Right Eye/////////////////////////////////////////////////////////////
void PS_renderR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
		if(!AltRender)
		{
		color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y)).rgb;
		
		//Right
		int x = 20 % 1023;
		[loop]
	for (int j = 0; j >= -x; --j) 
	{
			if (tex2D(SamplerCC, float2(texcoord.x-j*pix.x,texcoord.y)).r >= texcoord.x+pix.x && tex2D(SamplerCC, float2(texcoord.x+j*pix.x,texcoord.y)).r >= texcoord.x+pix.x) 
			{
				color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x+j*pix.x, texcoord.y)).rgb;
			}
		}
	}
	else
	{
			color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y)).rgb;
					
		//AltLeft
		int x = 20 % 1023;
		[loop]
	for (int j = 0; j >= -x; --j) 
	{
			if (tex2D(SamplerCC, float2(texcoord.x-j*pix.x,texcoord.y)).r >= texcoord.x-pix.x && tex2D(SamplerCC, float2(texcoord.x+j*pix.x,texcoord.y)).r >= texcoord.x+pix.x) 
			{		
				color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x+j*pix.x, texcoord.y)).rgb;
			}
		}
	}
}

//////////////////////////////////////////////////////Barrle_Distortion/////////////////////////////////////////////////////
float3 BDL(float2 texcoord)

{
	float k = K;
	float kcube = KCube;

	float r2 = (texcoord.x-0.5) * (texcoord.x-0.5) + (texcoord.y-0.5) * (texcoord.y-0.5);       
	float f = 0.0;

	f = 1 + r2 * (k + kcube * sqrt(r2));

	float x = f*(texcoord.x-0.5)+0.5;
	float y = f*(texcoord.y-0.5)+0.5;
	float pos = Hsquish-1;
	float mid = pos*1024*pix.y;
	float3 BDListortion = tex2D(SamplerCL,float2(x,(y*Hsquish)-mid)).rgb;

	return BDListortion.rgb;
}

float3 BDR(float2 texcoord)

{
	float k = K;
	float kcube = KCube;

	float r2 = (texcoord.x-0.5) * (texcoord.x-0.5) + (texcoord.y-0.5) * (texcoord.y-0.5);       
	float f = 0.0;

	f = 1 + r2 * (k + kcube * sqrt(r2));

	float x = f*(texcoord.x-0.5)+0.5;
	float y = f*(texcoord.y-0.5)+0.5;
	float pos = Hsquish-1;
	float mid = pos*1024*pix.y;
	float3 BDRistortion = tex2D(SamplerCR,float2(x,(y*Hsquish)-mid)).rgb;

	return BDRistortion.rgb;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 pos : SV_Position, float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
	if(BD)
	{
		if(!AltRender)
		{
		color = texcoord.x < 0.5 ? BDL(float2(texcoord.x*2 + Perspective * pix.x,texcoord.y)).rgb : BDR(float2(texcoord.x*2-1 - Perspective * pix.x,texcoord.y)).rgb;
		}
		else
		{
		color = texcoord.x > 0.5 ? BDL(float2(texcoord.x*2-1 + Perspective * pix.x,texcoord.y)).rgb : BDR(float2(texcoord.x*2 - Perspective * pix.x,texcoord.y)).rgb;
		}
	}
	else
	{
		if(!AltRender)
		{
		color = texcoord.x < 0.5 ? tex2D(SamplerCL, float2(texcoord.x*2 + Perspective * pix.x, texcoord.y)).rgb : tex2D(SamplerCR, float2(texcoord.x*2-1 - Perspective * pix.x, texcoord.y)).rgb;
		}
		else
		{
		color = texcoord.x > 0.5 ? tex2D(SamplerCL, float2(texcoord.x*2-1 + Perspective * pix.x, texcoord.y)).rgb : tex2D(SamplerCR, float2(texcoord.x*2 - Perspective * pix.x, texcoord.y)).rgb;
		}
	}
}

///////////////////////////////////////////////Depth Map View//////////////////////////////////////////////////////////////////////

float4 PS(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
		
	float4 color = tex2D(SamplerCC, texcoord);
		
		
		if (DepthFlip)
		texcoord.y = 1 - texcoord.y;
		
		float4 depthM = ReShade::GetLinearizedDepth(texcoord.xy);
		
		if (CustomDM == 0)
	{	
		//Naruto
		if (AltDepthMap == 0)
		{
		depthM = (pow(abs(depthM),0.75));
		}
		
		//Batman Games
		if (AltDepthMap == 1)
		{
		float cF = 5;
		float cN = 0;
		depthM = (cN - depthM * cN) + (depthM * cF);
		}
		
		////Quake 2 XP
		if (AltDepthMap == 2)
		{
		float cF  = 0.01;
		float cN = 0;
		depthM = 1 - (cF * 1/depthM + cN);
		}
		
		//The Evil Within
		if (AltDepthMap == 3)
		{
		float cF = 1.5;
		float cN = 0;
		depthM = (cN - depthM * cN) + (depthM*cF);
		}
		
		//Sleeping Dogs:  DE
		if (AltDepthMap == 4)
		{
		float zF = 1.0;
		float zN = 0.025;
		depthM = 1 - (zF * zN / (zN + depthM * (zF - zN)) + pow(abs(depthM*depthM),1.0));
		}

		//Call of Duty: Advance Warfare
		if (AltDepthMap == 5)
		{
		float cF  = 0.00001;
		float cN = 0;
		depthM = (cF * 1/depthM + cN);
		}
		
		//Lords of the Fallen
		if (AltDepthMap == 6)
		{
		float cF  = 1.027;
		float cN = 0;
		depthM = 1 - (1 - cF) / (cN - cF * depthM); 
		}
		
		//Shadow Warrior
		if (AltDepthMap == 7)
		{
		float cF = 10;
		float cN = 0;
		depthM = (cN - depthM * cN) + (depthM*cF);
		}
		
		//Rage
		if (AltDepthMap == 8)
		{
		float LinLog = 0.005;
		depthM = (1 - (LinLog) / (LinLog - depthM * 1.5 * (LinLog -  0.05)))+(pow(abs(depthM*depthM),3.5));
		}
		
		//Assassin Creed Unity
		if (AltDepthMap == 9)
		{
		float cF = 25000;
		float cN = 1;
		depthM = 1-(-0+(pow(abs(depthM),cN))*cF);
		}
		
		//Skyrim | Deadly Premonition: The Directors's Cut
		if (AltDepthMap == 10)
		{
		float cF = 0.2;
		float cN = 0;
		depthM = 1 - (cF) / (cF - depthM * ((1 - cN) / (cF - cN * depthM)) * (cF - 1));
		}
		
		//Dying Light
		if (AltDepthMap == 11)
		{
		float zF = 1.0;
		float zN = 0.000025;
		float vF = 0.05;	
		depthM = (zF * zN / (zN + depthM * 1 * (zF - zN)))-(pow(abs(depthM*depthM),vF));
		}

		//Witcher 3
		if (AltDepthMap == 12)
		{
		float zF = 1.0;
		float zN = 0.00005;
		float vF = 0.110;	
		depthM = (zF * zN / (zN + depthM * 1 * (zF - zN)))-(pow(abs(depthM*depthM),vF));
		}
		
		//Fallout 4
		if (AltDepthMap == 13)
		{
		float cF = 25;
		float cN = 1;
		depthM = (-0+(pow(abs(depthM),cN))*cF);
		}
		
		//Magicka 2
		if (AltDepthMap == 14)
		{
		float cF = 0.001;
		float cM = 0;
		float cN = 0.250;
		depthM = (1 * cF / (cF + depthM * (depthM+cM) * (1 - cF))) / (pow(abs(depthM),cN));
		}
		
		//Dragon Dogma
		if (AltDepthMap == 15)
		{
		float cN = -0.02;
		float cF  = 1.025;
		depthM = 1 - (1 - cF) / (cN - cF * depthM); 
		}
		
		//Among The Sleep
		if (AltDepthMap == 16)
		{
		float cF = 1.0;
		float cN = 0.010;	
		depthM = 1 - log(depthM/cF)/log(cN/cF);
		}
		
		//Return to Castle Wolfensitne
		if (AltDepthMap == 17)
		{
		float cF = 0.1;
		float cM = 1.0;
		float cN = 0;
		depthM = 1 - (1 * cF / (cF + depthM * (depthM+cM) * (1 - cF))) / (pow(abs(depthM),cN));
		}	
		
		//Dreamfall Chapters
		if (AltDepthMap == 18)
		{
		float cF = 0.25;
		float cM = 15.0;
		float cN = 0.01;
		depthM = 1 - (1 * cF / (cF + depthM * (depthM+cM) * (1 - cF))) / (pow(abs(depthM),cN));
		}
				
		//CoD: Ghost
		if (AltDepthMap == 19)
		{
		float cF  = 0.00001;
		float cN = 0;
		depthM = (cF * 1/depthM + cN);
		}
		
		//Metro Redux Games | Borderlands 2
		if (AltDepthMap == 20)
		{
		float LinLog = 0.002;
		depthM = 1 - (LinLog) / (LinLog - depthM * depthM * (LinLog - 1));
		}
		
		//Souls Game
		if (AltDepthMap == 21)
		{
		float cF = 4.55;
		float cN = 2.0;
		depthM = 1 - (cN - depthM * cN) + (depthM*cF);
		}
	
		//Amnesia: The Dark Descent
		if (AltDepthMap == 22)
		{
		float cF  = 1.050;
		float cN = 0;
		depthM = 1 - (1 - cF) / (cN - cF * depthM); 
		}
		
		//Alien Isolation
		if (AltDepthMap == 23)
		{
		float cF = 20;
		float cN = 0;
		depthM = (cN - depthM * cN) + (depthM * cF);
		}
		
		//Dragon Ball Xeno
		if (AltDepthMap == 24)
		{
		float cF = 0.350;
		float cN = 0;
		depthM = 1 - (cF) / (cF - depthM * ((1 - cN) / (cF - cN * depthM)) * (cF - 1));
		}
	
	}
	else
	{
		//Custom One +
		if (CustomDM == 1)
		{
		float cF = Far;
		float cN = Near;
		depthM = (-0+(pow(abs(depthM),cN))*cF);
		}
		
		//Custom One -
		if (CustomDM == 2)
		{
		float cF = Far;
		float cN = Near;
		depthM = 1-(-0+(pow(abs(depthM),cN))*cF);
		}
		
		//Custom Two +
		if (CustomDM == 3)
		{
		float cF  = Far;
		float cN = Near;
		depthM = (1 - cF) / (cN - cF * depthM); 
		}
		
		//Custom Two -
		if (CustomDM == 4)
		{
		float cF  = Far;
		float cN = Near;
		depthM = 1 - (1 - cF) / (cN - cF * depthM); 
		}
		
		//Custom Three +
		if (CustomDM == 5)
		{
		float cF  = Far;
		float cN = Near;
		depthM = (cF * 1/depthM + cN);
		}
		
		//Custom Three -
		if (CustomDM == 6)
		{
		float cF  = Far;
		float cN = Near;
		depthM = 1 - (cF * 1/depthM + cN);
		}
		
		//Custom Four +
		if (CustomDM == 7)
		{
		float cF = Far;
		float cN = Near;	
		depthM = log(depthM/cF)/log(cN/cF);
		}
		
		//Custom Four -
		if (CustomDM == 8)
		{
		float cF = Far;
		float cN = Near;	
		depthM = 1 - log(depthM/cF)/log(cN/cF);
		}
		
		//Custom Five +
		if (CustomDM == 9)
		{
		float cF = Far;
		float cN = Near;
		depthM = (cF) / (cF - depthM * ((1 - cN) / (cF - cN * depthM)) * (cF - 1));
		}
		
		//Custom Five -
		if (CustomDM == 10)
		{
		float cF = Far;
		float cN = Near;
		depthM = 1 - (cF) / (cF - depthM * ((1 - cN) / (cF - cN * depthM)) * (cF - 1));
		}
		
		//Custom Six +
		if (CustomDM == 11)
		{
		float cF = Far;
		float cN = Near;
		depthM = (cN - depthM * cN) + (depthM * cF);
		}
		
		//Custom Six -
		if (CustomDM == 12)
		{
		float cF = Far;
		float cN = Near;
		depthM = 1 - (cN - depthM * cN) + (depthM * cF);
		}
	}
	
	float4 DM = depthM;
	
	if (DepthMap)
	{
	color.rgb = DM.rrr;				
	}
	return color;
	}

//*Rendering passes*//

technique Super_Depth3D
	{
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_calcLR;
			RenderTarget = texCC;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderL;
			RenderTarget = texCL;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderR;
			RenderTarget = texCR;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;
			RenderTarget = texCC;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS;
		}
	}
