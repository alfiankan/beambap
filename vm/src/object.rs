#[derive(Debug)]
pub enum DataType {
    Integer,
    String,
}

#[derive(Debug)]
pub struct MedusaObj {
    pub(crate) label: String,
    pub(crate) data_type: DataType,
    pub(crate) value: Box<[u8]>,
}

impl MedusaObj {
    pub fn change_val(&mut self, val: Box<[u8]>) {
        self.value = val;
    }
}