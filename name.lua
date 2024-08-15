local lzlib = require("zlib")  -- Make sure to have lzlib library
local base64 = require("base64") -- Assuming base64 encoding/decoding library

-- Base62 encoding/decoding table
local base62_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

-- Function to decode Base62 to bytes
local function base62_decode(encoded_str)
    local result = 0
    local base = 62
    local length = #encoded_str
    for i = 1, length do
        local char = encoded_str:sub(i, i)
        local value = base62_chars:find(char) - 1
        if value == nil then
            error("Invalid Base62 character: " .. char)
        end
        result = result * base + value
    end

    local bytes = {}
    while result > 0 do
        table.insert(bytes, 1, result % 256)
        result = math.floor(result / 256)
    end
    return string.char(table.unpack(bytes))
end

-- Function to decode Base64 (with URL-safe characters) and decompress
local function decompress(encoded_str)
    -- Replace Base62 URL-safe characters back to Base64 characters
    local base64_str = encoded_str:gsub('-', '+'):gsub('_', '/')
    base64_str = base64_str .. string.rep('=', (4 - #base64_str % 4) % 4)
    
    -- Decode Base64 to compressed bytes
    local compressed_bytes = base64.decode(base64_str)
    
    -- Decompress using lzlib
    local decompressed_bytes, err = lzlib.inflate()(compressed_bytes)
    if not decompressed_bytes then
        error("Decompression failed: " .. err)
    end

    return decompressed_bytes
end



function replace_dot(tag, timestamp, record) 
    new_record = record 
    new_record["newtag"] = decompress(tag)
    return 2, timestamp, new_record 
end

-- local encoded_str = "eJzTzy9KL9Yvz0zOTk3Rzcgv0C9PSy8qKNYvSS0qSkwvKs0r0U1Jzc0fFaadMIpYYkFBTqVuYk4OUAIoUKxvkmSaUmlqlFtulFYGAMX_qC4"
-- local decompressed_data = decompress(encoded_str)
-- print("Decompressed Data: " .. decompressed_data)