local gui = require "gui"

local window, panel, listBox, contextMenu, columnList, button, dropdown, slider, progressBar, colorPicker, textInput, text, checkbox, dialogBox, radioButton, menuBar

function love.load()
    window = gui.Window:new(10, 10, 400, 400, "Sample Window")
    panel = gui.Panel:new(20, 50, 100, 100)
    listBox = gui.ListBox:new(20, 160, 100, 100)

    listBox:addItem("Item 1")
    listBox:addItem("Item 2")
    listBox:addItem("Item 3")

    contextMenu = gui.ContextMenu:new({"Option 1", "Option 2", "Option 3"}, panel)

    columnList = gui.ColumnList:new(130, 50, 180, 100)
    columnList:addColumn("Column 1")
    columnList:addColumn("Column 2")
    columnList:addRow({"A1", "B1"})
    columnList:addRow({"A2", "B2"})
    columnList:addRow({"A3", "B3"})

    button = gui.Button:new(130, 160, 80, 20, "Button")
    dropdown = gui.Dropdown:new(220, 160, 80, 20, {"Option 1", "Option 2", "Option 3"})
    slider = gui.Slider:new(320, 160, 80, 20, 0, 100)
    progressBar = gui.ProgressBar:new(130, 190, 100, 20, 0, 100, 50)
    colorPicker = gui.ColorPicker:new(240, 190)
    textInput = gui.TextInput:new(130, 220, 100, 20)
    text = gui.Text:new(130, 250, "Sample Text")
    checkbox = gui.Checkbox:new(130, 270, 20, 20)
    dialogBox = gui.DialogBox:new(240, 220, "Sample Dialog")
    radioButton = gui.RadioButton:new(130, 300, 20, 20)

    menuBar = gui.MenuBar:new(0, 0, 400, 20)
    menuBar:addMenu("File", {"Open", "Save", "Exit"})
    menuBar:addMenu("Edit", {"Undo", "Redo", "Cut", "Copy", "Paste"})
    menuBar:addMenu("Help", {"About"})

    window:addChild(panel)
    window:addChild(listBox)
    window:addChild(columnList)
    window:addChild(button)
    window:addChild(dropdown)
    window:addChild(slider)
    window:addChild(progressBar)
    window:addChild(colorPicker)
    window:addChild(textInput)
    window:addChild(text)
    window:addChild(checkbox)
    window:addChild(dialogBox)
    window:addChild(radioButton)
    window:addChild(menuBar)
end

function love.draw()
    window:draw()
end

function love.update(dt)
    window:update(dt)
end

function love.mousepressed(x, y, button)
    window:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    window:mousereleased(x, y, button)
end
