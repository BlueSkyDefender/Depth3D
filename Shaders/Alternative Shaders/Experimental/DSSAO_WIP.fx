//

uniform int Alternate_Depth_Map_One <
	ui_type = "drag";
	ui_min = 0; ui_max = 40;
	ui_label = "DBAO DM";
	ui_tooltip = "Pick The Depth map for your AO.";
> = 0;

uniform int iterations <
	ui_type = "drag";
	ui_min = 2; ui_max = 4;
	ui_label = "iterations";
	ui_tooltip = "iterations";
> = 2.0;

uniform float FallOut <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 4.0;
	ui_label = "Fall Off";
	ui_tooltip = "FallOff";
> = 2.0;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map. Use This to Work on your Own Depth Map for your game.";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Depth Flip if the depth map is Upside Down.";
> = false;

//

uniform float timer < source = "timer"; >;

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
	
texture texDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerDM
	{
		Texture = texDM;
	};
	
texture texAO  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F;}; 

sampler SamplerAO
	{
		Texture = texAO;
	};
	
void DM(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0 )
{
	 float4 color;

			if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;

	float4 depthM = tex2D(DepthBuffer, float2(texcoord.x, texcoord.y));
	
		//Alien Isolation | Firewatch
		if (Alternate_Depth_Map_One == 0)
		{
		float cF = 1000000000;
		float cN = 1;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//Amnesia: The Dark Descent
		if (Alternate_Depth_Map_One == 1)
		{
		float cF = 1000;
		float cN = 1;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Among The Sleep | Soma
		if (Alternate_Depth_Map_One == 2)
		{
		float cF = 10;
		float cN = 0.05;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//The Vanishing of Ethan Carter Redux
		if (Alternate_Depth_Map_One == 3)
		{
		float cF  = 0.0075;
		float cN = 1;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Batman Arkham Knight | Batman Arkham Origins | Batman: Arkham City | BorderLands 2 | Hard Reset | Lords Of The Fallen | The Elder Scrolls V: Skyrim
		if (Alternate_Depth_Map_One == 4)
		{
		float cF = 50;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Call of Duty: Advance Warfare | Call of Duty: Black Ops 2 | Call of Duty: Ghost | Call of Duty: Infinite Warfare 
		if (Alternate_Depth_Map_One == 5)
		{
		float cF = 25;
		float cN = 1;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Casltevania: Lord of Shadows - UE | Dead Rising 3
		if (Alternate_Depth_Map_One == 6)
		{
		float cF = 25;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Doom 2016
		if (Alternate_Depth_Map_One == 7)
		{
		float cF = 25;
		float cN = 5;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Deadly Premonition:The Directors's Cut
		if (Alternate_Depth_Map_One == 8)
		{
		float cF = 30;
		float cN = 0;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Dragon Ball Xenoverse | Quake 2 XP
		if (Alternate_Depth_Map_One == 9)
		{
		float cF = 1;
		float cN = 0.005;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Warhammer: End Times - Vermintide | Fallout 4 
		if (Alternate_Depth_Map_One == 10)
		{
		float cF = 7.0;
		float cN = 1.5;
		depthM = (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Dying Light
		if (Alternate_Depth_Map_One == 11)
		{
		float cF = 100;
		float cN = 0.0075;
		depthM = cF / (1 + cF - (depthM/cN) * (1 - cF));
		}
		
		//GTA V
		if (Alternate_Depth_Map_One == 12)
		{
		float cF  = 10000; 
		float cN = 0.0075; 
		depthM = cF / (1 + cF - (depthM/cN) * (1 - cF));
		}
		
		//Magicka 2
		if (Alternate_Depth_Map_One == 13)
		{
		float cF = 1.025;
		float cN = 0.025;	
		depthM = clamp(pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000)/0.5,0,1.25);
		}
		
		//Middle-earth: Shadow of Mordor
		if (Alternate_Depth_Map_One == 14)
		{
		float cF = 650;
		float cN = 651;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Naruto Shippuden UNS3 Full Blurst
		if (Alternate_Depth_Map_One == 15)
		{
		float cF = 150;
		float cN = 0.001;
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Shadow warrior(2013)XP
		if (Alternate_Depth_Map_One == 16)
		{
		float cF = 5;
		float cN = 0.05;
		depthM = cN/(cN-cF) / ( depthM - cF/(cF-cN));
		}
		
		//Ryse: Son of Rome
		if (Alternate_Depth_Map_One == 17)
		{
		float cF = 1.010;
		float cN = 0;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Sleeping Dogs: DE
		if (Alternate_Depth_Map_One == 18)
		{
		float cF  = 1;
		float cN = 0.025;
		depthM =  (cN * cF / (cF + depthM * (cN - cF))); 
		}
		
		//Souls Games
		if (Alternate_Depth_Map_One == 19)
		{
		float cF = 1.050;
		float cN = 0.025;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Witcher 3
		if (Alternate_Depth_Map_One == 20)
		{
		float cF = 7.5;
		float cN = 1;	
		depthM = (pow(abs(cN-depthM),cF));
		}

		//Assassin Creed Unity | Just Cause 3
		if (Alternate_Depth_Map_One == 21)
		{
		float cF = 150;
		float cN = 151;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}	
		
		//Silent Hill: Homecoming
		if (Alternate_Depth_Map_One == 22)
		{
		float cF = 25;
		float cN = 25.869;
		depthM = clamp(1 - (depthM * cF / (cF - cN) + cN) / depthM,0,255);
		}
		
		//Monstrum DX11
		if (Alternate_Depth_Map_One == 23)
		{
		float cF = 1.075;	
		float cN = 0;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//S.T.A.L.K.E.R:SoC
		if (Alternate_Depth_Map_One == 24)
		{
		float cF = 1.001;
		float cN = 0;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}
		
		//Double Dragon Neon
		if (Alternate_Depth_Map_One == 25)
		{
		float cF = 0.5;
		float cN = 0.150;
		depthM = log(depthM / cN) / log(cF / cN);
		}
		
		//Deus Ex: Mankind Divided
		if (Alternate_Depth_Map_One == 26)
		{
		float cF = 250;
		float cN = 251;
		depthM = pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),1000);
		}	
		
		//The Elder Scrolls V: Skyrim Special Edition
		if (Alternate_Depth_Map_One == 27)
		{
		float cF = 20;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Rage64|
		if (Alternate_Depth_Map_One == 28)
		{
		float cF = 50;
		float cN = -0.5;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Through The Woods
		if (Alternate_Depth_Map_One == 29)
		{
		float cF = 25;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Amnesia: Machine for Pigs
		if (Alternate_Depth_Map_One == 30)
		{
		float cF = 100;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Requiem: Avenging Angel
		if (Alternate_Depth_Map_One == 31)
		{
		float cF = 100;
		float cN = 1.555;
		depthM = 1 - log(pow(abs(cN-depthM),cF));
		}
		
		//Turok: Dinosaur Hunter
		if (Alternate_Depth_Map_One == 32)
		{
		float cF = 1000; //10+
		float cN = 0;//1
		depthM = (pow(abs(cN-depthM),cF));
		}
		
		//Never Alone (Kisima Ingitchuna)
		if (Alternate_Depth_Map_One == 33)
		{
		float cF = 112.5;
		float cN = 1.995;
		depthM = 1 - log(pow(abs(cN-depthM),cF));
		}
		
		//Stacking
		if (Alternate_Depth_Map_One == 34)
		{
		float cF = 15;
		float cN = 0;
		depthM =  (exp(pow(depthM, depthM + cF / pow(depthM, cN) - 1 * (pow((depthM), cN)))) - 1) / (exp(depthM) - 1);
		}
		
		//Fez
		if (Alternate_Depth_Map_One == 35)
		{
		float cF = 25.0;
		float cN = 1.5125;
		depthM = clamp(1 - log(pow(abs(cN-depthM),cF)),0,1);
		}
		
		//Lara Croft & Temple of Osiris
		if (Alternate_Depth_Map_One == 36)
		{
		float cF = 0.340;//1.010+	or 150
		float cN = 12.250;//0 or	151
		depthM = 1 - clamp(pow(abs((exp(depthM * log(cF + cN)) - cN) / cF),10),0,1);
		}
		
		//DreamFall Chapters
		if (Alternate_Depth_Map_One == 37)
		{
		float cF = 100;	
		float cN = 5;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//DreamFall Chapters
		if (Alternate_Depth_Map_One == 38)
		{
		float cF = 100;	
		float cN = 100;	
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//LOZ TP HD
		if (Alternate_Depth_Map_One == 39)
		{
		float cF = 100;
		float cN = 2.250;
		depthM = (exp(depthM * log(cF + cN)) - cN) / cF;
		}
		
		//God of War Ghost of Sparta
		if (Alternate_Depth_Map_One == 40)
		{
		float cF = 10.5;
		float cN = 0.02;
		depthM = (pow(abs(cN-depthM),cF));
		}
				
	float4 D;

		D = depthM;

    
	color.rgb = D.rrr;
	
	Color = color;	

}

float3 GetPosition(float2 coords)
{
	return float3(coords.xy*2.0-1.0,10.0)*tex2D(SamplerDM,coords.xy).rgb;
}

float3 GetRandom(float2 co)
{
float random = frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453 * 1);
	return float3(random,random,random);
}

float3 normal_from_depth(float2 texcoords) 
{
  float depth;
  const float2 offset1 = float2(-1,1.1);
  const float2 offset2 = float2(1.1,1.1);
  
  float depth1 = tex2D(SamplerDM, texcoords + offset1).r;
  float depth2 = tex2D(SamplerDM, texcoords + offset2).r;
  
  float3 p1 = float3(offset1, depth1 - depth);
  float3 p2 = float3(offset2, depth2 - depth);
  
  float3 normal = cross(p1, p2);
  normal.z = -normal.z;
  
  return normalize(normal);
}

    float aoFF(in float3 ddiff,in float3 cnorm, in float c1, in float c2)
    {
          float3 vv = normalize(ddiff);
          float rd = length(ddiff);
          return (1.0-clamp(dot(normal_from_depth(float2(c1,c2)),-vv),-1,1.0)) *
           clamp(dot( cnorm,vv ),1.0,1.0)* 
                 (1.0 - 1.0/sqrt(1.0/(rd*rd) + 5));
    }

float4 GetAO( float2 texcoord )
{ 
	float X, num, iter;
    //read current normal,position and color.
    float3 n = normal_from_depth(texcoord);
    float3 p = GetPosition(texcoord);

    //randomization texture

    float2 random = GetRandom(texcoord).xy;
    
        //4 iterations 
		if (iterations == 4)
		{
		X = 4;
		num = 32;
		iter = 0.0005;
		}
		
		if (iterations == 3)
		{
		X = 3;
		num = 24;
		iter = 0.0006;
		}
		
		if (iterations == 2)
		{
		X = 2;
		num = 16;
		iter = 0.0007;
		}	

    //initialize variables:
    float ao = 0.0;
    float incx = FallOut*pix.x;
    float incy = FallOut*pix.y/1.5;
    float pw = incx;
    float ph = incy;
    float cdepth = tex2D(SamplerDM, texcoord).r;
    
    [unroll]
    for(float i=0.0; i<X; ++i) 
    {
       float npw = (pw+iter*random.x)/cdepth;
       float nph = (ph+iter*random.y)/cdepth;
	
		   float3 ddiff = GetPosition(texcoord.st+float2(npw,nph))-p;
		   float3 ddiff2 = GetPosition(texcoord.st+float2(npw,-nph))-p;
		   float3 ddiff3 = GetPosition(texcoord.st+float2(-npw,nph))-p;
		   float3 ddiff4 = GetPosition(texcoord.st+float2(-npw,-nph))-p;
		   float3 ddiff5 = GetPosition(texcoord.st+float2(0,nph))-p;
		   float3 ddiff6 = GetPosition(texcoord.st+float2(0,-nph))-p;
		   float3 ddiff7 = GetPosition(texcoord.st+float2(npw,0))-p;
		   float3 ddiff8 = GetPosition(texcoord.st+float2(-npw,0))-p;

		   ao+=  aoFF(ddiff,n,npw,nph);
		   ao+=  aoFF(ddiff2,n,npw,-nph);
		   ao+=  aoFF(ddiff3,n,-npw,nph);
		   ao+=  aoFF(ddiff4,n,-npw,-nph);
		   ao+=  aoFF(ddiff5,n,0,nph);
		   ao+=  aoFF(ddiff6,n,0,-nph);
		   ao+=  aoFF(ddiff7,n,npw,0);
		   ao+=  aoFF(ddiff8,n,-npw,0);
		
		//increase sampling area:
		   pw += incx;  
		   ph += incy;		    
    } 
    ao/=num;

    return ao;
}


#define s2(a, b)					temp = a; a = min(a, b); b = max(temp, b);
#define mn3(a, b, c)				s2(a, b); s2(a, c);
#define mx3(a, b, c)				s2(b, c); s2(a, c);

#define mnmx3(a, b, c)				mx3(a, b, c); s2(a, b);                                   // 3 exchanges
#define mnmx4(a, b, c, d)			s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
#define mnmx5(a, b, c, d, e)		s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
#define mnmx6(a, b, c, d, e, f) 	s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges

void AO_in(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	color = GetAO(texcoord);
}

void AO_out(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0 )
{

float2 ScreenCal = float2(2*pix.x,2*pix.y);

	float2 FinCal = ScreenCal*0.6;

	float4 v[9];
	[unroll]
	for(int i = -1; i <= 1; ++i) 
	{
		for(int j = -1; j <= 1; ++j)
		{		
		  float2 offset = float2(float(i), float(j));

		  v[(i + 1) * 3 + (j + 1)] = tex2D(SamplerAO, texcoord + offset * FinCal) + tex2D(SamplerAO, texcoord - offset * FinCal);
		  
		  }
	}

	float4 temp;

	mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
	mnmx5(v[1], v[2], v[3], v[4], v[6]);
	mnmx4(v[2], v[3], v[4], v[7]);
	mnmx3(v[3], v[4], v[8]);
	
 float4 Done = v[4]/2; 
	
 float4 CC = tex2D(BackBuffer,texcoord);
  
 float4 final = CC*min(0.950,Done);
  
   if (Depth_Map_View)
  {
  final = Done;
  }
  
  Color = final;
}


// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

//*Rendering passes*//

technique AO
{			
			pass DepthMap
		{
			VertexShader = PostProcessVS;
			PixelShader = DM;
			RenderTarget = texDM;
		}
			pass SSAOin
		{
			VertexShader = PostProcessVS;
			PixelShader = AO_in;
			RenderTarget = texAO;
		}
			pass SSAOout
		{
			VertexShader = PostProcessVS;
			PixelShader = AO_out;
		}
}