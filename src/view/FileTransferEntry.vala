/*
 *    FileTransferEntry.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
 *
 *    This file is part of Venom.
 *
 *    Venom is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Venom is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Venom.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Venom {
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/file_transfer_entry.ui")]
  public class FileTransferEntry : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label description;
    [GtkChild] private Gtk.ProgressBar progress;
    [GtkChild] private Gtk.Button open_file;
    [GtkChild] private Gtk.Button resume_transfer;
    [GtkChild] private Gtk.Button pause_transfer;
    [GtkChild] private Gtk.Button stop_transfer;
    [GtkChild] private Gtk.Button remove_transfer;

    private Logger logger;
    private FileTransferEntryViewModel view_model;
    private FileTransferExternalCommands external_commands;

    public FileTransferEntry(Logger logger, FileTransfer file_transfer, FileTransferEntryListener listener) {
      logger.d("FileTransferEntry created.");

      this.logger = logger;
      this.view_model = new FileTransferEntryViewModel(logger, file_transfer, listener);
      this.external_commands = new FileTransferExternalCommands(logger);

      view_model.bind_property("description", description, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("progress", progress, "fraction", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("open-visible", open_file, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("resume-visible", resume_transfer, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("pause-visible", pause_transfer, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("stop-visible", stop_transfer, "sensitive", GLib.BindingFlags.SYNC_CREATE);

      open_file.clicked.connect(view_model.on_open_clicked);
      resume_transfer.clicked.connect(view_model.on_resume_transfer);
      pause_transfer.clicked.connect(view_model.on_pause_transfer);
      stop_transfer.clicked.connect(view_model.on_stop_transfer);
      remove_transfer.clicked.connect(view_model.on_remove_transfer);

      view_model.open_file.connect(external_commands.open_file);
      view_model.open_save_file_dialog.connect(external_commands.open_save_file_dialog);
      external_commands.save_file_chosen.connect(view_model.on_save_file_chosen);
    }

    ~FileTransferEntry() {
      logger.d("FileTransferEntry destroyed.");
    }
  }

  public class FileTransferExternalCommands : GLib.Object {
    private Logger logger;
    public FileTransferExternalCommands(Logger logger) {
      this.logger = logger;
    }

    public signal void save_file_chosen(GLib.File file);

    public void open_save_file_dialog(string path, string filename) {
      var app = GLib.Application.get_default() as Gtk.Application;
      if (app == null) {
        logger.e("Could not get default application");
        return;
      }
      var window = app.get_active_window();
      var dialog = new Gtk.FileChooserNative(_(@"Save file $filename"),
                                             window,
                                             Gtk.FileChooserAction.SAVE,
                                             _("_Save"),
                                             _("_Cancel"));
      dialog.do_overwrite_confirmation = true;
      dialog.set_current_folder(path);
      dialog.set_current_name(filename);
      var ret = dialog.run();
      if (ret == Gtk.ResponseType.ACCEPT) {
        save_file_chosen(dialog.get_file());
      }
    }

    public void open_file(string filename) {
      string[] spawn_args = { "xdg-open", filename };
      string[] spawn_env = GLib.Environ.get();
      try {
        GLib.Process.spawn_async(null, spawn_args, spawn_env, GLib.SpawnFlags.SEARCH_PATH, null, null);
      } catch (SpawnError e) {
        logger.e("Could not open file browser: " + e.message);
      }
    }
  }
}
