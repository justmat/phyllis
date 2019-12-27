-- filter
--
-- @justmat

engine.name = "Phyllis"

local FilterGraph = require "filtergraph"

local alt = false

local lfo = include("lib/hnds_phyllis")
local lfo_targets = {
  "none",
  "freq",
  "res",
  "gain",
  "noise"
}


local function update_fg()
  -- keeps the filter graph current
  local ftype = params:get("type") == 0 and "lowpass" or "highpass"
  filter:edit(ftype, 12, params:get("freq"), params:get("res"))
end


function lfo.process()
  -- for lib hnds
  for i = 1, 4 do
    local target = params:get(i .. "lfo_target")
    if params:get(i .. "lfo") == 2 then
      -- frequency
      if target == 2 then
        params:set(lfo_targets[target], lfo.scale(lfo[i].slope, -1.0, 2.0, 0.00, 20000.00))
      -- resonance/q
      elseif target == 3 then
        params:set(lfo_targets[target], lfo.scale(lfo[i].slope, -1.0, 2.0, 0.00, 1.00))
      -- input gain
      elseif target == 4 then
        params:set(lfo_targets[target], lfo.scale(lfo[i].slope, -1.0, 2.0, 0.00, 5.00))
      -- noise
      elseif target == 5 then
        params:set(lfo_targets[target], lfo.scale(lfo[i].slope, -1.0, 2.0, 0.00, 1.00))
      end
    end
  end
end


function init()
  
  screen.aa(1)
  
  params:add_control("freq", "freq", controlspec.WIDEFREQ)
  params:set_action("freq", function(v) engine.freq(v) end)
  
  params:add_control("res", "res", controlspec.UNIPOLAR)
  params:set_action("res", function(v) engine.res(v) end)
  
  params:add_control("gain", "gain", controlspec.new(0.00, 5.00, "lin", 0.01, 1.00))
  params:set_action("gain", function(v) engine.gain(v) end)
  
  params:add_number("type", "type", 0, 1, 0)
  params:set_action("type", function(v) engine.type(v) end)
  
  params:add_control("noise", "noise", controlspec.new(0.0, 1.0, "lin", 0, 0))
  params:set_action("noise", function(v) engine.noise(v * 0.01) end)
  
  -- for hnds
  for i = 1, 4 do
    lfo[i].lfo_targets = lfo_targets
  end
  lfo.init()

  params:bang()

  norns.enc.sens(1, 5)
  
  filter = FilterGraph.new()
  filter:set_position_and_size(5, 5, 118, 35)
  
  local norns_redraw_timer = metro.init()
  norns_redraw_timer.time = 0.025
  norns_redraw_timer.event = function() update_fg() redraw() end
  norns_redraw_timer:start()
end


function key(n, z)
  -- only key 1 is used
  -- key1 is momentary alt
  if n == 1 then
    if z == 1 then
      alt = true
    else
      alt = false
    end
  end
end


function enc(n, d)
  -- enc 1 is navigation
  if n == 1 then
    params:delta("type", d)
  end
  -- filter controls
  if alt == false then
    if n == 2 then
      params:delta("freq", d)
    elseif n == 3 then
      params:delta("res", d)
    end
  else
    -- alt filter controls
    if n == 2 then
      params:delta("gain", d)
    elseif n == 3 then
      params:delta("noise", d)
    end
  end
end



function redraw()
  screen.clear()
  screen.level(alt and 2 or 4)
  -- freq
  screen.move(5, 49)
  screen.text("freq: ")
  screen.move(30, 49)
  screen.text(string.format("%.2f", params:get('freq')))
  -- res
  screen.move(100, 49)
  screen.text_right("res: ")
  screen.move(123, 49)
  screen.text_right(string.format("%.2f", params:get('res')))
  screen.level(alt and 4 or 2)
  -- gain
  screen.move(5, 59)
  screen.text("gain: ")
  screen.move(30, 59)
  screen.text(string.format("%.2f", params:get('gain')))
  -- noise
  screen.move(100, 59)
  screen.text_right("noise: ")
  screen.move(123, 59)
  screen.text_right(string.format("%.2f", params:get('noise')))
  -- filter type header
  screen.level(4)
  if params:get("type") == 1 then
    screen.move(123, 10)
    screen.text_right("hp")
  else
    screen.move(8, 10)
    screen.text("lp")
  end
  -- filtergraph
  filter:redraw()

  screen.update()
end
