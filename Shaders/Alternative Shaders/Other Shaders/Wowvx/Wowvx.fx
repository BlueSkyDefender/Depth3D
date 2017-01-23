 ///----------//
 ///**WOWvx**///
 //---------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.3																																	*//
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
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader 																			*//	
 //* ---------------------------------																																				*//
 //* Major Contributor and Insperation for this shader.																																*//
 //* User: WOWvX																																									*//
 //* Name: Shawn Barclay																																							*//
 //* Websites: A: https://bugs.winehq.org/show_bug.cgi?id=40602 B: https://reshade.me/forum/shader-suggestions/2812-wowvx-support#19996												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


uniform int Alternate_Depth_Map <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0Depth Map 11\0Depth Map 12\0Depth Map 13\0Depth Map 14\0Depth Map 15\0Depth Map 16\0Depth Map 17\0Depth Map 18\0Depth Map 19\0Depth Map 20\0Depth Map 21\0Depth Map 22\0Depth Map 23\0Depth Map 24\0Depth Map 25\0Depth Map 26\0Depth Map 27\0Depth Map 28\0Depth Map 29\0Depth Map 30\0Depth Map 31\0Depth Map 32\0Depth Map 33\00Depth Map 34\0Depth Map 35\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent Alternet Depth Map.";
> = 0;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0;

uniform int Disocclusion_Type <
	ui_type = "combo";
	ui_items = "Disocclusion Mask Off\0Normal Disocclusion Mask\0Radial Disocclusion Mask\0";
	ui_label = "Disocclusion Type";
	ui_tooltip = "Pick the type of blur you want.";
> = 0;

uniform float Disocclusion_Power <
	ui_type = "drag";
	ui_min = 0; ui_max = 0.5;
	ui_label = "Disocclusion Power";
	ui_tooltip = "Determines the Disocclusion masking of Depth Map. Default is 0.025";
> = 0.025;

uniform bool Depth_Map_Enhancement <
	ui_label = "Depth Map Enhancement";
	ui_tooltip = "Enable Or Dissable Depth Map Enhancement. Default is Off";
> = 0;

uniform float Adjust <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.5;
	ui_label = "Adjust";
	ui_tooltip = "Adjust DepthMap Enhancement, Dehancement occurs past one. Default is 1.0";
> = 1.0;

uniform int Weapon_Depth_Map <
	ui_type = "combo";
	ui_items = "Weapon Depth Map Off\0Custom Weapon Depth Map One\0Custom Weapon Depth Map Two\0Custom Weapon Depth Map Three\0Custom Weapon Depth Map Four\0WDM 1\0WDM 2\0WDM 3\0WDM 4\0WDM 5\0WDM 6\0WDM 7\0WDM 8\0WDM 9\0WDM 10\0WDM 11\0WDM 12\0WDM 13\0WDM 14\0WDM 15\0WDM 16\0WDM 17\0WDM 18\0WDM 19\0WDM 20\0WDM 21\0WDM 22\0WDM 23\0";
	ui_label = "Alternate Weapon Depth Map";
	ui_tooltip = "Alternate Weapon Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting.";
> = 0;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.500;
	ui_label = "Weapon Adjust Depth Map";
	ui_tooltip = "Adjust weapon depth map. Default is (Y 0, X 0.250, Z 1.001)";
> = float3(0.0,0.250,1.001);

uniform float Weapon_Percentage <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 5.0;
	ui_label = "Weapon Percentage";
	ui_tooltip = "Adjust weapon percentage. Default is 5.0";
> = 5.0;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

uniform int Custom_Depth_Map <
	ui_type = "combo";
	ui_items = "Custom Off\0Custom One\0Custom Two\0Custom Three\0Custom Four\0Custom Five\0Custom Six\0Custom Seven\0Custom Eight\0Custom Nine\0Custom Ten\0Custom Eleven\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Adjust your own Custom Depth Map.";
> = 0;

uniform float2 Near_Far <
	ui_type = "drag";
	ui_min = 0; ui_max = 100;
	ui_label = "Near & Far";
	ui_tooltip = "Adjustment for Near and Far Depth Map Precision.";
> = float2(1,1.5);

uniform bool Header_Flip <
	ui_label = "Header Flip";
	ui_tooltip = "If Header is on Bottom Left Use this to place it Back on the Top Left.";
> = true;

uniform int Content <
	ui_type = "combo";
	ui_items = "NoDepth\0Reserved\0Still\0CGI\0Game\0Movie\0Signage\0";
	ui_label = "Content Type";
	ui_tooltip = "Content Type for WOWvx.";
> = 0;

uniform bool Invert <
	ui_label = "Invert";
	ui_tooltip = "Invert Depth Map.";
> = true;

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
	
texture texDis  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

	
sampler SamplerDis
	{
		Texture = texDis;
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

//Depth Map Information	
float4 DepthMap(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{

	 float4 color = 0;

			if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
	
	float4 depthM = tex2D(DepthBuffer, float2(texcoord.x, texcoord.y));
	float4 WDM = tex2D(DepthBuffer, float2(texcoord.x, texcoord.y));
		
		if (Custom_Depth_Map == 0)
	{	
		//Alien Isolation | Firewatch
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
		
		//Call of Duty: Advance Warfare | Call of Duty: Black Ops 2 | Call of Duty: Ghost | Call of Duty: Infinite Warfare 
		if (Alternate_Depth_Map == 5)
		{
		float cF = 25;
		float cN = 1;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Casltevania: Lord of Shadows - UE | Dead Rising 3
		if (Alternate_Depth_Map == 6)
		{
		float cF = 25;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Doom 2016
		if (Alternate_Depth_Map == 7)
		{
		float cF = 25;
		float cN = 5;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
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
		
		//Warhammer: End Times - Vermintide | Fallout 4 
		if (Alternate_Depth_Map == 10)
		{
		float cF = 7.0;
		float cN = 1.5;
		depthM = (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Dying Light
		if (Alternate_Depth_Map == 11)
		{
		float cF = 100;
		float cN = 0.0075;
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
		
		//S.T.A.L.K.E.R:SoC
		if (Alternate_Depth_Map == 24)
		{
		float cF = 1.001;
		float cN = 0;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Double Dragon Neon
		if (Alternate_Depth_Map == 25)
		{
		float cF = 0.5;
		float cN = 0.150;
		depthM = log(depthM / cN) / log(cF / cN);
		}
		
		//Deus Ex: Mankind Divided
		if (Alternate_Depth_Map == 26)
		{
		float cF = 250;
		float cN = 251;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}	
		
		//The Elder Scrolls V: Skyrim Special Edition
		if (Alternate_Depth_Map == 27)
		{
		float cF = 20;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Rage64|
		if (Alternate_Depth_Map == 28)
		{
		float cF = 50;
		float cN = -0.5;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Through The Woods
		if (Alternate_Depth_Map == 29)
		{
		float cF = 25;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Amnesia: Machine for Pigs
		if (Alternate_Depth_Map == 30)
		{
		float cF = 100;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Requiem: Avenging Angel
		if (Alternate_Depth_Map == 31)
		{
		float cF = 100;
		float cN = 1.555;
		depthM = 1 - log(pow(abs(cN-depthM),cF));
		}
		
		//Turok: Dinosaur Hunter
		if (Alternate_Depth_Map == 32)
		{
		float cF = 1000; //10+
		float cN = 0;//1
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Never Alone (Kisima Ingitchuna)
		if (Alternate_Depth_Map == 33)
		{
		float cF = 112.5;
		float cN = 1.995;
		depthM = 1 - log(pow(abs(cN-depthM),cF));
		}
		
		//Stacking
		if (Alternate_Depth_Map == 34)
		{
		float cF = 15;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Fez
		if (Alternate_Depth_Map == 35)
		{
		float cF = 25.0;
		float cN = 1.5125;
		depthM = clamp(1 - log(pow(abs(cN-depthM),cF)),0,1);
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
		
		//Custom Eleven
		if (Custom_Depth_Map == 11)
		{
		float cF = Near_Far.y;//1.010+	or 150
		float cN = Near_Far.x;//0 or	151
		depthM = 1 - log(pow(abs(cN-depthM),cF));
		}
		
	}
		
	float4 D;
	float4 depthMFar;
	float4 depthMFarT;
	
	float Adj;
	float Per;
		
		//Custom Weapon Depth Profile One	
		if (Weapon_Depth_Map == 1)
		{
		Adj = Weapon_Adjust.x;//0
		Per = Weapon_Percentage;//5
		float cWF = Weapon_Adjust.y;//0.250
		float cWN = Weapon_Adjust.z;//1.001
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Custom Weapon Depth Profile Two
		if (Weapon_Depth_Map == 2)
		{
		Adj = Weapon_Adjust.x;//0
		Per = Weapon_Percentage;//5
		float cWF = Weapon_Adjust.y;//-1000
		float cWN = Weapon_Adjust.z;//0.985
		WDM = (log(cWF / cWN*WDM - cWF));
		}
		
		//Custom Weapon Depth Profile Three	
		if (Weapon_Depth_Map == 3)
		{
		Adj = Weapon_Adjust.x;//0
		Per = Weapon_Percentage;//5
		float cWF = Weapon_Adjust.y;//0.250
		float cWN = Weapon_Adjust.z;//1.001
		WDM = (log(cWF * cWN/WDM - cWF));
		}
		
		//Custom Weapon Depth Profile Four	
		if (Weapon_Depth_Map == 4)
		{
		Adj = Weapon_Adjust.x;//0
		Per = Weapon_Percentage;//5
		float cWF = Weapon_Adjust.y;//-0.05
		float cWN = Weapon_Adjust.z;//0.500
		WDM = 1 - (log(cWN * WDM)/ 1 - log(cWF+WDM));
		}
		
		//Weapon Depth Map One
		if (Weapon_Depth_Map == 5)
		{
		Adj = 0;
		Per = 5;
		float cWF = -1000;
		float cWN = 0.9856;
		WDM = (log(cWF / cWN*WDM - cWF));
		}
		
		//Weapon Depth Map Two
		if (Weapon_Depth_Map == 6)
		{
		Adj = 0.001;
		Per = 0.440;
		float cWF = 0.255;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Three
		if (Weapon_Depth_Map == 7)
		{
		Adj = 0.000;
		Per = 0.180;
		float cWF = 0.235;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Four
		if (Weapon_Depth_Map == 8)
		{
		Adj = 0.00000001;
		Per = 0.675;
		float cWF = 10;
		float cWN = 0.0085;
		WDM = (log(cWF / cWN*WDM - cWF));
		}
		
		//Weapon Depth Map Five
		if (Weapon_Depth_Map == 9)
		{
		Adj = 0.001;
		Per = 0.525;
		float cWF = 0.080;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Six
		if (Weapon_Depth_Map == 10)
		{
		Adj = 0;
		Per = 0.500;
		float cWF = -1.9;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Seven
		if (Weapon_Depth_Map == 11)
		{
		Adj = 0.125;
		Per = 1;
		float cWF = -1.0;
		float cWN = -0.1;
		WDM = (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Eight
		if (Weapon_Depth_Map == 12)
		{
		Adj = 0.037;
		Per = 5.0;
		float cWF = 0.75;
		float cWN = -1.0;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Nine
		if (Weapon_Depth_Map == 13)
		{
		Adj = 0.000001;
		Per = 5.0;
		float cWF = 0.0045;
		float cWN = 100;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Ten
		if (Weapon_Depth_Map == 14)
		{
		Adj = 0.0;
		Per = 2;
		float cWF = 37.5;
		float cWN = 0.523;
		WDM = (log(cWF / cWN*WDM - cWF));
		}
		
		//Weapon Depth Map Eleven
		if (Weapon_Depth_Map == 15)
		{
		Adj = 0.0003;
		Per = 0.625;
		float cWF = 0.625;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Twelve
		if (Weapon_Depth_Map == 16)
		{
		Adj = 0.050;
		Per = 1.0;
		float cWF = 1.5;
		float cWN = 1.7;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Thirteen
		if (Weapon_Depth_Map == 17)
		{
		Adj = 0;
		Per = 0.666;
		float cWF = -0.06;
		float cWN = 0.666;
		WDM = 1 - (log(cWN * WDM)/ 1 - log(cWF+WDM));
		}
		
		//Weapon Depth Map Fourteen
		if (Weapon_Depth_Map == 18)
		{
		Adj = 0;
		Per = 0.500;
		float cWF = -0.0865;
		float cWN = -0.2;
		WDM = 1 - (log(cWN * WDM)/ 1 - log(cWF+WDM));
		}
		
		//Weapon Depth Map Fifteen
		if (Weapon_Depth_Map == 19)
		{
		Adj = 0.000001;
		Per = 5;
		float cWF = 1.6;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Profile Sixteen
		if (Weapon_Depth_Map == 20)
		{
		Adj = 0.00000001;
		Per = 5;
		float cWF = -0.4925;
		float cWN = 0.200;
		WDM = 1 - (log(cWN * WDM)/ 1 - log(cWF+WDM));
		}
		
		//Weapon Depth Profile Seventeen
		if (Weapon_Depth_Map == 21)
		{
		Adj = 0.040;
		Per = 5;
		float cWF = 0.051;
		float cWN = 1.250;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Profile Eighteen
		if (Weapon_Depth_Map == 22)
		{
		Adj = 0;
		Per = 0.580;
		float cWF = -0.005;
		float cWN = 1.5;
		WDM = 1 - (log(cWN * WDM)/ 1 - log(cWF+WDM));
		}
		
		//Weapon Depth Profile Nineteen
		if (Weapon_Depth_Map == 23)
		{
		Adj = 0.0001;
		Per = 5;
		float cWF = 0.025;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Profile Twenty
		if (Weapon_Depth_Map == 24)
		{
		Adj = 0.0001;
		Per = 5;
		float cWF = 0.035;
		float cWN = 1.001;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Profile Twenty One
		if (Weapon_Depth_Map == 25)
		{
		Adj = 0.000010;
		Per = 5;
		float cWF = -0.4;
		float cWN = 0.375;
		WDM = 1 - (log(cWN * WDM)/ 1 - log(cWF+WDM));
		}
		
		//Weapon Depth Profile Twenty Two
		if (Weapon_Depth_Map == 26)
		{
		Adj = 0.102000;
		Per = 3.650000;
		float cWF = 0.001300;
		float cWN = 50.000000;
		WDM = 1 - (log(cWF * cWN/WDM - cWF));
		}
		
		//Weapon Depth Map Twenty Three
		if (Weapon_Depth_Map == 27)
		{
		Adj = 0.00000001;
		Per = 0.6;//0.675
		float cWF = 4.925;//10
		float cWN = 0.0075;//0.0085
		WDM = (log(cWF / cWN*WDM - cWF));
		}
		
	float NearDepth;
	
	if (Weapon_Depth_Map == 27 || Weapon_Depth_Map == 23 || Weapon_Depth_Map == 20 || Weapon_Depth_Map == 19 || Weapon_Depth_Map == 13 || Weapon_Depth_Map == 8)
	{
	NearDepth = step(depthM.r,Adj/100000);
	}
	else
	{
	NearDepth = step(depthM.r,Adj);
	}
	
	if(Depth_Map_Enhancement == 0)
    {
		if (Weapon_Depth_Map <= 0)
		{
		D = depthM;
		}
		else
		{
		D = lerp(depthM,WDM%Per,NearDepth);
		}
    }
    else
    {
		if (Weapon_Depth_Map <= 0)
		{
		float A = Adjust;
		float cDF = 1.025;
		float cDN = 0;
		depthMFar = pow(abs((exp(depthM * log(cDF + cDN)) - cDN) / cDF),1000);	
		D = lerp(depthMFar,depthM,A);
		}
		else
		{
		float A = Adjust;
		float cDF = 1.025;
		float cDN = 0;
		depthMFar = pow(abs((exp(depthM * log(cDF + cDN)) - cDN) / cDF),1000);	
		D = lerp(lerp(depthMFar,depthM,A),WDM%Per,NearDepth);
		}
    }
    
	color.rgb = D.rrr;
	
	return color;	

}
	
float4 DisocclusionMask(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
	float4 color;
	float2 dir;
	float B;
	float Con = 10;
	
	if(Disocclusion_Type > 0 && Disocclusion_Power > 0) 
	{	
	const float weight[10] = 
	{ 
	-0.08,
	-0.05,  
	-0.03,  
	-0.02,  
	-0.01,  
	0.01,  
	0.02,  
	0.03,  
	0.05,
	0.08
	};
	
	if(Disocclusion_Type == 1)
	{
	dir = float2(0.5,0);
	B = Disocclusion_Power;
	}
	
	if(Disocclusion_Type == 2)
	{
	dir = 0.5 - texcoord;
	B = Disocclusion_Power*2;
	}
	
	dir = normalize( dir ); 
	 
	[loop]
	for (int i = 0; i < 10; i++)
	{
	color += tex2D(SamplerCDM,texcoord + dir * weight[i] * B)/Con;
	}
	
	}
	else
	{
	color = tex2D(SamplerCDM,texcoord.xy);
	}

	return color;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float4 PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
	float HEIGHT;
	if (Header_Flip)
	{
	HEIGHT = BUFFER_RCP_HEIGHT;
	}
	else
	{
	HEIGHT = BUFFER_HEIGHT;
	}
	
	float size = 1;
	float4 Color;	
	
	//HeaderCode Blocks for WOWvx 3D activation//
	
	//BLOCK ONE
 	float4 A = all(abs(float2(0.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 B = all(abs(float2(2.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 C = all(abs(float2(4.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 D = all(abs(float2(6.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 E = all(abs(float2(14.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 F = all(abs(float2(32.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 G = all(abs(float2(34.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 H = all(abs(float2(36.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 I = all(abs(float2(38.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 J = all(abs(float2(40.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 K = all(abs(float2(42.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 L = all(abs(float2(44.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 M = all(abs(float2(46.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 N = all(abs(float2(48.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 BlockOne = A+B+C+D+E+F+G+H+I+J+K+L+M+N;
	
	//NO DEPTH
	float4 NDA = all(abs(float2(96.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDB = all(abs(float2(98.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDC = all(abs(float2(102.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDD = all(abs(float2(108.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDE = all(abs(float2(110.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDF = all(abs(float2(114.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDG = all(abs(float2(118.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDH = all(abs(float2(124.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDI = all(abs(float2(126.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDJ = all(abs(float2(128.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDK = all(abs(float2(138.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDL = all(abs(float2(152.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NDM = all(abs(float2(154.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 NoDepth = NDA+NDB+NDC+NDD+NDE+NDF+NDG+NDH+NDI+NDJ+NDK+NDL+NDM;

	//RESERVED
	float4 RA = all(abs(float2(26.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RB = all(abs(float2(28.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RC = all(abs(float2(98.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RD = all(abs(float2(100.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RE = all(abs(float2(110.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RF = all(abs(float2(112.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RG = all(abs(float2(116.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RH = all(abs(float2(118.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RI = all(abs(float2(120.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RJ = all(abs(float2(122.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RK = all(abs(float2(126.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RL = all(abs(float2(128.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RM = all(abs(float2(130.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RN = all(abs(float2(136.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RO = all(abs(float2(144.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RP = all(abs(float2(150.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RQ = all(abs(float2(154.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 RR = all(abs(float2(158.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 Reserved = RA+RB+RC+RD+RE+RF+RG+RH+RI+RJ+RK+RL+RM+RN+RO+RP+RQ+RR;
	
	//STILL
	float4 SA = all(abs(float2(26.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SB = all(abs(float2(30.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SC = all(abs(float2(96.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SD = all(abs(float2(100.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SE = all(abs(float2(102.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SF = all(abs(float2(104.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SG = all(abs(float2(108.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SH = all(abs(float2(112.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SI = all(abs(float2(116.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SJ = all(abs(float2(120.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SK = all(abs(float2(124.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SL = all(abs(float2(130.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SM = all(abs(float2(132.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SN = all(abs(float2(156.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 Still = SA+SB+SC+SD+SE+SF+SG+SH+SI+SJ+SK+SL+SM+SN;
	
	//CGI
	float4 CA = all(abs(float2(26.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CB = all(abs(float2(96.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CC = all(abs(float2(98.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CD = all(abs(float2(100.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CE = all(abs(float2(102.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CF = all(abs(float2(108.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CG = all(abs(float2(110.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CH = all(abs(float2(112.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CI = all(abs(float2(116.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CJ = all(abs(float2(122.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CK = all(abs(float2(124.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CL = all(abs(float2(126.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CM = all(abs(float2(138.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CN = all(abs(float2(140.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CO = all(abs(float2(142.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CP = all(abs(float2(144.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CQ = all(abs(float2(152.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CR = all(abs(float2(154.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CS = all(abs(float2(156.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CT = all(abs(float2(158.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 CGI = CA+CB+CC+CD+CE+CF+CG+CH+CI+CJ+CK+CL+CM+CN+CO+CP+CQ+CR+CS+CT;
	
	//GAME
	float4 GA = all(abs(float2(28.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GB = all(abs(float2(30.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GC = all(abs(float2(104.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GD = all(abs(float2(114.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GE = all(abs(float2(122.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GF = all(abs(float2(132.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GG = all(abs(float2(136.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GH = all(abs(float2(138.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GI = all(abs(float2(144.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GJ = all(abs(float2(150.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GK = all(abs(float2(152.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GL = all(abs(float2(156.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 GM = all(abs(float2(158.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 Game = GA+GB+GB+GC+GD+GE+GF+GG+GH+GI+GJ+GK+GL+GM;
	
	//MOVIE
	float4 MA = all(abs(float2(28.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MB = all(abs(float2(98.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MC = all(abs(float2(110.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MD = all(abs(float2(114.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 ME = all(abs(float2(120.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MF = all(abs(float2(126.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MG = all(abs(float2(130.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MH = all(abs(float2(136.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MI = all(abs(float2(140.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MJ = all(abs(float2(142.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MK = all(abs(float2(150.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 ML = all(abs(float2(154.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 MM = all(abs(float2(156.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 Movie = MA+MB+MC+MD+ME+MF+MG+MH+MI+MJ+MK+ML+MM;
	
	//SIGNAGE
	float4 SSA = all(abs(float2(30.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSB = all(abs(float2(96.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSC = all(abs(float2(102.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSD = all(abs(float2(104.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSE = all(abs(float2(108.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSF = all(abs(float2(114.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSG = all(abs(float2(118.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSH = all(abs(float2(120.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSI = all(abs(float2(122.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSJ = all(abs(float2(124.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSK = all(abs(float2(128.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSL = all(abs(float2(130.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSM = all(abs(float2(132.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSN = all(abs(float2(140.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSO = all(abs(float2(142.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSP = all(abs(float2(144.5,HEIGHT)-position.xy) < float2(0.5,size));
	float4 SSQ = all(abs(float2(158.5,pix.y)-position.xy) < float2(0.5,size));
	float4 Signage = SSA+SSB+SSC+SSD+SSE+SSF+SSG+SSH+SSI+SSJ+SSK+SSL+SSM+SSN+SSO+SSP+SSQ;
	
	float4 Content_Type;
	
	if (Content == 0)
		{
		Content_Type = NoDepth;
		}
	else if (Content == 1)
		{
		Content_Type = Reserved;
		}
	else if (Content == 2)
		{
		Content_Type = Still;
		}
	else if (Content == 3)
		{
		Content_Type = CGI;
		}
	else if (Content == 4)
		{
		Content_Type = Game;
		}
	else if (Content == 5)
		{
		Content_Type = Movie;
		}
	else
		{
		Content_Type = Signage;
		}
		
	Color = texcoord.x < 0.5 ? tex2D(BackBuffer,float2(texcoord.x*2 + Perspective * pix.x,texcoord.y)) : tex2D(SamplerDis,float2(texcoord.x*2-1 - Perspective * pix.x,texcoord.y));
	
	float4 BACK = all(abs(float2(80,HEIGHT)-position.xy) < float2(80,size)) ? 0 : Color;

	return BlockOne + Content_Type ? float4(0,0,1,0) : BACK;
	
	//HeaderCode Blocks for WOWvx 3D activation//
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

technique WOWvx
{			
			pass DepthMapPass
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget = texCDM;
		}
			pass DisocclusionPass
		{
			VertexShader = PostProcessVS;
			PixelShader = DisocclusionMask;
			RenderTarget = texDis;
		}
			pass SidebySide
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;	
		}
}
