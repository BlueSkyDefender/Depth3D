 ////-------//
 ///**NLM**///
 //-------////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Non Local Means Filter                                     																										
// For Reshade 3.0+																																					
// --------------------------																																			
// Have fun,																																								
// Jose Negrete AKA BlueSkyDefender																																		
// 																																											
// https://github.com/BlueSkyDefender/Depth3D																	
//  ---------------------------------
//																																	                                                                                                        																	
// 								Non-Local Means Made by panda1234lee ported over to Reshade by BSD													
//								Link for sorce info listed below																
// 								https://creativecommons.org/licenses/by-sa/4.0/ CC Thank You.
//
//								Non-Local Means sharpening figures out what
//								makes me different from other similar things
//								in the image, and exaggerates that
//                                                     
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// It is best to run Smart Sharp after tonemapping.

#if !defined(__RESHADE__) || __RESHADE__ < 40000
	#define Compatibility 1
#else
	#define Compatibility 0
#endif
uniform float G_Attenuation <
	ui_type = "drag";
	ui_min = 1; ui_max = 25; ui_step = 0.01;
	ui_tooltip = "Control the degree of attenuation of the Gaussian function.";
	ui_label = "Gaussian Attenuation";
> = 10;

uniform int NLM_Quality <
	ui_type = "combo";
	ui_items = "Low\0Medium\0High\0";
	ui_label = "NLM Quality";
	ui_tooltip = "Gives more control of Non-Local Means Quality.";
	ui_category = "Non-Local Means Filtering";
> = 1;

/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;	

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
				
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float normaL2(float4 RGB) 
{ 
   return pow(RGB.r, 2) + pow(RGB.g, 2) + pow(RGB.b, 2) + pow(RGB.a, 2);
}

float4 BB(in float2 texcoord, float2 AD)
{
	return tex2Dlod(BackBuffer, float4(texcoord + AD,0,0));
}

float2 Quality()
{
if (NLM_Quality == 2)
	return float2(3,1.0);
else if(NLM_Quality == 1)
	return float2(2,0.875);
else
	return float2(1,0.75);
}

float G_Ammount()
{
	return G_Attenuation;
}

#define search_radius Quality().x //Search window radius D = 1    2   3
#define block_radius Quality().y //Base Window Radius D = 0.75 0.875 1.0

#define search_window 2 * search_radius + 1 //Search window size
#define minus_search_window2_inv -rcp(search_window * search_window) //Refactor Search Window 

#define h G_Ammount() //Control the degree of attenuation of the Gaussian function
#define minus_h2_inv -rcp(h * h * 4) //The number of channels is four
#define noise_mult minus_h2_inv * 500 //Used for precision

float4 NLM(float2 texcoord)
{
	
          
	//Non-Local Mean// - https://blog.csdn.net/panda1234lee/article/details/88016834      
   float sum2;
   float2 RPC_WS = pix;
   float4 sum1;
	//Traverse the search window
   for(float y = -search_radius; y <= search_radius; ++y)
   {
      for(float x = -search_radius; x <= search_radius; ++x)
      { //Count the sum of the L2 norms of the colors in a search window (the colors in all Base windows
          float dist = 0;
 
		  //Traversing the Base window
          for(float ty = -block_radius; ty <= block_radius; ++ty)
          { 
             for(float tx = -block_radius; tx <= block_radius; ++tx)
             {  //clamping to increase performance & Search window neighborhoods
                float4 bv = saturate(  BB(texcoord, float2(x + tx, y + ty) * RPC_WS) );
                //Current pixel neighborhood
                float4 av = saturate(  BB(texcoord, float2(tx, ty) * RPC_WS) );
                
                dist += normaL2(av - bv);
             }
          }
		  //Gaussian weights (calculated from the color distance and pixel distance of all base windows) under a search window
          float window = exp(dist * noise_mult + (pow(x, 2) + pow(y, 2)) * minus_search_window2_inv);
 
          sum1 +=  window * saturate( BB(texcoord, float2(x, y) * RPC_WS) ); //Gaussian weight * pixel value         
          sum2 += window; //Accumulate Gaussian weights for all search windows for normalization
      }
   }
		
return float4(sum1.rgb / sum2,1);
}

uniform float timer < source = "timer"; >; //Please do not remove.
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y;	
	float3 Color = NLM(texcoord).rgb,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
	[branch] if(timer <= 12500)
	{
		//DEPTH
		//D
		float PosXD = -0.035+PosX, offsetD = 0.001;
		float3 OneD = all( abs(float2( texcoord.x -PosXD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float3 TwoD = all( abs(float2( texcoord.x -PosXD-offsetD, texcoord.y-PosY)) < float2(0.0025,0.007));
		D = OneD-TwoD;
		
		//E
		float PosXE = -0.028+PosX, offsetE = 0.0005;
		float3 OneE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.009));
		float3 TwoE = all( abs(float2( texcoord.x -PosXE-offsetE, texcoord.y-PosY)) < float2(0.0025,0.007));
		float3 ThreeE = all( abs(float2( texcoord.x -PosXE, texcoord.y-PosY)) < float2(0.003,0.001));
		E = (OneE-TwoE)+ThreeE;
		
		//P
		float PosXP = -0.0215+PosX, PosYP = -0.0025+PosY, offsetP = 0.001, offsetP1 = 0.002;
		float3 OneP = all( abs(float2( texcoord.x -PosXP, texcoord.y-PosYP)) < float2(0.0025,0.009*0.775));
		float3 TwoP = all( abs(float2( texcoord.x -PosXP-offsetP, texcoord.y-PosYP)) < float2(0.0025,0.007*0.680));
		float3 ThreeP = all( abs(float2( texcoord.x -PosXP+offsetP1, texcoord.y-PosY)) < float2(0.0005,0.009));
		P = (OneP-TwoP) + ThreeP;

		//T
		float PosXT = -0.014+PosX, PosYT = -0.008+PosY;
		float3 OneT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosYT)) < float2(0.003,0.001));
		float3 TwoT = all( abs(float2( texcoord.x -PosXT, texcoord.y-PosY)) < float2(0.000625,0.009));
		T = OneT+TwoT;
		
		//H
		float PosXH = -0.0072+PosX;
		float3 OneH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.001));
		float3 TwoH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.002,0.009));
		float3 ThreeH = all( abs(float2( texcoord.x -PosXH, texcoord.y-PosY)) < float2(0.00325,0.009));
		H = (OneH-TwoH)+ThreeH;
		
		//Three
		float offsetFive = 0.001, PosX3 = -0.001+PosX;
		float3 OneThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.009));
		float3 TwoThree = all( abs(float2( texcoord.x -PosX3 - offsetFive, texcoord.y-PosY)) < float2(0.003,0.007));
		float3 ThreeThree = all( abs(float2( texcoord.x -PosX3, texcoord.y-PosY)) < float2(0.002,0.001));
		Three = (OneThree-TwoThree)+ThreeThree;	
		
		//DD
		float PosXDD = 0.006+PosX, offsetDD = 0.001;	
		float3 OneDD = all( abs(float2( texcoord.x -PosXDD, texcoord.y-PosY)) < float2(0.0025,0.009));
		float3 TwoDD = all( abs(float2( texcoord.x -PosXDD-offsetDD, texcoord.y-PosY)) < float2(0.0025,0.007));
		DD = OneDD-TwoDD;
		
		//Dot
		float PosXDot = 0.011+PosX, PosYDot = 0.008+PosY;		
		float3 OneDot = all( abs(float2( texcoord.x -PosXDot, texcoord.y-PosYDot)) < float2(0.00075,0.0015));
		Dot = OneDot;
		
		//INFO
		//I	
		float PosXI = 0.0155+PosX, PosYI = 0.004+PosY, PosYII = 0.008+PosY;
		float3 OneI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosY)) < float2(0.003,0.001));
		float3 TwoI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYI)) < float2(0.000625,0.005));
		float3 ThreeI = all( abs(float2( texcoord.x - PosXI, texcoord.y - PosYII)) < float2(0.003,0.001));
		I = OneI+TwoI+ThreeI;
		
		//N
		float PosXN = 0.0225+PosX, PosYN = 0.005+PosY,offsetN = -0.001;
		float3 OneN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN)) < float2(0.002,0.004));
		float3 TwoN = all( abs(float2( texcoord.x - PosXN, texcoord.y - PosYN - offsetN)) < float2(0.003,0.005));
		N = OneN-TwoN;
		
		//F
		float PosXF = 0.029+PosX, PosYF = 0.004+PosY, offsetF = 0.0005, offsetF1 = 0.001;
		float3 OneF = all( abs(float2( texcoord.x -PosXF-offsetF, texcoord.y-PosYF-offsetF1)) < float2(0.002,0.004));
		float3 TwoF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0025,0.005));
		float3 ThreeF = all( abs(float2( texcoord.x -PosXF, texcoord.y-PosYF)) < float2(0.0015,0.00075));
		F = (OneF-TwoF)+ThreeF;
		
		//O
		float PosXO = 0.035+PosX, PosYO = 0.004+PosY;
		float3 OneO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.003,0.005));
		float3 TwoO = all( abs(float2( texcoord.x -PosXO, texcoord.y-PosYO)) < float2(0.002,0.003));
		O = OneO-TwoO;
		//Website
		return float4(D+E+P+T+H+Three+DD+Dot+I+N+F+O,1.) ? 1-texcoord.y*50.0+48.35f : float4(Color,1.);
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
technique NonLocal_Means
< ui_tooltip = "Suggestion : You Can Enable 'Performance Mode Checkbox,' in the lower bottom right of the ReShade's Main UI.\n"
			   "             Do this once you set your Smart Sharp settings of course."; >
{		
			pass NLM
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}