-- filter
--
-- @justmat

engine.name = "Filter"

local g = grid.connect(1)

function init()
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
  
  redraw()
end


function redraw()
  screen.clear()
  screen.move(64, 32)
  screen.text_center("filter")
  screen.update()
end



