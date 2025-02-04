const std = @import("std");
const testing = std.testing;
pub const world = @import("world.zig");
pub const Entity = @import("Entity.zig");
pub const component = @import("component.zig");
pub const type_erasure = @import("type_erasure/root.zig");

test {
    testing.refAllDecls(@This());
}
