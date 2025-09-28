use exports::template_fibo::activity::fibo_activity_ifc::Guest;
use wit_bindgen::generate;

generate!({ generate_all });
struct Component;
export!(Component);

impl Guest for Component {
    fn fibo(n: u8) -> Result<u64, ()> {
        if n <= 1 {
            Ok(n.into())
        } else {
            Ok(Self::fibo(n - 1).unwrap() + Self::fibo(n - 2).unwrap())
        }
    }
}
