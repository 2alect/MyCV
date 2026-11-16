-- Deterministic PNG preprocessing: grayscale + original alpha, no PDF soft-mask transfer functions.
local M = {}
local signature = '\137PNG\r\n\26\n'
local function read(path)
  local f = assert(io.open(path,'rb'), 'Cannot read footer PNG'); local s=f:read('*a'); f:close(); return s
end
local function chunk(kind, data)
  local payload=kind..data
  return string.pack('>I4',#data)..payload..string.pack('>I4',zlib.crc32(0,payload))
end
local function paeth(a,b,c)
  local p=a+b-c; local x,y,z=math.abs(p-a),math.abs(p-b),math.abs(p-c)
  if x<=y and x<=z then return a elseif y<=z then return b else return c end
end
function M.convert(source, output)
  local png=read(source); assert(png:sub(1,8)==signature,'Footer must be a PNG')
  local pos,idat,palette,trns=9,{},nil,nil
  local w,h,depth,color,compression,filter,interlace
  while pos<=#png do
    local n; n,pos=string.unpack('>I4',png,pos)
    local kind=png:sub(pos,pos+3); local data=png:sub(pos+4,pos+3+n)
    assert(#data==n,'Truncated PNG')
    if kind=='IHDR' then w,h,depth,color,compression,filter,interlace=string.unpack('>I4I4BBBBB',data)
    elseif kind=='IDAT' then idat[#idat+1]=data
    elseif kind=='PLTE' then palette=data
    elseif kind=='tRNS' then trns=data
    elseif kind=='IEND' then break end
    pos=pos+8+n
  end
  assert(w and w>0 and h>0 and w*h<=30000000,'Invalid or excessively large footer PNG')
  assert(depth==8 and interlace==0 and compression==0 and filter==0,
    'Footer PNG must be 8-bit, non-interlaced; export it as RGBA PNG')
  local channels=({[0]=1,[2]=3,[3]=1,[4]=2,[6]=4})[color]
  assert(channels,'Unsupported PNG color type')
  local raw=zlib.decompress(table.concat(idat)); local stride=w*channels
  assert(#raw==(stride+1)*h,'Invalid PNG scanline length')
  local previous,lines={},{}; local at=1
  for y=1,h do
    local mode=raw:byte(at); at=at+1; assert(mode<=4,'Invalid PNG filter')
    local row={}
    for x=1,stride do
      local a=row[x-channels] or 0; local b=previous[x] or 0; local c=previous[x-channels] or 0
      local predictor=0
      if mode==1 then predictor=a elseif mode==2 then predictor=b
      elseif mode==3 then predictor=math.floor((a+b)/2) elseif mode==4 then predictor=paeth(a,b,c) end
      row[x]=(raw:byte(at)+predictor)%256; at=at+1
    end
    local pixels={'\0'}
    for x=1,w do
      local i=(x-1)*channels+1; local r,g,b,a
      if color==6 then r,g,b,a=row[i],row[i+1],row[i+2],row[i+3]
      elseif color==2 then
        r,g,b,a=row[i],row[i+1],row[i+2],255
        if trns then local rr,gg,bb=string.unpack('>I2I2I2',trns); if r==rr and g==gg and b==bb then a=0 end end
      elseif color==3 then
        assert(palette,'Missing PNG palette'); local p=row[i]*3+1
        r,g,b=palette:byte(p,p+2); assert(b,'Invalid PNG palette index'); a=(trns and trns:byte(row[i]+1)) or 255
      else
        r=row[i]; g=r; b=r; a=color==4 and row[i+1] or 255
        if color==0 and trns and r==string.unpack('>I2',trns) then a=0 end
      end
      local luminance=(2126*r+7152*g+722*b)/10000
      local gray=math.floor(255-25.5*(1-luminance/255)+0.5)
      pixels[#pixels+1]=string.char(gray,a)
    end
    lines[#lines+1]=table.concat(pixels); previous=row
  end
  local ihdr=string.pack('>I4I4BBBBB',w,h,8,4,0,0,0)
  local result=signature..chunk('IHDR',ihdr)..chunk('IDAT',zlib.compress(table.concat(lines)))..chunk('IEND','')
  local f=assert(io.open(output,'wb'),'Cannot write generated footer PNG'); f:write(result); f:close()
  return output
end
function M.prepare(source)
  local digest=(sha2.digest256('footer-gray-v1:'..read(source)):gsub('.',function(c) return string.format('%02x',c:byte()) end))
  local output='build/footer-gray-'..digest..'.png'
  local existing=io.open(output,'rb')
  if existing then existing:close() else M.convert(source,output) end
  return output
end
return M
