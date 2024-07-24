
#[derive(Debug, PartialEq, Eq)]
pub enum OPCODE {
    LOAD_CONST = 1, // OK
    LOAD = 2, // OK
    BINARY_OP = 3, //OK
    STORE = 4, //OK
    RETURN_VALUE = 5,
    JUMP_IF_TRUE = 6,
    LOGICAL_OP = 7, // OK
    HALT = 8,
    JUMP_IF_FALSE = 9,
}

#[derive(Debug)]
pub struct OpcodeArgType {
    pub(crate) i: Option<i32>,
    pub(crate) label: Option<String>,
}