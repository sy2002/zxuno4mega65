### Joystick

* In games, choose "Sinclair" or "Interface 2" as joystick type.
* You can plug your joystick into port #1 or port #2. It does not matter, as long as you play with one joystick.
* You can emulate a joystick with your cursor keys plus <kbd>Space</kbd> as fire when you switch on <kbd>Scroll Lock</kbd>.
* Learn how to play with two [[Joysticks]] and more [[here|Joysticks]].

### Experimental mindset

Playing retro games needs an experimental mindset: Not each game will immediatelly work and often you need to try different versions. Always make sure that you have `.tap` versions of the games.

#### 48k version

Sometimes, the 48k version just works. Sometimes it does not and it crashes.

You can often solve this issue by switching the ZX Spectrum into 48k mode explicitly.
[[Read here|Getting-Started#commando-playing-a-48k-game-that-needs-manual-intervention]] how this works.
[[The description|Getting-Started#commando-playing-a-48k-game-that-needs-manual-intervention]] uses the game "Commando" as an example,
but it applies to any other 48k game that needs this treatment. In short, here is what you need to do:

```
OUT 32765, 48
.tapein <your-game's-tape-file.tap>
LOAD ""
```

#### 128k version

Sometimes, the 48k version will not run at all. Then you need the 128k version of the game. An example for such a game is ELITE.

### ULAplus

ULAplus just looks great in games! Switch it on, when offered in the game's startup menu and do proactively search the web for ULAplus games.

ULAplus is an enhanced ULA for the ZX Spectrum. It can be implemented as a plug-in replacement for the ULA, in emulators, or in modern hardware such as the ZX-Uno @ MEGA65. Here are some sources to learn more:

* https://sinclair.wiki.zxnet.co.uk/wiki/ULAplus

* https://sites.google.com/site/ulaplus/

### Getting games

* 300 legal ULAplus games: https://sourcesolutions.itch.io/ulaplus10

* Some really great ULAplus games such as Rick Dangerous and R-Type with unclear copyright status: http://abrimaal.pro-e.pl/zx/ulaplus.htm

* The source for "everything" with partially unclear copyright status: https://worldofspectrum.org/
