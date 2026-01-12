package isa_types_pkg;
  typedef enum logic [4:0] {
    ADD,
    SUB,
    AND,
    OR,
    XOR,
    SLL,
    SRL,
    SRA,
    SLT,
    SLTU,
    EQ,
    NE,
    LT,
    GE,
    LTU,
    GEU
  } operator_t;
endpackage
