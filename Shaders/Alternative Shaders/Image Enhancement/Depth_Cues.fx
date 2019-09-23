 ////---------------//
 ///**Depth Cues**///
 //---------------////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Depth Based Unsharp Mask Bilateral Contrast Adaptive Sharpening                                     																										
// For Reshade 3.0+																																					
// --------------------------																																			
// Have fun,																																								
// Jose Negrete AKA BlueSkyDefender																																		
// 																																											
// https://github.com/BlueSkyDefender/Depth3D																	
//  ---------------------------------																																	                                                                                                        																	                                                      
//                                                       Depth Cues
//                                Extra Information for where I got the Idea for Depth Cues.
//                             https://www.uni-konstanz.de/mmsp/pubsys/publishedFiles/LuCoDe06.pdf	
//																
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Automatic Blur Adjustment based on Resolutionsup to 8k considered.
#if (BUFFER_HEIGHT <= 720)
	#define Multi 0.5
#elif (BUFFER_HEIGHT <= 1080)
	#define Multi 1.0
#elif (BUFFER_HEIGHT <= 1440)
	#define Multi 1.5
#elif (BUFFER_HEIGHT <= 2160)
	#define Multi 2
#else
	#define Quality 2.5
#endif

// It is best to run Smart Sharp after tonemapping.

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = "Normal\0Reverse\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
	ui_category = "Depth Buffer";
> = 0;

uniform float Depth_Map_Adjust <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 1.0; ui_max = 1000.0; ui_step = 0.125;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map and sharpness distance.";
	ui_category = "Depth Buffer";
> = 250.0;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
	ui_category = "Depth Buffer";
> = false;

uniform bool DEPTH_DEBUG <
	ui_label = "View Depth";
	ui_tooltip = "Shows depth, you want close objects to be black and far objects to be white for things to work properly.";
	ui_category = "Depth Buffer";	
> = false;

uniform bool No_Depth_Map <
	ui_label = "No Depth Map";
	ui_tooltip = "If you have No Depth Buffer turn this On.";
	ui_category = "Depth Buffer";
> = false;

uniform float Shade_Power <	
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.25; ui_max = 1.0;	
	ui_label = "Shade Power";	
	ui_tooltip = "Adjust the Shade Power This improves AO, Shadows, & Darker Areas in game.\n"	
				 "Number 0.625 is default.";
	ui_category = "Depth Cues";
> = 0.625;

uniform float Blur_Cues <	
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 1.0;	
	ui_label = "Blur Shade";	
	ui_tooltip = "Adjust the to make Shade Softer in the Image.\n"	
				 "Number 0.5 is default.";
	ui_category = "Depth Cues";
> = 0.5;

uniform float Spread <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 1.0; ui_max = 25.0; ui_step = 0.25;
	ui_label = "Shade Fill";
	ui_tooltip = "Adjust This to have the shade effect to fill in areas gives fakeAO effect.\n"
				 "This is used for gap filling.\n"
				 "Number 7.5 is default.";
	ui_category = "Depth Cues";
> = 12.5;

uniform bool Debug_View <
	ui_label = "Depth Cues Debug";
	ui_tooltip = "Depth Cues Debug output the shadeded output.";
	ui_category = "Depth Cues";
> = false;
/*
uniform bool Fake_AO <
	ui_label = "Fake AO";
	ui_tooltip = "Fake AO only works when you Have Depth Buffer Access.";
	ui_category = "Fake AO";
> = false;

uniform float Fake_AO_Adjust <
	#if Compatibility
	ui_type = "drag";
	#else
	ui_type = "slider";
	#endif
	ui_min = 0.0; ui_max = 0.5;
	ui_label = "Fake AO Adjustment";
	ui_tooltip = "Adjust the depth map so Fake AO can work better.";
	ui_category = "Fake AO";
> = 0.1;
*/
/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define BlurSamples 10 //BlurSamples = # * 2
#define S_Power Spread * Multi
#define M_Power Blur_Cues * Multi

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
			
texture texHB { Width = BUFFER_WIDTH  * 0.5 ; Height = BUFFER_HEIGHT * 0.5 ; Format = R8; MipLevels = 1;};

sampler SamplerHB
	{
			Texture = texHB;
	};
	
texture texDC { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R8; MipLevels = 3;};

sampler SamplerDC
	{
			Texture = texDC;
	};
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float Depth(in float2 texcoord : TEXCOORD0)
{
	if (Depth_Map_Flip)
		texcoord.y =  1 - texcoord.y;
		
	float zBuffer = tex2D(DepthBuffer, texcoord).x; //Depth Buffer
	
	//Conversions to linear space.....
	//Near & Far Adjustment
	float Far = 1.0, Near = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
	
	float2 Z = float2( zBuffer, 1-zBuffer );
	
	if (Depth_Map == 0)//DM0. Normal
		zBuffer = Far * Near / (Far + Z.x * (Near - Far));		
	else if (Depth_Map == 1)//DM1. Reverse
		zBuffer = Far * Near / (Far + Z.y * (Near - Far));	
		 
	return saturate(zBuffer);	
}
	
float lum(float3 RGB)
{
		return dot(RGB, float3(0.2126, 0.7152, 0.0722) );
}

float BB(in float2 texcoord, float2 AD)
{
	/*
	if(Fake_AO)
		return 1-(1 - Fake_AO_Adjust/Depth(texcoord + AD).xxx);
	else
	*/
		return lum(tex2Dlod(BackBuffer, float4(texcoord + AD,0,0)).rgb);
}

float H_Blur(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target                                                                          
{
	float S = S_Power * 0.125;
	
	float sum = BB(texcoord,0) * BlurSamples;
    
    float total = BlurSamples;
    
    for ( int j = -BlurSamples; j <= BlurSamples; ++j)
    {
        float W = BlurSamples;
        
		sum += BB(texcoord , + float2(pix.x * S,0) * j ) * W;

        total += W;
    }
	return saturate(sum / total); // Get it  Total sum..... :D				
}

// Spread the blur a bit more. 
float DepthCues(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target  
{	
		float2 S = S_Power * 0.75f * pix;

		float M_Cues = 1, result = tex2Dlod(SamplerHB,float4(texcoord,0,M_Cues)).x;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2( 1, 0) * S ,0,M_Cues)).x;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0, 1) * S ,0,M_Cues)).x;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2(-1, 0) * S ,0,M_Cues)).x;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0,-1) * S ,0,M_Cues)).x;
		S *= 0.5;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2( 1, 0) * S ,0,M_Cues)).x;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0, 1) * S ,0,M_Cues)).x;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2(-1, 0) * S ,0,M_Cues)).x;
		result += tex2Dlod(SamplerHB,float4(texcoord + float2( 0,-1) * S ,0,M_Cues)).x;
		result *= rcp(9);
	
	// Formula for Image Pop = Original + (Original / Blurred).
	float DC = BB(texcoord,0) / result;
return saturate(lerp(1.0f,DC,Shade_Power));
}

float3 ShaderOut(float2 texcoord : TEXCOORD0)
{	
	float DCB = tex2Dlod(SamplerDC,float4(texcoord,0,M_Power)).x,DB = Depth(texcoord).x;
	float3 Out, BBN = tex2D(BackBuffer,texcoord).rgb;
	
	if(No_Depth_Map)
		DB = 0.0;
	
	Out.rgb = BBN * lerp(DCB,1., DB);
	
	if (Debug_View)
		Out = lerp(DCB,1., DB);
	
	if (DEPTH_DEBUG)
		Out = DB;
	
	return Out;
}
uniform float timer < source = "timer"; >; //Please do not remove.
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y,D,E,P,T,H,Three,DD,Dot,I,N,F,O;	
	float3 Color = ShaderOut(texcoord).rgb;
	
	[branch] if(timer <= 12500)
	{
		//DEPTH
		//D
		float PosXD = -0.035+PosX, offsetD = 0.001;
		float OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
		D = OneD-TwoD;
		
		//E
		float PosXE = -0.028+PosX, offsetE = 0.0005;
		float OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
		float TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
		E = (OneE-TwoE)+ThreeE;
		
		//P
		float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
		float OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.775));
		float TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.680));
		float ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		P = (OneP-TwoP) + ThreeP;

		//T
		float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
		float OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
		float TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
		T = OneT+TwoT;
		
		//H
		float PosXH = -0.0072+PosX;
		float OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
		float TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
		float ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.00325,0.009));
		H = (OneH-TwoH)+ThreeH;
		
		//Three
		float offsetFive = 0.001, PosX3 = -0.001+PosX;
		float OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
		float TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
		float ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
		Three = (OneThree-TwoThree)+ThreeThree;	
		
		//DD
		float PosXDD = 0.006+PosX, offsetDD = 0.001;	
		float OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DD = OneDD-TwoDD;
		
		//Dot
		float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;		
		float OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
		Dot = OneDot;
		
		//INFO
		//I	
		float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
		float OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
		float TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
		float ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
		I = OneI+TwoI+ThreeI;
		
		//N
		float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
		float OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
		float TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
		N = OneN-TwoN;
		
		//F
		float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
		float OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
		float TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
		float ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
		F = (OneF-TwoF)+ThreeF;
		
		//O
		float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
		float OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
		float TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
		O = OneO-TwoO;
		//Website
		return D+E+P+T+H+Three+DD+Dot+I+N+F+O ? 1-texcoord.y*50.0+48.35f : float4(Color,1.);
	}
	else
		return float4(Color,1.);
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

			pass Blur
		{
			VertexShader = PostProcessVS;
			PixelShader = H_Blur;
			RenderTarget = texHB;
		}
			pass BlurDC
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthCues;
			RenderTarget = texDC;
		}
			pass UnsharpMask
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}