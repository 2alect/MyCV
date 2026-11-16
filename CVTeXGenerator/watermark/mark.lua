local M = {}
function M.read(path)
  local f = io.open(path, 'rb')
  if not f then return nil end
  local data = f:read('*a'); f:close(); return data
end
function M.hash(data)
  return (sha2.digest256(data):gsub('.', function(c) return string.format('%02x', c:byte()) end))
end
local function field(value) return tostring(#value) .. ':' .. value end
function M.fingerprint(secret_path, content_path, photo_path)
  local secret = assert(M.read(secret_path), 'Cannot read watermark secret file')
  secret = secret:gsub('^\239\187\191', ''):gsub('\r?\n$', '')
  local count = utf8.len(secret)
  assert(count and count > 0 and count <= 128, 'Watermark secret must contain 1 to 128 UTF-8 characters')
  assert(not secret:find('[\r\n%z]'), 'Watermark secret must be a single line')
  local content = assert(M.read(content_path), 'Cannot read selected watermark content')
  local photo = M.read(photo_path)
  local content_hash = M.hash(content)
  local photo_hash = photo and M.hash(photo) or 'absent'
  local digest = M.hash('CVWM1' .. field(secret) .. field(content_hash) .. field(photo_hash))
  return {id = 'CV-' .. digest:sub(1,32), digest = digest, content = content_hash, photo = photo_hash}
end
function M.initialize()
  if M.initialized then return end
  M.initialized = true
  local path = token.get_macro('cvwatermarkfile')
  if not M.read(path) then return end
  local ok, result = pcall(M.fingerprint, path, token.get_macro('cvcontentfile'), token.get_macro('cvphotofile'))
  if not ok then
    tex.error('Invalid local watermark configuration', {tostring(result)})
    return
  end
  token.set_macro('cvwatermarkid', result.id, 'global')
  pdf.setinfo((pdf.getinfo() or '') .. string.format(
    ' /CVWatermarkVersion (1) /CVWatermarkID (%s) /CVWatermarkDigest (%s) /CVContentSHA256 (%s) /CVPhotoSHA256 (%s)',
    result.id, result.digest, result.content, result.photo))
end
return M
