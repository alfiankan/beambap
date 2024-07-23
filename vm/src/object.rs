pub enum DataType {
    Integer,
    String,
}

pub struct MedusaObj {
    pub(crate) label: String,
    pub(crate) data_type: DataType,
    pub(crate) value: Box<[u8]>,
}