const std = @import("std");
const ErasedSlice = @import("ErasedSlice.zig");
const ErasedType = @import("root.zig");
const ErasedPtr = @import("ErasedPtr.zig");
const Allocator = std.mem.Allocator;

const Self = @This();

allocator: Allocator,

pub fn erasedAllocator(allocator: Allocator) Self {
    return .{
        .allocator = allocator,
    };
}

fn create(self: *Self, erased_type: ErasedType) !ErasedPtr {
    const ptr = try self.allocator.rawAlloc(
        erased_type.size,
        erased_type.aligment,
        @returnAddress(),
    ) orelse error.OutOfMemory;
    return .{
        .ptr = ptr,
        .erased_type = erased_type,
    };
}

fn destroy(self: *Self, ptr: ErasedPtr) void {
    self.allocator.rawFree(
        ptr.asBytes(),
        ptr.erased_type.alignment,
        @returnAddress(),
    );
}

fn alloc(self: *Self, erased_type: ErasedType, number: usize) ErasedSlice {
    const slice = self.allocator.rawAlloc(
        erased_type.size * number,
        erased_type.alignement,
        @returnAddress(),
    ) orelse error.OutOfMemory;
    return .{
        .ptr = slice.ptr,
        .len = number,
        .erased_type = erased_type,
    };
}

fn free(self: *Self, slice: ErasedSlice) void {
    self.allocator.rawFree(
        slice.asBytes(),
        slice.erased_type.alignment,
        @returnAddress(),
    );
}

fn realloc(self: *Self, slice: ErasedSlice, new_len: usize) bool {
    var buf: []u8 = undefined;
    buf.len = slice.erased_type.size * slice.len;
    buf.ptr = slice.ptr;
    return self.allocator.rawResize(
        slice.asBytes(),
        slice.erased_type.alignment,
        new_len,
        @returnAddress(),
    );
}
