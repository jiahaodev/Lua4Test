--简易版本的 lua面向对象编程，未封装



--（1）类 - 对象

do

	local Rectangle = {area = 0,width = 0,height = 0}

	local tagnew = newtag()
	function Rectangle:new(o,width,height)
		o = o or {}
		settag(o,%tagnew)

		settagmethod(%tagnew,"index",function (tab,key)
			return %self[key]
		end)


		o.area = (width or self.width) * (height or self.height)
		return o
	end
		
	function Rectangle:printArea()
		local area = self.area
		print("area:",area)
	end


	local r = Rectangle:new(nil,10,20)
	r:printArea()

	local r1 = Rectangle:new(nil,20,20)
	r1:printArea()

	r:printArea()

end

--------------------------------------------------------------

--（2）类 - 继承
do

	local tagShape = newtag()
	--基类
	local Shape = {side = 0,area = 0}
	-- 基类方法 new
	function Shape:new(o,side)
		o = o or {}
		settag(o,%tagShape)

		settagmethod(%tagShape,"index",function (tab,key)
			return %self[key]
		end)

		side = side or self.side
		o.area = side * side
		return o
	end
	-- 基类方法 printArea
	function Shape:printArea ()
	  print("Shape area: ",self.area)
	end


	--(测试)创建对象
	myShape = Shape:new(nil,60)
	myShape:printArea()





	local tagSquare = newtag()
	--派生类A
	local Square = Shape:new()
	function Square:new(o,side)
		o = o or %Shape:new(o,side)
		settag(o,%tagSquare)
		settagmethod(%tagSquare,"index",function ( tag,key )
			return %self[key]
		end)
		return o
	end

	function Square:printArea()
		print("Square area:",self.area)
	end

	--（测试）创建对象
	mysquare = Square:new(nil,10)
	mysquare:printArea()



	local tagRectangle = newtag()
	--派生类B
	local Rectangle = Shape:new()
	-- 派生类方法 new
	function Rectangle:new (o,width,height)
	    o = o or %Shape:new(o)
		settag(o,%tagRectangle)
		settagmethod(%tagRectangle,"index",function ( tag,key )
			return %self[key]
		end)
		o.area = width * height
		return o
	end

	-- 派生类方法 printArea
	function Rectangle:printArea ()
	  print("Rectangle area: ",self.area)
	end

	--（测试） 创建对象
	myrectangle = Rectangle:new(nil,5,6)
	myrectangle:printArea()

end