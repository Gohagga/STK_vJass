library STKConstants
    globals
        public constant integer MAX_ROWS                = 7
        public constant integer MAX_COLUMNS             = 4
        public constant integer MAX_TALENT_SLOTS        = 28
        public constant integer MAX_PLAYER_COUNT        = 24
        public constant string  ACTIVE_LINK_TEXTURE     = "Textures/Water00.blp"
        public constant string  INACTIVE_LINK_TEXTURE   = "UI/Widgets/Console/Human/human-inventory-slotfiller.blp"
                                                        // "UI/Widgets/Glues/GlueScreen-Checkbox-Background.blp"
                                                        // "Textures/Water00.blp"
                                                        // "UI/Widgets/Console/Human/human-inventory-slotfiller.blp"

        // TalentView Config ============================================================================================
        // (Ignore this if using custom GenerateTalentView function)
        // Talent button height width scaling
        public constant real TTV_BUTTON_WIDTH = 0.035
        public constant real TTV_BUTTON_HEIGHT = 0.035

        // Talent-hover tooltip box
        public constant real TOOLTIP_WIDTH = 0.28
        public constant real TOOLTIP_HEIGHT = 0.16
        public constant real TOOLTIP_TEXT_X = 0
        public constant real TOOLTIP_TEXT_Y = 0
        public constant real TOOLTIP_TEXT_WIDTH = 0.25
        public constant real TOOLTIP_TEXT_HEIGHT = 0.13

        // Small rank box for multi-rank talents
        public constant real RANK_X = -0.0006
        public constant real RANK_Y = 0.0015
        public constant real RANK_SIZE_WIDTH = 0.020
        public constant real RANK_SIZE_HEIGHT = 0.014
        public constant real RANK_TEXT_SCALE = 0.7
        public constant string RANK_TEXTURE = "UI/Widgets/Console/Human/human-transport-slot.blp"

        // Highlight when talent is available to put points into
        public constant real HIGHLIGHT_WIDTH = 0.03
        public constant real HIGHLIGHT_HEIGHT = 0.03
        public constant string HIGHLIGHT_TEXTURE = "UI/Widgets/Console/Human/CommandButton/human-activebutton.blp"

        // Link between talents (dependency)
        public constant real LINK_WIDTH = 0.006
        public constant real LINK_INTERSECTION_SCALE = 0.80
        // End TalentView Config =========================================================================================

        // TalentTreeViewModel Config ====================================================================================
        // Affects automatic positioning of the talents
        public constant real BOX_WIDTH = 0.3
        public constant real BOX_HEIGHT = 0.44
        public constant real SIDE_MARGIN = 0.1
        public constant real VERTICAL_MARGIN = 0.15
        // End TalentTreeViewModel Config ================================================================================
    endglobals
endlibrary