-- Sound paths (pointing to your custom .wav file in a user-accessible directory)
-- local normal_mode_sound = "/Users/migbyte/Documents/sounds/MGS5 IDroid PowerOff.wav"
-- local insert_mode_sound = "/Users/migbyte/Documents/sounds/MGS5 IDroid PowerOn.wav"
-- local visual_mode_sound = "/System/Library/Sounds/Glass.aiff" -- Default macOS sound
-- Function to play sound asynchronously using vim.loop.spawn
local last_play_time = vim.loop.now() -- Initialize last play time
local throttle_delay = 100            -- Throttle delay in milliseconds

local function play_sound(sound)
  local now = vim.loop.now()
  if now - last_play_time > throttle_delay then
    last_play_time = now
    vim.loop.spawn("afplay", { args = { sound } })
  end
end
-- Ensure sounds don't repeat unnecessarily
local last_mode = nil

-- Play sound when entering Normal, Insert, or Visual modes
vim.api.nvim_create_autocmd("ModeChanged", {
  callback = function()
    local mode = vim.fn.mode()
    if mode ~= last_mode then
      last_mode = mode
      if mode == "n" then
        play_sound(normal_mode_sound)
      elseif mode == "i" then
        play_sound(insert_mode_sound)
      elseif mode:match("[vV␖]") then
        play_sound(visual_mode_sound)
      end
    end
  end,
})

-- Return the module (not strictly needed for this use case, but for consistency)
return {}
