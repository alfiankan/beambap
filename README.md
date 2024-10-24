## Regsiters
```bash
- PC = 1 (int)
- RET = 5 (uint)
- STACK = [1,2,3] uint[]
```

## OPCODES

```python
i = 0
n = 10
r = 0
while i < n:
  r += 1
print(r)


```

```asm
0   STORE i 0
1   STORE n 10
2   STORE r 0
3   PUSH r
4   PUSH 5
5   ADD
6   POP r
7   PUSH i
8   PUSH 1
9   ADD
10  POP i
11  PUSH i
12  PUSH n
13  CMP_LT 3
14  PUSH r
14  SYSCALL print
```
