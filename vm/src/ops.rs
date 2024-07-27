use crate::ops::OPCODE::{BINARY_OP, HALT, JUMP_IF_FALSE, LOAD, LOAD_CONST, LOGICAL_OP, RETURN_VALUE, STORE};

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

impl OPCODE {
    pub fn get_int_opcode(opcode: String) -> u32 {
        match opcode.as_str() {
            "LOAD_CONST" => LOAD_CONST as u32,
            "LOAD" => LOAD as u32,
            "BINARY_OP" => BINARY_OP as u32,
            "STORE" => STORE as u32,
            "RETURN_VALUE" => RETURN_VALUE as u32,
            "JUMP_IF_TRUE" => JUMP_IF_FALSE as u32,
            "LOGICAL_OP" => LOGICAL_OP as u32,
            "HALT" => HALT as u32,
            "JUMP_IF_FALSE" => JUMP_IF_FALSE as u32,
            _ => 0
        }
    }
}

#[derive(Debug)]
pub struct OpcodeArgType {
    pub(crate) i: Option<i32>,
    pub(crate) label: Option<String>,
}