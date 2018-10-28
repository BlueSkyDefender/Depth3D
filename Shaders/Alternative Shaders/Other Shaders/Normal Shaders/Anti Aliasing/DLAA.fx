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

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "DLAA Out\0Mask View A\0Mask View B\0Mask View C\0";
	ui_label = "View Mode";
	ui_tooltip = "This is used to select the normal view output or debug view.";
> = 0;

uniform int Luma_Coefficient <
	ui_type = "combo";
	ui_label = "Luma";
	ui_tooltip = "Changes how color get sharpened by Unsharped Masking.\n"
				 "This should only affect RGB Luminace.";
	ui_items = "SD video\0HD video\0HDR video\0";
> = 0;

uniform int Luminace_Selection <
	ui_type = "combo";
	ui_items = "RGB Luminace\0Green Channel Luminace\0";
	ui_label = "Luminace Selection";
	ui_tooltip = "Luminace color selection Green to RGB Luminace.";
> = 0;

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
	else
	{
		Luma = float3(0.2627, 0.6780, 0.0593); //(HDR video) https://en.wikipedia.org/wiki/Rec._2100
	}
	return Luma;
}

//Luminosity Intensity
float LI(in float3 value)
{	
	//Luminosity Controll from 0.1 to 1.0 
	//If GGG value of 0.333, 0.333, 0.333 is about right for Green channel. 
	//Slide 51 talk more about this.
	float Lum;
	if (Luminace_Selection == 0)
	{
		Lum = dot(value.xyz,Luma());
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
	float4 DLAA, DLAA_S, DLAA_L; //DLAA is the completed AA Result.
	
	//5 bi-linear samples cross
	float4 Center 		= tex2D(BackBuffer, texcoord);
	   
	float4 Left			= tex2D(BackBuffer, texcoord + float2(-1.5 * pix.x, 0.0		   ) );
	float4 Right		= tex2D(BackBuffer, texcoord + float2( 1.5 * pix.x, 0.0		   ) );
	
	float4 Up			= tex2D(BackBuffer, texcoord + float2( 0.0		  ,-1.0 * pix.y) );
	float4 Down			= tex2D(BackBuffer, texcoord + float2( 0.0		  , 1.0 * pix.y) );   

	
	//Combine horizontal and vertical blurs together
	float4 combH		= Left + Right;
	float4 combV   		= Up + Down;
	
	//Bi-directional anti-aliasing using HORIZONTAL & VERTICAL blur and horizontal edge detection
	//Slide information triped me up here. Read slide 43.
	float4 CenterDiffH	= abs( combH - 2.0 * Center ) * 0.5;
	float4 CenterDiffV	= abs( combV - 2.0 * Center ) * 0.5;
	
	//Edge detection
	float EdgeLumH		= LI( CenterDiffH.rgb );
	float EdgeLumV		= LI( CenterDiffV.rgb );
	
	//Blur
	float4 blurredH		= ( combH  + Center) / 3;
	float4 blurredV		= ( combV  + Center) / 3;
	
	//L(x)
	float LumH			= LI( blurredH.rgb );
	float LumV			= LI( blurredV.rgb );
	
	//t
	float satAmountH 	= saturate( ( lambda * EdgeLumH - epsilon ) / LumH );
	float satAmountV 	= saturate( ( lambda * EdgeLumV - epsilon ) / LumV );
	
	//color = lerp(color,blur,sat(Edge/blur)
	//Re-blend Short Edge Done
	DLAA = lerp( Center, blurredH, satAmountH );
	DLAA = lerp( DLAA,   blurredV, satAmountH );
   	
	float4 	HNegA, HNegB, HNegC, HNegD, HNegE, 
			HPosA, HPosB, HPosC, HPosD, HPosE, 
			VNegA, VNegB, VNegC, 
			VPosA, VPosB, VPosC;
			
	// Long Edges 
    //16 bi-linear samples cross, added extra bi-linear samples in each direction.
    HNegA   = tex2D(BackBuffer, texcoord + float2(-3.5 * pix.x,  0.0) );
	HNegB   = tex2D(BackBuffer, texcoord + float2(-5.5 * pix.x,  0.0) );
	HNegC   = tex2D(BackBuffer, texcoord + float2(-7.5 * pix.x,  0.0) );
	
	HPosA   = tex2D(BackBuffer, texcoord + float2( 3.5 * pix.x,  0.0) );	
	HPosB   = tex2D(BackBuffer, texcoord + float2( 5.5 * pix.x,  0.0) );
	HPosC   = tex2D(BackBuffer, texcoord + float2( 7.5 * pix.x,  0.0) );
	
	VNegA   = tex2D(BackBuffer, texcoord + float2( 0.0,-3.5 * pix.y) );
	VNegB   = tex2D(BackBuffer, texcoord + float2( 0.0,-5.5 * pix.y) );
	VNegC   = tex2D(BackBuffer, texcoord + float2( 0.0,-7.5 * pix.y) );
	
	VPosA   = tex2D(BackBuffer, texcoord + float2( 0.0, 3.5 * pix.y) );
	VPosB   = tex2D(BackBuffer, texcoord + float2( 0.0, 5.5 * pix.y) );
	VPosC   = tex2D(BackBuffer, texcoord + float2( 0.0, 7.5 * pix.y) );
	
    //Long Edge detection H & V
    float4 AvgBlurH = ( HNegA + HNegB + HNegC + Center + HPosA + HPosB + HPosC ) / 7;   
    float4 AvgBlurV = ( VNegA + VNegB + VNegC + Center + VPosA + VPosB + VPosC ) / 7;
	float EAH = clamp( AvgBlurH.a * 2.0 - 1.0 ,0.0,1.0);
	float EAV = clamp( AvgBlurV.a * 2.0 - 1.0 ,0.0,1.0);
        
	float longEdge = max( EAH, EAV);
	
	//Used to Protect Text
	if ( longEdge > 1.0 )
    {    
	//Merge for BlurSamples.
	//Long Blur H
    float LongBlurLumH	= LI( AvgBlurH.rgb);
    
    //Long Blur V
	float LongBlurLumV	= LI( AvgBlurV.rgb );

	float CenterLI		= LI( Center.rgb );
	float LeftLI		= LI( Left.rgb );
	float RightLI		= LI( Right.rgb );
	float UpLI			= LI( Up.rgb );
	float DownLI		= LI( Down.rgb );
  
    float blurUp = saturate( 0.0 + ( LongBlurLumH - UpLI    ) / (CenterLI - UpLI) );
    float blurDown = saturate( 1.0 + ( LongBlurLumH - CenterLI ) / (CenterLI - DownLI) );
    float blurLeft = saturate( 0.0 + ( LongBlurLumV - LeftLI   ) / (CenterLI - LeftLI) );
    float blurRight = saturate( 1.0 + ( LongBlurLumV - CenterLI ) / (CenterLI - RightLI) );

    float4 UDLR = float4( blurLeft, blurRight, blurUp, blurDown );
	
	UDLR = UDLR == float4(0.0, 0.0, 0.0, 0.0) ? float4(1.0, 1.0, 1.0, 1.0) : UDLR;
        
    float4 H = lerp( Left , Center, UDLR.x );
		   H = lerp( Right, H	  , UDLR.y );
    float4 V = lerp( Up   , Center, UDLR.z );
		   V = lerp( Down , V	  , UDLR.w );
	
	//Reuse short samples and DLAA Long Edge Out.
    DLAA = lerp( Center, H , EAH);
	DLAA = lerp( DLAA  , V , EAV);  
	}
	
	float Mask = (EdgeLumH + (longEdge > 0.5)) * 0.5;
	
	if(View_Mode == 1)
	{
		DLAA = Mask;
	}
	else if (View_Mode == 2)
	{
		DLAA = lerp(DLAA,float4(1,0,0,1),Mask);
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
			pass DLAA_Light
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
