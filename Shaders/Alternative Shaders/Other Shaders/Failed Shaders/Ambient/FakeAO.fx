 ////----------//
 ///**FakeAO**///
 //----------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Fake Ambient Occlusion is an Image Enhancement by Unsharp Masking the Depth Buffer.       																						*//
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
 //*            																																									*//
 //* Image Enhancement by Unsharp Masking the Depth Buffer            																												*//
 //* https://www.uni-konstanz.de/mmsp/pubsys/publishedFiles/LuCoDe06.pdf           																									*//
 //* https://dl.acm.org/citation.cfm?id=1142016           																															*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform float Spread <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.00;
	ui_label = "Shade Fill";
	ui_tooltip = "Adjust This to have the shade effect to fill in areas.\n"
				 "This is used for gap filling. AKA, Fake AO.\n"
				 "Number 25 is default.";
> = 25.0;

uniform float Power <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 12.50;
	ui_label = "Fake AO Power";
	ui_tooltip = "Adjust the Shade Power.\n"
				 "Number 6.25 is default.";
> = 6.25;

uniform float Dither_Bit <
	ui_type = "drag";
	ui_min = 1; ui_max = 15;
	ui_label = "Dither Bit";
	ui_tooltip = "Dither is an intentionally applied form of noise used to randomize quantization error, preventing banding in images.";
> = 6;

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Normal\0Reversed\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 0.25; ui_max = 250.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map and sharpness.";
> = 5.0;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset is for the Special Depth Map Only";
> = 0.0;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform float2 Image_Position_Adjust<
	ui_type = "drag";
	ui_min = -4096.0; ui_max = 4096.0;
	ui_label = "Image Position Adjust";
	ui_tooltip = "Adjust the Image Postion if it's off by a bit. Default is Zero.";
> = float2(0.0,0.0);
	
uniform float2 Horizontal_Vertical_Resize <
	ui_type = "drag";
	ui_min = 0.125; ui_max = 2;
	ui_label = "Horizontal & Vertical";
	ui_tooltip = "Adjust Horizontal and Vertical Resize. Default is 1.0.";
> = float2(1.0,1.0);

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
> = false;


/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
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
	
texture texGuss { Width = BUFFER_WIDTH*0.5; Height = BUFFER_HEIGHT*0.5; Format = RGBA8; MipLevels = 8;};

sampler SamplerBlur
	{
		Texture = texGuss;
		MipLODBias = 2.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
uniform float frametime < source = "frametime"; >;
float zBuffer(in float2 texcoord : TEXCOORD0)    
{
		float2 texXY = texcoord + Image_Position_Adjust * pix;		
		float2 midHV = (Horizontal_Vertical_Resize-1) * float2(BUFFER_WIDTH * 0.5,BUFFER_HEIGHT * 0.5) * pix;			
		texcoord = float2((texXY.x*Horizontal_Vertical_Resize.x)-midHV.x,(texXY.y*Horizontal_Vertical_Resize.y)-midHV.y);	
		
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float DM, zBuffer = tex2D(DepthBuffer, texcoord).x; //Depth Buffer
			
		//Conversions to linear space.....
		//Near & Far Adjustment
		float Far = 1.0, Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		
		float2 Offsets = float2(1 + Offset,1 - Offset), Z = float2( zBuffer, 1-zBuffer );
		
		if (Offset > 0)
		Z = min( 1, float2( Z.x*Offsets.x , ( Z.y - 0.0 ) / ( Offsets.y - 0.0 ) ) );
			
		if (Depth_Map == 0)//DM0. Normal
		{
			DM = 2.0 * Near * Far / (Far + Near - (2.0 * Z.x - 1.0) * (Far - Near));
		}		
		else if (Depth_Map == 1)//DM1. Reverse
		{
			DM = 2.0 * Near * Far / (Far + Near - (1.375 * Z.y - 0.375) * (Far - Near));
		}
	
	// Dither for DepthBuffer adapted from gedosato ramdom dither https://github.com/PeterTh/gedosato/blob/master/pack/assets/dx9/deband.fx
	// I noticed in some games the depth buffer started to have banding so this is used to remove that.
				
	float DB  = Dither_Bit;
	float noise = frac(sin(dot(texcoord * frametime, float2(12.9898, 78.233))) * 43758.5453);
	float dither_shift = (1.0 / (pow(2,DB) - 1.0));
	float dither_shift_half = (dither_shift * 0.5);
	dither_shift = dither_shift * noise - dither_shift_half;
	DM += -dither_shift;
	DM += dither_shift;
	DM += -dither_shift;
	
	// Dither End
		
	return saturate(DM);	
}

void Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target)                                                                          
{
	float4 CC = zBuffer(texcoord);

	const float samples[7] = {0.0f,0.020f,-0.020f,0.030f,-0.030f,0.05f,-0.05f};

    float factor = zBuffer(texcoord), aperture = 10000, maxBlur = Spread;

    float2 dofblur = float2 ( clamp( factor * aperture, -maxBlur, maxBlur ),clamp( factor * aperture, -maxBlur, maxBlur ) ) * pix;
    
	float X, Y;
		[unroll]
		for (int i = 0; i < 7; i++)
		{  
			X = dofblur.x * samples[i] * 2;
			Y = dofblur.y * samples[i] * 2;
			CC += lerp(zBuffer(float2(texcoord.x + X,texcoord.y)),zBuffer(float2(texcoord.x ,texcoord.y + Y)),0.5);
			CC += lerp(zBuffer(float2(texcoord.x - X ,texcoord.y - Y)),zBuffer(float2(texcoord.x + X ,texcoord.y - Y)),0.5);
		} 
		
		CC /= 14;
		
		color = CC;
}

float FakeAO(float2 texcoord : TEXCOORD0)
{

	float ByteN = 640; //Byte Shift
	float3 RGB, BS = float3(1.0f, 1.0f / ByteN, 1.0f / (ByteN * ByteN)),GS = float3(0.2989f, 0.5870f, 0.1140f);
		
	//Formula for FakeAO = Original * (Original - Blurred) * Amount.
	RGB = dot(zBuffer(texcoord).xxx,BS) - dot(tex2D(SamplerBlur,texcoord).xxx,BS) ;
	
	//Fake AO adjust
	float Combine = dot(RGB,GS * Power);
	
	return saturate(1-Combine);
}

float4 CuesOut(float2 texcoord : TEXCOORD0)
{		
	float4 Out;
	
	float4 Combine = lerp(FakeAO(texcoord).xxxx , 1.0 , zBuffer(texcoord)) * tex2D(BackBuffer, texcoord);
	
	float4 Debug_Done = lerp(FakeAO(texcoord).xxxx , 1.0 , zBuffer(texcoord));
		
	if (!Debug_View)
	{
		Out = Combine;
	}
	else
	{		
		Out = Debug_Done;
	}
	
	return Out;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = CuesOut(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
	if(timer <= 10000)
	{
	//DEPTH
	//D
	float PosXD = -0.035+PosX, offsetD = 0.001;
	float4 OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
	float4 TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
	D = OneD-TwoD;
	
	//E
	float PosXE = -0.028+PosX, offsetE = 0.0005;
	float4 OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
	float4 TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
	float4 ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
	E = (OneE-TwoE)+ThreeE;
	
	//P
	float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
	float4 OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.682));
	float4 TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.682));
	float4 ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
	P = (OneP-TwoP) + ThreeP;

	//T
	float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
	float4 OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
	float4 TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
	T = OneT+TwoT;
	
	//H
	float PosXH = -0.0071+PosX;
	float4 OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
	float4 TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
	float4 ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.003,0.009));
	H = (OneH-TwoH)+ThreeH;
	
	//Three
	float offsetFive = 0.001, PosX3 = -0.001+PosX;
	float4 OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
	float4 TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
	float4 ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
	Three = (OneThree-TwoThree)+ThreeThree;
	
	//DD
	float PosXDD = 0.006+PosX, offsetDD = 0.001;	
	float4 OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
	float4 TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
	DD = OneDD-TwoDD;
	
	//Dot
	float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;		
	float4 OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
	Dot = OneDot;
	
	//INFO
	//I
	float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
	float4 OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
	float4 TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
	float4 ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
	I = OneI+TwoI+ThreeI;
	
	//N
	float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
	float4 OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
	float4 TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
	N = OneN-TwoN;
	
	//F
	float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
	float4 OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
	float4 TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
	float4 ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
	F = (OneF-TwoF)+ThreeF;
	
	//O
	float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
	float4 OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
	float4 TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
	O = OneO-TwoO;
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
technique Fake_AO
{
			pass GussBlurFilter
		{
			VertexShader = PostProcessVS;
			PixelShader = Blur;
			RenderTarget = texGuss;
		}	
			pass FaleAO
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
