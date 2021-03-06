library STKConstants
    globals
        public constant integer MAX_ROWS                = 7
        public constant integer MAX_COLUMNS             = 4
        public constant integer MAX_TALENT_SLOTS        = 28
        public constant string  ACTIVE_LINK_TEXTURE     = "Textures/Water00.blp"
        public constant string  INACTIVE_LINK_TEXTURE   = "UI/Widgets/Console/Human/human-inventory-slotfiller.blp"
                                                        // "UI/Widgets/Glues/GlueScreen-Checkbox-Background.blp"
                                                        // "Textures/Water00.blp"
                                                        // "UI/Widgets/Console/Human/human-inventory-slotfiller.blp"

        // TalentView Config ============================================================================================
        // (Ignore this if using custom GenerateTalentView function)
        // Talent button height width scaling
        public constant real buttonWidth = 0.030
        public constant real buttonHeight = 0.030

        // Talent-hover tooltip box
        public constant real tooltipWidth = 0.28
        public constant real tooltipHeight = 0.16
        public constant real tooltipTextX = 0
        public constant real tooltipTextY = 0
        public constant real tooltipTextWidth = 0.25
        public constant real tooltipTextHeight = 0.13

        // Small rank box for multi-rank talents
        public constant real rankX = -0.0006
        public constant real rankY = 0.0015
        public constant real rankSizeWidth = 0.016
        public constant real rankSizeHeight = 0.010
        public constant real rankTextScale = 0.72
        public constant string rankTexture = "UI/Widgets/Console/Human/human-transport-slot.blp"

        // Highlight when talent is available to put points into
        public constant real highlightWidth = 0.025
        public constant real highlightHeight = 0.025
        public constant string highlightTexture = "UI/Widgets/Console/Human/CommandButton/human-activebutton.blp"

        // Link between talents (dependency)
        public constant real linkWidth = 0.006
        public constant real linkIntersectionScale = 1
        // End TalentView Config =========================================================================================


        // TalentTreeViewModel Config ====================================================================================
        // Affects automatic positioning of the talents
        public constant real boxWidth = 0.1547
        public constant real boxHeight = 0.3103
        public constant real sideMargin = -0.05
        public constant real verticalMargin = 0
        // End TalentTreeViewModel Config ================================================================================
    endglobals
endlibrary