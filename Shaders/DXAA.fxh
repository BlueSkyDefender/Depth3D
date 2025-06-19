////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* DXAA: Directionally approXimate Anti-Aliasing
//*	Jose Negrete
//*	Depth3D 
//*
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
//* Read the AXAA header file for more information
//* This DXAA is a heavy modification of AXAA the goal was to make it faster with minimal quality loss.
//*
//* Update: TBD 
//*
//////////////////////////////////////////////////////////Defines///////////////////////////////////////////////////////////////////
#define PIX float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define SEARCH_STEPS        32	
#define SUBPIX_TRIM         (1.0/4.0)
#define SUBPIX_TRIM_SCALE (1.0/(1.0 - SUBPIX_TRIM))	
#define SUBPIX_CAP          (3.0/4.0)	
#define SEARCH_THRESHOLD    (1.0/4.0)	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float3 LerpR(float3 a, float3 b, float amountOfA)	
{
    return float3( a.r * amountOfA + b.r * (1.0 - amountOfA),  // lerp red channel
				   b.g,                                        // keep green from b
				   b.b                                       );// keep blue from b
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void DXAA_Info(in sampler Tex, in float2 TC, inout float Edge, inout float4 HV_Info, inout float4 CardinalMix, inout float4 IntercardinalMix, inout float4 ColorCenter, inout float4 LumDir, inout float2 HV_Edge_Info, inout float Debug)
{
    float4 Center    = tex2D(Tex, TC);
    //Cardinal Directions
    float4 Up        = tex2D(Tex, TC - float2(0, PIX.y));//N
    float4 Down      = tex2D(Tex, TC + float2(0, PIX.y));//S
    float4 Right     = tex2D(Tex, TC + float2(PIX.x, 0));//E
    float4 Left      = tex2D(Tex, TC - float2(PIX.x, 0));//W
	//Intercardinal Directions
    float4 UpLeft    = tex2D(Tex, TC - float2( PIX.x, PIX.y) );//NW
    float4 UpRight   = tex2D(Tex, TC + float2( PIX.x,-PIX.y) );//NE
    float4 DownLeft  = tex2D(Tex, TC + float2(-PIX.x, PIX.y) );//SW
    float4 DownRight = tex2D(Tex, TC + float2( PIX.x, PIX.y) );//SE  
    
	float RangeMin = min(Center.w, min(min(Up.w, Left.w), min(Down.w, Right.w)));
	float RangeMax = max(Center.w, max(max(Up.w, Left.w), max(Down.w, Right.w)));
	float RangeMid = 0.5 * (RangeMin + RangeMax);
	float Alpha = 0.1 * (RangeMax - RangeMin); // Alpha is 10% of the luma range	
	float2 Directions = float2(Down.w - Up.w, Right.w - Left.w);      		
	// Vertical edge detection using horizontal variation
    float combH = Left.w + Right.w;
    float Vert = abs(combH - 2.0 * Center.w);
    // Horizontal edge detection using Vertical variation
    float combV = Up.w + Down.w;
    float Horz = abs(combV - 2.0 * Center.w);
	
	bool HorzSpan = Horz >= Vert;
	
	float lengthSign = HorzSpan ? -Pix.y : -Pix.x;

    //Range
    Edge = length(Directions);
    //Directions 
    HV_Info = float4(float2(0,0),RangeMid,Alpha);
	CardinalMix = Up + Left + Right + Down;
	IntercardinalMix = UpLeft + UpRight + DownLeft + DownRight;
	ColorCenter = Center;
	LumDir = float4(Up.w,Down.w,Left.w,Right.w);
	HV_Edge_Info = float2(HorzSpan,lengthSign);
	
	Debug = 0;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float4 DXAA(sampler tex,float2 texcoord)
{
	float Range, Debug;
	float2 HorzSpan_LengthSign;
	float4 Dir_RangeMid_Alpha, ColorMix, IColorMix, ColorCenter, LumDir;//Up | Down |Left | Right;
	DXAA_Info(tex, texcoord, Range, Dir_RangeMid_Alpha, ColorMix, IColorMix, ColorCenter, LumDir, HorzSpan_LengthSign, Debug );
	// Check if current pix is in the rangeMid ± Alpha and EXIT
	if (abs(ColorCenter.w - Dir_RangeMid_Alpha.z) <= Dir_RangeMid_Alpha.w)
	    return float4(ColorCenter.rgb, 1.0f);		   
	//+ Dir_RangeMid_Alpha.xy * Pix // future modifications to catch small issues incoming
	//Color Mix
	float4 cMix = ColorMix;
	//Subpix
	float Luma = cMix.w;
	float RangeLuma = abs(Luma - ColorCenter.w);
	//Blending
	float BlendL = max(0.0, (RangeLuma / Range) - SUBPIX_TRIM) * SUBPIX_TRIM_SCALE;		
	BlendL = min(SUBPIX_CAP, BlendL);		
	//Final Mix
	cMix += ColorCenter;
	cMix += IColorMix;
	cMix *= float3(1.0 / 9.0,0,0);//Why is the old code only the Red Channel

	if (!HorzSpan_LengthSign.x)
	{
		LumDir.x = LumDir.z; // Up = Left
		LumDir.y = LumDir.w; // Down = Right
	}
	
	float gradN = abs(LumDir.x - ColorCenter.w);
	float gradS = abs(LumDir.y - ColorCenter.w);
	LumDir.x = (LumDir.x + ColorCenter.w) * 0.5;
	LumDir.y = (LumDir.y + ColorCenter.w) * 0.5;
	
	// Compute Dmin and Dmax
	float minL = min(min(LumDir.x, LumDir.y), min(LumDir.z, LumDir.w));
	float maxL = max(max(LumDir.x, LumDir.y), max(LumDir.z, LumDir.w));
	float Dmin = abs(ColorCenter.w - minL);
	float Dmax = abs(ColorCenter.w - maxL);			

	// Determine search iterations based on contrast
	int sIterations = SEARCH_STEPS;
	bool Iterations_A = max(Dmin, Dmax) <= 0.1; //only 1 iteration
	bool Iterations_B = min(Dmin, Dmax) >  0.1; //only 2+ iteration
	bool Iterations_C = min(Dmin, Dmax) >  0.3; //only 3+ iteration
	
	if (Iterations_A)
	    sIterations = 1;
	if (Iterations_B)
	    sIterations = 2;
	if (Iterations_C)
	    sIterations = 3;
	    
	// Contrast Conservation for Thin Lines
	if (gradN > 0.3 && gradS > 0.3) 
	{
	    HorzSpan_LengthSign.y = 0.0; // Prevents bilinear filtering
	} 		

	// CHOOSE SIDE OF PIXEL WHERE GRADIENT IS HIGHEST
	if (gradN <= gradS)
	{
	    LumDir.x = LumDir.y;
	    gradN = gradS;
	    HorzSpan_LengthSign.y *= -1.0;
	}
	
	float2 PosN;
	PosN.x = texcoord.x + (HorzSpan_LengthSign.x ? 0.0 : HorzSpan_LengthSign.y * 0.5);
	PosN.y = texcoord.y + (HorzSpan_LengthSign.x ? HorzSpan_LengthSign.y * 0.5 : 0.0);
	
	// CHOOSE SEARCH LIMITING VALUES
	gradN *= SEARCH_THRESHOLD;
	
	// SEARCH IN BOTH DIRECTIONS UNTIL FIND LUMA PAIR AVERAGE IS OUT OF RANGE
	float2 PosP = PosN;
	float2 OffNP = HorzSpan_LengthSign.x ? float2(Pix.x, 0.0) :
										   float2(0.0f, Pix.y);
									    
	float LumaEndN = LumDir.x, LumaEndP = LumDir.x;
	bool DoneN = false, DoneP = false;
	
    PosN += OffNP * float2(-1.0, -1.0);
    PosP += OffNP * float2(1.0, 1.0);

	for (int i = 0; i < sIterations; i++)  // Apply adaptive search range
	{
	    if (!DoneN)
	        LumaEndN = tex2Dlod(tex,float4(PosN.xy,0,0)).w;
	    if (!DoneP)
	        LumaEndP = tex2Dlod(tex,float4(PosP.xy,0,0)).w;

	    DoneN = DoneN || (abs(LumaEndN - LumDir.x) >= gradN);
	    DoneP = DoneP || (abs(LumaEndP - LumDir.x) >= gradN);
	    
	    if (DoneN && DoneP)
	        break;
	    if (!DoneN)
	        PosN -= OffNP;
	    if (!DoneP)
	        PosP += OffNP;
	}
	
	// HANDLE IF CENTER IS ON POSITIVE OR NEGATIVE SIDE
	float DstN = HorzSpan_LengthSign.x ? texcoord.x - PosN.x : texcoord.y - PosN.y;
	float DstP = HorzSpan_LengthSign.x ? PosP.x - texcoord.x : PosP.y - texcoord.y;
	bool DirectionN = DstN < DstP;
	LumaEndN = DirectionN ? LumaEndN : LumaEndP;

	// CHECK IF PIXEL IS IN SECTION OF SPAN WHICH GETS NO FILTERING   
	if (((ColorCenter.w - LumDir.x) < 0.0) == ((LumaEndN - LumDir.x) < 0.0)) 
	    HorzSpan_LengthSign.y = 0.0;
	
	float SpanLength = DstP + DstN;
	DstN = DirectionN ? DstN : DstP;
	float SubPixelOffset = (0.5 + (DstN * (-1.0 / SpanLength))) * HorzSpan_LengthSign.y;
	float3 RGBF = tex2Dlod(tex, float4(float2( texcoord.x + (HorzSpan_LengthSign.x ? 0.0 : SubPixelOffset),
											   texcoord.y + (HorzSpan_LengthSign.x ? SubPixelOffset : 0.0) )  ,0,0)).xyz;
	
	return float4(LerpR(cMix.rgb,RGBF,BlendL),1.0);//Debug;
}