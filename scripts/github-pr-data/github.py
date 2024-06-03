import os, json
import requests

SCRIPT_PATH = os.path.dirname(__file__)

headers = {
    "Authorization": f"token {os.getenv('GITHUB_TOKEN')}",
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28"
}

base_url = "https://api.github.com/repos"

repos, raised_by = [], []

with open(f"{SCRIPT_PATH}/data/github.json", "r") as github_json:
   github_json = json.loads(github_json.read())
   repos = github_json['repos']
   raised_by = github_json['raised_by']

csv = "Repo Name, Raised By, Reviewers, Title, Link"

for repo in repos:
    pulls = requests.get(f"{base_url}/{repo}/pulls", headers=headers).json()
    pull_csv = ""
    for pull in pulls:
        if pull['user']['login'] in raised_by and pull['state'] == 'open':
          reviewers = " & ".join([r['login'] for r in pull['requested_reviewers']])
          if not reviewers:
             reviewers = "None assigned"
          pull_csv += f"{repo}, {pull['user']['login']}, {reviewers}, {pull['title']}, {pull['html_url']}\n"
    csv = csv.strip("\n") + "\n" + pull_csv

print(csv.strip("\n"))