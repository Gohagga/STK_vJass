library BSR // initializer init

    globals
        public constant integer MAX_BIT_LENGTH = 1000
    endglobals

    public struct BitStreamReader

        private string data
        private integer pointer
        private integer array bitArray[MAX_BIT_LENGTH]
        public string lastReadChunk
        
        static method create takes string data returns BitStreamReader
            local BitStreamReader bsr = BitStreamReader.allocate()
            local integer length = StringLength(data)
            local integer i = 0

            set bsr.data = data
            set bsr.pointer = 0

            loop
                exitwhen i >= length
                set bsr.bitArray[i] = S2I(SubString(data, i, i+1))
                set i = i + 1
            endloop

            return bsr
        endmethod

        public method readStr takes integer bitCount returns string
            local string readBits = SubString(this.data, this.pointer, this.pointer + bitCount)
            set this.pointer = this.pointer + bitCount
            return readBits
        endmethod

        public method readInt takes integer bitCount returns integer
            local integer value = 0
            local integer end = this.pointer + bitCount
            set this.lastReadChunk = SubString(this.data, this.pointer, end)
            loop
                exitwhen this.pointer >= end
                set value = value * 2 + this.bitArray[this.pointer]
                set this.pointer = this.pointer + 1
            endloop
            return value
        endmethod
    endstruct
endlibrary