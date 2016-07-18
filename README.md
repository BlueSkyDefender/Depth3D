#SuperDepth3D
Depth Map Based 3D post-process shader v1.6.5 for Reshade 3.0
It also needs *ReShade.fxh* to work.

There are the Basic Depth maps you can use for your games listed and not listed. Look at this link for other game Compatablity.

This Mod alows for Depth Map Based 3D like What Nvidia does with Compatablity Mode 3D and Kind of what TriDef Does with Power 3D. 

http://reshade.me/compatibility
At this link look for Depth Map compatablity.

Here is a quick and dirty game list of working Depth Maps. 

PLEASE SET YOUR RESOLUTION FIRST. Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted.

[Game List]							[Alternet Depth Map]	[Depth Flip On]		[Read Below]
Alien Isolation								DM 10
Amnesia: The Dark Descent					DM 0
Among The Sleep								DM 16				DF On
Assassin Creed Unity						DM 9
Batman Arkham Knight						DM 1
Batman Arkham Origins						DM 1
Batman: Arkham City							DM 2
BorderLands 2								DM 2									RB
Call of Duty: Advance Warfare				DM 19
Call of Duty: Black Ops 2					DM 19									RB
Call of Duty: Ghost							DM 19									RB
Casltevania: Lord of Shadows - UE			DM 7
Condemned: Criminal Origins					DM 0									RB
Deadly Premonition: The Directors's Cut		DM 10									RB
Dragon Ball Xenoverse						DM 16
Dragons Dogma: Dark Arisen					DM 15
DreamFall Chapters							DM 18				DF On
Dying Light									DM 11
Fallout 4									DM 13
Firewatch									DM 1				DF On
GTA V										DM 11									RB
Hard Reset									DM 8									RB
Lords of The Fallen							DM 6
Magicka 2									DM 14									RB
Metro 2033 Redux							DM 20									RB
Metro Last Light Redux						DM 20									RB
Middle-earth: Shadow of Mordor				DM 12									RB
Naruto Shippuden UNS3 Full Blurst			DM 0									RB
Quake 4										DM 17
Rage64										DM 8									RB
Return To Castle Wolfenstine				DM 17									RB
Shadow warrior(2013)						DM 7									RB
Skyrim										DM 10
Sleeping Dogs: DE							DM 4
Souls Games									DM 6
The Evil Within								DM 3									RB
Witcher 3									DM 12
Zombi										DM 3

You can also try different depth maps for other games your self by changing AltDepthMap number From 0-20. 
You *may* want to disable AA in game. You can always enable SMAA in reshade for AA or play at 4k with no AA. 
Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted. Turn On SSAO or HABO They help a lot.

In-game Menu Settings
======================================================================================================================================

Shift + f2 for Reshade 3.0 menu

* Alternate Depth Map	[Depth Map 5 ▼]		[0|1|2|3|4|5|6|7|9|10|11|12|13|14|15|16|17|18|19|20|C1|C2] Alternate Depth Map for different Games. 
						[Custom One  ▼]		Also Added, the Ablity to
						[Custom Two  ▼]  	make your Own Depth Map.
* Depth				   -[◄▪▪▪▪▪▪▪▪25►]+		[0:25] Depth Default is 25. "Drag to Adjust Perspective."
* Perspective		   -[◄▪▪▪▪0▪▪▪▪▪►]+		[-25:25] Perspective Default is 0. "Drag to Adjust Perspective."
* Warp Adjust		   -[◄▪▪▪▪0▪▪▪▪▪►]+		[-25:25] Warp Adjust Default is 0. "Adjust the warp in the right eye."
* Depth Flip	 		[Off ▼]				Depth Flip if Upside Down.
* Depth Map View 		[Off ▼]				Depth Map View. To see The Depth map. Use This to Work on your Own Depth Map for your game.
* Far				   -[◄▪▪▪▪▪▪▪▪▪▪►]+		Default is "0.05" Far Depth Map Adjustment. This works on both [Custom Two ▼] and [Custom Two ▼]
* Near				   -[◄▪▪▪▪▪▪▪▪▪▪►]+		Default is "1.25" Near Depth Map Adjustment. This works on both [Custom Two ▼] and [Custom Two ▼]
* Eye Swap  	 		[Off ▼]  			Swap Left/Right to Right/Left and ViceVersa.

Pop Removed WIP See SuperDepth3DL&R_WIP_.fx If you like to Test it.

Read Below Section
======================================================================================================================================

{BoarderLands 2}
Use a Controller for menus navigation or keyboard. 
Mouse and keyboard is good for gameplay. 

{Call of Duty: Ghost}
Set Image Quality to Extra.

{Call of Duty: Black Ops 2}
Turn off AA.

{Condemned: Criminal Origins}
Depth Buffer Drops time to time Also Dissable FSAA (FSAA OFF)

{Deadly Premonition}
Can Run with Higer Rez useing DPfix095.
To Use it with Reshade Just Start Up Reshade and Make a profile for it like any other game.

Then head to the folder and rename d3d9.dll to dxgi.dll. 
Now open the DPfix095.zip Directly from http://blog.metaclassofnil.com/wp-content/uploads/2013/12/DPfix095.zip or http://blog.metaclassofnil.com/?p=438.

Install the contents of that folder in to Deadly Premonition Folder where you changed Reshade's d3d9.dll to dxgi.dll. Edit the DPfix.ini too what ever REZ you want. Then start the game.

{GTA 5}
Rename the dxgi.dll too d3d11.dll for DX11 mode.

{Hard Reset}
Must Enable FSAA for depth buffer access.

{Magicka 2} 
Rename the opengl.dll to dxgi.dll
Also Use a Controller for game play.

{Metro Last Light Redux}
Rename the d3d9.dll or dxgi.dll to d3d11.dll

{Metro 2033 Redux}
Rename the d3d9.dll or dxgi.dll to d3d11.dll

{Middle-earth: Shadow of Mordor}
3D only works if your game at 100% scaling and FullScreen mode. 
Borderless Full Screen will not work Window mode will not Work. 
So if you want to Play at a lower resolution, then set your windows resolution lower then run the game in full screen and set your scaling to 100%. 
Anything Lower or Higher then 100% will not work.

{Naruto Shippuden UNS3 Full Blurst}
Ignore the warnings click play.

{Quake 4}
If some how you can click on the menu......... Good Luck.
Also if some how you get it working When the game Saves You have to recheck the 3D shader. 
This is where a Defaults.ini will come in handy.

{Rage}
Start the game with out Reshade Set your game resolution First Turn off AA. 
Exit, Then use reshade and set your setting you want then launch your game. You can not change your resolution once in game This sill remove the depth map.
Rage 64 was tested only.

{Return To Castle Wolfenstine}
Increase Depth to 25+ Do this by typing in your amount.
The game seems to run really slow with my shader at the start. 
This may be a problem with my old card.
But, Wait untill the frame rate stablizes. Then play the game.

Setting you want to change if you want to play at 4k.

Look in your config to see what you need to change. wolfconfig.cfg
Ex.
seta r_customaspect "1"

seta r_customheight "2160"

seta r_customwidth "3840"

seta r_fullscreen "1"

seta r_mode "-1"

{Skyrim V}
Change the SkyrimPrefs.ini setting too.

bFloatPointRenderTarget=0
bDeferredShadows=0

{Shadow warrior(2013)}
Depth Buffer only in DX9 so launch it in Shadow Warrior XP and turn on FSAAX2 in game.

{The Evil With In}
Game too big for scren DPI scaling. 
To fix this go to where the program is installed and find the EXE

Steam\steamapps\common\TheEvilWithin
Right click the EvilWithin.exe
Go to Compatibility
Check Disable Display Scaling On High DPI Settings

This should fix it. For more look up this problem on google.

Games Not working in Reshade 3.0
======================================================================================================================================
crosire's ReShade version '3.0.0.81'

{Wolfenstine The New Order} - not working in Reshade 3.0
[Set Launch Options](+r_multisamples "0" +vt_maxaniso "16")
This game must be started at the lower Resoution 1600x1200 Then Switch to 1920x1080. Befor you exit switch it back to 1600x1200. 
Note if you want to 4k It the same process Start the game at 1600x1200 then switch it to 3840x2160.
Also note you can't switch back. So say you Start the game at 1600x1200 then switch to 4k then back too 1600x1200 it will not work. 
If you change it one last time to 4k It will not work. You must restart your game for eatch change of resolution.
You can always enable SMAA in reshade for AA or play at 4k with no AA.

In order to completely disable DOF:

“open up graphicsprofiles.json and find the postprocessdof line and change high and ultra to 0.” \SteamLibrary\steamapps\common\Wolfenstein.The.New.Order\base\graphicsprofiles.json

Should look like this;
Ex.
"r_postProcessDofMode" : 
	{ 
		"low" : 0,
		"mid" : 0,
		"high" : 0,
		"ultra" : 0
	},
