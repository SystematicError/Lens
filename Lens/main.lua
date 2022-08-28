#!/usr/bin/env luajit

local lgi = require "lgi"
local Gtk = lgi.require("Gtk", "4.0")
local Gdk = lgi.require("Gdk", "4.0")

local app = Gtk.Application {application_id = "com.github.systematicerror.minitools.lens"}

function app:on_activate()
    local main_window = Gtk.ApplicationWindow {application = self}

    local open = Gtk.Button {icon_name = "list-add-symbolic"}

    local title = Gtk.Label {
        yalign = 1,
        vexpand = true,
        label = "Lens",
        css_classes = {"title"}
    }

    local subtitle = Gtk.Label {
        yalign = 0,
        vexpand = true,
        label = "No image is currently open",
        css_classes = {"subtitle"}
    }

    local title_box = Gtk.Box {orientation = Gtk.Orientation.VERTICAL}
    title_box:append(title)
    title_box:append(subtitle)

    local header = Gtk.HeaderBar {title_widget = title_box}
    header:pack_start(open)
    main_window:set_titlebar(header)

    local greeter_text = Gtk.Label {label = "Click the + icon to open an image"}

    local greeter = Gtk.Box {
        valign = Gtk.Align.CENTER,
        spacing = 10,
        orientation = Gtk.Orientation.VERTICAL
    }

    -- TODO: Use logo here instead
    greeter:append(Gtk.Image {pixel_size = 80, icon_name = "image-x-generic-symbolic"})
    greeter:append(greeter_text)

    local image = Gtk.Picture()

    local viewport = Gtk.Stack()
    viewport:add_child(greeter)
    viewport:add_child(image)
    main_window:set_child(viewport)

    local function load_image(filename)
        if filename then
            -- TODO: Error handling using Gdk.Texture
            -- Using true as debug statement
            if true then
                subtitle.label = filename:gsub("^" .. os.getenv("HOME"), "~")
                image:set_filename(filename)
                greeter.visible = false
            else
                subtitle.label = "No image is currently open"
                greeter_text.label = "Failed to open image"
                greeter.visible = true
            end
        end
    end

    if arg[1] then
        load_image()

    -- TODO: Make clipboard reading actually work
    -- Using true as a debug statement
    elseif true then
        Gdk.Display():get_clipboard():read_texture_async(function(clip, task)
            subtitle.label = "Clipboard"
            greeter.visible = false
        end)
    end

    function open:on_clicked()
        local file_chooser = Gtk.FileChooserDialog {title = "Choose an image"}
        file_chooser:set_modal(main_window)
        file_chooser:set_transient_for(main_window)

        -- TODO: Button spacing
        file_chooser:add_button("Open", Gtk.ResponseType.ACCEPT)
        file_chooser:add_button("Close", Gtk.ResponseType.CANCEL)

        -- TODO: Proper filtering
        -- local filter = Gtk.FileFilter()
        -- filter:set_name("Image Files")
        -- filter:add_mime_type("image/jpeg")
        -- filter:add_mime_type("image/png")
        -- file_chooser:add_filter(filter)

        function file_chooser:on_response(response)
            if response == Gtk.ResponseType.ACCEPT then
                load_image(file_chooser:get_file():get_path())
            end

            file_chooser:destroy()
        end

        file_chooser:present()
    end

    main_window:present()
end

app:run()

