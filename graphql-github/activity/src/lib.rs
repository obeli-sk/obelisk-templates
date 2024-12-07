use crate::exports::template_graphql_github::activity::graphql_github::Guest;
use cynic::GraphQlResponse;
use exports::template_graphql_github::activity::graphql_github;
use obelisk::log::log::info;
use waki::Client;
use wit_bindgen::generate;

generate!({ generate_all });
pub(crate) struct Component;
export!(Component);

#[cynic::schema("github")]
mod schema {}

impl Guest for Component {
    fn releases(owner: String, repo: String) -> Result<Vec<graphql_github::Release>, String> {
        let query = build_query(&owner, &repo);
        println!("query to send: {query:?}");
        let github_token = std::env::var("GITHUB_TOKEN")
            .expect("GITHUB_TOKEN must be passed as environment variable");
        let resp = Client::new()
            .post("https://api.github.com/graphql")
            .header("Authorization", format!("Bearer {github_token}"))
            .header("User-Agent", "test")
            .json(&query)
            .send()
            .map_err(|err| format!("{err:?}"))?;
        if resp.status_code() != 200 {
            return Err(format!("Unexpected status code: {}", resp.status_code()));
        }
        let resp: GraphQlResponse<Releases> = resp.json().map_err(|err| format!("{err:?}"))?;
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
            info(&format!(
                "Got {} releases for {owner}/{repo}",
                releases.len()
            ));
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
