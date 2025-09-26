local delayed_chat_delay = 240

local function print_chat_delayed(event)
  if event.tick == 0 then return end
  for _, delayed_chat_message in pairs(storage.delayed_chat_messages) do
    log(delayed_chat_message)
    game.print(delayed_chat_message)
  end

  storage.delayed_chat_messages = {}
  script.on_nth_tick(delayed_chat_delay, nil)
end

local function create_delayed_chat()
  script.on_nth_tick(delayed_chat_delay, function(event)
    print_chat_delayed(event)
  end)
end

script.on_init(function()
  storage.delayed_chat_messages = {}
  table.insert(storage.delayed_chat_messages, "DATA GENERATION FINISHED. You can quit the game now.")

  if storage.delayed_chat_messages ~= nil and next(storage.delayed_chat_messages) ~= nil then
    create_delayed_chat()
  end
end)

script.on_load(function()
  table.insert(storage.delayed_chat_messages, "DATA GENERATION FINISHED. You can quit the game now.")

  if storage.delayed_chat_messages ~= nil and next(storage.delayed_chat_messages) ~= nil then
    create_delayed_chat()
  end
end)
