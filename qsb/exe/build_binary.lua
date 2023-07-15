
NameOfFileOrigin = arg[1]
NameOfDestination = arg[2]

Chunk = loadfile(NameOfFileOrigin .. ".lua")
print(NameOfFileOrigin)
print(NameOfDestination)
print(Chunk)
Output = assert(io.open(NameOfDestination .. '.bin', 'wb'))
print(Output)
Output:write(string.dump(Chunk))
Output:close()
