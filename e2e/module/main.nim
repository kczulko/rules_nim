import zip/zipfiles
# Opens a zip file for reading, writing or appending.
var z: ZipArchive
if not z.open("foo.bar.zip"):
  echo "Opening zip failed"
  quit(1)

# extracts all files from archive z to the destination directory.
z.extractAll("files/td")

