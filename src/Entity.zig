const std = @import("std");

const Entity = @This();

pub fn getMaxEntities(comptime W: type) comptime_int {
    var max_entities: comptime_int = 1_000_000;
    if (@hasDecl(W, "MAX_ENTITIES")) {
        max_entities = W.MAX_ENTITIES;
    }
    return max_entities;
}
/// DON'T MODIFY.
id: u32,
/// DON'T MODIFY.
generation: u32,

pub fn Store(max_entities: comptime_int) type {
    return struct {
        const Self = @This();
        const MAX_ENTITIES: u32 = @intCast(max_entities);
        /// The maximum number of entities allowed.
        /// The next entity id available.
        entities: std.ArrayList(Entity) = undefined,
        available_ids: std.ArrayList(u32) = undefined,

        pub fn init(alloc: std.mem.Allocator) !Self {
            const entities = try std.ArrayList(Entity).initCapacity(alloc, Self.MAX_ENTITIES);
            errdefer entities.deinit();
            const available_ids = try std.ArrayList(u32).initCapacity(alloc, Self.MAX_ENTITIES);

            return .{
                .entities = entities,
                .available_ids = available_ids,
            };
        }

        pub fn deinit(self: Self) void {
            self.available_ids.deinit();
            self.entities.deinit();
        }

        pub fn create_entity(self: *Self) !Entity {
            // Allocate an returned id if there is one.
            while (self.available_ids.popOrNull()) |id| {
                if (id > self.entities.items.len) {
                    continue;
                }
                return self.entities.items[id];
            }
            // Reserve the next id.
            const id: u32 = @intCast(self.entities.items.len);
            // Check if we are not going over the maximum number of entities.
            if (id > Self.MAX_ENTITIES - 1) {
                return error.MAX_ENTITIES_REACHED;
            }

            try self.entities.append(.{
                .id = id,
                .generation = 0,
            });

            return self.entities.items[id];
        }

        pub fn release_entity(self: *Self, entity: Entity) !void {
            if (!self.isEntityAlive(entity))
                return error.TRIED_TO_RELEASE_DEAD_ENTITY;
            self.entities.items[entity.id].generation = self.entities.items[entity.id].generation + 1;
            try self.available_ids.append(entity.id);
        }

        pub fn isEntityAlive(self: *Self, entity: Entity) bool {
            return self.entities.items[entity.id].generation == entity.generation;
        }
    };
}

test "entitie store" {
    const testing = std.testing;
    var store = try Store(10).init(testing.allocator);
    defer store.deinit();
    const e1 = try store.create_entity();
    try testing.expectEqual(
        Entity{
            .id = 0,
            .generation = 0,
        },
        e1,
    );
    const e2 = try store.create_entity();
    try testing.expectEqual(
        Entity{
            .id = 1,
            .generation = 0,
        },
        e2,
    );
    try store.release_entity(e2);
    try testing.expect(!store.isEntityAlive(e2));
    const e3 = try store.create_entity();
    try testing.expectEqual(
        Entity{
            .id = 1,
            .generation = 1,
        },
        e3,
    );
}
