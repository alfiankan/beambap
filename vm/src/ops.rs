
#[derive(Debug, PartialEq, Eq)]
pub enum OPCODE {
    LOAD_CONST = 1,
    LOAD = 2,
    BINARY_OP = 3,
    STORE = 4,
    RETURN_VALUE = 5,
    JUMP_IF_TRUE = 6,
    LOGICAL_OP = 7,
    HALT = 8,
    JUMP_IF_FALSE = 9,
}

#[derive(Debug)]
pub struct OpcodeArgType {
    pub(crate) i: Option<i32>,
    pub(crate) label: Option<String>,
}