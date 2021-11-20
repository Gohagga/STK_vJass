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

    endstruct

    function SetUpLink takes framehandle frame, framehandle parent, real width returns nothing
        call BlzFrameClearAllPoints(frame)
        call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, parent, FRAMEPOINT_CENTER, 0, 0)
        call BlzFrameSetSize(frame, width, width)
        call BlzFrameSetTexture(frame, "UI/Widgets/Console/Human/human-inventory-slotfiller.blp", 0, true)
        call BlzFrameSetLevel(frame, 1)
        call BlzFrameSetVisible(frame, true)
    endfunction

    public function GenerateTalentView takes framehandle parent returns ITalentView

        // ========= SETUP ===============================================================================
        local real buttonWidth = STKConstants_buttonWidth
        local real buttonHeight = STKConstants_buttonHeight
        local string buttonTexture = "ReplaceableTextures/CommandButtons/BTNPeasant.blp"
        local real tooltipWidth = STKConstants_tooltipWidth
        local real tooltipHeight = STKConstants_tooltipHeight
        local real tooltipTextX = STKConstants_tooltipTextX
        local real tooltipTextY = STKConstants_tooltipTextY
        local real tooltipTextWidth = STKConstants_tooltipTextWidth
        local real tooltipTextHeight = STKConstants_tooltipTextHeight
        local string tooltipDefaultText = "Default talent name \n\nDefault talent description"

        local real rankX = STKConstants_rankX
        local real rankY = STKConstants_rankY
        local real rankSizeWidth = STKConstants_rankSizeWidth
        local real rankSizeHeight = STKConstants_rankSizeHeight
        local string rankTexture = STKConstants_rankTexture

        local real highlightWidth = STKConstants_highlightWidth
        local real highlightHeight = STKConstants_highlightHeight
        local string highlightTexture = STKConstants_highlightTexture

        local real linkWidth = STKConstants_linkWidth
        // ========= ENDSETUP ============================================================================

        // Creating the view
        local TalentView view = TalentView.create()
        
        local framehandle linkLeft = BlzCreateFrameByType("BACKDROP", "LeftLink", parent, "", 0)
        local framehandle linkUp = BlzCreateFrameByType("BACKDROP", "UpLink", parent, "", 0)
        local framehandle linkRight = BlzCreateFrameByType("BACKDROP", "RightLink", parent, "", 0)
        local framehandle linkDown = BlzCreateFrameByType("BACKDROP", "DownLink", parent, "", 0)

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
        call BlzFrameSetPoint(rankText, FRAMEPOINT_CENTER, rankImage, FRAMEPOINT_CENTER, 0, 0)
        call BlzFrameSetSize(rankText, 0.01, 0.012)
        call BlzFrameSetText(rankText, "0")

        call BlzFrameSetPoint(highlight, FRAMEPOINT_CENTER, buttonMain, FRAMEPOINT_CENTER, 0, 0)
        call BlzFrameSetSize(highlight, highlightWidth, highlightHeight)
        call BlzFrameSetTexture(highlight, highlightTexture, 0, true)

        call BlzFrameSetTexture(buttonImage, buttonTexture, 0, true)

        call BlzFrameClearAllPoints(toolRank)
        call BlzFrameSetPoint(toolRank, FRAMEPOINT_TOP, toolBox, FRAMEPOINT_TOP, 0.0, -0.015)
        call BlzFrameSetSize(toolRank, tooltipWidth - 0.03, tooltipHeight - 0.03)
        call BlzFrameSetText(toolRank, "Rank 1/3")
        
        call SetUpLink(linkLeft, parent, linkWidth)
        call SetUpLink(linkUp, parent, linkWidth)
        call SetUpLink(linkRight, parent, linkWidth)
        call SetUpLink(linkDown, parent, linkWidth)

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
        
        return view
    endfunction
endlibrary