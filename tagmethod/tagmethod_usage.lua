-- lua 标签方法的应用

--(1)设置默认值

do

	local tagDefault = newtag()

	function setDefault(t,d)
		settag(t,%tagDefault)
		settagmethod(%tagDefault,"index",function(tab,key)
			-- print("key:"..key) 
			return %d
		end)
	end

	-- 测试
	tab = {x = 10, y = 20}
	print(tab.x,tab.z)

	setDefault(tab,0)
	print(tab.x,tab.z)

end




--(2)跟踪访问、数值改变

do
	local tagTrace = newtag()
	function traceTable(t)

		settag(t,%tagTrace)
		--gettable
		settagmethod(%tagTrace,"gettable",function(tab,key)
			local value = rawget(tab,key)
			if value then
				print("key:"..key,"value:"..value)
			else
				local tm = gettagmethod(tag(tab),"index")
				if tm then
					value = tm(tab,key)
				end
			end
			return value
		end)

		--settable
		settagmethod(%tagTrace,"settable",function(tab,key,value)
			local old = rawget(tab,key)
			local new = value
			print("key:"..key,"old:"..old,"new:"..new)
			rawset(tab,key,value)
		end)

		--index（主要捕获value为nil的访问）
		settagmethod(%tagTrace,"index",function(tab,key)
			print("try to index - key:"..key)
			return nil
		end)

	end


	--测试
	local t = {x = 10, y = 20}
	traceTable(t)

	print(t.x)
	t.x = 100

	print(t.z)

end



--（3）只读
do
	local tagReadOnly = newtag()
	function readonly(t)
		settag(t,%tagReadOnly)

		settagmethod(%tagReadOnly,"settable",function ( ... )
			error("modify is not allowed")
		end)
	end
	
	--测试
	local tab ={x=10,y=20}
	tab.x = 100   --可以修改

	readonly(tab)
	tab.x = 50
end