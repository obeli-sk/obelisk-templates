use crate::exports::template_http::activity::http_get::Guest;
use std::time::Duration;
use wit_bindgen::generate;

generate!({ generate_all });
struct Component;
export!(Component);

impl Guest for Component {
    fn get(url: String) -> Result<String, String> {
        let resp = waki::Client::new()
            .get(&url)
            .connect_timeout(Duration::from_secs(1))
            .send()
            .map_err(|err| format!("{err:?}"))?;
        let body = resp.body().map_err(|err| format!("{err:?}"))?;
        Ok(String::from_utf8_lossy(&body).into_owned())
    }
}

#[cfg(test)]
mod tests {
    use crate::{exports::template_http::activity::http_get::Guest as _, Component};

    #[ignore]
    #[test]
    fn integration_test() {
        let url = std::env::var("TEST_URL").expect("TEST_URL must be set");
        let res = Component::get(url);
        println!("result: {res:?}");
    }
}
