library STK initializer init requires STKTalentTreeViewModel, STKITalentSlot, STKITalentView, STKTalentView, RuidTalentTreeView, STKConstants

    globals

        public constant integer MAX_TALENT_SLOTS = STKConstants_MAX_TALENT_SLOTS
        STKTalentTreeViewModel_TalentTreeViewModel array TalentUILeft[24]
        STKTalentTreeViewModel_TalentTreeViewModel array TalentUIMiddle[24]
        STKTalentTreeViewModel_TalentTreeViewModel array TalentUIRight[24]

        private hashtable Hash = InitHashtable()
        private constant integer UNIT_INIT_KEY  = 11
        private constant integer TREE_INIT_KEY  = 12
        private constant integer PANEL_INIT_KEY = 13
        private constant integer PLAYER_KEY  = 14

        ITalentView array TalentSlotFramesLeft[MAX_TALENT_SLOTS]
        ITalentView array TalentSlotFramesMiddle[MAX_TALENT_SLOTS]
        ITalentView array TalentSlotFramesRight[MAX_TALENT_SLOTS]
    endglobals

    // This function links talent framehandles like buttons, highlight textures, links to the system
    function GenerateTalentSlotLeft takes framehandle parent, integer index, integer panelId returns ITalentSlot
        local ITalentView view
        local STKTalentViewModel_TalentViewModel talentSlot

        if (TalentSlotFramesLeft[index] == 0) then
            // The system is creating frames here. If need to link existing, Comment this line and implement lines below
            set TalentSlotFramesLeft[index] = STKTalentView_GenerateTalentView(parent)
        endif
        return STKTalentViewModel_TalentViewModel.create(TalentSlotFramesLeft[index])
    endfunction

    function GenerateTalentSlotMiddle takes framehandle parent, integer index, integer panelId returns ITalentSlot
        local ITalentView view
        local STKTalentViewModel_TalentViewModel talentSlot

        if (TalentSlotFramesMiddle[index] == 0) then
            // The system is creating frames here. If need to link existing, Comment this line and implement lines below
            set TalentSlotFramesMiddle[index] = STKTalentView_GenerateTalentView(parent)
        endif
        return STKTalentViewModel_TalentViewModel.create(TalentSlotFramesMiddle[index])
    endfunction

    function GenerateTalentSlotRight takes framehandle parent, integer index, integer panelId returns ITalentSlot
        local ITalentView view
        local STKTalentViewModel_TalentViewModel talentSlot

        if (TalentSlotFramesRight[index] == 0) then
            // The system is creating frames here. If need to link existing, Comment this line and implement lines below
            set TalentSlotFramesRight[index] = STKTalentView_GenerateTalentView(parent)
        endif
        return STKTalentViewModel_TalentViewModel.create(TalentSlotFramesRight[index])
    endfunction

    // Use to add talent tree to a unit, only need to do it once

    private function InitializeTreeDelayed takes nothing returns nothing
        local integer timerKey = GetHandleId(GetExpiredTimer())
        local unit u = LoadUnitHandle(Hash, UNIT_INIT_KEY, timerKey)
        local integer playerId = GetPlayerId(GetOwningPlayer(u))
        local STKTalentTree_TalentTree tree = LoadInteger(Hash, TREE_INIT_KEY, timerKey)
        local integer panelId = LoadInteger(Hash, PANEL_INIT_KEY, timerKey)
        call DestroyTimer(GetExpiredTimer())

        call tree.Initialize()
        if (panelId == 1) then
            call TalentUILeft[playerId].SetTree(tree)
        elseif (panelId == 2) then
            call TalentUIMiddle[playerId].SetTree(tree)
        elseif (panelId == 3) then
            call TalentUIRight[playerId].SetTree(tree)
        endif
    endfunction

    private function UpdateTreeDelayed takes nothing returns nothing
        local integer timerKey = GetHandleId(GetExpiredTimer())
        local unit u = LoadUnitHandle(Hash, UNIT_INIT_KEY, timerKey)
        local integer playerId = LoadInteger(Hash, PLAYER_KEY, timerKey)
        local STKTalentTree_TalentTree tree = LoadInteger(Hash, TREE_INIT_KEY, timerKey)
        local integer panelId = LoadInteger(Hash, PANEL_INIT_KEY, timerKey)
        call DestroyTimer(GetExpiredTimer())

        if (panelId == 1) then
            call TalentUILeft[playerId].ResetTalentViewModels()
        elseif (panelId == 2) then
            call TalentUIMiddle[playerId].ResetTalentViewModels()
        elseif (panelId == 3) then
            call TalentUIRight[playerId].ResetTalentViewModels()
        endif
    endfunction

    public function AssignTalentTreeLeft takes unit u, integer createdTalentTree returns nothing
        local STKTalentTree_TalentTree talentTree = createdTalentTree
        local timer tim = CreateTimer()
        call SaveInteger(Hash, 1, GetHandleId(u), talentTree)

        call SaveUnitHandle(Hash, UNIT_INIT_KEY, GetHandleId(tim), u)
        call SaveInteger(Hash, TREE_INIT_KEY, GetHandleId(tim), talentTree)
        call SaveInteger(Hash, PANEL_INIT_KEY, GetHandleId(tim), 1)
        call TimerStart(tim, 0, false, function InitializeTreeDelayed)
    endfunction

    public function AssignTalentTreeMiddle takes unit u, integer createdTalentTree returns nothing
        local STKTalentTree_TalentTree talentTree = createdTalentTree
        local timer tim = CreateTimer()
        call SaveInteger(Hash, 2, GetHandleId(u), talentTree)

        call SaveUnitHandle(Hash, UNIT_INIT_KEY, GetHandleId(tim), u)
        call SaveInteger(Hash, TREE_INIT_KEY, GetHandleId(tim), talentTree)
        call SaveInteger(Hash, PANEL_INIT_KEY, GetHandleId(tim), 2)
        call TimerStart(tim, 0, false, function InitializeTreeDelayed)
    endfunction

    public function AssignTalentTreeRight takes unit u, integer createdTalentTree returns nothing
        local STKTalentTree_TalentTree talentTree = createdTalentTree
        local timer tim = CreateTimer()
        call SaveInteger(Hash, 3, GetHandleId(u), talentTree)

        call SaveUnitHandle(Hash, UNIT_INIT_KEY, GetHandleId(tim), u)
        call SaveInteger(Hash, TREE_INIT_KEY, GetHandleId(tim), talentTree)
        call SaveInteger(Hash, PANEL_INIT_KEY, GetHandleId(tim), 3)
        call TimerStart(tim, 0, false, function InitializeTreeDelayed)
    endfunction

    public function UpdateTalentViews takes player p returns nothing
        local integer playerId = GetPlayerId(p)
        local timer timLeft = CreateTimer()
        local timer timMiddle = CreateTimer()
        local timer timRight = CreateTimer()

        call SaveInteger(Hash, PLAYER_KEY, GetHandleId(timLeft), playerId)
        call SaveInteger(Hash, PANEL_INIT_KEY, GetHandleId(timLeft), 1)
        call TimerStart(timLeft, 0, false, function UpdateTreeDelayed)

        call SaveInteger(Hash, PLAYER_KEY, GetHandleId(timMiddle), playerId)
        call SaveInteger(Hash, PANEL_INIT_KEY, GetHandleId(timMiddle), 2)
        call TimerStart(timMiddle, 0, false, function UpdateTreeDelayed)

        call SaveInteger(Hash, PLAYER_KEY, GetHandleId(timRight), playerId)
        call SaveInteger(Hash, PANEL_INIT_KEY, GetHandleId(timRight), 3)
        call TimerStart(timRight, 0, false, function UpdateTreeDelayed)
    endfunction

    function OnTalentViewChanged takes STKTalentTreeViewModel_TalentTreeViewModel ttvm, player watcher returns nothing
        call UpdateTalentViews(watcher)
    endfunction

    // Use to show the talent tree view to a player
    public function OpenTalentsView takes player p returns nothing
        local integer playerId = GetPlayerId(p)
        call TalentUILeft[playerId].RenderTree()
        call TalentUIMiddle[playerId].RenderTree()
        call TalentUIRight[playerId].RenderTree()
    endfunction

    public function ToggleTalentsView takes player p returns nothing
        local integer playerId = GetPlayerId(p)
        if (TalentUILeft[playerId].IsWatched() or TalentUIMiddle[playerId].IsWatched() or TalentUIRight[playerId].IsWatched()) then
            call TalentUILeft[playerId].Hide()
            call TalentUIMiddle[playerId].Hide()
            call TalentUIRight[playerId].Hide()
        else
            call TalentUILeft[playerId].RenderTree()
            call TalentUIMiddle[playerId].RenderTree()
            call TalentUIRight[playerId].RenderTree()
        endif
    endfunction

    // Use to add or remove available talent points from a unit
    public function UpdateUnitTalentPoints takes unit u, integer whichTree, integer points returns nothing
        local STKTalentTree_TalentTree tree = LoadInteger(Hash, whichTree, GetHandleId(u))
        call tree.SetTalentPoints(tree.GetTalentPoints() + points)
        call TalentUILeft[GetPlayerId(GetOwningPlayer(u))].ResetTalentViewModels()
        call TalentUIMiddle[GetPlayerId(GetOwningPlayer(u))].ResetTalentViewModels()
        call TalentUIRight[GetPlayerId(GetOwningPlayer(u))].ResetTalentViewModels()
    endfunction

    // Use to make a player watch unit's talent tree
    // public function PlayerLookAtUnitsTree takes player p, unit u returns nothing
    //     local STKTalentTree_TalentTree talentTree = LoadInteger(Hash, 0, GetHandleId(u))
    //     call TalentUILeft[GetPlayerId(p)].SetTree(talentTree)
    // endfunction

    function GameBeginningSetup takes nothing returns nothing
        local integer i = 0

        // Initialize Talent UI for all players
        
        // Can substitute with your own TalentTreeView generating function =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
        // It creates the box, confirm cancel and close buttons
        local ITalentTreeView talentTreeView1 = RuidTalentTreeView_GenerateTalentTreeViewLeft(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
        local ITalentTreeView talentTreeView2 = RuidTalentTreeView_GenerateTalentTreeViewMiddle(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
        local ITalentTreeView talentTreeView3 = RuidTalentTreeView_GenerateTalentTreeViewRight(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))

        loop
            exitwhen i >= 24 // Generating talent view for all 24 players. It's recommended to only do it for necessary playerIds
            set TalentUILeft[i] = STKTalentTreeViewModel_TalentTreeViewModel.create(Player(i), talentTreeView1, GenerateTalentSlotLeft, 1, OnTalentViewChanged)
            set TalentUIMiddle[i] = STKTalentTreeViewModel_TalentTreeViewModel.create(Player(i), talentTreeView2, GenerateTalentSlotMiddle, 2, OnTalentViewChanged)
            set TalentUIRight[i] = STKTalentTreeViewModel_TalentTreeViewModel.create(Player(i), talentTreeView3, GenerateTalentSlotRight, 3, OnTalentViewChanged)

            // Talents are auto-positioned based on these params and talentree's column/row count ?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=
            set TalentUILeft[i].boxWidth = STKConstants_boxWidth
            set TalentUILeft[i].boxHeight = STKConstants_boxHeight
            set TalentUILeft[i].sideMargin = STKConstants_sideMargin
            set TalentUILeft[i].verticalMargin = STKConstants_verticalMargin
            
            set TalentUIMiddle[i].boxWidth = STKConstants_boxWidth
            set TalentUIMiddle[i].boxHeight = STKConstants_boxHeight
            set TalentUIMiddle[i].sideMargin = STKConstants_sideMargin
            set TalentUIMiddle[i].verticalMargin = STKConstants_verticalMargin

            set TalentUIRight[i].boxWidth = STKConstants_boxWidth
            set TalentUIRight[i].boxHeight = STKConstants_boxHeight
            set TalentUIRight[i].sideMargin = STKConstants_sideMargin
            set TalentUIRight[i].verticalMargin = STKConstants_verticalMargin
            // =?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=?=

            set i = i + 1
        endloop
    endfunction

    function init takes nothing returns nothing
        local timer tim = CreateTimer()
        call TimerStart(tim, 0, false, function GameBeginningSetup)
    endfunction
endlibrary