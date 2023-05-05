
local gui = {}

-- Base class for all GUI components
gui.Component = {}
gui.Component.__index = gui.Component

function gui.Component:new(x, y, width, height)
    local component = {
        x = x or 0,
        y = y or 0,
        width = width or 0,
        height = height or 0,
        parent = nil,
        children = {}
    }
    setmetatable(component, gui.Component)
    return component
end

function gui.Component:addChild(child)
    child.parent = self
    table.insert(self.children, child)
end

function gui.Component:getAbsolutePosition()
    local x, y = self.x, self.y
    if self.parent then
        local px, py = self.parent:getAbsolutePosition()
        x, y = x + px, y + py
    end
    return x, y
end

function gui.Component:drawChildren()
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

function gui.Component:draw()
    -- To be implemented by each component
end

-- Window class
gui.Window = setmetatable({}, gui.Component)
gui.Window.__index = gui.Window

function gui.Window:new(x, y, width, height, options)
    local window = gui.Component.new(self, x, y, width, height)
    window.options = options or {draggable = false, closeButton = false, titled = false}
    return window
end

function gui.Window:draw()
    -- Draw window based on options
    -- Draw children
    self:drawChildren()
end

-- Panel class
gui.Panel = setmetatable({}, gui.Component)
gui.Panel.__index = gui.Panel

function gui.Panel:new(x, y, width, height)
    local panel = gui.Component.new(self, x, y, width, height)
    return panel
end

function gui.Panel:draw()
    -- Draw panel
    -- Draw children
    self:drawChildren()
end

-- Implement other components
-- ...

return gui
