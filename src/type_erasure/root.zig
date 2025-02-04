const std = @import("std");
pub const alloc = @import("alloc.zig");
const erasure_checks = @import("build_options").erasure_checks;

pub const ErasedPtr = @import("ErasedPtr.zig");
pub const ErasedSlice = @import("ErasedSlice.zig");

pub const TypeId = struct {
    pub const UNKNOWN = std.mem.zeroes(TypeId);

    unique_value: if (erasure_checks) usize else void,

    fn Uniq(comptime T: type) type {
        return struct {
            var uniq = @typeName(T);
        };
    }

    pub inline fn init(comptime T: type) TypeId {
        if (erasure_checks) {
            return TypeId{ .unique_value = @intFromPtr(&Uniq(T).uniq) };
        } else {
            comptime std.debug.assert(@sizeOf(TypeId) == 0);
            return undefined;
        }
    }

    pub fn isValid(self: TypeId) bool {
        return self.unique_value != UNKNOWN.unique_value;
    }

    pub inline fn eql(self: TypeId, other: TypeId) bool {
        if (erasure_checks) {
            return self.isValid() and other.isValid() and self.unique_value == other.unique_value;
        } else {
            return true;
        }
    }

    pub fn isIdOf(self: TypeId, comptime Other: type) bool {
        return self.eql(init(Other));
    }
};

pub const ErasedType = struct {
    size: u32,
    alignment: u29,
    id: TypeId = TypeId.UNKNOWN,

    pub fn init(comptime T: type) ErasedType {
        return initAligned(T, @alignOf(T));
    }

    pub fn initAligned(comptime T: type, alignment: u29) ErasedType {
        if (@sizeOf(T) == 0)
            @compileError("Erased zero-sized types not handled yet. ZST:" ++ @typeName(T));

        switch (T) {
            ErasedType => {
                @compileError("Cannot erase erased types.");
            },
            else => {},
        }

        return .{
            .size = @sizeOf(T),
            .alignment = alignment,
        };
    }

    pub fn isSameErased(self: ErasedType, other: ErasedType) bool {
        return self.id.eql(other);
    }

    pub fn isErasureOf(self: ErasedType, comptime T: type) bool {
        self.id.isIdOf(T);
    }
};

pub fn typeId(comptime T: type) TypeId {
    return TypeId.init(T);
}

pub fn erase(comptime T: type) ErasedType {
    return ErasedType.init(T);
}

test "type id" {
    const testing = std.testing;
    try testing.expect(!typeId(u8).isIdOf(u16));
}
