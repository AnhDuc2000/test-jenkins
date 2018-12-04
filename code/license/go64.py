# Quick hack to test encoding a password string to get out a resulting base64 string and back

import base64

str = base64.b64encode(b"password")

print ( str )

str2 = base64.urlsafe_b64decode( str )

print ( str2.decode() )

# Quick hack to test encoding a password string to get out a resulting base64 string and back

str = base64.b64decode("put your encoded string here")

print ( str )
