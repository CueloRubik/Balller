local M={}
local function checksum(s)
 local a,b=1,0
 for i=1,#s do a=(a+s:byte(i))%65521 b=(b+a)%65521 end
 return tostring(b*65536+a)
end
function M.encode(P)
 local parts={'BALLLER_PROFILE_1',P.gems,P.stars,P.hits,P.rounds,P.plays,P.skin}
 for i=1,4 do parts[#parts+1]=P.best[i] end
 for i=1,4 do parts[#parts+1]=P.owned[i] and 1 or 0 end
 local body=table.concat(parts,'|')
 return body..'|'..checksum(body)
end
function M.decode(s)
 if type(s)~='string' or #s>1000 then return false end
 local parts={}
 for part in s:gmatch('[^|]+') do parts[#parts+1]=part end
 if #parts~=16 or parts[1]~='BALLLER_PROFILE_1' then return false end
 local body=table.concat(parts,'|',1,15)
 if checksum(body)~=parts[16] then return false end
 local nums={}
 for i=2,15 do
  local n=tonumber(parts[i])
  if not n or n~=n or n%1~=0 or n<0 or n>10000000 then return false end
  nums[i]=n
 end
 if nums[7]<1 or nums[7]>4 or nums[12]~=1 then return false end
 for i=13,15 do if nums[i]>1 then return false end end
 if nums[7]>1 and nums[11+nums[7]]~=1 then return false end
 local P={best={},owned={}}
 P.gems,P.stars,P.hits,P.rounds,P.plays,P.skin=nums[2],nums[3],nums[4],nums[5],nums[6],nums[7]
 for i=1,4 do P.best[i]=nums[7+i] P.owned[i]=nums[11+i]==1 end
 return P
end
return M
