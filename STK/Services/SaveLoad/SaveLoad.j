library STKSaveLoad initializer init requires BSR // STKTalentTreeViewModel //, STKITalentSlot, STKITalentView, STKTalentView, STKTalentTreeView, STKConstants

    globals
        public constant integer TALENTTREE_ID_THRESHOLD_SMALL = 16
        public constant integer TALENTTREE_ID_THRESHOLD_LARGE = 64

        public constant integer TALENT_ID_THRESHOLD_SMALL = 32
        public constant integer TALENT_ID_THRESHOLD_LARGE = 128
        
        public constant integer TALENT_RANK_THRESHOLD_SMALL = 16
        public constant integer TALENT_RANK_THRESHOLD_MEDIUM = 32
        public constant integer TALENT_RANK_THRESHOLD_LARGE = 64
        public constant integer TALENT_RANK_THRESHOLD_EXTRA = 256
    endglobals

    // Private globals
    globals
        private constant string array threshold2SizeName[2]
        private constant string array threshold4SizeName[4]

        private constant integer array talentTreeIdThreshold[2]
        private constant integer array talentIdThreshold[2]
        private constant integer array talentRankThreshold[4]
    endglobals

    private function nextPowerOfTwo takes integer n returns integer
        local integer value = 1
        loop
            exitwhen value >= n
            set value = value * 2
        endloop
        return value
    endfunction

    private function getThresholdValue takes integer size, integer whichThreshold returns integer
        local integer value = -1
        if (whichThreshold == 0) then // talentTreeId
            set value = talentTreeIdThreshold[size]
        elseif (whichThreshold == 1) then // talentId
            set value = talentIdThreshold[size]
        elseif (whichThreshold == 2) then // talentRank
            set value = talentRankThreshold[size]
        endif
        return value
    endfunction

    private function findSizeBits takes integer value, integer whichThreshold returns integer
        local integer thresholdKey = 0
        local integer i = 0
        local integer threshold = 0
        local integer bits = 0
        loop
            set threshold = getThresholdValue(i, whichThreshold)
            exitwhen value < threshold or threshold == 0
            set thresholdKey = i
            set i = i + 1
        endloop
    
        set threshold = getThresholdValue(thresholdKey, whichThreshold)
        loop
            set bits = bits + 1
            set threshold = threshold / 2
            exitwhen threshold <= 1
        endloop
        return bits
    endfunction
    
    public function LoadTalentTree takes BSR_BitStreamReader stream, integer talentTreeIdBits, integer talentIdBits, integer talentRankBits returns nothing// STKTalentTree_TalentTree
        local integer talentTreeId = 0
        local integer readMode = 0
        local integer talentCount = 0
        local integer talentId = 0
        local integer talentRank = 0
        local integer i = 0

        call BJDebugMsg("Loading Talent Tree")

        set talentTreeId = stream.readInt(talentTreeIdBits)
        call BJDebugMsg(stream.lastReadChunk + " - Talent Tree Id: " + I2S(talentTreeId))

        set readMode = stream.readInt(1)

        // Sequential
        if (readMode == 0) then
            call BJDebugMsg(stream.lastReadChunk + " - Read mode: Sequential")

            set talentCount = stream.readInt(talentIdBits)
            call BJDebugMsg(stream.lastReadChunk + " - Talent with Ranks Count: " + I2S(talentCount))

            set i = 0
            loop
                exitwhen i == talentCount

                set talentId = stream.readInt(talentIdBits)
                call BJDebugMsg(stream.lastReadChunk + " - Talent Id: " + I2S(talentId))

                set talentRank = stream.readInt(talentRankBits)
                call BJDebugMsg(stream.lastReadChunk + " - Talent [" + I2S(talentId) + "] Rank: " + I2S(talentRank))
                
                set i = i + 1
            endloop
        endif

        // Positional
        if (readMode == 1) then
            call BJDebugMsg(stream.lastReadChunk + " - Read mode: Positional")
            
            set talentCount = stream.readInt(talentIdBits)
            call BJDebugMsg(stream.lastReadChunk + " - Max Talent Id: " + I2S(talentCount))

            set i = 0
            loop
                exitwhen i == talentCount

                set talentRank = stream.readInt(talentRankBits)
                call BJDebugMsg(stream.lastReadChunk + " - Talent [" + I2S(i) + "] Rank: " + I2S(talentRank))
                
                set i = i + 1
            endloop
        endif
    endfunction

    public function LoadForUnit takes /*unit owner,*/ string bitStream returns nothing
        local integer i = 0
        
        local integer talentTreeIdSize = 0
        local integer talentRankSize = 0
        local integer talentIdSize = 0
        
        local integer talentTreeIdBits = 0
        local integer talentIdBits = 0
        local integer talentRankBits = 0        
        
        local integer talentTreeId = 0
        local integer talentTreeCount = 0

        local BSR_BitStreamReader stream = BSR_BitStreamReader.create(bitStream)

        set talentTreeIdSize = stream.readInt(1)
        call BJDebugMsg(stream.lastReadChunk + " - Talent Tree Id size: " + threshold2SizeName[talentTreeIdSize] + " threshold: " + I2S(talentTreeIdThreshold[talentTreeIdSize]))

        set talentRankSize = stream.readInt(2)
        call BJDebugMsg(stream.lastReadChunk + " - Talent Rank size: " + threshold4SizeName[talentRankSize] + " threshold: " + I2S(talentRankThreshold[talentRankSize]))

        set talentIdSize = stream.readInt(1)
        call BJDebugMsg(stream.lastReadChunk + " - Talent Id size: " + threshold2SizeName[talentIdSize] + " threshold: " + I2S(talentIdThreshold[talentIdSize]))

        // Talent Tree Count
        set talentTreeCount = stream.readInt(4)
        call BJDebugMsg(stream.lastReadChunk + " - Talent Tree count: " + I2S(talentTreeCount))

        // Bit sizes
        set talentTreeIdBits = findSizeBits(talentTreeIdSize, 0)
        set talentIdBits = findSizeBits(talentIdSize, 1)
        set talentRankBits = findSizeBits(talentRankSize, 2)

        // Talent Trees
        set i = 0
        loop
            exitwhen i == talentTreeCount
            call LoadTalentTree(stream, talentTreeIdBits, talentIdBits, talentRankBits)
            set i = i + 1
        endloop

    endfunction

    private function init takes nothing returns nothing
        set threshold2SizeName[0] = "SMALL"
        set threshold2SizeName[1] = "LARGE"

        set threshold4SizeName[0] = "SMALL"
        set threshold4SizeName[1] = "MEDIUM"
        set threshold4SizeName[2] = "LARGE"
        set threshold4SizeName[3] = "EXTRA"

        set talentTreeIdThreshold[0] = TALENTTREE_ID_THRESHOLD_SMALL
        set talentTreeIdThreshold[1] = TALENTTREE_ID_THRESHOLD_LARGE

        set talentIdThreshold[0] = TALENT_ID_THRESHOLD_SMALL
        set talentIdThreshold[1] = TALENT_ID_THRESHOLD_LARGE
        
        set talentRankThreshold[0] = TALENT_RANK_THRESHOLD_SMALL
        set talentRankThreshold[1] = TALENT_RANK_THRESHOLD_MEDIUM
        set talentRankThreshold[2] = TALENT_RANK_THRESHOLD_LARGE
        set talentRankThreshold[3] = TALENT_RANK_THRESHOLD_EXTRA

        set talentTreeIdThreshold[2] = 0
        set talentIdThreshold[2] = 0
        set talentRankThreshold[4] = 0
    endfunction
endlibrary