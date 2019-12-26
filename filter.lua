-- filter
--
-- @justmat

engine.name = "Filter"

local FilterGraph = require "filtergraph"

local g = grid.connect(1)

function init()
  
  screen.aa(1)
  
  params:add_control("freq", "freq", controlspec.WIDEFREQ)
  params:set_action("freq", function(v) engine.freq(v) end)
  
  params:add_control("res", "res", controlspec.UNIPOLAR)
  params:set_action("res", function(v) engine.res(v) end)
  
  params:add_control("gain", "gain", controlspec.AMP)
  params:set_action("gain", function(v) engine.gain(v) end)
  
  params:add_number("type", "type", 0, 1, 0)
  params:set_action("type", function(v) engine.type(v) end)
  
  params:add_control("noise", "noise", controlspec.new(0.0, 1.0, "lin", 0, 0))
  params:set_action("noise", function(v) engine.noise(v * 0.01) end)
  
  fg = FilterGraph.new()
  
  local norns_redraw_timer = metro.init()
  norns_redraw_timer.time = 0.025
  norns_redraw_timer.event = function() redraw() end
  norns_redraw_timer:start()
end


local function update_fg()
  fg:edit(params:get("type") == 0 and "lowpass" or "highpass", 12, params:get("freq"), params:get("res"))
end


function enc(n, d)
  if n == 1 then
    params:delta("gain", d)
  elseif n == 2 then
    params:delta("freq", d)
  elseif n == 3 then
    params:delta("res", d)
  end
  update_fg()
end



function redraw()
  screen.clear()
  fg:redraw()
  screen.level(4)
  screen.fill()
  screen.update()
end



