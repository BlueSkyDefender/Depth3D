 ////-------//
 ///**PMB**///
 //-------////
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* pseudo motion blur                            																														*//
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
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
uniform float Persistence <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.00;
	ui_label = " Persistence";
	ui_tooltip = "Increase persistence longer the trail or afterimage.\n"
				"If pushed out the effect is alot like long exposure.\n"
				"This can be used for light painting in games.\n"
				"1000/1 is 1.0, so 1/2 is 0.5 and so forth.\n"
				"Default is 1/250 so 0.750, 0 is infinity.";
	ui_category = "Motion Blur Adjust";
> = 0.50;

uniform float Power <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 2.5;
	ui_label = "Power";
	ui_tooltip = "Power.";
> = 1.75;

uniform float Blur_Amount <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 1.5;
	ui_label = "Blur Amount";
	ui_tooltip = "Adjust Blur Amount";
> = 1.0;


uniform bool Blur_Boost <
	ui_label = " Blur Boost";
	ui_tooltip = "Boost Blur by lowering image res by half.";
> = 0;

//Depth Map//
uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "DM0 Normal\0DM1 Reversed\0";
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "Linearization for the zBuffer also known as Depth Map.\n"
			     "DM0 is Z-Normal and DM1 is Z-Reversed.\n";
	ui_category = "Depth Map";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.0;
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


uniform int Debug_View <
	ui_type = "combo";
	ui_items = "A\0B\0C\0D\0";
	ui_label = " Debug Views";
> = 0;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture DepthBufferTex : DEPTH;

sampler ZBuffer 
	{ 
		Texture = DepthBufferTex; 
	};
	
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};

texture CurrentColorBuffer  { Width = BUFFER_WIDTH ; Height = BUFFER_HEIGHT; Format = RGBA32F;  MipLevels = 2; }; 

sampler CColorBuffer
	{
		Texture = CurrentColorBuffer;
	};
	
texture CurrentDepthBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; }; 

sampler CDepthBuffer
	{
		Texture = CurrentDepthBuffer;
	};

texture PastDepthBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; }; 

sampler PDepthBuffer
	{
		Texture = PastDepthBuffer;
	};


texture PastColorBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; }; 

sampler PCDepthBuffer
	{
		Texture = PastColorBuffer;
	};

texture PastSingleDepthBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PSDepthBuffer
	{
		Texture = PastSingleDepthBuffer;
	};
	
uniform float frametime < source = "frametime"; >;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
float DepthMap(float2 texcoord : TEXCOORD0)
{	
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBuffer = tex2D(ZBuffer, texcoord).x; //Depth Buffer
	
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

float4 Bbuffer(float2 texcoord : TEXCOORD)
{		
	float P = Persistence;
    float4 C = tex2D(BackBuffer, texcoord);
    
    C = tex2D(PCDepthBuffer, texcoord);
    
    C = C * P;
    
    C = max( tex2Dlod(CColorBuffer, float4(texcoord,0,Blur_Boost)), C);
    
    return C;
}

float4 Vbuffer(float2 texcoord : TEXCOORD)
{   
	float current_buffer = DepthMap(texcoord);
	float past_single_buffer = tex2D(PSDepthBuffer, texcoord).x;//Past Single Buffer
		
	//Used for a mask calculation
	//Velosity Mask
	float V = distance(current_buffer,past_single_buffer);
	
	float2 a = float2(V * Power, V ) / past_single_buffer;	
	return float4(a,0,1.0);
}

float4 MotionBlur(float2 texcoord : TEXCOORD0)
{	
	float DB = DepthMap(texcoord), Mask = saturate(lerp(1-Vbuffer(texcoord).r,1,-1));
	float2 AVB = saturate(Vbuffer(texcoord).rg * 0.5 + 0.5);
	float4 color = tex2D(BackBuffer, texcoord); 
	if(Debug_View == 0)
	{ // Bbuffer(texcoord)
		color =  lerp(Bbuffer(texcoord), tex2D(BackBuffer, texcoord), Mask );	
	}
	else if(Debug_View == 1)
	{
		color = lerp(float4(1,0,0,1), tex2D(BackBuffer, texcoord), Mask );
	}
	else if (Debug_View == 2)
	{
		color = Mask.xxxx;
	}
	else if (Debug_View == 3)
	{
		color = Bbuffer(texcoord);
	}
	//else
	//{
		//color = tex2D(BackBuffer, texcoord + AVB * pix * 2);
	//}
	
	if(Depth_Map_View)
		color =  DepthMap(texcoord).xxxx;
		
return color;
}

void Current_DepthBuffer(float4 position : SV_Position, float2 texcoords : TEXCOORD, out float4 Depth : SV_Target0, out float4 Color : SV_Target1)
{	 	
	Depth = DepthMap(texcoords);
	float2 tex_offset = Blur_Amount * pix; // gets texel offset
    float4 result = tex2D(BackBuffer,texcoords); // current fragment's contribution
	
	result += tex2D(BackBuffer,texcoords + float2(-1.0f * tex_offset.x,-0.5f * tex_offset.y));
		
	result += tex2D(BackBuffer,texcoords + float2(0.5f * tex_offset.x, -1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(0,                   -1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(-1.0f * tex_offset.x, 				  0));
	
	result += tex2D(BackBuffer,texcoords + float2(0.5f * tex_offset.x, -0.5f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(-0.5f * tex_offset.x, 0.5f * tex_offset.y));

	result += tex2D(BackBuffer,texcoords + float2(1.0f * tex_offset.x,  				  0));
	
	result += tex2D(BackBuffer,texcoords + float2(0,                    1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(-0.5f * tex_offset.x, 1.0f * tex_offset.y));
	
	result += tex2D(BackBuffer,texcoords + float2(1.0f * tex_offset.x,  0.5f * tex_offset.y));
	
	result /= 11;
	Color = result;
}

void Past_DepthBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingleD : SV_Target0, out float4 PastD : SV_Target1,out float4 PastC : SV_Target2)
{	
	PastD = DepthMap(texcoord);
	PastC = tex2D(BackBuffer, texcoord);
	PastSingleD = tex2D(CDepthBuffer,texcoord);
}

uniform float timer < source = "timer"; >;
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color =  MotionBlur(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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

///////////////////////////////////////////////////////////ReShade.fxh///////////////////////////////////////////////////////////////

// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

//*Rendering passes*//

technique Pseudo_Motion_Blur
{
		pass CBB
	{
		VertexShader = PostProcessVS;
		PixelShader = Current_DepthBuffer;
		RenderTarget0 = CurrentDepthBuffer;
		RenderTarget1 = CurrentColorBuffer;
	}	
	pass MotionBlur
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;
	}
		pass PBB
	{
		VertexShader = PostProcessVS;
		PixelShader = Past_DepthBuffer;
		RenderTarget0 = PastSingleDepthBuffer;
		RenderTarget1 = PastDepthBuffer;
		RenderTarget2 = PastColorBuffer;		
	}		
}