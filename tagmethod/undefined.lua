--功能：捕获未定义的全局变量
--用于程序初始化完成后，禁止全局变量的编辑

do
	local f = function(name)
		local v = rawget(globals(),name)
		if v then
			return v
		else
			error("undefined global variable `"..name.."'")
		end
	end
	settagmethod(tag(nil),"getglobal",f)
end


a = 1
c = 3
print(a)
print(b)  --这里会报错
print(c)