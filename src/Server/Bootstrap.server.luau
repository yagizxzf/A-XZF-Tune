--!strict
local fleet=require(script.Parent.Fleet).start()
game:BindToClose(function() fleet:stop() end)
