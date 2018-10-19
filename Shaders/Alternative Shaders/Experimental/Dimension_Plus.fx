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

#define Depth_Map_Division 1.75

// Determines The Max Depth amount.
#define Depth_Max 25

uniform int DBA <
	ui_type = "combo";
	ui_items = "Off\0Circle Gradient\0Oval Gradient\0Vertical Gradient\0";
	ui_label = "Depth Buffer Assiste";
	ui_tooltip = "Select the assisting Depth Buffer or turn it off.";
> = 0;

uniform float GDepth <
	ui_type = "drag";
	ui_min = 1; ui_max = 12.5;
	ui_label = "Gradient Depth Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.\n" 
				 "You can override this value Default is One.";
> = 1.0;

uniform float Divergence <
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

uniform int Fill <
	ui_type = "drag";
	ui_min = 0; ui_max = 4.0;
	ui_label = "Fill";
	ui_tooltip = "Raise this to fill in areas in the image.\n" 
				 "Default is 2";
> = 2;

uniform float Image_Texture_Complexity <
	ui_type = "drag";
	ui_min = 0; ui_max = 25.0;
	ui_label = "Image Texture Complexity";
	ui_tooltip = "Raise this to add more pop out to areas in the image that have more texture complexity.\n" 
				 "Default is 1.0";
> = 1.0;

uniform float Range_Adjust_N <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.25;
	ui_label = "Range Adjust Near";
	ui_tooltip = "Range adjust determines the transform range in world. Default is Zero.";
> = 0.0f;

uniform float Range_Adjust_F <
	ui_type = "drag";
	ui_min = 0.75; ui_max = 1.0;
	ui_label = "Range Adjust Far";
	ui_tooltip = "Range adjust determines the transform range in world. Default is One.";
> = 1.0f;

uniform bool Day_Night_Mode <
	ui_label = "Day & Night";
	ui_tooltip = "This mode helps correct for some day and night scenes.";
> = false;

uniform bool Neg_Tex <
	ui_label = "Negitive Texture Complexity";
	ui_tooltip = "This Mode Flip the Texture Complexity.";
> = false;

uniform float Balance <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = " Balance";
	ui_tooltip = "Balance Between Edge Detection and Cr.\n"
				"Default is 0.5";
> = 0.5;

uniform int Pulfrich_Effect_Assist <
	ui_type = "combo";
	ui_items = "Off\0Left to Right\0Right to Left\0";
	ui_label = "Pulfrich Effect Assist";
	ui_tooltip = "Pulfrich effect is a psychophysical percept wherein lateral motion of an object in the field of view is interpreted by the visual cortex as having a depth.\n" 
				 //"Special Mode is Both Left to Right and Right to Left.\n" 
				 "Use Pulfrich Effect Adjust to adjust Special Mode.";
> = 0;

uniform float Disocclusion_Power_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 12.5;
	ui_label = " Disocclusion Power Adjust";
	ui_tooltip = "Automatic occlusion masking power adjust.\n"
				"Default is 2.5";
> = 2.5;

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "Debug View.";
> = false;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
		
texture texFakeDB { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA8; MipLevels = 2;};

sampler SamplerFakeDB
	{
		Texture = texFakeDB;
		//MipLODBias = 1.0f;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
texture texBB { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA8; MipLevels = 8;};

sampler SamplerBBlur
	{
		Texture = texBB;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	
		
texture texBl { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA8; MipLevels = 2;};

sampler SamplerBlur
	{
		Texture = texBl;
		MipLODBias = 1.0f;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};	

texture texBF { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F;MipLevels = 2;};

sampler SamplerBF
	{
		Texture = texBF;
		MipLODBias = 1.0f;
		MipFilter = Linear; 
		MinFilter = Linear; 
		MagFilter = Linear;
	};
	
texture CurrentBB  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler CBackBuffer
	{
		Texture = CurrentBB;
	};

texture PastSingleBB  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler PSBackBuffer
	{
		Texture = PastSingleBB;
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
    //return dot(float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x), float3(0.3, 0.59, 0.11));//Gray-scale conversion.
}

float3 encodePalYuv(float3 rgb)
{
	float3 RGB2Y =  float3( 0.299, 0.587, 0.114);
	float3 RGB2Cb = float3(-0.14713, -0.28886, 0.436);
	float3 RGB2Cr = float3(0.615,-0.51499,-0.10001);

	return float3(dot(rgb, RGB2Y), dot(rgb, RGB2Cb), dot(rgb, RGB2Cr));
}

float4 BB(in float2 texcoord : TEXCOORD0)                                                                         
{
	float4 BB = tex2D(BackBuffer,texcoord);
	return BB;
}

float4 BBlur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0): SV_Target                                                                          
{
	float2 samples[12] = {  
	float2(-0.326212, -0.405805),  
	float2(-0.840144, -0.073580),  
	float2(-0.695914, 0.457137),  
	float2(-0.203345, 0.620716),  
	float2(0.962340, -0.194983),  
	float2(0.473434, -0.480026),  
	float2(0.519456, 0.767022),  
	float2(0.185461, -0.893124),  
	float2(0.507431, 0.064425),  
	float2(0.896420, 0.412458),  
	float2(-0.321940, -0.932615),  
	float2(-0.791559, -0.597705)  
	};  
	  
	float4 sum = BB( texcoord);  
	for (int i = 0; i < 12; i++)
	{  
		sum += BB( texcoord + samples[i] * pix * 6);  
	}  

	sum *= 0.07692307;  

		return sum;
}

float4 Blur(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0): SV_Target                                                                          
{
	float4 left ,right;
	
	float3 A,B,C,Flip = 0;
	
	if(Neg_Tex)
	Flip = 1.0;
	
	float M = texcoord.y+(Image_Texture_Complexity*125)*pix.y;
	left.rgb = rgb2hsv(Flip-BB(texcoord + float2(M * pix.x,0)).rgb);
	right.rgb = rgb2hsv(Flip-BB(texcoord - float2(M * pix.x,0)).rgb);

	A += distance(left, right);
	A += A;
	A += A;
	
	left.rgb = rgb2hsv(Flip-tex2Dlod(SamplerBBlur,float4(texcoord,0,Fill)).rgb);
	right.rgb = rgb2hsv(Flip-BB(texcoord).rgb);
	
	B += distance(left, right);
	B += B;
	B += B;
	
	left.rgb = A;
	right.rgb = B;
	
	C += distance(left, right);
		
	return 1-float4(saturate(C.x), 1, 1, 1);
}

// transform range in world-z to 0-1 for near-far
float DepthRange( float d )
{
	float nearPlane = Range_Adjust_N;
	float farPlane = Range_Adjust_F;
    return ( d - nearPlane ) / ( farPlane - nearPlane );
}

float4 FakeDB(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0): SV_Target
{
	float4 Done, left, right;
	float B = encodePalYuv(tex2D(BackBuffer,texcoord).rgb).b;
	float M = texcoord.y+(Image_Texture_Complexity*125)*pix.y;
	
	left.rgb = encodePalYuv(BB(texcoord + float2(M * pix.x,0)).rgb);
	right.rgb = encodePalYuv(BB(texcoord - float2(M * pix.x,0)).rgb);

	M = (left.x+right.x)/2;
		
	if(Day_Night_Mode)
	B += M;
	
	Done = lerp(tex2D(SamplerBlur,texcoord).xxxx,B.xxxx,Balance).xxxx;
	
	return saturate(Done);
}

float4 Assist(in float2 texcoord : TEXCOORD0)                                                                         
{
	float Merge, Num = 1800.00f;
	
	if(DBA == 2)
	Num = 1125.00f;
	
	float Down = (texcoord.y-Num*pix.y).x, Up = 1-(texcoord.y+Num*pix.y).x, Left = (texcoord.x-Num*pix.x).x, Right = 1-(texcoord.x+Num*pix.x).x;
	float Up_A = smoothstep(1,0.0,(texcoord.y+1.0*pix.y).x - 0.25);
	
	if(DBA == 1)
	{
		Merge = smoothstep(0,0.375,Down*Right*Up*Left);
	}
	else if(DBA == 2)
	{	
		Merge = smoothstep(0,0.375,(Down*Up)-(Left*Right)*(Left*Right));
	}
	else if(DBA == 3)
	{	
		Merge = smoothstep(0,1,Up_A);
	}
	
	//return lerp(tex2D(SamplerBF,texcoord.xy),Merge,Per);
	return Merge;
}

float4 Mix(in float2 texcoord : TEXCOORD0)                                                                         
{
float W = 1, DM, A, MS =  Divergence * pix.x;

	float M = 1, N = 9, Div = 1.0f / N, weight_A[9] = {0.0f,0.0125f,-0.0125f,0.025f,-0.025f,0.0375f,-0.0375f,0.05f,-0.05f};
	
	A += 5.5f; // Normal
	float2 dir = float2(0.5f,0.0f);
	MS *= Disocclusion_Power_Adjust;
		
	if (Disocclusion_Power_Adjust > 0) 
	{		
		[loop]
		for (int i = 0; i < N; i++)
		{	
			DM += tex2Dlod(SamplerFakeDB,float4(texcoord + dir * (weight_A[i] * MS) * A,0,M)).x * Div;
		}
	}
	else
	{
		DM = tex2Dlod(SamplerFakeDB,float4(texcoord,0,M)).x;
	}
		
	return saturate(float4(DepthRange(DM).xxx,W));		
}

#define SIGMA 10
#define BSIGMA 0.1125
#define MSIZE 9

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
	float3 c =  Mix(texcoord.xy).rgb;
	const int kSize = (MSIZE-1)/2;	

	float weight[MSIZE] = {0.031225216, 0.035206333, 0.038138565, 0.039695028, 0.039894000, 0.039695028, 0.038138565, 0.035206333, 0.031225216};  // by 9


		float3 final_colour;
		float Z;
		[unroll]
		for (int j = 0; j <= kSize; ++j)
		{
			weight[kSize+j] = normpdf(float(j), SIGMA);
			weight[kSize-j] = normpdf(float(j), SIGMA);
		}
		
		float3 cc;
		float factor;
		float bZ = 1.0/normpdf(0.0, BSIGMA);
		
		[loop]
		for (int i=-kSize; i <= kSize; ++i)
		{
			for (int j=-kSize; j <= kSize; ++j)
			{
				float2 XY = float2(float(i),float(j))*pix;
				cc =  Mix(texcoord.xy+XY).rgb;

				factor = normpdf3(cc-c, BSIGMA)*bZ*weight[kSize+j]*weight[kSize+i];
				Z += factor;
				final_colour += factor*cc;
			}
		}
		
	return float4(final_colour/Z, 1.0);
}

float4 LeftI(float2 texcoord : TEXCOORD0)
{	
	float4 Left;
	float DepthL = 1, N = 9, LDepth, samplesA[9] = {0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1.0};
	
	//MS is Max Separation P is Perspective Adjustment
	float MS = Divergence * pix.x, EX = Divergence*125.0, A = texcoord.y+EX*pix.y;
	
		A *= pix.x;	
		
		[loop]
		for ( int x = 0 ; x < N; x++ ) 
		{
			float S = samplesA[x], MSM = MS + 0.001f;
			LDepth = min(DepthL,tex2Dlod(SamplerBF,float4(texcoord.x + S * MSM, texcoord.y,0,0)).x);
				
			LDepth += min(DepthL,tex2Dlod(SamplerBF,float4(texcoord.x + S * (MSM * 0.9375f), texcoord.y,0,0)).x);
						
			LDepth += min(DepthL,tex2Dlod(SamplerBF,float4(texcoord.x + S * (MSM * 0.6875f), texcoord.y,0,0)).x);
			
			LDepth += min(DepthL,tex2Dlod(SamplerBF,float4(texcoord.x + S * (MSM * 0.500f), texcoord.y,0,0)).x);
		
			LDepth += min(DepthL,tex2Dlod(SamplerBF,float4(texcoord.x + S * (MSM * 0.4375f), texcoord.y,0,0)).x);
			
			LDepth += min(DepthL,tex2Dlod(SamplerBF,float4(texcoord.x + S * (MSM * 0.1875f), texcoord.y,0,0)).x);
								
			DepthL = min(DepthL,LDepth / 6.0f);
		}
		
		DepthL = DepthL * MS;	
	
	float ReprojectionLeft =  DepthL;

		Left = tex2Dlod(BackBuffer, float4((texcoord.x + ReprojectionLeft) + A, texcoord.y,0,0));
				
			if (Pulfrich_Effect_Assist == 1)
			{
				Left = tex2Dlod(PSBackBuffer, float4((texcoord.x + ReprojectionLeft) + A, texcoord.y,0,0));
			}
return Left;
}

float4 RightI(float2 texcoord : TEXCOORD0)
{
	float4 Right;
	float DepthR = 1, N = 9, RDepth, samplesA[9] = {0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1.0};
	
	//MS is Max Separation P is Perspective Adjustment
	float MS = Divergence * pix.x, EX = Divergence*125.0, A = texcoord.y+EX*pix.y;
	
		A *= pix.x;	
			
		[loop]
		for ( int x = 0 ; x < N; x++ ) 
		{
			float S = samplesA[x], MSM = MS + 0.001f;
			RDepth = min(DepthR,tex2Dlod(SamplerBF,float4(texcoord.x - S * MSM, texcoord.y,0,0)).x);
				
			RDepth += min(DepthR,tex2Dlod(SamplerBF,float4(texcoord.x - S * (MSM * 0.9375f), texcoord.y,0,0)).x);
						
			RDepth += min(DepthR,tex2Dlod(SamplerBF,float4(texcoord.x - S * (MSM * 0.6875f), texcoord.y,0,0)).x);
			
			RDepth += min(DepthR,tex2Dlod(SamplerBF,float4(texcoord.x - S * (MSM * 0.500f), texcoord.y,0,0)).x);
		
			RDepth += min(DepthR,tex2Dlod(SamplerBF,float4(texcoord.x - S * (MSM * 0.4375f), texcoord.y,0,0)).x);
			
			RDepth += min(DepthR,tex2Dlod(SamplerBF,float4(texcoord.x - S * (MSM * 0.1875f), texcoord.y,0,0)).x);
								
			DepthR = min(DepthR,RDepth / 6.0f);
		}
		
		DepthR = DepthR * MS;	
	
	float ReprojectionRight =  DepthR;

		Right = tex2Dlod(BackBuffer, float4((texcoord.x - ReprojectionRight) - A, texcoord.y,0,0));
				
			if (Pulfrich_Effect_Assist == 1)
			{
				Right = tex2Dlod(PSBackBuffer, float4((texcoord.x - ReprojectionRight) - A, texcoord.y,0,0));
			}
			
return Right;
}

float4 Converter(float2 texcoord : TEXCOORD0)
{		
	float2 TCL, TCR, TexCoords = texcoord;
	float4 color, Right, Left;
	float DepthL, DepthR, N, S, X, L, R;
	float samplesA[9] = {0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1.0};
	
	//MS is Max Separation P is Perspective Adjustment
	float MS = GDepth * pix.x, P = Perspective * pix.x;
					
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

		float EX = GDepth*125.0, A = texcoord.y+EX*pix.y;
		A *= pix.x;
	
		[loop]
		for ( int x = 0 ; x < 9; x++ ) 
		{
			S = samplesA[x] * MS * 1.21875;
			L += Assist(float2(TCL.x+S, TCL.y)).x/9;
			R += Assist(float2(TCR.x-S, TCR.y)).x/9;
			DepthL = min(1,L);
			DepthR = min(1,R);
		}
		DepthL = DepthL * MS;
		DepthR = DepthR * MS;		
	
	float ReprojectionLeft =  DepthL;
	float ReprojectionRight = DepthR;


		Left = LeftI(float2((TCL.x + ReprojectionLeft) + A, TCL.y));
		Right = RightI(float2((TCR.x - ReprojectionRight)- A, TCR.y));
				
			if (Pulfrich_Effect_Assist == 1)
			{
				Left = LeftI(float2((TCL.x + ReprojectionLeft) + A, TCL.y));
			}
			else if (Pulfrich_Effect_Assist == 2)
			{
				Right = RightI(float2((TCR.x - ReprojectionRight)- A, TCR.y));
			}

float4 cL = Left,cR = Right; //Left Image & Right Image

	if ( Eye_Swap )
	{
		cL = Right;
		cR = Left;	
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
			color = TexCoords.x < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 1)
		{	
			color = TexCoords.y < 0.5 ? cL : cR;
		}
		else if(Stereoscopic_Mode == 2)
		{
			color = int(gridxy.y) & 1 ? cR : cL;	
		}
		else if(Stereoscopic_Mode == 3)
		{
			color = int(gridxy.x) & 1 ? cR : cL;		
		}
		else if(Stereoscopic_Mode == 4)
		{
			color = int(gridxy.x+gridxy.y) & 1 ? cR : cL;
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
				
				color =  (cA*LeftEyecolor) + (cB*RightEyecolor);
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

			color = float4(red, green, blue, 0);
			}
			else if (Anaglyph_Colors == 2)
			{
				float4 LeftEyecolor = float4(0.0,1.0,0.0,1.0);
				float4 RightEyecolor = float4(1.0,0.0,1.0,1.0);
				
				color =  (cA*LeftEyecolor) + (cB*RightEyecolor);			
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
					
			color = float4(red, green, blue, 0);
			}
		}
	
		if(Debug_View)
		color.rgb = tex2D(SamplerBF,texcoord).xxx;

	return float4(color.rgb,1);
}

void Current_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{	 	
	color = tex2D(BackBuffer,texcoord);
}

void Past_BackBuffer(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 PastSingle : SV_Target)
{	
	PastSingle = tex2D(CBackBuffer,texcoord);
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
			pass CBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Current_BackBuffer;
			RenderTarget = CurrentBB;
		}
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
			RenderTarget = texBl;
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
			pass PBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BackBuffer;
			RenderTarget = PastSingleBB;	
		}
}
