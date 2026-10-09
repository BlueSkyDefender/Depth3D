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
 //* Port/Modified to ReShadeFX by Jose Negrete AKA BlueSkyDefender - http://www.Depth3D.info
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
 //* Update: I found a more human readable version here. 
 //*         https://github.com/kosua20/Rendu/blob/master/resources/common/shaders/screens/fxaa.frag
 //*         At this point I will be branching this to DXAA. Since AXAA Is nice and all. I just like
 //*         my own port that is all.
 //*																																												
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if __RENDERER__ >= 0x10000 && __RENDERER__ < 0x20000 //This was added due to not compiling on AMD OpenGL
	#define OpenGL_Switch 1
#else
	#define OpenGL_Switch 0
#endif

#if __RESHADE__ <= 60100 // This was added to fix compiling on old ReShade versions
	#define ReShade_Switch 1
#else
	#define ReShade_Switch 0
#endif

//////////////////////////////////////////////////////////Defines///////////////////////////////////////////////////////////////////
#define Pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define FXAA_EDGE_THRESHOLD      (1.0/8.0)  //Contrast check: the local contrast needed, relative to the brightest tap.
#define FXAA_EDGE_THRESHOLD_MIN  (1.0/16.0) //Contrast check: and never under this, so dark areas are left alone.
#define AXAA_ALPHA               0.1        //Filtered region check: the band around rangeMid, as a share of the range.
#define AXAA_BETA                0.3        //Thin line check: both gradients over this keep the pixel as it is.
#define AXAA_SUBPIX_311          1          //1: FXAA 3.11 subpixel, one fetch shifted toward the edge. 0: FXAA 1's 3x3 box blend.
#define AXAA_COLOR_EDGES         1          //1: luma is half brightest channel, half Rec.601, so equal brightness colour edges count.
#define AXAA_RELATIVE            1          //1: thin line and search limits scale with the local brightest tap (dark scenes).
#define AXAA_SOFT                1          //1: the exits fade in and out instead of switching, so moving edges crawl less.
#define AXAA_FOLIAGE             0.75      //Foliage guard: how much of the AA busy texture loses (0 off, 1 all of it).
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
//A lot of the helper functions stuff is not needed in ReShade.
float Max3_AXAA(float3 RGB)
{
	return max(RGB.r, max(RGB.g, RGB.b));
}
//The luma every test reads: the brightest of the channels W picks. HDR (scRGB, 1.0 is 80 nits) is compressed into
//0 to 1 by l / (1 + l), so the thresholds tuned for SDR mean the same thing there. Dark values barely change.
//Colour edges: the brightest channel alone cannot tell red from green at the same brightness, Rec.601 luma can. Half
//of each keeps grey edges as they were (both agree on grey) and lets colour edges in.
float AXAA_Luma(float3 RGB, float3 W, bool HDR_Mode)
{
	float L = max(Max3_AXAA(RGB * W), 0.0);
	#if AXAA_COLOR_EDGES
	const float3 Rec601 = float3(0.299, 0.587, 0.114);
	L = 0.5 * (L + max(dot(RGB * W, Rec601) * rcp(dot(W, Rec601)), 0.0));
	#endif
	return HDR_Mode ? L * rcp(1.0 + L) : L;
}

float4 FxaaTexGrad(sampler tex, float2 pos, float2 grad)
{
	#if ReShade_Switch
    float lod = log2(max(length(grad) * 512.0, 1e-6)); // approximate LOD
    return tex2Dlod(tex, float4(pos, 0, lod));
    #else
    return tex2Dgrad(tex, pos.xy, grad, grad);
	#endif
}

float4 FxaaTexLod(sampler tex, float2 pos)
{
    return tex2Dlod(tex, float4(pos.xy, 0.0,0));
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//sRGB encode, for the linear light fetch below.
float3 AXAA_sRGB(float3 C)
{
	C = saturate(C);
	return C <= 0.0031308 ? C * 12.92 : 1.055 * pow(C, 1.0 / 2.4) - 0.055;
}

//W picks the channels the edge search looks at (luma is the max of rgb * W). SuperDepth3D's anaglyph runs it once
//per eye, on that eye's channels: across both eyes the parallax offset reads as false edges.
//texF is the sampler for the one final fetch. Linear_F true means texF decodes sRGB (SRGBTexture = true on an 8 bit back
//buffer): the bilinear blend across the edge then happens in linear light, so light and dark edges and thin bright
//lines keep their brightness, and the result is encoded back here. Free, it is only a sampler state.
float4 AXAA_W(sampler tex,sampler texF,float2 texcoord,bool HDR_Mode,float3 W,bool Linear_F)
{
    //SEARCH MAP
    float3 rgbN = FxaaTexOff(tex, texcoord, int2( 0,-1)).xyz;
    float3 rgbW = FxaaTexOff(tex, texcoord, int2(-1, 0)).xyz;
    float3 rgbM = FxaaTexOff(tex, texcoord, int2( 0, 0)).xyz;
    float3 rgbE = FxaaTexOff(tex, texcoord, int2( 1, 0)).xyz;
    float3 rgbS = FxaaTexOff(tex, texcoord, int2( 0, 1)).xyz;
    float lumaN = AXAA_Luma(rgbN, W, HDR_Mode);
    float lumaW = AXAA_Luma(rgbW, W, HDR_Mode);
    float lumaM = AXAA_Luma(rgbM, W, HDR_Mode);
    float lumaE = AXAA_Luma(rgbE, W, HDR_Mode);
    float lumaS = AXAA_Luma(rgbS, W, HDR_Mode);
    float rangeMin = min(lumaM, min(min(lumaN, lumaW), min(lumaS, lumaE)));
    float rangeMax = max(lumaM, max(max(lumaN, lumaW), max(lumaS, lumaE)));
    float range = rangeMax - rangeMin;
    
	// CONTRAST CHECK (FXAA): too little local contrast, nothing to anti-alias. EXIT
	// Soft: an edge moving by a pixel crosses these limits from frame to frame, and a hard on/off made it pop (crawl).
	// AA_Fade eases the result in over a band around each limit instead. Fully off or fully on still exits or runs as before.
	float Th = max(FXAA_EDGE_THRESHOLD_MIN, rangeMax * FXAA_EDGE_THRESHOLD);
	#if AXAA_SOFT
	if (range < Th * 0.75)
	    return float4(rgbM.rgb,lumaM);
	float AA_Fade = saturate((range - Th * 0.75) * rcp(Th * 0.5));
	#else
	if (range < Th)
	    return float4(rgbM.rgb,lumaM);
	float AA_Fade = 1.0;
	#endif

	// FILTERED REGION CHECK (AXAA): already filtered pixels blend their neighbours, so M or one of its neighbours sits
	// in rangeMid ± alpha. A raw edge only has the two sides' values. EXIT
	float rangeMid = 0.5 * (rangeMin + rangeMax);
	float alpha = AXAA_ALPHA * range; // Alpha is 10% of the luma range
	float4 NWES = abs(float4(lumaN, lumaW, lumaE, lumaS) - rangeMid);
	float Mid_D = min(abs(lumaM - rangeMid), min(min(NWES.x, NWES.y), min(NWES.z, NWES.w)));
	#if AXAA_SOFT
	if (Mid_D <= alpha * 0.5)
	    return float4(rgbM.rgb,lumaM);
	AA_Fade *= saturate((Mid_D - alpha * 0.5) * rcp(alpha));
	#else
	if (Mid_D <= alpha)
	    return float4(rgbM.rgb,lumaM);
	#endif

    float3 rgbL = rgbN + rgbW + rgbM + rgbE + rgbS;

    //COMPUTE LOWPASS
    #if FXAA_SUBPIX != 0
        float lumaL = (lumaN + lumaW + lumaE + lumaS) * 0.25;
        float rangeL = abs(lumaL - lumaM);
    #endif

    #if FXAA_SUBPIX == 1
        //One divide by the range, in SDR and HDR alike. The contrast check above keeps range over zero.
        float blendL = max(0.0,
            (rangeL / range) - FXAA_SUBPIX_TRIM) * FXAA_SUBPIX_TRIM_SCALE;
        blendL = min(FXAA_SUBPIX_CAP, blendL);
    #endif
    
    //CHOOSE VERTICAL OR HORIZONTALS SEARCH
    float3 rgbNW = FxaaTexOff(tex, texcoord, int2(-1,-1)).xyz;
    float3 rgbNE = FxaaTexOff(tex, texcoord, int2( 1,-1)).xyz;
    float3 rgbSW = FxaaTexOff(tex, texcoord, int2(-1, 1)).xyz;
    float3 rgbSE = FxaaTexOff(tex, texcoord, int2( 1, 1)).xyz;
    #if (FXAA_SUBPIX_FASTER == 0) && (FXAA_SUBPIX > 0)
        rgbL += (rgbNW + rgbNE + rgbSW + rgbSE);
        rgbL *= 1.0 / 9.0;
    #endif
    float lumaNW = AXAA_Luma(rgbNW, W, HDR_Mode);
    float lumaNE = AXAA_Luma(rgbNE, W, HDR_Mode);
    float lumaSW = AXAA_Luma(rgbSW, W, HDR_Mode);
    float lumaSE = AXAA_Luma(rgbSE, W, HDR_Mode);
    #if AXAA_SUBPIX_311
    //FXAA 3.11 subpixel amount: how far M sits from the weighted 3x3 average (straight neighbours count twice), as a
    //share of the range, eased and squared. Read here, before N and S are reused for the edge.
    float subpixC = saturate(abs(((lumaN + lumaS + lumaW + lumaE) * 2.0 + (lumaNW + lumaNE + lumaSW + lumaSE)) * (1.0 / 12.0) - lumaM) / range);
    float subpixF = (-2.0 * subpixC + 3.0) * subpixC * subpixC;
    float subpixH = subpixF * subpixF * FXAA_SUBPIX_CAP;
    #endif
    float edgeVert =
			        abs((0.25 * lumaNW) + (-0.5 * lumaN) + (0.25 * lumaNE)) +
			        abs((0.50 * lumaW) + (-1.0 * lumaM) + (0.50 * lumaE)) +
			        abs((0.25 * lumaSW) + (-0.5 * lumaS) + (0.25 * lumaSE));
    float edgeHorz =
			        abs((0.25 * lumaNW) + (-0.5 * lumaW) + (0.25 * lumaSW)) +
			        abs((0.50 * lumaN) + (-1.0 * lumaM) + (0.50 * lumaS)) +
			        abs((0.25 * lumaNE) + (-0.5 * lumaE) + (0.25 * lumaSE));
    // FOLIAGE GUARD: a real edge is strong in one direction only, min(edgeVert, edgeHorz) / range is 0 for a straight edge
    // and 0.25 for a 45 degree one. Leaves, grass and other busy texture flip in both directions: a lone speck is 1.0, a
    // checkerboard 2.0. Fading the AA out from 0.5 to 1.0 keeps their detail and leaves edges and diagonals as they were.
    // Silhouettes against the sky are clean edges, so leaf outlines still get smoothed.
    float Clutter = min(edgeVert, edgeHorz) * rcp(range);
    AA_Fade *= 1.0 - smoothstep(0.5, 1.0, Clutter) * AXAA_FOLIAGE;
    if (AA_Fade <= 0.0)
        return float4(rgbM.rgb,lumaM);
    bool horzSpan = edgeHorz >= edgeVert;
    float lengthSign = horzSpan ? -Pix.y : -Pix.x;
    if (!horzSpan)
    {
        lumaN = lumaW;
        lumaS = lumaE;
    }
    
    float gradientN = abs(lumaN - lumaM);
    float gradientS = abs(lumaS - lumaM);

	// THIN LINE CHECK (AXAA): steep on both sides is a one pixel line. The bilinear fetch and the 3x3 lowpass would
	// both blend it into its neighbours, so keep the pixel. EXIT
	// Relative: in dark scenes real lines rarely reach 0.3, so the limit scales with the brightest tap (floor 0.25).
	#if AXAA_RELATIVE
	float Lum_Scale = max(rangeMax, 0.25);
	#else
	float Lum_Scale = 1.0;
	#endif
	float thinT = AXAA_BETA * Lum_Scale, thinG = min(gradientN, gradientS);
	#if AXAA_SOFT
	if (thinG > thinT * 1.15)
	    return float4(rgbM.rgb,lumaM);
	AA_Fade *= saturate((thinT * 1.15 - thinG) * rcp(thinT * 0.3));
	#else
	if (thinG > thinT)
	    return float4(rgbM.rgb,lumaM);
	#endif

    lumaN = (lumaN + lumaM) * 0.5;
    lumaS = (lumaS + lumaM) * 0.5;
	// ADAPTIVE SEARCH RANGE (AXAA): dmin and dmax are M against the min and max luma of the whole 3x3.
	float minLuma = min(min(rangeMin, min(lumaNW, lumaNE)), min(lumaSW, lumaSE));
	float maxLuma = max(max(rangeMax, max(lumaNW, lumaNE)), max(lumaSW, lumaSE));
	float dmin = lumaM - minLuma;
	float dmax = maxLuma - lumaM;
	// Low contrast all round, max(dmin, dmax) <= 0.1, gets 1 iteration. Above that the full search runs, which covers
	// the poster's "2+ iterations" (min > 0.1) and "3+ iterations" (min > 0.3): those are the least it may take.
	int searchIterations = max(dmin, dmax) <= 0.1 * Lum_Scale ? 1 : FXAA_SEARCH_STEPS;
	
	// CHOOSE SIDE OF PIXEL WHERE GRADIENT IS HIGHEST
	bool pairN = gradientN >= gradientS;
	if (!pairN)
	{
	    lumaN = lumaS;
	    gradientN = gradientS;
	    lengthSign *= -1.0;
	}
	
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
	        lumaEndN = AXAA_Luma(FxaaTexLod(tex, posN.xy).xyz, W, HDR_Mode);
	    if (!doneP)
	        lumaEndP = AXAA_Luma(FxaaTexLod(tex, posP.xy).xyz, W, HDR_Mode);
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
	float Normal = lengthSign;
	if (((lumaM - lumaN) < 0.0) == ((lumaEndN - lumaN) < 0.0))
	    lengthSign = 0.0;

	float spanLength = (dstP + dstN);
	dstN = directionN ? dstN : dstP;
	float subPixelOffset = (0.5 + (dstN * (-1.0 / spanLength))) * lengthSign;
	#if AXAA_SUBPIX_311
	// SUBPIXEL (FXAA 3.11): no box blur. One fetch, shifted across the edge by the larger of the edge offset (0 where
	// the span gets no filtering) and the subpixel amount. Keeps texture and edges sharper than the 3x3 average.
	subPixelOffset = max(subPixelOffset * rcp(Normal), subpixH) * Normal;
	#endif
	float3 rgbF = FxaaTexLod(texF, float2(
                                            texcoord.x + (horzSpan ? 0.0 : subPixelOffset),
                                            texcoord.y + (horzSpan ? subPixelOffset : 0.0))).xyz;
	if (Linear_F)
	    rgbF = AXAA_sRGB(rgbF);
	#if !AXAA_SUBPIX_311
	// SUBPIXEL BLENDING (FXAA): FxaaLerp3(rgbL, rgbF, blendL), the lowpass weighted by blendL, on all three channels.
	rgbF = lerp(rgbF.rgb, rgbL.rgb, blendL);
	#endif
	return float4(lerp(rgbM.rgb, rgbF.rgb, AA_Fade), lumaM);
}

float4 AXAA(sampler tex,float2 texcoord,bool HDR_Mode)
{
	return AXAA_W(tex, tex, texcoord, HDR_Mode, 1.0, false);
}
