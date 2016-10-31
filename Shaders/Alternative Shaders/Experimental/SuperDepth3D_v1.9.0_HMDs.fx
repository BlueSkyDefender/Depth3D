 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.0																																	*//
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
 //* Original work was based on Shader Based on CryTech 3 Dev work http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology								*//
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Change the Cross Cusor Key
// Determines the Cusor Toggle Key useing keycode info
// You can use http://keycode.info/ to figure out what key is what.
// key B is Key Code 66, This is Default. Ex. Key 187 is the code for Equal Sign =.

#define Cross_Cusor_Key 66

uniform int Alternate_Depth_Map <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0Depth Map 11\0Depth Map 12\0Depth Map 13\0Depth Map 14\0Depth Map 15\0Depth Map 16\0Depth Map 17\0Depth Map 18\0Depth Map 19\0Depth Map 20\0Depth Map 21\0Depth Map 22\0Depth Map 23\0Depth Map 24\0Depth Map 25\0Depth Map 26\0Depth Map 27\0Depth Map 28\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent Alternet Depth Map.";
> = 0;

uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 50;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes. You can Override this setting.";
> = 25;

uniform float Convergence <
	ui_type = "drag";
	ui_min = -0.250; ui_max = 0.250;
	ui_label = "Convergence Slider";
	ui_tooltip = "Determines the Convergence point. Default is 0";
> = 0;

uniform int IPD <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Optical Pupillary Distance Adjust";
	ui_tooltip = "Determines the distance between your eyes. Default is 0";
> = 0;

uniform bool Depth_Map_Enhancement <
	ui_label = "Depth Map Enhancement";
	ui_tooltip = "Enable Or Dissable Depth Map Enhancement. Default is Off";
> = 0;

uniform float Adjust <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 1.5;
	ui_label = "Adjust";
	ui_tooltip = "Adjust DepthMap Enhancement, Dehancement occurs past one. Default is 1.0";
> = 1.0;

uniform bool Depth_Map_Clamp <
	ui_label = "Depth Map Clamp";
	ui_tooltip = "Clamps Min and Max setting of Your Depth Map, you may want to turn this on if going pass 25 Depth. Default is Off";
> = 0;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

uniform int Custom_Depth_Map <
	ui_type = "combo";
	ui_items = "Custom Off\0Custom One\0Custom Two\0Custom Three\0Custom Four\0Custom Five\0Custom Six\0Custom Seven\0Custom Eight\0Custom Nine\0Custom Ten\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Adjust your own Custom Depth Map.";
> = 0;

uniform float2 Near_Far <
	ui_type = "drag";
	ui_min = 0; ui_max = 100;
	ui_label = "Near & Far";
	ui_tooltip = "Adjustment for Near and Far Depth Map Precision.";
> = float2(1,1.5);

uniform int Polynomial_Barrel_Distortion <
	ui_type = "combo";
	ui_items = "Off\0Polynomial Distortion\0";
	ui_label = "Polynomial Barrel Distortion";
	ui_tooltip = "Barrel Distortion for HMD type Displays.";
> = 0;

uniform float Lens_Center <
	ui_type = "drag";
	ui_min = 0.475; ui_max = 0.575;
	ui_label = "Lens Center";
	ui_tooltip = "Adjust Lens Center. Default is 0.5";
> = 0.5;

uniform float Lens_Distortion <
	ui_type = "drag";
	ui_min = -1; ui_max = 5;
	ui_label = "Lens Distortion";
	ui_tooltip = "Lens distortion value.";
> = 0.0;

uniform float3 Polynomial_Colors <
	ui_type = "color";
	ui_tooltip = "Adjust the Polynomial Distortion Red, Green, Blue. Default is (R 255, G 255, B 255)";
	ui_label = "Polynomial Color Distortion";
> = float3(1.0, 1.0, 1.0);

uniform float2 Horizontal_Vertical_Squish <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2;
	ui_label = "Horizontal & Vertical";
	ui_tooltip = "Adjust Horizontal and Vertical squish cubic distortion value. Default is 1.0.";
> = float2(1,1);

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Select how you like the Edge of the screen to look like.";
> = 1;

uniform float Cross_Cusor_Size <
	ui_type = "drag";
	ui_min = 1; ui_max = 100;
	ui_tooltip = "Pick your size of the cross cusor. Default is 25";
	ui_label = "Cross Cusor Size";
> = 25.0;

uniform float3 Cross_Cusor_Color <
	ui_type = "color";
	ui_tooltip = "Pick your own cross cusor color. Default is (R 255, G 255, B 255)";
	ui_label = "Cross Cusor Color";
> = float3(1.0, 1.0, 1.0);

uniform bool Eye_Swap <
	ui_label = "Eye Swap";
	ui_tooltip = "Left right image change.";
> = false;

uniform int HMD_Profiles <
	ui_type = "combo";
	ui_items = "Off\0Profile One\0";
	ui_label = "Head Mounted Display Profiles";
	ui_tooltip = "Preset Head Mounted Display Profiles";
> = 0;

uniform bool mouse < source = "key"; keycode = Cross_Cusor_Key; toggle = true; >;

uniform float2 Mousecoords < source = "mousepoint"; > ;



////////////////////////////////////////////////HMD Profiles/////////////////////////////////////////////////////////////////
//Lens Distortion Area//
float LD()
{
float L_D = Lens_Distortion;
if (HMD_Profiles == 0)
{
 L_D;
}

if (HMD_Profiles == 1)
{
 L_D = -0.5;
}
return L_D;
}

//Horizontal Vertical Squish Area//
float2 H_V_S()
{
float2 H_V_S = Horizontal_Vertical_Squish;
if (HMD_Profiles == 0)
{
 H_V_S;
}

if (HMD_Profiles == 1)
{
 H_V_S = float2(1,1.25);
}
return H_V_S;
}

//float2 Horizontal_Vertical_Squish = float2(1,1.25);

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
	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCC  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA8;}; 
texture texCDM  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA8;};
	
sampler SamplerCLMIRROR
	{
		Texture = texCL;
		AddressU = MIRROR;
		AddressV = MIRROR;
		AddressW = MIRROR;
	};
	
sampler SamplerCLBORDER
	{
		Texture = texCL;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

sampler SamplerCLCLAMP
	{
		Texture = texCL;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};

sampler SamplerCRMIRROR
	{
		Texture = texCR;
		AddressU = MIRROR;
		AddressV = MIRROR;
		AddressW = MIRROR;
	};
	
sampler SamplerCRBORDER
	{
		Texture = texCR;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
sampler SamplerCRCLAMP
	{
		Texture = texCR;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
sampler SamplerCC
	{
		Texture = texCC;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
sampler SamplerCDM
	{
		Texture = texCDM;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
float4 MouseCuror(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 Mpointer; 
	if(mouse)
	{
	Mpointer = all(abs(Mousecoords - pos.xy) < Cross_Cusor_Size) * (1 - all(abs(Mousecoords - pos.xy) > Cross_Cusor_Size/(Cross_Cusor_Size/2))) ? float4(Cross_Cusor_Color, 1.0) : tex2D(BackBuffer, texcoord);//cross
	}
	else
	{
	Mpointer =  tex2D(BackBuffer, texcoord);
	}
	return Mpointer;
}

//Depth Map Information	
float4 SbSdepth(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{

	 float4 color = 0;

			if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
	
	float4 depthM = tex2D(DepthBuffer, float2(texcoord.x, texcoord.y));
	
	float4 depthMFar;
		
		if (Custom_Depth_Map == 0)
	{	
		//Alien Isolation | Fallout 4 | Firewatch
		if (Alternate_Depth_Map == 0)
		{
		float cF = 1000000000;
		float cN = 1;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Amnesia: The Dark Descent
		if (Alternate_Depth_Map == 1)
		{
		float cF = 1000;
		float cN = 1;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Among The Sleep | Soma
		if (Alternate_Depth_Map == 2)
		{
		float cF = 10;
		float cN = 0.05;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//The Vanishing of Ethan Carter Redux
		if (Alternate_Depth_Map == 3)
		{
		float cF  = 0.0075;
		float cN = 1;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Batman Arkham Knight | Batman Arkham Origins | Batman: Arkham City | BorderLands 2 | Hard Reset | Lords Of The Fallen | The Elder Scrolls V: Skyrim
		if (Alternate_Depth_Map == 4)
		{
		float cF = 50;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Call of Duty: Advance Warfare | Call of Duty: Black Ops 2 | Call of Duty: Ghost
		if (Alternate_Depth_Map == 5)
		{
		float cF  = 0.01;
		float cN = 1;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Casltevania: Lord of Shadows - UE | Dead Rising 3
		if (Alternate_Depth_Map == 6)
		{
		float cF = 25;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Condemned: Criminal Origins | Rage | Return To Castle Wolfenstine | The Evil Within | Quake 4
		if (Alternate_Depth_Map == 7)
		{
		float cF  = 1;
		float cN = 0.0025;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Deadly Premonition:The Directors's Cut
		if (Alternate_Depth_Map == 8)
		{
		float cF = 30;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Dragon Ball Xenoverse | Quake 2 XP
		if (Alternate_Depth_Map == 9)
		{
		float cF = 1;
		float cN = 0.005;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Warhammer: End Times - Vermintide
		if (Alternate_Depth_Map == 10)
		{
		float cF = 1;	
		float cN = 5.5;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Dying Light
		if (Alternate_Depth_Map == 11)
		{
		float cF = 100;
		float cN = 0.005;
		depthM = cF / (1 + cF - (depthM/cN) * (1 - cF));
		}
		
		//GTA V
		if (Alternate_Depth_Map == 12)
		{
		float cF  = 10000; 
		float cN = 0.0075; 
		depthM = cF / (1 + cF - (depthM/cN) * (1 - cF));
		}
		
		//Magicka 2
		if (Alternate_Depth_Map == 13)
		{
		float cF = 1.025;
		float cN = 0.025;	
		depthM = clamp(pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000)/0.5,0,1.25);
		}
		
		//Middle-earth: Shadow of Mordor
		if (Alternate_Depth_Map == 14)
		{
		float cF = 650;
		float cN = 651;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Naruto Shippuden UNS3 Full Blurst
		if (Alternate_Depth_Map == 15)
		{
		float cF = 150;
		float cN = 0.001;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Shadow warrior(2013)XP
		if (Alternate_Depth_Map == 16)
		{
		float cF = 5;
		float cN = 0.05;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Ryse: Son of Rome
		if (Alternate_Depth_Map == 17)
		{
		float cF = 1.010;
		float cN = 0;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Sleeping Dogs: DE | DreamFall Chapters
		if (Alternate_Depth_Map == 18)
		{
		float cF  = 1;
		float cN = 0.025;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Souls Games
		if (Alternate_Depth_Map == 19)
		{
		float cF = 1.050;
		float cN = 0.025;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Witcher 3
		if (Alternate_Depth_Map == 20)
		{
		float cF = 7.5;
		float cN = 1;	
		depthM = (pow(abs(cN-depthM),cF));
		}

		//Assassin Creed Unity | Just Cause 3
		if (Alternate_Depth_Map == 21)
		{
		float cF = 150;
		float cN = 151;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}	
		
		//Silent Hill: Homecoming
		if (Alternate_Depth_Map == 22)
		{
		float cF = 25;
		float cN = 25.869;
		depthM = clamp(1 - (depthM * cF / (cF - cN) + cN) / depthM,0,255);
		}
		
		//Monstrum DX11
		if (Alternate_Depth_Map == 23)
		{
		float cF = 1.075;	
		float cN = 0;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Serious Sam Revolution
		if (Alternate_Depth_Map == 24)
		{
		float cF = 1.01;	
		float cN = 0;	
		depthM = clamp(pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000)/0.5,0,1.25);
		}
		
		//Double Dragon Neon
		if (Alternate_Depth_Map == 25)
		{
		float cF = 0.025;//1
		float cN = 0.16;//1.875
		depthM = clamp(1 - (depthM * cF / (cF - cN) + cN) / depthM,0,255);
		}
		
		//Deus Ex: Mankind Divided
		if (Alternate_Depth_Map == 26)
		{
		float cF = 250;
		float cN = 251;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}	
		
		//Skyrim SE
		if (Alternate_Depth_Map == 27)
		{
		float cF = 5;
		float cN = 5;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Doom
		if (Alternate_Depth_Map == 28)
		{
		float cF = 50;
		float cN = -0.5;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
	}
	else
	{
	
		//Custom One
		if (Custom_Depth_Map == 1)
		{
		float cF = Near_Far.y; //10+
		float cN = Near_Far.x;//1
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Custom Two
		if (Custom_Depth_Map == 2)
		{
		float cF  = Near_Far.y; //100+
		float cN = Near_Far.x; //0.01-
		depthM = cF / (1 + cF - (depthM/cN) * (1 - cF));
		}
		
		//Custom Three
		if (Custom_Depth_Map == 3)
		{
		float cF  = Near_Far.y;//0.025
		float cN = Near_Far.x;//1.0
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Custom Four
		if (Custom_Depth_Map == 4)
		{
		float cF = Near_Far.y;//1000000000 or 1	
		float cN = Near_Far.x;//0 or 13	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Custom Five
		if (Custom_Depth_Map == 5)
		{
		float cF = Near_Far.y;//1
		float cN = Near_Far.x;//0.025
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Custom Six
		if (Custom_Depth_Map == 6)
		{
		float cF = Near_Far.y;//1
		float cN = Near_Far.x;//1.875
		depthM = clamp(1 - (depthM * cF / (cF - cN) + cN) / depthM,0,255); //Infinite reversed-Z. Clamped, not so Infinate anymore.
		}
		
		//Custom Seven
		if (Custom_Depth_Map == 7)
		{
		float cF = Near_Far.y;//1.01	
		float cN = Near_Far.x;//0	
		depthM = clamp(pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000)/0.5,0,1.25);
		}
		
		//Custom Eight
		if (Custom_Depth_Map == 8)
		{
		float cF = Near_Far.y;//1.010+	or 150
		float cN = Near_Far.x;//0 or	151
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Custom Nine
		if (Custom_Depth_Map == 9)
		{
		float cF = Near_Far.y;
		float cN = Near_Far.x;
		depthM = log(depthM / cN) / log(cF / cN);
		}
		
		//Custom Ten
		if (Custom_Depth_Map == 10)
		{
		float cF = Near_Far.y;//5
		float cN = Near_Far.x;//5
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
	}
		
	float4 D;
	
	if(Depth_Map_Enhancement == 0)
    {
    D = depthM;	
    }
    else
    {
    float A = Adjust;
	float cDF = 1.025;
	float cDN = 0;
	depthMFar = pow(abs((exp(depthM * log(cDF + cDN)) - cDN) / cDF),1000);	
    D = lerp(depthMFar,depthM,A);	
    }
    
    if(Depth_Map_Clamp == 1)
	{
  	color.rgb = clamp(D.rrr,0,1);
	}
	else
	{
	color.rgb = D.rrr;
	}
	
	return color;	

}
  
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	
	const float samples[4] = {0.25, 0.50, 0.75, 1};
	float DepthL = 1.0, DepthR = 1.0;
	float C = Convergence;
	float D = Depth;
	float2 uv = 0;
	[loop]
	for (int j = 0; j <= 3; ++j) 
	{	
			uv.x = samples[j] * D;
			DepthL =  min(DepthL,tex2D(SamplerCDM,float2(texcoord.x+uv.x*pix.x, texcoord.y)).r);
			DepthR =  min(DepthR,tex2D(SamplerCDM,float2(texcoord.x-uv.x*pix.x, texcoord.y)).r);
	}
		if(!Eye_Swap)
		{	
			if(Custom_Sidebars == 0)
			{
			color = tex2D(BackBufferMIRROR, float2(texcoord.xy+float2(((DepthL/1-C)*D),0)*pix.xy));
			colorT = tex2D(BackBufferMIRROR, float2(texcoord.xy-float2(((DepthR/1-C)*D),0)*pix.xy));
			}
			else if(Custom_Sidebars == 1)
			{
			color = tex2D(BackBufferBORDER, float2(texcoord.xy+float2(((DepthL/1-C)*D),0)*pix.xy));
			colorT = tex2D(BackBufferBORDER, float2(texcoord.xy-float2(((DepthR/1-C)*D),0)*pix.xy));
			}
			else
			{
			color = tex2D(BackBufferCLAMP, float2(texcoord.xy+float2(((DepthL/1-C)*D),0)*pix.xy));
			colorT = tex2D(BackBufferCLAMP, float2(texcoord.xy-float2(((DepthR/1-C)*D),0)*pix.xy));
			}
		}
		else
		{		
			if(Custom_Sidebars == 0)
			{
			colorT = tex2D(BackBufferMIRROR, float2(texcoord.xy+float2(((DepthL/1-C)*D),0)*pix.xy));
			color = tex2D(BackBufferMIRROR, float2(texcoord.xy-float2(((DepthR/1-C)*D),0)*pix.xy));
			}
			else if(Custom_Sidebars == 1)
			{
			colorT = tex2D(BackBufferBORDER, float2(texcoord.xy+float2(((DepthL/1-C)*D),0)*pix.xy));
			color = tex2D(BackBufferBORDER, float2(texcoord.xy-float2(((DepthR/1-C)*D),0)*pix.xy));
			}
			else
			{
			colorT = tex2D(BackBufferCLAMP, float2(texcoord.xy+float2(((DepthL/1-C)*D),0)*pix.xy));
			color = tex2D(BackBufferCLAMP, float2(texcoord.xy-float2(((DepthR/1-C)*D),0)*pix.xy));
			}
		}
}


////////////////////////////////////////////////////Polynomial_Distortion/////////////////////////////////////////////////////

float2 DL(float2 p, float k1) //Cubic Lens Distortion 
{
	float LC = 1-Lens_Center;
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * k1 + (LD() * sqrt(r2));

	 p.x = newRadius * (p.x-0.5)+0.5;
	 p.y = newRadius * (p.y-0.5)+0.5;
	
	return p;
}

float2 DR(float2 p, float k1) //Cubic Lens Distortion 
{
	float LC = Lens_Center;
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * k1 + (LD() * sqrt(r2));

	 p.x = newRadius * (p.x-0.5)+0.5;
	 p.y = newRadius * (p.y-0.5)+0.5;
	
	return p;
}

float4 PDL(float2 texcoord)

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = Polynomial_Colors.x;
		Green = Polynomial_Colors.y;
		Blue = Polynomial_Colors.z;
		
		uv_red = DL(texcoord.xy-sectorOrigin,Red) + sectorOrigin;
		uv_green = DL(texcoord.xy-sectorOrigin,Green) + sectorOrigin;
		uv_blue = DL(texcoord.xy-sectorOrigin,Blue) + sectorOrigin;
		
		if(Custom_Sidebars == 0)
		{
		color_red = tex2D(SamplerCLMIRROR, uv_red).r;
		color_green = tex2D(SamplerCLMIRROR, uv_green).g;
		color_blue = tex2D(SamplerCLMIRROR, uv_blue).b;
		}
		if(Custom_Sidebars == 1)
		{
		color_red = tex2D(SamplerCLBORDER, uv_red).r;
		color_green = tex2D(SamplerCLBORDER, uv_green).g;
		color_blue = tex2D(SamplerCLBORDER, uv_blue).b;
		}
		else
		{
		color_red = tex2D(SamplerCLCLAMP, uv_red).r;
		color_green = tex2D(SamplerCLCLAMP, uv_green).g;
		color_blue = tex2D(SamplerCLCLAMP, uv_blue).b;
		}

		if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
		{
			color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
		}
		else
		{
			color = float4(0,0,0,1);
		}
		return color;
		
	}
	
	float4 PDR(float2 texcoord)

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = Polynomial_Colors.x;
		Green = Polynomial_Colors.y;
		Blue = Polynomial_Colors.z;
		
		uv_red = DR(texcoord.xy-sectorOrigin,Red) + sectorOrigin;
		uv_green = DR(texcoord.xy-sectorOrigin,Green) + sectorOrigin;
		uv_blue = DR(texcoord.xy-sectorOrigin,Blue) + sectorOrigin;
		
		if(Custom_Sidebars == 0)
		{
		color_red = tex2D(SamplerCRMIRROR, uv_red).r;
		color_green = tex2D(SamplerCRMIRROR, uv_green).g;
		color_blue = tex2D(SamplerCRMIRROR, uv_blue).b;
		}
		if(Custom_Sidebars == 1)
		{
		color_red = tex2D(SamplerCRBORDER, uv_red).r;
		color_green = tex2D(SamplerCRBORDER, uv_green).g;
		color_blue = tex2D(SamplerCRBORDER, uv_blue).b;
		}
		else
		{
		color_red = tex2D(SamplerCRCLAMP, uv_red).r;
		color_green = tex2D(SamplerCRCLAMP, uv_green).g;
		color_blue = tex2D(SamplerCRCLAMP, uv_blue).b;
		}

		if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
		{
			color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
		}
		else
		{
			color = float4(0,0,0,1);
		}
		return color;
		
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{	
	float D = Depth;
	float IPDD = IPD-(D/2);
	if(!Depth_Map_View)
	{
	
	float posH = H_V_S().y-1;
	float midH = posH*BUFFER_HEIGHT/2*pix.y;
		
	float posV = H_V_S().x-1;
	float midV = posV*BUFFER_WIDTH/2*pix.x;
	
	if(Polynomial_Barrel_Distortion == 0 && HMD_Profiles == 0 )
	{	
		if(Custom_Sidebars == 0)
		{
		color = texcoord.x < 0.5 ? tex2D(SamplerCLMIRROR,float2(((texcoord.x*2)*H_V_S().x)-midV + IPDD * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRMIRROR,float2(((texcoord.x*2-1)*H_V_S().x)-midV - IPDD * pix.x,(texcoord.y*H_V_S().y)-midH));
		}
		if(Custom_Sidebars == 1)
		{
		color = texcoord.x < 0.5 ? tex2D(SamplerCLBORDER,float2(((texcoord.x*2)*H_V_S().x)-midV + IPDD * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRBORDER,float2(((texcoord.x*2-1)*H_V_S().x)-midV - IPDD * pix.x,(texcoord.y*H_V_S().y)-midH));
		}	
		else
		{
		color = texcoord.x < 0.5 ? tex2D(SamplerCLCLAMP,float2(((texcoord.x*2)*H_V_S().x)-midV + IPDD * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRCLAMP,float2(((texcoord.x*2-1)*H_V_S().x)-midV - IPDD * pix.x,(texcoord.y*H_V_S().y)-midH));
		}
	}
	else
	{	
	color = texcoord.x < 0.5 ? PDL(float2(((texcoord.x*2)*H_V_S().x)-midV + IPDD * pix.x,(texcoord.y*H_V_S().y)-midH)) : PDR(float2(((texcoord.x*2-1)*H_V_S().x)-midV - IPDD * pix.x,(texcoord.y*H_V_S().y)-midH));
	}
	}
	else
	{
	color = tex2D(SamplerCDM,texcoord.xy);
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

technique Super_Depth3D
{			
			pass MousePass
		{
			VertexShader = PostProcessVS;
			PixelShader = MouseCuror;
		}
			pass DepthMapPass
		{
			VertexShader = PostProcessVS;
			PixelShader = SbSdepth;
			RenderTarget = texCDM;
		}
			pass SinglePassStereo
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderLR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;
		}
			pass SidebySideTopandBottomLineCheckerboardPass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;	
		}
}
