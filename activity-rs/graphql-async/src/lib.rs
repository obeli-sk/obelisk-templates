use generated::exports::template_graphql_github::activity::graphql_github::Guest;
use anyhow::{Context as _, bail};
use cynic::GraphQlResponse;
use generated::exports::template_graphql_github::activity::graphql_github;
use wstd::http::Client;
use wstd::{
    http::{Body, Method, Request, StatusCode},
    runtime::block_on,
};
use generated::export;

mod generated {
    #![allow(clippy::empty_line_after_outer_attr)]
    include!(concat!(env!("OUT_DIR"), "/any.rs"));
}

struct Component;
export!(Component with_types_in generated);

#[cynic::schema("github")]
mod schema {}

async fn send_query(
    owner: String,
    repo: String,
) -> Result<GraphQlResponse<Releases>, anyhow::Error> {
    let github_token =
        std::env::var("GITHUB_TOKEN").expect("GITHUB_TOKEN must be passed as environment variable");
    let query = build_query(&owner, &repo);
    println!("query to send: {query:?}");

    let req = Request::builder()
        .header("Authorization", &format!("Bearer {github_token}"))
        .header("Content-Type", "application/json")
        .header("User-Agent", "test")
        .method(Method::POST)
        .uri("https://api.github.com/graphql")
        .body(
            Body::from_json(&query)
                .with_context(|| format!("cannot serialize the query {query:?}"))?,
        )
        .context("cannot create the request")?;
    let mut resp = Client::new()
        .send(req)
        .await
        .context("cannot send the request")?;

    if resp.status() != StatusCode::OK {
        bail!("Unexpected status code: {}", resp.status());
    }
    resp.body_mut()
        .json()
        .await
        .context("deserialization error")
}

impl Guest for Component {
    fn releases(owner: String, repo: String) -> Result<Vec<graphql_github::Release>, String> {
        let resp = block_on(send_query(owner, repo)).map_err(|err| err.to_string())?;
        if let Some(errors) = resp.errors {
            eprintln!("Got errors :{errors:?}");
        }
        if let Some(data) = resp.data {
            let releases: Vec<_> = data
                .repository
                .into_iter()
                .map(|repo| repo.releases.nodes)
                .flatten()
                .flatten()
                .flatten()
                .map(graphql_github::Release::from)
                .collect();
            Ok(releases)
        } else {
            return Err("data part is missing".to_string());
        }
    }
}

impl From<Release> for graphql_github::Release {
    fn from(value: Release) -> Self {
        Self {
            tag_name: value.tag_name,
            name: value.name,
            is_latest: value.is_latest,
        }
    }
}

fn build_query<'a>(
    owner: &'a str,
    repo: &'a str,
) -> cynic::Operation<Releases, ReleasesArguments<'a>> {
    use cynic::QueryBuilder;

    Releases::build(ReleasesArguments { owner, repo })
}

// This part is generated using `cynic-querygen`

#[derive(cynic::QueryVariables, Debug)]
pub struct ReleasesArguments<'a> {
    pub owner: &'a str,
    pub repo: &'a str,
}

#[derive(cynic::QueryFragment, Debug)]
#[cynic(graphql_type = "Query", variables = "ReleasesArguments")]
pub struct Releases {
    #[arguments(owner: $owner, name: $repo)]
    pub repository: Option<Repository>,
}

#[derive(cynic::QueryFragment, Debug)]
pub struct Repository {
    #[arguments(first: 10)]
    pub releases: ReleaseConnection,
}

#[derive(cynic::QueryFragment, Debug)]
pub struct ReleaseConnection {
    pub nodes: Option<Vec<Option<Release>>>,
}

#[derive(cynic::QueryFragment, Debug)]
pub struct Release {
    pub is_latest: bool,
    pub name: Option<String>,
    pub tag_name: String,
}

#[cfg(test)]
mod tests {
    use crate::Component;
    use crate::generated::exports::template_graphql_github::activity::graphql_github::Guest as _;

    #[ignore]
    #[test]
    fn integration_test() {
        let owner = std::env::var("TEST_OWNER").expect("TEST_OWNER must be set");
        let repo = std::env::var("TEST_REPO").expect("TEST_REPO must be set");
        let releases = Component::releases(owner, repo).unwrap();
        println!("releases: {releases:?}");
    }
}
