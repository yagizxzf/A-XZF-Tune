--!strict
-- Minimal synchronous built-in harness. Unit cases must not yield or access services with side effects.
return function(filter: string?): any
	local totals={run=0,passed=0,failed=0,cases={}}
	local expect={}
	function expect.equal(a,b) assert(a==b,"expected "..tostring(b)..", got "..tostring(a)) end
	function expect.truthy(v) assert(v,"expected truthy") end
	function expect.falsy(v) assert(not v,"expected falsy") end
	function expect.near(a,b,t) assert(a==a and math.abs(a-b)<=(t or 1e-6),"expected "..tostring(b)..", got "..tostring(a)) end
	function expect.throws(fn) local ok=pcall(fn) assert(not ok,"expected error") end
	local context={expect=expect}
	function context.test(name,fn)
		totals.run+=1 local ok,err=pcall(fn)
		table.insert(totals.cases,{name=name,pass=ok,error=if ok then nil else tostring(err)})
		if ok then totals.passed+=1 else totals.failed+=1 warn("[AXZF FAIL] "..name..": "..tostring(err)) end
	end
	for _,m in ipairs(script.Parent:GetChildren()) do
		if m:IsA("ModuleScript") and string.sub(m.Name,-5)=="_Test" and (not filter or string.find(m.Name,filter,1,true)) then
			local ok,err=pcall(function() require(m)(context) end)
			if not ok then context.test(m.Name.." load",function() error(err) end) end
		end
	end
	print(string.format("[AXZF UNIT] %d run / %d passed / %d failed",totals.run,totals.passed,totals.failed))
	return totals
end
