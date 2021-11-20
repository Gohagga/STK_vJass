library STKTalentTree initializer init requires STKTalent, STKConstants

    globals
        public constant integer MAX_ROWS        = STKConstants_MAX_ROWS
        public constant integer MAX_COLUMNS     = STKConstants_MAX_COLUMNS

        public constant integer MAX_TALENTS = STKConstants_MAX_TALENT_SLOTS

        // Event variables
        public unit EventUnit
        public integer EventTalentTree
        public integer EventTalent
        public integer EventRank
        // Event result
        public string ResultTalentRequirements
    endglobals

    public struct TalentTree

        public unit ownerUnit
        public player ownerPlayer
        public string icon             = ""
        public string title            = ""
        public integer pointsAvailable = 0

        public STKTalent_Talent array talents[MAX_TALENTS]
        public integer array rankState[MAX_TALENTS]
        public integer array tempRankState [MAX_TALENTS]
        private boolean isDirty = false

        public integer rows = MAX_ROWS
        public integer columns = MAX_COLUMNS
        public integer maxTalents = MAX_TALENTS
        
        stub method Initialize takes nothing returns nothing

        endmethod

        private method AddTalentRaw takes integer x, integer y, STKTalent_Talent talent returns STKTalent_Talent
            local integer index = x + y * this.columns
            local STKTalent_Talent existing

            // If talent already exists
            if (this.talents[index] != 0) then

                // If talent is multirank, handle it differently
                if (this.talents[index].maxRank > 1) then
                    call this.talents[index].RemoveTalentFinalDescription()
                    call this.talents[index].SetLastRank(talent)
                    call this.talents[index].SetTalentFinalDescription()
                    call this.talents[index].UpdateMaxRank()
                else
                    call this.talents[index].SetLastRank(talent)
                    call this.talents[index].SetTalentFinalDescription()
                    call this.talents[index].UpdateMaxRank()
                endif
            else
                set this.talents[index] = talent
                set this.rankState[index] = 0
                call this.talents[index].UpdateMaxRank()
            endif

            if (this.tempRankState[index] != talent.startingLevel) then
                set this.isDirty = true
            endif
            set this.tempRankState[index] = talent.startingLevel

            return talent
        endmethod

        // Grid starts from bottom left being (0, 0)
        method AddTalent takes integer x, integer y, STKTalent_Talent talent returns STKTalent_Talent
            return this.AddTalentRaw(x, y, talent)
        endmethod

        // Grid starts from bottom left being (0, 0)
        method AddTalentCopy takes integer x, integer y, STKTalent_Talent data returns STKTalent_Talent
            local STKTalent_Talent talent = STKTalent_Talent.createCopy(data)
            return this.AddTalentRaw(x, y, talent)
        endmethod

        method CreateTalent takes nothing returns STKTalent_Talent
            local STKTalent_Talent talent = STKTalent_Talent.create()
            call talent.SetCost(1)
            return talent
        endmethod

        // Talent callbacks =======================================================================================
        method ActivateTalent takes STKTalent_Talent talent, integer rank returns nothing
            set EventUnit = this.ownerUnit
            set EventTalentTree = this
            set EventTalent = talent
            set EventRank = rank

            if (talent.onActivate != null) then
                call TriggerEvaluate(talent.onActivate)
            endif
        endmethod

        method AllocateTalent takes STKTalent_Talent talent returns nothing
            set EventUnit = this.ownerUnit
            set EventTalentTree = this
            set EventTalent = talent
            set EventRank = talent.GetTalentRank()

            if (talent.onAllocate != null) then
                call TriggerEvaluate(talent.onAllocate)
            endif
        endmethod

        method DeallocateTalent takes STKTalent_Talent talent returns nothing
            set EventUnit = this.ownerUnit
            set EventTalentTree = this
            set EventTalent = talent
            set EventRank = talent.GetTalentRank()

            if (talent.onDeallocate != null) then
                call TriggerEvaluate(talent.onDeallocate)
            endif
        endmethod

        method ActivateTalentRecursively takes STKTalent_Talent talent, integer count, integer rank returns nothing
            if (talent.previousRank != 0 and count > 1) then
                call this.ActivateTalentRecursively(talent.previousRank, count - 1, rank)
            endif

            call this.ActivateTalent(talent, rank - count)
        endmethod

        method CalculateTalentRequirements takes STKTalent_Talent talent returns string
            set EventUnit = this.ownerUnit
            set EventTalentTree = this
            
            set ResultTalentRequirements = null
            if (talent.requirements != null) then
                call TriggerEvaluate(talent.requirements)
            endif

            return ResultTalentRequirements
        endmethod

        // End Talent callbacks =======================================================================================

        method SaveTalentRankState takes nothing returns nothing

            local integer i = 0

            if (this.isDirty == false) then
                return
            endif
            
            loop
                exitwhen i == this.maxTalents

                if (this.talents[i] != 0) then
                    if (this.rankState[i] != this.tempRankState[i]) then

                        if (this.talents[i].previousRank != 0) then
                            call this.ActivateTalentRecursively(this.talents[i].previousRank, this.tempRankState[i] - this.rankState[i], this.tempRankState[i] + 1)
                        else
                            call this.ActivateTalentRecursively(this.talents[i], this.tempRankState[i] - this.rankState[i], this.tempRankState[i] + 1)
                        endif
                        set this.rankState[i] = this.tempRankState[i]
                    endif
                endif

                set i = i + 1
            endloop

            call this.ResetTempRankState()
        endmethod

        method ResetTempRankState takes nothing returns nothing

            local integer i = 0
            local integer j = 0
            local STKTalent_Talent talent
            local STKTalent_Talent talent2

            if (this.isDirty == false) then
                return
            endif

            loop
                exitwhen i == this.maxTalents
                
                set talent = this.talents[i]
                if (talent != 0 and this.rankState[i] != this.tempRankState[i]) then

                    // set this.pointsAvailable = this.pointsAvailable + talent.cost
                    set j = this.tempRankState[i]
                    if (talent.maxRank == 1 and j > this.rankState[i]) then
                        call this.DeallocateTalent(talent)
                        set this.pointsAvailable = this.pointsAvailable + talent.cost
                    else
                        set talent2 = talent.previousRank
                        loop
                            // TODO
                            exitwhen j <= this.rankState[i] or talent2 == 0
                            call this.DeallocateTalent(talent2)
                            set this.pointsAvailable = this.pointsAvailable + talent2.cost
                            set talent2 = talent2.previousRank
                            set j = j - 1
                        endloop
                    endif
                endif

                // Loop until zero level
                set j = this.tempRankState[i]
                loop
                    exitwhen j < 0
                    
                    // Reset the UI to lowest
                    if (talent.previousRank != 0) then
                        set talent = talent.previousRank
                    endif

                    set j = j - 1
                endloop

                // Then level it up back to the current rankState
                set j = 1
                loop
                    exitwhen j > this.rankState[i]
                    
                    // Reset the UI towards current
                    if (talent.nextRank != 0) then
                        set talent = talent.nextRank
                    endif

                    set j = j + 1
                endloop

                set this.talents[i] = talent
                // EXPERIMENTAL
                set this.tempRankState[i] = this.rankState[i]

                set i = i + 1
            endloop
            set this.isDirty = false
        endmethod

        method ApplyTalentTemporary takes integer index returns nothing
            local STKTalent_Talent talent = this.talents[index]
            // We assume there is definitely a talent on this index

            set this.isDirty = true

            if (this.tempRankState[index] < talent.maxRank) then
                set this.pointsAvailable = this.pointsAvailable - talent.cost
                set this.tempRankState[index] = this.tempRankState[index] + 1

                // Fire talent allocate event
                call this.AllocateTalent(talent)
                if (talent.nextRank != 0) then
                    set this.talents[index] = talent.nextRank
                endif
            else
                // Rollback
                set this.pointsAvailable = this.pointsAvailable + talent.cost
                set this.tempRankState[index] = this.tempRankState[index] - 1
            endif

        endmethod

        method CheckDependencyKey takes integer requiredLevel, integer index, integer depIndex returns string
            local STKTalent_Talent talent = this.talents[index]
            local string errorText = null

            if (requiredLevel == 0 or talent == 0) then
                set errorText = null
            elseif (requiredLevel == -1) then
                set errorText = ""
            endif

            if (this.tempRankState[depIndex] < requiredLevel) then
                set errorText = errorText + this.talents[depIndex].name

                if (talent.maxRank > 1) then
                    set errorText = errorText + " (" + I2S(requiredLevel) + ")"
                endif
            endif

            return errorText
        endmethod

        method CheckDependencyKeyLeft takes integer requiredLevel, integer index returns string
            local integer depIndex = index - 1
            return this.CheckDependencyKey(requiredLevel, index, depIndex)
        endmethod

        method CheckDependencyKeyUp takes integer requiredLevel, integer index returns string
            local integer depIndex = index + this.columns
            return this.CheckDependencyKey(requiredLevel, index, depIndex)
        endmethod

        method CheckDependencyKeyRight takes integer requiredLevel, integer index returns string
            local integer depIndex = index + 1
            return this.CheckDependencyKey(requiredLevel, index, depIndex)
        endmethod

        method CheckDependencyKeyDown takes integer requiredLevel, integer index returns string
            local integer depIndex = index - this.columns
            return this.CheckDependencyKey(requiredLevel, index, depIndex)
        endmethod

        
        // [TalentDepType.up]: (index: number, cols: number) => [index + cols, 1],
        // [TalentDepType.right]: (index: number, cols: number) => [index + 1, 0],
        // [TalentDepType.down]: (index: number, cols: number) => [index - cols, 1],

        // Event methods ==========================================================

        static method GetEventUnit takes nothing returns unit
            return EventUnit
        endmethod

        static method GetEventTalent takes nothing returns STKTalent_Talent
            return EventTalent
        endmethod

        static method GetEventRank takes nothing returns integer
            return EventRank
        endmethod

        static method GetEventTalentTree takes nothing returns TalentTree
            return EventTalentTree
        endmethod

        static method SetTalentRequirementsResult takes string requirements returns nothing
            set ResultTalentRequirements = requirements
        endmethod

        // End Event methods ======================================================

        static method create takes unit owner returns TalentTree
            local TalentTree tt = TalentTree.allocate()
            set tt.ownerUnit = owner
            set tt.ownerPlayer = GetOwningPlayer(owner)

            return tt
        endmethod

        method SetColumnsRows takes integer columns, integer rows returns nothing
            set this.columns = columns
            set this.rows = rows
        endmethod

        method GetTitle takes nothing returns string
            // return this.title + " (" + I2S(tree.pointsAvailable) + " points available)"
            return this.title
        endmethod
        
        method onDestroy takes nothing returns nothing
            set this.ownerUnit = null
            set this.ownerPlayer = null
        endmethod

    endstruct

    private function init takes nothing returns nothing
        
    endfunction

endlibrary