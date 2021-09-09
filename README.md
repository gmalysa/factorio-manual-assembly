## Description

Machines need to be operated `manually` using the circuit network to provide inputs. The goal is
to provide input control recipes for assemblers, mining drills, furnaces, oil refineries, chemical
plants, etc. Eventual goal to make these recipes extensible by other mods.

Recipes will be organized into difficulty tiers, outline of plans so far:
1. Static enable signals to operate the machine
1. Sequences of signals to operate the machine
1. Markov chain state machines (introducing machine feedback to the control circuit)
1. Single variable feedback control systems with some increase in plant complexity over the tier
1. SISO systems that are not LTI, have noise and disturbance, or otherwise may require an adaptive
   controller
1. MIMO plants, likely just LTI
1. Further combinations of these (for example, markov chain based state machine that transitions
   between different MIMO plant models during assembly)

Some will simply pause the machine's progress when the inputs are unmet and others will ideally
cause production to fail, resources to be consumed, and some kind of trash item to be produced

More complicated plants (i.e. ones based on a volterra series to capture non-LTI behavior in MIMO)
are obviously possible, but may not be playable or solvable in game (or out of game).

## Status

Sandboxing features, generally. So far:
* burner mining drills randomly drift in `tracking`, tracking far from the target value slows
  mining speed. There's no input to apply control though.
* a manual assembler entity exists that has a combinator input and a reference view attached
* static enable code works
* sequence of signals code works

## To Test

Clone into the mods folder, or clone elsewhere and symlink here as `manual-assembly_` followed by
the current version, which is in info.json and is 0.0.1 at the moment. For example:

```
cd ~/.factorio/mods
git clone https://github.com/gmalysa/factorio-manual-assembly.git manual-assembly_0.0.1
```

Then modify `mod-list.json` and add
```json
{
	"name": "manual-assembly",
	"enabled": true
}
```
alphabetically in the mod list.

## Contact

Reach me on discord or twitter, ButteryGreg#2112 or @ButteryGreg, to discuss or whatever
