 ////----------//
 ///**Medain**///
 //----------////
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 // For Reshade 3.0
 // --------------------------
 // This work is licensed under a Creative Commons Attribution 3.0 Unported License.
 // So you are free to share, modify and adapt it for your needs, and even use it for commercial use.
 // I would also love to hear about a project you are using it with.
 // https://creativecommons.org/licenses/by/3.0/us/
 //
 // Have fun,
 // Jose Negrete AKA BlueSkyDefender
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
uniform float Power <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "Median Power Slider";
	ui_tooltip = "Determines the Median Power.";
> = 1.0;

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

//sort two
void SortTwo(inout float4 a, inout float4 b)
{
	float4 store = a;
	a = min(a,b);
	b = max(store,b);
}

void Min(inout float4 x0, inout float4 x1 ,inout float4 x2){ SortTwo(x0, x1); SortTwo(x0, x2);}

void Max(inout float4 x0, inout float4 x1 ,inout float4 x2){ SortTwo(x1, x2); SortTwo(x0, x2);}

void Sort3(inout float4 x0, inout float4 x1, inout float4 x2) // 3 exchanges
{
	Max(x0,x1,x2);
	SortTwo(x0,x1);
}

void Sort4(inout float4 x0, inout float4 x1, inout float4 x2, inout float4 x3) // 4 exchanges
{
	SortTwo(x0,x1);
	SortTwo(x2,x3);
	SortTwo(x0,x2);
	SortTwo(x1,x3);
}

void Sort5(inout float4 x0, inout float4 x1, inout float4 x2, inout float4 x3, inout float4 x4)  // 6 exchanges
{
	SortTwo(x0,x1);
	SortTwo(x2,x3);
	Min(x0,x2,x4);
	Max(x1,x3,x4);
}

void Sort6(inout float4 x0, inout float4 x1, inout float4 x2, inout float4 x3, inout float4 x4 , inout float4 x5) // 7 exchanges
{
	SortTwo(x0,x3);
	SortTwo(x1,x4);
	SortTwo(x2,x5);
	Min(x0,x1,x2);
	Max(x3,x4,x5);
}

float4 Sort(float4 x0,float4 x1,float4 x2,float4 x3,float4 x4,float4 x5,float4 x6,float4 x7,float4 x8)
{
	Sort6(x0, x1, x2, x3, x4, x5);
		Sort5(x1, x2, x3, x4, x6);
			Sort4(x2, x3, x4, x7);
				Sort3(x3, x4, x8);
	return x4;
}

float4 Median(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float2 ScreenCal = float2(Power*pix.x,Power*pix.y), FinCal = ScreenCal*0.6;
	float4 C[9] = { tex2D(BackBuffer, texcoord + float2(-1,-1) * FinCal), // Right Down
					tex2D(BackBuffer, texcoord + float2(-1, 0) * FinCal), // Right
					tex2D(BackBuffer, texcoord + float2(-1, 1) * FinCal), // Right Up
					tex2D(BackBuffer, texcoord + float2( 0,-1) * FinCal), // Down
					tex2D(BackBuffer, texcoord),                          // Center
					tex2D(BackBuffer, texcoord + float2( 0, 1) * FinCal), // Up
					tex2D(BackBuffer, texcoord + float2( 1,-1) * FinCal), // Left Down
					tex2D(BackBuffer, texcoord + float2( 1, 0) * FinCal), // Left
					tex2D(BackBuffer, texcoord + float2( 1, 1) * FinCal)};// Up Left
	return Sort(C[0],C[1],C[2],C[3],C[4],C[5],C[6],C[7],C[8]);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	color = tex2D(SamplerMed,float2(texcoord.x,texcoord.y));
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

technique Median_Filter_Free
{
			pass MedianPass
		{
			VertexShader = PostProcessVS;
			PixelShader = Median;
			RenderTarget = texMed;
		}
			pass OutputPass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;
		}
}
