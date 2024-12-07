use crate::obelisk::log::log::info;
use crate::obelisk::types::time::ScheduleAt;
use crate::template_fibo::workflow::fibo_workflow_ifc as workflow;
use crate::template_fibo::workflow_obelisk_ext::fibo_workflow_ifc as workflow_ext;
use waki::{handler, ErrorCode, Request, Response};
use wit_bindgen::generate;

generate!({ generate_all });
#[allow(dead_code)]
struct Component;

#[handler]
fn handle(_req: Request) -> Result<Response, ErrorCode> {
    let n = std::env::var("N")
        .expect("env var `N` must be set")
        .parse()
        .expect("parameter `N` must be of type u8");

    let iterations = std::env::var("ITERATIONS")
        .expect("env var `ITERATIONS` must be set")
        .parse()
        .expect("parameter `ITERATIONS` must be of type u32");

    let fibo_res = if n >= 10 {
        println!("scheduling");
        let execution_id = workflow_ext::fiboa_schedule(ScheduleAt::Now, n, iterations);
        format!("scheduled: {}", execution_id.id)
    } else if n > 1 {
        // Call the execution directly.
        println!("direct call");
        let fibo_res = workflow::fiboa(n, iterations);
        format!("direct call: {fibo_res}")
    } else {
        println!("hardcoded");
        "hardcoded: 1".to_string() // For performance testing - no activity is called
    };
    info(&format!("Sending response {fibo_res}"));
    Response::builder().body(fibo_res).build()
}
