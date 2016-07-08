# SuperDepth3D
Depth Map Based 3D post-process shader v1.6 for Reshade 3.0
It also needs ReShade.fxh to work.

There are the Basic Depth maps you can use for your games listed and not listed. Look at this link for other game Compatablity.

This Mod alows for Depth Map Based 3D like What Nvidia does with Compatablity Mode 3D and Kind of what TriDef Does with Power 3D. 

http://reshade.me/compatibility
At this link look for Depth Map compatablity.

Here is a quick and dirty game list of working Depth Maps. 

PLEASE SET YOUR RESOLUTION FIRST. Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted.

.-=|DepthFix Off|=-.
======================================================================================================================================

[Depth Map 0]
Naruto Shippuden UNS3 Full Blurst | Amnesia: The Dark Descent | The Evil With In {Read Below} | Sleeping Dogs: DE | RAGE64 {Read Below} | Quake 4 {Read Below}

[Depth Map 1]
BoarderLands 2 {Read Below} | Deadly Premonition: The Directors's Cut {Read Below}

[Depth Map 2]
Batman Arkham Origins | Batman Arkham Knight

[Depth Map 3]
Skyrim V {Read Below}

[Depth Map 4]
Fallout 4 | Alien Isolation | Shadow warrior(2013) {Read Below}

[Depth Map 5]
Lords of The Fallen  | Dragons Dogma: Dark Arisen Dragon | Ball Xenoverse | Hard Reset {Read Below} | Return To Castle Wolfenstine {Read Below} | Souls Games

[Depth Map 6]
Dying Light

[Depth Map 7]
Assassin Creed Unity | Call of Duty: Ghost {Read Below} | Call of Duty: Black Ops 2 {Read Below}

[Depth Map 8]
Metro Last Light Redux {Read Below} | Metro 2033 Redux {Read Below} | Batman: Arkham City

[Depth Map 9]
Middle-earth: Shadow of Mordor {Read Below} | GTA V {Read Below}

[Depth Map 10]
Call of Duty: Advance Warfare

[Depth Map 11]
Magicka 2 {Read Below} | Casltevania: Lord of Shadows - UE

[Depth Map 12]
Condemned: Criminal Origins {Read Below} | Zombi

[Depth Map 13]
Witcher 3

.-=|DepthFix On|=-.
======================================================================================================================================

[Depth Map 0]
 Among The Sleep

[Depth Map 5]
DreamFall Chapters

[Depth Map 8]
Firewatch

You can also try different depth maps for other games your self by changing AltDepthMap number From 0-15. 
You *may* want to disable AA in game. You can always enable SMAA in reshade for AA or play at 4k with no AA. 
Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted. Turn On SSAO or HABO They help a lot.

In-game Menu Settings
======================================================================================================================================

Shift + f2 for Reshade 3.0 menu

* Depth Map View 	[Off ▼]		Depth Map View. To see The Depth map. Use This to Work on your Own Depth Map for your game.
* Alternate Depth Map	[Depth Map 5 ▼]	[0|1|2|3|4|5|6|7|9|10|11|12|13] Alternate Depth Map for different Games. 
* Depth Flip	 	[Off ▼]		Depth Flip if Upside Down.
* Pop		 	[Pop Off ▼]	[0|1|2|3|4|5|6] Adds more depth depending on the game.
* Perspective	       -[◄▪▪▪▪0▪▪▪▪▪►]+	[-15:15] Perspective Default is 0 "Drag to Adjust Perspective"
* Depth		       -[◄▪▪▪▪15▪▪▪▪►]+	[0:25] Depth Default is 15 "Drag to Adjust Perspective"
* Eye Swap  	 	[Off ▼]  	Swap Left/Right to Right/Left and ViceVersa.

Pop Now Works. For games that are open World/RPGs Try Pop Two, Pop Three, and Pop Four. For FPS Try Pop One, Pop Two and Pop Four. 
For RTS games Try Pop One <----> Pop Five. You can Just try any of them out really.

Ex. In Batman: Arkham City Depth Map 8 + Pop 6 looks best to me.

Read Below Section
======================================================================================================================================

{Deadly Premonition}
Can Run with Higer Rez useing DPfix095.
To Use it with Reshade Just Start Up Reshade and Make a profile for it like any other game.

Then head to the folder and rename d3d9.dll to dxgi.dll. 
Now open the DPfix095.zip Directly from http://blog.metaclassofnil.com/wp-content/uploads/2013/12/DPfix095.zip or http://blog.metaclassofnil.com/?p=438.

Install the contents of that folder in to Deadly Premonition Folder where you changed Reshade's d3d9.dll to dxgi.dll. Edit the DPfix.ini too what ever REZ you want. Then start the game.

{Magicka 2} 
Rename the opengl.dll to dxgi.dll
Also Use a Controller for game play.

{BoarderLands 2}
Use a Controller for menus navigation or keyboard. 
Mouse and keyboard is good for gameplay. 

{Rage}
Start the game with out Reshade Set your game resolution First Turn off AA. 
Exit, Then use reshade and set your setting you want then launch your game. You can not change your resolution once in game This sill remove the depth map.
Rage 64 was tested only.

{Metro Last Light Redux}
Rename the d3d9.dll or dxgi.dll to d3d11.dll

{Metro 2033 Redux}
Rename the d3d9.dll or dxgi.dll to d3d11.dll

{Middle-earth: Shadow of Mordor}
3D only works if your game at 100% scaling and FullScreen mode. 
Borderless Full Screen will not work Window mode will not Work. 
So if you want to Play at a lower resolution, then set your windows resolution lower then run the game in full screen and set your scaling to 100%. 
Anything Lower or Higher then 100% will not work.

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

{The Evil With In}
Game too big for scren DPI scaling. 
To fix this go to where the program is installed and find the EXE

Steam\steamapps\common\TheEvilWithin
Right click the EvilWithin.exe
Go to Compatibility
Check Disable Display Scaling On High DPI Settings

This should fix it. For more look up this problem on google.

{Call of Duty: Ghost}
Set Image Quality to Extra.

{Call of Duty: Black Ops 2}
Turn off AA.

{Hard Reset}
Must Enable FSAA for depth buffer access.

{Condemned: Criminal Origins}
Depth Buffer Drops time to time Also Dissable FSAA (FSAA OFF)

{Shadow warrior(2013)}
Depth Buffer only in DX9 so launch it in Shadow Warrior XP and turn on FSAAX2 in game.

{GTA 5}
Rename the dxgi.dll too d3d11.dll for DX11 mode.

{Skyrim V}
Change the SkyrimPrefs.ini setting too.

bFloatPointRenderTarget=0
bDeferredShadows=0

{Quake 4}
If some how you can click on the menu......... Good Luck.
Also if some how you get it working When the game Saves You have to recheck the 3D shader. 
This is where a Defaults.ini will come in handy.

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
