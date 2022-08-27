#!/usr/bin/env luajit

-- TODO: Migrate to gtk4

local lgi = require "lgi"
local Gtk = lgi.require("Gtk", "3.0")
local Gdk = lgi.require("Gdk", "3.0")

local app = Gtk.Application {
    application_id = "com.github.systematicerror.minitools.imageviewer"
}

function app:on_startup()
    Gtk.ApplicationWindow {
      application = self,
      default_width = 500,
      default_height = 500
    }
end

function app:on_activate()
    local new_file = Gtk.Button {
        visible = true,
        Gtk.Image {visible = true, icon_name = "list-add-symbolic"}
    }

    local header = Gtk.HeaderBar {
        visible = true,
        show_close_button = true,
        title = "Image Viewer",
        new_file
    }

    self.active_window:set_titlebar(header)

    local empty = Gtk.Box {
        visible = true,
        spacing = 10,
        valign = Gtk.Align.CENTER,
        orientation = Gtk.Orientation.VERTICAL,

        Gtk.Image {
            visible = true,
            pixel_size = 70,
            icon_name = "image-missing-symbolic"
        },

        Gtk.Label {
            visible = true,
            label = "Click the + icon to open an image"
        }
    }

    -- TODO: Scale image and add gestures
    local image = Gtk.Image {visible = true}

    if arg[1] then
        empty.visible = false
        local command = (arg[1] or ""):lower()

        if command == "file" then
            header.subtitle = arg[2] or nil
            image:set_from_file(arg[2] or nil)

        elseif command == "clipboard" then
            header.subtitle = "Clipboard"

            Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD):request_image(function(_, copied)
                image:set_from_pixbuf(copied)
            end)
        end
    end

    local choosing_file = false

    function new_file.on_clicked()
        if choosing_file then return end
        choosing_file = true

        local file_chooser = Gtk.FileChooserDialog {visible = true}

        file_chooser:add_button("Open", Gtk.ResponseType.ACCEPT)
        file_chooser:add_button("Cancel", Gtk.ResponseType.CANCEL)

        -- TODO: Fix warning
        file_chooser:set_titlebar(Gtk.HeaderBar {
            visible = true,
            show_close_button = true,
            title = "Choose an image"
        })

        function file_chooser:on_response(response)
            if response == Gtk.ResponseType.ACCEPT then
                choosing_file = false
                empty.visible = false
                header.subtitle = file_chooser:get_filename()
                image:set_from_file(file_chooser:get_filename())
            end

            file_chooser:destroy()
        end
    end

    self.active_window:add(Gtk.Stack {visible = true, empty, image})
    self.active_window:present()
end

app:run()
