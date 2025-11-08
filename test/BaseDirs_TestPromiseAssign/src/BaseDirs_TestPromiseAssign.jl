module BaseDirs_TestPromiseAssign

using BaseDirs

const lie = BaseDirs.@promise_no_assign BaseDirs.config()

end
