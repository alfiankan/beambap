

struct MedusaVMConfig {
    debug: bool,
}

struct MedusaVM {
    vm_config: MedusaVMConfig,
}

impl MedusaVM {
    fn new(&self, config: MedusaVMConfig) -> MedusaVM {
        return MedusaVM{
            vm_config: config,
        }
    }

    fn load_byte_code(&self, dir: Vec<String>) {
        // load bytecode first find main.med to be loaded at first
        // then continue other files

    }

    // starting process to contain schedulers
    // one scheduler has one real process, memory manager, ops and garbage collector
    fn start(&self) {
        // gather instructions
        // start scheduler
        // if thereis ops to opcode SPAWN it mean separate new medusa process, creating isolated memmory
        // for main medusa process is same

    }
}

#[cfg(test)]
mod test_vm {
    use std::fs::File;
    use std::io::Write;
    use std::ops::Deref;
    use crate::ops::OPCODE;

    fn write_bytecode(bytecodes: &Vec<u8>, opcode: u32, oparg_number: i32, oparg_ref: &str) {


    }

    #[test]
    fn just_run() {

        /* generate bytecode
        offset  |   opcode      | opargs
        0           LOAD_CONST      10
        1           STORE           [max]
        2           LOAD_CONST      0
        3           STORE           [result]
        4           LOAD            [result]
        5           LOAD_CONST      [1]
        6           BINARY_OP       [+]
        7           STORE           [result]
        8           LOAD            [result]
        9           LOAD            [max]
        10          LOGICAL_OP      [>]
        11          JUMP_IF_FALSE   4
        12          HALT
                [32bit next_offset][bytecode][next_offset][bytecode]
                [2+10+1][2byte][10] []
         */

        // next start 32 byte zeros
        let mut main_bytecode: Vec<u8> = Vec::new();
        for idx in 0..32 {
            main_bytecode.push(0);
        }


        let mut file = File::create("main.med").unwrap();
        file.write_all(main_bytecode.deref()).unwrap();
    }
}