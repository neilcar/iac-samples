import twistlock.serverless
import subprocess
import os
import json
import urllib.request

def handler(event, context):

    # Read the request body.
    if "body" in event:
        cmd = event["body"]
    else:
        cmd = None

    # Check for dns command.
    if "query" in event:
        query = event["query"]
    else:
        query = None
        
    # Prepare the default response.
    response = {
      "isBase64Encoded": False,
      "statusCode": 200,
      "headers": {"Content-Type": "text/plain"},
      "body": "OK\n"
    }

    # If the request body contains a string,
    # execute it as a command in a new process.
    if cmd is not None:
        try:
            p = subprocess.Popen(cmd.split(" "), stdout=subprocess.PIPE)
            out, _ = p.communicate()
            out = out.decode("utf8")
        except Exception as e:
            out = str(e)

        response['body'] = out

    if query is not None:
        try:
            contents = urllib.request.urlopen(query)
            content = contents.getcode()
        except Exception as e:
            content = str(e)
        
        response['query'] = content
        
        
    return response
