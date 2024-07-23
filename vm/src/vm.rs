

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

    // starting process to contain schedulers
    // one scheduler has one real process, memory manager, ops and garbage collector
    fn start(&self) {
        // gather instructions
        // start scheduler
        // if thereis ops to opcode SPAWN it mean separate new medusa process, creating isolated memmory
        // for main medusa process is same

    }

}