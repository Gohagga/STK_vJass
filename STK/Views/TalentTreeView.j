library STKTalentTreeView requires STKTalentViewModel
    
    public struct TalentTreeView extends ITalentTreeView

        framehandle box
        framehandle container
        framehandle containerImage
        framehandle title
        framehandle closeButton
        framehandle confirmButtonMain
        // framehandle confirmButtonImage
        framehandle cancelButtonMain
        // framehandle cancelButtonImage

    endstruct

    public function GenerateTalentTreeView takes framehandle parent returns ITalentTreeView

        // ========= SETUP ===============================================================================
        local real boxWidth = 0.3
        local real boxHeight = 0.44
        local real boxSideMargin = 0.1
        local real boxVerticalMargin = 0.1
        local real boxY = 0.394
        local real boxX = 0.134
        local string boxText = "X"

        local real cancelWidth = 0.12
        local real cancelHeight = 0.03
        local real cancelY = 0.01
        local real cancelX = 0
        local string cancelText = "Cancel"
        
        local real confirmWidth = 0.12
        local real confirmHeight = 0.03
        local real confirmY = 0.01
        local real confirmX = 0
        local string confirmText = "Confirm"

        local real closeButtonWidth = 0.03
        local real closeButtonHeight = 0.03
        local real closeButtonY = 0.01 // 0.394
        local real closeButtonX = 0.01 // 0.134
        local string closeButtonText = "X"
        // ========= ENDSETUP ============================================================================

        // Creating the view
        local ITalentTreeView view = TalentTreeView.create()

        local framehandle box = BlzCreateFrame("SuspendDialog", parent, 0, 0)
        local framehandle title = BlzGetFrameByName("SuspendTitleText", 0)
        local framehandle closeButton = BlzGetFrameByName("SuspendDropPlayersButton", 0)
        local framehandle closeText = BlzGetFrameByName("SuspendDropPlayersButtonText", 0)

        local framehandle confirmButton = BlzCreateFrame("ScriptDialogButton", box, 0, 0)
        local framehandle confirmTextf = BlzGetFrameByName("ScriptDialogButtonText", 0)
        local framehandle cancelButton = BlzCreateFrame("ScriptDialogButton", box, 0, 0)
        local framehandle cancelTextf = BlzGetFrameByName("ScriptDialogButtonText", 0)

        call BlzFrameClearAllPoints(box)
        call BlzFrameSetAbsPoint(box, FRAMEPOINT_CENTER, 0.35, 0.34)
        call BlzFrameSetSize(box, boxWidth, boxHeight)

        call BlzFrameSetText(title, "Talent Tree")

        call BlzFrameClearAllPoints(closeButton)
        call BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, box, FRAMEPOINT_TOPRIGHT, closeButtonX, closeButtonY)
        call BlzFrameSetSize(closeButton, closeButtonWidth, closeButtonHeight)
        call BlzFrameSetText(closeButton, closeButtonText)

        call BlzFrameClearAllPoints(confirmButton)
        call BlzFrameSetPoint(confirmButton, FRAMEPOINT_BOTTOMRIGHT, box, FRAMEPOINT_BOTTOM, confirmX, confirmY)
        call BlzFrameSetSize(confirmButton, confirmWidth, confirmHeight)
        call BlzFrameSetText(confirmButton, confirmText)
        
        call BlzFrameClearAllPoints(cancelButton)
        call BlzFrameSetPoint(cancelButton, FRAMEPOINT_BOTTOMLEFT, box, FRAMEPOINT_BOTTOM, cancelX, cancelY)
        call BlzFrameSetSize(cancelButton, cancelWidth, cancelHeight)
        call BlzFrameSetText(cancelButton, cancelText)

        set view.box = box
        set view.container = box
        set view.title = title
        set view.closeButton = closeButton
        set view.confirmButtonMain = confirmButton
        set view.cancelButtonMain = cancelButton

        return view
    endfunction

endlibrary