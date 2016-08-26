SuperDepth3D_Reprojection_3DC.fx

For testing on checkerboard 3D Monitors/Tv.

In this shader I allow for checkerboard size Adjustment.
with the Checkerboard 3D Pixel Size drag bar.
The this works on the division of the Resolution you have set for the game.

uniform int P <
	ui_type = "drag";
	ui_min = 1; ui_max = 50;
	ui_label = "Checkerboard 3D Pixel Size";
	ui_tooltip = "Adjust the Pixel Size for the right size. This Assumes pixle order is L/R R/L.";
> = 1;

//Code snip
float gridy = floor(texcoord.y*(BUFFER_HEIGHT/P));
float gridx = floor(texcoord.x*(BUFFER_WIDTH/P));
if ((int(gridy+gridx) & 1) == 0)
	{
	color = tex2D(SamplerCL,float2(texcoord.x + Perspective * pix.x,texcoord.y)).rgb;
	}
	else
	{
	color = tex2D(SamplerCR,float2(texcoord.x - Perspective * pix.x,texcoord.y)).rgb;
	}
//Code end snip

So If it works on Checkerboard 3D setting 1 then that good it works by 1pixle by 1 pixle No extra work needs to be done.
If it works on any other number then.... well I need to just Adjust for rez then based on the number provided.