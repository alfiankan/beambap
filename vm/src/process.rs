use std::collections::HashMap;
use std::ops::Deref;
use crate::object::{MedusaObj, DataType};
use crate::ops::{OPCODE, OpcodeArgType};
use crate::process::ProcessStatus::Zero;
use crate::scheduler::MedusaScheduler;

#[derive(Debug)]
pub enum ProcessStatus {
    Zero = 0,
    Running = 1,
    Paused = 2,
}

struct MedusaProcess {
    pid: u32,
    register: Vec<i32>,
    label: String,
    heap: HashMap<u32, MedusaObj>,
    stack: HashMap<String, u32>,
    bytecode: Vec<Vec<OpcodeArgType>>,
    pc: u32,
    status: ProcessStatus,
}

impl MedusaProcess {
    fn new(pid: u32, label: &str, bytecodes: Vec<Vec<OpcodeArgType>>) -> MedusaProcess {
       return MedusaProcess{
           pid: pid,
           register: Vec::new(),
           label: label.to_string(),
           heap: HashMap::new(),
           stack: HashMap::new(),
           bytecode: bytecodes,
           pc: 0,
           status: Zero,
       }
    }
    fn move_pc(&mut self) {
        self.pc += 1;
    }
}


struct MedusaProcessManager {
    debug: bool,
    pid_counter: u32,
    processes_regs: HashMap<String, MedusaProcess>,
}

impl MedusaProcessManager {
    fn new() -> MedusaProcessManager {
        return MedusaProcessManager{
            debug: true,
            pid_counter: 0,
            processes_regs: HashMap::new(),
        }
    }

    fn spawn(&mut self, label: &str, bytecode: Vec<Vec<OpcodeArgType>>) {
        println!("Spawning new process");
        let next_pid = self.pid_counter + 1;
        let p = MedusaProcess::new(next_pid, label, bytecode);
        if self.debug {
            // print opcode
            println!("Code loaded into memory length : {}", p.bytecode.len());
        }
        let label = p.label.clone();
        self.processes_regs.insert(label, p);
        self.pid_counter += 1;
    }

    fn ps(&self) {
        for p in &self.processes_regs {
            println!("PID: {} NAME: {} STATUS: {:?}", p.1.pid, p.0, p.1.status);
        }
    }

    fn examine(&mut self) {
        let mp = self.processes_regs.get_mut("add iter loop").unwrap();
        println!("Register: {:?}", mp.register);
        println!("DO {:?}", mp.bytecode.get(mp.pc as usize));

        let line_code = mp.bytecode.get(mp.pc as usize).unwrap();

        if line_code[0].i == Some(OPCODE::LOAD_CONST as i32) {
            let op_arg = line_code[1].i.unwrap();
            let heap_legth = mp.heap.len() + 1;
            mp.heap.insert(heap_legth as u32, MedusaObj{
                label: op_arg.to_string(),
                data_type: DataType::String,
                value: op_arg.to_string().into_bytes().into_boxed_slice(),
            });
            mp.stack.insert(op_arg.to_string(), heap_legth as u32);
            mp.register.push(heap_legth as i32);
        }

        if line_code[0].i == Some(OPCODE::STORE as i32) {
            let heap_legth = mp.heap.len() + 1;
            mp.heap.insert(heap_legth as u32, MedusaObj{
                label: line_code[1].label.clone().unwrap(),
                data_type: DataType::String,
                value: line_code[1].label.clone().unwrap().into_bytes().into_boxed_slice(),
            });
            mp.stack.insert(line_code[1].label.clone().unwrap(), heap_legth as u32);
        }

        if line_code[0].i == Some(OPCODE::LOAD as i32) {
        }
        mp.move_pc();
    }

}


#[cfg(test)]
mod test_process_manager {
    use crate::ops::OpcodeArgType;
    use crate::process::MedusaProcessManager;

    #[test]
    fn just_run() {
        /*
        reg = []
        0 LOAD_CONST 10
        1   STORE [max]
        2   LOAD_CONST 0
        3   STORE [result]
        4   LOAD [result]
        5   LOAD_CONST [1]
        6   BINARY_OP [+]
        7   STORE [result]
        8   LOAD [result]
        9   LOAD [max]
        10  LOGICAL_OP [>]
        11  JUMP_IF_FALSE 2
        12  HALT
         */
        let mut pm = MedusaProcessManager::new();

        let mut code: Vec<Vec<OpcodeArgType>> = Vec::new();
        code.push(vec![OpcodeArgType{i: Some(1), label: None}, OpcodeArgType{i: Some(10), label: None}]);
        code.push(vec![OpcodeArgType{i: Some(4), label: None}, OpcodeArgType{i: None, label: Some("max".to_string()) }]);
        code.push(vec![OpcodeArgType{i: Some(1), label: None}, OpcodeArgType{i: Some(0), label: None}]);
        code.push(vec![OpcodeArgType{i: Some(4), label: None}, OpcodeArgType{i: None, label: Some("result".to_string())}]);
        code.push(vec![OpcodeArgType{i: Some(2), label: None}, OpcodeArgType{i: None, label: Some("result".to_string())}]);
        code.push(vec![OpcodeArgType{i: Some(1), label: None}, OpcodeArgType{i: Some(1), label: None}]);
        code.push(vec![OpcodeArgType{i: Some(3), label: None}, OpcodeArgType{i: None, label: Some("+".to_string())}]);
        code.push(vec![OpcodeArgType{i: Some(4), label: None}, OpcodeArgType{i: None, label: Some("result".to_string())}]);
        code.push(vec![OpcodeArgType{i: Some(2), label: None}, OpcodeArgType{i: None, label: Some("result".to_string())}]);
        code.push(vec![OpcodeArgType{i: Some(2), label: None}, OpcodeArgType{i: None, label: Some("max".to_string())}]);
        code.push(vec![OpcodeArgType{i: Some(7), label: None}, OpcodeArgType{i: None, label: Some(">".to_string())}]);
        code.push(vec![OpcodeArgType{i: Some(9), label: None}, OpcodeArgType{i: Some(2), label: None}]);
        code.push(vec![OpcodeArgType{i: Some(8), label: None}, OpcodeArgType{i: None, label: None}]);
        pm.spawn("add iter loop", code);
        pm.ps();

        for _ in 1..5 {
            pm.examine();
        }

    }
}