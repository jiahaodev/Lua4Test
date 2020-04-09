---A Star 实现


--(1)Point定义
Point = {
	parent = nil,

	f = nil,
	g = nil,
	h = nil,

	x = nil,
	y = nil,

	isWall = nil, -- 是否是墙
}

local tagPoint = newtag()

function Point:new(x,y,parent)
	local o = {}
	settag(o,%tagPoint)
	settagmethod(%tagPoint,"index",function (tab,key)
		return %self[key]
	end)
	o.x = x
	o.y = y
	o.parent = parent
	return o
end

function Point:updateParent(parent,g)
	self.parent = parent;
	self.g = g;
	self.f = g + self.h;
end

function Point:tostring()
	return format("( %d , %d )",self.x,self.y)
end

----------------------------------------------------------

--(2) A Star算法相关
local AStar ={}

--核心算法
function AStar:findPath(startPoint,endPoint,map)
	assert(startPoint and endPoint)
	local openList = {}
	local closeList = {} 
	self:calcF(startPoint,endPoint)
	tinsert(openList,startPoint)

	while getn(openList) > 0 do
		local minPoint,index = self:findMinPoint(openList)
		tremove(openList,index)
		tinsert(closeList,minPoint) 
		--获取min的周围点(可前往的点)
		local surroundPoints = self:getSurroundPoints(minPoint,map);
		--过滤掉已经在closeList中的点
		self:filterClosePoints(surroundPoints,closeList)
		for i = 1,getn(surroundPoints) do
			local surroundP =  surroundPoints[i];
			if self:findPointInList(surroundP,openList) then
				local newG = self:calcG(surroundP,minPoint)
				if newG < surroundP.g then
					surroundP:updateParent(minPoint,newG);
				end
			else
				surroundP.parent = minPoint;
				self:calcF(surroundP,endPoint);
				tinsert(openList,surroundP)
			end
		end
		--检测是否已经到达终点
		if self:findPointInList(endPoint,openList) then
			break;
		end
	end
	return endPoint.parent ~= nil
end



--计算点的g值
function AStar:calcG(nowPoint,parentPoint)
	local toParentG = sqrt((nowPoint.x - parentPoint.x)^2 +(nowPoint.y - parentPoint.y)^2 ) 
	return toParentG + parentPoint.g
end


--计算点的f值
function AStar:calcF(nowPoint,endPoint)
	local h = abs(endPoint.x - nowPoint.x) + abs(endPoint.y - nowPoint.y)
	local g;
	if nowPoint.parent == nil then
		g = 0
	else
		g = self:calcG(nowPoint,nowPoint.parent)
	end
	local f = g + h;
	nowPoint.f = f;
	nowPoint.g = g;
	nowPoint.h = h;
end


--查找一个list中是否含有某个点
function AStar:findPointInList(point,list)
	for i = 1,getn(list) do
		-- if list[i].x == point.x and list[i].y == point.y then
		-- 	return 1,i;
		-- end
		if list[i] == point then
			return 1,i;
		end
	end
	return nil,nil;
end

--查找list中f最小的点
function AStar:findMinPoint(list)
	local f = 9999;   -- todo
	local result = nil;
	local index = 1;
	for i=1,getn(list) do
		if list[i].f < f then
			result = list[i];
			f = list[i].f;
			index = i;
		end
	end
	return result,index;
end

--获取某个点周围的可行点
function AStar:getSurroundPoints(point,map)
	local list = {}
	local up,down,left,right = nil,nil,nil,nil
	local lu,ru,ld,rd = nil,nil,nil,nil --左上、右上、左下、右下
	local mapWidth,mapHeight = map.width,map.height;
	local checkPoint = function(point)
		if point and not point.isWall then
			tinsert(%list,point)
			return point
		end
		return nil
	end
	if (point.y < mapHeight ) then
		up = checkPoint(map[point.x][point.y+1]);
	end
	if (point.y > 1) then
		down = checkPoint(map[point.x][point.y-1]);
	end
	if (point.x > 1) then
		left = checkPoint(map[point.x-1][point.y]);
	end
	if (point.x < mapWidth) then
		right = checkPoint(map[point.x+1][point.y]);
	end
	if (left and up) then
		lu = checkPoint(map[point.x-1][point.y+1])
	end
	if (right and up) then
		ru = checkPoint(map[point.x+1][point.y+1])
	end
	if (left and down) then
		ld = checkPoint(map[point.x-1][point.y-1])
	end
	if (right and down) then
		rd = checkPoint(map[point.x+1][point.y-1])
	end
	return list;
end


--过滤掉已经在closeList中的点
function AStar:filterClosePoints(surroundPoints,closeList)
	for i = getn(surroundPoints),1,-1 do
		if self:findPointInList(surroundPoints[i],closeList) then
			tremove(surroundPoints,i)
		end
	end
end

--打印从起点到终点的路径
function AStar:printPath(endPoint)
	if not (endPoint and endPoint.parent) then
		return;
	end 
	local list = {}
	local point = endPoint;
	while point ~= nil do
		tinsert(list,point)
		point = point.parent
	end
	for i=getn(list),1,-1 do
		print(list[i]:tostring())
	end
end


----------------------------------------------------------
--(3)测试

local mapWidth = 100
local mapHeight = 100
local map = {width = mapWidth,height = mapHeight}
for i = 1,mapWidth do
	local tmp = {}
	for j = 1,mapHeight do
		local p = Point:new(i,j)
		tinsert(tmp,Point:new(i,j))
	end
	tinsert(map,tmp)
end
--设置障碍物
map[4][1].isWall = 1;
map[4][2].isWall = 1;  
map[4][3].isWall = 1;
map[4][4].isWall = 1;
map[4][5].isWall = 1;
map[4][6].isWall = 1;
-- map[4][7].isWall = 1;
-- map[4][8].isWall = 1;

local startPoint = map[2][3];
local endPoint = map[100][4];

if AStar:findPath(startPoint,endPoint,map) then
	AStar:printPath(endPoint)
else
	print("can not find path")
end