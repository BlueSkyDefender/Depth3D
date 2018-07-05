 ////----------------------//
 ///**2D to 3D converter**///
 //----------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* 2D+ Psudo Depth Based on Unsharp Mask                        																													*//
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
 //*                                                                            																									*//
 //* 																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The Max Depth amount.
#define Depth_Max 25

uniform float Depth <
	ui_type = "drag";
	ui_min = 1; ui_max = Depth_Max;
	ui_label = "Divergence Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.\n" 
				 "You can override this value.";
> = 15;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -Depth_Max; ui_max = Depth_Max;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point. Default is 0";
> = 0.0;

uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Anaglyph\0";
	ui_label = "3D Display Mode";
	ui_tooltip = "Stereoscopic 3D display output selection.";
> = 0;

uniform float Interlace_Optimization <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.5;
	ui_label = " Interlace Optimization";
	ui_tooltip = "Interlace Optimization Is used to reduce alisesing in a Line or Column interlaced image.\n"
	             "This has the side effect of softening the image.\n"
	             "Default is 0.375";
> = 0.375;

uniform int Scaling_Support <
	ui_type = "combo";
	ui_items = " 2160p\0 Native\0 1080p A\0 1080p B\0 1050p A\0 1050p B\0 720p A\0 720p B\0";
	ui_label = "Scaling Support";
	ui_tooltip = "Dynamic Super Resolution , Virtual Super Resolution, downscaling, or Upscaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.";
> = 1;

uniform int Anaglyph_Colors <
	ui_type = "combo";
	ui_items = "Red/Cyan\0Dubois Red/Cyan\0Green/Magenta\0Dubois Green/Magenta\0";
	ui_label = "Anaglyph Color Mode";
	ui_tooltip = "Select colors for your 3D anaglyph glasses.";
> = 0;

uniform float Anaglyph_Desaturation <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Anaglyph Desaturation";
	ui_tooltip = "Adjust anaglyph desaturation, Zero is Black & White, One is full color.";
> = 1.0;

uniform bool Eye_Swap <
	ui_label = "Swap Eyes";
	ui_tooltip = "L/R to R/L.";
> = false;

uniform float Image_Texture_Complexity <
	ui_type = "drag";
	ui_min = 0; ui_max = 25.0;
	ui_label = "Image Texture Complexity";
	ui_tooltip = "Raise this to add more pop out to areas in the image that have more texture complexity.\n" 
				 "Default is 1.0";
> = 1.0;

uniform float Range_Adjust <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 1.0;
	ui_label = "Range Adjust";
	ui_tooltip = "Range adjust determines the transform range in world. Default is 0";
> = 1.0;

uniform bool Night_Mode <
	ui_label = "Night Mode";
	ui_tooltip = "Night_Mode.";
> = false;

uniform int Mode <
	ui_type = "combo";
	ui_items = "Movie Mode\0Game Mode FPS\0Game Mode Mix\0Game Mode RTS\0";
	ui_label = "Depth Map Mode";
	ui_tooltip = "Pick an fake Depth Map Mode.";
> = 0;

uniform bool Pop <
	ui_label = "Pop";
	ui_tooltip = "Add a little image pop out.";
> = false;

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "Debug View.";
> = false;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define SIGMA 25

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
		
texture texFakeDB { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8;MipLevels = 8;};

sampler SamplerFakeDB
	{
		Texture = texFakeDB;
		MipLODBias = 2.0f;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
texture texBB { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; MipLevels = 8;};

sampler SamplerBBlur
	{
		Texture = texBB;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
		
texture texB { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; MipLevels = 8;};

sampler SamplerBlur
	{
		Texture = texB;
		MipLODBias = 4.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	

texture texBF { Width = BUFFER_WIDTH*0.5; Height = BUFFER_HEIGHT*0.5; Format = RGBA32F;MipLevels = 8;};

sampler SamplerBF
	{
		Texture = texBF;
		MipLODBias = 2.0f;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    return dot(float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x), float3(0.3, 0.59, 0.11));//Gray-scale conversion.
}

float3 encodePalYuv(float3 rgb)
{
	float3 RGB2Y =  float3( 0.299, 0.587, 0.114);
	float3 RGB2Cb = float3(-0.14713, -0.28886, 0.436);
	float3 RGB2Cr = float3(0.615,-0.51499,-0.10001);

	return float3(dot(rgb, RGB2Y), dot(rgb, RGB2Cb), dot(rgb, RGB2Cr));
}

float4 BBlur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0): SV_Target                                                                          
{
	return tex2D(BackBuffer,texcoord);
}

float4 Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0): SV_Target                                                                          
{
	float4 left ,right;
	
	float3 A,B,C;
	float M = texcoord.y+(Image_Texture_Complexity*100)*pix.y;
	left.rgb = rgb2hsv(tex2D(BackBuffer,texcoord + float2(M * pix.x,0)).rgb);
	right.rgb = rgb2hsv(tex2D(BackBuffer,texcoord - float2(M * pix.x,0)).rgb);

	A += distance(left, right);
	A += A;
	A += A;
	
	left.rgb = rgb2hsv(tex2Dlod(SamplerBBlur,float4(texcoord,0,1)).rgb);
	right.rgb = rgb2hsv(tex2D(BackBuffer,texcoord).rgb);
	
	B += distance(left, right);
	B += B;
	B += B;
	
	left.rgb = A;
	right.rgb = B;
	
	C += distance(left, right);
	
	return 1-float4(C.x, 1, 1, 1);
}

// transform range in world-z to 0-1 for near-far
float DepthRange( float d )
{
	float nearPlane = 0;
	float farPlane = Range_Adjust;
    return ( d - nearPlane ) / ( farPlane - nearPlane );
}

float4 FakeDB(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0): SV_Target
{
	float4 Done, left, right;
	//float R = encodePalYuv(tex2D(BackBuffer,texcoord).rgb).r;
	float G = encodePalYuv(tex2D(BackBuffer,texcoord).rgb).g;
	//float B = encodePalYuv(tex2D(BackBuffer,texcoord).rgb).b;
	float M = texcoord.y+(Image_Texture_Complexity*100)*pix.y;
	
	left.rgb = encodePalYuv(tex2D(BackBuffer,texcoord + float2(M * pix.x,0)).rgb);
	right.rgb = encodePalYuv(tex2D(BackBuffer,texcoord - float2(M * pix.x,0)).rgb);

	M = (left.x+right.x)/2;
	G *= 10;
	
	if(Night_Mode)
	G += M;
	
	float AA = lerp(tex2D(SamplerBlur,texcoord).xxxx,G.xxxx,0.50).x;
	float AB = lerp(tex2D(SamplerBlur,texcoord).xxxx,G.xxxx,0.425).x;
	float AC = lerp(tex2D(SamplerBlur,texcoord).xxxx,G.xxxx,0.375).x;
	
	if (Mode == 0)
	{
		Done = DepthRange(AA).xxxx;
	}
	else if (Mode == 1)
	{
		Done = DepthRange(AB).xxxx;
	}
	else if (Mode == 2)
	{
		Done = DepthRange(AC).xxxx;
	}
	else if (Mode == 3)
	{
		Done = tex2D(SamplerBlur,texcoord).xxxx;
	}

	return saturate(Done);
}

#define BSIGMA 0.1
#define MSIZE 15

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

float normpdf3(in float3 v, in float sigma)
{
	return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
}
	
float4 Bilateral_Filter(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	//Bilateral Filter//                                                                                                                                                                   
	float3 c = tex2D(SamplerFakeDB,texcoord.xy).rgb;
	
	float2 ScreenCal = float2(2.5*pix.x,2.5*pix.y);

	float2 FinCal = ScreenCal;
	
	const int kSize = (MSIZE-1)/2;	

	float weight[MSIZE] = 
	{  
	0.031225216, 
	0.033322271, 
	0.035206333, 
	0.036826804, 
	0.038138565, 
	0.039104044, 
	0.039695028, 
	0.039894000, 
	0.039695028, 
	0.039104044, 
	0.038138565, 
	0.036826804, 
	0.035206333, 
	0.033322271, 
	0.031225216
	};  

		float3 final_colour;
		float Z;
		[unroll]
		for (int i = 0; i <= kSize; ++i)
		{
			weight[kSize+i] = normpdf(float(i), SIGMA);
			weight[kSize-i] = normpdf(float(i), SIGMA);
		}
		
		float3 cc;
		float factor;
		float bZ = 1.0/normpdf(0.0, BSIGMA);
		
		[loop]
		for (int j=-kSize; j <= kSize; ++j)
		{
			for (int k=-kSize; k <= kSize; ++k)
			{
			
				float2 XY;

					XY = float2(float(j),float(k))*FinCal;
					cc = tex2D(SamplerFakeDB,texcoord.xy+XY).rgb;
	
				factor = normpdf3(cc-c, BSIGMA)*bZ*weight[kSize+k]*weight[kSize+j];
				Z += factor;
				final_colour += factor*cc;

			}
		}
		
		float4 Bilateral_Filter = float4(final_colour/Z, 1.0);
return max(0.01,Bilateral_Filter);
}

float Conv(float D,float2 texcoord)
{
	float MSZ = Depth * pix.x;

		float Divergence_Locked = Depth * 0.001;
		
		float Convergence;		

			Convergence = 1 - Divergence_Locked / D;
	
		Convergence = lerp( MSZ * Convergence, MSZ * D, 0.8125);
				
    return Convergence;
}

float4 Converter(float2 texcoord : TEXCOORD0)
{		
	float4 Out;
	float2 TCL,TCR,TexCoords = texcoord;
	float samplesA[13] = {0.5,0.546875,0.578125,0.625,0.659375,0.703125,0.75,0.796875,0.828125,0.875,0.921875,0.953125,1.0};
	float MS = Depth * pix.x, Adjust_A = 0.07692307;
	float P = Perspective * pix.x;
	if(Eye_Swap)
	{
		if ( Stereoscopic_Mode == 0 )
		{
			TCL = float2((texcoord.x*2-1) - P,texcoord.y);
			TCR = float2((texcoord.x*2) + P,texcoord.y);
		}
		else if( Stereoscopic_Mode == 1 )
		{
			TCL = float2(texcoord.x - P,texcoord.y*2-1);
			TCR = float2(texcoord.x + P,texcoord.y*2);
		}
		else
		{
			TCL = float2(texcoord.x - P,texcoord.y);
			TCR = float2(texcoord.x + P,texcoord.y);
		}
	}	
	else
	{
		if (Stereoscopic_Mode == 0)
		{
			TCL = float2((texcoord.x*2) + P,texcoord.y);
			TCR = float2((texcoord.x*2-1) - P,texcoord.y);
		}
		else if(Stereoscopic_Mode == 1)
		{
			TCL = float2(texcoord.x + P,texcoord.y*2);
			TCR = float2(texcoord.x - P,texcoord.y*2-1);
		}
		else
		{
			TCL = float2(texcoord.x + P,texcoord.y);
			TCR = float2(texcoord.x - P,texcoord.y);
		}
	}
	
	//Optimization for line & column interlaced out.
	if (Stereoscopic_Mode == 2)
	{
		TCL.y = TCL.y + (Interlace_Optimization * pix.y);
		TCR.y = TCR.y - (Interlace_Optimization * pix.y);
	}
	else if (Stereoscopic_Mode == 3)
	{
		TCL.x = TCL.x + (Interlace_Optimization * pix.y);
		TCR.x = TCR.x - (Interlace_Optimization * pix.y);
	}
		
		//Workaround for DX9 Games	
	
		float4 cL, LL; //tex2D(BackBuffer,float2(TCL.x,TCL.y)); //objects that hit screen boundary is replaced with the BackBuffer 		
		float4 cR, RR; //tex2D(BackBuffer,float2(TCR.x,TCR.y)); //objects that hit screen boundary is replaced with the BackBuffer
		float S, RF, RN, LF, LN, EX = Depth*125;
		float A = texcoord.y+EX*pix.y;
		A *= pix.x;
		
		[unroll]
		for (int i = 0; i < 13; i++) 
		{
				S = samplesA[i] * MS * 1.21875;
				LF += tex2D(SamplerBF,float2(TCL.x+S, TCL.y)).x*Adjust_A;
				RF += tex2D(SamplerBF,float2(TCR.x-S, TCR.y)).x*Adjust_A;
				LF = saturate(LF);
				RF = saturate(RF);
		}
			if(Pop)
			{
				LF = Conv(LF,TexCoords);
				RF = Conv(RF,TexCoords);
			}
			else
			{
				LF = MS * LF;
				RF = MS * RF;
			}
			cR = tex2Dlod(BackBuffer, float4( (TCR.x + RF) + A, TCR.y,0,0)); //Good
			cL = tex2Dlod(BackBuffer, float4( (TCL.x - LF) - A, TCL.y,0,0)); //Good

			RR = cR;
			LL = cL;
			
			if ( !Eye_Swap )
			{
				cR = LL; //Good
				cL = RR; //Good
			}
			
	float2 gridxy;

	if(Scaling_Support == 0)
	{
		gridxy = floor(float2(TexCoords.x*3840.0,TexCoords.y*2160.0));
	}	
	else if(Scaling_Support == 1)
	{
		gridxy = floor(float2(TexCoords.x*BUFFER_WIDTH,TexCoords.y*BUFFER_HEIGHT));
	}
	else if(Scaling_Support == 2)
	{
		gridxy = floor(float2(TexCoords.x*1920.0,TexCoords.y*1080.0));
	}
	else if(Scaling_Support == 3)
	{
		gridxy = floor(float2(TexCoords.x*1921.0,TexCoords.y*1081.0));
	}
	else if(Scaling_Support == 4)
	{
		gridxy = floor(float2(TexCoords.x*1680.0,TexCoords.y*1050.0));
	}
	else if(Scaling_Support == 5)
	{
		gridxy = floor(float2(TexCoords.x*1681.0,TexCoords.y*1051.0));
	}
	else if(Scaling_Support == 6)
	{
		gridxy = floor(float2(TexCoords.x*1280.0,TexCoords.y*720.0));
	}
	else if(Scaling_Support == 7)
	{
		gridxy = floor(float2(TexCoords.x*1281.0,TexCoords.y*721.0));
	}
			
		if(Stereoscopic_Mode == 0)
		{	
			Out = TexCoords.x < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 1)
		{	
			Out = TexCoords.y < 0.5 ? cL : cR;
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
	
			if(Debug_View)
			Out.rgb = tex2D(SamplerBF,texcoord).xxx;

	return float4(Out.rgb,1);
}

	
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.5*BUFFER_WIDTH*pix.x,PosY = 0.5*BUFFER_HEIGHT*pix.y;	
	float4 Color = Converter(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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
technique Dimension_Plus
{
			pass BBlurFilter
		{
			VertexShader = PostProcessVS;
			PixelShader = BBlur;
			RenderTarget = texBB;
		}
			pass BlurFilter
		{
			VertexShader = PostProcessVS;
			PixelShader = Blur;
			RenderTarget = texB;
		}	
			pass FakeDBFilter
		{
			VertexShader = PostProcessVS;
			PixelShader = FakeDB;
			RenderTarget = texFakeDB;
		}	
			pass BilateralFilterPass
		{
			VertexShader = PostProcessVS;
			PixelShader = Bilateral_Filter;
			RenderTarget = texBF;
		}		
			pass CuesUnsharpMask
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
