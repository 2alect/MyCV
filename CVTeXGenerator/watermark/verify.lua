-- Run from CVTeXGenerator. Sidecars must be retained privately with the original PDF.
local script = arg[0]:gsub('\\', '/')
local base = script:match('^(.*)/') or '.'
local wm = dofile(base .. '/mark.lua')
local record = arg[1] == '--record'
local path = record and arg[2] or arg[1]
if not path then
  io.stderr:write('Usage: texlua watermark/verify.lua [--record] file.pdf\n'); os.exit(2)
end
local data = wm.read(path)
if not data then io.stderr:write('Cannot read PDF\n'); os.exit(2) end
local doc = pdfe.open(path)
if not doc then io.stderr:write('Invalid PDF\n'); os.exit(2) end
local raw_info = pdfe.getinfo(doc) or {}
local info = {CVWatermarkID = raw_info.CVWatermarkID, CVWatermarkDigest = raw_info.CVWatermarkDigest}
print('Copy ID: ' .. tostring(info.CVWatermarkID or 'not found'))
print('Fingerprint: ' .. tostring(info.CVWatermarkDigest or 'not found'))
pdfe.close(doc)
if not record and arg[2] then
  if not arg[3] or not arg[4] then io.stderr:write('Expected secret, content, and photo paths\n'); os.exit(2) end
  local ok, expected_mark = pcall(wm.fingerprint, arg[2], arg[3], arg[4])
  if not ok then io.stderr:write(tostring(expected_mark) .. '\n'); os.exit(2) end
  if expected_mark.digest ~= info.CVWatermarkDigest then
    io.stderr:write('Fingerprint: does NOT match supplied secret/content/photo\n'); os.exit(1)
  end
  print('Fingerprint: matches supplied secret/content/photo')
end
local digest = wm.hash(data)
local sidecar = path .. '.sha256'
if record then
  if wm.read(sidecar) then io.stderr:write('Refusing to overwrite an existing integrity record\n'); os.exit(2) end
  local f = assert(io.open(sidecar,'wb')); f:write(digest .. '\n'); f:close()
  print('Recorded SHA-256. Keep this sidecar as the trusted original record.')
else
  local expected = wm.read(sidecar)
  if not expected then print('Integrity: unknown (no trusted .sha256 sidecar)'); os.exit(0) end
  if expected:match('^([0-9a-f]+)') ~= digest then
    io.stderr:write('Integrity: CHANGED relative to the saved record\n'); os.exit(1)
  end
  print('Integrity: exact match to saved record')
end
