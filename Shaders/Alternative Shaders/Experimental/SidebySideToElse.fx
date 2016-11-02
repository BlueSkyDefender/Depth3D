 ////--------------------//
 ///**SidebySideToElse**///
 //--------------------////

// Change the Cross Cusor Key
// Determines the Cusor Toggle Key useing keycode info
// You can use http://keycode.info/ to figure out what key is what.
// key B is Key Code 66, This is Default. Ex. Key 187 is the code for Equal Sign =.

#define Cross_Cusor_Key 66

uniform int Perspective <
	ui_type = "drag";
	ui_min = -350; ui_max = 350;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point.";
> = 295;

uniform int Polynomial_Barrel_Distortion <
	ui_type = "combo";
	ui_items = "Off\0Polynomial Distortion\0";
	ui_label = "Polynomial Barrel Distortion";
	ui_tooltip = "Barrel Distortion for HMD type Displays.";
> = 0;

uniform float Lens_Center <
	ui_type = "drag";
	ui_min = 0.475; ui_max = 0.575;
	ui_label = "Lens Center";
	ui_tooltip = "Adjust Lens Center. Default is 0.5";
> = 0.5;

uniform float Lens_Distortion <
	ui_type = "drag";
	ui_min = -1; ui_max = 5;
	ui_label = "Lens Distortion";
	ui_tooltip = "Lens distortion value.";
> = 0.0;

uniform float3 Polynomial_Colors <
	ui_type = "color";
	ui_min = 0.0; ui_max = 2.0;
	ui_tooltip = "Adjust the Polynomial Distortion Red, Green, Blue. Default is (R 255, G 255, B 255)";
	ui_label = "Polynomial Color Distortion";
> = float3(1.0, 1.0, 1.0);

uniform float2 Horizontal_Vertical_Squish <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2;
	ui_label = "Horizontal & Vertical";
	ui_tooltip = "Adjust Horizontal and Vertical squish cubic distortion value. Default is 1.0.";
> = float2(1,1);

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

uniform int SidebySideToElse <
	ui_type = "combo";
	ui_items = "Off\0ON\0";
	ui_label = "Side by Side to Else";
	ui_tooltip = "NUll";
> = 0;

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

uniform int HMD_Profiles <
	ui_type = "combo";
	ui_items = "Off\0Profile One\0";
	ui_label = "Head Mounted Display Profiles";
	ui_tooltip = "Preset Head Mounted Display Profiles";
> = 0;

uniform bool mouse < source = "key"; keycode = Cross_Cusor_Key; toggle = true; >;

uniform float2 Mousecoords < source = "mousepoint"; > ;

////////////////////////////////////////////////HMD Profiles/////////////////////////////////////////////////////////////////
//Lens Distortion Area//
float LD()
{
float L_D = Lens_Distortion;
if (HMD_Profiles == 0)
{
 L_D;
}

if (HMD_Profiles == 1)
{
 L_D = -0.5;
}
return L_D;
}

//Horizontal Vertical Squish Area//
float2 H_V_S()
{
float2 H_V_S = Horizontal_Vertical_Squish;
if (HMD_Profiles == 0)
{
 H_V_S;
}

if (HMD_Profiles == 1)
{
 H_V_S = float2(1,1.25);
}
return H_V_S;
}

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
  
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
void PS_renderLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	

		if(SidebySideToElse == 0)
		{	
			if(!Eye_Swap)
			{	
				if(Custom_Sidebars == 0)
				{
				color =  tex2D(BackBufferMIRROR,texcoord.xy);
				colorT = tex2D(BackBufferMIRROR,texcoord.xy);
				}
				else if(Custom_Sidebars == 1)
				{
				color = tex2D(BackBufferBORDER, texcoord.xy);
				colorT = tex2D(BackBufferBORDER,texcoord.xy);
				}
				else
				{
				color = tex2D(BackBufferCLAMP, texcoord.xy);
				colorT = tex2D(BackBufferCLAMP,texcoord.xy);
				}
			}
			else
			{		
				if(Custom_Sidebars == 0)
				{
				colorT = tex2D(BackBufferMIRROR,texcoord.xy);
				color = tex2D(BackBufferMIRROR, texcoord.xy);
				}
				else if(Custom_Sidebars == 1)
				{
				colorT = tex2D(BackBufferBORDER,texcoord.xy);
				color = tex2D(BackBufferBORDER, texcoord.xy);
				}
				else
				{
				colorT = tex2D(BackBufferCLAMP,texcoord.xy);
				color = tex2D(BackBufferCLAMP, texcoord.xy);
				}
			}
		}
		else
		{
		if(!Eye_Swap)
			{	
				if(Custom_Sidebars == 0)
				{
				color =  tex2D(BackBufferMIRROR,float2(texcoord.x*0.5,texcoord.y));
				colorT = tex2D(BackBufferMIRROR,float2(texcoord.x*0.5+0.5,texcoord.y));
				}
				else if(Custom_Sidebars == 1)
				{
				color = tex2D(BackBufferBORDER,float2(texcoord.x*0.5,texcoord.y));
				colorT = tex2D(BackBufferBORDER,float2(texcoord.x*0.5+0.5,texcoord.y));
				}
				else
				{
				color =  tex2D(BackBufferCLAMP,float2(texcoord.x*0.5,texcoord.y)) ;
				colorT =  tex2D(BackBufferCLAMP,float2(texcoord.x*0.5+0.5,texcoord.y));
				}
			}
			else
			{		
				if(Custom_Sidebars == 0)
				{
				colorT = tex2D(BackBufferMIRROR,float2(texcoord.x*0.5+0.5,texcoord.y));
				color = tex2D(BackBufferMIRROR,float2(texcoord.x*0.5,texcoord.y));
				}
				else if(Custom_Sidebars == 1)
				{
				colorT = tex2D(BackBufferBORDER,float2(texcoord.x*0.5+0.5,texcoord.y));
				color = tex2D(BackBufferBORDER,float2(texcoord.x*0.5,texcoord.y));
				}
				else
				{
				colorT = tex2D(BackBufferCLAMP,float2(texcoord.x*0.5+0.5,texcoord.y));
				color = tex2D(BackBufferCLAMP,float2(texcoord.x*0.5,texcoord.y));
				}
			}
		}
}


////////////////////////////////////////////////////Polynomial_Distortion/////////////////////////////////////////////////////

float2 DL(float2 p, float k1) //Cubic Lens Distortion 
{
	float LC = 1-Lens_Center;
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * k1 + (LD() * sqrt(r2));

	 p.x = newRadius * (p.x-0.5)+0.5;
	 p.y = newRadius * (p.y-0.5)+0.5;
	
	return p;
}

float2 DR(float2 p, float k1) //Cubic Lens Distortion 
{
	float LC = Lens_Center;
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * k1 + (LD() * sqrt(r2));

	 p.x = newRadius * (p.x-0.5)+0.5;
	 p.y = newRadius * (p.y-0.5)+0.5;
	
	return p;
}

float4 PDL(float2 texcoord)

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = Polynomial_Colors.x;
		Green = Polynomial_Colors.y;
		Blue = Polynomial_Colors.z;
		
		uv_red = DL(texcoord.xy-sectorOrigin,Red) + sectorOrigin;
		uv_green = DL(texcoord.xy-sectorOrigin,Green) + sectorOrigin;
		uv_blue = DL(texcoord.xy-sectorOrigin,Blue) + sectorOrigin;
		
		if(Custom_Sidebars == 0)
		{
		color_red = tex2D(SamplerCLMIRROR, uv_red).r;
		color_green = tex2D(SamplerCLMIRROR, uv_green).g;
		color_blue = tex2D(SamplerCLMIRROR, uv_blue).b;
		}
		else if(Custom_Sidebars == 1)
		{
		color_red = tex2D(SamplerCLBORDER, uv_red).r;
		color_green = tex2D(SamplerCLBORDER, uv_green).g;
		color_blue = tex2D(SamplerCLBORDER, uv_blue).b;
		}
		else
		{
		color_red = tex2D(SamplerCLCLAMP, uv_red).r;
		color_green = tex2D(SamplerCLCLAMP, uv_green).g;
		color_blue = tex2D(SamplerCLCLAMP, uv_blue).b;
		}

		if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
		{
			color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
		}
		else
		{
			color = float4(0,0,0,1);
		}
		return color;
		
	}
	
	float4 PDR(float2 texcoord)

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = Polynomial_Colors.x;
		Green = Polynomial_Colors.y;
		Blue = Polynomial_Colors.z;
		
		uv_red = DR(texcoord.xy-sectorOrigin,Red) + sectorOrigin;
		uv_green = DR(texcoord.xy-sectorOrigin,Green) + sectorOrigin;
		uv_blue = DR(texcoord.xy-sectorOrigin,Blue) + sectorOrigin;
		
		if(Custom_Sidebars == 0)
		{
		color_red = tex2D(SamplerCRMIRROR, uv_red).r;
		color_green = tex2D(SamplerCRMIRROR, uv_green).g;
		color_blue = tex2D(SamplerCRMIRROR, uv_blue).b;
		}
		else if(Custom_Sidebars == 1)
		{
		color_red = tex2D(SamplerCRBORDER, uv_red).r;
		color_green = tex2D(SamplerCRBORDER, uv_green).g;
		color_blue = tex2D(SamplerCRBORDER, uv_blue).b;
		}
		else
		{
		color_red = tex2D(SamplerCRCLAMP, uv_red).r;
		color_green = tex2D(SamplerCRCLAMP, uv_green).g;
		color_blue = tex2D(SamplerCRCLAMP, uv_blue).b;
		}

		if( ((uv_red.x > 0) && (uv_red.x < 1) && (uv_red.y > 0) && (uv_red.y < 1)))
		{
			color = float4(color_red.x, color_green.y, color_blue.z, 1.0);
		}
		else
		{
			color = float4(0,0,0,1);
		}
		return color;
		
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
	float posH = H_V_S().y-1;
	float midH = posH*BUFFER_HEIGHT/2*pix.y;
		
	float posV = H_V_S().x-1;
	float midV = posV*BUFFER_WIDTH/2*pix.x;
	if(Polynomial_Barrel_Distortion == 0)
	{
	if(Stereoscopic_Mode == 0)
		{	
			if(Custom_Sidebars == 0)
			{
			color = texcoord.x < 0.5 ? tex2D(SamplerCLMIRROR,float2(((texcoord.x*2)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRMIRROR,float2(((texcoord.x*2-1)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.x < 0.5 ? tex2D(SamplerCLBORDER,float2(((texcoord.x*2)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRBORDER,float2(((texcoord.x*2-1)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
			else
			{
			color = texcoord.x < 0.5 ? tex2D(SamplerCLCLAMP,float2(((texcoord.x*2)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRCLAMP,float2(((texcoord.x*2-1)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}	
		}
		else if(Stereoscopic_Mode == 1)
		{
			if(Custom_Sidebars == 0)
			{
			color = texcoord.y < 0.5 ? tex2D(SamplerCLMIRROR,float2((texcoord.x*H_V_S().x)-midV + Perspective * pix.x,((texcoord.y*2)*H_V_S().y)-midH)) : tex2D(SamplerCRMIRROR,float2((texcoord.x*H_V_S().x)-midV - Perspective * pix.x,((texcoord.y*2-1)*H_V_S().y)-midH));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.y < 0.5 ? tex2D(SamplerCLBORDER,float2((texcoord.x*H_V_S().x)-midV + Perspective * pix.x,((texcoord.y*2)*H_V_S().y)-midH)) : tex2D(SamplerCRBORDER,float2((texcoord.x*H_V_S().x)-midV - Perspective * pix.x,((texcoord.y*2-1)*H_V_S().y)-midH));		
			}
			else
			{
			color = texcoord.y < 0.5 ? tex2D(SamplerCLCLAMP,float2((texcoord.x*H_V_S().x)-midV + Perspective * pix.x,((texcoord.y*2)*H_V_S().y)-midH)) : tex2D(SamplerCRCLAMP,float2((texcoord.x*H_V_S().x)-midV - Perspective * pix.x,((texcoord.y*2-1)*H_V_S().y)-midH));	
			}
		}
		else if(Stereoscopic_Mode == 2)
		{
			float gridL = frac(texcoord.y*(BUFFER_HEIGHT/2));
			if(Custom_Sidebars == 0)
			{
			color = gridL > 0.5 ? tex2D(SamplerCLMIRROR,float2(((texcoord.x)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRMIRROR,float2(((texcoord.x)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
			else if(Custom_Sidebars == 1)
			{
			color = gridL > 0.5 ? tex2D(SamplerCLBORDER,float2(((texcoord.x)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRBORDER,float2(((texcoord.x)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
			else
			{
			color = gridL > 0.5 ? tex2D(SamplerCLCLAMP,float2(((texcoord.x)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRCLAMP,float2(((texcoord.x)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
		}
		else
		{
			float gridy = floor(texcoord.y*(BUFFER_HEIGHT));
			float gridx = floor(texcoord.x*(BUFFER_WIDTH));
			if(Custom_Sidebars == 0)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(SamplerCLMIRROR,float2(((texcoord.x)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRMIRROR,float2(((texcoord.x)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
			else if(Custom_Sidebars == 1)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(SamplerCLBORDER,float2(((texcoord.x)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRBORDER,float2(((texcoord.x)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
			else
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(SamplerCLCLAMP,float2(((texcoord.x)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : tex2D(SamplerCRCLAMP,float2(((texcoord.x)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
			}
		}
	}
	else
	{
	color = texcoord.x < 0.5 ? PDL(float2(((texcoord.x*2)*H_V_S().x)-midV + Perspective * pix.x,(texcoord.y*H_V_S().y)-midH)) : PDR(float2(((texcoord.x*2-1)*H_V_S().x)-midV - Perspective * pix.x,(texcoord.y*H_V_S().y)-midH));
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

technique SidebySide_To_Else
{			
			pass MousePass
		{
			VertexShader = PostProcessVS;
			PixelShader = MouseCuror;
		}
			pass SinglePassStereo
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_renderLR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;
		}
			pass SidebySideToElse
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;	
		}
}
