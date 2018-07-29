uniform float Cursor_Depth 
	ui_type = drag;
	ui_min = 0; ui_max = 100;
	ui_label = Cursor Depth;
	ui_tooltip = This options pushes the cursor in and out of the screen.;
 = 75.0;

uniform int Stereoscopic_Mode 
	ui_type = combo;
	ui_items = Off0Side by Side0Top and Bottom0;
	ui_label = 3D Display Mode;
	ui_tooltip = Side by SideTop and BottomLine Interlaced displays output.;
 = 0;

uniform float Cross_Cursor_Size 
	ui_type = drag;
	ui_min = 1; ui_max = 100;
	ui_label = Cross Cursor Size;
	ui_tooltip = Pick your size of the cross cursor.n 
				 Default is 25;
 = 25.0;

uniform float3 Cross_Cursor_Color 
	ui_type = color;
	ui_label = Cross Cursor Color;
	ui_tooltip = Pick your own cross cursor color.n 
				  Default is (R 255, G 255, B 255);
 = float3(1.0, 1.0, 1.0);

uniform bool InvertY 
	ui_label = Invert Y-Axis;
	ui_tooltip = Invert Y-Axis for the cross cursor.;
 = false;

D3D Starts Here

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture BackBufferTex  COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};
	
texture texCL  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 
texture texCR  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerCL
	{
		Texture = texCL;
	};

sampler SamplerCR
	{
		Texture = texCR;
	};

uniform float2 Mousecoords  source = mousepoint;  ;	
Cross Cursor	
void LR(in float4 position  SV_Position, in float2 texcoord  TEXCOORD0, out float4 color  SV_Target0 , out float4 colorT SV_Target1)
{

float2 MC, MCA, MCB;

MC = Mousecoords;
MCA = Mousecoordsfloat2(1-(Cursor_Depthpix.x),1.0);
MCB = Mousecoordsfloat2(1-(-Cursor_Depthpix.x),1.0);

float4 SBSL, SBSR;
	if(Stereoscopic_Mode == 1) SbS
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x0.5,texcoord.y));
	SBSR = tex2D(BackBuffer, float2(texcoord.x0.5+0.5,texcoord.y));
		if (!InvertY)
		{
			SBSL = all(abs(MCA - position.xy)  Cross_Cursor_Size)  (1 - all(abs(MCA - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSL;cross
			SBSR = all(abs(MCB - position.xy)  Cross_Cursor_Size)  (1 - all(abs(MCB - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSR;cross
		}
		else
		{
			SBSL = all(abs(float2(MCA.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size)  (1 - all(abs(float2(MCA.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSL;cross
			SBSR = all(abs(float2(MCB.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size)  (1 - all(abs(float2(MCB.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSR;cross
		}
	}
	else if(Stereoscopic_Mode == 2) TnB
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y0.5));
	SBSR = tex2D(BackBuffer, float2(texcoord.x,texcoord.y0.5+0.5));
		if (!InvertY)
		{
			SBSL = all(abs(MCA - position.xy)  Cross_Cursor_Size)  (1 - all(abs(MCA - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSL;cross
			SBSR = all(abs(MCB - position.xy)  Cross_Cursor_Size)  (1 - all(abs(MCB - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSR;cross
		}
		else
		{
			SBSL = all(abs(float2(MCA.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size)  (1 - all(abs(float2(MCA.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSL;cross
			SBSR = all(abs(float2(MCB.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size)  (1 - all(abs(float2(MCB.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSR;cross
		}
	}
	else
	{
	SBSL = tex2D(BackBuffer, float2(texcoord.x,texcoord.y)); Monoscopic No stereo
		if (!InvertY)
		{
			SBSL = all(abs(MC - position.xy)  Cross_Cursor_Size)  (1 - all(abs(MC - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSL;cross
		}
		else
		{
			SBSL = all(abs(float2(MC.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size)  (1 - all(abs(float2(MC.x,BUFFER_HEIGHT-MC.y) - position.xy)  Cross_Cursor_Size(Cross_Cursor_Size2)))  float4(Cross_Cursor_Color, 1.0)  SBSL;cross
		}
	}
	
color = SBSL;
colorT = SBSR;
}

float4 MouseCursor(float4 position  SV_Position, float2 texcoord  TEXCOORD)  SV_Target
{	
	float4 Out;
	
	if ( Stereoscopic_Mode == 1) SbS
	{
	Out = texcoord.x  0.5  tex2D(SamplerCL,float2(texcoord.x2,texcoord.y))  tex2D(SamplerCR,float2(texcoord.x2-1,texcoord.y));
	}
	else if (Stereoscopic_Mode == 2) TnB
	{
	Out = texcoord.y  0.5  tex2D(SamplerCL,float2(texcoord.x,texcoord.y2)) tex2D(SamplerCR,float2(texcoord.x,texcoord.y2-1));
	}
	else Monoscopic No stereo
	{
	Out = tex2D(SamplerCL,texcoord);
	}
	
	return Out;
}

ReShade.fxh
 Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id  SV_VertexID, out float4 position  SV_Position, out float2 texcoord  TEXCOORD)
{
	texcoord.x = (id == 2)  2.0  0.0;
	texcoord.y = (id == 1)  2.0  0.0;
	position = float4(texcoord  float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

Rendering passes

technique Cross_Cursor
{			
		pass StereoMonoCCPass
		{
			VertexShader = PostProcessVS;
			PixelShader = LR;
			RenderTarget0 = texCL;
			RenderTarget1 = texCR;
		}
			pass Cursor
		{
			VertexShader = PostProcessVS;
			PixelShader = MouseCursor;
		}	
}