#!/usr/bin/env python3
"""Delete all retweets older than May 2026 using the X (Twitter) API v2."""

import os
import sys
import time
from datetime import datetime, timezone

from dotenv import load_dotenv
import tweepy

load_dotenv()

CUTOFF = datetime(2026, 5, 1, tzinfo=timezone.utc)

BEARER_TOKEN = os.environ.get("TWITTER_BEARER_TOKEN")
API_KEY = os.environ.get("TWITTER_API_KEY")
API_SECRET = os.environ.get("TWITTER_API_SECRET")
ACCESS_TOKEN = os.environ.get("TWITTER_ACCESS_TOKEN", "")
ACCESS_SECRET = os.environ.get("TWITTER_ACCESS_SECRET", "")


def get_client():
    # for name in ("TWITTER_API_KEY", "TWITTER_API_SECRET", "TWITTER_ACCESS_TOKEN", "TWITTER_ACCESS_SECRET"):
    #     if not os.environ.get(name):
    #         sys.exit(f"Missing env var: {name}")
    return tweepy.Client(
        bearer_token=BEARER_TOKEN,
        consumer_key=API_KEY,
        consumer_secret=API_SECRET,
        access_token=ACCESS_TOKEN,
        access_token_secret=ACCESS_SECRET,
        wait_on_rate_limit=True,
    )


def get_user_id(client):
    me = client.get_me()
    if not me or not me.data:
        sys.exit("Could not fetch authenticated user.")
    return me.data.id


def fetch_retweets(client, user_id):
    retweets = []
    pagination_token = None

    while True:
        resp = client.get_users_tweets(
            user_id,
            max_results=100,
            tweet_fields=["created_at", "referenced_tweets"],
            pagination_token=pagination_token,
        )

        if not resp.data:
            break

        for tweet in resp.data:
            if not tweet.referenced_tweets:
                continue
            is_retweet = any(ref.type == "retweeted" for ref in tweet.referenced_tweets)
            if is_retweet and tweet.created_at < CUTOFF:
                retweets.append(tweet)

        if "next_token" in (resp.meta or {}):
            pagination_token = resp.meta["next_token"]
        else:
            break

    return retweets


def main():
    dry_run = "--dry-run" in sys.argv

    client = get_client()
    user_id = get_user_id(client)
    print(f"Authenticated as user {user_id}")

    print("Fetching tweets (this may take a while for large timelines)...")
    retweets = fetch_retweets(client, user_id)
    print(f"Found {len(retweets)} retweet(s) older than {CUTOFF.strftime('%B %Y')}")

    if not retweets:
        return

    if dry_run:
        for rt in retweets:
            print(f"  [DRY RUN] Would unretweet {rt.id} from {rt.created_at.strftime('%Y-%m-%d')}")
        return

    deleted = 0
    for rt in retweets:
        source_id = next(ref.id for ref in rt.referenced_tweets if ref.type == "retweeted")
        try:
            client.unretweet(source_id)
            deleted += 1
            print(f"  Unretweeted {rt.id} (from {rt.created_at.strftime('%Y-%m-%d')})")
            time.sleep(1)
        except tweepy.TooManyRequests:
            print("  Rate limited — waiting 15 minutes...")
            time.sleep(900)
            client.unretweet(source_id)
            deleted += 1
        except tweepy.errors.TwitterServerError as e:
            print(f"  Server error on {rt.id}, skipping: {e}")

    print(f"\nDone. Removed {deleted}/{len(retweets)} retweets.")


if __name__ == "__main__":
    main()
