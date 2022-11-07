import subprocess
import os
import json

def handler(event, context):

    # Read the request body.
    if "body" in event:
        cmd = event["body"]
    else:
        cmd = None

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

    return response
