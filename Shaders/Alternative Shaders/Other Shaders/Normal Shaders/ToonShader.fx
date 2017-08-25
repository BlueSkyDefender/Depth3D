 ////----------------------//
 ///**2D to 3D Converter**///
 //----------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Based Unsharp Mask                                      																													*//
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
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The resolution of the Bilateral Filtered Image. For 4k Use 2, 1.75 or 1.5. For 1440p Use 1.5, 1.375, or 1.25. For 1080p use 1.25, or 1.
#define Image_Division 1

uniform float2 X <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "X";
	ui_tooltip = "X";
> = float2(0,0);

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float3x3 sx = float3x3( 
    float3(1.0, 2.0, 1.0), 
    float3(0.0, 0.0, 0.0), 
   float3(-1.0, -2.0, -1.0) 
);
float3x3 sy = float3x3( 
    float3(1.0, 0.0, -1.0), 
    float3(2.0, 0.0, -2.0), 
    float3(1.0, 0.0, -1.0) 
);


    float3 diffuse = tex2D(BackBuffer, texcoord).rgb;
    float3x3 I;
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            float3 sam  = tex2D(BackBuffer, texcoord + float2(i-1,j-1) * (X.x*pix.x) ).rgb;
            I[i][j] = length(sam); 
    }
}

float gx = dot(sx[0], I[0]) + dot(sx[1], I[1]) + dot(sx[2], I[2]); 
float gy = dot(sy[0], I[0]) + dot(sy[1], I[1]) + dot(sy[2], I[2]);

float g = sqrt(pow(gx, 2.0)+pow(gy, 2.0));
return float4(diffuse - float3(g.rrr), 1.0);
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

technique Toon_Shader
{			
			pass UnsharpMask
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}