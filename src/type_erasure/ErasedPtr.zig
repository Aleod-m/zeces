const erasure_checks = @import("build_options").erasure_checks;
const std = @import("std");
const Allocator = std.mem.Allocator;

const ErasedType = @import("root.zig").ErasedType;
const eraseType = @import("root.zig").eraseType;
const ErasedPtr = @This();

ptr: usize,
erased_type: ErasedType,

const Stripted = struct {
    ptr: usize,

    fn sized(self: Stripted, erased_type: ErasedType) ErasedPtr {
        return .{
            .ptr = self.ptr,
            .erased_type = erased_type,
        };
    }

    fn sizedFromType(self: Stripted, comptime T: type) ErasedPtr {
        return .{
            .ptr = self.ptr,
            .erased_type = eraseType(T),
        };
    }
};

fn init(val: anytype) ErasedPtr {
    // FIXME: Check for already erased type.
    return .{
        .erased_type = ErasedType.init(@TypeOf(val)),
        .ptr = @intFromPtr(val),
    };
}

fn strip(self: ErasedPtr) Stripted {
    return .{
        .ptr = self.ptr,
    };
}

fn create(comptime T: type, alloc: Allocator) !ErasedPtr {
    const erased_type = eraseType(T);
    const uninit_val: *anyopaque = @intFromPtr(try alloc.create(T));
    return .{
        .erased_ty = erased_type,
        .ptr = uninit_val,
    };
}

fn set(self: *ErasedPtr, val: anytype) void {
    self.as(@TypeOf(val)).* = val;
}

fn as(self: *ErasedPtr, comptime T: type) *T {
    if (erasure_checks and !self.erased_type.isErasureOf(T)) {
        std.debug.panic("Tried to cast erased pointer of erasedtype {} to {}", .{
            self.erased_type,
            @typeName(T),
        });
    }
    return @ptrCast(self.ptr);
}

fn asPtrType(self: *ErasedPtr, comptime PtrType: type) PtrType {
    const pointed_type = @typeInfo(PtrType).pointer.child;
    return self.as(pointed_type);
}

fn asBytes(self: *ErasedPtr) []u8 {
    var buf: []u8 = undefined;
    buf.len = self.erased_type.size;
    buf.ptr = self.ptr;
    return buf;
}
