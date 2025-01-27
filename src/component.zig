pub const Storage = enum {
    Table,
    Set,
};

pub fn Define(comptime C: type) type {
    const info = @typeInfo(C);
    _ = info;
    return struct {};
}
