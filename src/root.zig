const std = @import("std");
const testing = std.testing;
pub const world = @import("./world.zig");
pub const component = @import("./component.zig");
pub const system = @import("./system.zig");

test "basic add functionality" {
    const Position = component.Define(struct {
        const STORAGE: component.Storage = .Table;
        const Data = struct {
            x: f32,
            y: f32,
            z: f32,
        };
    });

    const IterPos = system.Define(struct {
        const Self = @This();
        const SCHEDULE: world.Schedule = .Run;
        const Positions: type = system.Query(struct { pos: Position });

        fn run(position: Positions.Item) void {
            _ = position;
        }
    });

    var _world = world.Define(struct {
        const COMPONENTS: [1]type = .{Position};
        const SYSTEMS: [1]type = .{IterPos};
    }){};
    defer _world.shutdown();

    try _world.run();
}
