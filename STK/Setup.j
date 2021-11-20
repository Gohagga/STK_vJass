library STK initializer init requires STKTalentTreeViewModel, STKITalentSlot, STKITalentView, STKTalentView, STKTalentTreeView, STKConstants

    globals

        public constant integer MAX_TALENT_SLOTS = STKConstants_MAX_TALENT_SLOTS
        STKTalentTreeViewModel_TalentTreeViewModel array TalentUI[24]

        private hashtable Hash = InitHashtable()
        ITalentView array TalentSlotFrames[300]
    endglobals

    // This function links talent framehandles like buttons, highlight textures, links to the system
    function GenerateTalentSlot takes framehandle parent, integer index, integer panelId returns ITalentSlot
        local ITalentView view
        local STKTalentViewModel_TalentViewModel talentSlot

        if (TalentSlotFrames[index] == 0) then
            // The system is creating frames here. If need to link existing, Comment this line and implement lines below
            set TalentSlotFrames[index] = STKTalentView_GenerateTalentView(parent)

            // Uncomment to link your own frames =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
            // set view = STKTalentView_TalentView.create()
            // set TalentSlotFrames[index] = view

            // set view.buttonMain    = 
            // set view.buttonImage   = 
            // set view.tooltipBox    = 
            // set view.tooltipText   = 
            // set view.tooltipRank   = 
            // set view.rankImage     = 
            // set view.rankText      = 
            // set view.highlight     = 

            // set view.linkLeft      = 
            // set view.linkUp        = 
            // set view.linkRight     = 
            // set view.linkDown      = 
            // =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
        endif

        return STKTalentViewModel_TalentViewModel.create(TalentSlotFrames[index])
    endfunction

    // Use to add talent tree to a unit, only need to do it once
    public function AssignTalentTree takes unit u, integer createdTalentTree returns nothing
        local STKTalentTree_TalentTree talentTree = createdTalentTree
        local integer playerId = GetPlayerId(GetOwningPlayer(u))
        call SaveInteger(Hash, 0, GetHandleId(u), talentTree)
        call talentTree.Initialize()
        call TalentUI[playerId].SetTree(talentTree)
    endfunction

    // Use to show the talent tree view to a player
    public function OpenTalentsView takes player p returns nothing
        local integer playerId = GetPlayerId(p)
        call TalentUI[playerId].RenderTree()
    endfunction

    // Use to add or remove available talent points from a unit
    public function UpdateUnitTalentPoints takes unit u, integer points returns nothing
        local STKTalentTree_TalentTree tree = LoadInteger(Hash, 0, GetHandleId(u))
        call tree.SetTalentPoints(tree.GetTalentPoints() + points)
        call TalentUI[GetPlayerId(GetOwningPlayer(u))].ResetTalentViewModels()
    endfunction

    // Use to make a player watch unit's talent tree
    public function PlayerLookAtUnitsTree takes player p, unit u returns nothing
        local STKTalentTree_TalentTree talentTree = LoadInteger(Hash, 0, GetHandleId(u))
        call TalentUI[GetPlayerId(p)].SetTree(talentTree)
    endfunction

    function GameBeginningSetup takes nothing returns nothing
        local integer i = 0

        // Initialize Talent UI for all players
        
        // Can substitute with your own TalentTreeView generating function =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
        // It creates the box, confirm cancel and close buttons
        local ITalentTreeView talentTreeView = STKTalentTreeView_GenerateTalentTreeView(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))

        loop
            exitwhen i >= 24 // Generating talent view for all 24 players. It's recommended to only do it for necessary playerIds
            set TalentUI[i] = STKTalentTreeViewModel_TalentTreeViewModel.create(Player(i), talentTreeView, GenerateTalentSlot, 1)

            // Talents are auto-positioned based on these params and talentree's column/row count ?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
            set TalentUI[i].boxWidth = 0.3
            set TalentUI[i].boxHeight = 0.44
            set TalentUI[i].sideMargin = 0.1
            set TalentUI[i].verticalMargin = 0.15
            // =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=

            set i = i + 1
        endloop
    endfunction

    function init takes nothing returns nothing
        local timer tim = CreateTimer()
        call TimerStart(tim, 1, false, function GameBeginningSetup)
    endfunction
endlibrary