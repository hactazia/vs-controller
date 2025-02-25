local screen = {}

function screen.getScreen()
    return peripheral.find("monitor")
end

function screen.clear()
    local monitor = screen.getScreen()
    if monitor == nil then
        return
    end
    monitor.clear()
end

function screen.write(text, x, y)
    local monitor = screen.getScreen()
    if monitor == nil then
        return
    end
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

return screen