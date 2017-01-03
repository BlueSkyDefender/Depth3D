 ////-----------//
 ///**Depth3D**///
 //-----------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.0																																	*//
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
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0";
	ui_label = "Alternate Depth Map";
	ui_tooltip = "Alternate Depth Map for different Games. Read the ReadMeDepth3d.txt, for setting. Each game May and can use a diffrent Alternet Depth Map.";
> = 0;

uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 75;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes. You can Override this setting.";
> = 25;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0;

uniform int Disocclusion_Type <
	ui_type = "combo";
	ui_items = "Disocclusion Mask Off\0Normal Disocclusion Mask\0Radial Disocclusion Mask\0Normal Disocclusion Mask Plus\0Radial Disocclusion Mask Plus\0";
	ui_label = "Disocclusion Type";
	ui_tooltip = "Pick the type of blur you want.";
> = 1;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

uniform float Adjust <
	ui_type = "drag";
	ui_min = -1.0; ui_max = 1.500;
	ui_label = "DepthMap Enhancement & Dehancement";
	ui_tooltip = "Adjust DepthMap Enhancement, Dehancement occurs past one. Default is 1.0";
> = 1.0;

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

uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Checkerboard 3D\0";
	ui_label = "3D Display Mode";
	ui_tooltip = "Side by Side/Top and Bottom/Line Interlaced displays output.";
> = 0;

uniform bool Eye_Swap <
	ui_label = "Eye Swap";
	ui_tooltip = "Left right image change.";
> = false;

uniform bool mouse < source = "key"; keycode = Cross_Cusor_Key; toggle = true; >;

uniform float2 Mousecoords < source = "mousepoint"; > ;

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
	float4 WDM = tex2D(DepthBuffer, float2(texcoord.x, texcoord.y));
		
		if (Alternate_Depth_Map == 0)
		{
		float cF = 100;
		float cN = 99;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}

		if (Alternate_Depth_Map == 1)
		{
		float cF = 10;
		float cN = 1;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		if (Alternate_Depth_Map == 2)
		{
		float cF  = 0.025;
		float cN = 1;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}

		if (Alternate_Depth_Map == 3)
		{
		float cF = 1;
		float cN = 0.025;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		if (Alternate_Depth_Map == 4)
		{
		float cF = 1.000;
		float cN = 0;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		if (Alternate_Depth_Map == 5)
		{
		float cF = 5;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		if (Alternate_Depth_Map == 6)
		{
		float cF  = 100;
		float cN = -0.01;
		depthM = cF / (1 + cF - (depthM/cN) * (1 - cF));
		}
		
		if (Alternate_Depth_Map == 7)
		{
		float cF = 1;
		float cN = 13;
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}

		if (Alternate_Depth_Map == 8)
		{
		float cF = 25;
		float cN = 25.869;
		depthM = (1 - (depthM * cF / (cF - cN) + cN) / depthM);
		}
		
		if (Alternate_Depth_Map == 9)
		{
		float cF = 1.025;
		float cN = 0.025;	
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000)/0.5;
		}
		
		if (Alternate_Depth_Map == 10)
		{
		float cF = 0.5;
		float cN = 0.150;
		depthM = log(depthM / cN) / log(cF / cN);
		}
		
	float4 D;
	float4 depthMFar;

    float A = Adjust;
	float cDF = 1.025;
	float cDN = 0;
	depthMFar = pow(abs((exp(depthM * log(cDF + cDN)) - cDN) / cDF),1000);	
    D = lerp(depthMFar,depthM,A);
        	
    color.rgb = clamp(D.rrr,0,1);
  		
	return color;	

}
	
float4 DisocclusionMask(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
	float4 color;
	float2 dir;
	float B;
	float Con = 10;
	float DP = Depth;
	float Disocclusion_Power = DP/1000;
	float Disocclusion_Power_Plus = DP/500;
	
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
	
	if(Disocclusion_Type == 3)
	{
	dir = float2(0.5,0);
	B = Disocclusion_Power_Plus;
	}
	
	if(Disocclusion_Type == 4)
	{
	dir = 0.5 - texcoord;
	B = Disocclusion_Power_Plus*2;
	}
	
	dir = normalize( dir ); 
	 
	[loop]
	for (int i = -0; i < 10; i++)
	{
	color += tex2D(SamplerCDM,texcoord + dir * weight[i] * B)/Con;
	}
	
	if(Disocclusion_Type == 0)
	{
	color = tex2D(SamplerCDM,texcoord.xy);
	}
	
	return color;
} 
  
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	
	const float samples[4] = {0.50, 0.66, 1};
	float DepthL = 1.0, DepthR = 1.0;
	float C = Convergence;
	float D = Depth;
	float2 uv = 0;
	[loop]
	for (int j = 0; j < 3; ++j) 
	{	
			uv.x = samples[j] * D;
			DepthL =  min(DepthL,tex2D(SamplerCC,float2(texcoord.x+uv.x*pix.x, texcoord.y)).r);
			DepthR =  min(DepthR,tex2D(SamplerCC,float2(texcoord.x-uv.x*pix.x, texcoord.y)).r);
	}
		if(!Eye_Swap)
		{	
			if(Custom_Sidebars == 0)
			{
			color = tex2D(BackBufferMIRROR, float2(texcoord.xy+float2((DepthL*D),0)*pix.xy));
			colorT = tex2D(BackBufferMIRROR, float2(texcoord.xy-float2((DepthR*D),0)*pix.xy));
			}
			else if(Custom_Sidebars == 1)
			{
			color = tex2D(BackBufferBORDER, float2(texcoord.xy+float2((DepthL*D),0)*pix.xy));
			colorT = tex2D(BackBufferBORDER, float2(texcoord.xy-float2((DepthR*D),0)*pix.xy));
			}
			else
			{
			color = tex2D(BackBufferCLAMP, float2(texcoord.xy+float2((DepthL*D),0)*pix.xy));
			colorT = tex2D(BackBufferCLAMP, float2(texcoord.xy-float2((DepthR*D),0)*pix.xy));
			}
		}
		else
		{		
			if(Custom_Sidebars == 0)
			{
			colorT = tex2D(BackBufferMIRROR, float2(texcoord.xy+float2((DepthL*D),0)*pix.xy));
			color = tex2D(BackBufferMIRROR, float2(texcoord.xy-float2((DepthR*D),0)*pix.xy));
			}
			else if(Custom_Sidebars == 1)
			{
			colorT = tex2D(BackBufferBORDER, float2(texcoord.xy+float2((DepthL*D),0)*pix.xy));
			color = tex2D(BackBufferBORDER, float2(texcoord.xy-float2((DepthR*D),0)*pix.xy));
			}
			else
			{
			colorT = tex2D(BackBufferCLAMP, float2(texcoord.xy+float2((DepthL*D),0)*pix.xy));
			color = tex2D(BackBufferCLAMP, float2(texcoord.xy-float2((DepthR*D),0)*pix.xy));
			}
		}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
	if(!Depth_Map_View)
	{
		if(Stereoscopic_Mode == 0)
		{	
			if(Custom_Sidebars == 0)
			{
			color = texcoord.x < 0.5 ? tex2D(SamplerCLMIRROR,float2(texcoord.x*2 + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRMIRROR,float2(texcoord.x*2-1 - Perspective * pix.x,texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.x < 0.5 ? tex2D(SamplerCLBORDER,float2(texcoord.x*2 + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRBORDER,float2(texcoord.x*2-1 - Perspective * pix.x,texcoord.y));
			}
			else
			{
			color = texcoord.x < 0.5 ? tex2D(SamplerCLCLAMP,float2(texcoord.x*2 + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRCLAMP,float2(texcoord.x*2-1 - Perspective * pix.x,texcoord.y));
			}
		}
		else if(Stereoscopic_Mode == 1)
		{
			if(Custom_Sidebars == 0)
			{
			color = texcoord.y < 0.5 ? tex2D(SamplerCLMIRROR,float2(texcoord.x + Perspective * pix.x,texcoord.y*2)) : tex2D(SamplerCRMIRROR,float2(texcoord.x - Perspective * pix.x,texcoord.y*2-1));	
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.y < 0.5 ? tex2D(SamplerCLBORDER,float2(texcoord.x + Perspective * pix.x,texcoord.y*2)) : tex2D(SamplerCRBORDER,float2(texcoord.x - Perspective * pix.x,texcoord.y*2-1));
			}
			else
			{
			color = texcoord.y < 0.5 ? tex2D(SamplerCLCLAMP,float2(texcoord.x + Perspective * pix.x,texcoord.y*2)) : tex2D(SamplerCRCLAMP,float2(texcoord.x - Perspective * pix.x,texcoord.y*2-1));
			}
		}
		else if(Stereoscopic_Mode == 2)
		{
			float gridL = frac(texcoord.y*(BUFFER_HEIGHT/2));
			if(Custom_Sidebars == 0)
			{
			color = gridL > 0.5 ? tex2D(SamplerCLMIRROR,float2(texcoord.x + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRMIRROR,float2(texcoord.x - Perspective * pix.x,texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = gridL > 0.5 ? tex2D(SamplerCLBORDER,float2(texcoord.x + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRBORDER,float2(texcoord.x - Perspective * pix.x,texcoord.y));			
			}
			else
			{
			color = gridL > 0.5 ? tex2D(SamplerCLCLAMP,float2(texcoord.x + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRCLAMP,float2(texcoord.x - Perspective * pix.x,texcoord.y));			
			}
		}
		else
		{
			float gridy = floor(texcoord.y*(BUFFER_HEIGHT));
			float gridx = floor(texcoord.x*(BUFFER_WIDTH));
			if(Custom_Sidebars == 0)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(SamplerCLMIRROR,float2(texcoord.x + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRMIRROR,float2(texcoord.x - Perspective * pix.x,texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(SamplerCLBORDER,float2(texcoord.x + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRBORDER,float2(texcoord.x - Perspective * pix.x,texcoord.y));
			}
			else
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(SamplerCLCLAMP,float2(texcoord.x + Perspective * pix.x,texcoord.y)) : tex2D(SamplerCRCLAMP,float2(texcoord.x - Perspective * pix.x,texcoord.y));
			}
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

technique Depth3D
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
			pass DisocclusionPass
		{
			VertexShader = PostProcessVS;
			PixelShader = DisocclusionMask;
			RenderTarget = texCC;
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
