vim9script

var x = 42
const name = "Hello"

def Add(a, b)
  return a + b
enddef

def Greet(name: string)
  echo "Hello, " .. name
enddef

var nums = [1, 2, 3, 4, 5]
var result = Add(10, 20)
