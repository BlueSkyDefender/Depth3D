 ///---------//
 ///**BIAA**///
 //--------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Bilinear Interpolation Anti Aliasing.                                     																										 
 //* For Reshade 3.0+																																								
 //* --------------------------																																						
 //* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																							
 //* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																			
 //* I would also love to hear about a project you are using it with.																											
 //* https://creativecommons.org/licenses/by/3.0/us/																															
 //*																																											
 //* Have fun,																																									
 //* Jose Negrete AKA BlueSkyDefender																																			
 //* ---------------------------------																																			    
 //* 																																												
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform float AA_Power <
	ui_type = "drag";
	ui_min = 0.5; ui_max = 1;
	ui_label = "AA Power";
	ui_tooltip = "Use this to adjust the AA power.\n"
				 "Default is 0.75";
	ui_category = "BIAA";
> = 0.75;

uniform int View_Mode <
	ui_type = "combo";
	ui_items = "BIAA\0Mask View\0";
	ui_label = "View Mode";
	ui_tooltip = "This is used to select the normal view output or debug view.\n"
				 "Masked View gives you a view of the edge detection.\n"
				 "Default is BIAA.";
	ui_category = "BIAA";
> = 0;

uniform float Mask_Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Mask Adjustment";
	ui_tooltip = "Use this to adjust the Mask.\n"
				 "Default is 0.5";
	ui_category = "BIAA";
> = 0.375;
/*
uniform float Adjust <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.5;
	ui_label = "Adjustment";
	ui_category = "BIAA";
> = 0.5;
*/
/////////////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////
#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Luminosity Intensity
float LI(in float4 value)
{	
	return dot(value.rgb,float3(0.333, 0.333, 0.333));
}

float2 EdgeDetection(float2 TC, float2 offset)
{   
     float2 X = float2(offset.x,0), Y = float2(0,offset.y);
    
    // Bilinear Interpolation. 
    float Left = LI( tex2D(BackBuffer, TC-X ) ) + LI( tex2D(BackBuffer, TC-X ) );
    float Right = LI( tex2D(BackBuffer, TC+X ) ) + LI( tex2D(BackBuffer, TC+X ) );
    
    float Up = LI( tex2D(BackBuffer, TC-Y ) ) + LI( tex2D(BackBuffer, TC-Y ) );
    float Down = LI( tex2D(BackBuffer, TC+Y ) ) + LI( tex2D(BackBuffer, TC+Y ) );
	// Calculate like NFAA
    return float2(Down-Up,Right-Left) * 0.5;
}

float4 BIAA(float2 texcoord)
{
	float4 Done = float4(tex2D(BackBuffer, texcoord).rgb,1.0);
	float3 result = tex2D(BackBuffer, texcoord).rgb * (1.0-AA_Power);
	float2 Offset = pix;
    float2 X = float2(pix.x, 0.0), Y = float2(0.0, pix.y);
        
    // Calculate Edge
    float2 Edge = EdgeDetection(texcoord, Offset);
    
    // Like NFAA calculate normal from Edge
    float2 N = float2(Edge.x,-Edge.y);
    
	//Calculate Gradient from edge    
	Edge += EdgeDetection( texcoord -X, Offset);
	Edge += EdgeDetection( texcoord +X, Offset);
	Edge += EdgeDetection( texcoord -Y, Offset);
	Edge += EdgeDetection( texcoord +Y, Offset);
	Edge += EdgeDetection( texcoord -X -Y, Offset);
	Edge += EdgeDetection( texcoord -X +Y, Offset);
	Edge += EdgeDetection( texcoord +X -Y, Offset);
	Edge += EdgeDetection( texcoord +X +Y, Offset);
	
	// Like DLAA calculate mask from gradient above.
    float Mask = length(N) < pow(0.002, Mask_Adjust);
    
    // Like NFAA Calculate Main Mask based on edge strenght.
    if ( Mask )
    {
    	result = tex2D(BackBuffer, texcoord).rgb;
    }
    else
	{
	       	    
	    //Revert gradient
	    N = float2(Edge.x,-Edge.y);
    
	    // Like NFAA reproject with samples along the edge and adjust againts it self.
		// Will Be Making changes for short edges and long later.
	    float AA_Adjust = AA_Power * rcp(6);   
		result += tex2D(BackBuffer, texcoord+(N * 0.5)*Offset).rgb * AA_Adjust;
		result += tex2D(BackBuffer, texcoord-(N * 0.5)*Offset).rgb * AA_Adjust;
		result += tex2D(BackBuffer, texcoord+(N * 0.25)*Offset).rgb * AA_Adjust;
		result += tex2D(BackBuffer, texcoord-(N * 0.25)*Offset).rgb * AA_Adjust;
		result += tex2D(BackBuffer, texcoord+N*Offset).rgb * AA_Adjust;
		result += tex2D(BackBuffer, texcoord-N*Offset).rgb * AA_Adjust;
	}

    // Set result
   if (View_Mode == 0)
   	Done = float4(result,1.0);
   else
   	Done = lerp(float4(1.0,0.0,1.0,1.0),Done,saturate(Mask));
	
    	return Done;
}

uniform float timer < source = "timer"; >; //Please do not remove.
////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float PosX = 0.9525f*BUFFER_WIDTH*pix.x,PosY = 0.975f*BUFFER_HEIGHT*pix.y;	
	float3 Color = BIAA(texcoord).rgb,D,E,P,T,H,Three,DD,Dot,I,N,F,O;
	
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
technique Bilinear_Interpolation_Anti_Aliasing
{
			pass BIAA
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;	
		}
}
