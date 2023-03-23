library STKTalentView requires STKTalentViewModel, STKConstants
    
    public struct TalentView extends ITalentView

        framehandle buttonMain
        framehandle buttonImage
        framehandle tooltipBox
        framehandle tooltipText
        framehandle tooltipRank
        framehandle rankImage
        framehandle rankText
        framehandle highlight

        framehandle linkLeft
        framehandle linkUp
        framehandle linkRight
        framehandle linkDown
        framehandle linkIntersection

    endstruct

    function SetUpLink takes framehandle frame, framehandle parent, real width returns nothing
        call BlzFrameClearAllPoints(frame)
        call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, parent, FRAMEPOINT_CENTER, 0, 0)
        call BlzFrameSetSize(frame, width, width)
        call BlzFrameSetTexture(frame, "UI/Widgets/Console/Human/human-inventory-slotfiller.blp", 0, true)
        call BlzFrameSetLevel(frame, 1)
        call BlzFrameSetVisible(frame, false)
    endfunction

    public function GenerateTalentView takes framehandle parent returns ITalentView

        // ========= SETUP ===============================================================================
        local real buttonWidth = STKConstants_TTV_BUTTON_WIDTH
        local real buttonHeight = STKConstants_TTV_BUTTON_HEIGHT
        local string buttonTexture = "ReplaceableTextures/CommandButtons/BTNPeasant.blp"
        local real tooltipWidth = STKConstants_TOOLTIP_WIDTH
        local real tooltipHeight = STKConstants_TOOLTIP_HEIGHT
        local real tooltipTextX = STKConstants_TOOLTIP_TEXT_X
        local real tooltipTextY = STKConstants_TOOLTIP_TEXT_Y
        local real tooltipTextWidth = STKConstants_TOOLTIP_TEXT_WIDTH
        local real tooltipTextHeight = STKConstants_TOOLTIP_TEXT_HEIGHT
        local string tooltipDefaultText = "Default talent name \n\nDefault talent description"

        local real rankX = STKConstants_RANK_X
        local real rankY = STKConstants_RANK_Y
        local real rankSizeWidth = STKConstants_RANK_SIZE_WIDTH
        local real rankSizeHeight = STKConstants_RANK_SIZE_HEIGHT
        local real rankTextScale = STKConstants_RANK_TEXT_SCALE
        local string rankTexture = STKConstants_RANK_TEXTURE

        local real highlightWidth = STKConstants_HIGHLIGHT_WIDTH
        local real highlightHeight = STKConstants_HIGHLIGHT_HEIGHT
        local string highlightTexture = STKConstants_HIGHLIGHT_TEXTURE

        local real linkWidth = STKConstants_LINK_WIDTH
        local real linkIntersectionScale = STKConstants_LINK_INTERSECTION_SCALE
        // ========= ENDSETUP ============================================================================

        // Creating the view
        local TalentView view = TalentView.create()
        
        local framehandle linkLeft = BlzCreateFrameByType("BACKDROP", "LeftLink", parent, "", 0)
        local framehandle linkUp = BlzCreateFrameByType("BACKDROP", "UpLink", parent, "", 0)
        local framehandle linkRight = BlzCreateFrameByType("BACKDROP", "RightLink", parent, "", 0)
        local framehandle linkDown = BlzCreateFrameByType("BACKDROP", "DownLink", parent, "", 0)
        local framehandle linkIntersection = BlzCreateFrameByType("BACKDROP", "DownLink", parent, "", 0)

        local framehandle highlight = BlzCreateFrameByType("BACKDROP", "AvailableImage", parent, "", 0)
        local framehandle buttonMain = BlzCreateFrame("ScoreScreenBottomButtonTemplate", parent, 0, 0)
        local framehandle buttonImage = BlzGetFrameByName("ScoreScreenButtonBackdrop", 0)
        local framehandle toolBox = BlzCreateFrame("ListBoxWar3", buttonMain, 0, 0)
        local framehandle toolText = BlzCreateFrameByType("TEXT", "StandardInfoTextTemplate", toolBox, "StandardInfoTextTemplate", 0)
        local framehandle rankImage = BlzCreateFrameByType("BACKDROP", "Counter", buttonMain, "", 0)
        local framehandle rankText = BlzCreateFrameByType("TEXT", "FaceFrameTooltip", buttonMain, "", 0)
        local framehandle toolRank = BlzCreateFrameByType("TEXT", "FaceFrameTooltip", toolBox, "", 0)

        call BlzFrameSetTooltip(buttonMain, toolBox)

        call BlzFrameSetTextAlignment(rankText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        call BlzFrameSetTextAlignment(toolRank, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_RIGHT)

        call BlzFrameSetPoint(buttonMain, FRAMEPOINT_CENTER, parent, FRAMEPOINT_CENTER, 0, 0)
        call BlzFrameSetSize(buttonMain, buttonWidth, buttonHeight)
        call BlzFrameSetLevel(buttonMain, 2)

        call BlzFrameSetPoint(toolBox, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPRIGHT, 0, 0)
        call BlzFrameSetSize(toolBox, tooltipWidth, tooltipHeight)

        call BlzFrameClearAllPoints(toolText)
        call BlzFrameSetPoint(toolText, FRAMEPOINT_CENTER, toolBox, FRAMEPOINT_CENTER, tooltipTextY, tooltipTextY)
        call BlzFrameSetSize(toolText, tooltipTextWidth, tooltipTextHeight)
        call BlzFrameSetText(toolText, tooltipDefaultText)

        call BlzFrameSetPoint(rankImage, FRAMEPOINT_BOTTOMRIGHT, buttonMain, FRAMEPOINT_BOTTOMRIGHT, rankX, rankY)
        call BlzFrameSetSize(rankImage, rankSizeWidth, rankSizeHeight)
        call BlzFrameSetTexture(rankImage, rankTexture, 0, true)

        call BlzFrameClearAllPoints(rankText)
        call BlzFrameSetPoint(rankText, FRAMEPOINT_TOPLEFT, rankImage, FRAMEPOINT_TOPLEFT, 0, 0)
        call BlzFrameSetPoint(rankText, FRAMEPOINT_BOTTOMRIGHT, rankImage, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        call BlzFrameSetText(rankText, "0")
        call BlzFrameSetTextAlignment(rankText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        call BlzFrameSetScale(rankText, rankTextScale)

        call BlzFrameSetPoint(highlight, FRAMEPOINT_CENTER, buttonMain, FRAMEPOINT_CENTER, 0, 0)
        call BlzFrameSetSize(highlight, highlightWidth, highlightHeight)
        call BlzFrameSetTexture(highlight, highlightTexture, 0, true)

        call BlzFrameSetTexture(buttonImage, buttonTexture, 0, true)

        call BlzFrameClearAllPoints(toolRank)
        call BlzFrameSetPoint(toolRank, FRAMEPOINT_TOP, toolBox, FRAMEPOINT_TOP, 0.0, -0.015)
        call BlzFrameSetSize(toolRank, tooltipWidth - 0.03, tooltipHeight - 0.03)
        call BlzFrameSetText(toolRank, "Rank 1/3")
        
        call SetUpLink(linkLeft, buttonMain, linkWidth)
        call SetUpLink(linkUp, buttonMain, linkWidth)
        call SetUpLink(linkRight, buttonMain, linkWidth)
        call SetUpLink(linkDown, buttonMain, linkWidth)
        call SetUpLink(linkIntersection, buttonMain, linkWidth)
        call BlzFrameSetScale(linkIntersection, linkIntersectionScale)

        // EXPERIEMENTAL
        call BlzFrameSetVisible(buttonMain, false)
        call BlzFrameSetVisible(highlight, false)
        
        set view.highlight = highlight
        set view.buttonMain = buttonMain
        set view.buttonImage = buttonImage
        set view.tooltipBox = toolBox
        set view.tooltipText = toolText
        set view.tooltipRank = toolRank
        set view.rankImage = rankImage
        set view.rankText = rankText
        set view.linkLeft = linkLeft
        set view.linkUp = linkUp
        set view.linkRight = linkRight
        set view.linkDown = linkDown
        set view.linkIntersection = linkIntersection
        
        return view
    endfunction
endlibrary