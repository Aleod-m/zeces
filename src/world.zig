fn Define(comptime W: type) type {
    const info = @typeInfo(W);
    _ = info;

    return struct {};
}

pub const Schedule = enum {
    Init,
    Update,
    Shutdown,
};

pub const RunBehaviour = enum {
    /// Run the Init schedule then run the Update schedule each time the run() function is called. The Shutdown schedule is ran once.
    Poll,
    /// Run the Init schedule then automaticaly run the Update Schedule in a loop until the Exit event is emitted then run the Shutdown Schedule.
    Continuous,
    /// Run the Init Schedule then Run the Update Schedule once finaly run the Shutdown schedule.
    OnShot,
};
