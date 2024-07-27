use std::collections::VecDeque;
use std::fs;
use medusa_vm::ops::OPCODE;

pub struct ByteCodeCompiler {}

impl ByteCodeCompiler {

    pub fn new() -> ByteCodeCompiler {
        return ByteCodeCompiler{}
    }
    pub fn compile_code(&self, code: &str) -> Vec<u8> {
        let lines = code.split("\n");

        let mut parsed_line_token_clean: VecDeque<VecDeque<String>> = VecDeque::new();
        for line in lines {
            let mut  idx = 0;
            let tokens = line.split(" ").collect::<Vec<&str>>();
            let mut parsed_inline_token_clean: VecDeque<String> = VecDeque::new();
            while idx < tokens.len() {
                if tokens[idx] != "" {
                    let clean_token = tokens[idx].replace("[", "").replace("]", "");
                    parsed_inline_token_clean.push_back(clean_token);
                }
                idx += 1;
            }
            parsed_inline_token_clean.pop_front();
            parsed_line_token_clean.push_back(parsed_inline_token_clean);
        }

        // clean empty line
        let parsed_line_token_clean = parsed_line_token_clean.iter().fold(VecDeque::new(), |mut acc, x| {
            if x.len() > 0 { acc.push_back(x); }
            acc
        });

        let mut main_bytecode: Vec<u8> = Vec::new();
        // skip 32 byte for header
        for _ in 0..32 { main_bytecode.push(0); }

        for line in parsed_line_token_clean {
            let opcode = OPCODE::get_int_opcode(line[0].to_string());
            let opcode_byte = opcode.to_le_bytes();

            let op_arg = line[1].as_bytes();
            let instruction_size = op_arg.len() + opcode_byte.len();
            let instruction_size_byte = instruction_size.to_le_bytes();
            // opcode
            for b in instruction_size_byte { main_bytecode.push(b); }
            for b in opcode_byte { main_bytecode.push(b); }
            for b in op_arg { main_bytecode.push(*b); }
        }

        return  main_bytecode;

    }

    pub fn compile(&self, code_path: &str) {

        let source_file = fs::read_to_string(code_path).unwrap();
        let bytecodes = self.compile_code(source_file.as_str());

        fs::write(format!("{}.med", code_path), bytecodes).unwrap()
    }
}

#[cfg(test)]
mod compiler_test {
    use super::*;

    #[test]
    fn just_compile() {
        let compiler = ByteCodeCompiler::new();
        compiler.compile("../examples/simple/loop_add.medusa");
    }
}
