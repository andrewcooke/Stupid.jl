
module LittleBrother
using Cipher, Tasks2, Rand2

export tests, read_file, encrypt_file


const LITTLE_BROTHER_LEN = 659408

function read_file()
    open(readbytes, "../little-brother.txt")
end

function encrypt_file(key_length)
    plain = read_file()
    repeat() do
        key = collect2(Uint8, take(key_length, rands(Uint8)))
        cipher = encrypt(key, plain)
        key, cipher
    end
end


function test_length()
    l = length(read_file())
    @assert l == LITTLE_BROTHER_LEN l
end

function tests()
    println("LittleBrother")
    test_length()
end

end
