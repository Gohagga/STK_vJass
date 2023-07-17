/* Entities within the system

=> TalentTree <============================================================================
A game logic object owned by and pointing to a single unit. These are some of its responsibilities:
- is built using Talents, holds their reference and their position on the grid
- keeps track of Talent (active) ranks and temporary (allocated) ranks
- keeps track of and manages "Talent points"
- manages things like talent tree title, background image, number of columns and rows
- responsible for activating/deactivating, applying/removing effects of Talents upon its unit


[How to use]
TalentTree struct contains behaviors integrated with the system itself.
It is meant to be INHERITED by the user, creating a custom talent tree, in example; Shepherd. In rpgs these could be Warrior, Mage, Cleric etc.

After creating a new type of TalentTree, override "Initialize", and other methods as needed

[Properties]
-> public string title
    Name of the talent tree, shown on the Talent tree window
    this.title

-> public integer talentPoints
    Internal variable for tracking talent points. Unused if talent points are held externally e.g. Lumber
    this.talentPoints

-> public string backgroundImage
    Path to the texture that will be rendered in TalentTree background.

[Overrideable methods]
-> stub method Initialize takes nothing returns nothing
    Always override when creating a new type of talent tree. Used for setting up the talent tree with row number, column number, background image, talent points, title. Then add Talents to it and customize their behavior.

-> stub method SetTalentPoints takes integer points returns nothing
    Override when your Talent points are held externally, e.g. if you are using Lumber to track talent points, change player's Lumber to given value.

-> stub method GetTalentPoints takes nothing returns integer
    Override when your Talent points are held externally, e.g. if you are using Lumber to track talent points, return player's Lumber value.

-> stub method GetTitle takes nothing returns string
    Override when you want to show some dynamic info in the title, e.g. number of Talent points

[Public methods used during Initialize]
-> method SetIdColumnsRows takes integer id, integer columns, integer rows returns nothing
    Sets TalentTree Id which is important for save-loading
    Sets number of columns and rows according which Talents will be rendered on the grid
    call this.SetColumnsRows(4, 7)

-> method CreateTalent takes nothing returns STKTalent_Talent
    Creates an unmodified Talent object, ready to be configured
    local STKTalent_Talent t = this.CreateTalent()

-> method CreateTalentCopy tales STKTalent_Talent data returns STKTalent_Talent
    Creates a copy of given talent and returns it, ready to be tweaked.
    local STKTalent_Talent t = this.CreateTalentCopy(t)

-> method AddTalent takes integer x, integer y, STKTalent_Talent talent returns STKTalent_Talent
    Adds talent to the talent tree at grid position (starts from bottom left being (0, 0))
    Given talent object should be configured
    call this.AddTalent(1, 0, t)

-> method AddTalentCopy takes integer x, integer y, STKTalent_Talent data returns STKTalent_Talent
    Creates a copy of given talent and adds it to the talent tree at grid position (starts from bottom left being (0, 0))
    Given talent object should be configured
    local STKTalent_Talent t = this.AddTalentCopy(1, 2, oldTalent)

-> method SaveTalentRankState takes nothing returns nothing
    Call this at the end of Initialize when some Talents start with certain rank
    call this.SaveTalentRankState()

[Event methods used inside Activate/Deactivate/Allocate/Deallocate/Requirements callback functions]
-> static method GetEventUnit takes nothing returns unit
    Returns unit that owns the talent tree
    local unit u = thistype.GetEventUnit()

-> static method GetEventTalent takes nothing returns STKTalent_Talent
    Returns talent object that is being resolved
    local STKTalent_Talent t = thistype.GetEventTalent()

-> static method GetEventRank takes nothing returns integer
    Returns rank of the talent that is being activated/deactivated/allocated/deallocated
    local integer r = thistype.GetEventRank()

-> static method GetEventTalentTree takes nothing returns TalentTree
    Returns the talent tree instance whose Talent is triggering the event
    local STKTalentTree_TalentTree tt = thistype.GetEventTalentTree()

-> static method SetTalentRequirementsResult takes string requirements returns nothing
    Needs to be called within Requirements function to disable the talent.
    If method is not called, requirements is considered fulfilled.
    Example below requires "8 litres of milk".
    thistype.SetTalentRequirementsResult("8 litres of milk")
===========================================================================================


=> Talent <================================================================================
Created inside Initialize method of a TalentTree, it contains all necessary data for showing/rendering and logic to apply on unit upon activation/deactivation/allocation. By itself, it does not keep track of ranks, one talent object corresponds to a single rank on its TalentTree. Each talent rank is its own Talent object, with its own icon, title, description, logic etc. When adding a Talent to a grid position where there is already a Talent assigned, it is added to its chain. Talents can be chained, and each new one added as a new rank and increasing their max rank.

[Public methods]
-> method SetName takes string name returns Talent
    Name of the talent, visible on hover

-> method SetDescription takes string description returns Talent
    Talent description, visible on hover

-> method SetIcon takes string name returns Talent
    Sets both enabled and disabled icon, automatically appends name to "ReplaceableTextures\\CommandButtons\\BTN" and "DISBTN"

-> method SetIconEnabled takes string path returns Talent
    Sets full path of enabled icon

-> method SetIconDisabled takes string path returns Talent
    Sets full path of enabled icon

-> method SetOnAllocate takes code func returns Talent
    Sets callback function that is triggered when talent point is allocated into this talent (before being activated)

-> method SetOnDeallocate takes code func returns Talent
    Sets callback function that is triggered when talent point is removed from this talent, e.g. through Cancel button (before being activated)
    
-> method SetOnActivate takes code func returns Talent
    Sets callback function that is triggered when talent is activated (Confirm is clicked and point is allocated)

-> method SetOnDeactivate takes code func returns Talent
    Sets callback function that is triggered when talent is deactivated (When talent tree is fully reset)

-> method SetRequirements takes code func returns Talent
    Sets callback function that can prevent allocating points into this talent with a custom message

-> method SetDependencies takes integer left, integer up, integer right, integer down returns Talent
    A talent with dependency will require talent in that direction to have given amount of levels before points can be allocated into itself

-> method SetCost takes integer cost returns Talent
    Cost is how much points the talent requires to be taken

-> method SetChainId takes integer saveId returns Talent
    Important for save-loading, each talent chain should have its own id (unique per talent tree). Do not reuse old ids for new talents.
===========================================================================================


=> ITalentTreeView and TalentTreeView =====================================================
Connects the TalentTreeViewModel object with actual which make up the TalentTree screen, with Confirm, Cancel and Close buttons.

TalentTreeView contains a method that returns a ITalentTreeView instance for a single TalentTree.
Can write your own version if you already have existing UI creation code, have created UI through .fdf files and want to connect it to the system. Create a struct that implements ITalentTreeView and write a function that creates/hydrates and returns this struct. If player can only ever be shown a single Talent tree, it is okay to return the same set of frame references every time.
===========================================================================================


=> ITalentView and TalentView =============================================================
Connects the TalentViewModel object with actual frames which make up a single Talent. It will be manipulated as players click and hover, changing title, icons, enabling/disabling etc. Within setup, these structs are used to hook up the system with actual UI frames.

TalentView contains a method that returns a ITalentView instance for a single Talent.
Can write your own version but have a warning, when called, this function should always create a new set of frames, otherwise, only one Talent button will ever be visible.
===========================================================================================


=> ITalentSlot and TalentViewModel ========================================================
Contains behavior of a TalentView during events specified by ITalentSlot and handles rendering of the view based on data from a Talent instance.

Can write your own version but not recommended without a good knowledge of this system.
===========================================================================================

=> TalentTreeViewModel ====================================================================
Internal class that holds most of the system logic, connecting TalentView, TalentTree view, TalentTree and Talent instances and gluing it all together. It keeps track of, and handles player input (Talent clicking, Confirm/Cancel clicking, talent points change etc). It reacts to Talent changes and re-renders the view.

Does not have an interface because it's not recommended or intended to write your own version.
===========================================================================================
*/

/* Save Load API
-> function RegisterTalentTree takes integer id, TalentTreeFactory factoryMethod returns boolean
    Should be called on init for every type of TalentTree implementation. This must be done so that system knows which TalentTree to
    create for the unit when loading
    call STKSaveLoad_RegisterTalentTree(1, Shepherd.LoadCreate)

-> function LoadForUnit takes unit owner, string bitString returns nothing
    Takes the bitString string, creates TalentTree instances for the unit, loads the ranks and activates talents
    call STKSaveLoad_LoadForUnit(udg_Hero, udg_BitStream)

-> function SaveForUnit takes unit owner returns string
    Takes the unit's TalentTree objects and creates a bit string with rank data
    call STKSaveLoad_SaveForUnit(udg_Hero)

-> function LoadTalentTree takes integer panelId, BSRW_BitStreamReader stream, integer talentTreeIdBits, integer talentIdBits, integer talentRankBits, unit owner returns STKTalentTree_TalentTree
    Used internally by LoadForUnit

-> function SaveTalentTree takes BSRW_BitStreamWriter stream, integer talentTreeIdBits, integer talentIdBits, integer talentRankBits, STKTalentTree_TalentTree tree returns nothing
    Used internally by SaveForUnit
*/