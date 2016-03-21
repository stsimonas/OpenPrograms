# AEPack
[Applied Energistics](http://ae-mod.info) pack of programs and tools for [Open Computers](https://oc.cil.li).

***

**aefind** - a search tool for querying the ME network, useful for quickly finding items and their detailed information.

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