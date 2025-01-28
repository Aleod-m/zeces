const std = @import("std");
const testing = std.testing;
pub const world = @import("world.zig");
pub const Entity = @import("Entity.zig");
pub const component = @import("component.zig");

test {
    testing.refAllDecls(@This());
}
