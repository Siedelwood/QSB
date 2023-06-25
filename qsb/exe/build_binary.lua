
NameOfFileOrigin = arg[1]
NameOfDestination = arg[2]

Chunk = loadfile(NameOfFileOrigin .. ".lua")
Output = io.open(NameOfDestination .. '.bin', 'wb')
Output:write(string.dump(Chunk))
Output:close()