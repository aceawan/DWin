module dwin.backend.xcb.xcb;

import dwin.log;

import xcb.xcb;
import dwin.backend.xcb.cursor;

class XCB {
public:
	this() {
		log = Log.MainLogger;
		connection = xcb_connect(null, null);
		conError err = cast(conError)xcb_connection_has_error(connection);
		if (err)
			log.Fatal("Error while connecting to X11, %s", err);
		log.Info("Successfully connect to X11!");

		screen = xcb_setup_roots_iterator(xcb_get_setup(connection)).data;
		root = screen.root;

		mainCursor = new Cursor(this, CursorIcons.XC_crosshair);
		mainCursor.Apply();
	}

	~this() {
		xcb_disconnect(connection);
	}

	auto GrabKey(ubyte owner_events, ushort modifiers, xcb_keycode_t key, ubyte pointer_mode, ubyte keyboard_mode) {
		return xcb_grab_key(connection, owner_events, root, modifiers, key,
			pointer_mode, keyboard_mode);
	}

	auto GrabButton(ubyte owner_events, ushort event_mask, ubyte pointer_mode, ubyte keyboard_mode, xcb_cursor_t cursor, ubyte button, ushort modifiers) {
		return xcb_grab_button(connection, owner_events, root, event_mask,
			pointer_mode, keyboard_mode, root,
			cursor, button, modifiers);
	}

	auto GrabPointer(ubyte owner_events, ushort event_mask, ubyte pointer_mode, ubyte keyboard_mode, xcb_cursor_t cursor, xcb_timestamp_t time) {
		return xcb_grab_pointer(connection, owner_events, root, event_mask,
			pointer_mode, keyboard_mode, root, cursor, time);
	}

	auto UngrabPointer(xcb_timestamp_t	 time) {
		return xcb_ungrab_pointer(connection, time);
	}

	void Flush() {
		xcb_flush(connection);
	}

	@property xcb_connection_t * Connection() { return connection; }
	@property xcb_screen_t * Screen() { return screen; }
	@property ref xcb_drawable_t Root() { return root; }
	@property Cursor MainCursor() { return mainCursor; }

private:
	enum conError {
		Error = 1,
		ClosedExtNotSupported,
		ClosedMemInsufficient,
		ClosedReqLenExceed,
		ClosedParseErr,
		ClosedInvalidScreen
	}

	Log log;
	xcb_connection_t * connection;
	xcb_screen_t * screen;
	xcb_drawable_t root;
	Cursor mainCursor;
}
