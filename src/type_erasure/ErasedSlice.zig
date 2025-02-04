const erasure_checks = @import("build_options").erasure_checks;
const std = @import("std");

const ErasedPtr = @import("ErasedPtr.zig");
const ErasedType = @import("root.zig").ErasedType;
const eraseType = @import("root.zig").eraseType;

const Self = @This();

ptr: usize,
len: usize,
erased_type: ErasedType,

const Striped = struct {
    ptr: usize,
    len: usize,

    fn sized(self: Striped, erased_ty: ErasedType) Self {
        return .{
            .ptr = self.ptr,
            .len = self.len,
            .erased_type = erased_ty,
        };
    }

    fn sizedFromType(self: Striped, comptime T: type) Self {
        return self.sized(eraseType(T));
    }
};

pub fn empty(comptime T: type) Self {
    return emptyFromErrased(eraseType(T));
}

pub fn emptyFromErrased(erased_type: ErasedType) Self {
    return .{
        .ptr = undefined,
        .len = 0,
        .erased_type = erased_type,
    };
}
pub fn strip(self: Self) Striped {
    return .{
        .ptr = self.ptr,
        .len = self.len,
    };
}

pub fn as(self: *Self, comptime T: type) []T {
    if (erasure_checks and !self.erased_type.isErasureOf(T)) {}
    var buf: []T = undefined;
    buf.ptr = @ptrFromInt(self.ptr);
    buf.len = self.len;
    return buf;
}

pub fn asBytes(self: *Self) []u8 {
    var buf: []u8 = undefined;
    buf.len = self.erased_type.size * self.len;
    buf.ptr = self.ptr;
}

pub fn get(self: *Self, index: usize) ErasedPtr {
    if (self.len <= index) {
        std.debug.panic();
    }
    return .{
        .ptr = self.ptr + index * self.erased_type.size,
        .erased_type = self.erased_type,
    };
}

pub fn set(self: *Self, index: usize, val: anytype) void {
    self.get(index).set(val);
}
