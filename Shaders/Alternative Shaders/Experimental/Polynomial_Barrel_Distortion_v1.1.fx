 ////------------------------------------------//
 ///**Polynomial Barrel Distortion for HMDs**///
 //-----------------------------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Barrel Distortion for HMD type Displays For SuperDepth3D v1.1																													*//
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
 //* Also thank you Zapal for your help with fixing a few things in this shader. 																									*//
 //* https://reshade.me/forum/shader-presentation/2128-3d-depth-map-based-stereoscopic-shader?start=900#21236																		*//
 //* 																																												*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform int Interpupillary_Distance <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Interpupillary Distance";
	ui_tooltip = "Determines the distance between your eyes.\n" 
				 "In Monoscopic mode it's x offset calibration.\n"
				 "Default is 0.";
> = 0;

uniform int Stereoscopic_Mode_Convert <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0SbS to Alt-TnB\0TnB to Alt-TnB\0Monoscopic\0";
	ui_label = "3D Display Mode Conversion";
	ui_tooltip = "3D display output conversion for SbS and TnB.";
> = 0;

uniform float Lens_Center <
	ui_type = "drag";
	ui_min = 0.475; ui_max = 0.575;
	ui_label = "Lens Center";
	ui_tooltip = "Adjust Lens Center. Default is 0.5";
> = 0.5;

uniform float Lens_Distortion <
	ui_type = "drag";
	ui_min = -0.325; ui_max = 5;
	ui_label = "Lens Distortion";
	ui_tooltip = "Lens distortion value, positive values of k2 gives barrel distortion, negative give pincushion.\n"
				 "Default is 0.01";
> = 0.01;

uniform float3 Polynomial_Colors <
	ui_type = "drag";
	ui_min = 0.250; ui_max = 2.0;
	ui_tooltip = "Adjust the Polynomial Distortion Red, Green, Blue.\n"
				 "Default is (R 1.0, G 1.0, B 1.0)";
	ui_label = "Polynomial Color Distortion";
> = float3(1.0, 1.0, 1.0);

uniform float2 Zoom_Aspect_Ratio <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2;
	ui_label = "Lens Zoom & Aspect Ratio";
	ui_tooltip = "Lens Zoom amd Aspect Ratio.\n" 
				 "Default is 1.0.";
> = float2(1.0,1.0);

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Select how you like the Edge of the screen to look like.";
> = 1;

uniform bool Diaspora <
	ui_label = "Diaspora Fix";
	ui_tooltip = "A small fix for the game Diaspora.";
> = false;

//////////////////////////////////////////////////HMD Profiles//////////////////////////////////////////////////////////////////

uniform int HMD_Profiles <
	ui_type = "combo";
	ui_items = "Off\0Profile One\0Profile Two\0"; //Add your own Profile here.
	ui_label = "HMD Profiles";
	ui_tooltip = "Head Mounted Display Profiles.";
> = 0;

float4x4 HMDProfiles()
{
float Zoom = Zoom_Aspect_Ratio.x;
float Aspect_Ratio = Zoom_Aspect_Ratio.y;

float IPD = Interpupillary_Distance;
float LC = Lens_Center;
float LD = Lens_Distortion;
float Z = Zoom;
float AR = Aspect_Ratio;
float3 PC = Polynomial_Colors;
float4x4 Done;

	//Make your own Profile here.
	if (HMD_Profiles == 1)
	{
		IPD = 0.0;					//Interpupillary Distance. Default is 0
		LC = 0.5; 					//Lens Center. Default is 0.5
		LD = 0.01;					//Lens Distortion. Default is 0.01
		Z = 1.0;					//Zoom. Default is 1.0
		AR = 1.0;					//Aspect Ratio. Default is 1.0
		PC = float3(1,1,1);			//Polynomial Colors. Default is (Red 1.0, Green 1.0, Blue 1.0)
	}
	
	//Make your own Profile here.
	if (HMD_Profiles == 2)
	{
		IPD = -25.0;				//Interpupillary Distance.
		LC = 0.5; 					//Lens Center. Default is 0.5
		LD = 0.250;					//Lens Distortion. Default is 0.01
		Z = 1.0;					//Zoom. Default is 1.0
		AR = 0.925;					//Aspect Ratio. Default is 1.0
		PC = float3(0.5,0.75,1);	//Polynomial Colors. Default is (Red 1.0, Green 1.0, Blue 1.0)
	}

if(Diaspora)
{
Done = float4x4(float4(IPD,PC.x,Z,0),float4(LC,PC.y,AR,0),float4(LD,PC.z,0,0),float4(0,0,0,0)); //Diaspora frak up 4x4 fix
}
else
{
Done = float4x4(float4(IPD,LC,LD,0),float4(PC.x,PC.y,PC.z,0),float4(Z,AR,0,0),float4(0,0,0,0));
}
return Done;
}

////////////////////////////////////////////////HMD Profiles End/////////////////////////////////////////////////////////////////

//Interpupillary Distance Section//
float IPDS()
{
	float IPDS = HMDProfiles()[0][0];
	return IPDS;
}

//Lens Center Section//
float LCS()
{
	float LCS = HMDProfiles()[0][1];
	return LCS;
}

//Lens Distortion Section//
float LD_k2()
{
	float LD = HMDProfiles()[0][2];
	return LD;
}

//Lens Zoom & Aspect Ratio Section//
float2 Z_A()
{
	float2 ZA = float2(HMDProfiles()[2][0],HMDProfiles()[2][1]);
	return ZA;
}

//Polynomial Colors Section//
float3 P_C()
{
	float3 PC = float3(HMDProfiles()[1][0],HMDProfiles()[1][1],HMDProfiles()[1][2]);
	return PC;
}

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
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
	
////////////////////////////////////////////////////Polynomial_Distortion/////////////////////////////////////////////////////
void LR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 , out float4 colorT: SV_Target1)
{	
float4 SBSL, SBSR;
	if(Stereoscopic_Mode_Convert == 0 || Stereoscopic_Mode_Convert == 2) //SbS
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x*0.5,texcoord.y));
	SBSR = tex2D(BackBuffer, float2(texcoord.x*0.5+0.5,texcoord.y));
	}
	else if(Stereoscopic_Mode_Convert == 1 || Stereoscopic_Mode_Convert == 3) //TnB
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5));
	SBSR = tex2D(BackBuffer, float2(texcoord.x,texcoord.y*0.5+0.5));
	}
	else
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y)); //Monoscopic No stereo
	}
	
color = SBSL;
colorT = SBSR;
}

float2 DL(float2 p, float k_RGB) //Cubic Lens Distortion Left
{
	float LC = 1-LCS();
	float LD_k1 = 0.01; //Lens distortion value, positive values of k1 give barrel distortion, negative give pincushion.
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * LD_k1 * k_RGB + (LD_k2() * k_RGB * r2 * r2);

	 p.x = newRadius * (p.x-0.5)+0.5;
	 p.y = newRadius * (p.y-0.5)+0.5;
	
	return p;
}

float2 DR(float2 p, float k_RGB) //Cubic Lens Distortion Right
{
	float LC = LCS();
	float LD_k1 = 0.01; //Lens distortion value, positive values of k1 give barrel distortion, negative give pincushion.
	float r2 = (p.x-LC) * (p.x-LC) + (p.y-0.5) * (p.y-0.5);       
	
	float newRadius = 1 + r2 * LD_k1 * k_RGB + (LD_k2() * k_RGB * r2 * r2);

	 p.x = newRadius  * (p.x-0.5)+0.5;
	 p.y = newRadius  * (p.y-0.5)+0.5;
	
	return p;
}

float4 PDL(float2 texcoord)		//Texture = texCL Left

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = 1 / P_C().x;
		Green = 1/ P_C().y;
		Blue = 1/ P_C().z;
		
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
	
	float4 PDR(float2 texcoord)		//Texture = texCR Right

{		
		float4 color;
		float2 uv_red, uv_green, uv_blue;
		float4 color_red, color_green, color_blue;
		float Red, Green, Blue;
		float2 sectorOrigin;

    // Radial distort around center
		sectorOrigin = (texcoord.xy-0.5,0,0); //sectorOrigin = (texcoord.xy-0.5,0,0);
		
		Red = 1 / P_C().x;
		Green = 1 / P_C().y;
		Blue = 1 / P_C().z;
		
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
float4 PBDOut(float2 texcoord : TEXCOORD0)
{	
	float4 Out;
	
	float X = Z_A().x;
	float Y = Z_A().y * Z_A().x * 2;
	
	float posH = Y - 1;
	float midH = posH*BUFFER_HEIGHT/2*pix.y;
		
	float posV = X - 1;
	float midV = posV*BUFFER_WIDTH/2*pix.x;
	
	if( Stereoscopic_Mode_Convert == 0 || Stereoscopic_Mode_Convert == 1)
	{
	Out = texcoord.x < 0.5 ? PDL(float2(((texcoord.x*2)*X)-midV + IPDS() * pix.x,(texcoord.y*Y)-midH)) : PDR(float2(((texcoord.x*2-1)*X)-midV - IPDS() * pix.x,(texcoord.y*Y)-midH));
	}
	else if (Stereoscopic_Mode_Convert == 2 || Stereoscopic_Mode_Convert == 3)
	{
	Out = texcoord.y < 0.5 ? PDL(float2((texcoord.x*X)-midV + IPDS() * pix.x,((texcoord.y*2)*Y)-midH)) : PDR(float2((texcoord.x*X)-midV - IPDS() * pix.x,((texcoord.y*2-1)*Y)-midH));
	}
	else
	{
	Out = PDL(float2((texcoord.x*X)-midV + IPDS() * pix.x,(texcoord.y*Y)-midH));
	}
	return Out;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	//#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	float HEIGHT = BUFFER_HEIGHT/2,WIDTH = BUFFER_WIDTH/2;	
	float2 LCD,LCE,LCP,LCT,LCH,LCThree,LCDD,LCDot,LCI,LCN,LCF,LCO;
	float size = 9.5,set = BUFFER_HEIGHT/2,offset = (set/size),Shift = 50;
	float4 Color = PBDOut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;

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

technique Polynomial_Barrel_Distortion
{			
			pass StereoMonoPass
		{
			VertexShader = PostProcessVS;
			PixelShader = LR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;
		}
			pass SidebySidePolynomialBarrelDistortion
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}