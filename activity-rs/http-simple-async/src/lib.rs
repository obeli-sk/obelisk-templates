use crate::exports::template_http::activity::http_get::Guest;
use wit_bindgen::generate;
use wstd::{
    http::{Client, Method, Request},
    runtime::block_on,
};

generate!({ generate_all });
struct Component;
export!(Component);

async fn get_plain(url: &str) -> Result<String, anyhow::Error> {
    let client = Client::new();
    let mut request = Request::builder();
    request = request.uri(url).method(Method::GET);
    let request = request.body(wstd::io::empty())?;
    let response = client.send(request).await?;
    eprintln!("< {:?} {}", response.version(), response.status());
    for (key, value) in response.headers().iter() {
        let value = String::from_utf8_lossy(value.as_bytes());
        eprintln!("< {key}: {value}");
    }
    let body = response.into_body().bytes().await?;
    Ok(String::from_utf8_lossy(&body).into_owned())
}

impl Guest for Component {
    fn get_plain(url: String) -> Result<String, String> {
        block_on(async move { get_plain(&url).await.map_err(|err| err.to_string()) })
    }
}

#[cfg(test)]
mod tests {
    use crate::{Component, exports::template_http::activity::http_get::Guest as _};

    #[ignore]
    #[test]
    fn integration_test() {
        let url = std::env::var("TEST_URL").expect("TEST_URL must be set");
        let body = Component::get_plain(url).unwrap();
        println!("body: {body}");
    }
}
