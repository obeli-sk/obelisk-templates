use exports::template_fibo::activity::fibo_activity_ifc::Guest;
use wit_bindgen::generate;

generate!({ generate_all });
struct Component;
export!(Component);

impl Guest for Component {
    fn fibo(n: u8) -> u64 {
        if n <= 1 {
            n.into()
        } else {
            Self::fibo(n - 1) + Self::fibo(n - 2)
        }
    }
}
