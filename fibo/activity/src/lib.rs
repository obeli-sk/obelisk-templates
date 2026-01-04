use generated::export;
use generated::exports::template_fibo::activity::fibo_activity_ifc::Guest;

mod generated {
    #![allow(clippy::empty_line_after_outer_attr)]
    include!(concat!(env!("OUT_DIR"), "/any.rs"));
}

struct Component;
export!(Component with_types_in generated);

impl Guest for Component {
    fn fibo(n: u8) -> Result<u64, ()> {
        if n <= 1 {
            Ok(n.into())
        } else {
            Ok(Self::fibo(n - 1).unwrap() + Self::fibo(n - 2).unwrap())
        }
    }
}
