# AEPack
[Applied Energistics](http://ae-mod.info) pack of programs and tools for [Open Computers](https://oc.cil.li).

***

**aefind** - a search tool for querying the ME network, useful for quickly finding items and their detailed information.
**aemon** - a program which runs in an infinite loop, constantly checking the count of specific items in the attached AE network if and the levels are lower than required places crafting orders.

***

## OPPM
OPPM config snippet for local package registration:
```lua
["stsimonas/OpenPrograms"]={
	["aepack"] = {
		["files"] = {
			[":master/AEPack/bin"] = "/bin",          
			[":master/AEPack/man"] = "/man",          
			[":master/AEPack/lib"] = "/lib"
		},
		["repo"] = "tree/master/AEPack",
		["name"] = "AEPack",
		["description"] = "Applied Energistics pack of programs and tools for Open Computers",
		["authors"] = "st.simonas"
	}
}
```