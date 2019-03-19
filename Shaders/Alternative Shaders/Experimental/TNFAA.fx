 ////-----------------//
 ///**Temporal NFAA**///
 //-----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Temporal Normal Filter Anti Aliasing.                      																										            *//
 //* For Reshade 3.0+																																					    		*//
 //* --------------------------																																						*//
 //* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																								*//
 //* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																				*//
 //* I would also love to hear about a project you are using it with.																												*//
 //* https://creativecommons.org/licenses/by/3.0/us/																																*//
 //*																																												*//
 //* Have fun,																																										*//
 //* Jose Negrete AKA BlueSkyDefender																																				*//
 //* Based on port by b34r                       																																	*//
 //* https://www.gamedev.net/forums/topic/580517-nfaa---a-post-process-anti-aliasing-filter-results-implementation-details/?page=2													*//	
 //* ---------------------------------																																				*//
 //*                                                                            																									*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform float filterSpread_var <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2.0;
	ui_label = "Spread";
	ui_tooltip = "Filter Spread controls how large an area the filter tries to sample\n"
				 "and fix aliasing within. This has a direct relationship to the angle\n"
				 "of lines the filter can smooth well. A 45 degree line will be perfectly\n"
				 "alised with a spread of 1.0, steeper lines will need higher\n"
				 "values. The tradeoff for setting a high spread value is the overall\n"
				 "Softness/Ghosting of the image. Values between 0.5f and 2.0f work best.\n"
				 "Default is 1.0f.";
> = 1.0;

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "Temporal-NFAA\0Mask View A\0Mask View B\0Non-Masked View\0";
	ui_label = "View Mode";
	ui_tooltip = "This is used to select the Temporal views output or debug views.\n"
				 "Non-Masked View is only good for semi-static scenes.\n"
				 "Default is Temporal-NFAA.";
> = 0;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define ws 0.5
#define Jitter_Ammount 0.5 //Adjust Randomized Halton base(2,3) Jitter and Dejitter filter. This should be subpix 0.5-0.75
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture CurrentBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler CBackBuffer
	{
		Texture = CurrentBackBuffer;
	};
	
texture PastBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PBackBuffer
	{
		Texture = PastBackBuffer;
	};

texture PastSingleBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PSBackBuffer
	{
		Texture = PastSingleBackBuffer;
	};
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float4 GetBB(float2 texcoord : TEXCOORD)
{
	return tex2D(BackBuffer, texcoord);
}
//Randomized Halton
uniform int random < source = "random"; min = 0; max = 256; >;

float Halton(float i, float base)
{
  float x = 1.0f / base;
  float v = 0.0f;
  while (i > 0)
  {
    v += x * (i % base);
    i = floor(i / base);
    x /= base;
  }
  return v;
}

float4 T_Out(float2 texcoord : TEXCOORD)
{		
	float Persistence = 0.95f;
    float4 C = GetBB(texcoord);
    
    C.rgb = tex2Dlod(PBackBuffer, float4(texcoord,0,0)).rgb;
    
    C.rgb = C.rgb * Persistence;
    
    C.rgb = max( tex2D(CBackBuffer, texcoord).rgb, C.rgb);
    
    return C;
}
	
float4 NFAA(float2 texcoord : TEXCOORD)
{	
	float3 NFAA;
    float2 UV = texcoord.xy, S = ws, SW = S * pix, n;
			
	float3 ct = GetBB( float2( UV.x , UV.y - SW.y ) ).rgb,
		   cl = GetBB( float2( UV.x - SW.x , UV.y ) ).rgb,
		   cr = GetBB( float2( UV.x + SW.x , UV.y ) ).rgb,
		   cd = GetBB( float2( UV.x , UV.y + SW.y ) ).rgb;
		   n = float2(length(ct - cd),length(cr - cl));
		
    float   nl = length(n) * filterSpread_var;
 
    if (nl < (1.0 / 16))
    {
		NFAA = GetBB(UV).rgb;
	}
    else
    {
	n *= pix / nl;
 
	float3   o = GetBB( UV ).rgb,
			t0 = GetBB( UV + n * 0.5).rgb * 0.9,
			t1 = GetBB( UV - n * 0.5).rgb * 0.9,
			t2 = GetBB( UV + n).rgb * 0.75,
			t3 = GetBB( UV - n).rgb * 0.75;
 
		NFAA = (o + t0 + t1 + t2 + t3) / 4.3;
	}

return float4(NFAA,nl);
}

void Current_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{

	float2 XY = float2(random,random);
	//Randomized Halton base(2,3)
	XY = float2(Halton(XY.x, 2),Halton(XY.y, 3));
	XY = XY * Jitter_Ammount;//subpix jitter
	
	float2 W = XY * pix;
	float3 ct, cl, cr, cd;	
	ct = NFAA( float2( texcoord.x , texcoord.y - W.y ) ).rgb;
	cl = NFAA( float2( texcoord.x - W.x , texcoord.y ) ).rgb;
	cr = NFAA( float2( texcoord.x + W.x , texcoord.y ) ).rgb;
	cd = NFAA( float2( texcoord.x , texcoord.y + W.y ) ).rgb;
	color = float4((ct + cd + cr + cl) / 4, 1 );
}

void Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target0, out float4 Past : SV_Target1)
{
	PastSingle = tex2D(CBackBuffer,texcoord);
	Past = tex2D(BackBuffer,texcoord);
}

float4 TNFAA(float2 texcoord : TEXCOORD)
{
	float Mask = NFAA(texcoord).w, filterStrength_var = 2.5f;
	
	if (Mask > 0.05)
	Mask = 1-Mask;
	else
	Mask = 1;
	
	Mask = saturate(lerp(Mask,1,-filterStrength_var));
    float2 UV = texcoord.xy, SW = Jitter_Ammount * pix, n;
			
	float3  ct = T_Out( float2( UV.x , UV.y - SW.y ) ).rgb,
			cl = T_Out( float2( UV.x - SW.x , UV.y ) ).rgb,
			cr = T_Out( float2( UV.x + SW.x , UV.y ) ).rgb,
			cd = T_Out( float2( UV.x , UV.y + SW.y ) ).rgb;
	float4 NFAA = float4((ct + cd + cr + cl) / 4, Mask);	
	
	// Final color
	if(View_Mode == 0)
	{
		NFAA = lerp(NFAA,GetBB( texcoord.xy ), Mask );
	}
	else if(View_Mode == 1)
	{
		NFAA = lerp(float4(1,0,0,1),GetBB( texcoord.xy ), Mask );
	}
	else if (View_Mode == 2)
	{
		NFAA = Mask.xxxx;
	}
	else if (View_Mode == 3)
	{
		NFAA = NFAA;
	}

	return NFAA;	
}
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = TNFAA(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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
technique Temporal_Normal_Filter_Anti_Aliasing
{
			pass CBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Current_BackBuffer;
			RenderTarget = CurrentBackBuffer;
		}
			pass NFAA
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
			pass PBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BackBuffer;
			RenderTarget0 = PastSingleBackBuffer;
			RenderTarget1 = PastBackBuffer;
			
		}
}
