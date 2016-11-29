 ////--------------------------//
 ///**Temporal Anti-Aliasing**///
 //--------------------------////
 
 
 //---------------------------------------------------------------------------------------------//
 // 	Temporal anti-aliasing Filter Made by Takashi Imagire ported over to Reshade by BSD 	//
 //		His website is http://t-pot.com/ 														//
 //		GitHub Link for source info https://github.com/imagire	  								//
 // 	Direct Link https://github.com/t-pot/TAA/blob/master/taa.hlsl  Thank You.	  			//
 //_____________________________________________________________________________________________//
 
 
uniform float TAAPower <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.250;
	ui_label = "TAA Power Slider";
	ui_tooltip = "Temporal anti-aliasing Power.";
> = 0.5;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
float3 RGB2YCbCr(float3 rgb)
{
	float3 RGB2Y = float3(0.29900, 0.58700, 0.11400);
	float3 RGB2Cb = float3(-0.16874, -0.33126, 0.50000);
	float3 RGB2Cr = float3(0.50000, -0.41869, -0.081);

	return float3(dot(rgb, RGB2Y), dot(rgb, RGB2Cb), dot(rgb, RGB2Cr));
}

float3 YCbCr2RGB(float3 ycc)
{
	float3 YCbCr2R = float3(1.0, 0.00000, 1.40200);
	float3 YCbCr2G = float3(1.0,-0.34414, -0.71414);
	float3 YCbCr2B = float3(1.0, 1.77200, 1.40200);

	return float3(dot(ycc, YCbCr2R), dot(ycc, YCbCr2G), dot(ycc, YCbCr2B));
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
	const float2 XYoffset[4] = { float2( 0, +1 ), float2( 0, -1 ), float2(+1,  0 ), float2(-1,  0) };

	float4 center_color = tex2D(BackBuffer, texcoord);

	float4 neighbor_sum = center_color;

	for (int i = 0; i < 4; i++)
	{
		//Take points in the vicinity
		float4 neighbor = tex2D(BackBuffer, texcoord + XYoffset[i] * pix * TAAPower);
		
		float3 color_diff = abs(neighbor.xyz - center_color.xyz);
		
		float3 ycc = RGB2YCbCr(color_diff.xyz); //Watch the difference with the center with YCbCr
		
		const float cbcr_threshhold = TAAPower;
		
		float cbcr_len = length(color_diff.yz); 
		
		if (cbcr_threshhold < cbcr_len)
		{
			ycc = (cbcr_threshhold / cbcr_len) * ycc; //When the hue component is largely different, the color is corrected to the range that falls within the threshold value and synthesized
			
			neighbor.rgb = center_color.rgb + YCbCr2RGB(ycc);
		}
		neighbor_sum += neighbor;
	}
	float4 Color = neighbor_sum / 5.0f;

	color =  Color;
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

technique Temporal_AA
{
			pass TAAOutputPass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;	
		}
}
