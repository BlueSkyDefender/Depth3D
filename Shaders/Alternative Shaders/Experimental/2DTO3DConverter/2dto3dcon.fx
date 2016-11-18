uniform int Depth <
	ui_type = "drag";
	ui_min = 0; ui_max = 75;
	ui_label = "Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation between both eyes. You can Override this setting.";
> = 25;

uniform float Convergence <
	ui_type = "drag";
	ui_min = -0.250; ui_max = 0.250;
	ui_label = "Convergence Slider";
	ui_tooltip = "Determines the Convergence point. Default is 0";
> = 0;

uniform float Match <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 100.0;
	ui_label = "Power";
	ui_tooltip = "Power Default is 1";
> = 1.0;

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

	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texLeft  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texRight  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texHSV  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture texPH { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture texPHL { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture texPHR { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texL { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 

texture PseudoDofTexS < source = "Sgrad.png"; > { Width = 1024; Height = 1024; MipLevels = 1; Format = RGBA8; };
sampler PseudoDofSamplerS { Texture = PseudoDofTexS; };


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
	
	
sampler Sampler
	{
		Texture = tex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
float3 DMRender(float2 texcoord : TEXCOORD0) : SV_Target
{
float micro_size = 2.5;
float shift_x = 0;
float shift_y = 0;
float patch_size;

	float2 p = floor(texcoord.xy / micro_size );
	float2 shift = float2(shift_x, shift_y);
	float2 offset = texcoord.xy / micro_size - p;
	int num_patches = 3;
	int num_images = 1;
	float best_slope = 0;
	float best_match = Match;
	
	[loop]
	for(float patch_size = micro_size / 2.0; patch_size >= 0.0; patch_size -= 0.5) 
	{
		float2 left_base = p * micro_size + shift - offset * patch_size;
		float score = 0;
		
		for (int i = 0; i < num_patches; i++) 
	{
		for(int j = 0; j < num_patches; j++) 
		{
				float2 pixel_shift = float2(i, j);
				float4 left = tex2Doffset(BackBuffer, texcoord, left_base + pixel_shift);
			for(int m = -num_images; m <= num_images; m++) 
			{
				for(int n = -num_images; n <= num_images; n++) 
				{
				if(m == 0 && n == 0) continue;
				float2 right_base = left_base + float2(m, n) * (micro_size + patch_size);
				float4 right = tex2Doffset(BackBuffer, texcoord , right_base + pixel_shift);
				score += distance(left, right);
				}
			}
		}
	}
		if(score < best_match) 
		{
			best_slope = patch_size;
			best_match = score;
		}
	}
	float sum = best_slope / (micro_size / 2.0);
	return lerp(float4(sum, sum, sum, 1.0),tex2D(PseudoDofSamplerS,texcoord.xy),0.50);
}


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
			DepthL =  min(DepthL,tex2D(Sampler,float2(texcoord.x+uv.x*pix.x, texcoord.y)).r)/1-C;
			DepthR =  min(DepthR,tex2D(Sampler,float2(texcoord.x-uv.x*pix.x, texcoord.y)).r)/1-C;
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
	float Perspective = 0;
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
		color = tex2D(Sampler,texcoord.xy);
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

//*Rendering passes*//
technique Super_2DTO3D
{								
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = DMRender;
			RenderTarget = tex;
		}

			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderLR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;
		}
			pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;
			
		}
}