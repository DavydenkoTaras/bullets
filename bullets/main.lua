rnd = math.random;
min = math.min;
max = math.max;
sqrt = math.sqrt;
rad = math.rad;
cos = math.cos;
sin = math.sin;
abs = math.abs;
floor = math.floor;
ceil = math.ceil;
round = math.round;
W = display.contentWidth;
H = display.contentHeight;



function rotate_point(x, y, cx, cy, a) -- a need in rad
	local dx=x-cx;
	local dy=y-cy;
	local a1 = math.atan2(dy, dx);
	local d = (dx^2+dy^2)^0.5;
	local a2 = a1+a;
	local nx = cx+d*math.cos(a2);
	local ny = cy+d*math.sin(a2);
	
	return {nx, ny};
end

function vec_sum(vec_1, vec_2)
	local res = {};
	for i=1, #vec_1 do
		res[i] = vec_1[i]+vec_2[i];
	end
	return res;
end

function vec_mult_num(vec, n)
	local res = {};
	for i=1, #vec do
		res[i] = n*vec[i];
	end
	return res;
end

function vec_normalized(vec)
	local dx = vec[1];
	local dy = vec[2];
	local d = sqrt(dx*dx + dy*dy);
	if d~=0 then
		return {dx/d, dy/d};
	else
		return {0, 0};
	end
end

function vec_equal(vec_1, vec_2)
	ok=true;
	for i=1, #vec_1 do
		if vec_1[i] ~= vec_2[i] then
			ok=false;
			break;
		end
	end
	return ok;
end

function vec_copy(vec)
	local res = {};
	for i=1, #vec do
		res[i] = vec[i];
	end
	return res;
end


function absPos(obj)
	local x=obj.x;
	local y=obj.y;
	local obj2=obj.parent;
	while obj2~=nil do
		x=x+obj2.x;
		y=y+obj2.y;
		obj2=obj2.parent;
	end
	return {x, y};
end

function rect_rect_colision(pos_obj1, size_obj1, pos_obj2, size_obj2)
	if abs( pos_obj1.x-pos_obj2.x )<(size_obj1.width+size_obj2.width)/2 and
		math.abs( pos_obj1.y-pos_obj2.y )<(size_obj1.height+size_obj2.height)/2 then
		return true;
	else
		return false;
	end
end

function circle_circle_colision(obj1, obj2)
	local dx = obj2.x-obj1.x;
	local dy = obj2.y-obj1.y;
	local d = sqrt(dx*dx + dy*dy);
	return (d<obj1.radius+obj2.radius);
end

function lineColision1D(x1, x2, x3, x4)
	local dx1 = x2-x1;
	local dx2 = x4-x3;
	local c1 = (x2-x1)/2;
	local c2 = (x4-x3)/2;
	local d = math.abs(c2-c1);
	local full_w = (dx1+dx2)/2;
	return (d<full_w);
end

function lineColision( A, B, C, D )
	local ok=false;
	
	local E = 0.00001;
	
	local null_1 = math.abs(A.x - B.x)<E;
	local null_2 = math.abs(C.x - D.x)<E;
	
	if not (null_1 or null_2) then
		local k1 = (B.y-A.y) / (B.x-A.x);
		local k2 = (D.y-C.y) / (D.x-C.x);
		local b1 = A.y-A.x*k1;
		local b2 = C.y-C.x*k2;
		
		local x = (b1-b2) / (k2-k1);
		local y = x*k1 + b1;
		
		local x_min_1 = min(A.x, B.x);
		local x_max_1 = max(A.x, B.x);
		local x_min_2 = min(C.x, D.x);
		local x_max_2 = max(C.x, D.x);
		local y_min_1 = min(A.y, B.y);
		local y_max_1 = max(A.y, B.y);
		local y_min_2 = min(C.y, D.y);
		local y_max_2 = max(C.y, D.y);
		
		if x>=x_min_1 and x<=x_max_1 and x>=x_min_2 and x<=x_max_2 and y>=y_min_1 and y<=y_max_1 and y>=y_min_2 and y<=y_max_2 then
			ok=true;
		end
		-- print("no null");
	elseif null_1 and null_2 then
		if A.x == C.x then
			ok = lineColision1D(A.y, B.y, C.y, D.y);
		end
		-- print("all null");
	else
		if null_2 then
			A, B, C, D = C, D, A, B; -- остальные ифы убедили нас что null_1 ~= null_2 поэтому если null_2 то не null_1 но я буду рассматривать ситуацию только с null_1 поэтому меняем местами
		end
		
		-- print("null_1 ~= null_2");
		
		local k2 = (D.y-C.y) / (D.x-C.x);
		local b2 = C.y-C.x*k2;
		
		local y_min = min(A.y, B.y);
		local y_max = max(A.y, B.y);
		
		local x_min = min(C.x, D.x);
		local x_max = max(C.x, D.x);
		
		local x = A.x;
		local y = b2+A.x*k2;
		if x>=x_min and x<=x_max and y>=y_min and y<=y_max then
			ok=true;
		end
	end
	
	return ok;
end

function rect_rot_rect_Colision(rect, obj)
	local ok=false;
	
	local x1 = absPos(rect)[1];
	local y1 = absPos(rect)[2];
	local x2 = absPos(obj)[1];
	local y2 = absPos(obj)[2];
	local rot = rad(obj.rotation);
	
	local A = { x = x1-rect.width/2 , y = y1-rect.height/2 };
	local B = { x = x1+rect.width/2 , y = y1-rect.height/2 };
	local C = { x = x1-rect.width/2 , y = y1+rect.height/2 };
	local D = { x = x1+rect.width/2 , y = y1+rect.height/2 };
	
	local rect_ver = { A, B, C, D };
	
	local E = { x = x2-obj.width/2 , y = y2-obj.height/2 };
	local F = { x = x2+obj.width/2 , y = y2-obj.height/2 };
	local G = { x = x2-obj.width/2 , y = y2+obj.height/2 };
	local H = { x = x2+obj.width/2 , y = y2+obj.height/2 };
	
	local obj_ver = { E, F, G, H };
	
	for i=1, #obj_ver do
		local dd = distanse(obj_ver[i].x, obj_ver[i].y, x2, y2);
		local dx = obj_ver[i].x-x2;
		local dy = obj_ver[i].y-y2;
		local rot2 = math.atan2(dy, dx);
		local f_rot = rot+rot2;
		obj_ver[i].x = x2 + math.cos(f_rot)*dd;
		obj_ver[i].y = y2 + math.sin(f_rot)*dd;
	end
	
	for i=1, #rect_ver do
		for j=1, #obj_ver do
			if lineColision(rect_ver[(i-1)%4+1], rect_ver[i%4+1], obj_ver[(j-1)%4+1], obj_ver[j%4+1]) then
				ok=true;
			end
		end
	end
	
	for i=1, #rect_ver do
		local P=rect_ver[i];
		local dx = P.x-obj.x;
		local dy = P.y-obj.y;
		local dd = (dx^2+dy^2)^0.5;
		local P2={x=0, y=0};
		P2.x = obj.x + dd*math.cos(math.atan2(dy, dx)-rot);
		P2.y = obj.y + dd*math.sin(math.atan2(dy, dx)-rot);
		if (P2.x>obj.x-obj.width/2 and P2.x<obj.x+obj.width/2) and (P2.y>obj.y-obj.height/2 and P2.y<obj.y+obj.height/2) then
			ok=true;
		end
	end
	
	for i=1, #obj_ver do
		local P=obj_ver[i];
		if P.x>A.x and P.x<B.x and P.y>A.y and P.y<C.y then
			ok=true;
		end
	end
	
	
	
	return ok;
end



function newGroup(x, y, par)
	local new_group = display.newGroup();
	new_group.x = x;
	new_group.y = y;
	if par~=nil then
		par:insert(new_group);
	end
	return new_group;
end

local bg = display.newRect(W/2, H/2, W*2, H*2);
bg:setFillColor(0.125,0.125,0.5);

local game = newGroup(0, 0);
game.pause = false;



local speed_mult = 1;
function add_transition(par) -- obj, trans_obj, t, onComplete
	local obj = par.obj;
	local trans_obj = par.trans_obj;
	local t = par.t;
	local onComplete = par.onComplete;
	
	local td_obj = {};
	
	for str, val in pairs(trans_obj) do
		local d = val - obj[str];
		local td = d / t;
		td_obj[str] = td;
	end
	
	local new_fr = 0;
	
	local function new_transition()
		if not game.pause then
			if new_fr<t then
				for str, val in pairs(td_obj) do
					if obj[str]~=nil then
						obj[str] = obj[str] + val*speed_mult;
					else
						Runtime:removeEventListener("enterFrame", new_transition);
						break;
					end
				end
			else
				Runtime:removeEventListener("enterFrame", new_transition);
				obj.transition=nil;
				for str, val in pairs(trans_obj) do
					if obj[str]~=nil then
						obj[str] = val;
					else
						return;
					end
				end
				if onComplete ~= nil then
					onComplete();
					-- print("onComplete !");
				end
			end
			new_fr=new_fr+speed_mult;
		end
	end
	
	Runtime:addEventListener("enterFrame", new_transition);
	
	obj.transition = new_transition;
	
	return new_transition;
end



local hero = newGroup(W/2, H/2, game);
hero.speed = 6;
-- local body = display.newImage(hero, "image/hero/body.png");
-- body.radius = math.min(body.width, body.height)/2;
local body = display.newCircle(hero, 0, 0, 5);
body:setFillColor(0);
hero.radius=body.width/2;
body:setStrokeColor(1,1,0);
body.strokeWidth = 2;

local key_press = {};
Runtime:addEventListener("key", function(event)
	key_press[event.keyName] = (event.phase == "down");
end);

local move_control = { {"left", {-1,0}}, {"right", {1,0}}, {"up", {0,-1}}, {"down", {0,1}} };

function move(moving_body, size_body, v)
	moving_body:translate(v[1], v[2]);
	moving_body.x = min(moving_body.x, W-moving_body.width/2);
	moving_body.x = max(moving_body.x, moving_body.width/2);
	moving_body.y = min(moving_body.y, H-moving_body.height/2);
	moving_body.y = max(moving_body.y, moving_body.height/2);
end



function clean_obj_arr(arr)
	for i=#arr, 1, -1 do
		display.remove(table.remove(arr, i));
	end
end



hero.bullet = {};
hero.bullet.speed = 16;
hero.bullet.time_max = 5;
hero.bullet.time = hero.bullet.time_max;
hero.bomb_n = 0;
function hero.shoot()
	local new_bullet = display.newCircle(hero.x, hero.y, 10);
	new_bullet:setFillColor(0);
	new_bullet.radius = 10;
	new_bullet.dmg = 1;
	new_bullet.v = {0, -hero.bullet.speed};
	table.insert(hero.bullet, new_bullet);
	hero.bullet.time = hero.bullet.time_max;
end

local lvl = 1;
local load_lvl = {};

local attack;

local bullet = {};
local danger_rect = {};
local ability_obj = {};
local hero_bonus_obj = {};

function hero.death()
	hero.x=W/2;
	hero.y=H/2;
	for i=#bullet, 1, -1 do
		local obj = bullet[i];
		Runtime:removeEventListener("enterFrame", bullet[i].shoot);
		bullet[i].delete();
	end
	Runtime:removeEventListener("enterFrame", attack);
	clean_obj_arr(ability_obj);
	clean_obj_arr(hero_bonus_obj);
	hero.bomb_n=0;
	load_lvl[lvl]();
end

bullet.init = function(par) -- x, y, r, v, destroyable, hp, destroy_event, obj_func, dmg_arr
	local x = par.x;
	local y = par.y;
	local r = par.r;
	local v = par.v;
	local destroyable = par.destroyable;
	local hp = par.hp;
	local destroy_event = par.destroy_event;
	local obj_func = par.obj_func;
	local dmg_arr = par.dmg_arr or {hero.bullet};
	
	local new_bullet = newGroup(x, y, game);
	new_bullet.body = display.newCircle(new_bullet, 0, 0, r);
	new_bullet.radius = r;
	new_bullet.v = v;
	new_bullet.destroyable = destroyable;
	new_bullet.hp = hp;
	new_bullet.destroy_event = destroy_event;
	new_bullet.dmg_arr = dmg_arr;
	new_bullet.alt_arr = {};
	new_bullet.on = true;
	new_bullet.add_to = function(arr)
		table.insert(arr, new_bullet);
		table.insert(new_bullet.alt_arr, arr);
	end
	new_bullet.delete = function()
		for i=1, #new_bullet.alt_arr do
			table.remove(new_bullet.alt_arr[i], table.indexOf(new_bullet.alt_arr[i], new_bullet));
		end
		Runtime:removeEventListener("enterFrame", new_bullet.shoot);
		display.remove(table.remove(bullet, table.indexOf(bullet, new_bullet)));
	end
	if obj_func ~= nil then
		obj_func(new_bullet);
	end
	table.insert(bullet, new_bullet);
	return new_bullet;
end

danger_rect.init = function(par)
	local new_danger_rect
end

function add_bullet_v_circle(par) -- cx, cy, cr, n, r, speed, destroyable, destroy_event
	local cx = par.cx;
	local cy = par.cy;
	local cr = par.cr;
	local n = par.n;
	local r = par.r;
	local speed = par.speed;
	local destroyable = par.destroyable;
	local destroy_event = par.destroy_event;
	local hp = par.hp;
	local obj_func = par.obj_func;
	
	local new_cir = {};
	local ia = rad(360/n);
	for i=1, n do
		local a = ia*i;
		table.insert(new_cir, bullet.init({ x=cx+cr*cos(a), y=cy+cr*sin(a), r=r, v={cos(a)*speed, sin(a)*speed}, destroyable=destroyable, hp=0, destroy_event=destroy_event }));
		if obj_func ~= nil then
			obj_func(new_cir[i]);
		end
		-- display.remove(new_cir[i].body);
		-- new_cir[i].body = display.newImageRect(new_cir[i], "image/bullet/blood.png", new_cir[i].radius, new_cir[i].radius*2);
		-- new_cir[i].body.rotation=math.pi*a/180;
	end
	return new_cir;
end

--[[local root_bullet = bullet.init(W/2, H/2-100, 50, {0, 0}, true, 1, nil);
function add_cir_destroy_event(obj)
	obj.destroy_event = function()
		local new_cir = add_bullet_v_circle(obj.x, obj.y, obj.radius*1.5, 10, obj.radius/2, 2, false, nil);
		obj.destroyable = false;
		add_transition({ obj=obj, trans_obj={alpha=0}, t=10, onComplete=function()
			display.remove(table.remove(bullet, table.indexOf(bullet, obj)));
			for i=1, #new_cir do
				if new_cir[i].radius>5 then
					add_cir_destroy_event(new_cir[i]);
					new_cir[i].destroyable = true;
				end
			end
		end });
	end
end
add_cir_destroy_event(root_bullet);]]--

function set_body_fill_star(obj)
	obj.body.fill = {type="image", filename="image/bullet/star.png"};
end

function add_hp_bar(obj, main)
	local hp_max = obj.hp;
	if main then
		local new_hp_bar = display.newRect(20, 20, W-40, 8);
		new_hp_bar.strokeWidth=2;
		new_hp_bar:setStrokeColor(0);
		new_hp_bar.anchorX = 0;
		new_hp_bar.refresh = function()
			if obj.x ~= nil then
				new_hp_bar.width = (W-40)/hp_max*obj.hp;
			else
				Runtime:removeEventListener("enterFrame", new_hp_bar.refresh);
				display.remove(new_hp_bar);
			end
		end
		Runtime:addEventListener("enterFrame", new_hp_bar.refresh);
	else
		local new_hp_bar = display.newRect(obj.x, obj.y+obj.height/2+6, obj.hp, 8);
		new_hp_bar.strokeWidth=2;
		new_hp_bar:setStrokeColor(0);
		new_hp_bar.refresh = function()
			if obj.x ~= nil then
				new_hp_bar.width = obj.hp;
				new_hp_bar.x = obj.x;
				new_hp_bar.y = obj.y+obj.height/2+6
			else
				Runtime:removeEventListener("enterFrame", new_hp_bar.refresh);
				display.remove(new_hp_bar);
			end
		end
		Runtime:addEventListener("enterFrame", new_hp_bar.refresh);
	end
end

function add_root_bullet(par) -- x, y, r, hp
	local x = par.x;
	local y = par.y;
	local r = par.r;
	local hp = par.hp;
	local dmg_arr = par.dmg_arr or {hero.bullet};
	
	local root_bullet = bullet.init({ x=x, y=y, r=r, v={0, 0}, destroyable=true, hp=hp, dmg_arr=dmg_arr });
	add_hp_bar(root_bullet, true);
	root_bullet.body:setFillColor(0);
	root_bullet.body:setStrokeColor(1,0,0);
	root_bullet.body.strokeWidth = 2;
	return root_bullet;
end

function next_level()
	lvl=lvl+1;
	load_lvl[lvl]();
end

local ability = {};
hero.ability={};
ability["bomb"] = {event=function()
	if hero.bomb_n > 0 then
		hero.bomb_n = hero.bomb_n - 1;
		for i=#bullet, 1, -1 do
			local obj = bullet[i];
			local dx = obj.x-hero.x;
			local dy = obj.y-hero.y;
			local d = sqrt(dx*dx + dy*dy);
			if d<400 then
				if obj.hp <= 0 then
					local vx = 50*dx/d;
					local vy = 50*dy/d;
					obj.on = false;
					add_transition({ obj=obj, trans_obj={x=obj.x+vx, y=obj.y+vy, alpha=0}, t=30, onComplete=function()
						if obj.delete ~= nil then
							obj.delete();
						end
					end });
				else
					obj.hp = obj.hp - 30;
					if obj.hp <= 0 and obj.destroyable==true and obj.destroy_event~=nil then
						obj.destroy_event();
					end
				end
			end
		end
	end
end, key="x"};

function add_hero_bonus_obj(par) -- str, val, x, y, on
	local str = par.str;
	local val = par.val;
	local x = par.x;
	local y = par.y;
	local on = par.on;
	
	local new_hero_bonus_obj = display.newImage(game, "image/hero_bonus/"..str..".png");
	new_hero_bonus_obj.x = x;
	new_hero_bonus_obj.y = y;
	new_hero_bonus_obj.str = str;
	new_hero_bonus_obj.val = val;
	new_hero_bonus_obj.on = on
	if new_hero_bonus_obj.on == nil then
		new_hero_bonus_obj.on = true;
	end
	table.insert(hero_bonus_obj, new_hero_bonus_obj);
	return new_hero_bonus_obj;
end

function add_ability_obj(str, x, y, hero_colision_event)
	local new_ability_obj = display.newImage(game, "image/power_up/"..str..".png");
	new_ability_obj.x = x;
	new_ability_obj.y = y;
	new_ability_obj.ability = ability[str];
	new_ability_obj.str = str;
	new_ability_obj.hero_colision_event = hero_colision_event;
	table.insert(ability_obj, new_ability_obj);
	return new_ability_obj;
end

load_lvl[1] = function()
	-- local root_bullet = bullet.init({ x=W/2, y=-10, r=10, v={0, 0}, destroyable=true, hp=1 });
	local root_bullet = add_root_bullet({ x=W/2, y=-10, r=10, hp=1 });
	add_transition({ obj=root_bullet, trans_obj={y=100}, t=30 });
	root_bullet.destroy_event = function()
		add_transition({ obj=root_bullet, trans_obj={alpha=0}, t=30, onComplete=function()
			display.remove(table.remove(bullet, table.indexOf(bullet, root_bullet)));
			next_level();
		end });
	end
end

load_lvl[2] = function()
	local root_bullet = add_root_bullet({ x=W/2, y=-10, r=10, hp=10 });
	add_transition({ obj=root_bullet, trans_obj={y=100}, t=30 });
	root_bullet.destroy_event = function()
		add_transition({ obj=root_bullet, trans_obj={alpha=0}, t=30, onComplete=function()
			display.remove(table.remove(bullet, table.indexOf(bullet, root_bullet)));
			next_level();
		end });
		Runtime:removeEventListener("enterFrame", root_bullet.shoot);
	end
	root_bullet.shoot_time_max = 10;
	root_bullet.shoot_time = root_bullet.shoot_time_max;
	root_bullet.shoot = function()
		root_bullet.shoot_time = root_bullet.shoot_time - 1;
		if root_bullet.shoot_time == 0 then
			root_bullet.shoot_time = root_bullet.shoot_time_max;
			bullet.init({ x=root_bullet.x, y=root_bullet.y, r=10, v={rnd(-2, 2), 2}, destroyable=false, hp=0, obj_func=set_body_fill_star }); -- (x, y, r, v, destroyable, hp, destroy_event)
		end
	end
	Runtime:addEventListener("enterFrame", root_bullet.shoot);
end

load_lvl[3] = function()
	local root_bullet = add_root_bullet({ x=W/2, y=-10, r=10, hp=50 });
	add_transition({ obj=root_bullet, trans_obj={y=100}, t=30 });
	root_bullet.destroy_event = function()
		add_transition({ obj=root_bullet, trans_obj={alpha=0}, t=30, onComplete=function()
			display.remove(table.remove(bullet, table.indexOf(bullet, root_bullet)));
			next_level();
		end });
		Runtime:removeEventListener("enterFrame", root_bullet.shoot);
	end
	root_bullet.shoot_time_max = 5;
	root_bullet.shoot_time = root_bullet.shoot_time_max;
	root_bullet.shoot = function()
		root_bullet.shoot_time = root_bullet.shoot_time - 1;
		if root_bullet.shoot_time == 0 then
			root_bullet.shoot_time = root_bullet.shoot_time_max;
			bullet.init({ x=root_bullet.x, y=root_bullet.y, r=20, v={(rnd()-0.5)*16, 8}, destroyable=false, hp=0, obj_func=set_body_fill_star });
		end
	end
	Runtime:addEventListener("enterFrame", root_bullet.shoot);
end

load_lvl[4] = function()
	local root_bullet = add_root_bullet({ x=W/2, y=-10, r=10, hp=80 });
	add_transition({ obj=root_bullet, trans_obj={y=100}, t=30 });
	root_bullet.destroy_event = function()
		add_transition({ obj=root_bullet, trans_obj={alpha=0}, t=30, onComplete=function()
			display.remove(table.remove(bullet, table.indexOf(bullet, root_bullet)));
			next_level();
		end });
		Runtime:removeEventListener("enterFrame", root_bullet.shoot);
	end
	root_bullet.shoot_time_max = 2;
	root_bullet.shoot_time = root_bullet.shoot_time_max;
	root_bullet.shoot_n = 0;
	root_bullet.shoot = function()
		root_bullet.shoot_time = root_bullet.shoot_time - 1;
		if root_bullet.shoot_time == 0 then
			root_bullet.shoot_time = root_bullet.shoot_time_max;
			root_bullet.shoot_n=root_bullet.shoot_n+1;
			if root_bullet.shoot_n%3==0 then
				bullet.init({ x=root_bullet.x, y=root_bullet.y, r=20, v={(rnd()-0.5)*16, 8}, destroyable=false, hp=0, obj_func=set_body_fill_star });
			end
			if root_bullet.shoot_n%2==0 then
				local a = rad((root_bullet.shoot_n%48)*360/48 + 3*floor(root_bullet.shoot_n/48));
				bullet.init({ x=root_bullet.x, y=root_bullet.y, r=15, v={4*cos(a), 4*sin(a)}, destroyable=false, hp=0, obj_func=set_body_fill_star });
			end
		end
	end
	Runtime:addEventListener("enterFrame", root_bullet.shoot);
end

load_lvl[5] = function()
	local hero_star_bullet={};
	local root_bullet = add_root_bullet({ x=W/2, y=-10, r=10, hp=10, dmg_arr={hero_star_bullet} });
	add_transition({ obj=root_bullet, trans_obj={y=100}, t=30 });
	root_bullet.destroy_event = function()
		add_transition({ obj=root_bullet, trans_obj={alpha=0}, t=30, onComplete=function()
			local bomb_img = add_ability_obj("bomb", root_bullet.x, root_bullet.y, next_level);
			display.remove(table.remove(bullet, table.indexOf(bullet, root_bullet)));
			-- next_level();
		end });
		Runtime:removeEventListener("enterFrame", root_bullet.shoot);
	end
	root_bullet.shoot_time_max = 2;
	root_bullet.shoot_time = root_bullet.shoot_time_max;
	root_bullet.shoot_n = 0;
	root_bullet.shoot = function()
		root_bullet.shoot_time = root_bullet.shoot_time - 1;
		if root_bullet.shoot_time == 0 then
			root_bullet.shoot_time = root_bullet.shoot_time_max;
			root_bullet.shoot_n=root_bullet.shoot_n+1;
			if root_bullet.shoot_n%40==0 then
				bullet.init({ x=root_bullet.x, y=root_bullet.y, r=40, v={0, 5}, destroyable=true, hp=0, obj_func=function(obj)
					set_body_fill_star(obj);
					add_transition({ obj=obj.body.fill, trans_obj={r=0, g=0, b=0}, t=30, onComplete=function()
						obj.destroy_event=function()
							display.remove(table.remove(bullet, table.indexOf(bullet, obj)));
							local new_cir = add_bullet_v_circle({ cx=obj.x, cy=obj.y, cr=obj.radius*1.5, n=12, speed=12, r=obj.radius/2, destroyable=false });
							for i=1, #new_cir do
								new_cir[i].body:setFillColor(0);
								new_cir[i].add_to(hero_star_bullet);
								new_cir[i].dmg = 1;
							end
						end
					end });
				end });
			end
			-- if root_bullet.shoot_n%3==0 then
				-- bullet.init({ x=root_bullet.x, y=root_bullet.y, r=20, v={(rnd()-0.5)*16, 8}, destroyable=false, hp=0, obj_func=set_body_fill_star });
			-- end
			if root_bullet.shoot_n%2==0 then
				local a = rad((root_bullet.shoot_n%48)*360/48 + 3*floor(root_bullet.shoot_n/48));
				for i=0, 2 do
					bullet.init({ x=root_bullet.x, y=root_bullet.y, r=15, v={4*cos(a+10*i), 4*sin(a+10*i)}, destroyable=false, hp=0, obj_func=set_body_fill_star });
				end
			end
		end
	end
	Runtime:addEventListener("enterFrame", root_bullet.shoot);
end

load_lvl[6] = function()
	--[[local add_bullet_line = function(par) -- x1, y1, x2, y2, n, r, obj_func
		local x1 = par.x1;
		local y1 = par.y1;
		local x2 = par.x2;
		local y2 = par.y2;
		local n = par.n;
		local r = par.r;
		local obj_func = par.obj_func;
		
		local tdx = (x2-x1)/(n-1);
		local tdy = (y2-y1)/(n-1);
		if r==nil then
			r=math.sqrt(tdx*tdx + tdy*tdy);
		end
		
		local new_line = {};
		
		for i=1, n do
			local new_bullet = bullet.init(x1+tdx*i, y1+tdy*i, r);
			obj_func(new_bullet);
			table.insert(new_line, new_bullet);
		end
		
		return new_line;
	end]]--
	
	--[[for i=1, 40 do
		for j=1, 20 do
			local new_bullet = bullet.init({ x=40*i-10, y=-40, r=20, v={0, 2}, hp=0, obj_func=set_body_fill_star });
			new_bullet.need=true;
		end
	end]]--
	
	for i=1, 2 do
		local new_bomb = add_hero_bonus_obj({ str="bomb_n", val=1, x=rnd(100, W-100), y=rnd(100, H-100), on=false });
		new_bomb.alpha = 0;
		add_transition({ obj=new_bomb, trans_obj={alpha=1}, t=30, onComplete=function()
			new_bomb.on = true;
		end });
	end
	
	local fr=0;
	attack=function()
		fr=fr+1;
		if fr%20 == 0 then
			for i=0, 40 do
				local new_bullet = bullet.init({ x=40*i-10, y=-40, r=20, v={0, 2}, hp=0, obj_func=set_body_fill_star });
				new_bullet.need=true;
			end
			if fr/20 == 15 then
				Runtime:removeEventListener("enterFrame", attack);
				next_level();
			end
		end
	end
	Runtime:addEventListener("enterFrame", attack);
end

load_lvl[7] = function()
	add_transition({ obj=bg.fill, trans_obj={r=0, g=0, b=0}, t=300, onComplete=function()
		local chara = newGroup(W/2-100, -100, game);
		chara.img = display.newImage("image/evil/chara.png");
		chara.body = {x=0, y=0, width=32, height=32, rotation=0, parent=chara};
		table.insert(danger_rect, chara.body);
		add_transition({ obj=chara, trans_obj={x=W/2, y=200}, t=60, onComplete=function()
			
		end });
	end });
end

load_lvl[lvl]();


Runtime:addEventListener("enterFrame", function()
	local v={0, 0};
	for i=1, #move_control do
		if key_press[move_control[i][1]]==true then
			v=vec_sum(v, move_control[i][2]);
		end
	end
	move(hero, body, vec_mult_num(vec_normalized(v), hero.speed));
	
	for i=#bullet, 1, -1 do
		if ( abs(W/2-bullet[i].x)>W/2+bullet[i].radius or abs(H/2-bullet[i].y)>H/2+bullet[i].radius ) and not bullet[i].need then
			bullet[i].delete();
		else
			if bullet[i].destroyable then
				for j=1, #bullet[i].dmg_arr do
					for k=#bullet[i].dmg_arr[j], 1, -1 do
						if circle_circle_colision(bullet[i], bullet[i].dmg_arr[j][k]) then
							bullet[i].hp = bullet[i].hp - bullet[i].dmg_arr[j][k].dmg;
							if bullet[i].hp<=0 then
								if bullet[i].destroy_event ~= nil then
									bullet[i].destroy_event();
								end
							end
							if bullet[i].dmg_arr[j][k].delete ~= nil then
								bullet[i].dmg_arr[j][k].delete();
							else
								display.remove(table.remove(bullet[i].dmg_arr[j], k));
							end
						end
					end
				end
			end
			
			bullet[i]:translate(bullet[i].v[1], bullet[i].v[2]);
			if bullet[i].on then
				if circle_circle_colision(hero, bullet[i]) then
					hero.death();
					break;
				end
			end
		end
	end
	
	hero.bullet.time = max(0, hero.bullet.time - 1);
	if hero.bullet.time == 0 and key_press["z"] then
		hero.shoot();
	end
	
	for i=#hero.bullet, 1, -1 do
		if ( abs(W/2-hero.bullet[i].x)>W/2+hero.bullet[i].radius or abs(H/2-hero.bullet[i].y)>H/2+hero.bullet[i].radius ) then
			display.remove(table.remove(hero.bullet, i));
		else
			hero.bullet[i]:translate(hero.bullet[i].v[1], hero.bullet[i].v[2]);
		end
	end
	
	for i=#danger_rect, 1, -1 do
		local x = hero.x;
		local y = hero.y;
		local r = hero.radius;
		local w = r*sqrt(2);
		if rect_rot_rect_Colision({x = hero.x, y=hero.y, width=w, height=w}, danger_rect[i]) then -- x = r/sqrt(2);
			hero:death();
			break;
		end
	end
	
	for i=#ability_obj, 1, -1 do
		if rect_rect_colision(ability_obj[i], ability_obj[i], hero, body) then
			if table.indexOf(hero.ability, ability_obj[i].str) == nil then
				table.insert(hero.ability, ability_obj[i].str);
			end
			ability_obj[i].hero_colision_event();
			display.remove(table.remove(ability_obj, i));
		end
	end
	
	for i=#hero_bonus_obj, 1, -1 do
		if rect_rect_colision(hero_bonus_obj[i], hero_bonus_obj[i], hero, body) then
			hero[hero_bonus_obj[i].str] = hero[hero_bonus_obj[i].str] + hero_bonus_obj[i].val;
			display.remove(table.remove(hero_bonus_obj, i));
		end
	end
end);

Runtime:addEventListener("key", function(event)
	if event.phase == "down" then
		for i=1, #hero.ability do
			if ability[hero.ability[i]].key == event.keyName then
				ability[hero.ability[i]].event();
				break;
			end
		end
	end
end);










