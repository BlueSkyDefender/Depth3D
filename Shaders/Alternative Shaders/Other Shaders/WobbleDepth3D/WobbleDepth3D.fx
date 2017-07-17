 ////-----------------//
 ///**WobbleDepth3D**///
 //-----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.6																																	*//
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
 //* I made this :p																																									*//
 //*																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The resolution of the Depth Map. For 4k Use 1.75 or 1.5. For 1440p Use 1.5 or 1.25. For 1080p use 1. Too low of a resolution will remove too much.
#define Depth_Map_Division 1.0

// Determines The Max Depth amount.
#define Depth_Max 35

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Depth Map 0\0Depth Map 1\0Depth Map 2\0Depth Map 3\0Depth Map 4\0Depth Map 5\0Depth Map 6\0Depth Map 7\0Depth Map 8\0Depth Map 9\0Depth Map 10\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 50.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map for your games.";
> = 7.5;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset is for the Special Depth Map Only";
> = 0.5;

uniform int Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = Depth_Max;
	ui_label = "Divergence Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.\n" 
				 "You can override this value.";
> = 15;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.15;
	ui_label = "Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect.";
> = 0.025;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point.\n" 
				 "Default is 0";
> = 0;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map.";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform int Wobble_Speed <
	ui_type = "combo";
	ui_items = "Speed-----\0Speed----\0Speed---\0Speed--\0Speed-\0Normal Speed\0Speed+\0Speed++\0Speed+++\0Speed++++\0Speed+++++\0Off\0";
	ui_label = "Wobble Speed";
	ui_tooltip = "Set the speed of the Wobble 3D Effect.";
> = 5;

uniform int Wobble_Mode <
	ui_type = "combo";
	ui_items = "Wobble Mode X Rotation\0Wobble Mode X Heartbeat\0Wobble Mode X L/R\0Wobble Mode X Lerp\0";
	ui_label = "Wobble Transition Effect";
	ui_tooltip = "Change the Transition of the Wobble 3D Effect.";
> = 0;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Edges selection for your screen output.";
> = 1;

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
	

texture texCDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F;};
	
sampler SamplerCDM
	{
		Texture = texCDM;
	};
	

//Depth Map Information	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

float4 Depth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float DDA = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float DA = Depth_Map_Adjust*2; //Depth Map Adjust - Near
		//All 1.0f are Far Adjustment
		
		//0. DirectX Custom Constant Far
		float DirectX = 2.0 * DDA * 1.0f / (1.0f + DDA - zBuffer * (1.0f - DDA));
		
		//1. DirectX Alternative
		float DirectXAlt = pow(abs(zBuffer - 1.0),DA);
		
		//2. OpenGL
		float OpenGL = 2.0 * DDA * 1.0f / (1.0f + DDA - (2.0 * zBuffer - 1.0) * (1.0f - DDA));
		
		//3. OpenGL Reverse
		float OpenGLRev = 2.0 * 1.0f * DDA / (DDA + 1.0f - (2.0 * zBuffer - 1.0) * (DDA - 1.0f));
		
		//4. Raw Buffer
		float Raw = pow(abs(zBuffer),DA);
		
		//5. Old Depth Map from 1.9.5
		float Old = 100 / (1 + 100 - (zBuffer/DDA) * (1 - 100));
		
		//6. Special Depth Map
		float Special = pow(abs(exp(zBuffer)*Offset),(DA*25));
		
		if (Depth_Map == 0)
		{
		zBuffer = DirectX;
		}
		
		else if (Depth_Map == 1)
		{
		zBuffer = DirectXAlt;
		}

		else if (Depth_Map == 2)
		{
		zBuffer = OpenGL;
		}
		
		else if (Depth_Map == 3)
		{
		zBuffer = OpenGLRev;
		}
		
		else if (Depth_Map == 4)
		{
		zBuffer = lerp(DirectXAlt,OpenGLRev,0.5);
		}
		
		else if (Depth_Map == 5)
		{
		zBuffer = lerp(Raw,DirectX,0.5);
		}

		else if (Depth_Map == 6)
		{
		zBuffer = Raw;
		}
		
		else if (Depth_Map == 7)
		{
		zBuffer = lerp(DirectX,OpenGL,0.5);
		}
		
		else if (Depth_Map == 8)
		{
		zBuffer = lerp(Raw,OpenGL,0.5);
		}		
		
		else if (Depth_Map == 9)
		{
		zBuffer = Old;
		}
		
		else if (Depth_Map == 10)
		{
		zBuffer = Special;
		}
	
	return float4(zBuffer.rrr,1);	
}

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0)
{
		float N,R,G,B,A = 1;
		
		float DM = Depth(texcoord).r;
		
		R = DM;
		G = DM;
		B = DM;
		
	// Dither for DepthBuffer adapted from gedosato ramdom dither https://github.com/PeterTh/gedosato/blob/master/pack/assets/dx9/deband.fx
	// I noticed in some games the depth buffer started to have banding so this is used to remove that.
			
	float dither_bit  = 7.0;
	float noise = frac(sin(dot(texcoord, float2(12.9898, 78.233))) * 43758.5453 * 1);
	float dither_shift = (1.0 / (pow(2,dither_bit) - 1.0));
	float dither_shift_half = (dither_shift * 0.5);
	dither_shift = dither_shift * noise - dither_shift_half;
	R += -dither_shift;
	R += dither_shift;
	R += -dither_shift;
	
	// Dither End	
	
	Color = float4(lerp(R,1,0.05),lerp(R,1,0.05),lerp(R,1,0.05),A);
}


uniform float2 WobbleSpeedZero < source = "pingpong"; min = 0; max = 1; step = 1; >;
uniform float2 WobbleSpeedOne < source = "pingpong"; min = 0; max = 1; step = 2.5; >;
uniform float2 WobbleSpeedTwo < source = "pingpong"; min = 0; max = 1; step = 3.75; >;
uniform float2 WobbleSpeedThree < source = "pingpong"; min = 0; max = 1; step = 5.0; >;
uniform float2 WobbleSpeedFour < source = "pingpong"; min = 0; max = 1; step = 6.25; >;
uniform float2 WobbleSpeedFive < source = "pingpong"; min = 0; max = 1; step = 7.5; >;
uniform float2 WobbleSpeedSix < source = "pingpong"; min = 0; max = 1; step = 10; >;
uniform float2 WobbleSpeedSeven < source = "pingpong"; min = 0; max = 1; step = 15; >;
uniform float2 WobbleSpeedEight < source = "pingpong"; min = 0; max = 1; step = 20; >;
uniform float2 WobbleSpeedNine< source = "pingpong"; min = 0; max = 1; step = 25; >;
uniform float2 WobbleSpeedTen < source = "pingpong"; min = 0; max = 1; step = 30; >;
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
float4 WobbleLRC(in float2 texcoord : TEXCOORD0)
{	
	float samples[5] = {0.50, 0.58, 0.66, 0.83, 1};
	float DepthL = 1.0, DepthR = 1.0;
	float P = Perspective * pix.x, MS = Divergence * pix.x, S, w;
	float4 color;
	
	if(Wobble_Speed == 0)
		{
		w = WobbleSpeedZero.x;
		}
		else if (Wobble_Speed == 1)
		{
		w = WobbleSpeedOne.x;
		}
		else if (Wobble_Speed == 2)
		{
		w = WobbleSpeedTwo.x;
		}
		else if (Wobble_Speed == 3)
		{
		w = WobbleSpeedThree.x;
		}
		else if (Wobble_Speed == 4)
		{
		w = WobbleSpeedFour.x;
		}
		else if (Wobble_Speed == 5)
		{
		w = WobbleSpeedFive.x;
		}
		else if (Wobble_Speed == 6)
		{
		w = WobbleSpeedSix.x;
		}
		else if (Wobble_Speed == 7)
		{
		w = WobbleSpeedSeven.x;
		}
		else if (Wobble_Speed == 8)
		{
		w = WobbleSpeedEight.x;
		}
		else if (Wobble_Speed == 9)
		{
		w = WobbleSpeedNine.x;
		}
		else if (Wobble_Speed == 10)
		{
		w = WobbleSpeedTen.x;
		}
		else
		{
		w = 0.50;
		}
		
	[loop]
	for (int j = 0; j < 5; ++j) 
	{	
		S = samples[j] * MS;
		
		float L = tex2Dlod(SamplerCDM,float4((texcoord.x+P)+S, texcoord.y,0,0)).r;
		float R = tex2Dlod(SamplerCDM,float4((texcoord.x-P)-S, texcoord.y,0,0)).r;
		
		DepthL =  min(DepthL,L);
		DepthR =  min(DepthR,R);
	}
	
	float ParallaxL = max(-0.1,MS * (1-ZPD/DepthL));
	float ParallaxR = max(-0.1,MS * (1-ZPD/DepthR));
	
		ParallaxL = lerp(ParallaxL,DepthL * MS,0.5);
		ParallaxR = lerp(ParallaxR,DepthR * MS,0.5);
		
		float ReprojectionLeft =  ParallaxL;
		float ReprojectionRight = ParallaxR;

if(!Depth_Map_View)
	{
		if (Wobble_Mode == 0)
			{
				if (w < 0.25)
				{
				if(Custom_Sidebars == 0)
					{
					color = tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}
					else if(Custom_Sidebars == 1)
					{
					color = tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}
					else
					{
					color = tex2D(BackBufferCLAMP,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}	
				}
				else if(w > 0.75)
				{
				if(Custom_Sidebars == 0)
					{
					color = tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}
					else if(Custom_Sidebars == 1)
					{
					color = tex2D(BackBufferBORDER,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}
					else
					{
					color = tex2D(BackBufferCLAMP,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}	
				}
				else
				{
				color = tex2D(BackBuffer, texcoord);
				}
			}
			else if(Wobble_Mode == 1)
			{
				if (texcoord.x < w)
				{
				if(Custom_Sidebars == 0)
					{
					color = tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}
					else if(Custom_Sidebars == 1)
					{
					color = tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}
					else
					{
					color = tex2D(BackBufferCLAMP,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}	
				}
				else if (texcoord.x > w)
				{
				if(Custom_Sidebars == 0)
					{
					color = tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}
					else if(Custom_Sidebars == 1)
					{
					color = tex2D(BackBufferBORDER,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}
					else
					{
					color = tex2D(BackBufferCLAMP,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}	
				}
				else
				{
				color = tex2D(BackBuffer, texcoord);
				}
			}
			else if(Wobble_Mode == 2)
			{
				if (w < 0.50)
				{
				if(Custom_Sidebars == 0)
					{
					color = tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}
					else if(Custom_Sidebars == 1)
					{
					color = tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}
					else
					{
					color = tex2D(BackBufferCLAMP,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y));
					}	
				}
				else if (w > 0.50)
				{
				if(Custom_Sidebars == 0)
					{
					color = tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}
					else if(Custom_Sidebars == 1)
					{
					color = tex2D(BackBufferBORDER,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}
					else
					{
					color = tex2D(BackBufferCLAMP,float2((texcoord.x - P) - ReprojectionRight,texcoord.y));
					}	
				}
				else
				{
				color = tex2D(BackBuffer, texcoord);
				}
			}
			else
			{
			if(Custom_Sidebars == 0)
					{
					color = lerp(tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)),tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)), w);
					}
					else if(Custom_Sidebars == 1)
					{
					color = lerp(tex2D(BackBufferBORDER,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)),tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)),w);
					}
					else
					{
					color = lerp(tex2D(BackBufferCLAMP,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)),tex2D(BackBufferCLAMP,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)),w);
					}
			}
			
	}
	else
	{
		color = tex2D(SamplerCDM,texcoord.xy);
	}
	return color;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	//#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	float HEIGHT = BUFFER_HEIGHT/2,WIDTH = BUFFER_WIDTH/2;	
	float2 LCD,LCE,LCP,LCT,LCH,LCThree,LCDD,LCDot,LCI,LCN,LCF,LCO;
	float size = 9.5,set = BUFFER_HEIGHT/2,offset = (set/size),Shift = 50;
	float4 Color = WobbleLRC(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;

	if(timer <= 10000)
	{
	//DEPTH
	//D
	float offsetD = (size*offset)/(set-((size/size)+(size/size)));
	LCD = float2(-90-Shift,0); 
	float4 OneD = all(abs(LCD+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoD = all(abs(LCD+float2(WIDTH*offsetD,HEIGHT)-position.xy) < float2(size,size*1.5));
	D = OneD-TwoD;
	//
	
	//E
	float offs = (size*offset)/(set-(size/size)/2);
	LCE = float2(-62-Shift,0); 
	float4 OneE = all(abs(LCE+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoE = all(abs(LCE+float2(WIDTH*offs,HEIGHT)-position.xy) < float2(size*0.875,size*1.5));
	float4 ThreeE = all(abs(LCE+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	E = (OneE-TwoE)+ThreeE;
	//
	
	//P
	float offsetP = (size*offset)/(set-((size/size)*5));
	float offsP = (size*offset)/(set-(size/size)*-11);
	float offseP = (size*offset)/(set-((size/size)*4.25));
	LCP = float2(-37-Shift,0);
	float4 OneP = all(abs(LCP+float2(WIDTH,HEIGHT/offsetP)-position.xy) < float2(size,size*1.5));
	float4 TwoP = all(abs(LCP+float2((WIDTH)*offsetD,HEIGHT/offsetP)-position.xy) < float2(size,size));
	float4 ThreeP = all(abs(LCP+float2(WIDTH/offseP,HEIGHT/offsP)-position.xy) < float2(size*0.200,size));
	P = (OneP-TwoP)+ThreeP;
	//

	//T
	float offsetT = (size*offset)/(set-((size/size)*16.75));
	float offsetTT = (size*offset)/(set-((size/size)*1.250));
	LCT = float2(-10-Shift,0);
	float4 OneT = all(abs(LCT+float2(WIDTH,HEIGHT*offsetTT)-position.xy) < float2(size/4,size*1.875));
	float4 TwoT = all(abs(LCT+float2(WIDTH,HEIGHT/offsetT)-position.xy) < float2(size,size/4));
	T = OneT+TwoT;
	//
	
	//H
	LCH = float2(13-Shift,0);
	float4 OneH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size/2,size*2));
	float4 ThreeH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	H = (OneH-TwoH)+ThreeH;
	//
	
	//Three
	float offsThree = (size*offset)/(set-(size/size)*1.250);
	LCThree = float2(38-Shift,0);
	float4 OneThree = all(abs(LCThree+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoThree = all(abs(LCThree+float2(WIDTH*offsThree,HEIGHT)-position.xy) < float2(size*1.2,size*1.5));
	float4 ThreeThree = all(abs(LCThree+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	Three = (OneThree-TwoThree)+ThreeThree;
	//
	
	//DD
	float offsetDD = (size*offset)/(set-((size/size)+(size/size)));
	LCDD = float2(65-Shift,0);
	float4 OneDD = all(abs(LCDD+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoDD = all(abs(LCDD+float2(WIDTH*offsetDD,HEIGHT)-position.xy) < float2(size,size*1.5));
	DD = OneDD-TwoDD;
	//
	
	//Dot
	float offsetDot = (size*offset)/(set-((size/size)*16));
	LCDot = float2(85-Shift,0);	
	float4 OneDot = all(abs(LCDot+float2(WIDTH,HEIGHT*offsetDot)-position.xy) < float2(size/3,size/3.3));
	Dot = OneDot;
	//
	
	//INFO
	//I
	float offsetI = (size*offset)/(set-((size/size)*18));
	float offsetII = (size*offset)/(set-((size/size)*8));
	float offsetIII = (size*offset)/(set-((size/size)*5));
	LCI = float2(101-Shift,0);	
	float4 OneI = all(abs(LCI+float2(WIDTH,HEIGHT*offsetI)-position.xy) < float2(size,size/4));
	float4 TwoI = all(abs(LCI+float2(WIDTH,HEIGHT/offsetII)-position.xy) < float2(size,size/4));
	float4 ThreeI = all(abs(LCI+float2(WIDTH,HEIGHT*offsetIII)-position.xy) < float2(size/4,size*1.5));
	I = OneI+TwoI+ThreeI;
	//
	
	//N
	float offsetN = (size*offset)/(set-((size/size)*7));
	float offsetNN = (size*offset)/(set-((size/size)*5));
	LCN = float2(126-Shift,0);	
	float4 OneN = all(abs(LCN+float2(WIDTH,HEIGHT/offsetN)-position.xy) < float2(size,size/4));
	float4 TwoN = all(abs(LCN+float2(WIDTH*offsetNN,HEIGHT*offsetNN)-position.xy) < float2(size/5,size*1.5));
	float4 ThreeN = all(abs(LCN+float2(WIDTH/offsetNN,HEIGHT*offsetNN)-position.xy) < float2(size/5,size*1.5));
	N = OneN+TwoN+ThreeN;
	//
	
	//F
	float offsetF = (size*offset)/(set-((size/size*7)));
	float offsetFF = (size*offset)/(set-((size/size)*5));
	float offsetFFF = (size*offset)/(set-((size/size)*-7.5));
	LCF = float2(153-Shift,0);	
	float4 OneF = all(abs(LCF+float2(WIDTH,HEIGHT/offsetF)-position.xy) < float2(size,size/4));
	float4 TwoF = all(abs(LCF+float2(WIDTH/offsetFF,HEIGHT*offsetFF)-position.xy) < float2(size/5,size*1.5));
	float4 ThreeF = all(abs(LCF+float2(WIDTH,HEIGHT/offsetFFF)-position.xy) < float2(size,size/4));
	F = OneF+TwoF+ThreeF;
	//
	
	//O
	float offsetO = (size*offset)/(set-((size/size*-5)));
	LCO = float2(176-Shift,0);	
	float4 OneO = all(abs(LCO+float2(WIDTH,HEIGHT/offsetO)-position.xy) < float2(size,size*1.5));
	float4 TwoO = all(abs(LCO+float2(WIDTH,HEIGHT/offsetO)-position.xy) < float2(size/1.5,size));
	O = OneO-TwoO;
	//
	}
	
	Website = D+E+P+T+H+Three+DD+Dot+I+N+F+O ? float4(1.0,1.0,1.0,1) : Color;
	
	if(timer >= 10000)
	{
	Done = Color;
	}
	else
	{
	Done = Website;
	}

	return Done;
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

technique WobbleDepth3D
{			
			pass DepthMapPass
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget = texCDM;
		}
			pass SinglePassStereo
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}	

}
