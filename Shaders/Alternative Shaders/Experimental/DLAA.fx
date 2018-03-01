 ////--------//
 ///**DLAA**///
 //--------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Directionally localized antialiasing.                                     																										*//
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
 //* http://and.intercon.ru/releases/talks/dlaagdc2011/																																*//	
 //* ---------------------------------																																				*//
 //*                                                                            																									*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform int Debug_View <
	ui_type = "combo";
	ui_items = "Off\0Short Edge\0Long Edge\0";
	ui_label = "Debug View";
	ui_tooltip = "To view Edge Detect working on, movie piture & ect.";
> = false;

uniform int Luminace_Selection <
	ui_type = "combo";
	ui_items = "RGB Luminace\0Green Channel Luminace\0";
	ui_label = "Luminace Selection";
	ui_tooltip = "Luminace color selection Green to RGB.";
> = 0;

uniform float Long_Edge_Seek <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Long Edge Seek";
	ui_tooltip = "Use this to seek out long edged jaggys.\n"
				 "The Sronger the blurryer the image.\n"
				 "Default is 0.625";
> = 0.625;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define lambda 3.0f
#define epsilon 0.1f

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Luminosity Intensity
float LI(in float3 value)
{	
	//Luminosity Controll from 0.1 to 1.0 
	//If GGG value of 0.333, 0.333, 0.333 is about right for Green channel. 
	//If RGB channels are used as luminosity 0.299, 0.587, 0.114
	//Slide 51 talk more about this.
	float Lum;
	if (Luminace_Selection == 0)
	{
		Lum = dot(value.xyz, float3(0.299, 0.587, 0.114));
	}
	else
	{
		Lum = dot(value.yyy, float3(0.333, 0.333, 0.333));
	}
	
	return Lum;
}

//Information on Slide 44 says to run the edge processing jointly short and Large.
float4 DLAA(float2 texcoord)
{
	//Short Edge Filter http://and.intercon.ru/releases/talks/dlaagdc2011/slides/#slide43
	float4 DLAA; //DLAA is the completed AA Result.
	
	//5 bi-linear samples cross
	float4 Center 		= tex2D(BackBuffer, texcoord);    
	float4 Left			= tex2D(BackBuffer, texcoord + float2(-pix.x,  0.0) );
	float4 Right		= tex2D(BackBuffer, texcoord + float2( pix.x,  0.0) );
	float4 Up			= tex2D(BackBuffer, texcoord + float2( 0.0, -pix.y) );
	float4 Down			= tex2D(BackBuffer, texcoord + float2( 0.0,  pix.y) );   
	
	//Combine horizontal and vertical blurs together
	float4 combH		= Left + Right;
	float4 combV   		= Up + Down;
	
	//Bi-directional anti-aliasing using *only* HORIZONTAL blur and horizontal edge detection
	//Slide information triped me up here. Read slide 43.
	float4 CenterDiffH	= abs( combH - 2.0 * Center ) * 0.5;  
	//float4 CenterDiffV	= abs( combV - 2.0 * Center ) * 0.5;
	
	//Edge detection
	float EdgeLumH		= LI( CenterDiffH.rgb );
	//float EdgeLumV		= LI( CenterDiffV.rgb );
		
	//Blur
	float4 blurredH		= ( combH + Center) * 0.33333333;
	float4 blurredV		= ( combV + Center) * 0.33333333;
	
	//L(x)
	float LumH			= LI( blurredH.rgb );
	float LumV			= LI( blurredV.rgb );
	
	//t
	float satAmountH 	= saturate( ( lambda * EdgeLumH - epsilon ) / LumH );
    float satAmountV 	= saturate( ( lambda * EdgeLumH - epsilon ) / LumV );
	
	//color = lerp(color,blur,sat(Edge/blur)
	//Re-blend Short Edge Done
	DLAA = lerp( Center,  blurredH, satAmountH );
	DLAA = lerp( Center,  blurredV, satAmountV );
	
	float4 HNegA, HNegB, HNegC, HNegD, HPosA, HPosB, HPosC, HPosD, VNegA, VNegB, VNegC, VNegD, VPosA, VPosB, VPosC, VPosD, CenterH, CenterV;
			
	// Long Edges 
    //16 bi-linear samples cross, 4 extra bi-linear samples in each direction. -8to8 Slide 44
	HNegA	= tex2D(BackBuffer, texcoord + float2(-pix.x,  0.0) );
	HNegB   = tex2D(BackBuffer, texcoord + float2(-2.0 * pix.x,  0.0) );
	HNegC   = tex2D(BackBuffer, texcoord + float2(-4.0 * pix.x,  0.0) );
	HNegD   = tex2D(BackBuffer, texcoord + float2(-8.0 * pix.x,  0.0) );
	HPosA   = tex2D(BackBuffer, texcoord + float2( pix.x,  0.0) );
	HPosB   = tex2D(BackBuffer, texcoord + float2( 2.0 * pix.x,  0.0) );
	HPosC   = tex2D(BackBuffer, texcoord + float2( 4.0 * pix.x,  0.0) );
	HPosD   = tex2D(BackBuffer, texcoord + float2( 8.0 * pix.x,  0.0) );
	 
	VNegA   = tex2D(BackBuffer, texcoord + float2( 0.0,-pix.y) );
	VNegB   = tex2D(BackBuffer, texcoord + float2( 0.0,-2.0 * pix.y) );
	VNegC   = tex2D(BackBuffer, texcoord + float2( 0.0,-4.0 * pix.y) );
	VNegD   = tex2D(BackBuffer, texcoord + float2( 0.0,-8.0 * pix.y) );
	VPosA   = tex2D(BackBuffer, texcoord + float2( 0.0, pix.y) );
	VPosB   = tex2D(BackBuffer, texcoord + float2( 0.0, 2.0 * pix.y) );
	VPosC   = tex2D(BackBuffer, texcoord + float2( 0.0, 4.0 * pix.y) );
	VPosD   = tex2D(BackBuffer, texcoord + float2( 0.0, 8.0 * pix.y) );
	
    //Long Edge detection H
    float4 EdgeBlurH = ( HNegA + HNegB + HNegC + HNegD + HPosA + HPosB + HPosC + HPosD );
    float4 longEdgeDH = abs( EdgeBlurH - 8.0 * DLAA ) * 0.5;
    float LongEdgeLumH	= LI( longEdgeDH.rgb );
    
    //Long Edge detection V
    float4 EdgeBlurV = ( VNegA + VNegB + VNegC + VNegD + VPosA + VPosB + VPosC + VPosD );
    float4 longEdgeDV = abs( EdgeBlurV - 8.0 * DLAA ) * 0.5; 
	float LongEdgeLumV	= LI( longEdgeDV.rgb );

	float LongEdgeLumHV = (LongEdgeLumV + LongEdgeLumV) * 0.5;

    //Long Edge detection H & V
    //float longEdge = abs( longEdgeH - longEdgeV);
    float LES = 1-Long_Edge_Seek; 
    if ( LongEdgeLumHV > LES )
	{    	
	//Merge for BlurSamples.
	//Long Blur H
    float4 longBlurH = ( HNegA + HNegB + HNegC + HNegD + HPosA + HPosB + HPosC + HPosD ) * 0.125;
    float LongBlurLumH	= LI( longBlurH.rgb );
    
    //Long Blur V
    float4 longBlurV = ( VNegA + VNegB + VNegC + VNegD + VPosA + VPosB + VPosC + VPosD ) * 0.125;
	float LongBlurLumV	= LI( longBlurV.rgb );
    
    //t
    float satAmountLH 	= saturate( ( lambda * LongEdgeLumH - epsilon ) / LongBlurLumH );
    float satAmountLV 	= saturate( ( lambda * LongEdgeLumV - epsilon ) / LongBlurLumV );
    
	float CenterLI		= LI( Center.rgb );
	float LeftLI		= LI( Left.rgb );
	float RightLI		= LI( Right.rgb );
	float UpLI			= LI( Up.rgb );
	float DownLI		= LI( Down.rgb );
    
    float4 V = Center;
    float4 H = Center;
    
    float blurUp = CenterLI == UpLI ? 0.0 : saturate( 0 + ( LongBlurLumH - UpLI    ) / ( CenterLI - UpLI    ) );
    float blurDown = CenterLI == DownLI ? 0.0 : saturate( 1 + ( LongBlurLumH - CenterLI ) / ( CenterLI - DownLI ) );
    float blurLeft = CenterLI == LeftLI ? 0.0 : saturate( 0 + ( LongBlurLumV - LeftLI   ) / ( CenterLI - LeftLI   ) );
    float blurRight = CenterLI == RightLI ? 0.0 : saturate( 1 + ( LongBlurLumV - CenterLI ) / ( CenterLI - RightLI  ) );

    float4 UDLR = float4( blurLeft, blurRight, blurUp, blurDown );

    V = lerp( Left  , V, UDLR.x );
    V  = lerp( Right , V, UDLR.y );
    H = lerp( Up   , H, UDLR.z );
    H = lerp( Down, H, UDLR.w );
	
	//Reuse short samples and DLAA Long Edge Out.
    DLAA = lerp( DLAA, V , satAmountLV);
	DLAA = lerp( DLAA, H , satAmountLH);  
    }
   
   	if(Debug_View == 1)
	{
		DLAA = EdgeLumH.xxxx;
	}
	else if(Debug_View == 2)
	{
		DLAA = LongEdgeLumHV.xxxx;
	}
	else
	{
		DLAA = DLAA;
	}

	    
	return DLAA;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = DLAA(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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
technique Directionally_Localized_Anti_Aliasing
{
			pass DLAA
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
