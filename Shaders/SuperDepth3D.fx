 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.6.1																																*//
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
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				*//																								*//
 //* ---------------------------------																																					*//
 //*																																												*//
 //* Original work was based on Shader Based on forum user 04348 and be located here http://reshade.me/forum/shader-presentation/1594-3d-anaglyph-red-cyan-shader-wip#15236			*//
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 uniform bool DepthMap <
	ui_items = "Off\0ON\0";
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform int AltDepthMap <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0Depth Map 11\0Depth Map 12\0Depth Map 13\0Depth Map 14\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent AltDepthMap.";
> = 5;

uniform bool DepthFlip <
	ui_items = "Off\0ON\0";
	ui_label = "Depth Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

uniform int Pop <
	ui_type = "combo";
	ui_items = "Pop Off\0Pop One\0Pop Two\0Pop Three\0Pop Four\0Pop Five\0Pop Six\0";
	ui_label = "Pop Settings";
	ui_tooltip = "Image Warping in Both Eyes. Try Pop One through Pop Five, Too see what looks better too you.";
> = 0;

 uniform float Perspective <
	ui_type = "drag";
	ui_min = -15; ui_max = 15;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the amount of separation between both eyes. Separation Default is 0.";
> = 0;
 
uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 25;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes. Deviation Default is 15. To go beyond 25 max you need to enter your own number.";
> = 15;

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


    if (AltDepthMap >= 0 && Pop == 1)
    {
    depthL = (pow(abs(depthL),0.25)-0.15);
	}
	
	if (AltDepthMap >= 0 && Pop == 2)
    {
    depthL = 1 - ((pow(abs(depthL/2),0.275))*10)-0.15;	
	}
	
	if (AltDepthMap >= 0 && Pop == 3)
    {		
    float LinLog = 0.00000075;
	depthL = ((LinLog) / (LinLog - depthL * (LinLog - 1)) + ((pow(abs(depthL),5)+0.75)/3.75));
	}
	
	if (AltDepthMap >= 0 && Pop == 4)
    {		
   	float LinLog = 0.000010;
	depthL = ((LinLog) / (LinLog - depthL * (LinLog - 1)))-0.375;
	}
	
	if (AltDepthMap >= 0 && Pop == 5)
    {		
	float LinLog = 0.1;
	depthL = 1 - (LinLog) / (LinLog - depthL * depthL * (LinLog -  37.5));
	}
		
	if (AltDepthMap >= 0 && Pop == 6)
    {		
	float LinLog = 0.05;
	depthL = 1 - (LinLog) / (LinLog - depthL / 62.5 *  (LinLog -  1)) + (pow(abs(depthL*3),0.25)-0.25);
	}
	
    float4 DL =  depthL;


	float4 depthR = ReShade::GetLinearizedDepth(float2((texcoord.x*2-1), texcoord.y));

		//Naruto Shippuden UNS3 Full Blurst | Amnesia: The Dark Descent | The Evil With In | Sleeping Dogs: DE | RAGE64 | Among The Sleep
		if (AltDepthMap == 0)
		{
		depthR = (pow(abs(depthR),0.75));
		}
		
		//BoarderLands 2 | Deadly Premonition: The Directors's Cut
		if (AltDepthMap == 1)
		{
		depthR = (pow(abs(depthR*depthR),0.15)-0.25);
		}
		
		//Batman Arkham Origins
		if (AltDepthMap == 2)
		{
		float LinLog = 0.05;
		depthR = 1 - (LinLog) / (LinLog - depthR / 62.5 *  (LinLog -  1)) + (pow(abs(depthR*3),0.25)-0.25);
		}
		
		//Skyrim V
		if (AltDepthMap == 3)
		{
		depthR = (pow(abs(depthR*3),0.25)-0.15);
		}
		
		//Alien Isolation | Shadow warrior(2013)
		if (AltDepthMap == 4)
		{
		depthR = (pow(abs(depthR/2),0.2)-0.25);
		}
		
		//Lords of The Fallen  | Dragons Dogma: Dark Arisen Dragon | Ball Xenoverse | Hard Reset | Return To Castle Wolfenstine| Souls Games | DreamFall Chapters
		if (AltDepthMap == 5)
		{
		depthR = (pow(abs(depthR),0.25)-0.15);
		}
		
		//Dying Light
		if (AltDepthMap == 6)
		{
		depthR = 1 - ((pow(abs(depthR/2),0.25))*10)-0.15;
		}
		
		//Assassin Creed Unity | Call of Duty: Ghost | Call of Duty: Black Ops 2
		if (AltDepthMap == 7)
		{
		float LinLog = 0.000015;
		depthR = (LinLog) / (LinLog - depthR * (LinLog - 1));
		}
		
		//Metro Last Light Redux | Metro 2033 Redux
		if (AltDepthMap == 8)
		{
		depthR = (pow(abs(depthR*2),0.25)-0.15);
		}
		
		//Middle-earth: Shadow of Mordor | GTA V
		if (AltDepthMap == 9)
		{
		depthR = 1 - ((pow(abs(depthR/2),0.275))*10)-0.15;	
		}
		
		//Call of Duty: Advance Warfare
		if (AltDepthMap == 10)
		{
		float LinLog = 0.000010;
		depthR = ((LinLog) / (LinLog - depthR * (LinLog - 1)))-0.375;
		}
		
		//Magicka 2
		if (AltDepthMap == 11)
		{
		float LinLog = 0.1;
		depthR = 1 - (LinLog) / (LinLog - depthR * depthR * (LinLog -  37.5));
		}
		
		//Condemned: Criminal Origins
		if (AltDepthMap == 12)
		{
		depthR = (pow(abs(depthR/2),0.75));
		}

		//Witcher 3
		if (AltDepthMap == 13)
		{
		float LinLog = 0.00000075;
		depthR = ((LinLog) / (LinLog - depthR * (LinLog - 1)) + ((pow(abs(depthR),5)+0.75)/3.75));
		}
		
		//Fallout 4
		if (AltDepthMap == 14)
		{
		float LinLog = 0.004;
		depthR = (1-(LinLog) / (LinLog - depthR * (LinLog-0.1)) + ((pow(abs(depthR*15),1)+0.50)/4));
		}
		
		

    float4 DR = depthR;	
    
    if (EyeSwap)
	{
    color.r = texcoord.x < 0.5 ? 1.0 - DL.r : DR.r;
	}
	else
	{
    color.r = texcoord.x < 0.5 ? DL.r : 1.0 - DR.r;
	}	
	return color.r;	
	}


	void  PS_calcLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
	{
	float HalfDepth = Depth/2;
	color.rgb = texcoord.x-Depth*pix.x*SbSdepth(float2(texcoord.x-HalfDepth*pix.x,texcoord.y));
	}

/////////////////////////////////////////L/R//////////////////////////////////////////////////////////////////////
void PS_renderR(in float4 position : SV_Position, in float2 texcoord: TEXCOORD0, out float3 color : SV_Target)
{	
		
	color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x*2-1, texcoord.y)).rgb;
	
	int x = 25 % 1023;
	[loop]
	for (int j = 0; j <= x; j++) 
	{
			if (tex2D(SamplerCC, float2((texcoord.x > 0.5)-j*pix.x,texcoord.y)).r >= texcoord.x-pix.x && tex2D(SamplerCC, float2(texcoord.x+j*pix.x,texcoord.y)).r <= texcoord.x+pix.x) 
		{
			
			color.rgb = tex2D(ReShade::BackBuffer, float2((texcoord.x*2-1)+j*pix.x, texcoord.y)).rgb;
			
		}
	}
}
			
	void PS_renderL(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{	

			color.rgb = tex2D(ReShade::BackBuffer, float2((texcoord.x*2), texcoord.y)).rgb;

	
	int x = 25 % 1023;
	[loop]		
	for (int i = 0; i <= x; i++) 
	{
		if (tex2D(SamplerCC, float2((texcoord.x < 0.5)+i*pix.x,texcoord.y)).r >= texcoord.x-pix.x && tex2D(SamplerCC, float2(texcoord.x+i*pix.x,texcoord.y)).r <= texcoord.x-pix.x)
		{
			if (Pop >= 1)
			{
			
			color.rgb = tex2D(ReShade::BackBuffer, float2(texcoord.x*2+i*pix.x, texcoord.y)).rgb;
			
			}
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
		
		//Naruto Shippuden UNS3 Full Blurst | Amnesia: The Dark Descent | The Evil With In | Sleeping Dogs: DE | RAGE64 | Among The Sleep
		if (AltDepthMap == 0)
		{
		depthM = (pow(abs(depthM),0.75));
		}
		
		//BoarderLands 2 | Deadly Premonition: The Directors's Cut
		if (AltDepthMap == 1)
		{
		depthM = (pow(abs(depthM*depthM),0.15)-0.25);
		}
		
		//Batman Arkham Origins
		if (AltDepthMap == 2)
		{
		float LinLog = 0.05;
		depthM = 1 - (LinLog) / (LinLog - depthM / 62.5 *  (LinLog -  1)) + (pow(abs(depthM*3),0.25)-0.25);
		}
		
		//Skyrim v
		if (AltDepthMap == 3)
		{
		depthM = (pow(abs(depthM*3),0.25)-0.15);
		}
		
		//Alien Isolation | Shadow warrior(2013)
		if (AltDepthMap == 4)
		{
		depthM = (pow(abs(depthM/2),0.2)-0.25);
		}
		
		//Lords of The Fallen  | Dragons Dogma: Dark Arisen Dragon | Ball Xenoverse | Hard Reset | Return To Castle Wolfenstine| Souls Games | DreamFall Chapters
		if (AltDepthMap == 5)
		{
		depthM = (pow(abs(depthM),0.25)-0.15);
		}
		
		//Dying Light
		if (AltDepthMap == 6)
		{
		depthM = 1 - ((pow(abs(depthM/2),0.25))*10)-0.15;
		}
		
		//Assassin Creed Unity | Call of Duty: Ghost | Call of Duty: Black Ops 2
		if (AltDepthMap == 7)
		{
		float LinLog = 0.000015;
		depthM = (LinLog) / (LinLog - depthM * (LinLog - 1));
		}
		
		//Metro Last Light Redux | Metro 2033 Redux
		if (AltDepthMap == 8)
		{
		depthM = (pow(abs(depthM*2),0.25)-0.15);
		}
		
		//Middle-earth: Shadow of Mordor | GTA V
		if (AltDepthMap == 9)
		{
		depthM = 1 - ((pow(abs(depthM/2),0.275))*10)-0.15;	
		}
		
		//Call of Duty: Advance Warfare
		if (AltDepthMap == 10)
		{
		float LinLog = 0.000010;
		depthM = ((LinLog) / (LinLog - depthM * (LinLog - 1)))-0.375;
		}
		
		//Magicka 2
		if (AltDepthMap == 11)
		{
		float LinLog = 0.1;
		depthM = 1 - (LinLog) / (LinLog - depthM * depthM * (LinLog -  37.5));
		}
		
		//Condemned: Criminal Origins
		if (AltDepthMap == 12)
		{
		depthM = (pow(abs(depthM/2),0.75));
		}

		//Witcher 3
		if (AltDepthMap == 13)
		{
		float LinLog = 0.00000075;
		depthM = ((LinLog) / (LinLog - depthM * (LinLog - 1)) + ((pow(abs(depthM),5)+0.75)/3.75));
		}
		
		//Fallout 4
		if (AltDepthMap == 14)
		{
		float LinLog = 0.004;
		depthM = (1-(LinLog) / (LinLog - depthM * (LinLog-0.1)) + ((pow(abs(depthM*15),1)+0.50)/4));
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
