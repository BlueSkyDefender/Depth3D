 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Color based 3D post-process shader v1																																			*//
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

uniform int blur <
	ui_type = "drag";
	ui_min = 0; ui_max = 25;
	ui_label = "Blur Slider";
	ui_tooltip = "Determines the amount of Depth Map Blur.";
> = 3;

uniform bool LRRL <
	ui_label = "Eye Swap";
	ui_tooltip = "Left right image change.";
> = false;

uniform bool CS <
	ui_label = "Circle or Square";
	ui_tooltip = "Gradient change.";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;};

texture PseudoDofTexC < source = "Cgrad.png"; > { Width = 1024; Height = 1024; MipLevels = 1; Format = RGBA8; };
sampler PseudoDofSamplerC { Texture = PseudoDofTexC; };

texture PseudoDofTexS < source = "Sgrad.png"; > { Width = 1024; Height = 1024; MipLevels = 1; Format = RGBA8; };
sampler PseudoDofSamplerS { Texture = PseudoDofTexS; };


texture DepthBufferTex : DEPTH;
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex; 
	};

sampler DepthBuffer 
	{ 
		Texture = DepthBufferTex; 
	};

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
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
	sampler SamplerCCL
	{
		Texture = texCCL;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
sampler2D SamplerCDM
	{
		Texture = texCDM;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};

float4 HQ4X(float2 uv : TEXCOORD)
{
	float mx = 1; // start smoothing wt.
	const float k = -1.10; // wt. decrease factor
	const float max_w = 1; // max filter weigth
	const float min_w = 0.03; // min filter weigth
	const float lum_add = 0.33; // effects smoothing

	float4 color = tex2D(BackBuffer, uv);
	float3 c = color.xyz;

	float x = 0.5 * (1.0 / 256.0);
	float y = 0.5 * (1.0 / 256.0);

	const float3 dt = 1.0*float3(1.0, 1.0, 1.0);

	float2 dg1 = float2( x, y);
	float2 dg2 = float2(-x, y);

	float2 sd1 = dg1*0.5;
	float2 sd2 = dg2*0.5;

	float2 ddx = float2(x,0.0);
	float2 ddy = float2(0.0,y);

	float4 t1 = float4(uv-sd1,uv-ddy);
	float4 t2 = float4(uv-sd2,uv+ddx);
	float4 t3 = float4(uv+sd1,uv+ddy);
	float4 t4 = float4(uv+sd2,uv-ddx);
	float4 t5 = float4(uv-dg1,uv-dg2);
	float4 t6 = float4(uv+dg1,uv+dg2);

	float3 i1 = tex2D(BackBuffer, t1.xy).xyz;
	float3 i2 = tex2D(BackBuffer, t2.xy).xyz;
	float3 i3 = tex2D(BackBuffer, t3.xy).xyz;
	float3 i4 = tex2D(BackBuffer, t4.xy).xyz;

	float3 o1 = tex2D(BackBuffer, t5.xy).xyz;
	float3 o3 = tex2D(BackBuffer, t6.xy).xyz;
	float3 o2 = tex2D(BackBuffer, t5.zw).xyz;
	float3 o4 = tex2D(BackBuffer, t6.zw).xyz;

	float3 s1 = tex2D(BackBuffer, t1.zw).xyz;
	float3 s2 = tex2D(BackBuffer, t2.zw).xyz;
	float3 s3 = tex2D(BackBuffer, t3.zw).xyz;
	float3 s4 = tex2D(BackBuffer, t4.zw).xyz;

	float ko1 = dot(abs(o1-c),dt);
	float ko2 = dot(abs(o2-c),dt);
	float ko3 = dot(abs(o3-c),dt);
	float ko4 = dot(abs(o4-c),dt);

	float k1=min(dot(abs(i1-i3),dt),max(ko1,ko3));
	float k2=min(dot(abs(i2-i4),dt),max(ko2,ko4));

	float w1 = k2; if(ko3<ko1) w1*=ko3/ko1;
	float w2 = k1; if(ko4<ko2) w2*=ko4/ko2;
	float w3 = k2; if(ko1<ko3) w3*=ko1/ko3;
	float w4 = k1; if(ko2<ko4) w4*=ko2/ko4;

	c=(w1*o1+w2*o2+w3*o3+w4*o4+0.001*c)/(w1+w2+w3+w4+0.001);
	w1 = k*dot(abs(i1-c)+abs(i3-c),dt)/(0.125*dot(i1+i3,dt)+lum_add);
	w2 = k*dot(abs(i2-c)+abs(i4-c),dt)/(0.125*dot(i2+i4,dt)+lum_add);
	w3 = k*dot(abs(s1-c)+abs(s3-c),dt)/(0.125*dot(s1+s3,dt)+lum_add);
	w4 = k*dot(abs(s2-c)+abs(s4-c),dt)/(0.125*dot(s2+s4,dt)+lum_add);

	w1 = clamp(w1+mx,min_w,max_w);
	w2 = clamp(w2+mx,min_w,max_w);
	w3 = clamp(w3+mx,min_w,max_w);
	w4 = clamp(w4+mx,min_w,max_w);

	return float4((w1*(i1+i3)+w2*(i2+i4)+w3*(s1+s3)+w4*(s2+s4)+c)/(2.0*(w1+w2+w3+w4)+1.0), 1.0);
}

float Blur(float2 texcoord : TEXCOORD0)
{
float4 color;
	if(blur > 0)
	{
	const float weight[11] = {
		0.082607,
		0.080977,
		0.076276,
		0.069041,
		0.060049,
		0.050187,
		0.040306,
		0.031105,
		0.023066,
		0.016436,
		0.011254
	};
	[loop]
	for (int i = -0; i < 5; i++)
	{
		float currweight = weight[abs(i)];
		color += (HQ4X( texcoord.xy + float2(1,0) * (float)i * pix.x * blur) * currweight + HQ4X( texcoord.xy + float2(1,0) * (float)i * pix.x * -blur) * currweight)  / 0.75;
	}
	}
	else
	{
	color = HQ4X(texcoord.xy);
	}
	return color;
}


//Depth Map Information	
void Grade(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{

 float3 px = Blur(float2(texcoord.x,texcoord.y)) - HQ4X(texcoord.xy);
 
color = px;
 
}
  
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float3 color : SV_Target0 , out float3 colorT: SV_Target1)
{	
	const float samples[4] = {0.5, 0.66, 1, 0.25};
	float DepthL = 1, DepthR = 1;
	float2 uv = 0;
	[loop]
	for (int j = 0; j <= 3; ++j) 
	{
			if(!CS)
		{
			uv.x = samples[j] * Depth*5;
			DepthL =  min(DepthL,(tex2D(PseudoDofSamplerS,float2(texcoord.x+uv.x*pix.x, texcoord.y)).r)-tex2D(SamplerCC,float2(texcoord.x, texcoord.y)).b);
			DepthR =  min(DepthR,(tex2D(PseudoDofSamplerS,float2(texcoord.x-uv.x*pix.x, texcoord.y)).r)-tex2D(SamplerCC,float2(texcoord.x, texcoord.y)).b);
		}
		else
		{
			DepthL =  min(DepthL,1 - (tex2D(PseudoDofSamplerC,float2(texcoord.x+uv.x*pix.x, texcoord.y)).r)-tex2D(SamplerCC,float2(texcoord.x, texcoord.y)).b);
			DepthR =  min(DepthR,1 - (tex2D(PseudoDofSamplerC,float2(texcoord.x-uv.x*pix.x, texcoord.y)).r)-tex2D(SamplerCC,float2(texcoord.x, texcoord.y)).b);
		}	

			//color.rgb = DepthL;
			color.rgb = tex2D(BackBuffer , float2(texcoord.xy+float2(DepthL*Depth,0)*pix.xy)).rgb;
		
			colorT.rgb = tex2D(BackBuffer , float2(texcoord.xy-float2(DepthR*Depth,0)*pix.xy)).rgb;
	
	}
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float3 color : SV_Target)
{

	color = texcoord.x < 0.5 ? tex2D(SamplerCL,float2(texcoord.x*2 + Perspective * pix.x,texcoord.y)).rgb : tex2D(SamplerCR,float2(texcoord.x*2-1 - Perspective * pix.x,texcoord.y)).rgb;
	
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

technique Super_Depth3D
{
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = Grade;
			RenderTarget = texCC;
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
