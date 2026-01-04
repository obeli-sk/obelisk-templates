use generated::export;
use generated::exports::template_fibo::workflow::fibo_workflow_ifc::Guest;
use generated::obelisk::workflow::workflow_support::join_set_create;
use generated::template_fibo::{
    activity::fibo_activity_ifc::fibo as fibo_activity,
    activity_obelisk_ext::fibo_activity_ifc::{fibo_await_next, fibo_submit},
};

mod generated {
    #![allow(clippy::empty_line_after_outer_attr)]
    include!(concat!(env!("OUT_DIR"), "/any.rs"));
}

struct Component;
export!(Component with_types_in generated);

impl Guest for Component {
    fn fiboa(n: u8, iterations: u32) -> Result<u64, ()> {
        let mut last = 0;
        for _ in 0..iterations {
            last = fibo_activity(n).unwrap();
        }
        Ok(last)
    }

    fn fiboa_concurrent(n: u8, iterations: u32) -> Result<u64, ()> {
        let join_set = join_set_create();
        for _ in 0..iterations {
            fibo_submit(&join_set, n);
        }
        let mut last = 0;
        for _ in 0..iterations {
            last = fibo_await_next(&join_set).unwrap().1.unwrap();
        }
        Ok(last)
    }
}
