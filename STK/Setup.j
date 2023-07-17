library STK initializer init requires STKTalentTreeViewModel, STKITalentSlot, STKITalentView, STKTalentView, STKTalentTreeView, STKConstants, STKStore

    globals

        public constant integer MAX_TALENT_SLOTS = STKConstants_MAX_TALENT_SLOTS
        public constant integer MAX_PLAYER_COUNT = STKConstants_MAX_PLAYER_COUNT

        private STKStore store
    endglobals

    // This function links talent framehandles like buttons, highlight textures, links to the system
    function GenerateTalentSlot takes framehandle parent, integer index, integer panelId returns ITalentSlot
        local ITalentView view
        local STKTalentViewModel_TalentViewModel talentSlot

        if (store.GetTalentView(panelId, index) == 0) then
            // The system is creating frames here. If need to link existing, Comment this line and implement lines below
            call store.SetTalentView(panelId, index, STKTalentView_GenerateTalentView(parent))
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

        return STKTalentViewModel_TalentViewModel.create(store.GetTalentView(panelId, index))
    endfunction

    // Use to add talent tree to a unit, only need to do it once
    public function AssignTalentTree takes integer panelId, unit u, STKTalentTree_TalentTree createdTalentTree returns nothing
        local integer playerId = GetPlayerId(GetOwningPlayer(u))
        call store.SetUnitTalentTree(panelId, u, createdTalentTree)
        call createdTalentTree.Initialize()
        call store.GetPlayerTalentTreeViewModel(panelId, playerId).SetTree(createdTalentTree)
    endfunction

    // Use to show the talent tree view to a player
    public function OpenTalentScreen takes player p returns nothing
        local integer playerId = GetPlayerId(p)
        local integer i = 0
        local STKTalentTreeViewModel_TalentTreeViewModel ttvm
        loop
            set ttvm = store.GetPlayerTalentTreeViewModel(i, playerId)
            exitwhen ttvm == 0
            call ttvm.RenderTree()
            set i = i + 1
        endloop
    endfunction

    // Use to add or remove available talent points from a unit
    public function UpdateUnitTalentPoints takes integer panelId, unit u, integer points returns nothing
        local integer playerId = GetPlayerId(GetOwningPlayer(u))
        local STKTalentTree_TalentTree tree = store.GetUnitTalentTree(panelId, u)
        local STKTalentTreeViewModel_TalentTreeViewModel ttvm
	    call tree.SetTalentPoints(tree.GetTalentPoints() + points)
        set panelId = 0
        loop
            set ttvm = store.GetPlayerTalentTreeViewModel(panelId, playerId)
            exitwhen ttvm == 0
            call ttvm.ResetTalentViewModels()
            set panelId = panelId + 1
        endloop
    endfunction

    // Use to reset a unit's talent tree
    public function ResetUnitTalentTree takes integer panelId, unit u returns nothing
        local STKTalentTree_TalentTree tree = store.GetUnitTalentTree(panelId, u)
        call tree.ResetTalentRankState()
        call store.GetPlayerTalentTreeViewModel(panelId, GetPlayerId(GetOwningPlayer(u))).ResetTalentViewModels()
    endfunction

    // Use to make a player watch unit's talent tree
    public function PlayerLookAtUnitsTree takes integer panelId, player p, unit u returns nothing
        local STKTalentTree_TalentTree tree = store.GetUnitTalentTree(panelId, u)
        call store.GetPlayerTalentTreeViewModel(panelId, GetPlayerId(GetOwningPlayer(u))).SetTree(tree)
    endfunction

    function GameBeginningSetup takes nothing returns nothing
        local integer i = 0
        local STKTalentTreeViewModel_TalentTreeViewModel ttvm

        // Initialize Talent UI for all players
        
        // Can substitute with your own TalentTreeView generating function =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
        // It creates the box, confirm cancel and close buttons
        local ITalentTreeView talentTreeView = STKTalentTreeView_GenerateTalentTreeView(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
        loop
            exitwhen i >= MAX_PLAYER_COUNT // Generating talent view for all 24 players. It's recommended to only do it for necessary playerIds
            set ttvm = STKTalentTreeViewModel_TalentTreeViewModel.createSingleView(Player(i), talentTreeView, GenerateTalentSlot)
            call store.SetPlayerTalentTreeViewModel(0, i, ttvm)

            // Talents are auto-positioned based on these params and talentree's column/row count ?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
            set ttvm.boxWidth = STKConstants_BOX_WIDTH
            set ttvm.boxHeight = STKConstants_BOX_HEIGHT
            set ttvm.sideMargin = STKConstants_SIDE_MARGIN
            set ttvm.verticalMargin = STKConstants_VERTICAL_MARGIN
            // =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=

            set i = i + 1
        endloop
    endfunction

    function init takes nothing returns nothing
        local timer tim = CreateTimer()
        set store = STKStore.create()
        call TimerStart(tim, 1, false, function GameBeginningSetup)
    endfunction
endlibrary