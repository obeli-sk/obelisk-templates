use exports::template_fibo::workflow::fibo_workflow_ifc::Guest;
use obelisk::workflow::workflow_support::{new_join_set_generated, ClosingStrategy};
use template_fibo::{
    activity::fibo_activity_ifc::fibo as fibo_activity,
    activity_obelisk_ext::fibo_activity_ifc::{fibo_await_next, fibo_submit},
};
use wit_bindgen::generate;

generate!({ generate_all });
struct Component;
export!(Component);

impl Guest for Component {
    fn fiboa(n: u8, iterations: u32) -> u64 {
        let mut last = 0;
        for _ in 0..iterations {
            last = fibo_activity(n);
        }
        last
    }

    fn fiboa_concurrent(n: u8, iterations: u32) -> u64 {
        let join_set_id = new_join_set_generated(ClosingStrategy::Complete);
        for _ in 0..iterations {
            fibo_submit(&join_set_id, n);
        }
        let mut last = 0;
        for _ in 0..iterations {
            last = fibo_await_next(&join_set_id).unwrap().1;
        }
        last
    }
}
