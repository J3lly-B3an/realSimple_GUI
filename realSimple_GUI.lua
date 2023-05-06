
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



-- Button class
gui.Button = setmetatable({}, gui.Component)
gui.Button.__index = gui.Button

function gui.Button:new(x, y, width, height, text, onClick)
    local button = gui.Component.new(self, x, y, width, height)
    button.text = text or ""
    button.onClick = onClick or function() end
    return button
end

function gui.Button:draw()
    local x, y = self:getAbsolutePosition()
    love.graphics.rectangle("line", x, y, self.width, self.height)
    love.graphics.printf(self.text, x, y + self.height / 2 - 6, self.width, "center")
    self:drawChildren()
end

function gui.Button:isMouseOver(mx, my)
    local x, y = self:getAbsolutePosition()
    return mx >= x and mx <= x + self.width and my >= y and my <= y + self.height
end

function gui.Button:mousepressed(x, y, button)
    if button == 1 and self:isMouseOver(x, y) then
        self.onClick()
    end
end

-- ContextMenu class
gui.ContextMenu = setmetatable({}, gui.Component)
gui.ContextMenu.__index = gui.ContextMenu

function gui.ContextMenu:new(options)
    local contextMenu = gui.Component.new(self, 0, 0, 0, 0)
    contextMenu.options = options or {}
    contextMenu.visible = false
    contextMenu.parentClickHandler = function(parent, x, y, button)
        if button == 2 then
            self.visible = true
            self.x = x - parent.x
            self.y = y - parent.y
        end
    end
    return contextMenu
end

function gui.ContextMenu:draw()
    if self.visible then
        local x, y = self:getAbsolutePosition()
        local font = love.graphics.getFont()
        local lineHeight = font:getHeight()

        self.width = 0
        for _, option in ipairs(self.options) do
            self.width = math.max(self.width, font:getWidth(option) + 8)
        end

        self.height = #self.options * lineHeight
        love.graphics.rectangle("line", x, y, self.width, self.height)

        for i, option in ipairs(self.options) do
            love.graphics.print(option, x + 4, y + (i - 1) * lineHeight)
        end

        self:drawChildren()
    end
end

function gui.ContextMenu:mousepressed(x, y, button)
    if button == 1 and self.visible then
        local selectedIndex = nil
        for i, _ in ipairs(self.options) do
            local optionX, optionY = self:getAbsolutePosition()
            local font = love.graphics.getFont()
            local lineHeight = font:getHeight()
            if x >= optionX and x <= optionX + self.width and y >= optionY + (i - 1) * lineHeight and y <= optionY + i * lineHeight then
                selectedIndex = i
                break
            end
        end

        if selectedIndex then
            self:onOptionSelected(selectedIndex)
        end

        self.visible = false
    end
end

function gui.ContextMenu:onOptionSelected(index)
end


-- ColumnList class
gui.ColumnList = setmetatable({}, gui.Component)
gui.ColumnList.__index = gui.ColumnList

function gui.ColumnList:new(columns, rows)
    local columnList = gui.Component.new(self, 0, 0, 0, 0)
    columnList.columns = columns or {}
    columnList.rows = rows or {}
    columnList.offsetY = 0
    columnList.scrollSpeed = 20
    return columnList
end

function gui.ColumnList:addRow(row)
    table.insert(self.rows, row)
end

function gui.ColumnList:draw()
    local x, y = self:getAbsolutePosition()

    for i, column in ipairs(self.columns) do
        love.graphics.print(column, x + 4, y - self.offsetY)
        y = y + 20

        for _, row in ipairs(self.rows) do
            love.graphics.print(row[i] or "", x + 4, y - self.offsetY)
            y = y + 20
        end

        x = x + 100
        y = self.y
    end

    self:drawChildren()
end

function gui.ColumnList:update(dt)
    if love.keyboard.isDown("up") then
        self.offsetY = math.min(self.offsetY + self.scrollSpeed * dt, 0)
    end
    if love.keyboard.isDown("down") then
        self.offsetY = math.max(self.offsetY - self.scrollSpeed * dt, -20 * (#self.rows - 1))
    end
end


-- DropdownMultichoice class
gui.DropdownMultichoice = setmetatable({}, gui.Component)
gui.DropdownMultichoice.__index = gui.DropdownMultichoice

function gui.DropdownMultichoice:new(options)
    local dropdown = gui.Component.new(self, 0, 0, 200, 30)
    dropdown.options = options or {}
    dropdown.expanded = false
    dropdown.selected = {}
    dropdown.backgroundColor = {0.7, 0.7, 0.7}
    dropdown.borderColor = {0, 0, 0}
    dropdown.textColor = {0, 0, 0}
    return dropdown
end

function gui.DropdownMultichoice:draw()
    local x, y = self:getAbsolutePosition()

    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", x, y, self.width, self.height)
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", x, y, self.width, self.height)
    love.graphics.setColor(self.textColor)
    love.graphics.print("Select options", x + 4, y + 4)

    if self.expanded then
        local optY = y + self.height
        for i, option in ipairs(self.options) do
            love.graphics.setColor(self.borderColor)
            love.graphics.rectangle("line", x, optY, self.width, self.height)
            love.graphics.setColor(self.backgroundColor)
            love.graphics.rectangle("fill", x, optY, self.width, self.height)
            love.graphics.setColor(self.textColor)
            love.graphics.print(option.text, x + 4, optY + 4)

            if self.selected[i] then
                love.graphics.print("X", x + self.width - 20, optY + 4)
            end

            optY = optY + self.height
        end
    end
end

function gui.DropdownMultichoice:mousepressed(x, y, button)
    if button == 1 then
        local px, py = self:getAbsolutePosition()
        if self.expanded then
            local optY = py + self.height
            for i, option in ipairs(self.options) do
                if x >= px and x <= px + self.width and y >= optY and y <= optY + self.height then
                    self.selected[i] = not self.selected[i]
                    return
                end
                optY = optY + self.height
            end
        end

        if x >= px and x <= px + self.width and y >= py and y <= py + self.height then
            self.expanded = not self.expanded
        else
            self.expanded = false
        end
    end
end


-- SliderBar class
gui.SliderBar = setmetatable({}, gui.Component)
gui.SliderBar.__index = gui.SliderBar

function gui.SliderBar:new(min, max, value)
    local slider = gui.Component.new(self, 0, 0, 200, 20)
    slider.minValue = min or 0
    slider.maxValue = max or 100
    slider.value = value or slider.minValue
    slider.thumbPosition = 0
    slider:updateThumbPosition()
    slider.backgroundColor = {0.7, 0.7, 0.7}
    slider.thumbColor = {0.5, 0.5, 0.5}
    slider.borderColor = {0, 0, 0}
    return slider
end

function gui.SliderBar:draw()
    local x, y = self:getAbsolutePosition()

    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", x, y + self.height / 2 - 2, self.width, 4)
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", x, y + self.height / 2 - 2, self.width, 4)

    love.graphics.setColor(self.thumbColor)
    love.graphics.rectangle("fill", x + self.thumbPosition - 8, y, 16, self.height)
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", x + self.thumbPosition - 8, y, 16, self.height)
end

function gui.SliderBar:updateThumbPosition()
    local range = self.maxValue - self.minValue
    self.thumbPosition = (self.value - self.minValue) / range * self.width
end

function gui.SliderBar:mousepressed(x, y, button)
    if button == 1 then
        local ax, ay = self:getAbsolutePosition()
        if x >= ax and x <= ax + self.width and y >= ay and y <= ay + self.height then
            self.dragging = true
        end
    end
end

function gui.SliderBar:mousereleased(_, _, button)
    if button == 1 then
        self.dragging = false
    end
end

function gui.SliderBar:mousemoved(x, y, _, _, istouch)
    if self.dragging and not istouch then
        local ax, ay = self:getAbsolutePosition()
        local range = self.maxValue - self.minValue
        self.value = self.minValue + (x - ax) / self.width * range
        self.value = math.max(math.min(self.value, self.maxValue), self.minValue)
        self:updateThumbPosition()
    end
end


-- ProgressBar class
gui.ProgressBar = setmetatable({}, gui.Component)
gui.ProgressBar.__index = gui.ProgressBar

function gui.ProgressBar:new(min, max, value)
    local progressBar = gui.Component.new(self, 0, 0, 200, 20)
    progressBar.minValue = min or 0
    progressBar.maxValue = max or 100
    progressBar.value = value or progressBar.minValue
    progressBar.backgroundColor = {0.7, 0.7, 0.7}
    progressBar.foregroundColor = {0.4, 0.6, 0.8}
    progressBar.borderColor = {0, 0, 0}
    return progressBar
end

function gui.ProgressBar:draw()
    local x, y = self:getAbsolutePosition()
    local progressWidth = (self.value - self.minValue) / (self.maxValue - self.minValue) * self.width

    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", x, y, self.width, self.height)
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", x, y, self.width, self.height)
    love.graphics.setColor(self.foregroundColor)
    love.graphics.rectangle("fill", x, y, progressWidth, self.height)
end

function gui.ProgressBar:setValue(value)
    self.value = math.min(math.max(value, self.minValue), self.maxValue)
end


-- TextInput component
gui.TextInput = {}
gui.TextInput.__index = gui.TextInput
setmetatable(gui.TextInput, {__index = gui.Base})

function gui.TextInput:new(x, y, width, height)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.x, obj.y, obj.width, obj.height = x or 0, y or 0, width or 100, height or 20
    obj.backgroundColor = {1, 1, 1}
    obj.foregroundColor = {0, 0, 0}
    obj.borderColor = {0.6, 0.6, 0.6}
    obj.text = ""
    obj.cursorPosition = 0
    obj.cursorVisible = true
    obj.cursorTimer = 0
    obj.cursorBlinkTime = 0.5
    obj.hasFocus = false
    return obj
end

function gui.TextInput:draw()
    local x, y = self:getAbsolutePosition()

    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", x, y, self.width, self.height)
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", x, y, self.width, self.height)
    love.graphics.setColor(self.foregroundColor)
    love.graphics.printf(self.text, x + 2, y + self.height / 2 - 3, self.width - 4)

    if self.hasFocus and self.cursorVisible then
        local cursorX = x + 2 + love.graphics.getFont():getWidth(self.text:sub(1, self.cursorPosition))
        love.graphics.line(cursorX, y + 2, cursorX, y + self.height - 4)
    end
end

function gui.TextInput:update(dt)
    if self.hasFocus then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= self.cursorBlinkTime then
            self.cursorVisible = not self.cursorVisible
            self.cursorTimer = 0
        end
    end
end

function gui.TextInput:mousepressed(x, y, button)
    if self:isPointInside(x, y) then
        self.hasFocus = true
    else
        self.hasFocus = false
    end
end

function gui.TextInput:textinput(text)
    if self.hasFocus then
        self.text = self.text:sub(1, self.cursorPosition) .. text .. self.text:sub(self.cursorPosition + 1)
        self.cursorPosition = self.cursorPosition + 1
    end
end

function gui.TextInput:keypressed(key)
    if self.hasFocus then
        if key == "backspace" then
            self.text = self.text:sub(1, self.cursorPosition - 1) .. self.text:sub(self.cursorPosition + 1)
            self.cursorPosition = math.max(self.cursorPosition - 1, 0)
        elseif key == "delete" then
            self.text = self.text:sub(1, self.cursorPosition) .. self.text:sub(self.cursorPosition + 2)
        elseif key == "left" then
            self.cursorPosition = math.max(self.cursorPosition - 1, 0)
        elseif key == "right" then
            self.cursorPosition = math.min(self.cursorPosition + 1, #self.text)
        elseif key == "home" then
            self.cursorPosition = 0
        elseif key == "end" then
            self.cursorPosition = #self.text
        end
    end
end


-- Text component
gui.Text = {}
gui.Text.__index = gui.Text
setmetatable(gui.Text, {__index = gui.Base})

function gui.Text:new(x, y, text)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.x, obj.y = x or 0, y or 0
    obj.text = text or ""
    obj.foregroundColor = {1, 1, 1}
    return obj
end

function gui.Text:draw()
    local x, y = self:getAbsolutePosition()
    love.graphics.setColor(self.foregroundColor)
    love.graphics.print(self.text, x, y)
end


-- gui.lua
-- ...

-- Tooltip component
gui.Tooltip = {}
gui.Tooltip.__index = gui.Tooltip
setmetatable(gui.Tooltip, {__index = gui.Base})

function gui.Tooltip:new(text, parent)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.text = text or ""
    obj.foregroundColor = {1, 1, 1}
    obj.backgroundColor = {0, 0, 0, 0.8}
    obj.parent = parent
    obj.hovered = false
    obj.padding = 4
    return obj
end

function gui.Tooltip:draw()
    if self.hovered then
        local x, y = self.parent:getAbsolutePosition()
        local font = love.graphics.getFont()
        local textWidth, textHeight = font:getWidth(self.text), font:getHeight()

        love.graphics.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", x, y - textHeight - self.padding, textWidth + 2 * self.padding, textHeight + 2 * self.padding)

        love.graphics.setColor(self.foregroundColor)
        love.graphics.print(self.text, x + self.padding, y - textHeight)
    end
end

function gui.Tooltip:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local parentX, parentY, parentWidth, parentHeight = self.parent:getBoundingBox()
    self.hovered = mouseX >= parentX and mouseX <= parentX + parentWidth and mouseY >= parentY and mouseY <= parentY + parentHeight
end

-- Checkbox component
gui.Checkbox = {}
gui.Checkbox.__index = gui.Checkbox
setmetatable(gui.Checkbox, {__index = gui.Base})

function gui.Checkbox:new(x, y, size, checked)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.x, obj.y = x or 0, y or 0
    obj.size = size or 20
    obj.checked = checked or false
    obj.borderColor = {1, 1, 1}
    obj.fillColor = {0.6, 0.6, 0.6}
    obj.checkColor = {0, 1, 0}
    obj.hovered = false
    obj.onClick = function() end
    return obj
end

function gui.Checkbox:draw()
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self:getAbsolutePosition(), self.size, self.size)

    if self.checked then
        love.graphics.setColor(self.checkColor)
    else
        love.graphics.setColor(self.fillColor)
    end
    love.graphics.rectangle("fill", self:getAbsolutePosition(), self.size - 2, self.size - 2)
end

function gui.Checkbox:update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local x, y, width, height = self:getBoundingBox()
    self.hovered = mouseX >= x and mouseX <= x + width and mouseY >= y and mouseY <= y + height
end

function gui.Checkbox:mousepressed(x, y, button)
    if self.hovered and button == 1 then
        self.checked = not self.checked
        self.onClick(self.checked)
    end
end

-- DialogBox component
gui.DialogBox = {}
gui.DialogBox.__index = gui.DialogBox
setmetatable(gui.DialogBox, {__index = gui.Base})

function gui.DialogBox:new(x, y, width, height, title, message)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.x, obj.y = x or 0, y or 0
    obj.width, obj.height = width or 200, height or 100
    obj.title = title or "Dialog"
    obj.message = message or ""
    obj.borderColor = {1, 1, 1}
    obj.titleBackgroundColor = {0.2, 0.2, 0.2}
    obj.backgroundColor = {0.4, 0.4, 0.4}
    obj.textColor = {1, 1, 1}
    obj.font = love.graphics.newFont(12)
    obj.titleFont = love.graphics.newFont(14)
    return obj
end

function gui.DialogBox:draw()
    local x, y = self:getAbsolutePosition()

    -- Draw the border and background
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", x, y, self.width, self.height)
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", x + 1, y + 1, self.width - 2, self.height - 2)

    -- Draw the title bar
    love.graphics.setColor(self.titleBackgroundColor)
    love.graphics.rectangle("fill", x + 1, y + 1, self.width - 2, 25)

    -- Draw the title text
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.textColor)
    love.graphics.printf(self.title, x, y + 5, self.width, "center")

    -- Draw the message text
    love.graphics.setFont(self.font)
    love.graphics.printf(self.message, x + 10, y + 35, self.width - 20, "left")
end

-- RadioButton component
gui.RadioButton = {}
gui.RadioButton.__index = gui.RadioButton
setmetatable(gui.RadioButton, {__index = gui.Base})

function gui.RadioButton:new(x, y, label, group)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.x, obj.y = x or 0, y or 0
    obj.label = label or ""
    obj.group = group
    obj.selected = false
    obj.borderColor = {1, 1, 1}
    obj.backgroundColor = {0.2, 0.2, 0.2}
    obj.textColor = {1, 1, 1}
    obj.font = love.graphics.newFont(12)
    obj.circleRadius = 6
    return obj
end

function gui.RadioButton:draw()
    local x, y = self:getAbsolutePosition()

    -- Draw the outer circle
    love.graphics.setColor(self.borderColor)
    love.graphics.circle("line", x + self.circleRadius, y + self.circleRadius, self.circleRadius)

    -- Draw the inner circle if selected
    if self.selected then
        love.graphics.setColor(self.backgroundColor)
        love.graphics.circle("fill", x + self.circleRadius, y + self.circleRadius, self.circleRadius - 2)
    end

    -- Draw the label text
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.label, x + self.circleRadius * 2 + 4, y)
end

function gui.RadioButton:mousepressed(x, y, button)
    if button == 1 and self:isMouseInside(x, y) then
        self.selected = not self.selected
        if self.group then
            for _, radioButton in ipairs(self.group) do
                if radioButton ~= self then
                    radioButton.selected = false
                end
            end
        end
    end
end


-- MenuBar component
gui.MenuBar = {}
gui.MenuBar.__index = gui.MenuBar
setmetatable(gui.MenuBar, {__index = gui.Base})

function gui.MenuBar:new(x, y, width, height)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.x, obj.y = x or 0, y or 0
    obj.width, obj.height = width or love.graphics.getWidth(), height or 25
    obj.backgroundColor = {0.8, 0.8, 0.8}
    obj.menuItems = {}
    return obj
end

function gui.MenuBar:addMenuItem(label, callback)
    local menuItem = {label = label, callback = callback}
    table.insert(self.menuItems, menuItem)
    return menuItem
end

function gui.MenuBar:draw()
    local x, y = self:getAbsolutePosition()
    local menuItemWidth = self.width / #self.menuItems

    -- Draw the background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", x, y, self.width, self.height)

    -- Draw the menu items
    love.graphics.setColor(0, 0, 0)
    for i, menuItem in ipairs(self.menuItems) do
        local menuItemX = x + (i - 1) * menuItemWidth
        love.graphics.print(menuItem.label, menuItemX + 10, y + (self.height - love.graphics.getFont():getHeight()) / 2)
    end
end

function gui.MenuBar:mousepressed(x, y, button)
    if button == 1 and self:isMouseInside(x, y) then
        local menuItemWidth = self.width / #self.menuItems
        local index = math.floor((x - self.x) / menuItemWidth) + 1
        if self.menuItems[index] and self.menuItems[index].callback then
            self.menuItems[index].callback()
        end
    end
end



-- ColorPicker component
gui.ColorPicker = {}
gui.ColorPicker.__index = gui.ColorPicker
setmetatable(gui.ColorPicker, {__index = gui.Base})

function gui.ColorPicker:new(x, y)
    local obj = setmetatable(gui.Base.new(self), self)
    obj.x, obj.y = x or 0, y or 0
    obj.redSlider = gui.Slider:new(0, 0, 100, 20, 0, 255)
    obj.greenSlider = gui.Slider:new(0, 30, 100, 20, 0, 255)
    obj.blueSlider = gui.Slider:new(0, 60, 100, 20, 0, 255)
    return obj
end

function gui.ColorPicker:getColor()
    local r, g, b = self.redSlider:getValue(), self.greenSlider:getValue(), self.blueSlider:getValue()
    return {r / 255, g / 255, b / 255}
end

function gui.ColorPicker:update(dt)
    self.redSlider:update(dt)
    self.greenSlider:update(dt)
    self.blueSlider:update(dt)
end

function gui.ColorPicker:draw()
    local x, y = self:getAbsolutePosition()

    -- Draw sliders
    self.redSlider:draw()
    self.greenSlider:draw()
    self.blueSlider:draw()

    -- Draw color preview
    local color = self:getColor()
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x + self.redSlider.width + 10, y, 50, 90)
end

function gui.ColorPicker:mousepressed(x, y, button)
    self.redSlider:mousepressed(x, y, button)
    self.greenSlider:mousepressed(x, y, button)
    self.blueSlider:mousepressed(x, y, button)
end


-----


return gui
