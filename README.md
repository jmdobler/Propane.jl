# Propane
Experimental in-dev Package that should eventually do some basic campaign planning. The fundamental idea is that any chemical process can be diveded into smaller kind-of-finished parts. The process chuncks are currently calles 'phase's. What a phase does is changing one 'state' into another more forward the value chain.

## Provides a Mini-language (DSL) for phase representation
Phases are defined in seperate modules and included to the main file. The Propane DSL defines a handful of macros that describe what happens within a phase. The defined phase is registered in the global 'SCOPE'. The Scope is a place where all defined phases and stages live. The most important function is PropaneCore.run(SCOPE). If it so happens that a state, say reasonably the state that represents the finished product of a campaign, has a demand, the run()-Function will cycle through all defined phases to equalize this demand. It will stop once there is no demand on the finished-product-state or any state passed on the way to do so.

