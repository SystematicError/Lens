#!/usr/bin/env luajit

-- TODO: CLI argument parsing

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
        label = "/home/systematic/Pictures/ocean.png",
        css_classes = {"subtitle"}
    }

    local title_box = Gtk.Box {orientation = Gtk.Orientation.VERTICAL}
    title_box:append(title)
    title_box:append(subtitle)

    local header = Gtk.HeaderBar {title_widget = title_box}
    header:pack_start(open)
    main_window:set_titlebar(header)

    -- TODO: Greeting screen

    local image = Gtk.Picture()
    image:set_alternative_text("Failed to load image")
    main_window:set_child(image)

    function open:on_clicked()
        local file_chooser = Gtk.FileChooserDialog {title = "Choose an image"}
        file_chooser:set_transient_for(main_window)

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
                -- TODO: Error Handling
                local texture = Gdk.Texture.new_from_file(file_chooser:get_file())
                image:set_paintable(texture)

            end

            file_chooser:destroy()
        end

        file_chooser:present()
    end

    main_window:present()
end

app:run()

