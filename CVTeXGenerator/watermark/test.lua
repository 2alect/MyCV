local wm = dofile('watermark/mark.lua')
assert(wm.hash('abc') == 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad')
local prefix = 'build/wm-unit-'
local function write(name, data)
  local f = assert(io.open(prefix .. name, 'wb')); f:write(data); f:close()
end
local function fingerprint() return wm.fingerprint(prefix..'secret', prefix..'content', prefix..'photo') end
write('secret', 'recipient | date | nonce\n'); write('content', 'Example content'); write('photo', 'image bytes')
local initial = fingerprint()
assert(initial.id == fingerprint().id)
write('photo', 'modified image bytes'); assert(initial.id ~= fingerprint().id)
write('photo', 'image bytes'); write('content', 'Changed content'); assert(initial.id ~= fingerprint().id)
write('content', 'Example content'); write('secret', 'another recipient'); assert(initial.id ~= fingerprint().id)
write('secret', string.rep('x',128)); assert(pcall(fingerprint))
write('secret', string.rep('x',129)); assert(not pcall(fingerprint))
write('secret', ''); assert(not pcall(fingerprint))
write('secret', 'line1\nline2'); assert(not pcall(fingerprint))
write('secret', '\239\187\191recipient | date | nonce\r\n'); assert(fingerprint().id == initial.id)
os.remove(prefix..'photo'); assert(fingerprint().photo == 'absent')
for _,name in ipairs({'secret','content'}) do os.remove(prefix..name) end
print('Watermark unit checks passed')
