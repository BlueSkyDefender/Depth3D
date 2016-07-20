 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.7 L & R Eye																															*//
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
 
uniform int AltDepthMap <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0Depth Map 11\0Depth Map 12\0Depth Map 13\0Depth Map 14\0Depth Map 15\0Depth Map 16\0Depth Map 17\0Depth Map 18\0Depth Map 19\0Depth Map 20\0Custom One\0Custom Two\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent AltDepthMap.";
> = 0;
uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 25;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes. Deviation Default is 15. To go beyond 25 max you need to enter your own number.";
> = 10;

uniform int Perspective <
	ui_type = "drag";
	ui_min = -25; ui_max = 25;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point.";
> = 0;

uniform int WA <
	ui_type = "drag";
	ui_min = -50; ui_max = 50;
	ui_label = "Warp Adjust";
	ui_tooltip = "Adjust the warp in the right eye.";
> = 0;

uniform int Pop <
	ui_type = "combo";
	ui_items = "Pop Off\0Pop +\0Pop ++\0Pop +++\0";
	ui_label = "Pop";
	ui_tooltip = "Test Adjustment.";
> = 0;

uniform bool DepthFlip <
	ui_items = "Off\0ON\0";
	ui_label = "Depth Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

uniform bool DepthMap <
	ui_items = "Off\0ON\0";
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform float Far <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
	ui_label = "Far";
	ui_tooltip = "Far Depth Map Adjustment.";
> = 0.050;
 
 uniform float Near <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
	ui_label = "Near";
	ui_tooltip = "Near Depth Map Adjustment.";
> = 1.25;

uniform bool EyeSwap <
	ui_items = "Off\0ON\0";
	ui_label = "Eye Swap";
	ui_tooltip = "Swap Left/Right to Right/Left and ViceVersa.";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#include "ReShade.fxh"

#define pix  	float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerCL
	{
		Texture = texCL;
	};
	
sampler SamplerCR
	{
		Texture = texCR;
	};
	
		sampler2D SamplerCC
	{
		Texture = texCC;
	};
	
	
//depth information
	float SbSdepth (float2 texcoord) 
	
	{

	 float4 color = tex2D(SamplerCC, texcoord);

			if (DepthFlip)
			texcoord.y =  1 - texcoord.y;


	float4 depthL = ReShade::GetLinearizedDepth(float2((texcoord.x*2), texcoord.y));


		//Naruto
		if (AltDepthMap == 0)
		{
		depthL = (pow(abs(depthL),0.75));
		}
		
		//Batman Games
		if (AltDepthMap == 1)
		{
		float LinLog = 0.05;
		depthL = 1 - (LinLog) / (LinLog - depthL / 62.5 *  (LinLog -  1)) + (pow(abs(depthL*3),0.25)-0.25);
		}
		
		//BorderLands 2
		if (AltDepthMap == 2)
		{
		float zF = 1;
		float zN = 0.001;
		depthL = 1 - (zF * zN / (zN + depthL * depthL * (zF - zN)));
		}
		
		//The Evil Within
		if (AltDepthMap == 3)
		{
		float LinLog = 1.00;
		depthL = 1 - (LinLog) / (LinLog - depthL * depthL * (LinLog -  25));
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
		float cF = 0.0000075;
		float cN = 1;
		float cC = 25;
		depthL = (cN * cF / (cF + depthL * 1 * (cN - cF))) + pow(abs(depthL*depthL),cC);
		}
		
		//Souls Game
		if (AltDepthMap == 6)
		{
		float zF = 5.0;
		float zN = 0.035;
		depthL = 1 - (zF * zN / (zN + depthL * 1 * (zF - zN))) + pow(abs(depthL*depthL),25);
		}
		
		//Shadow Warrior
		if (AltDepthMap == 7)
		{
		float zF = 1.15;
		float zN = 0.070;
		depthL = 1 - (zF * zN / (zN + depthL * 1 * (zF - zN)))+(pow(abs(depthL*depthL),5));
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
		float cF = 0.00000000015;
		float cM = 0.00001;
		float cN = 0.0001;
		depthL = (1 * cF / (cF + depthL * (depthL+cM) * (1 - cF))) / (pow(abs(depthL),cN));
		}

		// Skyrim | Deadly Premonition: The Directors's Cut | Alien Isolation
		if (AltDepthMap == 10)
		{
		float LinLog = 0.1;
		depthL = 1 - (LinLog) / (LinLog - depthL * depthL * (LinLog -  37.5));
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
		float cF = 0.002;
		float cM = 0;
		float cN = 0.0005;
		depthL = 1 - (1 * cF / (cF + depthL * (depthL+cM) * (1 - cF))) / (pow(abs(depthL),cN));
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
		float cF = 0.002;
		float cM = 0;
		float cN = -0.010;
		depthL = 1 - (1 * cF / (cF + depthL * (depthL+cM) * (1 - cF))) / (pow(abs(depthL),cN));
		}
		
		//Dragon Ball Xeno
		if (AltDepthMap == 16)
		{
		float cF = 0.010;
		float cM = 0;
		float cN = 0;
		depthL = 1 - (1 * cF / (cF + depthL * (depthL+cM) * (1 - cF))) / (pow(abs(depthL),cN));
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
		float cF = 0.000015;
		float cM = 0;
		float cN = 1.0;
		depthL = (1 * cF / (cF + (pow(abs(depthL+cM),cN)) * (1 - cF)));
		}
		
		//Metro Last Light
		if (AltDepthMap == 20)
		{
		float LinLog = 0.002;
		depthL = 1 - (LinLog) / (LinLog - depthL * depthL * (LinLog - 1));
		}
	
		//Custom One		
		if (AltDepthMap == 21)
		{
		float cF = Far;
		float cN = Near;
		float cC = 25;
		depthL = (cN * cF / (cF + depthL * 1 * (cN - cF))) + pow(abs(depthL*depthL),cC);
		}
		
		//Custom Two
		if (AltDepthMap == 22)
		{
		float cF = Far;
		float cN = Near;
		float cC = 25;
		depthL = 1 - (cN * cF / (cF + depthL * 1 * (cN - cF))) + pow(abs(depthL*depthL),cC);
		}

    float4 DL =  depthL;


	float4 depthR = ReShade::GetLinearizedDepth(float2((texcoord.x*2-1), texcoord.y));
		
		
		//Naruto
		if (AltDepthMap == 0)
		{
		depthR = (pow(abs(depthR),0.75));
		}
		
		//Batman Games
		if (AltDepthMap == 1)
		{
		float LinLog = 0.05;
		depthR = 1 - (LinLog) / (LinLog - depthR / 62.5 *  (LinLog -  1)) + (pow(abs(depthR*3),0.25)-0.25);
		}
		
		//BorderLands 2
		if (AltDepthMap == 2)
		{
		float zF = 1;
		float zN = 0.001;
		depthR = 1 - (zF * zN / (zN + depthR * depthR * (zF - zN)));
		}
		
		//The Evil Within
		if (AltDepthMap == 3)
		{
		float LinLog = 1.00;
		depthR = 1 - (LinLog) / (LinLog - depthR * depthR * (LinLog -  25));
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
		float cF = 0.0000075;
		float cN = 1;
		float cC = 25;
		depthR = (cN * cF / (cF + depthR * 1 * (cN - cF))) + pow(abs(depthR*depthR),cC);
		}
		
		//Souls Game
		if (AltDepthMap == 6)
		{
		float zF = 5.0;
		float zN = 0.035;
		depthR = 1 - (zF * zN / (zN + depthR * 1 * (zF - zN))) + pow(abs(depthR*depthR),25);
		}
		
		//Shadow Warrior
		if (AltDepthMap == 7)
		{
		float zF = 1.15;
		float zN = 0.070;
		depthR = 1 - (zF * zN / (zN + depthR * 1 * (zF - zN)))+(pow(abs(depthR*depthR),5));
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
		float cF = 0.00000000015;
		float cM = 0.00001;
		float cN = 0.0001;
		depthR = (1 * cF / (cF + depthR * (depthR+cM) * (1 - cF))) / (pow(abs(depthR),cN));
		}

		// Skyrim | Deadly Premonition: The Directors's Cut | Alien Isolation
		if (AltDepthMap == 10)
		{
		float LinLog = 0.1;
		depthR = 1 - (LinLog) / (LinLog - depthR * depthR * (LinLog -  37.5));
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
		float cF = 0.002;
		float cM = 0;
		float cN = 0.0005;
		depthR = 1 - (1 * cF / (cF + depthR * (depthR+cM) * (1 - cF))) / (pow(abs(depthR),cN));
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
		float cF = 0.002;
		float cM = 0;
		float cN = -0.010;
		depthR = 1 - (1 * cF / (cF + depthR * (depthR+cM) * (1 - cF))) / (pow(abs(depthR),cN));
		}
		
		//Dragon Ball Xeno
		if (AltDepthMap == 16)
		{
		float cF = 0.010;
		float cM = 0;
		float cN = 0;
		depthR = 1 - (1 * cF / (cF + depthR * (depthR+cM) * (1 - cF))) / (pow(abs(depthR),cN));
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
		float cF = 0.000015;
		float cM = 0;
		float cN = 1.0;
		depthR = (1 * cF / (cF + (pow(abs(depthR+cM),cN)) * (1 - cF)));
		}
		
		//Metro Last Light
		if (AltDepthMap == 20)
		{
		float LinLog = 0.002;
		depthR = 1 - (LinLog) / (LinLog - depthR * depthR * (LinLog - 1));
		}
	
		//Custom One		
		if (AltDepthMap == 21)
		{
		float cF = Far;
		float cN = Near;
		float cC = 25;
		depthR = (cN * cF / (cF + depthR * 1 * (cN - cF))) + pow(abs(depthR*depthR),cC);
		}
		
		//Custom Two
		if (AltDepthMap == 22)
		{
		float cF = Far;
		float cN = Near;
		float cC = 25;
		depthR = 1 - (cN * cF / (cF + depthR * 1 * (cN - cF))) + pow(abs(depthR*depthR),cC);
		}

    float4 DR = depthR;	
     
     if (EyeSwap)
	{
    color.r = texcoord.x < 0.5 ? 1 - DL.r : 1 - DR.r;
	}
	else
	{
    color.r = texcoord.x < 0.5 ?  DL.r : DR.r;
	}	
	return color.r;	
	}


	void  PS_calcLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
	{
	float NegDepth = -Depth;
	float LeftDepth = Depth/5+WA;
	float RightDepth = Depth/5-WA;
	color.r = texcoord.x-NegDepth*pix.x*SbSdepth(float2(texcoord.x+RightDepth*pix.x,texcoord.y));
	color.gb = texcoord.x-Depth*pix.x*SbSdepth(float2(texcoord.x-LeftDepth*pix.x,texcoord.y));
	}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////

	void PS_renderL(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
	{
		color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x*2, texcoord.y)).rgb;

		[loop]
		for (int j = 0; j <= 15; j++) 
		{
			if (tex2D(SamplerCC, float2((texcoord.x < 0.5)+j*pix.x,texcoord.y)).b >= texcoord.x-pix.x/2 && tex2D(SamplerCC, float2(texcoord.x+j*pix.x,texcoord.y)).b <= texcoord.x+pix.x/2) 
			{
			
			float pop = 1;
			
			if (Pop == 0)		
				pop = 1;
			else if (Pop == 1)	
				pop = 0.9375;
			else if (Pop == 2)
				pop = 0.875;
			else if (Pop == 3)
				pop = 0.75;
					
				color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x*2+j*pix.x/pop,texcoord.y)).rgb;
			}
		}
	}

	void PS_renderR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
	{
		color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x*2-1, texcoord.y)).rgb;

		[loop]
	for (int j = 0; j >= -15; --j) 
	{
			if (tex2D(SamplerCC, float2((texcoord.x > 0.5)-j*pix.x,texcoord.y)).r >= texcoord.x-pix.x/2 && tex2D(SamplerCC, float2(texcoord.x+j*pix.x,texcoord.y)).r >= texcoord.x-pix.x/2)   
		{
			
			float pop = 1;
			
			if (Pop == 0)		
				pop = 1;
			else if (Pop == 1)	
				pop = 0.9375;
			else if (Pop == 2)
				pop = 0.875;
			else if (Pop == 3)
				pop = 0.75;
					
				color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x*2-1+j*pix.x/pop, texcoord.y)).rgb;
			}
		}
	}



void PS0(float4 pos : SV_Position, float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{
		
color = texcoord.x < 0.5 ? tex2D(SamplerCL, float2(texcoord.x - Perspective * pix.x, texcoord.y)).rgb : tex2D(SamplerCR, float2(texcoord.x + Perspective * pix.x, texcoord.y)).rgb;

}

///////////////////////////////////////////////Depth Map View//////////////////////////////////////////////////////////////////////

float4 PS(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
		
	float4 color = tex2D(SamplerCC, texcoord);
		
		
		if (DepthFlip)
		texcoord.y = 1 - texcoord.y;
		
		float4 depthM = ReShade::GetLinearizedDepth(texcoord.xy);
		
		//Naruto
		if (AltDepthMap == 0)
		{
		depthM = (pow(abs(depthM),0.75));
		}
		
		//Batman Games
		if (AltDepthMap == 1)
		{
		float LinLog = 0.05;
		depthM = 1 - (LinLog) / (LinLog - depthM / 62.5 *  (LinLog -  1)) + (pow(abs(depthM*3),0.25)-0.25);
		}
		
		//BorderLands 2
		if (AltDepthMap == 2)
		{
		float zF = 1;
		float zN = 0.001;
		depthM = 1 - (zF * zN / (zN + depthM * depthM * (zF - zN)));
		}
		
		//The Evil Within
		if (AltDepthMap == 3)
		{
		float LinLog = 1.00;
		depthM = 1 - (LinLog) / (LinLog - depthM * depthM * (LinLog -  25));
		}
		
		//Sleeping Dogs:  DE
		if (AltDepthMap == 4)
		{
		float zF = 1.0;
		float zN = 0.025;
		depthM = 1 - (zF * zN / (zN + depthM * (zF - zN)) + pow(abs(depthM*depthM),1.0));
		}

		//Lords of the Fallen
		if (AltDepthMap == 5)
		{
		float cF = 0.0000075;
		float cN = 1;
		float cC = 25;
		depthM = (cN * cF / (cF + depthM * 1 * (cN - cF))) + pow(abs(depthM*depthM),cC);
		}
		
		//Souls Game
		if (AltDepthMap == 6)
		{
		float zF = 5.0;
		float zN = 0.035;
		depthM = 1 - (zF * zN / (zN + depthM * 1 * (zF - zN))) + pow(abs(depthM*depthM),25);
		}
		
		//Shadow Warrior
		if (AltDepthMap == 7)
		{
		float zF = 1.15;
		float zN = 0.070;
		depthM = 1 - (zF * zN / (zN + depthM * 1 * (zF - zN)))+(pow(abs(depthM*depthM),5));
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
		float cF = 0.00000000015;
		float cM = 0.00001;
		float cN = 0.0001;
		depthM = (1 * cF / (cF + depthM * (depthM+cM) * (1 - cF))) / (pow(abs(depthM),cN));	
		}
		
		//Magicka 2 | Skyrim | Deadly Premonition: The Directors's Cut| Alien Isolation
		if (AltDepthMap == 10)
		{
		float LinLog = 0.1;
		depthM = 1 - (LinLog) / (LinLog - depthM * depthM * (LinLog -  37.5));
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
		float cF = 0.002;
		float cM = 0;
		float cN = 0.0005;
		depthM = 1 - (1 * cF / (cF + depthM * (depthM+cM) * (1 - cF))) / (pow(abs(depthM),cN));
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
		float cF = 0.002;
		float cM = 0;
		float cN = -0.010;
		depthM = 1 - (1 * cF / (cF + depthM * (depthM+cM) * (1 - cF))) / (pow(abs(depthM),cN));
		}
		
		//Dragon Ball Xeno
		if (AltDepthMap == 16)
		{
		float cF = 0.010;
		float cM = 0;
		float cN = 0;
		depthM = 1 - (1 * cF / (cF + depthM * (depthM+cM) * (1 - cF))) / (pow(abs(depthM),cN));
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
		float cF = 0.000015;
		float cM = 0;
		float cN = 1.0;
		depthM = (1 * cF / (cF + (pow(abs(depthM+cM),cN)) * (1 - cF)));
		}
		
		//Metro Last Light
		if (AltDepthMap == 20)
		{
		float LinLog = 0.002;
		depthM = 1 - (LinLog) / (LinLog - depthM * depthM * (LinLog - 1));
		}
		
		//Custom One		
		if (AltDepthMap == 21)
		{
		float cF = Far;
		float cN = Near;
		float cC = 25;
		depthM = (cN * cF / (cF + depthM * 1 * (cN - cF))) + pow(abs(depthM*depthM),cC);
		}
		
		//Custom Two
		if (AltDepthMap == 22)
		{
		float cF = Far;
		float cN = Near;
		float cC = 25;
		depthM = 1 - (cN * cF / (cF + depthM * 1 * (cN - cF))) + pow(abs(depthM*depthM),cC);
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
