
# medusa naive stack vm

## Registers
```bash
pc              = Program Counter (byte offset)
stack = [] grow
```

## Format `.med`
- magic code `4 byte`
- version `4 byte`
- reserved `24 byte`
after 32 byte is directly the bytecode


## Step
1. load all bytecode to runtime
2. execute 

```
def get_sum(target, check):
    result = 0
    result = target + check
    return result
    
def main():
    a = get_sum(9, 3)
            
module.get_sum function label -> 4353
module.main function label -> 0
result -> 211
target -> 9
check  -> 4

Stack is hash point to heap

stack['result'] = 4343534  -> location on heap

stack [13]
4353:get_sum:
    LOAD_CONST 0
    STORE [result]
    LOAD [target]
    LOAD [check]
    BINARY_OP [+]
    STORE [result]
    RETURN_VALUE
0:main:
    LOAD_GLOBAL [4353]
    LOAD_CONST 9
    LOAD_CONST 4
    CALL
    STORE [a]
    
    
    

```


## Instruction

- [PUSH] LOAD_CONST <constant_value> : load constant to register
- [POP ] LOAD_GLOBAL <heap_value> : load global to register
- STORE <heap_value> : store to heap