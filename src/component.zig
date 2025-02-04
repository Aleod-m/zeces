const Entity = @import("Entity.zig");
const type_erasure = @import("type_erasure/root.zig");

pub fn Define(comptime C: type) type {
    return struct {
        const ID: u32 = @intFromError(@field(anyerror, @typeName(C)));
        const Data: type = C;
    };
}

const storage = struct {
    pub const StorageType = enum {
        Table,
        Set,
    };
    const StorageVT = struct {
        storage: *anyopaque,
        addComponent: fn (
            *anyopaque,
            entity: Entity,
        ) void,
    };

    fn TableStorage(max_entities: comptime_int) type {
        _ = max_entities;
        return struct {};
    }
};
