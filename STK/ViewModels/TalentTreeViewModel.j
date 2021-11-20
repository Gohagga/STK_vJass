library STKTalentTreeViewModel requires STKITalentSlot

    globals
        private constant integer FRAME_INDEX_KEY = 0
        private constant integer FRAME_PANEL_ID = 0
        private integer array Instances[300]
        private integer InstanceCount = 0
        private hashtable FrameIndex = InitHashtable()
        private trigger ClickTrigger = null
        private trigger ConfirmTrigger = null
        private trigger CancelTrigger = null
        private trigger CloseTrigger = null
    endglobals

    function interface TalentSlotFactory takes framehandle parent, integer index, integer panelId returns ITalentSlot

    private function ConcatenateErrors takes string err1, string err2 returns string
        if (err1 == null and err2 == null) then
            return null
        elseif (err1 == null) then
            return err2
        elseif (err2 == null) then
            return err1
        endif
        return err1 + ", " + err2
    endfunction

    public struct TalentTreeViewModel

        private player watcher
        private boolean watched = false
        private STKTalentTree_TalentTree tree = 0

        private ITalentTreeView view
        private framehandle parent
        private integer panelId
        private ITalentSlot array slots[STKTalentTree_MAX_TALENTS]
        private integer slotCount = STKTalentTree_MAX_TALENTS

        // UI config ===============================================================
        public real boxWidth = 0
        public real boxHeight = 0
        public real sideMargin = 0
        public real verticalMargin = 0
        // End UI config ===============================================================

        static method SetUpTriggersIfNeeded takes nothing returns nothing
            if (ClickTrigger == null) then
                set ClickTrigger = CreateTrigger()
                call TriggerAddAction(ClickTrigger, function thistype.TalentButtonClicked)
            endif

            if (ConfirmTrigger == null) then
                set ConfirmTrigger = CreateTrigger()
                call TriggerAddAction(ConfirmTrigger, function thistype.ConfirmButtonClicked)
            endif

            if (CancelTrigger == null) then
                set CancelTrigger = CreateTrigger()
                call TriggerAddAction(CancelTrigger, function thistype.CancelButtonClicked)
            endif

            if (CloseTrigger == null) then
                set CloseTrigger = CreateTrigger()
                call TriggerAddAction(CloseTrigger, function thistype.CloseButtonClicked)
            endif
        endmethod

        static method SetUpSlotTriggersIfNeeded takes ITalentSlot slot, integer i, integer panelId returns nothing
            local integer fi = LoadInteger(FrameIndex, FRAME_INDEX_KEY + panelId, GetHandleId(slot.GetButtonFrame()))
            if (fi == 0) then
                call BlzTriggerRegisterFrameEvent(ClickTrigger, slot.GetButtonFrame(), FRAMEEVENT_CONTROL_CLICK)
                call SaveInteger(FrameIndex, FRAME_PANEL_ID, GetHandleId(slot.GetButtonFrame()), panelId)
                call SaveInteger(FrameIndex, FRAME_INDEX_KEY + panelId, GetHandleId(slot.GetButtonFrame()), i + 1)
            endif
        endmethod

        static method SetUpActionTriggersIfNeeded takes ITalentTreeView view returns nothing
            if (LoadInteger(FrameIndex, FRAME_INDEX_KEY, GetHandleId(view.confirmButtonMain)) == 0) then
                call BlzTriggerRegisterFrameEvent(ConfirmTrigger, view.confirmButtonMain, FRAMEEVENT_CONTROL_CLICK)
                call SaveInteger(FrameIndex, FRAME_INDEX_KEY, GetHandleId(view.confirmButtonMain), 1)
            endif
            if (LoadInteger(FrameIndex, FRAME_INDEX_KEY, GetHandleId(view.cancelButtonMain)) == 0) then
                call BlzTriggerRegisterFrameEvent(CancelTrigger, view.cancelButtonMain, FRAMEEVENT_CONTROL_CLICK)
                call SaveInteger(FrameIndex, FRAME_INDEX_KEY, GetHandleId(view.cancelButtonMain), 1)
            endif
            if (LoadInteger(FrameIndex, FRAME_INDEX_KEY, GetHandleId(view.closeButton)) == 0) then
                call BlzTriggerRegisterFrameEvent(CloseTrigger, view.closeButton, FRAMEEVENT_CONTROL_CLICK)
                call SaveInteger(FrameIndex, FRAME_INDEX_KEY, GetHandleId(view.closeButton), 1)
            endif
        endmethod

        static method create takes player watcher, ITalentTreeView view, TalentSlotFactory talentSlotFactory, integer panelId returns TalentTreeViewModel
            local TalentTreeViewModel this = TalentTreeViewModel.allocate()
            local ITalentSlot slot
            local integer i = 0

            local framehandle f

            set this.view = view
            set this.watcher = watcher
            set this.parent = view.box
            set this.panelId = panelId
            
            call thistype.SetUpTriggersIfNeeded()

            // Set up the talent slots
            loop
                exitwhen i == STKTalentTree_MAX_TALENTS

                // Create a new slot
                set slot = talentSlotFactory.evaluate(view.box, i, panelId)
                set this.slots[i] = slot

                // Set its watcher to this watcher
                call slot.SetWatcher(watcher)
                call thistype.SetUpSlotTriggersIfNeeded(slot, i, panelId)

                set i = i + 1
            endloop

            call thistype.SetUpActionTriggersIfNeeded(view)

            set Instances[InstanceCount] = this
            set InstanceCount = InstanceCount + 1

            call this.Hide()
            return this
        endmethod

        method TalentClicked takes integer index returns nothing
            local ITalentSlot slot = this.slots[index]
            local STKTalent_Talent talent = 0
            local integer tempState

            if (this.watched == false) then
                return
            endif

            if (this.tree == 0) then
                return
            endif

            set talent = this.tree.talents[index]
            if (talent == 0) then
                return
            endif

            set tempState = this.tree.tempRankState[index]
            if (this.tree.pointsAvailable >= talent.cost and tempState < talent.maxRank) then

                call this.tree.ApplyTalentTemporary(index)
                set tempState = this.tree.tempRankState[index]
                call this.ResetTalentViewModels()
            endif
        endmethod

        method OnConfirm takes nothing returns nothing
            
            if (this.tree != 0) then
                call this.tree.SaveTalentRankState()
                call this.ResetTalentViewModels()
            endif

        endmethod

        method OnCancel takes nothing returns nothing
            
            if (this.tree != 0) then
                call this.tree.ResetTempRankState()
                call this.ResetTalentViewModels()
            endif

        endmethod

        method UpdatePointsAndTitle takes nothing returns nothing
            if (GetLocalPlayer() != this.watcher) then
                return
            endif

            if (tree != 0) then
                call BlzFrameSetText(this.view.title, this.tree.GetTitle())
            endif
        endmethod

        method ResetTalentViewModels takes nothing returns nothing

            local integer i = 0
            local ITalentSlot slot
            local STKTalent_Talent talent

            if (this.tree == 0 or this.tree == null) then
                return
            endif

            loop
                exitwhen i == this.slotCount

                set slot = this.slots[i]
                set talent = this.tree.talents[i]

                if (talent != 0) then
                    // Update Talent Slot from Talent
                    call slot.SetTalent(talent)
                    call this.UpdateTalentSlot(slot, talent, this.tree, i)
                else
                    call slot.SetState(0)
                endif

                set i = i + 1
            endloop
            // Update points
            call this.UpdatePointsAndTitle()
        endmethod

        method SetTree takes STKTalentTree_TalentTree tree returns nothing
            set this.tree = tree
            call this.ResetTalentViewModels()
        endmethod

        method IsWatched takes nothing returns boolean
            return this.watched
        endmethod

        // Show
        method RenderTree takes nothing returns nothing
            local STKTalentTree_TalentTree tree
            local integer cols = 0
            local integer rows = 0
            local real xIncrem = 0
            local real yIncrem = 0
            local integer i = 0
            local ITalentSlot slot
            local real x
            local real y

            set this.watched = true

            if (this.tree == 0) then
                return
            endif

            // Reorganize the talents
            set tree = this.tree
            set cols = tree.columns
            set rows = tree.rows

            set xIncrem = (this.boxWidth * (1 - this.sideMargin)) / (cols + 1)
            set yIncrem = (this.boxHeight * (1 - this.verticalMargin)) / (rows + 1)

            // call BJDebugMsg("sidem " + R2S(this.sideMargin) + " vertim " + R2S(this.verticalMargin) + " boxw " + R2S(this.boxWidth) + " boxh " + R2S(this.boxHeight))
            // call BJDebugMsg("Cols " + I2S(cols) + " Rows " + I2S(rows) + " xinc " + R2S(xIncrem) + " yinc " + R2S(yIncrem))
            // call BJDebugMsg("Slots Count " + I2S(this.slotCount))

            call this.ResetTalentViewModels()

            set i = 0
            loop
                exitwhen i >= this.slotCount
                // call BJDebugMsg("i " + I2S(i) + " / " + I2S(this.slotCount))
                set slot = this.slots[i]
                
                set x = R2I(ModuloInteger(i, cols)) * xIncrem - ((cols - 1) * 0.5) * xIncrem
                set y = R2I((i) / cols) * yIncrem - ((rows - 1) * 0.5) * yIncrem
                
                // call BJDebugMsg("Moving slot " + I2S(slot) + " x: " + R2S(x) + ", y: " + R2S(y))
                call slot.MoveTo(FRAMEPOINT_CENTER, this.view.container, FRAMEPOINT_CENTER, x, y, xIncrem, yIncrem)

                if (tree.talents[i] != 0) then
                    // call slot.SetTalent(tree.talents[i])
                    // call UpdateTalentSlot(slot, tree.talents[i], tree, i)
                    // call BJDebugMsg("Setting visible")
                    call slot.SetVisible(true)
                else
                    // call slot.SetVisible(false)
                endif

                set i = i + 1
            endloop
            
            if (GetLocalPlayer() != this.watcher) then
                return
            endif

            call BlzFrameSetVisible(this.view.box, true)
        endmethod

        method Hide takes nothing returns nothing
            
            local integer i = 0
            set this.watched = false
    
            // for (let i = 0; i < this._slots.length; i++) {
            //     this._slots[i].visible = false;
            // }
    
            if (GetLocalPlayer() != this.watcher) then
                return
            endif

            call BlzFrameSetVisible(this.view.box, false)
        endmethod

        method UpdateTalentSlot takes ITalentSlot slot, STKTalent_Talent talent, STKTalentTree_TalentTree tree, integer index returns nothing
            
            local integer tempState = tree.tempRankState[index]
            // State Available
            local integer state = 3
            local boolean dep = false
            local boolean req = false
            local boolean depOk = true
            local boolean reqOk = true
            local string depError
            local string reqError

            local string depLeft = tree.CheckDependencyKeyLeft(talent.dependencyLeft, index)
            local string depUp = tree.CheckDependencyKeyUp(talent.dependencyUp, index)
            local string depRight = tree.CheckDependencyKeyRight(talent.dependencyRight, index)
            local string depDown = tree.CheckDependencyKeyDown(talent.dependencyDown, index)

            call slot.SetRank(tempState)
            call slot.RenderLinks(depLeft, depUp, depRight, depDown)

            call slot.SetErrorText("")
            set depOk = true
            set reqOk = true

            set depError = ""
            set reqError = ""

            if (depLeft == null and depUp == null and depRight == null and depDown == null) then
                set depOk = true
            else
                set depOk = false
                set depError = ConcatenateErrors(depLeft, depUp)
                set depError = ConcatenateErrors(depError, depRight)
                set depError = ConcatenateErrors(depError, depDown)
            endif

            set reqError = tree.CalculateTalentRequirements(talent)
            set reqOk = false
            if (reqError == null) then
                set reqOk = true
                set reqError = null
            endif

            if (tempState == talent.maxRank) then
                // call BJDebugMsg("STATE 4")
                call slot.SetState(4) // Maxed
            elseif (depOk and reqOk and talent.cost <= tree.pointsAvailable) then
                // call BJDebugMsg("STATE 3")
                call slot.SetState(3) // Available
            else
                call slot.SetErrorText(depError + reqError)

                call slot.SetState(1)
                if (reqOk) then
                    // call BJDebugMsg("STATE 1")
                    call slot.SetState(1) // RequireDisabled
                elseif (depOk) then
                    // call BJDebugMsg("STATE 2")
                    call slot.SetState(2) // DependDisabled
                endif
            endif
        endmethod

        static method TalentButtonClicked takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local integer panelId = LoadInteger(FrameIndex, FRAME_PANEL_ID, GetHandleId(frame))
            local integer index = LoadInteger(FrameIndex, FRAME_INDEX_KEY + panelId, GetHandleId(frame)) - 1
            local player clickingPlayer = GetTriggerPlayer()
            local thistype ttvm
            local integer i = 0

            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)

            loop
                exitwhen i == InstanceCount
                set ttvm = Instances[i]
                if (ttvm != 0 and ttvm.watcher == clickingPlayer and ttvm.panelId == panelId) then
                    call ttvm.TalentClicked(index)
                endif
                set i = i + 1
            endloop
        endmethod

        static method ConfirmButtonClicked takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local player clickingPlayer = GetTriggerPlayer()
            local thistype ttvm
            local integer i = 0

            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)

            loop
                exitwhen i == InstanceCount
                set ttvm = Instances[i]
                if (ttvm != 0 and ttvm.watcher == clickingPlayer) then
                    call ttvm.OnConfirm()
                endif
                set i = i + 1
            endloop
        endmethod

        static method CancelButtonClicked takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local player clickingPlayer = GetTriggerPlayer()
            local thistype ttvm
            local integer i = 0

            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)
            
            loop
                exitwhen i == InstanceCount
                set ttvm = Instances[i]
                if (ttvm != 0 and ttvm.watcher == clickingPlayer) then
                    call ttvm.OnCancel()
                endif
                set i = i + 1
            endloop
        endmethod

        static method CloseButtonClicked takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local player clickingPlayer = GetTriggerPlayer()
            local thistype ttvm
            local integer i = 0

            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)

            loop
                exitwhen i == InstanceCount
                set ttvm = Instances[i]
                if (ttvm != 0 and ttvm.watcher == clickingPlayer) then
                    // call ttvm.OnClose()
                    call ttvm.Hide()
                endif
                set i = i + 1
            endloop
        endmethod        

        method onDestroy takes nothing returns nothing
            set Instances[this] = 0
        endmethod

    endstruct
endlibrary

