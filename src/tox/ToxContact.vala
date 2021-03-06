/*
 *    ToxContact.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  public class Contact : IContact, GLib.Object {
    // Saved in toxs savefile
    public int         db_id           { get; set; }
    public string      tox_id          { get; set; }
    public uint32      tox_friend_number { get; set; }
    public string      name            { get; set; default = ""; }
    public string      status_message  { get; set; default = ""; }
    public DateTime    last_seen       { get; set; default = new DateTime.now_local(); }
    public UserStatus  user_status     { get; set; default = UserStatus.NONE; }
    // Saved in venoms savefile
    public string      alias           { get; set; default = ""; }
    public bool        is_blocked      { get; set; default = false; }
    public string      group           { get; set; default = ""; }
    public bool        auto_conference { get; set; default = false; }
    public bool        auto_filetransfer { get; set; default = false; }
    public string      auto_location   { get; set; default = ""; }
    // Not saved
    public bool        connected       { get; set; default = false; }
    public Gdk.Pixbuf ? tox_image      { get; set; default = null; }
    public int         unread_messages { get; set; default = 0; }
    public bool        _is_typing      { get; set; default = false; }
    public bool        _show_notifications { get; set; default = true; }

    public Contact(uint32 friend_number, string id) {
      tox_friend_number = friend_number;
      tox_id = id;
    }

    public string get_id() {
      return tox_id;
    }

    public string get_name_string() {
      return alias != "" ? alias : (name != "" ? name : tox_id);
    }

    public string get_status_string() {
      return status_message;
    }

    public UserStatus get_status() {
      return user_status;
    }

    public bool is_connected() {
      return connected;
    }

    public bool is_typing() {
      return _is_typing;
    }

    public bool is_conference() {
      return false;
    }

    public Gdk.Pixbuf get_image() {
      return tox_image ?? pixbuf_from_resource(R.icons.default_contact, 128);
    }

    public bool get_requires_attention() {
      return unread_messages > 0;
    }

    public void clear_attention() {
      unread_messages = 0;
    }

    public bool show_notifications() {
      return _show_notifications;
    }
  }
}
