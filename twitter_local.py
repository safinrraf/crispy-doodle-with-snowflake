#!/usr/bin/env python
# -*- coding: utf-8 -*-
#

# Future modules for Python 2
from __future__ import print_function

import json
import os
import queue

# Built-in modules
import sys
import threading
import time
from datetime import datetime

# Third-party modules
import boto3
import tweepy

__author__ = "Snowflake"
__version__ = "1.0"
__maintainer__ = "Snowflake"
__email__ = "developers@snowflake.com"
__status__ = "Prototype"



with open('secrets/twitter/keys.json') as config_file:
    config = json.load(config_file)

##############
# KEYS
##############
#get your Twitter API Key and Secret https://developer.twitter.com/en/apply-for-access
consumer_key = config['consumer_key']
consumer_secret = config['consumer_secret']
# get your Twitter Access Token and Secret https://developer.twitter.com/en/apply-for-access
access_token = config['access_token']
access_token_secret = config['access_token_secret']
#AWS bucket name
bucket = "my-twitter-to-snowflake-s3-bucket-1234"
# specify your own default twitter keyword here. 
keyword = "#covid"


# Function to consume the tweets from the queue and write to S3
def consumer():
    tweet_list = []
    total_count = 0
    s3_client = boto3.client('s3')

    while not event.is_set() or not pipeline.empty():

        data = pipeline.get()
        data_dict = json.loads(data)
        data_dict.update({"keyword": keyword})
        tweet_list.append(json.dumps(data_dict))
        total_count += 1

        if total_count % 2 == 0:
            print(".", end="")
        if total_count % 100 == 0:
            print("{0} tweets retrieved".format(str(total_count)))
            filename = f"tweets_{datetime.now().strftime('%Y%m%d%H%M%S')}.json"
            print(f"==> writing {str(len(tweet_list))} records to {filename}")
            tweet_file = open(filename, 'w')
            tweet_file.writelines(tweet_list)
            tweet_file.close()
            now = datetime.now()
            key = "{0}/{1}/{2}/{3}/{4}/{5}/{6}".format(keyword, str(now.year), str(now.month), str(now.day),
                                                       str(now.hour), str(now.minute), filename)
            print(f"==> uploading to {key}")
            s3_client.upload_file(filename, bucket, key)
            print(f"==> uploaded to {key}")
            tweet_list = []
            os.remove(filename)


class JSONStreamProducer(tweepy.StreamListener):

    def on_data(self, data):
        pipeline.put(data)
        if not event.is_set():
            return True
        else:
            return False

    def on_error(self, status):
        print("Error: " + str(status))


if __name__ == "__main__":
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    pipeline = queue.Queue()
    event = threading.Event()

    myListener = JSONStreamProducer()
    myStream = tweepy.Stream(auth=auth, listener=myListener)

    t = threading.Thread(target=consumer)

    myStream.filter(track=[keyword], is_async=True)
    t.start()

    time.sleep(900)
    event.set()
