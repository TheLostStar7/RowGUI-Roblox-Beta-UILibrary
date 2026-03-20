--!strict
export type MaidTask = RBXScriptConnection|Instance|(() -> ())|{Destroy:(() -> ())?}|{Disconnect:(() -> ())?}
local Maid = {}
Maid.__index = Maid
export type Maid = {
  _tasks:{[any]:MaidTask},
  _count:number,
  Give:(self:Maid,task:MaidTask) -> MaidTask,
  GiveKey:(self:Maid,key:any,task:MaidTask) -> MaidTask,
  Clean:(self:Maid) -> (),
  Destroy:(self:Maid) -> ()
}
function Maid.new():Maid
  return setmetatable({
    _tasks = {},
    _count = 0
  },Maid)
end
function Maid:CleanUp(task:MaidTask)
  local t = typeof(task)
  if t == "RBXScriptConnection" then
    (task::RBXScriptConnection):Disconnect()
  elseif t == "Instance" then
    (task::Instance):Destroy()
  elseif t == "function" then
    (task::() -> ())()
  elseif t == "table" then
    local tbl = task::any
    if typeof(tbl.Destroy) == "function" then
      tbl:Destroy()
    elseif typeof(tbl.Disconnect) == "function" then
      tbl:Disconnect()
    end
  end
end
function Maid:Give(task:MaidTask):MaidTask
  local n = self._count+1
  self._tasks[n] = task
  self._count = n
  return task
end
function Maid:GiveKey(key:any,task:MaidTask):MaidTask
  local tasks = self._tasks
  local old = tasks[key]
  if old ~= nil then
    self:CleanUp(old)
  end
  tasks[key] = task
  return task
end
function Maid:Clean()
  local tasks = self._tasks
  local count = self._count
  for i = count,1,-1 do
    local task = tasks[i]
    if task ~= nil then
      self:CleanUp(task)
      tasks[i] = nil::any
    end
  end
  for key,task in pairs(tasks) do
    if type(key) ~= "number" then
      self:CleanUp(task)
      tasks[key] = nil::any
    end
  end
  self._count = 0
end
function Maid:Destroy()
  self:Clean()
end
return Maid
