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
 //* Original work was based on the shader code from																																*//
 //* CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology																				*//
 //* Also Fu-Bama a shader dev at the reshade forums https://reshade.me/forum/shader-presentation/5104-vr-universal-shader															*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The resolution of the Depth Map. For 4k Use 1.75 or 1.5. For 1440p Use 1.5 or 1.25. For 1080p use 1. Too low of a resolution will remove too much.
#define Depth_Map_Division 1.0

//Divergence & Convergence//
uniform float Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = 100; ui_step = 0.5;
	ui_label = "·Divergence Slider·";
	ui_tooltip = "Divergence increases differences between the left and right retinal images and allows you to experience depth.\n" 
				 "The process of deriving binocular depth information is called stereopsis.\n"
				 "You can override this value.";
	ui_category = "Divergence & Convergence";
> = 35.0;

uniform int Convergence_Mode <
	ui_type = "combo";
	ui_items = "ZPD Tied\0ZPD Locked\0";
	ui_label = " Convergence Mode";
	ui_tooltip = "Select your Convergence Mode for ZPD calculations.\n" 
				 "ZPD Locked mode is locked to divergence & dissables ZPD control below.\n" 
				 "ZPD Tied is controlled by ZPD. Works in tandam with Divergence.\n" 
				 "For FPS with no custom weapon profile use Tied.\n" 
				 "Default is ZPD Tied.";
	ui_category = "Divergence & Convergence";
> = 0;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.250;
	ui_label = " Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect also known as Convergence.\n"
				"For FPS Games keeps this low Since you don't want your gun to pop out of screen.\n"
				"This is controled by Convergence Mode.\n"
				"Default is 0.010, Zero is off.";
	ui_category = "Divergence & Convergence";
> = 0.010;

uniform float ZPD_Balance <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " ZPD Balance";
	ui_tooltip = "Zero Parallax Distance balances between ZPD Depth and Scene Depth.\n"
				"Default is Zero is full Convergence and One is Full Depth.";
	ui_category = "Divergence & Convergence";
> = 0.5;

//Occlusion Masking//
uniform int Disocclusion <
	ui_type = "drag";
	ui_min = 16; ui_max = 128;
	ui_label = "·Occlusion Quality·";
	ui_tooltip = "Occlusion masking power & Mask Based culling adjustments.\n"
				 "Affects Gap/Hole Filling quality.\n"
				 "Default is 32.";
	ui_category = "Occlusion Masking";
> = 32;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = " Edge Handling";
	ui_tooltip = "Edges selection for your screen output.";
	ui_category = "Occlusion Masking";
> = 1;

//Depth Map//
uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DM0 Normal\0DM1 Reversed\0";
	ui_label = "·Depth Map Selection·";
	ui_tooltip = "Linearization for the zBuffer also known as Depth Map.\n"
			     "DM0 is Z-Normal and DM1 is Z-Reversed.\n";
	ui_category = "Depth Map";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.0; ui_step = 0.125;
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "This allows for you to adjust the DM precision.\n"
				 "Adjust this to keep it as low as possible.\n"
				 "Default is 7.5";
	ui_category = "Depth Map";
> = 7.5;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Depth Map Offset";
	ui_tooltip = "Depth Map Offset is for non conforming ZBuffer.\n"
				 "It,s rare if you need to use this in any game.\n"
				 "Use this to make adjustments to DM 0 or DM 1.\n"
				 "Default and starts at Zero and it's Off.";
	ui_category = "Depth Map";
> = 0.0;

uniform bool Depth_Map_View <
	ui_label = " Depth Map View";
	ui_tooltip = "Display the Depth Map.";
	ui_category = "Depth Map";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = " Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Map";
> = false;

uniform int Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = " Perspective Slider";
	ui_tooltip = "Determines the perspective point of the two images this shader produces.\n"
				 "For an HMD, use Polynomial Barrel Distortion shader to adjust for IPD.\n" 
				 "Do not use this perspective adjustment slider to adjust for IPD.\n"
				 "Default is Zero.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform float Wobble_Speed <
	ui_type = "drag";
	ui_min = -1; ui_max = 1;
	ui_label = " Wobble Speed";
	ui_category = "Stereoscopic Options";
> = 0.0;

uniform int Wobble_Mode <
	ui_type = "combo";
	ui_items = "Wobble Mode X Rotation\0Wobble Mode X Heartbeat\0Wobble Mode X L/R\0Wobble Mode X Lerp\0Wobble Mode X Full\0";
	ui_label = "Wobble Transition Effect";
	ui_tooltip = "Change the Transition of the Wobble 3D Effect.";
	ui_category = "Stereoscopic Options";
> = 4;

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

//Depth Map Information	
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

float Depth(in float2 texcoord : TEXCOORD0)
{	
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBuffer = tex2Dlod(DepthBuffer, float4(texcoord,0,0)).x; //Depth Buffer
	
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1.0, Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
	
	float2 Offsets = float2(1 + Offset,1 - Offset), Z = float2( zBuffer, 1-zBuffer );
	
	if (Offset > 0)
	Z = min( 1, float2( Z.x*Offsets.x , Z.y /  Offsets.y  ));
		
	if (Depth_Map == 0)//DM0. Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = Far * Near / (Far + Z.y * (Near - Far));
		
	return zBuffer;
}
uniform float timer < source = "timer"; >;
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
float Conv(float D,float2 texcoord)
{
	float Z = ZPD, ZP = saturate(ZPD_Balance);	
				
		float Convergence = 1 - Z / D;

		if (ZPD == 0)
			ZP = 1.0;
		
    return lerp(Convergence,D, ZP);
}

float Encode(in float2 texcoord : TEXCOORD0)
{
	return Conv(Depth(texcoord),texcoord); //Convergence is done here.
}

// Horizontal parallax offset & Hole filling effect
float2 Parallax( float Dive, float2 Coordinates) //WIP
{
	//ParallaxSteps
	int Steps = Disocclusion;
	
	// Offset per step progress & Limit
	float LayerDepth = 1.0 / clamp(Steps,32,255);
	
	//Offsets listed here Max Seperation is 3% - 6% of screen space with Depth Offsets & Netto layer offset change based on MS.
	float MS = Dive * pix.x, P = (100 - (Perspective * 2)) * 0.01f, deltaCoordinates = MS * LayerDepth, Offsets = Dive * 0.1f, M;
	float2 ParallaxCoord = Coordinates, DB_Offset = float2((Dive * 0.0375f) * pix.x, 0);
	float CurrentDepthMapValue = Encode(ParallaxCoord), CurrentLayerDepth, DepthDifference;
	
	if (Wobble_Mode == 4)
	ParallaxCoord.x += (MS * 0.5f) * P;
	
	// Steep parallax mapping
	[loop]
	while(CurrentLayerDepth < CurrentDepthMapValue)
	{
		// Shift coordinates horizontally in linear fasion
		ParallaxCoord.x -= deltaCoordinates;
		// Get depth value at current coordinates
		CurrentDepthMapValue = Encode(ParallaxCoord - DB_Offset); // Offset
		// Get depth of next layer
		CurrentLayerDepth += LayerDepth;
	}

	// Parallax Occlusion Mapping
	float2 PrevParallaxCoord = float2(ParallaxCoord.x + deltaCoordinates, ParallaxCoord.y);
	float afterDepthValue = CurrentDepthMapValue - CurrentLayerDepth;
	float beforeDepthValue = Encode(PrevParallaxCoord - DB_Offset) - CurrentLayerDepth + LayerDepth;
	
	// Interpolate coordinates
	float weight = afterDepthValue / (afterDepthValue - beforeDepthValue);
	ParallaxCoord = PrevParallaxCoord * max(0,weight) + ParallaxCoord * min(1,1.0f - weight);

	// Apply gap masking (by JMF) Don't know who this Is to credit him.... :(
	DepthDifference = distance(afterDepthValue,afterDepthValue) * MS;
	DepthDifference += beforeDepthValue * Offsets * pix.x;
	ParallaxCoord.x += DepthDifference;

	return ParallaxCoord;
};

float Repeat(float t, float L)
{
	return clamp(t - floor(t / L) * L, 0.0f, L);
}

float PingPong(float t, float L)
{
	t = Repeat(t, L * 2f);
	return L - abs(t - L);
}

float4 WobbleLRC(in float2 texcoord : TEXCOORD0)
{	
	float2 TCL = texcoord, TCR = texcoord, TCC = texcoord;
	float4 color, Left, Right, Center;
	float w = PingPong(timer/((1-Wobble_Speed)*1000),1), DW = w;
	float MS = Divergence * pix.x, P = Perspective * pix.x;
	
	TCL.x -= MS * 0.5f;
	TCR.x += MS * 0.5f;
	
	TCL.x -= P * 0.5f;
	TCR.x += P * 0.5f;
	
	DW -= 0.5;
	DW *= Divergence;
	DW *= 2;
		
	//Left & Right Parallax for Stereo Vision
	if (Wobble_Mode <= 3)
	{
		TCL = Parallax(-Divergence, TCL); //Stereoscopic 3D using Reprojection Left					
		TCR = Parallax( Divergence, TCR); //Stereoscopic 3D using Reprojection Right	
	}
	else
	{
		TCC = Parallax( DW, TCC);
	}
	
	if(Custom_Sidebars == 0)
	{
		Left = tex2D(BackBufferMIRROR,TCL);
		Right = tex2D(BackBufferMIRROR,TCR);
		Center = tex2D(BackBufferMIRROR,TCC);
	}
	else if(Custom_Sidebars == 1)
	{
		Left = tex2D(BackBufferBORDER,TCL);
		Right = tex2D(BackBufferBORDER,TCR);
		Center = tex2D(BackBufferBORDER,TCC);
	}
	else
	{
		Left = tex2D(BackBufferCLAMP,TCL.x);
		Right = tex2D(BackBufferCLAMP,TCR.x);
		Center = tex2D(BackBufferCLAMP,TCC);
	}	
	

if(!Depth_Map_View)
	{
		if (Wobble_Mode == 0)
			{
				if (w < 0.25)
					color = Left;
				else if(w > 0.75)
					color = Right;
				else
					color = tex2D(BackBuffer, texcoord);
			}
			else if(Wobble_Mode == 1)
			{
				if (texcoord.x < w)
					color = Left;
				else if (texcoord.x > w)
					color = Right;	
				else
					color = tex2D(BackBuffer, texcoord);
			}
			else if(Wobble_Mode == 2)
			{
				if (w < 0.50)
					color = Left;
				else if (w > 0.50)
					color = Right;
				else
					color = tex2D(BackBuffer, texcoord);
			}
			else if(Wobble_Mode == 3)
			{
				color = lerp(Right,Left, w);
			}
			else
			{
				color = Center;
			}
			
	}
	else
	{
		color =  Encode(texcoord);
	}
	return color;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
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
			pass SinglePassStereo
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}	

}
