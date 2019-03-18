 ////-------------//
 ///**NFAA Fast**///
 //-------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Normal Filter Anti Aliasing.                                     																										        *//
 //* For Reshade 3.0																																								*//
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

uniform float filterStrength_var <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 1.0;
	ui_label = "Strength";
	ui_tooltip = "Filter Strength Adjusts the overall power of the filter. \n"
				 "Values in the range of 0.5 to 1.0 should provide good results without\n"
				 "blurring the overal image too much. Anything higher will also likely\n"
				 "cause ugly blocky or spikey artifacts.\n"
				 "Default is 0.75f.";
> = 0.75;

uniform float filterSpread_var <
	ui_type = "drag";
	ui_min = 0.875; ui_max = 1.875;
	ui_label = "Spread";
	ui_tooltip = "Filter Spread controls how large an area the filter tries to sample\n"
				 "and fix aliasing within. This has a direct relationship to the angle\n"
				 "of lines the filter can smooth well. A 45 degree line will be perfectly\n"
				 "alised with a spread of 1.0, steeper lines will need higher\n"
				 "values. The tradeoff for setting a high spread value is the overall\n"
				 "softness of the image. Values between 0.875f and 1.875f work best.\n"
				 "Default is 1.0f.";
> = 1.0;

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "NFAA\0Mask View A\0Mask View B\0";
	ui_label = "View Mode";
	ui_tooltip = "This is used to select the normal view output or debug view.\n"
				 "NFAA Masked Needs Stroner Settings where as NFAA Pure needs Weaker settings.\n"
				 "Default is NFAA Masked.";

> = 0;

uniform int Luma_Coefficient <
	ui_type = "combo";
	ui_label = "Luma";
	ui_tooltip = "Changes how color get used for the other effects.\n";
	ui_items = "SD video\0HD video\0HDR video\0Intensity\0Color\0";
> = 3;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define w filterSpread_var
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float3 Luma()
{
	float3 Luma;
	
	if (Luma_Coefficient == 0)
	{
		Luma = float3(0.299, 0.587, 0.114); // (SD video)
	}
	else if (Luma_Coefficient == 1)
	{
		Luma = float3(0.2126, 0.7152, 0.0722); // (HD video) https://en.wikipedia.org/wiki/Luma_(video)
	}
	else if (Luma_Coefficient == 2)
	{
		Luma = float3(0.2627, 0.6780, 0.0593); //(HDR video) https://en.wikipedia.org/wiki/Rec._2100
	}
	else if (Luma_Coefficient == 3)
	{
		Luma = float3(0.333, 0.333, 0.333); //If GGG value of 0.333, 0.333, 0.333 is about right for Green channel. 
	}
	return Luma;
}

//Luminosity Intensity
float LI(in float3 value)
{	
	//Luminosity Controll
	if (Luma_Coefficient == 2)
		value.rgb = value.ggg;
	
	return dot(value.rgb,Luma());
}

float4 GetBB(float2 texcoord : TEXCOORD)
{
	return tex2D(BackBuffer, texcoord);
}

float4 NFAA(float2 texcoord)
{
	float4 NFAA;
    float2 UV = texcoord.xy, S = w;	
	float2 SW = S * pix;
	float t, l, r, d, n;
	float3 ct, cl, cr, cd;
	if (Luma_Coefficient == 4) 
	{ 	
		ct = GetBB( float2( UV.x , UV.y - SW.y ) ).rgb;
		cl = GetBB( float2( UV.x - SW.x , UV.y ) ).rgb;
		cr = GetBB( float2( UV.x + SW.x , UV.y ) ).rgb;
		cd = GetBB( float2( UV.x , UV.y + SW.y ) ).rgb;
		n = float2(length(ct - cd),length(cr - cl));
	}
	else
	{		
		t = LI(GetBB( float2( UV.x , UV.y - SW.y ) ).rgb);
		l = LI(GetBB( float2( UV.x - SW.x , UV.y ) ).rgb);
		r = LI(GetBB( float2( UV.x + SW.x , UV.y ) ).rgb);
		d = LI(GetBB( float2( UV.x , UV.y + SW.y ) ).rgb);
		n = float2(t - d, r - l);
	}	
    float   nl = length(n) * filterStrength_var;
 
    if (nl < (1.0 / 16))
    {
		NFAA = GetBB(UV);
	}
    else
    {
	n *= pix / nl;
 
	float4   o = GetBB( UV ),
			t0 = GetBB( UV + n * 0.5) * 0.9,
			t1 = GetBB( UV - n * 0.5) * 0.9,
			t2 = GetBB( UV + n) * 0.75,
			t3 = GetBB( UV - n) * 0.75;
 
		NFAA = (o + t0 + t1 + t2 + t3) / 4.3;
	}
	
	float Mask = nl;
	
	if (Mask > 0.05)
	Mask = 1-Mask;
	else
	Mask = 1;
	
	// Final color
	if(View_Mode == 1)
	{
		NFAA = lerp(float4(2.5,0,0,1),GetBB( texcoord.xy ), Mask );
	}
	else if (View_Mode == 2)
	{
		NFAA = Mask.xxxx;
	}	

return NFAA;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = NFAA(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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
technique Normal_Filter_Anti_Aliasing
{
			pass NFAA_Fast
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
