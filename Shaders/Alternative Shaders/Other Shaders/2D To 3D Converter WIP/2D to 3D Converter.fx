 ////----------------------//
 ///**2D to 3D Converter**///
 //----------------------////
 
uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 25;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes. You can Override this setting.";
> = 15;

uniform int Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0;

uniform float Adjust <
	ui_type = "drag";
	ui_min = 0.50; ui_max = 1.0;
	ui_label = "Fake Buffer Power";
	ui_tooltip = "Determines the amount of fake buffer is used.";
> = 0.750;

uniform int HSVSwitch <
	ui_type = "combo";
	ui_items = "One\0Two\0Three\0Four\0Five\0";
	ui_label = "HSV Color Switch";
	ui_tooltip = "HSV Color Switch To match the Content Color your playin.";
> = 2;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Select how you like the Edge of the screen to look like.";
> = 1;

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

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

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
	
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerCC
	{
		Texture = texCC;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
texture texCDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 

sampler SamplerCDM
	{
		Texture = texCDM;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
texture texY  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 

sampler SamplerY
	{
		Texture = texY;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};

texture texHSV  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 

sampler SamplerHSV
	{
		Texture = texHSV;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
		
texture PseudoDofTexS < source = "Sgrad.png"; > { Width = 1024; Height = 1024; MipLevels = 1; Format = RGBA8; };
sampler PseudoDofSamplerS { Texture = PseudoDofTexS; };
	
float3 RGB2YCbCr(float3 yuv)
{
	// YUV offset
	const float3 offset = float3(-0.0625, -0.5, -0.5);
	
	// RGB coefficients
	const float3 Rcoeff = float3( 1.164, 0.000,  1.596);
	const float3 Gcoeff = float3( 1.164, -0.391, -0.813);
	const float3 Bcoeff = float3( 1.164, 2.018,  0.000);

	float3 rgb;

	yuv = clamp(yuv, 0.0, 1.0);

	yuv += offset;

	rgb.r = dot(yuv, Rcoeff);
	rgb.g = dot(yuv, Gcoeff);
	rgb.b = dot(yuv, Bcoeff);
	
	return rgb;
	
}


float4 Y(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
  float4 lum = float4(0.30, 0.59, 0.11, 1);
 
  // TOP ROW
  float s11 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(-1.0f / 1024.0f, -1.0f / 768.0f)).rgb).x , lum);   // LEFT
  float s12 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(0, -1.0f / 768.0f)).rgb).x, lum);             // MIDDLE
  float s13 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(1.0f / 1024.0f, -1.0f / 768.0f)).rgb).x, lum);    // RIGHT
 
  // MIDDLE ROW
  float s21 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(-1.0f / 1024.0f, 0)).rgb).x, lum);                // LEFT
  // Omit center
  float s23 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(-1.0f / 1024.0f, 0)).rgb).x, lum);                // RIGHT
 
  // LAST ROW
  float s31 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(-1.0f / 1024.0f, 1.0f / 768.0f)).rgb).x, lum);    // LEFT
  float s32 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(0, 1.0f / 768.0f)).rgb).x, lum);              // MIDDLE
  float s33 = dot(RGB2YCbCr(tex2D(BackBuffer,texcoord + float2(1.0f / 1024.0f, 1.0f / 768.0f)).rgb).x, lum); // RIGHT
 
  float t1 = s13 + s33 + (2 * s23) - s11 - (2 * s21) - s31;
  float t2 = s31 + (2 * s32) + s33 - s11 - (2 * s12) - s13;
 
  float4 col;
 
  if (((t1 * t1) + (t2 * t2)) > 1000) {
  col = float4(0,0,0,1);
  } else {
    col = float4(1,1,1,1);
  }
 
  return col;
  
	//return RGB2YCbCr(tex2D(BackBuffer,texcoord).rgb).x;
} 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float4 DM(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
return 1-(0.3*(tex2D(SamplerY,texcoord))+0.3*RGB2YCbCr(tex2D(BackBuffer,texcoord).rgb).y+0.5*(0.5*RGB2YCbCr(tex2D(BackBuffer,texcoord).rgb).x+0.2*RGB2YCbCr(tex2D(BackBuffer,texcoord).rgb).y+0.3* RGB2YCbCr(tex2D(BackBuffer,texcoord).rgb).z));
}

float4 RGBtoHSV(float2 texcoord : TEXCOORD0) : SV_Target
{
    float3 HCV = tex2D(BackBuffer,texcoord).rgb;
    float S;
    
    if(HSVSwitch == 0)
    {
    S = HCV.y / (HCV.z + 0.25);
    }
    else if(HSVSwitch == 1)
    {
    S = HCV.y / (HCV.z + 0.50);
    }
    else if(HSVSwitch == 2)
    {
    S = HCV.y / (HCV.z + 0.75);
    }
    else if(HSVSwitch == 3)
    {
    S = HCV.y / (HCV.z + 1.0);
    }
    else
    {
    S = HCV.y / (HCV.z + 100);
    }
    
    float3 gray_scale = float3(HCV.x, S, HCV.z);	
	return  dot(gray_scale, float3(0.3, 0.59, 0.11))+tex2D(SamplerCDM, texcoord);
}


////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	
	const float samples[4] = {0.25, 0.50, 0.75, 1};
	float DepthL = 1.0, DepthR = 1.0;
	float D = Depth;
	float2 uv = 0;
	float2 FAKE = 0;
	[loop]
	for (int j = 0; j <= 3; ++j) 
	{	
			uv.x = samples[j] * D;
			DepthL =  min(DepthL,lerp(tex2D(PseudoDofSamplerS,float2(texcoord.x+uv.x*pix.x, texcoord.y)).r,tex2D(SamplerHSV,float2(texcoord.x+uv.x*pix.x, texcoord.y)).r,Adjust));
			DepthR =  min(DepthR,lerp(tex2D(PseudoDofSamplerS,float2(texcoord.x-uv.x*pix.x, texcoord.y)).r,tex2D(SamplerHSV,float2(texcoord.x-uv.x*pix.x, texcoord.y)).r,Adjust));
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
		color = tex2D(SamplerHSV,texcoord);
	}
}

///////////////////////////////////////////////////////////ReShade.fxh///////////////////////////////////////////////////////////////

// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

//*Rendering passes*//

technique Converter
{
			pass Y
		{
			VertexShader = PostProcessVS;
			PixelShader = Y;
			RenderTarget = texY;
		}
			pass HSV
		{
			VertexShader = PostProcessVS;
			PixelShader = RGBtoHSV;
			RenderTarget = texHSV;
		}
			pass DM
		{
			VertexShader = PostProcessVS;
			PixelShader = DM;
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
