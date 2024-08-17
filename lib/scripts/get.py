# Description: Script makes a REST request.
# Input:
#   argv[1] - method
#   argv[2] - url
#   argv[3] - headers         -> expected as a json string
#   argv[4] - params (optional) -> expected as a json string
#
# Output:
#   exit code (-1) - Request was not sent. Script did not complete
#              (0) - Request was sent. It did not necessarily complete
#
#   stdout:  [status code]    - Status code returned by url server -> Status code: {response.status_code}
#            [response text]  - Text returned by url server        -> Response: {response.text}
#
#   stderr:  ["Invalid JSON header"] - argv[3] format error
#            ["Invalid JSON params"] - argv[4] format error
#            ["Invalid number of arguments"]
#            [HTTP Request failed: {e}]

import requests
import json
import sys

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

    # get the params from the arg list. Check formatting (expected JSON)
    body = None
    if(len(sys.argv) == 5):
        try:
          t = sys.argv[4]
          body = json.loads(t)
        except json.JSONDecodeError:
          sys.stderr.write("Invalid JSON params")
          sys.exit(-1)

    try:
      response = requests.request(method, url, headers=headers, params=body)
      print(f'Status code: {response.status_code}')
      print(f'Response: {response.text}')
    except requests.exceptions.RequestException as e:
      print(f"HTTP Request failed: {e}")
      sys.exit(-1)
    
    #program finished
    sys.exit(0)