use crate::exports::template_http::activity::http_get::Guest as GetGuest;
use crate::exports::template_http::activity::http_post::Guest as PostGuest;
use wit_bindgen::generate;
use wstd::{
    http::{Client, IntoBody as _, Method, Request},
    runtime::block_on,
};

generate!({ generate_all });
struct Component;
export!(Component);

async fn get_plain(url: &str) -> Result<String, anyhow::Error> {
    let client = Client::new();
    let request = Request::builder()
        .uri(url)
        .method(Method::GET)
        .header("User-Agent", "my-awesome-agent/1.0")
        .body(wstd::io::empty())?;
    let response = client.send(request).await?;
    eprintln!("< {:?} {}", response.version(), response.status());
    for (key, value) in response.headers().iter() {
        let value = String::from_utf8_lossy(value.as_bytes());
        eprintln!("< {key}: {value}");
    }
    let body = response.into_body().bytes().await?;
    Ok(String::from_utf8_lossy(&body).into_owned())
}

async fn get_json(url: &str) -> Result<String, anyhow::Error> {
    let client = Client::new();
    let request = Request::builder()
        .uri(url)
        .method(Method::GET)
        .header("Accept", "application/json")
        .body(wstd::io::empty())?;
    let response = client.send(request).await?;
    eprintln!("< {:?} {}", response.version(), response.status());
    for (key, value) in response.headers().iter() {
        let value = String::from_utf8_lossy(value.as_bytes());
        eprintln!("< {key}: {value}");
    }
    let body: serde_json::Value = response.into_body().json().await?;
    Ok(serde_json::to_string(&body)?)
}

async fn post(url: &str, conetnt_type: &str, body: String) -> Result<String, anyhow::Error> {
    let client = Client::new();
    let request = Request::builder()
        .uri(url)
        .method(Method::POST)
        .header("content-type", conetnt_type)
        .body(body.as_bytes().into_body())?;
    let response = client.send(request).await?;
    eprintln!("< {:?} {}", response.version(), response.status());
    for (key, value) in response.headers().iter() {
        let value = String::from_utf8_lossy(value.as_bytes());
        eprintln!("< {key}: {value}");
    }
    let body = response.into_body().bytes().await?;
    Ok(String::from_utf8_lossy(&body).into_owned())
}

impl GetGuest for Component {
    fn get_plain(url: String) -> Result<String, String> {
        block_on(async move { get_plain(&url).await.map_err(|err| err.to_string()) })
    }

    fn get_json(url: String) -> Result<String, String> {
        block_on(async move { get_json(&url).await.map_err(|err| err.to_string()) })
    }
}

impl PostGuest for Component {
    fn post(url: String, content_type: String, body: String) -> Result<String, String> {
        block_on(async move {
            post(&url, &content_type, body)
                .await
                .map_err(|err| err.to_string())
        })
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
