////----------//
///**Trails**///
//----------////
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//* Trails                            																														
//* For Reshade 3.0																																								
//* --------------------------																																						
//* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																								
//* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																				
//* I would also love to hear about a project you are using it with.																												
//* https://creativecommons.org/licenses/by/3.0/us/																																
//*																																												
//* Have fun,																																										
//* Jose Negrete AKA BlueSkyDefender																																				
//*																																												
//* https://github.com/BlueSkyDefender/Depth3D																				
//* ---------------------------------																																				
//*																																												
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define PerColor 0 // Lets you adjust per Color Channel.Default 0 off

#if !PerColor
uniform float Persistence <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.00;
	ui_label = "Persistence";
	ui_tooltip = "Increase persistence longer the trail or afterimage.\n"
				"If pushed out the effect is alot like long exposure.\n"
				"This can be used for light painting in games.\n"
				"1000/1 is 1.0, so 1/2 is 0.5 and so forth.\n"
				"Default is 0.25, 0 is infinity.";
> = 0.25;
#else
uniform float3 Persistence <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.00;
	ui_label = "Persistence";
	ui_tooltip = "Increase persistence longer the trail or afterimage RGB.\n"
				"If pushed out the effect is alot like long exposure.\n"
				"This can be used for light painting in games.\n"
				"1000/1 is 1.0, so 1/2 is 0.5 and so forth.\n"
				"Default is 0.25, 0 is infinity.";
> = float3(0.25,0.25,0.25);
#endif

uniform float TQ <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Trail Quality";
	ui_tooltip = "Adjust Trail Quality";
> = 0.5;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture PBB  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; MipLevels = 1;}; 

sampler PBackBuffer
	{
		Texture = PBB;
	};
	
///////////////////////////////////////////////////////////TAA/////////////////////////////////////////////////////////////////////	
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define iResolution float2(BUFFER_WIDTH, BUFFER_HEIGHT)

uniform float frametime < source = "frametime"; >;

float3 T_Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{	
    float3 C = tex2D(BackBuffer, texcoord).rgb;

    C.rgb = tex2Dlod(PBackBuffer, float4(texcoord,0,TQ)).rgb;

    #if !PerColor
    float P = 1-Persistence;
    C *= P;
    #else
    float3 P = 1-Persistence;
	C = C * P; 
    #endif
    
    C = max( tex2D(BackBuffer, texcoord).rgb, C);

    return C;
}

void Past_BB(float4 position : SV_Position, float2 texcoord : TEXCOORD, out float4 Past : SV_Target)
{   float2 samples[12] = {
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
	  
	float4 sum = tex2D(BackBuffer,texcoord);  
	float Adjust = TQ*pix.x;
	for (int i = 0; i < 12; i++)
	{  
		sum += tex2D(BackBuffer, texcoord + Adjust * samples[i]);  
	} 
 
	Past = sum * 0.07692307;  
 
}

///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////
// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
technique Trails
	{
			pass Trails
		{
			VertexShader = PostProcessVS;
			PixelShader = T_Out;
		}
			pass PBB
		{
			VertexShader = PostProcessVS;
			PixelShader = Past_BB;
			RenderTarget = PBB;
			
		}
	}