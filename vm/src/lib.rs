mod process;
mod scheduler;
mod ops;
mod vm;
mod object;

pub fn add(left: usize, right: usize) -> usize {
    left + right
}



#[cfg(test)]
mod test_vm_bytecode_operation {
    use super::*;

    #[test]
    fn one_module_add_numbers() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
