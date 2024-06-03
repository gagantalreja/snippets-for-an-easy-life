# Script to Fetch Github PR Data

The script can fetch all OPEN PR data from the repositories mentioned in the `./data/github.json` file for the mentioned users.

- Create a `./data/github.json` file using the template in `./data/github.json.example` file.

- Generate a Github Personal Access Token in your github developer settings and set the GITHUB_TOKEN env variable

```shell
GITHUB_TOKEN=<your-github-pat-token>
```

- Run the following command to install the required python libraries. You can also use a python virtual environment.
```shell
python3 -m pip install -r ./requirements.txt
```

- Run the following command to run the script and get output in a csv file

```shell
python3 /Users/talreja/Desktop/repos/ld-terraform/zmisc/github.py > ./data/pulls.csv
```