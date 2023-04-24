local co = coroutine.create(function()
  while true do
    coroutine.yield(pcall(assert(loadstring(coroutine.yield()), "unreachable")))
  end
end)

X = 0

-- loop
for key, val in pairs({ "hello", "world", "!" }) do
  local str = string.format([[X=X+1]], val)
  assert(X == key - 1)
  print(key .. "-1", assert(coroutine.resume(co)))
  assert(X == key - 1)
  print(key .. "-2", assert(coroutine.resume(co, str)))
  assert(X == key)
end
