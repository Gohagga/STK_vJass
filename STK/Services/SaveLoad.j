library STKSaveLoad initializer init requires BSRW, STK // STKTalentTreeViewModel //, STKITalentSlot, STKITalentView, STKTalentView, STKTalentTreeView, STKConstants

    globals
        public constant integer MAX_TALENT_SLOTS = STKConstants_MAX_TALENT_SLOTS
        
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

        private TalentTreeFactory array talentTreeFactories[TALENT_ID_THRESHOLD_LARGE]
        private integer maxTalentTreeId = 0

        private integer array tempArrayChainIndex[TALENT_ID_THRESHOLD_LARGE]
        private string charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$#0123456789"
        private integer charsetBase = 6
        private integer array charsetMap[100]
        private hashtable hash
    endglobals

    function interface TalentTreeFactory takes unit u returns STKTalentTree_TalentTree

    private function getCharIndex takes string char returns integer
        local integer i = 0
        local integer length = StringLength(charset)
        loop
            exitwhen i >= length or char == SubString(charset, i, i+1)
            set i = i + 1
        endloop
        return i
    endfunction

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

    private function findThresholdSize takes integer value, integer whichThreshold returns integer
        local integer size = 0
        local integer threshold = getThresholdValue(size, whichThreshold)
        loop
            exitwhen value < threshold or threshold == 0
            set size = size + 1
            set threshold = getThresholdValue(size, whichThreshold)
        endloop
        return size
    endfunction

    public function RegisterTalentTree takes integer id, TalentTreeFactory factoryMethod returns boolean
        local TalentTreeFactory f = talentTreeFactories[id]
        if (id == 0) then
            call BJDebugMsg("|cffdd0808STK-Error: IDs should start from 1, not 0. (SaveLoad.RegisterTalentTree)")
            return false
        endif
        if (f != 0) then
            call BJDebugMsg("|cffdd0808STK-Error: " + I2S(id) + " is already used. (SaveLoad.RegisterTalentTree)")
            return false
        endif
        set talentTreeFactories[id] = factoryMethod
        if (id > maxTalentTreeId) then
            set maxTalentTreeId = id
        endif
        return true
    endfunction
    
    public function LoadTalentTree takes integer panelId, BSRW_BitStreamReader stream, integer talentTreeIdBits, integer talentIdBits, integer talentRankBits, unit owner returns STKTalentTree_TalentTree
        local integer talentTreeId = 0
        local integer readMode = 0
        local integer talentCount = 0
        local integer talentId = 0
        local integer talentRank = 0
        local integer i = 0
        local STKTalentTree_TalentTree tree

        call BJDebugMsg("Loading Talent Tree")

        set talentTreeId = stream.readInt(talentTreeIdBits)
        call BJDebugMsg(stream.lastReadChunk + " - Talent Tree Id: " + I2S(talentTreeId))

        set tree = talentTreeFactories[talentTreeId].evaluate(owner)
        call STK_AssignTalentTree(panelId, owner, tree)
        call tree.UpdateChainIdTalentIndex()

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

                call tree.ApplyTalentChainTemporary(talentId, talentRank)
                
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

                set talentId = i + 1
                set talentRank = stream.readInt(talentRankBits)
                call BJDebugMsg(stream.lastReadChunk + " - Talent [" + I2S(talentId) + "] Rank: " + I2S(talentRank))

                if (talentRank > 0) then
                    call tree.ApplyTalentChainTemporary(talentId, talentRank)
                endif
                
                set i = i + 1
            endloop
        endif

        call tree.SaveTalentRankState()
        return tree
    endfunction

    public function SaveTalentTree takes BSRW_BitStreamWriter stream, integer talentTreeIdBits, integer talentIdBits, integer talentRankBits, STKTalentTree_TalentTree tree returns nothing
        local integer i = 0
        local integer talentCount = 0
        local integer chainId = 0
        local string seq = ""
        local string pos = ""
        local BSRW_BitStreamWriter tempWriter = BSRW_BitStreamWriter.create()

        set i = 0
        loop
            exitwhen i == MAX_TALENT_SLOTS
            set tempArrayChainIndex[i] = 0
            set i = i + 1
        endloop

        call stream.write(tree.GetId(), talentTreeIdBits)

        // Sequential
        set talentCount = 0
        set i = 0
        loop
            exitwhen i == MAX_TALENT_SLOTS
            if (tree.rankState[i] > 0 and tree.talents[i] > 0) then
                set talentCount = talentCount + 1
                call tempWriter.write(tree.talents[i].GetChainId(), talentIdBits)
                call tempWriter.write(tree.rankState[i], talentRankBits)
            endif
            set i = i + 1
        endloop
        set seq = tempWriter.get()
        call tempWriter.flush().write(talentCount, talentIdBits)
        set seq = tempWriter.get() + seq

        // Positional
        set talentCount = 0
        set i = 0
        loop
            exitwhen i == MAX_TALENT_SLOTS
            if (tree.rankState[i] > 0 and tree.talents[i] > 0) then
                set chainId = tree.talents[i].GetChainId()
                if (chainId > talentCount) then
                    // Highest chain id
                    set talentCount = chainId
                endif
                if (tempArrayChainIndex[chainId] > 0) then
                    call BJDebugMsg("|cffdd0808STK-Error: Talents on different grid positions should not share Chain ID " + I2S(chainId) + " (" + tree.talents[i].name + "). (SaveLoad.SaveTalentTree)")
                endif
                set tempArrayChainIndex[chainId] = i
            endif
            set i = i + 1
        endloop

        call tempWriter.flush().write(talentCount, talentIdBits)
        set i = 0
        loop
            exitwhen i == talentCount
            call tempWriter.write(tree.rankState[tempArrayChainIndex[i]], talentRankBits)
            set i = i + 1
        endloop
        set pos = tempWriter.get()
        
        if (StringLength(seq) < StringLength(pos)) then
            call stream.write(0, 1)
            call stream.writeStream(seq)
        else
            call stream.write(1, 1)
            call stream.writeStream(pos)
        endif

        set seq = null
        set pos = null
    endfunction

    public function LoadForUnit takes unit owner, string bitString returns nothing
        local integer i = 0
        local STKTalentTree_TalentTree tt
        
        local integer talentTreeIdSize = 0
        local integer talentRankSize = 0
        local integer talentIdSize = 0
        
        local integer talentTreeIdBits = 0
        local integer talentIdBits = 0
        local integer talentRankBits = 0        
        
        local integer talentTreeId = 0
        local integer talentTreeCount = 0

        local BSRW_BitStreamReader stream = BSRW_BitStreamReader.create(bitString)

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
            set tt = LoadTalentTree(i + 1, stream, talentTreeIdBits, talentIdBits, talentRankBits, owner)
            set i = i + 1
        endloop

    endfunction

    public function SaveForUnit takes unit owner returns string
        local integer i = 0
        local integer j = 0
        local integer maxTalentRank = 0
        local integer maxTalentId = 0
        local integer talentTreeCount = 0
        
        local integer talentTreeIdSize = 0
        local integer talentIdSize = 0
        local integer talentRankSize = 0
        
        local integer talentTreeIdBits = 0
        local integer talentIdBits = 0
        local integer talentRankBits = 0
        
        local STKTalentTree_TalentTree tt
        local integer talentTreeId = 0

        local BSRW_BitStreamWriter stream

        // Loop over unit's talent trees
        // And find maxTalentRank, maxTalentId
        set j = 1
        loop
            set tt = STK_Store.GetUnitTalentTree(j, owner)
            exitwhen tt <= 0

            set talentTreeCount = talentTreeCount + 1
            set i = 0
            loop
                exitwhen i == MAX_TALENT_SLOTS
                if (tt.rankState[i] > maxTalentRank) then
                    set maxTalentRank = tt.rankState[i]
                endif
                if (tt.talents[i].GetChainId() > maxTalentId) then
                    set maxTalentId = tt.talents[i].GetChainId()
                endif
                set i = i + 1
            endloop

            set j = j + 1
        endloop

        set talentTreeIdSize = findThresholdSize(maxTalentTreeId, 0)
        set talentIdSize = findThresholdSize(maxTalentId, 1)
        set talentRankSize = findThresholdSize(maxTalentRank, 2)

        set stream = BSRW_BitStreamWriter.create()

        call stream.write(talentTreeIdSize, 1)
        call BJDebugMsg(stream.lastWrittenChunk + " - Talent Tree Id size: " + threshold2SizeName[talentTreeIdSize] + " threshold: " + I2S(talentTreeIdThreshold[talentTreeIdSize]))

        call stream.write(talentRankSize, 2)
        call BJDebugMsg(stream.lastWrittenChunk + " - Talent Rank size: " + threshold4SizeName[talentRankSize] + " threshold: " + I2S(talentRankThreshold[talentRankSize]))

        call stream.write(talentIdSize, 1)
        call BJDebugMsg(stream.lastWrittenChunk + " - Talent Id size: " + threshold2SizeName[talentIdSize] + " threshold: " + I2S(talentIdThreshold[talentIdSize]))

        // Talent Tree Count
        call stream.write(talentTreeCount, 4)
        call BJDebugMsg(stream.lastWrittenChunk + " - Talent Tree count: " + I2S(talentTreeCount))

        // Bit sizes
        set talentTreeIdBits = findSizeBits(talentTreeIdSize, 0)
        set talentIdBits = findSizeBits(talentIdSize, 1)
        set talentRankBits = findSizeBits(talentRankSize, 2)

        // Talent Trees
        set i = 1
        loop
            set tt = STK_Store.GetUnitTalentTree(i, owner)
            exitwhen tt <= 0
            call BJDebugMsg("Saving Talent tree " + I2S(i) + " - " + tt.title)
            call SaveTalentTree(stream, talentTreeIdBits, talentIdBits, talentRankBits, tt)
            set i = i + 1
        endloop

        return stream.get()
    endfunction

    public function LoadForUnitEncoded takes unit owner, string saveCode returns nothing
        local BSRW_BitStreamWriter writer = BSRW_BitStreamWriter.create()
        local integer length = StringLength(saveCode)
        local integer index = 0
        local integer i = 0
        local string character = ""
    
        set i = 0
        loop
            exitwhen i >= length
            set character = SubString(saveCode, i, i+1)
            
            set index = getCharIndex(character)
        
            if (index >= 0) then
                call writer.write(index, charsetBase)
            endif
            set i = i + 1
        endloop

        set character = writer.get()

        call LoadForUnit(owner, character)
        call writer.destroy()
        set character = null
    endfunction

    public function SaveForUnitEncoded takes unit owner returns string
        local string encoded = ""
        local string bitString = SaveForUnit(owner)
        local integer bitStringLength = StringLength(bitString)
        local integer remainder = ModuloInteger(bitStringLength, charsetBase)
        local integer i = 0
        local integer value = 0
        local BSRW_BitStreamReader reader

        // Padding up to the charset base
        if (remainder != 0) then
            set i = charsetBase - remainder
            loop
                exitwhen i <= 0
                set bitString = bitString + "0"
                set i = i - 1
            endloop
        endif
        set reader = BSRW_BitStreamReader.create(bitString)

        set i = 0
        loop
            exitwhen i >= bitStringLength
            set value = reader.readInt(charsetBase)
            set encoded = encoded + SubString(charset, value, value + 1)
            set i = i + charsetBase
        endloop

        return encoded
    endfunction

    private function init takes nothing returns nothing
        local integer i = 0
        local string char = ""

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

        // set hash = InitHashtable()
        // loop
        //     exitwhen i == StringLength(charset)
        //     set char = SubString(charset, i, i+1)
        //     call BJDebugMsg("Hashing " + char + " hash " + I2S(StringHash(char)))
        //     if (65 <= StringHash(char) and StringHash(char) <= 90) then
        //         call SaveInteger(hash, 0, 32 + StringHash(char), i)
        //     else
        //         call SaveInteger(hash, 0, StringHash(char), i)
        //     endif
        //     set i = i + 1
        // endloop
    endfunction
endlibrary