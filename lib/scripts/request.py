'''
Logic has been moved to submod collection_calls


# Description: Script makes a REST request.
# Input:
#   argv[1] - method
#   argv[2] - url
#   argv[3] - headers         -> expected as a json string
#   argv[4] - body (optional) -> expected as a json string
#
# Output:
#   exit code (-1) - Request was not sent. Script did not complete
#              (0) - Request was sent. It was not necessarily successful. 
#                    See status codes.
#
#   stdout:  [status code]    - Status code returned by url server -> Status code: {response.status_code}
#            [response text]  - Text returned by url server        -> Response: {response.text}
#
#   stderr:  ["Invalid JSON header"] - argv[3] format error
#            ["Invalid JSON body"] - argv[4] format error
#            ["Invalid number of arguments"]
#            [HTTP Request failed: {e}]

import os
import requests
import json
import sys

def load_data(data):
    if(os.path.isfile(data)):
      with open(data, mode= 'r', encoding= 'utf-8') as file:
        contents = file.read()
      contentsJson = json.loads(contents)
      data = contentsJson['request_body']

    return data

if __name__ == "__main__":
    if len(sys.argv) < 4 or len(sys.argv) > 5:
      sys.stderr.write("Invalid number of arguments")
      sys.exit(-1)

    method = sys.argv[1].upper()
    url = sys.argv[2]

    # get the headers from the arg list. Check formatting (expected JSON) 
    headers = None
    if(len(sys.argv) >= 4):
      try:
        t = sys.argv[3] 
        headers = json.loads(t)
      except json.JSONDecodeError:
        sys.stderr.write("Invalid JSON header")
        sys.exit(-1)

    # get the body from the arg list. Check formatting (expected JSON)
    body = None
    if(len(sys.argv) == 5):
        try:
          body = load_data(sys.argv[4])
          #body = json.loads(t)
          #sys.stderr.write(f"body: {body}")
          #body['contactlist'] = json.loads(body['contactlist'])
          #body = json.dumps(body)
        except json.JSONDecodeError:
          sys.stderr.write("Invalid JSON body")
          sys.exit(-1)

    try:
      response = requests.request(method, url, headers=headers, data=body)
      print(f'Status code: {response.status_code}')
      print(f'Response: {response.text}')
    except requests.exceptions.RequestException as e:
      print(f"HTTP Request failed: {e}")
      sys.exit(-1)

    # program finished 
    sys.exit(0)
'''