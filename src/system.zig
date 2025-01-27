pub fn Define(comptime S: type) type {
    const info = @typeInfo(S);
    _ = info;
    return struct {};
}
