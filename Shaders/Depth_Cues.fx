 ////---------------------//
 ///**Cues Unsharp Mask**///
 //---------------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Based Unsharp Mask effect                                  																													*//
 //* For Reshade 3.0+																																								*//
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

uniform float Shade_Power <	
	ui_type = "drag";
	ui_min = 0.5; ui_max = 1.0;	
	ui_label = "Shade Power";	
	ui_tooltip = "Adjust the Shade Power This improves AO, Shadows, & Darker Areas in game.\n"	
				 "Number 0.75 is default.";
> = 0.75;

uniform float Blur_Cues <	
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;	
	ui_label = "Blur Shade";	
	ui_tooltip = "Adjust the to make Shade Softer in the Image.\n"	
				 "Number 0.5 is default.";
> = 0.5;

uniform float Spread <
	ui_type = "drag";
	ui_min = 5; ui_max = 12.5; ui_step = 0.25;
	ui_label = "Shade Fill";
	ui_tooltip = "Adjust This to have the shade effect to fill in areas.\n"
				 "This is used for gap filling.\n"
				 "Number 7.5 is default.";
> = 7.5;

uniform bool Debug_View <
	ui_label = "Debug View";
	ui_tooltip = "To view Shade & Blur effect on the game, movie piture & ect.";
> = false;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

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
			
texture texB { Width = BUFFER_WIDTH * 0.5; Height = BUFFER_HEIGHT * 0.5; Format = RGBA8; };

sampler SamplerBlur
	{
		Texture = texB;
	};	
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void Blur(in float4 position : SV_Position, in float2 texcoords : TEXCOORD0, out float4 color : SV_Target)                                                                          
{
	float2 Adjust = (Spread * 0.75 ) * pix;
	float4 result = tex2D(BackBuffer,texcoords);	
	result += tex2D(BackBuffer,texcoords + float2( 1, 0) * Adjust );
	result += tex2D(BackBuffer,texcoords + float2(-1, 0) * Adjust );	
	result += tex2D(BackBuffer,texcoords + float2( 1, 0) * 0.25 * Adjust );
	result += tex2D(BackBuffer,texcoords + float2(-1, 0) * 0.25 * Adjust );	
	result += tex2D(BackBuffer,texcoords + float2( 1, 0) * 0.5 * Adjust );
	result += tex2D(BackBuffer,texcoords + float2(-1, 0) * 0.5 * Adjust );	
	result += tex2D(BackBuffer,texcoords + float2( 1, 0) * 0.75 * Adjust );
	result += tex2D(BackBuffer,texcoords + float2(-1, 0) * 0.75 * Adjust );	
	color = result / 9;
}

//Spread the blur a bit more. 
float4 Adjust(float2 texcoords)
{
float2 S = Spread * 0.1875f * pix;

	float4 result;
	result += tex2D(SamplerBlur,texcoords + float2( 1, 0) * S );
	result += tex2D(SamplerBlur,texcoords + float2( 0, 1) * S );
	result += tex2D(SamplerBlur,texcoords + float2(-1, 0) * S );
	result += tex2D(SamplerBlur,texcoords + float2( 0,-1) * S );
	S *= 0.75f;
	result += tex2D(SamplerBlur,texcoords + float2( 1, 1) * S );
	result += tex2D(SamplerBlur,texcoords + float2(-1,-1) * S );	
	result += tex2D(SamplerBlur,texcoords + float2( 1,-1) * S );
	result += tex2D(SamplerBlur,texcoords + float2(-1, 1) * S );	

return result / 8; 
}

float3 GS(float3 color)
{
    float grayscale = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
    color.r = grayscale;
    color.g = grayscale;
    color.b = grayscale;
	return clamp(color,0.003,1.0);//clamping to protect from over Dark.
}

float LI(float3 value)
{	
	return dot(value.rgb,float3(0.333, 0.333, 0.333)); 
}


float DepthCues(float2 texcoord)
{
	float3 RGB;	
	//Formula for Image Pop = Original + (Original / Blurred) * Amount.
	RGB = GS(tex2D(BackBuffer,texcoord).rgb) / GS( Adjust(texcoord).rgb );
		
	float Done = dot(RGB,float3(0.333, 0.333, 0.333));
	
	return saturate(Done);
}

float USM(float2 texcoord )
{
	float2 tex_offset = pix; // Gets texel offset
	float result =  DepthCues(texcoord);
		  result += DepthCues( float2(texcoord + float2( 1, 0) * tex_offset));
		  result += DepthCues( float2(texcoord + float2(-1, 0) * tex_offset));
		  result += DepthCues( float2(texcoord + float2( 0, 1) * tex_offset));
		  result += DepthCues( float2(texcoord + float2( 0, 1) * tex_offset));
		  tex_offset *= 0.75;		   
		  result += DepthCues( float2(texcoord + float2( 1, 1) * tex_offset));
		  result += DepthCues( float2(texcoord + float2(-1,-1) * tex_offset));
		  result += DepthCues( float2(texcoord + float2( 1,-1) * tex_offset));
		  result += DepthCues( float2(texcoord + float2(-1, 1) * tex_offset));

	return result/9;
}


float4 CuesOut(float2 texcoord : TEXCOORD0)
{		
	float4 Out, Debug_Done = saturate(lerp(1.0f,lerp(USM(texcoord).xxxx,DepthCues(texcoord).xxxx,1-Blur_Cues),Shade_Power)), Combine = tex2D(BackBuffer,texcoord) * Debug_Done;
	
if (!Debug_View)
		Out = Combine;
	else
		Out = Debug_Done;
			
	return Out;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >; //Please do not remove.
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y;	
	float4 Color = CuesOut(texcoord),D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
	[branch] if(timer <= 12500)
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
		float4 OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.775));
		float4 TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.680));
		float4 ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		P = (OneP-TwoP) + ThreeP;

		//T
		float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
		float4 OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
		float4 TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
		T = OneT+TwoT;
		
		//H
		float PosXH = -0.0072+PosX;
		float4 OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
		float4 TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
		float4 ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.00325,0.009));
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
		//Website
		return D+E+P+T+H+Three+DD+Dot+I+N+F+O ? 1-texcoord.y*50.0+48.35f : Color;
	}
	else
	{
		return Color;
	}
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
technique Monocular_Cues
{
		pass BlurFilter
	{
		VertexShader = PostProcessVS;
		PixelShader = Blur;
		RenderTarget = texB;
	}		
		pass CuesUnsharpMask
	{
		VertexShader = PostProcessVS;
		PixelShader = Out;	
	}
}
