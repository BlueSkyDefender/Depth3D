 ////------------//
 ///**3DToElse**///
 //------------////
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Stereo Input Converter 1.0                             																														*//
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

uniform int Stereoscopic_Mode_Input <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Checkerboard 3D\0Anaglyph GS *WIP*\0Anaglyph Color *WIP*\0Frame Sequential\0";
	ui_label = "Stereoscopic Mode Input";
	ui_tooltip = "Change to the proper stereoscopic input.";
	ui_category = "Stereoscopic Conversion";
> = 0;

uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Anaglyph\0";
	ui_label = "3D Display Mode";
	ui_tooltip = "Stereoscopic 3D display output selection.";
	ui_category = "Stereoscopic Conversion";
> = 0;

uniform int Perspective <
	ui_type = "drag";
	ui_min = -350; ui_max = 350;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform int Scaling_Support <
	ui_type = "combo";
	ui_items = " 2160p\0 Native\0 1080p A\0 1080p B\0 1050p A\0 1050p B\0 720p A\0 720p B\0TEST\0";
	ui_label = "Scaling Support";
	ui_tooltip = "Dynamic Super Resolution , Virtual Super Resolution, downscaling, or Upscaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.";
	ui_category = "Stereoscopic Options";
> = 1;

uniform float Interlace_Optimization <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.5;
	ui_label = " Interlace Optimization";
	ui_tooltip = "Interlace Optimization Is used to reduce alisesing in a Line or Column interlaced image.\n"
	             "This has the side effect of softening the image.\n"
	             "Default is 0.375";
	ui_category = "Stereoscopic Options";
> = 0.375;

uniform int Anaglyph_Colors <
	ui_type = "combo";
	ui_items = "Red/Cyan\0Dubois Red/Cyan\0Green/Magenta\0Dubois Green/Magenta\0";
	ui_label = "Anaglyph Color Mode";
	ui_tooltip = "Select colors for your 3D anaglyph glasses.";
	ui_category = "Stereoscopic Options";
> = 0;

uniform float Anaglyph_Desaturation <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Anaglyph Desaturation";
	ui_tooltip = "Adjust anaglyph desaturation, Zero is Black & White, One is full color.";
	ui_category = "Stereoscopic Options";
> = 1.0;

uniform bool Eye_Swap <
	ui_label = "Eye Swap";
	ui_tooltip = "Left right image change.";
	ui_category = "Stereoscopic Options";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define TextureSize float2(BUFFER_WIDTH, BUFFER_HEIGHT)

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
	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 

sampler SamplerCL
	{
		Texture = texCL;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

sampler SamplerCR
	{
		Texture = texCR;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};
	
texture texBB  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; MipLevels = 8;}; 

sampler SamplerBB
	{
		Texture = texBB;
	};
  
 texture CurrentBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 

sampler CBackBuffer
	{
		Texture = CurrentBackBuffer;
	};

texture PastSingleBackBuffer  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;}; 

sampler PSBackBuffer
	{
		Texture = PastSingleBackBuffer;
	};
  
////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////
uniform uint framecount < source = "framecount"; >;
//Total amount of frames since the game started.

void PS_InputBB(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
	color = tex2D(BackBuffer, float2(texcoord.x,texcoord.y));
}

//Unilateral Left
float4 UL(in float2 texcoord : TEXCOORD0)
{
	float gridy = floor(texcoord.y*(BUFFER_HEIGHT)); //Native
	return int(gridy) & 1 ? 0 : tex2D(BackBuffer, float2(texcoord.x,texcoord.y)) ;
}

float4 Uni_L(in float2 texcoord : TEXCOORD0)
{
   float4 tl = UL(texcoord);
   float4 tr = UL(texcoord + float2(0.0, -pix.y));
   float4 bl = UL(texcoord + float2(0.0, pix.y));
   float h = 0.5f;
   float4 tA = lerp( tl, tr, h );
   float4 tB = lerp( tl, bl, h );
   float4 done = lerp( tA, tB, h ) * 2.0;//2.0 Gamma correction.
   return done;
}

//Unilateral Right
float4 UR(in float2 texcoord : TEXCOORD0)
{
	float gridy = floor(texcoord.y*(BUFFER_HEIGHT)); //Native
	return int(gridy) & 1 ? tex2D(BackBuffer, float2(texcoord.x,texcoord.y)) : 0 ;
}

float4 Uni_R(in float2 texcoord : TEXCOORD0)
{
   float4 tl = UR(texcoord);
   float4 tr = UR(texcoord + float2(0.0, -pix.y));
   float4 bl = UR(texcoord + float2(0.0, pix.y));
   float h = 0.5f;
   float4 tA = lerp( tl, tr, h );
   float4 tB = lerp( tl, bl, h );
   float4 done = lerp( tA, tB, h ) * 2.0;//2.0 Gamma correction.
   return done;
}

//Bilateral Left
float4 BL(in float2 texcoord : TEXCOORD0)
{
	float2 gridxy = floor(float2(texcoord.x*BUFFER_WIDTH,texcoord.y*BUFFER_HEIGHT));
	return int(gridxy.x+gridxy.y) & 1 ? 0 : tex2D(BackBuffer, float2(texcoord.x,texcoord.y)) ;
}

float4 Bi_L(in float2 texcoord : TEXCOORD0)
{
   float4 tl = BL(texcoord);
   float4 tr = BL(texcoord + float2(pix.x, 0.0));
   float4 bl = BL(texcoord + float2(0.0, pix.y));
   float4 br = BL(texcoord + float2(pix.x, pix.y));
   float h = 0.5f;
   float4 tA = lerp( tl, tr, h );
   float4 tB = lerp( bl, br, h );
   float4 done = lerp( tA, tB, h ) * 2.0;//2.0 Gamma correction.
   return done;
}

//Bilateral Right
float4 BR(in float2 texcoord : TEXCOORD0)
{
	float2 gridxy = floor(float2(texcoord.x*BUFFER_WIDTH,texcoord.y*BUFFER_HEIGHT));
	return int(gridxy.x+gridxy.y) & 1 ? tex2D(BackBuffer, float2(texcoord.x,texcoord.y)) : 0 ;
}

float4 Bi_R(in float2 texcoord : TEXCOORD0)
{
   float4 tl = BR(texcoord);
   float4 tr = BR(texcoord + float2(pix.x, 0.0));
   float4 bl = BR(texcoord + float2(0.0, pix.y));
   float4 br = BR(texcoord + float2(pix.x, pix.y));
   float h = 0.5f;
   float4 tA = lerp( tl, tr, h );
   float4 tB = lerp( bl, br, h );
   float4 done = lerp( tA, tB, h ) * 2.0;//2.0 Gamma correction.
   return done;
}

void PS_InputLR(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 colorA : SV_Target0 , out float4 colorB: SV_Target1)
{	
float4 Left,Right;
	if(Stereoscopic_Mode_Input == 0) //SbS
	{
		Left =  tex2D(BackBuffer,float2(texcoord.x*0.5,texcoord.y));
		Right = tex2D(BackBuffer,float2(texcoord.x*0.5+0.5,texcoord.y));
	}
	else if(Stereoscopic_Mode_Input == 1) //TnB
	{
		Left =  tex2D(BackBuffer,float2(texcoord.x,texcoord.y*0.5));
		Right = tex2D(BackBuffer,float2(texcoord.x,texcoord.y*0.5+0.5));
	}	
	else if(Stereoscopic_Mode_Input == 2) //Line_Interlaced Unilateral Reconstruction needed.
	{
		Left =  Uni_L(texcoord);
		Right = Uni_R(texcoord);
	}	
	else if(Stereoscopic_Mode_Input == 3) //CB_3D Bilateral Reconstruction needed.
	{
		Left =  Bi_L(texcoord);
		Right = Bi_R(texcoord);
	}
	else if(Stereoscopic_Mode_Input == 4)
	{
		float3 Red = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).rrr * float3(1,0,0);
		float3 Green = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).ggg * float3(0,1,0);
		float3 Blue = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).bbb * float3(0,0,1);
			
		float GS_R = length(Red);
		float GS_GB = length(Blue+Green);
		
		float4 A = float4(GS_R,GS_R,GS_R,1);		
		float4 B = float4(GS_GB,GS_GB,GS_GB,1);

		Left =  A;
		Right = B;
	}
	else if(Stereoscopic_Mode_Input == 5) //  DeAnaglyph Need. Need to Do ReSearch.
	{
		float3 Red = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).rrr * float3(1,0,0);
		float3 Green = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).ggg * float3(0,1,0);
		float3 Blue = tex2D(BackBuffer,float2(texcoord.x,texcoord.y)).bbb * float3(0,0,1);
			
		float GS_R = length(Red);
		float GS_GB = length(Blue+Green);
		
		float4 A = float4(GS_R,GS_R,GS_R,1);				
		float4 B = float4(GS_GB,GS_GB,GS_GB,1);

		A = lerp(A , tex2Dlod(SamplerBB,float4(texcoord,0,8.0)) , 0.025);		 
		float3 GS_A = dot(A.rgb,float3(0.299, 0.587, 0.114));
		float3 ADone = lerp(GS_A,A.rgb,62.5);
	
		B = lerp(B , tex2Dlod(SamplerBB,float4(texcoord,0,8.0)) , 0.025);		 
		float3 GS_B = dot(B.rgb,float3(0.299, 0.587, 0.114));
		float3 BDone = lerp(GS_B,B.rgb,62.5);
		
	
		A = lerp(float4(ADone,1),float4(ADone,1)*tex2Dlod(SamplerBB,float4(texcoord,0,5.0)),0.25);
		B = lerp(float4(BDone,1),float4(BDone,1)*tex2Dlod(SamplerBB,float4(texcoord,0,2.0)),0.25);
		
		Left =  A;
		Right = B;
		
	}
	else //Frame Sequential Conversion.
	{
		float OddEven = framecount % 2 == 0;
		
		//Past Single Frame
		Left = tex2D(PSBackBuffer,float2(texcoord.x,texcoord.y));
		Right = tex2D(PSBackBuffer,float2(texcoord.x,texcoord.y));
		//Current Single Frame
		if (OddEven)
		{	
			Left =  tex2D(BackBuffer,float2(texcoord.x,texcoord.y));
		}
		else
		{
			Right = tex2D(BackBuffer,float2(texcoord.x,texcoord.y));
		}
	}
	colorA = Left;
	colorB = Right;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void PS0(float4 position : SV_Position, float2 texcoord : TEXCOORD0, out float4 color : SV_Target)
{
	float4 cL, cR , Out;
	float2 TCL, TCR;
	float P = Perspective * pix.x;
		
		if (Stereoscopic_Mode == 0)
		{
			TCR.x = (texcoord.x*2-1) - P;
			TCL.x = (texcoord.x*2) + P;
			TCR.y = texcoord.y;
			TCL.y = texcoord.y;
		}
		else if(Stereoscopic_Mode == 1)
		{
			TCR.x = texcoord.x - P;
			TCL.x = texcoord.x + P;
			TCR.y = (texcoord.y*2-1);
			TCL.y = (texcoord.y*2);
		}
		else
		{
			TCR.x = texcoord.x - P;
			TCL.x = texcoord.x + P;
			TCR.y = texcoord.y;
			TCL.y = texcoord.y;
		}
		
		//Optimization for line & column interlaced out.
		if (Stereoscopic_Mode == 2)
		{
			TCL.y = TCL.y + (Interlace_Optimization * pix.y);
			TCR.y = TCR.y - (Interlace_Optimization * pix.y);
		}
		else if (Stereoscopic_Mode == 3)
		{
			TCL.x = TCL.x + (Interlace_Optimization * pix.x);
			TCR.x = TCR.x - (Interlace_Optimization * pix.x);
		}
		
		if(Eye_Swap)
		{
		cL = tex2D(SamplerCL,float2(TCL.x,TCL.y));
		cR = tex2D(SamplerCR,float2(TCR.x,TCR.y));
		}
		else
		{
		cL = tex2D(SamplerCR,float2(TCL.x,TCL.y));
		cR = tex2D(SamplerCL,float2(TCR.x,TCR.y));
		}

	float2 gridxy;

	if(Scaling_Support == 0)
	{
		gridxy = floor(float2(texcoord.x*3840.0,texcoord.y*2160.0));
	}	
	else if(Scaling_Support == 1)
	{
		gridxy = floor(float2(texcoord.x*BUFFER_WIDTH,texcoord.y*BUFFER_HEIGHT));
	}
	else if(Scaling_Support == 2)
	{
		gridxy = floor(float2((texcoord.x*1920.0)*0.5,(texcoord.y*1080.0)*0.5));
	}
	else if(Scaling_Support == 3)
	{
		gridxy = floor(float2((texcoord.x*1921.0)*0.5,(texcoord.y*1081.0)*0.5));
	}
	else if(Scaling_Support == 4)
	{
		gridxy = floor(float2((texcoord.x*1680.0)*0.5,(texcoord.y*1050.0)*0.5));
	}
	else if(Scaling_Support == 5)
	{
		gridxy = floor(float2((texcoord.x*1681.0)*0.5,(texcoord.y*1051.0)*0.5));
	}
	else if(Scaling_Support == 6)
	{
		gridxy = floor(float2((texcoord.x*1280.0)*0.5,(texcoord.y*720.0)*0.5));
	}
	else if(Scaling_Support == 7)
	{
		gridxy = floor(float2((texcoord.x*1281.0)*0.5,(texcoord.y*721.0)*0.5));
	}
			
	if(Stereoscopic_Mode == 0)
	{	
		Out = texcoord.x < 0.5 ? cL : cR;
	}
	else if(Stereoscopic_Mode == 1)
	{	
		Out = texcoord.y < 0.5 ? cL : cR;
	}
	else if(Stereoscopic_Mode == 2)
	{
		Out = int(gridxy.y) & 1 ? cR : cL;	
	}
	else if(Stereoscopic_Mode == 3)
	{
		Out = int(gridxy.x) & 1 ? cR : cL;		
	}
	else if(Stereoscopic_Mode == 4)
	{	
		Out = int(gridxy.x+gridxy.y) & 1 ? cR : cL;
	}
	else if(Stereoscopic_Mode == 5)
	{													
			float3 HalfLA = dot(cL.rgb,float3(0.299, 0.587, 0.114));
			float3 HalfRA = dot(cR.rgb,float3(0.299, 0.587, 0.114));
			float3 LMA = lerp(HalfLA,cL.rgb,Anaglyph_Desaturation);  
			float3 RMA = lerp(HalfRA,cR.rgb,Anaglyph_Desaturation); 
			
			float4 cA = float4(LMA,1);
			float4 cB = float4(RMA,1);

		if (Anaglyph_Colors == 0)
		{
			float4 LeftEyecolor = float4(1.0,0.0,0.0,1.0);
			float4 RightEyecolor = float4(0.0,1.0,1.0,1.0);
			
			Out =  (cA*LeftEyecolor) + (cB*RightEyecolor);
		}
		else if (Anaglyph_Colors == 1)
		{
		float red = 0.437 * cA.r + 0.449 * cA.g + 0.164 * cA.b
				- 0.011 * cB.r - 0.032 * cB.g - 0.007 * cB.b;
		
		if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

		float green = -0.062 * cA.r -0.062 * cA.g -0.024 * cA.b 
					+ 0.377 * cB.r + 0.761 * cB.g + 0.009 * cB.b;
		
		if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

		float blue = -0.048 * cA.r - 0.050 * cA.g - 0.017 * cA.b 
					-0.026 * cB.r -0.093 * cB.g + 1.234  * cB.b;
		
		if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }

		Out = float4(red, green, blue, 0);
		}
		else if (Anaglyph_Colors == 2)
		{
			float4 LeftEyecolor = float4(0.0,1.0,0.0,1.0);
			float4 RightEyecolor = float4(1.0,0.0,1.0,1.0);
			
			Out =  (cA*LeftEyecolor) + (cB*RightEyecolor);			
		}
		else
		{
							
		float red = -0.062 * cA.r -0.158 * cA.g -0.039 * cA.b
				+ 0.529 * cB.r + 0.705 * cB.g + 0.024 * cB.b;
		
		if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

		float green = 0.284 * cA.r + 0.668 * cA.g + 0.143 * cA.b 
					- 0.016 * cB.r - 0.015 * cB.g + 0.065 * cB.b;
		
		if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

		float blue = -0.015 * cA.r -0.027 * cA.g + 0.021 * cA.b 
					+ 0.009 * cB.r + 0.075 * cB.g + 0.937  * cB.b;
		
		if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
				
		Out = float4(red, green, blue, 0);
		}
	}
	color = Out;
}

void Current_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{	 	
	color = tex2D(BackBuffer,texcoord);
}

void Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target)
{	
	PastSingle = tex2D(CBackBuffer,texcoord);
}

///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////

// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

///////////////////////////////////////////////Depth Map View//////////////////////////////////////////////////////////////////////

//*Rendering passes*//

technique To_Else
{		
			pass CBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Current_BackBuffer;
			RenderTarget = CurrentBackBuffer;
		}
			pass BB
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_InputBB;
			RenderTarget = texBB;
		}	
			pass StereoInput
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_InputLR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;
		}
			pass StereoToElse
		{
			VertexShader = PostProcessVS;
			PixelShader = PS0;	
		}
			pass PBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BackBuffer;
			RenderTarget = PastSingleBackBuffer;	
		}
		
}
