 ////----------------//
 ///**BSD_Medain2X**///
 //----------------////

uniform float Power <
	ui_type = "drag";
	ui_min = 0.1; ui_max = 2.5;
	ui_label = "Median Power Slider";
	ui_tooltip = "Determines the Median Power.";
> = 1.0;

uniform int MedianFilter <
	ui_type = "combo";
	ui_items = "Off\0Median On\0Median 2X\0Median Control\0Median 2X Control\0";
	ui_label = "Median Selection";
> = 0;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};

texture texMed { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;};

sampler SamplerMed
	{
		Texture = texMed;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
texture texMedOne { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;};

sampler SamplerMedOne
	{
		Texture = texMedOne;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
#define s2(a, b)				temp = a; a = min(a, b); b = max(temp, b);
#define mn3(a, b, c)			s2(a, b); s2(a, c);
#define mx3(a, b, c)			s2(b, c); s2(a, c);

#define mnmx3(a, b, c)			mx3(a, b, c); s2(a, b);                                   // 3 exchanges
#define mnmx4(a, b, c, d)		s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
#define mnmx5(a, b, c, d, e)	s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
#define mnmx6(a, b, c, d, e, f) s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges	

float4 Median(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
	float2 ScreenCal;
    if(MedianFilter == 3)
    {
    ScreenCal = float2(Power*pix.x,Power*pix.y);
    }
    else
    {
    ScreenCal = float2(2.5*pix.x,2.5*pix.y);
	}
	float2 FinCal = ScreenCal*0.6;

	float4 v[9];
	[unroll]
	for(int i = -1; i <= 1; ++i) 
	{
		for(int j = -1; j <= 1; ++j)
		{		
		  float2 offset = float2(float(i), float(j));

		  v[(i + 1) * 3 + (j + 1)] = tex2D(BackBuffer, texcoord + offset * FinCal);
		}
	}

	float4 temp;

	mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
	mnmx5(v[1], v[2], v[3], v[4], v[6]);
	mnmx4(v[2], v[3], v[4], v[7]);
	mnmx3(v[3], v[4], v[8]);
	
	return v[4];
}

float4 MedianOne(float4 position : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
	float2 ScreenCal;
    if(MedianFilter == 4)
    {
    ScreenCal = float2(Power*pix.x,Power*pix.y);
    }
    else
    {
    ScreenCal = float2(2.5*pix.x,2.5*pix.y);
	}
	float2 FinCal = ScreenCal*0.6;

	float4 v[9];
	[unroll]
	for(int i = -1; i <= 1; ++i) 
	{
		for(int j = -1; j <= 1; ++j)
		{		
		  float2 offset = float2(float(i), float(j));
		  
		  v[(i + 1) * 3 + (j + 1)] = tex2D(SamplerMed, texcoord + offset * FinCal);
		}
	}

	float4 temp;

	mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
	mnmx5(v[1], v[2], v[3], v[4], v[6]);
	mnmx4(v[2], v[3], v[4], v[7]);
	mnmx3(v[3], v[4], v[8]);
	
	return v[4];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{

	if(MedianFilter == 1 || MedianFilter == 3)
	{
	color = tex2D(SamplerMed,float2(texcoord.x,texcoord.y));	
	}
	else if(MedianFilter == 2 || MedianFilter == 4)
	{
	color = tex2D(SamplerMedOne,float2(texcoord.x,texcoord.y));	
	}
	else
	{
	color = tex2D(BackBuffer,float2(texcoord.x,texcoord.y));
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

technique Median_Filter
{
			pass MedianPass
		{
			VertexShader = PostProcessVS;
			PixelShader = Median;
			RenderTarget = texMed;
		}
			pass MedianPassOne
		{
			VertexShader = PostProcessVS;
			PixelShader = MedianOne;
			RenderTarget = texMedOne;
		}
			pass OutputPass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;	
		}
}
