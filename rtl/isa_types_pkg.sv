package isa_types_pkg;
  typedef enum logic [6:0] {
    //operation func3 func7
    ADD,    //  000 0000000
    SUB,    //  000 0100000
    SLL,    //  001 0000000
    SLT,    //  010 0000000
    SLTU,   //  011 0000000
    XOR,    //  100 0000000
    SRL,    //  101 0000000
    SRA,    //  101 0100000
    OR,     //  110 0000000
    AND,    //  111 0000000  // R-type operations
    ADDI,   //  000   
    SLLI,   //  001 0000000  
    SLTI,   //  010  
    SLTIU,  //  011  
    XORI,   //  100  
    SRLI,   //  101 0000000  
    SRAI,   //  101 0100000  
    ORI,    //  110  
    ANDI,   //  111   // I-type operations
    LB,     //  000  
    LH,     //  001  
    LW,     //  010  
    LBU,    //  100  
    LHU,    //  101   // L-Type operations 
    SB,     //  000  
    SH,     //  001  
    SW,     //  010   // S-Type operations 
    EQ,     //  000  
    NE,     //  001  
    LT,     //  100  
    GE,     //  101  
    LTU,    //  110  
    GEU,    //  111   // B-Type operations 
    LUI,
    AUIPC,  // U-Type operations
    JAL,
    JALR    //  000   // J-Type operations
  } operator_t;
endpackage
