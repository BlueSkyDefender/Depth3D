 ////-----------------------------//
 ///**Temporal Aliasing Reducer**///
 //-----------------------------////
 
 
 //---------------------------------------------------------------------------------------------//
 // 	Temporal anti-aliasing Filter Made by Takashi Imagire 									//
 //		ported over to Reshade and moded by BSD													// 
 //		His website is http://t-pot.com/ 														//
 //		GitHub Link for source info https://github.com/imagire	  								//
 // 	Direct Link https://github.com/t-pot/TAA/blob/master/taa.hlsl  Thank You.	  			//
 //_____________________________________________________________________________________________//
 
 uniform float Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1;
	ui_label = "Four Point Adjust";
	ui_tooltip = "To fine tune Adjustment.";
> = 0.5;
 
uniform float Threshhold <
	ui_type = "drag";
	ui_min = 0.1; ui_max = 0.5;
	ui_label = "Threshhold";
	ui_tooltip = "Threshhold Adjustment.";
> = 0.250;

uniform float Power <
	ui_type = "drag";
	ui_min = 0.1; ui_max = 100;
	ui_label = "Median Power Slider";
	ui_tooltip = "Determines the Median Power.";
> = 4.0;

uniform int DebugOutput <
	ui_type = "combo";
	ui_items = "Off\0On\0";
	ui_label = "Debug Output";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture texCC  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerCC
	{
		Texture = texCC;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
float3 RGB2YCoCg(float3 c)//YCoCg seems to work better then YCbCr
{

	return float3(
			 c.x/4.0 + c.y/2.0 + c.z/4.0,
			 c.x/2.0 - c.z/2.0,
			-c.x/4.0 + c.y/2.0 - c.z/4.0
					);
	
}

float3 YCoCg2RGB(float3 c)
{	

	if(DebugOutput == 0)
	{
			return saturate(float3(
			c.x + c.y - c.z,
			c.x + c.z,
			c.x - c.y - c.z
		));
	}
	else
	{
	return float3(
			1,0,0
		);
	}
}

texture texMed { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA32F;};

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

    ScreenCal = float2(Power*pix.x,Power*pix.y);

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void PS(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
	const float2 XYoffset[4] = { float2( 0, 1 ), float2( 0, -1 ), float2(1, 0 ), float2(-1, 0) };

	float4 center_color = tex2D(SamplerMed, texcoord);

	float4 neighbor_sum = center_color;

	for (int i = 0; i < 4; i++)
	{
		//Take points in the vicinity
		float4 neighbor = tex2D(BackBuffer, texcoord + XYoffset[i] * pix * Adjust);
		
		float3 color_diff = abs(neighbor.xyz - center_color.xyz) ;
		
		float3 ycc = RGB2YCoCg(color_diff.xyz); //Watch the difference with the center with YCoCg
		
		const float cbcr_threshhold = Threshhold;
		
		float cbcr_len = length(color_diff.yz); 
		
		if (cbcr_threshhold < cbcr_len)
		{
			ycc = (cbcr_threshhold / cbcr_len) * ycc ; //When the hue component is largely different, the color is corrected to the range that falls within the threshold value and synthesized
			
			neighbor.rgb = center_color.rgb + YCoCg2RGB(ycc);
		}
		neighbor_sum += neighbor;
	}
	float4 Color = neighbor_sum / 5.0f;
	
color =  Color;
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

technique Temporal_Aliasing_Reducer
{
	pass MedianPass
		{
			VertexShader = PostProcessVS;
			PixelShader = Median;
			RenderTarget = texMed;
		}

			pass TAOutputPass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS;
		}
		


}
