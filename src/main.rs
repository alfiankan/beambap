use rustpython_ast::StmtFunctionDef;
use rustpython_parser::parse;
use rustpython_parser_core::Mode;
use std::fmt::Debug;
use medusa_vm::add;

fn main() {
    println!("Hello, world!");
    let source = r###"#print()

#def greet(name: str, language="indonesia") -> None:
#    print(f"greet {name}")

#def main():
#    greet("alfi")
#    print("hello")

def hello():
    bio = {"nama": "alfi", "sex": "male", "age": 24}
    for b in bio.keys():
        print(b, bio[b])

    "###;
    println!("{}", source);
    let result = parse(source, Mode::Module, "<embedded>");

    match result {
        Err(err) => {
            println!("ERROR: {}", err)
        }
        Ok(res) => {
            println!("{:#?}", res);

            match res.module() {
                None => {}
                Some(parsed) => {
                    for stmt in parsed.body.clone() {
                        let fd = stmt.as_function_def_stmt();
                        match fd {
                            None => {}
                            Some(fd) => {
                                println!("IS FUNCTION DEFINITION {}", fd.name);

                                println!("{:#?}", fd.args);
                            }
                        }
                    }
                }
            }
        }
    }
    println!("{}", add(1, 5));

}
