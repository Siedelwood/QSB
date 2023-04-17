-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" };
   { name = "system", root = "/home/runner/work/Revision/Revision/.luarocks" };
}
lua_interpreter = "lua";
variables = {
   LUA_DIR = "/home/runner/work/Revision/Revision/.lua";
   LUA_BINDIR = "/home/runner/work/Revision/Revision/.lua/bin";
}
