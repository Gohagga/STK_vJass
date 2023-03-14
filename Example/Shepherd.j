scope Shepherd initializer init

    public struct Shepherd extends STKTalentTree_TalentTree

        // Overriden stub methods ==================================================
        method GetTalentPoints takes nothing returns integer
            return GetPlayerState(this.ownerPlayer, PLAYER_STATE_RESOURCE_LUMBER)
        endmethod

        method SetTalentPoints takes integer points returns nothing
            call SetPlayerState(this.ownerPlayer, PLAYER_STATE_RESOURCE_LUMBER, points)
        endmethod

        method GetTitle takes nothing returns string
            return this.title
        endmethod
        // =========================================================================

        method Initialize takes nothing returns nothing
            local STKTalent_Talent t

            call this.SetColumnsRows(3, 4)
            set this.title = "Shepherd"
            call this.SetTalentPoints(6)
            set this.backgroundImage = "arms.dds"
            // set this.icon = "FireBolt"
            // TODO: set tree background texture here

            // The tree should be built with talents here
            // ==============================================

            // Wondrous Flute <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Rank 1
            set t = this.CreateTalent()
            call t.SetName("Wondrous Flute")
            call t.SetDescription("Calls a sheep to your side.")
            call t.SetIcon("AlleriaFlute")
            call t.SetOnActivate(function thistype.Activate_CallSheep)
            call t.SetCost(0) // First level of this talent is free
            call this.AddTalent(0, 0, t)

            // Rank 2
            set t = this.CreateTalent()
            call t.SetName("Wondrous Flute")
            call t.SetDescription("Calls another sheep to your side.")
            call t.SetIcon("AlleriaFlute")
            call t.SetOnActivate(function thistype.Activate_CallSheep)
            call this.AddTalent(0, 0, t)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Soothing Song <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Rank 1
            set t = this.CreateTalent()
            call t.SetName("Soothing Song")
            call t.SetDescription("Calls a flying sheep to your side.")
            call t.SetIcon("DispelMagic")
            call t.SetOnActivate(function thistype.Activate_CallFlyingSheep)
            call t.SetDependencies(1, 0, 0, 0) // left 1 (left up right down)
            call this.AddTalent(1, 0, t)

            // Rank 2
            set t = this.CreateTalent()
            call t.SetName("Soothing Song")
            call t.SetDescription("Calls another flying sheep to your side.")
            call t.SetIcon("DispelMagic")
            call t.SetOnActivate(function thistype.Activate_CallFlyingSheep)
            call t.SetDependencies(1, 0, 0, 0) // left 1 (left up right down)
            call this.AddTalent(1, 0, t)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Shepherd Apprentice <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Rank 1
            set t = this.CreateTalent()
            call t.SetName("Shepherd Apprentice")
            call t.SetDescription("Gain an apprentice.")
            call t.SetIcon("Peasant")
            call t.SetOnActivate(function thistype.Activate_GainApprentice)
            call this.AddTalent(2, 0, t)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Lots of Apprentices <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Rank 1
            set t = this.CreateTalent()
            call t.SetName("Lots of Apprentices")
            call t.SetDescription("Gain 2 guard apprentices.")
            call t.SetIcon("Footman")
            call t.SetOnActivate(function thistype.Activate_Gain2Guards)
            call t.SetDependencies(0, 0, 0, 1) // down 1 (left up right down)
            call this.AddTalent(2, 1, t)

            // Rank 2
            set t = this.CreateTalent()
            call t.SetName("Lots of Apprentices")
            call t.SetDescription("Gain 2 guard apprentices.")
            call t.SetIcon("Footman")
            call t.SetOnActivate(function thistype.Activate_Gain2Guards)
            call t.SetDependencies(0, 0, 0, 1) // down 1 (left up right down)
            call this.AddTalent(2, 1, t)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Coming of the Lambs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Rank 1
            set t = this.CreateTalent()
            call t.SetName("Coming of the Lambs")
            call t.SetDescription("Gain a Sheep and a Flying Sheep.")
            call t.SetIcon("Sheep")
            call t.SetOnActivate(function thistype.Activate_ComingOfTheLambs)
            call t.SetDependencies(0, 0, 1, 1) // right 1 down 1 (left up right down)
            call this.AddTalent(1, 1, t)

            // Rank 2
            set t = this.CreateTalent()
            call t.SetName("Coming of the Lambs")
            call t.SetDescription("Gain 2 Sheep and 2 Flying Sheep.")
            call t.SetIcon("Sheep")
            call t.SetOnActivate(function thistype.Activate_ComingOfTheLambs)
            call t.SetDependencies(0, 0, 1, 1) // right 1 down 1 (left up right down)
            call this.AddTalent(1, 1, t)

            // Rank 3
            set t = this.CreateTalent()
            call t.SetName("Coming of the Lambs")
            call t.SetDescription("Gain 3 Sheep and 3 Flying Sheep.")
            call t.SetIcon("Sheep")
            call t.SetOnActivate(function thistype.Activate_ComingOfTheLambs)
            call t.SetDependencies(0, 0, 1, 1) // right 1 down 1 (left up right down)
            call this.AddTalent(1, 1, t)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Call of the Wilds <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            // Rank 1
            set t = this.CreateTalent()
            call t.SetName("Call of the Wilds")
            call t.SetDescription("Five hostile wolves appear.")
            call t.SetIcon("TimberWolf")
            call t.SetOnActivate(function thistype.Activate_CallOfTheWilds)
            call t.SetRequirements(function thistype.Requirement_CallOfTheWilds)
            call this.AddTalent(1, 2, t)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

            // Only need to call this if some talents start with certain rank
            // call this.SaveTalentRankState()
        endmethod


        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // Can use these methods inside Activate/Deactivate/Allocate/Deallocate/Requirements functions
        
        // static method GetEventUnit takes nothing returns unit
        // Returns unit that owns the talent tree
        // thistype.GetEventUnit()

        // static method GetEventTalent takes nothing returns STKTalent_Talent
        // Returns talent object that is being resolved
        // thistype.GetEventTalent()

        // static method GetEventRank takes nothing returns integer
        // Returns rank of the talent that is being activated
        // thistype.GetEventRank()

        // static method GetEventTalentTree takes nothing returns TalentTree
        // Returns "this"
        // thistype.GetEventTalentTree()

        // static method SetTalentRequirementsResult takes string requirements returns nothing
        // Needs to be called within Requirements function to disable the talent
        // thistype.SetTalentRequirementsResult("8 litres of milk")

        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        static method Activate_CallSheep takes nothing returns nothing
            local unit u = thistype.GetEventUnit()
            call CreateUnit(GetOwningPlayer(u), 'nshe', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
        endmethod

        static method Activate_CallFlyingSheep takes nothing returns nothing
            local unit u = thistype.GetEventUnit()
            call CreateUnit(GetOwningPlayer(u), 'nshf', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
        endmethod

        static method Activate_GainApprentice takes nothing returns nothing
            local unit u = thistype.GetEventUnit()
            call CreateUnit(GetOwningPlayer(u), 'hpea', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
        endmethod

        static method Activate_Gain2Guards takes nothing returns nothing
            local unit u = thistype.GetEventUnit()
            call CreateUnit(GetOwningPlayer(u), 'hfoo', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
            call CreateUnit(GetOwningPlayer(u), 'hfoo', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
        endmethod

        static method Activate_ComingOfTheLambs takes nothing returns nothing
            local unit u = thistype.GetEventUnit()
            local integer i = thistype.GetEventRank()
            loop
                exitwhen i <= 0
                call CreateUnit(GetOwningPlayer(u), 'nshe', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
                call CreateUnit(GetOwningPlayer(u), 'nshf', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
                set i = i - 1
            endloop
        endmethod

        static method Activate_CallOfTheWilds takes nothing returns nothing
            local unit u = thistype.GetEventUnit()
            local integer i = 0
            loop
                exitwhen i > 5
                call CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'nwlt', GetUnitX(u), GetUnitY(u), GetRandomDirectionDeg())
                set i = i + 1
            endloop
        endmethod

        static method IsEnumUnitSheepFilter takes nothing returns boolean
            return GetUnitTypeId(GetFilterUnit()) == 'nshe' or GetUnitTypeId(GetFilterUnit()) == 'nshf'
        endmethod

        static method Requirement_CallOfTheWilds takes nothing returns nothing
            local unit u = thistype.GetEventUnit()
            local group g = CreateGroup()
            call GroupEnumUnitsInRange(g, GetUnitX(u), GetUnitY(u), 5000, Filter(function thistype.IsEnumUnitSheepFilter))
            if (CountUnitsInGroup(g) < 8) then
                call thistype.SetTalentRequirementsResult("8 nearby sheep")
            endif
        endmethod
    endstruct

    private function init takes nothing returns nothing
    endfunction

endscope