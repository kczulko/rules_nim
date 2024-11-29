import hashlib
import urllib3
import base64
from black import format_str, FileMode

filename = "versions.bzl"

def url_sha384(url):
    http = urllib3.PoolManager()
    r = http.request('GET', url, preload_content=False)
    chunk_size = 2048
    hasher = hashlib.sha384()
    while True:
        data = r.read(chunk_size)
        if not data:
            break
        hasher.update(data)

    r.release_conn()
    return hasher.digest()

def override_versions_file(tool_versions):
    code = "TOOL_VERSIONS" + " = " + str(tool_versions)
    res = format_str(code, mode=FileMode())
    with open(filename, "w") as f:
      print(res, file=f)

def main():
    global_vars = {}
    local_vars = {}
    tool_versions = {}
    with open(filename) as f:
        code = compile(f.read(), filename, 'exec')
        exec(code, global_vars, local_vars)
    tool_versions = local_vars["TOOL_VERSIONS"]
    for version in tool_versions:
        params = tool_versions[version]
        download_url = params["download_url_template"]
        platforms = params["platforms"]
        for platform in platforms:
            url = download_url.format(version = version, platform = platform)
            sha = url_sha384(url)
            integrity = "sha384-{}".format(base64.b64encode(sha).decode())
            platforms[platform] = integrity

    override_versions_file(tool_versions)

if __name__ == "__main__":
    main()
