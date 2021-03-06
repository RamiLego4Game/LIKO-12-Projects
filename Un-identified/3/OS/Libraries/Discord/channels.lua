--Discord channels api implementation

local discord = ...

local chns = {}

function chns.getChannel(id)
  return assert(discord.request("channels/"..id))
end

function chns.modifyChannel(id,params)
  return assert(discord.request("channels/"..id,params,"PATCH"))
end

function chns.deleteChannel(id)
  return assert(discord.request("channels/"..id,false,"DELETE"))
end

chns.closeChannel = chns.deleteChannel

function chns.getChannelMessages(id,around,before,after,limit)
  local data = {
    around=around, before=before, after=after, limit=limit
  }
  
  data = http.urlencode(data)
  
  return assert(discord.request("channels/"..id.."/messages?"..data))
end

function chns.getChannelMessage(chid,msid)
  return assert(discord.request("channels/"..chid.."/messages/"..msid))
end

function chns.createMessage(chid,content)
  return assert(discord.request("channels/"..chid.."/messages",{content=content},"POST"))
end

function chns.createReaction(chid,msid,emoji)
  return assert(discord.request("channels/"..chid.."/messages/"..msid.."/reactions/"..emoji.."/@me", false, "PUT"))
end

function chns.deleteOwnReaction(chid,msid,emoji)
  return assert(discord.request("channels/"..chid.."/messages/"..msid.."/reactions/"..emoji.."/@me", false, "DELETE"))
end

function chns.deleteUserReaction(chid,msid,emoji,usid)
  return assert(discord.request("channels/"..chid.."/messages/"..msid.."/reactions/"..emoji.."/"..usid, false, "DELETE"))
end

function chns.getReactions(chid,msid,emoji,before,after,limit)
  local data = {
    before=before, after=after, limit=limit
  }
  
  data = http.urlencode(data)
  
  return assert(discord.request("channels/"..chid.."/messages/"..msid.."/reactions/"..emoji.."?"..data))
end

function chns.deleteAllReactions(chid,msid)
  return assert(discord.request("channels/"..chid.."/messages/"..msid.."/reactions", false, "DELETE"))
end

return chns