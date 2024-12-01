use exports::testing_namespace::testing_package::testing_exported_interface::Guest;
use wit_bindgen::generate;

generate!({ generate_all });
struct Component;
export!(Component);

impl Guest for Component {
    fn fibo(n: u8) -> u64 {
        if n == 0 {
            0
        } else if n == 1 {
            1
        } else {
            Self::fibo(n - 1) + Self::fibo(n - 2)
        }
    }
}
