 ////----------//
 ///**Trails**///
 //----------////
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Trails an pseudo motion blur                            																														*//
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
	ui_category = "Trails Adjust";
> = 0.300;

uniform float T_P_Q <
	ui_type = "drag";
	ui_min = 0; ui_max = 2.0;
	ui_label = " Trail Quality & Persistence Quality";
	ui_tooltip = "Adjust trail and persistence blur effect.";
	ui_category = "Trails Adjust";
> = 1.0;

uniform float MBSeeking <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.00;
	ui_label = " Motion Blur Seeking";
	ui_tooltip = "Motion Blur Seeking effets the mask used for the effect.";
> = 0.75;

uniform float MPower <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 250.0;
	ui_label = " Motion Seeking Power";
	ui_tooltip = "This is used for general screen motion information.";
	ui_category = "Trails Adjust";
> = 125.0;

uniform float PowerL <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.10;
	ui_label = " Power Limiter";
	ui_tooltip = "Power Limiter is used to limit the seeking size of moving objects.";
	ui_category = "Trails Adjust";
> = 0.0;

uniform int Fill <
	ui_type = "drag";
	ui_min = 1; ui_max = 4;
	ui_label = " Fill Amount";
	ui_tooltip = "Adjust the Fill area for the Mask";
	ui_category = "Trails Adjust";
> = 2;

uniform bool Mask_View <
	ui_label = " Mask View";
	ui_tooltip = "To view the Mask use for Trails.";
	ui_category = "Trails Debug";
> = false;

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
	ui_min = 0.250; ui_max = 25.0;
	ui_label = " Depth Map Adjustment";
	ui_tooltip = "This allows for you to adjust the DM precision.\n"
				 "Adjust this to keep it as low as possible.\n"
				 "Default is 1.0";
	ui_category = "Depth Map";
> = 1.0;

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

uniform bool Depth_Map_Flip <
	ui_label = " Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Map";
> = false;

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

texture texTDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler DepthBuffer
	{
		Texture = texTDM;
	};
	
texture Mtex  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; MipLevels = 8;}; 

sampler MaskBuffer
	{
		Texture = Mtex;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
			
texture CurrentDepthBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler CDepthBuffer
	{
		Texture = CurrentDepthBuffer;
	};

texture PastDepthBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PDepthBuffer
	{
		Texture = PastDepthBuffer;
	};

texture PastSingleDepthBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PSDepthBuffer
	{
		Texture = PastSingleDepthBuffer;
	};
//CB

texture CurrentBackBuffer  { Width = BUFFER_WIDTH*0.5; Height = BUFFER_HEIGHT*0.5; Format = RGBA32F;}; 

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
texture texAveLum {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerAveLum																
	{
		Texture = texAveLum;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
texture texLumWeapon {Width = 256*0.5; Height = 256*0.5; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256*0.5 and a mip bias of 8 should be 1x1 

float AveLum(in float2 texcoord : TEXCOORD0)
{
	float Luminance = tex2Dlod(SamplerAveLum,float4(texcoord,0,0)).r; //Average Luminance Texture Sample 
	Luminance = smoothstep(0,1,Luminance*5);
	return Luminance;
}
	
uniform float frametime < source = "frametime"; >;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target)
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
					
	Color = float4(zBuffer,zBuffer,zBuffer,1.0);
}

float4 Mask(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{   
	float4 current_buffer = tex2D(DepthBuffer,texcoord);
	float4 past_single_buffer = tex2D(PSDepthBuffer, texcoord);//Past Single Buffer
	 
	//Used for a mask calculation
	//Velosity Mask
	float V = length(current_buffer-past_single_buffer);
	float Vr = smoothstep(0,1,V);
	float Vg = smoothstep(0,1,V*MPower);
	float Vb = smoothstep(0,1,V*25);
	
	return float4(Vr,Vg,Vb,1.0);
}

float4 VBuffer(float2 texcoord : TEXCOORD0)
{	
	float X = tex2Dlod(MaskBuffer,float4(texcoord,0,Fill)).b > (PowerL+0.005) ? 1 : 0;
	float Ma = lerp(0,AveLum(texcoord).r,tex2D(DepthBuffer,texcoord).r), Mb = X;
	float4 color;
	
	float4 current_buffer = tex2D(BackBuffer,texcoord);
	float4 past_buffer = tex2D(PBackBuffer, texcoord);//Past Buffer
	
	float P = 1-Persistence;
	past_buffer.rgb = past_buffer.rgb * P;
	
	current_buffer.rgb = max( current_buffer.rgb, past_buffer.rgb);

	float2 A = tex2D(DepthBuffer,texcoord).rr * 0.5 + 0.5;
	float2 B = float2(0, Ma);
	float2 C = float2(0, Mb * 0.5);
	float2 VelocityD = A - B - C;
	float Vm = saturate((VelocityD.x + VelocityD.y) *0.5);
			
	color =  float4(lerp( current_buffer.rgb ,tex2D(BackBuffer,texcoord).rgb,Vm.xxx > MBSeeking),1.0);

	
	if (Mask_View)
		color = lerp(Vm.xxxx * 2.0,Vm.xxxx > MBSeeking, 1-MBSeeking);
			
return color;
}
//CB
void Current_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{	 	
	color = tex2D(BackBuffer,texcoord);
}

void Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target0, out float4 Past : SV_Target1)
{	
	float2 samples[6] = {
	float2(-0.326212, -0.405805),  
	float2(-0.840144, -0.073580),  
	float2(-0.695914, 0.457137),  
	float2(-0.203345, 0.620716),  
	float2(0.962340, -0.194983),  
	float2(0.473434, -0.480026),  
	}; 
	
	Past = tex2D(BackBuffer,texcoord);
	PastSingle = tex2D(CBackBuffer,texcoord);
	
	float2 Adjust = float2(T_P_Q,T_P_Q)*pix;
	if(T_P_Q > 0)
	{
		[loop]
		for (int i = 0; i < 6; i++)
		{  
			Past += tex2D(BackBuffer, texcoord + Adjust * samples[i]);
			continue;
		}
		
	Past *= 0.16666666;
	}
}
//DB
void Current_DepthBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{	 	
	color = tex2D(DepthBuffer,texcoord);
}

void Past_DepthBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target0, out float4 Past : SV_Target1)
{	
	Past = tex2D(DepthBuffer,texcoord);
	PastSingle = tex2D(CDepthBuffer,texcoord);
}

float4 Average_Luminance(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float3 Average_Lum = tex2Dlod(MaskBuffer,float4(texcoord,0,0)).ggg;
	return float4(Average_Lum,1);
}

uniform float timer < source = "timer"; >;
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = VBuffer(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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

technique Trails
{
				pass CBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Current_BackBuffer;
			RenderTarget = CurrentBackBuffer;
		}
		pass zbuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthMap;
		RenderTarget = texTDM;
	}
		pass MaskBuffer
	{
		VertexShader = PostProcessVS;
		PixelShader = Mask;
		RenderTarget = Mtex;
	}
		pass CBB
	{
		VertexShader = PostProcessVS;
		PixelShader = Current_DepthBuffer;
		RenderTarget = CurrentDepthBuffer;
	}
		pass AverageLuminance
	{
		VertexShader = PostProcessVS;
		PixelShader = Average_Luminance;
		RenderTarget = texAveLum;
	}
		pass ExposureOut
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
		pass PBB
	{
		VertexShader = PostProcessVS;
		PixelShader = Past_DepthBuffer;
		RenderTarget0 = PastSingleDepthBuffer;
		RenderTarget1 = PastDepthBuffer;		
	}		
}