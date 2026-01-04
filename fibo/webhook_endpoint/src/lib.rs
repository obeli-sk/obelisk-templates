use crate::generated::obelisk::log::log::info;
use crate::generated::obelisk::types::time::ScheduleAt;
use crate::generated::template_fibo::workflow::fibo_workflow_ifc as workflow;
use crate::generated::template_fibo::workflow_obelisk_schedule::fibo_workflow_ifc as workflow_schedule;
use wstd::http::body::Body;
use wstd::http::{Error, Request, Response, StatusCode};

mod generated {
    #![allow(clippy::empty_line_after_outer_attr)]
    include!(concat!(env!("OUT_DIR"), "/any.rs"));
}

#[wstd::http_server]
async fn main(_request: Request<Body>) -> Result<Response<Body>, Error> {
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
        let execution_id = workflow_schedule::fiboa_schedule(ScheduleAt::Now, n, iterations);
        format!("scheduled: {}", execution_id.id)
    } else if n > 1 {
        // Call the execution directly.
        println!("direct call");
        let fibo_res = workflow::fiboa(n, iterations).unwrap();
        format!("direct call: {fibo_res}")
    } else {
        println!("hardcoded");
        "hardcoded: 1".to_string() // For performance testing - no activity is called
    };
    info(&format!("Sending response {fibo_res}"));
    Response::builder()
        .status(StatusCode::OK)
        .body(Body::from(fibo_res))
        .map_err(Error::from)
}
