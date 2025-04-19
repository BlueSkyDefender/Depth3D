 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* AXAA: Adaptive approXimate Anti-Aliasing
 //*	Jae-Ho Nah, Sunho Ki,  Yeongkyu Lim, Jinhong Park, and Chulho Shin
 //*	LG Electronics 
 //*
 //* FXAA: Fast approXimate anti-aliasing
 //*	Timothy Lottes
 //*	NVIDIA Corporation   
 //*                              																										 
 //* https://developer.download.nvidia.com/assets/gamedev/files/sdk/11/FXAA_WhitePaper.pdf
 //* https://nahjaeho.github.io/papers/SIG2016/SIG2016_AXAA.pdf
 //*
 //* ----------------------------------------------------------------------------------
 //* File:        es3-kepler\FXAA\assets\shaders/FXAA_Default.frag
 //* SDK Version: v3.00 
 //* Email:       gameworks@nvidia.com
 //* Site:        http://developer.nvidia.com/
 //*
 //* Copyright (c) 2014-2015, NVIDIA CORPORATION. All rights reserved.
 //*
 //* Redistribution and use in source and binary forms, with or without
 //* modification, are permitted provided that the following conditions
 //* are met:
 //*  * Redistributions of source code must retain the above copyright
 //*    notice, this list of conditions and the following disclaimer.
 //*  * Redistributions in binary form must reproduce the above copyright
 //*    notice, this list of conditions and the following disclaimer in the
 //*    documentation and/or other materials provided with the distribution.
 //*  * Neither the name of NVIDIA CORPORATION nor the names of its
 //*    contributors may be used to endorse or promote products derived
 //*    from this software without specific prior written permission.
 //*
 //* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
 //* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 //* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 //* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 //* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 //* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 //* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 //* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 //* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 //* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 //* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 //*
 //* ----------------------------------------------------------------------------------
 //*
 //* Port/Modified to ReShadeFX by Jose Negrete AKA BlueSkyDefender - Depth3D.info
 //*
 //* Notes:
 //* ----------------------------------------------------------------------------------
 //* Since there where no example shaders I had to follow the white paper from SIGGRAPH
 //* 2016 Talking about AXAA. I also had to port FXAA aswell to ReShadeFX. I didn't check 
 //* if ReShade already had a working FXAA. But,I am sure there already is one. Finding
 //* the licence was harder than porting the shader.
 //*
 //* - God what a pain
 //*																																												
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if __RENDERER__ >= 0x10000 && __RENDERER__ < 0x20000 //This was added due to not compiling on AMD OpenGL
	#define OpenGL_Switch 1
#else
	#define OpenGL_Switch 0
#endif
//////////////////////////////////////////////////////////Defines///////////////////////////////////////////////////////////////////
#define Pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
//#define FXAA_EDGE_THRESHOLD      (1.0/8.0)  // Replaced with AXAA early Return
//#define FXAA_EDGE_THRESHOLD_MIN  (1.0/24.0) // Replaced with AXAA early Return
#define FXAA_SEARCH_STEPS        32
#define FXAA_SEARCH_ACCELERATION 1
#define FXAA_SEARCH_THRESHOLD    (1.0/4.0)
#define FXAA_SUBPIX              1
#define FXAA_SUBPIX_FASTER       0
#define FXAA_SUBPIX_CAP          (3.0/4.0)
#define FXAA_SUBPIX_TRIM         (1.0/4.0)
#define FXAA_SUBPIX_TRIM_SCALE (1.0/(1.0 - FXAA_SUBPIX_TRIM))
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float4 FxaaTexOff(sampler tex, float2 pos, int2 off)
{
	#if OpenGL_Switch
	float2 texelSize = Pix;
	float2 uv = pos + float2(off) * texelSize;
	return tex2Dlod(tex, float4(uv, 0, 0));
	#else
    return tex2Dlod(tex, float4(pos.xy,0,0), off);
	#endif
}

float FxaaLuma(float3 rgb)
{
    return rgb.y * (0.587 / 0.299) + rgb.x;
}

float3 FxaaFilterReturn(float3 rgb)
{
    return rgb;
}

float4 FxaaTexGrad(sampler tex, float2 pos, float2 grad)
{
    return tex2Dgrad(tex, pos.xy, grad, grad);
}

float3 FxaaLerp3(float3 a, float3 b, float amountOfA)
{
    return (float3(-amountOfA,0,0) * b) +
        ((a * float3(amountOfA,0,0)) + b);
}

float4 FxaaTexLod(sampler tex, float2 pos)
{
    return tex2Dlod(tex, float4(pos.xy, 0.0,0));
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float4 AXAA(sampler tex,float2 texcoord)
{
    //SEARCH MAP
    float3 rgbN = FxaaTexOff(tex, texcoord, int2( 0,-1)).xyz;
    float3 rgbW = FxaaTexOff(tex, texcoord, int2(-1, 0)).xyz;
    float3 rgbM = FxaaTexOff(tex, texcoord, int2( 0, 0)).xyz;
    float3 rgbE = FxaaTexOff(tex, texcoord, int2( 1, 0)).xyz;
    float3 rgbS = FxaaTexOff(tex, texcoord, int2( 0, 1)).xyz;
    float lumaN = FxaaLuma(rgbN);
    float lumaW = FxaaLuma(rgbW);
    float lumaM = FxaaLuma(rgbM);
    float lumaE = FxaaLuma(rgbE);
    float lumaS = FxaaLuma(rgbS);
    float rangeMin = min(lumaM, min(min(lumaN, lumaW), min(lumaS, lumaE)));
    float rangeMax = max(lumaM, max(max(lumaN, lumaW), max(lumaS, lumaE)));
    float range = rangeMax - rangeMin;
    
	float rangeMid = 0.5 * (rangeMin + rangeMax);
	float alpha = 0.1 * (rangeMax - rangeMin); // Alpha is 10% of the lum range

	// Check if current pix is in the rangeMid ± alpha and EXIT
	if (abs(lumaM - rangeMid) <= alpha)
	    return float4(FxaaFilterReturn(rgbM), 1.0f);
	    
	/* // FXAA old way of doing it
    if (range < max(FXAA_EDGE_THRESHOLD_MIN, rangeMax * FXAA_EDGE_THRESHOLD))
    {
        return float4(FxaaFilterReturn(rgbM), 1.0f);
    }
    */
    float3 rgbL = rgbN + rgbW + rgbM + rgbE + rgbS;
    
    //COMPUTE LOWPASS
    #if FXAA_SUBPIX != 0
        float lumaL = (lumaN + lumaW + lumaE + lumaS) * 0.25;
        float rangeL = abs(lumaL - lumaM);
    #endif
    #if FXAA_SUBPIX == 1
        float blendL = max(0.0,
            (rangeL / range) - FXAA_SUBPIX_TRIM) * FXAA_SUBPIX_TRIM_SCALE;
        blendL = min(FXAA_SUBPIX_CAP, blendL);
    #endif
    
    //CHOOSE VERTICAL OR HORIZONTAL SEARCH
    float3 rgbNW = FxaaTexOff(tex, texcoord, int2(-1,-1)).xyz;
    float3 rgbNE = FxaaTexOff(tex, texcoord, int2( 1,-1)).xyz;
    float3 rgbSW = FxaaTexOff(tex, texcoord, int2(-1, 1)).xyz;
    float3 rgbSE = FxaaTexOff(tex, texcoord, int2( 1, 1)).xyz;
    #if (FXAA_SUBPIX_FASTER == 0) && (FXAA_SUBPIX > 0)
        rgbL += (rgbNW + rgbNE + rgbSW + rgbSE);
        rgbL *= float3(1.0 / 9.0,0,0);
    #endif
    float lumaNW = FxaaLuma(rgbNW);
    float lumaNE = FxaaLuma(rgbNE);
    float lumaSW = FxaaLuma(rgbSW);
    float lumaSE = FxaaLuma(rgbSE);
    float edgeVert =
			        abs((0.25 * lumaNW) + (-0.5 * lumaN) + (0.25 * lumaNE)) +
			        abs((0.50 * lumaW) + (-1.0 * lumaM) + (0.50 * lumaE)) +
			        abs((0.25 * lumaSW) + (-0.5 * lumaS) + (0.25 * lumaSE));
    float edgeHorz =
			        abs((0.25 * lumaNW) + (-0.5 * lumaW) + (0.25 * lumaSW)) +
			        abs((0.50 * lumaN) + (-1.0 * lumaM) + (0.50 * lumaS)) +
			        abs((0.25 * lumaNE) + (-0.5 * lumaE) + (0.25 * lumaSE));
    bool horzSpan = edgeHorz >= edgeVert;
    float lengthSign = horzSpan ? -Pix.y : -Pix.x;
    if (!horzSpan)
        lumaN = lumaW;
    if (!horzSpan)
        lumaS = lumaE;
    float gradientN = abs(lumaN - lumaM);
    float gradientS = abs(lumaS - lumaM);
    lumaN = (lumaN + lumaM) * 0.5;
    lumaS = (lumaS + lumaM) * 0.5;
	// Compute dmin and dmax
	float minLuma = min(min(lumaN, lumaS), min(lumaW, lumaE));
	float maxLuma = max(max(lumaN, lumaS), max(lumaW, lumaE));
	float dmin = abs(lumaM - minLuma);
	float dmax = abs(lumaM - maxLuma);
	
	// Determine search iterations based on contrast
	int searchIterations = FXAA_SEARCH_STEPS; // Default maximum search I don't think I did this correct. But, it looks good. -_(o _ o)_-
	bool IterationsA = max(dmin, dmax) <= 0.1;//only 1 iteration
	bool IterationsB = min(dmin, dmax) > 0.1; //only 2+ iteration
	bool IterationsC = min(dmin, dmax) > 0.3; //only 3+ iteration
	
	if (IterationsA)
	    searchIterations = 1;
	if (IterationsB)
	    searchIterations = 2;
	if (IterationsC)
	    searchIterations = 3;
	
	// Contrast Conservation for Thin Lines
	if ((gradientN > 0.3) && (gradientS > 0.3)) 
	{
	    lengthSign = 0.0; // Prevents bilinear filtering
	}    
	
	// CHOOSE SIDE OF PIXEL WHERE GRADIENT IS HIGHEST
	bool pairN = gradientN >= gradientS;
	if (!pairN)
	    lumaN = lumaS;
	if (!pairN)
	    gradientN = gradientS;
	if (!pairN)
	    lengthSign *= -1.0;
	
	float2 posN;
	posN.x = texcoord.x + (horzSpan ? 0.0 : lengthSign * 0.5);
	posN.y = texcoord.y + (horzSpan ? lengthSign * 0.5 : 0.0);
	
	// CHOOSE SEARCH LIMITING VALUES
	gradientN *= FXAA_SEARCH_THRESHOLD;
	
	// SEARCH IN BOTH DIRECTIONS UNTIL FIND LUMA PAIR AVERAGE IS OUT OF RANGE
	float2 posP = posN;
	float2 offNP = horzSpan ?
						     float2(Pix.x, 0.0) :
						     float2(0.0f, Pix.y);
	float lumaEndN = lumaN;
	float lumaEndP = lumaN;
	bool doneN = false;
	bool doneP = false;
	
	#if FXAA_SEARCH_ACCELERATION == 1
	    posN += offNP * float2(-1.0, -1.0);
	    posP += offNP * float2(1.0, 1.0);
	#endif
	
	for (int i = 0; i < searchIterations; i++)  // Apply adaptive search range
	{
	#if FXAA_SEARCH_ACCELERATION == 1
	    if (!doneN)
	        lumaEndN = FxaaLuma(FxaaTexLod(tex, posN.xy).xyz);
	    if (!doneP)
	        lumaEndP = FxaaLuma(FxaaTexLod(tex, posP.xy).xyz);
	#endif
	    doneN = doneN || (abs(lumaEndN - lumaN) >= gradientN);
	    doneP = doneP || (abs(lumaEndP - lumaN) >= gradientN);
	    if (doneN && doneP)
	        break;
	    if (!doneN)
	        posN -= offNP;
	    if (!doneP)
	        posP += offNP;
	}
	
	// HANDLE IF CENTER IS ON POSITIVE OR NEGATIVE SIDE
	float dstN = horzSpan ? texcoord.x - posN.x : texcoord.y - posN.y;
	float dstP = horzSpan ? posP.x - texcoord.x : posP.y - texcoord.y;
	bool directionN = dstN < dstP;
	lumaEndN = directionN ? lumaEndN : lumaEndP;
	
	// CHECK IF PIXEL IS IN SECTION OF SPAN WHICH GETS NO FILTERING   
	if (((lumaM - lumaN) < 0.0) == ((lumaEndN - lumaN) < 0.0)) 
	    lengthSign = 0.0;
	
	float spanLength = (dstP + dstN);
	dstN = directionN ? dstN : dstP;
	float subPixelOffset = (0.5 + (dstN * (-1.0 / spanLength))) * lengthSign;
	float3 rgbF = FxaaTexLod(tex, float2(
                                            texcoord.x + (horzSpan ? 0.0 : subPixelOffset),
                                            texcoord.y + (horzSpan ? subPixelOffset : 0.0))).xyz;    

	return float4(FxaaFilterReturn(FxaaLerp3(rgbL, rgbF, blendL)), 1.0f);
}