// LICENSE
// =======
// Copyright (c) 2017-2019 Advanced Micro Devices, Inc. All rights reserved.
// -------
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// -------
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
// -------
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This is the practical limit for the algorithm's scaling ability (quality is limited by 3x3 taps). Example resolutions,
//  1280x720  -> 1080p = 2.25x area
//  1536x864  -> 1080p = 1.56x area
//  1792x1008 -> 1440p = 2.04x area
//  1920x1080 -> 1440p = 1.78x area
//  1920x1080 ->    4K =  4.0x area
//  2048x1152 -> 1440p = 1.56x area
//  2560x1440 ->    4K = 2.25x area
//  3072x1728 ->    4K = 1.56x area

// It is best to run CAS after tonemapping.

uniform float Sharpness <
	ui_type = "drag";
    ui_label = "Sharpening strength";
    ui_tooltip = "0 := no sharpening, to 1 := full sharpening.\nScaled by the sharpness knob while being transformed to a negative lobe (values at -1/5 * adjust)";
	ui_min = 0.0; ui_max = 1.0;
> = 0.5;

uniform bool CAS_BETTER_DIAGONALS <
	ui_label = "CAS Better Diagonals";
	ui_tooltip = "Instead of using the 3x3 'box' with the 5-tap 'circle' this uses just the 'circle'.";
> = false;

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
> = false;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
			
float3 Min3(float3 x, float3 y, float3 z)
{
    return min(x, min(y, z));
}

float3 Max3(float3 x, float3 y, float3 z)
{
    return max(x, max(y, z));
}

float3 CASPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{    
    // fetch a 3x3 neighborhood around the pixel 'e',
    //  a b c
    //  d(e)f
    //  g h i
 
     //Unsharp
    float3 a = tex2D(BackBuffer, texcoord + float2(-pix.x, -pix.y)).rgb;
    float3 b = tex2D(BackBuffer, texcoord + float2(0.0, -pix.y)).rgb;
    float3 c = tex2D(BackBuffer, texcoord + float2(pix.x, -pix.y)).rgb;
    float3 d = tex2D(BackBuffer, texcoord + float2(-pix.x, 0.0)).rgb;
    float3 e = tex2D(BackBuffer, texcoord).rgb;
    float3 f = tex2D(BackBuffer, texcoord + float2(pix.x, 0.0)).rgb;
    float3 g = tex2D(BackBuffer, texcoord + float2(-pix.x, pix.y)).rgb;
    float3 h = tex2D(BackBuffer, texcoord + float2(0.0, pix.y)).rgb;
    float3 i = tex2D(BackBuffer, texcoord + float2(pix.x, pix.y)).rgb;
  
	// Soft min and max.
	//  a b c             b
	//  d e f * 0.5  +  d e f * 0.5
	//  g h i             h
    // These are 2.0x bigger (factored out the extra multiply).
    float3 mnRGB2, mnRGB = Min3( Min3(d.rgb, e.rgb, f.rgb), b.rgb, h.rgb);
	
	if( CAS_BETTER_DIAGONALS)
    {
		mnRGB2 = Min3( Min3(mnRGB, a.rgb, c.rgb), g.rgb, i.rgb);
		mnRGB += mnRGB2;
	}
    
    float3 mxRGB2, mxRGB = Max3( Max3(d.rgb, e.rgb, f.rgb), b.rgb, h.rgb);
    
    if( CAS_BETTER_DIAGONALS )
    {
		mxRGB2 = Max3( Max3(mxRGB, a.rgb, c.rgb), g.rgb, i.rgb);  
		mxRGB += mxRGB2;
    }
    
    // Smooth minimum distance to signal limit divided by smooth max.
    float3 ampRGB, rcpMRGB = rcp(mxRGB);

	if( CAS_BETTER_DIAGONALS)
		ampRGB = saturate(min(mnRGB, 2.0 - mxRGB) * rcpMRGB);
	else
		ampRGB = saturate(min(mnRGB, 1.0 - mxRGB) * rcpMRGB);
    
    // Shaping amount of sharpening.
    ampRGB = sqrt(ampRGB);
      
   // Filter shape.
   //  0 w 0
   //  w 1 w
   //  0 w 0  
   float peak = -rcp(5.) * saturate(Sharpness);
   
   float3 wRGB = ampRGB * peak;
     
   float3 rcpWeightRGB = rcp(1. + 4. * wRGB);
   
   float3 Done = saturate((b.rgb * wRGB + d.rgb * wRGB + f.rgb * wRGB + h.rgb * wRGB + e.rgb) * rcpWeightRGB);
   
   if (Debug_View)
		Done = ampRGB;
	
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

technique Constrast_Adaptive_Sharpening
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CASPass;
	}
}