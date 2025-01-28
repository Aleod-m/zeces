const std = @import("std");
pub const Entity = @import("Entity.zig");

fn getMaxEntities(comptime W: type) comptime_int {
    var max_entities: comptime_int = 1_000_000;
    if (@hasDecl(W, "MAX_ENTITIES")) {
        max_entities = W.MAX_ENTITIES;
    }
    return max_entities;
}

/// Defines a World struct.
///
/// Configuration constants:
/// - MAX_ENTITIES: u32
/// - COMPONENTS: [_]type
pub fn Define(comptime W: type) type {
    return struct {
        const Self = @This();
        const EntityStore = Entity.Store(getMaxEntities(W));
        entity_store: EntityStore,
        entity_alloc: std.heap.ArenaAllocator,

        pub fn initAlloc(alloc: std.mem.Allocator) !Self {
            var entity_alloc = std.heap.ArenaAllocator.init(alloc);
            return .{
                .entity_store = try EntityStore.init(entity_alloc.allocator()),
                .entity_alloc = entity_alloc,
            };
        }

        pub fn run(self: *Self) void {
            _ = self;
        }

        pub fn deinit(self: *Self) void {
            self.entity_alloc.deinit();
        }

        pub fn spawn(self: *Self) !Entity {
            return self.entity_store.create_entity();
        }

        pub fn despawn(self: *Self, entity: Entity) !void {
            try self.entity_store.release_entity(entity);
        }

        pub fn isEntityAlive(self: *Self, entity: Entity) bool {
            return self.entity_store.isEntityAlive(entity);
        }
    };
}

test "entities" {
    // Setup
    const testing = std.testing;
    const World = Define(struct {
        const MAX_ENTITIES: comptime_int = 10;
    });
    var world = try World.initAlloc(testing.allocator);
    defer world.deinit();

    // First Spawn 
    const e1 = try world.spawn();
    try testing.expectEqual(
        Entity{
            .id = 0,
            .generation = 0,
        },
        e1,
    );

    // Second Spawn test id. 
    const e2 = try world.spawn();
    try testing.expectEqual(
        Entity{
            .id = 1,
            .generation = 0,
        },
        e2,
    );
    // Test liveness. 
    try world.despawn(e2);
    try testing.expect(!world.isEntityAlive(e2));

    // Test generation. 
    const e3 = try world.spawn();
    try testing.expectEqual(
        Entity{
            .id = 1,
            .generation = 1,
        },
        e3,
    );
}
